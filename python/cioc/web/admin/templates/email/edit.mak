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


<%! from cioc.core import constants as const %>
<%inherit file="cioc.web:templates/master.mak" />
<%
query = [('DM', options.DM.id)]
if options.MR:
	query.append(('MR', '1'))
%>
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_email_index', _query=query)}">${_('Standard Email Update Text')}</a> ]</p>
<form method="post" action="${request.current_route_path()}" class="form-horizontal">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
%if not is_add == 'edit':
<input type="hidden" name="EmailID" value="${EmailID}">
%endif
<input type="hidden" name="DM" value="${options.DM.id}">
%if options.MR:
<input type="hidden" name="MR" value="1">
%endif
</div>

<div class="panel panel-default max-width-lg">
<div class="panel-heading">
	<h2>${_('Add Standard Email Update Text') if is_add else _('Edit Standard Email Update Text')}</h2>
</div>
<div class="panel-body no-padding">
	<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
%if not is_add and context.get('email') is not None:
${self.makeMgmtInfo(email)}
%endif

<tr>
	${self.fieldLabelCell(None,_('Name'), None, True)}
	<td class="field-data-cell">
		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." + lang.FormCulture + ".Name"
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.text(field, maxlength=200, class_='form-control')}
			</div>
		</div>
		%endfor
	</td>
</tr>

<tr>
	${self.fieldLabelCell(None,_('Default Message'),
		_('The Default Message will be the one initially selected when creating a new email update request. Users will have the opportunity to choose a different message before sending.'), False)}
	<td class="field-data-cell">
	%if not is_add and email.DefaultMsg:
	<span class="Info">${_('This message is currently the Default Message')}</span>
	%else:
	<% 
	if options.DM.id == const.DM_CIC:
		lbl = _('Make this the default message.')
	else:
		lbl = _('Make this the default %s message.') % (_('"All-Opportunities"') if options.MR else _('Volunteer'))
	%>
	${renderer.errorlist('email.DefaultMsg')}
	${renderer.checkbox('email.DefaultMsg', label= lbl)}
	%endif
	</td>
</tr>

<tr>
	${self.fieldLabelCell(None,_('Subject'), None, False)}
	<td class="field-data-cell">
		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." + lang.FormCulture + ".StdSubject"
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.text(field, maxlength=100, class_='form-control')}
			</div>
		</div>
		%endfor

		%if len(active_cultures) > 1:
		<div class="form-group row">
			${renderer.label('email.StdSubjectBilingual',_('Bilingual'),class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist('email.StdSubjectBilingual')}
				${renderer.text('email.StdSubjectBilingual', maxlength=150, class_='form-control')}
			</div>
		</div>
		%endif
		<p>${_('(Record / Dossier: [RECORD NUMBER])')}</p>
	</td>
</tr>
<tr>
	${self.fieldLabelCell(None,_('Greeting'), None, False)}
	<td class="field-data-cell">
		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." + lang.FormCulture + ".StdGreetingStart"
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.text(field, maxlength=100, class_='form-control')}
			</div>
		</div>
		%endfor

		<p>${_('[RECORD OWNER AGENCY NAME]')}</p>

		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." +lang.FormCulture + ".StdGreetingEnd"
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.text(field, maxlength=100, class_='form-control')}
			</div>
		</div>
		%endfor
	</td>
</tr>

<tr>
	${self.fieldLabelCell(None,_('Message Body'), None, False)}
	<td class="field-data-cell">
		<p>${_('[RECORD ORGANIZATION NAME]')}</p>
		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." + lang.FormCulture + ".StdMessageBody"
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				<span class="SmallNote">${_('Maximum 1500 characters. Do <strong>not</strong> use HTML.')|n}</span>
				${renderer.textarea(field, class_='form-control')}
			</div>
		</div>
		%endfor
	</td>
<tr>

%if not options.MR:
<tr>
	${self.fieldLabelCell(None,_('Detail Link'), None, False)}
	<td class="field-data-cell">
		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." + lang.FormCulture + ".StdDetailDesc"
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.text(field, maxlength=100, class_='form-control')}
			</div>
		</div>
		%endfor
		<p>${_('[LINK TO DETAILS PAGE]')}</p>
	</td>
<tr>
	${self.fieldLabelCell(None,_('Feedback Link'), None, False)}
	<td class="field-data-cell">
		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." + lang.FormCulture + ".StdFeedbackDesc"
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.text(field, maxlength=100, class_='form-control')}
			</div>
		</div>
		%endfor
		<p>${_('[LINK TO FEEDBACK PAGE]')}</p>
	</td>
</tr>
%endif

%if options.DM.id == const.DM_VOL:
<tr>
	${self.fieldLabelCell(None,_('All Opportunities Link') if options.MR else _('Other Opportunities Link'), None, False)}
	<td class="field-data-cell">
		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." + lang.FormCulture + ".StdOrgOppsDesc"
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.text(field, maxlength=100, class_='form-control')}
			</div>
		</div>
		%endfor
		<p>${_('[LINK TO OPPORTUNITIES WITH ORGANIZATION]')}</p>
	</td>
</tr>

<tr>
	${self.fieldLabelCell(None,_('Suggest Opportunity Link'), None, False)}
	<td class="field-data-cell">
		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." + lang.FormCulture + ".StdSuggestOppDesc"
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.text(field, maxlength=100, class_='form-control')}
			</div>
		</div>
		%endfor
		<p>${_('[LINK TO SUGGEST OPPORTUNITY FOR ORGANIZATION]')}</p>
	</td>
</tr>
%endif

<tr>
	${self.fieldLabelCell(None,_('Contact'), None, False)}
	<td class="field-data-cell">
		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." + lang.FormCulture + ".StdContact"
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				<span class="SmallNote">${_('Maximum 255 characters. Do <strong>not</strong> use HTML.')|n}</span>
				${renderer.textarea(field, class_='form-control')}
			</div>
		</div>
		%endfor
		<p>${_('[RECORD OWNER AGENCY CONTACT INFO]')}</p>
	</td>
</tr>

<tr>
	<td colspan="2" class="field-data-cell">
		<input type="submit" name="Submit" value="${_('Add') if is_add else _('Update')}" class="btn btn-default">
		%if not is_add and not email.DefaultMsg:
		<input type="submit" name="Delete" value="${_('Delete')}" class="btn btn-default"> 
		%endif
		<input type="reset" value="${_('Reset Form')}" class="btn btn-default">
	</td>
</tr>
</table>
</div>
</div>
</form>

