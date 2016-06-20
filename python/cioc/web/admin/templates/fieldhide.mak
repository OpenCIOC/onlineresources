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

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>
<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">

%if domain.id != const.DM_VOL:
<p>${_('Shared fields, denoted by a <span class="Alert">*</span>, may be used across different CIOC modules (CIC or Volunteer).')|n}</p>
%endif

<form method="post" action="${request.route_path('admin_fieldhide')}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="DM" value="${domain.id}">
</div>

${sc.shown_cultures_ui(False)}

<table class="BasicBorder cell-padding-3 sortable_table" data-sortdisabled="[0]">
<thead>
<tr>
	%if domain.id != const.DM_VOL:
	<th class="RevTitleBox"></th>
	%endif
	<th class="RevTitleBox">${_('Name')}</th>
%for culture in record_cultures:
<% lang = culture_map[culture] %>
	<th ${sc.shown_cultures_attrs(culture, "RevTitleBox")}>${_('Display')} (${lang.LanguageName})</th>
%endfor
	<th class="RevTitleBox">${_('Hide')}</th>
</tr>
</thead>
<tbody>
<% HideField = set(renderer.value('HideField') or []) %>
%for fieldinfo in fields:
<tr>
	%if domain.id != const.DM_VOL:
	<td class="Alert" align="center">${ u'*' if  fieldinfo.Shared else u'&nbsp;' |n}</td>
	%endif

	<td class="FieldLabelLeft"> ${ fieldinfo.FieldName }
	%for culture in record_cultures:
	<% 
		lang = culture_map[culture]
	%>
	<td ${sc.shown_cultures_attrs(culture)}>
		${fieldinfo.Descriptions.get(lang.FormCulture, dict()).get('FieldDisplay')}
	</td>
	%endfor
	<td style="text-align: center" data-tbl-key="${1 if str(fieldinfo.FieldID) in HideField else 0}">
	${renderer.ms_checkbox('HideField', str(fieldinfo.FieldID), title=fieldinfo.FieldName + _(': Hide Field'))}
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

