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


from pyramid.decorator import reify


class VolProfileUser:
    def __init__(self, request):
        self.request = request

        self._checked = False
        self._set_no_login()

    @reify
    def LoggedIn(self):
        self._check()
        return self._logged_in

    @reify
    def Email(self):
        self._check()
        return self._email

    @reify
    def ProfileID(self):
        self._check()
        return self._profile_id

    def _check(self):
        request = self.request

        if self._checked:
            return

        self._checked = True

        if not self.request.dboptions.UseVolunteerProfiles:
            return

        email_addr, profile_key = self._get_login_params()

        if not email_addr or not profile_key:
            return

        with self.request.connmgr.get_connection("admin") as conn:
            sql = """DECLARE @RC int, @ProfileID uniqueidentifier, @ErrMsg nvarchar(500)
                    EXEC @RC = dbo.sp_VOL_Profile_s_Login ?, ?, ?, @ProfileID OUTPUT, @ErrMsg OUTPUT
                    SELECT @RC AS [Return], @ProfileID AS ProfileID, @ErrMsg AS ErrMsg"""

            result = conn.execute(
                sql, request.dboptions.MemberID, email_addr, profile_key
            ).fetchone()

            if not result.Return:
                self._logged_in = True
                self._email = email_addr
                self._profile_id = "{" + result.ProfileID + "}"

    def _get_login_params(self):
        request = self.request

        email_addr, profile_key = get_auth_principal(request)
        if not email_addr or not profile_key:
            return None, None

        email_addr = email_addr.strip().lower()[:60]
        profile_key = profile_key.strip().lower()[:32]

        return email_addr, profile_key

    def _set_no_login(self):
        self._logged_in = False
        self._email = None
        self._profile_id = None

    def __nonzero__(self):
        return self.LoggedIn


_userid_key = "vprofileauth.userid"
_login_key = "vporfileauth.login_key"


def get_auth_principal(request):
    login = request.session.get(_userid_key)
    key = request.session.get(_login_key)
    return login, key


def remember(request, principal, **kw):
    request.session[_userid_key] = str(principal)
    login_key = kw.get("login_key")
    if login_key:
        request.session[_login_key] = str(login_key)
    return []


def forget(request):
    if _userid_key in request.session:
        del request.session[_userid_key]
    if _login_key in request.session:
        del request.session[_login_key]


def do_logout(request):
    forget(request)
    request.session.invalidate()


def do_login(request, principal, login_key):
    # bump session timeout to 2 days
    request.session.adjust_session_timeout(3600 * 24 * 2)
    remember(request, principal, login_key=login_key)
