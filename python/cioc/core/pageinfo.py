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


import cioc.core.constants as const
from cioc.core.i18n import gettext as _

import logging

log = logging.getLogger(__name__)


class PageInfo:
    def __init__(self, request, domain, db_area):
        self.request = request
        self.Domain = domain
        self.DbArea = db_area

        if db_area == const.DM_CIC:
            self.DbAreaS = const.DM_S_CIC
            self.DbAreaDefaultPath = ""
        elif db_area == const.DM_VOL:
            self.DbAreaS = const.DM_S_VOL
            self.DbAreaDefaultPath = "volunteer/"
        else:
            self.DbAreaS = "GBL"
            self.DbAreaDefaultPath = "admin/"

        app_url = request.application_url  # + extra_app_url
        if not app_url.endswith("/"):
            app_url = app_url + "/"
        this_url = request.path_url
        path_parts = this_url.split("/")
        if app_url == this_url:
            self.ThisPage = "/"
        else:
            self.ThisPage = path_parts[-1]
            if path_parts[-1] == "":
                self.ThisPage = path_parts[-2]

        self.ThisPageFull = this_url[len(app_url) :]
        self.PathToStart = "../" * self.ThisPageFull.count("/")
        if not self.PathToStart:
            self.PathToStart = "/"

        if self.ThisPageFull == "":
            self.ThisPageFull = "start"

        if self.ThisPageFull == "volunteer/":
            self.ThisPageFull = "volunteer/start"

        if self.ThisPageFull.startswith("record/"):
            self.ThisPageFull = "details.asp"

        # vol details page with search engine optimized urls
        if (
            self.ThisPageFull == "volunteer/details.asp"
            and request.passvars.record_root
        ):
            self.PathToStart = "../../"

        self.RootPath = app_url
        self.application_path = request.application_url[len(request.host_url) :]
        if self.application_path.endswith("/"):
            self.application_path = self.application_path[:-1]

    def fetch(self):
        with self.request.connmgr.get_connection() as conn:
            page_info = conn.execute(
                "EXEC dbo.sp_GBL_PageInfo_s ?", self.ThisPageFull
            ).fetchone()
            if page_info:
                self.PageTitle = page_info.PageTitle
                self.HasHelp = page_info.HAS_HELP
            else:
                self.PageTitle = ""
                self.HasHelp = False

    @property
    def DbAreaTitle(self):
        title = _("Database Admin Area", self.request)
        if self.DbArea == const.DM_CIC:
            return self.request.viewdata.cic.Title
        elif self.DbArea == const.DM_VOL:
            return self.request.viewdata.vol.Title

        return title

    @property
    def DbAreaBottomMsg(self):
        if self.DbArea == const.DM_CIC:
            return self.request.viewdata.cic.BottomMessage or ""

        if self.DbArea == const.DM_VOL:
            return self.request.viewdata.vol.BottomMessage or ""

        return ""

    @property
    def DbAreaViewType(self):
        if self.DbArea == const.DM_CIC:
            return self.request.viewdata.cic.ViewType

        if self.DbArea == const.DM_VOL:
            return self.request.viewdata.vol.ViewType

        return None
