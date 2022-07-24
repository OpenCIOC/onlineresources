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

# std lib
import json
import datetime
import decimal
import sys

# 3rd party
from dogpile.cache import make_region
from dogpile.cache.api import CachedValue

# this app
from cioc.core import constants as const
from cioc.core.recentsearch import RecentSearches


def key_mangler(key):
    return const._app_name + ":" + key


_region = None
_cache_last_changed = None


def get_cache(request):
    global _cache_last_changed, _region
    if _region is None or _cache_last_changed != request.config["_last_change"]:
        _region = make_region(key_mangler=key_mangler)
        args = {
            "connection_pool": request.redispool,
            "redis_expiration_time": 60 * 60 * 2,  # 2 hours
            "distributed_lock": True,
            "thread_local_lock": False,
            "lock_timeout": 0.5,
            "lock_sleep": 0.1,
            "serializer": cache_dumps,
            "deserializer": cache_loads,
        }
        args.update(request.redispool.connection_kwargs)
        _region.configure(
            "dogpile.cache.redis",
            expiration_time=3600,
            arguments=args,
        )

        _cache_last_changed = request.config["_last_change"]

    return _region


class EnhancedJSONEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            ARGS = ("year", "month", "day", "hour", "minute", "second", "microsecond")
            return {
                "__type__": "datetime.datetime",
                "args": [getattr(obj, a) for a in ARGS],
            }
        elif isinstance(obj, datetime.date):
            ARGS = ("year", "month", "day")
            return {
                "__type__": "datetime.date",
                "args": [getattr(obj, a) for a in ARGS],
            }
        elif isinstance(obj, datetime.time):
            ARGS = ("hour", "minute", "second", "microsecond")
            return {
                "__type__": "datetime.time",
                "args": [getattr(obj, a) for a in ARGS],
            }
        elif isinstance(obj, datetime.timedelta):
            ARGS = ("days", "seconds", "microseconds")
            return {
                "__type__": "datetime.timedelta",
                "args": [getattr(obj, a) for a in ARGS],
            }
        elif isinstance(obj, decimal.Decimal):
            return {"__type__": "decimal.Decimal", "args": [str(obj)]}
        elif isinstance(obj, RecentSearches):
            return {"__type__": "RecentSearches", "args": [obj.values()]}
        else:
            return super().default(obj)


class EnhancedJSONDecoder(json.JSONDecoder):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, object_hook=self.object_hook, **kwargs)

    def object_hook(self, d):
        if "__type__" not in d:
            return d
        o = sys.modules[__name__]
        for e in d["__type__"].split("."):
            o = getattr(o, e)
        args, kwargs = d.get("args", ()), d.get("kwargs", {})
        return o(*args, **kwargs)


def cache_dumps(value, dumps=json.dumps, cls=EnhancedJSONEncoder):
    return dumps(value, cls=cls)


def cache_loads(value, loads=json.loads, cls=EnhancedJSONDecoder):
    return CachedValue(*loads(value, cls=cls))
