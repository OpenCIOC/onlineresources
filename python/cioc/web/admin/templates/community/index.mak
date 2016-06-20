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

<%def name="makeCommunityList(name)">
<select name="${name}" id="${name}", >
	%for community in communities:
		<option value="${community.CM_ID}">${community.Community}</option>
	%endfor
</select>
</%def>
<p style="font-weight:bold">[ 
<a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a>
| <a href="${request.passvars.route_path('import_community')}">${_('Update Communities Version')}</a>
| <a href="${request.passvars.route_path('import_community_map')}">${_('Update External Communities')}</a>
| <a href="${request.passvars.route_path('admin_community', action='edit')}">${_('Add Community')}</a>
| <a href="${request.passvars.route_path('admin_community', action='edit', _query=[('altarea', 'on')])}">${_('Add Alternative Search Area')}</a>
| <a href="${request.passvars.makeLink('~/comfind.asp', 'SearchParams=on')}">${_('Show Search Parameters')}</a>
| <a href="${request.passvars.route_path('admin_community', action='list')}">${_('Full List')}</a>
]</p>
<form action="${request.route_path('admin_community', action='edit')}" method="get">
${request.passvars.cached_form_vals|n}
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox"><label for="CM_ID">${_('Edit Community')}</th>
</tr>
<tr>
<td>
${makeCommunityList('CM_ID')}
<input type="submit" value="${_('View/Edit Community')}"></td>
</tr>
</table>
</form>
