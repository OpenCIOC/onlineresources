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
from __future__ import print_function
import argparse
from collections import namedtuple, defaultdict, Counter
import copy
from six.moves import cStringIO as StringIO
import datetime
from glob import glob
import itertools
import json
import os
import subprocess
import sys
import tempfile
import traceback
from six.moves.urllib.parse import urljoin
from zipfile import ZipFile
import zipfile
from six.moves import map

CREATE_NO_WINDOW = 0x08000000
creationflags = 0

import requests
from lxml import etree

try:
	import cioc  # NOQA
except ImportError:
	sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from cioc.core import constants as const, config, email, bufferedzip
from cioc.core.utf8csv import UTF8Reader, write_csv_to_zip


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


def previous_files(dest_dir, prefix, suffix=''):
	return glob(os.path.join(dest_dir, prefix + 'Full' + _date_pattern + suffix + '.zip')) + \
		glob(os.path.join(dest_dir, prefix + 'IncrementalFrom' + _date_pattern + 'To' + _date_pattern + suffix + '.zip'))


def calculate_previous_date_and_this_date(lang, dest_dir, prefix, force_previous):
	now = datetime.datetime.now().strftime(_time_format)
	if force_previous:
		return force_previous, now

	suffix_len = len(lang.file_suffix)
	end = -4 - suffix_len
	start = len(now) - end

	previous_dump_times = [x[-start:end] for x in previous_files(dest_dir, prefix, lang.file_suffix)]
	previous_dump_times.sort()
	if previous_dump_times:
		previous = previous_dump_times[-1]
	else:
		previous = None

	return previous, now


def calculate_destination_name(lang, type, dest_dir, previous, now, prefix):
	if previous is None:
		type = 'full'
	return os.path.join(
		dest_dir,
		prefix + _fname_formats[type].format(now=now, previous=previous, file_suffix=lang.file_suffix)
	)


class DEFAULT(object):
	pass


def get_config_item(args, key, default=DEFAULT):
	config_prefix = args.config_prefix
	config = args.config
	if default is DEFAULT:
		return config.get(config_prefix + key, config[key])

	return args.config.get(config_prefix + key, config.get(key, default))


def parse_args(argv):
	parser = argparse.ArgumentParser()
	parser.add_argument('--config', dest='configfile', action='store',
						default=const._config_file)
	parser.add_argument('--type', dest='type', action='store', default='full')
	parser.add_argument('url', action='store')
	parser.add_argument('dest', action='store')
	parser.add_argument('--file', dest='file', action='store', default=None)
	parser.add_argument('--email', dest='email', action='store_const', const=True, default=False)
	parser.add_argument('--nosslverify', dest='nosslverify', action='store_const', const=True, default=False)
	parser.add_argument('--config-prefix', dest='config_prefix', action='store', default='')
	parser.add_argument('--force-previous', dest='force_previous', action='store', default=None)
	parser.add_argument('--only-lang', dest='only_lang', action='append', default=[])

	args = parser.parse_args(argv)
	if args.config_prefix and not args.config_prefix.endswith('.'):
		args.config_prefix += '.'
	try:
		args.config = config.get_config(args.configfile, const._app_name)
	except Exception:
		sys.stderr.write('ERROR: Could not process config file:\n')
		sys.stderr.write(traceback.format_exc())
		return None

	return args


def stream_download(dest_file, url, **kwargs):
	# remove possible conflicting arg
	kwargs.pop('stream', None)

	r = requests.get(url, stream=True, **kwargs)
	r.raise_for_status()
	size = 0
	with open(dest_file, 'wb') as fd:
		for chunk in r.iter_content(chunk_size=8192):
			size += len(chunk)
			fd.write(chunk)

	print('downloaded', size, 'bytes')


def reupload_num_report(url, filename, field, **kwargs):
	data = None
	with open(filename, 'rb') as f:
		data = f.read()

	upload_num_report_json_doc(url, data, field, **kwargs)


def upload_num_report_json_doc(url, data, field, **kwargs):
	kwargs.pop('stream', None)
	headers = {'content-type': 'application/json'}
	kwargs['params']['Field'] = field

	r = requests.post(url, data=data, headers=headers, **kwargs)
	r.raise_for_status()


def upload_num_report(url, records_sent, counts, field, dest_file, **kwargs):
	data = json.dumps({'counts': counts, 'sent': records_sent})
	with open(os.path.splitext(dest_file)[0] + '_counts.json', 'w') as f:
		f.write(data)

	upload_num_report_json_doc(url, data, field, **kwargs)


