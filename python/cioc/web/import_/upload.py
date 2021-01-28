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

# Copyright (c) 2003-2012 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
# ==================================================================

from __future__ import absolute_import
from __future__ import print_function
import os
import copy
import logging
from zipfile import ZipFile

from pyramid.view import view_config, view_defaults
from lxml import etree

from cioc.core import validators as validators, i18n, constants as const, viewbase

_ = i18n.gettext

log = logging.getLogger(__name__)

templateprefix = 'cioc.web.import_:templates/'

XSD = '{http://www.w3.org/2001/XMLSchema}'
CIOC_NS = '{urn:ciocshare-schema}'
CIOC_VOL_NS = '{urn:ciocshare-schema-vol}'
_xmlschema = None
_xmlschema_elements = None
_xmlschema_mtime = None


def get_xmlschema():
	global _xmlschema, _xmlschema_elements, _xmlschema_mtime
	schema_path = os.path.join(const._app_path, 'import', 'cioc_schema.xsd')
	mtime = os.path.getmtime(schema_path)

	if _xmlschema is None or mtime != _xmlschema_mtime:
		_xmlschema_elements = {}
		_xmlschema_mtime = mtime

		schema_doc = etree.parse(schema_path)

		for element in schema_doc.iterfind("/%(xsd)selement[@name='ROOT']/%(xsd)scomplexType/%(xsd)ssequence/%(xsd)selement" % {'xsd': XSD}):
			new_doc = copy.deepcopy(schema_doc)
			doc_root = new_doc.getroot()
			to_add = doc_root.find("./%(xsd)selement[@name='ROOT']/%(xsd)scomplexType/%(xsd)ssequence/%(xsd)selement[@name='%(name)s']" % {'xsd': XSD, 'name': element.attrib['name']})
			if 'minOccurs' in to_add.attrib:
				del to_add.attrib['minOccurs']

			if 'maxOccurs' in to_add.attrib:
				del to_add.attrib['maxOccurs']

			doc_root.append(to_add)
			doc_root.remove(doc_root.find("./%(xsd)selement[@name='ROOT']" % {'xsd': XSD}))
			_xmlschema_elements[CIOC_NS + element.attrib['name']] = etree.XMLSchema(new_doc)

		inner = etree.XML('''<xsd:complexType xmlns:xsd="http://www.w3.org/2001/XMLSchema">
					<xsd:sequence>
						<xsd:any namespace="##any" minOccurs="0" maxOccurs="unbounded" processContents="skip"/>
					</xsd:sequence>
					<xsd:anyAttribute namespace="##any" processContents="skip"/>
					</xsd:complexType>''')

		for element in schema_doc.iterfind("/%(xsd)selement[@name='ROOT']/%(xsd)scomplexType/%(xsd)ssequence/%(xsd)selement" % {'xsd': XSD}):
			element[:] = [copy.deepcopy(inner)]

		_xmlschema = etree.XMLSchema(schema_doc)

	return _xmlschema, _xmlschema_elements


class UploadSchema(validators.RootSchema):

	ImportFile = validators.FieldStorageUploadConverter(not_empty=True)
	DisplayName = validators.String(max=255, if_empty=None)


class Context(object):
	pass


