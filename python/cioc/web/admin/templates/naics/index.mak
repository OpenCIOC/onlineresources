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

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>
<form action="${request.route_path('admin_naics', action='edit')}" method="get">
${request.passvars.cached_form_vals|n}
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox" colspan="2">${_('Add / Edit NAICS Code')}</th>
</tr>
<tr>
	<td colspan="2">
	${_('To find a NAICS Code to edit, use the')} <a href="${request.passvars.makeLink('~/naicsfind.asp')}" class="poplink" target="_BLANK" data-popargs="{size:'sm',name:'sFind'}">${_('NAICS Code Finder')}</a>
	<br>${_('To create a new entry, leave the code blank.')}
	</td>
</tr>
<tr>
<td class="FieldLabelLeft"><label for="Code">${_('Code:')}</label></td>
<td>
<input type="text" value="" name="Code" id="Code" size="6" maxlength="6">
<input type="submit" value="${_('View/Edit Code')}"></td>
</tr>
</table>
</form>