def remove_exclusions(reader_to_exclude_from, url, args, **kwargs):
	r = requests.get(url + '/icarolsource', stream=True, **kwargs)
	r.raise_for_status()
	with tempfile.TemporaryFile() as fd:
		for chunk in r.iter_content(chunk_size=8192):
			fd.write(chunk)

		fd.seek(0)
		csv_file = open_zipfile(fd)
		reader = UTF8Reader(csv_file)
		next(reader)
		exclusion_set = set((x[0] for x in reader))

	for row in reader_to_exclude_from:
		if row[0] in exclusion_set:
			continue

		yield tuple(row)


def calculate_deletion_list(lang, url, args, **kwargs):
	suffix = lang.file_suffix + '_full_list'
	previous_filenames = previous_files(args.dest, args.filename_prefix, suffix)

	kwargs.pop('stream', None)

	r = requests.get(url + '/list', stream=True, **kwargs)
	r.raise_for_status()
	dest_file = args.dest_file[:-4] + '_full_list.zip'
	update_environ('ALLEXPORTFILES', dest_file)
	with open(dest_file, 'wb') as fd:
		for chunk in r.iter_content(chunk_size=8192):
			fd.write(chunk)

	to_delete_count = 0
	to_delete_percent = 0
	if previous_filenames and args.type != 'full':
		now = datetime.datetime.now().strftime(_time_format)
		end = -len(suffix) - 4
		start = -len(now) + end

		previous_filenames.sort(key=lambda x: x[start:end])

		csv_file = open_zipfile(previous_filenames[-1])
		reader = UTF8Reader(csv_file)
		next(reader)
		previous = set(remove_exclusions(reader, url, args, **kwargs))
		previous_count = len(previous)

		csv_file.close()
		csv_file = open_zipfile(dest_file)
		reader = UTF8Reader(csv_file)
		header = next(reader)

		current_records = list(map(tuple, reader))
		record_counts = Counter(x[0] for x in current_records)

		previous.difference_update(current_records)

		csv_file.close()

		to_delete = list(previous)
		del previous

		to_delete.sort()
		to_delete_count = len(to_delete)

		to_delete_percent = 100 * to_delete_count / previous_count

		dest_file = args.dest_file[:-4] + '_delete.zip'
		update_environ('ALLEXPORTFILES', dest_file)
		update_environ('SYNCEXPORTFILES', dest_file)
		with open(dest_file, 'wb') as fd:
			with bufferedzip.BufferedZipFile(fd, 'w', zipfile.ZIP_DEFLATED) as zip:
				write_csv_to_zip(zip, itertools.chain([header], to_delete), os.path.basename(dest_file)[:-4] + '.csv')

	else:
		csv_file = open_zipfile(dest_file)
		reader = UTF8Reader(csv_file)
		header = next(reader)
		record_counts = Counter(x[0] for x in reader)
		csv_file.close()

		dest_file = args.dest_file[:-4] + '_delete.zip'
		update_environ('ALLEXPORTFILES', dest_file)
		update_environ('SYNCEXPORTFILES', dest_file)
		with open(dest_file, 'wb') as fd:
			with bufferedzip.BufferedZipFile(fd, 'w', zipfile.ZIP_DEFLATED) as zip:
				write_csv_to_zip(zip, [header], os.path.basename(dest_file)[:-4] + '.csv')

	return to_delete_percent, to_delete_count, record_counts


def download_url(baseurl):
	return urljoin(baseurl, '/export/airs')


def download_kwargs(lang, args):
	kwargs = {
		'auth': (get_config_item(args, 'airs_export_user'), get_config_item(args, 'airs_export_password')),
		'params': {
			'version': get_config_item(args, 'airs_export_xmlversion', '3_0'),
			'DST': get_config_item(args, 'airs_export_dst'),
			'IncludeSiteAgency': get_config_item(args, 'airs_export_include_site_agency', 'on'),
			'IncludeDeleted': 'on',
			'PubCodeSync': get_config_item(args, 'airs_export_pub_code_sync', 'on'),
			'FileSuffix': '-' + os.path.basename(args.dest_file)[:-4],
			'AnyLanguageChange': 'on',
			'LabelLangOverride': 0,
			'Ln': lang.culture
		}
	}

	if args.type == 'part' and args.previous is not None:
		kwargs['params']['PartialDate'] = args.previous

	if args.nosslverify:
		kwargs['verify'] = False

	return kwargs


def open_zipfile(dest_file):
	zip = ZipFile(dest_file, 'r')
	files = zip.namelist()
	return zip.open(files[0], 'r')


