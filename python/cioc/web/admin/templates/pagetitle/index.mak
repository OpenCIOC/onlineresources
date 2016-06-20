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

<%def name="makePageList(name)">
<select name="${name}" id="${name}" class="form-control">
	%for page in pages:
		<option value="${page.PageName}">${page.PageName} ${ "(" + page.PageTitle + ")" if page.PageTitle else ""}</option>
	%endfor
</select>
</%def>
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>
<form action="${request.route_path('admin_pagetitle', action='edit')}" method="get" class="form-inline">
${request.passvars.cached_form_vals|n}
<h2><label for="PageName">${_('Edit Page Title')}</label></h2>
<p>${_("This allows you to override the displayed title of a sub-set of CIOC pages. If the title cannot be overriden, it is not included below.")}</p>
${makePageList('PageName')}
<input type="submit" value="${_('View/Edit Page')}" class="btn btn-default">
</form>
