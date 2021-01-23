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
from pyramid.view import view_config, view_defaults

# this app
from cioc.core.i18n import gettext as _
from cioc.core.viewbase import ViewBase
from six.moves import map

log = logging.getLogger(__name__)

templateprefix = 'cioc.web.gbl:templates/'


def make_url(x):

	data = {
		'url': u'%s://%s' % (x.Protocol, x.AccessURL),
		'name': '%s (%s)' % (x.AccessURL, x.ViewName),
	}
	if x.URLViewType is not None:
		data['viewtype'] = x.URLViewType

	return data


@view_defaults(route_name='gbl_shortcodes', renderer=templateprefix + 'shortcodes.mak')
class ShortcodesView(ViewBase):

	@view_config(request_method='POST')
	def post(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		# at the moment just redirect to where we are
		self._go_to_route('gbl_shortcodes')

	@view_config()
	def get(self):
		request = self.request
		user = request.user

		cic_view_types = []
		vol_view_types = []
		keys = None
		if user.SuperUser:
			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @MemberID int
				SET @MemberID = ?
				EXEC sp_VOL_View_DomainMap_l @MemberID
				EXEC sp_CIC_View_DomainMap_l @MemberID
				EXEC sp_GBL_FeedAPIKey_l @MemberID, 1'''
				cursor = conn.execute(sql, request.dboptions.MemberID)

				vol_view_types = list(map(make_url, cursor.fetchall()))

				cursor.nextset()
				cic_view_types = list(map(make_url, cursor.fetchall()))

				cursor.nextset()

				keys = [{'key': x.FeedAPIKey, 'name': x.Owner, 'cic': x.CIC, 'vol': x.VOL} for x in cursor.fetchall()]
				cursor.close()

		title = _('Short Code Generator', request)
		return self._create_response_namespace(title, title, {'keys': keys, 'cic_domains': cic_view_types, 'vol_domains': vol_view_types}, no_index=True)
