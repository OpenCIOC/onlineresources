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
from pyramid.httpexceptions import HTTPUnauthorized, HTTPForbidden, HTTPInternalServerError
from pyramid.view import view_config

# this app
from cioc.core import i18n
from cioc.core import viewbase
from six.moves import map
from six.moves import zip

log = logging.getLogger(__name__)

_ = i18n.gettext


def make_headers(extra_headers=None):
	tmp = dict(extra_headers or {})
	return tmp


def make_401_error(message, realm='CIOC RPC'):
	error = HTTPUnauthorized(headers=make_headers({'WWW-Authenticate': 'Basic realm="%s"' % realm}))
	error.content_type = "text/plain"
	error.text = message
	return error


def make_403_error(message, realm='CIOC RPC'):
	error = HTTPForbidden()
	error.content_type = "text/plain"
	error.text = message
	return error


def make_internal_server_error(message):
	error = HTTPInternalServerError()
	error.content_type = "text/plain"
	error.text = message
	return error


@view_config(route_name='jsonfeeds_quicklist', renderer='json')
@view_config(route_name='jsonfeeds_headinglist', renderer='json')
@view_config(route_name='rpc_quicklist', renderer='json')
@view_config(route_name='rpc_headinglist', renderer='json')
class JsonfeedsQuicklist(viewbase.ViewBase):

	def __call__(self):
		request = self.request

		if request.matched_route.name.startswith('rpc_') and not request.user:
			return make_401_error(u'Access Denied')

		cic_view = request.viewdata.cic
		pub_code = request.matchdict.get('pubcode')
		add_count = request.params.get('count')

		if pub_code:
			type_name = 'Headings'
			sql = 'EXEC dbo.sp_CIC_GeneralHeading_l' + ('_Count' if add_count else '') + ' ?,NULL, NULL,?,0,1,?'
			args = [cic_view.ViewType if add_count else request.dboptions.MemberID, True if cic_view.CanSeeNonPublicPub is None else cic_view.CanSeeNonPublicPub, pub_code]
		elif not (cic_view.LimitedView or cic_view.QuickListPubHeadings):
			type_name = 'Publications'
			sql = 'EXEC dbo.sp_CIC_Publication_l' + ('_Count' if add_count else '') + ' ?, 0, NULL'
			args = [cic_view.ViewType]
		else:
			type_name = 'Headings'
			sql = 'EXEC dbo.sp_CIC_GeneralHeading_l' + ('_Count' if add_count else '') + ' ?,?,NULL,?,0,1'
			args = [cic_view.ViewType if add_count else request.dboptions.MemberID, cic_view.QuickListPubHeadings or cic_view.PB_ID, True if cic_view.CanSeeNonPublicPub is None else cic_view.CanSeeNonPublicPub]

		with request.connmgr.get_connection('cic') as conn:
			cursor = conn.execute(sql, args)
			quicklist = cursor.fetchall()
			colnames = [t[0] for t in cursor.description]

		fixfn = lambda x: dict(zip(colnames, x))
		request.response.headers["Access-Control-Allow-Origin"] = "*"
		return {
			'type': type_name,
			'quicklist': list(map(fixfn, quicklist))
		}
