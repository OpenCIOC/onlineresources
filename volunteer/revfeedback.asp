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
Call setPageInfo(True, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtFeedbackCommon.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtReviewFeedback.asp" -->
<!--#include file="../includes/list/incAgencyList.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
Const FB_BTD_ORG_SORT = " ORDER BY ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, STUFF(CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=bt.NUM) THEN NULL ELSE COALESCE(', ' + btd.LOCATION_NAME,'') + COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') + COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'') END, 1, 2, ''), fb.SUBMIT_DATE"

Const FB_NEW_ORG_SORT = " ORDER BY CASE WHEN fb.NUM IS NULL THEN fb.ORG_NAME ELSE dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1),btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) END"

If Not (user_bFeedbackAlertVOL _
		Or user_bAddVOL _
		Or user_intUpdateVOL <> UPDATE_NONE _
		) Then
	Call securityFailure()
End If

Call makePageHeader(TXT_REVIEW_FEEDBACK & " (" & TXT_VOLUNTEER & ")", TXT_REVIEW_FEEDBACK & " (" & TXT_VOLUNTEER & ")", True, False, True, True)

Dim strFeedbackSQL
Dim cmdFb, rsFb
Dim fldFBID, _
	fldOrgName, _
	fldVNUM, _
	fldAccessURL, _
	bDifferentLang

Dim strOwnerList

Call openAgencyListRst(DM_VOL, False, False)
strOwnerList = makeRecordOwnerAgencyList(user_strAgency, "AssignTo", False)
Call closeAgencyListRst()

Set cmdFb = Server.CreateObject("ADODB.Command")
Set rsFb = Server.CreateObject("ADODB.Recordset")
With cmdFb
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdText
	.CommandTimeout = 0
End With

%>
<ul>
	<li><a href="#MyFB"><%=TXT_FEEDBACK_EXISTING%> (<%=user_strAgency%>)</a></li>
	<li><a href="#MyNewFB"><%=TXT_NEW_RECORD_SUGGESTIONS%> (<%=user_strAgency%>)</a></li>
	<li><a href="#NewFB"><%=TXT_NEW_RECORD_SUGGESTIONS%>  (<%=TXT_UNASSIGNED%>)</a></li>
	<li><a href="#OtherFB"><%=TXT_FEEDBACK_EXISTING%> (<%=TXT_OTHER_AGENCIES%>)</a></li>
	<li><a href="#OtherNewFB"><%=TXT_NEW_RECORD_SUGGESTIONS%> (<%=TXT_OTHER_AGENCIES%>)</a></li>
</ul>
<hr>

<%
'***************************************
' Feedback for User's Own Agency
'***************************************
strFeedbackSQL = "SELECT vo.MemberID, fb.MemberID AS FB_MemberID, fb.FB_ID, fb.SUBMIT_DATE, fb.AccessURL, sl.Culture, sl.LanguageName AS LanguageName," & _
	"""SUBMITTED_BY"" = CASE WHEN u.User_ID IS NULL THEN CASE WHEN fb.SOURCE_NAME IS NULL THEN " & QsNl("(" & TXT_UNKNOWN & ")") & " ELSE fb.SOURCE_NAME END ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END, " & _
	"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL_FB," & _
	"vo.VNUM, vod.POSITION_TITLE," & _
	"dbo.fn_VOL_CanUpdateRecord(vo.VNUM," & user_intID & "," & g_intViewTypeVOL & ",@@LANGID,GETDATE()) AS CAN_UPDATE" & vbCrLf & _
	"FROM VOL_Feedback fb" & vbCrLf & _
	"INNER JOIN STP_Language sl ON fb.LangID=sl.LangID" & vbCrLf & _
	"LEFT JOIN GBL_Users u ON fb.User_ID=u.User_ID" & vbCrLf & _
	"INNER JOIN VOL_Opportunity vo ON fb.VNUM=vo.VNUM" &  vbCrLf & _
	"LEFT JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 WHEN LangID=fb.LangID THEN 1 ELSE 2 END, LangID)" & vbCrLf & _
	"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 WHEN LangID=fb.LangID THEN 1 ELSE 2 END, LangID)" & vbCrLf & _
	"WHERE (" & vbCrLf & _
	"		vo.MemberID=" & g_intMemberID & vbCrLf & _
	"		OR fb.MemberID=" & g_intMemberID & vbCrLf & _
	"		OR dbo.fn_VOL_CanUpdateRecord(vo.VNUM," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE())=1" & vbCrLf & _
	"		OR EXISTS(SELECT * FROM VOL_OP_SharingProfile vos WHERE VNUM=vo.VNUM AND ShareMemberID_Cache=" & g_intMemberID & vbCrLf & _
	"			AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=vos.ProfileID AND shp.CanViewFeedback=1))" & vbCrLf & _
	"	)" & vbCrLf & _
	"AND vo.RECORD_OWNER=" & Qs(user_strAgency,SQUOTE)

If Not Nl(g_strWhereClauseVOL) Then
	strFeedbackSQL = strFeedbackSQL & AND_CON & g_strWhereClauseVOL
End If

Select Case Request("Sort") 
	Case "L"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.LangID, fb.SUBMIT_DATE"
	Case "R" 
		strFeedbackSQL = strFeedbackSQL & " ORDER BY vo.RECORD_OWNER, fb.SUBMIT_DATE"
	Case "P"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY vod.POSITION_TITLE, fb.SUBMIT_DATE"
	Case "O"
		strFeedbackSQL = strFeedbackSQL & FB_BTD_ORG_SORT & ", fb.SUBMIT_DATE"
	Case "S"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY SUBMITTED_BY, fb.SUBMIT_DATE"
	Case Else
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.SUBMIT_DATE"
End Select

'Response.Write("<pre>" & strFeedbackSQL & "</pre>")
'Response.Flush()

With cmdFb
	.CommandText = strFeedbackSQL
End With
With rsFb
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFb
	
	Set fldFBID = .Fields("FB_ID")
	Set fldOrgName = .Fields("ORG_NAME_FULL_FB")
	Set fldVNUM = .Fields("VNUM")
	Set fldAccessURL = .Fields("AccessURL")
%>

<h2 id="MyFB"><%=TXT_FEEDBACK_EXISTING%> (<%=user_strAgency%>)</h2>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_RECORDS_WITH_FEEDBACK%></p>
<%	If .RecordCount > 0 Then%>
<table class="BasicBorder cell-padding-3 table-striped">
	<thead>
	<tr class="RevTitleBox">
<%		If g_bMultiLingual Then%>
		<th><a href="<%=makeLink(ps_strThisPage,"Sort=L",vbNullString)%>" class="RevTitleText"><%=TXT_FEEDBACK_LANGUAGE%></a></th>
<%		End If%>
		<th><a href="<%=makeLink(ps_strThisPage,"Sort=P",vbNullString)%>" class="RevTitleText"><%=TXT_POSITION_TITLE%></a></th>
		<th><a href="<%=makeLink(ps_strThisPage,"Sort=O",vbNullString)%>" class="RevTitleText"><%=TXT_ORG_NAMES%></a></th>
		<th><a href="<%=makeLink(ps_strThisPage,"Sort=S",vbNullString)%>" class="RevTitleText"><%=TXT_SUBMITTED_BY%></a></th>
		<th><a href="<%=makeLink(ps_strThisPage,"Sort=D",vbNullString)%>" class="RevTitleText"><%=TXT_DATE_SUBMITTED%></a></th>
		<th><%=TXT_ACTION%></th>
	</tr>
	</thead>
	<tbody>
<%
		While Not .EOF
%>
	<tr valign="TOP">
<%			If g_bMultiLingual Then%>
		<td><%=.Fields("LanguageName")%></td>
<%			End If%>
		<td><a href="<%=makeVOLDetailsLink(.Fields("VNUM"),vbNullString,vbNullString)%>"><%=.Fields("POSITION_TITLE")%></a></td>
		<td><%=fldOrgName.Value%></td>
		<td align="right"><%=.Fields("SUBMITTED_BY")%>
				<div style="font-size:small; font-style:italic;"><%=fldAccessURL.Value%></div></td>
		<td align="right"><%=DateString(.Fields("SUBMIT_DATE"),True)%></td>
			<td class="container-action-list">
				<a class="btn btn-sm btn-info btn-action-list" href="<%=makeLink("revfeedback_view.asp","FBID=" & fldFBID,vbNullString)%>"><span class="glyphicon glyphicon-search" aria-hidden="true"></span> <%=TXT_VIEW_FEEDBACK%></a>
<%			If .Fields("CAN_UPDATE") = 1 Then%>
				<a class="btn btn-sm btn-info btn-action-list" href="<%=makeLink("entryform.asp","VNUM=" & fldVNUM & StringIf(bDifferentLang,"&UpdateLn=" & .Fields("Culture")),vbNullString)%>"><span class="glyphicon glyphicon-edit" aria-hidden="true"></span> <%=TXT_UPDATE%></a>
<%			End If
			If user_bCanDeleteRecordVOL And .Fields("CAN_UPDATE") = 1 And (.Fields("MemberID")=g_intMemberID Or .Fields("FB_MemberID")=g_intMemberID) Then%>
				<a class="btn btn-sm btn-danger btn-action-list" href="<%=makeLink("revfeedback_delete.asp","FBID=" & fldFBID,vbNullString)%>"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span> <%=TXT_DELETE%></a>
<%			End If%>
			</td>
		</tr>
<%			.MoveNext
		Wend
%>
	</tbody>
</table>
<hr />
<%
	End If
	.Close
End With

'***************************************
' New Record Suggestions for User's Own Agency
'***************************************
strFeedbackSQL = "SELECT fb.FB_ID, fb.SUBMIT_DATE, fb.AccessURL, sl.Culture, sl.LanguageName AS LanguageName," & _
	"""SUBMITTED_BY"" = CASE WHEN u.User_ID IS NULL THEN CASE WHEN fb.SOURCE_NAME IS NULL THEN " & QsNl("(" & TXT_UNKNOWN & ")") & " ELSE fb.SOURCE_NAME END ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END, " & _
	"ISNULL(fb.ORG_NAME,dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME)) AS ORG_NAME_FULL_FB," & _
	"ISNULL(fb.POSITION_TITLE," & QsNl("(" & TXT_UNKNOWN & ")") & ") AS POSITION_TITLE," & vbCrLf & _
	"COALESCE(fb.LOCATION,dbo.fn_GBL_DisplayCommunity(bt.LOCATED_IN_CM,@@LANGID),btd.SITE_CITY) AS LOCATED_IN" & vbCrLf & _
	"FROM VOL_Feedback fb" & vbCrLf & _
	"INNER JOIN STP_Language sl ON fb.LangID=sl.LangID" & vbCrLf & _
	"LEFT JOIN GBL_Users u ON fb.User_ID=u.User_ID " & vbCrLf & _
	"LEFT JOIN GBL_BaseTable bt ON fb.NUM=bt.NUM " & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 WHEN LangID=fb.LangID THEN 1 ELSE 2 END, LangID)" & vbCrLf & _
	"WHERE fb.MemberID=" & g_intMemberID & vbCrLf & _
	"AND fb.VNUM IS NULL" & vbCrLf & _
	"AND fb.FEEDBACK_OWNER=" & QsNl(user_strAgency)

