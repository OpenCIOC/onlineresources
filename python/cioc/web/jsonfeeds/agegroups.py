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
from pyramid.httpexceptions import HTTPForbidden, HTTPInternalServerError, HTTPUnauthorized
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


@view_config(route_name='jsonfeeds_agegrouplist', renderer='json')
@view_config(route_name='rpc_agegrouplist', renderer='json')
class JsonfeedsQuicklist(viewbase.ViewBase):

	def __call__(self):
		request = self.request

		if request.matched_route.name.startswith('rpc_') and not request.user:
			return make_401_error(u'Access Denied')

		sql = 'EXEC dbo.sp_GBL_AgeGroup_l ?,0'
		args = [request.dboptions.MemberID]

		with request.connmgr.get_connection('cic') as conn:
			cursor = conn.execute(sql, args)
			agegrouplist = cursor.fetchall()
			colnames = [t[0] for t in cursor.description]

		fixfn = lambda x: dict(zip(colnames, x))
		request.response.headers["Access-Control-Allow-Origin"] = "*"
		return {
			'agegroups': list(map(fixfn, agegrouplist))
		}
