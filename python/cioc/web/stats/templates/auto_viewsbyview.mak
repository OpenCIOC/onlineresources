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
from cioc.core import constants as const, listformat
%>

<% makeLink = request.passvars.makeLink %>

<p>[ <a href="${makeLink(link_prefix + "stats.asp")}">${_('Main Stats Page')}</a>
| <a href="${makeLink(link_prefix + "stats2.asp")}">${_('Total Record Use')}</a>
| <a href="${makeLink(link_prefix + "stats3.asp")}">${_('Top 50 Records')}</a>
| <a href="${makeLink(link_prefix + "stats4.asp")}">${_('Use by Agency')}</a>
| <span class="HighLight"><a href="${makeLink(link_prefix + "stats_auto.asp")}">${_('Quick Reports')}</a></span>
| <a href="${makeLink(link_prefix + "stats_delete.asp")}">${_('Delete Old Statistics')}</a>
]</p>

<h2>${renderinfo.page_name}</h2>
<form action="${request.current_route_path()}">
<div style="display:none;">
${request.passvars.cached_form_vals}
</div>
<table class="BasicBorder cell-padding-3">
<tr>
	<td class="FieldLabel">${_('Custom Date Range')}</td>
	<td>
	${renderer.date_search(today=False)}
	</td>
</tr>
%if request.pageinfo.DbArea == const.DM_CIC:
	<tr>
		<td class="FieldLabel">${renderer.label('PBID', _('Publication'))}</td>
		<td>
		${renderer.errorlist('PBID')}
		${renderer.select('PBID', options=[('','')] + listformat.format_pub_list(publist, True, request.viewdata.cic.UsePubNamesOnly))}
		</td>
	</tr>
%endif
</table>
<p>
<input type="submit" name="submit" value="${_('Generate Report')}">
</p>
</form>

%if stat_rows:
	<table class="BasicBorder cell-padding-3">
		<tr class="RevTitleBox">
			<th>
			%if publication_code:
				<span class="HighLight">
				${publication_code}
				%if publication_name:
					<br>${publication_name}
				%endif
				</span>
			%else:
				&nbsp;
			%endif
			</th>
			%for month in months:
			<th colspan="3">${month}</th>
			%endfor
		</tr>
		<tr class="RevTitleBox">
			<th>${_('View Name')}</th>
			%for month in months:
				<th>${_('Logged In')}</th>
				<th>${_('Public')}</th>
				<th>${_('Total')}</th>
			%endfor
		</tr>

	%for viewtype in viewtype_list:
		<tr valign="top">
			<td scope="row" class="FieldLabelLeft">${viewtype}</td>
			%for month in months:
				<% stats = stat_rows.get((viewtype,month)) %>
				%if stats:
					<td>${stats.StaffCount}</td>
					<td>${stats.Total - stats.StaffCount}</td>
					<td>${stats.Total}</td>
				%else:
					<td>0</td>
					<td>0</td>
					<td>0</td>
				%endif
			%endfor
		</tr>
	%endfor
	</table>
%endif
