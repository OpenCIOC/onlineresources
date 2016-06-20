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


Dim bError, _
	strStoredProcName

bError = False

strStoredProcName = "sp_" & ps_strDbArea & "_Stats1"

Call makePageHeader(TXT_STATS_RESULTS, TXT_STATS_RESULTS, True, True, True, True)

Dim strIDList, _
	strAgency, _
	strStartDate, _
	strEndDate, _
	strIPAddress, _
	intRobotID, _
	intUserType, _
	intViewType, _
	intLimitLangID, _
	bStaff

strIDList = Request("IDList")

If Len(strIDList) > 10000 Then
	Call handleError(TXT_TOO_MANY_RECORDS, _
	vbNullString, vbNullString)
	bError = True
End If

strAgency = Nz(Request("RecordOwner"),Null)

strIPAddress = Nz(Request("IPAddress"),Null)

intUserType = Nz(Request("SLID"),Null)

intViewType = Nz(Request("ViewType"),Null)
If Not IsIDList(intViewType) Then
	intViewType = Null
End If
If Nl(intViewType) And Not user_intCanViewStatsDOM = STATS_ALL Then
	Dim strVTCon
	strVTCon = vbNullString
	intViewType = vbNullString

	openChangeViewsListRst(True)
	With rsListChangeViews
		While Not .EOF
			intViewType = intViewType & strVTCon & .Fields("ViewType")
			strVTCon = ","
			.MoveNext
		Wend
	End With
	closeChangeViewsListRst()
End If

intLimitLangID = Nz(Request("LimitLangID"),Null)
If Not IsLangID(intLimitLangID) Then
	intLimitLangID = Null
End If

strStartDate = Null
If Not Nl(Request("StartDate")) Then
	If IsSmallDate(Request("StartDate")) Then
		strStartDate = DateValue(Request("StartDate"))
	Else
		bError = True
		Call handleError(Request("StartDate") & TXT_INVALID_DATE_FORMAT & DateString(MIN_SMALL_DATE,True) & TXT_AND_LC & DateString(MAX_SMALL_DATE,True), _
			vbNullString, vbNullString)
	End If
End If

strEndDate = Null
If Not Nl(Request("EndDate")) Then
	If IsSmallDate(Request("EndDate")) Then
		strEndDate = DateValue(Request("EndDate"))
	Else
		bError = True
		Call handleError(Request("EndDate") & TXT_INVALID_DATE_FORMAT & DateString(MIN_SMALL_DATE,True) & TXT_AND_LC & DateString(MAX_SMALL_DATE,True), _
			vbNullString, vbNullString)
	End If
End If

Select Case Request("StaffStatus")
	Case "P"
		bStaff = SQL_FALSE
	Case "L"
		bStaff = SQL_TRUE
	Case Else
		bStaff = Null
End Select

intRobotID = Nz(Request("RobotStatus"),Null)
If Not IsNumeric(intRobotID) Then
	intRobotID = Null
Else
	intRobotID = CInt(intRobotID)
End If

If Not g_bPrintMode Then
	Dim strViewName
	strViewName = vbNullString
	If Not user_intCanViewStatsDOM = STATS_ALL Then
		strViewName = " ( " & IIf(ps_intDbArea = DM_CIC, g_strViewNameCIC, g_strViewNameVOL) & " )"
	End If
%>
<p>[ <span class="HighLight"><a href="<%=makeLinkB("stats.asp")%>"><%=TXT_MAIN_STATS_PAGE%></a></span>
| <a href="<%=makeLinkB("stats2.asp")%>"><%=TXT_TOTAL_RECORD_USE & strViewName%></a>
| <a href="<%=makeLinkB("stats3.asp")%>"><%=TXT_TOP_50_RECORDS & strViewName%></a>
<%If user_intCanViewStatsDOM = STATS_ALL Then%>
| <a href="<%=makeLinkB("stats4.asp")%>"><%=TXT_USE_BY_AGENCY%></a>
| <a href="<%=makeLinkB("stats_auto.asp")%>"><%=TXT_AUTO_REPORTS%></a>
<%
End If
If user_bSuperUserDOM Then
%>
| <a href="<%=makeLinkB("stats_delete.asp")%>"><%=TXT_DELETE_STATS%></a>
<%End If%>
]</p>
<%End If%>
<%
If Not bError Then
'20 minute timeout on this page. It could take a while.
Server.ScriptTimeout = 1200

