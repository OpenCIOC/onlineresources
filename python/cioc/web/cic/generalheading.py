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

from itertools import groupby
from operator import attrgetter
import xml.etree.ElementTree as ET
import collections

# 3rd party
from markupsafe import escape_silent as escape, Markup

from formencode import Schema, ForEach, All
from formencode.variabledecode import variable_decode
from pyramid.view import view_config, view_defaults

# thisapp
from cioc.core import validators, constants as const

from cioc.core.i18n import gettext as _
from cioc.web.cic.viewbase import CicViewBase

log = logging.getLogger(__name__)

templateprefix = "cioc.web.cic:templates/generalheading/"

UsedOptions = {"Y": True, "N": False, "T": None}
RUsedOptions = {v: k for k, v in UsedOptions.items()}


class GeneralHeadingBaseSchema(Schema):
    if_key_missing = None

    Used = validators.DictConverter(UsedOptions, if_emtpy=False, if_missing=False)
    NonPublic = validators.StringBool()
    DisplayOrder = validators.Int(min=0, max=validators.MAX_TINY_INT, if_empty=0)
    HeadingGroup = validators.IDValidator()

    TaxonomyRestrict = validators.Bool()
    TaxonomyName = validators.Bool()

    IconNameFull = validators.String(max=65)


base_fields = list(GeneralHeadingBaseSchema.fields.keys())


class GeneralHeadingDescriptionSchema(Schema):
    if_key_missing = None

    Name = validators.UnicodeString(max=200)


class GeneralHeadingSchema(validators.RootSchema):
    if_key_missing = None

    generalheading = GeneralHeadingBaseSchema()
    descriptions = validators.CultureDictSchema(
        GeneralHeadingDescriptionSchema(),
        pre_validators=[validators.DeleteKeyIfEmpty()],
    )

    RelatedHeadings = All(
        validators.Set(use_set=True), ForEach(validators.IDValidator())
    )


class CodeSchema(Schema):
    Code = ForEach(validators.TaxonomyCodeValidator)


class GeneralHeadingTaxonomySchema(GeneralHeadingSchema):

    MustMatch = ForEach(CodeSchema())
    MatchAny = ForEach(CodeSchema())

    chained_validators = [validators.RequireAtLeastOne(["MustMatch", "MatchAny"])]


EditValues = collections.namedtuple(
    "EditValues",
    "generalheading generalheading_descriptions relatedheadings generalheadings headinggroups pubcode must_match match_any terms is_add PB_ID, GH_ID",
)


