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

<%
makeLink=request.passvars.makeLink
%>
<p>[ <a href="${makeLink('/tax_mng.asp')}">${_('Return to Manage Taxonomy')}</a> ]</p>

<h3>${_('What should I do with these results?')}</h3>
<p>${_('Use the ')}<a href="${request.passvars.route_path('cic_taxonomy', action='activations')}">${_('Drill-Down Activation Tool')}</a>${_(' to update your Activations. You can also use the ')}<a href="${request.passvars.route_path('cic_taxonomy', action='activationrec')}">${_('Activation Recommendation Tool')}</a>${_(', which will use this information and more to recommend specific activations or deactivations.')}</p>
<p class="Info">${_('This report details branches for which more than one Taxonomy Term has been activated.')}
<br>${_('Y branch Terms and Level 1 Terms are automatically excluded from this report.')}
<br>${_('It is recommended that each branch be activated at only one level whenever possible.')}</p>
<p>${_('Found %d result(s).') % len(terms)}</p>

%if terms:
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox">${_('Code')}</th>
	<th class="RevTitleBox">${_('Term')}</th>
	<th class="RevTitleBox">${_('Usage')}</th>
	<th class="RevTitleBox">${_('Action')}</th>
</tr>

%for term in terms:
<tr>
	<td>${term.Code}</td>
	<td>${term.Term}</td>
	<td>${term.Usage}</td>
	<td>
		<a href="${makeLink('/tax_edit.asp',dict(TC=term.Code))}"><img src="${request.static_url('cioc:images/edit.gif')}" width="15" height="14" border="0" title="${_('Edit')}"></a>
	%if term.Usage > 0:
		<a href="${makeLink('/results.asp',dict(TMCR='on',incDel='on',TMC=term.Code))}"><img src="${request.static_url('cioc:images/zoom.gif')}" width="17" height="14" border="0" title="${_('Search')}"></a>
	%endif
	</td>
</tr>
%endfor
</table>
%endif
