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

<p align="center">[ <a href="javascript:parent.close()">Close Window</a> ]</p>

<form action="${request.route_path('admin_view', action='topicsearch')}" method="get">
<div style="display: none;">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="ViewType" value="${ViewType}">
</div>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox"><label for="TopicSearchID">${_('Edit Topic Search')}</th>
</tr>
<tr>
<td>
<select name="TopicSearchID" id="TopicSearchID", >
	<option value="">${_('>> Create New <<')}</option>
	%for topic_search in topic_searches:
	<option value="${topic_search.TopicSearchID}">${topic_search.SearchTitle}</option>
	%endfor
</select>
<input type="submit" value="${_('View/Edit Topic Search')}"></td>
</tr>
</table>
</form>

<p align="center">[ <a href="javascript:parent.close()">Close Window</a> ]</p>
