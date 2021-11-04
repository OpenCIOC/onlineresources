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
from collections import deque
from binascii import crc32


class RecentSearches(object):

	def __init__(self, items=None):
		if items:
			self.items = {v['key']: v for v in items}
			self.lru = deque([v['key'] for v in items], maxlen=20)
		else:
			self.items = {}
			self.lru = deque(maxlen=20)

	def get(self, key):
		""" key is crc32 hexdigest of a previous where clause """
		return self.items.get(key)

	def add(self, value):
		""" Expects: dict with keys: sql and will add key """

		sql = value['sql']
		info = value.get('info')
		if sql and sql[0] == '(' and sql[-1] == ')':
			# check if we have paren padded previous sql
			key = '%08x' % (crc32(sql[1:-1].encode('utf-8')) & 0xffffffff)
			try:
				old_item = self.items[key]
				sql = old_item['sql']
				info = info or old_item.get('info')
			except KeyError:
				key = '%08x' % (crc32(sql.encode('utf-8')) & 0xffffffff)
		else:
			key = '%08x' % (crc32(sql.encode('utf-8')) & 0xffffffff)

		value['key'] = key
		value['sql'] = sql
		value['info'] = info
		if key in self.items:
			try:
				self.lru.remove(key)
			except ValueError:
				pass
			self.lru.appendleft(key)

		else:
			self.lru.appendleft(key)
			for dkey in list(self.items.keys()):
				if dkey not in self.lru:
					del self.items[dkey]

		self.items[key] = value

		return key

	def values(self):
		"Returns in order of most recent to least"
		return list(iter(self))

	def __iter__(self):
		return (self.items[k] for k in self.lru)

	def mostrecent(self):
		try:
			return self.items[self.lru[0]]
		except IndexError:
			return None

	def __len__(self):
		return len(self.lru)

	def __repr__(self):
		return '%s: %s' % (self.__class__.__name__, self.items)

	def __nonzero__(self):
		return not not self.items

	__bool__ = __nonzero__


class RecentSearchManager(object):
	def __init__(self, request):
		self.request = request

	@property
	def cic(self):
		try:
			rs = self.request.session['RecentSearchCIC']
			return rs
		except KeyError:
			rs = self.request.session['RecentSearchCIC'] = RecentSearches()
			return rs

	@property
	def vol(self):
		try:
			rs = self.request.session['RecentSearchVOL']
			return rs
		except KeyError:
			rs = self.request.session['RecentSearchVOL'] = RecentSearches()
			return rs
