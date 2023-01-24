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
Call makePageHeader(TXT_DELETE_STATS_TITLE, TXT_DELETE_STATS_TITLE, True, True, True, True)
%>
<p>[ <a href="<%=makeLinkB("stats.asp")%>"><%=TXT_MAIN_STATS_PAGE%></a>
| <a href="<%=makeLinkB("stats2.asp")%>"><%=TXT_TOTAL_RECORD_USE%></a>
| <a href="<%=makeLinkB("stats3.asp")%>"><%=TXT_TOP_50_RECORDS%></a>
| <a href="<%=makeLinkB("stats4.asp")%>"><%=TXT_USE_BY_AGENCY%></a>
| <a href="<%=makeLinkB("stats_auto.asp")%>"><%=TXT_AUTO_REPORTS%></a>
| <span class="HighLight"><a href="<%=makeLinkB("stats_delete.asp")%>"><%=TXT_DELETE_STATS%></a></span>
]</p>

<h1><%=TXT_DELETE_STATS_TITLE%></h1>
<p><%=TXT_INST_DELETE_STATS%></p>
<%
Dim cmdStatD, rsStatD
Set cmdStatD = Server.CreateObject("ADODB.Command")
With cmdStatD
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandText = "dbo.sp_" & ps_strDbArea & "_Stats_Month_l"
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.CommandTimeout = 0
	Set rsStatD = .Execute
End With
%>
<form action="stats_delete2.asp" method="post" name="EntryForm">
<%=g_strCacheFormVals%>
<%
Dim intStatTotal, intStatStaffTotal
intStatTotal = 0
intStatStaffTotal = 0

With rsStatD
%>
<table class="BasicBorder cell-padding-2">
<tr class="RevTitleBox"><th><%=TXT_DELETE_UP_TO%></th><th><%=TXT_NUMBER_STATS_DELETE%></th></tr>
<%
	While Not .EOF
		intStatTotal = intStatTotal + .Fields("UsageCount")
%>
<tr><td><label for="DeleteToDate_<%=Replace(.Fields("STAT_MONTH")," ","_")%>"><input type="radio" name="DeleteToDate" id="DeleteToDate_<%=Replace(.Fields("STAT_MONTH")," ","_")%>" value="<%=DateString(DateAdd("m",1,.Fields("STAT_MONTH")),True)%>"><%=.Fields("STAT_MONTH")%></label></td><td><%=intStatTotal%></td></tr>
<%
		.MoveNext
	Wend
%>
</table>
<input type="submit" value="<%=TXT_DELETE%>" class="btn btn-default">
<%
End With
%>
</form>
<%
Call makePageFooter(True)
%>
