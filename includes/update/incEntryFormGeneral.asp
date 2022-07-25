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
from datetime import date, time, datetime
from collections import defaultdict
from xml.etree import cElementTree as ET
from adodbapi.apibase import variantConversions
from adodbapi import dateconverter
try:
	from cgi import escape as cgiescape
except ImportError:
	from html import escape as cgiescape

import json

from markupsafe import Markup
from webhelpers2.html import tags

from cioc.core import constants as const
from cioc.core.i18n import gettext
from cioc.core.modelstate import convert_options

_ = lambda x: gettext(x, pyrequest)

DBNull = type(None)

def convertVariantToPython(variant, adType):
	if isinstance(variant,DBNull):
		return None
	return variantConversions[adType](variant)

def _tmp_cast(v, t):
	v = convertVariantToPython(v, t)
	if isinstance(v, date) and not isinstance(v, datetime):
		v = datetime(v.year, v.month, v.day)
	if isinstance(v, bytes):
		v = v.decode('utf-8')
	return v

def rs_iter(rs):
	if rs.EOF:
		return []

	fields = [field.Name for field in rs.Fields]
	types = [field.Type for field in rs.Fields]
	rows = zip(*rs.GetRows())
	return [dict(zip(fields, map(_tmp_cast, row, types))) for row in rows]

def prepSocialMediaFeedback(rsFb):
	global sm_feedback_values
	sm_feedback_values = defaultdict(list)

	rsFb.MoveFirst()
	for i, row in enumerate(rs_iter(rsFb), 1):
		if row['SOCIAL_MEDIA']:
			xml = ET.fromstring(row['SOCIAL_MEDIA'].encode('utf-8'))
			
			for el in xml.findall('./SM'):
				sm_id = el.get('SM_ID')
				url = el.get('URL', None)
				proto = el.get('Proto', None) or 'http://'
				
				sm_feedback_values[sm_id].append({'sm_id': sm_id, 'proto': proto, 'url': url, 'feedback': i, 
						'language_name': row.get('LanguageName')})

				
def getSocialMediaFeedback(sm_id, txt_feeback_num, txt_colon,txt_update, txt_content_deleted):
	template = u'<br><span class="Info">{}%d{}{}</span> <span class="Alert">%s</span> <input type="button" value="{}" onClick="document.EntryForm.SOCIAL_MEDIA_%s.value=%s;">'.format(txt_feeback_num, " (%s)" if pyrequest.multilingual else '%s', txt_colon, txt_update)
	escape = cgiescape
	dumps = json.dumps

	output = []
	for fb in sm_feedback_values[sm_id]:
		output.append(template % (fb['feedback'], fb['language_name'] if pyrequest.multilingual else '', escape((fb['proto'] + fb['url']) if fb['url'] else txt_content_deleted), sm_id, escape(dumps((fb['proto'] + fb['url']) if fb['url'] else '') , True)))
		

	return "".join(output)


def prepLanguagesFeedback(rsFb):
	global ln_feedback_values
	ln_feedback_values = []
	ln_feedback_all_ids = set()

	rsFb.MoveFirst()
	for i, row in enumerate(rs_iter(rsFb)):
		values = {}
		ln_feedback_values.append(values)
		if row['LANGUAGES']:
			try:
				xml = ET.fromstring(row['LANGUAGES'])
			except Exception as e:
				continue

			values['LanguageName'] = row['LanguageName']
			for el in xml.findall('./NOTE'):
				values['NOTE'] = {'note': el.text}

			
			for el in xml.findall('.//LN'):
				ln_id = el.get('ID')
				ln_feedback_all_ids.add(ln_id)
				note = el.get('NOTE', u'')
				lnds = {x.text.strip() for x in el.findall('.//LND') if x.text.strip()}
				
				values[ln_id] = {
					'ln_id': ln_id, 'note': note, 'lnds': lnds
				}
	
	return ','.join(ln_feedback_all_ids)

def getLanguagesFeedback(ln_id, language_name, checked, note, txt_feedback_num, txt_colon, txt_update, txt_content_deleted):
	lnds = language_details
	template = u'<br><span class="Info">{txt_feedback_num}%(no)d{txt_multi_lingual}{txt_colon}</span> <span class="Alert">%(value)s</span> <input type="button" value="{txt_update}" onClick="restore_form_values(\'#language-entry-%(id)s\', %(update_values)s); languages_check_state.apply(document.EntryForm.LN_ID_%(id)s);">'.format(txt_feedback_num=txt_feedback_num, txt_multi_lingual=" (%(language_name)s)" if pyrequest.multilingual else '', txt_colon=txt_colon, txt_update=txt_update)
	escape = cgiescape
	dumps = json.dumps

	output = []
	for i, values in enumerate(ln_feedback_values):
		if not values:
			continue
		fb = values.get(six.text_type(ln_id), {})
		if not fb:
			if not int(checked):
				continue
		
			value = six.text_type(txt_content_deleted)
			update_values = {'LN_ID': '', 'LN_NOTES_%s' % ln_id: '', 'LND_%s' % ln_id: []}
		else:
			value = six.text_type(language_name)
			update_values = {
				'LN_ID': [six.text_type(ln_id)], 'LN_NOTES_%s' % six.text_type(ln_id): [six.text_type(fb['note'])],
				'LND_%s' % six.text_type(ln_id): [six.text_type(x['LND_ID']) for x in lnds if six.text_type(x['LND_ID']) in fb['lnds']]
			}
			details = [six.text_type(x['Name']) for x in lnds if six.text_type(x['LND_ID']) in fb['lnds']]
			if fb['note']:
				details.append(escape(fb['note'], True))
			if details:
				value += u' (%s)' % u', '.join(details)
		
		output.append(template % {'no': i + 1, 'language_name': values['LanguageName'], 'id': ln_id, 'update_values': escape(dumps(update_values), True), 'value': value})
		
	return u"".join(output)

def getLanguageNotesFeedback(note, txt_feedback_num, txt_colon, txt_update, txt_content_deleted):
	template = u'<br><span class="Info">{txt_feedback_num}%(no)d{txt_multi_lingual}{txt_colon}</span> <span class="Alert">%(value)s</span> <input type="button" value="{txt_update}" onClick="document.EntryForm.LANGUAGE_NOTES.value=%(update_value)s;">'.format(txt_feedback_num=txt_feedback_num, txt_multi_lingual=" (%(language_name)s)" if pyrequest.multilingual else '', txt_colon=txt_colon, txt_update=txt_update)

	escape = cgiescape
	dumps = json.dumps

	output = []
	for i, values in enumerate(ln_feedback_values, 1):
		if not values:
			continue

		fb = values.get('NOTE', {})
		if not fb or not fb.get('note'):
			if not note:
				continue
			
			value = six.text_type(txt_content_deleted)
			update_value = u''

		else:
			update_value = value = fb['note']
			
		output.append(template % {'no': i, 'language_name': values['LanguageName'], 'update_value': escape(dumps(six.text_type(update_value)), True), 'value': escape(value)})

	return u''.join(output)

def makeLanguageDetailList(rsLanguage):
	global language_details
	rsLanguage.MoveFirst
	language_details = []
	keys = 'LND_ID Name HelpText'.split()
	for row in rs_iter(rsLanguage):
		tmp = {k: v for k, v in row.items() if k in keys}
		language_details.append(tmp)

_language_detail_help_ui_template = u''' <span class="ui-corner-all ui-state-default" style="inline-block"><span class="ui-icon ui-icon-help" style="display: inline-block" tabindex="0" data-help-text="%s">%s</span></span>'''
_language_detail_row_template = u'''
		 <div class="margin-bottom-5"><label><input name="LND_%(lnid)s" type="checkbox" value="%(LND_ID)s" %(checked)s> %(Name)s</label>%(help_ui)s</div>'''

def languageDetailsUI(lnid, lndids, txt_help):
	selected_ids = [x.strip() for x in six.text_type(lndids).split(',')]
	escape = cgiescape
	rows = []
	for detail in language_details:
		vars = {
			'lnid': lnid, 'help_ui': u'', 
			'LND_ID': detail['LND_ID'], 'Name': escape(detail['Name']),
			'checked': u'checked' if six.text_type(detail['LND_ID']) in selected_ids else u''
		}
		if detail['HelpText']:
			vars['help_ui'] = _language_detail_help_ui_template % (escape(detail['HelpText']), txt_help) 

		rows.append(_language_detail_row_template % vars)

	return u''.join(rows)

def makeLanguageDetailsMap(rsLanguage):
	global language_detail_map
	language_detail_map = {}

	rsLanguage.MoveFirst
	for row in rs_iter(rsLanguage):
		language_detail_map[six.text_type(row['LND_ID'])] = row

def getLanguageDetailValue(lndid, key):
	try:
		return language_detail_map[lndid][key]
	except KeyError:
		return None

def prepStdChecklistFeedback(rsFb, general_notes, field_name):
	global std_checklist_feedback
	std_checklist_feedback = []

	rsFb.MoveFirst()
	for row in rs_iter(rsFb):
		values = {}
		std_checklist_feedback.append(values)
		if not row[field_name]:
			continue

		try:
			xml = ET.fromstring(row[field_name].encode('utf-8'))
		except Exception as e:
			values['language_name'] = row['LanguageName']
			values['NOTE'] = row[field_name]
			continue

		values['language_name'] = row['LanguageName']
		if general_notes:
			for el in xml.findall('./NOTE'):
				values['NOTE'] = {'note': el.text}

		for el in xml.findall('*/*'):
			id = el.get('ID')
			values[id] = {'id': id, 'note': el.get('NOTE')}

	return bool(any(std_checklist_feedback))


def getStdChecklistFeedback(prefix, field_name, item_notes, item_id, checked, note, item_name, txt_feeback_num, txt_colon, txt_update, txt_content_deleted):
	notes_update = u''
	if item_notes:
		notes_update = u'$(\'#{prefix}_NOTES_%(id)s\').val(%(note)s);'.format(prefix=prefix)

	template = u'<br><span class="Info">{fbnum}%(no)d{lang}{colon}</span> <span class="Alert">%(value)s</span> <input type="button" value="{update}" onClick="$(\'#{prefix}_ID_%(id)s\').prop(\'checked\', %(chked)s);{notes_update}">'.format(fbnum=txt_feeback_num, lang=" (%(language_name)s)" if pyrequest.multilingual else '', colon=txt_colon, update=txt_update, prefix=prefix, notes_update=notes_update)
	escape = cgiescape
	dumps = json.dumps

	output = []
	for i, values in enumerate(std_checklist_feedback, 1):
		if not values:
			# no feedback
			continue

		ns = {'no': i, 'language_name': values['language_name'], 'id': item_id}
		fb = values.get(six.text_type(item_id), {})
		if not fb:
			if not int(checked):
				# no change
				continue

			ns['value'] = six.text_type(txt_content_deleted)
			ns['chked'] = 'false'
			ns['note'] = ''

		else:
			if int(checked):
				if not item_notes:
					# no change
					continue
				elif six.text_type(note) == fb['note']:
					#no change
					continue
				
			value = six.text_type(item_name)
			if item_notes and fb['note']:
				value += u' - ' + escape(fb['note'])

			ns['value'] = value
			ns['chked'] = 'true'
			ns['note'] = escape(dumps(fb['note']), True)

		output.append(template % ns)


	output = u''.join(output)
	ns = {'fb': output[4:], 'colspan': ''}
	if item_notes:
		ns['colspan'] = 'colspan=2'

	return u'<tr><td %(colspan)s>%(fb)s</td></tr>' % ns


