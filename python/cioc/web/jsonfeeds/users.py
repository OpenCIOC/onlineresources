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


# stdlib
from __future__ import absolute_import
import logging

# 3rd party
from pyramid.view import view_config

# this app
from cioc.web.cic import viewbase

log = logging.getLogger(__name__)


@view_config(route_name="jsonfeeds_users", renderer="json")
class JsonFeedsUsers(viewbase.CicViewBase):
    def __call__(self):
        request = self.request
        user = request.user

        if not user:
            return []

        term = request.params.get("term")
        if term:
            term = term.strip()
        if not term:
            return []

        if len(term) > 60:
            return []

        args = [request.dboptions.MemberID, term]

        sql = """
			SELECT User_ID, UserName, Agency FROM GBL_Users WHERE Inactive = 0 AND
			MemberID_Cache = ? AND UserName LIKE '%' + ? + '%' COLLATE Latin1_General_100_CI_AI
		"""
        if not user.SuperUser:
            sql += " AND Agency = ?"
            args.append(user.Agency)

        sql += """
			ORDER BY CASE WHEN UserName LIKE ? + '%' COLLATE Latin1_General_100_CI_AI THEN 0 ELSE 1 END,
			UserName COLLATE Latin1_General_100_CI_AI
		"""

        args.append(term)

        with request.connmgr.get_connection("admin") as conn:
            users = conn.execute(sql, args).fetchall()

        return [
            {
                "chkid": u.User_ID,
                "value": u.UserName,
                "label": u.UserName
                + ((" (" + u.Agency + ")") if user.SuperUser else ""),
            }
            for u in users
        ]
