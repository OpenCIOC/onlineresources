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

import logging
from urllib.parse import urljoin

from pyramid.view import view_config
from pyramid.httpexceptions import HTTPNotFound, HTTPFound

from cioc.core import viewbase

template = "cioc.web.gbl:templates/pages.mak"
log = logging.getLogger(__name__)


@view_config(route_name="gbl_go")
class GoView(viewbase.ViewBase):
    def __init__(self, request):
        super().__init__(request, require_login=False)

    def __call__(self):
        request = self.request

        with request.connmgr.get_connection() as conn:
            cursor = conn.execute(
                """EXEC sp_GBL_Redirect_s_Slug ?, ?""",
                request.dboptions.MemberID,
                request.matchdict["slug"],
            )

            redirect = cursor.fetchone()

        if not redirect:
            return HTTPNotFound()

        url = urljoin(request.url, redirect.url)
        return HTTPFound(location=url)
