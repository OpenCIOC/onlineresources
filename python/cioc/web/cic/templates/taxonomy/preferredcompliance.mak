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

<%def name="headerextra()">
<link rel="stylesheet" type="text/css" href="${request.pageinfo.PathToStart}styles/taxonomy.css"/>
</%def>

<%
makeLink=request.passvars.makeLink
%>

<p>[ <a href="${makeLink('/tax_mng.asp')}">${_('Return to Manage Taxonomy')}</a>
%if request.user.cic.SuperUserGlobal and request.dboptions.OtherMembersActive:
|
	%if act_global:
	<a href="${request.passvars.current_route_path()}">${_('Return to Local Report')}</a>
	%else:
	<a href="${request.passvars.current_route_path(_query=[('Global', 'on')])}">${_('See Global Report')}</a>
	%endif
%endif
]</p>
<h2>${_('Report on Preferred Term Compliance')}</h2>
<p class="Info">${_('This report provides a report on compliance with the current list of Preferred Terms, if any have been set. Branches with no Preferred Term set are not considered for compliance.')}</p>
<p>${_('Some compliance actions can be selected for automatic update, such as updating existing indexing and/or activation to a preferred higher-level Term, deactivating a non-preferred Term that is not indexed to any records. Activation of currently inactive preferred Terms is also available for automatic update, but not selected by default; please consider their individual applicability to your data.')}</p>
<h3>Action Types</h3>
<p>${_('Some special case terms require more careful review. Please review the types of actions available:')}</p>
<dl>
	<dt class="FieldLabelLeftClr"><img src="${request.static_url('cioc:images/rollup.gif')}" width="15" height="15" border="0" alt="${_('Re-index')}"> <em>${_('[Preferred Code]')}</em></dt>
	<dd>${_('This indicates that there is a Preferred Term (the given Code) at a higher level in the Taxonomy hierarchy. Selecting this Term for action will update all existing activations and indexing to the higher-level Term. Hold your mouse over the suggested Preferred Term to display the Term name.')}</dd>
	<dt class="FieldLabelLeftClr"><img src="${request.static_url('cioc:images/greencheck.gif')}" width="15" height="15" border="0" alt="${_('Activate')}"> ${_('Activate')}</dt>
	<dd>${_('This indicates that the Term is a currently Inactive Preferred Term. Note that some Terms may automatically become active as lower-level Terms are re-indexed and activated at the preferred level, so it may not be necessary to activate these Terms explicitly. Not selected for action by default.')}</dd>
	<dt class="FieldLabelLeftClr"><img src="${request.static_url('cioc:images/redx.gif')}" width="15" height="15" border="0" alt="${_('Deactivate')}"> ${_('Deactivate')}</dt>
	<dd>${_('This indicates that this Term is not a preferred Term, is not in use, and a Preferred Term equivalent is available.')|n}</dd>
	<dt class="FieldLabelLeftClr"><img src="${request.static_url('cioc:images/redx.gif')}" width="15" height="15" border="0" alt="${_('Deactivate')}"> ${_('Deactivate <em>(No Preferred Term available!)</em>')|n}</dt>
	<dd>${_('This indicates that this Term is not a preferred Term, but one or more of its sibling Terms are Preferred Terms. There is no Preferred-Term equivalent available; deactivate with caution. In cases where records are assigned to this type of Term, it will be marked <em>Evaluation Required</em>. Not selected for action by default.')|n}</dd>
	<dt class="FieldLabelLeftClr">${_('Evaluation Required')}</dt>
	<dd>${_('These Terms have records associated with them and cannot be deactivated or rolled-up into a single higher-level Preferred Term. Where applicable, lower-level terms should be manually activated as needed and records manually re-indexed at a lower level to become compliant.')}</dd>
</dl>

<form action="${request.current_route_path()}" method="post">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="mod" value="on">
%if request.dboptions.OtherMembersActive and act_global:
<input type="hidden" name="Global" value="on">
%endif
</div>

