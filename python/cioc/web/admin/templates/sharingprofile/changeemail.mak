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

from cioc.core import constants
DM_CIC = constants.DM_CIC
DM_VOL = constants.DM_VOL

%>
<%inherit file="cioc.web:templates/master.mak" />
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> 
| <a href="${request.passvars.route_path('admin_sharingprofile_index', _query=dict(DM=domain.id))}">${_('Return to Sharing Profiles')}</a>
| <a href="${request.passvars.route_path('admin_sharingprofile', action='edit', _query=dict(DM=domain.id, ProfileID=_context.ProfileID))}">${_('Return to Sharing Profile - %s') % profile.Name}</a>
]</p>

<form action="${request.route_path('admin_sharingprofile', action='changeemail')}" method="post">
${request.passvars.cached_form_vals |n}
<input type="hidden" name="ProfileID" value="${ProfileID}">
<input type="hidden" name="DM" value="${domain.id}">
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
<tr>
	<td class="FieldLabelLeft">${_('Email Notifications')}</td>
	<td>
	${renderer.errorlist("ShareNotifyEmailAddresses")}
	${renderer.text("ShareNotifyEmailAddresses", maxlength=1000)}
	</td>
</tr>
<tr>
	<td colspan="2">
	<input type="submit" id="submit-data" value="${_('Update Email Settings')}">
	</td>
</tr>
</table>

</form>
