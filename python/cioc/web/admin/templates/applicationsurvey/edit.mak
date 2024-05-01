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
<%! from operator import itemgetter %>
<%
is_add = action == 'add'
if not is_add:
	completed_count = applicationsurvey.COMPLETED
	first_date = applicationsurvey.FIRST_DATE or _('N/A')
	last_date = applicationsurvey.LAST_DATE or _('N/A')
else:
	completed_count = 0
	if context.get('applicationsurvey') is not None:
		applicationsurvey.Name = applicationsurvey.Name + ' ' + _('Copy')
%>
${renderer.errorlist()}
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_applicationsurvey_index')}">${_('Application Surveys')}</a> ]</p>
<form method="post" action="${request.route_path('admin_applicationsurvey', action=action)}">
	<div class="NotVisible">
		${request.passvars.cached_form_vals|n}
		%if not is_add:
		<input type="hidden" name="APP_ID" value="${APP_ID}">
		%endif
	</div>

	<p class="AlertBubble">
		${_('Important Note: Once a survey question has been completed, you may no longer modify the survey question or delete the survey, to preserve the integrity of reports. Please ensure that questions are complete and accurate before using the survey. You may still add/remove answer options, or change the help text of the question. To change the questions being asked, copy the survey and then switch the active survey in the General Setup options.')}
	</p>

	<table class="BasicBorder cell-padding-3 full-width form-table responsive-table">
		<tr>
			<th class="RevTitleBox" colspan="2">${_('Add Application Survey') if action=='add' else _('Edit Application Survey')}</th>
		</tr>
		%if not is_add and context.get('applicationsurvey') is not None:
		${self.makeMgmtInfo(applicationsurvey)}
		%endif
		%if not is_add:
		<tr>
			<td class="field-label-cell">${_('Surveys Stats')}</td>
			<td class="field-data-cell">
				<ul>
					<li>${_('Completed ')} <strong>${completed_count}</strong> ${_(' times')}</li>
					<li>${_('First completed on ')} <strong>${first_date}</strong></li>
					<li>${_('Last completed on ')} <strong>${last_date}</strong></li>
				</ul>
			</td>
		</tr>
		%endif
		%if not is_add:
		<tr>
			<td class="field-label-cell">${_('Status')}</td>
			<td class="field-data-cell">
				${renderer.errorlist(applicationsurvey.Archived)}
				${renderer.checkbox('applicationsurvey.Archived', label=_('Archive this survey'))}
				%if applicationsurvey.Archived:
				<p class="SmallNote">${_('Survey was archived on: ') + applicationsurvey.ARCHIVED_DATE}</p>
				%endif
				%if applicationsurvey.IN_USE:
				<br />
				<div class="AlertBubble clear-line-above">
					${_('This survey is currently in use on Volunteer forms.')}
				</div>
				%endif
			</td>
		</tr>
		%endif
		<tr>
			${self.fieldLabelCell('Culture',_('Language'),help_text = _('Internal name for administrators'),is_required=True)}
			<td class="field-data-cell">
				%if is_add:
				${renderer.errorlist('Culture')}
				${renderer.select('Culture', [(x, culture_map[x].LanguageName) for x in active_cultures], class_='form-control')}
				%else:
				${applicationsurvey.LanguageName}
				%endif
			</td>
		</tr>

		<tr>
			${self.fieldLabelCell('applicationsurvey.Name',_('Survey Name'),help_text = _('Internal name for administrators'),is_required=True)}
			<td class="field-data-cell">
				${renderer.errorlist('applicationsurvey.Name')}
				${renderer.text('applicationsurvey.Name', maxlength=255, class_='form-control')}
			</td>
		</tr>
		<tr>
			${self.fieldLabelCell('applicationsurvey.Title',_('Survey Title'),help_text = _('Public title displayed on application forms for survey section'),is_required=True)}
			<td class="field-data-cell">
				${renderer.errorlist('applicationsurvey.Title')}
				${renderer.text('applicationsurvey.Title', maxlength=255, class_='form-control')}
			</td>
		</tr>
		<tr>
			${self.fieldLabelCell('applicationsurvey.Description',_('Survey Description'),help_text = _('Public description of the survey purpose, privacy informnation, etc.'))}
			<td class="field-data-cell">
				${renderer.errorlist('applicationsurvey.Description')}
				${renderer.textarea('applicationsurvey.Description', class_='form-control WYSIWYG')}
			</td>
		</tr>

		%for i in range(1,4):
		<%
		field = 'applicationsurvey.TextQuestion' + str(i)
		if is_add:
			usage_count = 0
		else:
			usage_count = getattr(applicationsurvey,'T' + str(i) + 'QC' )
		%>
		<tr>
			<td class="field-label-cell">${_('Text Question ') + str(i)}</td>
			<td class="field-data-cell">
				${renderer.errorlist(field)}
				${renderer.label(field,_('Short Text-Answer Question'),class_='control-label')}
				${renderer.text(field, maxlength=500, class_='form-control', readonly=(usage_count > 0))}
				%if not is_add:
				<div class="SmallNote clear-line-below">${_('Answered ')} <strong>${usage_count}</strong> ${_(' time(s)')}</div>
				%endif
				${renderer.label(field + 'Help',_('Instructions / Details (optional)'),class_='control-label')}
				${renderer.textarea(field + 'Help', class_='form-control WYSIWYG')}
			</td>
		</tr>
		%endfor

		%for i in range(1,4):
		<%
		field = 'applicationsurvey.DDQuestion' + str(i)
		if is_add:
			usage_count = 0
		else:
			usage_count = getattr(applicationsurvey,'DD' + str(i) + 'QC' )
		%>
		<tr>
			<td class="field-label-cell">${_('Drop-down Question ') + str(i)}</td>
			<td class="field-data-cell">
				${renderer.errorlist(field)}
				${renderer.label(field,_('Drop-down selection Question'),class_='control-label')}
				${renderer.text(field, maxlength=500, class_='form-control', readonly=(usage_count > 0))}
				%if not is_add:
				<div class="SmallNote clear-line-below">${_('Answered ')} <strong>${usage_count}</strong> ${_(' time(s)')}</div>
				%endif
				<label class="control-label">${_('Drop-down Options: ')}</label>
				<ul>
					%for j in range(1,11):
					<li>
						${renderer.errorlist(field + 'Opt' + str(j))}
						${renderer.text(field + 'Opt' + str(j), maxlength=150, class_='form-control')}
					</li>
					%endfor
				</ul>

				${renderer.label(field + 'Help',_('Instructions / Details (optional)'),class_='control-label')}
				${renderer.textarea(field + 'Help', class_='form-control WYSIWYG')}
			</td>
		</tr>
		%endfor
		<tr>
			<td colspan="2">
				<input type="submit" name="Submit" value="${_('Add') if action=='add' else _('Update')}" class="btn btn-default">
				%if not (is_add or completed_count > 0):
				<input type="submit" name="Delete" value="${_('Delete')}" class="btn btn-default">
				%endif
				<input type="reset" value="${_('Reset Form')}" class="btn btn-default">
			</td>
		</tr>

	</table>

</form>

<%def name="bottomjs()">
<script type="text/javascript">
	$(document).ready(function () {
		$('[data-toggle="popover"]').popover();
	});
</script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/6.1.0/tinymce.min.js" integrity="sha512-dr3qAVHfaeyZQPiuN6yce1YuH7YGjtUXRFpYK8OfQgky36SUfTfN3+SFGoq5hv4hRXoXxAspdHw4ITsSG+Ud/g==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script type="text/javascript">
	tinymce.init({
		selector: '.WYSIWYG',
		plugins: 'anchor autolink link advlist lists image charmap preview searchreplace paste visualblocks code fullscreen insertdatetime media table contextmenu help',
		menubar: 'edit view insert format table help',
		toolbar: 'undo redo styles bullist numlist link | bold italic underline forecolor removeformat | copy cut paste searchreplace code',
		extended_valid_elements: 'span[*],i[*]',
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
</%def>