def getStdChecklistNotesFeedback(field_name, note, txt_feedback_num, txt_colon, txt_update, txt_content_deleted):
	template = u'<br><span class="Info">{txt_feedback_num}%(no)d{txt_multi_lingual}{txt_colon}</span> <span class="Alert">%(value)s</span> <input type="button" value="{txt_update}" onClick="document.EntryForm.{field}_NOTES.value=%(update_value)s;">'.format(txt_feedback_num=txt_feedback_num, txt_multi_lingual=" (%(language_name)s)" if pyrequest.multilingual else '', txt_colon=txt_colon, txt_update=txt_update, field=field_name)

	escape = cgiescape
	dumps = json.dumps

	output = []
	for i, values in enumerate(std_checklist_feedback, 1):
		if not values:
			continue

		fb = values.get('NOTE', {})
		if not fb or not fb.get('note'):
			if not note:
				continue
			
			value = six.text_type(txt_content_deleted)
			update_value = u''

		else:
			update_value = value = fb['note']
			
		output.append(template % {'no': i, 'language_name': values['language_name'], 'update_value': escape(dumps(six.text_type(update_value)), True), 'value': escape(value)})

	return u''.join(output)


def convertEventScheduleFeedbackEntry(entry):
	recurs_day_of_week = entry.get('RECURS_DAY_OF_WEEK') or u'0'
	recurs_day_of_month = entry.get('RECURS_DAY_OF_MONTH')
	recurs_xth_weekday_of_month = entry.get('RECURS_XTH_WEEKDAY_OF_MONTH')

	ui_select_value = u'0'

	if recurs_xth_weekday_of_month:
		ui_select_value = u'3'
	elif recurs_day_of_month:
		ui_select_value = u'2'
	elif recurs_day_of_week == u'1':
		ui_select_value = u'1'

	result = {'RECURS_TYPE': ui_select_value}
	for key, value in entry.items():
		if key.startswith('RECURS_WEEKDAY_'):
			if value == '1':
				value = 'on'
			else:
				continue

		result[key] = value

	return result


def prepEventScheduleFeedback(rsFb):
	rsFb.MoveFirst()
	entries = []
	new_count = 0
	for row in rs_iter(rsFb):
		values = {}
		entries.append(values)
		if not row['EVENT_SCHEDULE']:
			continue

		xml = row['EVENT_SCHEDULE'] or u'<SCHEDULES />'
		xml = ET.fromstring(xml.encode('utf-8'))
		values['_order'] = order = []
		values['_language'] = row['LanguageName']
		for entry in xml:
			attrib = {k: format_time_if_iso(v) if k.endswith('_TIME') else format_date_if_iso(v) if k.endswith('_DATE') else v for k, v in entry.attrib.items()}
			sched_id = attrib.get('SchedID')
			if not sched_id:
				new_count += 1
				sched_id = attrib['SchedID'] = 'NEWFB%s' % new_count
			order.append(sched_id)
			if not attrib.get('START_DATE'):
				schedule_line = _('[deleted]')
			else:
				schedule_line = format_event_schedule_line(attrib)

			attrib['_line'] = schedule_line
			attrib = convertEventScheduleFeedbackEntry(attrib)
			values[sched_id] = attrib
	
	return entries

def makeEventScheduleEntry(entry, label, prefix, feedback=None):
	recurs_day_of_week = entry.get('RECURS_DAY_OF_WEEK') or u'0'
	recurs_day_of_month = entry.get('RECURS_DAY_OF_MONTH')
	recurs_xth_weekday_of_month = entry.get('RECURS_XTH_WEEKDAY_OF_MONTH')

	this_entry_feedback = []
	if feedback:

		sched_id = entry['SchedID']
		for fb_num, fbe in enumerate(feedback, 1):
			if not fbe:
				continue

			language = ''
			if pyrequest.multilingual:
				language = ' ({})'.format(fbe['_language'])

			fbe = dict(fbe.get(sched_id))
			if not fbe:
				continue

			line = fbe.pop('_line')
			if all(entry.get(k) == v for k, v in fbe.items()):
				continue

			this_entry_feedback.append(
				Markup('''<div>
						<span class="Info">{txt_fbnum}{fb_num}{language}{txt_colon}</span>
						<span class="Alert">{line} <input type="button" value="{txt_update}" class="schedule-ui-accept-feedback" data-schedule="{values}"></span>
						</div>
				''').format(
					txt_fbnum=_('Feedback #'), txt_colon=_(': '), txt_update=_('Update'), fb_num=fb_num, line=line,
					language=language, values=json.dumps({prefix + k: [v] for k, v in fbe.items() if k != '_line'})
				)
			)

	this_entry_feedback = Markup('').join(this_entry_feedback)

	hide_display = Markup(u' style="display: None"')
	ui_select_value = u'0'

	if recurs_xth_weekday_of_month:
		ui_select_value = u'3'
	elif recurs_day_of_month:
		ui_select_value = u'2'
	elif recurs_day_of_week == u'1':
		ui_select_value = u'1'

	
	recurs_display = u''
	week_text_display = hide_display
	month_text_display = u''
	day_of_week_display = u''
	week_of_month_display = hide_display
	day_of_month_display = hide_display
	recurs_every = entry.get('RECURS_EVERY') or '1'

	if ui_select_value == u'0':
		recurs_display = hide_display
		day_of_week_display = hide_display
		recurs_every = '1'
	elif ui_select_value == u'1':
		week_text_display = u''
		month_text_display = hide_display
	elif ui_select_value == u'2':
		day_of_week_display = hide_display
		day_of_month_display = u''
	elif ui_select_value == u'3':
		recurs_display = hide_display
		week_of_month_display = u''

	weekdays = [
		('1', _('Su')),
		('2', _('Mo')),
		('3', _('Tu')),
		('4', _('We')),
		('5', _('Th')),
		('6', _('Fr')),
		('7', _('Sa')),
	]

	weekdays = Markup(u' ').join(
		tags.checkbox(prefix + 'RECURS_WEEKDAY_' + no, 'on', checked=entry.get('RECURS_WEEKDAY_' + no) == '1', label=l)
		for no, l in weekdays)

	ns = {
		'txt_repeats': _('Repeats'),
		'txt_delete': _('Delete'),
		'date_text_size': const.DATE_TEXT_SIZE,
		'time_text_size': const.TIME_TEXT_SIZE,
		'text_size': const.TEXT_SIZE,
		'txt_start_date': _('Start Date'),
		'txt_end_date': _('End Date'),
		'txt_start_time': _('Start Time'),
		'txt_end_time': _('End Time'),
		'START_DATE': entry.get('START_DATE') or u'',
		'END_DATE': entry.get('END_DATE') or u'',
		'START_TIME': entry.get('START_TIME') or u'',
		'END_TIME': entry.get('END_TIME') or u'',
		'RECURS_TYPE': tags.select(prefix + 'RECURS_TYPE', ui_select_value, convert_options([
				('0', _('Never')), ('1', _('Weekly')), ('2', _('Monthly by Day of Month')), ('3', _('Montly by Week of Month'))]),
				class_='recur-type-selector'),
		'RECURS_EVERY': recurs_every,
		'RECURS_DAY_OF_WEEK': recurs_day_of_week,
		'RECURS_XTH_WEEKDAY_OF_MONTH': recurs_xth_weekday_of_month or u'',
		'RECURS_DAY_OF_MONTH': recurs_day_of_month or u'',
		'Label': entry.get('Label') or u'',
		'weekdays': weekdays,
		'recurs_display': recurs_display,
		'txt_repeat_every': _('Repeat Every'),
		'week_text_display': week_text_display,
		'month_text_display': month_text_display,
		'txt_weeks': _('weeks'),
		'txt_months': _('months'),
		'day_of_week_display': day_of_week_display,
		'txt_repeat_on': _('Repeat On'),
		'week_of_month_display': week_of_month_display,
		'txt_week_of_month': _('Week of Month'),
		'day_of_month_display': day_of_month_display,
		'txt_day_of_month': _('Day of Month'),
		'txt_label': _('Label'),
		'feedback': this_entry_feedback,
	}
	output = Markup(u'''
		<div class="EntryFormItemBox" id="{prefix}container">
		<div style="float: right;"><button type="button" class="EntryFormItemDelete ui-state-default ui-corner-all" id="{prefix}DELETE">{txt_delete}</button></div>
		<h4 class="EntryFormItemHeader">{label}</h4>
		<div id="{prefix}DISPLAY" class="EntryFormItemContent">
		<table class="NoBorder cell-padding-2">
		<tr>
			<td class="FieldLabelLeftClr">{txt_start_date}</td>
			<td><input type="text" name="{prefix}START_DATE" size="{date_text_size}" maxlength="{date_text_size}" value="{START_DATE}" class="DatePicker"></td>
		</tr>
		<tr>
			<td class="FieldLabelLeftClr">{txt_end_date}</td>
			<td><input type="text" name="{prefix}END_DATE" size="{date_text_size}" maxlength="{date_text_size}" value="{END_DATE}" class="DatePicker"></td>
		</tr>
		<tr>
			<td class="FieldLabelLeftClr">{txt_start_time}</td>
			<td><input type="text" name="{prefix}START_TIME" size="{time_text_size}" maxlength="{time_text_size}" value="{START_TIME}"></td>
		</tr>
		<tr>
			<td class="FieldLabelLeftClr">{txt_end_time}</td>
			<td><input type="text" name="{prefix}END_TIME" size="{time_text_size}" maxlength="{time_text_size}" value="{END_TIME}"></td>
		</tr>
		<tr>
			<td class="FieldLabelLeftClr">{txt_label}</td>
			<td><input type="text" name="{prefix}Label" size="{text_size}" maxlength="{text_size}" value="{Label}"></td>
		</tr>
		<tr>
			<td class="FieldLabelLeftClr">{txt_repeats}</td>
			<td>{RECURS_TYPE}</td>
		</tr>
		<tr class="recurs-ui repeat-every-ui" {recurs_display}">
			<td class="FieldLabelLeftClr">{txt_repeat_every}</td>
			<td>
			<input type="text" name="{prefix}RECURS_EVERY" value="{RECURS_EVERY}" maxlength="2" size="3" class="posint">
			<span class="recurs-week-label" {week_text_display}>{txt_weeks}</span>
			<span class="recurs-month-label" {month_text_display}>{txt_months}</span>
			</td>
		</tr>
		<tr class="recurs-ui repeats-on-ui" {day_of_week_display}>
			<td class="FieldLabelLeftClr">{txt_repeat_on}</td>
			<td>{weekdays}</td>
		</tr>
		<tr class="recurs-ui repeat-week-of-month-ui" {week_of_month_display}>
			<td class="FieldLabelLeftClr">{txt_week_of_month}</td>
			<td><input type="text" name="{prefix}RECURS_XTH_WEEKDAY_OF_MONTH" value="{RECURS_XTH_WEEKDAY_OF_MONTH}" maxlength="2" size="3" class="posint"></td>
		</tr>
		<tr class="recurs-ui repeat-day-of-month-ui" {day_of_month_display}>
			<td class="FieldLabelLeftClr">{txt_day_of_month}</td>
			<td><input type="text" name="{prefix}RECURS_DAY_OF_MONTH" value="{RECURS_DAY_OF_MONTH}" maxlength="2" size="3" class="posint"></td>
		</tr>

		</table>
		{feedback}
		</div><div style="clear: both;"></div></div>
		''').format(prefix=prefix, label=label, **ns).replace(u'\n', u'')
	return output


