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

%if _context.addable:
<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
%endif

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
	<td class="FieldLabelLeft">${_('Info')}</td>
	<td>${_('%d records will be added to this Sharing Profile.') % add_info.WillBeAdded}
	%if add_info.AlreadyAdded:
		${_('%d records will not be added because they are already included in this Sharing Profile.') % add_info.AlreadyAdded}
	%endif
	%if add_info.OtherProfile:
		${_('%d records will not be added because they are included in another Sharing Profile with this Member.') % add_info.OtherProfile}
	%endif
	</td>
</tr>
%if _context.addable:
<tr>
	<td class="FieldLabelLeft">${_('Revocation Period')}</td>
	<td>
    ${_('The revocation period is %d day(s).') % profile.RevocationPeriod}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('I Understand')}</td>
	<td>
	<p class="Alert">
    <label><input type="checkbox" class="i-understand"> ${_('I understand that the selected records will immediately become available to my Partner under the terms of this Sharing agreement.')}</label>
	</p>
	<p class="Alert">
    <label><input type="checkbox" class="i-understand"> ${_('I understand that, once added, I will not have the ability to remove the records again immediately; I must wait until the revocation period defined by this agreement has passed.')}</label>
	</p>
	</td>
</tr>
%endif
<tr>
	<td colspan="2">
	<form action="${request.route_path('admin_sharingprofile', action='records')}" method="post">
	<div class="hidden">
	${request.passvars.cached_form_vals |n}
	<input type="hidden" name="ProfileID" value="${ProfileID}">
	<input type="hidden" name="DM" value="${domain.id}">
	<input type="hidden" name="confirmed" value="on">
	<input type="hidden" name="IDList" value="${IDList}">
	</div>
	<input type="submit" value="${_('Add Records to Sharing Profile')}" ${'disabled' if _context.addable else ''} id="submit-data">
	</form>
	</td>
</tr>
</table>

%if _context.addable:
</div>
%endif

<%def name="bottomjs()">
%if _context.addable:
<script type="text/javascript">
jQuery(function($) {
	var submitbutton = $('#submit-data').prop('disabled', true),
		checkboxes = $('.i-understand').click(function() {
			submitbutton.prop('disabled', checkboxes.is(':not(:checked)'));
		});
})
</script>
%endif
</%def>
