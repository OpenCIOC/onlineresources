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
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_mappingsystem_index')}">${_('Return to Mapping Systems')}</a> ]</p>
<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
<form method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
%if not is_add:
<input type="hidden" name="MAP_ID" value="${MAP_ID}">
%endif
</div>

${sc.shown_cultures_ui()}

<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('Edit Mapping System') if not is_add else _('Add Mapping System')}</th></tr>
%if not is_add and context.get('mapping') is not None:
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Status')}</td>
	<td>
	%if mapping.UsageCount:
		${_('This Mapping System is <strong>being used</strong> by %d record(s).') % mapping.UsageCount |n} [ <a href="${request.passvars.makeLink('/results.asp',dict(Limit='EXISTS(SELECT * FROM GBL_BT_MAP WHERE MAP_ID=%d AND NUM=bt.NUM)' % mapping.MAP_ID))}">${_('Search')}</a> ] 
		<br>${_('Because this Mapping System is being used, you cannot currently delete it.')}
	%else:
		${_('This Mapping System is <strong>not</strong> being used by any records.')|n}
		<br>${_('Because this Mapping System is not being used, you can delete it using the button at the bottom of the form.')}
	%endif
	</td>
</tr>
${self.makeMgmtInfo(mapping)}
%endif

<tr>
	<td class="FieldLabelLeft NoWrap">${_('Name')}</td>
	<td><span class="SmallNote">${_('Name of this Mapping System (not displayed in records)')}</span>
	<table class="NoBorder cell-padding-2">
%for culture in record_cultures:
<% lang = culture_map[culture] %>
	<tr ${sc.shown_cultures_attrs(culture)}>
	<td class="FieldLabelLeftClr">${renderer.label("descriptions." +lang.FormCulture + ".Name", lang.LanguageName)}</td>
	<td>
	${renderer.errorlist("descriptions." +lang.FormCulture + ".Name")}
	${renderer.text("descriptions." +lang.FormCulture + ".Name", maxlength=50)}
	</td>
	</tr>
%endfor
	</table>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Label')}</td>
	<td><span class="SmallNote">${_('Text used to display the link to the map within a record, e.g. View Google Map. Also used as the name of this Mapping System.')}</span>
	<table class="NoBorder cell-padding-2">
%for culture in record_cultures:
<% lang = culture_map[culture] %>
	<tr ${sc.shown_cultures_attrs(culture)}>
	<td class="FieldLabelLeftClr">${renderer.label("descriptions." +lang.FormCulture + ".Label", lang.LanguageName)}</td>
	<td>
	${renderer.errorlist("descriptions." +lang.FormCulture + ".Label")}
	${renderer.text("descriptions." +lang.FormCulture + ".Label", maxlength=200)}
	</td>
	</tr>
%endfor
	</table>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Link')}</td>
	<td><span class="SmallNote">${_('You may use any of the following fields in your link: [NUM], [SITE_ADDRESS], [SITE_STREET_NUMBER], [SITE_STREET], [SITE_STREET_TYPE], [SITE_STREET_DIR], [SITE_CITY], [SITE_PROVINCE], [SITE_COUNTRY], [SITE_POSTAL_CODE], [LATITUDE], [LONGITUDE]. Example: http://maps.mysite.ca/map_script?record=[NUM]. Adequate address information must be supplied in order for a mapping link to appear, even when using an external Mapping System.')}</span>
	<table class="NoBorder cell-padding-2">
%for culture in record_cultures:
<% lang = culture_map[culture] %>
	<tr ${sc.shown_cultures_attrs(culture)}>
	<td class="FieldLabelLeftClr">${renderer.label("descriptions." +lang.FormCulture + ".String", lang.LanguageName)}</td>
	<td>
	${renderer.errorlist("descriptions." +lang.FormCulture + ".String")}
	${renderer.proto_url("descriptions." +lang.FormCulture + ".String", maxlength=255)}
	</td>
	</tr>
%endfor
	</table>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap"><label for="mapping.DefaultProvince">${_('Default Province')}</label></td>
	<td>
		${renderer.errorlist('mapping.DefaultProvince')}
		${renderer.text('mapping.DefaultProvince', maxlength="2", size="3")}
		<br>${_('Default value for the state / province that is sent to the Mapping System when there is no value in the record being mapped.')}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap"><label for="mapping.DefaultCountry">${_('Default Country')}</label></td>
	<td>
		${renderer.errorlist('mapping.DefaultCountry')}
		${renderer.text('mapping.DefaultCountry', maxlength="50")}
		<br>${_('Default value for the country that is sent to the Mapping System when there is no value in the record being mapped.')}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('New Window')}</td>
	<td>
		${renderer.errorlist('mapping.NewWindow')}
		${renderer.checkbox('mapping.NewWindow', label=_('Open the map link in a new browser window'))}
	</td>
</tr>
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Add') if is_add else _('Update')}"> 
	%if not is_add and context.get('mapping') is not None and not mapping.UsageCount:
	<input type="submit" name="Delete" value="${_('Delete')}"> 
	%endif
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>
</form>
</div>


<%def name="bottomjs()">
${sc.shown_cultures_js()}
</%def>