@view_defaults(route_name="cic_generalheading")
class GeneralHeading(CicViewBase):
    @view_config(
        route_name="cic_generalheading_index", renderer=templateprefix + "index.mak"
    )
    def index(self):
        request = self.request
        user = request.user

        if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL:
            self._security_failure()

        model_state = request.model_state
        model_state.validators = {"PB_ID": validators.IDValidator(not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            # XXX invalid PB_ID

            self._error_page(_("Invalid Publication ID", request))

        headings = []
        with request.connmgr.get_connection("admin") as conn:
            headings = conn.execute(
                "EXEC dbo.sp_CIC_GeneralHeading_l_Admin ?, ?",
                request.dboptions.MemberID,
                model_state.value("PB_ID"),
            ).fetchall()
            for heading in headings:
                heading.Descriptions = self._culture_dict_from_xml(
                    heading.Descriptions, "DESC"
                )
                if heading.RelatedHeadings:
                    heading.RelatedHeadings = Markup(
                        "<br>".join(
                            escape(x["Name"])
                            for x in self._dict_list_from_xml(
                                heading.RelatedHeadings, "HEADING"
                            )
                        )
                    )

        title = _("Headings List", request)
        return self._create_response_namespace(
            title, title, dict(headings=headings), no_index=True
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
                "cic_generalheading",
                action="delete",
                _query=[
                    ("GH_ID", request.POST.get("GH_ID")),
                    ("PB_ID", request.POST.get("PB_ID")),
                ],
            )

        user = request.user

        if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL:
            self._security_failure()

        model_state = request.model_state
        model_state.form.variable_decode = True

        tax_heading = not not request.params.get("TaxonomyHeading")

        if tax_heading:
            model_state.schema = GeneralHeadingTaxonomySchema()
        else:
            model_state.schema = GeneralHeadingSchema()

        validator = validators.IDValidator(not_empty=True)
        try:
            PB_ID = validator.to_python(request.POST.get("PB_ID"))
        except validators.Invalid as e:
            self._error_page(_("Publication ID:", request) + e.msg)

        if user.cic.LimitedView and PB_ID and user.cic.PB_ID != PB_ID:
            self._security_failure()

        validator = validators.IDValidator()
        try:
            GH_ID = validator.to_python(request.POST.get("GH_ID"))
        except validators.Invalid:
            self._error_page(_("Invalid Heading ID", request))

        is_add = not GH_ID

        if model_state.validate():
            # valid. Save changes and redirect

            kwargs = fields = base_fields[:]

            if tax_heading:
                fields.remove("Used")

            form_data = model_state.form.data
            generalheading = form_data.get("generalheading")
            args = [
                GH_ID,
                user.Mod,
                request.dboptions.MemberID,
                not request.dboptions.OtherMembersActive or user.cic.SuperUserGlobal,
                PB_ID,
            ]
            args.extend(generalheading.get(x) for x in fields)

            if tax_heading:
                args.append(None)
                kwargs.append("Used")

            root = ET.Element("DESCS")

            for culture, data in (form_data["descriptions"] or {}).items():
                desc = ET.SubElement(root, "DESC")
                ET.SubElement(desc, "Culture").text = culture.replace("_", "-")
                for name, value in data.items():
                    if value:
                        ET.SubElement(desc, name).text = value

            args.append(ET.tostring(root, encoding="unicode"))
            kwargs.append("Descriptions")

            root = ET.Element("HEADINGS")

            for value in form_data["RelatedHeadings"] or []:
                desc = ET.SubElement(root, "HEADING").text = str(value)

            args.append(ET.tostring(root, encoding="unicode"))
            kwargs.append("RelatedHeadings")

            if tax_heading:
                for code_type in ["MustMatch", "MatchAny"]:
                    root = ET.Element("terms")
                    for link in form_data[code_type] or []:
                        link_el = ET.SubElement(root, "link")
                        for code in link["Code"]:
                            ET.SubElement(link_el, "code").text = code

                    args.append(ET.tostring(root, encoding="unicode"))
                    kwargs.append(code_type)

            kwargstr = ", ".join(x.join(("@", "=?")) for x in kwargs)

            with request.connmgr.get_connection("admin") as conn:
                sql = (
                    """
                DECLARE @ErrMsg as nvarchar(500),
                @RC as int,
                @GH_ID as int

                SET @GH_ID = ?

                EXECUTE @RC = dbo.sp_CIC_GeneralHeading_u @GH_ID OUTPUT, ?, ?, ?, ?, %s, @ErrMsg=@ErrMsg OUTPUT

                SELECT @RC as [Return], @ErrMsg AS ErrMsg, @GH_ID as GH_ID
                """
                    % kwargstr
                )

                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:
                GH_ID = result.GH_ID
                if is_add:
                    msg = _("The General Heading has been successfully added.", request)
                else:
                    msg = _(
                        "The General Heading has been successfully updated.", request
                    )

                self._go_to_route(
                    "cic_generalheading",
                    action="edit",
                    _query=[("InfoMsg", msg), ("GH_ID", GH_ID), ("PB_ID", PB_ID)],
                )

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:
            ErrMsg = _("There were validation errors.")

        data = model_state.form.data

        tmp_data = variable_decode(request.POST)

        match_any = tmp_data.get("MatchAny") or []
        must_match = tmp_data.get("MustMatch") or []

        extra_codes = [y for x in match_any + must_match for y in x["Code"]]

        edit_values = self._get_edit_info(is_add, PB_ID, GH_ID, extra_codes)._asdict()
        edit_values["ErrMsg"] = ErrMsg

        val = model_state.value("generalheading.Used")
        data["generalheading.Used"] = RUsedOptions.get(val, val)
        data["RelatedHeadings"] = request.POST.getall("RelatedHeadings")
        data["MustMatch"] = must_match
        data["MatchAny"] = match_any

        if is_add:
            title = _("Add Heading", request)
        else:
            title = (
                _("Edit Heading: %s", request)
                % edit_values["generalheading"].CurrentDisplayName
            )
        return self._create_response_namespace(title, title, edit_values, no_index=True)

    @view_config(match_param="action=edit", renderer=templateprefix + "edit.mak")
    def edit(self):
        request = self.request
        user = request.user

        if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL:
            self._security_failure()

        model_state = request.model_state
        model_state.validators = {
            "PB_ID": validators.IDValidator(not_empty=True),
            "GH_ID": validators.IDValidator(),
        }
        model_state.method = None

        if not model_state.validate():
            # XXX invalid PB_ID
            if model_state.is_error("PB_ID"):
                self._error_page(_("Invalid Publication ID", request))

            self._error_page(_("Invalid Heading ID", request))

        PB_ID = model_state.value("PB_ID")
        GH_ID = model_state.value("GH_ID")
        is_add = not GH_ID

        if user.cic.LimitedView and PB_ID and PB_ID != user.cic.PB_ID:
            self._security_failure()

        edit_values = self._get_edit_info(is_add, PB_ID, GH_ID)

        data = model_state.form.data
        data["generalheading"] = edit_values.generalheading
        data["descriptions"] = edit_values.generalheading_descriptions
        data["RelatedHeadings"] = edit_values.relatedheadings
        data["MustMatch"] = edit_values.must_match
        data["MatchAny"] = edit_values.match_any

        if not is_add:
            val = edit_values.generalheading.Used
            data["generalheading.Used"] = RUsedOptions.get(val, val)

        if is_add:
            title = _("Add Heading", request)
        else:
            title = (
                _("Edit Heading: %s", request)
                % edit_values.generalheading.CurrentDisplayName
            )

        return self._create_response_namespace(
            title, title, edit_values._asdict(), no_index=True
        )

    def _get_edit_info(self, is_add, PB_ID, GH_ID, extra_codes=None):
        request = self.request
        user = request.user

        # core data
        generalheading = None
        generalheading_descriptions = {}
        relatedheadings = set()
        terms = []

        # ancillary display data
        generalheadings = []
        headinggroups = []

        with request.connmgr.get_connection("admin") as conn:
            if not is_add:
                sql = "EXEC dbo.sp_CIC_GeneralHeading_s ?, ?, ?"
                cursor = conn.execute(
                    sql, request.dboptions.MemberID, user.Agency, GH_ID
                )
                generalheading = cursor.fetchone()
                if generalheading:
                    PB_ID = generalheading.PB_ID
                    if user.cic.LimitedView and not PB_ID == user.cic.PB_ID:
                        self._security_failure()

                    cursor.nextset()
                    for lng in cursor.fetchall():
                        generalheading_descriptions[lng.Culture.replace("-", "_")] = lng

                    cursor.nextset()

                    relatedheadings = {str(x[0]) for x in cursor.fetchall()}

                    cursor.nextset()

                    terms = cursor.fetchall()

                cursor.close()

                if not generalheading:
                    # not found
                    self._error_page(_("Heading Not Found", request))

            codes = {x.Code for x in terms}
            if extra_codes:
                codes.update(extra_codes)

            cursor = conn.execute(
                """
                        DECLARE @PB_ID int=?
                        SELECT PubCode,MemberID, CanEditHeadingsShared FROM CIC_Publication WHERE PB_ID=@PB_ID
                        EXEC dbo.sp_CIC_GeneralHeading_l_Related ?, @PB_ID
                        EXEC dbo.sp_CIC_GeneralHeading_Group_l @PB_ID
                        EXEC dbo.sp_TAX_Term_l_GeneralHeading ?""",
                PB_ID,
                GH_ID,
                ",".join(codes),
            )

            publication = cursor.fetchone()

            cursor.nextset()

            generalheadings = cursor.fetchall()

            cursor.nextset()

            headinggroups = list(map(tuple, cursor.fetchall()))

            cursor.nextset()

            term_map = dict(map(tuple, cursor.fetchall()))

            cursor.close()

        if not publication:
            self._error_page(_("Publication Not Found", request))

        if (
            publication.MemberID is None
            and request.dboptions.OtherMembersActive
            and not request.user.cic.SuperUserGlobal
            and not publication.CanEditHeadingsShared
        ):
            self._go_to_route("cic_generalheading_index", _query=[("PB_ID", PB_ID)])

        must_match = []
        match_any = []
        for k, g in groupby(terms, key=attrgetter("MatchAny")):
            target = match_any if k else must_match
            target.extend(
                {"Code": [x.Code for x in h]}
                for k, h in groupby(g, key=attrgetter("GH_TAX_ID"))
            )

        return EditValues(
            generalheading,
            generalheading_descriptions,
            relatedheadings,
            generalheadings,
            headinggroups,
            publication.PubCode,
            must_match,
            match_any,
            term_map,
            is_add,
            PB_ID,
            GH_ID,
        )

    @view_config(
        match_param="action=delete", renderer="cioc.web:templates/confirmdelete.mak"
    )
    def delete(self):
        request = self.request
        user = request.user

        if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL:
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {
            "GH_ID": validators.IDValidator(not_empty=True),
            "PB_ID": validators.IDValidator(not_empty=True),
        }
        model_state.method = None

        if not model_state.validate():
            if model_state.is_error("PB_ID"):
                self._error_page(
                    _("Publication ID:", request)
                    + model_state.renderer.errorlist("PB_ID")
                )

            self._error_page(_("Invalid Heading ID", request))

        GH_ID = model_state.form.data["GH_ID"]
        PB_ID = model_state.form.data["PB_ID"]

        if user.cic.LimitedView and PB_ID and user.cic.PB_ID != PB_ID:
            self._security_failure()

        request.override_renderer = "cioc.web:templates/confirmdelete.mak"

        title = _("Delete Heading", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                id_name="GH_ID",
                id_value=GH_ID,
                route="cic_generalheading",
                action="delete",
                extra_values=[("PB_ID", PB_ID)],
            ),
            no_index=True,
        )

    @view_config(match_param="action=delete", request_method="POST")
    def delete_confirm(self):
        request = self.request
        user = request.user

        if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL:
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {
            "GH_ID": validators.IDValidator(not_empty=True),
            "PB_ID": validators.IDValidator(not_empty=True),
        }
        model_state.method = None

        if not model_state.validate():
            if model_state.is_error("PB_ID"):
                self._error_page(
                    _("Publication ID:", request)
                    + model_state.renderer.errorlist("PB_ID")
                )

            self._error_page(_("Invalid Heading ID", request))

        GH_ID = model_state.form.data["GH_ID"]
        PB_ID = model_state.form.data["PB_ID"]

        if user.cic.LimitedView and PB_ID != user.cic.PB_ID:
            self._security_failure()

        with request.connmgr.get_connection("admin") as conn:
            sql = """
            DECLARE @ErrMsg as nvarchar(500),
            @RC as int

            EXECUTE @RC = dbo.sp_CIC_GeneralHeading_d ?, ?, ?,?, @ErrMsg=@ErrMsg OUTPUT

            SELECT @RC as [Return], @ErrMsg AS ErrMsg
            """

            # XXX Enforce only delete general headings belonging to LimitedView users.
            cursor = conn.execute(
                sql,
                request.dboptions.MemberID,
                not request.dboptions.OtherMembersActive or user.cic.SuperUserGlobal,
                GH_ID,
                user.cic.PB_ID if user.cic.LimitedView else None,
            )
            result = cursor.fetchone()
            cursor.close()

        if not result.Return:
            self._go_to_route(
                "cic_publication",
                action="edit",
                _query=[
                    ("PB_ID", model_state.value("PB_ID")),
                    (
                        "InfoMsg",
                        _("The General Heading was successfully deleted.", request),
                    ),
                ],
            )

        if result.Return == 3:
            # XXX check that this is the only #3
            self._error_page(_("Unable to delete Heading:", request) + result.ErrMsg)

        self._go_to_route(
            "cic_generalheading",
            action="edit",
            _query=[
                ("ErrMsg", _("Unable to delete Heading: ") + result.ErrMsg),
                ("GH_ID", GH_ID),
            ],
        )
