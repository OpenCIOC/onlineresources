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
<%!
from markupsafe import escape_silent as h, Markup
from webhelpers.html import tags
%>

%if not request.user.cic.LimitedView and not is_shared_edit:
<p style="font-weight:bold">[ <a href="${request.passvars.route_path('cic_publication_index')}">${_('Return to Publications')}</a> ]</p>
<form method="post" action="${request.route_path('cic_publication', action='edit')}" class="form">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
%if not is_add:
<input type="hidden" name="PB_ID" value="${PB_ID}">
%endif
</div>

<table class="BasicBorder cell-padding-4 form-table responsive-table max-width-lg clear-line-below">
<tr>
	<th colspan="2" class="RevTitleBox">${_('Edit Publication') if not is_add else _('Add Publication')}</th>
</tr>
<%
route_path = request.passvars.route_path
can_delete = True 
MemberID = request.dboptions.MemberID
%>
%if not is_add and context.get('publication') is not None:
<tr>
	<td class="field-label-cell">${_('Status')}</td>
	<td class="field-data-cell">
	%if not views:
		${_('This Publication is <strong>not</strong> being used by any Views.')|n}
	%else:
		${_('This Publication is <strong>being used</strong> by the following Views:')|n} 
		${Markup('; ').join((Markup('<a href="%s">%s</a>') % (route_path('admin_view', action='edit', _query=[('ViewType',x.ViewType), ('DM',const.DM_CIC)]),x.ViewName)) if x.MemberID==MemberID else x.ViewName for x in views)}
	%endif
	%if publication.UsageCountLocal or publication.UsageCountOther:
		<% can_delete = False %>
		%if publication.UsageCountLocal:
		<br>${(_('This Publication is <strong>being used</strong> by %d local Organization / Program records') if request.dboptions.OtherMembers else _('This Publication is <strong>being used</strong> by %d Organization / Program records')) % publication.UsageCountLocal |n} [ <a href="${request.passvars.makeLink('/results.asp',dict(PBID=PB_ID))}">${_('Search')}</a> ] 
		%endif
		%if publication.UsageCountOther:
		<br>${_('This Publication is <strong>being used</strong> by %d Organization / Program records beloging to other Members') % publication.UsageCountOther |n}
		%endif
	%else:
		<br>${_('This Publication is <strong>not</strong> being used by any Organization / Program records.')|n}
	%endif
	%if can_delete:
		<br>${_('Because this Publication is not being used, you can delete it using the button at the bottom of the form.')}
	%else:
		<br>${_('Because this Publication is being used, you cannot currently delete it.')}
		%if request.user.cic.SuperUser:
			<br><a href="${route_path('cic_publication', action='clearrecords', _query=[('PB_ID', PB_ID)])}" target="_blank">${_('Clear publication from all records')}</a>
		%endif
	%endif
	</td>
</tr>
${self.makeMgmtInfo(publication)}
%endif
<tr>
	<td class="field-label-cell"><label for="publication.PubCode">${_('Code')}</label></td>
	<td class="field-data-cell">
		${renderer.errorlist('publication.PubCode')}
		<div class="form-inline form-inline-always">
			${renderer.text('publication.PubCode', maxlength=20, class_="form-control")}
			<br>${_('Unique code identifying this Publication. Only alpha-numeric characters are allowed (A-Z,0-9).')}
		</div>
	</td>
</tr>

%if not is_add and context.get('publication') is not None and publication.MemberID is None:
<tr>
	<td class="field-label-cell">${_('Allow Local Editors')}</td>
	<td class="field-data-cell">
		${renderer.errorlist('publication.CanEditHeadingsShared')}
		${renderer.checkbox('publication.CanEditHeadingsShared', label=_("Headings of this publication can be edited as if it were local publication"))}
	</td>
</tr>
%endif

%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." +lang.FormCulture + ".Notes", _('Publication Notes (%s)') %lang.LanguageName)}</td>
	<td class="field-data-cell">
	${renderer.errorlist("descriptions." +lang.FormCulture + ".Notes")}
	${renderer.textarea("descriptions." +lang.FormCulture + ".Notes", class_="form-control")}
	</td>
</tr>
%endfor
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." +lang.FormCulture + ".Name", _('Name (%s)') %lang.LanguageName)}</td>
	<td class="field-data-cell">
	${renderer.errorlist("descriptions." +lang.FormCulture + ".Name")}
	${renderer.text("descriptions." +lang.FormCulture + ".Name", maxlength=100, class_="form-control")}
	</td>
