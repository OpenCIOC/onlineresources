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

# 3rd party
from dogpile.cache import make_region

# this app
from cioc.core import constants as const


def key_mangler(key):
	return const._app_name + ':' + key


_region = None
_cache_last_changed = None


def get_cache(request):
	global _cache_last_changed, _region
	if _region is None or _cache_last_changed != request.config['_last_change']:
		_region = make_region(key_mangler=key_mangler)
		args = {
			'connection_pool': request.redispool,
			'redis_expiration_time': 60 * 60 * 2,   # 2 hours
			'distributed_lock': True,
			'lock_timeout': .5,
			'lock_sleep': .1
		}
		args.update(request.redispool.connection_kwargs)
		_region.configure(
			'dogpile.cache.redis',
			expiration_time=3600,
			arguments=args
		)

		_cache_last_changed = request.config['_last_change']

	return _region
