# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================


# stdlib

from __future__ import absolute_import
import datetime
import time
import six


def _strftime(value):
	if datetime:
		if isinstance(value, datetime.datetime):
			return u"%04d%02d%02dT%02d:%02d:%02d" % (
				value.year, value.month, value.day,
				value.hour, value.minute, value.second)

	if not isinstance(value, (tuple, time.struct_time)):
		if value == 0:
			value = time.time()
		value = time.localtime(value)

	return u"%04d%02d%02dT%02d:%02d:%02d" % value[:6]


def escape(s):
	s = s.replace(u"&", u"&amp;")
	s = s.replace(u"<", u"&lt;")
	return s.replace(u">", u"&gt;")


class Marshaller:
	"""Generate an XML-RPC params chunk from a Python data structure.

	Create a Marshaller instance for each set of parameters, and use
	the "dumps" method to convert your data (represented as a tuple)
	to an XML-RPC params chunk.  To write a fault response, pass a
	Fault instance instead.  You may prefer to use the "dumps" module
	function for this purpose.
	"""

	# by the way, if you don't understand what's going on in here,
	# that's perfectly ok.

	def __init__(self, encoding='utf-8'):
		self.memo = set()
		self.data = None
		self.encoding = encoding

	def dumps(self, values):
		out = []
		write = out.append

		write(u'<?xml version="1.0" encoding="%s"?>\n<root>\n' % self.encoding)
		self.__dump(values, write)
		write(u"</root>\n")
		result = u''.join(x.encode(self.encoding) for x in out)
		return result

	def __dump(self, value, write):
		if isinstance(value, dict):
			self.dump_struct(value, write)

		elif isinstance(value, (tuple, list)):
			self.dump_array(value, write)

		elif value is None:
			self.dump_nil(value, write)

		elif isinstance(value, bool):
			self.dump_bool(value, write)
		elif isinstance(value, datetime):
			self.dump_datetime(value, write)
		else:
			self.dump_default(value, write)

	def dump_nil(self, value, write):
		return

	def dump_default(self, value, write, escape=escape):
		write(escape(six.text_type(value)))

	def dump_bool(self, value, write):
		write(value and u"1" or u"0")

	def dump_array(self, value, write):
		i = id(value)
		if i in self.memo:
			raise TypeError("cannot marshal recursive sequences")
		self.memo.add(i)
		dump = self.__dump
		for v in value:
			if v is not None:
				write(u"<item>\n")
				dump(v, write)
				write(u"</item>\n")
			else:
				write(u"<item/>\n")
		self.memo.discard(i)

	def dump_struct(self, value, write, escape=escape):
		i = id(value)
		if i in self.memo:
			raise TypeError("cannot marshal recursive dictionaries")
		self.memo.add(i)
		dump = self.__dump
		for k, v in value.items():
			if isinstance(k, six.string_types):
				k = escape(six.text_type(k))
			else:
				raise TypeError("dictionary key must be string")
			if v is not None:
				write(u"<%s>" % k)
				dump(v, write)
				write(u"</%s>\n" % k)
			else:
				write(u"<%s/>\n" % k)
		self.memo.discard(i)

	def dump_datetime(self, value, write):
		write(_strftime(value))


def xml_renderer(info):
	def _render(value, system):
		request = system.get('request')
		if request is not None:
			response = request.response
			ct = response.content_type
			if ct == response.default_content_type:
				response.content_type = 'text/xml'

			return Marshaller().dumps(value)
	return _render


def includeme(config):
	config.add_renderer('cioc:xml', xml_renderer)