Select Case Request("Sort") 
	Case "L"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.LangID, fb.SUBMIT_DATE"
	Case "P"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.POSITION_TITLE, fb.SUBMIT_DATE"
	Case "O"
		strFeedbackSQL = strFeedbackSQL & FB_NEW_ORG_SORT & ", fb.SUBMIT_DATE"
	Case "S"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY SUBMITTED_BY, fb.SUBMIT_DATE"
	Case Else
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.SUBMIT_DATE"
End Select

'Response.Write("<pre>" & strFeedbackSQL & "</pre>")
'Response.Flush()

With cmdFb
	.CommandText = strFeedbackSQL
End With

With rsFb
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFb
	
	Set fldFBID = .Fields("FB_ID")
	Set fldOrgName = .Fields("ORG_NAME_FULL_FB")
	Set fldAccessURL = .Fields("AccessURL")
%>
<a name="MyNewFB"></a>
<h2><%=TXT_NEW_RECORD_SUGGESTIONS%> (<%=user_strAgency%>)</h2>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_SUGGESTIONS_FOR_RECORDS%></p>
<%
	If .RecordCount > 0 Then
		If user_bCanAssignFeedbackVOL Then
%>
<form action="revfeedback_assign.asp" method="get" role="form" class="form-horizontal">
<%=g_strCacheFormVals%>
<%
		End If
