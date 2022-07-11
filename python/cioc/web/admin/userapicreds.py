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

from uuid import uuid4

# 3rd party
from formencode import Schema, ForEach, All
from formencode.variabledecode import variable_decode
from pyramid.view import view_config, view_defaults

# thisapp
from cioc.core import validators, constants as const, security
from cioc.core.rootfactories import BasicRootFactory

from cioc.core.i18n import gettext as _
from cioc.core.viewbase import error_page
from cioc.web.admin.viewbase import AdminViewBase

log = logging.getLogger(__name__)
templateprefix = "cioc.web.admin:templates/userapicreds/"


class AdminUserApiCredsContext(BasicRootFactory):
    def __init__(self, request, *args, **kwargs):
        self.list_page = kwargs.pop("list_page", False)

        super(AdminUserApiCredsContext, self).__init__(request, *args, **kwargs)
        self.request = request

        if request.user.CanManageUsers:
            # check for a UserID parameter
            user_id = request.params.get("User_ID")
            log.debug("userid: %s", user_id)
            if user_id:
                return self.get_user_from_id(user_id)

        self.get_user_from_id(request.user.User_ID)

    def get_user_from_id(self, user_id):
        request = self.request
        try:
            user_id = validators.IDValidator().to_python(user_id)
        except validators.Invalid as error:
            error_page(
                request,
                _("Invalid User_ID: %s") % error.msg,
                const.DM_GLOBAL,
                const.DM_GLOBAL,
                _("User API Credentials"),
            )

        if user_id == self.request.user.User_ID:
            self.user = self.request.user
            if self.list_page:
                sql = "EXEC sp_GBL_Users_APICreds_l ?, ?, ?"
                with request.connmgr.get_connection("admin") as conn:
                    self.cred_list = conn.execute(
                        sql, request.dboptions.MemberID, None, user_id
                    ).fetchall()

            return

        sql = """
			DECLARE @MemberID int = ?, @AgencyCode char(3) = ?, @User_ID int = ?
			EXEC sp_GBL_Users_s_APICreds @MemberID, @AgencyCode, @User_ID
			"""
        if self.list_page:
            sql += "EXEC sp_GBL_Users_APICreds_l @MemberID, @AgencyCode, @User_ID"

        with request.connmgr.get_connection("admin") as conn:
            cursor = conn.execute(
                sql,
                request.dboptions.MemberID,
                None if request.user.SuperUser else request.user.Agency,
                user_id,
            )
            self.user = cursor.fetchone()
            if not self.user:
                error_page(
                    request,
                    _("User not found"),
                    const.DM_GLOBAL,
                    const.DM_GLOBAL,
                    _("User API Credentials"),
                )

            if self.list_page:
                cursor.nextset()
                self.cred_list = cursor.fetchall()


@view_defaults(route_name="admin_userapicreds")
class AdminUserApiCredsView(AdminViewBase):
    @view_config(
        route_name="admin_userapicreds_index", renderer=templateprefix + "index.mak"
    )
    def index(self):
        context = self.request.context
        title = _("User API Credentials for %s") % context.user.UserName
        return self._create_response_namespace(
            title,
            title,
            {"cred_list": context.cred_list, "cred_user": context.user},
            no_index=True,
        )

    @view_config(match_param="action=add", renderer=templateprefix + "add.mak")
    def add(self):
        context = self.request.context
        title = _("User API Credentials for %s") % context.user.UserName
        return self._create_response_namespace(
            title, title, {"cred_user": context.user}, no_index=True
        )

    @view_config(match_param="action=add", request_method="POST", renderer="json")
    def save(self):
        request = self.request
        context = self.request.context
        user = request.user

        cred_id = str(uuid4())
        cred_password = security.getRandomPassword(30)

        salt = security.MakeSalt()
        repeat = 20000
        hash = security.Crypt(salt, cred_password, repeat)

        usage_note = request.params.get("UsageNote")
        if usage_note:
            usage_note = usage_note.strip()[:150]

        usage_note = usage_note or None

        with request.connmgr.get_connection("admin") as conn:
            sql = """
				DECLARE @RC int, @ErrMsg nvarchar(500)
				EXEC @RC = sp_GBL_Users_APICreds_i ?, ?, ?, ?,?, ?, ?, ?, ?, @ErrMsg OUTPUT
				SELECT @RC AS [Return], @ErrMsg AS ErrMsg
			"""

            result = conn.execute(
                sql,
                request.dboptions.MemberID,
                None if user.SuperUser else user.Agency,
                user.Mod,
                context.user.User_ID,
                "{" + cred_id + "}",
                salt,
                repeat,
                hash,
                usage_note,
            ).fetchone()

            if result.Return:
                return {"success": False, "errormessage": result.ErrMsg}

        return {"success": True, "cred_id": cred_id, "cred_password": cred_password}

    @view_config(
        match_param="action=delete", renderer="cioc.web:templates/confirmdelete.mak"
    )
    def delete(self):
        request = self.request

        model_state = request.model_state

        model_state.validators = {
            "CredID": validators.UUIDValidator(not_empty=True),
        }
        model_state.method = None
        if not model_state.validate():
            self._error_page(
                _("Credential ID:", request) + model_state.renderer.errorlist("CredID")
            )

        CredID = model_state.form.data["CredID"]

        title = _("Delete Heading", request)
        return self._create_response_namespace(
            title,
            title,
            dict(
                id_name="CredID",
                id_value=CredID,
                route="cic_generalheading",
                action="delete",
                extra_values=[("User_ID", request.context.user.User_ID)],
            ),
            no_index=True,
        )

    @view_config(match_param="action=delete", request_method="POST")
    def delete_confirm(self):
        request = self.request

        model_state = request.model_state

        model_state.validators = {
            "CredID": validators.UUIDValidator(not_empty=True),
        }
        model_state.method = None

        if not model_state.validate():
            self._error_page(
                _("Credential ID:", request) + model_state.renderer.errorlist("CredID")
            )

        CredID = model_state.form.data["CredID"]

        with request.connmgr.get_connection("admin") as conn:
            sql = """
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_GBL_Users_APICreds_d ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			"""

            result = conn.execute(
                sql,
                request.dboptions.MemberID,
                None if request.user.SuperUser else request.user.Agency,
                request.context.user.User_ID,
                CredID,
            ).fetchone()

        if not result.Return:
            self._go_to_route(
                "admin_userapicreds_index",
                _query=[
                    ("User_ID", request.context.user.User_ID),
                    (
                        "InfoMsg",
                        _("The API credential was successfully deleted.", request),
                    ),
                ],
            )

        self._go_to_route(
            "admin_userapicreds_index",
            _query=[
                ("User_ID", request.context.user.User_ID),
                (
                    "ErrMsg",
                    _("Unable to delete API credential: ", request) + result.ErrMsg,
                ),
            ],
        )
