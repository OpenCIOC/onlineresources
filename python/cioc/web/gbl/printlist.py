# =========================================================================================
#  Copyright 2024 KCL Software Solutions Inc.
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

import itertools
import logging
import os
import re
import shutil
import subprocess
import sys
import tempfile

from collections import defaultdict
from functools import partial
from operator import attrgetter

log = logging.getLogger(__name__)

from pyramid.view import view_config
from pyramid.renderers import render, render_to_response
from textwrap import dedent

from markupsafe import Markup

try:
    os.environ["PATH"] = r"c:\msys64\mingw64\bin;" + os.environ["PATH"]
    from weasyprint import HTML
    from weasyprint.text.fonts import FontConfiguration
except Exception:
    log.exception(
        "Unable to import weasyprint, pango dependency probably not installed"
    )
    HTML = FontConfiguration = None

from cioc.core import listformat, viewbase, template, validators, constants as const
from cioc.core.i18n import gettext as _
from cioc.core.format import textToHTML
from cioc.core.webobfiletool import FileIterator
from cioc.core.security import sanitize_html_description

default_template = "cioc.web.gbl:templates/printlist/index.mak"

RECORD_FETCH_BATCH_SIZE = 1000

fix_replace_string_number = re.compile(r"\$([0-9]+)")
fix_replace_string_amp = re.compile(r"\$&")

if sys.prefix != sys.base_prefix:
    PYTHON_EXE = os.path.join(sys.prefix, "scripts", "python.exe")
else:
    PYTHON_EXE = os.path.join(sys.prefix, "python.exe")

PDF_GEN_MAX_MEM_IN_GB = 1
PDF_BASE_COMMAND = [
    PYTHON_EXE,
    "-m",
    "weasyprint",
    "-e",
    "utf-8",
]
PROCGOV_EXE = shutil.which("procgov64")
if PROCGOV_EXE:
    PDF_BASE_COMMAND = [
        PROCGOV_EXE,
        f"--maxmem={PDF_GEN_MAX_MEM_IN_GB}G",
        "--terminate-job-on-exit",
        "-r",
        "--",
    ] + PDF_BASE_COMMAND


class PrintListSchemaBase(validators.RootSchema):
    ignore_key_missing = True
    if_key_missing = None

    Picked = validators.Bool()
    ProfileID = validators.IDValidator(if_invalid=None)
    Msg = validators.String()
    ReportTitle = validators.String(max=255, if_invalid=None)

    IncludeDeleted = validators.Bool()
    IncludeNonPublic = validators.Bool()
    OutputPDF = validators.Bool()


class CICPrintListSchema(PrintListSchemaBase):
    GHPBID = validators.IDValidator(if_invalid=None)

    PBType = validators.OneOf(["A", "N", "AF", "F"], if_invalid=None)

    PBID = validators.CSVForEach(validators.IDValidator, if_invalid=None)
    incPBID = validators.CSVForEach(validators.IDValidator, if_invalid=None)
    PBIDx = validators.CSVForEach(validators.IDValidator, if_invalid=None)

    GHType = validators.OneOf(["A", "N", "AF", "F"], if_invalid=None)
    GHID = validators.CSVForEach(validators.IDValidator, if_invalid=None)
    GHIDx = validators.CSVForEach(validators.IDValidator, if_invalid=None)

    SortBy = validators.OneOf(["O", "H"], if_invalid=None)
    IncludeTOC = validators.Bool()
    IncludeIndex = validators.Bool()

    CMType = validators.OneOf(["S", "L"], if_invalid=None)
    CMID = validators.CSVForEach(validators.IDValidator, if_invalid=None)

    # The IndexType option is from the customreport page. It provides an
    # override to the SortBy, IncludeTOC, and IncludeIndex Options.
    IndexType = validators.OneOf(["N", "T"], if_invalid=None)

    IDList = validators.CSVForEach(validators.NumValidator(), if_invalid=None)


class VOLPrintListSchema(PrintListSchemaBase):
    IDList = validators.CSVForEach(validators.VNumValidator(), if_invalid=None)

    IncludeExpired = validators.Bool()
    SortBy = validators.OneOf(["O", "P", "C", "M"], if_invalid=None)


