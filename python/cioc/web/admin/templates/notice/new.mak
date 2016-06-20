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

<form method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
</div>

<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('New Admin Notice')}</th></tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${renderer.label('AdminAreaID', _('Area'))}</td>
	<td>
	${renderer.errorlist("AdminAreaID")}
	${renderer.select("AdminAreaID", [(x.AdminAreaID, x.Name) for x in areas])}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft NoWrap">${renderer.label('RequestDetail', _('Request Detail'))}</td>
	<td>
		${renderer.errorlist('RequestDetail')}
        ${renderer.textarea('RequestDetail')}
	</td>
</tr>
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Add')}"> 
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>
