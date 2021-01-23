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

# 3rd party
from pyramid.view import view_config, view_defaults

# this app
from cioc.core import validators as ciocvalidators

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = 'cioc.web.admin:templates/datafeedapikey/'
log = logging.getLogger(__name__)


class APISchema(ciocvalidators.RootSchema):
	if_key_missing = None

	Owner = ciocvalidators.UnicodeString(not_empty=True, max=100)
	CIC = ciocvalidators.Bool()
	VOL = ciocvalidators.Bool()
	Inactive = ciocvalidators.Bool()

FeedAPIKeyValidator = ciocvalidators.UUIDValidator(not_empty=True)


@view_defaults(route_name='admin_datafeedapikey')
class DataFeedApiKeyView(viewbase.AdminViewBase):

	@view_config(match_param='action=inactive', renderer=templateprefix + 'confirm.mak')
	@view_config(match_param='action=add', renderer=templateprefix + 'edit.mak')
	@view_config(match_param='action=edit', renderer=templateprefix + 'edit.mak')
	def edit(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		is_add = request.matchdict['action'] == 'add'
		FeedAPIKey = None
		if not is_add:
			model_state = request.model_state
			model_state.validators = {'FeedAPIKey': FeedAPIKeyValidator}
			model_state.method = None

			if not model_state.validate():
				return self._error_page(_('Invalid Feed API Key', request))

			FeedAPIKey = model_state.value('FeedAPIKey')

		edit_info = self._get_edit_info(is_add, FeedAPIKey)

		if edit_info['key']:
			request.model_state.form.data = self.dict_from_row(edit_info['key'])

		if is_add:
			title = _('Add API Key', request)
		elif request.matchdict['action'] == 'inactive':
			if not edit_info['key'].Inactive:
				title = _('Deactivate Feed API Key', request)
			else:
				title = _('Activate Feed API Key', request)

		else:
			title = _('Edit Feed API Key', request)

		return self._create_response_namespace(title, title, edit_info, no_index=True)

	@view_config(match_param='action=add', request_method='POST', renderer=templateprefix + 'edit.mak')
	@view_config(match_param='action=edit', request_method='POST', renderer=templateprefix + 'edit.mak')
	def save(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		is_add = request.matchdict['action'] == 'add'
		extra_validators = {}
		if not is_add:
			extra_validators['FeedAPIKey'] = FeedAPIKeyValidator

		model_state = request.model_state
		model_state.schema = APISchema(**extra_validators)

		ErrMsg = ''
		if not model_state.validate():
			if 'FeedAPIKey' in model_state.form.errors:
				return self._error_page(_('Invalid Feed API Key', request))

			FeedAPIKey = model_state.value('FeedAPIKey')
			ErrMsg = _('There were validation errors.', request)

		else:
			FeedAPIKey = model_state.value('FeedAPIKey')
			args = [
				FeedAPIKey, request.user.Mod, request.MemberID, model_state.value('Owner'),
				model_state.value('CIC') if request.user.cic.SuperUser else None,
				model_state.value('VOL') if request.user.vol.SuperUser else None
			]
			if is_add:
				sql_method = 'i @FeedAPIKey OUTPUT',
			else:
				sql_method = 'u @FeedAPIKey'

			if request.params.get('Update') == 'Submit Updates':
				with request.connmgr.get_connection('admin') as conn:
					sql = '''
					DECLARE @ErrMsg as nvarchar(500),
						@RC as int,
						@FeedAPIKey uniqueidentifier
					SET @FeedAPIKey = ?

					EXECUTE @RC = dbo.sp_GBL_FeedAPIKey_%s, ?, ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

					SELECT @RC as [Return], @ErrMsg AS ErrMsg, @FeedAPIKey AS FeedAPIKey
					''' % sql_method
					result = conn.execute(sql, args).fetchone()
					log.debug('Result: %s %s', result.Return, result.ErrMsg)
					if not result.Return:
						if is_add:
							msg = _('API Key Added', request)
						else:
							msg = _('API Key Updated', request)

						log.debug('Redirect')
						self._go_to_route('admin_datafeedapikey', action='edit', _query=[('InfoMsg', msg), ('FeedAPIKey', result.FeedAPIKey)])

					ErrMsg = result.ErrMsg

		edit_info = self._get_edit_info(is_add, FeedAPIKey)
		edit_info['ErrMsg'] = ErrMsg
		if is_add:
			title = _('Edit Feed API Key', request)
		else:
			title = _('Add API Key', request)

		return self._create_response_namespace(title, title, edit_info, no_index=True)

	@view_config(match_param='action=inactive', request_method="POST", renderer=templateprefix + 'confirm.mak')
	def confirm_inactive(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.validators = {'FeedAPIKey': FeedAPIKeyValidator}

		if not model_state.validate():
			self._error_page(_('Invalid Feed API Key', request))

		FeedAPIKey = model_state.value('FeedAPIKey')
		if request.params.get('Inactive'):
			inactivate = True
		else:
			inactivate = False

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_GBL_FeedAPIKey_u_Inactive ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			'''
			result = conn.execute(sql, FeedAPIKey, request.MemberID, inactivate).fetchone()
			if result.Return:
				self._error_page(result.ErrMsg)

		if inactivate:
			msg = _('API Key Deactivated', request)
		else:
			msg = _('API Key Activated', request)

		self._go_to_route('admin_datafeedapikey', action='edit', _query=[('InfoMsg', msg), ('FeedAPIKey', FeedAPIKey)])

	@view_config(route_name='admin_datafeedapikey_index', renderer=templateprefix + 'index.mak')
	def index(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_GBL_FeedAPIKey_l ?', request.MemberID)

			keys = cursor.fetchall()
			cursor.close()

		title = _('Basic Data Feed API Key', request)

		return self._create_response_namespace(title, title, {'keys': keys}, no_index=True)

	def _get_edit_info(self, is_add, FeedAPIKey):
		request = self.request

		log.debug('FeedAPIKey: %s', FeedAPIKey)

		key = None
		if not is_add:
			with request.connmgr.get_connection('admin') as conn:

				sql = '''
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int

				EXECUTE @RC = dbo.sp_GBL_FeedAPIKey_s ?, ?, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				'''

				cursor = conn.execute(sql, FeedAPIKey, request.MemberID)

				key = cursor.fetchone()

				cursor.nextset()

				result = cursor.fetchone()

				cursor.close()

				if result.Return:
					self._error_page(result.ErrMsg)

			if key is None:
				self._error_page(_('API Key not found', request))

		return {'key': key, 'is_add': is_add, 'FeedAPIKey': FeedAPIKey}
