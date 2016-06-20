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
<%
use_cic = request.user.cic.SuperUser
use_vol = request.user.vol.SuperUser and request.dboptions.UseVOL
only_vol = request.dboptions.UseVOL and not request.dboptions.UseCIC
%>
<%inherit file="cioc.web:templates/master.mak" />

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>
<form method="post" action="${request.route_path('admin_generalsetup')}" class="form-horizontal">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
</div>

<div class="panel panel-default max-width-lg">
<div class="panel-heading">
	<h2>${_('Edit general database options')}</h2>
</div>
<div class="panel-body no-padding">
	<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">

${self.makeMgmtInfo(settings, show_created=False)}

<tr>
	${self.fieldLabelCell(None,_('Training Mode'),
		_('When the database is in training mode, Emails are not sent out. '
			'An alert-coloured header will appear on every page. Note that this applies '
			'to all modules in the database.'),False)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.TrainingMode')}
		${renderer.checkbox('settings.TrainingMode', label=_('The database is in training mode.'))}
	</td>
</tr>

<%
sections = []
if use_cic or only_vol:
	sections.append((_('CIC'), 'CIC'))

if use_vol:
	sections.append((_('Volunteer'), 'VOL'))
%>
%for dm_label, domain in sections:
<% 
	label = '%s (%s)' % (_('Database Name'), dm_label)
%>
<tr>
	${self.fieldLabelCell(None,label,
		_('Name to use for the database in outgoing Emails'),True)}
	<td class="field-data-cell">
	%for culture in active_cultures:
		<%
			lang = culture_map[culture]
			field = "descriptions." +lang.FormCulture + ".DatabaseName" + domain
			label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.text(field, maxlength=255, class_='form-control')}
			</div>
		</div>
	%endfor
	</td>