def schema_part_prep(schema_doc, name, type):
	new_doc = copy.deepcopy(schema_doc)
	doc_root = new_doc.getroot()

	doc_root.remove(doc_root.find("./%selement[@name='Source']" % XSD))
	doc_root.append(etree.XML('<xs:element xmlns:xs="http://www.w3.org/2001/XMLSchema" name="%s" type="%s"/>' % (name, type)))

	pop = "//xs:complexType[@name='%(type)s']/xs:sequence/xs:element[@type='tSite' or @type='tAgency' or @type='tSiteService']" % {'type': type}
	elements = {}
	for element in doc_root.xpath(pop, namespaces={'xs': XS}):
		element.getparent().remove(element)

		attributes = element.attrib
		elements[attributes['name']] = (attributes['type'], dict(attributes))

	return etree.XMLSchema(new_doc), elements

schema_parts = {
	'tAgency': 'Agency',
	'tSite': 'Location',
	'tSiteService': 'Service',
	'tSource': 'Source',
}

schema_parts_display_name = {
	'tAgency': 'Agency',
	'tSite': 'Site',
	'tSiteService': 'Service'
}

xmlschema_elements = {}


def init_xmlschema():
	schema_path = os.path.join(__file__, '..', '..', '..', 'import', 'airs_3_0_modified.xsd')
	schema_doc = etree.parse(schema_path)

	for type, name in schema_parts.items():
		if type == 'tSource':
			continue

		xmlschema_elements[type] = schema_part_prep(schema_doc, name, type)

	element = schema_doc.getroot().find("./%(xs)selement[@name='Source']//%(xs)ssequence" % {'xs': XSD})
	element.getparent().remove(element)
	element = element[0]
	xmlschema_elements['tSource'] = (etree.XMLSchema(schema_doc.getroot()), {'Agency': ('tAgency', dict(element.attrib))})


def _validate_part(error_log, counts, iterable, root, tagname, schema, elements):
	key = None
	saw = {x: 0 for x in elements.keys()}
	to_remove = []
	while True:
		try:
			event, element = next(iterable)
		except StopIteration:
			return None

		if event == 'start' and element.tag in elements:
			saw[element.tag] += 1
			to_remove.append(element)
			type, attributes = elements[element.tag]

			# print element.tag, type, schema_parts[type], xmlschema_elements[type]
			if type != 'tSite' or element.tag != 'AgencyLocation':
				counts[type] += 1
			_validate_part(error_log, counts, iterable, element, schema_parts[type], *xmlschema_elements[type])

		elif event == 'end' and element.tag == 'Key' and element.getparent() == root:
			key = element.text
			counts[key] += 1

		elif event == 'end' and element == root:
			# print 'found end'
			for el in to_remove:
				root.remove(el)
			oldtag = element.tag
			element.tag = tagname

			if oldtag == 'Source':
				element[:] = []
				element.text = None

			if not schema.validate(element):
				for error in schema.error_log:
					error_log.append((key, oldtag, SchemaError(element.sourceline, error.column, error.message)))

			for name, (type, attributes) in elements.items():
				# Check seen data against min/maxOccurs in elements
				min = attributes.get('minOccurs', 1)
				max = attributes.get('maxOccurs', 1)
				if saw[name] < int(min):
					error_log.append((
						key, oldtag,
						SchemaError(
							element.sourceline,
							None,
							'Error parsing %s element. Not enough %s elements. Expected %d but got %d' %
							(oldtag, name, min, saw[name])
						)
					))

				if max != 'unbounded' and saw[name] > int(max):
					error_log.append((
						key, oldtag,
						SchemaError(
							element.sourceline,
							None,
							'Error parsing %s element. Not to many %s elements. Expected %d but got %d' %
							(oldtag, name, max, saw[name])
						)
					))
			# NOTE this return must happen on the end event when element is root
			return


def validate_download(args, counts):
	init_xmlschema()
	error_log = []

	xmlfile = open_zipfile(args.dest_file)

	iterable = etree.iterparse(xmlfile, events=('start', 'end'))
	event, element = next(iterable)
	_validate_part(error_log, counts, iterable, element, 'Source', *xmlschema_elements['tSource'])

	return error_log


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


def output_error_log(args, error_log):
	template = 'NUM: %s, Element: %s, Line: %s,\nMessage: %s\n'
	for key, tag, error in error_log:
		sys.stderr.write(template % (key, tag, error.line, error.message))


def email_log(args, outputstream, report, validation_errors, is_error):
	author = get_config_item(args, 'airs_export_notify_from', 'admin@cioc.ca')
	to = [x.strip() for x in get_config_item(args, 'airs_export_notify_emails', 'admin@cioc.ca').split(',')]
	email.send_email(fakerequest(args.config), author, to, 'AIRS Export to iCarol%s' % (' -- Review Required!' if validation_errors else (' -- ERRORS!' if is_error else '')), '\n\n'.join((report, outputstream.getvalue())))


