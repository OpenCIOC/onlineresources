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


from pyramid import testing, url
from cioc.core import viewbase, constants as const, pageinfo
from cioc.web import on_new_request, on_context_found

import logging
class DummyEvent(object):
	def __init__(self, request):
		self.request = request

log = logging.getLogger(__name__)
class Test_ViewBase(object):
	def setUp(self):

		self.config = testing.setUp()
		self.config.add_route('test_route', '/test')
		self.request = request = testing.DummyRequest()
		def route_url(route_name, *args, **kw):
			return url.route_url(route_name, request, *args, **kw)

		request.route_url = route_url
		on_new_request(DummyEvent(request))

		request.matched_route = 'test'

		on_context_found(DummyEvent(request))
		request.pageinfo = pageinfo.PageInfo(request, const.DM_CIC, const.DM_CIC)

	def tearDown(self):
		testing.tearDown()

	def _check_exc(self, exc, end):
		response = viewbase.redirect(exc, self.request)
		
		log.info(response.headers)

		assert 'Location' in response.headers
		url = response.headers['Location']

		assert url.startswith('http://')
		assert url.endswith(end)

	def test_redirect_view_gotoroute(self):

		exc = viewbase.GoToRoute('test_route')

		self._check_exc(exc, '/test')

	def test_redirect_view_gotopage(self):

		exc = viewbase.GoToPage('~/test.asp')

		self._check_exc(exc, '/test.asp')


	def test_redirect_view_security_failure(self):

		exc = viewbase.SecurityFailure()

		self._check_exc(exc, '/security_failure.asp')

		
		
	def test_base_class_go_to_page(self):
		vb = viewbase.ViewBase(self.request, const.DM_CIC, const.DM_CIC)
		
		try:
			vb._go_to_page('~/test.asp')
		except viewbase.GoToPage, e:
			assert e.url == '~/test.asp'
			assert e.httpvals is None
			assert e.exclude_keys is None
		else:
			assert False, "Didn't throw exception"


		try:
			vb._go_to_page('~/test.asp', 'orange', 'blue')
		except viewbase.GoToPage, e:
			assert e.url == '~/test.asp'
			assert e.httpvals == 'orange'
			assert e.exclude_keys == 'blue'
		else:
			assert False, "Didn't throw exception"
	
	def test_base_class_go_to_route(self):
		vb = viewbase.ViewBase(self.request, const.DM_CIC, const.DM_CIC)
		
		try:
			vb._go_to_route('test')
		except viewbase.GoToRoute, e:
			assert e.route_name == 'test'
			assert e.exclude_keys is None
			assert not e.kw
		else:
			assert False, "Didn't throw exception"


		try:
			vb._go_to_route('test', 'blue', orange='orange')
		except viewbase.GoToRoute, e:
			assert e.route_name == 'test'
			assert e.exclude_keys == 'blue'
			assert e.kw['orange'] == 'orange'
		else:
			assert False, "Didn't throw exception"

	def test_base_class_security_login(self):
		try:
			vb = viewbase.ViewBase(self.request, const.DM_CIC, const.DM_CIC, True)
		except viewbase.SecurityFailure:
			pass
		else:
			assert False, "Expected security failure"


	def test_base_class_no_public_access(self):
		from cioc.core import dboptions
		class DummyDbOptions(dboptions.DbOptions):
			def __init__(self, dboptions):
				self.dbopts = dboptions.dbopts

		dboptions = DummyDbOptions(self.request.dboptions)
		dboptions.AllowPublicAccess = False

		self.request.dboptions = dboptions

		try:
			vb = viewbase.ViewBase(self.request, const.DM_CIC, const.DM_CIC)
		except viewbase.SecurityFailure:
			pass
		else:
			assert False, "Expected security failure"
			

	def test_base_class_create_namespace(self):
		vb = viewbase.ViewBase(self.request, const.DM_CIC, const.DM_CIC)
		
		ns = vb._create_response_namespace("test page", "test doc", {'a': 'a'})

		assert ns['a'] == 'a'


		assert 'renderinfo' in ns

		self.config.add_settings({'mako.directories': 'cioc.web:templates'})

		r = vb._render_to_response('cioc.core.tests:empty.mak', 'test page', 'test doc', {'a': 'a'})

	def test_base_class_security_failure(self):
		vb = viewbase.ViewBase(self.request, const.DM_CIC, const.DM_CIC)
		try:
			vb._security_failure()
		except viewbase.SecurityFailure:
			pass
		else:
			assert False, "Expected security failure"

