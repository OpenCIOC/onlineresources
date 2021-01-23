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
import codecs

from pyramid.response import Response
from pyramid.view import view_config
from pyramid.httpexceptions import HTTPUnauthorized, HTTPInternalServerError

import lxml.etree as ET
import isodate

from cioc.core import i18n
#from cioc.core.webobfiletool import FileIterator
from cioc.web.cic import viewbase

_ = i18n.gettext

default_error_headers = {}  # 'Content-Type': 'text/plain'}


def make_headers(extra_headers=None):
	tmp = dict(extra_headers or {})
	return tmp


def make_401_error(message, realm_suffix='Update'):
	error = HTTPUnauthorized(headers=make_headers({'WWW-Authenticate': 'Basic realm="CLBC %s"' % realm_suffix}))
	error.content_type = "text/plain"
	error.text = message
	return error


def make_internal_server_error(message):
	error = HTTPInternalServerError()
	error.content_type = "text/plain"
	error.text = message
	return error


@view_config(route_name='special_clbcupdate')
class ClbcUpdate(viewbase.CicViewBase):

	def __call__(self):
		request = self.request
		user = request.user

		# NOTE if an error returns before input is fully read apache will throw a fit

		if not user:
			request.body_file.read()  # read input for apache
			return make_401_error(u'Authentication Required')

		if 'clbcupdate' not in user.cic.ExternalAPIs:
			request.body_file.read()  # read input for apache
			return make_401_error(u'Insufficient Permissions')

		content_type = request.content_type
		if content_type != 'text/xml':
			request.body_file.read()  # read input for apache
			return make_internal_server_error(u'Unexpected Content-Type')

		encoding = request.charset or 'latin1'

		try:
			encoding = codecs.lookup(encoding)
		except LookupError:
			request.body_file.read()  # read input for apache
			return make_internal_server_error(u'Unexpected Encoding')

		# NOTE if an error returns before here and input is not fully read, apache will throw a fit

		intree = ET.parse(request.body_file, ET.XMLParser(encoding=encoding.name))
		inroot = intree.getroot()

		outxmlroot = ET.Element('VendorTransactionResponses', SessionID=inroot.get('SessionID'))

		try:
			with request.connmgr.get_connection('admin') as conn:
				conn.autocommit = False
				# next sql statement will create the transaction and exit the with
				# statement either rolls it back or commits it based on whether
				# there was an exception

				process_transactions(conn, inroot, outxmlroot, user.Mod)

		except HTTPInternalServerError as e:
			return e

		# Transaction committed and connection closed

		res = Response(content_type='text/xml', charset=encoding.name)
		res.body = ET.tostring(outxmlroot, encoding=encoding.name)

		return res

_methods = {}


def vendor_method(name):
	def inner(fn):
		_methods[name] = fn
		return fn

	return inner


def get_vendor(conn, rsn, name_suffix):
	vendor = conn.execute('SELECT CAST(Vendor AS nvarchar(max)) AS Vendor FROM CLBC_VENDOR_EXPORT WHERE RSN=?', rsn).fetchone()

	return ET.fromstring((u'<Vendor%(suffix)s%(xml)s%(suffix)s>' % {'suffix': name_suffix, 'xml': vendor[0].strip()[7:-1]}).encode('utf-8'))


def process_transactions(conn, inxml, outxml, user_name):
	for trans in inxml.iterfind('.//VendorTransaction'):
		action = trans[0]

		try:
			method = _methods[action.tag]
		except KeyError:
			raise make_internal_server_error(u'Attempt to update unknown transaction type: ' + action.tag)

		rsn = action.get('VendorID')
		try:
			rsn = int(rsn, 10)
		except ValueError:
			continue

		if not validate(conn, action, rsn, user_name):
			continue

		outtrans = ET.SubElement(outxml, u'VendorTransactionResponse', TransactionID=trans.get('TransactionID'))

		outtrans.append(trans)
		outtrans.append(get_vendor(conn, rsn, u'Before'))

		method(conn, action, rsn, user_name)

		outtrans.append(get_vendor(conn, rsn, u'After'))


def get_addr_id(action):
	addr_id = action.get('AddressID')
	if addr_id is not None:
		addr_id = int(addr_id, 10)

	return addr_id


