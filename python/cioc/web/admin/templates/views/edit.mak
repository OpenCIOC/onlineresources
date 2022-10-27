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
<%namespace file="cioc.web:templates/displayoptions.mak" import="display_options"/>
<%!
from markupsafe import escape_silent as h, Markup
%>
<%def name="make_message_options(field_name, field_label, field_help, title=True, icon=True, message=True)">
<tr>
	${self.fieldLabelCell(None,field_label,field_help,False)}
	<td class="field-data-cell">
		%if title:
		%for culture in culture_order:
		<% lang = culture_map[culture] %>
		<div class="form-group">
			${renderer.label("descriptions." + lang.FormCulture + "." + field_name + "Title", field_label + ' - ' + _('Title') + _(': ') + lang.LanguageName)}
			<div class="SmallNote">${_('Maximum 100 characters. HTML is allowed.')}</div>
			${renderer.errorlist("descriptions." + lang.FormCulture + "." + field_name + "Title")}
			${renderer.text("descriptions." + lang.FormCulture + "." + field_name + "Title", maxlength=100, class_="form-control")}
		</div>
		%endfor
		%endif
		%if icon:
		%for culture in culture_order:
		<% lang = culture_map[culture] %>
		<div class="form-group">
			${renderer.label("descriptions." + lang.FormCulture + "." + field_name + "Glyph", field_label + ' - ' +  _('Icon') + _(': ') + lang.LanguageName)}
			<div class="SmallNote">${_('Bootstrap Glyphicon Name')}</div>
			${renderer.errorlist("descriptions." + lang.FormCulture + "." + field_name + "Glyph")}
			${renderer.text("descriptions." + lang.FormCulture + "." + field_name + "Glyph", maxlength=30, class_="form-control")}
		</div>
		%endfor
		%endif
		%if message:
		%for culture in culture_order:
		<% lang = culture_map[culture] %>
		<div class="form-group">
			${renderer.label("descriptions." + lang.FormCulture + "." + field_name + "Message" , field_label + ' - ' +  _('Message') + _(': ') + lang.LanguageName)}
			<div class="SmallNote">${_('Maximum 8000 characters. HTML is allowed.')}</div>
			${renderer.errorlist("descriptions." + lang.FormCulture + "." + field_name + "Message")}
			${renderer.textarea("descriptions." + lang.FormCulture + "." + field_name + "Message", class_="form-control")}
		</div>
		%endfor
		%endif
	</td>
</tr>
</%def>

<div class="btn-group" role="group">
	<a role="button" class="btn btn-default" href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a>
	<a role="button" class="btn btn-default" href="${request.passvars.route_path('admin_view_index', _query=[('DM', domain.id)])}">${_('Return to Views (%s)') % _(domain.label)}</a>
</div>

<p class="HideJs Alert">${_('Javascript is required to use this page.')}</p>

<%
makeLinkAdmin = request.passvars.makeLinkAdmin
route_path = request.passvars.route_path
dboptions = request.dboptions
can_delete = False
missing_cultures = [x for x in active_cultures if x not in view_cultures]
%>

