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

<% HasOtherMembersActive = request.dboptions.OtherMembersActive %>
<% SuperUserGlobal = request.user.cic.SuperUserGlobal %>
<% SuperUser = request.user.cic.SuperUser %>

<h2>${_('Manage Publications')}</h2>
<p style="font-weight:bold">[ <a href="${request.passvars.route_path('cic_publication', action='edit')}">${_('Add New Publication')}</a> 
| <a href="${request.passvars.route_path('cic_publication_index', _query=[('PrintMd', 'on')])}" target="_blank">${_('Print Version (New Window)')}</a> 
%if not SuperUserGlobal:
| <a href="${request.passvars.route_path('admin_notices', action='new', _query=[('AreaCode', 'PUBLICATION')])}">${_('Request Change')}</a>
%endif
]</p>

%if pubs:
%if HasOtherMembersActive:
<h3>${_('Publications for %s') % request.dboptions.get_best_lang('MemberNameCIC')}</h3>
<p class="Alert">${_('Note: Counts for "Other Records" reflect all records in this database owned by other CIOC Members, not just those that have been shared with you.')}</p>
%endif

<table class="BasicBorder cell-padding-3">
<thead>
<tr>
	<th class="RevTitleBox">${_('Code')}</th>
	<th class="RevTitleBox">${_('Name')}</th>
	<th class="RevTitleBox">${_('Non-Public')}</th>
	<th class="RevTitleBox">${_('Headings')}</th>
	%if HasOtherMembersActive:
	<th class="RevTitleBox">${_('Local Records')}</th>
	<th class="RevTitleBox">${_('Other Records')}</th>
	<th class="RevTitleBox">${_('Local Views') if SuperUserGlobal else _('Views')}</th>
	%else:
	<th class="RevTitleBox">${_('Records')}</th>
	<th class="RevTitleBox">${_('Views')}</th>
	%endif
	<th class="RevTitleBox">${_('Action')}</th>
</tr>
</thead>
<tbody class="alternating-highlight">
%for pub in pubs:
<tr>
	<td>${pub.PubCode}</td>
	<td>${pub.PubName or ''}</td>
	<td style="text-align:center">${'*' if pub.NonPublic else ''}</td>
	<td style="text-align:center">
	%if pub.HasHeadings:
	<a href="${request.passvars.route_path('cic_generalheading_index', _query=[('PB_ID', pub.PB_ID)])}">${_('view')}</a>
	%endif
	</td>
	<td style="text-align:right">${pub.UsageCountLocal}</td>
	%if HasOtherMembersActive:
	<td style="text-align:right">${pub.UsageCountOther}</td>
	%endif
	<td style="text-align:right">${pub.ViewCountLocal}</td>
	<td style="text-align:right"><a href="${request.passvars.route_path('cic_publication', action='edit', _query=[('PB_ID', pub.PB_ID)])}">${_('Edit')}</a>
	%if SuperUserGlobal and HasOtherMembersActive:
		| <a href="${request.passvars.route_path('cic_publication', action='sharedstate', _query=[('state', 'shared'),('PB_ID', pub.PB_ID)])}">${_('Make Shared')}</a>
	%endif
	</td>
</tr>
%endfor
</tbody>
</table>
%endif

%if shared_pubs:
<h3>${_('Shared Publications')}</h3>

%if SuperUser:
<form action="${request.current_route_url()}" method="post">
<div class="hidden">
${request.passvars.cached_form_vals}
</div>
%endif
<table class="BasicBorder cell-padding-3">
<thead>
<tr>
	<th class="RevTitleBox">${_('Code')}</th>
	<th class="RevTitleBox">${_('Name')}</th>
	<th class="RevTitleBox">${_('Non-Public')}</th>
	<th class="RevTitleBox">${_('Headings')}</th>
	<th class="RevTitleBox">${_('Local Records') if HasOtherMembersActive else _('Records')}</th>
	%if HasOtherMembersActive:
	<th class="RevTitleBox">${_('Other Records')}</th>
	%endif
	<th class="RevTitleBox">${_('Local Views') if (SuperUserGlobal and HasOtherMembersActive) else _('Views')}</th>
%if SuperUserGlobal:
	%if HasOtherMembersActive:
	<th class="RevTitleBox">${_('Other Views')}</th>
	%endif
	<th class="RevTitleBox">${_('Action')}</th>
%endif
%if SuperUser:
	<th class="RevTitleBox">${_('Hide')}</th>
%endif
</tr>
</thead>
<tbody class="alternating-highlight">
%for pub in shared_pubs:
<tr>
	<td>${pub.PubCode}</td>
	<td>${pub.PubName}</td>
	<td style="text-align:center">${'*' if pub.NonPublic else ''}</td>
	<td style="text-align:center">
	%if pub.HasHeadings:
	<a href="${request.passvars.route_path('cic_generalheading_index', _query=[('PB_ID', pub.PB_ID)])}">${_('view')}</a>
		%if not SuperUserGlobal and pub.CanEditHeadingsShared:
		| <a href="${request.passvars.route_path('cic_publication', action='edit', _query=[('PB_ID', pub.PB_ID)])}">${_('edit')}</a>
		%endif
	%endif
	</td>
	<td style="text-align:right">${pub.UsageCountLocal}</td>
	%if HasOtherMembersActive:
	<td style="text-align:right">${pub.UsageCountOther}</td>
	%endif
	<td style="text-align:right">${pub.ViewCountLocal}</td>
	%if SuperUserGlobal:
	%if HasOtherMembersActive:
	<td style="text-align:right">${pub.ViewCountOther}</td>
	%endif
	<td style="text-align:right">
	%if len(pub.InUseByMembers) == 1:
		## NOTE must be 1 because the member that does not have it hidden gets to be the owner of the publication
	<a href="${request.passvars.route_path('cic_publication', action='sharedstate', _query=[('state', 'local'),('PB_ID', pub.PB_ID)])}">${_('Make Local (%s)') % pub.InUseByMembers[0]['MemberName']}</a> |
	%endif
	<a href="${request.passvars.route_path('cic_publication', action='edit', _query=[('PB_ID', pub.PB_ID)])}">${_('Edit')}</a>
	</td>
	%endif
	%if SuperUser:
	<td style="text-align:center">${renderer.ms_checkbox('PubHide', pub.PB_ID, title=_('Hide: ') + pub.PubCode)}</td>
	%endif
</tr>
%endfor
</tbody>
</table>

%if SuperUser:
<br><input type="submit" value="${_('Update')}">
</form>
%endif

%endif

%if other_pubs:
	<p>${_('There are %s publication(s) owned by other members: ') % other_pubs[0]}<a href="${request.passvars.route_path('cic_publication', action='other')}">${_('View')}</a></p>
%endif
