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
from cioc.core import listformat
%>

<%def name="printlist_form()">
<form method="post" id="EntryForm" action="printlist">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
${renderer.hidden('IDList')}
</div>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_("Use this form to customize print options")}</th></tr>
<tr>
	<td class="FieldLabelLeft">${_("Profile")}</td>
	<td>${renderer.select("ProfileID", printprofiles, class_="form-control")}</td>
</tr>
%if request.pageinfo.DbArea == const.DM_CIC:
	%if not request.user.cic.LimitedView:
		%if publications:
	<td class="FieldLabelLeft">${_('Publications')}</td>
	<td>
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
	<td class="FieldLabelLeft">${_("General Headings")}</td>
	<td>
			%if renderer.value("IDList"):
			    ${_("Further limit your selection using:")}<br>&nbsp;<br>
			%endif
			${makeGeneralHeadingUI()}
	</td>
</tr>
		%endif
<tr>
	<td class="FieldLabelLeft">${_("Sort By")}</td>
	<td>
	<p class="SmallNote">${_("When sorted by heading, results will also be grouped by heading")}</p>
	${renderer.radio("SortBy", "O", True, label=_("Organization / Program Name(s)"))}
	<br>${renderer.radio("SortBy", "H", label=_("Heading"))}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_("Index and Table of Contents")}</td>
	<td>
	<p class="SmallNote">${_("The field used in the table of contents is controlled by the sort order.")}</p>
	${renderer.checkbox("IncludeTOC", label=_("Include Table of Contents"))}
	<br>${renderer.checkbox("IncludeIndex", label=_("Include Index"))}
	</td>
</tr>
%elif request.pageinfo.DbArea == const.DM_VOL:
<tr>
	<td class="FieldLabelLeft">${_("Sort By")}</td>
	<td>${renderer.radio("SortBy", "O", True, label=_("Organization / Program Name(s)"))}
	<br>${renderer.radio("SortBy", "P", label=_("Position Title"))}
	<br>${renderer.radio("SortBy", "C", label=_("Date Created"))}
	<br>${renderer.radio("SortBy", "M", label=_("Last Modified"))}
	</td>
</tr>
%endif
%if request.viewdata.dom.CanSeeNonPublic:
<tr>
	<td class="FieldLabelLeft">${_("Non-Public Records")}</td>
	<td>${renderer.checkbox("IncludeNonPublic", "on", label=_("Include non-public records"))}</td>
</tr>
%endif
%if request.viewdata.dom.CanSeeDeleted:
<tr>
	<td class="FieldLabelLeft">${_("Deleted Records")}</td>
	<td>${renderer.checkbox("IncludeDeleted", "on", label=_("Include deleted records"))}</td>
</tr>
%endif
%if request.pageinfo.DbArea == const.DM_VOL and request.viewdata.vol.CanSeeExpired:
<tr>
	<td class="FieldLabelLeft">${_("Expired Records")}</td>
	<td>${renderer.checkbox("IncludeExpired", "on", label=_("Include expired records"))}</td>
</tr>
%endif
<tr>
	<td class="FieldLabelLeft">${_("Ouput Format")}</td>
	<td>${renderer.checkbox("OutputPDF", "on", label=_("Output PDF"))}</td>
</tr>
</table>
<input type="submit" value="${_("Next")} >>">
</form>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
</%def>

<%def name="bottomjs()">
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/advsrch.js')}
<script type="text/javascript">
jQuery(function($) {
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
                        <div class="radio col-sm-6">
                            ${renderer.radio(f"{field_prefix}Type", "AF", id=f"{field_prefix}Type_AF", label=_('Has all from'))}
                        </div>
                        <div class="radio col-sm-6">
                            ${renderer.radio(f"{field_prefix}Type", "F", checked=True, id=f"{field_prefix}Type_F", label=_('Has any from'))}
                        </div>
                    </div>
		    <div>
                    ${renderer.select(f"{field_prefix}ID", values_list,
                            class_="form-control", multiple=True, size=6)}
		    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6">
            <div class="panel panel-info">
                <div class="panel-body">
                    <h4>${exclude_prompt}</h4>
		    <div>
                    ${renderer.select(f"{field_prefix}IDx", values_list,
                            class_="form-control", multiple=True, size=6)}
		    </div>
                </div>
            </div>
        </div>
    </div>
</%def>
