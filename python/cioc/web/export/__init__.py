﻿# =========================================================================================
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


def includeme(config):
    urlprefix = "/export/"

    config.add_route(
        "export_airs",
        urlprefix + "airs",
        factory="cioc.core.rootfactories.BasicRootFactory",
    )

    config.add_route(
        "export_airs_full_list",
        urlprefix + "airs/list",
        factory="cioc.core.rootfactories.BasicRootFactory",
    )

    config.add_route(
        "export_airs_icarol_source_list",
        urlprefix + "airs/icarolsource",
        factory="cioc.core.rootfactories.BasicRootFactory",
    )
