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
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_interests_index')}">${_('Return to Specific Areas of Interest')}</a> ]</p>
<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
<form method="post" action="${request.route_path('admin_interests', action='edit')}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
%if not is_add:
<input type="hidden" name="AI_ID" value="${AI_ID}">
%endif
</div>

${sc.shown_cultures_ui()}

<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('Edit Specific Area of Interest') if not is_add else _('Add Specific Area of Interest')}</th></tr>
%if not is_add and context.get('interest') is not None:
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Status')}</td>
	<td>
	%if interest.UsageCount:
		${_('This Specific Area of Interest is <strong>being used</strong> by %d record(s).') % interest.UsageCount |n} [ <a href="${request.passvars.makeLink('~/volunteer/results.asp', dict(incDel="on", DisplayStatus="A", AIID=interest.AI_ID))}">${_('Search')}</a> ] 
		<br>${_('Because this Specific Area of Interest is being used, you cannot currently delete it.')}
	%else:
		${_('This Specific Area of Interest is <strong>not</strong> being used by any records.')|n}
		<br>${_('Because this Specific Area of Interest is not being used, you can delete it using the button at the bottom of the form.')}
	%endif
	</td>
</tr>
${self.makeMgmtInfo(interest)}
%endif

<tr>
	<td class="FieldLabelLeft NoWrap">${renderer.label("Code", _('Code'))}</td>
	<td>
	${renderer.errorlist("Code")}
	${renderer.text("Code", maxlength=20)}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Name')} <span class="Alert">*</span></td>
	<td>
	<table class="NoBorder cell-padding-2">
%for culture in record_cultures:
<% lang = culture_map[culture] %>
	<tr ${sc.shown_cultures_attrs(culture)}>
	<td class="FieldLabelLeftClr">${renderer.label("descriptions." +lang.FormCulture + ".Name", lang.LanguageName)}</td>
	<td>
	${renderer.errorlist("descriptions." +lang.FormCulture + ".Name")}
	${renderer.text("descriptions." +lang.FormCulture + ".Name", maxlength=200)}
	</td>
	</tr>
%endfor
	</table>
	</td>
</tr>
%if group_descs:
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Belongs to General Areas')}</td>
	<td>
		${renderer.errorlist('groups')}
	%for i,group_desc in enumerate(group_descs):
		%if i:
		<br>
		%endif
		${renderer.ms_checkbox('groups', unicode(group_desc.IG_ID), label=group_desc.Name)}
	%endfor
	</td>
</tr>
%endif
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Add') if is_add else _('Update')}"> 
	%if not is_add and context.get('interest') is not None and not interest.UsageCount:
	<input type="submit" name="Delete" value="${_('Delete')}"> 
	%endif
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>
</div>


<%def name="bottomjs()">
${sc.shown_cultures_js()}
</%def>

