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


# 3rd party
from pyramid.view import view_config, view_defaults

# this app
from cioc.core import systeminfo

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

log = logging.getLogger(__name__)

templateprefix = "cioc.web.admin:templates/"


@view_defaults(route_name="admin_sysinfo", renderer=templateprefix + "sysinfo.mak")
class SystemInfo(viewbase.AdminViewBase):
    @view_config()
    def get(self):
        request = self.request
        user = request.user

        if not user.SuperUser:
            self._security_failure()

        sysinfo = systeminfo.get_system_version_info_html()

        title = _("Manage Google Analytics Configuration", request)
        return self._create_response_namespace(
            title, title, {"sysinfo": sysinfo}, no_index=True
        )
