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

from cioc.core import constants as const, validators
from cioc.core.rootfactories import AllowSSLRootFactory, RequireSSLRootFactory


def includeme(config):
	urlprefix = '/rpc/'

	cicfactory = partial(AllowSSLRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC, allow_api_login=True)
	# /rpc/record/*
	config.add_route('rpc_orgdetails', urlprefix + 'record/{num:[A-Za-z]{3}\d{4,5}}',
		factory=cicfactory)

	volfactory = partial(AllowSSLRootFactory, domain=const.DM_VOL, db_area=const.DM_VOL, allow_api_login=True)
	config.add_route('rpc_oppdetails', urlprefix + 'opportunity/{vnum:V-[A-Za-z]{3}\d{4,5}}',
		factory=volfactory)

	config.add_route('rpc_oppdetails_opid', urlprefix + 'opportunity/{opid:\d+}',
		factory=volfactory)

	config.add_route('rpc_browseoppbyorg', urlprefix + 'browseoppbyorg',
		factory=volfactory)

	ssl_factory = partial(RequireSSLRootFactory, allow_api_login=True)
	config.add_route('rpc_whoami', urlprefix + 'whoami', factory=ssl_factory)

	config.add_route('rpc_countall', urlprefix + 'countall/{domain:(cic|vol)}', factory=ssl_factory)

	config.add_route('rpc_agegrouplist', urlprefix + 'agegrouplist', factory=ssl_factory)

	heading_list_path = urlprefix + 'quicklist/{pubcode:' + validators.code_validator_re[1:-1] + '}'
	config.add_route('rpc_headinglist', heading_list_path, factory=ssl_factory)

	config.add_route('rpc_quicklist', urlprefix + 'quicklist', factory=ssl_factory)
