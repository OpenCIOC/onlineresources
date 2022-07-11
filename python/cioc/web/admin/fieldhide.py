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

log = logging.getLogger(__name__)

from formencode import Schema, ForEach
from pyramid.view import view_defaults, view_config

from cioc.core import validators as ciocvalidators, constants as const, syslanguage

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = "cioc.web.admin:templates/"


class PostSchema(Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    if_key_missing = None

    HideField = ForEach(ciocvalidators.IDValidator())


@view_defaults(route_name="admin_fieldhide", renderer=templateprefix + "fieldhide.mak")
class FieldHide(viewbase.AdminViewBase):
    @view_config()
    def index(self):
        request = self.request
        user = request.user

        if not user.SuperUser:
            self._security_failure()

        domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
        if not domain:
            return self._go_to_page("~/admin/setup.asp")

        if (domain.id == const.DM_CIC and not user.cic.SuperUser) or (
            domain.id == const.DM_VOL and not user.vol.SuperUser
        ):

            self._security_failure()

        fields = []
        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC sp_%s_FieldOption_l_Hide ?"
                % ("GBL" if domain.id == const.DM_CIC else domain.str),
                request.MemberID,
            )
            fields = cursor.fetchall()
            cursor.close()

        for field in fields:
            field.Descriptions = self._culture_dict_from_xml(field.Descriptions, "DESC")

        # raise Exception

        record_cultures = syslanguage.active_record_cultures()

        request.model_state.form.data["HideField"] = [
            str(f.FieldID) for f in fields if f.InactiveByMember
        ]

        title = _("Manage Hidden Fields", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                fields=fields,
                record_cultures=record_cultures,
                domain=domain,
                shown_cultures=shown_cultures,
            ),
            no_index=True,
        )

    @view_config(request_method="POST")
    def save(self):
        request = self.request
        user = request.user

        if not user.SuperUser:
            self._security_failure()

        domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
        if not domain:
            return self._go_to_page("~/admin/setup.asp")

        if (domain.id == const.DM_CIC and not user.cic.SuperUser) or (
            domain.id == const.DM_VOL and not user.vol.SuperUser
        ):

            self._security_failure()

        model_state = request.model_state
        model_state.schema = PostSchema()
        model_state.form.variable_decode = True

        if model_state.validate():
            # valid. Save changes and redirect

            args = [
                request.dboptions.MemberID,
                ",".join(map(str, model_state.value("HideField") or [])),
            ]

            sql = (
                """
            DECLARE @ErrMsg as nvarchar(500),
            @RC as int

            EXECUTE @RC = dbo.sp_%s_Fields_u_InactiveByMember ?,?, @ErrMsg OUTPUT

            SELECT @RC as [Return], @ErrMsg AS ErrMsg
            """
                % domain.str
            )

            # raise Exception
            with request.connmgr.get_connection("admin") as conn:

                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:

                self._go_to_route(
                    "admin_fieldhide",
                    _query=(
                        ("InfoMsg", _("The Fields were sucessfully updated.", request)),
                        ("ShowCultures", shown_cultures),
                        ("DM", domain.id),
                    ),
                )

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:
            ErrMsg = _("There were validation errors.")

        fields = []
        with request.connmgr.get_connection("admin") as conn:
            fields = conn.execute(
                "EXEC sp_%s_FieldOption_l_Hide ?"
                % ("GBL" if domain.id == const.DM_CIC else domain.str),
                request.MemberID,
            ).fetchall()

        # errors = model_state.form.errors
        # raise Exception()
        # XXX should we refetch the basic info?

        for field in fields:
            field.Descriptions = self._culture_dict_from_xml(field.Descriptions, "DESC")

        record_cultures = syslanguage.active_record_cultures()

        title = _("Manage Hidden Fields", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                fields=fields,
                record_cultures=record_cultures,
                domain=domain,
                shown_cultures=shown_cultures,
                ErrMsg=ErrMsg,
            ),
            no_index=True,
        )
