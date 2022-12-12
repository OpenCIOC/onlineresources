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

<%inherit file="cioc.web:templates/master.mak"/>

<%!
import json
from functools import partial
from cioc.core import constants as const
%>

<%def name="searchmenu()" buffered="True">
<%
passvars = request.passvars
makeLink = passvars.makeLink
pageinfo = request.pageinfo
dboptions = request.dboptions
Culture = request.language.Culture
vd = request.viewdata.vol
user = request.user
user_vol = user.vol
%>
%if (not user and vd.UseProfilesView) or search_info.BSrchStepByStep or search_info.BSrchWhatsNew or search_info.BSrchStudent or (search_info.BSrchBrowseAll and (search_info.BSrchBrowseByOrg or search_info.BSrchBrowseByInterest)) or search_info.HasSearchTips:
<ul>
%if not user and vd.UseProfilesView:
	<li><em>${_('Do you have a Volunteer Profile?')}</em>
	${searchform_profilelinks()}
	</li>
%endif
	%if search_info.BSrchStepByStep:
	<li>${_('To begin a search on all available opportunities: ')}<a href="${makeLink('search1.asp')}"><strong>${_('Step-by-Step Search')}</strong></a>.</li>
	%endif
	%if search_info.BSrchWhatsNew:
	<li>${_('To see recent additions to the Database: ')}<a href="${makeLink('whatsnew.asp', 'numRecords=10')}"><strong>${_("What's New")}</strong></a>.</li>
	%endif
	%if search_info.BSrchStudent:
	<li>${_('For information on student volunteering: ')}<a href="${makeLink('student.asp')}"><strong>${_('Student / Youth Search')}</strong></a>.</li>
	%endif
	%if search_info.BSrchBrowseAll and (search_info.BSrchBrowseByOrg or search_info.BSrchBrowseByInterest):
	<li>${_("Browse all ")}
	%if search_info.BSrchBrowseByOrg:
		<a href="${makeLink('browsebyorg.asp')}"><strong>${_('Organizations')}</strong></a>
		%if search_info.BSrchBrowseByInterest:
			${_(' or ')}
		%endif
	%endif
	%if search_info.BSrchBrowseByInterest:
	<a href="${makeLink('browsebyinterest.asp')}"><strong>${_('Areas of Interest')}</strong></a>.</li>
	%endif
	%endif
	%if search_info.BSrchKeywords:
	<li>${_('Perform a keyword search for opportunities using the form below.')}</li>
	%endif
	%if search_info.HasSearchTips:
	<li>${_('For help with your search, review the ')}<a href="${makeLink('search_help.asp')}" style="font-weight:bold;">${_('Search Tips')}</a></li>
	%endif
</ul>
%endif
</%def>

<%def name="searchform_profilelinks()">
<%
passvars = request.passvars
makeLink = passvars.makeLink
%>
%if not request.vprofile_user: # XXX check if vprofile logged in
	<a href="${makeLink('profile/login.asp')}"><strong>${_('Login Now')}</strong></a>${_(' or ')}<a href="${makeLink('profile/create.asp')}"><strong>${_('create a Profile')}</strong></a>.
%else:
	<a href="${makeLink('profile/')}"><strong>${_('View your Profile')}</strong></a>${_(' or ')}<a href="${makeLink('profile/logout.asp')}"><strong>${_('Logout')}</strong></a>.
%endif
</%def>

<%def name="searchform_start()">
<form id="SearchForm" action="results.asp" method="get" name="Search">
<div style="display:none">
${request.passvars.cached_form_vals}
</div>
</%def>

<%def name="searchform_in_values()">
<label class="NoWrap"><input type="radio" name="SType" value="P" checked>${_('Keywords')}</label>
<label class="NoWrap"><input type="radio" name="SType" value="O">${_('Organization Name(s)')|n}</label>
</%def>

<%def name="searchform_keyword()">
	%if search_info.BSrchKeywords:
	<input type="text" maxlength="250" id="STerms" name="STerms" class="input-expand form-control ui-autocomplete-input">
	%endif
</%def>

<%def name="searchform()" buffered="True">
${searchform_start()}
<table class="NoBorder cell-padding-3">
<tr>
<td class="FieldLabelClr"><label for="STerms">${_('Find')}</label></td>
<td align="left">${searchform_keyword()}</td>
</tr>
<tr>
<td class="FieldLabelClr">${_('in')}</td>
<td align="left">${searchform_in_values()}</td>
</tr>
<tr>
<td colspan="2"><input type="submit" value="${_('Search')}">&nbsp;&nbsp;&nbsp;<input type="reset" value="${_('Clear Form')}"></td>
</tr>
</table>
		
</form>
</%def>

<%def name="bottomjs()">
	<form class="NotVisible" name="stateForm" id="stateForm">
	<textarea id="cache_form_values"></textarea>
	</form>
	<% renderinfo.list_script_loaded = True %>
	${request.assetmgr.JSVerScriptTag('scripts/bsearch.js')}
	<script type="text/javascript">
	(function() {
	var defaultParams = ${json.dumps(request.passvars.httpvals) |n};
	jQuery(function($) {
		init_cached_state('#SearchForm');
		init_pre_fill_search_parameters();
		init_bsearch_tabs(defaultParams, ${search_info.BSrchDefaultTab or '0'});
	%if search_info.BSrchAutoComplete and search_info.BSrchKeywords:
		init_find_box({
			P: "${ request.passvars.makeLink('~/jsonfeeds/vol_keyword_generator.asp', 'SearchType=P') |n}", 
			O: "${request.passvars.makeLink('~/jsonfeeds/vol_keyword_generator.asp', 'SearchType=O') |n}"
				});
	%endif
		restore_cached_state();
		});
	})();
	</script>
</%def>

<div id="vol-search">
${makeSearchForm(
		searchform, searchmenu, 
		searchform_start=partial(capture, searchform_start),
		searchform_keyword=partial(capture, searchform_keyword),
		searchform_profilelinks=partial(capture, searchform_profilelinks),
		searchform_in_values=partial(capture, searchform_in_values))|n}
</div>
