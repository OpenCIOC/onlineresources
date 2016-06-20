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
from pyramid.view import view_config, view_defaults

# CIOC Libraries
from cioc.core import i18n
from cioc.web.cic.viewbase import CicViewBase

templateprefix = 'cioc.web.cic:templates/taxonomy/'

_ = i18n.gettext


@view_defaults(route_name='cic_taxonomy', match_param='action=currentactivation')
class MultiLevelReportView(CicViewBase):
	def __init__(self, request, require_login=True):
		CicViewBase.__init__(self, request, require_login)

	@view_config(renderer=templateprefix + 'currentactivation.mak')
	def multilevelreport(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		terms = []
		with request.connmgr.get_connection('admin') as conn:
			terms = conn.execute('EXEC dbo.sp_TAX_Term_ActiveUsed_l ?', request.dboptions.MemberID).fetchall()

		title = _('Taxonomy Activation and Usage Report', request)
		return self._create_response_namespace(title, title, dict(terms=terms), no_index=True)
