<%
' =========================================================================================
'  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
'
'  Licensed under the Apache License, Version 2.0 (the "License");
'  you may not use this file except in compliance with the License.
'  You may obtain a copy of the License at
'
'      http://www.apache.org/licenses/LICENSE-2.0
'
'  Unless required by applicable law or agreed to in writing, software
'  distributed under the License is distributed on an "AS IS" BASIS,
'  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'  See the License for the specific language governing permissions and
'  limitations under the License.
' =========================================================================================

%>
<script language="python" runat="server">
import cgi
import re
import itertools
from datetime import date
from cioc.core.i18n import gettext
from cioc.core import constants as const

_ = lambda x: gettext(x, pyrequest)
from functools import partial

def get_numeric_extension(value):
	value = int(value)
	if value % 100 in [11,12,13]:
		return _('th')
	mod = value
	if mod == 1:
		return _('st')
	if mod == 2:
		return _('nd')
	if mod == 3:
		return _('rd')
	return _('th')
		

def format_event_schedule_line(values):
	line = []
	label = values.get('Label')
	if label:
		line.append(label)
		line.append(_(': '))

	recurs_every = int(values['RECURS_EVERY'])
	recurs_day_of_week = int(values['RECURS_DAY_OF_WEEK'])
	recurs_day_of_month = values.get('RECURS_DAY_OF_MONTH')
	recurs_xth_weekday_of_month = values.get('RECURS_XTH_WEEKDAY_OF_MONTH')

	if recurs_day_of_month is not None:
		recurs_day_of_month = int(recurs_day_of_month)
	if recurs_xth_weekday_of_month is not None:
		recurs_xth_weekday_of_month = int(recurs_xth_weekday_of_month)

	if recurs_every:
		if recurs_day_of_month or recurs_xth_weekday_of_month:
			unit = _('day') if recurs_day_of_month else _('week')
			number = recurs_day_of_month or recurs_xth_weekday_of_month
			line.append(
				_('On the {}{} {} of the month').format(
					unicode(number),
					get_numeric_extension(number),
					unit
				)
			)
			if recurs_xth_weekday_of_month:
				line.append(' on ')
		if recurs_day_of_week or recurs_xth_weekday_of_month:
			days = [
				(_('Sunday'), '1'),
				(_('Monday'), '2'),
				(_('Tuesday'), '3'),
				(_('Wednesday'), '4'),
				(_('Thursday'), '5'),
				(_('Friday'), '6'),
				(_('Saturday'), '7'),
			]
			days = [x[0] for x in days if int(values['RECURS_WEEKDAY_' + x[1]])]
			join = u', '
			if len(days) > 2:
				days[-1] = _('and ') + days[-1]
			elif len(days) == 2:
				join = u' ' + _('and ')

			line.append(join.join(days))

		line.append(u' ')
		line.append(_('every '))
		if recurs_every > 1:
			line.append(unicode(recurs_every))
			line.append(get_numeric_extension(recurs_every))
			line.append(u' ')

		if recurs_day_of_week:
			line.append(_('week'))
		else:
			line.append(_('month'))

		line.append(u' ')
		line.append(_('from'))
		line.append(u' ')

	line.append(values['START_DATE'])
	end_date = values.get('END_DATE')
	if end_date:
		line.append(u' ')
		line.append(_('to'))
		line.append(u' ')
		line.append(end_date)

	start_time = values.get('START_TIME')
	end_time = values.get('END_TIME')
	if start_time:
		line.append(start_time)
		if end_time:
			line.append(u' ')
			line.append(_('to'))
			line.append(u' ')
			line.append(end_time)

	return u''.join(line)

