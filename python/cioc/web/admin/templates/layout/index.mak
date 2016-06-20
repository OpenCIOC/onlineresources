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
<%
groupnames={
	'header': _('Header'),
	'footer': _('Footer'),
	'cicsearch': _('CIC Basic Search'),
	'volsearch': _('Volunteer Basic Search')
}
%>
<%def name="makeLayoutList(name, add_empty=False)">
<select name="${name}" id="${name}" class="form-control">
	%if add_empty:
	<option value=""> -- </option>
	%endif
	%for group,layoutgroup in groupby(layouts, attrgetter('LayoutType')):
		<optgroup label="${groupnames[group]}">
		
			%for layout in layoutgroup:
			<option value="${layout.LayoutID}">${layout.LayoutName + (' *' if layout.SystemLayout else '' if layout.Owner is None else (' [' + layout.Owner + ']'))}</option>
			%endfor

		</optgroup>
	%endfor
</select>
</%def>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp' if request.user.SuperUser else 'setup_webdev.asp')}">${_('Return to Setup')}</a> ]</p>
<form action="${request.route_path('admin_template_layout', action='edit')}" method="get" class="form-inline">
${request.passvars.cached_form_vals|n}
<h2><label for="LayoutID">${_('Edit Template Layout')}</h2>
<span class="SmallNote">${_('* represents a built-in Layout that cannot be changed')}</span>
<br>${makeLayoutList('LayoutID')}
<input type="submit" value="${_('View/Edit Template Layout')}" class="btn btn-default">
</form>

<form action="${request.route_path('admin_template_layout', action='add')}" method="get" class="form">
${request.passvars.cached_form_vals|n}
<h2>${_('Create New Template Layout')}</h2>
<div class="max-width-sm">
	<div class="form-group">
		<label for="LayoutID" class="control-label">${_('Copy Existing Template Layout:')}</label>
		${makeLayoutList('LayoutID', add_empty=True)}
	</div>
	<input type="submit" value="${_('Add Template Layout')}" class="btn btn-default">
</div>
</form>
