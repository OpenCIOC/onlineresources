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


# Logging
import logging
log = logging.getLogger(__name__)

# Python Libraries

# 3rd Party Libraries
from pyramid.view import view_config

# CIOC Libraries
from cioc.core import constants as const, i18n
from cioc.core.viewbase import ViewBase
from cioc.core.rootfactories import BasicRootFactory

templateprefix = 'cioc.web:templates/'

_ = i18n.gettext


@view_config(renderer=templateprefix + 'recentsearches.mak', route_name='cic_recentsearch')
@view_config(renderer=templateprefix + 'recentsearches.mak', route_name='vol_recentsearch')
class RecentSearchHistory(ViewBase):
	def __init__(self, request):
		ViewBase.__init__(self, request, require_login=True)

	def __call__(self):
		request = self.request
		user = request.user

		if not user:
			self._security_failure()

		if request.pageinfo.DbArea == const.DM_CIC:
			recentsearches = request.recentsearches.cic
		else:
			recentsearches = request.recentsearches.vol

		title = _('Recent Search History', request)
		return self._create_response_namespace(title, title, dict(recentsearches=recentsearches), no_index=True)


class RecentSearchRootFactory(BasicRootFactory):
	def __init__(self, request):
		if request.matched_route.name == 'cic_recentsearch':
			domain = const.DM_GLOBAL
			db_area = const.DM_CIC
		else:
			domain = db_area = const.DM_VOL
		BasicRootFactory.__init__(self, request, domain, db_area)
