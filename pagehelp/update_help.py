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

import xml.etree.cElementTree as ET
import os, codecs

from cioc.core.utils import read_file, write_file
from cioc.db.adohelper import *


def get_connection_string():
    tree = ET.parse(os.path.join("..", "web.config"))
    root = tree.getroot()
    for el in root.findall(".//appSettings/add"):
        if el.attrib["key"] == "cioc_cnn_e":
            return el.attrib["value"]

    return None


def perform_update(to_database=True):
    """
    If to_database is True, send the page help on disk to the database.
    If to_database is False, get the page help from the database and save it to disk.

    Returns the set of files on disk that have no corresponding PageInfo entry in the database
    """
    conn_str = get_connection_string()
    conn = get_connection(conn_str)

    allfiles = set(
        fn for fn in os.listdir(".") if os.path.isfile(fn) and fn.endswith(".htm")
    )

    dstrs = Recordset()
    dstrs.Open(
        "GBL_PageInfo", conn, ado.adOpenKeyset, ado.adLockOptimistic, ado.adCmdTable
    )

    dstrs.MoveFirst()
    while not dstrs.EOF:
        row = row_dict(dstrs)
        pagename = row["PageName"]
        fname = pagename[:-3].replace("/", "-") + "htm"
        allfiles.discard(fname)
        if to_database:
            if not os.path.exists(fname):
                dstrs.MoveNext()
                continue
            d = read_file(fname)
            dstrs.Fields("PageHelp").Value = d.encode("latin1").replace("\n", "\r\n")
            dstrs.Update()

        else:
            if row["PageHelp"] is None:
                dstrs.MoveNext()
                continue

            write_file(fname, row["PageHelp"])

        dstrs.MoveNext()

    dstrs.Close()
    dstrs = None
    conn.Close()
    conn = None

    return allfiles


def main(argv):
    from optparse import OptionParser

    parser = OptionParser()
    parser.add_option(
        "-g",
        "--get",
        dest="to_database",
        action="store_false",
        help="get page help from the database",
    )
    parser.set_defaults(to_database=True)
    (options, args) = parser.parse_args(argv)

    missed_files = perform_update(options.to_database)
    if not missed_files:
        return

    print("There are files not in the database:")
    for fname in sorted(missed_files):
        print("\t", fname)


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
