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

from __future__ import absolute_import
from __future__ import print_function


def _get_file_list_dir(root):
    import os

    return os.listdir(root)


def _get_file_list_html(root):
    import six.moves.urllib.request, six.moves.urllib.error, six.moves.urllib.parse
    import re

    filere = re.compile('<a href="([^"/]+)">')

    f = six.moves.urllib.request.urlopen(root)
    content = f.read()
    f.close()

    return [m.group(1) for m in filere.finditer(content)]


def get_file_list(root):
    if root.startswith("http"):
        return _get_file_list_html(root)

    return _get_file_list_dir(root)


def install_base_packages(opts):
    base_packages = set("Beaker lxml MarkupSafe pyodbc zope.interface pycrypto".split())
    files = get_file_list(opts.root)

    import os

    pyversion = "py" + opts.pyversion
    sep = "/" if opts.root.startswith("http") else os.path.sep

    root = opts.root
    if root[-1] == "/" or root[-1] == "\\":
        root = root[:-1]

    for fname in files:
        if pyversion not in fname:
            continue

        basename = fname.split("-")[0]
        if basename in base_packages:
            cmd = "easy_install -Z %s%s%s" % (opts.root, sep, fname)
            print("\n\n" + cmd)
            os.system(cmd)


def main():
    import argparse
    import sys

    parser = argparse.ArgumentParser(
        description="initialize an empty and activated virtualenv with dependencies"
    )

    parser.add_argument(
        "-p",
        "--pyversion",
        dest="pyversion",
        default=sys.version[:3],
        help="python version to use",
    )
    parser.add_argument(
        "-r",
        "--root",
        dest="root",
        default="http://cioc.info/basket/",
        help="root of the place to install the packages from",
    )

    args = parser.parse_args()
    install_base_packages(args)


if __name__ == "__main__":
    main()
