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


# Logging
from __future__ import absolute_import
import logging

log = logging.getLogger(__name__)

# Python Libraries
from functools import partial

# 3rd Party Libraries
from markupsafe import Markup
from pyramid.view import view_config

# CIOC Libraries
from cioc.core import i18n
from cioc.web.cic.viewbase import CicViewBase

templateprefix = "cioc.web.cic:templates/"

_ = i18n.gettext


@view_config(route_name="cic_csearch", renderer=templateprefix + "csearch.mak")
class ChildCareSearch(CicViewBase):
    def __init__(self, request, require_login=False):
        CicViewBase.__init__(self, request, require_login)

    def __call__(self):
        request = self.request

        title = _("Child Care Search", request)
        basic_namespace = self._create_response_namespace(
            title, title, {}, no_index=True
        )

        childsearchform, mapsbottomjs, search_info = self.childcare_form(
            basic_namespace
        )

        if childsearchform is None:
            self._security_failure()

        basic_namespace.update(
            dict(
                childsearchform=Markup(childsearchform()),
                mapsbottomjs=Markup(mapsbottomjs()),
                search_info=search_info,
            )
        )

        return basic_namespace

    def childcare_form(self, basic_namespace, communities=None, languages=None):
        request = self.request
        cic_view = request.viewdata.cic

        sql = """EXEC dbo.sp_CIC_View_s_CSrch ?"""

        age_groups = bus_routes = schools = types_of_program = types_of_care = None

        with request.connmgr.get_connection() as conn:
            search_info = conn.execute(sql, cic_view.ViewType).fetchone()
            if not search_info.CSrch:
                return None, None, None

            sql = """
				SET NOCOUNT ON;
				DECLARE @MemberID int = ?, @ViewType int = ?;
				EXEC dbo.sp_GBL_AgeGroup_l @MemberID, 1;
				EXEC dbo.sp_CCR_TypeOfCare_l @MemberID, 0, 0;
			"""
            if not communities:
                sql += "\nEXEC dbo.sp_CIC_View_Community_l @ViewType;"

            if search_info.CSrchBusRoute:
                sql += "\nEXEC dbo.sp_CIC_BusRoute_l @MemberID, 0;"

            if search_info.CSrchLanguages and not languages:
                sql += "\nEXEC dbo.sp_GBL_Language_l @MemberID, 0, 1;"

            if search_info.CSrchSchoolEscort or search_info.CSrchSchoolsInArea:
                sql += "\nEXEC dbo.sp_CCR_School_l @MemberID, 0"

            if search_info.CSrchTypeOfProgram:
                sql += "\nEXEC dbo.sp_CCR_TypeOfProgram_l @MemberID, 0, 0, NULL;"

            cursor = conn.execute(sql, request.dboptions.MemberID, cic_view.ViewType)

            age_groups = cursor.fetchall()

            cursor.nextset()
            types_of_care = cursor.fetchall()

            if not communities:
                cursor.nextset()
                communities = cursor.fetchall()

            if search_info.CSrchBusRoute:
                cursor.nextset()
                bus_routes = cursor.fetchall()

            if search_info.CSrchLanguages and not languages:
                cursor.nextset()
                languages = cursor.fetchall()

            if search_info.CSrchSchoolEscort or search_info.CSrchSchoolsInArea:
                cursor.nextset()
                schools = cursor.fetchall()

            if search_info.CSrchTypeOfProgram:
                cursor.nextset()
                types_of_program = cursor.fetchall()

            cursor.close()

        namespace = dict(basic_namespace)
        namespace.update(
            dict(
                search_info=search_info,
                age_groups=age_groups,
                communities=communities,
                bus_routes=bus_routes,
                languages=languages,
                schools=schools,
                types_of_program=types_of_program,
                types_of_care=types_of_care,
                located_near=[],
            )
        )

        childsearchform = partial(
            self._render, templateprefix + "csearch_form#childsearchform.mak", namespace
        )
        mapsbottomjs = partial(
            self._render, templateprefix + "csearch_form#mapsbottomjs.mak", namespace
        )

        return childsearchform, mapsbottomjs, search_info
