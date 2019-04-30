# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

from functools import partial

from cioc.core import constants as const
from cioc.core.rootfactories import BasicRootFactory
from cioc.web.gbl.emaillist import EmailListContext


def includeme(config):
	urlprefix = '/'

	# /recordlist
	factory = partial(EmailListContext, domain=const.DM_GLOBAL, db_area=const.DM_CIC)
	config.add_route('record_list_cic', urlprefix + 'recordlist', factory=factory)

	factory = partial(BasicRootFactory, domain=const.DM_GLOBAL, db_area=const.DM_CIC)
	config.add_route('pages_cic', urlprefix + 'pages/{slug}', factory=factory)

	factory = partial(BasicRootFactory, domain=const.DM_GLOBAL, db_area=const.DM_CIC)
	config.add_route('sched_upcoming_cic', urlprefix + 'events/upcoming', factory=factory)

	# /volunteer/recordlist
	factory = partial(EmailListContext, domain=const.DM_VOL, db_area=const.DM_VOL)
	config.add_route('record_list_vol', '/volunteer' + urlprefix + 'recordlist', factory=factory)

	factory = partial(BasicRootFactory, domain=const.DM_VOL, db_area=const.DM_VOL)
	config.add_route('pages_vol', '/volunteer' + urlprefix + 'pages/{slug}', factory=factory)

	factory = partial(BasicRootFactory, domain=const.DM_VOL, db_area=const.DM_VOL)
	config.add_route('sched_upcoming_vol', '/volunteer' + urlprefix + 'events/upcoming', factory=factory)

	# /shortcodes
	factory = partial(BasicRootFactory, domain=const.DM_GLOBAL, db_area=const.DM_GLOBAL)
	config.add_route('gbl_shortcodes', urlprefix + 'shortcodes')

	# /iconlist
	factory = partial(BasicRootFactory, domain=const.DM_GLOBAL, db_area=const.DM_GLOBAL)
	config.add_route('gbl_iconlist', urlprefix + 'iconlist')
