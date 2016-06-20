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
<style type="text/css">
	.SearchRecordCount {
		border-bottom: dotted thin black;
	}
	.SearchRecordCount:hover {
		border: none;
		text-decoration: underline;
	}
</style>


%if not recentsearches:
<p>${_('No Recent Searches')}</p>
%else:
<h2>${_('Your %d Most Recent Searches') % len(recentsearches)}</h2>
<ol>
%for search in recentsearches:
	<li><strong>${search["datetime"]}</strong>
		(<span class="SearchRecordCount" title="${_('Found in View')} #${search["view_type"]} ${search["view_name"]} ${'(%s)' % search["search_language"] if request.multilingual_active else ''}">${search["record_count"]} ${_('records')}</span>)
		[
		<a class="NoLineLink" href="${request.passvars.makeLink("results.asp",dict(RS=search["key"]))}">${_('Search')}</a>
		%if request.user.dom:
		|
		<a class="NoLineLink" href="${request.passvars.makeLink("advsrch.asp",dict(RS=search["key"]))}">${_('Refine')}</a>
		%endif
		]
		<ul>
		%if search["info"]:
		<li>${search["info"].replace('-{|}-','</li><li>')|n}</li>
		%else:
		<li><em>${_('[No search description provided]')}</em></li>
		%endif
		</ul>
	</li>
%endfor
</ol>
%endif
