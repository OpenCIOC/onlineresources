from itertools import zip_longest


def read_file(fname, encoding="utf-8"):
    with open(fname, encoding=encoding) as f:
        return f.read()


def write_file(fname, content, encoding="utf-8"):
    with open(fname, "w", encoding=encoding) as f:
        f.write(content)


def grouper(n, iterable, fillvalue=None):
    "grouper(3, 'ABCDEFG', 'x') --> ABC DEF Gxx"
    args = [iter(iterable)] * n
    return zip_longest(fillvalue=fillvalue, *args)
