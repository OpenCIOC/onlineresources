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
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_excelprofile_index')}">${_('Return to Excel Profiles')}</a> ]</p>
<form method="post" action="${request.route_path('admin_excelprofile', action=action)}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
%if action == 'edit':
<input type="hidden" name="ProfileID" value="${ProfileID}">
%endif
</div>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('Edit Excel Profile') if action == 'edit' else _('Add Excel Profile')}</th></tr>
%if action == 'edit' and context.get('profile') is not None:
${self.makeMgmtInfo(profile)}
%endif

%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="FieldLabelLeft">${renderer.label("descriptions." +lang.FormCulture + ".Name", _('Name') + " (" + lang.LanguageName + ")")}</td>
	<td>${renderer.errorlist("descriptions." +lang.FormCulture + ".Name")}
	${renderer.text("descriptions." +lang.FormCulture + ".Name", maxlength=50)}</td>
</tr>
%endfor
<tr>
	<td class="FieldLabelLeft">${_('Column Headers')}</td>
	<td>${renderer.errorlist("profile.ColumnHeadersWeb")}
    ${ renderer.radio("profile.ColumnHeadersWeb", 'N', False, _('No Column Headers'), id = "Column_Headers_None") }
    <br>${renderer.radio("profile.ColumnHeadersWeb", 'F', False, _('Use Field Name'), id = "Column_Headers_Name")}
    <br>${renderer.radio("profile.ColumnHeadersWeb", 'L', True, _('Use Field Label ("Friendly" Name)'), id = "Column_Headers_Label")}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Views')}</td>
	<td>${_('Available in the selected views')}
	%for view in view_descs:
	<br>${renderer.ms_checkbox('Views', str(view.ViewType), label=view.ViewName, id='view_' + str(view.ViewType))}
	%endfor
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Fields')}</td>
	<td>
		<table class="BasicBorder cell-padding-3">
			<tr>
				<th class="RevTitleBox">${_('Name')}</th>
				<th class="RevTitleBox">${_('Column Order (0-255)')}</th>
				<th class="RevTitleBox">${_('Sort Record Order (0-255)')}</th>
			</tr>
			%for row, field in enumerate(fieldorder):
				<% prefix = 'Fields-' + str(row) %>
			<tr>
				<td>${field_descs[field].FieldDisplay}${renderer.hidden(prefix + '.FieldID', field)}</td>
				<td>${renderer.errorlist(prefix + '.DisplayOrder')}${renderer.text(prefix + '.DisplayOrder', size=3, maxlength=3, title=field_descs[field].FieldDisplay + _(': Column Order'))}</td>
				<td>${renderer.errorlist(prefix + '.SortByOrder')}${renderer.text(prefix + '.SortByOrder', size=3, maxlength=3, title=field_descs[field].FieldDisplay + _(': Sort Record Order'))}</td>
			</tr>
			%endfor
		</table>
	</td>
</tr>
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Add') if action=='add' else _('Update')}"> 
	%if action != 'add':
	<input type="submit" name="Delete" value="${_('Delete')}"> 
	%endif
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>
</form>