def record_result_batcher(first_batch, cursor, batch_size=RECORD_FETCH_BATCH_SIZE):
    yield first_batch
    while True:
        batch = cursor.fetchmany(batch_size)
        if not batch:
            return
        yield batch


def prepare_find_replace(definition):
    flags = re.ASCII
    if not definition.MatchCase:
        flags |= re.IGNORECASE

    look_for = definition.LookFor
    replace_with = definition.ReplaceWith or ""
    if not definition.RegEx:
        look_for = re.escape(look_for)
        replace_with = replace_with.replace("\\", "\\\\")
    else:
        replace_with = fix_replace_string_amp.sub(
            r"\\g<0>", fix_replace_string_number.sub(r"\\\1", replace_with)
        )

    count = 0 if definition.MatchAll else 1

    regex = re.compile(look_for, flags)
    return partial(regex.sub, replace_with, count=count)


def process_field_contents(records, fields, find_and_replace):
    for i, record in enumerate(records):
        values = []
        for field in fields:
            contents = getattr(record, field.FieldName)
            if contents is None:
                values.append("")
                continue

            if not isinstance(contents, str):
                contents = str(contents)

            if not contents:
                values.append("")
                continue

            for fn in find_and_replace[field.PFLD_ID]:
                contents = fn(contents)

            values.append(
                Markup((field.Prefix or "").replace("##", str(i)))
                + (textToHTML(contents) or "")
                + Markup((field.Suffix or "").replace("##", str(i)))
            )
        yield record, values