def get_casconfirmdate(action):
	value = action.get('CASConfirmDate')
	if not value:
		raise make_internal_server_error(u'Missing Attribute: CASConfirmDate')

	if 'T' in value:
		return isodate.parse_datetime(value)
	else:
		return isodate.parse_date(value)


def validate(conn, action, rsn, user_name):
	addr_id = get_addr_id(action)
	result = conn.execute(_sql_validate, rsn, user_name, addr_id).fetchone()

	return False if not result else result[0]


@vendor_method('VendorMatchTransaction')
def _vendor_match(conn, action, rsn, user_name):

	value = get_casconfirmdate(action)

	conn.execute(_sql_vendor_match, rsn, user_name, value).close()


@vendor_method('VendorAddressMatchTransaction')
def _vendor_address_match(conn, action, rsn, user_name):
	value = get_casconfirmdate(action)
	addr_id = get_addr_id(action)
	if not addr_id:
		raise make_internal_server_error(u'Missing Attribute: AddressID')

	conn.execute(_sql_vendor_address_match, rsn, user_name, addr_id, value).close()


@vendor_method('VendorNameUpdateTransaction')
def _vendor_name_update(conn, action, rsn, user_name):
	value = action.get('LegalName')

	if not value:
		raise make_internal_server_error(u'Missing Attribute: LegalName')

	conn.execute(_sql_vendor_name_update, rsn, user_name, value).close()


@vendor_method('VendorAddressUpdateTransaction')
def _vendor_address_update(conn, action, rsn, user_name):
	args = [
		action.get(x) for x in [
			'Line1', 'Line2', 'Line3', 'Line4',
			'City', 'Province', 'Country', 'PostalCode'
		]
	]

	addr_id = get_addr_id(action)
	if not addr_id:
		raise make_internal_server_error(u'Missing Attribute: AddressID')

	conn.execute(_sql_vendor_address_update, rsn, user_name, addr_id, *args).close()


# SQL Strings below here

_sql_prefix = '''
	DECLARE @NUM varchar(8),
			@RSN int,
			@MODIFIED_BY varchar(200),
			@MODIFIED_DATE datetime;
			SET @RSN = ?;
			SET @MODIFIED_BY = ?
			SET @MODIFIED_DATE = GETDATE();
			SELECT @NUM=NUM FROM GBL_BaseTable WHERE RSN=@RSN;
			'''
_sql_validate = _sql_prefix + '''
			DECLARE @BADDR_ID int;
			SET @BADDR_ID = ?
			IF @BADDR_ID IS NOT NULL BEGIN
				SELECT HAS_RECORD=CAST(CASE WHEN EXISTS(SELECT * FROM GBL_BT_BILLINGADDRESS WHERE NUM=@NUM AND BADDR_ID=@BADDR_ID) THEN 1 ELSE 0 END AS bit)
			END ELSE BEGIN
				SELECT HAS_RECORD=CAST(CASE WHEN @NUM IS NOT NULL THEN 1 ELSE 0 END as bit)
			END'''


_sql_vendor_match = _sql_prefix + '''
			DECLARE @Value smalldatetime;
			SET @Value = ?
			IF NOT EXISTS(SELECT * FROM CIC_BT_EXTRA_DATE WHERE FieldName='EXTRA_DATE_B' AND NUM=@NUM) BEGIN
				INSERT INTO CIC_BT_EXTRA_DATE (FieldName, NUM, Value) VALUES ('EXTRA_DATE_B', @NUM, @Value)
			END ELSE BEGIN
				UPDATE CIC_BT_EXTRA_DATE SET Value=@Value WHERE FieldName='EXTRA_DATE_B' AND NUM=@NUM
			END
			UPDATE CIC_BaseTable SET MODIFIED_BY=@MODIFIED_BY,MODIFIED_DATE=@MODIFIED_DATE WHERE NUM=@NUM
			EXEC sp_GBL_BaseTable_History_i @MODIFIED_BY, @MODIFIED_DATE, @NUM, 'EXTRA_DATE_B', 1, 0'''

