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


#std library
import logging
import collections
import xml.etree.cElementTree as ET

#3rd party libs
from pyramid.view import view_config, view_defaults

#this app
from cioc.core import validators, constants as const
from cioc.core.i18n import gettext as _
from cioc.web.admin.viewbase import AdminViewBase, domain_validator

log = logging.getLogger(__name__)

Options = collections.namedtuple('Options', 'DM MR')


class OptionsSchema(validators.RootSchema):
	if_key_missing = None

	DM = domain_validator
	MR = validators.StringBool()


class EmailSchemaBase(validators.RootSchema):
	if_key_missing = None

	DefaultMsg = validators.Bool()

	StdSubjectBilingual = validators.UnicodeString(max=150)


class DescriptionSchemaBase(validators.RootSchema):
	if_key_missing = None

	Name = validators.UnicodeString(max=200, not_empty=True)

	StdSubject = validators.UnicodeString(max=100, not_empty=True)
	StdGreetingStart = validators.UnicodeString(max=100, not_empty=True)
	StdGreetingEnd = validators.UnicodeString(max=100)
	StdMessageBody = validators.UnicodeString(max=1500)

	StdDetailDesc = validators.UnicodeString(max=100)
	StdFeedbackDesc = validators.UnicodeString(max=100)

	StdContact = validators.UnicodeString(max=255, not_empty=True)

	StdSuggestOppDesc = validators.UnicodeString(max=150)
	StdOrgOppsDesc = validators.UnicodeString(max=150)


class DescriptionSchemaNotAllOpps(DescriptionSchemaBase):
	chained_validators = [validators.RequireAtLeastOne(['StdDetailDesc', 'StdFeedbackDesc'])]


class EmailSchema(validators.RootSchema):
	if_key_missing = None

	# need to add EmailID if not new
	email = EmailSchemaBase()

templateprefix = 'cioc.web.admin:templates/email/'


