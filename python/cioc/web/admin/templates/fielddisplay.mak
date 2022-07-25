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
<%! 
from cioc.core import constants as const
%>

<%
user = request.user
member_id = request.dboptions.MemberID
SuperUserGlobal = (domain.id==const.DM_VOL and user.vol.SuperUserGlobal) or (domain.id==const.DM_CIC and user.cic.SuperUserGlobal)
%>
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> 
%if not SuperUserGlobal:
| <a href="${request.passvars.route_path('admin_notices', action='new', _query=[('AreaCode', 'FIELDDISPLAY'), ('DM', domain.id)])}">${_('Request Change')}</a>
%endif
]</p>
<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">

%if domain.id != const.DM_VOL:
<p>${_('Shared fields, denoted by a <span class="Alert">*</span>, may be used across different CIOC modules (CIC or Volunteer). Please be courteous and contact your database partners (if any) before modifying the names of shared fields. Each module has its own field order and required fields.')|n}</p>
%endif

<form method="post" action="${request.route_path('admin_fielddisplay')}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="DM" value="${domain.id}">
</div>

<div class="HideNoJs">
${sc.shown_cultures_ui()}
</div>

<table class="BasicBorder cell-padding-3 sortable_table" data-sortdisabled="[0]">
<thead>
	<tr>
		%if domain.id != const.DM_VOL:
		<th class="RevTitleBox"></th>
		%endif
		<th class="RevTitleBox">${_('Name')}</th>
		%for culture in record_cultures:
		<% lang = culture_map[culture] %>
		<th ${sc.shown_cultures_attrs(culture, "RevTitleBox" )}>${_('Display')} (${lang.LanguageName})</th>
		%endfor
		<th class="RevTitleBox">${_('Order')}</th>
		<th class="RevTitleBox">${_('Required')}</th>
		<th class="RevTitleBox">${_('HTML Editor')}</th>
	</tr>
</thead>
<tbody>
%for index, field in enumerate(fields):
<% 
	prefix = 'field-' + str(index) + '.' 
	fieldinfo = fieldinfo_map[str(renderer.value(prefix + 'FieldID'))]
%>
	<tr>
		%if domain.id != const.DM_VOL:
		<td class="Alert" align="center">${ u'*' if  fieldinfo.Shared else u'&nbsp;' |n}</td>
		%endif

		<td class="FieldLabelLeft">
			${ fieldinfo.FieldName }
			%if SuperUserGlobal or fieldinfo.MemberID == member_id:
			<div style="display:none;">${renderer.hidden(prefix + 'FieldID')}</div>
			%endif
		</td>

		%for culture in record_cultures:
		<%
		lang = culture_map[culture]
		%>
		<td ${sc.shown_cultures_attrs(culture)}>
			<% field_name = prefix + 'Descriptions.' + lang.FormCulture + '.FieldDisplay' %>
			%if SuperUserGlobal or fieldinfo.MemberID == member_id:
			${renderer.errorlist(field_name)}${renderer.text(field_name, maxlength=100, size=30, title=lang.LanguageName + _(' Display Text for: ') + fieldinfo.FieldName)}
			%else:
			${renderer.value(field_name)}
			%endif
		</td>
		%endfor
		<td style="text-align: right">
			%if SuperUserGlobal or fieldinfo.MemberID == member_id:
			${renderer.errorlist(prefix + 'DisplayOrder')}${renderer.text(prefix + 'DisplayOrder', size=3, maxlength=3, title=fieldinfo.FieldName + _(': Display Order'))}
			%else:
			${renderer.value(prefix + 'DisplayOrder')}
			%endif
		</td>
		<td style="text-align: center">
			%if SuperUserGlobal or fieldinfo.MemberID == member_id:
			${renderer.errorlist(prefix + 'Required')}${renderer.checkbox(prefix + 'Required', title=fieldinfo.FieldName + _(': Required'))}
			%elif fieldinfo.Required:
			*
			%endif
		</td>
		<td style="text-align: center">
			%if fieldinfo.WYSIWYG is not None:
				%if SuperUserGlobal or fieldinfo.MemberID == member_id:
			${renderer.errorlist(prefix + 'WYSIWYG')}${renderer.checkbox(prefix + 'WYSIWYG', title=fieldinfo.FieldName + _(': HTML Editor'))}
				%elif fieldinfo.WYSIWYG:
			*
				%endif
			%endif
		</td>
	</tr>
%endfor
</tbody>

<tr>
	<td colspan="${4 + len(record_cultures) + (domain.id != const.DM_VOL)}">
	<input type="submit" name="Submit" value="${_('Update')}"> 
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>

</form>
</div>

<%def name="bottomjs()">
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/tablesort.js')}
${sc.shown_cultures_js()}
</%def>

