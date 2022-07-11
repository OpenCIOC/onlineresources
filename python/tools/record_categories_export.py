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

import argparse
import codecs
import csv
import os
import subprocess
import sys

from tools.toolslib import Context

from cioc.core import constants as const


def export(args, conn, filename, sql):
    filename = os.path.join(args.destdir, filename)
    with open(filename, "wb") as fd:
        with conn.execute(sql) as cursor:
            fd.write(codecs.BOM_UTF8)
            writer = csv.writer(fd)
            writer.writerow([d[0] for d in cursor.description])
            while True:
                rows = cursor.fetchmany(10000)
                if not rows:
                    break

                writer.writerows(
                    tuple(y.encode("utf-8") if isinstance(y, str) else y for y in x)
                    for x in rows
                )

    return filename


def export_distributions(args, conn):
    return export(
        args,
        conn,
        "distributions.csv",
        """
        SELECT pr.NUM, dst.DistCode
        FROM CIC_Distribution AS dst
        INNER JOIN CIC_BT_DST AS pr ON dst.DST_ID = pr.DST_ID
        INNER JOIN dbo.CIC_BT_EXTRA_TEXT et ON et.NUM=pr.NUM AND et.FieldName='EXTRA_ICAROLFILECOUNT'
        """,
    )


def export_headings(args, conn):
    return export(
        args,
        conn,
        "headings.csv",
        """
        SELECT pbr.NUM, pb.PubCode,
            CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, 0) ELSE ISNULL(ghne.Name,ghnf.Name) END AS HeadingName,
            CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, 0) ELSE ghne.Name END AS HeadingNameEn,
            CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, 2) ELSE ghnf.Name END AS HeadingNameFr
        FROM CIC_Publication AS pb
        INNER JOIN CIC_BT_PB AS pbr ON pb.PB_ID = pbr.PB_ID
        INNER JOIN CIC_BT_PB_GH AS ghr ON pbr.BT_PB_ID = ghr.BT_PB_ID
        INNER JOIN CIC_GeneralHeading AS gh ON gh.GH_ID = ghr.GH_ID
        LEFT JOIN CIC_GeneralHeading_Name AS ghne ON gh.GH_ID = ghne.GH_ID AND ghne.LangID=0
        LEFT JOIN CIC_GeneralHeading_Name AS ghnf ON gh.GH_ID = ghnf.GH_ID AND ghnf.LangID=2
        INNER JOIN dbo.CIC_BT_EXTRA_TEXT et ON et.NUM=pbr.NUM AND et.FieldName='EXTRA_ICAROLFILECOUNT'
        """,
    )


def export_publications(args, conn):
    return export(
        args,
        conn,
        "publications.csv",
        """
        SELECT pbr.NUM, pb.PubCode,
            ISNULL(pbne.Name,pbnf.Name) AS Name,
            pbne.Name AS NameEn,
            pbnf.Name AS NameFr
        FROM CIC_Publication AS pb
        INNER JOIN CIC_BT_PB AS pbr ON pb.PB_ID = pbr.PB_ID
        LEFT JOIN CIC_Publication_Name AS pbne ON pb.PB_ID = pbne.PB_ID AND pbne.LangID=0
        LEFT JOIN CIC_Publication_Name AS pbnf ON pb.PB_ID = pbnf.PB_ID AND pbnf.LangID=2
        INNER JOIN dbo.CIC_BT_EXTRA_TEXT et ON et.NUM=pbr.NUM AND et.FieldName='EXTRA_ICAROLFILECOUNT'
        """,
    )


def export_recordowners(args, conn):
    return export(
        args,
        conn,
        "recordowners.csv",
        """
        SELECT bt.NUM, sl.Culture, a.AgencyCode, dbo.fn_GBL_DisplayFullOrgName_Agency_2(btda.NUM,btda.ORG_LEVEL_1,btda.ORG_LEVEL_2,btda.ORG_LEVEL_3, btda.ORG_LEVEL_4, btda.ORG_LEVEL_5, btda.LOCATION_NAME, btda.SERVICE_NAME_LEVEL_1, btda.SERVICE_NAME_LEVEL_2) AS AgencyName
        FROM dbo.GBL_Agency a
        INNER JOIN dbo.GBL_BaseTable bt ON bt.RECORD_OWNER=a.AgencyCode
        INNER JOIN dbo.GBL_BaseTable_Description btd ON btd.NUM=bt.NUM
        INNER JOIN dbo.STP_Language sl ON btd.LangID=sl.LangID
        INNER JOIN CIC_BT_EXTRA_TEXT et ON bt.NUM=et.NUM AND et.FieldName='EXTRA_ICAROLFILECOUNT' AND et.LangID = btd.LangID
        LEFT JOIN dbo.GBL_BaseTable_Description btda ON a.AgencyNUMCIC=btda.NUM AND btda.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_BaseTable_Description btdax WHERE btdax.NUM=btda.NUM ORDER BY CASE WHEN btdax.LangID=btd.LangID THEN 0 ELSE 1 END, btdax.LangID)
        """,
    )


def export_all(args, context):
    files = []
    with context.connmgr.get_connection("admin") as conn:
        files.append(export_distributions(args, conn))
        files.append(export_headings(args, conn))
        files.append(export_publications(args, conn))
        files.append(export_recordowners(args, conn))

    return files


def maybe_run_after_cmd(context, files):
    after_cmd = context.config.get("record_categories_run_after_cmd")
    if after_cmd:
        os.environ["CSVFILES"] = " ".join(files)
        p = subprocess.Popen(after_cmd, shell=True, cwd=context.args.destdir)
        p.wait()


def parse_args(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--config", dest="configfile", action="store", default=const._config_file
    )
    parser.add_argument("destdir", metavar="destdir", action="store")

    args = parser.parse_args(argv)

    return args


def main(argv):
    args = parse_args(argv)
    context = Context(args)
    files = export_all(args, context)
    maybe_run_after_cmd(context, files)


if __name__ == "__main__":
    normalstdout = sys.stdout
    normalstderr = sys.stderr
    try:
        sys.exit(main(sys.argv[1:]))
    except Exception:
        sys.stdout = normalstdout
        sys.stderr = normalstderr

        raise
