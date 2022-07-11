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

from cioc.core import constants as const, validators
from cioc.core.rootfactories import BasicRootFactory


def includeme(config):
    urlprefix = "/jsonfeeds/"

    # /rpc/record/*
    factory_cic = partial(BasicRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC)
    factory_vol = partial(BasicRootFactory, domain=const.DM_VOL, db_area=const.DM_VOL)

    heading_list_path = (
        urlprefix + "quicklist/{pubcode:" + validators.code_validator_re[1:-1] + "}"
    )
    config.add_route(
        "jsonfeeds_headinglist",
        heading_list_path,
        "cioc.core.rootfactories.BasicRootFactory",
    )

    config.add_route(
        "jsonfeeds_quicklist",
        urlprefix + "quicklist",
        "cioc.core.rootfactories.BasicRootFactory",
    )

    config.add_route(
        "jsonfeeds_agegrouplist",
        urlprefix + "agegrouplist",
        "cioc.core.rootfactories.BasicRootFactory",
    )

    config.add_route("jsonfeeds_users", urlprefix + "users", factory=factory_cic)

    config.add_route(
        "jsonfeeds_vacancy", urlprefix + "vacancy/{action}", factory=factory_cic
    )

    config.add_route(
        "jsonfeeds_volpopularorgs",
        urlprefix + "volunteer/popular_orgs",
        factory=factory_vol,
    )

    config.add_route(
        "jsonfeeds_volpopularinterests",
        urlprefix + "volunteer/popular_interests",
        factory=factory_vol,
    )

    config.add_route(
        "jsonfeeds_volnewest", urlprefix + "volunteer/newest", factory=factory_vol
    )

    config.add_route(
        "jsonfeeds_volorg", urlprefix + "volunteer/org", factory=factory_vol
    )

    config.add_route(
        "jsonfeeds_volinterest", urlprefix + "volunteer/interest", factory=factory_vol
    )

    config.add_route(
        "jsonfeeds_cicnewest", urlprefix + "cominfo/newest", factory=factory_cic
    )

    config.add_route("jsonfeeds_cicpub", urlprefix + "cominfo/pub", factory=factory_cic)
    config.add_route("jsonfeeds_taxcodes", urlprefix + "taxcodes", factory=factory_cic)

    config.add_route(
        "jsonfeeds_cictaxonomy", urlprefix + "cominfo/taxonomy", factory=factory_cic
    )
    config.add_route(
        "jsonfeeds_icons",
        urlprefix + "icons",
        factory=partial(
            BasicRootFactory, domain=const.DM_GLOBAL, db_area=const.DM_GLOBAL
        ),
    )
