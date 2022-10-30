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

<div class="btn-group" role="group">
	<a role="button" class="btn btn-default" href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a>
	%if not SuperUserGlobal:
	<a role="button" class="btn btn-default" href="${request.passvars.route_path('admin_notices', action='new', _query=[('AreaCode', 'FIELDDISPLAYYESNO'), ('DM', domain.id)])}">${_('Request Change')}</a>
	%endif
</div>

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

		<table class="BasicBorder cell-padding-4 responsive-table-multicol">
			<tr class="field-header-row">
				<th class="RevTitleBox" ${ 'colspan="2"' if domain.id !=const.DM_VOL else '' |n }>${_('Name')}</th>
				%for culture in record_cultures:
				<% lang = culture_map[culture] %>
				<th ${sc.shown_cultures_attrs(culture, "RevTitleBox field-header-cell" )}>${_('Display')} (${lang.LanguageName})</th>
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

				<td class="field-label-cell">
					${ fieldinfo.FieldName }
					%if SuperUserGlobal:
					<div style="display:none;">
						${renderer.hidden(prefix + 'FieldID')}
					</div>
					%endif
				</td>

				%for culture in record_cultures:
				<%
				lang = culture_map[culture]
				field_name = prefix + 'Descriptions.' + lang.FormCulture + '.CheckboxOnText'
				%>
				<td ${sc.shown_cultures_attrs(culture, "field-data-cell" )}>
					<h4 class="field-header-secondary">${_('Display')} (${lang.LanguageName})</h4>
					%if SuperUserGlobal:
					<div class="form-group">
						${renderer.errorlist(field_name)}
						${renderer.label(field_name, _('On / True: '), class_="control-label col-xxs-12 col-xs-3 col-md-12 no-wrap")}
						<div class="col-xxs-12 col-xs-9 col-md-12">
							${renderer.text(field_name, maxlength=100, class_="form-control")}
						</div>
					</div>
					%else:
					<p><strong>${_('On: ')}</strong> ${fieldinfo.Descriptions.get(lang.FormCulture, dict()).get('CheckboxOnText')}</p>
					%endif
					<%
					field_name = prefix + 'Descriptions.' + lang.FormCulture + '.CheckboxOffText'
					%>
					%if SuperUserGlobal:
					<div class="form-group">
						${renderer.errorlist(field_name)}
						${renderer.label(field_name, _('Off / False: '), class_="control-label col-xxs-12 col-xs-3 col-md-12 no-wrap")}
						<div class="col-xxs-12 col-xs-9 col-md-12">
							${renderer.text(field_name, maxlength=100, class_="form-control")}
						</div>
					</div>
					%else:
					<p><strong>${_('Off: ')}</strong> ${fieldinfo.Descriptions.get(lang.FormCulture, dict()).get('CheckboxOffText')}</p>
					%endif
				</td>
				%endfor
			</tr>
			%endfor
		</table>
	%if SuperUserGlobal:
		<div class="clear-line-above">
			<input class="btn btn-default" type="submit" name="Submit" value="${_('Update')}">
			<input class="btn btn-default" type="reset" value="${_('Reset Form')}">
		</div>
	</form>
	%endif
</div>

<%def name="bottomjs()">
${sc.shown_cultures_js()}
</%def>

