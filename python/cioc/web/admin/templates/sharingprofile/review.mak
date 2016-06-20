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
from markupsafe import Markup
%>


<%inherit file="cioc.web:templates/master.mak" />
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_sharingprofile_index', _query=dict(DM=domain.id))}">${_('Return to Sharing Profiles')}</a> ]</p>

%if profile.ReadyToAccept:
<form action="${request.route_path('admin_sharingprofile', action='accept')}" method="post">
<div class="hidden">
${request.passvars.cached_form_vals |n}
<input type="hidden" name="ProfileID" value="${ProfileID}">
<input type="hidden" name="DM" value="${domain.id}">
</div>
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
	<td>${profile.MemberName}</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Records')}</td>
	<td><a href="${request.passvars.route_path('admin_sharingprofile', action='records', _query=[('DM', domain.id), ('ProfileID', _context.ProfileID)])}">${_('View records associated with this profile (%d)') % _context.profile.RecordCount}</a></td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can Update Records')}</td>
	<td>
	%if profile.CanUpdateRecords:
		%if not edit_languages:
		${_('You <strong>may</strong> update records.')|n}
		%else:
			${Markup(_('You <strong>may</strong> update records in %s.')) % ' or '.join(culture_map[c[0]].LanguageName for c in edit_languages)}
		%endif
		
	%else:
		${_('You <strong>may not</strong> update records.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can Use Print Tools')}</td>
	<td>
	%if profile.CanUsePrint:
		${_('You <strong>may</strong> use records in print tools.')|n}
	%else:
		${_('You <strong>may not</strong> use records in print tools.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can Export Records')}</td>
	<td>
	%if profile.CanUseExport:
    ${_('You <strong>may</strong> export records.')|n}
	%else:
    ${_('You <strong>may not</strong> export records.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can Update Publications')}</td>
	<td>
	%if profile.CanUpdatePubs:
    ${_('You <strong>may</strong> add/remove/update publication data.')|n}
	%else:
    ${_('You <strong>may not</strong> add/remove/update publication data.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can View Feedback')}</td>
	<td>
	%if profile.CanViewFeedback:
    ${_('You <strong>may</strong> view feedback for the record.')|n}
	%else:
    ${_('You <strong>may not</strong> view feedback for the record.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Can View Private Records')}</td>
	<td>
	%if profile.CanViewPrivate:
    ${_('Private data <strong>is</strong> accessible, if a privacy profile is assigned to the record.')|n}
	%else:
    ${_('Private data <strong>is not</strong> accessible, if a privacy profile is assigned to the record.')|n}
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Revocation Period')}</td>
	<td>
    ${_('The revocation period is %d day(s).') % profile.RevocationPeriod}
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Email Notifications')}</td>
	<td>
	%if profile.ReadyToAccept:
	${renderer.errorlist("ShareNotifyEmailAddresses")}
	${renderer.text("ShareNotifyEmailAddresses", maxlength=1000)}
	%else:
		${_('Notifications about this sharing profile will be sent to:')} <strong>${profile.ShareNotifyEmailAddresses}</strong>
		<a href="${request.passvars.route_path('admin_sharingprofile', action='changeemail', _query=[('DM', domain.id), ('ProfileID', _context.ProfileID)])}">${_('[Change]')}</a>
	%endif
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft">${_('Views')}</td>
	<td>
	%if profile.CanUseAnyView:
	${_("You can use records in <strong>any</strong> of your views.")|n}
	%else:
	${_("You can use records in the following of your views:")}<br>

	%for view in views:
	<br>${_('#%d - %s') % (view.ViewType, view.ViewName)}
	%endfor
	%endif
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
	<h4>${_('Available for the following fields:')}</h4>
	<ul>
		%for field in fields:
		<li>${field.FieldDisplay}</li>
		%endfor
	</ul>
	</td>
</tr>
<tr>
	<td colspan="2">
	%if profile.ReadyToAccept:
	<input type="submit" value="${_('Accept Sharing Agreement')}">
	%elif profile.Active and not profile.RevokedDate:
	<form action="${request.route_path('admin_sharingprofile', action='revoke')}" method="get">
	<div class="hidden">
	${request.passvars.cached_form_vals |n}
	<input type="hidden" name="ProfileID" value="${ProfileID}">
	<input type="hidden" name="DM" value="${domain.id}">
	</div>
	<input type="submit" value="${_('End Sharing Agreement')}">
	<br><span class="SmallNote">${_('You can end the agreement immediately regardless of the revocation period.')}</span>
	</form>
	%endif
	</td>
</tr>
</table>
%if profile.ReadyToAccept:
	</form>
%endif
