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


import logging


import xml.etree.ElementTree as ET

# import elementtree.ElementTree as ET
from io import BytesIO as StringIO

from pyramid.view import view_config
import requests
from formencode import validators, Any, Invalid

from cioc.core.i18n import gettext as _
from cioc.core.clienttracker import has_been_launched
from cioc.web.cic import viewbase
from cioc.core import validators as ciocvalidators

log = logging.getLogger(__name__)


class InRequest(viewbase.CicViewBase):
    @view_config(route_name="ct_push", renderer="json")
    def inrequest(self):
        CT = "{https://clienttracker.cioc.ca/schema/}"

        request = self.request
        if not has_been_launched(request):
            return {
                "fail": True,
                "errinfo": _(
                    "Current session not associated with a Client Tracker user.",
                    request,
                ),
            }

        vals = (request.session.get("ctlaunched") or "").split(":")
        if len(vals) != 3:
            return {
                "fail": True,
                "errinfo": _(
                    "Current session not associated with a Client Tracker user.",
                    request,
                ),
            }

        ctid, login, key = vals

        idstring = request.params.get("id")
        remove = request.params.get("RemoveItem")

        if not idstring:
            return {"fail": True, "errinfo": _("Error: No record was chosen", request)}

        validator = [ciocvalidators.NumValidator(), ciocvalidators.VNumValidator()]
        if remove:
            validator.append(validators.OneOf(["all"]))

        validator = Any(validators=validator)
        try:
            idstring = validator.to_python(idstring)
        except Invalid as e:
            return {
                "fail": True,
                "errinfo": _("Error: The following is an invalid ID: %s", request)
                % idstring,
            }

        if remove:
            domain = remove
        elif isinstance(idstring, str):
            domain = "CIC"
            idstring = idstring.upper()
        else:
            domain = "VOL"

        if remove:
            root = ET.Element(
                "pushResourceRemove", xmlns="https://clienttracker.cioc.ca/schema/"
            )
            ET.SubElement(root, "login").text = str(login)
            ET.SubElement(root, "key").text = str(key)
            ET.SubElement(root, "ctid").text = str(ctid)
            resource_item = ET.SubElement(root, "resourceItem")
            ET.SubElement(resource_item, "id").text = str(idstring)
        else:
            idfield = "NUM"
            sql = [
                "SELECT bt.NUM, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5"
            ]

            if domain == "VOL":
                idfield = "VNUM"
                sql.append(", vo.VNUM, vod.POSITION_TITLE")

            sql.append(
                "\nFROM GBL_BaseTable bt \n"
                "INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID\n"
            )

            if domain == "VOL":
                sql.append(
                    "INNER JOIN VOL_Opportunity vo ON bt.NUM=vo.NUM\n"
                    "WHERE vo.VNUM = ?"
                )
            else:
                sql.append("WHERE bt.NUM=?")

            sql = "".join(sql)
            with request.connmgr.get_connection() as conn:
                record = conn.execute(sql, idstring).fetchone()

            if not record:
                return {
                    "fail": True,
                    "errinfo": _("Error: No record exists with the ID: %s", request)
                    % idstring,
                }

            org_name = ", ".join(
                x
                for x in (getattr(record, "ORG_LEVEL_%i" % y) for y in range(1, 6))
                if x
            )

            if domain == "VOL":
                org_name = f"{record.POSITION_TITLE} ({org_name})"

            root = ET.Element(
                "pushResource", xmlns="https://clienttracker.cioc.ca/schema/"
            )
            ET.SubElement(root, "login").text = str(login)
            ET.SubElement(root, "key").text = str(key)
            ET.SubElement(root, "ctid").text = str(ctid)
            resource_item = ET.SubElement(root, "resourceItem")
            ET.SubElement(resource_item, "id").text = str(getattr(record, idfield))
            ET.SubElement(resource_item, "name").text = str(org_name)

            pfs = request.passvars.path_from_start
            request.passvars.path_from_start = "/"

            if domain == "CIC":
                url = request.application_url + request.passvars.makeDetailsLink(
                    idstring
                )
            else:
                url = request.application_url + request.passvars.makeVOLDetailsLink(
                    idstring
                )

            request.passvars.path_from_start = pfs

            ET.SubElement(resource_item, "url").text = str(url)

        fd = StringIO()
        ET.ElementTree(root).write(fd, "utf-8", True)
        xml = fd.getvalue()
        fd.close()

        log.debug("request xml: %s", xml)

        url = request.dboptions.ClientTrackerRpcURL + (
            "remove_resource" if remove else "add_resource"
        )
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

        success = root.find(CT + "success")
        if success is None:
            return {
                "fail": _(
                    "The Client Tracker server gave an invalid response.", request
                )
            }

        ids = [x.text for x in root.findall(CT + "id")]

        return {"fail": False, "ids": ids}
