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


from collections import namedtuple
import xml.etree.ElementTree as ET
from itertools import groupby
from operator import attrgetter

from formencode import Schema, ForEach, variabledecode
from pyramid.view import view_config, view_defaults

from cioc.core import validators

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

import logging

log = logging.getLogger(__name__)

templateprefix = "cioc.web.admin:templates/"

EditInfo = namedtuple(
    "EditInfo", "community_sets interests skills gi_interests gi_skills gi_sites data"
)

get_involved_sites = [
    ("https://testapi.getinvolved.ca/rpc", "Test Site"),
    ("https://api.getinvolved.ca/rpc", "Production Site"),
]


class AgencySchema(Schema):
    if_key_missing = None

    AgencyCode = validators.AgencyCodeValidator(not_empty=True)
    GetInvolvedUser = validators.UnicodeString(max=100)
    GetInvolvedToken = validators.UnicodeString(max=100)
    GetInvolvedCommunitySet = validators.IDValidator()
    GetInvolvedSite = validators.OneOf([x[0] for x in get_involved_sites])

    chained_validators = [
        validators.RequireNoneOrAll(
            [
                "GetInvolvedUser",
                "GetInvolvedToken",
                "GetInvolvedCommunitySet",
                "GetInvolvedSite",
            ]
        )
    ]


class InterestSchema(Schema):
    if_key_missing = None

    AI_ID = validators.IDValidator()
    GIInterestID = validators.IDValidator()
    GISkillID = validators.IDValidator()


class SkillSchema(Schema):
    if_key_missing = None

    SK_ID = validators.IDValidator()
    GIInterestID = validators.IDValidator()
    GISkillID = validators.IDValidator()


class GetInvolvedAPISchema(validators.RootSchema):
    if_key_missing = None

    agencies = ForEach(AgencySchema())
    interests = ForEach(InterestSchema())
    skills = ForEach(SkillSchema())


@view_defaults(
    route_name="admin_getinvolvedapi", renderer=templateprefix + "getinvolvedapi.mak"
)
class GetInvolvedAPI(viewbase.AdminViewBase):
    @view_config(request_method="POST")
    def post(self):
        request = self.request
        user = request.user

        if not user.vol.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state
        model_state.schema = GetInvolvedAPISchema()
        model_state.form.variable_decode = True

        if model_state.validate():
            # success
            agencies = ET.Element("Agencies")

            for agency in model_state.value("agencies") or []:
                if not any(agency.values()):
                    continue

                el = ET.SubElement(agencies, "Agency")
                for key, val in agency.items():
                    if val:
                        ET.SubElement(el, key).text = str(val)

            interests = ET.Element("Interests")

            for interest in model_state.value("interests") or []:
                if not interest.get("AI_ID") or not any(
                    interest.get(k) for k in ["GISkillID", "GIInterestID"]
                ):
                    continue

                el = ET.SubElement(interests, "Interest")
                for key, val in interest.items():
                    if val:
                        ET.SubElement(el, key).text = str(val)

            skills = ET.Element("Skills")
            for skill in model_state.value("skills") or []:
                if not skill.get("SK_ID") or not any(
                    skill.get(k) for k in ["GISkillID", "GIInterestID"]
                ):
                    continue

                el = ET.SubElement(skills, "Skill")
                for key, val in skill.items():
                    if val:
                        ET.SubElement(el, key).text = str(val)

            args = [
                request.dboptions.MemberID,
                ET.tostring(agencies, encoding="unicode"),
                ET.tostring(interests, encoding="unicode"),
                ET.tostring(skills, encoding="unicode"),
            ]

            with request.connmgr.get_connection("admin") as conn:
                sql = """
                    DECLARE @ErrMsg as nvarchar(500),
                    @RC as int

                    EXECUTE @RC = dbo.sp_VOL_GetInvolvedAPI_u ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

                    SELECT @RC as [Return], @ErrMsg AS ErrMsg
                """

                cursor = conn.execute(sql, args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:
                msg = _(
                    "The Get Involved API configuration was successfully updated.",
                    request,
                )

                self._go_to_route("admin_getinvolvedapi", _query=[("InfoMsg", msg)])

        else:
            ErrMsg = _("There were validation errors.")

        edit_info = self._get_edit_info()._asdict()
        edit_info["ErrMsg"] = ErrMsg

        model_state.form.data = variabledecode.variable_decode(request.POST)

        title = _("Manage Get Involved API Configuration", request)
        return self._create_response_namespace(title, title, edit_info, no_index=True)

    @view_config()
    def get(self):
        request = self.request
        user = request.user

        if not user.vol.SuperUserGlobal:
            self._security_failure()

        edit_info = self._get_edit_info()

        request.model_state.form.data = edit_info.data

        title = _("Manage Get Involved API Configuration", request)
        return self._create_response_namespace(
            title, title, edit_info._asdict(), no_index=True
        )

    def _get_edit_info(self, all=True):
        request = self.request

        agencies = []
        interests = []
        skills = []
        gi_interests = []
        gi_skills = []
        community_sets = []
        interest_map = []
        skill_map = []
        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC sp_VOL_GetInvolvedAPI_s ?, ?", request.dboptions.MemberID, all
            )

            community_sets = list(map(tuple, cursor.fetchall()))

            cursor.nextset()

            interests = cursor.fetchall()

            cursor.nextset()

            skills = list(map(tuple, cursor.fetchall()))

            cursor.nextset()

            gi_interests = cursor.fetchall()

            cursor.nextset()

            gi_skills = list(map(tuple, cursor.fetchall()))

            if all:
                cursor.nextset()

                agencies = cursor.fetchall()

                cursor.nextset()

                interest_map = cursor.fetchall()

                cursor.nextset()

                skill_map = cursor.fetchall()

            cursor.close()

        data = {}
        if all:
            data["agencies"] = [
                {
                    "AgencyCode": x.AgencyCode,
                    "GetInvolvedUser": x.GetInvolvedUser,
                    "GetInvolvedToken": x.GetInvolvedToken,
                    "GetInvolvedCommunitySet": x.GetInvolvedCommunitySet,
                    "GetInvolvedSite": x.GetInvolvedSite,
                }
                for x in agencies
            ]

            data["interests"] = [
                {
                    "AI_ID": x.AI_ID,
                    "GISkillID": x.GISkillID,
                    "GIInterestID": x.GIInterestID,
                }
                for x in interest_map
            ]
            data["skills"] = [
                {
                    "SK_ID": x.SK_ID,
                    "GISkillID": x.GISkillID,
                    "GIInterestID": x.GIInterestID,
                }
                for x in skill_map
            ]

        if request.dboptions.OnlySpecificInterests:
            interests = list(
                sorted(
                    {(g.AI_ID, g.InterestName) for g in interests},
                    key=lambda x: x[1],
                )
            )
        else:
            interests = [
                ([(g.AI_ID, g.InterestName) for g in group], k)
                for k, group in groupby(interests, key=attrgetter("InterestGroup"))
            ]

        log.debug("interests: %s", interests)
        gi_interests = [
            ([(g.GIInterestID, g.GIInterestName) for g in group], k)
            for k, group in groupby(gi_interests, key=attrgetter("GIInterestGroup"))
        ]

        # XXX fill out edit info
        return EditInfo(
            community_sets,
            interests,
            skills,
            gi_interests,
            gi_skills,
            get_involved_sites,
            data,
        )
