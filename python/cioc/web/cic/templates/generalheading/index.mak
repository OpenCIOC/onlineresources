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
<tr>
	%for culture in active_cultures:
		<% lang = culture_map[culture] %>
		<th>${_('Name')} (${lang.LanguageName})</th>
	%endfor
	<th>${_('Non-Public')}</th>
	<th>${_('Used')}</th>
	<th>${_('Heading Group')}</th>
	<th>${_('Related Headings')}</th>
	%if HasOtherMembersActive:
	<th>${_('Local Records')}</th>
	<th>${_('Other Records')}</th>
		%if SuperUserGlobal:
	<th>${_('Local Quick List')}</th>
	<th>${_('Other Quick List')}</th>
		%else:
	<th>${_('Quick List')}</th>
		%endif
	%else:
	<th>${_('Records')}</th>
	<th>${_('Quick List')}</th>
	%endif
</tr>

%for heading in headings:
<tr>
	%for culture in active_cultures:
		<td>${heading.Descriptions.get(culture.replace('-', '_'), dict()).get('Name') or ''}</td>
	%endfor
	<td style="text-align:center">${'*' if heading.NonPublic else ''}</td>
	<td style="text-align:center">${'*' if heading.Used else ('T' if heading.Used is None else '')}</td>
	<td>${heading.HeadingGroupName or ''}</td>
	<td>${heading.RelatedHeadings or ''}</td>
	<td style="text-align:right">${heading.UsageCountLocal}</td>
	%if HasOtherMembersActive:
	<td style="text-align:right">${heading.UsageCountOther}</td>
	%endif
	<td style="text-align:right">${heading.QuickListCountLocal}</td>
	%if HasOtherMembersActive and SuperUserGlobal:
	<td style="text-align:right">${heading.QuickListCountOther}</td>
	%endif
</tr>
%endfor
</table>