%>
<table class="BasicBorder cell-padding-3 table-striped">
	<thead>
		<tr class="RevTitleBox">
<%		If user_bCanAssignFeedbackVOL Then%>
			<th>&nbsp;</th>
<%		End If
		If g_bMultiLingual Then%>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=L",vbNullString)%>" class="RevTitleText"><%=TXT_FEEDBACK_LANGUAGE%></a></th>
<%		End If%>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=P",vbNullString)%>" class="RevTitleText"><%=TXT_POSITION_TITLE%></a></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=O",vbNullString)%>" class="RevTitleText"><%=TXT_ORG_NAMES%></a></th>
			<th><%=TXT_LOCATED_IN%></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=S",vbNullString)%>" class="RevTitleText"><%=TXT_SUBMITTED_BY%></a></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=D",vbNullString)%>" class="RevTitleText"><%=TXT_DATE_SUBMITTED%></a></th>
<%	If user_bAddVOL Or user_bSuperUserVOL Then%>
			<th><%=TXT_ACTION%></th>
<%	End If%>
		</tr>
	</thead>
	<tbody>
<%
		While Not .EOF
			bDifferentLang = False
			If .Fields("Culture") <> g_objCurrentLang.Culture Then
				bDifferentLang = True
			End If
%>
		<tr>
