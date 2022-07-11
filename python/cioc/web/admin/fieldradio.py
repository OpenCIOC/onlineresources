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

# import elementtree.ElementTree as ET

from formencode import Schema, foreach, variabledecode
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators, constants as const, syslanguage

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = "cioc.web.admin:templates/"


class FieldDescriptionSchema(Schema):
    if_key_missing = None

    CheckboxOnText = ciocvalidators.UnicodeString(max=20, not_empty=True)
    CheckboxOffText = ciocvalidators.UnicodeString(max=20, not_empty=True)


class FieldBaseSchema(Schema):
    if_key_missing = None

    FieldID = ciocvalidators.IDValidator()

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
    route_name="admin_fieldradio", renderer=templateprefix + "fieldradio.mak"
)
class FieldRadio(viewbase.AdminViewBase):
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
        with request.connmgr.get_connection() as conn:
            cursor = conn.execute("EXEC sp_%s_Field_Radio_l" % domain.str)
            fields = cursor.fetchall()
            cursor.close()

        for field in fields:
            field.Descriptions = self._culture_dict_from_xml(field.Descriptions, "DESC")

        # raise Exception

        record_cultures = syslanguage.active_record_cultures()

        fieldinfo_map = dict((str(f.FieldID), f) for f in fields)
        request.model_state.form.data["field"] = fields

        title = _("Change Field Yes/No Values", request)
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

        if not user.SuperUserGlobal:
            self._security_failure()

        domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
        if not domain:
            return self._go_to_page("~/admin/setup.asp")

        if (domain.id == const.DM_CIC and not user.cic.SuperUserGlobal) or (
            domain.id == const.DM_VOL and not user.vol.SuperUserGlobal
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
                    if not value:
                        continue

                    if key != "Descriptions":
                        ET.SubElement(field_el, key).text = six.text_type(value)
                        continue

                    descs = ET.SubElement(field_el, "DESCS")
                    for culture, data in six.iteritems(value):
                        culture = culture.replace("_", "-")
                        if culture not in shown_cultures:
                            continue

                        desc = ET.SubElement(descs, "DESC")
                        ET.SubElement(desc, "Culture").text = culture.replace("_", "-")
                        for key, value in six.iteritems(data):
                            if value:
                                ET.SubElement(desc, key).text = value

            args = [user.Mod, ET.tostring(root, encoding="unicode")]

            # raise Exception
            with request.connmgr.get_connection("admin") as conn:
                sql = (
                    """
				DECLARE @ErrMsg as nvarchar(500), 
				@RC as int 

				EXECUTE @RC = dbo.sp_%s_Field_Radio_u ?, ?, @ErrMsg OUTPUT  

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				"""
                    % domain.str
                )

                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:

                self._go_to_route(
                    "admin_fieldradio",
                    _query=(
                        (
                            "InfoMsg",
                            _("The Yes/No values were updated successfully.", request),
                        ),
                        ("ShowCultures", shown_cultures),
                        ("DM", domain.id),
                    ),
                )

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:
            ErrMsg = _("There were validation errors.")

        fields = []
        with request.connmgr.get_connection("admin") as conn:
            fields = conn.execute("EXEC sp_%s_Field_Radio_l 1" % domain.str).fetchall()

        # errors = model_state.form.errors
        # raise Exception()
        # XXX should we refetch the basic info?

        fieldinfo_map = dict((str(f.FieldID), f) for f in fields)

        fields = variabledecode.variable_decode(request.POST)["field"]

        record_cultures = syslanguage.active_record_cultures()

        title = _("Change Field Yes/No Values", request)
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
