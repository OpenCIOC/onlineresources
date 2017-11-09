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

import logging

from pyramid.view import view_config
from pyramid.exceptions import NotFound

from cioc.core import viewbase
from cioc.core.i18n import gettext as _
from cioc.core.i18n import get_locale

from datetime import date

template = 'cioc.web.gbl:templates/schedules.mak'
log = logging.getLogger(__name__)


class SchedulesBase(viewbase.ViewBase):
	def __init__(self, request):
		viewbase.ViewBase.__init__(self, request, False)

	def __call__(self):
		request = self.request

		with request.connmgr.get_connection() as conn:
			results = conn.execute(
				'''EXEC sp_%s_Schedule_l_Upcoming ?, ?, ?''' % request.pageinfo.DbAreaS,
				request.viewdata.dom.ViewType, request.passvars.cached_url_vals or None, request.pageinfo.PathToStart).fetchall()
		
		months = []
		locale = get_locale(request)
		month_names = locale.months['format']['wide']
		current_month = date.today()

		for month in ['Month1', 'Month2', 'Month3']:
			month_results = [x for x in results if getattr(x, month) is not None]
			month_results.sort(key=lambda x: getattr(x, month))
			month_display = '{} {}'.format(month_names[current_month.month], current_month.year)
			months.append((month_display, month_results))
			next_month = current_month.month + 1
			next_year = current_month.year
			if next_month > 12:
				next_month = 1
				next_year += 1
			current_month = date(next_year, next_month, 1)

		title = _('Upcoming Events', request)

		return self._create_response_namespace(title, title, {'months': months}, no_index=False)

@view_config(route_name='sched_upcoming_cic', renderer=template)
class SchedulesCIC(SchedulesBase):
	pass


@view_config(route_name='sched_upcoming_vol', renderer=template)
class SchedulesVOL(SchedulesBase):
	pass
