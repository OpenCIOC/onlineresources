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

<%def name="makeViewList(name, add_empty=False, id=None)">
<select name="${name}" id="${id or name}" class="form-control">
	%if add_empty:
	<option value=""> -- </option>
	%endif
	%for IsPublic, viewGroup in groupby(views, attrgetter('IsPublic')):
	<optgroup label="${_('Public Views') if IsPublic else _('Private Views')}">
		%for view in viewGroup:
		<option value="${view.ViewType}">#${view.ViewType} - ${view.ViewName + ('' if view.Owner is None else (' [' + view.Owner + ']'))}</option>
		%endfor
	</optgroup>
	%endfor
</select>
</%def>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>
<form action="${request.route_path('admin_view', action='edit')}" method="get" class="form-inline">
<div style="display: none;">
${request.passvars.cached_form_vals|n}
${renderer.hidden('DM', domain.id)}
</div>

<h2><label for="ViewType">${_('Edit View (%s)') % _(domain.label)}</label></h2>
${makeViewList('ViewType')}
<input type="submit" value="${_('View/Edit View')}" class="btn btn-default">
</form>

<form action="setup_view_add.asp" method="get" class="form-horizontal">
<div style="display: none;">
${request.passvars.cached_form_vals|n}
${renderer.hidden('DM', domain.id)}
</div>

<h2>${_('Create New View (%s)') % _(domain.label)}</h2>
<div class="max-width-sm">
	<p>${_('The initial values for the new View will be based on the View you specify. If you do not specify a View, the default View will be used. When you submit, you will be taken to a form to edit the new View. The name for the View must be unique.')|n}</p>
	<div class="form-group row">
		${renderer.label('ViewName', _('View Name'), class_='control-label col-sm-3')}
		<div class="col-sm-9">
			${renderer.text('ViewName', maxlength=100, class_='form-control')}
		</div>
	</div>
	<div class="form-group row">
		${renderer.label('NewViewType', _('Use View'), class_='control-label col-sm-3')}
		<div class="col-sm-9">
			${makeViewList('ViewType', add_empty=True, id='NewViewType')}
		</div>
	</div>
</div>
<input type="submit" value="${_('Add View')}" class="btn btn-default">
</form>
