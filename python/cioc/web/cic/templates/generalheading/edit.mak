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
<%namespace file="cioc.web.cic:templates/gh_select.mak" import="gh_selector"/>
<%!
from markupsafe import escape_silent as h, Markup
from webhelpers2.html import tags
%>

<%def name="headerextra()">
%if request.params.get('TaxonomyHeading') or (generalheading and generalheading.Used is None):
<link rel="stylesheet" type="text/css" href="${request.pageinfo.PathToStart}${request.assetmgr.makeAssetVer('styles/taxonomy.css')}"/>
%endif
</%def>

<% tax_heading = request.params.get('TaxonomyHeading') or (generalheading and generalheading.Used is None) %>

<p style="font-weight:bold">[ <a href="${request.passvars.route_path('cic_publication_index')}">${_('Return to Publications')}</a> | <a href="${request.passvars.route_path('cic_publication', action='edit', _query=[('PB_ID', PB_ID)])}">${_('Return to Publication: %s') % pubcode}</a> ]</p>
<form id="EntryForm" method="post" action="${request.route_path('cic_generalheading', action='edit')}" class="form-horizontal">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="PB_ID" value="${PB_ID}">
%if not is_add:
<input type="hidden" name="GH_ID" value="${GH_ID}">
%endif
%if tax_heading:
<input type="hidden" name="TaxonomyHeading" value="on">
%endif
</div>

<table class="BasicBorder cell-padding-4 form-table responsive-table max-width-lg clear-line-below">
<tr><th colspan="2" class="RevTitleBox">${_('Edit General Heading') if not is_add else _('Add General Heading')}</th></tr>
<%
route_path = request.passvars.route_path
can_delete = True 
%>
%if not is_add and context.get('generalheading') is not None:
<tr>
	<td class="field-label-cell">${_('Status')}</td>
	<td class="field-data-cell">
	%if not tax_heading:
		%if generalheading.UsageCountLocal or generalheading.UsageCountOther:
			<% can_delete = False %>
			%if generalheading.UsageCountLocal:
			${(_('This General Heading is <strong>being used</strong> by %d local Organization / Program records') if request.dboptions.OtherMembers else _('This General Heading is <strong>being used</strong> by %d Organization / Program records')) % generalheading.UsageCountLocal |n} [ <a href="${request.passvars.makeLink('/results.asp',dict(GHID=GH_ID))}">${_('Search')}</a> ] 
			%endif
			%if generalheading.UsageCountOther:
				%if generalheading.UsageCountLocal:
			<br>
				%endif
			${_('This General Heading is <strong>being used</strong> by %d Organization / Program records beloging to other Members') % generalheading.UsageCountOther |n}
			%endif
		%else:
			${_('This General Heading is <strong>not</strong> being used by any records.')|n}
		%endif
		%if can_delete:
			<br>${_('Because this General Heading is not being used, you can delete it using the button at the bottom of the form.')}
		%else:
			<br>${_('Because this General Heading is being used, you cannot currently delete it.')}
		%endif
	%else:
		%if generalheading.UsageCountLocal or generalheading.UsageCountOther:
			%if generalheading.UsageCountLocal:
			${(_('This General Heading is <strong>being used</strong> by %d local Organization / Program records') if request.dboptions.OtherMembers else _('This General Heading is <strong>being used</strong> by %d Organization / Program records')) % generalheading.UsageCountLocal |n} [ <a href="${request.passvars.makeLink('/results.asp',dict(GHID=GH_ID))}">${_('Search')}</a> ] 
			%endif
			%if generalheading.UsageCountOther:
				%if generalheading.UsageCountLocal:
			<br>
				%endif
			${_('This General Heading is <strong>being used</strong> by %d Organization / Program records beloging to other Members') % generalheading.UsageCountOther |n}
			%endif
		%else:
			${_('The current critera for this General Heading <strong>does not</strong> match any Organization / Program records')|n}
		%endif
	%endif
	</td>
