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
<% form_cultures = [culture_map[x].FormCulture for x in active_cultures] %>
<style type="text/css">
.hide-usage .usagefield {
	display: none;
}
.hide-guid .guidfield {
	display: none;
}
</style>

<p style="font-weight:bold">[ 
<a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a>
%if request.user.SuperUserGlobal:
| <a href="${request.passvars.route_path('admin_community_index')}">${_('Return to Communities')}</a>
| <a href="${request.passvars.route_path('import_community')}">${_('Update Communities Version')}</a>
| <a href="${request.passvars.route_path('admin_community', action='edit')}">${_('Add Community')}</a>
| <a href="${request.passvars.route_path('admin_community', action='edit', _query=[('altarea', 'on')])}">${_('Add Alternative Search Area')}</a>
%else:
| <a href="${request.passvars.makeLink("~/admin/notices/new","AreaCode=COMMUNITY")}">${_('Request Community Change')}</a>
%endif
| <a href="${request.passvars.makeLink('~/comfind.asp', 'SearchParams=on')}">${_('Show Search Parameters')}</a>
<% query_arg = [('csv', 'on')] %>

%if CM_ID:
| <a href="${request.passvars.route_path('admin_community', action='list')}">${_('Back to All Communities')}</a>
	<% query_arg.append(('CM_ID', str(CM_ID))) %>
%endif
| <a href="${request.passvars.route_path('admin_community', action='list', _query=query_arg)}">${_('Output As Excel')}</a>
]</p>
<p>
<div class="clearfix">
<div style="float: left">
<form method="GET" action="${request.current_route_path()}">
${request.passvars.cached_form_vals}
<input type="hidden" value="" name="CM_ID" id="CM_ID">
<input type="text" value="" id="WebCM_ID" disabled>
<input type="submit" value="${_('Show Children')}" id="community_filter_submit" disabled>
</form>
</div>
<div style="float: left; margin-left: 20px; padding-top: 5px;">
<label><input type="checkbox" class="toggle-field-show" data-toggle-show="guid"> ${_('Show GUIDs')}</label>
<label><input type="checkbox" class="toggle-field-show" data-toggle-show="usage"> ${_('Show Usage')}</label>
</div>
</div>
</p>
<table class="BasicBorder cell-padding-3 hide-guid hide-usage" id="results-table">
<tr>
	<th class="RevTitleBox">${_('ID')}</th>
%for culture in active_cultures:
<% lang = culture_map[culture] %>
	<th class="RevTitleBox">${_('Name (%s)') % lang.LanguageName}</th>
%endfor
	<th class="RevTitleBox guidfield">${_('GUID')}</th>
	<th class="RevTitleBox">${_('Parent')}</th>
	<th class="RevTitleBox">${_("Parent's Parent")}</th>
	<th class="RevTitleBox">${_('Province')}</th>
	<th class="RevTitleBox">${_('Is Alt-Area')}</th>
	<th class="RevTitleBox usagefield">${_('Is Parent')}</th>
	<th class="RevTitleBox usagefield">${_('Located In')}</th>
	<th class="RevTitleBox usagefield">${_('Areas Served')}</th>
	<th class="RevTitleBox usagefield">${_('Bus Routes')}</th>
	<th class="RevTitleBox usagefield">${_('Wards')}</th>
	<th class="RevTitleBox usagefield">${_('Views')}</th>
%if request.dboptions.UseVOL:
	<th class="RevTitleBox usagefield">${_('Opportunities')}</th>
	<th class="RevTitleBox usagefield">${_('Community Groups')}</th>
%endif
	<th class="RevTitleBox">${_('Alternate Names')}</th>
	<th class="RevTitleBox">${_('Alt Area Search')}</th>
</tr>
%for community in communities:
<tr>
<td>${community.CM_ID}</td>
%for form_culture in form_cultures:
	<td>${community.Names.get(form_culture, {}).get('Name')}</td>
%endfor
<td class="guidfield">${community.CM_GUID}</td>
<td>${community.ParentCommunityName}</td>
<td>${community.ParentCommunity2}</td>
<td>${community.ProvinceName}</td>
<td style="text-align: center">${'*' if community.AlternativeArea else ''}</td>
<td class="usagefield">${community.ParentUsage}</td>
<td class="usagefield">${community.LocatedInUsage}</td>
<td class="usagefield">${community.AreasServedUsage}</td>
<td class="usagefield">${community.BusRouteUsage}</td>
<td class="usagefield">${community.WardUsage}</td>
<td class="usagefield">${community.ViewUsage}</td>
%if request.dboptions.UseVOL:
<td class="usagefield">${community.VolOppUsage}</td>
<td class="usagefield">${community.CommunityGroupUsage}</td>
%endif
<td>${community.AltNames}</td>
<td>${community.AltAreaSearch}</td>
</tr>
%endfor
</table>

<%def name="bottomjs()">
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/checklists.js')}
<script type="text/javascript">
jQuery(function($) {
	var cm_link = '${request.passvars.makeLink("~/jsonfeeds/community_generator.asp")}',
		cm_error = '${_("An unknown community was entered")}';
		cm_web = $('#WebCM_ID').prop('disabled', false);

	$('#community_filter_submit').prop('disabled', false);
	init_municipality_autocomplete(cm_web, cm_link, cm_error);
	$(document).on('click', '.toggle-field-show', function() {
		var self = $(this);
		var target = self.data('toggleShow');
		var table = $('#results-table');
		if (this.checked) {
			table.removeClass('hide-' + target);
		} else {
			table.addClass('hide-' + target);
		}
	});
});
</script>
</%def>
