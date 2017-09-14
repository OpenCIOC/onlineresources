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

<%def name="error_page()">
<p class="Alert">${_('Are you sure you want to permanently clear this publication code from these items?')}
%if not context.get('suppress_back_message'):
<br>${_('Use your back button to return to the form if you do not want to clear the records.')}
%endif
</p>
%if publication.UsageCountLocal:
<br>${(_('This Publication is <strong>being used</strong> by %d local Organization / Program records') if request.dboptions.OtherMembers else _('This Publication is <strong>being used</strong> by %d Organization / Program records')) % publication.UsageCountLocal |n} [ <a href="${request.passvars.makeLink('/results.asp',dict(PBID=publication.PB_ID))}">${_('Search')}</a> ] 
%endif
%if publication.UsageCountOther:
<br>${_('This Publication is <strong>being used</strong> by %d Organization / Program records beloging to other Members') % publication.UsageCountOther |n}
%endif
<form method="post" action="${request.current_route_path()}">
<div style="display: none;">
${request.passvars.cached_form_vals|n}
%if context.get('id_value') and context.get('id_name'):
<input type="hidden" name="${context.get('id_name')}" value="${context.get('id_value')}">
%endif
</div>
<input type="submit" name="Submit" value="${_('Clear from all records')}">
</form>
</%def>

${error_page()}
