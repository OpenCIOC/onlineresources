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


import zipfile
import tempfile
import logging

from pyramid.response import Response
from pyramid.httpexceptions import HTTPUnauthorized, HTTPInternalServerError
from pyramid.view import view_config

from cioc.core import i18n
from cioc.core.webobfiletool import FileIterator
from cioc.web.cic import viewbase

from formencode import Schema, validators
from cioc.core import validators as ciocvalidators
from cioc.core import modelstate

log = logging.getLogger(__name__)

_ = i18n.gettext

mime_type = "application/zip"


def make_headers(extra_headers=None):
    tmp = dict(extra_headers or {})
    return tmp


def make_401_error(message, realm="O211 Export"):
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


class O211ExportOptionsSchema(Schema):
    allow_extra_fields = True
    if_key_missing = None

    feed = validators.OneOf(
        "recordids taxonomy community".split(), if_empty=None, strip=True
    )
    date = ciocvalidators.ISODateConverter(if_empty=None)


@view_config(route_name="special_o211export")
class O211Export(viewbase.CicViewBase):
    def __call__(self):
        request = self.request
        user = request.user

        if not user:
            return make_401_error("Access Denied")

        if "o211export" not in user.cic.ExternalAPIs:
            return make_401_error("Insufficient Permissions")

        model_state = modelstate.ModelState(request)
        model_state.schema = O211ExportOptionsSchema()
        model_state.form.method = None

        if not model_state.validate():
            if model_state.is_error("date"):
                msg = "Invalid date"
            elif model_state.is_error("feed"):
                msg = "Invalid feed."
            else:
                msg = "An unknown error occurred."

            return make_internal_server_error(msg)

        feed = model_state.value("feed")
        date = model_state.value("date")

        args = []
        if not feed:
            sql = [
                "SELECT CAST(record AS nvarchar(max)) AS record FROM O211SC_RECORD_EXPORT btd"
            ]

            if request.viewdata.cic.PB_ID:
                args.append(request.viewdata.cic.PB_ID)
                sql.append(" INNER JOIN CIC_BT_PB pb ON btd.NUM=pb.NUM AND pb.PB_ID=?")

            if date:
                args.append(date)
                sql.append(
                    """
                        WHERE EXISTS (SELECT * FROM GBL_BaseTable_History h
                            INNER JOIN GBL_FieldOption fo
                                    ON h.FieldID=fo.FieldID
                                WHERE h.NUM=btd.NUM AND h.LangID=btd.LangID
                                    AND h.MODIFIED_DATE >= ?
                                    AND fo.FieldName IN ('ORG_LEVEL_1','ORG_LEVEL_2','ORG_LEVEL_3','ORG_LEVEL_4','ORG_LEVEL_5',
                                    'ACCESSIBILITY','AFTER_HRS_PHONE','ALT_ORG','APPLICATION','AREAS_SERVED',
                                    'CONTACT_1','CONTACT_2','EXEC_1','EXEC_2','VOLCONTACT',
                                    'CRISIS_PHONE','ELIGIBILITY','E_MAIL','FAX','FORMER_ORG','HOURS','INTERSECTION',
                                    'LANGUAGES','LOCATED_IN_CM','MAIL_ADDRESS','PUBLIC_COMMENTS',
                                    'OFFICE_PHONE','SERVICE_LEVEL','RECORD_OWNER','DESCRIPTION','SITE_ADDRESS','SUBJECTS',
                                    'TDD_PHONE','TOLL_FREE_PHONE','WWW_ADDRESS', 'UPDATE_DATE', 'NUM', 'SUBMIT_CHANGES_TO', 'SOURCE_DB')
                            )"""
                )

            sql = " ".join(sql)

        elif feed == "recordids":
            sql = [
                "SELECT CAST((SELECT id=btd.NUM, language=btd.Culture FROM O211SC_RECORD_EXPORT btd"
            ]
            if request.viewdata.cic.PB_ID:
                args.append(request.viewdata.cic.PB_ID)
                sql.append(" INNER JOIN CIC_BT_PB pb ON btd.NUM=pb.NUM AND pb.PB_ID=?")

            sql.append("FOR XML PATH('record'), TYPE) AS nvarchar(max)) AS data ")

            sql = " ".join(sql)

        elif feed == "taxonomy":
            sql = "SELECT CAST(record AS nvarchar(max)) AS record from O211SC_TAXONOMY_EXPORT"

        elif feed == "community":
            sql = "SELECT CAST(record AS nvarchar(max)) AS record from O211SC_COMMUNITY_EXPORT"

        else:
            # XXX we should never get here
            return make_internal_server_error("Invalid feed.")

        log.debug("sql: %s", sql)
        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(sql, *args)

            data = [x[0] for x in cursor.fetchall()]

            cursor.close()

        data.insert(0, '<?xml version="1.0" encoding="UTF-8"?>\r\n<records>')
        data.append("</records>")
        data = "\r\n".join(data).encode("utf8")

        file = tempfile.TemporaryFile()
        zip = zipfile.ZipFile(file, "w", zipfile.ZIP_DEFLATED)
        zip.writestr("export.xml", data)
        zip.close()
        length = file.tell()
        file.seek(0)

        res = Response(content_type="application/zip", charset=None)
        res.app_iter = FileIterator(file)
        res.content_length = length

        res.headers["Content-Disposition"] = "attachment;filename=Export.zip"
        return res
