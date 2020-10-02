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
from redis import ConnectionPool

_redispool = None
_redisurl = None


def get_redis_pool(request):
	config = request.config
	url = config.get('session.url', '172.23.16.12:6379')

	global _redispool, _redisurl
	if not _redispool or url != _redisurl:
		if _redispool:
			# address change disconnect all connections
			_redispool.disconnect()

		host, port = url.split(':')
		_redispool = ConnectionPool(host=host, port=int(port))
		_redisurl = url

	return _redispool
