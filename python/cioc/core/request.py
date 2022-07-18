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


# Python STD Lib
from http import cookies as http_cookies
import urllib.parse
import logging
import typing as t

# 3rd party libs
from pyramid.request import Request
from pyramid.decorator import reify

# This app
from cioc.core.syslanguage import SystemLanguage
from cioc.core import (
    passvars,
    config,
    connection,
    dboptions,
    security,
    cache,
    constants as const,
    recentsearch,
    syslanguage,
    viewdata,
    session,
    redispool,
)

if t.TYPE_CHECKING:
    from .pageinfo import PageInfo

log = logging.getLogger(__name__)


class CiocRequestMixin:
    added_gtranslate: bool = False
    pageinfo: t.Optional["PageInfo"]

    @reify
    def app_name(self) -> str:
        return const._app_name

    @reify
    def MemberID(self) -> int:
        return self.dboptions.MemberID

    @reify
    def language(self) -> SystemLanguage:
        return SystemLanguage(self)

    @reify
    def passvars(self) -> passvars.PassVars:
        return passvars.PassVars(self)

    @reify
    def config(self) -> dict:
        return config.get_config(const._config_file, const._app_name)

    @reify
    def connmgr(self) -> connection.ConnectionManager:
        return connection.ConnectionManager(self)

    @reify
    def cache(self):
        """
        Get the default cache instance which has an expire of an hour
        """
        val = cache.get_cache(self)
        return val

    @reify
    def dboptions(self) -> dboptions.DbOptions:
        val = dboptions.get_db_options(self)
        return val

    @reify
    def viewdata(self):
        val = viewdata.ViewData(self)
        val.UpdateCulture()
        return val

    @reify
    def redispool(self):
        return redispool.get_redis_pool(self)

    @reify
    def session(self):
        # session cookie key must have underscore url encoded because classic asp is silly
        return session.get_session(self)

    @reify
    def default_culture(self):
        return self.dboptions.DefaultCulture

    @reify
    def user(self):
        return security.User(self)

    @reify
    def recentsearches(self):
        return recentsearch.RecentSearchManager(self)

    @reify
    def multilingual_active(self):
        return len([x for x in syslanguage._culture_list if x.Active]) > 1

    @reify
    def multilingual_records(self):
        return len([x for x in syslanguage._culture_list if x.ActiveRecord]) > 1

    @reify
    def multilingual(self):
        return self.multilingual_records or self.multilingual_active

    @reify
    def email_messages(self):
        return self.session.setdefault("email_messages", [])

    def email_notice(self, message):
        # log.debug(message)
        self.email_messages.append(message)
        self.session["email_messages"] = self.email_messages

    def cioc_delete_cookie(self, name, path="/", domain=None):
        self.cioc_set_cookie(name, None, path=path, domain=domain)


class CiocRequest(CiocRequestMixin, Request):
    def __init__(self, *args, **kw):
        super().__init__(*args, **kw)

        self.passvars

    def cioc_get_cookie(self, name):
        val = self.cookies.get(urllib.parse.quote(name).replace("_", "%5F"))
        if val:
            val = urllib.parse.unquote(val)
        return val

    def cioc_set_cookie(self, name, value, **args):
        cookie = http_cookies.SimpleCookie()
        key = urllib.parse.quote(name).replace("_", "%5F")
        if value is None:
            # deleting value
            value = ""
            args["max_age"] = 0
            args["expires"] = "Wed, 31-Dec-97 23:59:59 GMT"
        cookie[key] = urllib.parse.quote(value)
        morsel = cookie[key]
        morsel.update((x, y) for x, y in args.items() if y is not None)

        self.response.headerlist.append(("Set-Cookie", cookie.output(header="")))

    def current_route_url(self, *elements, **kw):
        if "_query" not in kw:
            kw["_query"] = {}
        return super().current_route_url(*elements, **kw)
