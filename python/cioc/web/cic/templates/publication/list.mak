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
<table class="BasicBorder cell-padding-3">
<thead>
<tr>
	<th>${_('Code')}</th>

	%for culture in active_cultures:
		<% lang = culture_map[culture] %>
		<th>${_('Name')} (${lang.LanguageName})</th>
	%endfor

	<th>${_('Non-Public')}</th>
	%if not pop_mode:
	<th>${_('Headings')}</th>
		%if HasOtherMembersActive:
	<th>${_('Local Records')}</th>
	<th>${_('Other Records')}</th>
	<th>${_('Local Views') if SuperUserGlobal else _('Views')}</th>
			%if SuperUserGlobal:
	<th>${_('Other Views')}</th>
	<th>${_('Local Quick List')}</th>
	<th>${_('Other Quick List')}</th>
			%else:
	<th>${_('Quick List')}</th>
			%endif
		%else:
	<th>${_('Records')}</th>
	<th>${_('Views')}</th>
	<th>${_('Quick List')}</th>
		%endif
	%endif
</tr>
</thead>

<tbody class="alternating-highlight">
%for pub in pubs:
<tr>
	<td${' style=text-decoration:line-through' if pub.Inactive else ''}>${pub.PubCode}</td>

	%for culture in active_cultures:
		<td>${pub.Descriptions.get(culture.replace('-', '_'), dict()).get('Name') or ''}</td>
	%endfor

	<td style="text-align:center">${'*' if pub.NonPublic else ''}</td>
	%if not pop_mode:
	<td style="text-align:right">${pub.HeadingCount}</td>
	<td style="text-align:right">${pub.UsageCountLocal}</td>
		%if HasOtherMembersActive:
	<td style="text-align:right">${pub.UsageCountOther}</td>
		%endif
	<td style="text-align:right">${pub.ViewCountLocal}</td>
		%if SuperUserGlobal and HasOtherMembersActive:
	<td style="text-align:right">${pub.ViewCountOther}</td>
		%endif
	<td style="text-align:right">${pub.QuickListCountLocal}</td>
		%if SuperUserGlobal and HasOtherMembersActive:
	<td style="text-align:right">${pub.QuickListCountOther}</td>
		%endif
	%endif
</tr>
%endfor
</tbody>
</table>

%if pop_mode:
<p align="center">[ <a href="javascript:parent.close()">Close Window</a> ]</p>
%endif