def makeEventScheduleContents_l(rst, bUseContent, has_feedback=False, rsFb=None, is_entryform=False):
	xml = None
	if bUseContent:
		xml = rst.Fields('EVENT_SCHEDULE').Value

	xml = xml or u"<SCHEDULES/>"
	xml = ET.fromstring(xml.encode('utf-8'))

	output = [Markup(u"""<div id="ScheduleEditArea" class="ScheduleEditArea EntryFormItemContainer" data-add-tmpl="{}">""").format(
		six.text_type(makeEventScheduleEntry({}, Markup(u'%s <span class="EntryFormItemCount">[COUNT]</span> %s') % (_('Schedule #'), _('(new)')), u"Sched_[ID]_")))
	]

	if is_entryform and bUseContent and has_feedback:
		feedback = prepEventScheduleFeedback(rsFb)
	else:
		feedback = None

	ids = []
	count = 0
	for count, item in enumerate(xml, 1):
		attrs = item.attrib
		sched_id = attrs['SchedID']
		ids.append(sched_id)
		output.append(
			makeEventScheduleEntry(
				attrs, Markup(u'%s <span class="EntryFormItemCount">%s</span>') % (_('Schedule #'), count),
				u"Sched_%s_" % sched_id,
				feedback
			)
		)
	
	if feedback:
		for fb_num, fbe in enumerate(feedback):
			for entry in fbe.get('_order', []):
				if not entry.startswith('NEW'):
					continue
				count += 1
				fake_entry = {'SchedID': entry}
				ids.append(entry)
				output.append(
					makeEventScheduleEntry(
						fake_entry, Markup(u'%s <span class="EntryFormItemCount">%s</span> %s') % (_('Schedule #'), count, _('(new from feedback)')),
						u"Sched_%s_" % entry,
						[fbe if i == fb_num else {} for i in range(len(feedback))]
					)
				)

	output.append(
		Markup(u'''
		<input type="hidden" name="Sched_IDS" class="EntryFormItemContainerIds" id="Sched_IDS" value="{}"></div>
		<button class="ui-state-default ui-corner-all EntryFormItemAdd" type="button" id="Sched_add_button">{}</button>
		''').format(u','.join(ids), _('Add'))
	)
	
	return u''.join(output)

</script>

<%
Dim bFieldHasFeedback
bFieldHasFeedback = False

Function getDropDownValue(strValue, strFunction, bLangID, strFieldName)
	Dim strReturn
	strReturn = vbNullString

	If Not Nl(strValue) And IsIDType(strValue) Then
		Dim cmdDropDown, rsDropDown
		Set cmdDropDown = Server.CreateObject("ADODB.Command")
		With cmdDropDown
			.ActiveConnection = getCurrentBasicCnn()
			.CommandText = "SELECT " & strFunction & "(" & strValue & StringIf(Not Nl(strFieldName),"," & QsNl(strFieldName)) & StringIf(bLangID,",@@LANGID") & StringIf(strFunction="dbo.fn_GBL_DisplayCurrency",",1") & ") AS DropDown"
			.CommandType = adCmdText
			.CommandTimeout = 0
		End With
		Set rsDropDown = Server.CreateObject("ADODB.Recordset")
		With rsDropDown
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdDropDown
			If Not .EOF Then
				strReturn = .Fields("DropDown")
			End If
			.Close
		End With
		Set rsDropDown = Nothing
		Set cmdDropDown = Nothing
	End If
	
	getDropDownValue = strReturn
End Function

Const EF_NEW = 0
Const EF_UPDATE = 1
Const EF_COPY = 2
Const EF_CREATEFB = 3

Dim bFeedback, _
	bFeedbackForm
bFeedback = False
bFeedbackForm = False

Dim	bFullUpdate
bFullUpdate = (ps_intDbArea = DM_CIC And user_bFullUpdateCIC) Or _
	(ps_intDbArea = DM_VOL And user_bFullUpdateVOL)

Function getFeedback(strFieldName,bUpdateButton,bWYSIWYG)
	Dim strReturn, strContent, strDisplay, i
	If bFeedback Then
		i = 1
		With rsFb
			.MoveFirst
			While Not .EOF
				If Not Nl(rsFb(strFieldName)) Then
					strContent = rsFb(strFieldName)
					strDisplay = strContent
					Select Case strFieldName
						Case "ACCREDITED"
							strDisplay = getDropDownValue(strContent,"dbo.fn_CIC_DisplayAccreditation",True,Null)
						Case "CERTIFIED"
							strDisplay = getDropDownValue(strContent,"dbo.fn_CIC_DisplayCertification",True,Null)
						Case "EMPLOYEES_RANGE"
							Dim intERID
							intERID = strContent
							If Not Nl(intERID) And IsIDType(intERID) Then
								Dim cmdEmployeeRange, rsEmployeeRange
								Set cmdEmployeeRange = Server.CreateObject("ADODB.Command")
								With cmdEmployeeRange
									.ActiveConnection = getCurrentCICBasicCnn()
									.CommandText = "dbo.sp_CIC_EmployeeRange_s"
									.CommandType = adCmdStoredProc
									.CommandTimeout = 0
									.Parameters.Append .CreateParameter("@ER_ID", adInteger, adParamInput, 4, intERID)
								End With
								Set rsEmployeeRange = Server.CreateObject("ADODB.Recordset")
								With rsEmployeeRange
									.CursorLocation = adUseClient
									.CursorType = adOpenStatic
									.Open cmdEmployeeRange
									If Not .EOF Then
										strDisplay = .Fields("Range")
									End If
									.Close
								End With
								Set rsEmployeeRange = Nothing
								Set cmdEmployeeRange = Nothing
							End If
						Case "FISCAL_YEAR_END"
							strDisplay = getDropDownValue(strContent,"dbo.fn_CIC_DisplayFiscalYearEnd",True,Null)
						Case "PAYMENT_TERMS"
							strDisplay = getDropDownValue(strContent,"dbo.fn_GBL_DisplayPaymentTerms",True,Null)
						Case "PREF_CURRENCY"
							strDisplay = getDropDownValue(strContent,"dbo.fn_GBL_DisplayCurrency",False,Null)
						Case "PREF_PAYMENT_METHOD"
							strDisplay = getDropDownValue(strContent,"dbo.fn_GBL_DisplayPaymentMethod",True,Null)
						Case "QUALITY"
							strDisplay = getDropDownValue(strContent,"dbo.fn_CIC_FullQuality",False,Null)
						Case "MAIL_STREET_TYPE"
							Dim bMSTAfter
							bMSTAfter = rsFb("MAIL_STREET_TYPE_AFTER")
							If Not Nl(bMSTAfter) Then
								bMSTAfter = CBool(bMSTAfter)
								strContent = strContent & "|" & IIf(bMSTAfter,SQL_TRUE,SQL_FALSE)
								strDisplay = strDisplay & " - " & IIf(bMSTAfter,TXT_AFTER_NAME, TXT_BEFORE_NAME)
							End If
						Case "MINIMUM_HOURS_PER"
							strDisplay = Nz(getDropDownValue(strContent,"dbo.fn_VOL_DisplayMinHoursPer",True,Null), strContent)
						Case "RECORD_TYPE"
							strDisplay = getDropDownValue(strContent,"dbo.fn_CIC_FullRecordType",False,Null)
						Case "SITE_STREET_TYPE"
							Dim bSSTAfter
							bSSTAfter = rsFb("SITE_STREET_TYPE_AFTER")
							If Not Nl(bSSTAfter) Then
								bSSTAfter = CBool(bSSTAfter)
								strContent = strContent & "|" & IIf(bSSTAfter,SQL_TRUE,SQL_FALSE)
								strDisplay = strDisplay & " - " & IIf(bSSTAfter,TXT_AFTER_NAME, TXT_BEFORE_NAME)
							End If
						Case "TYPE_OF_PROGRAM"
							strDisplay = getDropDownValue(strContent,"dbo.fn_CCR_DisplayTypeOfProgram",True,Null)
						Case "WARD"
							strDisplay = getDropDownValue(strContent,"dbo.fn_CIC_FullWard",False,Null)
					End Select
					If reEquals(strFieldName,"EXTRA_DROPDOWN_.*",False,False,True,False) Then
						strDisplay = getDropDownValue(strContent,"dbo.fn_" & ps_strDbArea & "_DisplayExtraDropDown",True,strFieldName)
					End If
					strReturn = strReturn & _
						"<div class=""feedback-item"">" & _
							"<span class=""Info"">" & TXT_FEEDBACK_NUM & i & StringIf(g_bMultiLingual," (" & .Fields("LanguageName") & ")") & TXT_COLON & "</span>" & _
							" <span class=""Alert"">" & textToHTML(strDisplay)
					If bUpdateButton Then
						If bWYSIWYG Then
							strReturn = strReturn & " <input type=""button"" value=""" & TXT_UPDATE & """ onClick=""tinymce.get(" & JsQs(strFieldName) & ").setContent("
						Else
							strReturn = strReturn & " <input type=""button"" value=""" & TXT_UPDATE & """ onClick=""document.EntryForm." & strFieldName & ".value="
						End If
						If Not reEquals(.Fields(strFieldName),CONTENT_DELETED_PATTERN,False,False,True,False) Then
							strReturn = strReturn & JsQs(Server.HTMLEncode(strContent))
						Else
							strReturn = strReturn & SQUOTE & SQUOTE
						End If
						strReturn = strReturn & StringIf(bWYSIWYG,")") & ";"" class=""ui-state-default ui-corner-all"">"
					End If
					strReturn = strReturn & _
							"</span>" & _
						"</div>"
				End If
				i = i+1
				.MoveNext
			Wend
		End With
	End If

	If Not Nl(strReturn) Then
		bFieldHasFeedback = True
	End If

	getFeedback = strReturn
End Function

Function getDateFeedback(strFieldName,bUpdateButton,bNoYear)
	Dim strReturn, i, strTmpDate
	If bFeedback Then
		i = 1
		With rsFb
			.MoveFirst
			While Not .EOF
				If Not Nl(rsFb(strFieldName)) Then
					strTmpDate = rsFb(strFieldName)
					If IsSmallDate(strTmpDate) Then
						strTmpDate = DateString(strTmpDate,True)
					End If
					If bNoYear Then
						strTmpDate = Replace(strTmpDate, " " & Year(Now()), "")
					End If
					strReturn = strReturn & _
						"<div class=""feedback-item"">" & _
							"<span class=""Info"">" & TXT_FEEDBACK_NUM & i & StringIf(g_bMultiLingual," (" & .Fields("LanguageName") & ")") & TXT_COLON & "</span>" & _
							" <span class=""Alert"">" & strTmpDate
					If bUpdateButton Then
						strReturn = strReturn & " <input type=""button"" value=""" & TXT_UPDATE & """ onClick=""document.EntryForm." & strFieldName & ".value="
						If rsFb(strFieldName) <> TXT_CONTENT_DELETED Then
							strReturn = strReturn & JsQs(strTmpDate)
						Else
							strReturn = strReturn & SQUOTE & SQUOTE
						End If
						strReturn = strReturn & ";"" class=""ui-state-default ui-corner-all"">"
					End If
					strReturn = strReturn & _
							"</span>" & _
						"</div>"
				End If
				i = i+1
				.MoveNext
			Wend
		End With
	End If
	
	If Not Nl(strReturn) Then
		bFieldHasFeedback = True
	End If

	getDateFeedback = strReturn
End Function

Function getCbFeedback(strFieldName,strOnVal,strOffVal)
	Dim strReturn, i
	If bFeedback Then
		i = 1
		With rsFb
			.MoveFirst
			While Not .EOF
				If Not Nl(rsFb(strFieldName)) Then
					strReturn = strReturn & "<br><span class=""Info"">" & _
						TXT_FEEDBACK_NUM & i & StringIf(g_bMultiLingual," (" & .Fields("LanguageName") & ")") & TXT_COLON & _
						"</span> <span class=""Alert"">"
					If rsFb(strFieldName) <> "0" And rsFb(strFieldName) <> "1" Then
						strReturn = strReturn & rsFb(strFieldName)
					Else
						strReturn = strReturn & textToHTML(IIf(rsFb(strFieldName),strOnVal,strOffVal))
					End If
					strReturn = strReturn & "</span>"
				End If
				i = i+1
				.MoveNext
			Wend
		End With
	End If

	If Not Nl(strReturn) Then
		bFieldHasFeedback = True
	End If

	getCbFeedback = strReturn
End Function

Function getGeoCodeFeedback()
	Dim strReturn, i
	
	Dim strJSUpdate
	
	If bFeedback Then
		i = 1
		With rsFb
			.MoveFirst
			While Not .EOF
				If Not Nl(rsFb("GEOCODE_TYPE")) Or Not Nl(rsFb("LATITUDE")) Or Not Nl(rsFb("LATITUDE")) Then
					strReturn = strReturn & "<br><span class=""Info"">" & _
						TXT_FEEDBACK_NUM & i & StringIf(g_bMultiLingual," (" & .Fields("LanguageName") & ")") & TXT_COLON & _
						"</span> <span class=""Alert"">"
					Select Case rsFb("GEOCODE_TYPE")
						Case GC_BLANK
							strReturn = strReturn & TXT_GC_BLANK_NO_GEOCODE
							strJSUpdate = "document.getElementById('GEOCODE_TYPE_BLANK').click();"
						Case GC_SITE
							strReturn = strReturn & TXT_GC_SITE_ADDRESS
							strJSUpdate = "document.getElementById('GEOCODE_TYPE_SITE').click();"
						Case GC_INTERSECTION
							strReturn = strReturn & TXT_GC_INTERSECTION
							strJSUpdate = "document.getElementById('GEOCODE_TYPE_INTERSECTION').click();"
						Case GC_MANUAL
							strReturn = strReturn & TXT_GC_MANUAL
							strJSUpdate = "document.getElementById('GEOCODE_TYPE_MANUAL').checked=true;"
							strJSUpdate = strJSUpdate & "do_geocode_type_manual(true);"
							If Not Nl(rsFb("LATITUDE")) And Not Nl(rsFb("LONGITUDE")) Then
								strReturn = strReturn & " [" & Nz(rsFb("LATITUDE"),"?") & ", " & Nz(rsFb("LONGITUDE"),"?") & "]"
								strJSUpdate = strJSUpdate & "handle_geocode_entryform_feedback(" & _
									Nz(Replace(rsFb("LATITUDE"),",","."),"document.getElementById('LATITUDE').value") & "," & _
									Nz(Replace(rsFb("LONGITUDE"),",","."),"document.getElementById('LONGITUDE').value") & ");"
							End If
					End Select
					strReturn = strReturn & " <input type=""button"" value=""" & TXT_UPDATE & """ onClick=""" & strJSUpdate & """ class=""ui-state-default ui-corner-all""></span>"
				End If
				i = i+1
				.MoveNext
			Wend
		End With
	End If
	getGeoCodeFeedback = strReturn
End Function

Function makeMemoFieldVal(strFieldName,strFieldContents,intSuggestedLength,bCheckForFeedback,bWYSIWYG)
	Dim strReturn
	Dim intFieldLen
	If Nl(strFieldContents) Then
		intFieldLen = 0
	Else
		intFieldLen = Len(strFieldContents)
		If bWYSIWYG Then
			strFieldContents = textToHTML(strFieldContents)
		End If
		strFieldContents = Server.HTMLEncode(strFieldContents)
	End If
	strReturn = strReturn & "<textarea" & _
		" id=" & AttrQs(strFieldName) & _
		" name=" & AttrQs(strFieldName) & _
		" rows=" & AttrQs(getTextAreaRows(intFieldLen,intSuggestedLength)) & _
		" class=""form-control" & IIf(bWYSIWYG," WYSIWYG",vbNullString) & """" & _
		" autocomplete=""off""" & _
		">" & strFieldContents & "</textarea>"
	If bFeedback And bCheckForFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True,True)
	End If
	makeMemoFieldVal = strReturn
