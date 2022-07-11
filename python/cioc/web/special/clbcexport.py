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


import zipfile, tempfile

from pyramid.response import Response
from pyramid.view import view_config
from cioc.web.special.clbcupdate import make_401_error

from cioc.core import i18n
from cioc.core.webobfiletool import FileIterator
from cioc.web.cic import viewbase

_ = i18n.gettext

mime_type = "application/zip"


@view_config(route_name="special_clbcexport")
class ClbcExport(viewbase.CicViewBase):
    def __call__(self):
        request = self.request
        user = request.user

        if not user:
            return make_401_error("Access Denied", "Export")

        if "clbcexport" not in user.cic.ExternalAPIs:
            return make_401_error("Insufficient Permissions", "Export")

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "SELECT CAST(Vendor AS nvarchar(max)) AS Vendor FROM CLBC_VENDOR_EXPORT"
            )

            data = [x[0] for x in cursor.fetchall()]

            cursor.close()

        data.insert(0, '<?xml version="1.0" encoding="UTF-8"?>\r\n<Vendors>')
        data.append("</Vendors>")
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
