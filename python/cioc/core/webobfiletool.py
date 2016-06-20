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


# Adapted from http://docs.webob.org/en/latest/file-example.html
class FileIterable(object):
	def __init__(self, filename, start=None, stop=None):
		self.filename = filename
		self.start = start
		self.stop = stop
	def __iter__(self):
		return FileIterator(open(self.filename, 'rb'), self.start, self.stop)
	def app_iter_range(self, start, stop):
		return self.__class__(self.filename, start, stop)

class FileIterator(object):
	chunk_size = 4096
	def __init__(self, fileobj, start=None, stop=None):
		self.fileobj = fileobj
		if start:
			self.fileobj.seek(start)
		if stop is not None:
			self.length = stop - start
		else:
			self.length = None
	def __iter__(self):
		return self
	def next(self):
		if self.length is not None and self.length <= 0:
			self.fileobj.close()
			raise StopIteration
		chunk = self.fileobj.read(self.chunk_size)
		if not chunk:
			self.fileobj.close()
			raise StopIteration
		if self.length is not None:
			self.length -= len(chunk)
			if self.length < 0:
				# Chop off the extra:
				chunk = chunk[:self.length]
		return chunk

