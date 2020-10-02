# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#	   http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================


from __future__ import absolute_import
from datetime import datetime, date

# 3rd party
from pyramid.decorator import reify
import pywintypes

# this app
from cioc.core import syslanguage
from cioc.core.request import CiocRequestMixin
import six


class FakeRegistry(object):
	pass


class CollectionShim(object):
	def __init__(self, collection):
		self._collection = collection

	def __getitem__(self, key):
		val = self._collection(key)
		if callable(val):
			val = val()
		if val is None:
			raise KeyError(key)

		return six.text_type(val)

	def __iter__(self):
		return iter(self._collection)

	def get(self, key, default=None):
		try:
			return self[key]
		except KeyError:
			return default

class MultiCollectionShim(object):
	def __init__(self, collections):
		self._collections = [CollectionShim(x) for x in collections]

	def __getitem__(self, key):
		for col in self._collections:
			try:
				return col[key]
			except KeyError:
				pass

		raise KeyError(key)

	def get(self, key, default=None):
		try:
			return self[key]
		except KeyError:
			return default

class HeaderShim(object):
	def __init__(self, collection):
		self._collection = CollectionShim(collection)

	def __getitem__(self, key):
		tmpkey = key.upper().replace('-', '_')
		if tmpkey not in ('CONTENT_TYPE',):
			tmpkey = 'HTTP_' + tmpkey

		val = self._collection[tmpkey]

		return six.text_type(val)

	def get(self, key, default=None):
		try:
			return self[key]
		except KeyError:
			return default


class RequestShim(CiocRequestMixin):
	def __init__(self, req, response):
		self.req = req
		self.GET = CollectionShim(req.QueryString)
		self.POST = CollectionShim(req.Form)
		self.params = MultiCollectionShim([req.QueryString, req.Form])
		self.cookies = CollectionShim(req.Cookies)
		self.headers = HeaderShim(req.ServerVariables)
		self.appvars = CollectionShim(req.ServerVariables)
		self.response = response

	@reify
	def language(self):
		return ShimSystemLanguage(self)

	@reify
	def application_url(self):
		applpath = six.text_type(self.appvars.get('APPL_PHYSICAL_PATH'))
		scriptpath = six.text_type(self.appvars.get('PATH_TRANSLATED'))
		scripturl = scriptpath[len(applpath):]

		return self.host_url + self.path[:-len(scripturl)]

	@reify
	def host_url(self):
		return self.scheme + '://' + self.host

	@reify
	def path_qs(self):
		qs = self.query_string
		if qs:
			qs = '?' + qs

		return self.path + qs

	@reify
	def path_url(self):
		return self.host_url + self.path

	@reify
	def scheme(self):
		return 'https' if self.headers.get('CIOC_USING_SSL') else 'http'

	@reify
	def url(self):
		return self.host_url + self.path_qs

	@reify
	def method(self):
		return six.text_type(self.appvars.get('REQUEST_METHOD'))

	@reify
	def host(self):
		return six.text_type(self.appvars.get('SERVER_NAME'))

	@reify
	def path(self):
		return six.text_type(self.appvars.get('PATH_INFO'))

	@reify
	def query_string(self):
		return six.text_type(self.appvars.get('QUERY_STRING'))

	@reify
	def remote_addr(self):
		return six.text_type(self.appvars.get('REMOTE_ADDR'))

	def cioc_set_cookie(self, key, value, **args):
		if value is None:
			value = u''
			if six.PY3:
				expires = pywintypes.Time(datetime(1997, 1, 1, 0,0,0).timestamp())
			else:
				expires = date(1997, 1, 1)
			args['expires'] = expires

		self.response.Cookies[key] = value
		for x, y in args.items():
			if y and x in ['path', 'domain', 'expires', 'secure']:
				setattr(self.response.Cookies[key], x.capitalize(), y)

	def cioc_get_cookie(self, key):
		return self.cookies.get(key)

	def add_response_callback(self, fn):
		"""
		Fake method to provide api compatibility.
		"""
		self.response_callbacks.append(fn)

	def add_finished_callback(self, fn):
		"""
		Fake method to provide api compatibility for session save.
		Session save in ASP will be managed by an explicit save call.
		"""
		self.finished_callbacks.append(fn)

	@reify
	def response_callbacks(self):
		return []

	@reify
	def finished_callbacks(self):
		return []

	registry = FakeRegistry


class ShimSystemLanguage(syslanguage.SystemLanguage):
	_public_methods_ = ['setSystemLanguage']
	_readonly_attrs_ = _public_attrs_ = syslanguage._culture_field_list + ['LocaleID']
