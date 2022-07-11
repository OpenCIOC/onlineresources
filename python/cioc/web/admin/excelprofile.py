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

import xml.etree.ElementTree as ET

# 3rd party
from formencode import Schema, validators, ForEach, All, variabledecode
from pyramid.view import view_config, view_defaults

# this app
from cioc.core import validators as ciocvalidators

from cioc.core.i18n import gettext as _
from cioc.web.admin.viewbase import AdminViewBase

log = logging.getLogger(__name__)

templateprefix = "cioc.web.admin:templates/excelprofile/"

column_headers = {"N": None, "F": False, "L": True}
column_headers_reverse = {v: k for k, v in column_headers.items()}


class ProfileBaseSchema(Schema):
    if_key_missing = None

    ColumnHeadersWeb = validators.DictConverter(column_headers)


class ProfileDescriptionSchema(Schema):
    if_key_missing = None

    Name = ciocvalidators.UnicodeString(max=100)


class FieldOrderSchema(Schema):
    if_key_missing = None

    FieldID = ciocvalidators.IDValidator(not_empty=True)
    DisplayOrder = validators.Int(min=0, max=255, if_empty=None)
    SortByOrder = validators.Int(min=0, max=255, if_empty=None)


class ProfileSchema(Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    if_key_missing = None

    profile = ProfileBaseSchema()
    descriptions = ciocvalidators.CultureDictSchema(ProfileDescriptionSchema())
    Views = All(validators.Set(use_set=True), ForEach(ciocvalidators.IDValidator()))
    Fields = ForEach(FieldOrderSchema())


@view_defaults(route_name="admin_excelprofile")
class ExcelProfile(AdminViewBase):
    @view_config(
        route_name="admin_excelprofile_index", renderer=templateprefix + "index.mak"
    )
    def index(self):
        request = self.request
        user = request.user

        if not user.SuperUser:
            self._security_failure()

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC sp_CIC_ExcelProfile_l ?, NULL", request.dboptions.MemberID
            )
            profiles = cursor.fetchall()
            cursor.close()

        title = _("Manage Excel Profiles", request)
        return self._create_response_namespace(
            title, title, dict(profiles=profiles), no_index=True
        )

    @view_config(
        match_param="action=edit",
        request_method="POST",
        renderer=templateprefix + "edit.mak",
    )
    @view_config(
        match_param="action=add",
        request_method="POST",
        renderer=templateprefix + "edit.mak",
    )
    def save(self):
        request = self.request

        if request.POST.get("Delete"):
            self._go_to_route(
                "admin_excelprofile",
                action="delete",
                _query=[("ProfileID", request.POST.get("ProfileID"))],
            )

        user = request.user

        if not user.SuperUser:
            self._security_failure()

        action = request.matchdict.get("action")
        is_add = action == "add"

        extra_validators = {}
        model_state = request.model_state
        if not is_add:
            extra_validators["ProfileID"] = ciocvalidators.IDValidator()

        model_state.schema = ProfileSchema(**extra_validators)
        model_state.form.variable_decode = True

        # values = variabledecode.variable_decode(request.POST)
        # raise Exception

        if model_state.validate():
            # valid. Save changes and redirect
            if not is_add:
                ProfileID = model_state.form.data["ProfileID"]
            else:
                ProfileID = None

            args = [
                ProfileID,
                user.Mod,
                request.dboptions.MemberID,
                model_state.form.data["profile"].get("ColumnHeadersWeb"),
            ]

            root = ET.Element("DESCS")

            for culture, data in model_state.form.data["descriptions"].items():
                desc = ET.SubElement(root, "DESC")
                ET.SubElement(desc, "Culture").text = culture.replace("_", "-")
                for name, value in data.items():
                    if value:
                        ET.SubElement(desc, name).text = value

            args.append(ET.tostring(root, encoding="unicode"))

            root = ET.Element("VIEWS")
            for view_type in model_state.form.data["Views"]:
                ET.SubElement(root, "VIEW").text = str(view_type)

            # raise Exception

            args.append(ET.tostring(root, encoding="unicode"))

            root = ET.Element("FIELDS")
            for field in model_state.form.data["Fields"]:
                if (
                    field["DisplayOrder"] is not None
                    or field["SortByOrder"] is not None
                ):
                    field_el = ET.SubElement(root, "FIELD")
                    for name, value in field.items():
                        if value is not None:
                            ET.SubElement(field_el, name).text = str(value)

            args.append(ET.tostring(root, encoding="unicode"))

            with request.connmgr.get_connection("admin") as conn:
                sql = """
                DECLARE @ErrMsg as nvarchar(500),
                @RC as int,
                @ProfileID as int

                SET @ProfileID = ?

                EXECUTE @RC = dbo.sp_CIC_ExcelProfile_u @ProfileID OUTPUT, ?, ?, ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

                SELECT @RC as [Return], @ErrMsg AS ErrMsg, @ProfileID as ProfileID
                """

                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:
                ProfileID = result.ProfileID

                if is_add:
                    msg = _("The Profile was successfully added.", request)
                else:
                    msg = _("The Profile was successfully updated.", request)

                self._go_to_route(
                    "admin_excelprofile",
                    action="edit",
                    _query=[("InfoMsg", msg), ("ProfileID", ProfileID)],
                )

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:
            if model_state.is_error("ProfileID"):
                self._error_page(_("Invalid Profile ID", request))

            ErrMsg = _("There were validation errors.")

        profile = None
        profile_descriptions = {}
        view_descs = []
        field_descs = []

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC dbo.sp_CIC_ExcelProfile_s_FormLists ?, ?",
                request.MemberID,
                model_state.value("ProfileID"),
            )

            view_descs = cursor.fetchall()

            cursor.nextset()

            field_descs = cursor.fetchall()

            cursor.close()

            if not is_add:
                profile = conn.execute(
                    "EXEC dbo.sp_CIC_ExcelProfile_s ?, ?",
                    request.dboptions.MemberID,
                    model_state.value("ProfileID"),
                ).fetchone()

        params = variabledecode.variable_decode(request.POST)
        fieldorder = [str(x["FieldID"]) for x in params.get("Fields", [])]
        field_descs = {str(f.FieldID): f for f in field_descs}

        val = model_state.value("profile.ColumnHeadersWeb")
        model_state.form.data["profile.ColumnHeadersWeb"] = column_headers_reverse.get(
            val, val
        )
        model_state.form.data["Views"] = request.POST.getall("Views")

        # errors = model_state.form.errors
        # data = model_state.form.data
        # raise Exception
        # XXX should we refetch the basic info?
        title = _("Manage Excel Profiles", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                action=action,
                profile=profile,
                profile_descriptions=profile_descriptions,
                ProfileID=model_state.value("ProfileID"),
                fieldorder=fieldorder,
                field_descs=field_descs,
                view_descs=view_descs,
                ErrMsg=ErrMsg,
            ),
            no_index=True,
        )

    @view_config(match_param="action=add", renderer=templateprefix + "edit.mak")
    @view_config(match_param="action=edit", renderer=templateprefix + "edit.mak")
    def edit(self):
        request = self.request
        user = request.user

        if not user.SuperUser:
            self._security_failure()

        action = request.matchdict.get("action")
        is_add = action == "add"

        model_state = request.model_state
        model_state.validators = {
            "ProfileID": ciocvalidators.IDValidator(not_empty=not is_add)
        }
        model_state.method = None

        if not model_state.validate():
            # XXX invalid ProfileID

            self._error_page(_("Invalid ID", request))

        ProfileID = model_state.form.data.get("ProfileID")

        profile = None
        profile_descriptions = {}
        views = []
        fields = []
        view_descs = []
        field_descs = []

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC dbo.sp_CIC_ExcelProfile_s ?, ?",
                request.dboptions.MemberID,
                ProfileID,
            )
            profile = cursor.fetchone()
            if profile:
                cursor.nextset()
                for lng in cursor.fetchall():
                    profile_descriptions[lng.Culture.replace("-", "_")] = lng

                cursor.nextset()

                fields = cursor.fetchall()

                cursor.nextset()

                views = cursor.fetchall()

            cursor.close()

            if not is_add and not profile:
                # not found
                self._error_page(_("Profile Not Found", request))

            cursor = conn.execute(
                "EXEC dbo.sp_CIC_ExcelProfile_s_FormLists ?, ?",
                request.MemberID,
                ProfileID,
            )

            view_descs = cursor.fetchall()

            cursor.nextset()

            field_descs = cursor.fetchall()

            cursor.close()

        fieldorder = [str(f.FieldID) for f in field_descs]
        field_sort_key = {f.FieldID: i for i, f in enumerate(field_descs)}
        field_descs = {str(f.FieldID): f for f in field_descs}

        model_state.form.data["profile"] = profile
        model_state.form.data["descriptions"] = profile_descriptions
        model_state.form.data["Views"] = [str(v.ViewType) for v in views]

        # we need to ensure that the Field Data is in the right order or the field labels get mixed up.
        model_state.form.data["Fields"] = sorted(
            fields, key=lambda x: field_sort_key.get(x.FieldID, 99999)
        )

        if profile:
            model_state.form.data[
                "profile.ColumnHeadersWeb"
            ] = column_headers_reverse.get(profile.ColumnHeaders, "L")

        if is_add:
            for desc in profile_descriptions.values():
                desc.Name = None

        title = _("Manage Excel Profiles", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                action=action,
                profile=profile,
                profile_descriptions=profile_descriptions,
                ProfileID=ProfileID,
                fieldorder=fieldorder,
                field_descs=field_descs,
                view_descs=view_descs,
            ),
            no_index=True,
        )

    @view_config(
        match_param="action=delete", renderer="cioc.web:templates/confirmdelete.mak"
    )
    def delete(self):
        request = self.request
        user = request.user

        if not user.SuperUser:
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {
            "ProfileID": ciocvalidators.IDValidator(not_empty=True)
        }
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid ID", request))

        ProfileID = model_state.form.data["ProfileID"]

        request.override_renderer = "cioc.web:templates/confirmdelete.mak"

        title = _("Manage Excel Profiles", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                id_name="ProfileID",
                id_value=ProfileID,
                route="admin_excelprofile",
                action="delete",
            ),
            no_index=True,
        )

    @view_config(match_param="action=delete", request_method="POST")
    def delete_confirm(self):
        request = self.request
        user = request.user

        if not user.SuperUser:
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {
            "ProfileID": ciocvalidators.IDValidator(not_empty=True)
        }
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid ID", request))

        ProfileID = model_state.form.data["ProfileID"]

        with request.connmgr.get_connection("admin") as conn:
            sql = """
            DECLARE @ErrMsg as nvarchar(500),
            @RC as int

            EXECUTE @RC = dbo.sp_CIC_ExcelProfile_d ?, ?, @ErrMsg=@ErrMsg OUTPUT

            SELECT @RC as [Return], @ErrMsg AS ErrMsg
            """

            cursor = conn.execute(sql, ProfileID, request.dboptions.MemberID)
            result = cursor.fetchone()
            cursor.close()

        if not result.Return:
            self._go_to_route(
                "admin_excelprofile_index",
                _query=[
                    ("InfoMsg", _("The Profile was successfully deleted.", request))
                ],
            )

        if result.Return == 3:
            self._error_page(
                _("Unable to delete Excel Profile: ", request) + result.ErrMsg
            )

        self._go_to_route(
            "admin_excelprofile",
            action="edit",
            _query=[
                ("ErrMsg", _("Unable to delete Excel Profile: ") + result.ErrMsg),
                ("ProfileID", ProfileID),
            ],
        )
