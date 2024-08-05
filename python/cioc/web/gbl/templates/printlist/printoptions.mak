<%doc>
=========================================================================================
 Copyright 2024 KCL Software Solutions Inc.

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


<%!
from markupsafe import Markup
from cioc.core import listformat
%>

<%def name="printlist_form()">
<form method="post" id="EntryForm" action="printlist" class="form">
	<div class="NotVisible">
		${request.passvars.cached_form_vals|n}
		${renderer.hidden('IDList')}
	</div>
	<div class="panel panel-default max-width-lg">
		<div class="panel-heading">
			<h2>${_("Use this form to customize print options")}</h2>
		</div>
		<div class="panel-body no-padding">
			<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
				<tr>
					<td class="field-label-cell">${_("Profile")}</td>
					<td class="field-data-cell">${renderer.select("ProfileID", printprofiles, class_="form-control")}</td>
				</tr>
				%if request.pageinfo.DbArea == const.DM_CIC:
				%if not request.user.cic.LimitedView:
				%if publications:
				<tr>
					<td class="field-label-cell">${_('Publications')}</td>
					<td class="field-data-cell">
						%if renderer.value('IDList'):
						${_("Further limit your selection using:")}<br>&nbsp;<br>
						%endif

						${makePublicationUI()}

					</td>
				</tr>
				%endif
				## Limited View
				%else:
				<tr>
					<td class="field-label-cell">${_("General Headings")}</td>
					<td class="field-data-cell">
						%if renderer.value("IDList"):
						${_("Further limit your selection using:")}<br>&nbsp;<br>
						%endif
						${makeGeneralHeadingUI()}
					</td>
				</tr>
				%endif
				<tr>
					<td class="field-label-cell">${_("Sort By")}</td>
					<td class="field-data-cell">
						<p class="SmallNote">${_("Records sorted by Heading may appear under multiple Heading titles")}</p>
						<div class="form-group">
							<div class="radio">
								${renderer.radio("SortBy", "O", True, label=_("Organization / Program Name(s)"))}
							</div>
							<div class="radio">
								${renderer.radio("SortBy", "H", label=_("Heading"))}
							</div>
						</div>
						<div class="checkbox">
							${renderer.checkbox("IncludeTOC", label=_("Include Table of Contents"))}
						</div>
					</td>
				</tr>
				<tr>
					<td class="field-label-cell">${_("Record Index")}</td>
					<td class="field-data-cell">
						<p class="SmallNote">${Markup(_("An index by record name can be included at the end of the document <strong>only</strong> when records are sorted by name."))}</p>
						<div class="checkbox">
							${renderer.checkbox("IncludeIndex", label=_("Include Index"))}
						</div>
					</td>
				</tr>
				%elif request.pageinfo.DbArea == const.DM_VOL:
				<tr>
					<td class="field-label-cell">${_("Sort By")}</td>
					<td class="field-data-cell">
						${renderer.radio("SortBy", "O", True, label=_("Organization / Program Name(s)"))}
						<br>${renderer.radio("SortBy", "P", label=_("Position Title"))}
						<br>${renderer.radio("SortBy", "C", label=_("Date Created"))}
						<br>${renderer.radio("SortBy", "M", label=_("Last Modified"))}
					</td>
				</tr>
				%endif
				%if request.viewdata.dom.CanSeeNonPublic:
				<tr>
					<td class="field-label-cell">${_("Non-Public Records")}</td>
					<td class="field-data-cell">${renderer.checkbox("IncludeNonPublic", "on", label=_("Include non-public records"))}</td>
				</tr>
				%endif
				%if request.viewdata.dom.CanSeeDeleted:
				<tr>
					<td class="field-label-cell">${_("Deleted Records")}</td>
					<td class="field-data-cell">${renderer.checkbox("IncludeDeleted", "on", label=_("Include deleted records"))}</td>
				</tr>
				%endif
				%if request.pageinfo.DbArea == const.DM_VOL and request.viewdata.vol.CanSeeExpired:
				<tr>
					<td class="field-label-cell">${_("Expired Records")}</td>
					<td class="field-data-cell">${renderer.checkbox("IncludeExpired", "on", label=_("Include expired records"))}</td>
				</tr>
				%endif
				<tr>
					<td class="field-label-cell">${_("Ouput Format")}</td>
					<td class="field-data-cell">${renderer.checkbox("OutputPDF", "on", label=_("Output PDF"))}</td>
				</tr>
			</table>
		</div>
	</div>
	<input type="submit" value="${_(" Next")}" class="btn btn-default clear-line-above">
</form>

<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
</%def>

<%def name="bottomjs()">
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/advsrch.js')}
<script type="text/javascript">
	jQuery(function ($) {
		init_cached_state()
		init_pubs_dropdown('${request.passvars.makeLink("~/jsonfeeds/heading_searchform.asp")}');
		restore_cached_state();
	})
</script>
</%def>

<%def name="makePublicationUI()">
### NOTE: This is a port from includes/search/incAdvSearchPub.asp which still exists
%if publicationsgh:
	${renderer.select("GHPBID", class_="form-control", options=[("","Publications"), (listformat.format_pub_list(publicationsgh, request.viewdata.cic.CanSeeNonPublicPub), _("General Headings"))])}
<br>
%endif
<div id="publication_search_selection">
	${makeIncludeAndExcludeUI(_("Include Publication(s)"), _("Exclude Publication(s)"), "PB", listformat.format_pub_list(publications, pub_names_only=request.viewdata.cic.UsePubNamesOnly))}
</div>
%if publicationsgh:
<div class="NotVisible" id="general_heading_search_selection">
	${makeGeneralHeadingUI()}
</div>
%endif
</%def>


<%def name="makeGeneralHeadingUI()">
${makeIncludeAndExcludeUI(_("Include Heading(s)"), _("Exclude Heading(s)"), "GH", generalheadings)}
</%def>

<%def name="makeIncludeAndExcludeUI(include_prompt, exclude_prompt, field_prefix, values_list)">
<p class="SmallNote">${_("Hold CTRL to select/deselect multiple items")}</p>
<div class="row">
	<div class="col-sm-6">
		<div class="panel panel-info">
			<div class="panel-body">
				<h4>${include_prompt}</h4>
				<div class="radio">
					${renderer.radio(f"{field_prefix}Type", "N", id=f"{field_prefix}Type_N", label=_('Has None'))}
				</div>
				<div class="radio">
					${renderer.radio(f"{field_prefix}Type", "A", id=f"{field_prefix}Type_A", label=_('Has Any'))}
				</div>
				<div class="row">
					<div class="col-sm-6">
						<div class="radio">
							${renderer.radio(f"{field_prefix}Type", "AF", id=f"{field_prefix}Type_AF", label=_('Has all from'))}
						</div>
					</div>
					<div class="col-sm-6">
						<div class="radio">
							${renderer.radio(f"{field_prefix}Type", "F", checked=True, id=f"{field_prefix}Type_F", label=_('Has any from'))}
						</div>
					</div>
				</div>
				<div>
					${renderer.select(f"{field_prefix}ID", values_list, class_="form-control", multiple=True, size=6)}
				</div>
			</div>
		</div>
	</div>
	<div class="col-sm-6">
		<div class="panel panel-info">
			<div class="panel-body">
				<h4>${exclude_prompt}</h4>
				<div>
					${renderer.select(f"{field_prefix}IDx", values_list, class_="form-control", multiple=True, size=6)}
				</div>
			</div>
		</div>
	</div>
</div>
</%def>
