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

import xml.etree.cElementTree as ET
#import elementtree.ElementTree as ET

import collections

from formencode import Schema, validators, foreach, variabledecode, Any
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = 'cioc.web.admin:templates/naics/'

EditValues = collections.namedtuple('EditValues', 'Code codeinfo exclusions')

def description_required(value_dict, state):
	exid = value_dict.get('Exclusion_ID')
	if exid and exid != 'NEW':
		return True
	return False

class NaicsExclusionBaseSchema(Schema):
	if_key_missing = None
	
	Exclusion_ID = Any(ciocvalidators.IDValidator(), validators.OneOf(['NEW']))
	LangID = validators.Int(min=0, max=ciocvalidators.MAX_SMALL_INT, not_empty=True)
	Description = ciocvalidators.UnicodeString(max=255) #sometimes required as per RequireIfPredicate below
	Establishment = validators.Bool()

	UseCodes = foreach.ForEach(ciocvalidators.NaicsCode())

	delete = validators.Bool()

	chained_validators = [ciocvalidators.RequireIfPredicate(description_required, ['Description'])]

class PostSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	exclusion = foreach.ForEach(NaicsExclusionBaseSchema())


@view_defaults(route_name='admin_naics', match_param='action=exclusion', renderer=templateprefix + 'exclusion.mak')
class NaicsExclusion(viewbase.AdminViewBase):
	
	@view_config()
	def index(self):
		request = self.request
		
		Code = self._basic_info()

		edit_values = self._get_edit_info(Code)
			
		#raise Exception

		request.model_state.form.data['exclusion'] = edit_values.exclusions

		title = _('NAICS Exclusions (%s)', request) % edit_values.codeinfo.Classification

		return self._create_response_namespace(title, title,
				edit_values._asdict(),
				no_index=True)

	@view_config(request_method="POST")
	def save(self):
		request = self.request
		user = request.user

		Code = self._basic_info()

		model_state = request.model_state
		model_state.schema = PostSchema()

		model_state.form.variable_decode = True

		if model_state.validate():
			# valid. Save changes and redirect

			root = ET.Element('Exclusions')
			for i,exclusion in enumerate(model_state.form.data['exclusion']):
				if not exclusion.get('Exclusion_ID'):
					continue

				if exclusion.get('Exclusion_ID') == 'NEW' and not exclusion.get('Description'):
					continue

				if exclusion.get('delete'):
					continue

				exclusion_el = ET.SubElement(root, 'Exclusion')
				ET.SubElement(exclusion_el, 'CNT').text = unicode(i)

				for key,value in exclusion.iteritems():
					if key == 'Exclusion_ID' and value == 'NEW':
						value = -1

					if key == 'Establishment':
						value = int(value)

					if key != 'UseCodes':
						if value is not None:
							ET.SubElement(exclusion_el, key).text = unicode(value)

						continue

					# Use Codes
					usecodes = ET.SubElement(exclusion_el, key)
					for usecode in value or []:
						ET.SubElement(usecodes, 'UseCode').text = unicode(usecode)

			args = [Code, user.Mod, ET.tostring(root)]

			#raise Exception
			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500), 
				@RC as int 

				EXECUTE @RC = dbo.sp_NAICS_Exclusion_u ?, ?, ?, @ErrMsg OUTPUT  

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				'''

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:

				self._go_to_route('admin_naics', action='exclusion', 
						_query=[('InfoMsg', _('The NAICS Exclusions were successfully updated.', request)), 
							('Code', Code)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			ErrMsg = _('There were validation errors.')

		edit_values = self._get_edit_info(Code)

		title = _('NAICS Exclusions (%s)', request) % edit_values.codeinfo.Classification

		edit_values = edit_values._asdict()

		exclusions = edit_values['exclusions'] = variabledecode.variable_decode(request.POST)['exclusion']

		for exclusion in exclusions:
			use_codes = exclusion['UseCodes']
			if isinstance(use_codes, basestring):
				exclusion['UseCodes'] = [use_codes]

		model_state.form.data['exclusion'] = exclusions

		edit_values['ErrMsg'] = ErrMsg

		#errors = model_state.form.errors
		#raise Exception()

		return self._create_response_namespace(title, title,
				edit_values, no_index=True)


	def _basic_info(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUserGlobal:
			self._security_failure()

		validator = ciocvalidators.IDValidator(not_empty=True)
		try:
			Code = validator.to_python(request.params.get('Code'))
		except validators.Invalid, e:
			self._error_page( _('Invalid NAICS Code:', request) + e.message )

		return Code

	def _get_edit_info(self, Code):
		request = self.request

		codeinfo = None
		exclusions = []
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC sp_NAICS_Exclusion_lf ?', Code)
			codeinfo = cursor.fetchone()

			if codeinfo:
				cursor.nextset()

				exclusions = cursor.fetchall()

			cursor.close()


		if not codeinfo: ## not a valid view
			self._error_page( _('NAICS Code Not Found', request))

		
		for exclusion in exclusions:
			exclusion.UseCodes = self._list_from_xml(exclusion.UseCodes, 'Code')

		return EditValues(Code, codeinfo, exclusions)
