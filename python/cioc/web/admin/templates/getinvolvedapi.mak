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
<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">

<% agencies = model_state.value('agencies') %>
%if agencies or interests or skills:
<form action="${request.current_route_path()}" method="post">
%endif
<div class="hidden">
${request.passvars.getHTTPVals(bForm=True)}
</div>

%if not agencies:
<p class="Info">${_('No Agencies found.')}</p>
%else:
	<h3>${_('Agency Configuration')}</h3>
	<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox">${_("Agency Code")}</th>
		<th class="RevTitleBox">${_("Get Involved User")}</th>
		<th class="RevTitleBox">${_("Get Involved Token")}</th>
		<th class="RevTitleBox">${_("Get Invovled Site")}</th>
		<th class="RevTitleBox">${_("Community Set")}</th>
	</tr>
	%for i in range(len(model_state.value('agencies'))):
	<tr>
		<% prefix = 'agencies-%d.' %i %>
		<td>
		${model_state.value(prefix + 'AgencyCode')}
		${renderer.errorlist(prefix + 'AgencyCode')}
		${renderer.hidden(prefix + 'AgencyCode')}
		</td>
		<td>
		${renderer.errorlist(prefix + 'GetInvolvedUser')}
		${renderer.text(prefix + 'GetInvolvedUser', size=30, maxlength=100, title=model_state.value(prefix + 'AgencyCode') + _(': Get Involved User'))}
		</td>
		<td>
		${renderer.errorlist(prefix + 'GetInvolvedToken')}
		${renderer.text(prefix + 'GetInvolvedToken', size=44, maxlength=100, title=model_state.value(prefix + 'AgencyCode') + _(': Get Involved Token'))}
		</td>
		<td>
		${renderer.errorlist(prefix + 'GetInvolvedSite')}
		${renderer.select(prefix + 'GetInvolvedSite', [('','')] + gi_sites)}
		</td>
		<td>
		${renderer.errorlist(prefix + 'GetInvolvedCommunitySet')}
		${renderer.select(prefix + 'GetInvolvedCommunitySet', [('','')] + community_sets)}
		</td>
	</tr>
	%endfor
	</table>
%endif

%if interests:
	<h3>${_('Interest Mapping')}</h3>
	<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox">${_("CIOC Interest")}</th>
		<th class="RevTitleBox">${_("Get Involved Interest")}</th>
		<th class="RevTitleBox">${_("Get Involved Skill")}</th>
	</tr>
	<% i = 0 %>
	%for i in range(len(model_state.value('interests') or [])):
	${interest_row(prefix = 'interests-%d.' % i)}
	%endfor
	
	<tr>
	<td colspan="3">
	<button id="add_interest" class='add-row' data-count="${i+1}" data-template-type="interest">${_('Add New Item')}</button>
	</td>
	</tr>
	</table>
%endif
%if skills:
	<h3>${_('Skill Mapping')}</h3>
	<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox">${_("CIOC Skill")}</th>
		<th class="RevTitleBox">${_("Get Involved Interest")}</th>
		<th class="RevTitleBox">${_("Get Involved Skill")}</th>
	</tr>
	<% i = 0 %>
	%for i in range(len(model_state.value('skills') or [])):
	${skill_row(prefix = 'skills-%d.' % i)}
	%endfor
	
	<tr>
	<td colspan="3">
	<button id="add_skill" class='add-row' data-count="${i+1}" data-template-type="skill">${_('Add New Item')}</button>
	</td>
	</tr>
	</table>
%endif


%if agencies or interests or skills:
<br>
<input type="submit" value="${_('Submit')}">
</form>
%endif

</div>

<%def name="interest_row(prefix)">
	<tr>
		<td>
		${renderer.errorlist(prefix + 'AI_ID')}
		${renderer.select(prefix + 'AI_ID', [('', '')] + interests)}
		</td>
		<td>
		${renderer.errorlist(prefix + 'GIInterestID')}
		${renderer.select(prefix + 'GIInterestID', [('','')] + gi_interests)}
		</td>
		<td>
		${renderer.errorlist(prefix + 'GISkillID')}
		${renderer.select(prefix + 'GISkillID', [('','')] + gi_skills)}
		</td>
	</tr>
</%def>

<%def name="skill_row(prefix)">
	<tr>
		<td>
		${renderer.errorlist(prefix + 'SK_ID')}
		${renderer.select(prefix + 'SK_ID', [('', '')] + skills)}
		</td>
		<td>
		${renderer.errorlist(prefix + 'GIInterestID')}
		${renderer.select(prefix + 'GIInterestID', [('','')] + gi_interests)}
		</td>
		<td>
		${renderer.errorlist(prefix + 'GISkillID')}
		${renderer.select(prefix + 'GISkillID', [('','')] + gi_skills)}
		</td>
	</tr>
</%def>


<%def name="bottomjs()">
<script type="text/html" id="new-item-template-interest">
${interest_row('interests-[COUNT].')}
</script>
<script type="text/html" id="new-item-template-skill">
${skill_row('skills-[COUNT].')}
</script>
<script type="text/javascript">
jQuery(function($) {
	$('.add-row').click(function(evt) {
		evt.preventDefault();
		var self = $(this), parent = self.parents('tr').first(), count = self.data('count'),
			templateType = self.data('templateType'),
			row = $($('#new-item-template-' + templateType)[0].innerHTML.replace(/\[COUNT\]/g, count++));


		self.data('count', count);

		parent.before(row);
		return false;
	});
});
</script>
</%def>
