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
log = logging.getLogger(__name__)

from pyramid.view import view_config, view_defaults
from formencode import Invalid
from markupsafe import Markup

from cioc.web.cic import viewbase
from cioc.core import validators as ciocvalidators
from cioc.core.i18n import gettext as _
from cioc.core.vacancyscript import make_history_table

idlist_validator = ciocvalidators.CSVForEach(ciocvalidators.IDValidator(not_emtpy=True))


class IncrementSchema(ciocvalidators.RootSchema):
	BT_VUT_ID = ciocvalidators.IDValidator(not_empty=True)
	Value = ciocvalidators.Int(max=1, min=-1, not_empty=True)

_change_global_template = Markup('''
	<h3>%(title)s</h3>
	%(changes)s
''')

_change_no_items_template = Markup('''<p class="Info">%s</p>''')


@view_defaults(route_name='jsonfeeds_vacancy', renderer='json', http_cache=0)
class Vacancy(viewbase.CicViewBase):

	def __init__(self, request):
		viewbase.CicViewBase.__init__(self, request, require_login=True)

	@view_config(match_param='action=canedit')
	def canedit(self):
		request = self.request
		user = self.request.user

		if not user.cic:
			return []

		ids = request.params.get('ids')

		try:
			ids = idlist_validator.to_python(ids)
		except Invalid:
			ids = []

		if not ids:
			return []

		ids = ','.join(map(unicode, ids))

		with request.connmgr.get_connection() as conn:
			editable = conn.execute('EXEC sp_CIC_Vacancy_l_CanUpdate ?, ?, ?', user.User_ID, request.viewdata.cic.ViewType, ids).fetchall()

		return [x[0] for x in editable]

	@view_config(match_param='action=refresh')
	def refresh(self):
		request = self.request
		user = self.request.user

		if not user.cic:
			return {'success': False}

		ids = request.params.get('ids')

		try:
			ids = idlist_validator.to_python(ids)
		except Invalid:
			ids = []

		if not ids:
			return {'success': False}

		ids = ','.join(map(unicode, ids))

		with request.connmgr.get_connection('admin') as conn:
			updates = conn.execute('EXEC sp_CIC_Vacancy_l_Refresh ?, ?, ?', request.dboptions.MemberID, request.viewdata.cic.ViewType, ids).fetchall()

		updates = [{'text': x.Text, 'bt_vut_id': x.BT_VUT_ID} for x in updates]

		return {
			'success': True,
			'updates': updates
		}

	@view_config(match_param='action=increment', request_method='POST')
	def increment(self):
		request = self.request
		user = request.user

		if not user.cic:
			return {'success': False, 'msg': _('Permission Denied', request), 'updates': []}

		model_state = request.model_state
		model_state.schema = IncrementSchema()

		if model_state.validate():
			sql = '''DECLARE @RC int, @ErrMsg nvarchar(500)
			EXEC @RC = sp_CIC_Vacancy_u_Increment ?, ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC AS [Return], @ErrMsg AS ErrMsg '''
			with request.connmgr.get_connection('admin') as conn:
				cursor = conn.execute(sql, user.User_ID, user.Mod, request.viewdata.cic.ViewType, model_state.value('BT_VUT_ID'), model_state.value('Value'))

				new_values = cursor.fetchone()

				cursor.nextset()

				result = cursor.fetchone()

				cursor.close()

			updates = [
				{
					'text': new_values.Text,
					'bt_vut_id': new_values.BT_VUT_ID
				}
			]
			if not result.Return:
				value = model_state.value('Value')
				if value > 0:
					msg = _('Success: added %d to vacancy.') % value
				else:
					msg = _('Success: removed %d from vacancy.') % abs(value)

				return {
					'success': True,
					'msg': msg,
					'updates': updates
				}

			ErrMsg = _('Unable to complete your change: %s') % result.ErrMsg

		else:
			updates = []
			ErrMsg = _('Validation Error')

		return {
			'success': False,
			'msg': ErrMsg,
			'updates': updates
		}

	@view_config(match_param='action=history')
	def history(self):
		request = self.request
		user = self.request.user

		if not user.cic:
			permission_denied = _('Unable to load history information: Permission Denied', request)
			return {'success': False, 'content': permission_denied, 'title': permission_denied}

		vut_id = request.params.get('BT_VUT_ID')
		validator = ciocvalidators.IDValidator(not_emtpy=True)

		try:
			vut_id = validator.to_python(vut_id)
		except Invalid:
			unable_to_load = _('Unable to load history information.', request)
			return {'success': False, 'content': unable_to_load, 'title': unable_to_load}

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_CIC_Vacancy_sl_History ?, ?, ?', user.User_ID, request.viewdata.cic.ViewType, vut_id)

			info = cursor.fetchone()

			cursor.nextset()

			changes = cursor.fetchall()

			cursor.close()

		if not info or not info.CAN_SEE_HISTORY:
			permission_denied = _('Unable to load history information: Permission Denied', request)
			return {'success': False, 'content': permission_denied, 'title': permission_denied}

		title = _('Vacancy History for %s', request) % info.RecordTitle

		if not changes:
			changes = _change_no_items_template % _('No change history')

		else:
			changes = make_history_table(request, changes)

		content = _change_global_template % {'title': title, 'changes': changes}

		return {
			'success': True,
			'content': content,
			'title': title
		}
