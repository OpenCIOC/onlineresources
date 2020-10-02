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
from collections import namedtuple

#import xml.etree.cElementTree as ET

# 3rd party
from pyramid.view import view_config, view_defaults

# this app
from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase
from cioc.core import constants as const, validators
from six.moves import map

log = logging.getLogger(__name__)

templateprefix = 'cioc.web.admin:templates/notice/'

NoticeInfo = namedtuple('NoticeInfo', 'domains notices sharing_profiles closed_count')


class NewSchema(validators.RootSchema):
	if_key_missing = None

	AdminAreaID = validators.IDValidator(not_empty=True)
	RequestDetail = validators.UnicodeString(not_empty=True)


class CloseSchema(validators.RootSchema):
	if_key_missing = None

	NoticeID = validators.IDValidator(not_empty=True)
	ActionTaken = validators.Int(min=1, max=2, if_empty=None)
	ActionNotes = validators.UnicodeString()


def get_notices_info(request, show_closed=False):
	user = request.user

	domains = _get_domains(user)
	notices = []
	sharing_profiles = []
	closed_count = None
	with request.connmgr.get_connection('admin') as conn:
		cursor = conn.execute('EXEC sp_GBL_Admin_Notice_l ?, ?, ?',
					','.join(map(str, domains)), request.dboptions.MemberID,
					show_closed)
		notices = cursor.fetchall()

		cursor.nextset()
		sharing_profiles = cursor.fetchall()

		if not show_closed:
			cursor.nextset()
			closed_count = cursor.fetchone()

		cursor.close()

	return NoticeInfo(domains, notices, sharing_profiles, closed_count)


@view_defaults(route_name='admin_notices')
class Notice(viewbase.AdminViewBase):

	@view_config(route_name='admin_notices_index', renderer=templateprefix + 'index.mak')
	def index(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		notices_info = get_notices_info(request, True)

		title = _('Admin Notices', request)
		return self._create_response_namespace(title, title, notices_info._asdict(), no_index=True)

	@view_config(match_param='action=new', renderer=templateprefix + 'new.mak')
	def new(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		valdict = {
			'AreaCode': validators.String(max=20, if_invalid=None, if_empty=None, if_missing=None),
			'DM': viewbase.domain_validator
		}
		model_state = request.model_state
		model_state.validators = valdict
		model_state.method = None

		model_state.validate()

		AreaCode = model_state.value('AreaCode')
		DM = model_state.value('DM')

		with request.connmgr.get_connection('admin') as conn:
			areas = conn.execute('EXEC sp_GBL_Admin_Area_l ?, NULL',
						request.dboptions.MemberID).fetchall()

		if AreaCode:
			AdminAreaID = [x.AdminAreaID for x in areas if x.AreaCode == AreaCode and (DM is None or x.Domain == DM.id)]
			if AdminAreaID:
				request.model_state.form.data['AdminAreaID'] = str(AdminAreaID[0])

		title = _('New Admin Notice', request)
		return self._create_response_namespace(title, title, dict(areas=areas), no_index=True)

	@view_config(match_param='action=new', renderer=templateprefix + 'new.mak', request_method='POST')
	def new_save(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.schema = NewSchema()

		if model_state.validate():
			args = [user.Mod, user.User_ID, model_state.value('AdminAreaID'), model_state.value('RequestDetail')]

			with request.connmgr.get_connection('admin') as conn:
				result = conn.execute('''
						DECLARE @ErrMsg nvarchar(500), @RC int
						EXEC @RC = sp_GBL_Admin_Notice_i ?,?,?,?, @ErrMsg OUTPUT

						SELECT @RC AS [Return], @ErrMsg AS ErrMsg''',
							*args).fetchone()

				if not result.Return:
					return self._go_to_page('~/admin/setup.asp', {'InfoMsg': _('Change request sent.')})

		else:
			ErrMsg = _('There were validation errors.')

		with request.connmgr.get_connection('admin') as conn:
			areas = conn.execute('EXEC sp_GBL_Admin_Area_l ?, NULL',
						request.dboptions.MemberID).fetchall()

		title = _('New Admin Notice', request)
		return self._create_response_namespace(title, title, dict(ErrMsg=ErrMsg, areas=areas), no_index=True)

	@view_config(match_param='action=close', renderer=templateprefix + 'close.mak')
	def close(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		validator = validators.IDValidator(not_empty=True)
		try:
			NoticeID = validator.to_python(request.params.get('NoticeID'))
		except validators.Invalid:
			self._error_page(_('Invalid ID', request))

		with request.connmgr.get_connection('admin') as conn:
			notice = conn.execute('EXEC sp_GBL_Admin_Notice_s ?',
						NoticeID).fetchone()

		if not notice:
			self._error_page(_('Not Found', request))

		domains = self._get_domains()
		if notice.Domain not in domains:
			self._security_failure()

		data = request.model_state.form.data
		data['ActionNotes'] = notice.ActionNotes
		data['ActionTaken'] = notice.ActionTaken

		title = _('Close Admin Notice', request)
		return self._create_response_namespace(title, title, dict(notice=notice, NoticeID=NoticeID), no_index=True)

	@view_config(match_param='action=close', renderer=templateprefix + 'close.mak', request_method='POST')
	def close_save(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		domains = self._get_domains()

		model_state = request.model_state
		model_state.schema = CloseSchema()

		if model_state.validate():
			NoticeID = model_state.value('NoticeID')
			args = [NoticeID, ','.join(map(str, domains)), user.Mod, model_state.value('ActionTaken'), model_state.value('ActionNotes')]

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
					DECLARE @RC int, @ErrMsg nvarchar(500)

					EXEC @RC = dbo.sp_GBL_Admin_Notice_u ?, ?, ?, ?, ?, @ErrMsg OUTPUT

					SELECT @RC AS [Return], @ErrMsg AS ErrMsg
					'''

				result = conn.execute(sql, args).fetchone()
				if not result.Return:
					self._go_to_route('reminder_index', _query=[])
		else:
			if model_state.is_error('NoticeID'):
				self._error_page(_('Invalid ID', request))

			NoticeID = model_state.value('NoticeID')
			ErrMsg = _('There were validation errors.')

		with request.connmgr.get_connection('admin') as conn:
			notice = conn.execute('EXEC sp_GBL_Admin_Notice_s ?',
						NoticeID).fetchone()

		if not notice:
			self._error_page(_('Not Found', request))

		if notice.Domain not in domains:
			self._security_failure()

		data = request.model_state.form.data
		data['ActionNotes'] = notice.ActionNotes
		data['ActionTaken'] = notice.ActionTaken

		log.debug('Errors: %s', model_state.form.errors)
		title = _('Close Admin Notice', request)
		return self._create_response_namespace(title, title, dict(notice=notice, NoticeID=NoticeID, ErrMsg=ErrMsg), no_index=True)

	def _get_domains(self):
		return _get_domains(self.request.user)


def _get_domains(user):
		domains = {const.DM_GLOBAL}
		if user.cic.SuperUserGlobal:
			domains.update([const.DM_CIC, const.DM_CCR])

		if user.vol.SuperUserGlobal:
			domains.add(const.DM_VOL)

		return domains
