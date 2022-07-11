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
import six.moves.urllib.request, six.moves.urllib.parse, six.moves.urllib.error


def hasGoogleMapsAPI(request):
    area_str = request.pageinfo.DbAreaS
    if area_str == "GBL":
        area_str = "CIC"
    domain_info = request.dboptions.domain_info
    return not not (
        domain_info["GoogleMapsClientID" + area_str]
        or domain_info["GoogleMapsAPIKey" + area_str]
    )


def getGoogleMapsKeyArg(request):
    area_str = request.pageinfo.DbAreaS
    if area_str == "GBL":
        area_str = "CIC"
    domain_info = request.dboptions.domain_info
    params = {}
    client_id = domain_info["GoogleMapsClientID" + area_str]
    api_key = domain_info["GoogleMapsAPIKey" + area_str]
    if client_id:
        params["client"] = client_id
        channel = domain_info["GoogleMapsChannel" + area_str]
        if channel:
            params["channel"] = channel

    elif api_key:
        params["key"] = api_key

    if params:
        return six.moves.urllib.parse.urlencode(params)

    return ""
