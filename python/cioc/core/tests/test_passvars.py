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
from pyramid import testing, url

from cioc.core import syslanguage
from cioc.core.passvars import PassVars


class Test_PassVars(object):
    def setUp(self):

        self.config = testing.setUp()
        self.config.add_route("root_route", "/")
        self.config.add_route("test_route", "/test")

    def tearDown(self):
        testing.tearDown()

    def _make_request(self, **kw):
        request = testing.DummyRequest(**kw)

        def route_url(route_name, *args, **kw):
            return url.route_url(route_name, request, *args, **kw)

        request.route_url = route_url

        request.language = syslanguage.SystemLanguage()

        return request

    def test_basic(self):
        request = self._make_request()
        pv = PassVars(request)

        assert not pv.UseViewCIC
        assert not pv.UseViewVOL

        assert not pv.record_root
        assert not pv.httpvals

        assert not pv.getHTTPVals()

        assert pv.cached_url_vals is pv.cached_url_vals
        assert pv.cached_form_vals is pv.cached_form_vals

    def test_makelink(self):
        request = self._make_request()
        pv = PassVars(request)

        assert pv.makeLink("blah.asp") == "blah.asp"
        assert pv.makeLink("blah.asp", "AB=CD") == "blah.asp?AB=CD"
        assert pv.makeLink("blah.asp", "AB=CD&CD=DF") == "blah.asp?AB=CD&CD=DF"

        assert pv.makeLink("blah.asp", {"AB": "CD"}) == "blah.asp?AB=CD"

        request.params["UseCICVw"] = 1

        pv = PassVars(request)

        assert pv.makeLink("blah.asp") == "blah.asp?UseCICVw=1"
        assert pv.makeLink("blah.asp", "AB=CD") == "blah.asp?UseCICVw=1&AB=CD"
        assert pv.makeLink("blah.asp", {"AB": "CD"}) == "blah.asp?UseCICVw=1&AB=CD"

        assert pv.makeLink("blah.asp", exclude_keys="UseCICVw") == "blah.asp"
        assert (
            pv.makeLink("blah.asp", "AB=CD", exclude_keys="UseCICVw")
            == "blah.asp?AB=CD"
        )
        assert (
            pv.makeLink("blah.asp", {"AB": "CD"}, exclude_keys="UseCICVw")
            == "blah.asp?AB=CD"
        )

        assert pv.makeLink("blah.asp", exclude_keys=("UseCICVw",)) == "blah.asp"
        assert pv.makeLink("blah.asp", exclude_keys=("Use",)) == "blah.asp?UseCICVw=1"
