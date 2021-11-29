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
from functools import partial

from cioc.core import constants as const
from cioc.core.rootfactories import BasicRootFactory


def includeme(config):
	urlprefix = '/import/'

	# /import/upload
	factory = partial(BasicRootFactory, domain=const.DM_GLOBAL, db_area=const.DM_CIC)
	config.add_route('import_upload', urlprefix + 'upload', factory=factory)

	config.add_route('import_community_map', urlprefix + 'externalcommunities')
	config.add_route('import_community', urlprefix + 'community')

	factory = partial(BasicRootFactory, domain=const.DM_VOL, db_area=const.DM_VOL)
	config.add_route('import_upload_vol', '/volunteer' + urlprefix + 'upload', factory=factory)
