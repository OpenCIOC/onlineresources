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
from datetime import datetime

# 3rd party
from formencode import ForEach
from pyramid.view import view_config, view_defaults
from pyramid.renderers import render

# this app
from cioc.core import constants as const, viewbase, i18n, validators, format, syslanguage
from cioc.web.admin.notices import get_notices_info
from cioc.core.rootfactories import BasicRootFactory
import six

log = logging.getLogger(__name__)

_ = i18n.gettext

templateprefix = 'cioc.web.cic:templates/reminders/'

dismiss_options = {'S': False, 'A': True}
dismiss_options_reverse = {v: k for k, v in six.iteritems(dismiss_options)}


class ReminderBaseSchema(validators.Schema):
	if_key_missing = None

	ActiveDate = validators.DateConverter()
	Culture = validators.ActiveCulture(record_cultures=True)
	DueDate = validators.DateConverter()
	NoteTypeID = validators.IDValidator()
	Notes = validators.UnicodeString(not_empty=True)
	DismissForAll = validators.DictConverter(dismiss_options, not_empty=True)


class ReminderSchema(validators.RootSchema):
	if_key_missing = None

	reminder = ReminderBaseSchema()

	reminder_agency_ID = ForEach(validators.AgencyCodeValidator)
	reminder_user_ID = ForEach(validators.IDValidator())

	NUM = ForEach(validators.NumValidator(), convert_to_list=True)
	VNUM = ForEach(validators.VNumValidator(), convert_to_list=True)


class ReminderQuerySchema(validators.RootSchema):
	if_key_missing = None

	NUM = validators.NumValidator()
	VNUM = validators.VNumValidator()


