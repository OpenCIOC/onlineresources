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


# stdlib
from __future__ import absolute_import
import logging

# 3rd party
from pyramid.view import view_config

# this app
from cioc.web.cic import viewbase

log = logging.getLogger(__name__)


@view_config(route_name='jsonfeeds_taxcodes', renderer='json')
class JsonFeedsIcons(viewbase.CicViewBase):

	def __call__(self):
		request = self.request

		term = request.params.get('term')
		if term:
			term = term.strip()
		if not term:
			return []

		if len(term) > 60:
			return []

		args = [request.dboptions.MemberID, term]

		sql = """
			EXEC sp_CIC_TaxCode_Finder ?, ?
		"""

		with request.connmgr.get_connection('cic') as conn:
			codes = conn.execute(sql, args).fetchall()

		return [{'value': x.Code, 'label': x.Term} for x in codes]
