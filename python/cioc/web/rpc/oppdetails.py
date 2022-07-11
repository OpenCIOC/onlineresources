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
import logging
from collections import OrderedDict

from xml.etree import ElementTree as ET

# 3rd party
from pyramid.httpexceptions import (
    HTTPUnauthorized,
    HTTPInternalServerError,
    HTTPNotFound,
)
from pyramid.view import view_config

# this app
from cioc.core import i18n, syslanguage
from cioc.core.format import textToHTML
from cioc.core.stat import insert_stat
from cioc.web.vol import viewbase

log = logging.getLogger(__name__)

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


@view_config(route_name="rpc_oppdetails", renderer="json")
@view_config(route_name="rpc_oppdetails_opid", renderer="json")
class RpcOrgDetails(viewbase.VolViewBase):
    def __call__(self):
        request = self.request
        user = request.user

        if not user:
            return make_401_error("Access Denied")

        if "realtimestandard" not in user.vol.ExternalAPIs:
            return make_401_error("Insufficient Permissions")

        opid = request.matchdict.get("opid")
        vnum = request.matchdict.get("vnum")

        if not opid and not vnum:
            raise HTTPNotFound()

        tmp_culture = cur_culture = request.params.get("TmpLn")
        restore_culture = request.language.Culture

        log.debug("Culture: %s", request.language.Culture)
        if cur_culture and syslanguage.is_record_culture(cur_culture):

            request.language.setSystemLanguage(cur_culture)
        else:
            cur_culture = request.language.Culture
            tmp_culture = None

        viewdata = request.viewdata.vol
        with request.connmgr.get_connection() as conn:
            if opid and not vnum:
                vnum = conn.execute(
                    "SELECT VNUM FROM VOL_Opportunity WHERE OP_ID=?", opid
                ).fetchone()
                if not vnum:
                    raise HTTPNotFound()

                vnum = vnum.VNUM

            fields = conn.execute(
                "EXEC sp_VOL_View_DisplayFields ?, ?, ?, ?, ?",
                viewdata.ViewType,
                False,
                vnum,
                False,
                None,
            ).fetchall()

            sql = [
                """DECLARE @ViewType int
                    SET @ViewType = ?
                    SELECT bt.MemberID, vo.OP_ID, vod.OPD_ID,
                    dbo.fn_VOL_RecordInView(vo.VNUM,@ViewType,vod.LangID,0,GETDATE()) AS IN_VIEW,
                    dbo.fn_CIC_RecordInView(bt.NUM,?,btd.LangID,0,GETDATE()) AS IN_CIC_VIEW,
                    vo.VNUM, vod.OPD_ID, vo.RECORD_OWNER, vo.NUM,
                    vod.NON_PUBLIC,
                    cioc_shared.dbo.fn_SHR_GBL_DateString(vod.MODIFIED_DATE) AS MODIFIED_DATE,
                    cioc_shared.dbo.fn_SHR_GBL_DateString(vod.UPDATE_DATE) AS UPDATE_DATE,
                    cioc_shared.dbo.fn_SHR_GBL_DateString(vod.UPDATE_SCHEDULE) AS UPDATE_SCHEDULE,
                    cioc_shared.dbo.fn_SHR_GBL_DateString(vod.DELETION_DATE) AS DELETION_DATE,
                    cioc_shared.dbo.fn_SHR_GBL_DateString(vo.DISPLAY_UNTIL) AS DISPLAY_UNTIL,
                    (SELECT Culture,LangID,LanguageName,LanguageAlias,LCID,Active
                        FROM STP_Language LANG WHERE LangID<>@@LANGID AND dbo.fn_VOL_RecordInView(vo.VNUM,@ViewType,LangID,0,GETDATE())=1 AND """,
                "ActiveRecord=1"
                if viewdata.ViewOtherLangs
                else "EXISTS(SELECT * FROM VOL_View_Description WHERE ViewType=@ViewType AND LangID=LANG.LangID)",
                """ ORDER BY CASE WHEN Active=1 THEN 0 ELSE 1 END, LanguageName FOR XML AUTO) AS RECORD_LANG,""",
            ]

            exclude = {
                "OP_ID",
                "VNUM",
                "NUM",
                "RECORD_OWNER",
                "NON_PUBLIC",
                "DELETION_DATE",
                "MODIFIED_DATE",
                "UPDATE_DATE",
                "UPDATE_SCHEDULE",
                "DISPLAY_UNTIL",
                "POSITION_TITLE",
            }
            if viewdata.DataMgmtFields:
                sql.append(
                    "\ncioc_shared.dbo.fn_SHR_GBL_DateString(vod.CREATED_DATE) AS CREATED_DATE,"
                )
                exclude.add("CREATED_DATE")

            sql.append(
                ",".join(x.FieldSelect for x in fields if x.FieldName not in exclude)
            )

            sql.append(
                """, vod.POSITION_TITLE, vod.VNUM AS LangVNUM
                    FROM VOL_Opportunity vo
                    LEFT JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID
                    INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM
                    LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
                    WHERE vo.VNUM=?
                    """
            )

            sql = "".join(sql)

            log.debug(sql)

            data = conn.execute(
                sql, viewdata.ViewType, request.viewdata.cic.ViewType, vnum
            ).fetchone()

        request.language.setSystemLanguage(restore_culture)

        if not data:
            raise HTTPNotFound()

        if not data.OPD_ID:
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

        fields = [
            OrderedDict(
                [
                    ("value", htmlvalue(x)),
                    ("name", x.FieldName),
                    ("display_name", x.FieldDisplay),
                    ("allow_html", x.CheckHTML),
                ]
            )
            for x in fields
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
                                "rpc_oppdetails",
                                vnum=vnum,
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
                ("position_title", data.POSITION_TITLE),
                (
                    "feedback_link",
                    "https://"
                    + request.host
                    + makeLink(
                        "~/volunteer/feedback.asp",
                        [("VNUM", vnum), ("UpdateLn", cur_culture)] + extra_link_args,
                    ),
                ),
                ("non_public", data.NON_PUBLIC),
                ("deletion_date", data.DELETION_DATE),
            ]
        )
        if data.IN_CIC_VIEW:
            full_info["org_link"] = request.host_url + request.passvars.makeDetailsLink(
                data.NUM,
                [("TmpLn" if tmp_culture else "Ln", cur_culture)] + extra_link_args,
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
                    ("created_date", data.CREATED_DATE),
                ]
            )

        full_info.update(
            [
                ("orgname", data.ORG_NAME_FULL),
                ("other_languages", other_langs),
                ("fields", fields),
                (
                    "volunteer_api_url",
                    makeLink(
                        "~/volunteer/volunteer2.asp", [("api", "on")] + extra_link_args
                    ),
                ),
            ]
        )

        with request.connmgr.get_connection("admin") as conn:
            insert_stat(request, data.OP_ID, data.VNUM, api=True)

        format = request.params.get("format")
        if format and format.lower() == "xml":
            request.override_renderer = "cioc:xml"

        return full_info
