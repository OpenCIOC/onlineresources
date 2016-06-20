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


import itertools
import tempfile
from xml.sax.saxutils import quoteattr
from xml.etree import cElementTree as ET
import zipfile

from pyramid.response import Response
from pyramid.httpexceptions import HTTPUnauthorized, HTTPInternalServerError
from pyramid.view import view_config

from cioc.core import bufferedzip, i18n, modelstate, validators
from cioc.core.utf8csv import write_csv_to_zip
from cioc.core.webobfiletool import FileIterator
from cioc.web.cic import viewbase


import logging
log = logging.getLogger(__name__)

_ = i18n.gettext


def make_headers(extra_headers=None):
	tmp = dict(extra_headers or {})
	return tmp


def make_401_error(message, realm='AIRS Export'):
	error = HTTPUnauthorized(headers=make_headers({'WWW-Authenticate': 'Basic realm="%s"' % realm}))
	error.content_type = "text/plain"
	error.text = message
	return error


def make_internal_server_error(message):
	error = HTTPInternalServerError()
	error.content_type = "text/plain"
	error.text = message
	return error


class AIRSExportOptionsSchema(validators.RootSchema):
	allow_extra_fields = True
	if_key_missing = None

	version = validators.OneOf(["3_1", "3_0", "3_0_Testing"], if_empty="3_0")
	DST = validators.UnicodeString(max=20, not_empty=True)
	IncludeDeleted = validators.Bool()
	IncludeSiteAgency = validators.Bool()
	PartialDate = validators.ISODateConverter()
	PubCodeSync = validators.Bool()
	FileSuffix = validators.String(max=100)


@view_config(route_name='export_airs')
class AIRSExport(viewbase.CicViewBase):

	def __call__(self):
		request = self.request
		user = request.user

		if not user:
			return make_401_error(u'Access Denied')

		if 'airsexport' not in user.cic.ExternalAPIs:
			return make_401_error(u'Insufficient Permissions')

		model_state = modelstate.ModelState(request)
		model_state.schema = AIRSExportOptionsSchema()
		model_state.form.method = None

		if not model_state.validate():
			if model_state.is_error('DST'):
				msg = u"Invalid Distribution"
			elif model_state.is_error("version"):
				msg = u"Invalid Version"
			else:
				msg = u"An unknown error occurred."

				log.error('AIRS Export Errors: %s: %s', msg, model_state.form.errors)
			return make_internal_server_error(msg)

		res = Response(content_type='application/zip', charset=None)
		res.app_iter, res.length = _zip_stream(request, model_state)

		res.headers['Content-Disposition'] = 'attachment;filename=Export.zip'
		return res


def _zip_stream(request, model_state):
	sql = '''EXEC sp_GBL_AIRS_Export_%s ?, @@LANGID, ?, ?, ?, ?, ?'''

	values = [
		request.viewdata.cic.ViewType,
		model_state.value('DST'),
		model_state.value('PubCodeSync'),
		model_state.value('PartialDate'),
		model_state.value('IncludeDeleted'),
		model_state.value('IncludeSiteAgency')
	]
	log.debug('query values: %s', values)

	file = tempfile.TemporaryFile()
	with bufferedzip.BufferedZipFile(file, 'w', zipfile.ZIP_DEFLATED) as zip:
		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute(
				sql % model_state.value('version'),
				*values
			)
			root_parameters = cursor.fetchone()

			cursor.nextset()

			_get_record_data(
				root_parameters, cursor, zip,
				'export%s.xml' % (model_state.value('FileSuffix') or ''))

			cursor.close()

	length = file.tell()
	file.seek(0)

	return FileIterator(file), length


def _get_record_data(root_parameters, cursor, zipfile, fname):
	names = [t[0] for t in root_parameters.cursor_description]
	values = [quoteattr(unicode(x) if x is not None else u'') for x in root_parameters]
	root_parameters = u' '.join(u'='.join(x) for x in zip(names, values))

	with tempfile.TemporaryFile() as file:
		file.write(u'<?xml version="1.0" encoding="UTF-8"?>\n'.encode('utf-8'))
		file.write((u'<Source %s>\n' % root_parameters).encode('utf-8'))
		while True:
			rows = cursor.fetchmany(2000)
			if not rows:
				break

			rows = u'\n'.join(x[0] for x in rows) + u'\n'
			file.write(rows.encode('utf-8'))

		file.write(u'</Source>\n'.encode('utf-8'))

		file.seek(0)
		zipfile.writebuffer(file, fname)


