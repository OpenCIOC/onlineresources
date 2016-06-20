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

<%def name="makeEmailValueList(name, add_empty=False)">
<select name="${name}" id="${name}" class="form-control">
	%if add_empty:
	<option value=""> -- </option>
	%endif
	%for DefaultMsg, emailGroup in groupby(emails, attrgetter('DefaultMsg')):
	<optgroup label="${_('Default Message') if DefaultMsg else _('Additional Messages')}">
		%for email in emailGroup:
			<option value="${email.EmailID}">${email.Name}</option>
		%endfor
	</optgroup>
	%endfor
</select>
</%def>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>

%if emails:
<form action="${request.route_path('admin_email', action='edit')}" method="get" class="form-inline">
<div class="hidden">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="DM" value="${options.DM.id}">
%if options.MR:
<input type="hidden" name="MR" value="1">
%endif
</div>
<h2><label for="EmailID">${_('Edit Standard Email Text')}</label></h2>
${makeEmailValueList('EmailID')}
<input type="submit" value="${_('View/Edit Standard Email Text')}" class="btn btn-default">
</form>
%else:
<p><em>${_('There are no existing update email texts.')}</em></p>
%endif

<form action="${request.route_path('admin_email', action='add')}" method="get" class="form">
<div class="hidden">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="DM" value="${options.DM.id}">
%if options.MR:
<input type="hidden" name="MR" value="1">
%endif
</div>

<h2>${_('Create New Standard Email Text')}</h2>
%if emails:
<div class="form-group max-width-sm">
	<label form="EmailID" class="control-label">${_('Copy Existing Standard Email Text')}</label>
	${makeEmailValueList('EmailID', add_empty=True)}
</div>
%endif
<input type="submit" value="${_('Add Standard Email Text')}" class="btn btn-default">
</form>