<div class="HideNoJs">
	<h2>${_('Edit View: ') + usage.CurrentName}</h2>

	<form method="post" action="${request.route_path('admin_view', action='edit')}" id="EntryForm" class="form">

		<div class="NotVisible">
			${request.passvars.cached_form_vals|n}
			<input type="hidden" name="ViewType" value="${ViewType}">
			<input type="hidden" name="DM" value="${domain.id}">
			<% culture_order = [x for x in active_cultures if x in view_cultures] %>
			%for culture in culture_order:
			<input type="hidden" name="ShowCultures" value="${culture}">
			%endfor
		</div>

		<h3>${_('Jump to:')}</h3>
		<ul>
			<li><a href="#basic">${_('Basic View Settings')}</a></li>
			<li><a href="#updating">${_('Record Updating and Feedback')}</a></li>
			<li><a href="#details">${_('Record Details')}</a></li>
			<li><a href="#searching">${_('Searching')}</a></li>
			<li><a href="#template">${_('Template and Layout Options')}</a></li>
			%if domain.id == const.DM_CIC:
			<li><a href="#classifications">${_('Classifications')}</a></li>
			%endif
			<li><a href="#fields">${_('Manage Fields')}</li>
		</ul>

		<div class="panel panel-default max-width-lg">
			<div class="panel-heading">
				<a name="basic"></a>
				<h2>${_('Basic View Settings')}</h2>
			</div>
			<div class="panel-body no-padding">
				<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
					%if context.get('view') is not None:
					<% can_delete = not security_levels and not usage.IsDefaultView %>
					<tr>
						${self.fieldLabelCell(None,_('Status'),None,False)}
						<td class="field-data-cell">
							<p>
								%if not security_levels:
								${_('This View is <strong>not</strong> being used by any User Types.') |n}
								%else:
								${_('This View is <strong>being used</strong> by the following User Types:')|n}
								${'; '.join('<a href="%s">%s</a>' % (makeLinkAdmin('setup_utypes_edit.asp', dict(SLID=x.SL_ID, DM=domain.id)),h(x.SecurityLevel)) for x in security_levels) |n}
								%endif
							</p>
							<p>
								%if usage.IsDefaultView:
								${_('This View is <strong>public</strong> because it is the <strong>default View</strong>.')|n}
								%elif usage.IsPublicView:
								${_('This View is <strong>public</strong> because it is visible from the default view: ')|n}
								%if usage.CanEditDefaultView:
								<a href="${request.passvars.route_path('admin_view', action='edit', _query=[('DM',domain.id),('ViewType',usage.DefaultViewType)])}">${usage.DefaultViewName}</a>
								%else:
								${usage.DefaultViewName}
								%endif
								%else:
								${_('This View is <strong>not</strong> public because it is neither the default View nor visible from the default View.')|n}
								%endif
								<br />
								%if can_delete:
								${_('Because this View is not being used, you can delete it using the button at the bottom of the form.')}
								%else:
								${_('Because this View is being used, you cannot currently delete it.')}
								%endif
							</p>

							<p>${_('This view is available in the following languages: ')}</p>
							<ul>
								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<li>
									${lang.LanguageName}
									%if len(culture_order) > 1:
									<a class="btn btn-sm btn-alert-border padding-sm" href="${route_path('admin_view', action='delete_lang', _query=[('DM', domain.id), ('ViewType',ViewType), ('Culture', culture)])}">
										<span class="fa fa-remove" aria-hidden="true"></span>
										${_('Delete')}
									</a>
									%endif
								</li>
								%endfor
							</ul>

							%if missing_cultures:
							<p>
								${_('Add language to this view:')}
								${', '.join('<a href="%s">%s</a>' % (route_path('admin_view', action='add_lang', _query=[('DM', domain.id), ('ViewType', ViewType), ('Culture', x)]), culture_map[x].LanguageName) for x in missing_cultures)|n}
							</p>
							%endif
						</td>
					</tr>
					${self.makeMgmtInfo(view)}
					%endif

					<tr>
						${self.fieldLabelCell(None,_('Owner'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.Owner")}
								${renderer.checkbox("item.Owner", request.user.Agency, label=" " + _('Setup of this item is exclusively controlled by the Agency: ') + (usage.ReadOnlyViewOwner or request.user.Agency))}
							</div>
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Name'),
						_('Unique name identifying this View.'),True)}
						<td class="field-data-cell">
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".ViewName",_('Name') + _(': ') + lang.LanguageName)}
								${self.requiredFieldMarker()}
								${renderer.errorlist("descriptions." + lang.FormCulture + ".ViewName")}
								${renderer.text("descriptions." + lang.FormCulture + ".ViewName", maxlength=100, class_="form-control")}
							</div>
							%endfor
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Notes'),
						_('A description of the purpose of the view.'),False)}
						<td class="field-data-cell">
							<p>
								<span class="Alert"><span class=" glyphicon glyphicon-star" aria-hidden="true"></span>${_('Important')}</span>${_(': ')}
								${_('Use notes to explain the who will use the View and for what purpose, to prevent future security issues or orphaned Views.')}
							</p>
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".Notes",_('Notes') + _(': ') + lang.LanguageName)}
								${renderer.errorlist("descriptions." + lang.FormCulture + ".Notes")}
								${renderer.textarea("descriptions." + lang.FormCulture + ".Notes", rows=const.TEXTAREA_ROWS_SHORT, class_="form-control")}
							</div>
							%endfor
						</td>
					</tr>
					<tr>
						${self.fieldLabelCell(None,_('Title'),_('The upper title apppearing above the page title in the header (when not using a custom header).'),False)}
						<td class="field-data-cell">
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".Title",_('Title') + _(': ') + lang.LanguageName)}
								${renderer.errorlist("descriptions." + lang.FormCulture + ".Title")}
								${renderer.text("descriptions." + lang.FormCulture + ".Title", maxlength=255, class_="form-control")}
							</div>
							%endfor
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Other Views'),
						_('In the default public View, determines which other Views are public. If the default View of a user, indicates the other Views that user may also access. Do not select any values if the View is neither the default public View nor the default View for a logged-in user.'),False)}
						<td class="field-data-cell">
							%if view_descs:
							%if usage.IsDefaultView:
							<p class="Alert">${_('Warning: this is the Default View. Any View selected below will immediately become publicly available.')}</p>
							%endif
							<p><strong>${_('Identify the other Views this View can see:')}</strong></p>
							<div class="row">
								%for rview in view_descs:
								<div class="col-md-6 col-lg-4 padding-sm-top">${renderer.ms_checkbox('Views', str(rview.ViewType), label=rview.ViewName, id='view_' + str(rview.ViewType))}</div>
								%endfor
							</div>
							%else:
							<em>${_('No other Views available')}</em>
							%endif
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Alert Column'),
						_('The alert column is located on the left side of the results list and is used to display alert information to the user, e.g. the record is non-public, deleted, has comments, or has feedback. The exact kinds of alerts the user sees will depend on the settings in their User Type.'),False)}
						<td class="field-data-cell">
							${renderer.errorlist("item.AlertColumn")}
							${renderer.checkbox("item.AlertColumn", label=_('Alert Column available'))}
						</td>
					</tr>

					%if domain.id == const.DM_CIC and dboptions.UseVOL:
					<tr>
						${self.fieldLabelCell(None,_('Volunteer'),
						_('When this setting is turned off, the software will not show the Volunteer menu link, the "V" alert in the alert column, any Volunteer-specific search criteria, or links to Volunteer activities from within the CIC Module.'),False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.VolunteerLink")}
								${renderer.checkbox("item.VolunteerLink", label=_('Show links to and information about the Volunteer Module'))}
							</div>
						</td>
					</tr>
					%endif

					<tr>
						${self.fieldLabelCell(None,_('Available Records'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.CanSeeDeleted")}
								${renderer.checkbox("item.CanSeeDeleted", label=_('Deleted Records are visible'))}
							</div>
							<div class="checkbox">
								${renderer.errorlist("item.CanSeeNonPublic")}
								${renderer.checkbox("item.CanSeeNonPublic", label=_('Non-public Records are visible'))}
							</div>

							%if domain.id == const.DM_VOL:
							<div class="checkbox">
								${renderer.errorlist("item.CanSeeExpired")}
								${renderer.checkbox("item.CanSeeExpired", label=_('Expired Records are visible'))}
							</div>

							<div class="form-group">
								${renderer.label('item.CommunitySetID', _('Only include records in the Community Set:'))} ${self.requiredFieldMarker()}
								${renderer.errorlist("item.CommunitySetID")}
								${renderer.select("item.CommunitySetID", community_sets, class_="form-control")}
							</div>
							%endif

							%if domain.id == const.DM_CIC:
							<div class="checkbox">
								${renderer.errorlist("item.RespectPrivacyProfile")}
								${renderer.checkbox("item.RespectPrivacyProfile", label=_('Respect Privacy Profiles'))}
								<span class="glyphicon glyphicon-question-sign" title="${_('Private fields will be hidden for records using a Privacy Profile')}"></span>
							</div>

							<div class="form-group">
								${renderer.label('item.PB_ID', _('Only include records in the Publication:'))}
								${renderer.errorlist("item.PB_ID")}
								${renderer.select("item.PB_ID", options=[('','')] + publication_descs, class_="form-control")}
							</div>
							%endif

							<div class="form-inline form-group">
								${renderer.errorlist("item.HidePastDueBy")}
								${h(_('Hide Records Past Due by %s or more days')) % renderer.text("item.HidePastDueBy", maxlength=3, title=_('Maximum Days Overdue'), class_="form-control")}
								${self.helpBubble(_('Hide Records Past Due by'),_("Calculated using the difference between today's date and the Update Schedule field. All records with empty Update Schedules are also excluded if you specify a number here."))}
								<div class="Alert">${_("Hide Past Due value should not be set in Views used for updating records.")}</div>
							</div>
						</td>
					</tr>

					%if domain.id == const.DM_CIC and dboptions.UseCIC:
					<tr>
						<td class="field-label-cell" rowspan="3">${_('Publications')}</td>
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.UsePubNamesOnly")}
								${renderer.checkbox("item.UsePubNamesOnly", label=_('Use Friendly Publication names only (when available)'))}
							</div>
						</td>
					</tr>
					<tr>
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.LimitedView")}
								${renderer.checkbox("item.LimitedView", label=_('Limited View: Only allow viewing / management of this View\'s Publication'))}
								${self.helpBubble(None,_('Applies only to Views where the records available in the View are already limited to a specific Publication'))}
							</div>

							<p>
								${_('If this is <strong>not</strong> a Limited View, which publications are available in the Basic / Advanced Search:')|n}
								<br>${renderer.errorlist("item.CanSeeNonPublicPub")}
								${renderer.radio("item.CanSeeNonPublicPub", 'A', label=_('Display all Publications'))}
								<br>${renderer.radio("item.CanSeeNonPublicPub", 'P', label=_('Only display public Publications'))}
								<br>${renderer.radio("item.CanSeeNonPublicPub", 'S', label=_('Only display the Publications below:'))}
							</p>
							<div style="margin-left:10px;">
								<div id="PUB_existing_add_container">
									%for pub in publication_descs:
									%if str(pub[0]) in publications:
									${renderer.ms_checkbox("PUB_ID", str(pub[0]), label=pub[1])}<br>
									%endif
									%endfor
								</div>
								<div class="form-group form-inline" id="PUB_new_input_container">
									<label for="NEW_PUB">${_('Name')}</label>
									<input type="text" id="NEW_PUB" maxlength="200" class="form-control">
									<button type="button" id="add_PUB">${_('Add')}</button>
									<br><a href="javascript:openWinL('${request.passvars.route_path('cic_publication_index', _query=[('pop','on')])}','pbWin')">${_('Publications List')}</a>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<td class="field-data-cell">
							${_('Automatically add the following publications to records created in this view:')|n}
							<div style="margin-left:10px;">
								<div id="ADDPUB_existing_add_container">
									%for pub in publication_descs:
									%if str(pub[0]) in auto_add_pubs:
									${renderer.ms_checkbox("ADDPUB_ID", str(pub[0]), label=pub[1])}<br>
									%endif
									%endfor
								</div>
								<div class="form-group form-inline" id="ADDPUB_new_input_container">
									<label for="NEW_ADDPUB">${_('Name')}</label>
									<input type="text" id="NEW_ADDPUB" maxlength="200" class="form-control">
									<button type="button" id="add_ADDPUB">${_('Add')}</button>
									<br><a href="javascript:openWinL('${request.passvars.route_path('cic_publication_index', _query=[('pop','on')])}','pbWin')">${_('Publications List')}</a>
								</div>
							</div>
						</td>
					</tr>
					%endif

					%if domain.id == const.DM_VOL and dboptions.UseVolunteerProfiles:
					<tr>
						${self.fieldLabelCell(None,_('Volunteer Profiles'),None,False)}
						<td class="field-data-cell">
							${renderer.errorlist("item.UseProfilesView")}
							${renderer.checkbox("item.UseProfilesView", label=_('Volunteer Profile links / searches are available in this View '))}
							<br><span class="Alert">${_('Note that Volunteer Profiles links and search results only apply to public users and publicly-available Views.')}</span>
						</td>
					</tr>
					%endif

					<tr>
						${self.fieldLabelCell(None,_('Google Translate Widget'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.GoogleTranslateWidget")}
								${renderer.checkbox('item.GoogleTranslateWidget', label=_('Show Google Translate Widget on Search and Details pages.'))}
							</div>
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".GoogleTranslateDisclaimer", _('Disclaimer') + _(': ') + lang.LanguageName)}
								<div class="SmallNote">${_('Maximum 1000 characters. HTML is allowed.')}</div>
								${renderer.errorlist("descriptions." + lang.FormCulture + ".GoogleTranslateDisclaimer")}
								${renderer.textarea("descriptions." + lang.FormCulture + ".GoogleTranslateDisclaimer", maxlength=1000, class_="form-control")}
							</div>
							%endfor
						</td>
					</tr>
					<tr>
						<td class="field-label-cell">${renderer.checkbox('HasLabelOverrides', label=_('Custom Label for "Organization"') if domain.id==const.DM_CIC else _('Custom Labels'))}</td>
						<td class="field-data-cell">
							<div id="override-instructions">&larr; ${_('Select the checkbox to view options.')}</div>
							<div id="override-labels" style="${'display: none' if not renderer.value('HasLabelOverrides') else ''}">
								%if domain.id == const.DM_CIC:
								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".SearchTitleOverride", _('Search Title') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Search Title'),_('Override the title for the main menu search page. Leave blank for default or title set through page titles setuparea.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".SearchTitleOverride")}
									${renderer.text("descriptions." + lang.FormCulture + ".SearchTitleOverride", maxlength=255, class_="form-control")}
								</div>
								%endfor
								<hr>

								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".OrganizationNames", _('Organization Name(s)') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Organization Name(s)'),_('Override "Organization Name(s)" on the main search page. Leave blank for default.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".OrganizationNames")}
									${renderer.text("descriptions." + lang.FormCulture + ".OrganizationNames", maxlength=255, class_="form-control")}
								</div>
								%endfor
								<hr>

								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".OrganizationsWithWWW", _('Organizations with Website') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Organizations with Website'),_('Override "Organizations with Website" on the main search page. Leave blank for default.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".OrganizationsWithWWW")}
									${renderer.text("descriptions." + lang.FormCulture + ".OrganizationsWithWWW", maxlength=255, class_="form-control")}
								</div>
								%endfor
								<hr>

								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".OrganizationsWithVolOps", _('Organizations With Volunteer Opportunities') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Organizations With Volunteer Opportunities'),_('Override "Organizations with Volunteer Opportunities" on the main search page. Leave blank for default.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".OrganizationsWithVolOps")}
									${renderer.text("descriptions." + lang.FormCulture + ".OrganizationsWithVolOps", maxlength=255, class_="form-control")}
								</div>
								%endfor
								<hr>

								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".FindAnOrgBy", _('Find an Organization or Program by type of service:') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Find an Organization or Program by type of service:'),_('Override "Find an Organization or Program by type of service:" on the main search page. Leave blank for default.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".FindAnOrgBy")}
									${renderer.text("descriptions." + lang.FormCulture + ".FindAnOrgBy", maxlength=255, class_="form-control")}
								</div>
								%endfor
								<hr>

								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".BrowseByOrg", _('Browse By Organization') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Browse By Organization'),_('Override "Browse by Organization" on the main search page and the Browse by Organization page. Leave blank for default.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".BrowseByOrg")}
									${renderer.text("descriptions." + lang.FormCulture + ".BrowseByOrg", maxlength=255, class_="form-control")}
								</div>
								%endfor
								<hr>

								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".ViewProgramsAndServices", _('View Programs and Services') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('View Programs and Services'),_('Override "View Programs and Services" on the public taxonomy search page. Leave blank for default.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".ViewProgramsAndServices")}
									${renderer.text("descriptions." + lang.FormCulture + ".ViewProgramsAndServices", maxlength=255, class_="form-control")}
								</div>
								%endfor
								<hr>

								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".ClickToViewDetails", _('Click on the organization / program name to view the full details of the record') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Click on the organization / program name to view the full details of the record'),_('Override "Click on the organization / program name to view the full details of the record" on search results pages. Leave blank for default.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".ClickToViewDetails")}
									${renderer.text("descriptions." + lang.FormCulture + ".ClickToViewDetails", maxlength=255, class_="form-control")}
								</div>
								%endfor
								<hr>

								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".OrgProgramNames", _('Organization / Program Name(s)') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Organization / Program Name(s)'),_('Override "Organization / Program Name(s)" on search result pages. Leave blank for default.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".OrgProgramNames")}
									${renderer.text("descriptions." + lang.FormCulture + ".OrgProgramNames", maxlength=255, class_="form-control")}
								</div>
								%endfor
								<hr>

								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".Organization", _('Organization') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Organization'),_('Override "Organization" on search result pages. Leave blank for default.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".Organization")}
									${renderer.text("descriptions." + lang.FormCulture + ".Organization", maxlength=255, class_="form-control")}
								</div>
								%endfor
								<hr>

								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".MultipleOrgWithSimilarMap", _('Multiple organizations with a similar map location') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Multiple organizations with a similar map location'),_('Override "Multiple organizations with a similar map location" on search result pages. Leave blank for default.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".MultipleOrgWithSimilarMap")}
									${renderer.text("descriptions." + lang.FormCulture + ".MultipleOrgWithSimilarMap", maxlength=255, class_="form-control")}
								</div>
								%endfor

								%for level in range(1, 4):

								<hr>
								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".OrgLevel%dName" % level, _('Org Level %d') % level + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Org Level %d') % level,_('Override the configured display name for ORG_LEVEL_%d  for public pages. Leave blank for value configured in Field Display setup area.') % level)}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".OrgLevel%dName" % level)}
									${renderer.text("descriptions." + lang.FormCulture + ".OrgLevel%dName" % level, maxlength=255, class_="form-control")}
								</div>
								%endfor

								%endfor
								%else:
								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group">
									${renderer.label("descriptions." + lang.FormCulture + ".SearchPromptOverride", _('Looking for Volunteer Opportunities[IN_COMMUNITY]?') + _(': ') + lang.LanguageName)}
									${self.helpBubble(_('Looking for Volunteer Opportunities[IN_COMMUNITY]?'),_('Override "Looking for Volunteer Opportunities[IN_COMMUNITY]?" on main menu page. Leave blank for default. [IN_COMMUNITY] will be replaced with "in Community Set Area Served Name" if applicable.'))}
									${renderer.errorlist("descriptions." + lang.FormCulture + ".SearchPromptOverride")}
									${renderer.text("descriptions." + lang.FormCulture + ".SearchPromptOverride", maxlength=255, class_="form-control")}
								</div>
								%endfor
								%endif
							</div>
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('My List'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.MyList")}
								${renderer.checkbox("item.MyList", label=_('Enable the "My List" feature'))}
							</div>
						</td>
					</tr>
				</table>
			</div>
		</div>

		<div class="panel panel-default max-width-lg">
			<div class="panel-heading">
				<a name="updating"></a>
				<h2>${_('Record Updating and Feedback')}</h2>
			</div>
			<div class="panel-body no-padding">
				<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
					<tr>
						${self.fieldLabelCell(None,_('Inclusion Policy'),
						_('The Record Inclusion Policy that will be presented to users who are attempting to suggest a new record in this View.'),False)}
						<td class="field-data-cell">
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".InclusionPolicy",_('Inclusion Policy') + _(': ') + lang.LanguageName)}
								<% inc_policy = [tuple(x) for x in inclusion_policies if x.LangID==lang.LangID] %>
								%if inc_policy:
								${renderer.errorlist("descriptions." + lang.FormCulture + ".InclusionPolicy")}
								${renderer.select("descriptions." + lang.FormCulture + ".InclusionPolicy", [('','')] + inc_policy, class_="form-control")}
								%else:
								<em>${_('There are no inclusion policies available.')}</em>
								%endif
							</div>
							%endfor
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Terms of Use'),
						_('Optional - the full website address to your privacy / data use policy. This will display in a new window linked from the Feedback / Suggestion form.'),False)}
						<td class="field-data-cell">
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".TermsOfUseURL",_('Terms of Use URL') + _(': ') + lang.LanguageName)}
								${renderer.errorlist("descriptions." + lang.FormCulture + ".TermsOfUseURL")}
								${renderer.proto_url("descriptions." + lang.FormCulture + ".TermsOfUseURL", class_="form-control")}
							</div>
							%endfor

							<div class="checkbox">
								${renderer.errorlist("item.DataUseAuth")}
								${renderer.checkbox("item.DataUseAuth", label=_("Show 'Data Use Authorization' checklist at the bottom of the Feedback / Suggestion form."))}
							</div>

							<div class="checkbox">
								${renderer.errorlist("item.DataUseAuthPhone")}
								${renderer.checkbox("item.DataUseAuthPhone", label=_("'Data Use Authorization' includes authorization for phone / in-person inquiries."))}
							</div>
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Other Languages'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.ViewOtherLangs")}
								${renderer.checkbox("item.ViewOtherLangs", label=_('Allow users to view / create records in any record languages that are configured in this database'))}
							</div>
						</td>
					</tr>

					%if domain.id == const.DM_CIC and dboptions.UseCIC:
					<tr>
						${self.fieldLabelCell(None,_('Child Care Resource Fields'),None,False)}
						<td class="field-data-cell">
							${renderer.errorlist("item.CCRFields")}
							${_('Select when to include selected Child Care Resources fields on record update forms:')}
							<div class="radio">
								${renderer.radio("item.CCRFields", value="P", label=_('Show a prompt for records not already designated as Child Care Resources'))}
							</div>
							<div class="radio">
								${renderer.radio("item.CCRFields", value="A", label=_('Include selected Child Care Resources fields for all records'))}
							</div>
						</td>
					</tr>
					%endif

					<tr>
						${self.fieldLabelCell(None,_('Feedback Records'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.AllowFeedbackNotInView")}
								${renderer.checkbox("item.AllowFeedbackNotInView", label=Markup(_('Allow submission of feedback by the public for records not normally in this View.')))}
								${self.helpBubble(None,_('This option must be activated to receive feedback on records that cannot normally be viewed (e.g. as non-public or deleted records in a public site). An alternative may be to use the feedback password feature for sensitive records. Note that a special key, sent out with the Update Email Request, is required to provide feedback for records not in the View.'))}
								<div class="Alert">${_('Use only for Views in which you actively solicit feedback via Update Email Request (does not apply to logged-in Views).')}</div>
							</div>
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell("item.AssignSuggestionsTo",_('Feedback Owner'),
						_('Optional: all new record suggestions that originate in this View will be automatically assigned to the selected Agency if given. These new record suggestions can still be reassigned to another Agency from the main Feedback page by a user with the appropriate permissions.'),False)}
						<td class="field-data-cell">
							<div class="form-inline form-inline-always form-group">
								${renderer.errorlist("item.AssignSuggestionsTo")}
								${renderer.select("item.AssignSuggestionsTo", ['']+[x[1] for x in agencies], class_="form-control")}
							</div>
						</td>
					</tr>

					%if domain.id == const.DM_CIC:
					<tr>
						<td class="field-label-cell" rowspan="2">${_('Feedback Notifications')}</td>
						<td class="field-data-cell">
							<div class="form-group">
								${renderer.label("item.AlsoNotify",_('Also Notify Email'))}
								${self.helpBubble(None,_('Optional - specify an Also Notify Email address that will receive notification of feedback submissions in this View.'))}
								${renderer.errorlist("item.AlsoNotify")}
								${renderer.email("item.AlsoNotify", class_="form-control")}
							</div>
							${_('This is <strong>in addition</strong> to the regular notification to the record owner Agency, and is intended when a 3rd party wants notification of suggested changes within this View.')|n}
						</td>
					</tr>
					<tr>
						<td>
							<div class="checkbox">
								${renderer.errorlist("item.NoProcessNotify")}
								${renderer.checkbox("item.NoProcessNotify", label=_('Do not notify the feedback submitter after processing their feedback.'))}
								${self.helpBubble(None,_('If an Also Notify Email has been specified, this party will still receive notification that the feedback was processed.'))}
							</div>
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Feedback Link'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.UseSubmitChangesTo")}
								${renderer.checkbox("item.UseSubmitChangesTo", label=Markup(_('Use the <em>Submit Changes To</em> field to create the Feedback link (if available).')))}
							</div>
						</td>
					</tr>
					%endif

					<tr>
						${self.fieldLabelCell(None,_('Feedback Message'),None,True)}
						<td class="field-data-cell">
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".FeedbackBlurb",_('Feedback Message') + _(': ') + lang.LanguageName)}
								${renderer.errorlist("descriptions." + lang.FormCulture + ".FeedbackBlurb")}
								<div class="SmallNote">${_('Maximum 2000 characters. HTML is allowed.')}</div>
								${renderer.textarea("descriptions." + lang.FormCulture + ".FeedbackBlurb", class_="form-control")}
							</div>
							%endfor
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Manage Fields'),
						_('The full field management area is available at the bottom of this page.'),False)}
						<td class="field-data-cell">
							<ul>
								<li><a href="javascript:openWinL('${makeLinkAdmin('setup_view_edit_fields.asp', dict(FType='U', DM=domain.id, ViewType=ViewType))}','fieldEdit')">${_('Update Fields (New Window)')}</a></li>
								<li><a href="javascript:openWinL('${makeLinkAdmin('setup_view_edit_fields.asp', dict(FType='F', DM=domain.id, ViewType=ViewType))}','fieldEdit')">${_('Feedback Fields (New Window)')}</a></li>
								%if domain.id == const.DM_CIC and dboptions.UseCIC:
								<li><a href="javascript:openWinL('${makeLinkAdmin('setup_view_edit_fields.asp', dict(FType='M', DM=domain.id, ViewType=ViewType))}','fieldEdit')">${_('Mail Form Fields (New Window)')}</a></li>
								%endif
							</ul>
						</td>
					</tr>
				</table>
			</div>
		</div>

		<div class="panel panel-default max-width-lg">
			<div class="panel-heading">
				<a name="details"></a>
				<h2>${_('Record Details')}</h2>
			</div>
			<div class="panel-body no-padding">
				<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
					<tr>
						${self.fieldLabelCell(None,_('Data Management Fields'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.LastModifiedDate")}
								${renderer.checkbox("item.LastModifiedDate", label=_('Last Modified'))}
								${self.helpBubble(None,_('Include the Last Modified Date in the Header of the Record Details page.'))}
							</div>
							<div class="checkbox">
								${renderer.errorlist("item.DataMgmtFields")}
								${renderer.checkbox("item.DataMgmtFields", label=_('Show extra Data Management Fields'))}
								${self.helpBubble(None,_('If selected, two additional rows of control/management fields appear at the top of the record on detail pages, including: Created Date, Deletion Date, Update Schedule, Record Owner, Last Email Update.'))}
							</div>
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Social Media'),
						_('If selected, the "Add This" service will be used to allow users to share the record using various social media sites. Note that this is different from the Social Media fields about the record that are added via the regular field setup for the Record Details page.'),False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.SocialMediaShare")}
								${renderer.checkbox("item.SocialMediaShare", label=_('Show Social Media "Share" buttons in the Record Details Header'))}
							</div>
						</td>
					</tr>

					%if domain.id == const.DM_CIC:
					<tr>
						${self.fieldLabelCell(None,_('Link Org Levels'),
						_('In Organization / Program record detail pages, levels of the organization name are linked to a new search if records are found matching levels 1, 1-2, 1-3, or 1-4.'),False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.LinkOrgLevels")}
								${renderer.checkbox("item.LinkOrgLevels", label=_('Link Organization Levels on Record Details pages'))}
							</div>
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Related Records Sidebar'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.ShowRecordDetailsSidebar")}
								${renderer.checkbox("item.ShowRecordDetailsSidebar", label=_('Use the Related Records Sidebar on the Record Details page (available for Agency-Site-Service classified records only).'))}
							</div>
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('PDF Output'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.AllowPDF")}
								${renderer.checkbox("item.AllowPDF", label=_('Allow PDF output'))}
							</div>
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".PDFBottomMessage", _('Footer Message') + _(': ') + lang.LanguageName)}
								${self.helpBubble(None,_('The text appearing at the bottom of each page of a PDF rendered in the view (such as details page PDF). Be thoughtful and keep it short - remember that this will be at the bottom of every page of the PDF. If you have a lot of information you want to include here, consider creating a webpage with the information and linking to it instead.'))}
								<div class="SmallNote">${_('Maximum 8000 characters. HTML is allowed.')}</div>
								${renderer.errorlist("descriptions." + lang.FormCulture + ".PDFBottomMessage")}
								${renderer.textarea("descriptions." + lang.FormCulture + ".PDFBottomMessage", maxlength=8000, class_="form-control")}
							</div>
							%endfor
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-inline form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".PDFBottomMargin", _('Footer Space') + _(': ')  + lang.LanguageName)}
								${self.helpBubble(None,_('Amount of space to allow for the PDF Footer Message (e.g. 2cm). Ensure that you have allocated the appropriate amount of space by testing the display after setting this value.'))}
								${renderer.errorlist("descriptions." + lang.FormCulture + ".PDFBottomMargin")}
								${renderer.text("descriptions." + lang.FormCulture + ".PDFBottomMargin", maxlength=20, class_="form-control")}
							</div>
							%endfor
						</td>
					</tr>
					%else:
					<tr>
						${self.fieldLabelCell(None,_('Suggest Opportunity'),
						_('If selected, the "Suggest a Volunteer Opportunity" link will be available from within all organization/program records.'),False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.SuggestOpLink")}
								${renderer.checkbox("item.SuggestOpLink", label=_('Show Suggest Opportunity link'))}
							</div>
						</td>
					</tr>
					%endif

					<tr>
						${self.fieldLabelCell(None,_('Manage Fields'),
						_('The full field management area is available at the bottom of this page.'),False)}
						<td class="field-data-cell">
							<a href="javascript:openWinL('${makeLinkAdmin('setup_view_edit_fields.asp', dict(FType='D', DM=domain.id, ViewType=ViewType))}','fieldEdit')">${_('Details Fields (New Window)')}</a>
						</td>
					</tr>
				</table>
			</div>
		</div>

		<div class="panel panel-default max-width-lg">
			<div class="panel-heading">
				<a name="searching"></a>
				<h2>${_('Searching')}</h2>
			</div>
			<div class="panel-body no-padding">
				<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
					<tr>
						${self.fieldLabelCell(None,_('Search Tips'),
						_('The Search Tips page content explaining the search options available from the main search page (link provided on the main search page).'),False)}
						<td class="field-data-cell">
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".SearchTips",_('Search Tips') + _(': ') + lang.LanguageName)}
								<% srch_tips = [tuple(x) for x in search_tips if x.LangID==lang.LangID] %>
								%if srch_tips:
								${renderer.errorlist("descriptions." + lang.FormCulture + ".SearchTips")}
								${renderer.select("descriptions." + lang.FormCulture + ".SearchTips", [('','')] + srch_tips, class_="form-control")}
								%else:
								<em>${_('There are no search tips available.')}</em>
								%endif
							</div>
							%endfor
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Basic Search'),None,False)}
						<td class="field-data-cell">
							${_('Include the following search types on the main page:')}
							<div class="row">
								<div class="col-sm-6">
									<div class="checkbox">
										${renderer.errorlist("item.BSrchKeywords")}
										${renderer.checkbox("item.BSrchKeywords", label=_('Keywords'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchAutoComplete")}
										${renderer.checkbox("item.BSrchAutoComplete", label=_('Keyword Auto-Complete'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchBrowseByOrg")}
										${renderer.checkbox("item.BSrchBrowseByOrg", label=_('Browse by Organization'))}
									</div>
									%if domain.id == const.DM_CIC:
									<div class="checkbox">
										${renderer.errorlist("item.BSrchNUM")}
										${renderer.checkbox("item.BSrchNUM", label=_('Record #'))}
									</div>
									%if dboptions.UseVOL:
									<div class="checkbox">
										${renderer.errorlist("item.BSrchVOL")}
										${renderer.checkbox("item.BSrchVOL", label=_('Organizations with Volunteer Opportunities'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchAges")}
										${renderer.checkbox("item.BSrchAges", label=_('Ages'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchWWW")}
										${renderer.checkbox("item.BSrchWWW", label=_('Organizations with Website'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchOCG")}
										${renderer.checkbox("item.BSrchOCG", label=_('OCG #'))}
									</div>
									%endif
									%else:
									<div class="checkbox">
										${renderer.errorlist("item.BSrchBrowseByInterest")}
										${renderer.checkbox("item.BSrchBrowseByInterest", label=_('Browse By Interest'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchBrowseAll")}
										${renderer.checkbox("item.BSrchBrowseAll", label=_('Browse All Organizations or Interests'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchWhatsNew")}
										${renderer.checkbox("item.BSrchWhatsNew", label=_('What\'s New'))}
									</div>
									%endif
								</div>
								<div class="col-sm-6">
									%if domain.id == const.DM_CIC:
									<div class="checkbox">
										${renderer.errorlist("item.BSrchVacancy")}
										${renderer.checkbox("item.BSrchVacancy", label=_('Availability'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchLanguage")}
										${renderer.checkbox("item.BSrchLanguage", label=_('Language of Service'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchNear2")}
										${renderer.checkbox("item.BSrchNear2", label=_('Within 2 KM'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchNear5")}
										${renderer.checkbox("item.BSrchNear5", label=_('Within 5 KM'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchNear10")}
										${renderer.checkbox("item.BSrchNear10", label=_('Within 10 KM'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchNear15")}
										${renderer.checkbox("item.BSrchNear15", label=_('Within 15 KM'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchNear25")}
										${renderer.checkbox("item.BSrchNear25", label=_('Within 25 KM'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchNear50")}
										${renderer.checkbox("item.BSrchNear50", label=_('Within 50 KM'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchNear100")}
										${renderer.checkbox("item.BSrchNear100", label=_('Within 100 KM'))}
									</div>
									%else:
									<div class="checkbox">
										${renderer.errorlist("item.BSrchStepByStep")}
										${renderer.checkbox("item.BSrchStepByStep", label=_('Step by Step'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchStudent")}
										${renderer.checkbox("item.BSrchStudent", label=_('Student Volunteers'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchCommunity")}
										${renderer.checkbox("item.BSrchCommunity", label=_('Communities'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchCommitmentLength")}
										${renderer.checkbox("item.BSrchCommitmentLength", label=_('Commitment Length'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.BSrchSuitableFor")}
										${renderer.checkbox("item.BSrchSuitableFor", label=_('Suitable For'))}
									</div>
									%endif
								</div>
							</div>

							<hr>

							%if domain.id == const.DM_CIC:
							<h4>${_('Quick List Setup')}</h4>
							<div class="form-horizontal">
								%for culture in culture_order:
								<% lang = culture_map[culture] %>
								<div class="form-group row">
									${renderer.label("descriptions." + lang.FormCulture + ".QuickListName", _('List Name (%s)') % lang.LanguageName, class_='control-label col-sm-3')}
									<div class="col-sm-9">
										${renderer.errorlist("descriptions." + lang.FormCulture + ".QuickListName")}
										${renderer.text("descriptions." + lang.FormCulture + ".QuickListName", maxlength=25, class_="form-control")}
									</div>
								</div>
								%endfor
								<div class="form-group row">
									${renderer.label('item.QuickListPubHeadings', _('Use Headings From'), class_='control-label col-sm-3')}
									<div class="col-sm-9">
										<span class="SmallNote">
											${_("Choose a Publication to have the Quick List display that Publication's Headings.")}
											${self.helpBubble(_('Use Headings From'),_("Choose a Publication to have the Quick List display that Publication's Headings.") + " " + _("By default, the Quick List displays the Publications for this View. If this is a Limited View, it will always use the Headings from this View's Publication. Non-public Headings will be hidden from the list if the View is set to hide non-public Publications."))}
										</span>
										${renderer.errorlist("item.QuickListPubHeadings")}
										${renderer.select("item.QuickListPubHeadings", options=[('','')] + pubs_with_headings, class_="form-control")}
									</div>
								</div>
								<div class="form-group row">
									${renderer.label('item.QuickListDropDown', _('List Type'), class_='control-label col-sm-3')}
									<div class="col-sm-9">
										${renderer.errorlist("item.QuickListDropDown")}
										${renderer.select("item.QuickListDropDown", [('1', _('Drop-Down List')),('2',_('Drop-Down List Per Group (Limited View)')),('0',_('Checkboxes'))], class_="form-control")}
									</div>
								</div>
								<div class="form-group row">
									${renderer.label('item.QuickListWrapAt', _('Wrap checkboxes at'), class_='control-label col-sm-3')}
									<div class="col-sm-9">
										${renderer.errorlist("item.QuickListWrapAt")}
										<div class="form-inline">
											${renderer.text("item.QuickListWrapAt", maxlength=1, class_="form-control")}
										</div>
									</div>
								</div>
								<div class="form-group row">
									<label class="control-label col-sm-3">
										${_('Checkboxes must match')}
									</label>
									<div class="col-sm-9">
										${renderer.errorlist("item.QuickListMatchAll")}
										${renderer.radio("item.QuickListMatchAll", 'ANY', label=_('Any selected values'))}
										<br>${renderer.radio("item.QuickListMatchAll", 'ALL', label=_('All selected values'))}
									</div>
								</div>
								<div class="form-group row">
									<label class="control-label col-sm-3">
										${_('Heading Groups')}
									</label>
									<div class="col-sm-9">
										${renderer.errorlist("item.QuickListSearchGroups")}
										${renderer.checkbox("item.QuickListSearchGroups", label=_('Make Heading Groups Searchable'))}
									</div>
								</div>
							</div>
							%endif

							<hr />
							<h4>${_('Tab Configuration (if using a tabbed search layout)')}</h4>
							<div class="form-horizontal">
								<div class="form-group row">
									${renderer.label('item.BSrchDefaultTab', _('Default Selected Tab (count from left starting at 0)'), class_='control-label col-sm-6')}
									<div class="col-sm-6 form-inline">
										${renderer.errorlist("item.BSrchDefaultTab")}
										${renderer.text("item.BSrchDefaultTab", maxlength=2, class_="form-control")}
									</div>
								</div>
							</div>
						</td>
					</tr>

					%if domain.id == const.DM_CIC:
					<tr>
						${self.fieldLabelCell(None,_('Topic Search'),None,False)}
						<td class="field-data-cell">
							<a href="javascript:openWinL('${request.passvars.route_path('admin_view', action='topicsearches', _query=[('DM', domain.id), ('ViewType',ViewType)])}','fieldEdit')">${_('Topic Searches (New Window)')}</a>
						</td>
					</tr>

					<tr>
						${self.fieldLabelCell(None,_('Quick Search'),None,False)}
						<td class="field-data-cell">
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-horizontal">
								<div class="form-group row">
									${renderer.label("descriptions." + lang.FormCulture + ".QuickSearchTitle", _('Section Title') + _(': ') + lang.LanguageName, class_='control-label col-sm-3')}
									<div class="col-sm-9">
										${renderer.errorlist("descriptions." + lang.FormCulture + ".QuickSearchTitle")}
										${renderer.text("descriptions." + lang.FormCulture + ".QuickSearchTitle", maxlength=100, class_="form-control")}
									</div>
								</div>
								<div class="form-group row">
									${renderer.label("descriptions." + lang.FormCulture + ".QuickSearchGlyph", _('Icon') + _(': ') + lang.LanguageName, class_='control-label col-sm-3')}
									<div class="col-sm-9">
										${renderer.errorlist("descriptions." + lang.FormCulture + ".QuickSearchGlyph")}
										${renderer.text("descriptions." + lang.FormCulture + ".QuickSearchGlyph", maxlength=30, class_="form-control")}
									</div>
								</div>
							</div>
							%endfor
							<a href="javascript:openWinL('${request.passvars.route_path('admin_view', action='quicksearch', _query=[('DM', domain.id), ('ViewType',ViewType)])}','fieldEdit')">${_('Quick Searches (New Window)')}</a>
						</td>
					</tr>
					%endif

					%if domain.id == const.DM_VOL:
					<tr>
						${self.fieldLabelCell(None,_('Step-by-Step Search'),None,False)}
						<td class="field-data-cell">
							${renderer.errorlist("item.SSrchIndividualCount")}
							${renderer.checkbox("item.SSrchIndividualCount", label=_('Show count of individuals needed on "Search: Step 1" page'))}
							<br>
							${renderer.errorlist("item.SSrchDatesTimes")}
							${renderer.checkbox("item.SSrchDatesTimes", label=_('Dates and Times'))}
						</td>
					</tr>
					%endif

					<tr>
						${self.fieldLabelCell(None,_('Advanced Search'),None,False)}
						<td class="field-data-cell">
							<p>${_('Include the following search types on the Advanced Search page:')}</p>
							<div class="row">
								<div class="col-sm-6">
									<div class="checkbox">
										${renderer.errorlist("item.ASrchAges")}
										${renderer.checkbox("item.ASrchAges", label=_('Ages'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.ASrchBool")}
										${renderer.checkbox("item.ASrchBool", label=_('Boolean search option (SQL Server full-text keywords)'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.ASrchOwner")}
										${renderer.checkbox("item.ASrchOwner", label=_('Record Owner'))}
									</div>
									%if domain.id == const.DM_CIC:
									<div class="checkbox">
										${renderer.errorlist("item.ASrchAddress")}
										${renderer.checkbox("item.ASrchAddress", label=_('Site Address'))}
									</div>
									%if dboptions.UseVOL:
									<div class="checkbox">
										${renderer.errorlist("item.ASrchVOL")}
										${renderer.checkbox("item.ASrchVOL", label=_('Organizations with Volunteer Opportunities'))}
									</div>
									%endif
									%elif domain.id == const.DM_VOL:
									<div class="checkbox">
										${renderer.errorlist("item.ASrchDatesTimes")}
										${renderer.checkbox("item.ASrchDatesTimes", label=_('Dates and Times'))}
									</div>
									%endif
								</div>
								<div class="col-sm-6">
									<div class="checkbox">
										${renderer.errorlist("item.ASrchEmail")}
										${renderer.checkbox("item.ASrchEmail", label=_('Email'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.ASrchLastRequest")}
										${renderer.checkbox("item.ASrchLastRequest", label=_('Last Email Requesting Update'))}
									</div>
									%if domain.id == const.DM_CIC:
									<div class="checkbox">
										${renderer.errorlist("item.ASrchNear")}
										${renderer.checkbox("item.ASrchNear", label=_('Located Near'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.ASrchVacancy")}
										${renderer.checkbox("item.ASrchVacancy", label=_('Availability'))}
									</div>
									<div class="checkbox">
										${renderer.errorlist("item.ASrchEmployee")}
										${renderer.checkbox("item.ASrchEmployee", label=_('Number of Employees'))}
									</div>
									%elif domain.id == const.DM_VOL:
									<div class="checkbox">
										${renderer.errorlist("item.ASrchOSSD")}
										${renderer.checkbox("item.ASrchOSSD", label=_('Diploma Requirements'))}
									</div>
									%endif
								</div>
							</div>

							<p>
								${_('Include the following Checklist search types on the Advanced Search page:')}
							</p>
							
							${renderer.errorlist("AdvSearchCheckLists")}
							<div class="row">
								%for field_id, label in chk_field_descs:
								<div class="col-sm-6">
									${renderer.ms_checkbox("AdvSearchCheckLists", str(field_id), label=label)}
								</div>
								%endfor
							</div>
						</td>
					</tr>

					%if domain.id == const.DM_CIC and dboptions.UseCIC:
					<tr>
						${self.fieldLabelCell(None,_('Child Care Search'),None,False)}
						<td class="field-data-cell">
							${renderer.errorlist("item.CSrch")}
							${renderer.checkbox("item.CSrch", label=_('Link to Child Care Resource Advanced Search form'))}
							<p>
								${_('Include the following search types on the Child Care Search page:')}
								<br>${renderer.errorlist("item.CSrchSchoolEscort")}
								${renderer.checkbox("item.CSrchSchoolEscort", label=_('Escorts to / from School'))}
								<br>${renderer.errorlist("item.CSrchKeywords")}
								${renderer.checkbox("item.CSrchKeywords", label=_('Keywords'))}
								<br>${renderer.errorlist("item.CSrchLanguages")}
								${renderer.checkbox("item.CSrchLanguages", label=_('Languages'))}
								<br>${renderer.errorlist("item.CSrchNear")}
								${renderer.checkbox("item.CSrchNear", label=_('Located Near'))}
								<br>${renderer.errorlist("item.CSrchSchoolsInArea")}
								${renderer.checkbox("item.CSrchSchoolsInArea", label=_('Local Schools'))}
								<br>${renderer.errorlist("item.CSrchBusRoute")}
								${renderer.checkbox("item.CSrchBusRoute", label=_('On / Near Bus Route'))}
								<br>${renderer.errorlist("item.CSrchSpaceAvailable")}
								${renderer.checkbox("item.CSrchSpaceAvailable", label=_('Space Available'))}
								<br>${renderer.errorlist("item.CSrchSubsidy")}
								${renderer.checkbox("item.CSrchSubsidy", label=_('Subsidy'))}
								<br>${renderer.errorlist("item.CSrchTypeOfProgram")}
								${renderer.checkbox("item.CSrchTypeOfProgram", label=_('Type of Program'))}
							</p>
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<p>
								<strong>${renderer.label("descriptions." + lang.FormCulture + ".CSrchText", _('Child Care Search Description (%s):') % lang.LanguageName)}</strong>
								<br>${renderer.errorlist("descriptions." + lang.FormCulture + ".CSrchText")}
								${renderer.text("descriptions." + lang.FormCulture + ".CSrchText", maxlength=255, class_="form-control")}
							</p>
							%endfor
						</td>
					</tr>
					%endif
					<tr>
						<td class="field-label-cell" ${'rowspan="3" 'if domain.id == const.DM_CIC else ' ' |n}>${_(' Manage Search Communities')}</td>
						<td class="field-data-cell">
							${renderer.errorlist("item.CommSrchWrapAt")}
							<div class="form-inline form-inline-always">
								<label for="item.CommSrchWrapAt">${_('Wrap Communities on search page after:')}</label>
								${renderer.text("item.CommSrchWrapAt", maxlength=1, class_='form-control')}
							</div>

							%if domain.id == const.DM_CIC:
							<br>${renderer.errorlist("item.CommSrchDropDown")}
							${renderer.checkbox("item.CommSrchDropDown", label=_('Display Communities as drop-down list'))}
							<br>${renderer.errorlist("item.OtherCommunity")}
							${renderer.checkbox("item.OtherCommunity", label=_('"Other Community" search box is available'))}
							%endif
						</td>
					</tr>

					%if domain.id == const.DM_CIC:
					<tr>
						<td class="field-data-cell">
							${renderer.errorlist("item.SrchCommunityDefault")}
							${_('Default to')}
							${renderer.radio("item.SrchCommunityDefault", value='L', label=_('Located in Community'))}
							${renderer.radio("item.SrchCommunityDefault", value='S', label=_('Serving Community'))}
						</td>
					</tr>
					<tr>
						<td class="field-data-cell">
							<a href="javascript:openWinL('${makeLinkAdmin('setup_view_edit_comms.asp', dict(ViewType=ViewType, DM=domain.id))}','commEdit')">${_('Manage Search Communities (New Window)')}</a>
						</td>
					</tr>
					%endif # CIC

					<tr>
						<td class="field-label-cell" rowspan="${5 if domain.id == const.DM_CIC and dboptions.UseCIC else 2}">${_('Search Results')}</td>
						<td class="field-data-cell">
							${_('Use the form below to set default display options for this View for users that do not have a login, or have not set any display options for their login.')}<br>
							${display_options(for_view=True)}
						</td>
					</tr>
					<tr>
						<td class="field-data-cell">
							${renderer.errorlist("item.PrintVersionResults")}
							${renderer.checkbox("item.PrintVersionResults", label=_('Print Version of search results is available (please select a Print Template above)'))}
						</td>
					</tr>
					%if domain.id == const.DM_CIC and dboptions.UseCIC:
					<tr>
						<td class="field-data-cell">
							${renderer.errorlist("item.MapSearchResults")}
							${renderer.checkbox("item.MapSearchResults", label=_('Map search results with Google Maps'))}
						</td>
					</tr>
					<tr>
						<td class="field-data-cell">
							${renderer.errorlist("item.AutoMapSearchResults")}
							${renderer.checkbox("item.AutoMapSearchResults", label=_('Show Map on search results page by default'))}
						</td>
					</tr>
					<tr>
						<td class="field-data-cell">
							<h4>${_('Facet Search Results')}</h4>
							${renderer.errorlist("item.RefineField1")}
							${renderer.select("item.RefineField1", options=[('','')] + facet_field_descs, class_="form-control")}
							${renderer.errorlist("item.RefineField2")}
							${renderer.select("item.RefineField2", options=[('','')] + facet_field_descs, class_="form-control")}
							${renderer.errorlist("item.RefineField3")}
							${renderer.select("item.RefineField3", options=[('','')] + facet_field_descs, class_="form-control")}
							${renderer.errorlist("item.RefineField4")}
							${renderer.select("item.RefineField4", options=[('','')] + facet_field_descs, class_="form-control")}
						</td>
					</tr>
					<tr>
						${self.fieldLabelCell('item.ResultsPageSize',_('Search Results per Page'),
						_('Optional: Setting this option will limit results returned to the set number of results. Leave blank for no limit. Minimum value is 100, maximum value is 9999.'),False)}
						<td class="field-data-cell">
							${renderer.errorlist("item.ResultsPageSize")}
							<div class="form-inline form-inline-always">
								${renderer.text("item.ResultsPageSize", maxlength=4, class_='form-control')}
							</div>
						</td>
					</tr>
					%endif

					<tr>
						${self.fieldLabelCell(None,_('No Results Message'),
						_('A message printed to the user if no search results are returned or a record cannot be found.'),False)}
						<td class="field-data-cell">
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".NoResultsMsg", _('No Results Message') + _(': ') + lang.LanguageName)}
								${renderer.errorlist("descriptions." + lang.FormCulture + ".NoResultsMsg")}
								<div class="SmallNote">${_('Maximum 2000 characters. HTML is allowed.')}</div>
								${renderer.textarea("descriptions." + lang.FormCulture + ".NoResultsMsg", maxlength=2000, class_="form-control")}
							</div>
							%endfor
						</td>
					</tr>
				</table>
			</div>
		</div>

		<div class="panel panel-default max-width-lg">
			<div class="panel-heading">
				<a name="template"></a>
				<h2>${_('Template and Layout Options')}</h2>
			</div>
			<div class="panel-body no-padding">
				<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
					<tr>
						${self.fieldLabelCell(None,_('Template'),None,False)}
						<td class="field-data-cell">
							<div class="form-group">
								${renderer.label("item.Template", _('Main Template'))}
								${self.requiredFieldMarker()}
								${renderer.errorlist("item.Template")}
								${renderer.select("item.Template", templates, class_="form-control")}
							</div>
							<div class="form-group">
								${renderer.label("item.PrintTemplate", _('Print Template'))}
								${renderer.errorlist("item.PrintTemplate")}
								${renderer.select("item.PrintTemplate", [('','')] + templates, class_="form-control")}
							</div>
						</td>
					</tr>

					%if print_profiles:
					<tr>
						${self.fieldLabelCell('item.DefaultPrintProfile',_('Default Print Profile'),None,False)}
						<td class="field-data-cell">
							<div class="form-group">
								${renderer.errorlist("item.DefaultPrintProfile")}
								${renderer.select("item.DefaultPrintProfile", [('','')] + print_profiles, class_="form-control")}
								<div class="SmallNote">${_('Public Print Profiles denoted by *.')}</div>
							</div>
						</td>
					</tr>
					%endif
					<tr>
						${self.fieldLabelCell(None,_('Tag Line'),
						_('A slogan or tag line that can be added to some Header Layouts.'),False)}
						<td class="field-data-cell">
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".TagLine", _('Tag Line') + _(': ') + lang.LanguageName)}
								${renderer.errorlist("descriptions." + lang.FormCulture + ".TagLine")}
								${renderer.text("descriptions." + lang.FormCulture + ".TagLine", maxlength=300, class_="form-control")}
							</div>
							%endfor
						</td>
					</tr>

					%if domain.id == const.DM_VOL:

					<tr>
						${self.fieldLabelCell(None,_('Spotlight Opportunity'),
						_('A valid record number will show the selected Opportunity. Any other value selects a random Opportunity.'),False)}
						<td class="field-data-cell">
							%for culture in culture_order:
							<% lang = culture_map[culture] %>
							<div class="form-inline form-group">
								${renderer.label("descriptions." + lang.FormCulture + ".HighlightOpportunity", _('Spotlight Opportunity') + _(': ') + lang.LanguageName)}
								${renderer.errorlist("descriptions." + lang.FormCulture + ".HighlightOpportunity")}
								${renderer.text("descriptions." + lang.FormCulture + ".HighlightOpportunity", maxlength=10, class_='form-control')}
							</div>
							%endfor
						</td>
					</tr>

					%endif

					${make_message_options('Bottom','Footer',_('The text appearing at the bottom of each page of the view. Be thoughtful and keep it short - remember that this has to load with every page. If you have a lot of information you want to include here, consider creating a webpage with the information and linking to it instead.'), icon=False, title=False)}

					${make_message_options('Menu','Basic Search Menu',_('The text appearing above the menu items on the start page.'))}

					${make_message_options('SearchAlert','Basic Search Alert',_('The text appearing on the left side of the start page and highlighted as an alert (above the menu in the default layouts).'))}

					${make_message_options('KeywordSearch','Basic Search Keyword',_('The panel containing the Keyword Search'),message=False)}

					${make_message_options('OtherSearch','Basic Search Other',_('Additional multi-purpose panel available in some layouts'))}

					${make_message_options('SearchLeft','Basic Search Left',_('Custom HTML to appear in the left area of the Basic Search page.'))}

					${make_message_options('SearchCentre','Basic Search Centre',_('Custom HTML to appear in the centre-bottom area of the Basic Search page.'))}

					${make_message_options('SearchRight','Basic Search Right',_('Custom HTML to appear in the right area of the Basic Search page.'))}
				</table>
			</div>
		</div>

		%if domain.id == const.DM_CIC:
		<div class="panel panel-default max-width-lg">
			<div class="panel-heading">
				<a name="classifications"></a>
				<h2>${_('Classifications')}</h2>
			</div>
			<div class="panel-body no-padding">
				<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
					<tr>
						${self.fieldLabelCell(None,_('NAICS'),None,False)}
						<td class="field-data-cell">
							${renderer.errorlist("item.UseNAICSView")}
							${renderer.checkbox("item.UseNAICSView", label=_('NAICS menu items and searches are available in this View'))}
						</td>
					</tr>
					%if dboptions.UseTaxonomy:
					<tr>
						${self.fieldLabelCell(None,_('Taxonomy'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.UseTaxonomyView")}
								${renderer.checkbox("item.UseTaxonomyView", label=_('Taxonomy menu items and searches are available in this View'))}
							</div>

							<div class="form-inline form-inline-always form-group">
								${renderer.errorlist("item.TaxDefnLevel")}
								${h(_('Show Definitions for Taxonomy Level %s and above.')) % renderer.select("item.TaxDefnLevel", options=range(0,6), class_="form-control")}
								${self.helpBubble(None,_('In a "Browse by Service Category" Search, show definitions for Taxonomy Terms at or above the Level selected. If 0 is selected, definitions will not be shown for any Terms.'))}
							</div>
						</td>
					</tr>
					%endif
					<tr>
						${self.fieldLabelCell(None,_('Thesaurus'),None,False)}
						<td class="field-data-cell">
							<div class="checkbox">
								${renderer.errorlist("item.UseThesaurusView")}
								${renderer.checkbox("item.UseThesaurusView", label=_('Thesaurus menu items and searches are available in this View'))}
							</div>
							<div class="checkbox">
								${renderer.errorlist("item.UseLocalSubjects")}
								${renderer.checkbox("item.UseLocalSubjects", label=_('Local Subjects in Browse, Sidebar'))}
								${self.helpBubble(None,_('If this option is checked, local subjects will be included in "Browse by Subject" and the Subject sidebar on the results page.'))}
							</div>
							<div class="checkbox">
								${renderer.errorlist("item.UseZeroSubjects")}
								${renderer.checkbox("item.UseZeroSubjects", label=_('Zero-Count Subjects In Browse, Sidebar'))}
								${self.helpBubble(None,_('If this option is checked, subjects with a zero count (not being used by any records in the view) will still be included in "Browse by Subject" and the Subject sidebar on the results page.'))}
							</div>
						</td>
					</tr>
				</table>
			</div>
		</div>
		%endif

		<div class="clear-line-below">
			%if usage.ReadOnlyViewOwner:
			<span class="Alert">${_('Setup of this item is exclusively controlled by the Agency: ') + usage.ReadOnlyViewOwner}</span>
			%else:
			<input type="submit" name="Submit" value="${_('Submit Updates')}" class="btn btn-default">
			%if can_delete:
			<input type="submit" name="Delete" value="${_('Delete')}" class="btn btn-default">
			%endif
			%endif
			<input type="reset" value="${_('Reset Form')}" class="btn btn-default">
		</div>

	</form>
</div>

<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
		<a name="fields"></a>
		<h2><span class="glyphicon glyphicon-tasks" aria-hidden="true"></span> ${_('Manage Fields')}</h2>
	</div>
	<div class="panel-body">
		<ul class="simple-list">
			%if domain.id == const.DM_CIC:
			<li><a href="javascript:openWinL('${request.passvars.route_path('admin_view', action='fieldgroup', _query=[('DM', domain.id), ('ViewType',ViewType)])}','fieldEdit')">${_('Field Groups (New Window)')}</a></li>
			%endif
			<li><a href="javascript:openWinL('${makeLinkAdmin('setup_view_edit_fields.asp', dict(FType='D', DM=domain.id, ViewType=ViewType))}','fieldEdit')">${_('Details Fields (New Window)')}</a></li>
			<li><a href="javascript:openWinL('${makeLinkAdmin('setup_view_edit_fields.asp', dict(FType='U', DM=domain.id, ViewType=ViewType))}','fieldEdit')">${_('Update Fields (New Window)')}</a></li>
			<li><a href="javascript:openWinL('${makeLinkAdmin('setup_view_edit_fields.asp', dict(FType='F', DM=domain.id, ViewType=ViewType))}','fieldEdit')">${_('Feedback Fields (New Window)')}</a></li>
			%if domain.id == const.DM_CIC and dboptions.UseCIC:
			<li><a href="javascript:openWinL('${makeLinkAdmin('setup_view_edit_fields.asp', dict(FType='M', DM=domain.id, ViewType=ViewType))}','fieldEdit')">${_('Mail Form Fields (New Window)')}</a></li>
			%endif
		</ul>
	</div>
</div>

%if domain.id == const.DM_CIC:
<form class="NotVisible" name="stateForm" id="stateForm">
	<textarea id="cache_form_values"></textarea>
</form>
	%if domain.id == const.DM_CIC:
	<% renderinfo.list_script_loaded = True %>
	%endif
%endif

<%def name="bottomjs()">
<script type="text/javascript">
	$(document).ready(function () {
		$('[data-toggle="popover"]').popover();
	});
</script>

	%if domain.id == const.DM_CIC:
	${request.assetmgr.JSVerScriptTag('scripts/admin.js')}
	%endif
<script type="text/javascript">
	jQuery(function () {
	%if domain.id == const.DM_CIC:
			init_publication_checklist("${request.passvars.makeLink('~/jsonfeeds/publication_generator.asp') |n}", "${_('Not Found')}");
	% endif
		var on_click = function (chk) {
			if (chk.checked) {
				$('#override-labels').show();
				$('#override-instructions').hide();
			} else {
				$('#override-labels').hide();
				$('#override-instructions').show();
			}
		};
		on_click($('#HasLabelOverrides').on('change', function () { return on_click(this); })[0]);
	});
</script>
</%def>