<%			If user_bCanAssignFeedbackVOL Then%>
			<td><input type="checkbox" name="AssignFB" value="<%=fldFBID%>"></td>
<%			End If
			If g_bMultiLingual Then%>
			<td><%=.Fields("LanguageName")%></td>
<%			End If%>
			<td><%=.Fields("POSITION_TITLE")%></td>
			<td><%=fldOrgName.Value%></td>
			<td><%=.Fields("LOCATED_IN")%></td>
			<td align="right"><%=.Fields("SUBMITTED_BY")%>
					<div style="font-size:small; font-style:italic;"><%=fldAccessURL.Value%></div></td>
			<td align="right"><%=DateString(.Fields("SUBMIT_DATE"),True)%></td>
<%				If (user_bAddVOL Or user_bSuperUserVOL) Then%>
			<td class="container-action-list">
				<a class="btn btn-sm btn-info btn-action-list" href="<%=makeLink("revfeedback_view.asp","FBID=" & .Fields("FB_ID"),vbNullString)%>"><span class="glyphicon glyphicon-search" aria-hidden="true"></span> <%=TXT_VIEW_FEEDBACK%></a>
				<a class="btn btn-sm btn-info btn-action-list" href="<%=makeLink("entryform.asp","FBID=" & .Fields("FB_ID") & StringIf(bDifferentLang,"&UpdateLn=" & .Fields("Culture")),vbNullString)%>"><span class="glyphicon glyphicon-edit" aria-hidden="true"></span> <%=TXT_CREATE_RECORD%></a>
<%					If user_bCanDeleteRecordVOL Then%>
				<a class="btn btn-sm btn-danger btn-action-list" href="<%=makeLink("revfeedback_delete.asp","FBID=" & .Fields("FB_ID"),vbNullString)%>"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span> <%=TXT_DELETE%></a>
<%					End If%>
			</td>
<%				End If%>
		</tr>
<%			.MoveNext
		Wend
%>
	</tbody>
</table>
<%		If user_bCanAssignFeedbackVOL Then%>
	<div class="form-group">
		<label for="AssignTo" class="control-label col-xs-12 col-sm-6 col-md-4 col-lg-3"><%=TXT_ASSIGN_TO%></label>
		<div class="col-xs-12 col-sm-6 col-md-8 col-lg-9 form-inline"><%=strOwnerList%> <input type="submit" value="<%=TXT_SUBMIT%>"></div>
	</div>
</form>
<%		End If
	End If
	.Close
End With
%>
<hr />
<%

