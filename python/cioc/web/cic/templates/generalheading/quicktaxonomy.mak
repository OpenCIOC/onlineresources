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
%>
<%def name="headerextra()">
<link rel="stylesheet" type="text/css" href="${request.pageinfo.PathToStart}styles/taxonomy.css"/>
</%def>

<p style="font-weight:bold">[ <a href="${request.passvars.route_path('cic_publication_index')}">${_('Return to Publications')}</a> | <a href="${request.passvars.route_path('cic_publication', action='edit', _query=[('PB_ID', PB_ID)])}">${_('Return to Publication: %s') % pubcode}</a> ]</p>

<p class="Alert" id="add_error_message" style="display: none;"></p>

<form id="EntryForm" method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="PB_ID" value="${PB_ID}">
</div>
<table border="0" class="NoBorder cell-padding-2" width="100%" id="activations-table" data-param-base="${json.dumps(dict(request.passvars._get_http_items()))}">
<tr>
	<th class="RevTitleBox" width="10"><!-- ${_('Select')} --></th>
	<th class="RevTitleBox" width="140">${_('Code')}</th>
	<th class="RevTitleBox">${_('Term')}</th>
</tr>

${Markup('\n').join(terms)}
</table>
<input type="submit" value="${_('Submit')}">
</form>



<%def name="bottomjs()">
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/tax.js')}
</%def>

