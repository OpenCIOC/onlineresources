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

<%def name="makeExcelProfileList(name, add_empty=False, id=None)">
<select name="${name}" id="${id or name}">
	%if add_empty:
	<option value=""> -- </option>
	%endif
	%for profile in profiles:
		<option value="${profile.ProfileID}">${profile.ProfileName}</option>
	%endfor
</select>
</%def>
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>
%if profiles:
<form action="${request.route_path('admin_excelprofile', action='edit')}" method="get">
${request.passvars.cached_form_vals|n}
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox">${renderer.label('ProfileID', _('Edit Excel Profile'))}</th>
</tr>
<tr>
<td>
${makeExcelProfileList('ProfileID')}
<input type="submit" value="${_('View/Edit Excel Profile')}"></td>
</tr>
</table>
</form>
<br>
%else:
<p><em>${_('There are no existing profiles.')}</em></p>
%endif
<form action="${request.route_path('admin_excelprofile', action='add')}" method="get">
${request.passvars.cached_form_vals|n}
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox" colspan="2">${_('Create New Excel Profile')}</th>
</tr>
%if profiles:
<tr>
	<td class="FieldLabelLeft">${renderer.label('NewProfileID', _('Copy Existing Excel Profile'))}</td>
	<td>${makeExcelProfileList('ProfileID', add_empty=True, id='NewProfileID')}</td>
</tr>
%endif
<tr>
	<td colspan="2" align="center"><input type="submit" value="${_('Add Excel Profile')}"></td>
</tr>
</table>
</form>
