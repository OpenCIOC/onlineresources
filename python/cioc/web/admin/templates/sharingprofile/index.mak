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

<%
route_path = request.passvars.route_path
types = [(_('My Profiles'), my_profiles, _('This area is for records you share with others.'), True),
		(_('Partner Profiles'), partner_profiles, _('This area is for records parters share with you.'), False)]
%>

<p style="font-weight:bold">[
<a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a>
| <a href="${route_path('admin_sharingprofile', action='add', _query=[('DM', domain.id)])}">${_('Add New Sharing Profile')}</a>
]</p>

%for title, profiles, tagline, add in types:

<h3>${title}</h3>
<p class="SmallNote">${tagline}</p>
%if profiles:
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox">${_('Name')}</th>
	<th class="RevTitleBox">${_('Status')}</th>
	<th class="RevTitleBox">${_('Member')}</th>
	<th class="RevTitleBox">${_('Records In (Total)')}</th>
	<th class="RevTitleBox">${_('Records In (Deleted)')}</th>
	<th class="RevTitleBox">${_('Action')}</th>
</tr>
%for profile in profiles:
<tr>
	<td>${profile.Name}</td>
	<td>
	%if not profile.Active and profile.RevokedDate:
		${_('Revoked')}
	%elif profile.AcceptedDate:
		${_('Active')}
	%elif profile.ReadyToAccept:
		${_('Awaiting Response')}
	%else:
		${_('Not Submitted')}
	%endif
	</td>
	<td>${profile.MemberName}</td>
	<td>${profile.RecordsInTotal}</td>
	<td><span class="${'Alert' if profile.RecordsInDeleted > 0 else ''}">${profile.RecordsInDeleted}</span></td>
	<td>
	<a href="${route_path('admin_sharingprofile', action='edit', _query=[('ProfileID', profile.ProfileID), ('DM', domain.id)])}">${_('Edit')}</a> 
	%if add:
	| <a href="${route_path('admin_sharingprofile', action='add', _query=[('ProfileID', profile.ProfileID), ('DM', domain.id)])}">${_('Copy')}</a>
	%endif
	</td>
</tr>
%endfor
</table>
<br>
%else:
<p><em>${_('There are no profiles.')}</em></p>
%endif

%endfor