'***************************************
' New Record Suggestions (Unassigned)
'***************************************
strFeedbackSQL = "SELECT fb.FB_ID, fb.SUBMIT_DATE, fb.AccessURL, sl.Culture, sl.LanguageName AS LanguageName," & _
	"""SUBMITTED_BY"" = CASE WHEN u.User_ID IS NULL THEN CASE WHEN fb.SOURCE_NAME IS NULL THEN " & QsNl("(" & TXT_UNKNOWN & ")") & " ELSE fb.SOURCE_NAME END ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END, " & _
	"ISNULL(fb.ORG_NAME,dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME)) AS ORG_NAME_FULL_FB," & _
	"ISNULL(fb.POSITION_TITLE," & QsNl("(" & TXT_UNKNOWN & ")") & ") AS POSITION_TITLE," & vbCrLf & _
	"COALESCE(fb.LOCATION,dbo.fn_GBL_DisplayCommunity(bt.LOCATED_IN_CM,@@LANGID),btd.SITE_CITY) AS LOCATED_IN" & vbCrLf & _
	"FROM VOL_Feedback fb" & vbCrLf & _
	"INNER JOIN STP_Language sl ON fb.LangID=sl.LangID" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable bt ON fb.NUM=bt.NUM " & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 WHEN LangID=fb.LangID THEN 1 ELSE 2 END, LangID)" & vbCrLf & _
	"LEFT JOIN GBL_Users u ON fb.User_ID=u.User_ID " & _
	"WHERE fb.MemberID=" & g_intMemberID & vbCrLf & _
	"AND fb.VNUM IS NULL" & vbCrLf & _
	"AND fb.FEEDBACK_OWNER IS NULL"

Select Case Request("Sort") 
	Case "L"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.LangID, fb.SUBMIT_DATE"
	Case "P"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.POSITION_TITLE, fb.SUBMIT_DATE"
	Case "O"
		strFeedbackSQL = strFeedbackSQL & FB_NEW_ORG_SORT & ", fb.SUBMIT_DATE"
	Case "S"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY SUBMITTED_BY, fb.SUBMIT_DATE"
	Case Else
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.SUBMIT_DATE DESC"
End Select

'Response.Write("<pre>" & strFeedbackSQL & "</pre>")
'Response.Flush()

With cmdFb
	.CommandText = strFeedbackSQL
End With

With rsFb
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFb
	
	Set fldFBID = .Fields("FB_ID")
	Set fldOrgName = .Fields("ORG_NAME_FULL_FB")
	Set fldAccessURL = .Fields("AccessURL")
%>
<a name="NewFB"></a>
<h2><%=TXT_NEW_RECORD_SUGGESTIONS%> (<%=TXT_UNASSIGNED%>)</h2>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_SUGGESTIONS_FOR_RECORDS%></p>
<%
	If .RecordCount > 0 Then
		If user_bCanAssignFeedbackVOL Then
%>
<form action="revfeedback_assign.asp" method="get" role="form" class="form-horizontal">
<%=g_strCacheFormVals%>
<%
		End If
%>
<table class="BasicBorder cell-padding-3 table-striped">
	<thead>
		<tr class="RevTitleBox">
<%		If user_bCanAssignFeedbackVOL Then%>
			<th>&nbsp;</th>
<%		End If
		If g_bMultiLingual Then%>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=L",vbNullString)%>" class="RevTitleText"><%=TXT_FEEDBACK_LANGUAGE%></a></th>
<%		End If%>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=P",vbNullString)%>" class="RevTitleText"><%=TXT_POSITION_TITLE%></a></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=O",vbNullString)%>" class="RevTitleText"><%=TXT_ORG_NAMES%></a></th>
			<th><%=TXT_LOCATED_IN%></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=S",vbNullString)%>" class="RevTitleText"><%=TXT_SUBMITTED_BY%></a></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=D",vbNullString)%>" class="RevTitleText"><%=TXT_DATE_SUBMITTED%></a></th>
<%		If user_bAddVOL Or user_bSuperUserVOL Then%>
			<th><%=TXT_ACTION%></th>
<%		End If%>
		</tr>
	</thead>
	<tbody>
<%
		While Not .EOF
			bDifferentLang = False
			If .Fields("Culture") <> g_objCurrentLang.Culture Then
				bDifferentLang = True
			End If
%>
		<tr>
<%			If user_bCanAssignFeedbackVOL Then%>
			<td><input type="checkbox" name="AssignFB" value="<%=fldFBID%>"></td>
<%			End If
			If g_bMultiLingual Then%>
			<td><%=.Fields("LanguageName")%></td>
<%			End If%>
			<td><%=.Fields("POSITION_TITLE")%></td>
			<td><%=fldOrgName.Value%></td>
			<td><%=.Fields("LOCATED_IN")%></td>
			<td align="right"><%=.Fields("SUBMITTED_BY")%>
					<div style="font-size:small; font-style:italic;"><%=fldAccessURL.Value%></div></td>
			<td align="right"><%=DateString(.Fields("SUBMIT_DATE"),True)%></td>
<%			If (user_bAddVOL Or user_bSuperUserVOL) Then%>
			<td class="container-action-list">
				<a class="btn btn-sm btn-info btn-action-list" href="<%=makeLink("revfeedback_view.asp","FBID=" & .Fields("FB_ID"),vbNullString)%>"><span class="glyphicon glyphicon-search" aria-hidden="true"></span> <%=TXT_VIEW_FEEDBACK%></a>
				<a class="btn btn-sm btn-info btn-action-list" href="<%=makeLink("entryform.asp","FBID=" & .Fields("FB_ID") & StringIf(bDifferentLang,"&UpdateLn=" & .Fields("Culture")),vbNullString)%>"><span class="glyphicon glyphicon-edit" aria-hidden="true"></span> <%=TXT_CREATE_RECORD%></a>
<%					If user_bCanDeleteRecordVOL Then%>
				<a class="btn btn-sm btn-danger btn-action-list" href="<%=makeLink("revfeedback_delete.asp","FBID=" & .Fields("FB_ID"),vbNullString)%>"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span> <%=TXT_DELETE%></a>
<%					End If%>
			</td>
<%			End If%>
		</tr>
<%			.MoveNext
		Wend
%>
	</tbody>
</table>
<%		If user_bCanAssignFeedbackVOL Then%>
	<div class="form-group">
		<label for="AssignTo" class="control-label col-xs-12 col-sm-6 col-md-4 col-lg-3"><%=TXT_ASSIGN_TO%></label>
		<div class="col-xs-12 col-sm-6 col-md-8 col-lg-9 form-inline"><%=strOwnerList%> <input type="submit" value="<%=TXT_SUBMIT%>"></div>
	</div>
</form>
<%
		End If
	End If
	.Close
End With
%>
<hr />
<%

'***************************************
' Feedback for Other Agencies
'***************************************
strFeedbackSQL = "SELECT vo.MemberID, fb.MemberID AS FB_MemberID, fb.FB_ID, fb.SUBMIT_DATE, fb.AccessURL, sl.Culture, sl.LanguageName AS LanguageName," & _
	"""SUBMITTED_BY"" = CASE WHEN u.User_ID IS NULL THEN CASE WHEN fb.SOURCE_NAME IS NULL THEN " & QsNl("[" & TXT_UNKNOWN & "]") & " ELSE fb.SOURCE_NAME END ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END, " & _
	"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL_FB," & _
	"vo.VNUM, vo.RECORD_OWNER, vod.POSITION_TITLE," & _
	"dbo.fn_VOL_CanUpdateRecord(vo.VNUM," & user_intID & "," & g_intViewTypeVOL & ",@@LANGID,GETDATE()) AS CAN_UPDATE" & vbCrLf & _
	"FROM VOL_Feedback fb" & vbCrLf & _
	"INNER JOIN STP_Language sl ON fb.LangID=sl.LangID" & vbCrLf & _
	"LEFT JOIN GBL_Users u ON fb.User_ID=u.User_ID" & vbCrLf & _
	"INNER JOIN VOL_Opportunity vo ON fb.VNUM=vo.VNUM" &  vbCrLf & _
	"LEFT JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 WHEN LangID=fb.LangID THEN 1 ELSE 2 END, LangID)" & vbCrLf & _
	"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 WHEN LangID=fb.LangID THEN 1 ELSE 2 END, LangID)" & vbCrLf & _
	"WHERE (" & vbCrLf & _
	"		vo.MemberID=" & g_intMemberID & vbCrLf & _
	"		OR fb.MemberID=" & g_intMemberID & vbCrLf & _
	"		OR dbo.fn_VOL_CanUpdateRecord(vo.VNUM," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE())=1" & vbCrLf & _
	"		OR EXISTS(SELECT * FROM VOL_OP_SharingProfile vos WHERE VNUM=vo.VNUM AND ShareMemberID_Cache=" & g_intMemberID & vbCrLf & _
	"			AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=vos.ProfileID AND shp.CanViewFeedback=1))" & vbCrLf & _
	"	)" & vbCrLf & _
	"AND vo.RECORD_OWNER <> " & Qs(user_strAgency,SQUOTE)

