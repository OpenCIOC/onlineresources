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

import collections

from formencode import Schema, validators, foreach, variabledecode, Any
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators
from cioc.web.admin.viewbase import AdminViewBase

from cioc.core.i18n import gettext as _

templateprefix = "cioc.web.admin:templates/thesaurus/"

EditValues = collections.namedtuple("EditValues", "sources")


def description_required(value_dict, state):
    exid = value_dict.get("SRC_ID")
    if exid and exid != "NEW":
        return True
    return False


class ThesaurusSourceDescriptionSchema(Schema):
    if_key_missing = None

    SourceName = ciocvalidators.UnicodeString(max=100, not_empty=True)


class ThesaurusSourceBaseSchema(Schema):
    if_key_missing = None

    SRC_ID = Any(ciocvalidators.IDValidator(), validators.OneOf(["NEW"]))
    Descriptions = ciocvalidators.CultureDictSchema(
        ThesaurusSourceDescriptionSchema(),
        record_cultures=False,
        allow_extra_fields=True,
        fiter_extra_fields=False,
        delete_empty=True,
        pre_validators=[ciocvalidators.DeleteKeyIfEmpty()],
    )

    delete = validators.Bool()


class PostSchema(Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    if_key_missing = None

    source = foreach.ForEach(ThesaurusSourceBaseSchema())


@view_defaults(
    route_name="admin_thesaurus",
    match_param="action=source",
    renderer=templateprefix + "source.mak",
)
class ThesaurusSource(AdminViewBase):
    @view_config()
    def source(self):
        request = self.request

        if not request.user.cic.SuperUserGlobal:
            self._security_failure()

        sources, usage = self._get_source_edit_info()

        # raise Exception

        request.model_state.form.data["source"] = sources

        title = _("Manage Thesaurus Source Values", request)
        return self._create_response_namespace(
            title, title, {"sources": sources, "usage": usage}, no_index=True
        )

    @view_config(request_method="POST")
    def save_source(self):
        request = self.request
        user = request.user

        if not request.user.cic.SuperUserGlobal:
            self._security_failure()

        model_state = request.model_state
        model_state.schema = PostSchema()

        model_state.form.variable_decode = True

        if model_state.validate():
            # valid. Save changes and redirect

            root = ET.Element("Sources")
            for i, source in enumerate(model_state.form.data["source"]):
                src_id = source.get("SRC_ID")
                if source.get("delete"):
                    continue

                descriptions = source.get("Descriptions") or {}

                if src_id == "NEW" and not any(
                    x.get("SourceName") for x in descriptions.values()
                ):
                    continue

                source_el = ET.SubElement(root, "Source")
                ET.SubElement(source_el, "CNT").text = six.text_type(i)

                if src_id == "NEW":
                    src_id = -1

                ET.SubElement(source_el, "SRC_ID").text = six.text_type(src_id)

                descs = ET.SubElement(source_el, "DESCS")
                for culture, value in six.iteritems((descriptions or {})):
                    value = value.get("SourceName")
                    if value is not None:
                        desc = ET.SubElement(descs, "DESC")
                        ET.SubElement(desc, "Culture").text = six.text_type(
                            culture.replace("_", "-")
                        )
                        ET.SubElement(desc, "SourceName").text = six.text_type(value)

            args = [user.Mod, ET.tostring(root, encoding="unicode")]

            # raise Exception
            with request.connmgr.get_connection("admin") as conn:
                sql = """
				DECLARE @ErrMsg as nvarchar(500), 
				@RC as int 

				EXECUTE @RC = dbo.sp_THS_Source_u ?, ?, @ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				"""

                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:

                self._go_to_route(
                    "admin_thesaurus",
                    action="source",
                    _query=[
                        (
                            "InfoMsg",
                            _(
                                "The Thesaurus Sources have been successfully updated.",
                                request,
                            ),
                        )
                    ],
                )

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:
            ErrMsg = _("There were validation errors.")

        edit_values = {}

        edit_values["usage"] = self._get_source_edit_info()[1]

        sources = edit_values["sources"] = variabledecode.variable_decode(request.POST)[
            "source"
        ]

        model_state.form.data["source"] = sources

        edit_values["ErrMsg"] = ErrMsg

        # errors = model_state.form.errors
        # raise Exception()

        title = _("Manage Thesaurus Source Values", request)
        return self._create_response_namespace(title, title, edit_values, no_index=True)

    def _get_source_edit_info(self):
        request = self.request

        sources = []
        usage = {}
        with request.connmgr.get_connection("admin") as conn:
            sources = conn.execute("EXEC sp_THS_Source_lf").fetchall()

        for source in sources:
            usage[six.text_type(source.SRC_ID)] = source.Usage
            source.Descriptions = self._culture_dict_from_xml(
                source.Descriptions, "DESC"
            )

        return sources, usage
