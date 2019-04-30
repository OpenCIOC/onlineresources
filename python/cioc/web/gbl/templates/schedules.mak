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

<h1>${_('Upcoming Events')}</h1>
%for month_display, month_results in months:
    <h2 style="border-top: thin solid; padding-top:9px;">${month_display}</h2>
	%if len(month_results) == 0:
		<p><em>${_('No listings available')|n}</em></p>
	%else:
		%for entry in month_results:
	        <h3>${entry.Name|n}</h3>
			%if request.pageinfo.DbArea == const.DM_VOL:
			<p><em>${entry.OrgName|n}</em></p>
			%endif
			<p style="margin-left: 27px; font-weight: bold;">${entry.Schedule|n}</p>
			%if entry.Description:
				<p style="margin-left: 27px;">${entry.Description|n}</p>
			%endif
		%endfor
	%endif
%endfor
