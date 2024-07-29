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


# Python Libraries
import logging
from collections import defaultdict

# 3rd Party Libraries
from pyramid.httpexceptions import HTTPNotFound
from pyramid.view import view_config, view_defaults
from markupsafe import Markup
from formencode import ForEach, Schema

# CIOC Libraries
from cioc.core import i18n, validators as ciocvalidators
from cioc.web.cic.viewbase import CicViewBase

log = logging.getLogger(__name__)

templateprefix = "cioc.web.cic:templates/customreport/"

_ = i18n.gettext


class SearchValidators(Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    CMType = ciocvalidators.String(max=1, if_invalid=None)
    CMID = ciocvalidators.CSVForEach(ciocvalidators.IDValidator(), convert_to_list=True, if_invalid=None)
    GHID = ciocvalidators.CSVForEach(ciocvalidators.IDValidator(), convert_to_list=True, if_invalid=None)
    PBID = ciocvalidators.CSVForEach(ciocvalidators.IDValidator(), convert_to_list=True, if_invalid=None)
    GHPBID = ciocvalidators.IDValidator(if_invalid=None, if_missing=None)


class NOT_FROM_DB:
    pass


@view_defaults(route_name="cic_customreport")
class CustomReport(CicViewBase):
    def __init__(self, request, require_login=False):
        CicViewBase.__init__(self, request, require_login)
        if not request.viewdata.cic.CustomReportTool:
            raise HTTPNotFound()

    @view_config(
        route_name="cic_customreport_index", renderer=templateprefix + "index.mak"
    )
    def index(self):
        request = self.request
        cic_view = request.viewdata.cic

        with request.connmgr.get_connection() as conn:
            cursor = conn.execute(
                "EXEC dbo.sp_CIC_View_Community_l_Report ?", cic_view.ViewType
            )

        report_communities = cursor.fetchall()

        communities = defaultdict(list)
        for row in report_communities:
            communities[row.Parent_CM_ID].append(row)

        cursor.nextset()

        report_instructions = cursor.fetchone()

        title = _("Create a Custom Report", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                report_communities=communities, report_instructions=report_instructions
            ),
            no_index=True,
        )

    @view_config(
        route_name="cic_customreport_topic", renderer=templateprefix + "topics.mak"
    )
    def topic(self):
        cursor = None

        request = self.request
        cic_view = request.viewdata.cic

        model_state = request.model_state
        model_state.method = None
        model_state.schema = SearchValidators()

        if not model_state.validate():
            for key in model_state.form.errors:
                log.debug('error %s: %s', key, model_state.form.errors[key])
                model_state.form.data.pop(key, None)

        community_ids = [x for x in model_state.value("CMID", None) or [] if x]
        community_ids = ",".join(map(str, community_ids)) if community_ids else None

        request = self.request
        cic_view = request.viewdata.cic

        cmtype = model_state.value("CMType")

        with request.connmgr.get_connection() as conn:
            cursor = conn.execute(
                "EXEC dbo.sp_CIC_View_QuickList_l_Report ?, ?, ?",
                cic_view.ViewType,
                community_ids,
                cmtype,
            )

            communities = cursor.fetchall()

            cursor.nextset()

            headings = cursor.fetchall()

        title = _("Create a Custom Report", request)
        return self._create_response_namespace(
            title,
            title,
            dict(communities=communities, headings=headings, cmtype=cmtype),
            no_index=True,
        )

    @view_config(
        route_name="cic_customreport_format", renderer=templateprefix + "format.mak"
    )
    def report_format(self):
        cursor = None

        request = self.request
        cic_view = request.viewdata.cic

        model_state = request.model_state
        model_state.method = None
        model_state.schema = SearchValidators()

        if not model_state.validate():
            for key in model_state.form.errors:
                model_state.form.data(key, None)

        community_ids = [x for x in model_state.value("CMID", None) or [] if x]
        community_ids = ",".join(map(str, community_ids)) if community_ids else None

        heading_ids = [x for x in model_state.value("GHID", None) or [] if x]
        heading_ids = ",".join(map(str, heading_ids)) if heading_ids else None

        pub_ids = [x for x in model_state.value("PBID", None) or [] if x]
        pub_ids = ",".join(map(str, pub_ids)) if pub_ids else None

        cmtype = model_state.value("CMType")

        log.debug(pub_ids)

        request = self.request
        cic_view = request.viewdata.cic

        with request.connmgr.get_connection() as conn:
            cursor = conn.execute(
                "EXEC dbo.sp_CIC_View_l_Report ?, ?, ?, ?",
                cic_view.ViewType,
                community_ids,
                heading_ids,
                pub_ids,
            )

            communities = cursor.fetchall()

            cursor.nextset()

            pubs = cursor.fetchall()

            cursor.nextset()

            headings = cursor.fetchall()

        title = _("Create a Custom Report", request)
        return self._create_response_namespace(
            title,
            title,
            dict(communities=communities, headings=headings, pubs=pubs, cmtype=cmtype),
            no_index=True,
        )
