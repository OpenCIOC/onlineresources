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

<%def name="makeSocialMediaList(name)">
<select name="${name}" id="${name}">
	<option value="">${_('>> CREATE NEW <<')}</option>
	%for socialmedia in descs:
		<option value="${socialmedia.SM_ID}">${socialmedia.SocialMediaName}</option>
	%endfor
</select>
</%def>
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>
<form action="${request.route_path('admin_socialmedia', action='edit')}" method="get">
${request.passvars.cached_form_vals|n}
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox"><label for="SM_ID">${_('Edit Social Media Type')}</label></th>
</tr>
<tr>
<td>
${makeSocialMediaList('SM_ID')}
<input type="submit" value="${_('View/Edit Social Media Type')}"></td>
</tr>
</table>
</form>
