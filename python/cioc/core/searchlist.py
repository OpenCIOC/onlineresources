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
from cioc.core import constants as const
import six


def get_search_list(request, dbarea):
	if dbarea == const.DM_CIC:
		key = 'aNUMSearchList'

	elif dbarea == const.DM_VOL:
		key = 'aOPIDSearchList'
	else:
		return []

	value = request.session.get(key)

	if value:
		return six.text_type(value).split(u',')
