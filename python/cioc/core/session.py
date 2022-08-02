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

import json
import functools

from pyramid_session_redis import RedisSessionFactory
from pyramid_session_redis.util import prefixed_id
from cioc.core.cache import EnhancedJSONEncoder, EnhancedJSONDecoder

from cioc.core import constants as const

_session_factory = None
_last_config_change = None


def session_dumps(obj):
    return json.dumps(obj, cls=EnhancedJSONEncoder).encode("utf-8")


def session_loads(value):
    return json.loads(value, cls=EnhancedJSONDecoder)


def get_session(request):
    global _session_factory, _last_config_change
    config = request.config

    if not _session_factory or _last_config_change != config["_last_change"]:
        _session_factory = RedisSessionFactory(
            cookie_name="ciocsession",
            cookie_secure=bool(request.headers.get("CIOC-SSL-POSSIBLE")),
            secret=config.get("session.secret", "|XMKo%DK5EisO:SI<&l+A;i2G"),
            id_generator=functools.partial(
                prefixed_id, prefix=f"{const._app_name}:session:"
            ),
            serialize=session_dumps,
            deserialize=session_loads,
            deserialized_fails_new=True,
            timeout=8 * 3600,  # 8 Hours
            redis_connection_pool=request.redispool,
        )

    return _session_factory(request)
