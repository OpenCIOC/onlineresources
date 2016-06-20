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
SuperUserGlobal = (domain.id==const.DM_VOL and user.vol.SuperUserGlobal) or (domain.id==const.DM_CIC and user.cic.SuperUserGlobal)
%>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a>
%if not SuperUserGlobal:
| <a href="${request.passvars.route_path('admin_notices', action='new', _query=[('AreaCode', 'FIELDDISPLAYYESNO'), ('DM', domain.id)])}">${_('Request Change')}</a>
%endif
]</p>
<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">

%if domain.id != const.DM_VOL:
<p>${_('Shared fields, denoted by a <span class="Alert">*</span>, may be used across different CIOC modules (CIC or Volunteer). Please be courteous and contact your database partners (if any) before modifying shared fields.')|n}</p>
%endif

%if SuperUserGlobal:
<form method="post" action="${request.route_path('admin_fieldradio')}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="DM" value="${domain.id}">
</div>
%endif

${sc.shown_cultures_ui(SuperUserGlobal)}

<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox" ${ 'colspan="2"' if domain.id != const.DM_VOL else '' |n }>${_('Name')}</th>
%for culture in record_cultures:
<% lang = culture_map[culture] %>
	<th ${sc.shown_cultures_attrs(culture, "RevTitleBox")}>${_('Display')} (${lang.LanguageName})</th>
%endfor
</tr>
%for index, field in enumerate(fields):
<% 
	prefix = 'field-' + str(index) + '.' 
	fieldinfo = fieldinfo_map[str(renderer.value(prefix + 'FieldID'))]
%>
<tr>
	%if domain.id != const.DM_VOL:
	<td class="Alert" align="center">${ u'*' if  fieldinfo.Shared else u'&nbsp;' |n}</td>
	%endif

	<td class="FieldLabelLeft"> ${ fieldinfo.FieldName }
	%if SuperUserGlobal:
	<div style="display:none;">
	${renderer.hidden(prefix + 'FieldID')}</div>
	%endif
	</td>

	%for culture in record_cultures:
	<% 
		lang = culture_map[culture]
		field_name = prefix + 'Descriptions.' + lang.FormCulture + '.CheckboxOnText'
	%>
	<td ${sc.shown_cultures_attrs(culture)}>
	<strong>${renderer.label(field_name, _('On: '))}</strong>
	%if SuperUserGlobal:
	${renderer.errorlist(field_name)}${renderer.text(field_name, maxlength=100, size=30)}
	%else:
	${fieldinfo.Descriptions.get(lang.FormCulture, dict()).get('CheckboxOnText')}
	%endif
	<br>
	<% field_name = prefix + 'Descriptions.' + lang.FormCulture + '.CheckboxOffText' %>
	<strong>${renderer.label(field_name, _('Off: '))}</strong>
	%if SuperUserGlobal:
	${renderer.errorlist(field_name)}${renderer.text(field_name, maxlength=100, size=30)}
	%else:
	${fieldinfo.Descriptions.get(lang.FormCulture, dict()).get('CheckboxOffText')}
	%endif
	</td>
	%endfor
	
</tr>
%endfor


%if SuperUserGlobal:
<tr>
	<td colspan="${4 + len(record_cultures) + (domain.id != const.DM_VOL)}">
	<input type="submit" name="Submit" value="${_('Update')}"> 
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
%endif
</table>

%if SuperUserGlobal:
</form>
%endif
</div>

<%def name="bottomjs()">
${sc.shown_cultures_js()}
</%def>

