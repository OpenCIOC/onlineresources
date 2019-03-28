# =========================================================================================
#  Copyright 2018 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
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

import argparse
import pprint
import json
import time
import string
from collections import namedtuple
from cStringIO import StringIO
import os
import sys
import traceback
import urllib
from collections import OrderedDict
from datetime import datetime

import isodate

CREATE_NO_WINDOW = 0x08000000
creationflags = 0

import requests
from lxml import etree as ET

try:
	import cioc  # NOQA
except ImportError:
	sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from tools.toolslib import Context

from cioc.core import constants as const  # , email


const.update_cache_values()
XS = 'http://www.w3.org/2001/XMLSchema'
XSD = '{' + XS + '}'
_time_format = '%Y%m%dT%H%M%S'
_fname_formats = {
	'full': 'Full{now}{file_suffix}.zip',
	'part': 'IncrementalFrom{previous}To{now}{file_suffix}.zip',
}
SchemaError = namedtuple('SchemaError', 'line column message')
LangSetting = namedtuple('LangSetting', 'culture file_suffix language_name')


_lang_settings = {
	'en-CA': LangSetting('en-CA', '', 'English'),
	'fr-CA': LangSetting('fr-CA', '_frCA', 'French')
}


_date_pattern = '????????T??????'


class FileWriteDetector(object):

	def __init__(self, obj):
		self.__obj = obj
		self.__dirty = False

	def is_dirty(self):
		return self.__dirty

	def write(self, string):
		self.__dirty = True
		return self.__obj.write(string)

	def __getattr__(self, key):
		return getattr(self.__obj, key)


class DEFAULT(object):
	pass


def get_config_item(args, key, default=DEFAULT):
	config_prefix = args.config_prefix
	config = args.config
	if default is DEFAULT:
		return config.get(config_prefix + key, config[key])

	return args.config.get(config_prefix + key, config.get(key, default))


def prepare_session(args):
	session = requests.Session()
	session.headers.update({
		'Authorization': 'Bearer ' + get_config_item(args, 'icarol_api_key', ''),
		'Accept': 'application/json'
	})
	args.session = session
	args.host = get_config_item(args, 'icarol_api_host')


def parse_args(argv):
	parser = argparse.ArgumentParser()
	parser.add_argument('--config', dest='configfile', action='store',
						default=const._config_file)
	parser.add_argument('--test', dest='test', action='store_const', const=True, default=False)
	parser.add_argument('--email', dest='email', action='store_const', const=True, default=False)
	parser.add_argument('--config-prefix', dest='config_prefix', action='store', default='')
	parser.add_argument('--modified-since', dest='modified_since', action='store', default=None)
	parser.add_argument('--fetch-mechanism', dest='fetch_mechanism', action='store', default=None)

	args = parser.parse_args(argv)
	if args.config_prefix and not args.config_prefix.endswith('.'):
		args.config_prefix += '.'

	if args.modified_since:
		try:
			args.modified_since = isodate.parse_datetime(args.modified_since)
		except:
			parser.error('invalid date format must be like 2018-10-10T15:45:00')

	return args


def pager(iterable, page_size=10):
	page = []
	count = 0
	for x in iterable:
		count += 1
		page.append(x)
		if count >= page_size:
			yield page
			count = 0
			page = []

	if page:
		yield page


class fakerequest(object):
	def __init__(self, config):
		self.config = config

	class dboptions(object):
		TrainingMode = False
		NoEmail = False
		DefaultEmailCIC = None
		DefaultEmailVOL = None
		DefaultEmailNameCIC = None
		DefaultEmailNameVOL = None

	class pageinfo(object):
		DbArea = const.DM_CIC


def icarol_takeall(args, modifiedSince=None):
	url = 'https://' + args.host + '/v1/Resource/Search'
	params = {'term': '*', 'takeAll': True}

	if args.extra_criteria:
		params.update(args.extra_criteria)

	if modifiedSince:
		params['modifiedSince'] = modifiedSince.isoformat()

	if args.test:
		print url + '?' + urllib.urlencode(params)
	response = args.session.get(url, json=params)
	response.raise_for_status()
	return response.json(object_pairs_hook=OrderedDict)