class PrintListBase(viewbase.ViewBase):
    def __init__(self, request):
        super().__init__(request, True)

    def get_validator(self):
        raise NotImplementedError()

    def __call__(self):
        if self.request.method == "POST":
            return self.post()

        return self.get()

    def get(self, require_id_list=True):
        request = self.request

        model_state = request.model_state
        model_state.variable_decode = True
        model_state.schema = self.get_validator()
        model_state.method = None

        return self.get_edit_info(require_id_list=require_id_list)

    def render_form_and_get_bottomjs_fn(self):
        response_namespace = self.get(False)
        form = template.render_template(
            "cioc.web.gbl:templates/printlist/printoptions#printlist_form.mak",
            response_namespace,
            None,
            self.request,
        )

        def bottomjs():
            return Markup(
                template.render_template(
                    "cioc.web.gbl:templates/printlist/printoptions#bottomjs.mak",
                    response_namespace,
                    None,
                    self.request,
                )
            )

        return form, bottomjs

    def _render_error_page(self, error_message, pagetitle=None, show_close=True):
        request = self.request
        pagetitle = pagetitle or _("Print Record List", request)
        return self._render_to_response(
            "cioc.web:templates/error.mak",
            pagetitle,
            pagetitle,
            {
                "ErrMsg": error_message
                + (
                    (
                        ' <a href="javascript:parent.close()">'
                        + _("Close Window", request)
                        + "</a>"
                    )
                    if show_close
                    else ""
                )
            },
        )

    def post(self):
        request = self.request

        model_state = request.model_state
        model_state.schema = self.get_validator()

        if not model_state.validate():
            # TODO this should not happen
            return self.get_edit_info(_("Validation Error"))

        profile_id = None
        if request.user:
            profile_id = model_state.value("ProfileID")
        else:
            profile_id = request.viewdata.dom.DefaultPrintProfile
            if profile_id is None:
                return self._security_failure()

        if profile_id is None:
            return self._render_error_page(_("No Print Profile was chosen.", request))
        if request.pageinfo.DbArea not in [const.DM_CIC, const.DM_VOL]:
            return self._render_error_page(
                _("No records were chosen to print.", request)
            )

        if not model_state.value("Picked"):
            with request.connmgr.get_connection("admin") as conn:
                cursor = conn.execute(
                    f"EXEC dbo.sp_GBL_PrintProfile_Msg_s ?, ?, ?",
                    profile_id,
                    request.viewdata.dom.ViewType,
                    request.pageinfo.DbArea,
                )
                profile = cursor.fetchone()

            if not profile:
                return self._render_error_page(
                    _("Could not find print profile.", request)
                )

            title = _("Print Record List")
            model_state.form.data.pop("Msg", None)
            model_state.form.data["Picked"] = True
            return self._render_to_response(
                "cioc.web.gbl:templates/printlist/message.mak",
                title,
                title,
                {"profile": profile},
            )

        where_clause = []
        where_arguments = []

        self.get_where_clause(where_clause, where_arguments)
        where_sql = " AND ".join(where_clause)

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                f"EXEC dbo.sp_{request.pageinfo.DbAreaS}_PrintProfile_sf ?, ?",
                profile_id,
                request.viewdata.dom.ViewType,
            )
            profile = cursor.fetchone()
            if not profile:
                return self._render_error_page(
                    _("No Print Profile was chosen", request), show_close=False
                )
            cursor.nextset()

            find_and_replace = defaultdict(list)
            for x in cursor.fetchall():
                find_and_replace[x.PFLD_ID].append(prepare_find_replace(x))

            cursor.nextset()
            fields = cursor.fetchall()
            cursor.close()

            extra_namespace = self.get_extra_namespace(conn, where_sql, where_arguments)

        field_sql = ", ".join(x.FieldSelect for x in fields)
        if field_sql:
            field_sql = ", " + field_sql
        printlist_sql = self.build_sql(field_sql, where_sql, where_arguments)

        try:
            cursor = request.connmgr.get_connection("admin").execute(
                printlist_sql, where_arguments
            )
        except Exception:
            log.exception(
                "error running sql. sql=%s, arguments=%s",
                printlist_sql,
                where_arguments,
            )
            raise

        log.debug("records sql=%s, arguments=%s", printlist_sql, where_arguments)

        first_batch = cursor.fetchmany(RECORD_FETCH_BATCH_SIZE)
        if not first_batch:
            return self._render_error_page(
                _("No records were chosen to print.", request),
                pagetitle=profile.PageTitle,
                show_close=False,
            )

        record_batch_iterator = record_result_batcher(first_batch, cursor)
        records_iterator = process_field_contents(
            itertools.chain.from_iterable(record_batch_iterator),
            fields,
            find_and_replace,
        )
        records_iterator = self.extra_records_processing(records_iterator)
        message = None
        if request.user:
            message = model_state.value("Msg")

        report_title = model_state.value("ReportTitle", profile.PageTitle)

        namespace = self._create_response_namespace(
            _(profile.PageTitle, request),
            _(profile.PageTitle, request),
            {
                "profile": profile,
                "fields": fields,
                "grouped_records": records_iterator,
                "message": Markup(sanitize_html_description(message))
                if message
                else None,
                "report_title": report_title,
                "_stream_result": True,
                **extra_namespace,
            },
            request,
        )
        renderer_args = ("cioc.web.gbl:templates/printlist/printlist.mak", namespace)
        if model_state.value("OutputPDF") and HTML and FontConfiguration:
            result = render(*renderer_args)
            resp = request.response
            with tempfile.TemporaryFile(suffix=".html") as f:
                f.writelines(result)
                file_size_in_gb = round(f.tell() / 1024 / 1024, 2)
                log.debug("Wrote %sGB to html file", file_size_in_gb)
                if file_size_in_gb >= PDF_GEN_MAX_MEM_IN_GB:
                    return self._render_error_page(
                        _(
                            "Report to large. Please reduce the number of records in the report.",
                            request,
                        ),
                        show_close=False,
                    )
                f.seek(0)
                outf = tempfile.TemporaryFile(suffix=".pdf")
                cmd = PDF_BASE_COMMAND + [
                    "--base-url",
                    request.path_url,
                    "-q",
                    "-",
                    "-",
                ]
                result = subprocess.run(
                    cmd, stdin=f, stdout=outf, stderr=subprocess.PIPE
                )
                if result.returncode:
                    if b"MemoryError" in result.stderr:
                        errmsg = _(
                            "Report to large. Please reduce the number of records in the report.",
                            request,
                        )
                    else:
                        log.error("Printlist PDF Generation Error: %r", result.stderr)
                        errmsg = _(
                            "Unable to generate report, please reduce the number of records and try again.",
                            request,
                        )
                    return self._render_error_page(
                        errmsg,
                        show_close=False,
                    )

                outf.seek(0, 2)
                length = outf.tell()
                outf.seek(0)
                resp.content_length = length
                resp.charset = None
                resp.app_iter = FileIterator(outf)
                resp.content_type = "application/pdf"
                return resp

        return render_to_response(*renderer_args)

    def get_extra_namespace(self, conn, where_sql, where_arguments):
        return {
            "name_toc": False,
            "heading_toc": False,
            "name_index": False,
            "heading_groups": None,
            "org_names": None,
        }

    def extra_records_processing(self, records_iterator):
        return [(None, [(None, records_iterator)])]

    def build_sql(self, field_sql, where_sql, arguments):
        raise NotImplementedError()

    def get_where_clause(self, where_clause, arguments):
        request = self.request
        model_state = request.model_state
        dbareas = request.pageinfo.DbAreaS
        if model_state.value("IncludeDeleted"):
            view_where_name = f"WhereClause{dbareas}"
        else:
            view_where_name = f"WhereClause{dbareas}NoDel"

        view_where = getattr(request.viewdata, view_where_name).replace(
            "AND shp.Active=1", "AND shp.Active=1 AND shp.CanUsePrint=1"
        )
        where_clause.append(f"({view_where})")
        if request.viewdata.dom.CanSeeNonPublic and not model_state.value(
            "IncludeNonPublic"
        ):
            tbl = "vod" if request.pageinfo.DbArea == const.DM_VOL else "btd"
            where_clause.append(f"({tbl}.NON_PUBLIC = 0)")

    def get_extra_edit_info_sql(
        self, statements, arguments, recordsets, DbAreaS, namespace
    ):
        return

    def get_edit_info_sql(self, namespace):
        request = self.request
        DbAreaS = self.request.pageinfo.DbAreaS
        statements = [
            f"""
            Declare @MemberID int = ?, @ViewType int = ?
            EXEC sp_{DbAreaS}_PrintProfile_l @MemberID, @ViewType"""
        ]
        arguments = [
            request.dboptions.MemberID,
            request.viewdata.ViewType,
        ]
        recordsets = [("printprofiles", partial(map, tuple))]

        self.get_extra_edit_info_sql(
            statements, arguments, recordsets, DbAreaS, namespace
        )

        return "\n".join(statements), arguments, recordsets

    def get_edit_info(self, ErrMsg=None, require_id_list=False):
        request = self.request

        model_state = request.model_state

        if not model_state.validate():
            # form error
            ErrMsg = _("There were validation errors.", request)

        idlist = model_state.value("IDList")
        if idlist and isinstance(idlist, list):
            # need to ensure that IDList is a Comma Separated List
            idlist = ",".join(str(x) for x in idlist)
            model_state.form.data["IDList"] = idlist

        title = _("Print Record List")
        if require_id_list and request.pageinfo.DbArea == const.DM_VOL and not idlist:
            return self._create_response_namespace(
                title,
                title,
                {
                    "ErrMsg": _("No records were chosen to prinnt"),
                    "only_show_error": True,
                },
            )

        with request.connmgr.get_connection("admin") as conn:
            namespace = {}
            sql, arguments, recordsets = self.get_edit_info_sql(namespace)
            cursor = conn.execute(sql, *arguments)
            for i, (name, formatter) in enumerate(recordsets):
                if i:
                    cursor.nextset()
                values = cursor.fetchall()
                if formatter:
                    values = formatter(values)
                namespace[name] = values

        return self._create_response_namespace(
            title,
            title,
            {
                "ErrMsg": ErrMsg,
                "only_show_error": False,
                **namespace,
            },
            no_index=True,
        )


