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

from urllib.parse import urlencode
from urllib.parse import parse_qs
import posixpath

from pyramid import httpexceptions
from markupsafe import Markup

import cioc.core.syslanguage as syslanguage
from cioc.core.basetypes import IsIDType

import logging

log = logging.getLogger(__name__)


class PassVars:
    """
    Extract the passed variables out of a request and create urls that pass them on
    """

    def __init__(self, request):
        self.request = request
        self.httpvals = {}
        self.record_root = request.headers.get("CIOC-FRIENDLY-RECORD-URL-ROOT")
        self.path_from_start = request.application_url[len(request.host_url) :]
        if not self.path_from_start:
            self.path_from_start = "/"

        self.listeners = []

        self.UseViewCIC = None
        self.UseViewVOL = None

        self.initialize()

    def initialize(self):
        request = self.request

        ln = None
        try:
            if request.params.get("UseEq", "").lower() == "on":
                ln = syslanguage.CULTURE_FRENCH_CANADIAN
            else:
                try:
                    ln = request.params["Ln"].strip()[:5]
                except KeyError:
                    pass
        except UnicodeDecodeError:
            raise httpexceptions.HTTPBadRequest()

        if ln and syslanguage.is_active_culture(ln):
            self.RequestLn = ln
        else:
            self.RequestLn = None

        syslanguage.record_root = self.record_root
        self.setDefaultCultureVars(
            request.dboptions.DefaultCulture or syslanguage.CULTURE_ENGLISH_CANADIAN,
            True,
        )

        try:
            UseViewCIC = int(request.params["UseCICVw"])
            if not IsIDType(UseViewCIC):
                raise ValueError(UseViewCIC)

            self.httpvals["UseCICVw"] = UseViewCIC
        except (KeyError, ValueError):
            try:
                del self.httpvals["UseCICVw"]
            except KeyError:
                pass

        try:
            UseViewVOL = int(request.params["UseVOLVw"])
            if not IsIDType(UseViewVOL):
                raise ValueError(UseViewVOL)
            self.httpvals["UseVOLVw"] = UseViewVOL
        except (KeyError, ValueError):
            try:
                del self.httpvals["UseVOLVw"]
            except KeyError:
                pass

        self._clear_cached_values()

        self._notify()

    def _get_http_items(self, exclude_keys=None):
        """Return the items to include as a key,val tuple generator"""

        if not exclude_keys:
            exclude_keys = ()
        elif isinstance(exclude_keys, str):
            exclude_keys = (exclude_keys,)

        items = [
            (key, val)
            for (key, val) in self.httpvals.items()
            if key not in exclude_keys
        ]
        return items

    def getHTTPVals(self, exclude_keys=None, bForm=False):
        items = self._get_http_items(exclude_keys)
        if not bForm:
            return urlencode(list(items))

        tmpl = Markup('<input type="hidden" name="%(key)s" value="%(val)s">')
        return Markup("").join(tmpl % {"key": key, "val": val} for (key, val) in items)

    def makeDetailsLink(self, num, httpvals=None, exclude_keys=None):
        if self.record_root:
            return self.makeLink(
                posixpath.join(self.path_from_start, self.record_root, str(num)),
                httpvals,
                exclude_keys,
            )

        vals = {"NUM": num}
        if httpvals:
            if isinstance(httpvals, str):
                httpvals = {
                    k: ",".join(v) for (k, v) in parse_qs(httpvals, True).items()
                }
            vals.update(httpvals)

        return self.makeLink(
            posixpath.join(self.path_from_start, "details.asp"), vals, exclude_keys
        )

    def makeVOLDetailsLink(self, vnum, httpvals=None, exclude_keys=None):
        if self.record_root:
            return self.makeLink(
                posixpath.join(
                    self.path_from_start, "volunteer", self.record_root, str(vnum)
                ),
                httpvals,
                exclude_keys,
            )

        vals = {"VNUM": vnum}
        if httpvals:
            if isinstance(httpvals, str):
                httpvals = {
                    k: ",".join(v) for (k, v) in parse_qs(httpvals, True).items()
                }
            vals.update(httpvals)

        return self.makeLink(
            posixpath.join(self.path_from_start, "volunteer", "details.asp"),
            vals,
            exclude_keys,
        )

    def makeLink(self, url, httpvals=None, exclude_keys=None):
        vars = []

        if exclude_keys:
            passvars = self.getHTTPVals(exclude_keys)
        else:
            passvars = self.cached_url_vals

        if passvars:
            vars.append(passvars)

        if httpvals:
            if isinstance(httpvals, str):
                vars.append(httpvals)

            elif isinstance(httpvals, (dict, list, tuple)):
                if isinstance(httpvals, dict):
                    httpvals = list(httpvals.items())

                force_utf8 = (
                    lambda x: x if not isinstance(x, str) else x.encode("utf-8")
                )
                vars.append(
                    urlencode([(force_utf8(k), force_utf8(v)) for k, v in httpvals])
                )

            else:
                raise Exception("Ooops I got an unexpected type for httpvals")

        if vars:
            vars = "?" + "&".join(vars)

        else:
            vars = ""

        if url.startswith("~/"):
            # log.debug(self.request.pageinfo.application_path)
            # log.debug(self.request.host_url)
            url = self.request.pageinfo.application_path + url[1:]
            if not url:
                url = "/"

        return url + vars

    def _route_core(self, fn, exclude_keys, **kw):
        _query = self._get_http_items(exclude_keys)
        if "_query" in kw and _query:
            _q = kw.pop("_query")
            if isinstance(_q, dict):
                _q = list(_q.items())
            _query = _query + list(_q)

        if _query:
            kw["_query"] = _query

        return fn(kw)

    def route_url(self, route_name, exclude_keys=None, **kw):
        return self._route_core(
            lambda x: self.request.route_url(route_name, **x), exclude_keys, **kw
        )

    def route_path(self, route_name, exclude_keys=None, **kw):
        return self._route_core(
            lambda x: self.request.route_path(route_name, **x), exclude_keys, **kw
        )

    def current_route_path(self, exclude_keys=None, **kw):
        return self._route_core(
            lambda x: self.request.current_route_path(**x), exclude_keys, **kw
        )

    def makeLinkAdmin(self, url, httpvals=None):
        if not httpvals:
            httpvals = {}
        elif isinstance(httpvals, str):
            httpvals = {k: ",".join(v) for (k, v) in parse_qs(httpvals, True).items()}

        default_culture = self.request.default_culture
        current_culture = self.request.language.Culture

        if default_culture != current_culture and "Ln" not in self.httpvals:
            httpvals["Ln"] = current_culture
            passvars = self.getHTTPVals(("Ln",))

        else:
            passvars = self.cached_url_vals

        vars = []
        if passvars:
            vars.append(passvars)

        if httpvals:
            vars.append(urlencode(httpvals))

        if vars:
            vars = "?" + "&".join(vars)
        else:
            vars = ""

        return posixpath.join(self.path_from_start, "admin", url) + vars

    def setDefaultCultureVars(self, strDefaultCulture, skip_notify=False):
        lang = self.request.language
        if strDefaultCulture:
            if syslanguage.is_active_culture(strDefaultCulture):
                culture = strDefaultCulture
            else:
                try:
                    culture = syslanguage._culture_list[0].Culture
                except IndexError:
                    # set default culture to english
                    culture = syslanguage.CULTURE_ENGLISH_CANADIAN

            self.DefaultCulture = culture

        # If the Ln parameter is different from default we
        # must be able to pass it
        if self.RequestLn == self.DefaultCulture:
            try:
                del self.httpvals["Ln"]
            except KeyError:
                pass
        elif self.RequestLn:
            self.httpvals["Ln"] = self.RequestLn

        self._clear_cached_values()

        # We may have altered the current session language
        if self.RequestLn:
            lang.setSystemLanguage(self.RequestLn)
        else:
            lang.setSystemLanguage(self.DefaultCulture)

        if not skip_notify:
            self._notify()

    def _clear_cached_values(self):
        if hasattr(self, "_cached_url_vals"):
            del self._cached_url_vals
        if hasattr(self, "_cached_form_vals"):
            del self._cached_form_vals

    @property
    def cached_url_vals(self):
        if not hasattr(self, "_cached_url_vals"):
            self._cached_url_vals = self.getHTTPVals()

        return self._cached_url_vals

    @property
    def cached_form_vals(self):
        if not hasattr(self, "_cached_form_vals"):
            self._cached_form_vals = self.getHTTPVals(bForm=True)

        return self._cached_form_vals

    @property
    def UseViewCIC(self):
        return self.httpvals.get("UseCICVw")

    @UseViewCIC.setter
    def UseViewCIC(self, value):
        if value is None:
            try:
                del self.httpvals["UseCICVw"]
            except KeyError:
                pass
        else:
            self.httpvals["UseCICVw"] = value

        self._clear_cached_values()
        self._notify()

    @property
    def UseViewVOL(self):
        return self.httpvals.get("UseVOLVw")

    @UseViewVOL.setter
    def UseViewVOL(self, value):
        if value is None:
            try:
                del self.httpvals["UseVOLVw"]
            except KeyError:
                pass
        else:
            self.httpvals["UseVOLVw"] = value

        self._clear_cached_values()
        self._notify()

    def addListener(self, fn):
        self.listeners.append(fn)

    def _notify(self):
        for fn in self.listeners:
            fn(self)