End Function

Function makeValidatedTextFieldVal(strFieldName,strFieldContents,intMaxLength,bCheckForFeedback,strValidate)
	Dim strReturn, _
		bSmallField

	If intMaxLength < 20 Then
		bSmallField = True
	End If

	strReturn = strReturn & _
		StringIf(bSmallField,"<div class=""form-inline"">") & _
		"<input type=""text""" & _
			" id=" & AttrQs(strFieldName) & _
			" name=" & AttrQs(strFieldName) & _
			" class=""form-control" & StringIf(Not Nl(strValidate)," " & strValidate) & """" & _
			" autocomplete=""off""" & _
			StringIf(Not Nl(intMaxLength), " maxlength=""" & intMaxLength & """") & _
			" value=" & AttrQs(strFieldContents) & ">" & _
		"</div>"
	If bFeedback And bCheckForFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True,False)
	End If
	makeValidatedTextFieldVal = strReturn
End Function

Function makeTextFieldVal(strFieldName,strFieldContents,intMaxLength,bCheckForFeedback)
	makeTextFieldVal = makeValidatedTextFieldVal(strFieldName,strFieldContents,intMaxLength,bCheckForFeedback,vbNullString)
End Function

Function makeWebFieldVal(strFieldName,strFieldContents,intMaxLength,bCheckForFeedback,strProtocol)
	Dim strReturn
	strReturn = strReturn & "<input type=""text""" & _
		" id=" & AttrQs(strFieldName) & _
		" name=" & AttrQs(strFieldName) & _
		" class=""protourl form-control""" & _
		" autocomplete=""off"""
	If Not Nl(intMaxLength) Then
		intMaxLength = intMaxLength + 8
		strReturn = strReturn & " maxlength=""" & intMaxLength & """"
	End If
	strReturn = strReturn & " value=" & AttrQs(Replace(Ns(strProtocol), "http://", vbNullString) & strFieldContents) & ">"
	If bFeedback And bCheckForFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True,False)
	End If
	makeWebFieldVal = strReturn
End Function

Function makeCBFieldVal(strFieldName,strFieldContents,strOnText,strOffText,strNullText,bAllowNulls,bCheckForFeedback)
	Dim strReturn
	If bAllowNulls Then
		strReturn = "<label for=""" & strFieldName & "_UNKNOWN"" class=""radio-inline""><input type=""radio""" & _
		" id=" & AttrQs(strFieldName & "_UNKNOWN") & _
		" name=" & AttrQs(strFieldName) & _
		" value="""""
		If Nl(strFieldContents) Then
			strReturn = strReturn & " checked"
		End If
		strReturn = strReturn & ">" & Nz(strNullText,TXT_UNKNOWN) & "</label>"
	End If
	strReturn = strReturn & " <label for=""" & strFieldName & "_YES"" class=""radio-inline""><input type=""radio""" & _
		" id=" & AttrQs(strFieldName & "_YES") & _
		" name=" & AttrQs(strFieldName) & _
		" value=" & AttrQs(SQL_TRUE)
	If strFieldContents = True Then
		strReturn = strReturn & " checked"
	End If
	strReturn = strReturn & ">" & strOnText & "</label>" & _
		" <label for=""" & strFieldName & "_NO"" class=""radio-inline""><input type=""radio""" & _
		" id=" & AttrQs(strFieldName & "_NO") & _
		" name=" & AttrQs(strFieldName) & _
		" value=" & AttrQs(SQL_FALSE)
	If strFieldContents = False Then
		strReturn = strReturn & " checked"
	End If
	strReturn = strReturn & ">" & strOffText & "</label>"
	If bFeedback And bCheckForFeedback Then
		strReturn = strReturn & getCbFeedback(strFieldName,strOnText,strOffText)
	End If
	makeCBFieldVal = strReturn
End Function

Dim bAddressRecordsetsOpen
bAddressRecordsetsOpen = False

Sub openAddressRecordsets()
	If Not bAddressRecordsetsOpen Then
		Call openBoxTypeListRst()
		Call openStreetTypeListRst(False)
		Call openStreetDirListRst()
		If Not bFeedbackForm Then
			Call openMappingSystemListRst(False)
		End If
		bAddressRecordsetsOpen = True
	End If
End Sub

Sub closeAddressRecordsets()
	If bAddressRecordsetsOpen Then
		Call closeBoxTypeListRst()
		Call closeStreetTypeListRst()
		Call closeStreetDirListRst()
		If Not bFeedbackForm Then
			Call closeMappingSystemListRst()
		End If
	End If
End Sub

Function makeContactContents(rst,strContactType,bUseContent)
	Dim strReturn, strQFldName
	Dim xmlDoc, xmlNode
	
	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With
	
	If bUseContent Then
		xmlDoc.loadXML Nz(rst(strContactType).Value,"<CONTACT/>")
	Else
		xmlDoc.loadXML "<CONTACT/>"
	End If
	Set xmlNode = xmlDoc.selectSingleNode("/CONTACT")
	
	strQFldName = AttrQs(strContactType & "_NAME")
	strReturn = _
			"<div class=""form-group"">" & _
				"<label for=" & strQFldName & " class=""control-label col-sm-3 col-lg-2"">" & TXT_NAME & "</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
					"<input type=""text"" name=" & strQFldName & " class=""form-control"" id=" & strQFldName & " maxlength=""100"" autocomplete=""off"" value=" & AttrQs(xmlNode.getAttribute("NAME")) & ">" & _
				"</div>" & _
			"</div>"
	strQFldName = AttrQs(strContactType & "_TITLE") 
	strReturn = strReturn & _
			"<div class=""form-group"">" & _
				"<label for=" & strQFldName & " class=""control-label col-sm-3 col-lg-2"">" & TXT_TITLE & "</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
					"<input type=""text"" name=" & strQFldName & " class=""form-control"" id=" & strQFldName & " maxlength=""100"" autocomplete=""off"" value=" & AttrQs(xmlNode.getAttribute("TITLE")) & "></div>" & _
			"</div>"
	strQFldName = AttrQs(strContactType & "_ORG")
	strReturn = strReturn & _
			"<div class=""form-group"">" & _
				"<label for=" & strQFldName & " class=""control-label col-sm-3 col-lg-2"">" & TXT_ORGANIZATION & "</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
					"<input type=""text"" name=" & strQFldName & " class=""form-control"" id=" & strQFldName & " maxlength=""100"" autocomplete=""off"" value=" & AttrQs(xmlNode.getAttribute("ORG")) & ">" & _
				"</div>" & _
			"</div>"
	Dim i
	For i = 1 to 3
		strQFldName = AttrQs(strContactType & "_PHONE" & i)
		strReturn = strReturn & _
			"<div class=""form-group"">" & _
				"<label for=" & strQFldName & " class=""control-label col-sm-3 col-lg-2"">" & TXT_PHONE & " #" & i & "</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
					"<input type=""text"" name=" & strQFldName  & " class=""form-control"" id=" & strQFldName & " maxlength=""100"" autocomplete=""off"" value=" & AttrQs(xmlNode.getAttribute("PHONE" & i)) & ">" & _
				"</div>" & _
			"</div>"
	Next
	strQFldName = AttrQs(strContactType & "_FAX")
	strReturn = strReturn & _
			"<div class=""form-group"">" & _
				"<label for=" & strQFldName & " class=""control-label col-sm-3 col-lg-2"">" & TXT_FAX & "</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
					"<input type=""text"" name=" & strQFldName  & " class=""form-control"" id=" & strQFldName & " maxlength=""100"" autocomplete=""off"" value=" & AttrQs(xmlNode.getAttribute("FAX")) & ">" & _
				"</div>" & _
			"</div>"
	strQFldName = AttrQs(strContactType & "_EMAIL")
	strReturn = strReturn & _
			"<div class=""form-group"">" & _
				"<label for=" & strQFldName & " class=""control-label col-sm-3 col-lg-2"">" & TXT_EMAIL & "</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
					"<input type=""text"" name=" & strQFldName  & " class=""form-control"" id=" & strQFldName & " maxlength=""100"" autocomplete=""off"" value=" & AttrQs(xmlNode.getAttribute("EMAIL")) & ">" & _
				"</div>" & _
			"</div>"
			
	makeContactContents = strReturn
End Function

Function makeContactFieldVal(rst,strContactType,bUseContent)
	Dim strReturn, strQFldName
	Dim xmlDoc, xmlNode
	
	Call openContactRecordsets()
	
	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With
	
	If bUseContent Then
		xmlDoc.loadXML Nz(rst(strContactType).Value,"<CONTACT/>")
	Else
		xmlDoc.loadXML "<CONTACT/>"
	End If
	Set xmlNode = xmlDoc.selectSingleNode("/CONTACT")
	
	strReturn = "<input type=""hidden"" name=""" & strContactType & "_ID" & """ value=""" & xmlNode.getAttribute("ContactID") & """>"

	strReturn = strReturn & _
		"<div class=""row-border-bottom"">" & _
			"<div class=""form-group"">" & _
				"<label class=""control-label col-sm-3 col-lg-2"">" & TXT_NAME & "</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
						"<table class=""NoBorder cell-padding-2 full-width"">" & _
						"<tr>" & _
							"<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_NAME_FIRST"">" & TXT_NAME_FIRST & "</label></td>" & _
							"<td><div class=""form-inline"">" & makeHonorificList(xmlNode.getAttribute("NAME_HONORIFIC"),strContactType & "_NAME_HONORIFIC",True,False) & "</div></td>" & _
							"<td class=""table-cell-100""><input type=""text"" id=""" & strContactType & "_NAME_FIRST"" name=""" & strContactType & "_NAME_FIRST"" maxlength=""60"" autocomplete=""off"" value=" & attrQs(xmlNode.getAttribute("NAME_FIRST")) & " class=""form-control""></td>" & _
						"</tr>" & _
						"<tr>" & _
							"<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_NAME_LAST"">" & TXT_NAME_LAST & "</label></td>" & _
							"<td colspan=""2""><input type=""text"" id=""" & strContactType & "_NAME_LAST"" name=""" & strContactType & "_NAME_LAST"" maxlength=""100"" autocomplete=""off"" value=" & attrQs(xmlNode.getAttribute("NAME_LAST")) & " class=""form-control""></td>" & _
						"</tr>" & _
						"<tr>" & _
							"<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_NAME_SUFFIX"">" & TXT_SUFFIX & "</label></td>" & _
							"<td colspan=""2""><input type=""text"" id=""" & strContactType & "_NAME_SUFFIX"" name=""" & strContactType & "_NAME_SUFFIX"" maxlength=""30"" autocomplete=""off"" value=" & attrQs(xmlNode.getAttribute("NAME_SUFFIX")) & " class=""form-control""></td>" & _
						"</tr>" & _
						"</table>"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strContactType & "_NAME",False,False)
	End If
	strReturn = strReturn & _
					"</div>" & _
				"</div>" & _
			"</div>"

	strQFldName = AttrQs(strContactType & "_TITLE")
	strReturn = strReturn & _
			"<div class=""row-border-bottom"">" & _
				"<div class=""form-group"">" & _
					"<label for=" & strQFldName & " class=""control-label col-sm-3 col-lg-2"">" & TXT_TITLE & "</label>" & _
					"<div class=""col-sm-9 col-lg-10"">" & _
						"<input type=""text"" name=" & strQFldName  & " class=""form-control"" id=" & strQFldName & " maxlength=""100"" autocomplete=""off"" value=" & AttrQs(xmlNode.getAttribute("TITLE")) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strContactType & "_TITLE",True,False)
	End If
	strReturn = strReturn & _
					"</div>" & _
				"</div>" & _
			"</div>"

	strQFldName = AttrQs(strContactType & "_ORG")
	strReturn = strReturn & _
			"<div class=""row-border-bottom"">" & _
				"<div class=""form-group"">" & _
					"<label for=" & strQFldName & " class=""control-label col-sm-3 col-lg-2"">" & TXT_ORGANIZATION & "</label>" & _
					"<div class=""col-sm-9 col-lg-10"">" & _
						"<input type=""text"" name=" & strQFldName  & " class=""form-control"" id=" & strQFldName & " maxlength=""100"" autocomplete=""off"" value=" & AttrQs(xmlNode.getAttribute("ORG")) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strContactType & "_ORG",True,False)
	End If
	strReturn = strReturn & _
					"</div>" & _
				"</div>" & _
			"</div>"
		
	Dim i
	For i = 1 to 3
		strReturn = strReturn & _
			"<div class=""row-border-bottom"">" & _
				"<div class=""form-group"">" & _
					"<label class=""control-label col-sm-3 col-lg-2"">" & TXT_PHONE & " #" & i & "</label>" & _
					"<div class=""col-sm-9 col-lg-10"">" & _
						"<table class=""NoBorder cell-padding-2 full-width"">" & _
						"<tr>" & _
							"<td class=""FieldLabelLeftClr"">" & TXT_TYPE & "</td>" & _
							"<td>" & makeContactPhoneTypeList(xmlNode.getAttribute("PHONE_" & i & "_TYPE"),strContactType & "_PHONE_" & i & "_TYPE",True,False) & "</td>" & _
							"<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_PHONE_" & i & "_NOTE"">" & TXT_NOTES & "</label></td>" & _
							"<td colspan=""3""><input type=""text"" id=""" & strContactType & "_PHONE_" & i & "_NOTE"" name=""" & strContactType & "_PHONE_" & i & "_NOTE"" size=""30"" maxlength=""100"" autocomplete=""off"" value=" & attrQs(xmlNode.getAttribute("PHONE_" & i & "_NOTE")) & " class=""form-control""></td>" & _
						"</tr>" & _
						"<tr>" & _
							"<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_PHONE_" & i & "_NO"">" & TXT_NUMBER & "</label></td>" & _
							"<td><input type=""text"" id=""" & strContactType & "_PHONE_" & i & "_NO"" name=""" & strContactType & "_PHONE_" & i & "_NO"" size=""20"" maxlength=""20"" autocomplete=""off"" value=" & attrQs(xmlNode.getAttribute("PHONE_" & i & "_NO")) & " class=""form-control""></td>" & _
							"<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_PHONE_" & i & "_EXT"">" & TXT_EXT & "</label></td>" & _
							"<td><input type=""text"" id=""" & strContactType & "_PHONE_" & i & "_EXT"" name=""" & strContactType & "_PHONE_" & i & "_EXT"" size=""6"" maxlength=""10"" autocomplete=""off"" value=" & attrQs(xmlNode.getAttribute("PHONE_" & i & "_EXT")) & " class=""form-control""></td>" & _
							"<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_PHONE_" & i & "_OPTION"">" & TXT_OPTION & "</label></td>" & _
							"<td><input type=""text"" id=""" & strContactType & "_PHONE_" & i & "_OPTION"" name=""" & strContactType & "_PHONE_" & i & "_OPTION"" size=""6"" maxlength=""10"" autocomplete=""off"" value=" & attrQs(xmlNode.getAttribute("PHONE_" & i & "_OPTION")) & " class=""form-control""></td>" & _
						"</tr>" & _
						"</table>"
		If bFeedback Then
			strReturn = strReturn & getFeedback(strContactType & "_PHONE" & i,False,False)
		End If
		strReturn = strReturn & _
						"</div>" & _
					"</div>" & _
				"</div>"
	Next

	strReturn = strReturn & _
		"<div class=""row-border-bottom"">" & _
			"<div class=""form-group"">" & _
				"<label class=""control-label col-sm-3 col-lg-2"">" & TXT_FAX & "</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
					"<table class=""NoBorder cell-padding-2 full-width"">" & _
					"<tr>" & _
					"<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_FAX_NOTE"">" & TXT_NOTES & "</label></td>" & _
					"<td colspan=""3""><input type=""text"" id=""" & strContactType & "_FAX_NOTE"" name=""" & strContactType & "_FAX_NOTE"" maxlength=""100"" autocomplete=""off"" value=" & attrQs(xmlNode.getAttribute("FAX_NOTE")) & " class=""form-control""></td>" & _
					"</tr>" & _
					"<tr>" & _
					"<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_FAX_NO"">" & TXT_NUMBER & "</label></td>" & _
					"<td><input type=""text"" id=""" & strContactType & "_FAX_NO"" name=""" & strContactType & "_FAX_NO"" maxlength=""20"" autocomplete=""off"" value=" & attrQs(xmlNode.getAttribute("FAX_NO")) & " class=""form-control""></td>" & _
					"<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_FAX_EXT"">" & TXT_EXT & "</label></td>" & _
					"<td><input type=""text"" id=""" & strContactType & "_FAX_EXT"" name=""" & strContactType & "_FAX_EXT"" size=""6"" maxlength=""10"" autocomplete=""off"" value=" & attrQs(xmlNode.getAttribute("FAX_EXT")) & " class=""form-control""></td>" & _
					"</tr><tr>" & _
					"<td colspan=""4""><label for=""" & strContactType & "_FAX_CALLFIRST""><input type=""checkbox"" id=""" & strContactType & "_FAX_CALLFIRST"" name=""" & strContactType & "_FAX_CALLFIRST"" value=""on""" & Checked(xmlNode.getAttribute("FAX_CALLFIRST")) & "> <span class=""FieldLabelClr"">" & TXT_PLEASE_CALL_FIRST & "</span></label></td>" & _
					"</tr>" & _
					"</table>"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strContactType & "_FAX",False,False)
	End If
	strReturn = strReturn & _
					"</div>" & _
				"</div>" & _
			"</div>"

	strQFldName = AttrQs(strContactType & "_EMAIL")
	strReturn = strReturn & _
			"<div class=""row-border-bottom"">" & _
				"<div class=""form-group"">" & _
					"<label for=" & strQFldName & " class=""control-label col-sm-3 col-lg-2"">" & TXT_EMAIL & "</label>" & _
					"<div class=""col-sm-9 col-lg-10"">" & _
						"<input type=""text"" name=" & strQFldName  & " class=""form-control"" id=" & strQFldName & " maxlength=""100"" autocomplete=""off"" value=" & AttrQs(xmlNode.getAttribute("EMAIL")) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strContactType & "_EMAIL",True,False)
	End If
	strReturn = strReturn & _
					"</div>" & _
				"</div>" & _
			"</div>"


	makeContactFieldVal = strReturn
