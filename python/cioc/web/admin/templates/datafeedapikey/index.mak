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
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox">${_("Feed API Key")}</th>
	<th class="RevTitleBox">${_("Owner Name")}</th>
	<th class="RevTitleBox">${_("Community Information")}</th>
	<th class="RevTitleBox">${_("Volunteer")}</th>
	<th class="RevTitleBox">${_("Active")}</th>
	<th class="RevTitleBox">${_("Action")}</th>
</tr>
%for key in keys:
<tr>
<td><code>${key.FeedAPIKey}</code></td>
<td>${key.Owner}</td>
<td>
%if key.CIC:
	<img src="${request.static_url('cioc:images/greencheck.gif')}" alt="${_('Checked')}" width="15" height="15" border="0" title="${key.Owner + _(': Applies to Community Information')}">
%endif
</td>
<td>
%if key.VOL:
	<img src="${request.static_url('cioc:images/greencheck.gif')}" alt="${_('Checked')}" width="15" height="15" border="0" title="${key.Owner + _(': Applies to Volunteer')}">
%endif
</td>
<td>
%if key.Inactive:
	<img src="${request.static_url('cioc:images/redx.gif')}" alt="${_('Inactive')}" width="15" height="15" border="0" title="${key.Owner + _(': Inactive')}">
%else:
	<img src="${request.static_url('cioc:images/greencheck.gif')}" alt="${_('Checked')}" width="15" height="15" border="0" title="${key.Owner + _(': Active')}">
%endif
</td>
<td class="NoWrap">
<form action="${request.route_path('admin_datafeedapikey', action='edit')}" method="get">
<div class="hidden">
${request.passvars.cached_form_vals}
<input type="hidden" name="FeedAPIKey" value="${key.FeedAPIKey}">
</div>
<input type="submit" value="${_('Edit')}">
</form>
</td>
</tr>
%endfor
<tr>
<td colspan="6">
<form action="${request.route_path('admin_datafeedapikey', action='add')}" method="get">
<div class="hidden">
${request.passvars.cached_form_vals}
</div>
<input type="submit" value="${_('Add New')}">
</form>
</td></tr>
</table>
