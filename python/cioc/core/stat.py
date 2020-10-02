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
from datetime import datetime
from cioc.core.security import get_remote_ip


def insert_stat(request, recid, numvnum, api=False):
	area = request.pageinfo.DbAreaS
	user = request.user
	with request.connmgr.get_connection('admin') as conn:
		conn.execute(
			'EXEC dbo.sp_%s_Stats_i ?, ?, ?, ?, ?, ?, ?, ?' % area,
			request.dboptions.MemberID, datetime.now(), get_remote_ip(request), recid, user.User_ID,
			request.viewdata.dom.ViewType, api, numvnum)
