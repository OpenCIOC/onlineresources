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
<p style="font-weight:bold">[
	%if cred_user.User_ID != request.user.User_ID:
	<a href="${request.passvars.makeLinkAdmin('users.asp')}">${_('Return to Edit Users')}</a> | <a href="${request.passvars.makeLinkAdmin('users_edit.asp', [('UserID', cred_user.User_ID)])}">${_('Return to User "%s"') % cred_user.UserName}</a>
	%else:
	<a href="${request.passvars.makeLinkAdmin('account.asp')}">${_('Return to Account')}</a>
	%endif
]</p>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox">${_("Credential ID")}</th>
	<th class="RevTitleBox">${_("Usage Note")}</th>
	<th class="RevTitleBox">${_("Action")}</th>
</tr>
%for cred in cred_list:
<tr>
<td><code>${cred.CredID}</code></td>
<td>${cred.UsageNotes}</td>
<td class="NoWrap">
<form action="${request.route_path('admin_userapicreds', action='delete')}" method="get">
<div class="hidden">
${request.passvars.cached_form_vals}
<input type="hidden" name="User_ID" value="${cred_user.User_ID}">
<input type="hidden" name="CredID" value="${cred.CredID}">
</div>
<input type="submit" value="${_('Delete')}">
</form>
</td>
</tr>
%endfor
<tr>
<td colspan="3">
<form action="${request.route_path('admin_userapicreds', action='add')}" method="get">
<div class="hidden">
${request.passvars.cached_form_vals}
<input type="hidden" name="User_ID" value="${cred_user.User_ID}">
</div>
<input type="submit" value="${_('Add New')}">
</form>
</td></tr>
</table>
