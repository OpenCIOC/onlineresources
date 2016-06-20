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


#stdlib
import datetime
import time
from types import (NoneType, TupleType, ListType, IntType,
					LongType, FloatType, StringType, UnicodeType, DictType)
import string
from collections import OrderedDict



def _strftime(value):
    if datetime:
        if isinstance(value, datetime.datetime):
            return "%04d%02d%02dT%02d:%02d:%02d" % (
                value.year, value.month, value.day,
                value.hour, value.minute, value.second)

    if not isinstance(value, (TupleType, time.struct_time)):
        if value == 0:
            value = time.time()
        value = time.localtime(value)

    return "%04d%02d%02dT%02d:%02d:%02d" % value[:6]


def escape(s, replace=string.replace):
    s = replace(s, "&", "&amp;")
    s = replace(s, "<", "&lt;")
    return replace(s, ">", "&gt;",)


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

	dispatch = {}

	def dumps(self, values):
		out = []
		write = out.append

		write('<?xml version="1.0" encoding="%s"?>\n<root>\n' % self.encoding)
		self.__dump(values, write)
		write("</root>\n")
		result = ''.join(out)
		return result

	def __dump(self, value, write):
		try:
			f = self.dispatch[type(value)]
		except KeyError:
			# check if this object can be marshalled as a structure
			raise TypeError, "cannot marshal %s objects" % type(value)
			# check if this class is a sub-class of a basic type,
			# because we don't know how to marshal these types
			# (e.g. a string sub-class)
		f(self, value, write)

	def dump_nil (self, value, write):
		pass
	dispatch[NoneType] = dump_nil

	def dump_int(self, value, write):
		# in case ints are > 32 bits
		write(str(value))
	dispatch[IntType] = dump_int

	def dump_bool(self, value, write):
		write(value and "1" or "0")
	dispatch[bool] = dump_bool

	def dump_long(self, value, write):
		write(str(int(value)))
	dispatch[LongType] = dump_long

	def dump_double(self, value, write):
		write(repr(value))
	dispatch[FloatType] = dump_double

	def dump_string(self, value, write, escape=escape):
		write(escape(value))
	dispatch[StringType] = dump_string

	def dump_unicode(self, value, write, escape=escape):
		value = value.encode(self.encoding)
		write(escape(value))
	dispatch[UnicodeType] = dump_unicode

	def dump_array(self, value, write):
		i = id(value)
		if i in self.memo:
			raise TypeError, "cannot marshal recursive sequences"
		self.memo.add(i)
		dump = self.__dump
		for v in value:
			if v is not None:
				write("<item>\n")
				dump(v, write)
				write("</item>\n")
			else:
				write("<item/>\n")
		self.memo.discard(i)
	dispatch[TupleType] = dump_array
	dispatch[ListType] = dump_array

	def dump_struct(self, value, write, escape=escape):
		i = id(value)
		if i in self.memo:
			raise TypeError, "cannot marshal recursive dictionaries"
		self.memo.add(i) 
		dump = self.__dump
		for k, v in value.items():
			if type(k) is not StringType:
				if unicode and type(k) is UnicodeType:
					k = k.encode(self.encoding)
				else:
					raise TypeError, "dictionary key must be string"
			if v is not None:
				write("<%s>" % k)
				dump(v, write)
				write("</%s>\n" % k)
			else:
				write("<%s/>\n" % k)
		self.memo.discard(i)
	dispatch[DictType] = dump_struct
	dispatch[OrderedDict] = dump_struct

	def dump_datetime(self, value, write):
		write(_strftime(value))
	dispatch[datetime.datetime] = dump_datetime


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
