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
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_community_index')}">${_('Return to Communities')}</a> ]</p>
%if not error_log:
<h2>${_('Validation of %s was SUCCESSFUL!') % filename}</h2>
%else:
<h2>${_('Validation of %s failed!') % filename}</h2>
<p><a href="${request.passvars.route_path('import_community')}">${_('Return to Update Communities Version')}</a></p>
%endif
</p>
%if error_log:
<table class="BasicBorder cell-padding-4">
%for error in error_log:
<tr>
<td style="white-space: pre-wrap">${error}</td>
</tr>
%endfor
</table>
%endif
%if unauthorized:
<h3>Unauthorized Values</h3>
<p>${_('The following communities were not matched by the imported file, and could not be removed because they are in use or were marked as local (unauthorized).')}</p>
<p>${_('Any values that could not be removed due to usage are now marked as local and may be manually removed once they are no longer in use.')}</p>
<table class="BasicBorder cell-padding-4">
	<tr>
		<th class="RevTitleBox">${_('ID')}</th>
		<th class="RevTitleBox">${_('Name')}</th>
		<th class="RevTitleBox">${_('Parent')}</th>
		<th class="RevTitleBox">${_('Source')}</th>
		<th class="RevTitleBox">${_('Used')}</th>
	</tr>
<% route_path = request.passvars.route_path %>
%for community in unauthorized:
	<tr>
		<td><a href="${route_path('admin_community', action='edit', _query=[('CM_ID', community.CM_ID)])}">${community.CM_ID}</a></td>
		<td>${community.Name}</td>
		<td>${community.Parent}</td>
		<td>${community.Source}</td>
		<td style="text-align:center">${'*' if community.Used else ''}</td>
	</tr>
%endfor
</table>
%endif

