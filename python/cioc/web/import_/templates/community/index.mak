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


<%! from markupsafe import Markup, escape %>
<%inherit file="cioc.web:templates/master.mak" />
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_community_index')}">${_('Return to Communities')}</a> ]</p>
<p class="Info">${escape(_('Use this form to upload a %sCommunities Repository%s data file. Note that the update will run immediately upon loading the file.')) % (Markup('<a href="http://community-repository.cioc.ca/" target="_blank">'), Markup('</a>'))}</p>
<form method="post" action="${request.current_route_path()}" enctype="multipart/form-data">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
</div>
<table class="BasicBorder cell-padding-2">
	<tr>
		<th colspan="2" class="RevTitleBox">${title}</th>
	</tr>
	<tr>
		<td>${_('Select File')}</td>
		<td>${renderer.errorlist('ImportFile')}<input type="file" name="ImportFile"></td>
	</tr>
	<tr>
		<td colspan="2"><input type="submit" value="${_('Upload File')}"></td>
	</tr>
</table>
</form>


