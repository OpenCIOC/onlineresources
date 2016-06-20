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

EditValues = collections.namedtuple('EditValues', 'Code codeinfo examples')

def description_required(value_dict, state):
	exid = value_dict.get('Example_ID')
	if exid and exid != 'NEW':
		return True
	return False

class NaicsExampleBaseSchema(Schema):
	if_key_missing = None
	
	Example_ID = Any(ciocvalidators.IDValidator(), validators.OneOf(['NEW']))
	LangID = validators.Int(min=0, max=ciocvalidators.MAX_SMALL_INT, not_empty=True)
	Description = ciocvalidators.UnicodeString(max=255) #sometimes required as per RequireIfPredicate below
	delete = validators.Bool()

	chained_validators = [ciocvalidators.RequireIfPredicate(description_required, ['Description'])]


class PostSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	example = foreach.ForEach(NaicsExampleBaseSchema())


@view_defaults(route_name='admin_naics', match_param='action=example', renderer=templateprefix + 'example.mak')
class NaicsExample(viewbase.AdminViewBase):
	
	@view_config()
	def index(self):
		request = self.request
		
		Code = self._basic_info()

		edit_values = self._get_edit_info(Code)
			
		#raise Exception

		request.model_state.form.data['example'] = edit_values.examples

		title = _('NAICS Examples (%s)', request) % edit_values.codeinfo.Classification

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

			root = ET.Element('Examples')
			for i,example in enumerate(model_state.form.data['example']):
				if not example.get('Example_ID'):
					continue

				if example.get('Example_ID') == 'NEW' and not example.get('Description'):
					continue

				if example.get('delete'):
					continue

				example_el = ET.SubElement(root, 'Example')
				ET.SubElement(example_el, 'CNT').text = unicode(i)

				for key,value in example.iteritems():
					if key == 'Example_ID' and value == 'NEW':
						value = -1

					if value is not None:
						ET.SubElement(example_el, key).text = unicode(value)

			args = [Code, user.Mod, ET.tostring(root)]

			#raise Exception
			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500), 
				@RC as int 

				EXECUTE @RC = dbo.sp_NAICS_Example_u ?, ?, ?, @ErrMsg OUTPUT  

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				'''

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:

				self._go_to_route('admin_naics', action='example', 
						_query=[('InfoMsg', _('The NAICS examples were successfully updated.', request)), 
							('Code', Code)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			ErrMsg = _('There were validation errors.')


		edit_values = self._get_edit_info(Code)


		title = _('NAICS Examples (%s)', request) % edit_values.codeinfo.Classification

		edit_values = edit_values._asdict()

		examples = edit_values['examples'] = variabledecode.variable_decode(request.POST)['example']

		model_state.form.data['example'] = examples

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
			self._error_page(_('Invalid NAICS Code:', request) + e.message )

		return Code

	def _get_edit_info(self, Code):
		request = self.request

		codeinfo = None
		examples = []
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC sp_NAICS_Example_lf ?', Code)
			codeinfo = cursor.fetchone()

			if codeinfo:
				cursor.nextset()

				examples = cursor.fetchall()

			cursor.close()

		if not codeinfo: ## not a valid view
			self._error_page(_('NAICS Code Not Found', request))

		return EditValues(Code, codeinfo, examples)
