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
<%namespace file="cioc.web.cic:templates/gh_select.mak" import="gh_selector"/>
<%!
from markupsafe import escape_silent as h, Markup
from webhelpers.html import tags
%>

<h2>${_('Update Publication information for %s:') % publication.PubCode}
<br><a href="${request.passvars.makeDetailsLink(NUM, dict(Number= Number) if Number is not None else None)}">${fullorg}</a></h2>

<% 
link_args = {'NUM': NUM}
if Number is not None:
	link_args['Number'] = Number
%>
%if NUM and not request.user.cic.PB_ID:
<p style="font-weight:bold">[ <a href="${request.passvars.makeLink('~/update_pubs.asp', link_args)}">${_('Return to Edit Publications for: %s') % fullorg}</a> ]</p>
%endif

<form method="post" action="${request.route_path('cic_updatepubs', action='edit')}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="NUM" value="${NUM}">
%if Number is not None:
<input type="hidden" name="Number" value="${Number}">
%endif
<input type="hidden" name="BTPBID" value="${BTPBID}">
</div>

%if feedback:

<table class="NoBorder cell-padding-2">
<tr><th colspan="2" align="left" class="Alert">${_('Check Feedback')}</th></tr>

%for i, fb in enumerate(feedback):

	<tr>
	<td class="FieldLabelLeftClr">${_('Feedback #%d (%s):') % (i, fb.LanguageName)}</td>
	<td class="Alert">${_('Submitted By: %s') % fb.SUBMITTED_BY}
	%if fb.SUBMITTED_BY_EMAIL:
	<br>${_('Submitter Email:')} <a href="mailto:${fb.SUBMITTED_BY_EMAIL}">${fb.SUBMITTED_BY_EMAIL}</a>
	%endif
	</td>
		
	</tr>

%endfor

</table>

<p><strong>${_('Delete Feedback')}</strong>
${renderer.radio("DeleteFeedback", 'Y', True, label=_('Yes'))} 
${renderer.radio("DeleteFeedback", 'N', False, label=_('No'))}

%endif #feedback

<div id="ShowFieldUI"></div>

<table class="BasicBorder cell-padding-4">
${self.makeMgmtInfo(publication)}

%for culture in record_cultures:
<% 
lang = culture_map[culture] 
desc = publication_descriptions.get(lang.FormCulture)
%>
<tr>
	<td class="FieldLabelLeft NoWrap">${renderer.label("descriptions." +lang.FormCulture + ".Description", _('Description (%s)') %lang.LanguageName)}</td>
	<td><span class="SmallNote">${_("Maximum 8000 characters.")}</span>
	%if desc and desc.RecordDescription:
	<br><button class="update-description" data-description="${desc.RecordDescription}">${_('Insert Current Description From Record')}</button>
	%endif
	<br>${renderer.errorlist("descriptions." +lang.FormCulture + ".Description")}
	${renderer.textarea("descriptions." +lang.FormCulture + ".Description")}
	%for i, fb in enumerate(feedback):
		%if fb.LangID==lang.LangID and fb.Description:
		<div class="feedback">
			<span class="Info">${_('Feedback #%d (%s):') %(i,lang.LanguageName)}</span> <span class="Alert">${fb.Description}</span>
			<button class="feedback-update" data-description="${fb.Description}">${_('Update')}</button>
		</div>
		%endif
	%endfor
	</td>
</tr>
%endfor
%if generalheadings or taxonomyheadings:
<tr>
	<td class="FieldLabelLeft NoWrap">${_('General Headings')}</td>
	<td>
	%if generalheadings:
		<%call expr="gh_selector('GHID', generalheadings, linked_headings)">
		%for i, fb in enumerate(feedback):
			%if fb.GeneralHeadings:
			<br><span class="Info">${_('Feedback #%d (%s):') %(i,fb.LanguageName)}</span> <span class="Alert">${fb.GeneralHeadings}</span>
			%endif
		%endfor
		</%call>
	%endif
	%if taxonomyheadings:
		<div><br><strong>${_('Existing Taxonomy-Based Headings')}</strong></div>
		<span class="Alert">${_('The Headings below are added automatically based on the Taxonomy Indexing for this record.')}</span>
		<ul>
		%for theading in taxonomyheadings:
			<li>${theading.Name}</li>
		%endfor
		</ul>
	%endif
	</td>
</tr>
%endif
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Update')}">
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>
</form>



<%def name="bottomjs()">
${request.assetmgr.JSVerScriptTag('scripts/displayField.js')}

<script type="text/javascript">
jQuery(function($) {
	$('.update-description').live('click', function() {
		var self = $(this);
		self.siblings('textarea')[0].value = self.data('description');
		return false;
	});
	$('.feedback-update').live('click', function() {
		var self = $(this), parent = self.parent();
		parent.siblings('textarea')[0].value = self.data('description');
		return false;
	});

	$("#ShowFieldUI").load("${request.passvars.makeLink('~/showfields.asp', dict(NUM=NUM))|n} #content_to_insert");
});
</script>
</%def>