@view_config(route_name='export_airs', request_method='POST', renderer='string')
class AIRSExportUpdateCount(viewbase.CicViewBase):

	def __call__(self):
		request = self.request
		user = request.user
		passvars = request.passvars  # noqa

		if not user:
			return make_401_error(u'Access Denied')

		if 'airsexport' not in user.cic.ExternalAPIs:
			return make_401_error(u'Insufficient Permissions')

		model_state = modelstate.ModelState(request)
		model_state.schema = AIRSExportOptionsSchema(Field=validators.String(max=10, not_empty=True))
		model_state.form.method = None

		# I don't think that version is relevant, just ignore it
		del model_state.schema.fields['version']
		del model_state.schema.fields['DST']
		del model_state.schema.fields['PartialDate']
		del model_state.schema.fields['IncludeDeleted']
		del model_state.schema.fields['IncludeSiteAgency']

		if not model_state.validate():
			if model_state.is_error('Field'):
				msg = u'Invalid Field'
			else:
				msg = u"An unknown error occurred."

			return make_internal_server_error(msg)

		try:
			data = request.json_body
		except:
			return make_internal_server_error(u'Error getting request body as JSON')

		counts = ET.Element('root')
		for num, count in data['counts'].iteritems():
			ET.SubElement(counts, 'row', {'num': num, 'count': unicode(count)})

		sent = ET.Element('sent')
		for num in data['sent']:
			ET.SubElement(sent, 'row', {'num': num})

		field = 'EXTRA_' + model_state.value('Field').upper() + 'FILECOUNT'
		datefield = 'EXTRA_DATE_' + model_state.value('Field').upper() + 'LASTSENT'
		if request.language.Culture != 'en-CA':
			datefield += request.language.Culture.split('-')[0].upper()

		log.debug('Date Field: %s %s', datefield, request.language.Culture)

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute(
				'''
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int

				EXEC @RC = sp_GBL_AIRS_Export_u_Counts ?, @@LANGID, ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT
				SELECT @RC AS [Return], @ErrMsg AS ErrMsg
				''',
				request.viewdata.cic.ViewType,
				field,
				datefield,
				ET.tostring(counts, 'utf-8'),
				ET.tostring(sent, 'utf-8'),
			)
			result = cursor.fetchone()
			if result.Return:
				log.debug('Error: %s', result.ErrMsg)
				return make_internal_server_error(_('Unable to save: ') + result.ErrMsg)

		response = request.response
		response.content_type = 'text/plain'
		return 'success'


@view_config(route_name='export_airs_full_list', renderer='string')
class AIRSExportFullList(viewbase.CicViewBase):

	def __call__(self):
		request = self.request
		user = request.user

		if not user:
			return make_401_error(u'Access Denied')

		if 'airsexport' not in user.cic.ExternalAPIs:
			return make_401_error(u'Insufficient Permissions')

		model_state = modelstate.ModelState(request)
		model_state.schema = AIRSExportOptionsSchema()
		model_state.form.method = None
		log.debug('full list')

		# I don't think that version is relevant, just ignore it
		del model_state.schema.fields['version']

		if not model_state.validate():
			if model_state.is_error('DST'):
				msg = u"Invalid Distribution"
			elif model_state.is_error('Field'):
				msg = u'Invalid Field'
			else:
				msg = u"An unknown error occurred."

			return make_internal_server_error(msg)

		sql = '''EXEC sp_GBL_AIRS_Export_FullList ?, @@LANGID, ?, ?, ?, ?'''

		values = [
			request.viewdata.cic.ViewType,
			model_state.value('DST'),
			model_state.value('PubCodeSync'),
			model_state.value('IncludeDeleted'),
			model_state.value('IncludeSiteAgency')
		]
		log.debug('full list: %s', values)
		file = tempfile.TemporaryFile()
		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute(
				sql, values
			)

			def row_group_iterable():
				yield [[u'Record NUM', u'Parent NUM', u'Record Type']]
				while True:
					rows = cursor.fetchmany(2000)
					if not rows:
						break
					yield itertools.imap(lambda x: tuple(y or u'' for y in x), rows)

			with bufferedzip.BufferedZipFile(file, 'w', zipfile.ZIP_DEFLATED) as zip:
				write_csv_to_zip(
					zip, itertools.chain.from_iterable(row_group_iterable()),
					'records%s.csv' % (model_state.value('FileSuffix') or ''))

		response = request.response
		response.content_type = 'application/zip'

		length = file.tell()
		file.seek(0)
		res = request.response
		res.content_type = 'application/zip'
		res.charset = None
		res.app_iter = FileIterator(file)
		res.content_length = length
		res.headers['Content-Disposition'] = 'attachment;filename=records%s.zip' % (model_state.value('FileSuffix') or '')
		return res
