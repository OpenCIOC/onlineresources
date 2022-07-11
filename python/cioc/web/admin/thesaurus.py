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

# third party
from pyramid.view import view_config, view_defaults
from formencode import ForEach, Schema, All

from cioc.core import validators, rootfactories, constants as const

from cioc.core.i18n import gettext as _
from cioc.core.viewbase import security_failure, init_page_info, error_page
from cioc.web.admin.viewbase import AdminViewBase
import six

log = logging.getLogger(__name__)

templateprefix = "cioc.web.admin:templates/thesaurus/"


class ThesaurusContext(rootfactories.BasicRootFactory):
    def __init__(self, request):
        request.context = self
        self.request = request

        # required to use go_to_page
        init_page_info(request, const.DM_GLOBAL, const.DM_GLOBAL)

        user = request.user

        if not user.cic.SuperUser:
            security_failure(request)

        SubjID = request.params.get("SubjID")
        validator = validators.IDValidator()
        try:
            SubjID = validator.to_python(SubjID)
        except validators.Invalid:
            error_page(
                request,
                _("Invalid ID", request),
                const.DM_GLOBAL,
                const.DM_GLOBAL,
                _("Manage Subjects", request),
            )

        self.SubjID = SubjID
        self.is_add = not SubjID

        subject = None
        if SubjID:
            with request.connmgr.get_connection("admin") as conn:
                subject = conn.execute(
                    "EXEC dbo.sp_THS_Subject_s_Basic ?, ?",
                    SubjID,
                    request.dboptions.MemberID,
                ).fetchone()

        if SubjID and not subject:
            error_page(
                request,
                _("Subject Not Found", request),
                const.DM_GLOBAL,
                const.DM_GLOBAL,
                _("Manage Subjects", request),
            )

        self.subject = subject


AuthorizedOptions = {"F": False, "T": True}
RAuthorizedOptions = dict((v, k) for k, v in six.iteritems(AuthorizedOptions))

UsedOptions = {"U": True, "N": False}
RUsedOptions = dict((v, k) for k, v in six.iteritems(UsedOptions))

UseAllOptions = {"ALL": True, "ANY": False}
RUseAllOptions = dict((v, k) for k, v in six.iteritems(UseAllOptions))


class ThesaurusInactivateSchema(Schema):
    Inactive = validators.Bool()


class ThesaurusLocalBaseSchema(validators.RootSchema):
    if_key_missing = None

    Used = validators.DictConverter(UsedOptions)
    UseAll = validators.DictConverter(UseAllOptions)
    SubjCat_ID = validators.IDValidator()
    SRC_ID = validators.IDValidator()
    Inactive = validators.Bool()


class ThesaurusSharedBaseSchema(ThesaurusLocalBaseSchema):
    Authorized = validators.DictConverter(AuthorizedOptions, if_empty=False)


class ThesaurusDescriptionSchema(Schema):
    if_key_missing = None

    Name = validators.UnicodeString(max=200, not_empty=True)
    Notes = validators.UnicodeString(max=8000)


class ThesaurusFullSchema(validators.RootSchema):
    if_key_missing = None

    # subject added at runtime
    # subject = ThesaurusBaseSchema()
    descriptions = validators.CultureDictSchema(
        ThesaurusDescriptionSchema(),
        pre_validators=[validators.DeleteKeyIfEmpty()],
        chained_validators=[
            validators.FlagRequiredIfNoCulture(ThesaurusDescriptionSchema)
        ],
    )
    UseSubj_ID = All(validators.Set(use_set=True), ForEach(validators.IDValidator()))
    BroaderSubj_ID = All(
        validators.Set(use_set=True), ForEach(validators.IDValidator())
    )
    RelatedSubj_ID = All(
        validators.Set(use_set=True), ForEach(validators.IDValidator())
    )

    MakeShared = validators.Bool()


