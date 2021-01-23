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
import xml.etree.cElementTree as ET

# 3rd party
from formencode import Schema, validators, Pipe
from pyramid.view import view_config, view_defaults

# this app
from cioc.core import validators as ciocvalidators, syslanguage

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase
import six

log = logging.getLogger(__name__)

templateprefix = 'cioc.web.admin:templates/mappingsystem/'


class MappingSystemBaseSchema(Schema):
	if_key_missing = None

	NewWindow = validators.Bool()
	DefaultProvince = ciocvalidators.String(min=2, max=2, if_empty=None, not_empty=True)
	DefaultCountry = ciocvalidators.UnicodeString(max=50, not_empty=True)

mapping_fields = ['NewWindow', 'DefaultProvince', 'DefaultCountry']


class MappingSystemDescriptionSchema(Schema):
	if_key_missing = None

	Name = ciocvalidators.UnicodeString(max=50)
	Label = ciocvalidators.UnicodeString(max=200)
	String = Pipe(ciocvalidators.URLWithProto(max=255), validators.MaxLength(255))

	chained_validators = [
		ciocvalidators.RequireIfAny('Name', present=("Label", 'String')),
		ciocvalidators.RequireIfAny('Label', present=("Name", "String")),
		ciocvalidators.RequireIfAny('String', present=("Name", "Label")),
	]


class MappingSystemSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	mapping = MappingSystemBaseSchema()
	descriptions = ciocvalidators.CultureDictSchema(MappingSystemDescriptionSchema(), record_cultures=True, delete_empty=False)


@view_defaults(route_name='admin_mappingsystem')
class MappingSystem(viewbase.AdminViewBase):

	@view_config(route_name='admin_mappingsystem_index', renderer=templateprefix + 'index.mak')
	def index(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_GBL_MappingSystem_l NULL')
			mappings = cursor.fetchall()
			cursor.close()

		title = _('Manage Mapping Systems', request)
		return self._create_response_namespace(title, title, dict(mappings=mappings), no_index=True)

	@view_config(match_param='action=edit', request_method="POST", renderer=templateprefix + 'edit.mak')
	def save(self):
		request = self.request

		if request.POST.get('Delete'):
			self._go_to_route('admin_mappingsystem', action='delete', _query=[('MAP_ID', request.POST.get('MAP_ID'))])

		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		model_state = request.model_state
		model_state.schema = MappingSystemSchema()
		model_state.form.variable_decode = True

		validator = ciocvalidators.IDValidator()
		try:
			MAP_ID = validator.to_python(request.POST.get('MAP_ID'))
		except validators.Invalid:
			self._error_page(_('Invalid Mapping System ID', request))

		is_add = not MAP_ID

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)

		if model_state.validate():
			# valid. Save changes and redirect
			args = [MAP_ID, user.Mod]
			mapping = model_state.form.data.get('mapping', {})
			args.extend(mapping.get(x) for x in mapping_fields)

			root = ET.Element('DESCS')

			for culture, data in six.iteritems(model_state.form.data['descriptions']):
				if culture.replace('_', '-') not in shown_cultures:
					continue

				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, "Culture").text = culture.replace('_', '-')
				for name, value in six.iteritems(data):
					if value:
						ET.SubElement(desc, name).text = value

			args.append(ET.tostring(root))

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				Declare @ErrMsg as nvarchar(500),
				@RC as int,
				@MAP_ID as int

				SET @MAP_ID = ?

				EXECUTE @RC = dbo.sp_GBL_MappingSystem_u @MAP_ID OUTPUT, %s, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg, @MAP_ID as MAP_ID
				''' % ', '.join('?' * (len(args) - 1))

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:
				MAP_ID = result.MAP_ID

				if is_add:
					msg = _('The Mapping System was successfully added.', request)
				else:
					msg = _('The Mapping System was successfully updated.', request)

				self._go_to_route('admin_mappingsystem', action='edit', _query=[('InfoMsg', msg), ("MAP_ID", MAP_ID), ("ShowCultures", shown_cultures)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:

			ErrMsg = _('There were validation errors.')

		mapping = None

		if not is_add:
			with request.connmgr.get_connection('admin') as conn:
				cursor = conn.execute('EXEC dbo.sp_GBL_MappingSystem_s ?', model_state.value('MAP_ID'))

				mapping = cursor.fetchone()

				cursor.close()

		record_cultures = syslanguage.active_record_cultures()

		# XXX should we refetch the basic info?
		title = _('Manage Mapping Systems', request)
		return self._create_response_namespace(title, title,
				dict(mapping=mapping, MAP_ID=model_state.value('MAP_ID'),
					shown_cultures=shown_cultures, record_cultures=record_cultures,
					is_add=is_add, ErrMsg=ErrMsg), no_index=True)

	@view_config(match_param='action=edit', renderer=templateprefix + 'edit.mak')
	def edit(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		model_state = request.model_state
		model_state.validators = {
			'MAP_ID': ciocvalidators.IDValidator()
		}
		model_state.method = None

		if not model_state.validate():
			# XXX invalid MAP_ID

			self._error_page(_('Invalid ID', request))

		MAP_ID = model_state.form.data.get('MAP_ID')
		is_add = not MAP_ID

		mapping = None
		mapping_descriptions = {}

		if not is_add:
			with request.connmgr.get_connection('admin') as conn:
				cursor = conn.execute('EXEC dbo.sp_GBL_MappingSystem_s ?', MAP_ID)
				mapping = cursor.fetchone()
				if mapping:
					cursor.nextset()
					for lng in cursor.fetchall():
						mapping_descriptions[lng.Culture.replace('-', '_')] = lng

				cursor.close()

			if not mapping:
				# not found
				self._error_page(_('Mapping System Not Found', request))

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)

		model_state.form.data['mapping'] = mapping
		model_state.form.data['descriptions'] = mapping_descriptions

		title = _('Manage Mapping Systems', request)
		return self._create_response_namespace(
			title, title,
			dict(
				mapping=mapping, MAP_ID=MAP_ID, is_add=is_add, shown_cultures=shown_cultures,
				record_cultures=syslanguage.active_record_cultures()
			), no_index=True)

	@view_config(match_param='action=delete', renderer='cioc.web:templates/confirmdelete.mak')
	def delete(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'MAP_ID': ciocvalidators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		MAP_ID = model_state.form.data['MAP_ID']

		request.override_renderer = 'cioc.web:templates/confirmdelete.mak'

		title = _('Manage Mapping Systems', request)
		return self._create_response_namespace(title, title, dict(id_name='MAP_ID', id_value=MAP_ID, route='admin_mappingsystem', action='delete'), no_index=True)

	@view_config(match_param='action=delete', request_method="POST")
	def delete_confirm(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'MAP_ID': ciocvalidators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		MAP_ID = model_state.form.data['MAP_ID']

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			Declare @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_GBL_MappingSystem_d ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			'''

			cursor = conn.execute(sql, MAP_ID)
			result = cursor.fetchone()
			cursor.close()

		if not result.Return:
			self._go_to_route('admin_mappingsystem_index', _query=[('InfoMsg', _('The Mapping System was successfully deleted.', request))])

		if result.Return == 3:
			self._error_page(_('Unable to delete Mapping System: ', request) + result.ErrMsg)

		self._go_to_route('admin_mappingsystem', action='edit', _query=[('ErrMsg', _('Unable to delete Mapping System: ') + result.ErrMsg), ('MAP_ID', MAP_ID)])
