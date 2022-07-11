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

from formencode import Schema, validators, foreach, variabledecode
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators, constants as const, syslanguage

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = "cioc.web.admin:templates/"


class FieldDescriptionSchema(Schema):
    if_key_missing = None

    FieldDisplay = ciocvalidators.UnicodeString(max=100)


class FieldBaseSchema(Schema):
    if_key_missing = None

    FieldID = ciocvalidators.IDValidator()
    DisplayOrder = validators.Int(min=0, max=256, not_empty=True)
    Required = validators.Bool()

    Descriptions = ciocvalidators.CultureDictSchema(
        FieldDescriptionSchema(),
        record_cultures=True,
        allow_extra_fields=True,
        fiter_extra_fields=False,
    )


class PostSchema(Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    if_key_missing = None

    pre_validators = [viewbase.cull_extra_cultures("Descriptions", "field")]
    field = foreach.ForEach(FieldBaseSchema())


@view_defaults(
    route_name="admin_fielddisplay", renderer=templateprefix + "fielddisplay.mak"
)
class FieldDisplay(viewbase.AdminViewBase):
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
                "EXEC sp_%s_FieldOption_l_Display ?"
                % ("GBL" if domain.id == const.DM_CIC else domain.str),
                request.MemberID,
            )
            fields = cursor.fetchall()
            cursor.close()

        for field in fields:
            field.Descriptions = self._culture_dict_from_xml(field.Descriptions, "DESC")

        record_cultures = syslanguage.active_record_cultures()

        fieldinfo_map = dict((str(f.FieldID), f) for f in fields)
        request.model_state.form.data["field"] = fields

        title = _("Change Field Display", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                fields=fields,
                record_cultures=record_cultures,
                domain=domain,
                shown_cultures=shown_cultures,
                fieldinfo_map=fieldinfo_map,
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

            root = ET.Element("FIELDS")
            for field in model_state.form.data["field"]:
                field_el = ET.SubElement(root, "Field")
                for key, value in six.iteritems(field):
                    if key != "Descriptions":
                        ET.SubElement(field_el, key).text = six.text_type(value)
                        continue

                    descs = ET.SubElement(field_el, "DESCS")
                    for culture in shown_cultures:

                        desc = ET.SubElement(descs, "DESC")
                        ET.SubElement(desc, "Culture").text = culture
                        for key, val in six.iteritems(
                            (value.get(culture.replace("-", "_")) or {})
                        ):
                            if val:
                                ET.SubElement(desc, key).text = val

            args = [
                user.Mod,
                request.dboptions.MemberID,
                (domain.id == const.DM_CIC and user.cic.SuperUserGlobal)
                or (domain.id == const.DM_VOL and user.vol.SuperUserGlobal),
                ET.tostring(root, encoding="unicode"),
            ]

            sql = (
                """
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_%s_Fields_u ?, ?, ?, ?, @ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			"""
                % domain.str
            )

            with request.connmgr.get_connection("admin") as conn:

                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:

                self._go_to_route(
                    "admin_fielddisplay",
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
                "EXEC sp_%s_FieldOption_l_Display ?, 0"
                % ("GBL" if domain.id == const.DM_CIC else domain.str),
                request.MemberID,
            ).fetchall()

        # errors = model_state.form.errors
        # raise Exception()
        # XXX should we refetch the basic info?

        fieldinfo_map = dict((str(f.FieldID), f) for f in fields)

        fields = variabledecode.variable_decode(request.POST)["field"]

        record_cultures = syslanguage.active_record_cultures()

        title = _("Change Field Display", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                fields=fields,
                record_cultures=record_cultures,
                domain=domain,
                shown_cultures=shown_cultures,
                fieldinfo_map=fieldinfo_map,
                ErrMsg=ErrMsg,
            ),
            no_index=True,
        )