@view_defaults(route_name='reminder_action')
class ReminderView(viewbase.ViewBase):
	def __init__(self, request):
		viewbase.ViewBase.__init__(self, request, True)

	def _get_template_info(self, title, result):
		if result.get('ErrorPage'):
			return self._error_page(result['ErrMsg'], title)

		try:
			del result['success']
		except KeyError:
			pass

		return self._create_response_namespace(title, title, result, no_index=True)

	@view_config(route_name='reminder_index', renderer=templateprefix + 'index.mak')
	def reminders(self):
		result = self._reminders()
		title = _('Reminders', self.request)

		if self.request.user.SuperUser:
			result.update(get_notices_info(self.request)._asdict())
		else:
			result['sharing_profiles'] = None
			result['closed_count'] = None
			result['notices'] = None

		return self._get_template_info(title, result)

	@view_config(route_name='reminder_index', request_param="json_api", renderer='json')
	def _reminders(self):
		request = self.request
		user = request.user

		model_state = request.model_state
		model_state.schema = ReminderQuerySchema()
		model_state.method = None

		reminders = []

		if model_state.validate():
			args = [user.User_ID]
			NUM = model_state.value('NUM')
			VNUM = model_state.value('VNUM')
			if NUM:
				sql = 'EXEC dbo.sp_GBL_Reminders_l ?, @NUM=?'
				args.append(NUM)
			elif VNUM:
				sql = 'EXEC dbo.sp_GBL_Reminders_l ?, @VNUM=?'
				args.append(VNUM)
			else:
				sql = 'EXEC dbo.sp_GBL_Reminders_l ?'

			with request.connmgr.get_connection() as conn:
				reminders = conn.execute(sql, args).fetchall()

			for reminder in reminders:
				reminder.Users = self._dict_list_from_xml(reminder.Users, 'user')
				reminder.Agencies = self._dict_list_from_xml(reminder.Agencies, 'agency')

			reminders = render(templateprefix + 'reminder_list.mak', {
					'reminders': reminders,
					'NUM': NUM and NUM.upper(),
					'VNUM': VNUM,
					'_': lambda x: _(x, request),
					'format_date': lambda x: i18n.format_date(x, request),
					'renderer' : model_state.renderer
				}, request)

			return {'reminders': reminders, 'success': True}

		return {'ErrMsg': "some Stuff", 'ErrorPage': True}

	@view_config(route_name='reminder', renderer=templateprefix + 'reminder.mak')
	def reminder(self):
		result = self._reminder()
		title = _('Edit Reminder', self.request)

		return self._get_template_info(title, result)

	@view_config(route_name='reminder', request_param="json_api", renderer='json')
	def _reminder(self):
		request = self.request

		reminder_id = request.matchdict.get('id')
		try:
			reminder_id = int(reminder_id, 10)
		except ValueError:
			request.response.status = '404 Not Found'
			return {'ErrMsg': _('Invalid ID', request), 'ErrorPage': True}

		with request.connmgr.get_connection('admin') as conn:
			sql = '''EXEC sp_GBL_Reminder_s ?, ?'''
			reminder = conn.execute(sql, request.dboptions.MemberID, reminder_id).fetchone()

		if not reminder:
			request.response.status = '404 Not Found'
			return {'ErrMsg': _('Reminder not found', request), 'ErrorPage': True}

		reminder_dict = {
			'ActiveDate': i18n.format_date(reminder.ActiveDate, request) if reminder.ActiveDate else None,
			'DueDate': i18n.format_date(reminder.DueDate, request) if reminder.DueDate else None,
			'PastDue': reminder.DueDate <= datetime.now() if reminder.DueDate else False,
			'Notes': format.textToHTML(reminder.Notes)
		}

		return {'success': True, 'reminder': reminder_dict}

	@view_config(route_name='reminder_add', renderer=templateprefix + 'edit.mak')
	@view_config(route_name='reminder_add', request_method='POST', request_param='_force_method=GET', renderer=templateprefix + 'edit.mak')
	@view_config(match_param='action=edit', renderer=templateprefix + 'edit.mak')
	def edit(self):
		result = self._edit()
		request = self.request
		if request.matched_route.name == 'reminder_add':
			title = _('Add Reminder', request)
		else:
			title = _('Edit Reminder', request)

		return self._get_template_info(title, result)

	@view_config(route_name='reminder_add', request_param="json_api", renderer='json')
	@view_config(match_param='action=edit', request_param="json_api", renderer='json')
	def _edit(self):
		request = self.request
		is_add = request.matched_route.name == 'reminder_add'

		reminder_id = None

		if not is_add:
			reminder_id = request.matchdict.get('id')
			try:
				reminder_id = int(reminder_id, 10)
			except ValueError:
				request.response.status = '404 Not Found'
				return {'ErrMsg': _('Invalid ID', request), 'ErrorPage': True}

		retval = self._get_edit_info(is_add, reminder_id)
		if not retval.get('ErrMsg'):
			retval['success'] = True

		return retval

	@view_config(route_name='reminder_add', request_method='POST', renderer=templateprefix + 'edit.mak')
	@view_config(request_method='POST', match_param='action=edit', renderer=templateprefix + 'edit.mak')
	def save(self):
		result = self._save(False)
		request = self.request
		if request.matched_route.name == 'reminder_add':
			title = _('Add Reminder', request)
		else:
			title = _('Edit Reminder', request)

		log.debug('errors: %s', request.model_state.form.errors)
		return self._get_template_info(title, result)

	@view_config(route_name='reminder_add', request_method='POST', request_param="json_api", renderer='json')
	@view_config(request_method='POST', match_param='action=edit', request_param="json_api", renderer='json')
	def _save(self, is_api=True):
		request = self.request
		user = request.user

		if request.params.get('delete'):
			args = request.matchdict.copy()
			args['action'] = 'delete'
			return self._go_to_route('reminder_action', **args)

		is_add = request.matched_route.name == 'reminder_add'

		reminder_id = None
		if not is_add:
			reminder_id = request.matchdict.get('id')
			try:
				reminder_id = int(reminder_id, 10)
			except ValueError:
				request.response.status = '404 Not Found'
				return {'ErrMsg': _('Invalid ID', request), 'ErrorPage': True}

		model_state = request.model_state
		model_state.form.variable_decode = True
		model_state.schema = ReminderSchema()

		if model_state.validate():
			data = model_state.form.data
			reminder = data['reminder']

			args = [reminder_id, user.Mod, user.User_ID]
			args.extend(reminder.get(x) for x in [
				'Culture', 'NoteTypeID', 'ActiveDate', 'DueDate', 'Notes', 'DismissForAll'])

			if not any(data.get(x) for x in ['reminder_agency_ID', 'reminder_user_ID']):
				data['reminder_user_ID'] = [user.User_ID]

			args.extend(','.join(str(y).upper() for y in x) if x else None for x in
					(data.get(z) for z in [
						'reminder_agency_ID', 'reminder_user_ID', 'NUM', 'VNUM']))

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
					DECLARE @RC int, @ErrMsg as nvarchar(500), @ReminderID int=?

					EXEC @RC = sp_GBL_Reminder_u @ReminderID OUTPUT, %s @ErrMsg OUTPUT

					SELECT @RC AS [Return], @ErrMsg AS ErrMsg, @ReminderID AS ReminderID
					''' % ('?,' * (len(args) - 1))

				result = conn.execute(sql, args).fetchone()

			if not result.Return:
				if is_api:
					return {'success': True}

				msg = _('The Reminder was successfully added', request) if is_add else _('The Reminder was successfully updated')
				self._go_to_route('reminder_action', action='edit', id=result.ReminderID, _query=[('InfoMsg', msg)])

			ErrMsg = result.ErrMsg

		else:
			ErrMsg = _('There were validation errors.')

		result = self._get_edit_info(is_add, reminder_id, True)
		if result.get('ErrMsg'):
			return result

		result['ErrMsg'] = ErrMsg
		result['success'] = False

		return result

	def _get_edit_info(self, is_add, reminder_id, is_error=False):
		request = self.request

		reminder = None
		reminder_users = []
		reminder_agencies = []
		nums = []
		vnums = []

		agencies = []
		note_types = []

		with request.connmgr.get_connection('admin') as conn:
			if not is_add:
				sql = '''EXEC sp_GBL_Reminder_s ?, ?'''
				cursor = conn.execute(sql, request.dboptions.MemberID, reminder_id)

				reminder = cursor.fetchone()

				if not reminder:
					request.response.status = '404 Not Found'
					return {'ErrMsg': _('Reminder not found', request), 'ErrorPage': True}

				if not is_error:

					cursor.nextset()
					reminder_users = cursor.fetchall()

					cursor.nextset()
					reminder_agencies = cursor.fetchall()

					cursor.nextset()
					nums = cursor.fetchall()

					cursor.nextset()
					vnums = cursor.fetchall()

				cursor.close()

			cursor = conn.execute('''
						EXEC sp_GBL_Agency_l ?, ?
						EXEC sp_GBL_RecordNote_Type_l
						''', request.dboptions.MemberID, False)

			agencies = [x.AgencyCode for x in cursor.fetchall()]

			cursor.nextset()
			note_types = [(x[0], ('[ ! ] ' if x[1] else '') + x[2]) for x in cursor.fetchall()]

			cursor.close()

		org_names = ((x[0], x.ORG_NAME_FULL) for x in nums)
		org_names = {k: v for k, v in org_names if v}
		pos_titles = {str(k): v for k, v in vnums if v}

		data = request.model_state.form.data
		if not is_add:
			if not is_error:
				data['reminder'] = reminder
				data['reminder_user_ID'] = [six.text_type(x[0]) for x in reminder_users]
				data['reminder_agency_ID'] = [x[0] for x in reminder_agencies]
				data['NUM'] = [x[0] for x in nums]
				data['VNUM'] = [six.text_type(x[0]) for x in vnums]

		if is_add or is_error:
			data['NUM'] = request.params.getall('NUM')
			data['VNUM'] = request.params.getall('VNUM')

		if not is_add or is_error:
			val = request.model_state.value('reminder.DismissForAll')
			data['reminder.DismissForAll'] = dismiss_options_reverse.get(val, val if val is not None else 'S')

		namespace = {
				'_': lambda x: i18n.gettext(x, request),
				'format_date': lambda x: i18n.format_date(x, request),
				'reminder': reminder,
				'record_cultures': syslanguage.active_record_cultures(),
				'culture_map': syslanguage.culture_map(),
				'agencies': agencies,
				'note_types': note_types,
				'ReminderID': reminder_id,
				'reminder_users': reminder_users,
				'reminder_agencies': reminder_agencies,
				'org_names': org_names,
				'position_titles': pos_titles,
				'renderer': request.model_state.renderer
			}
		return {'form': render(templateprefix + 'edit_form.mak', namespace, request)}

	@view_config(request_method='POST', match_param='action=dismiss', request_param="json_api", renderer='json')
	def dismiss(self):
		request = self.request
		user = request.user

		reminder_id = request.matchdict.get('id')
		try:
			reminder_id = int(reminder_id, 10)
		except ValueError:
			request.response.status = '404 Not Found'
			return {'ErrMsg': _('Invalid ID', request), 'ErrorPage': True}

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
				DECLARE @RC int, @ErrMsg nvarchar(500)

				EXEC @RC = sp_GBL_Reminder_u_Dismiss ?, ?, ?, ?, @ErrMsg OUTPUT

				SELECT @RC AS [Return], @ErrMsg AS ErrMsg
			'''
			dismissed = not not request.POST.get('dismiss')
			cursor = conn.execute(sql, reminder_id, user.Mod,
						user.User_ID, dismissed)

			result = cursor.fetchone()

			if not result.Return:
				return {'success': True, 'dismissed': dismissed}

		return {'ErrMsg': result.ErrMsg}

	@view_config(match_param='action=delete', renderer=templateprefix + 'edit.mak')
	def delete(self):
		result = self._delete()
		request = self.request
		title = _('Delete Reminder', request)

		return self._get_template_info(title, result)

	@view_config(match_param='action=delete', request_param="json_api", renderer='json')
	def _delete(self):
		request = self.request

		namespace = {
				'_': lambda x: i18n.gettext(x, request),
				'format_date': lambda x: i18n.format_date(x, request),
				'renderer': request.model_state.renderer
			}

		if request.params.get('json_api'):
			namespace['extra_values'] = [('json_api', 'on')]
		# XXX update to new #error_page syntax in Pyramid 1.4
		# http://docs.pylonsproject.org/projects/pyramid/en/1.4-branch/whatsnew-1.4.html#partial-mako-and-chameleon-template-renderings
		return {'success': True, 'form': render('cioc.web:templates/confirmdelete.mak', ('error_page', namespace), request=request)}

	@view_config(request_method='POST', match_param='action=delete', renderer=templateprefix + 'edit.mak')
	def delete_confirm(self):
		result = self._delete_confirm(False)
		request = self.request
		title = _('Delete Reminder', request)

		return self._get_template_info(title, result)

	@view_config(request_method='POST', match_param='action=delete', request_param="json_api", renderer='json')
	def _delete_confirm(self, is_api=True):
		request = self.request
		user = request.user

		reminder_id = request.matchdict.get('id')
		try:
			reminder_id = int(reminder_id, 10)
		except ValueError:
			request.response.status = '404 Not Found'
			return {'ErrMsg': _('Invalid ID', request), 'ErrorPage': True}

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @RC int, @ErrMsg nvarchar(500)

			EXEC @RC = dbo.sp_GBL_Reminder_d ?, ?, ?, @ErrMsg OUTPUT

			SELECT @RC AS [Return], @ErrMsg AS ErrMsg
			'''

			result = conn.execute(sql, reminder_id, user.User_ID, not not user.SuperUser).fetchone()

		if not result.Return:
			if is_api:
				return {'success': True}

			self._go_to_route('reminder_index', _query=[('InfoMsg', _('The Reminder was successfully deleted.', request))])

		retval = {'ErrMsg': _('Unable to delete Reminder: ', request) + result.ErrMsg}
		if result.Return == 3:
			retval['ErrorPage'] = True

		if is_api or result.Return == 3:
			return retval

		args = request.matchdict.copy()
		args['action'] = 'edit'
		args['_query'] = retval
		self._go_to_route('reminder_action', **args)


class ReminderRootFactory(BasicRootFactory):
	def __init__(self, request):
		request.context = self
		user = request.user

		if user.cic and user.vol:
			domain = const.DM_GLOBAL
		elif user.cic:
			domain = const.DM_CIC
		elif user.vol:
			domain = const.DM_VOL
		else:
			domain = const.DM_GLOBAL

		BasicRootFactory.__init__(self, request, domain, domain)
