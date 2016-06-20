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


from json import dumps

from collections import namedtuple
import xml.etree.cElementTree as ET
import isodate

from markupsafe import Markup
from cioc.core.i18n import gettext as _, format_datetime


_fields = 'MODIFIED_DATE MODIFIED_BY VacancyChange VacancyFinal'.split()
_xml_transform = [isodate.parse_datetime, unicode, int, int]

ChangesTuple = namedtuple('ChangesTuple', _fields)

_fields = zip(_fields, _xml_transform)

_change_item_template = Markup('''
<tr><td>%(date)s (%(by)s)</td><td style="text-align: right">%(change)s</td><td style="text-align: right">%(total)s</td></tr>
''')

_change_has_items_template = Markup('''
<table class="BasicBorder">
<tr><th>%(modified)s</th><th>%(change)s</th><th>%(total)s</th></tr>
%(changes)s
</table>
''')


def make_history_table(request, changes):
	changes = Markup('\n').join(
		_change_item_template % {
			'date': format_datetime(x.MODIFIED_DATE, request),
			'by': x.MODIFIED_BY,
			'change': x.VacancyChange,
			'total': x.VacancyFinal
		}
		for x in changes)

	changes = _change_has_items_template % {
		'modified': _('Revision Date', request),
		'change': _('Change', request),
		'total': _('Vacancy', request),
		'changes': changes
	}

	return changes


def make_history_table_from_xml_changes(request, changes):
	changes = u'<root>' + changes + '</root>'

	root = ET.fromstring(changes.encode('utf-8'))
	_changes = (ChangesTuple(*[fn(x.find(name).text) for (name, fn) in _fields]) for x in root.findall('.//Change'))

	return make_history_table(request, _changes)


def vacancy_parameters(request):
	makeLink = request.passvars.makeLink
	return dumps({
		'permission_url': makeLink("~/jsonfeeds/vacancy/canedit"),
		'increment_url': makeLink("~/jsonfeeds/vacancy/increment"),
		'refresh_url': makeLink("~/jsonfeeds/vacancy/refresh"),
		'history_url': makeLink("~/jsonfeeds/vacancy/history"),
		'edit_txt': _('Edit', request),
		'up_txt': _('Release Occupancy', request),
		'down_txt': _('Assign Occupancy', request),
		'done_txt': _('Finished Editing', request),
		'history_txt': _('Change History', request),
		'close_txt': _('Close', request),
		'history_title_txt': _('Vacancy History', request),
		'loading_txt': _('Loading...', request),
		'server_error_txt': _('Unable to talk to server: ', request),
	})


def vacancy_script(request):
	if not request.user.cic:
		return u''

	return u'''initialize_vacancy(%s)''' % vacancy_parameters(request)
