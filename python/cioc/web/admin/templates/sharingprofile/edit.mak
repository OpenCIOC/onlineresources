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


<%! 
from itertools import groupby
from operator import attrgetter
from cioc.core import constants as const, syslanguage
%>


<%inherit file="cioc.web:templates/master.mak" />
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_sharingprofile_index', _query=dict(DM=domain.id))}">${_('Return to Sharing Profiles')}</a> ]</p>

<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">

<form method="post" action="${request.route_path('admin_sharingprofile', action=action)}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
<input type="hidden" name="DM" value="${domain.id}">
%if action == 'edit':
<input type="hidden" name="ProfileID" value="${ProfileID}">
%endif
</div>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('Edit Sharing Profile') if action == 'edit' else _('Add Sharing Profile')}</th></tr>
%if action == 'edit' and context.get('profile') is not None:
${self.makeMgmtInfo(profile)}
%endif
%if action == 'edit':
<tr>
	<td class="FieldLabelLeft">${_('Records')}</td>
	<td><a href="${request.passvars.route_path('admin_sharingprofile', action='records', _query=[('DM', domain.id), ('ProfileID', _context.ProfileID)])}">${_('View records associated with this profile (%d)') % profile.RecordCount}</a></td>
</tr>
%endif
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="FieldLabelLeft">${renderer.label("descriptions." +lang.FormCulture + ".Name", _('Name') + " (" + lang.LanguageName + ")")}</td>
	<td>${renderer.errorlist("descriptions." +lang.FormCulture + ".Name")}
	${renderer.text("descriptions." +lang.FormCulture + ".Name", maxlength=50)}</td>
</tr>
%endfor
<tr>
	<td class="FieldLabelLeft">${renderer.label('share_member_id', _('Partner Member'))}</td>
	<td>${renderer.errorlist("profile.ShareMemberID")}
    ${renderer.select('profile.ShareMemberID', members, id="share_member_id")}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can Update Records')}</td>
	<td>${renderer.errorlist("profile.CanUpdateRecords")}
    ${renderer.checkbox('profile.CanUpdateRecords', label=_('The partner member may update records.'))}
	<p>${_('Limit updating records to the following languages (<strong>optional</strong>)')|n}:
		${renderer.errorlist("profile.EditLangs")}
		%for culture in syslanguage.active_record_cultures():
		<br>${renderer.ms_checkbox('profile.EditLangs', culture, label=culture_map[culture].LanguageName)}
		%endfor
	</p>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can Use Print Tools')}</td>
	<td>${renderer.errorlist("profile.CanUsePrint")}
    ${renderer.checkbox('profile.CanUsePrint', label=_('Records can be used in print tools by the partner member.'))}</td>
</tr>
%if domain.id==const.DM_CIC:
<tr>
	<td class="FieldLabelLeft">${_('Can Export Records')}</td>
	<td>${renderer.errorlist("profile.CanUseExport")}
    ${renderer.checkbox('profile.CanUseExport', label=_('Records can be exported by the partner member.'))}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can Update Publications')}</td>
	<td>${renderer.errorlist("profile.CanUpdatePubs")}
    ${renderer.checkbox('profile.CanUpdatePubs', label=_('The partner member may add/remove/update publication data.'))}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can View Private Records')}</td>
	<td>${renderer.errorlist("profile.CanViewPrivate")}
    ${renderer.checkbox('profile.CanViewPrivate', label=_('Private data is accessible, if a privacy profile is assigned to the record.'))}</td>
</tr>
%endif
<tr>
	<td class="FieldLabelLeft">${_('Can View Feedback')}</td>
	<td>${renderer.errorlist("profile.CanViewFeedback")}
    ${renderer.checkbox('profile.CanViewFeedback', label=_('The partner member may view feedback for the record. Note that users who can update a record can always view the feedback for that record.'))}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('profile.RevocationPeriod', _('Revocation Period'))}</td>
	<td>${renderer.errorlist("profile.RevocationPeriod")}
    ${renderer.text('profile.RevocationPeriod', maxlength=3)} ${_('days')}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Views')}</td>
	<td>
	${renderer.radio('profile.CanUseAnyView', 'Y', label=_("Records can be used in any of the partner member's views."), id='profile_CanUseAnyView_Y')}
	<br>${renderer.radio('profile.CanUseAnyView', 'N', label=_("Records can be used in the following partner member's views:"), id='profile_CanUseAnyView_N')}

	<div id="views">
	%for member_id, group in groupby(view_descs, key=attrgetter('MemberID')):
		<div id="views_${member_id}" class="hidden viewslist" data-member="${member_id}">
		%for view in group:
	<br>${renderer.ms_checkbox('profile.Views', str(view.ViewType), label=_('#%d - %s') % (view.ViewType, view.ViewName), id='view_' + str(view.ViewType))}
		%endfor
		</div>
	%endfor
	</div>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Fields')}</td>
	<td>
		%if always_shared_fields:
		<h4>${_('The Following Fields are shared automatically, or are Member-specific:')}</h4>
		<ul>
		%for field in always_shared_fields:
			<li${' style=font-style:italic' if field.Generated else ''}>${field.FieldDisplay}</li>
		%endfor
		</ul>
		%endif
		<h4>${_('Make available for the following fields:')}</h4>
		<p><input type="button" value="${_('Check All')}" id="field-check-all"> <input type="button" value="${_('UnCheck All')}" id="field-uncheck-all"></p>
		%for field in field_descs:
		<br>${renderer.ms_checkbox('profile.Fields', str(field.FieldID), label=field.FieldDisplay, id='field_' + str(field.FieldID))}
		%endfor
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${renderer.label('profile.NotifyEmailAddresses', _('Email Notifications'))}</td>
	<td>${renderer.errorlist("profile.NotifyEmailAddresses")}
	${renderer.text("profile.NotifyEmailAddresses", maxlength=1000)}
	</td>
</tr>
<tr>
	<td colspan="2">
	<input type="submit" name="Submit" value="${_('Add') if action=='add' else _('Update')}"> 
	%if action != 'add':
	<input type="submit" name="Delete" value="${_('Delete')}" href="${request.passvars.route_path('admin_sharingprofile', action='delete', _query=[('DM', domain.id), ('ProfileID', ProfileID)])}" class="nav-on-click"> 
	<input type="submit" name="Send" value="${_('Send to Partner')}" href="${request.passvars.route_path('admin_sharingprofile', action='send', _query=[('DM', domain.id), ('ProfileID', ProfileID)])}" class="nav-on-click">
	%endif
	<input type="reset" value="${_('Reset Form')}"></td>
</tr>
</table>

</form>
</div>

<%def name="bottomjs()">
<script type="text/javascript">
jQuery(function($) {
	var share_member_id = $('#share_member_id').val();
	$('.viewslist').each(function() {
		var el = $(this), member_id = el.data('member');
		if (member_id.toString() === share_member_id) {
			el.removeClass('hidden');
		} 
	});

	$('.nav-on-click').click(function() {
		window.location.href = $(this).attr('href');
		return false;
	});

	$('#field-check-all').click(function() {
		$(this).parents('td').first().find('input[type=checkbox]').prop('checked', true);
		return false;
	})
		
	$('#field-uncheck-all').click(function() {
		$(this).parents('td').first().find('input[type=checkbox]').prop('checked', false);
		return false;
	})
})
</script>
</%def>
