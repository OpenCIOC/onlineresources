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
from six.moves import map

log = logging.getLogger(__name__)

import xml.etree.cElementTree as ET

from pyramid.view import view_config, view_defaults

from cioc.core import validators, syslanguage

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = "cioc.web.admin:templates/interests/"


class InterestDescriptionSchema(validators.Schema):
    if_key_missing = None

    Name = validators.UnicodeString(max=200)


class InterestSchema(validators.Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    if_key_missing = None

    pre_validators = [viewbase.cull_extra_cultures("descriptions")]

    Code = validators.CodeValidator()
    descriptions = validators.CultureDictSchema(
        InterestDescriptionSchema(),
        record_cultures=True,
        delete_empty=False,
        chained_validators=[
            validators.FlagRequiredIfNoCulture(InterestDescriptionSchema)
        ],
    )
    groups = validators.All(
        validators.Set(use_set=True, if_missing=validators.NoDefault),
        validators.ForEach(
            validators.IDValidator(not_empty=True),
            not_empty=True,
            if_missing=validators.NoDefault,
        ),
    )


class HideSchema(validators.Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    if_key_missing = None

    ChkHide = validators.ForEach(validators.IDValidator())


@view_defaults(route_name="admin_interests")
class Interests(viewbase.AdminViewBase):
    def _get_interest_info(self):
        request = self.request
        user = request.user

        if not user.vol.SuperUser:
            self._security_failure()

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC sp_VOL_Interest_lf ?", request.dboptions.MemberID
            )
            interests = cursor.fetchall()
            cursor.close()

        for interest in interests:
            interest.Descriptions = self._culture_dict_from_xml(
                interest.Descriptions, "DESC"
            )
            if interest.Groups is not None:
                interest.Groups = " ; ".join(
                    x["Name"]
                    for x in self._dict_list_from_xml(interest.Groups, "GROUP")
                    if x.get("Name")
                )

        request.model_state.form.data["ChkHide"] = [
            six.text_type(x.AI_ID) for x in interests if x.Hidden
        ]
        domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
        record_cultures = syslanguage.active_record_cultures()

        title = _("Manage Areas of Interest", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                interests=interests,
                record_cultures=record_cultures,
                shown_cultures=shown_cultures,
            ),
            no_index=True,
        )

    @view_config(
        route_name="admin_interests_index",
        renderer=templateprefix + "index.mak",
        request_method="POST",
    )
    def hide(self):
        request = self.request
        user = request.user

        if not user.vol.SuperUser:
            self._security_failure()

        model_state = request.model_state
        model_state.schema = HideSchema()

        if model_state.validate():
            sql = "EXEC sp_VOL_Interest_u_Hide ?, ?"
            with request.connmgr.get_connection("admin") as conn:
                conn.execute(
                    sql,
                    request.dboptions.MemberID,
                    ",".join(map(str, model_state.value("ChkHide") or [])),
                )
            log.debug("ChkHide: %s", ",".join(map(str, model_state.value("ChkHide"))))
            return self._go_to_route(
                "admin_interests_index",
                _query=[("InfoMsg", _("Visibility Settings Saved", request))],
            )

        ChkHide = model_state.value("ChkHide")

        retval = self._get_interest_info()

        request.model_state.form.data["ChkHide"] = ChkHide

        return retval

    @view_config(
        route_name="admin_interests_index", renderer=templateprefix + "index.mak"
    )
    def index(self):
        request = self.request
        user = request.user

        if not user.vol.SuperUser:
            self._security_failure()

        return self._get_interest_info()

    @view_config(
        match_param="action=edit",
        request_method="POST",
        renderer=templateprefix + "edit.mak",
    )
    def save(self):
        request = self.request

        if request.POST.get("Delete"):
            self._go_to_route(
                "admin_interests",
                action="delete",
                _query=[("AI_ID", request.POST.get("AI_ID"))],
            )

        user = request.user

        if not user.vol.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state
        model_state.schema = InterestSchema()
        model_state.form.variable_decode = True

        validator = validators.IDValidator()
        try:
            AI_ID = validator.to_python(request.POST.get("AI_ID"))
        except validators.Invalid:
            self._error_page(_("Invalid Interest ID", request))

        is_add = not AI_ID

        domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)

        if model_state.validate():
            # valid. Save changes and redirect
            args = [AI_ID, user.Mod, model_state.value("Code")]

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

            root = ET.Element("GROUPS")
            for group_id in model_state.form.data["groups"]:
                ET.SubElement(root, "GROUP").text = six.text_type(group_id)

            args.append(ET.tostring(root, encoding="unicode"))

            with request.connmgr.get_connection("admin") as conn:
                sql = """
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int,
				@AI_ID as int

				SET @AI_ID = ?

				EXECUTE @RC = dbo.sp_VOL_Interest_u @AI_ID OUTPUT, %s, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg, @AI_ID as AI_ID
				""" % ", ".join(
                    "?" * (len(args) - 1)
                )

                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:
                AI_ID = result.AI_ID

                self._go_to_route(
                    "admin_interests",
                    action="edit",
                    _query=[
                        (
                            "InfoMsg",
                            _("The Interests were successfully updated.", request),
                        ),
                        ("AI_ID", AI_ID),
                        ("ShowCultures", shown_cultures),
                    ],
                )

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:

            ErrMsg = _("There were validation errors.")

        interest = None
        group_descs = []

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute("EXEC dbo.sp_VOL_Interest_s_FormLists")

            group_descs = cursor.fetchall()

            cursor.close()

            if not is_add:
                cursor = conn.execute("EXEC dbo.sp_VOL_Interest_s ?", AI_ID)

                interest = cursor.fetchone()

                cursor.close()

        record_cultures = syslanguage.active_record_cultures()
        model_state.form.data["groups"] = request.POST.getall("groups")

        title = _("Manage Areas of Interest", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                interest=interest,
                AI_ID=AI_ID,
                shown_cultures=shown_cultures,
                record_cultures=record_cultures,
                group_descs=group_descs,
                is_add=is_add,
                ErrMsg=ErrMsg,
            ),
            no_index=True,
        )

    @view_config(match_param="action=edit", renderer=templateprefix + "edit.mak")
    def edit(self):
        request = self.request
        user = request.user

        if request.params.get("Delete"):
            self._go_to_route(
                "admin_interests",
                action="delete",
                _query=[("AI_ID", request.GET.get("AI_ID"))],
            )

        if not user.vol.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state
        model_state.validators = {"AI_ID": validators.IDValidator()}
        model_state.method = None

        if not model_state.validate():
            # XXX invalid AI_ID
            self._error_page(_("Invalid ID", request))

        AI_ID = model_state.form.data.get("AI_ID")
        is_add = not AI_ID

        interest = None
        interest_descriptions = {}
        groups = []
        group_descs = []

        with request.connmgr.get_connection("admin") as conn:
            if not is_add:
                cursor = conn.execute("EXEC dbo.sp_VOL_Interest_s ?", AI_ID)
                interest = cursor.fetchone()
                if interest:
                    cursor.nextset()
                    for lng in cursor.fetchall():
                        interest_descriptions[lng.Culture.replace("-", "_")] = lng

                    cursor.nextset()
                    groups = [six.text_type(x[0]) for x in cursor.fetchall()]

                    cursor.close()

                if not interest:
                    # not found
                    self._error_page(_("Interest Not Found", request))

            cursor = conn.execute("EXEC dbo.sp_VOL_Interest_s_FormLists")

            group_descs = cursor.fetchall()

            cursor.close()

        domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)

        model_state.form.data["interest"] = interest
        if interest:
            model_state.form.data["Code"] = interest.Code
        model_state.form.data["descriptions"] = interest_descriptions
        model_state.form.data["groups"] = groups

        title = _("Manage Areas of Interest", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                interest=interest,
                AI_ID=AI_ID,
                is_add=is_add,
                shown_cultures=shown_cultures,
                group_descs=group_descs,
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

        if not user.vol.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {"AI_ID": validators.IDValidator(not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid ID", request))

        AI_ID = model_state.form.data["AI_ID"]

        request.override_renderer = "cioc.web:templates/confirmdelete.mak"

        title = _("Manage Areas of Interest", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                id_name="AI_ID",
                id_value=AI_ID,
                route="admin_interests",
                action="delete",
            ),
            no_index=True,
        )

    @view_config(match_param="action=delete", request_method="POST")
    def delete_confirm(self):
        request = self.request
        user = request.user

        if not user.vol.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {"AI_ID": validators.IDValidator(not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            self._(_("Invalid ID", request))

        AI_ID = model_state.form.data["AI_ID"]

        with request.connmgr.get_connection("admin") as conn:
            sql = """
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_VOL_Interest_d ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			"""

            cursor = conn.execute(sql, AI_ID)
            result = cursor.fetchone()
            cursor.close()

        if not result.Return:
            self._go_to_route(
                "admin_interests_index",
                _query=[
                    ("InfoMsg", _("The Interest was successfully deleted.", request))
                ],
            )

        if result.Return == 3:
            self._error_page(_("Unable to delete Interest: ", request) + result.ErrMsg)

        self._go_to_route(
            "admin_interests",
            action="edit",
            _query=[
                ("ErrMsg", _("Unable to delete Interest: ") + result.ErrMsg),
                ("AI_ID", AI_ID),
            ],
        )
