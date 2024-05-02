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
import tempfile
import zipfile
from datetime import datetime


from formencode import Schema, validators
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators
from cioc.core.bufferedzip import BufferedZipFile
from cioc.core.utf8csv import write_csv_to_zip
from cioc.core.webobfiletool import FileIterator

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

log = logging.getLogger(__name__)

surveyprefix = "cioc.web.admin:templates/applicationsurvey/"


class ApplicationSurveySchema(Schema):
    if_key_missing = None

    Archived = validators.Bool()
    Name = ciocvalidators.UnicodeString(max=255, not_empty=True)
    Title = ciocvalidators.UnicodeString(max=500, not_empty=True)
    Description = ciocvalidators.UnicodeString(max=8000)
    TextQuestion1 = ciocvalidators.UnicodeString(max=500)
    TextQuestion2 = ciocvalidators.UnicodeString(max=500)
    TextQuestion3 = ciocvalidators.UnicodeString(max=500)
    TextQuestion1Help = ciocvalidators.UnicodeString(max=4000)
    TextQuestion2Help = ciocvalidators.UnicodeString(max=4000)
    TextQuestion3Help = ciocvalidators.UnicodeString(max=4000)
    DDQuestion1 = ciocvalidators.UnicodeString(max=500)
    DDQuestion2 = ciocvalidators.UnicodeString(max=500)
    DDQuestion3 = ciocvalidators.UnicodeString(max=500)
    DDQuestion1Help = ciocvalidators.UnicodeString(max=4000)
    DDQuestion2Help = ciocvalidators.UnicodeString(max=4000)
    DDQuestion3Help = ciocvalidators.UnicodeString(max=4000)
    DDQuestion1Opt1 = ciocvalidators.UnicodeString(max=150)
    DDQuestion1Opt2 = ciocvalidators.UnicodeString(max=150)
    DDQuestion1Opt3 = ciocvalidators.UnicodeString(max=150)
    DDQuestion1Opt4 = ciocvalidators.UnicodeString(max=150)
    DDQuestion1Opt5 = ciocvalidators.UnicodeString(max=150)
    DDQuestion1Opt6 = ciocvalidators.UnicodeString(max=150)
    DDQuestion1Opt7 = ciocvalidators.UnicodeString(max=150)
    DDQuestion1Opt8 = ciocvalidators.UnicodeString(max=150)
    DDQuestion1Opt9 = ciocvalidators.UnicodeString(max=150)
    DDQuestion1Opt10 = ciocvalidators.UnicodeString(max=150)
    DDQuestion2Opt1 = ciocvalidators.UnicodeString(max=150)
    DDQuestion2Opt2 = ciocvalidators.UnicodeString(max=150)
    DDQuestion2Opt3 = ciocvalidators.UnicodeString(max=150)
    DDQuestion2Opt4 = ciocvalidators.UnicodeString(max=150)
    DDQuestion2Opt5 = ciocvalidators.UnicodeString(max=150)
    DDQuestion2Opt6 = ciocvalidators.UnicodeString(max=150)
    DDQuestion2Opt7 = ciocvalidators.UnicodeString(max=150)
    DDQuestion2Opt8 = ciocvalidators.UnicodeString(max=150)
    DDQuestion2Opt9 = ciocvalidators.UnicodeString(max=150)
    DDQuestion2Opt10 = ciocvalidators.UnicodeString(max=150)
    DDQuestion3Opt1 = ciocvalidators.UnicodeString(max=150)
    DDQuestion3Opt2 = ciocvalidators.UnicodeString(max=150)
    DDQuestion3Opt3 = ciocvalidators.UnicodeString(max=150)
    DDQuestion3Opt4 = ciocvalidators.UnicodeString(max=150)
    DDQuestion3Opt5 = ciocvalidators.UnicodeString(max=150)
    DDQuestion3Opt6 = ciocvalidators.UnicodeString(max=150)
    DDQuestion3Opt7 = ciocvalidators.UnicodeString(max=150)
    DDQuestion3Opt8 = ciocvalidators.UnicodeString(max=150)
    DDQuestion3Opt9 = ciocvalidators.UnicodeString(max=150)
    DDQuestion3Opt10 = ciocvalidators.UnicodeString(max=150)


all_fields = tuple(ApplicationSurveySchema.fields.keys())


class ApplicationReportSchema(Schema):

    APP_ID = ciocvalidators.IDValidator()
    StartDate = ciocvalidators.DateConverter()
    EndDate = ciocvalidators.DateConverter()
    ExportCSV = ciocvalidators.Bool()