_sql_vendor_address_match = _sql_prefix + '''
			DECLARE @BADDR_ID int
			DECLARE @Value smalldatetime;
			SET @BADDR_ID = ?
			SET @Value = ?
			UPDATE GBL_BT_BILLINGADDRESS SET CAS_CONFIRMATION_DATE=@Value WHERE NUM=@NUM AND BADDR_ID=@BADDR_ID
			UPDATE GBL_BaseTable_Description SET MODIFIED_BY=@MODIFIED_BY,MODIFIED_DATE=@MODIFIED_DATE WHERE NUM=@NUM AND LangID=0
			EXEC sp_GBL_BaseTable_History_i @MODIFIED_BY, @MODIFIED_DATE, @NUM, 'BILLING_ADDRESSES', 1, 0'''

_sql_vendor_name_update = _sql_prefix + '''
			DECLARE @Value nvarchar(200);
			SET @Value = ?
			DECLARE @OldOrgLevel1 varchar(200); SELECT @OldOrgLevel1=ORG_LEVEL_1 FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=0
			DECLARE @OLD_NUMS TABLE(NUM varchar(8));
			INSERT INTO @OLD_NUMS (NUM)
				SELECT NUM FROM GBL_BaseTable_Description btd
				WHERE ORG_LEVEL_1=@OldOrgLevel1
				AND EXISTS(SELECT * FROM CIC_BaseTable cbt INNER JOIN CIC_RecordType rt ON cbt.RECORD_TYPE = rt.RT_ID AND rt.RecordType='L' AND btd.NUM=cbt.NUM)
			UPDATE GBL_BaseTable_Description SET ORG_LEVEL_1=@Value,MODIFIED_BY=@MODIFIED_BY,MODIFIED_DATE=@MODIFIED_DATE WHERE NUM=@NUM AND LangID=0
			UPDATE GBL_BaseTable_Description SET ORG_LEVEL_1=@Value,MODIFIED_BY=@MODIFIED_BY,MODIFIED_DATE=@MODIFIED_DATE WHERE EXISTS(SELECT * FROM @OLD_NUMS old WHERE GBL_BaseTable_Description.NUM=old.NUM)
			EXEC sp_GBL_BaseTable_History_i @MODIFIED_BY, @MODIFIED_DATE, @NUM, 'ORG_LEEL_1', 1, 0
			DECLARE @UPD_NUM varchar(8); DECLARE cur CURSOR LOCAL FOR SELECT NUM FROM @OLD_NUMS;
			OPEN cur; fetch next from cur into @UPD_NUM; WHILE @@FETCH_STATUS=0 BEGIN;
				EXEC sp_GBL_BaseTable_History_i @MODIFIED_BY, @MODIFIED_DATE, @UPD_NUM, 'ORG_LEVEL_1', 1, 0;
				fetch next from cur into @UPD_NUM
			END\n CLOSE cur\n deallocate cur;
			'''

_sql_vendor_address_update = _sql_prefix + '''
			DECLARE @BADDR_ID int,
					@Line1 nvarchar(200),
					@Line2 nvarchar(200),
					@Line3 nvarchar(200),
					@Line4 nvarchar(200),
					@City nvarchar(100),
					@Province varchar(2),
					@Country nvarchar(60),
					@PostalCode varchar(20)
			SET @BADDR_ID = ?
			SET @Line1 = ?
			SET @Line2 = ?
			SET @Line3 = ?
			SET @Line4 = ?
			SET @City = ?
			SET @Province = ?
			SET @Country = ?
			SET @PostalCode = ?

			UPDATE GBL_BT_BILLINGADDRESS SET
				LINE_1=@Line1,
				LINE_2=@Line2,
				LINE_3=@Line3,
				LINE_4=@Line4,
				CITY=@City,
				PROVINCE=@Province,
				COUNTRY=@Country,
				POSTAL_CODE=@PostalCode
			WHERE NUM=@NUM AND BADDR_ID=@BADDR_ID
			UPDATE GBL_BaseTable_Description SET MODIFIED_BY=@MODIFIED_BY,MODIFIED_DATE=@MODIFIED_DATE WHERE NUM=@NUM AND LangID=0
			EXEC sp_GBL_BaseTable_History_i @MODIFIED_BY, @MODIFIED_DATE, @NUM, 'BILLING_ADDRESSES', 1, 0
			'''
