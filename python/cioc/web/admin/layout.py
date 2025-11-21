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


import xml.etree.ElementTree as ET

try:
    from cgi import escape
except ImportError:
    from html import escape
import urllib.request, urllib.error, urllib.parse
import codecs
import os

from formencode import Schema, validators
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators
from cioc.core.utils import read_file

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase
from cioc.core.template import _system_layout_dir

log = logging.getLogger(__name__)

templateprefix = "cioc.web.admin:templates/layout/"


class LayoutBaseSchema(Schema):
    if_key_missing = None

    Owner = ciocvalidators.AgencyCodeValidator()

    AlmostStandardsMode = validators.StringBool(if_empty=False)
    LayoutCSS = ciocvalidators.UnicodeString()
    LayoutCSSURL = ciocvalidators.Url(max=255)
    UseFullCIOCBootstrap = validators.Bool()


class LayoutDescriptionSchema(Schema):
    if_key_missing = None

    LayoutName = ciocvalidators.UnicodeString(max=150, not_empty=True)
    LayoutHTML = ciocvalidators.UnicodeString()
    LayoutHTMLURL = ciocvalidators.Url(max=255)
    chained_validators = [
        ciocvalidators.RequireIfAny(
            "LayoutName", present=["LayoutHTML", "LayoutHTMLURL"]
        ),
    ]


