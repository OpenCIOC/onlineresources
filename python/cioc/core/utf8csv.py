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

# this is adapted from the example at the bottom of https://docs.python.org/2/library/csv.html
from __future__ import absolute_import
import csv
import codecs
import tempfile
import six


class SQLServerBulkDialect(csv.Dialect):
	delimiter = '\x03'
	lineterminator = '\x04'
	skipinitialspace = False
	escapechar = None
	quoting = csv.QUOTE_NONE


class UTF8Reader(object):
	"""
	A CSV reader which will iterate over lines in the CSV file "f",
	which is encoded in the given encoding.
	"""

	def __init__(self, f, dialect=csv.excel, **kwds):
		self.reader = csv.reader(f, dialect=dialect, **kwds)

	def next(self):
		row = next(self.reader)
		return [six.text_type(s, "utf-8-sig") for s in row]

	def __iter__(self):
		return self


class UTF8CSVWriter(object):
	"""
	A CSV writer which will write rows to CSV file "f",
	which is encoded in the given encoding.
	"""
	def __init__(self, f, dialect=csv.excel, **kwds):
		# Redirect output to a queue
		self.writer = csv.writer(f, dialect=dialect, **kwds)

	def writerow(self, row):
		if six.PY2:
			row = [s.encode("utf-8") for s in row]

		self.writer.writerow(row)

	def writerows(self, rows):
		for row in rows:
			self.writerow(row)


def write_csv_to_zip(zip, data, fname, **kwargs):
	if six.PY3:
		csvfile = tempfile.TemporaryFile('w+', encoding='utf-8-sig', newline='')
	else:
		csvfile = tempfile.TemporaryFile()

		# required to have all spreadsheet programs
		# understand Unicode
		csvfile.write(codecs.BOM_UTF8)

	csvwriter = UTF8CSVWriter(csvfile, **kwargs)

	csvwriter.writerows(data)

	csvfile.seek(0)
	zip.writebuffer(csvfile, fname)
	csvfile.close()
