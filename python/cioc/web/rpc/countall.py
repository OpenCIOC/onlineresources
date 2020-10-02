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
from pyramid.httpexceptions import HTTPUnauthorized, HTTPInternalServerError
from pyramid.view import view_config

# this app
from cioc.core import i18n
from cioc.core import viewbase

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


def make_internal_server_error(message):
	error = HTTPInternalServerError()
	error.content_type = "text/plain"
	error.text = message
	return error


@view_config(route_name='rpc_countall', renderer='json')
class Count(viewbase.ViewBase):

	def __call__(self):
		request = self.request
		user = request.user

		retval = {}

		domain = request.matchdict['domain'].upper()

		if not user:
			return make_401_error(u'Access Denied')

		if 'realtimestandard' not in user.cic.ExternalAPIs:
			return make_401_error(u'Insufficient Permissions')

		with request.connmgr.get_connection() as conn:
			count_row = conn.execute('EXEC sp_' + domain + '_View_c_Records ?', request.viewdata.cic.ViewType).fetchone()

			if count_row:
				retval['RecordCount'] = count_row.RecordsInView
			else:
				retval['RecordCount'] = 0

		if not retval:
			return make_401_error(u'Insufficient Permissions')

		format = request.params.get('format')
		if format and format.lower() == 'xml':
			request.override_renderer = 'cioc:xml'

		return retval
