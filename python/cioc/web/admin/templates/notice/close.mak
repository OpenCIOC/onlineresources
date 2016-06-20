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

<% 
makeLink = request.passvars.makeLink
route_path = request.passvars.route_path
%>
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${route_path('reminder_index')}">${_('Return to Reminders')}</a> ]</p>

<form method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="NoticeID" value="${NoticeID}">
</div>

<table class="BasicBorder cell-padding-3">
<tr>
	<td class="FieldLabelLeft">${_('Area')}</td>
	<td><a href="${makeLink('~/' + notice.ManageLocation, notice.ManageLocationParams)}">${notice.AreaName}</a></td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Created')}</td>
	<td>${format_date(notice.CREATED_DATE)} (${notice.CREATED_BY})</td>
</tr>
<tr>

	<td class="FieldLabelLeft">${_('Domain')}</td>
	<td>${_(domain_map[notice.Domain].label)}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Details')}</td>
	<td>${escape_silent(notice.RequestDetail).replace('\n', Markup('<br>'))}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('ActionTaken', _('Action Taken'))}</td>
	<td>${renderer.errorlist('ActionTaken')}
		${renderer.select('ActionTaken', options=[('',_('No Action Taken')), (1, _('Reject')), (2, _('Complete'))])}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('ActionNotes', _('Action Notes'))}</td>
	<td>${renderer.errorlist('ActionNotes')}
		${renderer.textarea('ActionNotes')}</td>
</tr>
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Update')}"> 
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>
</form>