@view_config(route_name="print_list_cic", renderer=default_template)
class PrintRecordListCIC(PrintListBase):
    def get_validator(self):
        return CICPrintListSchema()

    def get_ghpbid(self):
        # extra logic to handle mutually exclusive options
        request = self.request
        if request.viewdata.cic.LimitedView:
            ghpbid = request.viewdata.cic.PB_ID
        else:
            ghpbid = request.model_state.value("GHPBID")

        return ghpbid

    def get_where_clause(self, where_clause, arguments):
        model_state = self.request.model_state

        # The IndexType option is from the customreport page. It provides an
        # override to the SortBy, IncludeTOC, and IncludeIndex Options.
        index_type = model_state.value("IndexType")
        if index_type:
            if index_type == "N":
                # Sort by Name and include Name index
                model_state.form.data["SortBy"] = "O"
                model_state.form.data["IncludeTOC"] = False
                model_state.form.data["IncludeIndex"] = True
            else:
                # Sort By Topic (Heading) and include Heading TOC and Name index
                model_state.form.data["SortBy"] = "H"
                model_state.form.data["IncludeTOC"] = True
                model_state.form.data["IncludeIndex"] = True

        ghpbid = self.get_ghpbid()
        ghtype = model_state.value("GHType")
        if (not ghpbid or ghtype == "N") and model_state.value("SortBy") == "H":
            # sort by Heading is meaningless without ghpbid or if GHType is N (Has None)
            model_state.form.data["SortBy"] = "O"

        pbtype = model_state.value("PBType")

        pbid = None
        if ghpbid:
            pbtype = None
        else:
            pbid = model_state.value("PBID")
            if not pbid:
                pbid = model_state.value("incPBID")

        if pbtype == "A":
            where_clause.append(
                "(EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM))"
            )
        elif pbtype == "N":
            where_clause.append(
                "(NOT EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM))"
            )
        elif pbid:
            pbid = set(pbid)
            arguments.extend(sorted(pbid))
            if pbtype == "AF":
                where_clause.append(
                    "("
                    + " AND ".join(
                        [
                            "EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM AND pb.PB_ID=?)"
                        ]
                        * len(pbid)
                    )
                    + ")"
                )
            else:
                where_clause.append(
                    "(EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM AND pb.PB_ID IN ("
                    + ",".join("?" * len(pbid))
                    + ")))"
                )
        pbidx = model_state.value("PBIDx")
        if pbidx:
            pbidx = set(pbidx)
            arguments.extend(sorted(pbidx))
            where_clause.append(
                "(NOT EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM AND pb.PB_ID IN ("
                + ",".join("?" * len(pbidx))
                + ")))"
            )

        ghtype = model_state.value("GHType")
        ghid = model_state.value("GHID")
        if ghtype == "A":
            if ghpbid:
                arguments.append(ghpbid)
                where_clause.append(
                    "(EXISTS(SELECT * FROM CIC_BT_PB_GH gh INNER JOIN CIC_BT_PB pb ON gh.BT_PB_ID = pb.BT_PB_ID"
                    " WHERE pb.NUM=bt.NUM and pb.PB_ID=?))"
                )
        elif ghtype == "N":
            if ghpbid:
                arguments.append(ghpbid)
                where_clause.append(
                    "(EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM AND pb.PB_ID=?"
                    " AND NOT EXISTS(SELECT * FROM CIC_BT_PB_GH gh WHERE gh.BT_PB_ID = pb.BT_PB_ID)))"
                )
        elif ghid:
            ghid = set(ghid)
            arguments.extend(sorted(ghid))
            if ghtype == "AF":
                where_clause.append(
                    "("
                    + " AND ".join(
                        [
                            "EXISTS(SELECT * FROM CIC_BT_PB_GH gh "
                            "INNER JOIN CIC_BT_PB pb ON gh.BT_PB_ID = pb.BT_PB_ID "
                            "WHERE pb.NUM=bt.NUM AND gh.GH_ID=?)"
                        ]
                        * len(ghid)
                    )
                    + ")"
                )
            else:
                where_clause.append(
                    "(EXISTS(SELECT * FROM CIC_BT_PB_GH gh "
                    "WHERE gh.NUM_Cache=bt.NUM AND gh.GH_ID IN ("
                    + ",".join("?" * len(ghid))
                    + ")))"
                )
        ghidx = model_state.value("GHIDx")
        if ghidx and ghpbid:
            ghidx = set(ghidx)
            arguments.append(ghpbid)
            arguments.extend(sorted(ghidx))
            where_clause.append(
                "(EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM AND pb.PB_ID=?"
                " AND NOT EXISTS(SELECT * FROM CIC_BT_PB_GH gh WHERE gh.BT_PB_ID = pb.BT_PB_ID AND gh.GH_ID IN ("
                + ",".join("?" * len(ghidx))
                + "))))"
            )

        idlist = model_state.value("IDList")
        if idlist:
            idlist = set(idlist)
            arguments.extend(sorted(idlist))
            where_clause.append("(bt.NUM IN (" + ",".join("?" * len(idlist)) + "))")

        cmidlist = model_state.value("CMID")
        if cmidlist:
            cmidlist = set(cmidlist)
            arguments.append(",".join(str(x) for x in cmidlist))
            if model_state.value("CMType") == "L":
                where_clause.append(
                    "(bt.LOCATED_IN_CM IS NULL OR bt.LOCATED_IN_CM IN (SELECT CM_ID FROM dbo.fn_GBL_Community_Search_rst(?)))"
                )
            else:
                where_clause.append(
                    dedent("""\
                    (EXISTS(
                        SELECT * 
                        FROM CIC_BT_CM cm 
                        INNER JOIN dbo.fn_GBL_Community_Search_rst(?) cl
                            ON cl.CM_ID=cm.CM_ID
                        WHERE cm.NUM=bt.NUM))""")
                )

        return super().get_where_clause(where_clause, arguments)

    def get_extra_edit_info_sql(
        self, statements, arguments, recordsets, DbAreaS, namespace
    ):
        request = self.request
        if not request.user.cic.LimitedView:
            statements.append("""EXEC dbo.sp_CIC_Publication_l @ViewType, 0, 0""")
            format_pubs = (
                partial(
                    listformat.format_pub_list,
                    flag_non_public=True,
                    pub_names_only=request.viewdata.cic.UsePubNamesOnly,
                ),
            )
            recordsets.append(("publications", None))

            statements.append("""EXEC dbo.sp_CIC_Publication_l @ViewType, 1, NULL""")
            recordsets.append(("publicationsgh", None))
            namespace["generalheadings"] = []

        else:
            arguments.extend(
                [request.user.PB_ID, request.viewdata.cic.CanSeeNonPublicPub]
            )
            statements.append(
                """EXEC dbo.sp_CIC_GeneralHeading_l @MemberID, ? NULL, ?, 0"""
            )
            recordsets.append(("generalheadings", None))

    def get_extra_namespace(self, conn, where_sql, where_arguments):
        model_state = self.request.model_state
        sortby = model_state.value("SortBy")
        ghpbid = self.get_ghpbid()
        ghid = model_state.value("GHID")
        ghtype = model_state.value("GHType")
        include_toc = model_state.value("IncludeTOC")
        heading_toc = include_toc and sortby == "H" and ghpbid and ghtype != "N"
        name_toc = include_toc and sortby != "H"
        name_index = (
            model_state.value("IncludeIndex")
            and sortby == "H"
            and ghpbid
            and ghtype != "N"
        )

        sql_parts = []
        arguments = []
        if heading_toc:

            def header_process(cursor):
                groupgetter = attrgetter("GroupDisplayOrder", "Group", "GroupID")
                groups = []
                for group_key, headings in itertools.groupby(
                    cursor.fetchall(), key=groupgetter
                ):
                    groups.append((group_key, list(headings)))
                return groups

            args = [
                ghpbid,
                self.request.dboptions.MemberID,
                ghpbid,
            ]

            group_limit = ""
            if ghid and (ghtype == "AF" or ghtype == "F"):
                ghid = set(ghid)
                ghplaceholders = ",".join("?" * len(ghid))
                args.extend(ghid)
                group_limit = f" AND gh.GH_ID IN ({ghplaceholders}) "

            arguments.extend(args)
            arguments.extend(where_arguments)
            sql_parts.append(
                (
                    "heading_groups",
                    header_process,
                    dedent(f"""\
            SELECT gh.GH_ID, ISNULL(CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE CASE WHEN ghn.LangID=@@LANGID THEN ghn.Name ELSE '[' + ghn.Name + ']' END END,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']') AS GeneralHeading,
                    ghgn.GroupID, ghgn.Name AS [Group],
                    gh.IconNameFull, ghgn.IconNameFull AS IconNameFullGroup, ghgn.DisplayOrder AS GroupDisplayOrder, gh.DisplayOrder AS HeadingDisplayOrder
                FROM CIC_Publication pb
                INNER JOIN CIC_GeneralHeading gh
                    ON pb.PB_ID=gh.PB_ID
                LEFT JOIN CIC_GeneralHeading_Name ghn
                    ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
                LEFT JOIN (SELECT ghg.GroupID, DisplayOrder, Name, ghg.IconNameFull
                            FROM CIC_GeneralHeading_Group ghg
                            INNER JOIN CIC_GeneralHeading_Group_Name ghgn
                                ON ghg.GroupID=ghgn.GroupID AND ghgn.LangID=@@LANGID
                            WHERE ghg.PB_ID=?) ghgn
                    ON gh.HeadingGroup=ghgn.GroupID
            WHERE (pb.MemberID=? OR pb.MemberID IS NULL)
                AND pb.PB_ID=? {group_limit}
                AND (Used=1 OR Used IS NULL)
                AND (gh.NonPublic=0)
                AND EXISTS(SELECT *
                {self.base_from}
                INNER JOIN CIC_BT_PB pb
                    ON bt.NUM=pb.NUM
                INNER JOIN CIC_BT_PB_GH pr
                    ON pb.BT_PB_ID=pr.BT_PB_ID
                WHERE pr.GH_ID=gh.GH_ID AND {where_sql}
                )
            ORDER BY ISNULL(ghgn.DisplayOrder,0), ISNULL(ghgn.Name, CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE CASE WHEN ghn.LangID=@@LANGID THEN ghn.Name ELSE '[' + ghn.Name + ']' END END), gh.DisplayOrder, CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE CASE WHEN ghn.LangID=@@LANGID THEN ghn.Name ELSE '[' + ghn.Name + ']' END END"""),
                )
            )

        if name_index or name_toc:
            arguments.extend(where_arguments)

            def name_process(cursor):
                return cursor.fetchall()

            sql_parts.append(
                (
                    "org_names",
                    name_process,
                    dedent(f"""\
                    SELECT bt.NUM AS XNUM, dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL
                    {self.base_from}
                    WHERE {where_sql}
                    ORDER BY {self.base_sort}"""),
                )
            )

        namespace = {
            "heading_toc": heading_toc,
            "name_toc": name_toc,
            "name_index": name_index,
            "heading_groups": None,
            "org_names": None,
        }
        if sql_parts:
            sql = "\n".join(x[-1] for x in sql_parts)
            log.debug("extra sql=%s, arguments=%s", sql, arguments)
            cursor = conn.execute(sql, *arguments)
            for i, (name, process_fn, sql) in enumerate(sql_parts):
                if i:
                    cursor.nextset()
                namespace[name] = process_fn(cursor)

        return namespace

    def extra_records_processing(self, records_iterator):
        sortby = self.request.model_state.value("SortBy")
        ghpbid = self.get_ghpbid()
        include_toc = self.request.model_state.value("IncludeTOC")
        if sortby != "H" or not ghpbid or not include_toc:
            return super().extra_records_processing(records_iterator)

        def process():
            groupgetter = attrgetter(
                "GeneralHeadingGroupDisplayOrder",
                "GeneralHeadingGroupName",
                "GeneralHeadingGroupID",
            )
            headinggetter = attrgetter(
                "GeneralHeadingDisplayOrder", "GeneralHeadingName", "GeneralHeadingID"
            )
            for group_key, group_iter in itertools.groupby(
                records_iterator, key=lambda x: groupgetter(x[0])
            ):
                yield (
                    group_key,
                    (
                        (heading_key, heading_iter)
                        for heading_key, heading_iter in itertools.groupby(
                            group_iter, key=lambda x: headinggetter(x[0])
                        )
                    ),
                )

        return process()

    base_from = dedent("""\
        FROM GBL_BaseTable bt
        INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID
        LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM
        LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID
        LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM
        LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=@@LANGID
        LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx ON (((btd.SORT_AS_USELETTER IS NULL OR btd.SORT_AS_USELETTER=0) AND btd.ORG_LEVEL_1 LIKE idx.LetterIndex + '%') OR (btd.SORT_AS_USELETTER=1 AND btd.SORT_AS LIKE idx.LetterIndex + '%'))
    """)
    base_sort = dedent("""\
            idx.LetterIndex, ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
                STUFF(
                    CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)
                        THEN NULL
                        ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +
                            COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
                            COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')
                         END,
                    1, 2, ''
                )""")

    def build_sql(self, field_sql, where_sql, arguments):
        model_state = self.request.model_state
        sortby = model_state.value("SortBy")
        extra_from = ""
        sortby_sql = self.base_sort
        ghpbid = self.get_ghpbid()
        ghid = model_state.value("GHID")
        ghtype = model_state.value("GHType")
        if sortby == "H" and ghpbid is not None and ghtype != "N":
            arguments.insert(0, ghpbid)
            sortby_sql = (
                "ISNULL(ghx.GeneralHeadingGroupDisplayOrder,0), ISNULL(ghx.GroupName, ghx.GeneralHeading), ghx.GeneralHeadingDisplayOrder, ghx.GeneralHeading,"
                + sortby_sql
            )
            field_sql += ",ghx.GroupName AS GeneralHeadingGroupName, ghx.GroupID AS GeneralHeadingGroupID, ghx.GeneralHeadingGroupDisplayOrder, ghx.GeneralHeading AS GeneralHeadingName, ghx.GH_ID AS GeneralHeadingID, ghx.GeneralHeadingDisplayOrder"

            group_limit = ""
            if ghid and (ghtype == "AF" or ghtype == "F"):
                ghid = set(ghid)
                ghplaceholders = ",".join("?" * len(ghid))
                arguments[1:1] = ghid
                group_limit = f" AND gh.GH_ID IN ({ghplaceholders}) "

            extra_from = dedent(f"""\
            LEFT JOIN (
                SELECT pb.NUM, gh.GH_ID, CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END AS GeneralHeading,
                    gh.DisplayOrder AS GeneralHeadingDisplayOrder, ghg.GroupID, ghgn.Name AS GroupName, ghg.DisplayOrder AS GeneralHeadingGroupDisplayOrder
                FROM CIC_BT_PB pb
                INNER JOIN CIC_BT_PB_GH pr
                    ON pb.BT_PB_ID=pr.BT_PB_ID
                INNER JOIN CIC_GeneralHeading gh
                    ON pr.GH_ID=gh.GH_ID
                LEFT JOIN CIC_GeneralHeading_Name ghn
                    ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=@@LANGID
                LEFT JOIN CIC_GeneralHeading_Group ghg
                    ON gh.HeadingGroup=ghg.GroupID
                LEFT JOIN CIC_GeneralHeading_Group_Name ghgn
                    ON ghg.GroupID=ghgn.GroupID AND ghgn.LangID=@@LANGID
                WHERE pb.PB_ID=? {group_limit}
                AND NonPublic=0
                AND CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END IS NOT NULL
            ) ghx
                ON ghx.NUM=bt.NUM
            """)

        return dedent(f"""\
            SELECT bt.NUM AS XNUM{field_sql}
            {self.base_from}
            {extra_from}
            WHERE {where_sql}
            ORDER BY {sortby_sql}""")