</tr>
%endfor
<tr>
	<td class="field-label-cell">${_('Non-Public')}</td>
	<td class="field-data-cell">${renderer.errorlist("publication.NonPublic")}
	${renderer.radio("publication.NonPublic", 'True', False, label=_('Yes'))}
	${renderer.radio("publication.NonPublic", 'False', True, label=_('No'))}
	<br>${('Non-public publications will not be visible in views that cannot see non-public records.')}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Field Use')}</td>
	<td>
	<table class="BasicBorder cell-padding-3">
		<thead>
			<tr>
				<th>&nbsp;</th>
				<th>${_('Field')}</th>
				<th>${_('Description')}</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>${renderer.checkbox("publication.FieldDesc")}</td>
				<td class="FieldLabelLeftClr"><label for="publication.FieldDesc">*_DESC</label></td>
				<td>${renderer.errorlist("publication.FieldDesc")}
				${_('Publication Description (display, feedback)')}</td>
			</tr>
			<tr>
				<td>${renderer.checkbox("publication.FieldHeadings")}</td>
				<td class="FieldLabelLeftClr"><label for="publication.FieldHeadings">*_HEADINGS</label></td>
				<td>${renderer.errorlist("publication.FieldHeadings")}
				${_('Public General Headings assigned to this record (display, feedback)')}</td>
			</tr>
			<tr>
				<td>${renderer.checkbox("publication.FieldHeadingsNP")}</td>
				<td class="FieldLabelLeftClr"><label for="publication.FieldHeadingsNP">*_HEADINGS_NP</label></td>
				<td>${renderer.errorlist("publication.FieldHeadingsNP")}
				${_('All General Headings assigned to this record (display, feedback, update)')}</td>
			</tr>
			<tr>
				<td>${renderer.checkbox("publication.FieldHeadingGroups")}</td>
				<td class="FieldLabelLeftClr"><label for="publication.FieldHeadingGroups">*_HEADINGGROUPS</label></td>
				<td>${renderer.errorlist("publication.FieldHeadingGroups")}
				${_('Heading Groups associated with the public General Headings assigned to this record (display)')}</td>
			</tr>
			<tr>
				<td>${renderer.checkbox("publication.FieldHeadingGroupsNP")}</td>
				<td class="FieldLabelLeftClr"><label for="publication.FieldHeadingGroupsNP">*_HEADINGGROUPS_NP</label></td>
				<td>${renderer.errorlist("publication.FieldHeadingGroupsNP")}
				${_('Heading Groups associated with any of the General Headings assigned to this record (display)')}</td>
			</tr>
		</tbody>
		</table>
	<br>${('If checked, the publication description and general headings for this publication can be selected in setup to be put on display and feedback pages.')}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${_('Heading Groups')}</td>
	<td><p class="SmallNote">${_('Optional')}</p>
		<table class="BasicBorder cell-padding-3">
		<thead>
		<tr>
			<th>${_('Delete')}</th>
			<th>${_('Name')} / ${_('Icon')}</th>
			<th>${_('Order')}</th>
		</tr>
		</thead>
		<tbody id="group-add-target">
		%for index,group in enumerate(groups):
			<% 
				prefix = 'group-' + str(index) + '.' 
				if isinstance(group, dict):
					groupid = group.get('GroupID')
				else:
					groupid = group.GroupID
			%>
			${makeHeadingGroupRow(prefix, groupid)}
		%endfor
		</tbody>
		</table>
		<button id="add-group-row">${_('Add Group')}</button>
	</td>
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
%endif

