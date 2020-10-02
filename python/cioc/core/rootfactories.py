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
from . import constants as const
viewbase = None


class BaseRootFactory(object):
	allow_ssl = False
	require_ssl = False
	dont_redirect = False
	force_print_mode = False
	allow_api_login = False


class BasicRootFactory(BaseRootFactory):

	def __init__(self, request, domain=const.DM_GLOBAL, db_area=const.DM_GLOBAL, **kwargs):
		for key, val in kwargs.items():
			setattr(self, key, val)

		request.context = self
		global viewbase
		if not viewbase:
			from . import viewbase
		viewbase.init_page_info(request, domain, db_area)


class AllowSSLRootFactory(BasicRootFactory):
	allow_ssl = True
	require_ssl = False


class RequireSSLRootFactory(BasicRootFactory):
	allow_ssl = True
	require_ssl = True