</tr>
${self.makeMgmtInfo(generalheading)}
%endif
%if tax_heading:
<tr>
	<td class="field-label-cell">${_('Use Taxonomy Term Name')}</td>
	<td class="field-data-cell">
		${renderer.errorlist("generalheading.TaxonomyName")}
		${renderer.checkbox("generalheading.TaxonomyName", id='generalheading_TaxonomyName', label=_('Use taxonomy term name(s) for the name of this general heading instead of setting one here.'))}
	</td>
</tr>
%endif
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr class="name-row" ${'style="display: none;"' if renderer.value('generalheading.TaxonomyName') else '' |n}>
	<td class="FieldLabelLeft NoWrap">${renderer.label("descriptions." + lang.FormCulture + ".Name", _('Name (%s)') % lang.LanguageName)}</td>
	<td>
	${renderer.errorlist("descriptions." +lang.FormCulture + ".Name")}
	${renderer.text("descriptions." + lang.FormCulture + ".Name", maxlength=200, class_="form-control")}
	</td>
</tr>
%endfor
<tr>
	<td class="field-label-cell">${renderer.label("generalheading.IconNameFull", _('Icon Name'))}</td>
	<td class="field-data-cell">
		<% icon_name_full = renderer.value("generalheading.IconNameFull") %>
		%if icon_name_full:
		<div class="alert-info icon-listing-group">
			${icon_name_full}
			%if icon_name_full.startswith('fa'):
			<i class="fa ${icon_name_full}"></i>
			%elif icon_name_full.startswith('glyphicon'):
			<span class="glyphicon ${icon_name_full}"></span>
			%elif icon_name_full.startswith('icon'):
			<span class="${icon_name_full}"></span>
			%else:
			${_('Error Displaying Icon')}
			%endif
		</div>
		%endif
		${renderer.errorlist("generalheading.IconNameFull")}
		<div class="clear-line-below">
			${renderer.text("generalheading.IconNameFull", maxlength=65, class_="form-control")}
			<div class="help-block"><a href="${request.passvars.route_url('gbl_iconlist')}" target="_blank">${_('Browse icons')}</div>
		</div>
	</td>
</tr>
%if not tax_heading:
<tr>
	<td class="field-label-cell">${_('Used Heading')}</td>
	<td class="field-data-cell">
	%if can_delete:
	${renderer.errorlist("generalheading.Used")}
	${renderer.radio("generalheading.Used", 'Y', checked=True, label=_('Yes'))}
	${renderer.radio("generalheading.Used", 'N', label=_('No'))}
	%else:
	${_('Yes') if generalheading.Used else _('No')}
	%endif
	</td>
</tr>
%else:
<tr>
	<td class="field-label-cell">${_('Taxonomy Search')}</td>
	<td class="field-data-cell">
		<div id="tax-selection">
		%for selected, title, term_id in [(renderer.value('MustMatch') or [], _('Must Match:'), 'MustMatch'), (renderer.value('MatchAny') or [], _('Match at least one from:'), 'MatchAny')]:
		<div class="TermListTitle" style="clear: left;">${title}</div>
		${renderer.errorlist(term_id, class_='Alert errorlist')}
		<div class="TermList">
			<div class="${term_id}TermList" data-match="${term_id}">
			%if selected:
				<ul>
					%for i,link in enumerate(selected):
					<li class="TermItem">
					${u' ~ '.join(terms.get(code) for code in link['Code'])}&nbsp;&nbsp;<a class="SimulateLink remove-link"><img src="/images/x.gif" border="0"></a>
					%for j,code in enumerate(link['Code']):
						${renderer.hidden('%s-%d.Code-%d' % (term_id, i, j))}
					%endfor
					</li>
					%endfor
				</ul>
			%else:
				${_('[ No Terms ]')}
			%endif
			</div>
		</div>
		%endfor
			<div class="TermListTitle">
				${renderer.checkbox('generalheading.TaxonomyRestrict', label=_('Restrict'))}
			</div>
		</div>
		<br><a class="ButtonLink SimulateLink" id="modify-term-selection">${_('Add or Remove Terms')}</a>
	</td>
