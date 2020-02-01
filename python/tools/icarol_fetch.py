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
import re
from Queue import Queue
from collections import namedtuple
from cStringIO import StringIO
import os
import sys
import traceback
import urllib
from collections import OrderedDict
from datetime import datetime
from threading import Thread

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
from cioc.core import syslanguage


invalid_xml_chars = re.compile(u'[\x00-\x08\x0c\x0e-\x19]')

const.update_cache_values()
_time_format = '%Y-%m-%d %H:%M:%S'
LangSetting = namedtuple('LangSetting', 'culture file_suffix language_name sql_language')

_lang_settings = {
	'en-CA': LangSetting('en-CA', '', 'en', syslanguage.SQLALIAS_ENGLISH),
	'fr-CA': LangSetting('fr-CA', '_frCA', 'fr', syslanguage.SQLALIAS_FRENCH)
}


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
		'Accept': 'application/json'
	})
	args.session = session
	args.host = get_config_item(args, 'o211_import_api_host')
	args.key = get_config_item(args, 'o211_import_api_key', '')


def parse_args(argv):
	parser = argparse.ArgumentParser()
	parser.add_argument('--config', dest='configfile', action='store',
						default=const._config_file)
	parser.add_argument('--test', dest='test', action='store_const', const=True, default=False)
	parser.add_argument('--email', dest='email', action='store_const', const=True, default=False)
	parser.add_argument('--config-prefix', dest='config_prefix', action='store', default='')
	parser.add_argument('--modified-since', dest='modified_since', action='store', default=None)
	parser.add_argument('--fetch-mechanism', dest='fetch_mechanism', action='store', default=None)
	parser.add_argument('--only-lang', dest='only_lang', action='append', default=[])

	args = parser.parse_args(argv)
	if args.config_prefix and not args.config_prefix.endswith('.'):
		args.config_prefix += '.'

	if args.modified_since and args.modified_since != 'any':
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


def get_record_list(args, modifiedSince=None, lang='en'):
	url = 'https://' + args.host + '/api/records/'
	params = {
		'key': args.key,
		'service': '0',
		'lang': lang
	}

	if args.extra_criteria:
		params.update(args.extra_criteria)

	if modifiedSince:
		params['updatedOn'] = modifiedSince

	url = url + '?' + urllib.urlencode(params)

	response = args.session.get(url)
	response.raise_for_status()
	data = response.json(object_pairs_hook=OrderedDict)
	if isinstance(data, dict):
		error = data.get('Error')
		if error:
			raise Exception('Request Error: %s' % error)
		raise Exception('Response dictionary not list: %r' % data)

	return data


def get_records(args, id, lang='en'):
	url = 'https://' + args.host + '/api/record/'
	if not isinstance(id, list):
		id = [id]

	id_str = map(str, id)
	params = {
		'id': ",".join(id_str),
		'key': args.key,
		'service': '0',
		'lang': lang
	}
	url = url + '?' + urllib.urlencode(params)
	start = time.time()
	response = args.session.get(url)
	duration = time.time() - start
	if args.test:
		print 'requested {} records in {}s'.format(len(id), duration)
	response.raise_for_status()
	tmp = {x['ResourceAgencyNum']: x for x in response.json(object_pairs_hook=OrderedDict)}
	result = [tmp[x] for x in id]
	return result


def fetch_record_batches(args, record_ids, lang):
	for page in pager(record_ids, 100):
		for record in get_records(args, page, lang.language_name):
			yield record


def _to_xml(obj, parent=None, record_id=None):
	if parent is None:
		parent = ET.Element('root')

	if isinstance(obj, dict):
		record_id = obj.get('ResourceAgencyNum')
		for key, value in obj.items():
			if not isinstance(key, basestring):
				key = unicode(key)

			if key[0] not in string.ascii_letters:
				key = 'k' + key

			if value:
				sub = ET.SubElement(parent, 'field', name=key)
				_to_xml(value, sub, record_id)

		return parent

	if isinstance(obj, (list, tuple)):
		for value in obj:
			sub = ET.SubElement(parent, 'item')
			_to_xml(value, sub, record_id)

		return parent

	if obj is None:
		return parent

	obj = unicode(obj).strip()
	if not obj:
		return parent

	try:
		parent.text = obj
	except Exception:
		try:
			parent.text = invalid_xml_chars.sub(obj, u'').strip()
		except Exception as e:
			print 'error converting to xml:', record_id, e, repr(obj)
			raise

		if record_id:
			print 'Corrected data that was not valid in record id %s: %r' % (record_id, obj)
		else:
			print 'Corrected data that was not valid unknown record:', repr(obj)

	return parent


def to_xml(obj):
	return ET.tostring(_to_xml(obj))


def push_to_database(context, lang, queue, service):
	sql = u'''
	EXEC sp_CIC_iCarolImport_Incremental ?, ?, ?
	'''
	next_modified = context.args.next_modified_since
	with context.connmgr.get_connection('admin', language=lang.sql_language) as conn:

		while True:
			batch = queue.get()
			if batch is None:
				queue.task_done()
				return

			try:
				xml_0 = to_xml(batch)
				conn.execute(sql, service, next_modified, xml_0)
			except Exception:
				traceback.print_exc()
			queue.task_done()


def fetch_from_o211(context, lang):
	records = get_record_list(context.args, context.args.modified_since, lang.language_name)
	if context.args.test:
		records.sort(key=lambda x: x['UpdatedOn'])
		records = records[-60:]
		pprint.pprint(records)
		return

	queue = Queue(maxsize=2)
	thread = Thread(target=push_to_database, args=(context, lang, queue, 0))
	thread.daemon = True
	thread.start()

	for batch in pager(fetch_record_batches(context.args, (x['ResourceAgencyNum'] for x in records), lang), 1000):
		queue.put(batch)

	queue.put(None)
	queue.join()


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

	if not context.args.modified_since:
		context.args.modified_since = meta_data.LastFetched

	# XXX Should this be observed value instead of this
	context.args.next_modified_since = datetime.now()


def format_modified_date(context):
	if context.args.modified_since == 'any':
		return

	context.args.modified_since = context.args.modified_since.strftime(_time_format)


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
		if not get_config_item(args, 'o211_import_notify_emails', None):
			sys.stderr.write('ERROR: No value for o211_import_notify_emails set in config\n')
			return 1
		else:
			sys.stdout = StringIO()
			sys.stderr = sys.stdout

	sys.stderr = FileWriteDetector(sys.stderr)
	import traceback

	try:
		prepare_session(args)
		check_db_state(context)
		format_modified_date(context)

		langs = get_config_item(args, 'o211_import_languages', 'en-CA').split(',')
		for culture in langs:
			if args.only_lang and culture not in args.only_lang:
				print 'Skipping ', culture
				continue

			lang = _lang_settings.get(culture.strip(), _lang_settings['en-CA'])

			fetch_from_o211(context, lang)

		update_db_state(context)
	except Exception:
		traceback.print_exc()

	if sys.stderr.is_dirty():
		retval = 1

	# TODO: Add email sending.
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
