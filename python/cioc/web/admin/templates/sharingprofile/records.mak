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
from operator import attrgetter
import datetime

from cioc.core import constants
DM_CIC = constants.DM_CIC
DM_VOL = constants.DM_VOL

%>
<%inherit file="cioc.web:templates/master.mak" />
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> 
| <a href="${request.passvars.route_path('admin_sharingprofile_index', _query=dict(DM=domain.id))}">${_('Return to Sharing Profiles')}</a>
| <a href="${request.passvars.route_path('admin_sharingprofile', action='edit', _query=dict(DM=domain.id, ProfileID=_context.ProfileID))}">${_('Return to Sharing Profile - %s') % profile.Name}</a>
]</p>

<% editable = _context.editable or _context.addable or _context.partnerrecordrevoke %>
%if editable:
<form action="${request.route_path('admin_sharingprofile', action='remove_records')}" method="post">
${request.passvars.cached_form_vals |n}
<input type="hidden" name="ProfileID" value="${ProfileID}">
<input type="hidden" name="DM" value="${domain.id}">
%endif
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox">${_('Review Sharing Profile')}</th></tr>
${self.makeMgmtInfo(profile)}

<tr>
	<td class="FieldLabelLeft">${_('Profile Name')}</td>
	<td>${profile.Name}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Partner Member')}</td>
	<td>
	%if profile.MemberID==request.dboptions.MemberID:
		${profile.ReceivingMemberName}
	%else:
		${profile.SharingMemberName}
	%endif
	</td>
</tr>
%if not _context.addable:
<tr>
	<td class="FieldLabelLeft">${_('Revocation Period')}</td>
	<td>${_('The revocation period is %d day(s).') % profile.RevocationPeriod}</td>
</tr>
%endif
%if request.dboptions.MemberID==profile.MemberID and editable:
<tr>
	<td class="FieldLabelLeft">${_('Add Records')}</td>
	<td><a href="${request.passvars.makeLink('~/results.asp', [('ShareIDx', str(_context.ProfileID))])}">${_('View records not in this profile')}</a>
	<br>${_('Records can be added through the "Action on Selected Records" menu on the search results pages.')}</td>
</tr>
%endif
<tr>
	<td class="FieldLabelLeft">${_('Records')}</td>
	<td>
	%if records:
	${_('Available for the following records:')}<br>
	<table class="BasicBorder cell-padding-3">
	<tr>
	%if editable:
	<td class="FieldLabelLeft">${_('Remove')}</td>
	%endif
	
	<td class="FieldLabelLeft">
	%if domain.id == DM_CIC:
		${_('Record #')}
	%else:
		${_('ID')}
	%endif
	</td>
	<td class="FieldLabelLeft">${('Organization Name(s)')}</td>
	%if domain.id == DM_VOL:
	<td class="FieldLabelLeft">${_('Position Title')}</td>
	%endif
	</tr>
		<% 
		if domain.id == DM_CIC:
			id_name = 'NUM'
			getter = attrgetter('NUM', 'ORG_NAME_FULL')
			makeDetailsLink = request.passvars.makeDetailsLink
			linkgen = lambda x: makeDetailsLink(record.NUM)
		else:
			id_name = 'VNUM'
			getter = attrgetter('VNUM', 'ORG_NAME_FULL', 'POSITION_TITLE') 
			makeVOLDetailsLink = request.passvars.makeVOLDetailsLink
			linkgen = lambda x: makeVOLDetailsLink(x.VNUM)
		is_share_member = request.dboptions.MemberID == profile.ShareMemberID
		now = datetime.datetime.now()
		%>
		%for record in records:
	<tr>
		<% fields = getter(record) %>
		%if editable:
		<td>
			%if not record.RevokedDate or (is_share_member and record.RevokedDate > now):
			${renderer.ms_checkbox(id_name, str(fields[0]), id='_'.join((id_name, str(fields[0]))))}
			%endif
			%if record.RevokedDate:
			${format_date(record.RevokedDate)}
			%endif
		</td>
		%endif
		%for i,field in enumerate(fields):
		<td>
			%if not i and record.CAN_SEE:
				<a href="${linkgen(record)}">${field}</a>
			%else:
				${field}
			%endif
		</td>
		%endfor
	</tr>
		%endfor
	</table>
	%else:
	<em>${_('There are no records in this profile.')}</em>
	%endif
	</td>
</tr>
%if ( _context.addable or _context.partnerrecordrevoke) and records:
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
%if editable and records:
<tr>
	<td colspan="2">
	<input type="submit" id="submit-data" value="${_('Remove selected records from Sharing Profile')}" ${'disabled' if _context.addable or _context.partnerrecordrevoke else '' }>
	</td>
</tr>
%endif
</table>

%if editable:
</form>
%endif
<%def name="bottomjs()">
%if _context.addable or _context.partnerrecordrevoke:
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
%endif
</%def>
