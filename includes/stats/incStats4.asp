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

Call makePageHeader(TXT_STATS & TXT_COLON & TXT_USE_BY_AGENCY, TXT_STATS & TXT_COLON & TXT_USE_BY_AGENCY, True, True, True, True)
%>
<%If Not g_bPrintMode Then%>
<p>[ <a href="<%=makeLinkB("stats.asp")%>"><%=TXT_MAIN_STATS_PAGE%></a>
| <a href="<%=makeLinkB("stats2.asp")%>"><%=TXT_TOTAL_RECORD_USE%></a>
| <a href="<%=makeLinkB("stats3.asp")%>"><%=TXT_TOP_50_RECORDS%></a>
| <span class="HighLight"><a href="<%=makeLinkB("stats4.asp")%>"><%=TXT_USE_BY_AGENCY%></a></span>
| <a href="<%=makeLinkB("stats_auto.asp")%>"><%=TXT_AUTO_REPORTS%></a>
<% If user_bSuperUserDOM Then %>
| <a href="<%=makeLinkB("stats_delete.asp")%>"><%=TXT_DELETE_STATS%></a>
<% End If %>
| <a href="<%=makeLink(ps_strThisPage,"PrintMd=on",vbNullString)%>" target="_BLANK"><%=TXT_PRINT_VERSION_NW%></a>
]</p>
<%End If%>
<%

Dim cmdStat4, rsStat4
Set cmdStat4 = Server.CreateObject("ADODB.Command")
With cmdStat4
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandText = "sp_" & ps_strDbArea & "_Stats4"
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.CommandTimeout = 0
	Set rsStat4 = .Execute
End With

Dim intRecordLocalTotal, _
	intRecordSharedTotal, _
	intStatTotal, _
	intStatStaffTotal

intRecordLocalTotal = 0
intRecordSharedTotal = 0
intStatTotal = 0
intStatStaffTotal = 0

With rsStat4
%>
<table class="BasicBorder cell-padding-2">
<tr class="RevTitleBox">
	<th><%=TXT_RECORD_OWNER%></th>
	<th><%=IIf(g_bOtherMembersActive,TXT_LOCAL_RECORDS,TXT_TOTAL_RECORDS)%></th>
	<%If g_bOtherMembersActive Then%>
	<th><%=TXT_OTHER_RECORDS%></th>
	<%End If%>
	<th><%=TXT_USAGE%> (<%=TXT_PUBLIC%>)</th>
	<th><%=TXT_USAGE%> (<%=TXT_TOTAL%>)</th>
</tr>
<%
	While Not .EOF
		If Nl(.Fields("RECORD_OWNER")) Then
			If .Fields("UsageCount") > 0 Then
%>
<tr>
	<td><%=TXT_UNKNOWN%></td>
	<td>-</td>
	<%If g_bOtherMembersActive Then%>
	<td>-</td>
	<%End If%>
	<td><%=.Fields("UsageCount")-Nz(.Fields("StaffUsageCount"),0)%></td>
	<td><%=.Fields("UsageCount")%></td>
</tr>
<%
			End If
		Else
%>
<tr>
	<td><%=.Fields("RECORD_OWNER")%></td>
	<td><%=.Fields("RecordCountLocal")%></td>
	<%If g_bOtherMembersActive Then%>
	<td><%=.Fields("RecordCountOther")%></td>
	<%End If%>
	<td><%=.Fields("UsageCount")-Nz(.Fields("StaffUsageCount"),0)%></td>
	<td><%=.Fields("UsageCount")%></td>
</tr>
<%
			intRecordLocalTotal = intRecordLocalTotal + .Fields("RecordCountLocal")
			intRecordSharedTotal = intRecordSharedTotal + .Fields("RecordCountOther")
		End If
		intStatTotal = intStatTotal + .Fields("UsageCount")
		intStatStaffTotal = intStatStaffTotal + .Fields("StaffUsageCount")
		.MoveNext
	Wend
%>
<tr>
	<td class="FieldLabel"><%=TXT_TOTAL%></td>
	<td><%=intRecordLocalTotal%></td>
	<%If g_bOtherMembersActive Then%>
	<td><%=intRecordSharedTotal%></td>
	<%End If%>
	<td><%=intStatTotal-intStatStaffTotal%></td>
	<td><%=intStatTotal%></td>
</tr>
</table>
<%
End With
%>
<%
Call makePageFooter(True)
%>
