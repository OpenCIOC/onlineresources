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
import six
log = logging.getLogger(__name__)

import xml.etree.cElementTree as ET

from formencode import Schema, validators, schema
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase 

templateprefix = 'cioc.web.admin:templates/naics/'

NAICS_SECTOR = 2

NaicsCode = ciocvalidators.NaicsCode

class MaybeRequireParent(validators.FormValidator):
	def _(x): return x

	messages = {'notsector': _('Only a Sector may have a blank Parent Code')}

	del _

	def _to_python(self, value_dict, state):
		val = value_dict.get('Parent')
		code = value_dict.get('Code')
		errors = {}
		if not val and code and len(str(code)) != NAICS_SECTOR:
			errors['Parent'] = validators.Invalid(self.message('notsector', state), value_dict, state)

			raise validators.Invalid(schema.format_compound_error(errors), 
							value_dict, state, error_dict=errors)


		return value_dict

class NaicsBaseSchema(Schema):
	if_key_missing = None
	
	NewCode = NaicsCode(not_empty=True)
	Parent = NaicsCode()

	CompUS = validators.Bool()
	CompMex = validators.Bool()

	chained_validators = [MaybeRequireParent()]

base_fields = list(NaicsBaseSchema.fields.keys())

class NaicsDescriptionSchema(Schema):
	if_key_missing = None

	Classification = ciocvalidators.UnicodeString(max=200, not_empty=True)
	Description = ciocvalidators.UnicodeString(max=8000)


class NaicsSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None
	
	naics = NaicsBaseSchema()
	descriptions = ciocvalidators.CultureDictSchema(NaicsDescriptionSchema())