</tr>
%endfor
<tr>
	${self.fieldLabelCell('settings.DefaultTemplate',_('Admin Design Template'),
		_('This template is used in the "Admin" (shared) section of the database.'),True)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.DefaultTemplate')}
		${renderer.select('settings.DefaultTemplate', templates, class_='form-control')}
	</td>
</tr>
<tr>
	${self.fieldLabelCell('settings.DefaultPrintTemplate', _('Admin Print Template'),
		_('This template is used for "Print Mode" in the "Admin" (shared) section of the database.'),False)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.DefaultPrintTemplate')}
		${renderer.select('settings.DefaultPrintTemplate', templates, class_='form-control')}
	</td>
</tr>

<%
sections = []
if use_cic:
	sections.append((_('CIC'), 'CIC', _('Community Information Database'), cic_views))

if use_vol:
	sections.append((_('Volunteer'), 'VOL', _('Volunteer Database'), vol_views))
%>

%for dm_label, domain, dm_full_name, views in sections:
	<%
		field = 'settings.DefaultView' + domain
		label = _('Default View (%s)') % dm_label
		help = _('This view is used for the %s when a user is not logged in (the "public" view).') % dm_full_name
	%>
<tr>
	${self.fieldLabelCell(field,label,help,True)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.DefaultView'+domain)}
		${renderer.select('settings.DefaultView'+domain, views, class_='form-control')}
	</td>
</tr>
%endfor

<tr>
	${self.fieldLabelCell(None,_('Public Print Mode'),
		_('This only applies if a print template has been specified '
			'for the View in question. Only the details page is available '
			'to the public in print mode, and the javascript title option is disabled.'),False)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.PrintModePublic')}
		${renderer.checkbox('settings.PrintModePublic', label=_('Print version available to non-logged in users (the public)'))}
	</td>
</tr>
<tr>
	${self.fieldLabelCell(None,_('User Initials'),
		_("If selected, the user's initials are used when a user's identity "
			"is required for input to a field. Otherwise, the user's first and last name are used."),False)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.UseInitials')}
		${renderer.checkbox('settings.UseInitials', label=_('Use user initials '))}
	</td>
</tr>
<tr>
	${self.fieldLabelCell('settings.LoginRetryLimit',_('Login Attempts'),
		_('The number of incorrect attempts to log in are allowed before the account is locked'),False)}
	<td class="field-data-cell">
		<div class="form-inline">
			${renderer.errorlist('settings.LoginRetryLimit')}
			${renderer.select('settings.LoginRetryLimit', options=[('', _('No Limit')), '5', '7', '10'], class_="form-control")}
		</div>
	</td>
</tr>

<%
sections = []
if use_cic:
	sections.append((_('CIC'), 'CIC', ''))

if use_vol:
	sections.append((_('Volunteer'), 'VOL', '/volunteer'))
%>

%for dm_label, domain, extra_url in sections:
<tr>
	${self.fieldLabelCell('settings.BaseURL' + domain,(_('Base URL (%s)') % dm_label),
		_('The full web address to the root of the application. Do not include the trailing slash. (e.g. mysite.cioc.ca)'),True)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.BaseURL'+domain)}
		<div class="input-group">
			<span class="input-group-addon">https://</span>
			${renderer.text('settings.BaseURL'+domain, class_='form-control')}
			%if extra_url:
			<span class="input-group-addon">${extra_url}</span>
			%endif
		</div>
		
	</td>
</tr>
%endfor

<tr>
	${self.fieldLabelCell('settings.DaysSinceLastEmail' + domain,_('Days Since Last Email'),
		_('When sending an update Email request for a single record, an alert will '
			'be printed if the last Email update request was less than this many days '
			'ago. Note: this applies to all modules of the database.'), True)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.DaysSinceLastEmail')}
		<div class="form-inline">
			${renderer.text('settings.DaysSinceLastEmail', maxlength=3, class_="form-control")}
		</div>
	</td>
</tr>

<%
sections = []
if use_cic:
	sections.append((_('CIC'), 'CIC', False))

if use_vol:
	sections.append((_('Volunteer'), 'VOL', False))

if request.dboptions.UseVolunteerProfiles:
	sections.append((_('Volunteer Profile'), 'VOLProfile', True))
%>

%for dm_label, domain, is_required in sections:
<tr>
	${self.fieldLabelCell('settings.DefaultEmail' + domain,_('Default Email (%s)') % dm_label,
	_('The Default Email address is used whenever an Email message is generated by the system and a specific Agency Email is unavailable.'), is_required)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.DefaultEmail'+domain)}
		${renderer.email('settings.DefaultEmail'+domain, class_='form-control')}
	</td>
</tr>
%endfor

<%
sections = []
if use_cic or only_vol:
	sections.append((_('CIC'), 'CIC'))

if use_vol:
	sections.append((_('Volunteer'), 'VOL'))
%>
%for dm_label, domain in sections:
<% 
	label = '%s (%s)' % (_('Feedback Message'), dm_label)
%>
<tr>
	${self.fieldLabelCell(None,label,
		_('Message printed after someone submits feedback on a record.'),True)}
	<td class="field-data-cell">
	%for culture in active_cultures:
		<%
			lang = culture_map[culture]
			field = "descriptions." +lang.FormCulture + ".FeedbackMsg" + domain
			label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.textarea(field, class_='form-control')}
			</div>
		</div>
	%endfor
	</td>
</tr>
%endfor

%for dm_label, domain in sections:

<% 
	label = '%s (%s)' % (_('Record Notes'), dm_label)
%>
<tr>
	${self.fieldLabelCell(None,label,None,False)}
	<td class="field-data-cell">
	%for prompt, action in [(_('updated'), 'Update'), (_('deleted'), 'Delete')]:
		<% field = ''.join(('settings.Can', action, 'RecordNote', domain)) %>
	${_('Record Notes (e.g. Internal Memo) can be %s by:') % prompt}<br> 
	${renderer.errorlist(field)}
	${renderer.radio(field, 'N', label=_('No one (not allowed)'))}
	<br>${renderer.radio(field, 'A', label=_('Anyone with update permissions'))}
	<br>${renderer.radio(field, 'S', label=_('Super User only'))}
	<br><br>
	%endfor

	${renderer.errorlist('settings.RecordNoteTypeOptional'+ domain)}
	${renderer.checkbox('settings.RecordNoteTypeOptional' + domain, label=_('Note Types are optional'))}
	</td>
</tr>

%endfor
%if use_cic:
<tr>
	${self.fieldLabelCell(None,_('Default Geocode Type'),None,False)}
	<td class="field-data-cell">${renderer.errorlist('settings.DefaultGCType')}
	${renderer.radio('settings.DefaultGCType', 'B', label=_('No value (do not map)'))}
	<br>${renderer.radio('settings.DefaultGCType', 'S', label=_('Site address'))}
	<br>${renderer.radio('settings.DefaultGCType', 'I', label=_('Intersection'))}
	<br>${renderer.radio('settings.DefaultGCType', 'M', label=_('Manual placement'))}
	<br><br>${_('Default method of geo-coding on new records')}
	</td>
</tr>
<tr>
	${self.fieldLabelCell(None,_('Prevent Duplicate Org Names'),None,False)}
	<td class="field-data-cell">${renderer.errorlist('settings.PreventDuplicateOrgNames')}
	${renderer.radio('settings.PreventDuplicateOrgNames', value='A', label=_('Allow duplicate organization / program names'))}
	<br>${renderer.radio('settings.PreventDuplicateOrgNames', value='W', label=_('Warn about duplicate organization / program names'))}
	<br>${renderer.radio('settings.PreventDuplicateOrgNames', value='D', label=_("Don't Allow duplicate organization / program names"))}
	</td>
</tr>
<tr>
	${self.fieldLabelCell(None,_('New NUM Selection'),
		_('If checked, then new NUMs will be the lowest '
			'NUM available for the agency, even if there are higher NUMs already taken. If not checked, '
			'then a new NUM will be one more than the highest one already used for that agency.'),False)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.UseLowestNUM')}
		${renderer.checkbox('settings.UseLowestNUM', '1', label=_('Always pick lowest unused NUM'))}
	</td>
</tr>
<tr>
	${self.fieldLabelCell('settings.SiteCodeLength',_('Billing/Other Address Site Code'),
		_('Max length for the optional site code component of the Billing and Other Addresses fields. Use 0 to disable site code.'),False)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.SiteCodeLength')}
		<div class="form-inline">
			${renderer.text('settings.SiteCodeLength', maxlength=3, class_="form-control")}
		</div>
	</td>
</tr>
<tr>
	${self.fieldLabelCell(None,_('Offline Tools'),
		_('When selected, the Offline Tools will be permitted to connect to this CIOC database and the Offline Tools options will be available in setup areas.'),False)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.UseOfflineTools')}
		${renderer.checkbox('settings.UseOfflineTools', label=_('Enable Offline Tools Support'))}
	</td>
</tr>
%endif
%if use_vol:
<tr>
	${self.fieldLabelCell(None,_('Volunteer Centre Organization Name(s)'),
		_('Name of organization(s) to which a Volunteer Profile Account Holder agrees to allow the use of their private data as outlined in the Privacy Policy.'),True)}
	<td class="field-data-cell">
		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." +lang.FormCulture + ".VolProfilePrivacyPolicyOrgName" 
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.text(field, maxlength=255, class_='form-control')}
			</div>
		</div>
		%endfor
	</td>
</tr>

<tr>
	${self.fieldLabelCell(None,_('Volunteer Profile Privacy Policy'),
		_('Privacy Policy under which Volunteer Profile Account holders agree to let you use their personal information.'),True)}
	<td class="field-data-cell">
		%for culture in active_cultures:
		<%
		lang = culture_map[culture]
		field = "descriptions." +lang.FormCulture + ".VolProfilePrivacyPolicy"
		label = lang.LanguageName
		%>
		<div class="form-group row">
			${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
			<div class="col-sm-9 col-md-10">
				${renderer.errorlist(field)}
				${renderer.textarea(field, default_rows=const.TEXTAREA_ROWS_LONG, class_='form-control')}
			</div>
		</div>
		%endfor
	</td>
</tr>

<tr>
	${self.fieldLabelCell(None,_('Area of Interest'),
		_('When selected, the software will omit General Areas of Interest on search and data entry pages, including for Volunteer Profile users. The setup areas for General Areas of Interest remain available so that they can be configured correctly in a multi-member database (This is because some members may have different settings). However, there is no requirement to complete the General Area setup if they are not being used by any member of the database.'),False)}
	<td class="field-data-cell">
		${renderer.errorlist('settings.OnlySpecificInterests')}
		${renderer.checkbox('settings.OnlySpecificInterests', label=_('Only use Specific Areas of Interest'))}
	</td>
</tr>
%endif

<tr>
	<td colspan="2" class="field-data-cell">
		<input type="submit" name="Submit" value="${_('Update')}" class="btn btn-default"> 
		<input type="reset" value="${_('Reset Form')}" class="btn btn-default">
	</td>
</tr>
</table>
</div>
</div>
</form>

<%def name="bottomjs()">
<script type="text/javascript">
$(document).ready(function(){
    $('[data-toggle="popover"]').popover();
});
</script>
</%def>
