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
import re
from Queue import Queue
from collections import namedtuple
from cStringIO import StringIO
import os
import sys
import tempfile
import traceback
import urllib
import pyodbc
from collections import OrderedDict
from datetime import datetime
from threading import Thread
from operator import itemgetter

import isodate

CREATE_NO_WINDOW = 0x08000000
creationflags = 0


import requests

try:
	import cioc  # NOQA
except ImportError:
	sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from tools.toolslib import Context

from cioc.core import constants as const, email
from cioc.core import syslanguage
from cioc.core.utf8csv import UTF8CSVWriter, SQLServerBulkDialect
from cioc.core.connection import ConnectionError
from cioc.web.import_.upload import process_import


invalid_xml_chars = re.compile(u'[\x00-\x08\x0c\x0e-\x19]')

const.update_cache_values()
_time_format = '%Y-%m-%d %H:%M:%S'
LangSetting = namedtuple('LangSetting', 'culture file_suffix language_name sql_language')

_lang_settings = {
	'en-CA': LangSetting('en-CA', '', 'en', syslanguage.SQLALIAS_ENGLISH),
	'fr-CA': LangSetting('fr-CA', '_frCA', 'fr', syslanguage.SQLALIAS_FRENCH)
}

FieldOrder = [
	"ResourceAgencyNum", "ImportDate", "ImportStatus", "Refresh",
	"PublicName", "AlternateName", "OfficialName", "TaxonomyLevelName",
	"ParentAgency", "ParentAgencyNum", "RecordOwner", "UniqueIDPriorSystem",
	"MailingAttentionName", "MailingAddress1", "MailingAddress2",
	"MailingCity", "MailingStateProvince", "MailingPostalCode",
	"MailingCountry", "MailingAddressIsPrivate", "PhysicalAddress1",
	"PhysicalAddress2", "PhysicalCity", "PhysicalCounty",
	"PhysicalStateProvince", "PhysicalPostalCode", "PhysicalCountry",
	"PhysicalAddressIsPrivate", "OtherAddress1", "OtherAddress2", "OtherCity",
	"OtherCounty", "OtherStateProvince", "OtherPostalCode", "OtherCountry",
	"Latitude", "Longitude", "HoursOfOperation", "Phone1Number", "Phone1Name",
	"Phone1Description", "Phone1IsPrivate", "Phone1Type", "Phone2Number",
	"Phone2Name", "Phone2Description", "Phone2IsPrivate", "Phone2Type",
	"Phone3Number", "Phone3Name", "Phone3Description", "Phone3IsPrivate",
	"Phone3Type", "Phone4Number", "Phone4Name", "Phone4Description",
	"Phone4IsPrivate", "Phone4Type", "Phone5Number", "Phone5name",
	"Phone5Description", "Phone5IsPrivate", "Phone5Type", "PhoneFax",
	"PhoneFaxDescription", "PhoneFaxIsPrivate", "PhoneTTY",
	"PhoneTTYDescription", "PhoneTTYIsPrivate", "PhoneTollFree",
	"PhoneTollFreeDescription", "PhoneTollFreeIsPrivate", "PhoneNumberHotline",
	"PhoneNumberHotlineDescription", "PhoneNumberHotlineIsPrivate",
	"PhoneNumberBusinessLine", "PhoneNumberBusinessLineDescription",
	"PhoneNumberBusinessLineIsPrivate", "PhoneNumberOutOfArea",
	"PhoneNumberOutOfAreaDescription", "PhoneNumberOutOfAreaIsPrivate",
	"PhoneNumberAfterHours", "PhoneNumberAfterHoursDescription",
	"PhoneNumberAfterHoursIsPrivate", "EmailAddressMain", "WebsiteAddress",
	"AgencyStatus", "AgencyClassification", "AgencyDescription", "SearchHints",
	"CoverageArea", "CoverageAreaText", "Eligibility",
	"EligibilityAdult", "EligibilityChild", "EligibilityFamily",
	"EligibilityFemale", "EligibilityMale", "EligibilityTeen",
	"SeniorWorkerName", "SeniorWorkerTitle", "SeniorWorkerEmailAddress",
	"SeniorWorkerPhoneNumber", "SeniorWorkerIsPrivate", "MainContactName",
	"MainContactTitle", "MainContactEmailAddress", "MainContactPhoneNumber",
	"MainContactType", "MainContactIsPrivate", "LicenseAccreditation",
	"IRSStatus", "FEIN", "YearIncorporated", "AnnualBudgetTotal",
	"LegalStatus", "SourceOfFunds", "ExcludeFromWebsite",
	"ExcludeFromDirectory", "DisabilitiesAccess",
	"PhysicalLocationDescription", "BusServiceAccess",
	"PublicAccessTransportation", "PaymentMethods", "FeeStructureSource",
	"ApplicationProcess", "ResourceInfo", "DocumentsRequired",
	"LanguagesOffered", "LanguagesOfferedList", "AvailabilityNumberOfTimes",
	"AvailabilityFrequency", "AvailabilityPeriod",
	"ServiceNotAlwaysAvailability", "CapacityType", "ServiceCapacity",
	"NormalWaitTime", "TemporaryMessage", "TemporaryMessageAppears",
	"TemporaryMessageExpires", "EnteredOn", "UpdatedOn", "MadeInactiveOn",
	"InternalNotes", "InternalNotesForEditorsAndViewers",
	"HighlightedResource", "LastVerifiedOn", "LastVerifiedByName",
	"LastVerifiedByTitle", "LastVerifiedByPhoneNumber",
	"LastVerifiedByEmailAddress", "LastVerificationApprovedBy",
	"AvailableForDirectory", "AvailableForReferral", "AvailableForResearch",
	"PreferredProvider", "ConnectsToSiteNum", "ConnectsToProgramNum",
	"LanguageOfRecord", "CurrentWorkflowStepCode", "VolunteerOpportunities",
	"VolunteerDuties", "IsLinkOnly", "ProgramAgencyNamePublic",
	"SiteAgencyNamePublic", "Categories", "TaxonomyTerm", "TaxonomyTerms",
	"TaxonomyTermsNotDeactivated", "TaxonomyCodes", "Coverage", "Hours",
	"Custom_A1) Does your organization consent to participate in the",
	"Custom_Public Comments", "Custom_A2) What is the likelihood that within the next 2-5 year",
	"Custom_S1) Does your organization own/rent/sublease the space",
	"Custom_S2) If your organization rents the space please state fr",
	"Custom_S3) What type of facilities do you have at the space (Ch",
	"Custom_S4) What is the approximate square footage of the space",
	"Custom_S5) In what type of building is the space located",
	"Custom_S6) If your organization plans to move from the space in",
	"Custom_Former Names", "Custom_Headings",
	"Custom_Legal Name", "Custom_Pub Codes", "Custom_Record Owner (211 Central)",
	"Custom_Record Owner (controlled)", "Custom_SINV", "Custom_iCarol-managed record",
	"Custom_Facebook", "Custom_Instagram", "Custom_LinkedIn", "Custom_Twitter", "Custom_YouTube"
]

