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


def make_401_error(message, realm="CIOC RPC"):
    error = HTTPUnauthorized(
        headers=make_headers({"WWW-Authenticate": 'Basic realm="%s"' % realm})
    )
    error.content_type = "text/plain"
    error.text = message
    return error


def make_internal_server_error(message):
    error = HTTPInternalServerError()
    error.content_type = "text/plain"
    error.text = message
    return error


@view_config(route_name="rpc_whoami", renderer="json")
class RpcWhoAmI(viewbase.ViewBase):
    def __call__(self):
        request = self.request
        user = request.user

        if not user:
            return make_401_error("Access Denied")

        retval = {}
        if "realtimestandard" in user.vol.ExternalAPIs:
            retval["VOL"] = True
        if "realtimestandard" in user.cic.ExternalAPIs:
            retval["CIC"] = True

        if not retval:
            return make_401_error("Insufficient Permissions")

        retval["UserName"] = user.UserName

        format = request.params.get("format")
        if format and format.lower() == "xml":
            request.override_renderer = "cioc:xml"

        return retval
