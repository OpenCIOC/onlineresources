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
import time
from collections import namedtuple, defaultdict, Counter
import copy
from cStringIO import StringIO
import datetime
import itertools
import json
import os
import subprocess
import sys
import traceback
from urlparse import urljoin

CREATE_NO_WINDOW = 0x08000000
creationflags = 0

import requests
from lxml import etree

try:
	import cioc  # NOQA
except ImportError:
	sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from cioc.core import constants as const, config, email


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

	args = parser.parse_args(argv)
	if args.config_prefix and not args.config_prefix.endswith('.'):
		args.config_prefix += '.'

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
	if modifiedSince:
		params['modifiedSince'] = modifiedSince.isoformat()
	response = args.session.get(url, json=params)
	response.raise_for_status()
	return response.json()


def icarol_get_records(args, id):
	url = 'https://' + args.host + '/v1/Resource/'
	if not isinstance(id, list):
		id = [id]

	id = map(str, id)
	params = {'id': id}
	start = time.time()
	response = args.session.get(url, params=params)
	duration = time.time() - start
	if args.test:
		print 'requested {} records in {}s'.format(len(id), duration)
	response.raise_for_status()
	result = response.json()
	return result


def fetch_records(args, record_ids):
	for page in pager(record_ids):
		for record in icarol_get_records(args, page):
			yield record


def fetch_from_icarol(args):
	records = icarol_takeall(args)
	records.sort(key=lambda x: x['modified'])
	if args.test:
		records = records[-60:]
		# pprint.pprint(records)
		# return

	for record in fetch_records(args, [x['id'] for x in records]):
		pprint.pprint(record)


def main(argv):
	args = parse_args(argv)
	retval = 0
	try:
		args.config = config.get_config(args.configfile, const._app_name)
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

	fetch_from_icarol(args)

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