@view_defaults(route_name="admin_thesaurus")
class Thesaurus(AdminViewBase):
    @view_config(
        match_param="action=edit",
        request_method="POST",
        renderer=templateprefix + "edit.mak",
    )
    def save(self):
        request = self.request
        context = request.context

        if request.POST.get("Delete"):
            self._go_to_route(
                "admin_thesaurus",
                action="delete",
                _query=[("SubjID", request.POST.get("SubjID"))],
            )

        user = request.user

        SubjID = context.SubjID
        is_add = context.is_add

        stored_proc_variant = ""
        subj_id_output = "OUTPUT"
        if is_add:
            schema = ThesaurusFullSchema(subject=ThesaurusLocalBaseSchema())
        else:
            if user.cic.SuperUserGlobal:
                if context.subject.MemberID is None:
                    subject_schema = ThesaurusSharedBaseSchema()
                else:
                    subject_schema = ThesaurusLocalBaseSchema()
                schema = ThesaurusFullSchema(subject=subject_schema)

            else:
                if context.subject.MemberID is None:
                    schema = validators.RootSchema(subject=ThesaurusInactivateSchema())
                    stored_proc_variant = "_Inactivate"
                    subj_id_output = ""
                if context.subject.MemberID == request.dboptions.MemberID:
                    schema = ThesaurusFullSchema(subject=ThesaurusLocalBaseSchema())
                else:
                    # editing term not owned by SuperUser Membership
                    self._security_failure()

        model_state = request.model_state
        model_state.schema = schema
        model_state.form.variable_decode = True

        base_fields = list(schema.fields["subject"].fields.keys())

        if model_state.validate():
            # valid. Save changes and redirect

            form_data = model_state.form.data

            args = [SubjID, user.Mod, request.dboptions.MemberID]

            subject = form_data.get("subject")
            args.extend(subject.get(x) for x in base_fields)
            kwargs = base_fields

            if not is_add and user.cic.SuperUserGlobal:
                args.append(not not form_data.get("MakeShared"))
                kwargs.append("MakeShared")

            if (
                is_add
                or user.cic.SuperUserGlobal
                or context.subject.MemberID == request.dboptions.MemberID
            ):
                root = ET.Element("DESCS")

                for culture, data in six.iteritems(form_data["descriptions"]):
                    desc = ET.SubElement(root, "DESC")
                    ET.SubElement(desc, "Culture").text = culture.replace("_", "-")
                    for name, value in six.iteritems(data):
                        if value:
                            ET.SubElement(desc, name).text = value

                args.append(ET.tostring(root, encoding="unicode"))
                kwargs.append("Descriptions")

                for field in ["UseSubj_ID", "BroaderSubj_ID", "RelatedSubj_ID"]:
                    root = ET.Element("SUBJS")
                    for value in form_data[field] or []:
                        ET.SubElement(root, "SUBJ").text = six.text_type(value)

                    args.append(ET.tostring(root, encoding="unicode"))

                kwargs.extend(["UseSubj", "BroaderSubj", "RelatedSubj"])

                # xml = args[-1]
                # raise Exception

            kwargstr = ", ".join(x.join(("@", "=?")) for x in kwargs)
            log.debug("kwargs: %s", kwargs)
            log.debug("args: %s", args)

            with request.connmgr.get_connection("admin") as conn:
                sql = """
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int,
				@SubjID as int

				SET @SubjID = ?

				EXECUTE @RC = dbo.sp_THS_Subject_u%s @SubjID %s, ?, ?, %s, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg, @SubjID as SubjID
				""" % (
                    stored_proc_variant,
                    subj_id_output,
                    kwargstr,
                )

                log.debug("sql: %s", sql)

                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:
                SubjID = result.SubjID

                if is_add:
                    msg = _("The Subject Term has been successfully added.", request)
                else:
                    msg = _("The Subject Term has been successfully updated.", request)

                self._go_to_route(
                    "admin_thesaurus",
                    action="edit",
                    _query=(("InfoMsg", msg), ("SubjID", SubjID)),
                )

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:
            ErrMsg = _("There were validation errors.")
            log.debug("errors: %s", model_state.form.errors)

        usesubjects = set()
        broadersubjects = set()
        relatedsubjects = set()

        usage = None
        categories = []
        sources = []
        other_term_descs = []

        used_for = []
        narrower = []

        with request.connmgr.get_connection("admin") as conn:
            extra_subjs = set(
                request.POST.getall("UseSubj_ID")
                + request.POST.getall("BroaderSubj_ID")
                + request.POST.getall("ReleatedSubj_ID")
            )
            log.debug(
                "params: %s, %s, %s", request.dboptions.MemberID, SubjID, extra_subjs
            )
            cursor = conn.execute(
                "EXEC dbo.sp_THS_Subject_s_FormLists ?, ?, ?",
                request.dboptions.MemberID,
                SubjID,
                ",".join(extra_subjs),
            )

            usage = cursor.fetchone()

            cursor.nextset()

            categories = [tuple(x) for x in cursor.fetchall()]

            cursor.nextset()

            sources = [tuple(x) for x in cursor.fetchall()]

            cursor.nextset()

            other_term_descs = cursor.fetchall()

            cursor.nextset()

            used_for = cursor.fetchall()

            cursor.nextset()

            narrower = cursor.fetchall()

            cursor.close()

            if not is_add:
                cursor = conn.execute(
                    "EXEC dbo.sp_THS_Subject_s ?, 1", request.POST.get("SubjID")
                )

                usesubjects = set(six.text_type(x[0]) for x in cursor.fetchall())

                cursor.nextset()

                broadersubjects = set(six.text_type(x[0]) for x in cursor.fetchall())

                cursor.nextset()

                relatedsubjects = set(six.text_type(x[0]) for x in cursor.fetchall())

                cursor.close()

        data = model_state.form.data

        val = model_state.value("subject.Authorized")
        data["subject.Authorized"] = RAuthorizedOptions.get(val, val)

        val = model_state.value("subject.Used")
        data["subject.Used"] = RUsedOptions.get(val, val)

        val = model_state.value("subject.UseAll")
        data["subject.UseAll"] = RUseAllOptions.get(val, val)

        val = data["UseSubj_ID"] = set(request.POST.getall("UseSubj_ID"))
        usesubjects |= val

        val = data["BroaderSubj_ID"] = set(request.POST.getall("BroaderSubj_ID"))
        broadersubjects |= val

        val = data["RelatedSubj_ID"] = set(request.POST.getall("RelatedSubj_ID"))
        relatedsubjects |= val

        # log.debug('errors: %s', model_state.form.errors)
        # errors = model_state.form.errors
        # data = model_state.form.data
        # raise Exception
        title = _("Manage Subjects", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                is_add=is_add,
                subject=context.subject,
                usage=usage,
                other_term_descs=other_term_descs,
                categories=categories,
                sources=sources,
                used_for=used_for,
                narrower=narrower,
                usesubjects=usesubjects,
                broadersubjects=broadersubjects,
                relatedsubjects=relatedsubjects,
                SubjID=request.POST.get("SubjID"),
                ErrMsg=ErrMsg,
            ),
            no_index=True,
        )

    @view_config(match_param="action=edit", renderer=templateprefix + "edit.mak")
    def edit(self):
        request = self.request

        context = request.context

        is_add = context.is_add
        SubjID = context.SubjID

        subject = context.subject
        subject_descriptions = {}

        usesubjects = []
        broadersubjects = []
        relatedsubjects = []

        usage = None
        categories = []
        sources = []
        other_term_descs = []

        used_for = []
        narrower = []

        with request.connmgr.get_connection("admin") as conn:
            if not is_add:
                cursor = conn.execute("EXEC dbo.sp_THS_Subject_s ?", SubjID)

                for lng in cursor.fetchall():
                    subject_descriptions[lng.Culture.replace("-", "_")] = lng

                cursor.nextset()

                usesubjects = set(six.text_type(x[0]) for x in cursor.fetchall())

                cursor.nextset()

                broadersubjects = set(six.text_type(x[0]) for x in cursor.fetchall())

                cursor.nextset()

                relatedsubjects = set(six.text_type(x[0]) for x in cursor.fetchall())

                cursor.close()

            if not is_add and not subject:
                # not found
                self._error_page(_("Subject Not Found", request))

            log.debug("params: %s, %s", request.dboptions.MemberID, SubjID)
            cursor = conn.execute(
                "EXEC dbo.sp_THS_Subject_s_FormLists ?, ?",
                request.dboptions.MemberID,
                SubjID,
            )

            usage = cursor.fetchone()

            cursor.nextset()

            categories = [tuple(x) for x in cursor.fetchall()]

            cursor.nextset()

            sources = [tuple(x) for x in cursor.fetchall()]

            cursor.nextset()

            other_term_descs = cursor.fetchall()

            cursor.nextset()

            used_for = cursor.fetchall()

            cursor.nextset()

            narrower = cursor.fetchall()

            cursor.close()

        data = request.model_state.form.data
        data["subject"] = subject
        data["descriptions"] = subject_descriptions
        data["UseSubj_ID"] = usesubjects
        data["BroaderSubj_ID"] = broadersubjects
        data["RelatedSubj_ID"] = relatedsubjects

        if subject:
            data["subject.Authorized"] = "T" if subject.Authorized else "F"
            data["subject.Used"] = "U" if subject.Used else "N"
            data["subject.UseAll"] = "ALL" if subject.UseAll else "ANY"

        title = _("Manage Subjects", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                is_add=is_add,
                subject=subject,
                usage=usage,
                other_term_descs=other_term_descs,
                categories=categories,
                sources=sources,
                used_for=used_for,
                narrower=narrower,
                usesubjects=usesubjects,
                broadersubjects=broadersubjects,
                relatedsubjects=relatedsubjects,
                SubjID=SubjID,
            ),
            no_index=True,
        )

    @view_config(
        match_param="action=delete", renderer="cioc.web:templates/confirmdelete.mak"
    )
    def delete(self):
        request = self.request
        user = request.user

        if not user.cic or not user.cic.SuperUser:
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {"SubjID": validators.IDValidator(not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid Subject ID", request))

        SubjID = model_state.form.data["SubjID"]

        request.override_renderer = "cioc.web:templates/confirmdelete.mak"

        title = _("Manage Subjects", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                id_name="SubjID",
                id_value=SubjID,
                route="admin_thesaurus",
                action="delete",
            ),
            no_index=True,
        )

    @view_config(match_param="action=delete", request_method="POST")
    def delete_confirm(self):
        request = self.request
        user = request.user

        if not user.cic or not user.cic.SuperUser:
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {"SubjID": validators.IDValidator(not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid Subject ID", request))

        SubjID = model_state.form.data["SubjID"]

        with request.connmgr.get_connection("admin") as conn:
            sql = """
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_THS_Subject_d ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			"""

            cursor = conn.execute(
                sql,
                SubjID,
                None
                if request.user.cic.SuperUserGlobal
                else request.dboptions.MemberID,
            )
            result = cursor.fetchone()
            cursor.close()

        if not result.Return:
            self._go_to_page(
                "~/admin/thesaurus.asp",
                {
                    "InfoMsg": _(
                        "The Subject Term has been successfully deleted.", request
                    )
                },
            )

        if result.Return == 3:
            # XXX check that this is the only #3
            self._error_page(_("Unable to delete Subject:", request) + result.ErrMsg)

        self._go_to_route(
            "admin_thesaurus",
            action="edit",
            _query=[
                ("ErrMsg", _("Unable to delete Subject: ") + result.ErrMsg),
                ("SubjID", SubjID),
            ],
        )
