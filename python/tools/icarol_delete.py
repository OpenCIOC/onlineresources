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
import sys
from zipfile import ZipFile
import zipfile
import itertools

try:
	import cioc  # NOQA
except ImportError:
	sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from cioc.core import bufferedzip
from cioc.core.utf8csv import UTF8Reader, write_csv_to_zip


def open_zipfile(dest_file):
	zip = ZipFile(dest_file, 'r')
	files = zip.namelist()
	return zip.open(files[0], 'r')


def main(previous_name, dest_file):
	to_delete_count = 0
	to_delete_percent = 0

	if previous_name.endswith('.zip'):
		csv_file = open_zipfile(previous_name)
	else:
		csv_file = open(previous_name)

	reader = UTF8Reader(csv_file)
	reader.next()
	previous = set(itertools.ifilter(lambda x: x[-1] in ['AGENCY', 'SITE', 'PROGRAM'], itertools.imap(lambda x: (x[0], x[1], x[2].upper()), reader)))
	previous_count = len(previous)

	csv_file.close()

	if dest_file.endswith('.zip'):
		csv_file = open_zipfile(dest_file)
	else:
		csv_file = open(dest_file)

	reader = UTF8Reader(csv_file)
	header = reader.next()

	current_records = map(tuple, reader)

	previous.difference_update(current_records)

	csv_file.close()

	to_delete = list(previous)
	del previous

	to_delete.sort()
	to_delete_count = len(to_delete)

	to_delete_percent = 100 * to_delete_count / previous_count

	dest_file = dest_file[:-4] + '_delete.zip'
	with open(dest_file, 'wb') as fd:
		with bufferedzip.BufferedZipFile(fd, 'w', zipfile.ZIP_DEFLATED) as zip:
			write_csv_to_zip(zip, itertools.chain([header], to_delete), os.path.basename(dest_file)[:-4] + '.csv')

	return to_delete_percent, to_delete_count, previous_count


if __name__ == '__main__':
	print main(*sys.argv[1:3])
