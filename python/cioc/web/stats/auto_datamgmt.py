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


import logging
from itertools import groupby
from operator import attrgetter
from collections import namedtuple

from pyramid.view import view_config, view_defaults
from markupsafe import Markup

from cioc.core import i18n, constants as const, viewbase, validators as ciocvalidators
from cioc.core.datesearch import date_search_options_sql

_ = i18n.gettext

log = logging.getLogger(__name__)

templateprefix = "cioc.web.stats:templates/"

StatType = namedtuple("StatType", "name hasother hascriteria")


@view_defaults(renderer=templateprefix + "auto_datamgmt.mak")
class Stats1View(viewbase.ViewBase):
    def __init__(self, request, login_required=True):
        super().__init__(request, True)

    @view_config(route_name="stats_auto_datamgmt_cic")
    @view_config(route_name="stats_auto_datamgmt_vol")
    def index(self):
        request = self.request
        user = request.user

        if user.dom.CanViewStats != const.STATS_ALL:
            self._security_failure()

        model_state = request.model_state

        extra_validators = {"ignore_key_missing": True}
        if request.pageinfo.DbArea == const.DM_CIC:
            extra_validators["PBID"] = ciocvalidators.IDValidator()

        model_state.schema = ciocvalidators.DateSearch()(**extra_validators)
        model_state.method = None

        stat_rows = []
        publist = []
        months = []
        ErrMsg = None
        link_prefix = (
            "~/" if request.pageinfo.DbArea == const.DM_CIC else "~/volunteer/"
        )
        publication_code = None
        publication_name = None

        with request.connmgr.get_connection("admin") as conn:
            if not model_state.validate():
                ErrMsg = _("There were validation errors.")
            else:

                if request.params.get("submit"):
                    tax_section = []
                    display_until_section = []
                    if request.pageinfo.DbArea == const.DM_CIC:
                        tax_section = [
                            StatType(_("Last Modified - Taxonomy"), True, True)
                        ]
                    else:
                        display_until_section = [
                            StatType(_("Display Until"), True, True)
                        ]

                    stat_types = (
                        [
                            StatType(_("Date Created"), True, True),
                            StatType(_("Last Modified"), True, True),
                        ]
                        + tax_section
                        + [
                            StatType(_("Last Full Update"), True, True),
                            StatType(_("Deletion Date"), True, True),
                        ]
                        + display_until_section
                    )

                    if request.dboptions.OtherMembersActive:
                        stat_types += [
                            StatType(_("Shared With Me"), False, True),
                            StatType(_("Shared By Me"), False, False),
                        ]

                    args = [request.dboptions.MemberID]
                    args_param = "?"
                    sql = "EXEC sp_%s_AutoReport_DataMgmt %s"
                    if any(
                        model_state.value(x)
                        for x in ["DateRange", "FirstDate", "LastDate"]
                    ):
                        prefix = ""
                        range = model_state.value("DateRange")
                        if range:
                            prefix = (
                                "SET NOCOUNT ON; DECLARE @FirstDate smalldatetime, @LastDate smalldatetime; SET @FirstDate = %s; SET @LastDate = %s\n"
                                % date_search_options_sql[range]
                            )
                            args_param = "?, @FirstDate, @LastDate"
                        else:
                            args_param = "?,?,?"
                            args.extend(
                                [
                                    model_state.value("FirstDate"),
                                    model_state.value("LastDate"),
                                ]
                            )

                        sql = prefix + "EXEC sp_%s_Stats_DataMgmt %s"

                    if request.pageinfo.DbArea == const.DM_CIC:
                        args_param += ",?"
                        args.append(model_state.value("PBID"))

                    sql = sql % (request.pageinfo.DbAreaS, args_param)
                    cursor = conn.execute(sql, args)
                    months = cursor.fetchone()

                    if request.pageinfo.DbArea == const.DM_CIC:
                        cursor.nextset()
                        publication_code = cursor.fetchone()
                        if publication_code:
                            publication_name = publication_code[1]
                            publication_code = publication_code[0]

                    link_template = Markup(
                        '<b>%(title)s</b>: <a href="%(url)s">%(count)d</a>'
                    )
                    nolink_template = Markup("<b>%(title)s</b>: %(count)d")
                    makeLink = request.passvars.makeLink
                    results = link_prefix + "results.asp"
                    exclude = ["Ln"]
                    for st in stat_types:
                        cursor.nextset()
                        stat_months = {}
                        for k, g in groupby(cursor.fetchall(), attrgetter("TheMonth")):
                            rows = list(g)

                            if st.hasother:
                                other = Markup("<br>").join(
                                    (link_template if x[3] else nolink_template)
                                    % {
                                        "title": x[1],
                                        "url": makeLink(
                                            results, "Shared=Y&" + x.Criteria, exclude
                                        ),
                                        "count": x[3],
                                    }
                                    for x in rows
                                )

                                local_shared_criteria = "Shared=N&"
                                tmpl = link_template

                            else:
                                other = None
                                local_shared_criteria = ""

                            if not st.hascriteria:
                                tmpl = nolink_template

                            local = Markup("<br>").join(
                                (tmpl if x[2] else nolink_template)
                                % {
                                    "title": x[1],
                                    "url": makeLink(
                                        results,
                                        local_shared_criteria + x.Criteria,
                                        exclude,
                                    )
                                    if st.hascriteria
                                    else "",
                                    "count": x[2],
                                }
                                for x in rows
                            )

                            stat_months[k] = (local, other)

                        stat_rows.append((st, stat_months))

                    cursor.close()

                if request.pageinfo.DbArea == const.DM_CIC:
                    publist = conn.execute(
                        "EXEC dbo.sp_CIC_Publication_l ?, ?, NULL",
                        request.viewdata.cic.ViewType,
                        False,
                    ).fetchall()

        title = _("Data Management Report", request)
        return self._create_response_namespace(
            title,
            title,
            {
                "months": list(months),
                "stat_rows": stat_rows,
                "publist": publist,
                "link_prefix": link_prefix,
                "ErrMsg": ErrMsg,
                "publication_name": publication_name,
                "publication_code": publication_code,
            },
            print_table=True,
            no_index=True,
        )
