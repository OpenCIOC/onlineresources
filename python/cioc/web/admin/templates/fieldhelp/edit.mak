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
<%namespace file="cioc.web.admin:templates/shown_cultures.mak" name="sc" />

<% 
OtherMembersActive = request.dboptions.OtherMembersActive
makeLink = request.passvars.makeLink
page_help_link = '~/' + ('' if domain.id == const.DM_CIC else 'volunteer/') + 'fieldhelp.asp' 
%>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${makeLink('~/admin/setup_help_fields.asp', dict(DM=domain.id))}">${_('Return to Field Help')}</a> ]</p>
<form method="post" action="${request.route_path('admin_fieldhelp', action='edit')}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="FieldID" value="${FieldID}">
<input type="hidden" name="DM" value="${domain.id}">
</div>

${sc.shown_cultures_ui()}

<table class="BasicBorder cell-padding-4">
%for culture in record_cultures:
<% lang = culture_map[culture] %>
% if SuperUserGlobal:
<tr ${sc.shown_cultures_attrs(culture)}><th class="RevTitleBox">${_('Field Help')} - ${field.FieldName}
%if field.FieldDisplay:
(${field.FieldDisplay})
%endif
- ${lang.LanguageName}
%if OtherMembersActive:
${_('(Global)')}
%endif
</th></tr>
<tr ${sc.shown_cultures_attrs(culture)}>
	<td><span class="SmallNote">${_('Maximum 8000 characters.')}</span>
	<br>${renderer.errorlist("descriptions." +lang.FormCulture + ".HelpText")}
	${renderer.textarea("descriptions." +lang.FormCulture + ".HelpText", title=field.FieldName + ' - ' + lang.LanguageName +_(': Field Help (Global)'))}
	<br><a href="javascript:openWin('${makeLink(page_help_link,dict(field=field.FieldName, Ln=culture),['Ln'])}','fHelp')">${_('View the current help')}</a>
	</td>
</tr>
%endif
%if OtherMembersActive:
<tr ${sc.shown_cultures_attrs(culture)}><th class="RevTitleBox">${_('Field Help')} - ${field.FieldName}
%if field.FieldDisplay:
(${field.FieldDisplay})
%endif
- ${lang.LanguageName}</th></tr>
<tr ${sc.shown_cultures_attrs(culture)}>
	<td><span class="SmallNote">${_('Maximum 8000 characters.')}</span>
	<br>${renderer.errorlist("descriptions." +lang.FormCulture + ".HelpTextMember")}
	${renderer.textarea("descriptions." +lang.FormCulture + ".HelpTextMember", title=field.FieldName + ' - ' + lang.LanguageName +_(': Field Help'))}
	<br><a href="javascript:openWin('${makeLink(page_help_link,dict(field=field.FieldName, Ln=culture),['Ln'])}','fHelp')">${_('View the current help')}</a>
	</td>
</tr>
%endif
%endfor
<tr>
	<td>
		<input type="submit" name="Submit" value="${_('Submit Updates')}"> 
		<input type="reset" value="${_('Reset Form')}">
	</td>
</tr>
</table>
</form>

<%def name="bottomjs()">
${sc.shown_cultures_js()}
</%def>

