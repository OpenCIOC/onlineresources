from __future__ import absolute_import

import six
from six.moves import zip_longest

if six.PY2:

    def read_file(fname, encoding="utf-8"):
        with open(fname, "rU") as f:
            return f.read().decode(encoding)

    def write_file(fname, content, encoding="utf-8"):
        with open(fname, "w") as f:
            f.write(content.encode(encoding))

else:

    def read_file(fname, encoding="utf-8"):
        with open(fname, "r", encoding=encoding) as f:
            return f.read()

    def write_file(fname, content, encoding="utf-8"):
        with open(fname, "w", encoding=encoding) as f:
            f.write(content)


def grouper(n, iterable, fillvalue=None):
    "grouper(3, 'ABCDEFG', 'x') --> ABC DEF Gxx"
    args = [iter(iterable)] * n
    return zip_longest(fillvalue=fillvalue, *args)