If Not Nl(g_strWhereClauseVOL) Then
	strFeedbackSQL = strFeedbackSQL & AND_CON & g_strWhereClauseVOL
End If

Select Case Request("Sort") 
	Case "L"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.LangID, fb.SUBMIT_DATE"
	Case "R" 
		strFeedbackSQL = strFeedbackSQL & " ORDER BY vo.RECORD_OWNER, fb.SUBMIT_DATE"
	Case "P"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY vod.POSITION_TITLE, fb.SUBMIT_DATE"
	Case "O"
		strFeedbackSQL = strFeedbackSQL & FB_BTD_ORG_SORT & ", fb.SUBMIT_DATE"
	Case "S"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY SUBMITTED_BY, fb.SUBMIT_DATE"
	Case Else
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.SUBMIT_DATE"
End Select

'Response.Write("<pre>" & strFeedbackSQL & "</pre>")
'Response.Flush()

Set cmdFb = Server.CreateObject("ADODB.Command")
With cmdFb
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strFeedbackSQL
	.CommandType = adCmdText
	.CommandTimeout = 0
End With
Set rsFb = Server.CreateObject("ADODB.Recordset")
With rsFb
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFb
	
	Set fldFBID = .Fields("FB_ID")
	Set fldOrgName = .Fields("ORG_NAME_FULL_FB")
	Set fldAccessURL = .Fields("AccessURL")
%>

<a name="OtherFB"></a>
<h2><%=TXT_FEEDBACK_EXISTING%> (<%=TXT_OTHER_AGENCIES%>)</h2>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_RECORDS_WITH_FEEDBACK%></p>
<%
	If .RecordCount > 0 Then
%>
<table class="BasicBorder cell-padding-3 table-striped">
	<thead>
		<tr class="RevTitleBox">
<%		If g_bMultiLingual Then%>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=L",vbNullString)%>" class="RevTitleText"><%=TXT_FEEDBACK_LANGUAGE%></a></th>
<%		End If%>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=P",vbNullString)%>" class="RevTitleText"><%=TXT_POSITION_TITLE%></a></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=O",vbNullString)%>" class="RevTitleText"><%=TXT_ORG_NAMES%></a></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=R",vbNullString)%>" class="RevTitleText"><%=TXT_RECORD_OWNER%></a></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=S",vbNullString)%>" class="RevTitleText"><%=TXT_SUBMITTED_BY%></a></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=D",vbNullString)%>" class="RevTitleText"><%=TXT_DATE_SUBMITTED%></a></th>
			<th><%=TXT_ACTION%></th>
		</tr>
	</thead>
	<tbody>
