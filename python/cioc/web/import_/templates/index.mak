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
<form method="post" action="${request.current_route_path()}" enctype="multipart/form-data">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
</div>
<table class="BasicBorder cell-padding-2">
	<tr>
		<th colspan="2">${_('Upload Import File')}</th>
	</tr>
	<tr>
		<td><label for="ImportFile">${_('Select File')}</label></td>
		<td>${renderer.errorlist('ImportFile')}<input type="file" name="ImportFile" id="ImportFile"></td>
	</tr>
	<tr>
		<td><label for="DisplayName">${_('Import As')}</label></td>
		<td>${renderer.errorlist('DisplayName')}
		${renderer.text('DisplayName', size=21, maxlength=255)}</td>
	</tr>
	<tr>
		<td colspan="2"><input type="submit" value="${_('Upload File')}"></td>
	</tr>
 </table>
</form>

<p align="center">[ <a href="javascript:parent.close()">Close Window</a> ]</p>