</tr>
%endif
<tr>
	<td class="field-label-cell">${_('Non-Public')}</td>
	<td class="field-data-cell">${renderer.errorlist("generalheading.NonPublic")}
	${renderer.radio("generalheading.NonPublic", 'True', False, label=_('Yes'))} 
	${renderer.radio("generalheading.NonPublic", 'False', True, label=_('No'))} 
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label('generalheading.DisplayOrder', _('Display Order'))}</td>
	<td class="field-data-cell">${renderer.errorlist("generalheading.DisplayOrder")}
		<div class="form-inline form-inline-always">
			${renderer.text("generalheading.DisplayOrder", value=0, maxlength=3, size=4, class_="form-control")}
		</div>
	</td>
</tr>
%if headinggroups:
<tr>
	<td class="field-label-cell">${renderer.label('generalheading.HeadingGroup', _('Heading Group'))}</td>
	<td class="field-data-cell">${renderer.errorlist("generalheading.HeadingGroup")}
	${renderer.select("generalheading.HeadingGroup", [('','')]+headinggroups, class_="form-control")}
	</td>
</tr>
%endif
%if generalheadings:
<tr>
	<td class="field-label-cell">${_('Related Headings')}</td>
	<td class="field-data-cell">${gh_selector("RelatedHeadings", generalheadings, relatedheadings)}</td>
</tr>
%endif
</table>
<input type="submit" name="Submit" value="${_('Add') if is_add else _('Update')}" class="btn btn-default">
%if not is_add and can_delete:
<input type="submit" name="Delete" value="${_('Delete')}" class="btn btn-default">
%endif
<input type="reset" value="${_('Reset Form')}" class="btn btn-default">
</form>

<%def name="bottomjs()">
%if request.params.get('TaxonomyHeading') or (generalheading and generalheading.Used is None):
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<div id="tax-selection-dialog" style="display: none;">
<table border="0" class="NoBorder" cellspacing="0" cellpadding="0" width="100%">
<tr valign="top">
	<td width="70%">
	<iframe id="searchFrame" src="about:blank" name="searchFrame" vspace="3" hspace="0" class="Search" frameborder="0" height="600"></iframe>
	</td>
	<td width="15px"></td>
	<td>
		
		<div class="TermListTitle">${_('Build Term List')}</div>
		<div class="TermList">
			<div id="BuildTermList">${_('[ No Terms ]')}</div>
		</div>
		<div id="SelectDiv" style="display: none;">
			<a id='add-match-all' data-target="MustMatch" class="ButtonLink SimulateLink">${_('Must Match')}</a>
			<a id='add-match-any' data-target="MatchAny" class="ButtonLink SimulateLink">${_('Match Any')}</a>
		</div>
		<div id="SuggestDiv" style="display: none;">
			<br style="clear:left;">
			<a id='suggest-link' class="ButtonLink SimulateLink" data-st="4">${_('Suggest Link')}</a>
			<a id='suggest-term' class="ButtonLink SimulateLink" data-st="5">${_('Suggest Term')}</a>
		</div>
		<div id="dialog-selected-target">
		</div>
		<p><a id='save-tax-form' class="ButtonLink SimulateLink">${_('Save')}</a>
		<a id="reset-tax-form" class="ButtonLink SimulateLink">${_('Reset Form')}</a>
		<a id="clear-tax-form" class="ButtonLink SimulateLink">${_('Clear Form')}</a>
		<a id="cancel-tax-form" class="ButtonLink SimulateLink">${_('Cancel')}</a></p>

	</td>
</tr>
</table>
</div>
%endif
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/generalheading.js')}
<script type="text/javascript">
jQuery(function() {
%if request.params.get('TaxonomyHeading') or (generalheading and generalheading.Used is None):
	init_gh_tax_edit("${request.passvars.makeLink('~/tax.asp', dict(MD=1))|n}", "${_('[ No Terms ]')}");
%endif
	init_general_heading_icons("${request.passvars.route_path("jsonfeeds_icons")}");
});
</script>
</%def>

