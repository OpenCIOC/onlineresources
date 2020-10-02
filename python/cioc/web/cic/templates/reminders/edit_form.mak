<%doc>
=========================================================================================
 Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
=========================================================================================
</%doc>

<%namespace file="cioc.web:templates/master.mak" import="makeMgmtInfo"/>
<%!
from itertools import groupby

from webhelpers2.html import tags
from markupsafe import Markup

from cioc.core.modelstate import convert_options
from cioc.core.utils import grouper

%>

<%
renderer = request.model_state.renderer
User_ID = request.user.User_ID
%>

<form action="${request.current_route_path()}" method="post">
<div class="hidden">
${request.passvars.cached_form_vals|n}
%if request.params.get('json_api'):
<input type="hidden" name="json_api" value="on">
%endif
</div>
<table class="BasicBorder cell-padding-3">
<tr><th class="RevTitleBox" colspan="2">${_('Edit Reminder') if ReminderID else _('Add a reminder')}</th></tr>
%if reminder:
${makeMgmtInfo(reminder)}
%endif
<tr>
	<td class="FieldLabelLeft">${_('Records:')}</td>
	<td>
	<ul style="list-style-type: none; padding: 0;">
		<li class="reminder-actions"><span class="FieldLabelLeftClr">${_('Community Information:')}</span>
		%if reminder and renderer.value("NUM"):
			<a target="_blank" title="${_('Search')}" href="${request.passvars.makeLink('~/rmresults.asp', [('ReminderID',reminder.ReminderID)])}"><span class="ui-icon ui-icon-search"></span></a>
		%endif
			<br><br>
			<table class="NoBorder cell-padding-1" style="margin-left: 2em;">
			%for row in grouper(6,renderer.value('NUM') or []):
				<tr>
				 %for num in row:
					%if num:
					<% org_name = org_names.get(num) %>
					<td><label ${Markup('title="%s"') % org_name if org_name else ''}>${renderer.ms_checkbox('NUM', value=num, id='NUM_ID_' + num)} ${num}</label></td>
					%endif
				%endfor
			%endfor
			<tr><td colspan="6"><input type="text" id="NEW_NUM" size="10" maxlength="8" title="${_('Record #')}"> <button id="add_NUM">${_('Add')}</button>
			<br>[ <a class="poplink" data-popargs="{&quot;name&quot;: &quot;oFind&quot, &quot;size&quot;: &quot;lg&quot;}" href="${request.passvars.makeLink('~/orgfind.asp')}" target="_blank">${_('Organization Record # Finder')}</a> ]</td></tr>
			</table>
		</li>
		<hr>
		<li class="reminder-actions"><span class="FieldLabelLeftClr">${_('Volunteer:')}</span>
		%if reminder and renderer.value("VNUM"):
			<a target="_blank" title="${_('Search')}" href="${request.passvars.makeLink('~/volunteer/rmresults.asp', [('ReminderID',reminder.ReminderID)])}"><span class="ui-icon ui-icon-search"></span></a>
		%endif
			<br><br>
			<table class="NoBorder cell-padding-1" style="margin-left: 2em;">
			%for row in grouper(6,renderer.value('VNUM') or []):
				<tr>
				%for vnum in row:
					%if vnum:
					<% position_title = position_titles.get(vnum) %>
					<td><label ${Markup('title="%s"') % position_title if position_title else ''}>${renderer.ms_checkbox('VNUM', value=vnum, id=u'VNUM_ID_' + vnum)} ${vnum}</label></td>
					%endif
				%endfor
				</tr>
			%endfor
			<tr><td colspan="6"><input type="text" id="NEW_VNUM" size="10" maxlength="10"> <button id="add_VNUM">${_('Add')}</button>
				<br>[ <a class="poplink" data-popargs="{&quot;name&quot;: &quot;oFind&quot, &quot;size&quot;: &quot;lg&quot;}" href="${request.passvars.makeLink('~/volunteer/oppfind.asp')}" target="_blank">${_('Opportunity Record ID Finder')}</a> ]</td></tr>
			</table>
		</li>
	</ul>
	
	</td>
</tr>
<tr>
<td class="FieldLabelLeft">${renderer.label('reminder.Culture', label=_('Language:'))}</td>
<td>${renderer.errorlist('reminder.Culture')}
<%
languages = (culture_map[x] for x in record_cultures)
languages = [(x.Culture, x.LanguageName) for x in languages]
%>
${renderer.select('reminder.Culture', options=[('', _('Any Language'))] + languages)}
</td>
</tr>
<tr>
<td class="FieldLabelLeft">${_('For:')}</td>
<td>
	<ul style="list-style-type: none; padding: 0;">
		<li><label>${_('Me')} ${renderer.ms_checkbox('reminder_user_ID', User_ID)}</label></li>
		<hr>
		<li><label for="NEW_reminder_user">${_('Users:')}</label>
			${renderer.errorlist('reminder_user_ID')}
			<ul style="list-style-type: none">
			%for user in reminder_users:
			%if user.User_ID != User_ID:
				<li>${renderer.ms_checkbox('reminder_user_ID', value=user.User_ID, label=' ' + user.UserName)}
			%endif
			%endfor
			<li><div id="reminder_user_new_input_table"><input type="text" id="NEW_reminder_user"> <button id="add_reminder_user">${_('Add')}</button></div></li>
			</ul>
		</li>
	%if request.user.SuperUser:
		<hr>
		<li>${_('Agencies:')}
		${renderer.errorlist('reminder_agency_ID')}
		<ul style="list-style-type: none">
			%for agency in reminder_agencies:
			<li>${renderer.ms_checkbox('reminder_agency_ID', value=agency.AgencyCode, label=' ' + agency.AgencyCode)}
			%endfor
			<li>${tags.select(None, None, id="NEW_reminder_agency", options=convert_options([('','')] + agencies))}
			<button id="add_reminder_agency">${_('Add')}</button></li>
		</ul>
	%endif
	</ul>
</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Dismissal:')} <span class="Alert">*</span></td>
	<td>${renderer.errorlist('reminder.DismissForAll')}
	${renderer.radio('reminder.DismissForAll', 'S', True, _('Each user dismisses their own reminder'))}
	<br>${renderer.radio('reminder.DismissForAll', 'A', False, _('Users may dismiss this reminder for everyone.'))}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('reminder.ActiveDate', label=_('Start:'))}</td>
	<td>${renderer.errorlist('reminder.ActiveDate')}
	${renderer.date('reminder.ActiveDate')}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('reminder.DueDate', label=_('Due:'))}</td>
	<td>${renderer.errorlist('reminder.DueDate')}
	${renderer.date('reminder.DueDate')}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('reminder.NoteTypeID', label=_('Type:'))}</td>
	<td>${renderer.errorlist('reminder.NoteTypeID')}
	${renderer.select('reminder.NoteTypeID', options=[('','')]+note_types)}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('reminder.Notes', label=_('Details:'))} <span class="Alert">*</span></td>
	<td>${renderer.errorlist('reminder.Notes')}
	${renderer.textarea('reminder.Notes')}</td>
</tr>
</table>
<button id="save-reminder">${_('Save') if ReminderID else _('Add Reminder')}</button>
%if ReminderID:
<button id="delete-reminder" data-reminder-id="${ReminderID}" name="delete" value="delete">${_('Delete')}</button>
%endif
</form>
</div>