@view_defaults(route_name='admin_naics')
class Naics(viewbase.AdminViewBase):
	
	@view_config(route_name='admin_naics_index', renderer=templateprefix + 'index.mak')
	def index(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUserGlobal:
			self._security_failure()

		title = _('Manage NAICS Codes', request)
		return self._create_response_namespace(title, title, {}, no_index=True)


	@view_config(match_param='action=edit', request_method="POST", renderer=templateprefix+'edit.mak')
	def save(self):
		request = self.request

		if request.POST.get('Delete'):
			self._go_to_route('admin_naics', action='delete', _query=[('Code', request.POST.get('Code'))])

		user = request.user

		if not user.cic.SuperUserGlobal:
			self._security_failure()

		model_state = request.model_state
		model_state.schema = NaicsSchema()
		model_state.form.variable_decode = True

		validator = ciocvalidators.IDValidator()
		try:
			Code = validator.to_python(request.POST.get('Code'))
		except validators.Invalid:
			self._error_page(_('Invalid NAICS Code', request))

		#values = variabledecode.variable_decode(request.POST)
		#raise Exception

		is_add = not Code

		if model_state.validate():
			# valid. Save changes and redirect
			naics = model_state.form.data.get('naics', {})
			args = [Code, user.Mod, user.Mod]
			args.extend(naics.get(x) for x in base_fields)
			kwargs = ', '.join(k.join(('@', '=?')) for k in base_fields)

			root = ET.Element('DESCS')

			for culture, data in six.iteritems(model_state.form.data['descriptions']):
				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, "Culture").text = culture.replace('_', '-')
				for name, value in six.iteritems(data):
					if value:
						ET.SubElement(desc, name).text = value

			args.append(ET.tostring(root))

			#xml = args[-1]
			#raise Exception
							

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500), 
				@RC as int 

				EXECUTE @RC = dbo.sp_NAICS_u ?, ?, @Source=?, %s, @Descriptions=?, @ErrMsg=@ErrMsg OUTPUT  

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				''' % kwargs

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:
				Code = naics.get('NewCode')


				if is_add:
					msg = _('The NAICS Code was added successfully.',request)
				else:
					msg = _('The NAICS Code was updated successfully.',request)

				self._go_to_route('admin_naics', action='edit', _query=[('InfoMsg', msg),("Code", Code)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:

			ErrMsg = _('There were validation errors.')

		naics = None
		descriptions = {}

		with request.connmgr.get_connection('admin') as conn:
			if not is_add:
				cursor = conn.execute('EXEC dbo.sp_NAICS_s ?', model_state.value('Code'))

				naics = cursor.fetchone()
				if naics:
					cursor.nextset()
					for lng in cursor.fetchall():
						descriptions[lng.Culture.replace('-', '_')] = lng

				cursor.close()

				if not naics:
					# not found
					self._error_page(_('NAICS Code Not Found', request))


		descs = sorted(list(descriptions.items()), key=lambda x: x[0] != request.language.Culture)

		classification = None
		if not is_add:
			title = _('Edit NAICS Code: ', request) + naics.Code
			classification = descs[0][1].Classification if descs else _('Unknown', request)
		else:
			title = _('Create New NAICS Code', request)

		#errors = model_state.form.errors
		#data = model_state.form.data
		#raise Exception
		# XXX should we refetch the basic info?
		title = _('Manage NAICS Codes', request)
		return self._create_response_namespace(title, title,
				dict(naics=naics, Code=Code,
					classification=classification,
					is_add=is_add, ErrMsg=ErrMsg), 
						no_index=True)

	@view_config(match_param='action=edit', renderer=templateprefix+'edit.mak')
	def edit(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUserGlobal:
			self._security_failure()


		model_state = request.model_state
		model_state.validators = {
				'Code': NaicsCode()
				}
		model_state.method = None

		if not model_state.validate():
			# XXX invalid Code
				
			self._error_page(_('Invalid ID', request))

		Code = model_state.form.data.get('Code')
		is_add = not Code

		naics = None
		descriptions = {}

		
		if not is_add:
			with request.connmgr.get_connection('admin') as conn:
				cursor = conn.execute('EXEC dbo.sp_NAICS_s ?', Code)
				naics = cursor.fetchone()
				if naics:
					cursor.nextset()
					for lng in cursor.fetchall():
						descriptions[lng.Culture.replace('-', '_')] = lng


				cursor.close()

				if not naics:
					# not found
					self._error_page(_('NAICS Code Not Found', request))


		model_state.form.data['naics'] = naics
		model_state.form.data['descriptions'] = descriptions

		if naics:
			model_state.form.data['naics.NewCode'] = Code

		descs = sorted(list(descriptions.items()), key=lambda x: x[0] != request.language.Culture)


		classification = None
		if not is_add:
			title = _('Edit NAICS Code: ', request) + naics.Code
			classification = descs[0][1].Classification if descs else _('Unknown', request)
		else:
			title = _('Create New NAICS Code', request)

		return self._create_response_namespace(title, title,
				dict(naics=naics, Code=Code, is_add=is_add, 
				classification=classification),
				no_index=True)


	@view_config(match_param='action=delete', renderer='cioc.web:templates/confirmdelete.mak')
	def delete(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUserGlobal:
			self._security_failure()


		model_state = request.model_state

		model_state.validators = {
				'Code': ciocvalidators.IDValidator(not_empty=True)
				}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		Code = model_state.form.data['Code']
		
		request.override_renderer = 'cioc.web:templates/confirmdelete.mak'

		title = _('Delete NAICS Code', request)
		return self._create_response_namespace(title, title, dict(id_name='Code', id_value=Code, route='admin_naics', action='delete'), no_index=True)

	@view_config(match_param='action=delete', request_method="POST")
	def delete_confirm(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUserGlobal:
			self._security_failure()


		model_state = request.model_state

		model_state.validators = {
				'Code': ciocvalidators.IDValidator(not_empty=True)
				}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		Code = model_state.form.data['Code']
		
		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500), 
			@RC as int 

			EXECUTE @RC = dbo.sp_NAICS_d ?, @ErrMsg=@ErrMsg OUTPUT  

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			''' 

			cursor = conn.execute(sql, Code)
			result = cursor.fetchone()
			cursor.close()


		if not result.Return:
			self._go_to_route('admin_naics_index', _query=[('InfoMsg', _('The NAICS Code was successfully deleted.', request))])

		if result.Return == 3:
			self._error_page(_('Unable to delete Community: ', request) + result.ErrMsg)

		self._go_to_route('admin_naics', action='edit', _query=[('ErrMsg', _('Unable to delete Community: ') + result.ErrMsg), ('Code', Code)])
	
