# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

import datetime
from decimal import Decimal

from pyramid.config import Configurator
from pyramid.httpexceptions import HTTPFound
from pyramid.renderers import JSON
from pyramid.settings import asbool

from pyramid.httpexceptions import HTTPNotFound, HTTPBadRequest
from pyramid.exceptions import URLDecodeError
from pyramid.view import view_config

from cioc.core import constants as const
import cioc.core.viewbase
from cioc.core.i18n import gettext as _


def invalid_path_tween_factory(handler, registry):
    def invalid_path_tween(request):
        # Due to a bug in WebOb accessing request.path (or request.path_info
        # etc) will raise UnicodeDecodeError if the requested path doesn't
        # decode with UTF-8, and this will result in a 500 Server Error from
        # our app.
        #
        # Detect this situation and send a 400 Bad Request instead.
        #
        # See:
        # https://github.com/Pylons/webob/issues/115
        # https://github.com/hypothesis/h/issues/4915
        try:
            request.path
            request.GET
        except UnicodeDecodeError:
            return HTTPBadRequest()

        return handler(request)

    return invalid_path_tween


def datetime_adapter(obj, request):
    return obj.isoformat()


def decimal_adapter(obj, request):
    return str(obj)


def notfound_view(request):
    return HTTPNotFound()


def bad_request_view(request):
    return HTTPBadRequest()


def main(global_config, **settings):
    """This function returns a Pyramid WSGI application."""

    const.update_cache_values()

    # set mako default filters
    settings["mako.imports"] = ["from markupsafe import escape_silent"]
    settings["mako.default_filters"] = ["escape_silent"]

    config = Configurator(
        settings=settings,
        root_factory="cioc.core.rootfactories.BasicRootFactory",
        request_factory="cioc.core.request.CiocRequest",
    )
    config.add_tween("cioc.web.invalid_path_tween_factory")
    json_renderer = JSON()
    json_renderer.add_adapter(datetime.datetime, datetime_adapter)
    json_renderer.add_adapter(datetime.date, datetime_adapter)
    json_renderer.add_adapter(Decimal, decimal_adapter)
    config.add_renderer("json", json_renderer)
    # The include below is a customization of pyramid_renderer that supports
    # streaming templates to the browser
    config.include("cioc.core.streamingrenderer")

    # allow for multiple templated css files with the which match parameter
    config.add_route(
        "template_css",
        r"styles/d/{version}/cioc{which:[^_]+}_{templateid:\d+}{debug:(_debug)?}.css",
        factory="cioc.core.rootfactories.BasicRootFactory",
    )
    config.add_route(
        "jquery_icons",
        "styles/d/{version}/images/ui-icons_{colour:[0-9a-zA-Z]{6}}_256x240.png",
        factory="cioc.core.rootfactories.BasicRootFactory",
    )

    config.add_static_view("styles", "cioc:styles")
    config.add_static_view("scripts", "cioc:scripts")
    config.add_static_view("images", "cioc:images")

    config.add_route(
        "cic_recentsearch",
        "recentsearch",
        factory="cioc.web.recentsearch.RecentSearchRootFactory",
    )
    config.add_route(
        "vol_recentsearch",
        "volunteer/recentsearch",
        factory="cioc.web.recentsearch.RecentSearchRootFactory",
    )

    config.add_view(
        "pyramid.view.append_slash_notfound_view",
        context="pyramid.httpexceptions.HTTPNotFound",
    )

    config.include("cioc.web.admin")
    config.include("cioc.web.cic")
    config.include("cioc.web.gbl")
    config.include("cioc.web.stats")
    config.include("cioc.web.ct")
    config.include("cioc.web.export")
    config.include("cioc.web.import_")
    config.include("cioc.web.special")
    config.include("cioc.web.vol")
    config.include("cioc.web.rpc")
    config.include("cioc.web.jsonfeeds")
    config.include("cioc.core.xmlrenderer")

    config.add_view(notfound_view, context=URLDecodeError)
    config.add_view(bad_request_view, context=HTTPBadRequest)

    if asbool(settings.get("show_db_warning_page")):
        config.add_view(
            connection_error,
            context="cioc.core.connection.ConnectionError",
            renderer="cioc.web:templates/dberror.mak",
        )

    config.scan()
    config.scan("cioc.core", ignore="cioc.core.tests")

    return config.make_wsgi_app()


def connection_error(request):
    request.response.status = "503 Service Unavailable"
    return {}


@view_config(
    context=cioc.core.viewbase.ErrorPage, renderer="cioc.web:templates/error.mak"
)
class ErrorPageView(cioc.core.viewbase.ViewBase):
    def __call__(self):
        context = self.request.exception
        title = context.title
        if not title:
            title = _("Error", self.request)

        return self._create_response_namespace(
            title, title, dict(ErrMsg=context.ErrMsg), no_index=True, show_message=True
        )
