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


# std lib
from __future__ import absolute_import
import binascii
import hashlib
import re
from datetime import datetime
from random import SystemRandom as StrongRandom
from os import urandom as get_random_bytes

# 3rd party
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC as PBKDF2
from pyramid.decorator import reify

# this app
import cioc.core.constants as const
from cioc.core.i18n import gettext, format_datetime
from cioc.core.email import send_email, format_message
import six
from six.moves import range
import base64


def Crypt(salt, password, repeat):
	pbkdf2 = PBKDF2(
		algorithm=hashes.SHA1(),
		length=33,
		salt=salt.encode('utf-8'),
		iterations=int(repeat)
	)
	return base64.b64encode(pbkdf2.derive(password.encode('utf-8'))).decode('ascii').strip()


def MakeSalt():
	return base64.b64encode(get_random_bytes(33)).decode('ascii').strip()


def getRandomString(length):
	l, r = divmod(length, 2)
	return binascii.hexlify(get_random_bytes(l + r)).decode('ascii')[:length]

# Alphabet for generating passwords. Double up on the numbers so that
# they are not significantly less probable than the upper or lower case letters.
password_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz12345678901234567890"

_ = lambda x: x
_blocked_login_email = _(
"""\
User Name: %s

This account has been locked due to 5 unsuccessful login attempts. A user with
account management privileges must unlock the account.

Last Attempt: %s (%s) %s

Note that repeated unauthorized attempts to access the database that lock
multiple accounts will block all login attempts to the database from the
above IP Address. Should this occur, you will need to notify your database
technical support to have the IP Address block removed.
""")


def getRandomPassword(length):
	sr = StrongRandom()
	return ''.join(sr.choice(password_chars) for x in range(length))


if six.PY3:
	def _hex_encode(b):
		return b.hex()

else:
	def _hex_encode(b):
		return b.encode('hex')


def HashComponents(*args):
	md5 = hashlib.md5()
	for arg in args:
		if isinstance(arg, six.text_type):
			arg = arg.encode('utf8')

		md5.update(arg)

	return _hex_encode(md5.digest())


non_bool_user_values = {
	'PB_ID', 'Domain', 'CREATED_DATE', 'CREATED_BY', 'MODIFIED_DATE', 'MODIFIED_BY',
	'SL_ID', 'Owner', 'ViewType', 'CanEditRecord', 'CanUpdatePubs', 'CanIndexTaxonomy',
	'ViewTypeOffline', 'CanEditVacancy', 'CanViewStats'
}


class UserType(object):
	def __init__(self, user, user_type):
		self.user = user
		self.user_type = user_type
		self._cache = {}

	def __getattr__(self, key):
		if key not in self._cache:
			self._cache[key] = self._get(key)

		return self._cache[key]

	def _get(self, key):
		user_type = self.user_type
		TechAdmin = (not not self.user.TechAdmin) if self.user else False
		SuperUserGlobal = (not not user_type.SuperUserGlobal or TechAdmin) if user_type else False
		SuperUser = (not not user_type.SuperUser or SuperUserGlobal) if user_type else False

		if key == 'TechAdmin':
			return TechAdmin

		if key == 'SuperUserGlobal':
			return SuperUserGlobal

		if key == 'SuperUser':
			return SuperUser

		if key == 'UserType':
			return user_type.SL_ID if user_type else None

		val = getattr(user_type, key, None) if user_type else None

		if key == 'ImportPermission':
			return SuperUser or not not val

		if key in ('CanEditRecord', 'CanUpdatePubs', 'CanIndexTaxonomy'):
			return const.UPDATE_ALL if SuperUser else (val or const.UPDATE_NONE)

		if key == 'CanViewStats':
			return const.STATS_ALL if SuperUser else (val or const.STATS_NONE)

		if key == 'ExportPermission':
			return const.EXPORT_ALL if SuperUser else (val or const.EXPORT_NONE)

		if key.startswith('Can') or key == 'SuppressNotifyEmail':
			return not not (val or SuperUser)

		if key == 'LimitedView':
			return not not (getattr(user_type, 'PB_ID', None) and val)

		if key == 'FeedbackAlert':
			return not not (val or SuperUser)

		if key in non_bool_user_values:
			return val

		return not not val

	@reify
	def ExternalAPIs(self):
		extapi = self.user_type and self.user_type.ExternalAPIs
		if extapi:
			return [x for x in extapi.split(',') if x]
		return []

	def __nonzero__(self):
		""" if user_type is none, make this class evaluate falsey"""
		if self.user_type:
			return True
		return False

	__bool__ = __nonzero__

