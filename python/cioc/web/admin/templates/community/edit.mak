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
<%namespace file="cioc.web.admin:templates/cm_checklist.mak" name="cc"/>
<%! 
import json

from markupsafe import Markup 
%>
<style type="text/css">
	#cm-checklist-target {
		margin-top: 0;
		list-style: none;
		padding-left: 0;
	}
</style>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_community_index')}">${_('Return to Communities')}</a> ]</p>
<form method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
%if not is_add:
<input type="hidden" name="CM_ID" value="${CM_ID}">
%endif
%if is_alt_area:
${renderer.hidden('altarea', 'on')}
%endif
</div>

<%
languages = (culture_map[x] for x in record_cultures)
self.languages = [(x.Culture, x.LanguageName) for x in languages]
%>

${sc.shown_cultures_ui()}

<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('Edit Community') if not is_add else _('Add Community')}</th></tr>
<% can_delete = True %>
%if not is_add and context.get('community') is not None:
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Status')}</td>
	<td>
	%if community.ParentUsage:
		<% can_delete = False %>
		${_('<strong>%d</strong> other Communities are using this Community as a parent community.') % community.ParentUsage |n} [ <a href="javascript:openWin('${request.passvars.makeLink('/comfind.asp')}','cfind')">${_('Community Finder')}</a> ]
	%else:
		${_('This Community <strong>is not</strong> being used by any Communities as a Parent Community.')|n}
	%endif
	%if community.AreasServedUsage:
		<% can_delete = False %>
		<br>${_('<strong>%d</strong> Organization / Program record(s) are using this Community as an "Area Served".') % community.AreasServedUsage |n} [ <a href="${request.passvars.makeLink('/results.asp',dict(Limit='EXISTS(SELECT * FROM CIC_BT_CM WHERE CM_ID=%d AND NUM=bt.NUM)' % community.CM_ID))}">${_('Search')}</a> ] 
	%else:
		${_('This Community <strong>is not</strong> being used by any Organization / Program records as an "Area Served".')|n}
	%endif
	%if community.LocatedInUsage:
		<% can_delete = False %>
		<br>${_('<strong>%d</strong> Organization / Program record(s) are using this Community as an "Located in Community".') % community.LocatedInUsage |n} [ <a href="${request.passvars.makeLink('/results.asp',dict(Limit='LOCATED_IN_CM=%d' % community.CM_ID))}">${_('Search')}</a> ] 
	%else:
		<br>${_('This Community <strong>is not</strong> being used by any Organization / Program records as an "Located in Community".')|n}
	%endif
	%if community.BusRouteUsage:
		<% can_delete = False %>
		<br>${_('<strong>%d</strong> Bus Routes are using this Community as a Municipality.') % community.BusRouteUsage |n}
	%elif community.UsesBusRoutes:
		<br>${_('This Community <strong>is not</strong> being used by any Bus Routes as a Municipality.')|n}
	%endif
	%if community.WardUsage:
		<% can_delete = False %>
		<br>${_('<strong>%d</strong> Wards are using this Community as a Municipality.') % community.WardUsage |n} 
	%elif community.UsesWards:
		<br>${_('This Community <strong>is not</strong> being used by any Wards as a Municipality.')|n}
	%endif
	%if community.VolOppUsage:
		<% can_delete = False %>
		<br>${_('<strong>%d</strong> Volunteer Opportunity record(s) are using this Community.') % community.VolOppUsage |n} [ <a href="${request.passvars.makeLink('/volunteer/results.asp',dict(Limit='EXISTS(SELECT * FROM VOL_OP_CM WHERE CM_ID=%d AND VNUM=vo.VNUM)' % community.CM_ID))}">${_('Search')}</a> ] 
	%elif request.dboptions.UseVOL:
		<br>${_('This Community <strong>is not</strong> being used by Volunteer opportunity records.')|n}
	%endif
	%if community.AltSearchArea:
		<br>${_('This Community is part of the following Alternate Search Areas: ')}
		<em>${Markup(', ').join(x['Name'] for x in community.AltSearchArea)}</em>
		<% can_delete = False %>
	%else:
		<br>${_('This Community <strong>is not</strong> part of an Alternate Search Area.')|n}
	%endif
	%if can_delete:
		<p>${_('Because this Community is not being used, you can delete it using the button at the bottom of the form.')}</p>
	%else:
		<p>${_('Because this Community is being used, you cannot currently delete it.')}</p>
	%endif
	</td>
</tr>
${self.makeMgmtInfo(community)}
%endif

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
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Display')}</td>
	<td><span class="SmallNote">${_('Fill in a value for Display if you want a different value from the Name for Search communities display and the Located In community display. This will not affect the display of the values for Areas Served.')}</span>
	<table class="NoBorder cell-padding-2">