%if not is_add:
	<br>
	<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox">${_('Manage General Headings')}</th>
	</tr>
	<tr>
	<td>[ <a href="${request.passvars.route_path('cic_generalheading_index', _query=[('PrintMd', 'on'), ('PB_ID', PB_ID)])}" target="_blank">${_('Print Version (New Window)')}</a>
	| <a href="${request.passvars.route_path('cic_generalheading', action='edit', _query=[('PB_ID',PB_ID)])}">${_('Create New General Heading')}</a>
	| <a href="${request.passvars.route_path('cic_generalheading', action='edit', _query=[('PB_ID',PB_ID),('TaxonomyHeading','on')])}">${_('Create New Taxonomy General Heading')}</a>
	| <a href="${request.passvars.route_path('cic_generalheading', action='quicktaxonomy', _query=[('PB_ID',PB_ID)])}">${_('Quick Add Taxonomy General Headings')}</a>
	]
	%if generalheadings:
	<form action="${request.route_path('cic_generalheading', action='edit')}" method="get">
	<div class="NotVisible">
	${request.passvars.cached_form_vals|n}
	<input type="hidden" name="PB_ID" value="${PB_ID}">
	</div>
	<br>
	${tags.select("GH_ID", None, options=generalheadings) }
	<input type="submit" value="${_('View/Edit General Heading')}">
	</form>
	%endif
	</td>
	</tr>
	%if not request.user.cic.LimitedView:
	<tr>
		<th class="RevTitleBox"><label for="CopyPBID">${_('Copy General Headings From:')}</label></th>
	</tr>
	<tr><td>
	<form action="${request.pageinfo.PathToStart}pubs_edit_gh_copy.asp" method="post">
	<div class="NotVisible">${request.passvars.cached_form_vals|n}
	<input type="hidden" name="PBID" value="${PB_ID}"></div>
	${tags.select("CopyPBID", None, options=[('', '')] + publications, id="CopyPBID") }
	<input type="submit" value="${_('View/Copy General Headings')}">
	</form>
	</td>
	</tr>
	%endif
	</table>

%endif


<%def name="bottomjs()">
<script type="text/html" id="new-item-template">
${makeHeadingGroupRow('group-[COUNT].', "NEW")}
</script>

<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/publication.js')}
<script type="text/javascript">
jQuery(function($) {
	var count = 999999;
	$('#add-group-row').click(function(evt) {
		var self = $(this), addtarget = $('#group-add-target'),
			row = $($('#new-item-template')[0].innerHTML.replace(/\[COUNT\]/g, count++));

		evt.preventDefault()
		addtarget.append(row);

		init_general_heading_icons(
				"${request.passvars.route_path("jsonfeeds_icons")}",
				row.find('.icon-autocomplete'));

		return false;
	});

	$('.icon-autocomplete').each( function() {
		init_general_heading_icons(
		"${request.passvars.route_path("jsonfeeds_icons")}",
		$(this));
	});

});
</script>
</%def>

<%def name="makeHeadingGroupRow(prefix, itemid)">
<tr>
	<td>
		${renderer.hidden(prefix + 'GroupID', itemid)}
		${renderer.checkbox(prefix + 'delete', title=_('Delete Heading'))}
	</td>
	<td>
	%for culture in active_cultures:
		<% lang = culture_map[culture] %>
		<div class="form-group">
			${renderer.label(prefix + 'Descriptions.' + lang.FormCulture + '.Name', lang.LanguageName)}
			${renderer.errorlist(prefix + 'Descriptions.' + lang.FormCulture + '.Name')}
			${renderer.text(prefix + 'Descriptions.' + lang.FormCulture + '.Name', maxlength=200, class_="form-control", title=_('%s Name') % culture_map[culture].LanguageName)}
		</div>
	%endfor
		<div class="form-group">
			${renderer.label(prefix + 'IconNameFull', _('Icon'))}
			%if renderer.value(prefix + 'IconNameFull'):
				<div class="icon-listing-group alert-info">
				${renderer.value(prefix + 'IconNameFull')}
				%if renderer.value(prefix + 'IconNameFull').startswith('fa'):
					<i class="fa ${renderer.value(prefix + 'IconNameFull')}"></i>
				%elif renderer.value(prefix + 'IconNameFull').startswith('glyphicon'):
					<span class="glyphicon ${renderer.value(prefix + 'IconNameFull')}"></span>
				%elif renderer.value(prefix + 'IconNameFull').startswith('icon'):
					<span class="${renderer.value(prefix + 'IconNameFull')}"></span>
				%else:
					${_('Error Displaying Icon')}
				%endif
				</div>
			%endif
			${renderer.errorlist(prefix + 'IconNameFull')}
			${renderer.text(prefix + 'IconNameFull', id='generalheading_IconNameFull', maxlength=65, class_="form-control icon-autocomplete")}
			<div class="help-block"><a href="${request.passvars.route_url('gbl_iconlist')}" target="_blank">${_('Browse icons')}</div>
		</div>
	</td>
	<td>
		<div class="form-inline form-inline-always">
			${renderer.errorlist(prefix + 'DisplayOrder')}${renderer.text(prefix + 'DisplayOrder', "0", size=3, maxlength=3, class_="form-control", title=_('Display Order'))}
		</div>
	</td>
</tr>
</%def>

