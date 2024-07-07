<%doc>
=========================================================================================
 Copyright 2024 KCL Software Solutions Inc.

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

<form method="post" target="_BLANK">
<div style="display:none">
${request.passvars.cached_form_vals}
%for key, value in request.model_state.form.data.items():
    %if isinstance(value, list):
	<input type="hidden" name="${key}" value="${','.join(str(x) for x in value)}">
    %elif isinstance(value, bool):
	<input type="hidden" name="${key}" value="${'on' if value else ''}">
    %elif value is None:
	<input type="hidden" name="${key}" value="">
    %else:
	<input type="hidden" name="${key}" value="${value}">
    %endif
%endfor
</div>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_("Use this form to customize print options")}</th></tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label("Msg", _("Report Message"))}</td>
	<td><span class="SmallNote">${_("HTML is allowed.")}</span>
	<br>${renderer.textarea('Msg', profile.DefaultMsg)}
</tr>
</table>
<input type="submit" value="${_("Next (New Window)")} >>">
</form>



