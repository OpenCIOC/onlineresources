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
from cioc.core import constants as const
%>
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_sharingprofile_index', _query=dict(DM=domain.id))}">${_('Return to Sharing Profiles')}</a> ]</p>

%if _context.addable:
<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
%endif

<form action="${request.route_path('admin_sharingprofile', action='remove_records')}" method="post">
<div class="hidden">
	${request.passvars.cached_form_vals |n}
	<input type="hidden" name="ProfileID" value="${ProfileID}">
	<input type="hidden" name="DM" value="${domain.id}">
	<input type="hidden" name="${'NUM' if domain.id == const.DM_CIC else 'VNUM'}" value="${IDList}">
</div>
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
	<td>${_('%d records will be removed from this Sharing Profile.') % remove_info.WillBeRemoved}
	%if remove_info.AlreadyRemoved:
		${_('%d records will not be removed because they have already been removed from this Sharing Profile') % remove_info.AlreadyRemoved}
	%endif
	</td>
</tr>
%if ( _context.addable or _context.partnerrecordrevoke):
<tr>
	<td class="FieldLabelLeft">${_('I Understand')}</td>
	<td>
	%if request.context.partnerrecordrevoke:
	<p class="Alert">
    <label><input type="checkbox" class="i-understand"> ${_('By sumbitting these records for removal, I understand that selected records under this agreement will become unavailable to me as of the date I select below.')}</label>
	</p>
	<p class="Alert">
    <label><input type="checkbox" class="i-understand"> ${_('I understand that I cannot restore these records to the Sharing Profile myself, and will need to contact my partner if I wish to restore them.')}</label>
	</p>
	%else:
	<p class="Alert">
    <label><input type="checkbox" class="i-understand"> ${_('By submitting these records for removal, I understand that selected records under this agreement will become unavailable to my partner as of the date I select below.')}</label>
	</p>
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Revocation Date')}</td>
	<td>
	${renderer.errorlist('RevocationDate')}
    ${_('The revocation period is <strong>%d</strong> day(s). Select a date on or after <strong>%s</strong>.') % (profile.RevocationPeriod, format_date(min_date))|n}
	<br>${renderer.date('RevocationDate')}
	</td>
</tr>
%endif
<tr>
	<td colspan="2">
	<input type="submit" value="${_('Revoke Records from Sharing Profile')}" ${'disabled' if _context.addable else ''} id="submit-data">
	</td>
</tr>
</table>
</form>

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