AllRecordsFieldOrder = [
	"ResourceAgencyNum", "ParentAgencyNum", "ConnectsToSiteNum",
	"ConnectsToProgramNum", "UniqueIDPriorSystem", "PublicName",
	"TaxonomyLevelName", "iCarolManaged", "RecordOwner", "UpdatedOn",
]

dts_file_template = os.path.join(os.environ.get('CIOC_UDL_BASE', r'd:\UDLS'), '%s', 'cron_job_runner.UDL')


def get_bulk_connection(language):
	dts = dts_file_template % const._app_name
	with open(dts) as dts_file:

		# the [1:] is there to drop the bom from the start of the file
		connstr = dts_file.read().decode('utf_16_le')[1:].replace(u'\r', u'').split(u'\n')

	for line in connstr:
		if line and line.startswith((u';', u'[')):
			continue

		break

	settings = dict(x.split(u'=') for x in line.split(';'))
	settings = [
		('Driver', '{SQL Server Native Client 10.0}'),
		('Server', settings['Data Source']),
		('Database', settings['Initial Catalog']),
		('UID', settings['User ID']),
		('PWD', settings['Password'])
	]
	connstr = ';'.join('='.join(x) for x in settings)

	try:
		conn = pyodbc.connect(connstr, autocommit=True, unicode_results=True)
		conn.execute("SET LANGUAGE '" + language + "'")
	except pyodbc.Error as e:
		raise ConnectionError(e)

	return conn


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
	parser.add_argument('--skip-fetch', dest='skip_fetch', action='store_true', default=False)
	parser.add_argument('--skip-import', dest='skip_import', action='store_true', default=False)

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


