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


# stdlib
from __future__ import absolute_import
from collections import OrderedDict
from itertools import groupby
from operator import attrgetter
from xml.etree import cElementTree as ET

# 3rd party
from pyramid.httpexceptions import (
    HTTPUnauthorized,
    HTTPInternalServerError,
    HTTPNotFound,
)
from pyramid.view import view_config

# this app
from cioc.core.format import textToHTML
from cioc.core import i18n, syslanguage
from cioc.core.stat import insert_stat
from cioc.web.cic import viewbase
from six.moves import range

_ = i18n.gettext


def make_headers(extra_headers=None):
    tmp = dict(extra_headers or {})
    return tmp


def make_401_error(message, realm="CIOC RPC"):
    error = HTTPUnauthorized(
        headers=make_headers({"WWW-Authenticate": 'Basic realm="%s"' % realm})
    )
    error.content_type = "text/plain"
    error.text = message
    return error


def make_internal_server_error(message):
    error = HTTPInternalServerError()
    error.content_type = "text/plain"
    error.text = message
    return error


def tidy_name(name):
    return (name or "").strip()


def link_org_level(request, record, level):
    org_data = tidy_name(getattr(record, "ORG_LEVEL_%d" % level))
    if not org_data:
        return None

    if level <= record.LINK_ORG_TO:
        crit = [
            ("OL%d" % i, getattr(record, "ORG_LEVEL_%d" % i, "") or "")
            for i in range(1, level + 1)
        ]
        return request.host_url + request.passvars.makeLink("~/rpc/orgsearch.asp", crit)

    return None


def link_service_name_level(request, record, level):
    org_data = tidy_name(getattr(record, "SERVICE_NAME_LEVEL_%d" % level))
    loc_data = tidy_name(record.LOCATION_NAME)

    if not org_data:
        return None

    if getattr(record, "LINK_SERVICE_NAME_%d" % level) and not (
        org_data == loc_data and record.LINK_LOCATION_NAME
    ):

        crit = [("ORGNUM", record.ORG_NUM or record.NUM), ("SL%d" % level, org_data)]

        return request.host_url + request.passvars.makeLink("~/rpc/orgsearch.asp", crit)

    return None


def link_location_name(request, record):
    org_data = tidy_name(record.LOCATION_NAME)

    if record.LINK_LOCATION_NAME and org_data:
        crit = [("ORG_NUM", record.ORG_NUM or record.NUM), ("LL1", org_data)]
        return request.host_url + request.passvars.makeLink("~/rpc/orgsearch.asp", crit)

    return None