Dim cmdStat1, rsStat1
Set cmdStat1 = Server.CreateObject("ADODB.Command")
With cmdStat1
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeDOM)
	If Nl(strIDList) Then
		.CommandText = strStoredProcName
		.Parameters.Append .CreateParameter("@Agency", adChar, adParamInput, 3, strAgency)
	Else
		.CommandText = strStoredProcName & "_Gen"
		.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strIDList)
	End If
	.Parameters.Append .CreateParameter("@UserType", adInteger, adParamInput, 4, intUserType)
	.Parameters.Append .CreateParameter("@ViewList", adLongVarChar, adParamInput, -1, intViewType)
	.Parameters.Append .CreateParameter("@StartDate", adDBDate, adParamInput, 4, strStartDate)
	.Parameters.Append .CreateParameter("@EndDate", adDBDate, adParamInput, 4, strEndDate)
	.Parameters.Append .CreateParameter("@IPAddress", adVarChar, adParamInput, 50, strIPAddress)
	.Parameters.Append .CreateParameter("@Staff", adBoolean, adParamInput, 1, bStaff)
	.Parameters.Append .CreateParameter("@LimitLangID", adInteger, adParamInput, 2, intLimitLangID)
	.Parameters.Append .CreateParameter("@RobotID", adInteger, adParamInput, 4, intRobotID)
	Set rsStat1 = .Execute
End With

Dim intStatTotal, _
	strLinkName, _
	fldID, _
	fldOrgName, _
	fldUsage, _
	fldInView

intStatTotal = 0

With rsStat1
	If Not .EOF Then
		.CacheSize = 100
		Set fldUsage = .Fields("UsageCount")
		Set fldInView = .Fields("InCurrentView")
		Set fldOrgName = .Fields("ORG_NAME_FULL")
		If ps_intDbArea = DM_VOL Then
			strLinkName = "VNUM"
			Set fldID = .Fields("VNUM")
		Else
			strLinkName = "NUM"
			Set fldID = .Fields("NUM")
		End If
%>
<table class="BasicBorder cell-padding-2">
<tr class="RevTitleBox"><th><%=TXT_RECORD_NUM%></th><%If ps_intDbArea=DM_VOL Then%><th><%=TXT_POSITION_TITLE%></th><%End If%><th><%=TXT_ORG_NAMES%></th><th><%=TXT_USAGE%></th></tr>
<%
		Dim i
		i = 0
		While Not .EOF
%>
<tr>
	<td><%If Not g_bPrintMode And fldInView.Value Then%><a href="<%
	If ps_intDbArea=DM_CIC Then
		Response.Write(makeDetailsLink(fldID,vbNullString,vbNullString))
	Else
		Response.Write(makeVOLDetailsLink(fldID,vbNullString,vbNullString))
	End If
		%>"><%End If%><%=fldID.Value%><%If Not g_bPrintMode And fldInView.Value Then%></a><%End If%></td>
	<%If ps_intDbArea=DM_VOL Then%><td><%=Nz(.Fields("POSITION_TITLE"),"(" & TXT_UNKNOWN & ")")%></td><%End If%>
	<td><%=fldOrgName.Value%></td>
	<td><%=Nz(fldUsage,0)%></td>
</tr>
<%
			intStatTotal = intStatTotal + Nz(fldUsage,0)
			.MoveNext
			i = i + 1
			If i Mod 500 = 0 Then
				Response.Flush
			End If
		Wend
%>
<tr><td colspan="<%=IIf(ps_intDbArea=DM_VOL,3,2)%>" class="FieldLabel"><%=TXT_TOTAL%></td><td><%=intStatTotal%></td></tr>
</table>
<%
	Else
%>
<p><%=TXT_NO_MATCHES%></p>
<%
	End If
End With

End If

Call makePageFooter(True)
%>
