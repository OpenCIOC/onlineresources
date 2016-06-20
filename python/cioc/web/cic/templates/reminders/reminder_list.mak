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

<%!
from itertools import groupby
from datetime import datetime 

from markupsafe import Markup

from cioc.core.format import textToHTML
%>
<% 
SuperUser = request.user.SuperUser 
User_ID = request.user.User_ID
add_query = []
if VNUM:
	add_query.append(('VNUM', VNUM))
if NUM:
	add_query.append(('NUM', NUM))

now = datetime.now()
past_due = (_('Past Due'), 'past-due', Markup('<span class="ui-state-error" style="background-color: transparent; border: none;"><span class="ui-icon ui-icon-alert" aria-hidden="true" style="display: inline-block; background-color: transparent; border: none"></span></span> '))
active = (_('Current Reminders'), 'current', Markup('<img src="%s" aria-hidden="true" style="vertical-align: text-top"> ') % (request.static_url('cioc:images/remind.gif')))
inactive = (_('Pending Reminders'), 'inactive', None)
def group_headings(x):
	if x.DueDate is not None and x.DueDate <= now:
		return past_due

	if x.ActiveDate is None or x.ActiveDate <= now:
		return active

	return inactive

#edit_gif = request.static_url('cioc:images/edit.gif')
alert_gif = request.static_url('cioc:images/alert.gif')
#search_gif = request.static_url('cioc:images/zoom.gif')
makeLink = request.passvars.makeLink
%>
<%def name="reminder_details(reminder)" filter="h,trim">
%if reminder.ActiveDate:
<div><strong>${_('Active:')}</strong> ${format_date(reminder.ActiveDate)}</div>
%endif
<div>
<strong>${_('For:')}</strong>
<% 
for_targets = []
not_me = [x for x in reminder.Users if x['User_ID'] != unicode(request.user.User_ID)] 
if len(not_me) != len(reminder.Users) or (not reminder.Users and not reminder.Agencies):
	for_targets.append(Markup('<em>%s</em>' % request.user.UserName))
for_targets.extend(x['UserName'] for x in not_me)
for_targets.extend(x['AgencyCode'] for x in reminder.Agencies)
%>
${Markup(', ').join(for_targets)}
</div>
%if reminder.UserID != User_ID:
<div><strong>${_('From:')}</strong> ${reminder.UserName}</div>
%endif
%if reminder.DismissalDate:
<div><strong>${_('Dismissed:')}</strong> ${format_date(reminder.DismissalDate)}</div>
%endif
</%def>
<div id="reminder-button-set" class="ui-widget-header ui-corner-all" style="float: left;">
<a class="edit-link" id="reminder-add-link" href="${request.passvars.route_path('reminder_add', _query=add_query)}">${_('Create New Reminder')}</a>
<span id="reminder-dismiss-ui">
<input type="checkbox" id="reminder-show-dismissed"><label for="reminder-show-dismissed">${_('Show Dismissed')}</label>
</span>
</div>
<div class="clearfix"></div>
%for (name, groupid, icon), section in groupby(reminders, key=group_headings):
<div class="reminder-section" id="reminder-section-${groupid}">
<h3 id="reminder-header-${groupid}">${icon}${name}</h3>
<div id="reminder-items-${groupid}">
%for for_others, group in groupby(section, key=lambda x: x.ForOthers): 
<div class="reminder-section" id="reminder-section-${groupid}-${'others' if for_others else 'me'}">
%if for_others:
	<h4 id="reminder-section-${groupid}-others">${_('Created for Others:')}</h4>
%else:
	<h4 id="reminder-section-${groupid}-me">${_('Created for Me:')}</h4>
%endif
<table class="NoBorder cell-padding-2">
%for reminder in group:
<tr class="reminder-item${' dismissed' if reminder.Dismissed else ''}">
<td style="white-space: nowrap; padding: 0.25em;" class="reminder-actions">
## <a class="comment-link" href="${request.passvars.route_path('reminder_action', id=reminder.ReminderID, action='comment')}" title="More Details"><span class="ui-icon ui-icon-comment" style="display: inline-block;">${_('Comments')}</span></a>
<span class="details-link" href="${request.passvars.route_path('reminder', id=reminder.ReminderID)}" data-tooltip="${reminder_details(reminder)}"><span class="ui-icon ui-icon-document">${_('More Details')}</span></span>
%if SuperUser or User_ID == reminder.UserID:
<a class="edit-link" title="${_('Edit')}" href="${request.passvars.route_path('reminder_action', id=reminder.ReminderID, action='edit')}">
<span class="ui-icon ui-icon-folder-open">${_('Edit')}</span></a>
##<img src="${edit_gif}"></a>
%endif
%if reminder.NUMCount > int(NUM is not None):
	<a target="_blank" title="${_('Community Information: %d record(s).') % reminder.NUMCount}" href="${makeLink('~/rmresults.asp', [('ReminderID',reminder.ReminderID)])}"><span aria-hidden="true" class="ui-icon ui-icon-search"></span></a>
##<img src="${search_gif}" style="vertical-align: text-bottom"></a>
%endif
%if reminder.VNUMCount > int(VNUM is not None):
	<a target="_blank" title="${_('Volunteer: %d record(s).') % reminder.VNUMCount}" href="${makeLink('~/volunteer/rmresults.asp', [('ReminderID', reminder.ReminderID)])}"><span class="ui-icon ui-icon-search"></span></a>
##<img src="${search_gif}" style="vertical-align: text-bottom"></a>
%endif
<span class="SimulateLink ui-icon ui-icon-arrowrefresh-1-e restore-reminder" data-reminder-id="${reminder.ReminderID}" title="${_('Restore')}">${_('Restore')}</span>
<span class="SimulateLink ui-icon ui-icon-close dismiss-reminder" data-reminder-id="${reminder.ReminderID}" title="${_('Dismiss')}">${_('Dismiss')}</span>
</td>
<td class="AutoShorten" style="padding: 0.25em;">
%if reminder.DueDate:
<span ${'class="Alert"' if groupid == 'past-due' else ''|n}>${format_date(reminder.DueDate)}</span>${_(':')}
%endif
%if reminder.HighPriority:
<img src="${alert_gif}" aria-hidden="true" style="vertical-align: text-bottom;"> <strong>${_('High Priority:')}</strong>
%endif
${textToHTML(reminder.Notes)}
</td>
</tr>
%endfor
</table>
</div>
%endfor
</div>
</div>
%endfor