def email_log(args, outputstream, is_error):
	author = get_config_item(args, 'o211_import_notify_from', 'admin@cioc.ca')
	to = [x.strip() for x in get_config_item(args, 'o211_import_notify_emails', 'admin@cioc.ca').split(',')]
	email.send_email(fakerequest(args.config), author, to, 'Import from iCarol%s' % (' -- ERRORS!' if is_error else ''), outputstream.getvalue())


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
	for page in pager(record_ids, 500):
		for record in get_records(args, page, lang.language_name):
			yield record


def _to_unicode(value):
	if value is None:
		return u''

	value = unicode(value)
	return invalid_xml_chars.sub(u'', value).strip()


def to_csv(records, target_file, headings):
	fn = itemgetter(*headings)

	writer = UTF8CSVWriter(target_file, dialect=SQLServerBulkDialect)
	out_stream = (map(_to_unicode, fn(x)) for x in records)
	writer.writerows(out_stream)


class CsvFileWriter(object):
	def __init__(self, context, headings):
		self.target_dir = context.csv_target_dir
		self.source_dir = context.csv_source_dir
		self.fd = None
		self.full_name = None
		self.headings = headings

	def __enter__(self):
		self.fd = tempfile.NamedTemporaryFile(suffix='.csv', dir=self.target_dir, delete=False)
		self.full_name = self.fd.name
		return self

	def __exit__(self, type, value, tb):
		if self.full_name:
			try:
				os.remove(self.full_name)
			except Exception:
				pass

	def serialize_records(self, records):
		if not self.fd:
			raise Exception('File not opened yet')

		to_csv(records, self.fd, self.headings)

	def close(self):
		if self.fd:
			self.fd.close()
			self.fd = None

	@property
	def source_file(self):
		return os.path.join(self.source_dir, os.path.basename(self.full_name))


def push_bulk(context, conn, sql, headings, batch, *args):
	with CsvFileWriter(context, headings) as writer:
		writer.serialize_records(batch)
		writer.close()
		conn.execute(sql, *(args + (writer.source_file,)))


def push_to_database(context, lang, queue):
	sql = u'''
	EXEC sp_CIC_iCarolImport_Incremental ?, ?
	'''
	next_modified = context.args.next_modified_since
	with get_bulk_connection(language=lang.sql_language) as conn:

		while True:
			batch = queue.get()
			if batch is None:
				queue.task_done()
				return

			try:
				push_bulk(context, conn, sql, FieldOrder, batch, next_modified)
			except Exception:
				traceback.print_exc()
			queue.task_done()


def push_all_records(conext, lang, all_records):
	sql = u'''
	EXEC sp_CIC_iCarolImport_AllRecords ?
	'''
	with get_bulk_connection(language=lang.sql_language) as conn:
		push_bulk(conext, conn, sql, AllRecordsFieldOrder, all_records)


