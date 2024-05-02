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
<%!
from itertools import groupby
from operator import attrgetter
%>

<%def name="makeApplicationSurveyList(name, id=None, *, add_empty=False)">
<select name="${name}" id="${name}" class="form-control">
	%if add_empty:
	<option value=""> -- </option>
	%endif
	%for group,surveygroup in groupby(applicationsurveys, attrgetter('LanguageName')):
	<optgroup label="${group}">

		%for survey in surveygroup:
		<option value="${survey.APP_ID}">${('* ' if survey.Archived else '') + survey.Name}</option>
		%endfor

	</optgroup>
	%endfor
</select>
</%def>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>

<div class="row">
	<div class="col-md-6">
		<form action="${request.route_path('admin_applicationsurvey', action='report')}" method="get" class="form">
			${request.passvars.cached_form_vals|n}
			<div class="panel panel-default">
				<div class="panel-heading">
					<h2>${_('Application Survey Report')}</h2>
				</div>
				<div class="panel-body">
					<div class="form-group">
						<label for="APP_ID3" class="control-label">${_('Application Survey:')}</label>
						${makeApplicationSurveyList('APP_ID', 'APP_ID3', add_empty=True)}
					</div>
					<div class="form-group">
						${renderer.label('StartDate',_('On or after the date'), class_='contol-label')}
						${renderer.date('StartDate', class_='form-control')}
					</div>
					<div class="form-group">
						${renderer.label('EndDate',_('Before the date'), class_='contol-label')}
						${renderer.date('EndDate', class_='form-control')}
					</div>
					<div class="form-group">
						${renderer.checkbox("ExportCSV", "1", label=_('Export as CSV'), label_class='control-label')}
					</div>
					<input type="submit" value="${_('Run Survey Report')}" class="btn btn-default">
					<input type="reset" value="${_('Reset')}" class="btn btn-default">
				</div>
			</div>
		</form>
	</div>
	<div class="col-md-6">
		<form action="${request.route_path('admin_applicationsurvey', action='edit')}" method="get" class="form-inline">
			${request.passvars.cached_form_vals|n}
			<div class="panel panel-default">
				<div class="panel-heading">
					<h2><label for="APP_ID">${_('Edit Application Survey')}</label></h2>
				</div>
				<div class="panel-body">
					<br>${makeApplicationSurveyList('APP_ID')}
					<input type="submit" value="${_('View/Edit Application Survey')}" class="btn btn-default">
				</div>
			</div>
		</form>
		<form action="${request.route_path('admin_applicationsurvey', action='add')}" method="get" class="form">
			${request.passvars.cached_form_vals|n}
			<div class="panel panel-default">
				<div class="panel-heading">
					<h2>${_('Create New Application Survey')}</h2>
				</div>
				<div class="panel-body">
					<div class="form-group">
						<label for="APP_ID2" class="control-label">${_('Copy Existing Application Survey:')}</label>
						${makeApplicationSurveyList('APP_ID', 'APP_ID2', add_empty=True)}
					</div>
					<input type="submit" value="${_('Add Application Survey')}" class="btn btn-default">
				</div>
			</div>
		</form>
	</div>
</div>






