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
from operator import attrgetter


def format_list(items, formatter=None, id_key=None, label_key=None):
    if not id_key and not label_key and not formatter:
        formatter = tuple
    if not formatter:
        formatter = attrgetter(id_key, label_key)

    return [formatter(item) for item in items]


class PubItemFormatter(object):
    def __init__(self, flag_non_public=False, pub_names_only=False):
        self.flag_non_public = flag_non_public
        self.pub_names_only = pub_names_only

    def __call__(self, item):
        if self.pub_names_only:
            label = item.PubName or item.PubCode
        else:
            label = [item.PubCode]
            if item.PubName:
                label.extend([" - ", item.PubName])

            if self.flag_non_public and item.NonPublic:
                label.append(" *")

            label = "".join(label)

        return (item.PB_ID, label)


def format_pub_list(items, flag_non_public=False, pub_names_only=False):
    return format_list(
        items, formatter=PubItemFormatter(flag_non_public, pub_names_only)
    )
