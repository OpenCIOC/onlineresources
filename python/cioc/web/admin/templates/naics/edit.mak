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
from cioc.core.naics import get_exclusions, get_examples
%>

<%inherit file="cioc.web:templates/master.mak" />

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | 
	<a href="${request.passvars.route_path('admin_naics_index')}">${_('Return to NAICS Management')}</a> ]</p>

<form method="post" action="${request.route_path('admin_naics', action='edit')}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
%if not is_add:
<input type="hidden" name="Code" value="${Code}">
%endif
</div>

<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('Use this form to edit Code information for %s') % classification if not is_add else _('Use this form to create	a new NAICS Code')}</th></tr>
<% can_delete = True %>
%if not is_add and context.get('naics') is not None:
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Status')}</td>
	<td>
	%if naics.UsageCount:
		${_('This NAICS Code is <strong>being used</strong> by %d records.') % naics.UsageCount |n} [ <a href="${request.passvars.makeLink('/results.asp',dict(NAICS= naics.Code))}">${_('Search')}</a> ] 
		<% can_delete = False %>
	%else:
		${_('This NAICS Code <strong>is not</strong> being used by any records.')|n}
	%endif
	%if can_delete:
	<br>${_('Because this NAICS Code is not being used, you can delete it using the button at the bottom of the form.')}
	%else:
		<br>${_('Because this NAICS Code is being used, you cannot currently delete it.')}
	%endif
	</td>
</tr>
${self.makeMgmtInfo(naics)}
<tr>
	<td class="FieldLabelLeft">${_('Source')}</td>
	<td>${naics.Source}</td>
</tr>
%endif
<tr>
	<td class="FieldLabelLeft NoWrap">${renderer.label('naics.NewCode', _('Code'))}</td>
	<td>
		${renderer.errorlist('naics.NewCode')}
		${renderer.text('naics.NewCode', maxlength=6)}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${renderer.label('naics.Parent', _('Parent Code'))}</td>
	<td>
		${renderer.errorlist('naics.Parent')}
		${renderer.text('naics.Parent', maxlength=6)}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Classication')}</td>
	<td>
	<table class="NoBorder cell-padding-2">
%for culture in active_cultures:
<% lang = culture_map[culture] %>
	<tr>
	<td class="FieldLabelLeftClr">${renderer.label("descriptions." +lang.FormCulture + ".Classification", lang.LanguageName)}</td>
	<td>
	${renderer.errorlist("descriptions." +lang.FormCulture + ".Classification")}
	${renderer.text("descriptions." +lang.FormCulture + ".Classification", maxlength=255)}
	</td>
	</tr>
%endfor
	</table>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Description')}</td>
	<td><span class="SmallNote">${_('Maximum 8000 characters.')} ${_('HTML is allowed.')}</span>
%for culture in active_cultures:
<% lang = culture_map[culture] %>
	<p><strong>${renderer.label("descriptions." +lang.FormCulture + ".Description", lang.LanguageName)}</strong>
	<br>${renderer.errorlist("descriptions." +lang.FormCulture + ".Description")}
	${renderer.textarea("descriptions." +lang.FormCulture + ".Description")}
	</p>
%endfor
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('International Compatibility')}</td>
	<td>
		${renderer.errorlist('naics.CompUS')}
		${renderer.checkbox('naics.CompUS', label=_('United States'))}
		<br>
		${renderer.errorlist('naics.CompMEX')}
		${renderer.checkbox('naics.CompMEX', label=_('Mexico'))}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Exclusions')}</td>
	%if is_add:
	<td>${_('Return to this form to add exclusions once the record has been added')}</td>
	%else:
	<td>${_('The current list of exclusions is below.')} <a href="${request.passvars.route_path('admin_naics', action='exclusion', _query=[('Code', Code)])}">${_('Edit Exclusions for this Code')}</a> ${_('(Make sure you submit your changes on this form first!).')}
	<p><strong>${_('Exclusion(s)')}</strong></p>
	${get_exclusions(request, Code, all_langs=True) or _('There are no exclusions')}
	</td>
	%endif
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Examples')}</td>
	%if is_add:
	<td>${_('Return to this form to add examples once the record has been added')}</td>
	%else:
	<td>${_('The current list of examples is below.')} <a href="${request.passvars.route_path('admin_naics', action='example', _query=[('Code', Code)])}">${_('Edit Examples for this Code')}</a> ${_('(Make sure you submit your changes on this form first!).')}
	<p><strong>${_('Example(s)')}</strong></p>
	${get_examples(request, Code, all_langs=True) or _('There are no examples')}
	</td>
	%endif
</tr>
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Add') if is_add else _('Update')}"> 
	%if not is_add and can_delete:
	<input type="submit" name="Delete" value="${_('Delete')}"> 
	%endif
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>
</form>

