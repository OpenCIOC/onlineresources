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

<p style="font-weight:bold">[ <a href="${request.passvars.route_path('cic_publication_index')}">${_('Back to Publications')}</a> ]</p>

<% SuperUserGlobal = request.user.cic.SuperUserGlobal %>

<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox">${_('Code')}</th>
	<th class="RevTitleBox">${_('Name')}</th>
	<th class="RevTitleBox">${_('Member Name')}</th>
	%if SuperUserGlobal:
	<th class="RevTitleBox">${_('Action')}</th>
	%endif
</tr>

%for pub in pubs:
<tr>
	<td>${pub.PubCode}</td>
	<td>${pub.PubName}</td>
	<td>${pub.MemberName}</td>
	%if SuperUserGlobal:
	<td><a href="${request.passvars.route_path('cic_publication', action='sharedstate', _query=[('state', 'shared'),('PB_ID', pub.PB_ID)])}">${_('Make Shared')}</a></td>
	%endif

</tr>
%endfor
</table>