@view_config(route_name="rpc_orgdetails", renderer="json")
class RpcOrgDetails(viewbase.CicViewBase):
    def __call__(self):
        request = self.request
        user = request.user

        if not user:
            return make_401_error("Access Denied")

        if "realtimestandard" not in user.cic.ExternalAPIs:
            return make_401_error("Insufficient Permissions")

        num = request.matchdict["num"]
        cur_culture = request.params.get("TmpLn")
        restore_culture = request.language.Culture

        if cur_culture and syslanguage.is_record_culture(cur_culture):
            request.language.setSystemLanguage(cur_culture)
        else:
            cur_culture = request.language.Culture

        viewdata = request.viewdata.cic
        with request.connmgr.get_connection() as conn:
            fields = conn.execute(
                "EXEC sp_CIC_View_DisplayFields ?, ?, ?, ?, ?, ?",
                num,
                viewdata.ViewType,
                False,
                False,
                None,
                None,
            ).fetchall()

            sql = [
                """DECLARE @ViewType int
					SET @ViewType = ?
					SELECT bt.MemberID, btd.BTD_ID,
					dbo.fn_CIC_LinkOrgLevel(@ViewType,bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,GETDATE()) AS LINK_ORG_TO,
					dbo.fn_CIC_LinkLocationName(@ViewType,bt.NUM,bt.ORG_NUM,btd.LOCATION_NAME,GETDATE()) AS LINK_LOCATION_NAME,
					dbo.fn_CIC_LinkServiceNameLevel(@ViewType,bt.NUM,bt.ORG_NUM,btd.SERVICE_NAME_LEVEL_1,GETDATE()) AS LINK_SERVICE_NAME_1,
					dbo.fn_CIC_LinkServiceNameLevel(@ViewType,bt.NUM,bt.ORG_NUM,btd.SERVICE_NAME_LEVEL_2,GETDATE()) AS LINK_SERVICE_NAME_2,
					dbo.fn_CIC_RecordInView(bt.NUM,@ViewType,btd.LangID,0,GETDATE()) AS IN_VIEW,
					bt.RSN, bt.NUM, bt.RECORD_OWNER,
					dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
					btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
					LOCATION_NAME,
					SERVICE_NAME_LEVEL_1, SERVICE_NAME_LEVEL_2,
					bt.ORG_NUM, btd.NON_PUBLIC,
					cioc_shared.dbo.fn_SHR_GBL_DateString(btd.MODIFIED_DATE) AS MODIFIED_DATE,
					cioc_shared.dbo.fn_SHR_GBL_DateString(btd.UPDATE_DATE) AS UPDATE_DATE,
					cioc_shared.dbo.fn_SHR_GBL_DateString(btd.UPDATE_SCHEDULE) AS UPDATE_SCHEDULE,
					cioc_shared.dbo.fn_SHR_GBL_DateString(btd.DELETION_DATE) AS DELETION_DATE,
					(SELECT Culture,LangID,LanguageName,LanguageAlias,LCID,Active
						FROM STP_Language LANG WHERE LangID<>@@LANGID AND dbo.fn_CIC_RecordInView(bt.NUM,@ViewType,LangID,0,GETDATE())=1 AND """,
                "ActiveRecord=1"
                if viewdata.ViewOtherLangs
                else "EXISTS(SELECT * FROM CIC_View_Description WHERE ViewType=@ViewType AND LangID=LANG.LangID)",
                """ORDER BY CASE WHEN Active=1 THEN 0 ELSE 1 END, LanguageName FOR XML AUTO) AS RECORD_LANG,""",
            ]

            if viewdata.UseSubmitChangesTo:
                sql.append(
                    "ISNULL(btd.SUBMIT_CHANGES_TO_PROTOCOL, 'https://') + btd.SUBMIT_CHANGES_TO AS FEEDBACK_LINK,"
                )

            if viewdata.MapSearchResults:
                sql.append("bt.LATITUDE, bt.LONGITUDE,")

            exclude = {
                "RSN",
                "NUM",
                "RECORD_OWNER",
                "NON_PUBLIC",
                "DELETION_DATE",
                "MODIFIED_DATE",
                "UPDATE_DATE",
                "UPDATE_SCHEDULE",
            }
            exclude.update("ORG_LEVEL_%d" % i for i in range(1, 6))
            sql.append(
                ",".join(x.FieldSelect for x in fields if x.FieldName not in exclude)
            )

            sql.append(
                """,btd.NUM AS LangNUM
						FROM GBL_BaseTable bt
						LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID
						LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM
						LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID
						LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM
						LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=@@LANGID
						WHERE bt.NUM=? """
            )

            sql = "".join(sql)

            data = conn.execute(sql, viewdata.ViewType, num).fetchone()

        request.language.setSystemLanguage(restore_culture)

        if not data:
            raise HTTPNotFound()

        if not data.BTD_ID:
            # TODO other langs interface?
            raise HTTPNotFound()

        if not data.IN_VIEW:
            return make_401_error(_("Record not in view", request))

        request.language.setSystemLanguage(cur_culture)

        if request.params.get("texttohtml"):

            def htmlvalue(field, data=data):
                field_contents = getattr(data, field.FieldName)
                if not field_contents:
                    return None

                if field.CheckMultiline or field.CheckHTML:
                    field_contents = textToHTML(field_contents)

                return field_contents

        else:

            def htmlvalue(field, data=data):
                return getattr(data, field.FieldName)

        field_groups = [
            {
                "name": k,
                "fields": [
                    OrderedDict(
                        [
                            ("value", htmlvalue(x)),
                            ("name", x.FieldName),
                            ("display_name", x.FieldDisplay),
                            ("allow_html", x.CheckHTML),
                        ]
                    )
                    for x in g
                ],
            }
            for (k, g) in groupby(fields, key=attrgetter("DisplayFieldGroupName"))
        ]

        makeLink = request.passvars.makeLink
        route_url = request.passvars.route_url
        format = request.params.get("format")
        if format and format.lower() == "xml":
            extra_link_args = [("format", "xml")]
        else:
            extra_link_args = []

        if data.RECORD_LANG:
            xml = ET.fromstring(
                ("<langs>%s</langs>" % data.RECORD_LANG).encode("utf-8")
            )
            other_langs = [
                OrderedDict(
                    [
                        ("name", x.get("LanguageName")),
                        ("culture", x.get("Culture")),
                        (
                            "link",
                            route_url(
                                "rpc_orgdetails",
                                num=num,
                                _query=[
                                    (
                                        "Ln" if x.get("Active") == "1" else "TmpLn",
                                        x.get("Culture"),
                                    )
                                ]
                                + extra_link_args,
                            ),
                        ),
                    ]
                )
                for x in xml.findall("./LANG")
            ]
        else:
            other_langs = []

        full_info = OrderedDict(
            [
                ("orgname", data.ORG_NAME_FULL),
                (
                    "feedback_link",
                    data.FEEDBACK_LINK
                    if viewdata.UseSubmitChangesTo
                    else (
                        "https://"
                        + request.host
                        + makeLink(
                            "~/feedback.asp",
                            [("NUM", num), ("UpdateLn", cur_culture)] + extra_link_args,
                        )
                    ),
                ),
                ("logo", getattr(data, "LOGO_ADDRESS", None)),
                ("non_public", data.NON_PUBLIC),
                ("deletion_date", data.DELETION_DATE),
            ]
        )

        if viewdata.LastModifiedDate:
            full_info.update(
                [
                    ("modified_date", data.MODIFIED_DATE),
                    ("update_date", data.UPDATE_DATE),
                ]
            )

        if viewdata.DataMgmtFields:
            full_info.update(
                [
                    ("update_schedule", data.UPDATE_SCHEDULE),
                ]
            )

        if viewdata.MapSearchResults:
            full_info.update(
                [
                    ("latitude", float(data.LATITUDE) if data.LATITUDE else None),
                    ("longitude", float(data.LONGITUDE) if data.LONGITUDE else None),
                ]
            )

        full_info.update(
            ("ORG_LEVEL_%d" % i, getattr(data, "ORG_LEVEL_%d" % i)) for i in range(1, 6)
        )
        full_info["LOCATION_NAME"] = data.LOCATION_NAME
        full_info.update(
            ("SERVICE_NAME_LEVEL_%d" % i, getattr(data, "SERVICE_NAME_LEVEL_%d" % i))
            for i in range(1, 3)
        )
        if viewdata.LinkOrgLevels:
            full_info.update(
                ("ORG_LEVEL_%d_SEARCH" % i, link_org_level(request, data, i))
                for i in range(1, 5)
            )
            full_info["LOCATION_NAME_SEARCH"] = link_location_name(request, data)
            full_info.update(
                (
                    "SERVICE_NAME_LEVEL_%d_SEARCH" % i,
                    link_service_name_level(request, data, i),
                )
                for i in range(1, 2)
            )

        full_info.update(
            [
                ("other_languages", other_langs),
                ("field_groups", field_groups),
            ]
        )

        with request.connmgr.get_connection("admin") as conn:
            insert_stat(request, data.RSN, data.NUM, api=True)

        format = request.params.get("format")
        if format and format.lower() == "xml":
            request.override_renderer = "cioc:xml"

        return full_info