%if compliancelist:
<div>
<p>
<input type="button" class="check-all" value="${_('Check All')}" class="btn btn-default">
<input type="button" class="uncheck-all" value="${_('UnCheck All')}" class="btn btn-default">
</p>
<table class="BasicBorder cell-padding-3 responsive-table max-width-lg clear-line-below">
<tr>
	<th class="RevTitleBox">${_('Code')}</th>
	<th class="RevTitleBox">${_('Term')}</th>
	<th class="RevTitleBox">${_('Usage')}</th>
	%if request.dboptions.OtherMembersActive and act_global:
	<th class="RevTitleBox">${_('Usage Other')}</th>
	%endif
	<th class="RevTitleBox">${_('Action')}</th>
</tr>

%for term in compliancelist:
<tr>
	<td><span${' class="ui-state-highlight"' if term.PreferredTerm else ''|n}>${term.Code}</span></td>
	<td>${term.Term}</td>
	<td>
	%if term.UsageCountLocal > 0:
		<a href="${makeLink('/results.asp',dict(TMCR='on',incDel='on',TMC=term.Code,Shared='N'))}">${term.UsageCountLocal}</a>
	%else:
		${term.UsageCountLocal}
	%endif
	</td>
	%if request.dboptions.OtherMembersActive and act_global:
	<td>
	%if term.UsageCountOther > 0:
		<a href="${makeLink('/results.asp',dict(TMCR='on',incDel='on',TMC=term.Code, Shared='Y'))}">${term.UsageCountOther}</a>
	%else:
		${term.UsageCountOther}
	%endif
	</td>
	%endif
	<td>
%if ((term.AutoFixCode is not None and term.UsageCountLocal) or term.Active==0 or term.UsageCountLocal+term.UsageCountOther==0):
	${renderer.ms_checkbox('AutoFixList', term.Code, id='AutoFixList_'+term.Code)}
%endif
%if (term.AutoFixCode is not None):
	<img src="${request.static_url('cioc:images/rollup.gif')}" width="15" height="15" border="0" alt="${_('Roll-up Term')}"> <span class="ui-state-highlight" title="${term.AutoFixTerm}">${term.AutoFixCode}</span>
%elif (term.PreferredTerm==0 and term.UsageCountLocal+term.UsageCountOther==0 and term.OrphanWarning==1):
	<img src="${request.static_url('cioc:images/redx.gif')}" width="15" height="15" border="0" alt="${_('Dectivate')}"> ${_('Deactivate')} <em>(${_('No Preferred Term available!')})</em>
%elif (term.PreferredTerm==0 and term.UsageCountLocal+term.UsageCountOther==0):
	<img src="${request.static_url('cioc:images/redx.gif')}" width="15" height="15" border="0" alt="${_('Dectivate')}"> ${_('Deactivate')}
%elif (term.Active==0):
	<img src="${request.static_url('cioc:images/greencheck.gif')}" width="15" height="15" border="0" alt="${_('Activate')}"> ${_('Activate')}
%else:
	<em>${_('Evaluation Required')}</em>
%endif
</td>
</tr>
%endfor
</table>
</div>
<p>
	<input type="submit" value="${_('Perform Selected Changes')}" class="btn btn-default">
	<input type="reset" value="${_('Reset')}" class="btn btn-default">
</p>
</form>
%else:
<p><em>${_('Fully Compliant, or no Preferred Term list has been set.')}</em></p>
%endif

<%def name="bottomjs()">
<script type="text/javascript">
jQuery(function($) {
	$('.check-all').click(function() {
		$(this).parent().parent().find('input[type=checkbox]').prop('checked', true);
		return false;
	})
		
	$('.uncheck-all').click(function() {
		$(this).parent().parent().find('input[type=checkbox]').prop('checked', false);
		return false;
	})
})
</script>
</%def>

