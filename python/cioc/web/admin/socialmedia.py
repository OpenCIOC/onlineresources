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
import logging
import xml.etree.cElementTree as ET

# 3rd party
from formencode import Schema, validators
from pyramid.view import view_config, view_defaults

# this app
from cioc.core import validators as ciocvalidators, syslanguage

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase
import six

log = logging.getLogger(__name__)

templateprefix = "cioc.web.admin:templates/socialmedia/"


class SocialMediaBaseSchema(Schema):
    if_key_missing = None

    Active = validators.Bool()
    DefaultName = ciocvalidators.UnicodeString(max=100, not_empty=True)
    IconURL16 = ciocvalidators.URLWithProto(max=255, not_empty=True)
    IconURL24 = ciocvalidators.URLWithProto(max=255, not_empty=True)
    GeneralURL = ciocvalidators.UnicodeString(max=255)


socialmedia_fields = ["DefaultName", "GeneralURL", "IconURL16", "IconURL24", "Active"]


class SocialMediaDescriptionSchema(Schema):
    if_key_missing = None

    Name = ciocvalidators.UnicodeString(max=100)


class SocialMediaSchema(Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    if_key_missing = None

    socialmedia = SocialMediaBaseSchema()
    descriptions = ciocvalidators.CultureDictSchema(
        SocialMediaDescriptionSchema(), record_cultures=True, delete_empty=False
    )


@view_defaults(route_name="admin_socialmedia")
class SocialMedia(viewbase.AdminViewBase):
    @view_config(
        route_name="admin_socialmedia_index", renderer=templateprefix + "index.mak"
    )
    def index(self):
        request = self.request
        user = request.user

        if not user.SuperUserGlobal:
            self._security_failure()

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute("EXEC sp_GBL_SocialMedia_l 1")
            descs = cursor.fetchall()
            cursor.close()

        title = _("Manage Social Media Types", request)
        return self._create_response_namespace(
            title, title, dict(descs=descs), no_index=True
        )

    @view_config(
        match_param="action=edit",
        request_method="POST",
        renderer=templateprefix + "edit.mak",
    )
    def save(self):
        request = self.request

        if request.POST.get("Delete"):
            self._go_to_route(
                "admin_socialmedia",
                action="delete",
                _query=[("SM_ID", request.POST.get("SM_ID"))],
            )

        user = request.user

        if not user.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state
        model_state.schema = SocialMediaSchema()
        model_state.form.variable_decode = True

        validator = ciocvalidators.IDValidator()
        try:
            SM_ID = validator.to_python(request.POST.get("SM_ID"))
        except validators.Invalid:
            self._error_page(_("Invalid Social Media Type ID", request))

        is_add = not SM_ID

        domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)

        if model_state.validate():
            # valid. Save changes and redirect
            args = [SM_ID, user.Mod]
            socialmedia = model_state.form.data.get("socialmedia", {})
            args.extend(socialmedia.get(x) for x in socialmedia_fields)

            root = ET.Element("DESCS")

            for culture, data in six.iteritems(model_state.form.data["descriptions"]):
                if culture.replace("_", "-") not in shown_cultures:
                    continue

                desc = ET.SubElement(root, "DESC")
                ET.SubElement(desc, "Culture").text = culture.replace("_", "-")
                for name, value in six.iteritems(data):
                    if value:
                        ET.SubElement(desc, name).text = value

            args.append(ET.tostring(root, encoding="unicode"))

            with request.connmgr.get_connection("admin") as conn:
                sql = """
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int,
				@SM_ID as int

				SET @SM_ID = ?

				EXECUTE @RC = dbo.sp_GBL_SocialMedia_u @SM_ID OUTPUT, %s, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg, @SM_ID as SM_ID
				""" % ", ".join(
                    "?" * (len(args) - 1)
                )

                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:
                SM_ID = result.SM_ID

                if is_add:
                    msg = _("The Social Media Type was successfully added.", request)
                else:
                    msg = _("The Social Media Type was successfully updated.", request)

                self._go_to_route(
                    "admin_socialmedia",
                    action="edit",
                    _query=[
                        ("InfoMsg", msg),
                        ("SM_ID", SM_ID),
                        ("ShowCultures", shown_cultures),
                    ],
                )

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:

            ErrMsg = _("There were validation errors.")

        socialmedia = None

        if not is_add:
            with request.connmgr.get_connection("admin") as conn:
                cursor = conn.execute(
                    "EXEC dbo.sp_GBL_SocialMedia_s ?", model_state.value("SM_ID")
                )

                socialmedia = cursor.fetchone()

                cursor.close()

        record_cultures = syslanguage.active_record_cultures()

        # errors = model_state.form.errors
        # data = model_state.form.data
        # raise Exception
        # XXX should we refetch the basic info?
        title = _("Manage Social Media Types", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                socialmedia=socialmedia,
                SM_ID=model_state.value("SM_ID"),
                shown_cultures=shown_cultures,
                record_cultures=record_cultures,
                is_add=is_add,
                ErrMsg=ErrMsg,
            ),
            no_index=True,
        )

    @view_config(match_param="action=edit", renderer=templateprefix + "edit.mak")
    def edit(self):
        request = self.request
        user = request.user

        if not user.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state
        model_state.validators = {"SM_ID": ciocvalidators.IDValidator()}
        model_state.method = None

        if not model_state.validate():
            # XXX invalid SM_ID

            self._error_page(_("Invalid ID", request))

        SM_ID = model_state.form.data.get("SM_ID")
        is_add = not SM_ID

        socialmedia = None
        socialmedia_descriptions = {}

        if not is_add:
            with request.connmgr.get_connection("admin") as conn:
                cursor = conn.execute("EXEC dbo.sp_GBL_SocialMedia_s ?", SM_ID)
                socialmedia = cursor.fetchone()
                if socialmedia:
                    cursor.nextset()
                    for lng in cursor.fetchall():
                        socialmedia_descriptions[lng.Culture.replace("-", "_")] = lng

                cursor.close()

            if not socialmedia:
                # not found
                self._error_page(_("Social Media Type Not Found", request))

        domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)

        model_state.form.data["socialmedia"] = socialmedia
        model_state.form.data["descriptions"] = socialmedia_descriptions

        title = _("Manage Social Media Types", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                socialmedia=socialmedia,
                SM_ID=SM_ID,
                is_add=is_add,
                shown_cultures=shown_cultures,
                record_cultures=syslanguage.active_record_cultures(),
            ),
            no_index=True,
        )

    @view_config(
        match_param="action=delete", renderer="cioc.web:templates/confirmdelete.mak"
    )
    def delete(self):
        request = self.request
        user = request.user

        if not user.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {"SM_ID": ciocvalidators.IDValidator(not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid ID", request))

        SM_ID = model_state.form.data["SM_ID"]

        request.override_renderer = "cioc.web:templates/confirmdelete.mak"

        title = _("Manage Social Media Types", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                id_name="SM_ID",
                id_value=SM_ID,
                route="admin_socialmedia",
                action="delete",
            ),
            no_index=True,
        )

    @view_config(match_param="action=delete", request_method="POST")
    def delete_confirm(self):
        request = self.request
        user = request.user

        if not user.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {"SM_ID": ciocvalidators.IDValidator(not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid ID", request))

        SM_ID = model_state.form.data["SM_ID"]

        with request.connmgr.get_connection("admin") as conn:
            sql = """
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_GBL_SocialMedia_d ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			"""

            cursor = conn.execute(sql, SM_ID)
            result = cursor.fetchone()
            cursor.close()

        if not result.Return:
            self._go_to_route(
                "admin_socialmedia_index",
                _query=[
                    (
                        "InfoMsg",
                        _("The Social Media Type was successfully deleted.", request),
                    )
                ],
            )

        if result.Return == 3:
            self._error_page(
                _("Unable to delete Social Media Type: ", request) + result.ErrMsg
            )

        self._go_to_route(
            "admin_socialmedia",
            action="edit",
            _query=[
                ("ErrMsg", _("Unable to delete Social Media Type: ") + result.ErrMsg),
                ("SM_ID", SM_ID),
            ],
        )
