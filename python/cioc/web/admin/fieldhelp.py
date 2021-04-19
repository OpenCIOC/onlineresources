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

from formencode import Schema
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators, syslanguage, constants as const

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = 'cioc.web.admin:templates/fieldhelp/'


class FieldHelpDescriptionSchema(Schema):
	if_key_missing = None

	HelpText = ciocvalidators.UnicodeString(max=8000)
	HelpTextMember = ciocvalidators.UnicodeString(max=8000)


class FieldHelpSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	pre_validators = [viewbase.cull_extra_cultures('descriptions')]

	FieldID = ciocvalidators.IDValidator(not_empty=True)
	descriptions = ciocvalidators.CultureDictSchema(FieldHelpDescriptionSchema(), record_cultures=True, delete_empty=False)


@view_defaults(route_name='admin_fieldhelp', renderer=templateprefix + 'edit.mak', match_param="action=edit")
class FieldHelp(viewbase.AdminViewBase):

	@view_config(request_method="POST")
	def save(self):
		request = self.request

		user = request.user

		if not user.SuperUser:
			self._security_failure()

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)

		if (domain.id == const.DM_CIC and not user.cic.SuperUser) or \
			(domain.id == const.DM_VOL and not user.vol.SuperUser):

			self._security_failure()

		SuperUserGlobal = (domain.id == const.DM_CIC and user.cic.SuperUserGlobal) \
			or (domain.id == const.DM_VOL and user.vol.SuperUserGlobal)

		model_state = request.model_state
		model_state.schema = FieldHelpSchema()
		model_state.form.variable_decode = True

		if model_state.validate():
			FieldID = model_state.form.data.get('FieldID')
			# valid. Save changes and redirect
			args = [FieldID, request.dboptions.MemberID, SuperUserGlobal, user.Mod]

			root = ET.Element('DESCS')

			for culture, data in six.iteritems(model_state.form.data['descriptions']):
				if culture.replace('_', '-') not in shown_cultures:
					continue

				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, "Culture").text = culture.replace('_', '-')
				for name, value in six.iteritems(data):
					if value:
						ET.SubElement(desc, name).text = value

			args.append(ET.tostring(root, encoding='unicode'))

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int

				EXEC @RC = dbo.sp_%s_FieldOption_u_Help ?, ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				''' % domain.str

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:
				self._go_to_route('admin_fieldhelp', action='edit', _query=[('DM', domain.id), ('InfoMsg', _('The Field Help was updated successfully.', request)), ("FieldID", FieldID), ("ShowCultures", shown_cultures)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:

			ErrMsg = _('There were validation errors.')

		field = None

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_%s_FieldOption_sf_Help ?, ?' % domain.str, model_state.value('FieldID'), request.dboptions.MemberID)

			field = cursor.fetchone()

			cursor.close()

		record_cultures = syslanguage.active_record_cultures()

		title = _('Manage Field Help', request)
		return self._create_response_namespace(
			title, title,
			dict(
				SuperUserGlobal=SuperUserGlobal, domain=domain,
				field=field, FieldID=model_state.value('FieldID'),
				shown_cultures=shown_cultures, record_cultures=record_cultures,
				ErrMsg=ErrMsg
			), no_index=True)

	@view_config()
	def edit(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
		if not domain:
			return self._go_to_page('~/admin/setup.asp')

		if (domain.id == const.DM_CIC and not user.cic.SuperUser) or \
			(domain.id == const.DM_VOL and not user.vol.SuperUser):

			self._security_failure()

		SuperUserGlobal = (domain.id == const.DM_CIC and user.cic.SuperUserGlobal) \
			or (domain.id == const.DM_VOL and user.vol.SuperUserGlobal)

		model_state = request.model_state
		model_state.validators = {
			'FieldID': ciocvalidators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			# XXX invalid FieldID

			self._error_page(_('Invalid ID', request))

		FieldID = model_state.form.data.get('FieldID')

		field = None
		field_descriptions = {}

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_%s_FieldOption_sf_Help ?, ?' % domain.str, FieldID, request.dboptions.MemberID)
			field = cursor.fetchone()

			cursor.nextset()

			for lng in cursor.fetchall():
				field_descriptions[lng.Culture.replace('-', '_')] = lng

			cursor.close()

		if not field:
			# not found
			self._error_page(_('Field Not Found', request))

		model_state.form.data['descriptions'] = field_descriptions

		title = _('Manage Field Help', request)
		return self._create_response_namespace(
			title, title,
			dict(
				SuperUserGlobal=SuperUserGlobal,
				field=field, FieldID=FieldID,
				shown_cultures=shown_cultures, domain=domain,
				record_cultures=syslanguage.active_record_cultures()
			), no_index=True)