def generate_report(args, counts):
	return 'AIRS export generated as "%s" with the following counts:\n%s\n' % (
		os.path.basename(args.dest_file),
		''.join('%s: %d\n' % (schema_parts_display_name[x], counts[x]) for x in ['tAgency', 'tSite', 'tSiteService'])
	)


def update_environ(target, extra):
	files = os.environ.get(target, '').split()
	os.environ[target] = ' '.join(files + [os.path.basename(extra)])


def process_language(args, lang):
	error_log = None
	url = None
	kwargs = {}
	counts = defaultdict(lambda: 0)

	print('\n\nProcessing %s:\n' % lang.language_name)

	try:
		args.previous, args.now = calculate_previous_date_and_this_date(lang, args.dest, args.filename_prefix, args.force_previous)
		args.dest_file = calculate_destination_name(lang, args.type, args.dest, args.previous, args.now, args.filename_prefix)
		if not args.file:
			url = download_url(args.url)
			kwargs = download_kwargs(lang, args)

			try:
				stream_download(args.dest_file, url, **kwargs)
			except requests.HTTPError as e:
				body = u''
				if e.response:
					body = u': ' + e.response.text
				sys.stderr.write('Unable to download file: %s%s\n' % (e, body))
		else:
			args.dest_file = args.file

		update_environ('ALLEXPORTFILES', args.dest_file)
		update_environ('SYNCEXPORTFILES', args.dest_file)
		error_log = validate_download(args, counts)
		if error_log:
			output_error_log(args, error_log)

	except requests.HTTPError:
		pass

	except Exception as e:
		sys.stderr.write('ERROR: Something went wrong generating the AIRS export:\n')
		sys.stderr.write(traceback.format_exc())

	record_counts = {}
	if not args.file:
		try:
			to_delete_percent, to_delete_count, record_counts = calculate_deletion_list(lang, url, args, **download_kwargs(lang, args))
		except requests.HTTPError as e:
			body = u''
			if e.response:
				body = u': ' + e.response.text
			sys.stderr.write(u'Unable to calculate deletion list: %s%s\n' % (e, body))
		else:
			if to_delete_count >= 50 and to_delete_percent >= 2:
				error_log.append('trigger warning subject')
				sys.stderr.write(u'Warning: scheduled to delete %s records (%s%% of total) from iCarol'
					% (to_delete_count, to_delete_percent))

	db_count_field = get_config_item(args, 'airs_export_db_count_field', None)
	if record_counts and db_count_field and not args.file:
		records_sent = list(counts.keys())
		try:
			upload_num_report(url, records_sent, record_counts, db_count_field, args.dest_file, **download_kwargs(lang, args))
		except requests.HTTPError as e:
			body = u''
			if e.response:
				body = u': ' + e.response.text
			sys.stderr.write(u'Unable to upload NUM counts: %s%s\n' % (e, body))

	report = generate_report(args, counts)

	return report, error_log


def main(argv):
	args = parse_args(argv)
	retval = 0
	if not args:
		return 1

	args.filename_prefix = get_config_item(args, 'airs_export_filename_prefix', '')

	if args.email:
		if not get_config_item(args, 'airs_export_notify_emails', None):
			sys.stderr.write('ERROR: No value for airs_export_notify_emails set in config\n')
			return 1
		else:
			sys.stdout = StringIO()
			sys.stderr = sys.stdout

	sys.stderr = FileWriteDetector(sys.stderr)

	before_cmd = get_config_item(args, 'airs_export_run_before_cmd', None)
	after_cmd = get_config_item(args, 'airs_export_run_after_cmd', None)

	if before_cmd:
		p = subprocess.Popen(before_cmd, shell=True, cwd=args.dest)
		p.wait()

	results = []
	error_logs = []
	langs = get_config_item(args, 'airs_export_languages', 'en-CA').split(',')
	for culture in langs:
		if args.only_lang and culture not in args.only_lang:
			print('Skipping ', culture)
			continue

		lang = _lang_settings.get(culture.strip(), _lang_settings['en-CA'])
		report, error_log = process_language(args, lang)

		results.append("\n\n%s Results:\n\n" % lang.language_name)

		error_logs.append(error_log)
		results.append(report)

	if args.email:
		email_log(
			args,
			sys.stdout,
			''.join(results),
			any(bool(x) for x in error_log),
			sys.stderr.is_dirty() and any(x is None for x in error_logs)
		)
	else:
		print()
		print("".join(results))

	if after_cmd:
		p = subprocess.Popen(after_cmd, shell=True, cwd=args.dest)
		p.wait()

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