@view_defaults(renderer=templateprefix + 'index.mak')
class UploadBase(viewbase.ViewBase):

	@view_config(route_name='import_upload')
	@view_config(route_name='import_upload_vol')
	def index(self):
		request = self.request
		user = request.user

		if not user.dom.ImportPermission:
			self._security_failure()

		title = _('Upload Import File', request)
		return self._create_response_namespace(title, title, {}, print_table=False, no_index=True)

	@view_config(route_name='import_upload', request_method="POST")
	@view_config(route_name='import_upload_vol', request_method="POST")
	def upload(self):
		request = self.request
		user = self.request.user

		if not user.dom.ImportPermission:
			self._security_failure()

		model_state = request.model_state
		model_state.schema = UploadSchema()

		title = _('Upload Import File', request)

		if not model_state.validate():
			return self._create_response_namespace(title, title, dict(ErrMsg=_('There were validation errors.', request)), print_table=False, no_index=True)

		data = model_state.form.data
		importfile = data['ImportFile']

		filename = importfile.filename
		xmlfile = file = importfile.file

		zipfile = None
		try:
			zipfile = ZipFile(file, 'r')
			files = zipfile.namelist()
			xmlfile = zipfile.open(files[0], 'r')
		except Exception:
			file.seek(0)
			xmlfile = file

		error_log, total_inserted = process_import(
			filename, xmlfile, request.dboptions.MemberID,
			request.pageinfo.Domain, request.pageinfo.DbAreaS, user.Mod,
			data.get('DisplayName'), request.connmgr, lambda x: _(x, request))
		xmlfile.close()

		if zipfile:
			zipfile.close()
			file.close()

		request.override_renderer = templateprefix + 'result.mak'

		return self._create_response_namespace(title, title,
				{'error_log': error_log, 'total_inserted': total_inserted,
				'filename': filename},
				print_table=False, no_index=True)


def process_import(filename, xmlfile, member_id, domain, domain_str, user_mod, display_name, connmgr, _):
	error_log = []
	xmlschema, element_schemas = get_xmlschema()

	self = Context()
	self.made_field_list = False
	self.total_inserted = 0
	self.source_db_code = None

	log.debug('domain: %d', domain)
	# domain = request.pageinfo.Domain
	# domain_str = request.pageinfo.DbAreaS
	if domain == const.DM_CIC:
		handlers = _xml_handlers
		id_column = 'NUM'
	else:
		handlers = _xml_handlers_vol
		id_column = 'VNUM'

	with connmgr.get_connection('admin') as conn:

		EFID = conn.execute('''
				DECLARE @EF_ID int
				EXEC dbo.sp_%s_ImportEntry_i ?,?,?,?, @EF_ID OUTPUT
				SELECT @EF_ID''' % domain_str, member_id, user_mod, filename, display_name).fetchone()[0]

		root = None
		try:
			for event, element in etree.iterparse(xmlfile):
				if root is None:
					root = element.getroottree().getroot()

				if element.getparent() != root:
					continue

				if domain == const.DM_CIC:
					validator = element_schemas.get(element.tag)
					if not validator:
						error_log.append((None, _('Warning: unexpected element %s at line %d') %
								(element.tag[len(CIOC_NS):], element.sourceline)))
						continue

					if not validator.validate(element):
						log.debug('Schema error: %s', validator.error_log)
						errmsg = _('Line %d, Column %d: %s')
						error_log.extend((element.get(id_column), errmsg % (x.line, x.column, x.message.replace(CIOC_NS, ''))) for x in validator.error_log)

						continue
				handler = handlers.get(element.tag)
				if handler:
					handler(self, element, conn, EFID, domain_str)

				element.clear()
		except etree.XMLSyntaxError as e:
			error_log.append((None, e.message))

		root = None
		element = None

	return error_log, self.total_inserted


