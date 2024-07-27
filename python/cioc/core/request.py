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
import logging
import typing as t

# 3rd party libs
from pyramid.request import Request
from pyramid.decorator import reify

# This app
from cioc.core.syslanguage import SystemLanguage
from cioc.core import (
    asset,
    cache,
    config,
    connection,
    constants as const,
    dboptions,
    passvars,
    recentsearch,
    redispool,
    security,
    session,
    syslanguage,
    viewdata,
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
    def assetmgr(self):
        return asset.AssetManager(self)

    @reify
    def email_messages(self):
        return self.session.setdefault("email_messages", [])

    def email_notice(self, message):
        # log.debug(message)
        self.email_messages.append(message)
        self.session["email_messages"] = self.email_messages


class CiocRequest(CiocRequestMixin, Request):
    def __init__(self, *args, **kw):
        super().__init__(*args, **kw)

        # self.passvars

    def current_route_url(self, *elements, **kw):
        if "_query" not in kw:
            kw["_query"] = {}
        return super().current_route_url(*elements, **kw)