def getEventScheduleEntryValues(sched_no, sched_id, vals, checkDate, checkInteger, checkID, checkLength, checkAddValidationError):
	is_new = sched_id.startswith('NEW')
	validation_label_prefix = _('Schedule # ') + sched_no + _(' - ')
	start_date = vals.get('START_DATE')
	if start_date:
		start_date = start_date.strip()

	if is_new and not start_date:
		return None
	
	if not is_new:
		try:
			sched_id = int(sched_id, 10)
		except TypeError:
			return None

	if pyrequest.pageinfo.DbArea == const.DM_VOL:
		id_field = 'VolVNUM'
		record_id = '@VNUM'
	else:
		id_field = 'GblNUM'
		record_id = '@NUM'

	if not start_date:
		# No Start date means it's a delete because start date is required
		return (sched_id, [(u'SchedID', sched_id)])

	def checkTime(label, value, name=None):
		if not value:
			vals[name] = None
			return

		value = check_time(label, value, checkAddValidationError)
		if value:
			value = value.isoformat()

		vals[name] = value

	def check_date(label, value, name=None):
		vals[name] = checkDate(label, value) or None

	recur_type = vals.get('RECURS_TYPE')
	if recur_type not in ['0', '1', '2', '3']:
		checkAddValidationError(validattion_label_prefix + _("Repeats") + _(': ') + _('Invalid Repeat Type'))
		return None

	to_check = [
		(_('Start Date'), 'START_DATE', partial(check_date, name='START_DATE')),
		(_('End Date'), 'END_DATE', partial(check_date, name='END_DATE')),
		(_('Start Time'), 'START_TIME', partial(checkTime, name='START_TIME')),
		(_('End Time'), 'END_TIME', partial(checkTime, name='END_TIME')),
	]

	def get_none(label, value, name=None):
		vals[name] = None
		
	def get_false(label, value, name=None):
		vals[name] = False
	
	def get_true(label, value, name=None):
		vals[name] = True

	def get_bool(label, value, name=None):
		vals[name] = bool(value)

	def get_zero(label, value, name=None):
		vals[name] = 0

	def get_one(label, value, name=None):
		vals[name] = 1
	
	def get_and_check_int(label, value, name=None):
		checkInteger(label, value)
		if value == '' or value is None:
			vals[name] = None
			return
		try:
			vals[name] = int(value, 10)
		except TypeError:
			vals[name] = None

	def get_and_check_int_min_1(label, value, name=None):
		get_and_check_int(label, value, name=name)
		if not vals[name]:
			vals[name] = 1

	if recur_type == '3':
		to_check.append((_('Repeat Every'), 'RECURS_EVERY', partial(get_one, name='RECURS_EVERY')))
	elif recur_type != '0':
		to_check.append((_('Repeat Every'), 'RECURS_EVERY', partial(get_and_check_int_min_1, name='RECURS_EVERY')))
	else:
		to_check.append((None, 'RECURS_EVERY', partial(get_zero, name='RECURS_EVERY')))

	if recur_type == '1':
		to_check.append((None, 'RECURS_DAY_OF_WEEK', partial(get_true, name="RECURS_DAY_OF_WEEK")))
	else:
		to_check.append((None, 'RECURS_DAY_OF_WEEK', partial(get_false, name="RECURS_DAY_OF_WEEK")))

	if recur_type == '2':
		to_check.append((_('Day of Month'), 'RECURS_DAY_OF_MONTH', partial(get_and_check_int, name='RECURS_DAY_OF_MONTH')))
	else:
		to_check.append((None, 'RECURS_DAY_OF_MONTH', partial(get_none, name='RECURS_DAY_OF_MONTH')))

	if recur_type == '3':
		to_check.append((_('Week of Month'), 'RECURS_XTH_WEEKDAY_OF_MONTH', partial(get_and_check_int_min_1, name='RECURS_XTH_WEEKDAY_OF_MONTH')))
	else:
		to_check.append((None, 'RECURS_XTH_WEEKDAY_OF_MONTH', partial(get_none, name='RECURS_XTH_WEEKDAY_OF_MONTH')))
	
	if recur_type in ['1', '3']:
		to_check.extend((None, 'RECURS_WEEKDAY_%d' % i, partial(get_bool, name='RECURS_WEEKDAY_%d' % i)) for i in range(1, 8))
	else:
		to_check.extend((None, 'RECURS_WEEKDAY_%d' % i, partial(get_false, name='RECURS_WEEKDAY_%d' % i)) for i in range (1, 8)) 
	
	changes = []
	for label, field, check in to_check:
		value = vals.get(field)
		if label:
			label = validation_label_prefix + label
		check(label, value)
		value = vals.get(field)
		if value is None:
			continue

		changes.append((field, value))

	label_val = vals.get('Label') or None
	if label_val:
		checkLength(validation_label_prefix + _('Label'), label_val, const.TEXT_SIZE)
		changes.append(('Label', label_val))
		
	if not is_new:
		changes.append(('SchedID', sched_id))
	
	return (sched_id, changes)


def getEventScheduleValues(checkDate, checkInteger, checkID, checkLength, checkAddValidationError):
	fields = ('Label START_DATE END_DATE START_TIME END_TIME RECURS_TYPE RECURS_EVERY RECURS_DAY_OF_WEEK '
			'RECURS_XTH_WEEKDAY_OF_MONTH RECURS_DAY_OF_MONTH').split()
	fields.extend('RECURS_WEEKDAY_%d' % i for i in range(1,8))

	output = []
	sched_ids = (pyrequest.POST.get("Sched_IDS") or u'').split(',')
	
	for sched_no, sched in enumerate(sched_ids, 1) :
		prefix = 'Sched_%s_' % sched
		vals = {x: pyrequest.POST.get(prefix + x) for x in fields}

		if 'NEW' in sched:
			sched_no = unicode(sched_no) + ' ' + _('(new)')
		else:
			sched_no = unicode(sched_no)

		entry = getEventScheduleEntryValues(sched_no, sched, vals, checkDate, checkInteger, checkID, checkLength, checkAddValidationError)
		if not entry:
			continue

		output.append(entry)

	return output


def convertEventScheduleValuesToXML(schedules):
	def escape_for_xml(value):
		if isinstance(value, bool):
			return unicode(int(value))

		if isinstance(value, int):
			return unicode(value)

		if isinstance(value, (datetime, time, date)):
			return value.isoformat()

		return cgi.escape(unicode(value), True)

	xml_values = []
	for sched_id, values in schedules:
		xml_values.append(
			u'<SCHEDULE {} />'.format(
				u' '.join('{}="{}"'.format(f, escape_for_xml(v)) for f, v in values if v is not None)
			)
		)

	return u''.join(xml_values)

</script>
<%
Function WrapCheckDate(strFldName, ByVal strValue)
	Dim strRetval
	If Nl(strValue) Then
		strRetval = vbNullString
	Else
		strRetval = CStr(strValue)
	End If
	Call checkDate(strFldName, strRetval)

	WrapCheckDate = ISODateString(strRetVal)
End Function
%>
