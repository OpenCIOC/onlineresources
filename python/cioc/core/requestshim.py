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

from collections.abc import Mapping

# 3rd party
from pyramid.decorator import reify
from webob.cookies import make_cookie

# this app
from cioc.core import syslanguage
from cioc.core.request import CiocRequestMixin
from cioc.core.modelstate import ModelState

import typing as t

if t.TYPE_CHECKING:
    from functools import cached_property as reify


class FakeRegistry:
    pass


class CollectionShim:
    def __init__(self, collection):
        self._collection = collection

    def __getitem__(self, key):
        val = self._collection(key)
        if callable(val):
            val = val()
        if val is None:
            raise KeyError(key)

        return str(val)

    def __iter__(self):
        return iter(self._collection)

    def get(self, key, default=None):
        try:
            return self[key]
        except KeyError:
            return default


class MultiMappingShim(Mapping):
    def __init__(self, collection):
        self._collection = collection

    def __getitem__(self, key):
        val = self._collection(key)
        if not val.Count:
            raise KeyError(key)
        return str(val(val.Count))

    def keys(self):
        return iter(self._collection)

    __iter__ = keys

    def items(self):
        for key in self._collection:
            for val in self._collection(key):
                yield (key, val)

    def values(self):
        for key in self._collection:
            yield from self._collection(key)

    def __len__(self):
        return sum(self._collection(x).Count for x in self._collection)

    def mixed(self):
        """
        Returns a dictionary where the values are either single
        values, or a list of values when a key/value appears more than
        once in this dictionary.  This is similar to the kind of
        dictionary often used to represent the variables in a web
        request.
        """
        result = {}
        multi = {}
        for key, value in self.items():
            if key in result:
                # We do this to not clobber any lists that are
                # *actual* values in this dictionary:
                if key in multi:
                    result[key].append(value)
                else:
                    result[key] = [result[key], value]
                    multi[key] = None
            else:
                result[key] = value
        return result


_dummy = object()


class NestedMultiMappingShim(MultiMappingShim):
    def __init__(self, collections):
        self._collections = collections

    def __getitem__(self, key):
        for col in self._collections:
            value = col.get(key, _dummy)
            if value is not _dummy:
                return value

        raise KeyError(key)

    def keys(self):
        for col in self._collections:
            yield from col

    __iter__ = keys

    def items(self):
        for col in self._collections:
            yield from col.items()

    def values(self):
        for col in self._collections:
            yield from col.values()

    def __len__(self):
        return sum(len(x) for x in self._collections)


class HeaderShim:
    def __init__(self, collection):
        self._collection = CollectionShim(collection)

    def __getitem__(self, key):
        tmpkey = key.upper().replace("-", "_")
        if tmpkey not in ("CONTENT_TYPE",):
            tmpkey = "HTTP_" + tmpkey

        val = self._collection[tmpkey]

        return str(val)

    def get(self, key, default=None):
        try:
            return self[key]
        except KeyError:
            return default


class ResponseHeaderShim:
    def __init__(self, response):
        self._response = response
        self._headers = {}

    def __getitem__(self, key):
        return self._headers[key.casefold()]

    def __setitem__(self, key, value):
        self._headers[key.casefold()] = value
        self._response.AddHeader(key, value)


class ResponseShim:
    def __init__(self, request, response):
        self._response = response
        self._request = request
        self.vary = None
        self.headers = ResponseHeaderShim(response)

    def __getattr__(self, name):
        return getattr(self._response, name)

    def set_cookie(self, name, value="", **args):
        if isinstance(value, str):
            value = value.encode("utf-8")
        cookie = make_cookie(name, value, **args)
        self._response.AddHeader("Set-Cookie", cookie)

    def delete_cookie(self, name, path="/", domain=None):
        self.set_cookie(name, None, path=path, domain=domain)


class RequestShim(CiocRequestMixin):
    def __init__(self, req, response):
        self.req = req
        self.GET = MultiMappingShim(req.QueryString)
        self.POST = MultiMappingShim(req.Form)
        self.params = NestedMultiMappingShim([self.GET, self.POST])
        self.cookies = CollectionShim(req.Cookies)
        self.headers = HeaderShim(req.ServerVariables)
        self.appvars = CollectionShim(req.ServerVariables)
        self.response = ResponseShim(self, response)

    @reify
    def language(self):
        return ShimSystemLanguage(self)

    @reify
    def application_url(self):
        applpath = str(self.appvars.get("APPL_PHYSICAL_PATH"))
        scriptpath = str(self.appvars.get("PATH_TRANSLATED"))
        scripturl = scriptpath[len(applpath) :]

        return self.host_url + self.path[: -len(scripturl)]

    @reify
    def host_url(self):
        return self.scheme + "://" + self.host

    @reify
    def path_qs(self):
        qs = self.query_string
        if qs:
            qs = "?" + qs

        return self.path + qs

    @reify
    def path_url(self):
        return self.host_url + self.path

    @reify
    def scheme(self):
        return "https" if self.headers.get("CIOC-USING-SSL") else "http"

    @reify
    def url(self):
        return self.host_url + self.path_qs

    @reify
    def method(self):
        return str(self.appvars.get("REQUEST_METHOD"))

    @reify
    def host(self):
        return str(self.appvars.get("SERVER_NAME"))

    @reify
    def path(self):
        return str(self.appvars.get("PATH_INFO"))

    @reify
    def query_string(self):
        return str(self.appvars.get("QUERY_STRING"))

    @reify
    def remote_addr(self):
        return str(self.appvars.get("REMOTE_ADDR"))

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

    @reify
    def model_state(self):
        return ModelState(self)

    exception = None

    registry = FakeRegistry


class ShimSystemLanguage(syslanguage.SystemLanguage):
    _public_methods_ = ["setSystemLanguage"]
    _readonly_attrs_ = _public_attrs_ = syslanguage._culture_field_list + ["LocaleID"]
