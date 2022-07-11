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


from formencode import Schema

from pyramid.view import view_config

from cioc.core import i18n, validators as ciocvalidators
from cioc.web.cic import viewbase

_ = i18n.gettext


class RegisterSchema(Schema):
    allow_extra_fields = True
    filter_extra_fields = True

    MachineName = ciocvalidators.UnicodeString(max=255, not_empty=True)
    PublicKey = ciocvalidators.UnicodeString(max=1000, not_empty=True)


@view_config(route_name="offline_register", renderer="json")
class Register(viewbase.CicViewBase):
    def __call__(self):
        request = self.request

        if not request.dboptions.UseOfflineTools:
            return {
                "fail": True,
                "message": _("Offline Tools not enabled for this database."),
            }

        request.response.content_type = "application/json"
        if not request.user:
            # security failure
            # response = request.response
            # response.status = "Not Authorized"
            # response.status_int = 401
            # response.headers['WWW-Authenticate'] = 'Basic realm="CIOC Offline Tools"'
            return {"fail": True, "message": _("Invalid Username or Password", request)}

        if not request.user.cic.ViewTypeOffline:
            return {
                "fail": True,
                "message": _("User does not have offline tool permissions", request),
            }

        model_state = request.model_state
        model_state.schema = RegisterSchema()
        if not model_state.validate():
            # validation error
            return {
                "fail": True,
                "message": _("invalid request", request),
                "errordetail": model_state.form.errors,
            }

        with request.connmgr.get_connection("admin") as conn:
            result = conn.execute(
                """
                         SET NOCOUNT ON
                         DECLARE @RC int, @ErrMsg nvarchar(500)
                         EXEC @RC = sp_CIC_Offline_Machine_i ?,?,?, @ErrMsg OUTPUT
                         SELECT @RC AS [Return], @ErrMsg AS ErrMsg
                            """,
                request.user.cic.SL_ID,
                model_state.value("MachineName"),
                model_state.value("PublicKey"),
            ).fetchone()

        if result.Return:
            # error
            return {"fail": True, "message": result.ErrMsg}

        return {"fail": False}