End Function

Function makeExtraCheckListContents(rst,bUseContent,bFbForm)
	Dim strReturn, strCon
	Dim intEXCID, strName, bIsSelected, strFeedback
	Dim xmlDoc, xmlNode, xmlChildNode
	
	strCon = vbNullString
	
	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With

	If bUseContent Then
		xmlDoc.loadXML Nz(rst(strFieldName & "_XML").Value,"<EXTRA_CHECKLIST/>")
	Else
		Dim rsExtraCheckList, cmdExtraCheckList
		Set cmdExtraCheckList = Server.CreateObject("ADODB.Command")
		With cmdExtraCheckList
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_" & ps_strDbArea & "_ExtraCheckList_s_Entryform"
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@FieldName", adVarChar, adParamInput, 100, strFieldName)
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
		End With
		Set rsExtraCheckList = Server.CreateObject("ADODB.Recordset")
		With rsExtraCheckList
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdExtraCheckList
		End With

		If Not rsExtraCheckList.EOF Then
			xmlDoc.loadXML Nz(rsExtraCheckList("EXTRA_CHECKLIST").Value, "<EXTRA_CHECKLIST/>")
		Else
			xmlDoc.loadXML "<EXTRA_CHECKLIST/>"
		End If

		Call rsExtraCheckList.Close()

		Set rsExtraCheckList = Nothing
		Set cmdExtraCheckList = Nothing
	End If

	Set xmlNode = xmlDoc.selectSingleNode("/EXTRA_CHECKLIST")
	
	If Not xmlNode Is Nothing Then
		For Each xmlChildNode in xmlNode.childNodes
			strFeedback = vbNullString
			intEXCID = xmlChildNode.getAttribute("ID")
			strName = xmlChildNode.getAttribute("Name")
			bIsSelected = xmlChildNode.getAttribute("SELECTED")
			strReturn = strReturn & _
				strCon & "<label for=" & AttrQs(strFieldName & "_" & intEXCID) & "><input type=""checkbox""" & _
					Checked(bIsSelected) & _
					" id=" & AttrQs(strFieldName & "_" & intEXCID) & _
					" name=" & AttrQs(strFieldName & IIf(bFbForm,"_LISTITEMS","_ID")) & _
					" value=" & AttrQs(IIf(bFbForm,"#" & strName & "#",intEXCID)) & _
					">" & strName & "</label>"
			strCon = "<br>"
		Next
	End If

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False,False)
	End If

	makeExtraCheckListContents = strReturn
