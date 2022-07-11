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

from pyramid.view import view_config
from pyramid.exceptions import NotFound

from cioc.core import viewbase
from cioc.core.i18n import gettext as _

template = "cioc.web.gbl:templates/pages.mak"
log = logging.getLogger(__name__)


class PagesBase(viewbase.ViewBase):
    def __init__(self, request):
        viewbase.ViewBase.__init__(self, request, False)

    def __call__(self):
        request = self.request

        with request.connmgr.get_connection() as conn:
            cursor = conn.execute(
                """EXEC sp_%s_Page_s_Slug ?, ?, ?""" % request.pageinfo.DbAreaS,
                request.dboptions.MemberID,
                request.matchdict["slug"],
                request.viewdata.dom.ViewType,
            )

            page = cursor.fetchone()

            cursor.nextset()

            other_langs = cursor.fetchall()

        if not page and not other_langs:
            raise NotFound()

        title = page and page.Title or _("Page not found", request)
        return self._create_response_namespace(
            title,
            title,
            {
                "page": page,
                "other_langs": other_langs,
            },
            no_index=True,
        )


@view_config(route_name="pages_cic", renderer=template)
class PagesCIC(PagesBase):
    pass


@view_config(route_name="pages_vol", renderer=template)
class PagesVOL(PagesBase):
    pass