class User(object):
	def __init__(self, request):
		self.request = request
		self.user = None
		self.cic = None
		self.vol = None

		user_info = self._process_login()
		if user_info:
			self.user, self.cic, self.vol = user_info

		self.cic = UserType(self.user, self.cic)
		self.vol = UserType(self.user, self.vol)

		self.SuperUserGlobal = self.cic.SuperUserGlobal or self.vol.SuperUserGlobal
		self.SuperUser = self.cic.SuperUser or self.vol.SuperUser
		self.WebDeveloper = self.cic.WebDeveloper or self.vol.WebDeveloper
		self.CanManageUsers = self.cic.CanManageUsers or self.vol.CanManageUsers
		if user_info:
			self.Mod = self.Initials if request.dboptions.UseInitials else ' '.join((self.FirstName, self.LastName))
		else:
			self.Mod = None

	def __getattr__(self, key):
		if key == 'dom':
			dom = self.request.pageinfo.DbArea
			if dom == const.DM_CIC:
				return self.cic

			if dom == const.DM_VOL:
				return self.vol

			raise AttributeError(key)

		if not self.user:
			return None

		return getattr(self.user, key)

	def __nonzero__(self):
		if self.user:
			return True
		return False

	__bool__ = __nonzero__

	# ***************************************************
	# everything here processes login information and is
	# not part of public interface
	# ***************************************************
	def _process_login(self):
		request = self.request
		allow_api_login = request.context.allow_api_login

		login, login_key, http_auth, password = self._get_login_params()
		if not login:
			return None

		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_GBL_Users_s_Security ?, ?, ?', request.dboptions.MemberID, login, allow_api_login)

			user = cursor.fetchone()
			if not user:
				cursor.close()
				return None

			if http_auth:
				retry_limit = request.dboptions.LoginRetryLimit
				login_attempts = user.LoginAttempts or 0
				hash = None
				if retry_limit and login_attempts >= retry_limit:
					cursor.close()
					return None

				hash = Crypt(user.PasswordHashSalt.strip(), password, user.PasswordHashRepeat)
				with request.connmgr.get_connection('admin') as conn2:
					conn2.execute('EXEC dbo.sp_GBL_Users_u_Login ?,?,?,?,?',
						request.dboptions.MemberID, user.UserName, hash == user.PasswordHash,
						get_remote_ip(request), user.SingleLoginKey)

				if hash != user.PasswordHash:
					if retry_limit and login_attempts + 1 >= retry_limit and (user.AgencyEmail or user.Email):
						to = {x for x in [user.AgencyEmail, user.Email] if x}
						from_ = user.AgencyEmail or user.Email
						body = format_message(gettext(_blocked_login_email, request))
						body = body % (
							user.UserName,
							format_datetime(datetime.now(), request),
							get_remote_ip(request),
							('https://' if request.dboptions.DomainDefaultViewSSLCompatibleCIC else 'http://') + request.host)

						send_email(request, from_, to, gettext('Locked Account in your CIOC database', request), body)

					cursor.close()
					return None

			else:
				componenets = ['{' + user.UserUID + '}', login]
				if user.SingleLogin:
					componenets.append(user.SingleLoginKey or '')

				hash = HashComponents(*componenets)

				if login_key != hash:
					cursor.close()
					return None

			self.Login = user and user.UserName

			cursor.nextset()

			cic_user_type = cursor.fetchone()

			cursor.nextset()

			vol_user_type = cursor.fetchone()

			cursor.close()

		return user, cic_user_type, vol_user_type

	def _get_login_params(self):
		http_auth = False
		password = None

		# check cookie
		login, login_key = get_auth_principal(self.request)

		if not login:
			login_info = self._parse_http_basic_auth()
			if login_info:
				login, password = login_info
				http_auth = True
				login = login[:50]

		return login, login_key, http_auth, password

	def _parse_http_basic_auth(self):
		# adapted from
		authorization = self.request.headers.get('Authorization', '')
		try:
			authmeth, auth = authorization.split(' ', 1)
		except ValueError:  # not enough values to unpack
			return None
		if authmeth.lower() == 'basic':
			try:
				auth = base64.b64decode(auth.strip().encode('ascii')).decode('utf-8')
			except binascii.Error:  # can't decode
				return None
			try:
				login, password = auth.split(':', 1)
			except ValueError:  # not enough values to unpack
				return None
			auth = (login, password)
			return auth

		return None


