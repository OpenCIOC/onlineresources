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

<form method="post" target="_BLANK" class="form">
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
	<div class="panel panel-default max-width-lg">
		<div class="panel-heading">
			<h2>${_("Use this form to customize print options")}</h2>
		</div>
		<div class="panel-body no-padding">
			<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
				<tr>
					<td class="field-label-cell">${renderer.label("Msg", _('Report Title'))}</td>
				</tr>
				<tr>
					<td class="field-data-cell">
						${renderer.text('ReportTitle', profile.PageTitle, maxlength=255, class_='form-control')}
					</td>
				</tr>
				<tr>
					<td class="field-label-cell">${renderer.label("Msg", _("Report Message"))}</td>
				</tr>
				<tr>
					<td class="field-data-cell">
						${renderer.textarea('Msg', profile.DefaultMsg, class_="form-control WYSIWYG")}
					</td>
				</tr>
			</table>
		</div>
	</div>
	<input type="submit" value="${_(" Next (New Window)")}>>" class="btn btn-default clear-line-above">
</form>

<script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/6.1.0/tinymce.min.js" integrity="sha512-dr3qAVHfaeyZQPiuN6yce1YuH7YGjtUXRFpYK8OfQgky36SUfTfN3+SFGoq5hv4hRXoXxAspdHw4ITsSG+Ud/g==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script type="text/javascript">
	tinymce.init({
		selector: '.WYSIWYG',
		plugins: 'anchor autolink link advlist lists image charmap preview searchreplace paste visualblocks code fullscreen insertdatetime media table contextmenu help',
		menubar: 'edit view format table help',
		toolbar: 'undo redo styles bullist numlist link | bold italic underline forecolor removeformat | copy cut paste searchreplace',
		convert_urls: false,
		schema: 'html5',
		color_map: [
			'#D3273E', 'Red',
			'#DC582A', 'Orange',
			'#007A78', 'Turquoise',
			'#1D4289', 'Blue',
			'#666666', 'Gray',
		]
	});
</script>