<%
		While Not .EOF
%>
		<tr valign="top">
<%			If g_bMultiLingual Then%>
			<td><%=.Fields("LanguageName")%></td>
<%			End If%>
			<td><a href="<%=makeVOLDetailsLink(.Fields("VNUM"),vbNullString,vbNullString)%>"><%=.Fields("POSITION_TITLE")%></a></td>
			<td><%=fldOrgName.Value%></td>
			<td><%=.Fields("RECORD_OWNER")%></td>
			<td align="right"><%=.Fields("SUBMITTED_BY")%>
					<div style="font-size:small; font-style:italic;"><%=fldAccessURL.Value%></div></td>
			<td align="right"><%=DateString(.Fields("SUBMIT_DATE"),True)%></td>
			<td class="container-action-list">
				<a class="btn btn-sm btn-info btn-action-list" href="<%=makeLink("revfeedback_view.asp","FBID=" & .Fields("FB_ID"),vbNullString)%>"><span class="glyphicon glyphicon-search" aria-hidden="true"></span> <%=TXT_VIEW_FEEDBACK%></a>
<%				If .Fields("CAN_UPDATE") Then%>
				<a class="btn btn-sm btn-info btn-action-list" href="<%=makeLink("entryform.asp","VNUM=" & .Fields("VNUM") & StringIf(bDifferentLang,"&UpdateLn=" & .Fields("Culture")),vbNullString)%>"><span class="glyphicon glyphicon-edit" aria-hidden="true"></span> <%=TXT_UPDATE%></a>
<%				End If
				If user_bCanDeleteRecordVOL And (.Fields("MemberID")=g_intMemberID Or .Fields("FB_MemberID")=g_intMemberID) Then%>
				<a class="btn btn-sm btn-danger btn-action-list" href="<%=makeLink("revfeedback_delete.asp","FBID=" & .Fields("FB_ID"),vbNullString)%>"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span> <%=TXT_DELETE%></a>
<%				End If%>
			</td>
		</tr>
<%
			.MoveNext
		Wend
%>
	</tbody>
</table>
<%
	End If
	.Close
End With
%>
<hr />
<%

