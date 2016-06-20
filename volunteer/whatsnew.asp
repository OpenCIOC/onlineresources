<%@LANGUAGE="VBSCRIPT"%>
<%Option Explicit%>

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

<% 'Base includes %>
<!--#include file="../includes/core/adovbs.inc" -->
<!--#include file="../includes/core/incVBUtils.asp" -->
<!--#include file="../includes/validation/incBasicTypes.asp" -->
<!--#include file="../includes/core/incRExpFuncs.asp" -->
<!--#include file="../includes/core/incHandleError.asp" -->
<!--#include file="../includes/core/incSetLanguage.asp" -->
<!--#include file="../includes/core/incPassVars.asp" -->
<!--#include file="../text/txtGeneral.asp" -->
<!--#include file="../text/txtError.asp" -->
<!--#include file="../includes/core/incConnection.asp" -->
<!--#include file="../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtClientTracker.asp" -->
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtRecordPages.asp" -->
<!--#include file="../text/txtSearchBasic.asp" -->
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/core/incOrderByConst.asp" -->
<!--#include file="../includes/display/incVOLDisplayOptionsFields.asp" -->
<!--#include file="../includes/core/incFieldDataClass.asp" -->
<!--#include file="../includes/search/incMakeTableClassVOL.asp" -->
<!--#include file="../includes/search/incMyList.asp" -->
<!--#include file="../includes/search/incSearchRecent.asp" -->
<% 
Dim bInlineMode
bInlineMode = Not Nl(Trim(Request("InlineMode")))

If Not bInlineMode Then
Call makePageHeader(TXT_WHATS_NEW, TXT_WHATS_NEW, True, True, False, True)
End If

'On Error Resume Next

Call getDisplayOptionsVOL(g_intViewTypeVOL, Not user_bVOL)

Const DEFAULT_DAYS = 14

Dim dateNumdays, _
	intNumDays, _
	intMinRecords, _
	strDateType
	
intNumDays = Trim(Request("numDays"))
If Nl(intNumDays) Then
	intNumDays = DEFAULT_DAYS
ElseIf IsNumeric(intNumDays) Then
	intNumDays = CInt(intNumDays)
	If intNumDays < 0 Then
		intNumDays = Abs(intNumDays)
	End If
	If intNumDays > MAX_TINY_INT Then
		intNumDays = DEFAULT_DAYS
	End If
Else
	intNumDays = DEFAULT_DAYS
End If
intMinRecords = Trim(Request("numRecords"))
If Nl(intMinRecords) Then
	intMinRecords = Null
ElseIf IsNumeric(intMinRecords) Then
	If 0+intMinRecords < MAX_TINY_INT Then
		intMinRecords = Abs(CInt(intMinRecords))
	Else
		intMinRecords = Null
	End If
Else
	intMinRecords = Null
End If

dateNumdays = DateString(DateAdd("d",-intNumDays,Date()),False)

strDateType = Trim(Request("dateType"))

Dim strQueryString

Dim strFrom, _
	strWhere, _
	strWhere2, _
	strOB

strFrom = "VOL_Opportunity vo" &  vbCrLf & _
	"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
	"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)"

Select Case strDateType
	Case "C"
		strWhere = "(vod.CREATED_DATE>=" & QsN(dateNumDays) & ")"
		strOB = "vod.CREATED_DATE DESC"
		strSearchInfoRefineNotes = TXT_SHOW_OPPS & " " & TXT_CREATED & " " & TXT_IN_THE_PAST & " " & intNumDays & " " & TXT_DAYS
	Case "M"
		strWhere = "(vod.MODIFIED_DATE>=" & QsN(dateNumDays) & ")"
		strOB = "vod.MODIFIED_DATE DESC"
		strSearchInfoRefineNotes = TXT_SHOW_OPPS & " " & TXT_MODIFIED & " " & TXT_IN_THE_PAST & " " & intNumDays & " " & TXT_DAYS
	Case Else
		strWhere = "(vod.UPDATE_DATE>=" & QsN(dateNumDays) & ")"
		strOB = "vod.UPDATE_DATE DESC"
		strSearchInfoRefineNotes = TXT_SHOW_OPPS & " " & TXT_UPDATED & " " & TXT_IN_THE_PAST & " " & intNumDays & " " & TXT_DAYS
		strDateType = "U"