ip_re = re.compile(r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$')


def get_remote_ip(request):
	addr = request.remote_addr
	forwarded_for = request.headers.get('X-Forwarded-For')
	if addr != '127.0.0.1' or not forwarded_for:
		return addr

	forwarded_for = forwarded_for.split(',')[-1].strip()

	if not ip_re.match(forwarded_for):
		return '127.127.127.127'

	return forwarded_for


def is_banned(request):
	with request.connmgr.get_connection() as conn:
		banned = conn.execute('''DECLARE @Banned bit; SET NOCOUNT ON;
						EXEC dbo.sp_GBL_Banned_Check ?, @Banned Output;
						SELECT @Banned AS Banned''', get_remote_ip(request)).fetchone().Banned

	return banned or ("DigExt; DTS Agent" in request.headers.get('User-Agency', ''))


# list of pages that are always available to non-logged in users regardless of
# whether dboptions.AllowPublicAccess is False
_non_logged_in_page_whitelist = ['login.asp', 'login_check.asp', 'logout.asp', 'security_failure.asp', 'clbcexport.mvc', 'clbcupdate.mvc', 'billinginfo']


def is_basic_security_failure(request, require_login):
	""" check basic page security

	request object must already have pageinfo attribute
	"""
	user = request.user

	if require_login and not user:
		return True

	pageinfo = request.pageinfo
	if not request.dboptions.AllowPublicAccess and not user and pageinfo.ThisPage.lower() not in _non_logged_in_page_whitelist:
		return True

	is_cic_page_and_user = (pageinfo.Domain == const.DM_CIC and not user.cic)
	is_vol_page_and_user = (pageinfo.Domain == const.DM_VOL and not user.vol)
	if require_login and (is_cic_page_and_user or is_vol_page_and_user):
		return True

	if ((pageinfo.Domain == const.DM_CIC and not request.dboptions.UseCIC) or
		(pageinfo.Domain == const.DM_VOL and not request.dboptions.UseVOL)):

		return True

	if (pageinfo.DbArea == const.DM_CIC and not request.dboptions.UseCIC and
			not user and pageinfo.ThisPage.lower() != '/'):

		return True

	return False


_userid_key = 'auth.userid'
_login_key = 'auth.login_key'


def get_auth_principal(request):
	login = request.session.get(_userid_key)
	key = request.session.get(_login_key)
	return login, key


def remember(request, principal, **kw):
	request.session[_userid_key] = six.text_type(principal)
	login_key = kw.get('login_key')
	if login_key:
		request.session[_login_key] = six.text_type(login_key)
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
	# bump session timeout to 5 days
	request.session.adjust_timeout_for_session(3600 * 24 * 5)
	remember(request, principal, login_key=login_key)


def needs_ssl_domains(request):
	if request.dboptions.SSLDomains:
		return True
	return False


def render_ssl_domain_list(request):
	from markupsafe import Markup
	link = request.passvars.makeLink("~/login.asp")
	item_template = Markup(u'''<li><a href="https://%s%s">%s</a></li>''')
	full_template = Markup(u'''<ul>%s</ul>''')

	inner = Markup(u'').join(item_template % (x, link, x) for x in sorted(request.dboptions.SSLDomains))

	return six.text_type(full_template % inner)