@view_defaults(route_name='admin_email', renderer=templateprefix + 'edit.mak')
class EmailValues(AdminViewBase):

	@view_config(route_name='admin_email_index', renderer=templateprefix + 'index.mak')
	def index(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		options = self._get_options()

		with request.connmgr.get_connection('admin') as conn:
			emails = conn.execute('EXEC dbo.sp_GBL_StandardEmailUpdate_l ?, ?, ?',
						request.dboptions.MemberID, options.DM.id, options.MR).fetchall()

		title = _('Standard Email Update Text (%s)', request) % _(options.DM.label, request)
		return self._create_response_namespace(title, title, dict(emails=emails, options=options), no_index=True)

	@view_config(match_param='action=edit', request_method='POST')
	@view_config(match_param='action=add', request_method='POST')
	def save(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		options = self._get_options()

		if request.params.get('Delete'):
			query = [('EmailID', request.params.get('EmailID')), ('DM', options.DM.id)]
			if options.MR:
				query.append(('MR', '1'))
			self._go_to_route('admin_email', action='delete', _query=query)

		is_add = request.matchdict.get('action') == 'add'

		model_state = request.model_state

		if options.MR:
			extra_validators = {'descriptions': validators.CultureDictSchema(DescriptionSchemaBase())}
		else:
			extra_validators = {'descriptions': validators.CultureDictSchema(DescriptionSchemaNotAllOpps())}

		if not is_add:
			extra_validators['EmailID'] = validators.IDValidator(not_empty=True)

		model_state.schema = EmailSchema(**extra_validators)
		model_state.form.variable_decode = True

		if model_state.validate():
			email_id = model_state.value('EmailID')

			args = [email_id, user.Mod, request.dboptions.MemberID, options.DM.id, options.MR, model_state.value('email.DefaultMsg'), model_state.value('email.StdSubjectBilingual')]

			root = ET.Element('DESCS')
			for culture, data in (model_state.value('descriptions') or {}).iteritems():
				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, 'Culture').text = culture.replace('_', '-')
				for name, value in data.iteritems():
					if value:
						ET.SubElement(desc, name).text = unicode(value)

			args.append(ET.tostring(root))

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int,
				@EmailID as int

				SET @EmailID = ?

				EXECUTE @RC = dbo.sp_GBL_StandardEmailUpdate_u @EmailID OUTPUT, ?, ?, ?, ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg, @EmailID as EmailID
				'''
				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:
				email_id = result.EmailID

				if is_add:
					msg = _('The Standard Email Update Text was successfully added.', request)
				else:
					msg = _('The Standard Email Update Text was successfully updated.', request)

				query = [('InfoMsg', msg), ("EmailID", email_id), ('DM', options.DM.id)]
				if options.MR:
					query.append(('MR', '1'))
				self._go_to_route('admin_email', action='edit', _query=query)

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			if model_state.is_error('EmailID'):
				self._error_page(_('Invalid Email ID', request))

			email_id = model_state.value('EmailID')

			ErrMsg = _('There were validation errors.')

		email = None

		if not is_add:
			with request.connmgr.get_connection('admin') as conn:
				cursor = conn.execute('EXEC dbo.sp_GBL_StandardEmailUpdate_s ?, ?, ?, ?',
							request.dboptions.MemberID, options.DM.id, options.MR, email_id)

				email = cursor.fetchone()

				cursor.close()

			if not email:
				self._error_page(_('Standard Email Update Text Not Found', request))

		log.debug('Errors: %s', model_state.form.errors)
		title = _('Standard Email Update Text (%s)', request) % _(options.DM.label, request)
		return self._create_response_namespace(title, title,
										dict(EmailID=email_id, email=email, is_add=is_add,
												options=options, ErrMsg=ErrMsg), no_index=True)

	@view_config(match_param='action=edit')
	@view_config(match_param='action=add')
	def edit(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		options = self._get_options()

		is_add = request.matchdict.get('action') == 'add'

		model_state = request.model_state
		model_state.method = None
		model_state.schema = validators.RootSchema(EmailID=validators.IDValidator(not_empty=not is_add))

		if not model_state.validate():
			self._error_page(_('Unable to load Standard Email Update Values: %s', request) % model_state.renderer.errorlist('EmailID'))
		email_id = model_state.value('EmailID')

		email = None
		descriptions = {}
		if email_id:
			with request.connmgr.get_connection('admin') as conn:
				cursor = conn.execute('EXEC dbo.sp_GBL_StandardEmailUpdate_s ?, ?, ?, ?',
							request.dboptions.MemberID, options.DM.id, options.MR, email_id)

				email = cursor.fetchone()

				cursor.nextset()
				descriptions = {x.Culture.replace('-', '_'): x for x in cursor.fetchall()}

			if not email:
				self._error_page(_('Standard Email Update Text Not Found', request))

		data = model_state.form.data
		data['email'] = email
		data['descriptions'] = descriptions

		if is_add:
			if email:
				email.DefaultMsg = False
			for desc in descriptions.values():
				desc.Name = None

		title = _('Standard Email Update Text (%s)', request) % _(options.DM.label, request)
		return self._create_response_namespace(title, title, dict(EmailID=email_id, email=email, is_add=is_add, options=options), no_index=True)

	def _get_options(self):
		request = self.request
		user = request.user

		validator = OptionsSchema()
		try:
			options = validator.to_python(request.params)
		except validators.Invalid, e:
			self._error_page(_('Invalid Domain: %s', self.request) % e.message)

		options['MR'] = not not options['MR']

		options = Options(**options)

		if options.DM is None:
			self._error_page(_('No domain provided.', self.request))

		if options.DM.id == const.DM_CIC:
			options = options._replace(MR=False)

		if not ((options.DM.id == const.DM_CIC and user.cic.SuperUser) or
			(options.DM.id == const.DM_VOL and user.vol.SuperUser)):
			self._security_failure()

		log.debug('options: %s', options)
		return options

	@view_config(match_param='action=delete', renderer='cioc.web:templates/confirmdelete.mak')
	def delete(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		options = self._get_options()

		model_state = request.model_state

		model_state.validators = {'EmailID': validators.IDValidator(not_empty=True)}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		EmailID = model_state.form.data['EmailID']

		request.override_renderer = 'cioc.web:templates/confirmdelete.mak'

		extra_values = [('DM', options.DM.id)]
		if options.MR:
			extra_values.append(('MR', '1'))

		title = _('Standard Email Update Text (%s)', request) % _(options.DM.label, request)
		return self._create_response_namespace(title, title, dict(id_name='EmailID', id_value=EmailID, route='admin_email', action='delete', extra_values=extra_values), no_index=True)

	@view_config(match_param='action=delete', request_method="POST")
	def delete_confirm(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		options = self._get_options()

		model_state = request.model_state

		model_state.validators = {'EmailID': validators.IDValidator(not_empty=True)}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		EmailID = model_state.form.data['EmailID']

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_GBL_StandardEmailUpdate_d ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			'''

			cursor = conn.execute(sql, EmailID, request.dboptions.MemberID, options.DM.id, options.MR)
			result = cursor.fetchone()
			cursor.close()

		query = [('DM', options.DM.id)]
		if options.MR:
			query.append(('MR', '1'))

		if not result.Return:
			self._go_to_route('admin_email_index', _query=[('InfoMsg', _('The Standard Email Update Text was successfully deleted.', request))] + query)

		if result.Return == 3:
			self._error_page(_('Unable to delete Standard Email Update Text: ', request) + result.ErrMsg)

		self._go_to_route('admin_email', action='edit', _query=[('ErrMsg', _('Unable to delete Standard Email Update Text: ') + result.ErrMsg), ('EmailID', EmailID)] + query)
