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

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_pagetitle_index')}">${_('Return to Page Titles')}</a> ]</p>
<form method="post" action="${request.route_path('admin_pagetitle', action='edit')}" class="form-horizontal">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="PageName" value="${PageName}">
</div>

<div class="panel panel-default max-width-lg">
<div class="panel-heading">
	<h2>${_('Edit Override Title for "%s"') % PageName}</h2>
</div>
<div class="panel-body no-padding">
	<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">

%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	${self.fieldLabelCell('descriptions.' + lang.FormCulture + '.TitleOverride',_('Page Title (%s)') % lang.LanguageName, None, True)}
	<td class="field-data-cell">
		${_('When not empty, overrides default value of')} <em>${descriptions[lang.FormCulture].PageTitle}</em>
		<br>${renderer.errorlist("descriptions." +lang.FormCulture + ".TitleOverride")}
		${renderer.text("descriptions." +lang.FormCulture + ".TitleOverride", maxlength=255, class_="form-control")}
	</td>
</tr>
%endfor
<tr>
	<td colspan="2">
		<input type="submit" name="Submit" value="${_('Submit Updates')}" class="btn btn-default"> 
		<input type="reset" value="${_('Reset Form')}" class="btn btn-default">
	</td>
</tr>
</table>
</div>
</div>
</form>