@view_config(route_name="print_list_vol", renderer=default_template)
class PrintRecordListVOL(PrintListBase):
    def get_validator(self):
        return VOLPrintListSchema()

    def get_where_clause(self, where_clause, arguments):
        request = self.request
        model_state = request.model_state
        idlist = model_state.value("IDList")
        if idlist:
            idlist = set(idlist)
            arguments.extend(sorted(idlist))
            where_clause.append("(vo.VNUM IN (" + ",".join("?" * len(idlist)) + "))")

        if model_state.value("IncludeExpired"):
            where_clause.append(
                "(vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())"
            )

        return super().get_where_clause(where_clause, arguments)

    def build_sql(self, field_sql, where_sql, arguments):
        sortby = self.request.model_state.value("SortBy")
        if sortby == "P":
            sortby_sql = "ORDER BY vod.POSITION_TITLE"

        elif sortby == "C":
            sortby_sql = "ORDER BY vod.CREATED_DATE"
        elif sortby == "M":
            sortby_sql = "ORDER BY vod.MODIFIED_DATE"
        else:
            sortby_sql = dedent("""\
                ORDER BY ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
                    STUFF(
                        CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)
                            THEN NULL
                            ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +
                                COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
                                COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')
                             END,
                        1, 2, ''
                    )""")

        return dedent(f"""\
            SELECT vo.VNUM AS XVNUM{field_sql}
            FROM VOL_Opportunity vo
            INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID
            INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM
            LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
            WHERE {where_sql}
            {sortby_sql}""")
