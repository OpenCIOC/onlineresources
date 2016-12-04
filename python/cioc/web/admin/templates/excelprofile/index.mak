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
<select name="${name}" id="${id or name}" class="form-control">
	%if add_empty:
	<option value=""> -- </option>
	%endif
	%for profile in profiles:
		<option value="${profile.ProfileID}">#${profile.ProfileID} - ${profile.ProfileName}</option>
	%endfor
</select>
</%def>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>
%if profiles:
<form action="${request.route_path('admin_excelprofile', action='edit')}" method="get" class="form-inline">
<div style="display: none;">
${request.passvars.cached_form_vals|n}
</div>
<h2><label for="ProfileID">${_('Edit Excel Profile')}</label></h2>
${makeExcelProfileList('ProfileID')}
<input type="submit" value="${_('View/Edit Excel Profile')}" class="btn btn-default">
</form>
<br>
%else:
<p><em>${_('There are no existing profiles.')}</em></p>
%endif

<form action="${request.route_path('admin_excelprofile', action='add')}" method="get" class="form-horizontal">
<div style="display: none;">
${request.passvars.cached_form_vals|n}
</div>
<h2>${_('Create New Excel Profile')}</h2>
%if profiles:
<div class="max-width-sm">
	<div class="form-group row">
		${renderer.label('NewProfileID', _('Copy Existing Excel Profile'), class_='control-label col-sm-4')}
		<div class="col-sm-8">
			${makeExcelProfileList('ProfileID', add_empty=True, id='NewProfileID')}
		</div>
	</div>
</div>
%endif
<input type="submit" value="${_('Add Excel Profile')}" class="btn btn-default">

</form>
