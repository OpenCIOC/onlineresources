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
activationText = {0: _('Inactive'), 1: _('Active'), None: _('Roll-up to Higher-level Term')}
OtherMembersActive = request.dboptions.OtherMembersActive
%>

<p>[ <a href="${makeLink('/tax_mng.asp')}">${_('Return to Manage Taxonomy')}</a> ]</p>
<p class="Info">${_('This report provides recommendations for activating or deactivating Taxonomy Terms based on best practices and current usage.')}</p>
<p>${_('Note that some activation changes are mandatory and will be automatically made when you submit your changes. Other activation changes are optional, and you can uncheck the box next to the change if you do not wish to accept it.')}</p>

<h2>${_('Options')}</h2>
<form action="${request.current_route_path()}" method="get">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="mod" value="on">
</div>
<ul>
	%if request.user.cic.SuperUserGlobal and OtherMembersActive:
	<li>${renderer.checkbox('GlobalActivations', label=_('Show global activations'))}</li>
	%endif
	<li>${renderer.checkbox('InactivateUnused', label=_('Inactivate unused Terms with used terms on the same branch.'))}</li>
	<li>${renderer.checkbox('IncludeShared', label=_('Include Shared Records'))}</li>
	<li>${renderer.checkbox('RollupLowLevelTerms', label=_('Rollup Low Level Terms'))}</li>
	<li>${renderer.checkbox('ExcludeYBranch', label=_('Exclude Y Branch'))}</li>
	<li>${renderer.checkbox('RecommendActivations', label=_('Recommend Activations'))}</li>
</ul>
<input type="submit" value="${_('Change Options')}">
</form>


<form action="${request.current_route_path()}" method="post">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="mod" value="on">
%for k,v in options._asdict().iteritems():
	%if v:
		${renderer.hidden(k, 'on')}
	%endif
%endfor
</div>

%if globaltermchanges:
<h2>${_('Changes to Taxonomy Activations')}</h2>
<p>${_('This section includes mandatory activations (such as for Terms associated with records), as well as recommendations for deactivating terms when there are no records attached and there is already another Term on the same branch that is associated with records.')}</p>
<div>
<p>
<input type="button" class="check-all" value="${_('Check All')}">
<input type="button" class="uncheck-all" value="${_('UnCheck All')}">
</p>
<table class="BasicBorder cell-padding-3">
<tr>
	<th></th>
	<th>${_('Code')}</th>
	<th>${_('Term')}</th>
	<th>${_('Action')}</th>
</tr>

%for term in globaltermchanges:
<tr>
	<td>
%if (term.NewActivation==0 or term.NewActivation is None):
	${renderer.ms_checkbox('InactivateRollupIDList', term.Code, id='InactivateRollupIDList_'+term.Code, title=_('Select: ') + term.Code)}</td>
%endif
	</td>
	<td><span${' class="ui-state-highlight"' if term.PreferredTerm else ''|n}>${term.Code}</span></td>
	<td>${term.Term}</td>
	<td>${activationText[term.NewActivation]}</td>
</tr>
%endfor
</table>
</div>
%endif

%if localtermchanges:
<h2>${_('Changes to Local Activations')}</h2>
<p>${_('This section includes mandatory activations (such as for Terms associated with records), as well as recommendations for deactivating terms when there are no records attached and there is already another Term on the same branch that is associated with records.')}</p>
<div>
<p>
<input type="button" class="check-all" value="${_('Check All')}">
<input type="button" class="uncheck-all" value="${_('UnCheck All')}">
</p>
<table class="BasicBorder cell-padding-3">
<tr>
	<th>&nbsp;</th>
	<th>${_('Code')}</th>
	<th>${_('Term')}</th>
	<th>${_('Action')}</th>
</tr>

%for term in localtermchanges:
<tr>
	<td>
%if (term.NewActivation==0 or term.NewActivation is None):
	${renderer.ms_checkbox('InactivateRollupIDList', term.Code, id='InactivateRollupIDList_'+term.Code, title=_('Select: ') + term.Code)}
%endif
	<td><span${' class="ui-state-highlight"' if term.PreferredTerm else ''|n}>${term.Code}</span></td>
	<td>${term.Term}</td>
	<td>${activationText[term.NewActivation]}</td>
</tr>
%endfor
</table>
</div>
%endif

%if activationsuggestions:
<h2>${_('Activation Suggestions')}</h2>
<p>${_('This section includes terms on branches where no other activation exists. Suggestions are only made for Terms at level 3 and below.')}</p>
<div>
<p>
<input type="button" class="check-all" value="${_('Check All')}">
<input type="button" class="uncheck-all" value="${_('UnCheck All')}">
</p>
<table class="BasicBorder cell-padding-3 clear-line-below">
<tr>
	<th>&nbsp;</th>
	<th>${_('Code')}</th>
	<th>${_('Term')}</th>
</tr>

%for term in activationsuggestions:
<tr>
	<td>${renderer.ms_checkbox('RecommendActivationIDList', term.Code, id='RecommendActivationIDList_'+ term.Code, title=_('Select: ') + term.Code)}</td>
	<td><span${' class="ui-state-highlight"' if term.PreferredTerm else ''|n}>${term.Code}</span></td>
	<td>${term.Term}</td>
</tr>
%endfor
</table>
</div>
%endif

<p>
<input type="submit" value="${_('Perform All Selected and Mandatory Changes')}"> <input type="reset" value="${_('Reset')}">
</p>
</form>

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

