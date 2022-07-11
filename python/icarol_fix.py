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
import sys

sys.path.append(".")
sys.path.append("tools")

import icarol_sync
from cioc.core import config
from cioc.core import constants as const
import os
import requests


def run_update(argv, dest, files):
    args = icarol_sync.parse_args(argv)
    args.config = config.get_config(args.configfile, const._app_name)
    args.previous = "123"

    args.dest = dest
    args.dest_file = os.path.join(args.dest, files[0])

    field = icarol_sync.get_config_item(args, "airs_export_db_count_field", None)

    for file in files:
        kwargs = icarol_sync.download_kwargs(args)
        kwargs["params"]["Field"] = field
        headers = {"content-type": "application/json"}
        data = open(os.path.join(args.dest, file), "r").read()

        url = icarol_sync.download_url(args.url)
        r = requests.post(url, data=data, headers=headers, **kwargs)
        r.raise_for_status()

        args.type = "part"


run_update(
    "--type full https://ontario.cioc.ca/ tools".split(),
    r"Y:\work\other clients\O211SC\iCarolLoads\ONT",
    [
        "ONFull20141107T151508_counts.json",
        "ONIncrementalFrom20141031T095049To20141107T023003_counts.json",
        "ONIncrementalFrom20141107T023003To20141114T023003_counts.json",
        "ONIncrementalFrom20141114T023003To20141121T023003_counts.json",
    ],
)
# print 'Done Ontario- press enter to continue'
# raw_input()
# run_update(
# 	'--config-prefix nvt --nosslverify https://fizban-m2/ tools'.split(), r'Y:\work\other clients\O211SC\iCarolLoads\NVT',
# 	['NVFull20141121T024000_counts.json']
# )
# print 'Done nunavut'
