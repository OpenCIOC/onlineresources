<%
' =========================================================================================
'  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
'
'  Licensed under the Apache License, Version 2.0 (the "License");
'  you may not use this file except in compliance with the License.
'  You may obtain a copy of the License at
'
'      http://www.apache.org/licenses/LICENSE-2.0
'
'  Unless required by applicable law or agreed to in writing, software
'  distributed under the License is distributed on an "AS IS" BASIS,
'  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'  See the License for the specific language governing permissions and
'  limitations under the License.
' =========================================================================================

%>

<%
If Not user_intCanViewStatsDOM = STATS_ALL Then
	Call securityFailure()
End If

Call makePageHeader(TXT_AUTO_REPORTS, TXT_AUTO_REPORTS, True, True, True, True)
%>
<p>[ <a href="<%=makeLinkB("stats.asp")%>"><%=TXT_MAIN_STATS_PAGE%></a>
| <a href="<%=makeLinkB("stats2.asp")%>"><%=TXT_TOTAL_RECORD_USE%></a>
| <a href="<%=makeLinkB("stats3.asp")%>"><%=TXT_TOP_50_RECORDS%></a>
| <a href="<%=makeLinkB("stats4.asp")%>"><%=TXT_USE_BY_AGENCY%></a>
| <span class="HighLight"><a href="<%=makeLinkB("stats_auto.asp")%>"><%=TXT_AUTO_REPORTS%></a></span>
<% If user_bSuperUserDOM Then %>
| <a href="<%=makeLinkB("stats_delete.asp")%>"><%=TXT_DELETE_STATS%></a>
<% End If %>
]</p>

<h3><%=TXT_AR_GENERATE%></h3>
<ul>
	<li><a href="<%=makeLinkB("stats/auto_datamgmt")%>"><%=TXT_AR_DATA_MANAGEMENT%></a></li>
	<li><a href="<%=makeLinkB("stats/auto_viewsbyro")%>"><%=TXT_AR_RECORD_VIEW_BY_OWNER%></a></li>
	<li><a href="<%=makeLinkB("stats/auto_viewsbyview")%>"><%=TXT_AR_RECORD_VIEW_BY_VIEW%></a></li>
	<li><a href="<%=makeLinkB("stats/auto_ipsbyro")%>"><%=TXT_AR_UNIQUE_IP_BY_OWNER%></a></li>
	<li><a href="<%=makeLinkB("stats/auto_ipsbyview")%>"><%=TXT_AR_UNIQUE_IP_BY_VIEW%></a></li>
	<li><a href="<%=makeLinkB("stats/auto_ips")%>"><%=TXT_AR_UNIQUE_IP_TOTAL%></a></li>
</ul>

<%
Call makePageFooter(True)
%>