End Select

If Not g_bPrintMode Then
	Response.Write(render_gtranslate_ui())
%>
<form action="<%=ps_strThisPage%>" method="GET" class="form-inline-always" role="form">
<%=g_strCacheFormVals%>
<div class="panel panel-default vol-whatsnew-panel">
	<div class="panel-body">
		<div class="form-group">
			<label for="dateType"><%=TXT_SHOW_OPPS %>
			<select name="dateType" class="form-control">
				<option value="U"<%If strDateType="U" Then%> SELECTED<%End If%>><%=TXT_UPDATED%></option>
				<option value="M"<%If strDateType="M" Then%> SELECTED<%End If%>><%=TXT_MODIFIED%></option>
				<option value="C"<%If strDateType="C" Then%> SELECTED<%End If%>><%=TXT_CREATED%></option>
			</select>
			</label>
		</div>
		<div class="form-group">
			<label for="numDays"><%= TXT_IN_THE_PAST %>
			<select name="numDays" class="form-control">
				<option value="1"<%If intNumDays=1 Then%> SELECTED<%End If%>>1</option>
				<option value="2"<%If intNumDays=2 Then%> SELECTED<%End If%>>2</option>
				<option value="7"<%If intNumDays=7 Then%> SELECTED<%End If%>>7</option>
				<option value="14"<%If intNumDays=14 Then%> SELECTED<%End If%>>14</option>
				<option value="21"<%If intNumDays=21 Then%> SELECTED<%End If%>>21</option>
			</select>
			<%= TXT_DAYS %>.</label>
		</div>
		<div class="form-group">
			<label for="numRecords">
			<%= TXT_SHOW_AT_LEAST %>
			<select name="numRecords" class="form-control">
				<option value=""> -- </option>
				<option value="10"<%If intMinRecords=10 Then%> SELECTED<%End If%>>10</option>
				<option value="20"<%If intMinRecords=20 Then%> SELECTED<%End If%>>20</option>
				<option value="30"<%If intMinRecords=30 Then%> SELECTED<%End If%>>30</option>
			</select>
			<%= TXT_RECORDS %></label>
		</div>
		<input type="submit" value="Search Again" class="btn btn-default">
		</div>
	</div>
</form>

<%
End If

Dim objOpTable	
Set objOpTable = New OpRecordTable

If Not Nl(intMinRecords) Then
	Dim cmdOpCount, rsOpCount
	Set cmdOpCount = Server.CreateObject("ADODB.Command")
	With cmdOpCount
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandType = adCmdText
		.CommandText = "SELECT COUNT(*) AS NUM_RECS" & vbCrLf & "FROM " & strFrom & vbCrLf & "WHERE " & IIf(Nl(strWhere),g_strWhereClauseVOLNoDel,strWhere & AND_CON & g_strWhereClauseVOLNoDel)
		.CommandTimeout = 0
		Set rsOpCount = .Execute
	End With
	If rsOpCount("NUM_RECS") < intMinRecords Then
		bCanRefineSearch = False
		Call objOpTable.setOptions(strFrom, vbNullString, vbNullString, False, intMinRecords, strOB)
	Else
		Call objOpTable.setOptions(strFrom, strWhere, vbNullString, False, vbNullString, vbNullString)
	End If
Else
	Call objOpTable.setOptions(strFrom, strWhere, vbNullString, False, vbNullString, vbNullString)
End If

Call objOpTable.makeTable()
Set objOpTable = Nothing
%>

<%
If Not bInlineMode Then
Call makePageFooter(True)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->

