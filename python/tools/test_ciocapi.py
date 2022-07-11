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

import sys
import argparse
from urllib.parse import urljoin

from xml.etree import ElementTree as ET
from datetime import date, timedelta

import requests


def parse_args(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--url", dest="url", action="store", default="http://fizban-current/"
    )
    parser.add_argument("user", action="store")
    parser.add_argument("passwd", action="store")

    return parser.parse_args(argv)


def request_kwargs(args):
    kwargs = {"auth": (args.user, args.passwd), "verify": False}

    return kwargs


def test_cic(args):
    r = requests.get(
        urljoin(args.url, "/rpc/orgsearch.asp"), params={"STerms": "fun"}, **args.kwargs
    )
    results = r.json()

    json_url = results["recordset"][0]["API_RECORD_DETAILS"]
    r2 = requests.get(json_url, **args.kwargs)
    jsoncheck = r2.json()
    assert not jsoncheck.get("error")

    r = requests.get(
        urljoin(args.url, "/rpc/orgsearch.asp"),
        params={"format": "xml", "STerms": "fun"},
        **args.kwargs
    )
    xmlresults = ET.fromstring(r.content)

    xml_url = xmlresults.find(".//record/field[@name='API_RECORD_DETAILS']").text
    r2 = requests.get(xml_url, **args.kwargs)
    xmlcheck = ET.fromstring(r2.content)
    error = xmlcheck.find(".//error")
    error = error and error.text
    assert not error

    assert xml_url.startswith(json_url)


def test_vol(args):
    tomorrow = date.today() + timedelta(days=1)
    volunteer_args_base = {
        "sCheckDay": str(tomorrow.day),
        "sCheckMonth": str(tomorrow.month),
        "sCheckYear": str(tomorrow.year),
        "VolunteerName": "Test",
        "VolunteerEmail": "test@example.com",
        "VolunteerPhone": "905-335-6324",
        "VolunteerCity": "Oakville",
    }
    r = requests.get(
        urljoin(args.url, "/rpc/oppsearch.asp"), params={"forOSSD": "on"}, **args.kwargs
    )
    results = r.json()

    json_url = results["recordset"][0]["API_RECORD_DETAILS"]
    r2 = requests.get(json_url, **args.kwargs)
    jsoncheck = r2.json()
    assert not jsoncheck.get("error")

    r = requests.get(
        urljoin(args.url, "/rpc/oppsearch.asp"),
        params={"format": "xml", "forOSSD": "on"},
        **args.kwargs
    )
    xmlresults = ET.fromstring(r.content)

    xml_url = xmlresults.find(".//record/field[@name='API_RECORD_DETAILS']").text
    r2 = requests.get(xml_url, **args.kwargs)
    xmlcheck = ET.fromstring(r2.content)
    error = xmlcheck.find(".//error")
    error = error and error.text
    assert not error

    assert xml_url.startswith(json_url)

    volunteer_args = {"VNUM": results["recordset"][0]["VNUM"]}
    volunteer_args.update(volunteer_args_base)

    r = requests.post(
        urljoin(args.url, "/volunteer/volunteer2.asp"),
        params={"api": "on"},
        data=volunteer_args,
        **args.kwargs
    )
    assert not r.json().get("error")

    volunteer_args = {"OPID": results["recordset"][0]["OPID"]}
    volunteer_args.update(volunteer_args_base)

    r = requests.post(
        urljoin(args.url, "/volunteer/volunteer2.asp"),
        params={"api": "on"},
        data=volunteer_args,
        **args.kwargs
    )
    assert not r.json().get("error")

    volunteer_args = {"VNUM": results["recordset"][0]["VNUM"]}
    volunteer_args.update(volunteer_args_base)

    r = requests.post(
        urljoin(args.url, "/volunteer/volunteer2.asp"),
        params={"api": "on", "format": "xml"},
        data=volunteer_args,
        **args.kwargs
    )
    error = ET.fromstring(r.content).find(".//error")
    error = error and error.text
    assert not error

    volunteer_args = {"OPID": results["recordset"][0]["OPID"]}
    volunteer_args.update(volunteer_args_base)

    r = requests.post(
        urljoin(args.url, "/volunteer/volunteer2.asp"),
        params={"api": "on", "format": "xml"},
        data=volunteer_args,
        **args.kwargs
    )
    error = ET.fromstring(r.content).find(".//error")
    error = error and error.text
    assert not error

    r = requests.get(urljoin(args.url, "/rpc/browseoppbyorg"), params={}, **args.kwargs)
    results = r.json()

    json_url = results[0]["OPP_SEARCH_LINK"]
    r2 = requests.get(json_url, **args.kwargs)
    jsoncheck = r2.json()
    assert not jsoncheck.get("error")

    r = requests.get(
        urljoin(args.url, "/rpc/browseoppbyorg"),
        params={"format": "xml"},
        **args.kwargs
    )
    xmlresults = ET.fromstring(r.content)

    xml_url = xmlresults.find(".//item/OPP_SEARCH_LINK").text
    r2 = requests.get(xml_url, **args.kwargs)
    xmlcheck = ET.fromstring(r2.content)
    error = xmlcheck.find(".//error")
    error = error and error.text
    assert not error

    assert results[0].get("NUM") == xmlresults.find(".//item/NUM").text


def main(argv):
    args = parse_args(argv)
    args.kwargs = request_kwargs(args)

    test_cic(args)
    test_vol(args)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
