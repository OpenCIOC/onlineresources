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


from __future__ import absolute_import
import logging
import six

log = logging.getLogger(__name__)

import xml.etree.cElementTree as ET
import collections

from formencode import Schema
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = "cioc.web.admin:templates/pagetitle/"

EditValues = collections.namedtuple("EditValues", "PageName page descriptions")


class PageTitleDescriptionSchema(Schema):
    if_key_missing = None

    TitleOverride = ciocvalidators.UnicodeString(max=255)


class PageTitleSchema(Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    if_key_missing = None

    pre_validators = [viewbase.cull_extra_cultures("descriptions")]

    PageName = ciocvalidators.String(max=255, not_empty=True)
    descriptions = ciocvalidators.CultureDictSchema(
        PageTitleDescriptionSchema(), record_cultures=True, delete_empty=False
    )


@view_defaults(route_name="admin_pagetitle")
class PageTitle(viewbase.AdminViewBase):
    @view_config(
        route_name="admin_pagetitle_index", renderer=templateprefix + "index.mak"
    )
    def index(self):
        request = self.request
        user = request.user

        if not user.SuperUserGlobal:
            self._security_failure()

        with request.connmgr.get_connection("admin") as conn:
            pages = conn.execute("EXEC dbo.sp_GBL_PageTitle_l").fetchall()

        title = _("Manage Page Titles", request)
        return self._create_response_namespace(
            title, title, dict(pages=pages), no_index=True
        )

    @view_config(
        match_param="action=edit",
        request_method="POST",
        renderer=templateprefix + "edit.mak",
    )
    def save(self):
        request = self.request

        user = request.user

        if not user.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state
        model_state.schema = PageTitleSchema()
        model_state.form.variable_decode = True

        if model_state.validate():
            PageName = model_state.form.data.get("PageName")
            # valid. Save changes and redirect
            args = [PageName, user.Mod]

            root = ET.Element("DESCS")

            for culture, data in six.iteritems(model_state.form.data["descriptions"]):
                desc = ET.SubElement(root, "DESC")
                ET.SubElement(desc, "Culture").text = culture.replace("_", "-")
                for name, value in six.iteritems(data):
                    if value:
                        ET.SubElement(desc, name).text = value

            args.append(ET.tostring(root, encoding="unicode"))

            # xml = args[-1]
            # raise Exception

            with request.connmgr.get_connection("admin") as conn:
                sql = """
				DECLARE @ErrMsg as nvarchar(500), 
				@RC as int 

				EXEC @RC = dbo.sp_GBL_PageTitle_u ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT  

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				"""

                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:
                self._go_to_route(
                    "admin_pagetitle",
                    action="edit",
                    _query=[
                        (
                            "InfoMsg",
                            _("The Page Title was successfully updated.", request),
                        ),
                        ("PageName", PageName),
                    ],
                )

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:
            if model_state.is_error("PageName"):
                self._go_to_route(
                    "admin_pagetitle_index",
                    _query=[("ErrMsg", _("Invalid Page", request))],
                )

            ErrMsg = _("There were validation errors.")

        edit_values = self._get_edit_info(request.post.get("PageName"))._asdict()
        edit_values["ErrMsg"] = ErrMsg

        # errors = model_state.form.errors
        # data = model_state.form.data
        # raise Exception
        # XXX should we refetch the basic info?
        title = _("Manage Page Titles", request)
        return self._create_response_namespace(title, title, edit_values, no_index=True)

    @view_config(match_param="action=edit", renderer=templateprefix + "edit.mak")
    def edit(self):
        request = self.request
        user = request.user

        if not user.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state
        model_state.validators = {
            "PageName": ciocvalidators.String(max=255, not_empty=True)
        }
        model_state.method = None

        if not model_state.validate():
            # XXX invalid PageName

            self._go_to_route(
                "admin_pagetitle_index", _query=[("ErrMsg", _("Invalid ID", request))]
            )

        PageName = model_state.form.data.get("PageName")

        edit_values = self._get_edit_info(PageName)

        model_state.form.data["descriptions"] = edit_values.descriptions

        title = _("Manage Page Titles", request)
        return self._create_response_namespace(
            title, title, edit_values._asdict(), no_index=True
        )

    def _get_edit_info(self, PageName):
        request = self.request

        page = None
        descriptions = {}

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute("EXEC dbo.sp_GBL_PageTitle_s ?", PageName)
            page = cursor.fetchone()

            cursor.nextset()

            for lng in cursor.fetchall():
                descriptions[lng.Culture.replace("-", "_")] = lng

            cursor.close()

        if not page:
            # not found
            self._error_page(_("Field Not Found", request))

        return EditValues(PageName, page, descriptions)