def _handle_record(self, element, conn, EFID, dm, id_column='NUM'):
	num = element.get(id_column)
	record_owner = element.get('RECORD_OWNER')
	has_english = element.get('HAS_ENGLISH') == '1'
	has_french = element.get('HAS_FRENCH') == '1'
	privacy_profile = element.get('PRIVACY_PROFILE')

	non_public = element.find(CIOC_NS + 'NON_PUBLIC')
	non_public_e = non_public_f = None
	if non_public is not None:
		non_public_e = non_public.get('V')
		if non_public_e:
			non_public_e = non_public_e == '1'

		non_public_f = non_public.get('VF')
		if non_public_f:
			non_public_f = non_public_f == '1'

	deletion_date = element.find(CIOC_NS + 'DELETION_DATE')
	deletion_date_e = deletion_date_f = None
	if deletion_date is not None:
		deletion_date_e = deletion_date.get('V')
		deletion_date_f = deletion_date.get('VF')

	xml = etree.tostring(element).replace(b'xmlns="urn:ciocshare-schema" ', b'', 1).replace(b'xmlns="urn:ciocshare-schema-vol" ', b'', 1)
	xml = xml.decode('utf-8')

	if not self.made_field_list:
		cursor = conn.cursor()
		cursor.executemany('EXEC dbo.sp_%s_ImportEntry_Field_i ?,%d' % (dm, EFID),
			[(id_column,), ('RECORD_OWNER',)] + [(e.tag[len(CIOC_NS):],) for e in element])

		self.made_field_list = True
		cursor.close()

	ERID = conn.execute('''
				DECLARE @ER_ID int
				EXEC dbo.sp_%s_ImportEntry_Data_i ?, ?, ?, ?, ?, ?, @ER_ID OUTPUT
				SELECT @ER_ID''' % dm, EFID, num, record_owner, privacy_profile, self.source_db_code, xml).fetchone()
	if ERID:
		ERID = ERID[0]

	if ERID:
		conn.execute('EXEC dbo.sp_%s_ImportEntry_Data_Language_i ?, ?, ?, ?, ?, ?, ?' % dm, ERID, has_english, has_french, non_public_e, non_public_f, deletion_date_e, deletion_date_f)
	else:
		print('NO ERID, so NO Language import')

	self.total_inserted += 1


def _handle_source_db(self, element, conn, EFID, dm):
	self.source_db_code = element.get('CD')
	attrs = ['NM', 'NMF', 'URL', 'URLF', 'CD']
	args = [element.get(x) for x in attrs]
	conn.execute('EXEC dbo.sp_CIC_ImportEntry_u_Source ?,?,?,?,?,?', EFID, *args)


def _handle_dist_code_list(self, element, conn, EFID, dm):
	_handle_code_list(self, element, conn, EFID, 'Dist', dm)


def _handle_pub_code_list(self, element, conn, EFID, dm):
	_handle_code_list(self, element, conn, EFID, 'Pub', dm)


def _handle_code_list(self, element, conn, EFID, cd, dm):
	codes = [(e.get('V'), EFID) for e in element]
	if codes:
		cursor = conn.cursor()
		cursor.executemany('EXEC dbo.sp_CIC_ImportEntry_' + cd + '_i ?, ?', codes)
		cursor.close()


def _privacy_profile_name_xml(element):
	root = etree.Element('DESCS')
	for culture, attr in [('en-CA', 'V'), ('fr-CA', 'VF')]:
		val = element.get(attr)
		if not val:
			continue
		desc = etree.SubElement(root, 'DESC')
		etree.SubElement(desc, 'Culture').text = culture
		etree.SubElement(desc, 'ProfileName').text = val

	return etree.tostring(root)


def _handle_privacy_profile_list(self, element, conn, EFID, dm):
	rows = [(_privacy_profile_name_xml(e), ','.join(x.get('V') for x in e), EFID) for e in element]
	if rows:
		cursor = conn.cursor()
		cursor.executemany('EXEC dbo.sp_CIC_ImportEntry_Priv_i ?,?,?',
					rows)
		cursor.close()

_xml_handlers = {
CIOC_NS + 'RECORD': _handle_record,
CIOC_NS + 'SOURCE_DB': _handle_source_db,
CIOC_NS + 'DIST_CODE_LIST': _handle_dist_code_list,
CIOC_NS + 'PUB_CODE_LIST': _handle_pub_code_list,
CIOC_NS + 'PRIVACY_PROFILE_LIST': _handle_privacy_profile_list
}


def _handle_vol_record(*args):
	return _handle_record(id_column='VNUM', *args)

_xml_handlers_vol = {
CIOC_VOL_NS + 'RECORD': _handle_vol_record,
# CIOC_VOL_NS + 'SOURCE_DB': _handle_source_db,
# CIOC_VOL_NS + 'DIST_CODE_LIST': _handle_dist_code_list,
# CIOC_VOL_NS + 'PUB_CODE_LIST': _handle_pub_code_list,
# CIOC_VOL_NS + 'PRIVACY_PROFILE_LIST': _handle_privacy_profile_list
}
