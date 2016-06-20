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
If Not user_intCanViewStatsDOM > STATS_NONE Then
	Call securityFailure()
End If

Call makePageHeader(TXT_STATS & TXT_COLON & TXT_TOP_50_RECORDS, TXT_STATS & TXT_COLON & TXT_TOP_50_RECORDS, True, True, True, True)
%>
<%
If Not g_bPrintMode Then
	Dim strViewName
	strViewName = vbNullString
	If Not user_intCanViewStatsDOM = STATS_ALL Then
		strViewName = " ( " & IIf(ps_intDbArea = DM_CIC, g_strViewNameCIC, g_strViewNameVOL) & " )"
	End If
%>
<p>[ <a href="<%=makeLinkB("stats.asp")%>"><%=TXT_MAIN_STATS_PAGE%></a>
| <a href="<%=makeLinkB("stats2.asp")%>"><%=TXT_TOTAL_RECORD_USE & strViewName%></a>
| <span class="HighLight"><a href="<%=makeLinkB("stats3.asp")%>"><%=TXT_TOP_50_RECORDS & strViewName%></a></span>
<%If user_intCanViewStatsDOM = STATS_ALL Then%>
| <a href="<%=makeLinkB("stats4.asp")%>"><%=TXT_USE_BY_AGENCY%></a>
| <a href="<%=makeLinkB("stats_auto.asp")%>"><%=TXT_AUTO_REPORTS%></a>
<%
End If
If user_bSuperUserDOM Then
%>
| <a href="<%=makeLinkB("stats_delete.asp")%>"><%=TXT_DELETE_STATS%></a>
<%End If%>
| <a href="<%=makeLink(ps_strThisPage,"PrintMd=on",vbNullString)%>" target="_BLANK"><%=TXT_PRINT_VERSION%></a>
]</p>
<%End If%>
<%

Dim cmdStat3, rsStat3
Set cmdStat3 = Server.CreateObject("ADODB.Command")
With cmdStat3
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "sp_" & ps_strDbArea & "_Stats3"
	.CommandType = adCmdStoredProc
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeDOM)
	.Parameters.Append .CreateParameter("@LimitByView", adBoolean, adParamInput, 1, IIf(user_intCanViewStatsDOM = STATS_ALL,SQL_FALSE,SQL_TRUE))
	.CommandTimeout = 0
	Set rsStat3 = .Execute
End With

Dim i, prevCount
i = 0
prevCount = -1

Dim intStatTotal, _
	intStatStaffTotal, _
	strLinkName, _
	fldID, _
	fldOrgName, _
	fldUsage, _
	fldStaffUsage, _
	fldInView

intStatTotal = 0
intStatStaffTotal = 0

With rsStat3
	Set fldOrgName = .Fields("ORG_NAME_FULL")
	Set fldUsage = .Fields("UsageCount")
	Set fldStaffUsage = .Fields("StaffUsageCount")
	Set fldInView = .Fields("InCurrentView")
	If ps_intDbArea = DM_VOL Then
		strLinkName = "VNUM"
		Set fldID = .Fields("VNUM")
	Else
		strLinkName = "NUM"
		Set fldID = .Fields("NUM")
	End If
%>
<table class="BasicBorder cell-padding-2">
<tr class="RevTitleBox"><th><%=TXT_RANK%></th><th><%=TXT_RECORD_NUM%></th><%If ps_intDbArea=DM_VOL Then%><th><%=TXT_POSITION_TITLE%></th><%End If%><th><%=TXT_ORG_NAMES%></th><th><%=TXT_USAGE%> (<%=TXT_PUBLIC%>)</th><th><%=TXT_USAGE%> (<%=TXT_TOTAL%>)</th></tr>
<%
	While Not .EOF
		If .Fields("UsageCount") <> prevCount Then
			i = i+1
		End If
		prevCount = .Fields("UsageCount")
%>
<tr>
	<td><%=i%></td>
	<td><%If Not g_bPrintMode And fldInView.Value Then%><a href="<%
	If ps_intDbArea = DM_CIC Then 
		Response.Write(makeDetailsLink(fldID,vbNullString,vbNullString))
	Else
		Response.Write(makeDetailsLink(fldID,vbNullString,vbNullString))
	End If
		%>"><%End If%><%=fldID.Value%><%If Not g_bPrintMode And fldInView.Value Then%></a><%End If%></td>
	<%If ps_intDbArea = DM_VOL Then%><td><%=Nz(.Fields("POSITION_TITLE"),"(" & TXT_UNKNOWN & ")")%></td><%End If%>
	<td><%=fldOrgName.Value%></td>
	<td><%=Nz(fldUsage,0)-Nz(fldStaffUsage,0)%></td>
	<td><%=Nz(fldUsage,0)%></td>
</tr>
<%
		intStatTotal = intStatTotal + Nz(fldUsage,0)
		intStatStaffTotal = intStatStaffTotal + Nz(fldStaffUsage,0)
		.MoveNext
	Wend
%>
<tr><td colspan="<%=IIf(ps_intDbArea=DM_VOL,4,3)%>" class="FieldLabel"><%=TXT_TOTAL%></td><td><%=intStatTotal-intStatStaffTotal%></td><td><%=intStatTotal%></td></tr>
</table>
<%
End With
%>
<%
Call makePageFooter(True)
%>
