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
import collections

from formencode import Schema, validators, ForEach, All
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators, constants as const, syslanguage

from cioc.core.i18n import gettext as _
from cioc.web.cic.viewbase import CicViewBase

templateprefix = 'cioc.web.cic:templates/updatepubs/'

class UpdatePubsDescriptionSchema(Schema):
	if_key_missing = None

	Description = ciocvalidators.UnicodeString(max=8000)
	
class UpdatePubsSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	descriptions = ciocvalidators.CultureDictSchema(UpdatePubsDescriptionSchema(), pre_validators=[ciocvalidators.DeleteKeyIfEmpty()])
	GHID = All(validators.Set(use_set=True), ForEach(ciocvalidators.IDValidator()))
	DeleteFeedback = validators.DictConverter({'Y': True, 'N': False}, if_empty=False, if_missing=False)


EditValues = collections.namedtuple('EditValues', 'publication publication_descriptions linked_headings fullorg generalheadings taxonomyheadings feedback NUM BTPBID Number record_cultures')

@view_defaults(route_name='cic_updatepubs')
class UpdatePubs(CicViewBase):
	
	@view_config(match_param='action=edit', request_method="POST", renderer=templateprefix+'edit.mak')
	def save(self):
		request = self.request
		user = request.user


		if not user.cic or user.cic.CanUpdatePubs == const.UPDATE_NONE:
			self._security_failure()

		model_state = request.model_state
		model_state.schema = UpdatePubsSchema()
		model_state.form.variable_decode = True

		base_params = []

		num = request.params.get('NUM')
		if num is not None:
			base_params.append( ('NUM', num) )

		number = request.params.get('Number')
		if number is not None:
			base_params.append( ('Number', number) )

		validator = ciocvalidators.IDValidator(not_empty=True)
		try:
			BTPBID = validator.to_python(request.POST.get('BTPBID'))
		except validators.Invalid:
			self._error_page(_('Invalid Publication ID', request))

		#values = variabledecode.variable_decode(request.POST)
		#raise Exception


		if model_state.validate():
			# valid. Save changes and redirect

			form_data = model_state.form.data
			args = [BTPBID, user.Mod, not not form_data.get('DeleteFeedback')]

			root = ET.Element('DESCS')

			for culture, data in six.iteritems((form_data['descriptions'] or {})):
				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, "Culture").text = culture.replace('_', '-')
				for name, value in six.iteritems(data):
					if value:
						ET.SubElement(desc, name).text = value

			args.append(ET.tostring(root, encoding='unicode'))

			root = ET.Element('HEADINGS')
			for heading in (form_data['GHID'] or []):
				ET.SubElement(root, 'GHID').text = six.text_type(heading)

			args.append(ET.tostring(root, encoding='unicode'))

			args.append(user.User_ID)
			args.append(request.viewdata.cic.ViewType)

			#xml = args[-1]
			#raise Exception
							
			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500), 
				@RC as int, 
				@BTPBID as int

				SET @BTPBID = ?

				EXECUTE @RC = dbo.sp_CIC_NUMPub_u @BTPBID OUTPUT, ?, ?, ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg, @BTPBID as BTPBID
				''' 

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:
				BTPBID = result.BTPBID

				self._go_to_route('cic_updatepubs', action='edit', _query=base_params + [('InfoMsg', _('The record was successfully updated.', request)),("BTPBID", BTPBID)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			ErrMsg = _('There were validation errors.')

		edit_values = self._get_edit_info(num, BTPBID, number, base_params)._asdict()
		edit_values['ErrMsg'] = ErrMsg
		
		#errors = model_state.form.errors
		#data = model_state.form.data
		#raise Exception

		title = _('Update Publications', request)
		return self._create_response_namespace(title, title,
				edit_values,
				no_index=True)

	@view_config(match_param='action=edit', renderer=templateprefix+'edit.mak')
	def edit(self):
		request = self.request
		user = request.user

		if not user.cic or user.cic.CanUpdatePubs == const.UPDATE_NONE:
			self._security_failure()


		base_params = []

		num = request.params.get('NUM')
		if num is not None:
			base_params.append( ('NUM', num) )

		number = request.params.get('Number')
		if number is not None:
			base_params.append( ('Number', number) )

		if request.params.get('Delete'):
			self._go_to_route('cic_updatepubs', action='delete', _query=base_params + [('BTPBID', request.params.get('BTPBID'))])

		model_state = request.model_state
		model_state.validators = {
				'BTPBID': ciocvalidators.IDValidator(not_empty=True)
				}
		model_state.method = None

		if not model_state.validate():
			# XXX invalid BTPBID
			self._error_page(_('Invalid Publication ID', request))

		BTPBID = model_state.form.data.get('BTPBID')
			
		edit_values = self._get_edit_info(num, BTPBID, number, base_params)

		data = model_state.form.data
		data['descriptions'] = edit_values.publication_descriptions
		data['GHID'] = edit_values.linked_headings

		title = _('Update Publications', request)
		return self._create_response_namespace(title, title,
				edit_values._asdict(),
				no_index=True)


	def _get_edit_info(self, num, BTPBID, number, base_params):
		request = self.request
		user = request.user

		publication = None
		publication_descriptions = {}

		fullorg = None
		generalheadings = []
		taxonomyheadings = []
		feedback = []


		with request.connmgr.get_connection('admin') as conn:
			sql = 'EXEC dbo.sp_CIC_NUMPub_s ?, ?, ?'
			cursor = conn.execute(sql, BTPBID, user.User_ID, request.viewdata.cic.ViewType)

			errordata = cursor.fetchone()

			if not errordata.Error:
				cursor.nextset()

				fullorg = cursor.fetchone().ORG_NAME_FULL

				cursor.nextset()

				publication = cursor.fetchone()

				cursor.nextset()

				for lng in cursor.fetchall():
					publication_descriptions[lng.Culture.replace('-', '_')] = lng

				cursor.nextset()

				generalheadings = cursor.fetchall()

				cursor.nextset()

				taxonomyheadings = cursor.fetchall()

				cursor.nextset()

				feedback = cursor.fetchall()

			cursor.close()

		if errordata.Error:

			self._error_page(errordata.ErrMsg or _('An unknown error occurred.', request))

		linked_headings = set(six.text_type(x.GH_ID) for x in generalheadings if x.SELECTED)

		record_cultures = [x for x in syslanguage.active_record_cultures() 
						if x.replace('-', '_') in publication_descriptions]

		return EditValues(publication, publication_descriptions, linked_headings, fullorg, generalheadings, taxonomyheadings, feedback, num, BTPBID, number, record_cultures)

	@view_config(match_param='action=delete', renderer='cioc.web:templates/confirmdelete.mak')
	def delete(self):
		request = self.request
		user = request.user

		if not user.cic or user.cic.CanUpdatePubs == const.UPDATE_NONE:
			self._security_failure()

		base_params = []

		num = request.params.get('NUM')
		if num is not None:
			base_params.append( ('NUM', num) )

		number = request.params.get('Number')
		if number is not None:
			base_params.append( ('Number', number) )

		model_state = request.model_state
		model_state.validators = {
				'BTPBID': ciocvalidators.IDValidator(not_empty=True)
				}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid Publication ID', request))

		BTPBID = model_state.form.data.get('BTPBID')
		

		title = _('Update Publications', request)
		return self._create_response_namespace(title, title, dict(id_name='BTPBID', id_value=BTPBID, extra_values=base_params, route='cic_updatepubs', action='delete'), no_index=True)

	@view_config(match_param='action=delete', request_method="POST")
	def delete_confirm(self):
		request = self.request
		user = request.user

		if not user.cic or user.cic.CanUpdatePubs == const.UPDATE_NONE:
			self._security_failure()

		base_params = []

		num = request.params.get('NUM')
		if num is not None:
			base_params.append( ('NUM', num) )

		number = request.params.get('Number')
		if number is not None:
			base_params.append( ('Number', number) )

		model_state = request.model_state
		model_state.validators = {
				'BTPBID': ciocvalidators.IDValidator(not_empty=True)
				}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid Publication ID', request))

		BTPBID = model_state.form.data.get('BTPBID')
		
		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500), 
			@RC as int 

			EXECUTE @RC = dbo.sp_CIC_NUMPub_d ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			''' 

			cursor = conn.execute(sql, BTPBID, user.User_ID, request.viewdata.cic.ViewType)
			result = cursor.fetchone()
			cursor.close()


		if not result.Return:
			if num:
				self._go_to_page('~/update_pubs.asp', dict(base_params + [('InfoMsg', _('The Publication was successfully deleted.', request))]))
			self._go_to_page('~/', dict(InfoMsg= _('The Publication was successfully deleted.', request)))

		self._error_page(_('Unable to delete Publication: ', request) + result.ErrMsg)

	
