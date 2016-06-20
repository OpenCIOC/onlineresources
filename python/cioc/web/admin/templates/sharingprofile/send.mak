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

<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('Send Profile To Partner Member for Review')}</th></tr>
${self.makeMgmtInfo(profile)}

<tr>
	<td class="FieldLabelLeft">${_('Profile Name')}</td>
	<td>${profile.Name}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Partner Member')}</td>
	<td>${profile.ReceivingMemberName}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Revocation Period')}</td>
	<td>
	${_('The revocation period is %d day(s).') % profile.RevocationPeriod}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('I Understand')}</td>
	<td>
	<p class="Alert"><label><input type="checkbox" class="i-understand"> ${_('I understand this Sharing agreement will not be active until it is accepted by my partner.')}</label></p>
	<p class="Alert"><label><input type="checkbox" class="i-understand"> ${_('I understand that, once sent, the only changes that can be made to this Sharing Profile are adding new Views, adding new Fields, and adding and removing records.')}</label></p>
	<p class="Alert"><label><input type="checkbox" class="i-understand"> ${_('I understand that, once accepted, I will not be able to revoke this agreement immediately; I will need to wait until the revocation period has passed.')}</label></p>
	</td>
</tr>
<tr>
	<td colspan="2">
	<form action="${request.route_path('admin_sharingprofile', action='send')}" method="post">
	<div class="hidden">
	${request.passvars.cached_form_vals |n}
	<input type="hidden" name="ProfileID" value="${ProfileID}">
	<input type="hidden" name="DM" value="${domain.id}">
	</div>
	<input type="submit" value="${_('Send Sharing Agreement To Partner Member')}" disabled id="submit-data">
	</form>
	</td>
</tr>
</table>
</div>

<%def name="bottomjs()">
<script type="text/javascript">
jQuery(function($) {
	var submitbutton = $('#submit-data').prop('disabled', true),
		checkboxes = $('.i-understand').click(function() {
			submitbutton.prop('disabled', checkboxes.is(':not(:checked)'));
		});
})
</script>
</%def>
