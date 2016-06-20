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

<p class="Alert">${_('Are you sure you want to permanently delete %s from this view?') % culture_map[Culture].LanguageName}
<br>${_('Use your back button to return to the form if you do not want to delete.')}</p>
<form method="post" action="${request.route_path('admin_view', action='delete_lang')}">
<div style="display: none;">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="ViewType" value="${ViewType}">
<input type="hidden" name="Culture" value="${Culture}">
<input type="hidden" name="DM" value="${domain.id}">
</div>
<input type="submit" name="Submit" value="${_('Delete')}">
</form>
