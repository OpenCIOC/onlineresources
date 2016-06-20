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
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_sharingprofile_index', _query=dict(DM=domain.id))}">${_('Return to Sharing Profiles')}</a> ]</p>

<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">

<form action="${request.route_path('admin_sharingprofile', action='revoke')}" method="post">
<div class="hidden">
${request.passvars.cached_form_vals |n}
<input type="hidden" name="ProfileID" value="${ProfileID}">
<input type="hidden" name="DM" value="${domain.id}">
</div>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('End Sharing Agreement with Partner Member')}</th></tr>
${self.makeMgmtInfo(profile)}

<tr>
	<td class="FieldLabelLeft">${_('Profile Name')}</td>
	<td>${profile.Name}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Partner Member')}</td>
	<td>
	%if request.context.addable:
		${profile.ReceivingMemberName}
	%else:
		${profile.SharingMemberName}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('I Understand')}</td>
	<td>
	%if request.context.partnerreview:
	<p class="Alert"><label><input type="checkbox" class="i-understand"> ${_('By revoking the agreement, I understand that all records under this agreement will become unavailable to me as of the date I select below.')}</label></p>
	%else:
	<p class="Alert"><label><input type="checkbox" class="i-understand"> ${_('By revoking the agreement, I understand that all records under this agreement will become unavailable to my partner as of the date I select below.')}</label></p>
	%endif
    <p class="Alert"><label><input type="checkbox" class="i-understand"> ${_('I understand that revoking this agreement is permanent. I will not be able to recover or restore this agreement later.')}</label></p>
    <p class="Alert"><label><input type="checkbox" class="i-understand"> ${_('I understand that the records currently associated with this Sharing Profile will be removed from the agreement once it is revoked, and I will no longer have a list of the records available to me.')}</label></p>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Revocation Date')}</td>
	<td>
	${_('The revocation period is <strong>%d</strong> day(s). Select a date on or after <strong>%s</strong>.') % (profile.RevocationPeriod, format_date(min_date))|n}
	<br>${renderer.date('RevocationDate')}
	</td>
</tr>
<tr>
	<td colspan="2">
	<input type="submit" value="${_('End Sharing Agreement With Partner Member')}" disabled id="submit-data">
	</td>
</tr>
</table>
</div>

</form>

<%def name="bottomjs()">
<script type="text/javascript">
jQuery(function($) {
	var initialized = false;
	var submitbutton = $('#submit-data').prop('disabled', true),
		checkboxes = $('.i-understand').click(function() {
			submitbutton.prop('disabled', checkboxes.is(':not(:checked)'));
		});
		

	setTimeout(function() {
		$('.DatePicker').datepicker('option', 'minDate', ${profile.RevocationPeriod if request.dboptions.MemberID==profile.MemberID else 0});
	}, 100);
})
</script>
</%def>