End Function

Function makeExtraDropDownContents(rst,bUseContent,bFbForm)
	Dim strReturn, _
		intCurVal
		
	If bUseContent Then
		intCurVal = rst(strFieldName)
	Else
		intCurVal = vbNullString
	End If
	
	Call openExtraDropDownListRst(ps_strDbArea, strFieldName, False, False, intCurVal)
	strReturn = makeExtraDropDownList(strFieldName, intCurVal, strFieldName, True, vbNullString)
	Call closeExtraDropDownListRst(strFieldName)
	
	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True,False)
	End If

	makeExtraDropDownContents = strReturn
End Function

Function makeDateFieldValFull(strFieldName,strFieldContents,bDateToday,bDate3Months,bDate6Months,bDate1Year,bDate18Months,bCheckForFeedback,bNoYear)
	Dim strReturn, strValue

	strValue = strFieldContents
	If Not bNoYear Then
		strValue = DateString(strFieldContents, True)
	End If
	strReturn = "<div class=""form-inline"">" & _
		"<input type=""text"" class=""DatePicker form-control" & StringIf(bNoYear, " NoYear") & """" & _
		" id=" & AttrQs(strFieldName) & _
		" name=" & AttrQs(strFieldName) & _
		" maxlength=""" & DATE_TEXT_SIZE & """ size=""" & DATE_TEXT_SIZE & """" & _
		" value=" & AttrQs(strValue) & ">"
	If bDateToday Then
		strReturn = strReturn & _
			" <input type=""button"" class=""btn btn-default"" value=" & AttrQs(TXT_TODAY) & " onClick=""" & StringIf(bNoYear, "$(") & "document.EntryForm." & _
			strFieldName & IIf(bNoYear, ").datepicker('gotoCurrent')", ".value='" & DateString(Date(),True)) & "';"">"
	End If
	If Not bNoYear Then
		If bDate3Months Then
			strReturn = strReturn & _
				" <input type=""button"" class=""btn btn-default"" value=" & AttrQs(TXT_3_MONTHS) & " onClick=""document.EntryForm." & _
				strFieldName & ".value='" & DateString(DateAdd("m",3,Date()),True) & "';"">"
		End If
		If bDate6Months Then
			strReturn = strReturn & _
				" <input type=""button"" class=""btn btn-default"" value=" & AttrQs(TXT_6_MONTHS) & " onClick=""document.EntryForm." & _
				strFieldName & ".value='" & DateString(DateAdd("m",6,Date()),True) & "';"">"
		End If
		If bDate1Year Then
			strReturn = strReturn & _
				" <input type=""button"" class=""btn btn-default"" value=" & AttrQs(TXT_1_YEAR) & " onClick=""document.EntryForm." & _
				strFieldName & ".value='" & DateString(DateAdd("yyyy",1,Date()),True) & "';"">"
		End If
		If bDate18Months Then
			strReturn = strReturn & _
				" <input type=""button"" class=""btn btn-default"" value=" & AttrQs(TXT_18_MONTHS) & " onClick=""document.EntryForm." & _
				strFieldName & ".value='" & DateString(DateAdd("m",18,Date()),True) & "';"">"
		End If
	End If
	If bFeedback And bCheckForFeedback Then
		strReturn = strReturn & getDateFeedback(strFieldName,True,bNoYear)
	End If
	strReturn = strReturn & "</div>"

	makeDateFieldValFull = strReturn
End Function

Function makeDateFieldVal(strFieldName,strFieldContents,bDateToday,bDate3Months,bDate6Months,bDate1Year,bDate18Months,bCheckForFeedback)
	makeDateFieldVal = makeDateFieldValFull(strFieldName,strFieldContents,bDateToday,bDate3Months,bDate6Months,bDate1Year,bDate18Months,bCheckForFeedback,False)
End Function

