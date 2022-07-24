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

from markupsafe import Markup

from cioc.core.i18n import gettext as _


def has_been_launched(request):
    return not not (
        request.dboptions.ClientTrackerIP and "ctlaunched" in request.session
    )


_details_add_record_template = Markup('<span class="NoWrap ListUI">%s | </span>')


def my_list_details_add_record(request, id):
    result = my_list_add_record_basic_ui(request, id)
    if result:
        return _details_add_record_template % result
    return ""


_my_list_template = Markup(
    """<span id="added_to_list_%(id)s" style="display:none;"><img src="/images/listadded.gif" alt="%(record_added)s"> %(record_added)s</span><span id="add_to_list_%(id)s"><span class="NoLineLink SimulateLink add_to_list" data-id="%(id)s"><img src="/images/listadd.gif" alt="%(add_record)s"> %(add_record)s</span>%(ct)s</span>"""
)
_ct_template = Markup(
    """<span id="ct_added_to_previous_request_%(id)s" class="Alert" style="display: none;"> * </span>"""
)


def my_list_add_record_basic_ui(request, id):
    launched = has_been_launched(request)

    if launched or request.viewdata.dom.MyList:
        id = str(id)
        if launched:
            ct = _ct_template % {
                "id": id,
            }
        else:
            ct = ""

        return _my_list_template % {
            "ct": ct,
            "id": id,
            "record_added": _("Record Added", request),
            "add_record": _("Add Record", request),
        }

    return ""
