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


import os
import logging
from cStringIO import StringIO
from zipfile import ZipFile

from pyramid.view import view_config, view_defaults
from lxml import etree

from cioc.core import validators as validators, i18n
from cioc.web.admin.viewbase import AdminViewBase

_ = i18n.gettext

log = logging.getLogger(__name__)

templateprefix = 'cioc.web.import_:templates/community/'


def get_xmlschema(filename):

	schema_path = os.path.join('..', 'import', filename)
	schema_doc = etree.parse(schema_path)

	return etree.XMLSchema(schema_doc)


def get_community_args(data, document):
	# NOTE also update self.sql below for the correct number of args
	return [data, document.getroot().get('source')]


def get_community_map_args(data, document):
	root = document.getroot()
	# NOTE also update self.sql below for the correct number of args
	return [data] + [root.get(x) for x in ['SystemCode', 'SystemName', 'CopyrightHolder1', 'CopyrightHolder2', 'ContactEmail']]


class UploadSchema(validators.RootSchema):
	ImportFile = validators.FieldStorageUploadConverter(not_empty=True)


@view_defaults(renderer=templateprefix + 'index.mak')
class CommunityUpload(AdminViewBase):

	def __init__(self, request):
		AdminViewBase.__init__(self, request)

		mapping = self.mapping = request.matched_route.name == 'import_community_map'
		if mapping:
			# NOTE next line must match number of args in get_community_map_args()
			self.sql = 'EXEC sp_GBL_Community_External_u_Import ?, ?, ?, ?, ?, ?'
			self.get_sql_args = get_community_map_args
			self.schemafile = None
			self.title = _('Upload External Community File', request)
		else:
			# NOTE next line must match number of args in get_community_args()
			self.sql = 'EXEC sp_GBL_Community_u_Import ?, ?'
			self.get_sql_args = get_community_args
			self.schemafile = 'cioc_community_schema.xsd'
			self.title = _('Upload Community File', request)

	@view_config(route_name='import_community')
	@view_config(route_name='import_community_map')
	def index(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		title = self.title
		return self._create_response_namespace(title, title, {'title': title}, no_index=True)

	@view_config(route_name='import_community', request_method="POST")
	@view_config(route_name='import_community_map', request_method="POST")
	def upload(self):
		request = self.request
		user = self.request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		model_state = request.model_state
		model_state.schema = UploadSchema()

		title = self.title

		if not model_state.validate():
			return self._create_response_namespace(title, title, dict(title=title, ErrMsg=_('There were validation errors.', request)), no_index=True)

		data = model_state.form.data
		importfile = data['ImportFile']

		filename = importfile.filename
		file = importfile.file

		zipfile = None
		try:
			zipfile = ZipFile(file, 'r')
			files = zipfile.namelist()
			data = zipfile.read(files[0])
			zipfile.close()
			file.close()
		except Exception, e:
			file.seek(0)
			data = file.read()
			file.close()

		xmlfile = StringIO(data)

		error_log = []
		sqlargs = None
		community_doc = None
		validator = None
		if self.schemafile:
			validator = get_xmlschema(self.schemafile)

		try:
			community_doc = etree.parse(xmlfile)
			if validator and not validator.validate(community_doc):
				log.debug('Schema error: %s', validator.error_log)
				error_log.extend(_('Line %d, Column %d: %s', request) %
					(x.line, x.column, x.message)
					for x in validator.error_log)

			if not error_log:
				sqlargs = self.get_sql_args(data, community_doc)

		except etree.XMLSyntaxError, e:
			error_log.append(e.message)

		finally:
			community_doc = None
			validator = None

		unauthorized = []
		if not error_log and sqlargs:
			with request.connmgr.get_connection('admin') as conn:
				cursor = conn.execute(self.sql, sqlargs)

				result = cursor.fetchone()

				cursor.nextset()
				unauthorized = cursor.fetchall()

			if result.Error:
				error_log.append(result.ErrMsg)

		request.override_renderer = templateprefix + 'result.mak'

		return self._create_response_namespace(title, title,
				{'error_log': error_log, 'unauthorized': unauthorized,
				'filename': filename},
				no_index=True)
