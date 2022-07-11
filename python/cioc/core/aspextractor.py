from babel.messages.extract import extract_python


class ReadlineCountingProxy:
    def __init__(self, fileobj):
        self.fileobj = fileobj
        self.count = 0
        self.in_python = False
        self.python_start = 0
        self.in_parse_encoding = False

    def readline(self, size=0):
        if self.in_parse_encoding:
            return self.fileobj.readline()

        self.count += 1
        line = self.fileobj.readline()
        if self.in_python:
            if line.strip() == "</script>":
                self.in_python = False
                self.count += 1
                line = self.fileobj.readline()
            else:
                return line

        while line:
            if (
                line.startswith("<script ")
                and 'language="python"' in line
                and 'runat="server"' in line
            ):
                self.in_python = True
                self.python_start = self.count - 1
                return self.readline()

            self.count += 1
            line = self.fileobj.readline()

        return ""

    def __getattr__(self, key):
        return getattr(self.fileobj, key)

    def seek(self, pos):
        self.in_parse_encoding = not self.in_parse_encoding
        return self.fileobj.seek(pos)


def extract_asp(fileobj, keywords, comment_tags, options):
    """Extract messages from asp files.

    :param fileobj: the file-like object the messages should be extracted from
    :param keywords: a list of keywords (i.e. function names) that should be recognized as translation functions
    :param comment_tags: a list of translator tags to search for and include in the results
    :param options: a dictionary of additional options (optional)
    :return: an iterator over ``(lineno, funcname, message, comments)`` tuples
    :rtype: ``iterator``
    """

    proxy = ReadlineCountingProxy(fileobj)

    for (lineno, funcname, message, comments) in extract_python(
        proxy, keywords, comment_tags, options
    ):
        yield (lineno + proxy.python_start, funcname, message, comments)
