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
from markupsafe import Markup
import json
%>

<%
makeLink = request.passvars.makeLink
route_path = request.passvars.route_path
OtherMembersActive = request.dboptions.OtherMembersActive
%>
<%def name="headerextra()">
<link rel="stylesheet" type="text/css" href="${request.pageinfo.PathToStart}${request.assetmgr.makeAssetVer('styles/taxonomy.css')}"/>
</%def>

<p>[ <a href="${makeLink('/tax_mng.asp')}">${_('Return to Manage Taxonomy')}</a>
<%
if not options.GlobalActivations: 
	switch_query = [('GlobalActivations','on')]
	json_query = []
	label = _('Switch to Global Activations')
else:
	switch_query = []
	json_query = [('GlobalActivations','on')] 
	label = _('Switch to Local Activations')
%>
%if OtherMembersActive and request.user.cic.SuperUserGlobal:
| <a href="${route_path('cic_taxonomy', action='activations', _query=switch_query)}">${label}</a>
%endif
]</p>

%if not OtherMembersActive:
	<h2>${_('Manage Taxonomy Activations')}</h2>
%elif options.GlobalActivations:
	<h2>${_('Manage Global Activations')}</h2>
%else:
	<h2>${_('Manage Local Activations')}</h2>
%endif
<div>

<table border="0" class="NoBorder cell-padding-2" width="100%" id="activations-table" data-url="${route_path('cic_taxonomy', action='activations')}" data-param-base="${json.dumps(dict(request.passvars._get_http_items() + json_query))}">
<tr>
	<th class="RevTitleBox" width="145">${_('Code')}</th>
	<th class="RevTitleBox">${_('Term')}</th>
</tr>

${Markup('\n').join(terms)}
</table>
</div>


<%def name="bottomjs()">
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/tax.js')}
</%def>

