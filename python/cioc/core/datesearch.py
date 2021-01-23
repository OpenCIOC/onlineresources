# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#	   http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

from __future__ import absolute_import
import calendar
from datetime import date

_dateToday = "CONVERT(varchar(12),GETDATE(),106)"
_dateThisMonthFirst = "DATEADD(d,1-DAY(GETDATE()),CONVERT(varchar(12),GETDATE(),106))"

date_search_options_sql = {
	'T': (_dateToday, 'NULL'),
	'Y': ("DATEADD(d,-1,CONVERT(varchar(12),GETDATE(),106))", _dateToday),
	'7': ("DATEADD(d,-6,CONVERT(varchar(12),GETDATE(),106))", "NULL"),
	'10': ("DATEADD(d,-9,CONVERT(varchar(12),GETDATE(),106))", "NULL"),
	'TM': (_dateThisMonthFirst, "NULL"),
	'PM': ("DATEADD(m,-1," + _dateThisMonthFirst + ")", _dateThisMonthFirst),
}


def add_months(sourcedate, months):
	month = sourcedate.month - 1 + months
	year = int(sourcedate.year + month / 12)
	month = month % 12 + 1
	day = min(sourcedate.day, calendar.monthrange(year, month)[1])
	return date(year, month, day)


def add_years(sourcedate, years):
	month = sourcedate.month
	year = int(sourcedate.year + years)
	day = min(sourcedate.day, calendar.monthrange(year, month)[1])
	return date(year, month, day)
