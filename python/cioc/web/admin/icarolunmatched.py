# =========================================================================================
#  Copyright 2020 KCL Software Solutions Inc.
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


# std lib
import logging

log = logging.getLogger(__name__)


# 3rd party
from pyramid.view import view_config

# this app
from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = "cioc.web.admin:templates/icarol/"


class IcarolUnmanaged(viewbase.AdminViewBase):
    @view_config(
        route_name="admin_icarolunmatched_index",
        renderer=templateprefix + "unmatched.mak",
    )
    def index(self):
        request = self.request
        user = request.user

        if not user.cic.SuperUser:
            self._security_failure()

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute("EXEC dbo.sp_CIC_iCarolImport_l_Unmatched")
            unmatched = cursor.fetchall()
            cursor.close()

        title = _("iCarol Unmatched", request)
        return self._create_response_namespace(
            title, title, dict(unmatched=unmatched), no_index=True
        )
