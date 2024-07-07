import sys, io
from queue import Queue
from threading import Thread

from mako.runtime import Context

from pyramid_mako import (
    MakoLookupTemplateRenderer,
    MakoRendererFactory,
    PkgResourceTemplateLookup,
    parse_options_from_settings,
    MakoRenderingException,
    text_error_template,
    reraise,
)

SENTINEL = object()
BUFFER_THRESHOLD = io.DEFAULT_BUFFER_SIZE


class StreamingBuffer:
    def __init__(self, template, data):
        self._queue = Queue(10)
        self._template = template
        self._thread = Thread(target=self._run, daemon=True)
        self._data = data
        self._keep_checking = True
        self._accumulator = []
        self._buffer_len = 0
        self._thread.start()

    def _run(self):
        ctx = Context(self, **self._data)
        try:
            self._template.render_context(ctx)
        except:
            try:
                exc_info = sys.exc_info()
                errtext = text_error_template().render(
                    error=exc_info[1], traceback=exc_info[2]
                )
                self._queue.put((MakoRenderingException(errtext), None, exc_info[2]))
                self._queue.put(SENTINEL)
                return
            finally:
                del exc_info

        if self._accumulator:
            self._queue.put("".join(self._accumulator).encode("utf8"))

        self._queue.put(SENTINEL)

    def write(self, value):
        self._buffer_len += len(value)
        self._accumulator.append(value)
        if self._buffer_len > BUFFER_THRESHOLD:
            self._queue.put("".join(self._accumulator).encode("utf8"))

            self._buffer_len = 0
            self._accumulator = []

    def __iter__(self):
        return self

    def __next__(self):
        if self._keep_checking:
            value = self._queue.get()
        else:
            raise StopIteration()

        if isinstance(value, tuple):
            reraise(*value)

        elif value is SENTINEL:
            self._keep_checking = False
            raise StopIteration()

        return value


class StreamingMakoLookupTemplateRenderer(MakoLookupTemplateRenderer):
    def __call__(self, value, system):
        # Update the system dictionary with the values from the user
        try:
            system.update(value)
        except (TypeError, ValueError):
            raise ValueError("renderer was passed non-dictionary as value")

        # Check if 'context' in the dictionary
        context = system.pop("context", None)

        # Rename 'context' to '_context' because Mako internally already has a
        # variable named 'context'
        if context is not None:
            system["_context"] = context

        template = self.template
        if self.defname is not None:
            template = template.get_def(self.defname)
        if system.get("_stream_result"):
            return StreamingBuffer(template, system)

        try:
            result = template.render_unicode(**system)
        except:
            try:
                exc_info = sys.exc_info()
                errtext = text_error_template().render(
                    error=exc_info[1], traceback=exc_info[2]
                )
                reraise(MakoRenderingException(errtext), None, exc_info[2])
            finally:
                del exc_info

        return result


class StreamingMakoRendererFactory(MakoRendererFactory):
    renderer_factory = staticmethod(StreamingMakoLookupTemplateRenderer)  # testing


def add_streaming_mako_renderer(config, extension, settings_prefix="mako."):
    """Register a Streaming Mako renderer for a template extension.

    This function is available on the Pyramid configurator after
    including the package:

    .. code-block:: python

       config.add_mako_renderer('.html', settings_prefix='mako.')

    The renderer will load its configuration from a prefix in the Pyramid
    settings dictionary. The default prefix is 'mako.'.
    """
    renderer_factory = StreamingMakoRendererFactory()
    config.add_renderer(extension, renderer_factory)

    def register():
        registry = config.registry
        opts = parse_options_from_settings(
            registry.settings, settings_prefix, config.maybe_dotted
        )
        lookup = PkgResourceTemplateLookup(**opts)

        renderer_factory.lookup = lookup

    config.action(("mako-streaming-renderer", extension), register)


def includeme(config):
    """Set up standard configurator registrations.  Use via:

    .. code-block:: python

       config = Configurator()
       config.include('pyramid_mako')

    Once this function has been invoked, the ``.mako`` and ``.mak`` renderers
    are available for use in Pyramid. This can be overridden and more may be
    added via the ``config.add_mako_renderer`` directive. See
    :func:`~pyramid_mako.add_mako_renderer` documentation for more information.
    """
    config.add_directive("add_mako_renderer", add_streaming_mako_renderer)

    config.add_mako_renderer(".mak")
