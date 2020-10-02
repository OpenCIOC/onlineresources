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
import os

import struct
from zlib import crc32


class FormatError(Exception):
	pass


class jQueryUIIcons(object):
	def __init__(self, location):
		self.location = location
		self._changed = None
		self._template = None
		self._palette_length = None

	def get_mtime(self):
		mtime = os.path.getmtime(self.location)

		return mtime

	def get_icon_string(self, colour):
		colour = bytes.fromhex(colour)

		mtime = os.path.getmtime(self.location)

		if not self._template or mtime != self._changed:
			f = open(self.location, 'rb')
			data = f.read()
			f.close()

			pos = data.find(b'PLTE') - 4
			if pos < 0:
				raise FormatError()

			length = self._palette_length = struct.unpack('>L', data[pos:pos + 4])[0]

			self._template = (data[:pos + 8], data[pos + 8 + length + 4:])

		colour = colour * (self._palette_length // 3)
		colour = colour + struct.pack('>L', crc32(b'PLTE' + colour) & 0xffffffff)

		return colour.join(self._template)
