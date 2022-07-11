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
import logging
import six

log = logging.getLogger(__name__)

import xml.etree.cElementTree as ET
from six import BytesIO as StringIO

from pyramid.view import view_config
import requests

from cioc.core.i18n import gettext as _
from cioc.core.clienttracker import has_been_launched
from cioc.web.cic import viewbase


class InRequest(viewbase.CicViewBase):
    @view_config(route_name="ct_inrequest", renderer="json")
    def inrequest(self):
        CT = "{http://clienttracker.cioc.ca/schema/}"
        request = self.request
        if not has_been_launched(request):
            return {
                "fail": True,
                "errinfo": _(
                    "Current session not associated with a Client Tracker user.",
                    request,
                ),
            }

        vals = request.cioc_get_cookie("ctlaunched").split(":")
        if len(vals) != 3:
            return {
                "fail": True,
                "errinfo": _(
                    "Current session not associated with a Client Tracker user.",
                    request,
                ),
            }

        ctid, login, key = vals

        root = ET.Element("isInRequest", xmlns="http://clienttracker.cioc.ca/schema/")
        ET.SubElement(root, "login").text = six.text_type(login)
        ET.SubElement(root, "key").text = six.text_type(key)
        ET.SubElement(root, "ctid").text = six.text_type(ctid)

        fd = StringIO()
        ET.ElementTree(root).write(fd, "utf-8", True)
        xml = fd.getvalue()
        fd.close()

        url = request.dboptions.ClientTrackerRpcURL + "is_in_request"
        headers = {"content-type": "application/xml; charset=utf-8"}

        r = requests.post(url, data=xml, headers=headers)
        try:
            r.raise_for_status()
        except Exception as e:
            log.debug(
                "unable to contact %s: %s %s, %s", url, r.status_code, r.reason, e
            )
            return {
                "fail": True,
                "errinfo": _(
                    "There was an error communicating with the Client Tracker server: %s",
                    request,
                )
                % e,
            }

        log.debug("encoding: %s", r.headers)
        log.debug("response: %s", repr(r.content))
        fd = StringIO(r.content)
        tree = ET.parse(fd)
        fd.close()

        root = tree.getroot()

        error = root.find(CT + "error")
        if error is not None:
            return {
                "fail": True,
                "errinfo": _("The Client Tracker server returned an error: %s", request)
                % error.text,
            }

        yes = root.find(CT + "yes")
        no = root.find(CT + "no")
        if yes is not None and no is not None:
            return {
                "fail": _(
                    "The Client Tracker server gave an invalid response.", request
                )
            }

        ids = []
        previous_ids = []
        log.debug("root %s", root.tag)
        if yes is not None:
            ids.extend(x.text for x in yes.findall(CT + "id"))
            previous_ids.extend(
                x.text for x in yes.findall("{0}previous-request/{0}id".format(CT))
            )

        retval = {"fail": False, "inrequest": yes is not None, "ids": ids}
        if previous_ids:
            retval["previous_ids"] = previous_ids

        return retval