class LayoutSchema(Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    if_key_missing = None

    layout = LayoutBaseSchema()
    descriptions = ciocvalidators.CultureDictSchema(
        LayoutDescriptionSchema(),
        pre_validators=[ciocvalidators.DeleteKeyIfEmpty()],
        chained_validators=[
            ciocvalidators.FlagRequiredIfNoCulture(LayoutDescriptionSchema)
        ],
    )


@view_defaults(route_name="admin_template_layout")
class TemplateLayout(viewbase.AdminViewBase):
    @view_config(
        route_name="admin_template_layout_index", renderer=templateprefix + "index.mak"
    )
    def index(self):
        request = self.request
        user = request.user

        if not (user.SuperUser or user.WebDeveloper):
            self._security_failure()

        with request.connmgr.get_connection() as conn:
            cursor = conn.execute(
                "EXEC sp_GBL_Template_Layout_l ?, NULL, NULL",
                request.dboptions.MemberID,
            )
            layouts = cursor.fetchall()
            cursor.close()

        title = _("Manage Template Layouts", request)
        return self._create_response_namespace(
            title, title, dict(layouts=layouts), no_index=True
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
        user = request.user

        if not (user.SuperUser or user.WebDeveloper):
            self._security_failure()

        action = request.matchdict.get("action")
        is_add = action == "add"

        if not is_add and request.params.get("Delete"):
            return self._go_to_route(
                "admin_template_layout",
                action="delete",
                _query=[("LayoutID", request.params.get("LayoutID"))],
            )

        extra_validators = {}
        model_state = request.model_state
        if not is_add:
            extra_validators["LayoutID"] = ciocvalidators.IDValidator(not_empty=True)

        schema = model_state.schema = LayoutSchema(**extra_validators)

        schema.fields["layout"].add_field(
            "LayoutType",
            validators.OneOf(
                ["header", "footer", "cicsearch", "volsearch"], not_empty=is_add
            ),
        )

        model_state.form.variable_decode = True

        if model_state.validate():
            # valid. Save changes and redirect
            if not is_add:
                LayoutID = model_state.form.data["LayoutID"]
            else:
                LayoutID = None

            args = [LayoutID, user.Mod, request.dboptions.MemberID, user.Agency]
            layout = model_state.form.data["layout"]
            args.extend(
                layout.get(k)
                for k in (
                    "Owner",
                    "LayoutType",
                    "LayoutCSS",
                    "LayoutCSSURL",
                    "AlmostStandardsMode",
                    "UseFullCIOCBootstrap",
                )
            )

            root = ET.Element("DESCS")

            for culture, data in model_state.form.data["descriptions"].items():
                desc = ET.SubElement(root, "DESC")
                ET.SubElement(desc, "LANG").text = culture.replace("_", "-")
                for name, value in data.items():
                    if value:
                        ET.SubElement(desc, name).text = value

            args.append(ET.tostring(root, encoding="unicode"))

            with request.connmgr.get_connection("admin") as conn:
                sql = """
                DECLARE @ErrMsg as nvarchar(500),
                @RC as int,
                @LayoutID as int

                SET @LayoutID = ?

                EXECUTE @RC = dbo.sp_GBL_Template_Layout_u @LayoutID OUTPUT, %s, @ErrMsg OUTPUT

                SELECT @RC as [Return], @ErrMsg AS ErrMsg, @LayoutID as LayoutID
                """ % (
                    ", ".join(["?"] * (len(args) - 1))
                )
                log.debug("sql, args: %s, %s", sql, args)
                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:
                LayoutID = result.LayoutID

                if is_add:
                    msg = _("The Template Layout was successfully added.", request)
                else:
                    msg = _("The Template Layout was successfully updated.", request)

                self.request.dboptions._invalidate()
                self._go_to_route(
                    "admin_template_layout",
                    action="edit",
                    _query=[("InfoMsg", msg), ("LayoutID", LayoutID)],
                )

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:
            if model_state.is_error("layout.LayoutID"):
                self._error_page(_("Invalid Layout ID", request))

            ErrMsg = _("There were validation errors.")

        layout = None
        if not is_add:
            with request.connmgr.get_connection("admin") as conn:
                cursor = conn.execute(
                    "EXEC sp_GBL_Template_Layout_s ?, ?, ?",
                    request.dboptions.MemberID,
                    user.Agency,
                    model_state.value("LayoutID"),
                )
                layout = cursor.fetchone()
                cursor.close()

        templates = None
        if not is_add:
            templates = self._get_status_info(layout)

        title = _("Manage Template Layouts", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                action=action,
                LayoutID=model_state.value("LayoutID"),
                layout=layout,
                templates=templates,
                ErrMsg=ErrMsg,
            ),
            no_index=True,
        )

    @view_config(match_param="action=edit", renderer=templateprefix + "edit.mak")
    @view_config(match_param="action=add", renderer=templateprefix + "edit.mak")
    def edit(self):
        request = self.request
        user = request.user

        if not (user.SuperUser or user.WebDeveloper):
            self._security_failure()

        action = request.matchdict.get("action")
        is_add = action == "add"

        model_state = request.model_state
        model_state.validators = {
            "LayoutID": ciocvalidators.IDValidator(not_empty=not is_add)
        }
        model_state.method = None

        if not model_state.validate():
            # XXX invalid LayoutID

            self._error_page(_("Invalid ID", request))

        LayoutID = model_state.value("LayoutID")

        layout = None
        layout_descriptions = {}

        if LayoutID:
            with request.connmgr.get_connection("admin") as conn:
                cursor = conn.execute(
                    "EXEC dbo.sp_GBL_Template_Layout_s ?, ?, ?",
                    request.dboptions.MemberID,
                    user.Agency,
                    LayoutID,
                )
                layout = cursor.fetchone()
                if layout is not None:
                    cursor.nextset()
                    for lng in cursor.fetchall():
                        layout_descriptions[lng.Culture.replace("-", "_")] = lng

                cursor.close()

        if not is_add and layout is None:
            # not found
            self._error_page(_("Layout not found.", request))

        model_state.form.data["layout"] = layout
        model_state.form.data["descriptions"] = layout_descriptions

        if layout and layout.SystemLayout:
            if layout.LayoutCSSURL:
                layout.LayoutCSS = read_file(
                    os.path.join(_system_layout_dir, layout.LayoutCSSURL)
                )
                layout.LayoutCSSURL = None

            for desc in layout_descriptions.values():
                if desc.LayoutHTMLURL:
                    desc.LayoutHTML = read_file(
                        os.path.join(_system_layout_dir, desc.LayoutHTMLURL)
                    )
                    desc.LayoutHTMLURL = None

        templates = None
        if is_add and layout:
            layout.SystemLayout = False
            for desc in layout_descriptions.values():
                desc.LayoutName = None
        else:
            if is_add:
                model_state.form.data["layout.AlmostStandardsMode"] = "False"

            templates = self._get_status_info(layout)

        title = _("Manage Template Layouts", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                action=action,
                layout=layout,
                layout_descriptions=layout_descriptions,
                LayoutID=LayoutID,
                templates=templates,
            ),
            no_index=True,
        )

    def _get_status_info(self, layout):
        if not layout or not layout.RELATED_TEMPLATE:
            return None

        passvars = self.request.passvars
        agency = self.request.user.Agency

        retval = []
        xml = ET.fromstring(layout.RELATED_TEMPLATE.encode("utf8"))
        MemberID = str(self.request.dboptions.MemberID)
        for template in xml.findall("./TMPL"):

            if (
                template.get("Owner", agency) == agency
                and template.get("MemberID", MemberID) == MemberID
            ):
                retval.append(
                    '<a href="%s">%s</a>'
                    % (
                        escape(
                            passvars.route_path(
                                "admin_template",
                                action="edit",
                                _query=[("TemplateID", template.get("Template_ID"))],
                            ),
                            True,
                        ),
                        escape(template.get("Name"), True),
                    )
                )

            else:
                retval.append(escape(template.get("Name"), True))

        return retval

    @view_config(
        match_param="action=delete", renderer="cioc.web:templates/confirmdelete.mak"
    )
    def delete(self):
        request = self.request
        user = request.user

        if not (user.SuperUser or user.WebDeveloper):
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {
            "LayoutID": ciocvalidators.IDValidator(not_empty=True)
        }
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid ID", request))

        LayoutID = model_state.form.data["LayoutID"]

        request.override_renderer = "cioc.web:templates/confirmdelete.mak"

        title = _("Manage Template Layouts", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                id_name="LayoutID",
                id_value=LayoutID,
                route="admin_template_layout",
                action="delete",
            ),
            no_index=True,
        )

    @view_config(match_param="action=delete", request_method="POST")
    def delete_confirm(self):
        request = self.request
        user = request.user

        if not (user.SuperUser or user.WebDeveloper):
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {
            "LayoutID": ciocvalidators.IDValidator(not_empty=True)
        }
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid ID", request))

        LayoutID = model_state.form.data["LayoutID"]

        with request.connmgr.get_connection("admin") as conn:
            sql = """
            DECLARE @ErrMsg as nvarchar(500),
            @RC as int

            EXECUTE @RC = dbo.sp_GBL_Template_Layout_d ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

            SELECT @RC as [Return], @ErrMsg AS ErrMsg
            """

            cursor = conn.execute(
                sql, LayoutID, request.dboptions.MemberID, user.Agency
            )
            result = cursor.fetchone()
            cursor.close()

        if not result.Return:
            self._go_to_route(
                "admin_template_layout_index",
                _query=[
                    (
                        "InfoMsg",
                        _("The Template Layout was successfully deleted.", request),
                    )
                ],
            )

        if result.Return == 3:
            self._error_page(
                _("Unable to delete Template Layout: ", request) + result.ErrMsg
            )

        self._go_to_route(
            "admin_template_layout",
            action="edit",
            _query=[
                ("ErrMsg", _("Unable to delete Template Layout: ") + result.ErrMsg),
                ("LayoutID", LayoutID),
            ],
        )

    @view_config(match_param="action=fetch", renderer="json")
    def fetch(self):
        request = self.request
        user = request.user

        if not (user.SuperUser or user.WebDeveloper):
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {"url": ciocvalidators.Url(max=255, not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            return {
                "fail": True,
                "message": "URL not valid:" + ",".join(model_state.errors_for("url")),
            }

        try:
            response = urllib.request.urlopen("https://" + model_state.form.data["url"])

            headers = response.info()
            contenttype = headers["Content-Type"].split(";")
            codec = codecs.lookup("cp1252")
            if len(contenttype) > 1:
                charset = contenttype[1].split("=")
                if len(charset) > 1:
                    try:
                        codec = codecs.lookup(charset[1])
                    except LookupError:
                        pass

            data = codec.decode(response.read())[0]
            log.debug(data)

            return {"fail": False, "data": data}
        except urllib.error.HTTPError as e:
            return {"fail": True, "message": str(e)}
