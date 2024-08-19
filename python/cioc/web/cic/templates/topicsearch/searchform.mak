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
<%namespace file="cioc.web.cic:templates/bsearch.mak" name="bsearch"/>
<%namespace file="cioc.web.cic:templates/searchcommon.mak" import="community_form" />
<%
from webhelpers2.html import tags
from cioc.core.modelstate import convert_options
%>

%if not request.params.get('InlineMode'):
<h2 class="RevBoxHeader">${topicsearch.SearchTitle}</h2>
%endif
<p>${topicsearch.SearchDescription}</p>

%if criteria:
<h3>${_('Current Criteria')}</h3>
<ul>
	%for c in criteria:
	<li>${c.Title}${_(': ')}<i>${searched_for_items[c.SearchType]}</i></li>
	%endfor
</ul>
%endif

<form action="${request.route_path('cic_topicsearch', tag=topicsearch_tag) if topicsearch.NextStep else '/results.asp'}" class="form-horizontal">
	<div class="NotVisible">
		${request.passvars.cached_form_vals|n}
		%for name, value in hidden_fields:
		${tags.hidden(name, value)}
		<input type="hidden" name="TopicSearch" value="${topicsearch_tag}">
		%endfor
	</div>
	%for f in formitems:
	<% search_items = searches.get(f.SearchType) %>
	%if f.IsRequired or search_items:
	<h3>
		${f.Title}
		%if f.Missing:
		<br>
		<p class="AlertBubble">${_('Required')}</p>
		%elif f.IsRequired:
		<span class="Alert">*</span>
		%endif
	</h3>
	%if f.Help:
	${f.Help|n}
	%elif search_items and f.IsRequired:
	<p class="SmallNote">${_('Please select at least one item from the list below.')}</p>
	%endif
	<div class="clear-line-below">
		%if not search_items:
		<em>${_('No values available')}</em>
		%elif f.SearchType == 'A':
		${bsearch.age_groups_form(search_items)}
		%elif f.SearchType == 'C':
		${community_form(search_items, request.viewdata.cic.OtherCommunity, idsuffix=topicsearch.TopicSearchID)}
		%elif f.SearchType == 'G1':
		${bsearch.quicklist_form(search_items, f.ListType, force_heading=True)}
		%elif f.SearchType == 'G2':
		${bsearch.quicklist_form(search_items, f.ListType, '_2', force_heading=True)}
		%elif f.SearchType == 'L':
		${tags.select('LNID', [], convert_options([('','')] + [tuple(x)[:2] for x in search_items]))}
		%endif
	</div>
	%endif
	%endfor
	<div>
		<input type="Submit" value="${_('Search')}" class="btn btn-default">
	</div>
</form>

<%def name="bottomjs()">
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/bsearch.js')}
<script type="text/javascript">
jQuery(function() {
	init_cached_state();
	init_bsearch_community_dropdown_expand("${_('Select ')}","${ request.passvars.makeLink(request.pageinfo.PathToStart + "jsonfeeds/community_generator.asp")}")
	restore_cached_state();
});
</script>
</%def>
