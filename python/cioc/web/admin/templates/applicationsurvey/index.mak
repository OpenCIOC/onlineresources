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

<%def name="makeApplicationSurveyList(name, add_empty=False)">
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
<form action="${request.route_path('admin_applicationsurvey', action='edit')}" method="get" class="form-inline">
${request.passvars.cached_form_vals|n}
<h2><label for="APP_ID">${_('Edit Application Survey')}</h2>
<br>${makeApplicationSurveyList('APP_ID')}
<input type="submit" value="${_('View/Edit Application Survey')}" class="btn btn-default">
</form>

<form action="${request.route_path('admin_applicationsurvey', action='add')}" method="get" class="form">
${request.passvars.cached_form_vals|n}
<h2>${_('Create New Application Survey')}</h2>
<div class="max-width-sm">
	<div class="form-group">
		<label for="APP_ID" class="control-label">${_('Copy Existing Application Survey:')}</label>
		${makeApplicationSurveyList('APP_ID', add_empty=True)}
	</div>
	<input type="submit" value="${_('Add Application Survey')}" class="btn btn-default">
</div>
</form>
