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


import zipfile
import tempfile
import os
import json

from formencode import Schema, ForEach
from pyramid.view import view_config

from pyramid.response import Response

from cioc.core import i18n, validators as ciocvalidators
from cioc.core.webobfiletool import FileIterator
from cioc.web.cic import viewbase
from cioc.web.offline.auth import AuthFailure, verify_auth


import logging
log = logging.getLogger(__name__)

_ = i18n.gettext

mime_type = 'application/zip'


class PullSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True
	if_key_missing = None

	FromDate = ciocvalidators.ISODateConverter(if_missing=None, not_empty=False)


class Pull2Schema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True
	if_key_missing = None

	NewRecords = ForEach(ciocvalidators.NumValidator())
	NewFields = ForEach(ciocvalidators.IDValidator())


@view_config(route_name='offline_pull')
class Pull(viewbase.CicViewBase):

	def __call__(self):
		data, record_data = self._really_do_it()

		data = json.dumps(data)

		file = tempfile.TemporaryFile()
		zip = zipfile.ZipFile(file, 'w', zipfile.ZIP_DEFLATED)
		zip.writestr('export.json', data)

		if record_data:
			try:
				zip.write(record_data, 'record_data.xml')
			finally:
				try:
					os.unlink(record_data)
				except:
					pass

		zip.close()
		length = file.tell()
		file.seek(0)

		res = Response(content_type='application/zip', charset=None)
		res.app_iter = FileIterator(file)
		res.content_length = length

		res.headers['Content-Disposition'] = 'attachment;filename=Export.zip'
		return res

	def _really_do_it(self):
		request = self.request

		try:
			user_type = verify_auth(request)
		except AuthFailure, e:
			return e.result_info, None

		model_state = request.model_state

		model_state.schema = PullSchema()
		if not model_state.validate():
			# validation error
			return {'fail': True, 'reason': _('invalid request', request)}, None

		data = {}
		file = None
		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_GBL_BaseTable_History_Offline_s ?, ?',
						user_type.MachineID, model_state.value('FromDate'))

			for i, table in enumerate(['views', 'communities', 'publications',
							'view_publications', 'field_groups', 'fields',
							'fieldgroup_fields', 'users', 'records_views',
							'record_publications', 'record_communities']):
				if i:
					cursor.nextset()

				cols = [d[0] for d in cursor.description]
				data[table] = [dict(zip(cols, row)) for row in cursor.fetchall()]

			cursor.nextset()

			file = _get_record_data(cursor)

			cursor.close()

		return {'fail': False, 'data': data}, file


@view_config(route_name='offline_pull2')
class Pull2(viewbase.CicViewBase):

	def __call__(self):
		data, record_data = self._really_do_it()

		data = json.dumps(data)

		file = tempfile.TemporaryFile()
		zip = zipfile.ZipFile(file, 'w', zipfile.ZIP_DEFLATED)
		zip.writestr('export.json', data)

		if record_data:
			try:
				zip.write(record_data, 'record_data.xml')
			finally:
				try:
					os.unlink(record_data)
				except:
					pass

		zip.close()
		length = file.tell()
		file.seek(0)

		res = Response(content_type='application/zip', charset=None)
		res.app_iter = FileIterator(file)
		res.content_length = length

		res.headers['Content-Disposition'] = 'attachment;filename=Export.zip'
		return res

	def _really_do_it(self):
		request = self.request

		try:
			user_type = verify_auth(request)
		except AuthFailure, e:
			return e.result_info, None

		model_state = request.model_state
		model_state.schema = Pull2Schema()

		if not model_state.validate():
			# validation error
			log.debug('Failure')
			return {'fail': True, 'reason': _('invalid request', request)}, None

		new_fields = model_state.value('NewFields')
		if new_fields:
			new_fields = u','.join(unicode(x) for x in sorted(set(new_fields)))

		new_records = model_state.value('NewRecords')
		if new_records:
			new_records = u','.join(unicode(x).upper() for x in sorted(set(new_records)))

		data = {}
		log.debug('Machine id: %d', user_type.MachineID)
		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_GBL_BaseTable_History_Offline_s_NewItems ?, ?, ?',
						user_type.MachineID, new_records or None, new_fields or None)

			file = _get_record_data(cursor)

			cursor.close()

		log.debug('response')
		return {'fail': False, 'data': data}, file


def _get_record_data(cursor):

	fd, fname = tempfile.mkstemp()
	file = os.fdopen(fd, 'w+b')
	log.debug("file name: %s", file.name)

	file.write(u'<record_data>'.encode('utf-8'))
	cols = None
	while True:
		rows = cursor.fetchmany(20000)
		if not rows:
			break

		if not cols:
			cols = [d[0] for d in cursor.description]

		rows = u''.join(x[0] for x in rows)
		file.write(rows.encode('utf-8'))

	file.write(u'</record_data>'.encode('utf-8'))

	file.close()

	return fname
