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
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_datafeedapikey_index')}">${_('Return to Index')}</a> ]</p>

<% activate_text = _('Activate') if key.Inactive else _('Inactivate') %>
<% btn_class = 'btn-default' if key.Inactive else 'btn-danger' %>
<p class="Alert">${_('Are you sure you want to %s this APIKey?') % activate_text}</p>
<form method="post" action="${request.current_route_path()}">
<div class="hidden">
${request.passvars.cached_form_vals}
<input type="hidden" name="FeedAPIKey" value="${key.FeedAPIKey}">
<input type="hidden" name="Inactive" value="${'' if key.Inactive else 'on'}">
</div>
<input type="submit" class="btn ${btn_class}" value="${activate_text}">
</form>