%for culture in record_cultures:
<% lang = culture_map[culture] %>
	<tr ${sc.shown_cultures_attrs(culture)}>
		<td class="FieldLabelLeftClr">${renderer.label("descriptions." +lang.FormCulture + ".Display", lang.LanguageName)}</td>
		<td>
			${renderer.errorlist("descriptions." +lang.FormCulture + ".Display")}
			${renderer.text("descriptions." +lang.FormCulture + ".Display", maxlength=200)}
		</td>
	</tr>
%endfor
	</table>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${renderer.label('community_ParentCommunityWeb', _('Parent Community'))} <span class="Alert">*</span></td>
	<td>
		${renderer.errorlist('community.ParentCommunity')}
		${renderer.hidden('community.ParentCommunity', id='community_ParentCommunity')}
		${renderer.text('community.ParentCommunityName', id='community_ParentCommunityWeb')}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${renderer.label('community.ProvinceState', _('Province, State and/or Country'))}</td>
	<td>
		${renderer.errorlist('community.ProvinceState')}
		${renderer.select('community.ProvinceState', [('','')] + prov_state)}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Alternate Name(s)')}</td>
	<td>
		<table class="form-table${' hidden' if not renderer.form.data.get('alt_names') else ''}" id="alt-name-target">
			<tr>
				<th class="ui-widget-header">${_('Alt Name')}</th>
				<th class="ui-widget-header">${_('Language')}</th>
				<th class="ui-widget-header">${_('Delete')}</th>
			</tr>
		%for i,alt_name in enumerate(renderer.form.data.get('alt_names') or []):
			<% prefix = 'alt_names-%d.' % i %>
			${make_alt_name(prefix)}
		%endfor
		</table>
		<input type="button" id="add-alternate-name" value="${_('Add')}">
	</td>
</tr>
%if is_alt_area:
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Search Communities')} <span class="Alert">*</span></td>
	<td>
		${cc.make_cm_checklist_ui('alt_areas', alt_area_name_map)}
	</td>
</tr>
%endif
<tr>
	<td colspan="2">
		<input type="submit" name="Submit" value="${_('Add') if is_add else _('Update')}"> 
		%if not is_add and can_delete:
			<input type="submit" name="Delete" value="${_('Delete')}"> 
		%endif
		<input type="reset" value="${_('Reset Form')}">
	</td>
</tr>
</table>
</form>

<%def name="make_alt_name(prefix, default_new=False)">
<% 
is_new = renderer.value(prefix + 'New', default_new) 
%>
<tr ${sc.shown_cultures_attrs(renderer.value(prefix + 'Culture')) if not is_new else ''}>
	<td class="ui-widget-content">
		${renderer.errorlist(prefix + 'AltName')}
		${renderer.text(prefix + 'AltName')}
	</td>
	<td class="ui-widget-content">
		${renderer.errorlist(prefix + 'Culture')}
		%if is_new:
			${renderer.select(prefix + 'Culture', self.languages)}
		%else:
			${culture_map[renderer.value(prefix + 'Culture', 'en-CA').replace('_', '-')].LanguageName}
			${renderer.hidden(prefix + 'Culture')}
		%endif
		${renderer.hidden(prefix + 'New', 'on' if is_new else '')}
	</td>
	<td class="ui-widget-content">
		${renderer.errorlist(prefix + 'Delete')}
		${renderer.checkbox(prefix + 'Delete')}
	</td>
</tr>
</%def>

<%def name="bottomjs()">
${sc.shown_cultures_js()}
<div class='hidden'>
<form id="stateForm" name="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
</div>
<script type="text/html" id="alt-name-template">
${make_alt_name('alt_names-[COUNT].', True)}
</script>
%if is_alt_area:
${cc.make_cm_checklist_template('alt_areas')}
%endif
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/community.js')}
<script type="text/javascript">
<%
parent_kw = {}
search_area_kw = {}
if community and community.ParentCommunity:
	parent_kw = {'_query': [('parent', community.ParentCommunity)]}

if community:
	search_area_kw = {'_query': [('cmid', community.CM_ID)]}
%>
(function($) {
	var parent_link = ${json.dumps(request.route_path('admin_community', action='parents', **parent_kw))|n},
		search_area_link = ${json.dumps(request.route_path('admin_community', action='alt_search_area', **search_area_kw))|n};
	$(function() {
		init_cached_state();

		init_municipality_autocomplete($('#community_ParentCommunityWeb'), parent_link, '${_("An unknown community was entered")}');

		init_community_edit($);
		init_cm_checklist($, search_area_link, {field: 'cm_checklist', txt_not_found:'${_("Not Found")|n}', match_prop: 'label', parent_cmid_input: $('#community_ParentCommunity')});

		restore_cached_state();
	});
})(jQuery);
</script>
</%def>