@view_defaults(route_name="admin_applicationsurvey")
class TemplateApplicationSurvey(viewbase.AdminViewBase):
    @view_config(
        route_name="admin_applicationsurvey_index", renderer=surveyprefix + "index.mak"
    )
    def index(self):
        request = self.request
        user = request.user

        if not user.vol.SuperUser:
            self._security_failure()

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                "EXEC sp_VOL_ApplicationSurvey_l ?, 0",
                request.dboptions.MemberID,
            )
            applicationsurveys = cursor.fetchall()
            cursor.close()

        title = _("Manage Application Surveys", request)
        return self._create_response_namespace(
            title, title, dict(applicationsurveys=applicationsurveys), no_index=True
        )

    @view_config(
        match_param="action=edit",
        request_method="POST",
        renderer=surveyprefix + "edit.mak",
    )
    @view_config(
        match_param="action=add",
        request_method="POST",
        renderer=surveyprefix + "edit.mak",
    )
    def save(self):
        request = self.request
        user = request.user

        if not (user.vol.SuperUser):
            self._security_failure()

        action = request.matchdict.get("action")
        is_add = action == "add"

        if not is_add and request.params.get("Delete"):
            return self._go_to_route(
                "admin_applicationsurvey",
                action="delete",
                _query=[("APP_ID", request.params.get("APP_ID"))],
            )

        extra_validators = {}
        model_state = request.model_state
        if not is_add:
            extra_validators["APP_ID"] = ciocvalidators.IDValidator(not_empty=True)
        else:
            extra_validators["Culture"] = ciocvalidators.ActiveCulture(not_empty=True)

        schema = ciocvalidators.RootSchema(
            applicationsurvey=ApplicationSurveySchema(), **extra_validators
        )
        model_state.schema = schema
        model_state.form.variable_decode = True

        if model_state.validate():
            # valid. Save changes and redirect
            if not is_add:
                APP_ID = model_state.form.data["APP_ID"]
            else:
                APP_ID = None

            args = [
                APP_ID,
                user.Mod,
                request.dboptions.MemberID,
                model_state.value("Culture"),
            ]
            applicationsurvey = model_state.form.data["applicationsurvey"]

            kwargs = ", ".join(k.join(("@", "=?")) for k in all_fields)
            args.extend(applicationsurvey.get(k) for k in all_fields)

            with request.connmgr.get_connection("admin") as conn:
                sql = """
                DECLARE @ErrMsg as nvarchar(500),
                @RC as int,
                @APP_ID as int

                SET @APP_ID = ?

                EXECUTE @RC = dbo.sp_VOL_ApplicationSurvey_u @APP_ID OUTPUT, %s, @ErrMsg OUTPUT

                SELECT @RC as [Return], @ErrMsg AS ErrMsg, @APP_ID as APP_ID
                """ % (
                    ", ".join(["?"] * (len(args) - 1))
                )
                log.debug("sql, args: %s, %s", sql, args)
                cursor = conn.execute(sql, *args)
                result = cursor.fetchone()
                cursor.close()

            if not result.Return:
                APP_ID = result.APP_ID

                if is_add:
                    msg = _("The Application Survey was successfully added.", request)
                else:
                    msg = _("The Application Survey was successfully updated.", request)

                self.request.dboptions._invalidate()
                self._go_to_route(
                    "admin_applicationsurvey",
                    action="edit",
                    _query=[("InfoMsg", msg), ("APP_ID", APP_ID)],
                )

            ErrMsg = _("Unable to save: ") + result.ErrMsg

        else:
            if model_state.is_error("APP_ID"):
                self._error_page(_("Invalid Application Survey ID", request))

            ErrMsg = _("There were validation errors.")

        applicationsurvey = None
        if not is_add:
            with request.connmgr.get_connection("admin") as conn:
                cursor = conn.execute(
                    "EXEC sp_VOL_ApplicationSurvey_s ?, ?",
                    request.dboptions.MemberID,
                    model_state.value("APP_ID"),
                )
                applicationsurvey = cursor.fetchone()
                cursor.close()

        title = _("Manage Application Surveys", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                action=action,
                APP_ID=model_state.value("APP_ID"),
                applicationsurvey=applicationsurvey,
                ErrMsg=ErrMsg,
            ),
            no_index=True,
        )

    @view_config(match_param="action=edit", renderer=surveyprefix + "edit.mak")
    @view_config(match_param="action=add", renderer=surveyprefix + "edit.mak")
    def edit(self):
        request = self.request
        user = request.user

        if not user.vol.SuperUser:
            self._security_failure()

        action = request.matchdict.get("action")
        is_add = action == "add"

        model_state = request.model_state
        model_state.validators = {
            "APP_ID": ciocvalidators.IDValidator(not_empty=not is_add)
        }
        model_state.method = None

        if not model_state.validate():
            # XXX invalid APP_ID

            self._error_page(_("Invalid ID", request))

        APP_ID = model_state.value("APP_ID")

        applicationsurvey = None
        applicationsurvey_descriptions = {}

        if APP_ID:
            with request.connmgr.get_connection("admin") as conn:
                cursor = conn.execute(
                    "EXEC dbo.sp_VOL_ApplicationSurvey_s ?, ?",
                    request.dboptions.MemberID,
                    APP_ID,
                )
                applicationsurvey = cursor.fetchone()
                cursor.close()

        if not is_add and applicationsurvey is None:
            # not found
            self._error_page(_("Application Survey not found.", request))

        model_state.form.data["applicationsurvey"] = applicationsurvey

        title = _("Manage Application Surveys", request)
        return self._create_response_namespace(
            title,
            title,
            dict(action=action, applicationsurvey=applicationsurvey, APP_ID=APP_ID),
            no_index=True,
        )

    def _get_status_info(self, applicationsurvey):
        if not applicationsurvey or not applicationsurvey.RELATED_TEMPLATE:
            return None

        passvars = self.request.passvars
        agency = self.request.user.Agency

        retval = []
        MemberID = str(self.request.dboptions.MemberID)

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

        model_state.validators = {"APP_ID": ciocvalidators.IDValidator(not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid ID", request))

        APP_ID = model_state.form.data["APP_ID"]

        request.override_renderer = "cioc.web:templates/confirmdelete.mak"

        title = _("Manage Application Surveys", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                id_name="APP_ID",
                id_value=APP_ID,
                route="admin_applicationsurvey",
                action="delete",
            ),
            no_index=True,
        )

    @view_config(match_param="action=delete", request_method="POST")
    def delete_confirm(self):
        request = self.request
        user = request.user

        if not user.vol.SuperUser:
            self._security_failure()

        model_state = request.model_state

        model_state.validators = {"APP_ID": ciocvalidators.IDValidator(not_empty=True)}
        model_state.method = None

        if not model_state.validate():
            self._error_page(_("Invalid ID", request))

        APP_ID = model_state.form.data["APP_ID"]

        with request.connmgr.get_connection("admin") as conn:
            sql = """
            DECLARE @ErrMsg as nvarchar(500),
            @RC as int

            EXECUTE @RC = dbo.sp_VOL_ApplicationSurvey_d ?, ?, @ErrMsg=@ErrMsg OUTPUT

            SELECT @RC as [Return], @ErrMsg AS ErrMsg
            """

            cursor = conn.execute(sql, request.dboptions.MemberID, APP_ID)
            result = cursor.fetchone()
            cursor.close()

        if not result.Return:
            self._go_to_route(
                "admin_applicationsurvey_index",
                _query=[
                    (
                        "InfoMsg",
                        _("The Application Survey was successfully deleted.", request),
                    )
                ],
            )

        if result.Return == 3:
            self._error_page(
                _("Unable to delete Application Survey: ", request) + result.ErrMsg
            )

        self._go_to_route(
            "admin_applicationsurvey",
            action="edit",
            _query=[
                ("ErrMsg", _("Unable to delete Application Survey: ") + result.ErrMsg),
                ("APP_ID", APP_ID),
            ],
        )

    @view_config(
        match_param="action=report",
        renderer=surveyprefix + "report.mak",
    )
    def report(self):
        request = self.request
        user = request.user

        if not (user.SuperUser or user.WebDeveloper):
            self._security_failure()

        model_state = request.model_state
        model_state.method = None

        model_state.schema = ApplicationReportSchema()

        if not model_state.validate():
            self._go_to_route(
                "admin_applicationsurvey_index",
                _query=[
                    (
                        "ErrMsg",
                        _("Unable to generate Application Survey report: ")
                        + model_state.renderer.errorlist(),
                    ),
                ],
            )

        export_csv = model_state.value("ExportCSV")
        APP_ID = model_state.value("APP_ID")
        StartDate = model_state.value("StartDate")
        EndDate = model_state.value("EndDate")

        if export_csv:
            stored_proc = "dbo.sp_VOL_ApplicationSurvey_Report_Detail"
        else:
            stored_proc = "dbo.sp_VOL_ApplicationSurvey_Report_Summary"

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                f"EXEC {stored_proc} ?, ?, ?, ?",
                request.dboptions.MemberID,
                APP_ID,
                StartDate,
                EndDate,
            )

            if export_csv:
                file = tempfile.TemporaryFile()
                with BufferedZipFile(file, "w", zipfile.ZIP_DEFLATED) as zip:
                    write_csv_to_zip(
                        zip,
                        cursor,
                        "applicationsurveys.csv",
                    )

                length = file.tell()
                file.seek(0)
                res = request.response
                res.content_type = "application/zip"
                res.charset = None
                res.app_iter = FileIterator(file)
                res.content_length = length
                res.headers[
                    "Content-Disposition"
                ] = "attachment;filename=applicationsurveys-%s.zip" % (
                    datetime.today().isoformat("-").replace(":", "-").split(".")[0]
                )
                return res

            counts_by_survey = cursor.fetchall()

            cursor.nextset()

            counts_by_city = cursor.fetchall()

            cursor.nextset()

            counts_by_answer = cursor.fetchall()

            title = _("Application Surveys Report", request)
            return self._create_response_namespace(
                title,
                title,
                dict(
                    id_name="APP_ID",
                    id_value=APP_ID,
                    counts_by_survey=counts_by_survey,
                    counts_by_city=counts_by_city,
                    counts_by_answer=counts_by_answer,
                    start_date = StartDate,
                    end_date = EndDate
                ),
                no_index=True,
            )
