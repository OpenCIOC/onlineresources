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
<%def name="makeLayoutList(name, add_empty=False)">
<select name="${name}" id="${name}" class="form-control">
	%if add_empty:
	<option value=""> -- </option>
	%endif
	%for culture,group in groupby(pages, attrgetter('Culture')):
		<optgroup label="${culture_map[culture].LanguageName}">
		
			%for page in group:
			<option value="${page.PageID}">${page.Title} (${page.Slug})</option>
			%endfor

		</optgroup>
	%endfor
</select>
</%def>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp' if request.user.SuperUser else 'setup_webdev.asp')}">${_('Return to Setup')}</a> ]</p>
<form action="${request.route_path('admin_pages', action='edit')}" method="get" class="form-inline">
<div style="display:none">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="DM" value="${domain.id}">
</div>
%if pages:
<h2><label for="PageID">${_('Edit Page')}</h2>
<br>${makeLayoutList('PageID')}
<input type="submit" value="${_('View/Edit Page')}" class="btn btn-default">
%endif
</form>

<form action="${request.route_path('admin_pages', action='add')}" method="get" class="form">
<div style="display: none;">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="DM" value="${domain.id}">
</div>
<h2>${_('Create New Page')}</h2>
<div class="max-width-sm">
%if pages:
	<div class="form-group">
		<label for="PageID" class="control-label">${_('Copy Existing Page:')}</label>
		${makeLayoutList('PageID', add_empty=True)}
	</div>
%endif
	<input type="submit" value="${_('Add Page')}" class="btn btn-default">
</div>
</form>
