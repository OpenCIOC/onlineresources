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

<%def name="makeTemplateList(name, add_empty=False)">
<select name="${name}" id="${name}" class="form-control">
	%if add_empty:
	<option value=""> -- </option>
	%endif
	%for template in templates:
		<option value="${template.Template_ID}">#${template.Template_ID} - ${template.Name + (' *' if template.SystemTemplate else '' if template.Owner is None else (' [' + template.Owner + ']'))} (${_('Used by %s Views') % template.Usage})</option>
	%endfor
</select>
</%def>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp' if request.user.SuperUser else 'setup_webdev.asp')}">${_('Return to Setup')}</a> ]</p>
<form action="${request.route_path('admin_template', action='edit')}" method="get" class="form-inline">
${request.passvars.cached_form_vals|n}
<h2>${_('Edit Template')}</h2>
<div class="max-width-md">
	<div class="SmallNote">${_('* represents a built-in Template that cannot be changed')}</div>
	${makeTemplateList('TemplateID')}
	<input type="submit" value="${_('View/Edit Template')}" class="btn btn-default">
</div>
</form>

<form action="${request.route_path('admin_template', action='add')}" method="get" class="form-horizontal">
${request.passvars.cached_form_vals|n}
<h2>${_('Create New Template')}</h2>
<div class="max-width-sm">
	${_('The initial values for the new template will be based on the template you specify. If you do not specify a template, the default template will be used. When you submit, you will be taken to a form to edit the new template. The name for the design template must be unique.')}
	<div class="form-group row">
		${renderer.label("TemplateID", _('Copy Existing Template'), class_='control-label col-sm-4')}
		<div class="col-sm-8">
			${makeTemplateList('TemplateID', add_empty=True)}
		</div>
	</div>
	<input type="submit" value="${_('Add Template')}" class="btn btn-default">
</div>
</form>
