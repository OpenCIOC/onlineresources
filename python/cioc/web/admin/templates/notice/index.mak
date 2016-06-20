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


<%inherit file="cioc.web:templates/master.mak" />

<%!
from markupsafe import escape_silent, Markup
from cioc.core import constants as const
domain_map = {
	const.DM_CIC: const.DMT_CIC,
	const.DM_VOL: const.DMT_VOL,
	const.DM_CCR: const.DMT_CCR,
	const.DM_GLOBAL: const.DMT_GBL
}
%>

<%def name="show_notices(closed_notices_list=False)">
<% 
makeLink = request.passvars.makeLink
route_path = request.passvars.route_path
SuperUserGlobal = request.user.SuperUserGlobal
%>
%if sharing_profiles and not closed_notices_list:
<h2>${_('The following Sharing Profiles are ready to be accepted')}</h2>
<table class="BasicBorder cell-padding-3">
<thead>
<tr>
	<th class="RevTitleBox">${_('Name')}</th>
	<th class="RevTitleBox">${_('Status')}</th>
	<th class="RevTitleBox">${_('Domain')}</th>
	<th class="RevTitleBox">${_('Action')}</th>
</tr>
</thead>
<tbody class="alternating-highlight">
%for profile in sharing_profiles:
<tr>
	<td>${profile.Name}</td>
	<td>
	%if not profile.Active and profile.RevokedDate:
		${_('Revoked')}
	%elif profile.AcceptedDate:
		${_('Active')}
	%elif profile.ReadyToAccept:
		${_('Awaiting Response')}
	%else:
		${_('Not Submitted')}
	%endif
	</td>
	<td>${_(domain_map[profile.Domain].label)}</td>
	<td>
	<a href="${route_path('admin_sharingprofile', action='edit', _query=[('ProfileID', profile.ProfileID), ('DM', profile.Domain)])}">${_('View')}</a> 
	</td>
</tr>
%endfor
</tbody>
</table>

%endif

<h2>${_('Admin Notices')}</h2>
%if closed_notices_list:
<p><a href="${request.passvars.route_path('reminder_index')}">${_('Return to Reminders')}</a></p>
%endif
%if notices:
<table class="BasicBorder cell-padding-3">
<thead>
<tr>
%if SuperUserGlobal:
	<th class="RevTitleBox">${_('Action')}</th>
%endif
	<th class="RevTitleBox">${_('Area')}</th>
	<th class="RevTitleBox">${_('Created')}</th>
	<th class="RevTitleBox">${_('Domain')}</th>
	<th class="RevTitleBox">${_('Details')}</th>
</tr>
</thead>
<tbody class="alternating-highlight">
%for notice in notices:
<% processed = notice.PROCESSED_DATE %>
<tr>
%if SuperUserGlobal:
	<td style="text-align:left" ${'class="AlertStrike"' if processed else '' |n}>
	<a href="${route_path('admin_notices', action='close', _query=[('NoticeID', notice.AdminNoticeID)])}">${_('View Details') if processed else _('Close Request')}</a>
	</td>
%endif
	<td ${'class="AlertStrike"' if processed else '' |n}>
	%if SuperUserGlobal:
	<a href="${makeLink('~/' + notice.ManageLocation, notice.ManageLocationParams)}">
	%endif
	${notice.AreaName}
	%if SuperUserGlobal:
	</a>
	%endif
	</td>
	<td ${'class="AlertStrike"' if processed else '' |n}>${format_date(notice.CREATED_DATE)} (${notice.CREATED_BY})</td>
	<td ${'class="AlertStrike"' if processed else '' |n}>${_(domain_map[notice.Domain].label)}</td>
	<td ${'class="AlertStrike"' if processed else '' |n}>${escape_silent(notice.RequestDetail).replace('\n', Markup('<br>'))}</td>

</tr>
%endfor
</tbody>
</table>
%else:
<em>${_('There are no admin notices at this time.')}</em>
<br>
%endif
%if closed_count and closed_count[0]:
<br>
<div class="ui-widget-header ui-corner-all" style="float: left;">
<a id="show-closed-notices" href="${route_path('admin_notices_index', _query=[('ShowClosed', 'on')])}">${ngettext(u'Show %d closed notice.', u'Show %d closed notices.', closed_count[0]) % closed_count[0]}</a>
</div>
<div class="clearfix"></div>
%endif
</%def>

${show_notices(True)}