'***************************************
' New Record Suggestions (Other)
'***************************************
strFeedbackSQL = "SELECT fb.FB_ID, fb.SUBMIT_DATE, fb.AccessURL, fb.FEEDBACK_OWNER, sl.Culture, sl.LanguageName AS LanguageName," & _
	"""SUBMITTED_BY"" = CASE WHEN u.User_ID IS NULL THEN CASE WHEN fb.SOURCE_NAME IS NULL THEN " & QsNl("(" & TXT_UNKNOWN & ")") & " ELSE fb.SOURCE_NAME END ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END, " & _
	"ISNULL(fb.ORG_NAME,dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME)) AS ORG_NAME_FULL_FB," & _
	"ISNULL(fb.POSITION_TITLE," & QsNl("(" & TXT_UNKNOWN & ")") & ") AS POSITION_TITLE," & vbCrLf & _
	"COALESCE(fb.LOCATION,dbo.fn_GBL_DisplayCommunity(bt.LOCATED_IN_CM,@@LANGID),btd.SITE_CITY) AS LOCATED_IN" & vbCrLf & _
	"FROM VOL_Feedback fb" & vbCrLf & _
	"INNER JOIN STP_Language sl ON fb.LangID=sl.LangID" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable bt ON fb.NUM=bt.NUM " & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
	"LEFT JOIN GBL_Users u ON fb.User_ID=u.User_ID " & _
	"WHERE fb.MemberID=" & g_intMemberID & vbCrLf & _
	"AND fb.VNUM IS NULL" & vbCrLf & _
	"AND fb.FEEDBACK_OWNER <> " & QsNl(user_strAgency)

Select Case Request("Sort") 
	Case "L"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.LangID, fb.SUBMIT_DATE"
	Case "P"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.POSITION_TITLE, fb.SUBMIT_DATE DESC"
	Case "O"
		strFeedbackSQL = strFeedbackSQL & FB_BTD_ORG_SORT
	Case "R"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.FEEDBACK_OWNER, fb.SUBMIT_DATE"
	Case "S"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY SUBMITTED_BY, fb.SUBMIT_DATE DESC"
	Case Else
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fb.SUBMIT_DATE DESC"
End Select

'Response.Write("<pre>" & strFeedbackSQL & "</pre>")
'Response.Flush()

With cmdFb
	.CommandText = strFeedbackSQL
End With

With rsFb
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFb
	
	Set fldFBID = .Fields("FB_ID")
	Set fldOrgName = .Fields("ORG_NAME_FULL_FB")
	Set fldAccessURL = .Fields("AccessURL")
%>
<a name="OtherNewFB"></a>
<h2><%=TXT_NEW_RECORD_SUGGESTIONS%> (<%=TXT_OTHER_AGENCIES%>)</h2>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_SUGGESTIONS_FOR_RECORDS%></p>
<%
	If .RecordCount > 0 Then
		If user_bSuperUserVOL Then
%>
<form action="revfeedback_assign.asp" method="get" role="form" class="form-horizontal">
<%=g_strCacheFormVals%>
<%
		End If
%>
<table class="BasicBorder cell-padding-3 table-striped">
	<thead>
		<tr class="RevTitleBox">
<%		If user_bSuperUserVOL Then%>
			<th>&nbsp;</th>
<%		End If
		If g_bMultiLingual Then%>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=L",vbNullString)%>" class="RevTitleText"><%=TXT_FEEDBACK_LANGUAGE%></a></th>
<%		End If%>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=P",vbNullString)%>" class="RevTitleText"><%=TXT_POSITION_TITLE%></a></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=O",vbNullString)%>" class="RevTitleText"><%=TXT_ORG_NAMES%></a></th>
			<th><%=TXT_LOCATED_IN%></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=R",vbNullString)%>" class="RevTitleText"><%=TXT_RECORD_OWNER%></a></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=S",vbNullString)%>" class="RevTitleText"><%=TXT_SUBMITTED_BY%></a></th>
			<th><a href="<%=makeLink(ps_strThisPage,"Sort=D",vbNullString)%>" class="RevTitleText"><%=TXT_DATE_SUBMITTED%></a></th>
<%		If user_bAddVOL Or user_bSuperUserVOL Then%>
			<th><%=TXT_ACTION%></th>
<%		End If%>
		</tr>
	</thead>
	<tbody>
<%
		While Not .EOF
			bDifferentLang = False
			If .Fields("Culture") <> g_objCurrentLang.Culture Then
				bDifferentLang = True
			End If
%>
		<tr>
<%			If user_bSuperUserVOL Then%>
			<td><input type="checkbox" name="AssignFB" value="<%=fldFBID%>"></td>
<%			End If
			If g_bMultiLingual Then%>
			<td><%=.Fields("LanguageName")%></td>
<%			End If%>
			<td><%=.Fields("POSITION_TITLE")%></td>
			<td><%=fldOrgName.Value%></td>
			<td><%=.Fields("LOCATED_IN")%></td>
			<td><%=.Fields("FEEDBACK_OWNER")%></td>
			<td align="right"><%=.Fields("SUBMITTED_BY")%>
					<div style="font-size:small; font-style:italic;"><%=fldAccessURL.Value%></div></td>
			<td align="right"><%=DateString(.Fields("SUBMIT_DATE"),True)%></td>
<%				If (user_bAddCIC Or user_bSuperUserCIC) Then%>
			<td class="container-action-list">
				<a class="btn btn-sm btn-info btn-action-list" href="<%=makeLink("revfeedback_view.asp","FBID=" & fldFBID,vbNullString)%>"><span class="glyphicon glyphicon-search" aria-hidden="true"></span> <%=TXT_VIEW_FEEDBACK%></a>
				<a class="btn btn-sm btn-info btn-action-list" href="<%=makeLink("entryform.asp","FBID=" & fldFBID & StringIf(bDifferentLang,"&UpdateLn=" & .Fields("Culture")),vbNullString)%>"><span class="glyphicon glyphicon-edit" aria-hidden="true"></span> <%=TXT_CREATE_RECORD%></a>
<%					If user_bSuperUserCIC Or user_bCanDeleteRecordCIC Then%>
				<a class="btn btn-sm btn-danger btn-action-list" href="<%=makeLink("revfeedback_delete.asp","FBID=" & fldFBID,vbNullString)%>"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span> <%=TXT_DELETE%></a>
<%					End If%>
			</td>
<%				End If%>
		</tr>
<%			.MoveNext
		Wend
%>
	</tbody>
</table>
<%		If user_bSuperUserVOL Then%>
	<div class="form-group">
		<label for="AssignTo" class="control-label col-xs-12 col-sm-6 col-md-4 col-lg-3"><%=TXT_ASSIGN_TO%></label>
		<div class="col-xs-12 col-sm-6 col-md-8 col-lg-9 form-inline"><%=strOwnerList%> <input type="submit" value="<%=TXT_SUBMIT%>"></div>
	</div>
</form>
<%
		End If
	End If
	.Close
End With

Set rsFb = Nothing
Set cmdFb = Nothing
%>

<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