def icarol_get_records(args, id):
	url = 'https://' + args.host + '/v1/Resource/'
	if not isinstance(id, list):
		id = [id]

	id_str = map(str, id)
	params = {'id': id_str}
	start = time.time()
	response = args.session.get(url, params=params)
	duration = time.time() - start
	if args.test:
		print 'requested {} records in {}s'.format(len(id), duration)
	response.raise_for_status()
	tmp = {x['id']: x for x in response.json(object_pairs_hook=OrderedDict)}
	result = [tmp[x] for x in id]
	return result


def fetch_records(args, record_ids):
	for page in pager(record_ids):
		for record in icarol_get_records(args, page):
			yield record


def _to_xml(obj, parent=None):
	if parent is None:
		parent = ET.Element('root')

	if isinstance(obj, dict):
		for key, value in obj.items():
			if not isinstance(key, basestring):
				key = unicode(key)

			if key[0] not in string.ascii_letters:
				key = 'k' + key

			sub = ET.SubElement(parent, key)
			_to_xml(value, sub)

		return parent

	if isinstance(obj, (list, tuple)):
		for value in obj:
			sub = ET.SubElement(parent, 'item')
			_to_xml(value, sub)

		return parent

	if obj is None:
		return parent

	parent.text = unicode(obj)
	return parent


def to_xml(obj):
	return ET.tostring(_to_xml(obj))


def fetch_from_icarol(context):
	records = icarol_takeall(context.args, context.args.modified_since)
	if context.args.test:
		records.sort(key=lambda x: x['modified'])
		records = records[-60:]
		pprint.pprint(records)
		return

	sql = u'''
	INSERT INTO CIC_iCarolImport (TakeAllJson, TakeAllXML, RecordJson, RecordXML)
	VALUES (?, ?, ?, ?)
	'''

	with context.connmgr.get_connection('admin') as conn:
		for record in zip(records, fetch_records(context.args, [x['id'] for x in records])):
			xml_0 = to_xml(record[0])
			xml_1 = to_xml(record[1])
			conn.execute(sql, json.dumps(record[0]), xml_0, json.dumps(record[1]), xml_1)


def check_db_state(context):
	context.args.extra_criteria = None
	if not context.args.fetch_mechanism:
		return

	sql = 'SELECT * FROM CIC_iCarolImportMeta WHERE Mechanism=?'
	with context.connmgr.get_connection('admin') as conn:
		meta_data = conn.execute(sql, context.args.fetch_mechanism).fetchone()

	if not meta_data:
		# XXX Should we do something to indicate to an operator that something is missing?
		return

	if meta_data.ExtraCriteria:
		context.args.extra_criteria = json.loads(meta_data.ExtraCriteria)

	context.args.modified_since = meta_data.LastFetched
	# XXX Should this be observed value instead of this
	context.args.next_modified_since = datetime.utcnow()


def update_db_state(context):
	if not context.args.fetch_mechanism:
		return

	sql = 'UPDATE CIC_iCarolImportMeta SET LastFetched=? WHERE Mechanism=?'
	with context.connmgr.get_connection('admin') as conn:
		conn.execute(sql, context.args.next_modified_since, context.args.fetch_mechanism)


def main(argv):
	args = parse_args(argv)
	context = Context(args)
	retval = 0
	try:
		args.config = context.config
	except Exception:
		sys.stderr.write('ERROR: Could not process config file:\n')
		sys.stderr.write(traceback.format_exc())
		return 1

	if args.email:
		if not get_config_item(args, 'airs_export_notify_emails', None):
			sys.stderr.write('ERROR: No value for airs_export_notify_emails set in config\n')
			return 1
		else:
			sys.stdout = StringIO()
			sys.stderr = sys.stdout

	sys.stderr = FileWriteDetector(sys.stderr)

	prepare_session(args)
	check_db_state(context)

	fetch_from_icarol(context)

	update_db_state(args)

	if sys.stderr.is_dirty():
		retval = 1

	return retval


if __name__ == '__main__':
	normalstdout = sys.stdout
	normalstderr = sys.stderr
	try:
		sys.exit(main(sys.argv[1:]))
	except Exception:
		sys.stdout = normalstdout
		sys.stderr = normalstderr

		raise
