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
from json import dumps

from cioc.core.i18n import gettext as _


def details_sidebar_parameters(request):
    return dumps(
        [
            "[" + _("Show Listings", request) + "]",
            "[" + _("Hide Listings", request) + "]",
            "[" + _("Show Deleted", request) + "]",
            "[" + _("Hide Deleted", request) + "]",
        ]
    )


def details_sidebar_script(request):
    return (
        """initialize_listing_toggle.apply(null, %s);"""
        % details_sidebar_parameters(request)
    )
