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


from functools import partial

from cioc.core import constants as const
from cioc.core.rootfactories import BasicRootFactory


def includeme(config):
	urlprefix = '/stats/'

	# /stats/auto_datamgmt
	factory = partial(BasicRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC)
	config.add_route('stats_auto_datamgmt_cic', urlprefix + 'auto_datamgmt', factory=factory)

	factory = partial(BasicRootFactory, domain=const.DM_VOL, db_area=const.DM_VOL)
	config.add_route('stats_auto_datamgmt_vol', '/volunteer' + urlprefix + 'auto_datamgmt', factory=factory)

	# /stats/auto_viewsbyro
	factory = partial(BasicRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC)
	config.add_route('stats_auto_viewsbyro_cic', urlprefix + 'auto_viewsbyro', factory=factory)

	factory = partial(BasicRootFactory, domain=const.DM_VOL, db_area=const.DM_VOL)
	config.add_route('stats_auto_viewsbyro_vol', '/volunteer' + urlprefix + 'auto_viewsbyro', factory=factory)

	# /stats/auto_viewsbyview
	factory = partial(BasicRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC)
	config.add_route('stats_auto_viewsbyview_cic', urlprefix + 'auto_viewsbyview', factory=factory)

	factory = partial(BasicRootFactory, domain=const.DM_VOL, db_area=const.DM_VOL)
	config.add_route('stats_auto_viewsbyview_vol', '/volunteer' + urlprefix + 'auto_viewsbyview', factory=factory)

	# /stats/auto_ipsbyro
	factory = partial(BasicRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC)
	config.add_route('stats_auto_ipsbyro_cic', urlprefix + 'auto_ipsbyro', factory=factory)

	factory = partial(BasicRootFactory, domain=const.DM_VOL, db_area=const.DM_VOL)
	config.add_route('stats_auto_ipsbyro_vol', '/volunteer' + urlprefix + 'auto_ipsbyro', factory=factory)

	# /stats/auto_ipsbyview
	factory = partial(BasicRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC)
	config.add_route('stats_auto_ipsbyview_cic', urlprefix + 'auto_ipsbyview', factory=factory)

	factory = partial(BasicRootFactory, domain=const.DM_VOL, db_area=const.DM_VOL)
	config.add_route('stats_auto_ipsbyview_vol', '/volunteer' + urlprefix + 'auto_ipsbyview', factory=factory)

	# /stats/auto_ipsbyview
	factory = partial(BasicRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC)
	config.add_route('stats_auto_ips_cic', urlprefix + 'auto_ips', factory=factory)

	factory = partial(BasicRootFactory, domain=const.DM_VOL, db_area=const.DM_VOL)
	config.add_route('stats_auto_ips_vol', '/volunteer' + urlprefix + 'auto_ips', factory=factory)
