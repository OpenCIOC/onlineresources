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

%if state == 'shared':
<p class="Alert">${_('Are you sure you want to make this a shared publication?')}
%else:
<p class="Alert">${_('Are you sure you want to make this a local publication?')}
%endif
<br>${_('Use your back button to return if you do not want to do this.')}</p>
<form method="post" action="${request.route_path('cic_publication', action='sharedstate')}">
<div style="display: none;">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="PB_ID" value="${PB_ID}">
<input type="hidden" name="state" value="${state}">
</div>
<input type="submit" name="Submit" value="${_('Update')}">
</form>
