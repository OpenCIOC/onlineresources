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

from functools import partial

from cioc.core import constants as const
from cioc.core.rootfactories import BasicRootFactory


def includeme(config):
    urlprefix = "/special/"

    factory = partial(
        BasicRootFactory,
        domain=const.DM_CIC,
        db_area=const.DM_CIC,
        allow_api_login=True,
    )
    # /special/CLBCExport.mvc/*
    config.add_route(
        "special_clbcexport", urlprefix + "CLBCExport.mvc", factory=factory
    )

    # /special/CLBCUpdate.mvc/*
    config.add_route(
        "special_clbcupdate", urlprefix + "CLBCUpdate.mvc", factory=factory
    )

    # /special/O211Export.mvc/*
    config.add_route(
        "special_o211export", urlprefix + "O211Export.mvc", factory=factory
    )

    # /special/oaccacc/*
    config.add_route(
        "special_oaccacexport", urlprefix + "oaccacexport", factory=factory
    )