def fetch_from_o211(context, lang):
	records = get_record_list(context.args, context.args.modified_since, lang.language_name)
	if context.args.test:
		records.sort(key=lambda x: x['UpdatedOn'])
		records = records[-60:]
		pprint.pprint(records)
		return

	queue = Queue(maxsize=2)
	thread = Thread(target=push_to_database, args=(context, lang, queue))
	thread.daemon = True
	thread.start()

	for batch in pager(fetch_record_batches(context.args, (x['ResourceAgencyNum'] for x in records), lang), 5000):
		queue.put(batch)

	queue.put(None)
	queue.join()

	all_records = get_record_list(context.args, 'any', lang.language_name)
	push_all_records(context, lang, all_records)


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

	sql = 'EXEC dbo.sp_CIC_iCarolImportMeta_u ?, ?'
	with context.connmgr.get_connection('admin') as conn:
		conn.execute(sql, context.args.fetch_mechanism, context.args.next_modified_since)


def generate_and_upload_import(context):
	sql = 'EXEC sp_CIC_iCarolImport_CreateSharing'
	total_import_count = 0
	with context.connmgr.get_connection('admin') as conn:
		cursor = conn.execute(sql)
		for member in cursor.fetchall():
			member_name = member.DefaultEmailNameCIC or member.BaseURLCIC or member.MemberID
			if not member.records:
				print "No Records for %s, skiping" % (member_name,)
				continue
			else:
				print "Processing Imports for %s" % (member_name,)

			with tempfile.TemporaryFile() as fd:
				fd.write(u'''<?xml version="1.0" encoding="UTF-8"?>
				<root xmlns="urn:ciocshare-schema"><DIST_CODE_LIST/><PUB_CODE_LIST/>'''.encode('utf8'))
				fd.write(member.records.encode('utf8'))
				fd.write(u'</root>'.encode('utf8'))
				fd.seek(0)

				error_log, total_inserted = process_import(
					'icarol_import_%s.xml' % (context.args.next_modified_since.isoformat(),),
					fd, member.MemberID, const.DM_CIC, const.DM_S_CIC, "(import system)",
					'iCarol Import %s' % (context.args.next_modified_since.isoformat(),),
					context.connmgr, lambda x: x
				)

			total_import_count += total_inserted
			print "Import Complete for Member %s. %s records imported" % (member_name, total_inserted)
			if error_log:
				print >>sys.stderr, "A problem was encountered validating input for Member %s, see below." % (member_name,)

			for record, errmsg in error_log:
				if record:
					print >>sys.stderr, u': '.join((record, errmsg)).encode('utf8')
				else:
					print >>sys.stderr, errmsg.encode('utf8')

			print

	print "Completed Processing Imports. %s Records imported" % (total_import_count,)


def main(argv):
	args = parse_args(argv)
	context = Context(args)
	retval = 0
	try:
		args.config = context.config
	except Exception:
		sys.stderr.write('ERROR: Could not process config file:\n')
		sys.stderr.write(traceback.format_exc())
		return 2

	if args.email:
		if not get_config_item(args, 'o211_import_notify_emails', None):
			sys.stderr.write('ERROR: No value for o211_import_notify_emails set in config\n')
			return 3
		else:
			sys.stdout = StringIO()
			sys.stderr = sys.stdout

	sys.stderr = FileWriteDetector(sys.stderr)
	import traceback

	try:
		prepare_session(args)
		check_db_state(context)
		format_modified_date(context)
		context.csv_target_dir = get_config_item(args, 'o211_import_csv_target')
		context.csv_source_dir = get_config_item(args, 'o211_import_csv_source')

		langs = get_config_item(args, 'o211_import_languages', 'en-CA').split(',')
		for culture in langs:
			if args.only_lang and culture not in args.only_lang:
				print 'Skipping ', culture
				continue

			lang = _lang_settings.get(culture.strip(), _lang_settings['en-CA'])

			if not args.skip_fetch:
				fetch_from_o211(context, lang)

		if not args.skip_import:
			generate_and_upload_import(context)

		if not args.skip_fetch:
			# we only want to update the High Water Mark when we actually fetch data.
			update_db_state(context)
	except Exception:
		traceback.print_exc()

	if sys.stderr.is_dirty():
		retval = 1

	if args.email:
		email_log(
			args,
			sys.stdout,
			sys.stderr.is_dirty()
		)

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
