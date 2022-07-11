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
from collections import namedtuple

from cioc.core import constants as const

ROInfo = namedtuple(
    "ROInfo", "Name Fax UpdatePhone UpdateEmail SiteAddress MailAddress"
)
empty_record_owner = ROInfo("", "", "", "", "", "")


def get_record_owner_info(request, agency_code, domain):
    if not agency_code:
        return empty_record_owner

    if domain == const.DM_CIC:
        sql = "EXEC dbo.sp_CIC_Agency_Update_s ?"
    elif domain == const.DM_VOL:
        sql = "EXEC dbo.sp_VOL_Agency_Update_s ?"
    else:
        raise ValueError(
            "Expected %s or %s for domain paramter but got %r"
            % (const.DM_CIC, const.DM_VOL, domain)
        )

    with request.connmgr.get_connection("admin") as conn:
        ro = conn.execute(sql, agency_code).fetchone()

    if not ro:
        return empty_record_owner

    email = ro.UPDATE_EMAIL
    if not email:
        if request.pageinfo.DbArea == const.DM_CIC:
            email = request.dboptions.DefaultEmailCIC
        else:
            email = request.dboptions.DefaultEmailVOL

    return ROInfo(
        ro.ORG_NAME_FULL,
        ro.FAX,
        ro.UPDATE_PHONE,
        email,
        ro.SITE_ADDRESS,
        ro.MAIL_ADDRESS,
    )
