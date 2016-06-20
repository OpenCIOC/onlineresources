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
import logging

# 3rd party
from pyramid.view import view_config

# this app
from cioc.core import i18n, validators as ciocvalidators
from cioc.web.cic import viewbase
from cioc.core.format import textToHTML

_ = i18n.gettext

log = logging.getLogger(__name__)

class APISchema(ciocvalidators.RootSchema):
	if_key_missing = None
	key = ciocvalidators.UUIDValidator(not_empty=True)
	description = ciocvalidators.Bool()
	address = ciocvalidators.Bool()
	email = ciocvalidators.Bool()
	web = ciocvalidators.Bool()
	officephone = ciocvalidators.Bool()
	hours = ciocvalidators.Bool()

class OrgAPISchema(APISchema):
	num = ciocvalidators.NumValidator(not_empty=True)

class CodeAPISchema(APISchema):
	code = ciocvalidators.CodeValidator(not_empty=True)
	location = ciocvalidators.UnicodeString(max=210)
	servicearea = ciocvalidators.UnicodeString(max=210)

class TaxCodeAPISchema(APISchema):
	code = ciocvalidators.TaxonomyCodeValidator(not_empty=True)
	location = ciocvalidators.UnicodeString(max=210)
	servicearea = ciocvalidators.UnicodeString(max=210)

class BaseFeedView(viewbase.CicViewBase):
	extra_args = []

	def get_proc_args(self):
		model_state = self.request.model_state

		default_args = ['key', 'description', 'address', 'email', 'web', 'officephone', 'hours']
		return [model_state.value(x) for x in default_args] + [model_state.value(x) for x in self.extra_args]

	def __call__(self):
		request = self.request

		model_state = request.model_state
		model_state.method = None
		model_state.schema = self.schema

		if not model_state.validate():
			api_key = None
			error_msg = _('Invalid Request', request)
			error_details = model_state.form.errors
			request.response.status_code = 400
			return {'error': error_msg, 'error_details': error_details}

		api_key = model_state.value('key')
		error_msg = None

		args = self.get_proc_args()

		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('''
				DECLARE @RC as int
				EXECUTE @RC = %s ?, %s
				SELECT @RC as [Return]
				''' % (self.stored_proc, ','.join('?' * len(args))), request.viewdata.cic.ViewType, *args)

		results = cursor.fetchall()

		cursor.nextset()
		key_error = cursor.fetchone()
		cursor.close()

		if key_error.Return == -1:
			request.response.status_code = 403
			error_msg = _('Invalid API Token', request)

		return {
			'error': error_msg,
			'recordset': self.process_results(results)
		}
	
@view_config(route_name='jsonfeeds_cicnewest', renderer='json')
class JsonFeedsCicNewestRecords(BaseFeedView):
	schema = APISchema
	stored_proc = 'dbo.sp_CIC_WhatsNew_Feed'
	def process_results(self, results):
		return	[{
					'id': row.NUM,
					'search': '/record/' + row.NUM,
					'name': row.ORG_NAME_FULL,
					'location': row.LOCATION,
					'description' : row.DESCRIPTION_SHORT,
					'address': row.SITE_ADDRESS,
					'email': row.EMAIL,
					'web': row.WEB,
					'officephone': textToHTML(row.OFFICE_PHONE),
					'hours': textToHTML(row.HOURS),
					'date': row.CREATED_DATE
				} for row in results]

@view_config(route_name='jsonfeeds_cicpub', renderer='json')
class JsonFeedsCicPubRecords(BaseFeedView):
	schema = CodeAPISchema
	stored_proc = 'dbo.sp_CIC_SpecificPub_Feed'
	extra_args = ['code','location','servicearea']

	def process_results(self, results):
		return	[{
					'id': row.NUM,
					'search': '/record/' + row.NUM,
					'name': row.ORG_NAME_FULL,
					'location': row.LOCATION,
					'description' : row.DESCRIPTION_SHORT,
					'address': row.SITE_ADDRESS,
					'email': row.EMAIL,
					'web': row.WEB,
					'officephone': textToHTML(row.OFFICE_PHONE),
					'hours': textToHTML(row.HOURS),
				} for row in results]

@view_config(route_name='jsonfeeds_cictaxonomy', renderer='json')
class JsonFeedsCicTaxRecords(BaseFeedView):
	schema = TaxCodeAPISchema
	stored_proc = 'dbo.sp_CIC_SpecificTax_Feed'
	extra_args = ['code','location','servicearea']

	def process_results(self, results):
		return	[{
					'id': row.NUM,
					'search': '/record/' + row.NUM,
					'name': row.ORG_NAME_FULL,
					'location': row.LOCATION,
					'description' : row.DESCRIPTION_SHORT,
					'address': row.SITE_ADDRESS,
					'email': row.EMAIL,
					'web': row.WEB,
					'officephone': textToHTML(row.OFFICE_PHONE),
					'hours': textToHTML(row.HOURS),
				} for row in results]