Function makeUserFieldVal(strFieldName,strFieldContents,bCheckForFeedback)
	Dim strReturn
	strReturn = strReturn & _
		"<div class=""form-inline"">" & _
		"<input type=""text""" & _
		" id=" & AttrQs(strFieldName) & _
		" name=" & AttrQs(strFieldName) & _
		" maxlength=""50"" size=""30"" " & _
		" class=""form-control""" & _
		" value=" & AttrQs(strFieldContents) & ">"
	If user_bLoggedIn Then
		strReturn = strReturn & " <input type=""button"" class=""btn btn-default"" value=""" & TXT_ME & """ onClick=""document.EntryForm." & strFieldName & ".value='" & user_strMod & "';"">"
	End If
	If bFeedback And bCheckForFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True,False)
	End If
	strReturn = strReturn & "</div>"
	makeUserFieldVal = strReturn
End Function

Dim bCanDeleteRecordNote, bCanUpdateRecordNote
Const RN_CHANGE_NOONE = 0
Const RN_CHANGE_ANYONE = 1
Const RN_CHANGE_SUPER_USER = 2

Function makeRecordNoteEntryTemplate(strNoteType)
	Dim strReturn, strPrefix
	strReturn = vbNullString

	strPrefix = strNoteType & "_[ID]_"

	strReturn = strReturn & _
		"<div class=""EntryFormItemBox"" id=""" & strPrefix & "container"">" & _
		"<h4 class=""EntryFormItemHeader"">" & TXT_NOTE_NUMBER & "<span class=""EntryFormItemCount"">[COUNT]</span><span style=""display:none;"" class=""NewFlag""> " & TXT_NEW & "</span></h4>" & _ 
		"<div id=""" & strPrefix & "EDIT"" class=""EntryFormItemContent"">" & _
		"<table class=""NoBorder cell-padding-2"">" & _
			"<tr style=""display:none;"" class=""CreatedField"">" & _
				"<td class=""FieldLabelLeftClr"">" & TXT_DATE_CREATED & "</td>" & _
				"<td>[CREATED_DATE] ([CREATED_BY])</td>" & _
			"</tr>" & _
			"<tr style=""display:none;"" class=""ModifiedField"">" & _
				"<td class=""FieldLabelLeftClr"">" & TXT_LAST_MODIFIED & "</td>" & _
				"<td>[MODIFIED_DATE] ([MODIFIED_BY])</td>" & _
			"</tr>"
	
	If rsListRecordNoteType.RecordCount > 0 Then		
		strReturn = strReturn & _
			"<tr>" & _
				"<td class=""FieldLabelLeftClr"">" & TXT_NOTE_TYPE & "</td>" & _
				"<td>" & makeRecordNoteTypeList(vbNullString,strPrefix & "NoteTypeID",IIf(ps_intDbArea=DM_CIC,g_bRecordNoteTypeOptionalCIC,g_bRecordNoteTypeOptionalVOL),vbNullString) & "</td>" & _
			"</tr></table>"
	End If
	
	strReturn = strReturn & _
			"<textarea name=""" & strPrefix & "RecordNoteValue"" title=" & AttrQs(TXT_NOTES) & " cols=""" & TEXTAREA_COLS-5 & """ rows=""" & TEXTAREA_ROWS_SHORT & """>[NOTE_VALUE]</textarea>" & _
		"</div><div style=""clear: both;""></div></div>"

	makeRecordNoteEntryTemplate = strReturn
End Function

Function makeRecordNoteEntry(xmlNoteNode, strField)
	Dim strReturn
	strReturn = vbNullString
	
	Dim strPrefix, _
		strHeading, _
		intNoteTypeID, _
		strNoteType, _
		bHighPriority, _
		strNoteValue, _
		dCreated, _
		strCreatedBy, _
		dModified, _
		strModifiedBy, _
		dCancelled, _
		strCancelledBy, _
		bCancelError
		
	dCancelled = xmlNoteNode.getAttribute("CANCELLED_DATE")
	strCancelledBy = Nz(xmlNoteNode.getAttribute("CANCELLED_BY"),TXT_UNKNOWN)
	bCancelError = xmlNoteNode.getAttribute("CancelError")
	strPrefix = strField & "_" & xmlNoteNode.getAttribute("RecordNoteID") & "_"
	intNoteTypeID = xmlNoteNode.getAttribute("NoteTypeID")
	If Not Nl(intNoteTypeID) Then
		intNoteTypeID = CInt(intNoteTypeID)
	End If
	bHighPriority = xmlNoteNode.getAttribute("HighPriority")
	If Not Nl(bHighPriority) And bHighPriority = "1" Then
		bHighPriority = True
	Else
		bHighPriority = False
	End If
	strNoteType = xmlNoteNode.getAttribute("NoteTypeName")
	strNoteValue = xmlNoteNode.getAttribute("Value")
	dCreated = Nz(xmlNoteNode.getAttribute("CREATED_DATE"),TXT_UNKNOWN)
	strCreatedBy = Nz(xmlNoteNode.getAttribute("CREATED_BY"),TXT_UNKNOWN)
	dModified = Nz(xmlNoteNode.getAttribute("MODIFIED_DATE"),TXT_UNKNOWN)
	strModifiedBy = Nz(xmlNoteNode.getAttribute("MODIFIED_BY"),TXT_UNKNOWN)

	strReturn = strReturn & _
		"<div class=""EntryFormNotesItem block-border-top" & StringIf(Not Nl(dCancelled), " RNCanceled") & """ id=""" & strPrefix & "CONTAINER"">" 
	If Nl(dCancelled) Then
		strReturn = strReturn & _
			"<div style=""float: right; margin-right: 4px; display: none;""><button type=""button"" class=""EntryFormItemRestoreAction ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"" id=""" & strPrefix & "RESTOREDELETE""><span class=""ui-button-text"" style=""padding-top: 0px; padding-bottom: 0px; padding-left: 1em;"">" & TXT_RESTORE & "</span></button></div>" & _
			"<div style=""float: right; margin-right: 4px;""><button type=""button"" class=""EntryFormItemAction ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icons"" id=""" & strPrefix & "ACTION""><span class=""ui-button-text"" style=""padding-top: 0px; padding-bottom: 0px; padding-left: 1em;"">" & TXT_ACTION & "</span><span class=""ui-button-icon-secondary ui-icon ui-icon-triangle-1-s""></span></button></div>"
	Else
		strReturn = strReturn & _
			"<div style=""float: right; margin-right: 4px; display: none;""><button type=""button"" class=""EntryFormItemDontRestoreCancel ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"" id=""" & strPrefix & "RESTOREDELETE""><span class=""ui-button-text"" style=""padding-top: 0px; padding-bottom: 0px; padding-left: 1em;"">" & TXT_DONT_RESTORE & "</span></button></div>" & _
			"<div style=""float: right; margin-right: 4px;""><button type=""button"" class=""EntryFormItemRestoreCancel ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"" id=""" & strPrefix & "RESTORECANCEL""><span class=""ui-button-text"" style=""padding-top: 0px; padding-bottom: 0px; padding-left: 1em;"">" & TXT_RESTORE & "</span></button></div>"
	End IF

	strReturn = strReturn & _
		"<div id=""" & strPrefix & "DISPLAY"" class=""EntryFormItemContent"" data-form-values=""" & _
		Server.HTMLEncode("{""id"": " & JSONQs(xmlNoteNode.getAttribute("RecordNoteID"), True) & _
		",""modified_date"":" & JSONQs(dModified, True) & _
		",""modified_by"":" & JSONQs(strModifiedBy, True) & _
		",""created_date"":" & JSONQs(dCreated, True) & _
		",""created_by"":" & JSONQs(strCreatedBy, True) & _
		",""note_value"":" & JSONQs(strNoteValue, True) & _
		",""note_type"":" & JSONQs(intNoteTypeID, True) & _
		"}" ) & """>"

	If Not Nl(dCancelled) Then
		strReturn = strReturn & _
			"<span class=""EntryFormItemCancelledDetails""><span class=""Alert"">" & IIf(bCancelError,TXT_CANCELLED_ERROR,TXT_NO_LONGER_APPLICABLE) & "</span>" & TXT_COLON & dCancelled & " (" & strCancelledBy & ")</span><br>" & vbCrLf 
	End If
	
	If bHighPriority Then
		strReturn = strReturn & _
			"<img src=""/images/alert.gif"" border=""0"">&nbsp;"
	End If

	If Not Nl(strNoteType) Then
		strReturn = strReturn & _
			"<strong>" & Server.HTMLEncode(strNoteType) & "</strong>" & TXT_COLON
	End If

	strReturn = strReturn & Server.HTMLEncode(strNoteValue) & " [" & strModifiedBy & ", " & dModified & "]</div><div style=""clear: both;""></div></div>" & vbCrLf

	makeRecordNoteEntry = strReturn
End Function


Function makeRecordNoteFieldVal(rst,strField,bUseContent)
	Dim strReturn, bHasCancelledSection
	Dim xmlDoc, xmlNode, xmlNoteNode
	
	Call openRecordNoteTypeRecordsets()
	
	Dim intCanDeleteRecordNote, intCanUpdateRecordNote
	intCanDeleteRecordNote = get_db_option("CanDeleteRecordNote" & ps_strDbArea)
	intCanUpdateRecordNote = get_db_option("CanUpdateRecordNote" & ps_strDbArea)

	bCanDeleteRecordNote = False
	If intCanDeleteRecordNote = RN_CHANGE_ANYONE Or (user_bSuperUserDOM And intCanDeleteRecordNote = RN_CHANGE_SUPER_USER) Then
		bCanDeleteRecordNote = True
	End If

	bCanUpdateRecordNote = False
	If intCanUpdateRecordNote = RN_CHANGE_ANYONE Or (user_bSuperUserDOM And intCanUpdateRecordNote = RN_CHANGE_SUPER_USER) Then
		bCanUpdateRecordNote = True
	End If

	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With
	
	If bUseContent Then
		xmlDoc.loadXML Nz(rst(strField).Value,"<" & strField & "/>")
	Else
		xmlDoc.loadXML "<" & strField & "/>"
	End If
	Set xmlNode = xmlDoc.selectSingleNode("/" & strField)
	
	Dim intCount
	intCount = 1

	strReturn = "<ul class=""EntryFormItemActionMenu"" style=""display: none;"">"
	If bCanUpdateRecordNote Then
		strReturn = strReturn & "<li data-action=""update""><a style=""cursor: pointer;"">"& TXT_UPDATE & "</a></li>"
	End If
	If bCanDeleteRecordNote Then
		strReturn = strReturn & "<li data-action=""delete""><a style=""cursor: pointer;"">"& TXT_DELETE & "</a></li>"
	End If

	strReturn = strReturn & _
		"<li data-action=""cancel"" data-cancel-type=""na"" data-cancel-template=" & AttrQs(Server.HTMLEncode("<span class=""EntryFormItemCancelledDetails""><span class=""Alert"">" & TXT_NO_LONGER_APPLICABLE & "</span>" & TXT_COLON & DateString(Now(), True) & " (" & user_strMod & ")<br></span>")) & "><a style=""cursor: pointer;"">" & TXT_CANCEL & TXT_COLON & TXT_NO_LONGER_APPLICABLE & "</a></li>" & vbCrLf & _
		"<li data-action=""cancel"" data-cancel-type=""error"" data-cancel-template=" & AttrQs(Server.HTMLEncode("<span class=""EntryFormItemCancelledDetails""><span class=""Alert"">" & TXT_CANCELLED_ERROR & "</span>" & TXT_COLON & DateString(Now(), True) & " (" & user_strMod & ")<br></span>")) & "><a style=""cursor: pointer;"">" & TXT_CANCEL & TXT_COLON & TXT_CANCELLED_ERROR & "</a></li></ul>" & vbCrLf & _
		"<button class=""ui-state-default ui-corner-all EntryFormItemAdd"" type=""button"" id=""" & strField & "_add_button"">" & TXT_ADD & "</button>" & vbCrLf & _
		"<div id=""" & strField & "_NoteArea"" class=""EntryFormNotesContainer"" data-add-tmpl=" & AttrQs(Server.HTMLEncode(makeRecordNoteEntryTemplate(strField))) & ">" & vbCrLf & _
		"<input type=""hidden"" name=""" & strField & "_UPDATE_IDS"" class=""EntryFormNotesUpdateIds"" id=""" & strField & "_UPDATE_IDS"" value="""">" & vbCrLf & _
		"<input type=""hidden"" name=""" & strField & "_DELETE_IDS"" class=""EntryFormNotesDeleteIds"" id=""" & strField & "_DELETE_IDS"" value="""">" & vbCrLf & _
		"<input type=""hidden"" name=""" & strField & "_CANCEL_IDS"" class=""EntryFormNotesCancelIds"" id=""" & strField & "_CANCEL_IDS"" value="""">" & vbCrLf & _
		"<input type=""hidden"" name=""" & strField & "_RESTORE_IDS"" class=""EntryFormNotesRestoreIds"" id=""" & strField & "_RESTORE_IDS"" value="""">" & vbCrLf & _
		"</div>"


	bHasCancelledSection = False
	For Each xmlNoteNode in xmlNode.childNodes
		If Not bHasCancelledSection Then
			If Not Nl(xmlNoteNode.getAttribute("CANCELLED_DATE")) Then
				bHasCancelledSection = True
				strReturn = strReturn & "<br><button class=""ui-state-default ui-corner-all EntryFormItemViewHidden"" type=""button"">" & TXT_VIEW_CANCELLED & "</button><div style=""display: none;"" class=""EntryFormItemCancelled"">"
			End If
		End If
		strReturn = strReturn & makeRecordNoteEntry(xmlNoteNode, strField)
		intCount = intCount + 1
	Next

	If bHasCancelledSection Then
		strReturn = strReturn & "</div>"
	End If

	If bFeedback Then
		strReturn = strReturn & getFeedback(strField,False,False)
	End If		

	makeRecordNoteFieldVal = strReturn
End Function

Function makeRecordOwnerFieldVal(rst, bUseContent)
	Dim strReturn
	Dim strOwnerAgency
	If bUseContent Then
		strOwnerAgency = rst("RECORD_OWNER")
	Else
		strOwnerAgency = user_strAgency
	End If
	Call openAgencyListRst(ps_intDbArea, True, True)
	strReturn = makeRecordOwnerAgencyList(strOwnerAgency,"RECORD_OWNER", True)
	Call closeAgencyListRst()
	makeRecordOwnerFieldVal = strReturn
End Function

Function makeRow(strFieldName,strFieldDisplay,strFieldVal,bFieldColumn,bHasHelp,bHasVersions,bRequired,bEnforceRequired,bHasFeedback,bHasLabel)
	Dim strReturn, strColContents, strLabelInsert
	strLabelInsert = StringIf(bHasLabel,"<label for=" & strFieldName & ">") & strFieldDisplay & StringIf(bHasLabel,"</label>")
	strReturn = vbCrLf & "<tr>" & _
		"<td class=""FieldLabelLeft" & StringIf(bHasFeedback," has-feedback-border") & """ id=""FIELD_" & strFieldName & """>" & strLabelInsert & _
		IIf(bRequired,"&nbsp;<span class=""Alert"">*</span>",vbNullString) & "</td>" & _
		"<td" & StringIf(bRequired And bEnforceRequired," data-field-required=""true""") & " data-field-display-name=" & AttrQs(strFieldDisplay) & ">" & strFieldVal & "</td>"
	If bFieldColumn Then
		strReturn = strReturn & "<td>"
		If bHasHelp Then
			strColContents = "<a href=""javascript:openWin('" & makeLink("fieldhelp.asp","field=" & strFieldName & "&amp;Ln=" & g_objCurrentLang.Culture,"Ln") & "','fHelp')""><img src=""/images/help.gif"" ALT=""" & TXT_HELP & """></a>"
		End If
		If bHasVersions Then
			strColContents = strColContents & StringIf(Not Nl(strColContents)," ") & "<img src=""/images/versions.gif"" alt=""" & strFieldDisplay & TXT_COLON & TXT_VERSIONS & """ class=""ShowVersions SimulateLink"" data-ciocid=""" & IIf(ps_intDbArea=DM_VOL, Request("VNUM"), strNUM) & """ data-ciocfield=""" & strFieldName & """ data-ciocfielddisplay=" & AttrQs(strFieldDisplay) & ">"
		End If
		If Nl(strColContents) Then
			strColContents = "&nbsp;"
		End If
		strReturn = strReturn & strColContents & "</td>"
	End If
	strReturn = strReturn & "</tr>"

	makeRow = strReturn
End Function

Function printRow(strFieldName,strFieldDisplay,strFieldVal,bFieldColumn,bHasHelp,bHasVersions,bRequired,bEnforceRequired,bHasFeedback,bHasLabel)
	%>
<tr>
	<td class="field-label-cell <%=StringIf(bHasFeedback," has-feedback-border")%>" id="FIELD_<%=strFieldName%>">
		<%If bHasLabel Then%><label for=<%=AttrQs(strFieldName)%>><%End If%>
			<%=strFieldDisplay%> <%If bRequired Then%> <span class="Alert" title="<%=TXT_REQUIRED%>">*</span><%End If%>
		<%If bHasLabel Then%></label><%End If%>
	</td>
	<td class="field-data-cell" data-field-display-name=<%=AttrQs(strFieldDisplay)%> <%If bRequired And bEnforceRequired Then%> data-field-required="true"<%End If%>>
		<%=strFieldVal%>
	</td>
	<%If bFieldColumn Then%>
	<td class="field-icon-cell icon-<%=IIf(bFeedbackForm,1,2)%>">
		<%If bHasVersions Then%>
			<span aria-hidden="true" class="glyphicon glyphicon-duplicate medium-icon ShowVersions SimulateLink" title="<%=strFieldDisplay & TXT_COLON & TXT_VERSIONS%>"
				data-ciocid="<%=IIf(ps_intDbArea=DM_VOL, Request("VNUM"), strNUM)%>" data-ciocfield="<%=strFieldName%>" data-ciocfielddisplay=<%=AttrQs(strFieldDisplay)%>></span>
		<%End If%>
		<%If bHasHelp Then%>
			<a href="javascript:openWin('<%=makeLink("fieldhelp.asp","field=" & strFieldName & "&amp;Ln=" & g_objCurrentLang.Culture,"Ln")%>','fHelp')"><span aria-hidden="true" class="glyphicon glyphicon-question-sign medium-icon" title="<%=TXT_HELP%>"></span></a>
		<%End If%>
	</td>
	<%End If%>
</tr>
<%
End Function

Function makeSocialMediaFieldVal(rst,bUseContent)
	Dim strReturn, strCon
	Dim strName, strGeneralURL, strIcon, strFeedback
	Dim xmlDoc, xmlNode, xmlChildNode
	
	strCon = vbNullString
	
	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With
	
	If bUseContent Then
		xmlDoc.loadXML Nz(rst("SOCIAL_MEDIA").Value,"<SOCIAL_MEDIA/>")
	Else
		Dim rsSocialMedia, cmdSocialMedia
		Set cmdSocialMedia = Server.CreateObject("ADODB.Command")
		With cmdSocialMedia
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_GBL_SocialMedia_s_Entryform"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
		End With
		Set rsSocialMedia = Server.CreateObject("ADODB.Recordset")
		With rsSocialMedia
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdSocialMedia
		End With

		If Not rsSocialMedia.EOF Then
			xmlDoc.loadXML Nz(rsSocialMedia("SOCIAL_MEDIA").Value, "<SOCIAL_MEDIA/>")
		Else
			xmlDoc.loadXML "<SOCIAL_MEDIA/>"
		End If

		Call rsSocialMedia.Close()

		Set rsSocialMedia = Nothing
		Set cmdSocialMedia = Nothing
	End If

	Dim junk

	If bFeedback Then
		junk = prepSocialMediaFeedback(rsFb)
	End If
	
	Set xmlNode = xmlDoc.selectSingleNode("/SOCIAL_MEDIA")
	If Not xmlNode Is Nothing Then
		For Each xmlChildNode in xmlNode.childNodes
			strFeedback = vbNullString
			strGeneralURL = xmlChildNode.getAttribute("GeneralURL")
			strName = xmlChildNode.getAttribute("Name")
			strIcon = xmlChildNode.getAttribute("Icon24")
			strReturn = strReturn & "<div class=""form-group"">" & vbCrLf & _
				"<label class=""control-label col-sm-3 col-lg-2"">" & _
					StringIf(Not Nl(strGeneralURL),"<a href=""http://" & strGeneralURL & """>") & _
					strName & _
					StringIf(Not Nl(strGeneralURL),"</a> ") & _
					StringIf(Not Nl(strIcon)," <img src=" & AttrQs(strIcon) & " alt=" & AttrQs(strName) & " aria-hidden=""true"" height=""24"" width=""24"">") & _
				"</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
					"<input id=" & AttrQs("SOCIAL_MEDIA_" & xmlChildNode.getAttribute("ID")) & _
					" name=" & AttrQs("SOCIAL_MEDIA_" & xmlChildNode.getAttribute("ID")) & _
					" class=""protourl unique form-control""" & _
					" value=" & AttrQs(Replace(Ns(xmlChildNode.getAttribute("Proto")), "http://", vbNullString) & xmlChildNode.getAttribute("URL")) & _
					" size=" & TEXT_SIZE-25 & _
					" unique=""SOCIAL_MEDIA""" & _
					" maxlength=""255""" & _
					" title=" & AttrQs(strName) & _
					">" 
			If bFeedback Then
				strFeedback = getSocialMediaFeedback(xmlChildNode.getAttribute("ID"), TXT_FEEDBACK_NUM, TXT_COLON, TXT_UPDATE, TXT_CONTENT_DELETED)
				If Not Nl(strFeedback) Then
					strReturn = strReturn & strFeedback
					bFieldHasFeedback = True
				End If
			End If
			strReturn = strReturn & "</div>" & _
				"</div>"
		Next
	End If

	makeSocialMediaFieldVal = strReturn
