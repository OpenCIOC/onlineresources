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

<%inherit file="cioc.web:templates/master.mak"/>
<%namespace file="cioc.web.admin:templates/notice/index.mak" import="show_notices"/>
<%!
from json import dumps as jsons
from markupsafe import Markup
def j(x):
	return Markup(jsons(x))
%>

%if request.user.SuperUser:
%if sharing_profiles or notices or (closed_count and closed_count[0]):
${show_notices()}
%endif
%endif

<h2>${_('Reminders')}</h2>
<div id="existing-reminders-page">
${reminders|n}
</div>


<%def name="bottomjs()">
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
${request.assetmgr.JSVerScriptTag('scripts/reminders.js')}
<% renderinfo.list_script_loaded = True %>
<script type="text/javascript">
	init_cached_state();
initialize_reminders(${_('Reminders')|j}, ${request.passvars.makeLink('~/jsonfeeds/users')|j},
	${request.passvars.makeLink('~/reminders')|j}, 
	${request.passvars.route_path('reminder_action', action='dismiss', id='IDIDID')|j},
	${_(':')|j},
	${_('[read more]')|j}, ${_('[less]')|j}, ${_('Loading...')|j},
	${_('Not Found')|j}
);

	restore_cached_state();
</script>
</%def>