End Function

Function makeLanguageItem(intLNID, bIsSelected, strLanguageName, strLangID, strNotes, strLNDIDs)
	Dim strReturn, i, tmp, strLanguageDetails, strFeedback
	strFeedback = vbNullString
	If bFeedback Then
		strFeedback = getLanguagesFeedback(intLNID, strLanguageName, bIsSelected, strNotes, TXT_FEEDBACK_NUM, TXT_COLON, TXT_UPDATE, TXT_CONTENT_DELETED)
	End If
	strReturn = "<tr class=""language-entry"" id=""language-entry-" & intLNID & """><td>" & _
		"<label><input name=""LN_ID"" id=""LN_ID_" & intLNID & """ class=""language-primary"" type=""checkbox"" value=""" & intLNID & """"
	If bIsSelected Then
		strReturn = strReturn & " checked"
	End If
	strReturn = strReturn & ">&nbsp;" & strLanguageName & "</label></td><td><div class=""language-details-notes""" & StringIf(bIsSelected = 0, " style=""display:none;""") & ">"
	strLanguageDetails = languageDetailsUI(intLNID, strLNDIDs, TXT_HELP)
	If Not Nl(strLanguageDetails) Then
		strReturn = strReturn & strLanguageDetails
	End If

	If (strLangID = g_objCurrentLang.LangID) Then
		strReturn = strReturn & _
			"<div><input type=""text"" name=""LN_NOTES_" & intLNID & """ " & _
			"title=" & AttrQs(TXT_NOTES & TXT_COLON & strLanguageName) & " " & _
			"id=""LN_NOTES_" & intLNID & """ class=""form-control"" " & _
			"value=""" & strNotes & """ " & _
			"size=""" & TEXT_SIZE-25 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """></div>"
	Else
		strReturn = strReturn
	End If
	strReturn = strReturn & "</div>" & strFeedback & "</td>" & "</tr>"

	makeLanguageItem = strReturn
End Function

Dim bLanguages
bLanguages = False

Function makeLanguageContents(rst,bUseContent)
	bLanguages = True
	bHasDynamicAddField = True
	Dim strReturn, junk
	Dim strNUM, strNotes, intNotesLen, strFeedbackLNIDs
	If bUseContent Then
		strNUM = rst.Fields("NUM")
		strNotes = rst.Fields("LANGUAGE_NOTES")
	Else
		strNUM = Null
	End If

	strFeedbackLNIDs = vbNullString
	If bFeedback Then
		strFeedbackLNIDs = prepLanguagesFeedback(rsFb)
	End If
	
	Dim cmdLanguage, rsLanguage, aLanguageDetails
	Set cmdLanguage = Server.CreateObject("ADODB.Command")
	With cmdLanguage
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMLanguage_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@LNIDS", adVarChar, adParamInput, 5000, strFeedbackLNIDs)
	End With
	Set rsLanguage = cmdLanguage.Execute
	
	junk = makeLanguageDetailList(rsLanguage)

	Set rsLanguage = rsLanguage.NextRecordset
	
	With rsLanguage
		strReturn = strReturn & "<table id=""LN_existing_add_table"" class=""NoBorder cell-border-bottom"">"
		While Not .EOF
			strReturn = strReturn & makeLanguageItem(.Fields("LN_ID"), .Fields("IS_SELECTED"), .Fields("LanguageName"), .Fields("LangID"), .Fields("Notes"), .Fields("LNDIDs"))
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With

	strReturn = strReturn & "<h4>" & TXT_ADD_LANGUAGES & "</h4>" & _
		"<p>" & TXT_INFO_LANGUAGES & "</p>" & _
		"<div class=""entryform-checklist-add-wrapper"" id=""LN_new_input_table"">" & _
			"<div class=""entryform-checklist-add-left"">" & _
				"<div class=""row form-group"">" & _
					"<label for=""NEW_LN"" class=""control-label control-label-left col-xs-1"">" & _
						TXT_NAME & _
					"</label>" & _
					"<div class=""col-xs-11""><input type=""text"" id=""NEW_LN"" class=""form-control""></div>" & _
				"</div>" & _
			"</div>" & _
			"<div class=""entryform-checklist-add-right"">" & _
				"<button type=""button"" class=""btn btn-default"" id=""add_LN"" data-new-template=""" & Server.HTMLEncode(makeLanguageItem("IDIDID", 1, "LANGNAMELANGNAME", g_objCurrentLang.LangID, vbNullString, vbNullString)) & """>" & TXT_ADD & "</button>" & _
			"</div>" & _
		"</div>"

	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<div class=""FieldLabelLeftClr""><label for=""LANGUAGE_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea name=""LANGUAGE_NOTES"" id=""LANGUAGE_NOTES""" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>"

	rsLanguage.Close
	Set rsLanguage = Nothing
	Set cmdLanguage = Nothing			

	If bFeedback Then
		strReturn = strReturn & getLanguageNotesFeedback(strNotes, TXT_FEEDBACK_NUM, TXT_COLON, TXT_UPDATE, TXT_CONTENT_DELETED)
	End If
	makeLanguageContents = strReturn
End Function

Dim bHasSchedule
bHasSchedule = False

Function makeEventScheduleContents(rst,bUseContent)
	bHasSchedule = True
	bHasDynamicAddField = True

	makeEventScheduleContents = makeEventScheduleContents_l(rst, bUseContent)
End Function

Function makeEventScheduleContentsEntryForm(rst,bUseContent)
	bHasSchedule = True
	bHasDynamicAddField = True

	makeEventScheduleContentsEntryForm = makeEventScheduleContents_l(rst, bUseContent, bFeedback, rsFb, True)

End Function

Sub printAutoFields(rst, bUseContent)
	Dim strCreatedDate, _
		strCreatedBy, _
		strModifiedDate, _
		strModifiedBy

	If bUseContent Then
		strModifiedDate = Nz(DateString(rst.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN)
		strModifiedBy = Nz(rst.Fields("MODIFIED_BY"),TXT_UNKNOWN)
		strCreatedDate = Nz(DateString(rst.Fields("CREATED_DATE"),True),TXT_UNKNOWN)
		strCreatedBy = Nz(rst.Fields("CREATED_BY"),TXT_UNKNOWN)
	End If
	
	Call printRow("CREATED_DATE", _
		TXT_DATE_CREATED, _
		strCreatedDate & " (" & TXT_SET_AUTOMATICALLY & ")", _
		True,False,False,False,False,False,False)
	Call printRow("CREATED_BY", _
		TXT_CREATED_BY, _
		strCreatedBy & " (" & TXT_SET_AUTOMATICALLY & ")", _
		True,False,False,False,False,False,False)
	Call printRow("MODIFIED_DATE", _
		TXT_LAST_MODIFIED, _
		strModifiedDate & " (" & TXT_SET_AUTOMATICALLY & ")", _
		True,False,False,False,False,False,False)
	Call printRow("MODIFIED_BY", _
		TXT_MODIFIED_BY, _
		strModifiedBy & " (" & TXT_SET_AUTOMATICALLY & ")", _
		True,False,False,False,False,False,False)
End Sub

Sub printUpdatedFields(rst, bUseContent, bEnforceRequired)
	Dim strUpdateDate, _
		strUpdatedBy, _
		strUpdateSchedule

	If bFullUpdate Then
		If bUseContent Then
			strUpdateDate = rst.Fields("UPDATE_DATE")
			strUpdatedBy = rst.Fields("UPDATED_BY")
			strUpdateSchedule = rst.Fields("UPDATE_SCHEDULE")
		End If
		Call printRow("UPDATE_DATE", _
			TXT_UPDATE_DATE, _
			makeDateFieldVal("UPDATE_DATE",strUpdateDate,True,False,False,False,False,False), _
			True,True,False,True,bEnforceRequired,False,True)
		Call printRow("UPDATED_BY", _
			TXT_UPDATED_BY, _
			makeUserFieldVal("UPDATED_BY",strUpdatedBy,False), _
			True,True,False,True,bEnforceRequired,False,True)
		Call printRow("UPDATE_SCHEDULE", _
			TXT_UPDATE_SCHEDULE, _
			makeDateFieldVal("UPDATE_SCHEDULE",strUpdateSchedule,False,True,True,True,True,False), _
			True,True,False,True,bEnforceRequired,False,True)
	End If
End Sub

Sub printRecordOwner(rst, bUseContent)
	If intFormType <> EF_UPDATE Then
		Call printRow("RECORD_OWNER", _
			TXT_RECORD_OWNER, _
			makeRecordOwnerFieldVal(rst, bUseContent), _
			True,True,IIf(ps_intDbArea = DM_CIC,Not bNew,False),True,False,bFieldHasFeedback,False)
	End If
End Sub

Dim bContactRecordsetsOpen
bContactRecordsetsOpen = False

Sub openContactRecordsets()
	If Not bContactRecordsetsOpen Then
		Call openHonorificListRst()
		Call openContactPhoneTypeListRst()
		bContactRecordsetsOpen = True
	End If
End Sub

Sub closeContactRecordsets()
	If bContactRecordsetsOpen Then
		Call closeHonorificListRst()
		Call closeContactPhoneTypeListRst()
	End If
End Sub

Dim bRecordNoteTypeRecordsetsOpen
bRecordNoteTypeRecordsetsOpen = False

Sub openRecordNoteTypeRecordsets()
	If Not bRecordNoteTypeRecordsetsOpen Then
		Call openRecordNoteTypeListRst()
		bRecordNoteTypeRecordsetsOpen = True
	End If
End Sub

Sub closeRecordNoteTypeRecordsets()
	If bRecordNoteTypeRecordsetsOpen Then
		Call closeRecordNoteTypeListRst()
	End If
End Sub
%>
