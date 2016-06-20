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
<!--#include file="includes/core/adovbs.inc" -->
<!--#include file="includes/core/incVBUtils.asp" -->
<!--#include file="includes/validation/incBasicTypes.asp" -->
<!--#include file="includes/core/incRExpFuncs.asp" -->
<!--#include file="includes/core/incHandleError.asp" -->
<!--#include file="includes/core/incSetLanguage.asp" -->
<!--#include file="includes/core/incPassVars.asp" -->
<!--#include file="text/txtGeneral.asp" -->
<!--#include file="text/txtError.asp" -->
<!--#include file="includes/core/incConnection.asp" -->
<!--#include file="includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtFeedbackCommon.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtReviewFeedback.asp" -->
<!--#include file="includes/list/incAgencyList.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<%

Const FB_ORG_SORT = " ORDER BY ISNULL(fb.SORT_AS,fb.ORG_LEVEL_1), fb.ORG_LEVEL_2, fb.ORG_LEVEL_3, fb.ORG_LEVEL_4, fb.ORG_LEVEL_5, STUFF(CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=fbe.NUM) THEN NULL ELSE COALESCE(', ' + fb.LOCATION_NAME,'') + COALESCE(', ' + fb.SERVICE_NAME_LEVEL_1,'') + COALESCE(', ' + fb.SERVICE_NAME_LEVEL_2,'') END, 1, 2, ''), fbe.SUBMIT_DATE"

Const FB_BTD_ORG_SORT = " ORDER BY ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, STUFF(CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=fbe.NUM) THEN NULL ELSE COALESCE(', ' + btd.LOCATION_NAME,'') + COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') + COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'') END, 1, 2, ''), fbe.SUBMIT_DATE"

If Not (user_bFeedbackAlertCIC _
		Or user_bAddCIC _
		Or user_intUpdateCIC <> UPDATE_NONE _
		Or user_intCanUpdatePubs <> UPDATE_NONE _
		) Then
	Call securityFailure()
End If

Call makePageHeader(TXT_REVIEW_FEEDBACK & " (" & TXT_CIC & ")", TXT_REVIEW_FEEDBACK & " (" & TXT_CIC & ")", True, False, True, True)

Dim strFeedbackSQL
Dim cmdFb, rsFb
Dim fldNUM, _
	fldFBID, _
	fldOrgName, _
	bDifferentLang
Dim strOwnerList

Call openAgencyListRst(DM_CIC, False, False)
strOwnerList = makeRecordOwnerAgencyList(user_strAgency, "AssignTo", False)
Call closeAgencyListRst()

Set cmdFb = Server.CreateObject("ADODB.Command")
Set rsFb = Server.CreateObject("ADODB.Recordset")
With cmdFb
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdText
	.CommandTimeout = 0
End With

If user_bFeedbackAlertCIC _
	Or user_bAddCIC _
	Or user_intUpdateCIC <> UPDATE_NONE Then
%>
<ul>
	<li><a href="#MyFB"><%=TXT_FEEDBACK_EXISTING%> (<%=user_strAgency%>)</a></li>
	<li><a href="#MyNewFB"><%=TXT_NEW_RECORD_SUGGESTIONS%> (<%=user_strAgency%>)</a></li>
	<li><a href="#NewFB"><%=TXT_NEW_RECORD_SUGGESTIONS%>  (<%=TXT_UNASSIGNED%>)</a></li>
<%	If user_intCanUpdatePubs <> UPDATE_NONE Then%>
	<li><a href="#PubFB"><%=TXT_PUBLICATION_FEEDBACK%></a></li>
<%	End If%>
	<li><a href="#OtherFB"><%=TXT_FEEDBACK_EXISTING%> (<%=TXT_OTHER_AGENCIES%>)</a></li>
	<li><a href="#OtherNewFB"><%=TXT_NEW_RECORD_SUGGESTIONS%> (<%=TXT_OTHER_AGENCIES%>)</a></li>
</ul>
<hr>
<%

'***************************************
' Feedback for User's Own Agency
'***************************************
strFeedbackSQL = "SELECT bt.NUM, bt.MemberID, fbe.MemberID AS FB_MemberID, fbe.FB_ID, fbe.SUBMIT_DATE, sl.Culture, sl.LanguageName AS LanguageName," & _
	"CASE WHEN u.User_ID IS NULL THEN CASE WHEN fbe.SOURCE_NAME IS NULL THEN '[" & TXT_UNKNOWN & "]' ELSE fbe.SOURCE_NAME END ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END AS SUBMITTED_BY, " & _
	"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL_FB," & _
	"dbo.fn_CIC_CanUpdateRecord(bt.NUM," & user_intID & "," & g_intViewTypeCIC & ",btd.LangID,GETDATE()) AS CAN_UPDATE" & vbCrLf & _
	"FROM GBL_FeedbackEntry fbe" & vbCrLf & _
	"INNER JOIN STP_Language sl ON fbe.LangID=sl.LangID" & vbCrLf & _
	"LEFT JOIN CIC_Feedback cfb ON fbe.FB_ID=cfb.FB_ID" & vbCrLf & _
	"LEFT JOIN CCR_Feedback ccfb ON fbe.FB_ID=ccfb.FB_ID" & vbCrLf & _
	"LEFT JOIN GBL_Feedback fb ON fbe.FB_ID=fb.FB_ID" & vbCrLf & _
	"LEFT JOIN GBL_Users u ON fbe.User_ID=u.User_ID" & vbCrLf & _
	"INNER JOIN GBL_BaseTable bt ON fbe.NUM=bt.NUM" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 WHEN LangID=fbe.LangID THEN 1 ELSE 2 END, LangID)" & vbCrLf & _
	"WHERE (" & vbCrLf & _
	"		bt.MemberID=" & g_intMemberID & vbCrLf & _
	"		OR fbe.MemberID=" & g_intMemberID & vbCrLf & _
	"		OR dbo.fn_CIC_CanUpdateRecord(bt.NUM," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE())=1" & vbCrLf & _
	"		OR EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE NUM=bt.NUM AND ShareMemberID_Cache=" & g_intMemberID & vbCrLf & _
	"			AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=bts.ProfileID AND shp.CanViewFeedback=1))" & vbCrLf & _
	"	)" & vbCrLf & _
	"AND (fb.FB_ID IS NOT NULL OR cfb.FB_ID IS NOT NULL OR ccfb.FB_ID IS NOT NULL)" & vbCrLf & _
	"AND bt.RECORD_OWNER=" & QsNl(user_strAgency)

If Not Nl(g_strWhereClauseCIC) Then
	strFeedbackSQL = strFeedbackSQL & AND_CON & g_strWhereClauseCIC
End If

Select Case Request("Sort") 
	Case "L"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.LangID, fbe.SUBMIT_DATE"
	Case "N" 
		strFeedbackSQL = strFeedbackSQL & " ORDER BY bt.NUM, fbe.SUBMIT_DATE"				
	Case "O"
		strFeedbackSQL = strFeedbackSQL & FB_BTD_ORG_SORT
	Case "S"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY SUBMITTED_BY, fbe.SUBMIT_DATE"
	Case Else
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.SUBMIT_DATE"
End Select

'Response.Write("<pre>" & Server.HTMLEncode(strFeedbackSQL) & "</pre>")
'Response.Flush()

With cmdFb
	.CommandText = strFeedbackSQL
End With

With rsFb
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFb
	Set fldNUM = .Fields("NUM")
	Set fldOrgName = .Fields("ORG_NAME_FULL_FB")
	Set fldFBID = .Fields("FB_ID")
%>

<a name="MyFB"></a><h2><%=TXT_FEEDBACK_EXISTING%> (<%=user_strAgency%>)</h2>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_RECORDS_WITH_FEEDBACK%></p>
<%
	If .RecordCount > 0 Then
%>
<table class="BasicBorder cell-padding-3">
<tr class="RevTitleBox">
<%		If g_bMultiLingual Then%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=L",vbNullString)%>" class="RevTitleText"><%=TXT_FEEDBACK_LANGUAGE%></a></th>
<%		End If%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=N",vbNullString)%>" class="RevTitleText"><%=TXT_RECORD_NUM%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=O",vbNullString)%>" class="RevTitleText"><%=TXT_ORG_NAMES%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=S",vbNullString)%>" class="RevTitleText"><%=TXT_SUBMITTED_BY%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=D",vbNullString)%>" class="RevTitleText"><%=TXT_DATE_SUBMITTED%></a></th>
	<th><%=TXT_ACTION%></th>
</tr>
<%
		While Not .EOF
			bDifferentLang = False
			If .Fields("Culture") <> g_objCurrentLang.Culture Then
				bDifferentLang = True
			End If
			
%>
<tr valign="TOP">
<%		If g_bMultiLingual Then%>
	<td><%=.Fields("LanguageName")%></td>
<%		End If%>
	<td><a href="<%=makeDetailsLink(fldNUM,vbNullString,vbNullString)%>"><%=fldNUM%></a></td>
	<td><%=fldOrgName.Value%></td>
	<td align="right"><%=.Fields("SUBMITTED_BY")%></td>
	<td align="right"><%=DateString(.Fields("SUBMIT_DATE"),True)%></td>
	<td>[&nbsp;<a href="<%=makeLink("revfeedback_view.asp","FBID=" & fldFBID,vbNullString)%>"><%=TXT_VIEW_FEEDBACK%></a><%
		If .Fields("CAN_UPDATE") = 1 Then
		%>&nbsp;|&nbsp;<a href="<%=makeLink("entryform.asp","NUM=" & fldNUM & StringIf(bDifferentLang,"&UpdateLn=" & .Fields("Culture")),vbNullString)%>"><%=TXT_UPDATE%></a><%
		End If
		If user_bCanDeleteRecordCIC And .Fields("CAN_UPDATE") = 1 And (.Fields("MemberID")=g_intMemberID Or .Fields("FB_MemberID")=g_intMemberID) Then
		%>&nbsp;|&nbsp;<a href="<%=makeLink("revfeedback_delete.asp","FBID=" & fldFBID,vbNullString)%>"><%=TXT_DELETE%></a><%
		End If%>&nbsp;]</td>
</tr>
<%			.MoveNext
		Wend
%>
</table>
<%
	End If
	.Close
End With

'***************************************
' New Record Suggestions (User's Agency)
'***************************************

strFeedbackSQL = "SELECT fbe.FB_ID, fbe.SUBMIT_DATE, sl.Culture, sl.LanguageName AS LanguageName," & vbCrLf & _
	"""SUBMITTED_BY"" = CASE WHEN u.User_ID IS NULL THEN CASE WHEN fbe.SOURCE_NAME IS NULL THEN '[" & TXT_UNKNOWN & "]' ELSE fbe.SOURCE_NAME END ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END, " & _
	"dbo.fn_GBL_DisplayFullOrgName_2(NULL,fb.ORG_LEVEL_1,fb.ORG_LEVEL_2,fb.ORG_LEVEL_3,fb.ORG_LEVEL_4,fb.ORG_LEVEL_5,fb.LOCATION_NAME,fb.SERVICE_NAME_LEVEL_1,fb.SERVICE_NAME_LEVEL_2, 1, 1) AS ORG_NAME_FULL_FB" & vbCrLf & _
	"FROM GBL_FeedbackEntry fbe" & vbCrLf & _
	"INNER JOIN STP_Language sl ON fbe.LangID=sl.LangID" & vbCrLf & _
	"LEFT JOIN GBL_Feedback fb ON fbe.FB_ID=fb.FB_ID" & vbCrLf & _
	"LEFT JOIN CIC_Feedback cfb ON fbe.FB_ID=cfb.FB_ID" & vbCrLf & _
	"LEFT JOIN CCR_Feedback ccfb ON fbe.FB_ID=ccfb.FB_ID" & vbCrLf & _
	"LEFT OUTER JOIN GBL_Users u ON fbe.User_ID=u.User_ID" & vbCrLf & _
	"WHERE fbe.MemberID=" & g_intMemberID & vbCrLf & _
	"AND fbe.NUM IS NULL" & vbCrLf & _
	"AND fbe.FEEDBACK_OWNER=" & QsNl(user_strAgency)

Select Case Request("Sort")
	Case "L"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.LangID, fbe.SUBMIT_DATE"
	Case "O"
		strFeedbackSQL = strFeedbackSQL & FB_ORG_SORT
	Case "S"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY SUBMITTED_BY, fbe.SUBMIT_DATE"
	Case Else
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.SUBMIT_DATE"
End Select

With cmdFb
	.CommandText = strFeedbackSQL
End With
With rsFb
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFb
	
	Set fldFBID = .Fields("FB_ID")
	Set fldOrgName = .Fields("ORG_NAME_FULL_FB")
%>
<a name="MyNewFB"></a><h2><%=TXT_NEW_RECORD_SUGGESTIONS%> (<%=user_strAgency%>)</h2>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_SUGGESTIONS_FOR_RECORDS%></p>
<%
	If .RecordCount > 0 Then
		If user_bCanAssignFeedbackCIC Then
%>
<form action="revfeedback_assign.asp" method="get">
<%=g_strCacheFormVals%>
<%
		End If
%>
<table class="BasicBorder cell-padding-3">
<tr class="RevTitleBox">
<%		If user_bCanAssignFeedbackCIC Then%>
	<th>&nbsp;</th>
<%		End If%>
<%		If g_bMultiLingual Then%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=L",vbNullString)%>" class="RevTitleText"><%=TXT_FEEDBACK_LANGUAGE%></a></th>
<%		End If%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=O",vbNullString)%>" class="RevTitleText"><%=TXT_ORG_NAMES%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=S",vbNullString)%>" class="RevTitleText"><%=TXT_SUBMITTED_BY%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=D",vbNullString)%>" class="RevTitleText"><%=TXT_DATE_SUBMITTED%></a></th>
<%		If user_bAddCIC Or user_bSuperUser Then%>
	<th><%=TXT_ACTION%></th>
<%		End If%>
</tr>
<%
		While Not .EOF
			bDifferentLang = False
			If .Fields("Culture") <> g_objCurrentLang.Culture Then
				bDifferentLang = True
			End If
%>
<tr>
<%			If user_bCanAssignFeedbackCIC Then%>
	<td><input type="checkbox" name="AssignFB" id="AssignFB_<%=fldFBID%>" value="<%=fldFBID%>"></td>
<%			End If%>
<%			If g_bMultiLingual Then%>
	<td><label for="AssignFB_<%=fldFBID%>"><%=.Fields("LanguageName")%></label></td>
<%			End If%>
	<td><%=fldOrgName.Value%></td>
	<td align="right"><%=.Fields("SUBMITTED_BY")%></td>
	<td align="right"><%=DateString(.Fields("SUBMIT_DATE"),True)%></td>
<%
			If (user_bAddCIC Or user_bSuperUserCIC) Then
%>
	<td>[&nbsp;<a href="<%=makeLink("revfeedback_view.asp","FBID=" & fldFBID,vbNullString)%>"><%=TXT_VIEW_FEEDBACK%></a>&nbsp;|&nbsp;<a href="<%=makeLink("entryform.asp","FBID=" & fldFBID & StringIf(bDifferentLang,"&UpdateLn=" & .Fields("Culture")),vbNullString)%>"><%=TXT_CREATE_RECORD%></a><%
				If user_bCanDeleteRecordCIC Then
		%>&nbsp;|&nbsp;<a href="<%=makeLink("revfeedback_delete.asp","FBID=" & fldFBID,vbNullString)%>"><%=TXT_DELETE%></a><%
				End If
	%>&nbsp;]</td>
<%
			End If
%>
</tr>
<%			.MoveNext
		Wend
%>
</table>
<%
		If user_bCanAssignFeedbackCIC Then%>
<p><strong><%=TXT_ASSIGN_TO%></strong><%=strOwnerList%> <input type="submit" value="<%=TXT_SUBMIT%>"></p>
</form>
<%
		End If
	End If
	.Close
End With

'***************************************
' New Record Suggestions (Unassigned)
'***************************************

strFeedbackSQL = "SELECT fbe.FB_ID,fbe.SUBMIT_DATE,sl.Culture,sl.LanguageName AS LanguageName," & vbCrLf & _
	"""SUBMITTED_BY"" = CASE WHEN u.User_ID IS NULL THEN CASE WHEN fbe.SOURCE_NAME IS NULL THEN '[" & TXT_UNKNOWN & "]' ELSE fbe.SOURCE_NAME END ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END, " & _
	"dbo.fn_GBL_DisplayFullOrgName_2(NULL,fb.ORG_LEVEL_1,fb.ORG_LEVEL_2,fb.ORG_LEVEL_3,fb.ORG_LEVEL_4,fb.ORG_LEVEL_5,fb.LOCATION_NAME,fb.SERVICE_NAME_LEVEL_1,fb.SERVICE_NAME_LEVEL_2, 1, 1) AS ORG_NAME_FULL_FB" & vbCrLf & _
	"FROM GBL_FeedbackEntry fbe" & vbCrLf & _
	"INNER JOIN STP_Language sl ON fbe.LangID=sl.LangID" & vbCrLf & _
	"LEFT JOIN GBL_Feedback fb ON fbe.FB_ID=fb.FB_ID" & vbCrLf & _
	"LEFT JOIN CIC_Feedback cfb ON fbe.FB_ID=cfb.FB_ID" & vbCrLf & _
	"LEFT JOIN CCR_Feedback ccfb ON fbe.FB_ID=ccfb.FB_ID" & vbCrLf & _
	"LEFT OUTER JOIN GBL_Users u ON fbe.User_ID=u.User_ID" & vbCrLf & _
	"WHERE fbe.MemberID=" & g_intMemberID & vbCrLf & _
	"AND fbe.NUM IS NULL" & vbCrLf & _
	"AND fbe.FEEDBACK_OWNER IS NULL"

Select Case Request("Sort")
	Case "L"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.LangID, fbe.SUBMIT_DATE"
	Case "O"
		strFeedbackSQL = strFeedbackSQL & FB_ORG_SORT
	Case "S"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY SUBMITTED_BY, fbe.SUBMIT_DATE"
	Case Else
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.SUBMIT_DATE"
End Select

With cmdFb
	.CommandText = strFeedbackSQL
End With
With rsFb
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFb
	
	Set fldFBID = .Fields("FB_ID")
	Set fldOrgName = .Fields("ORG_NAME_FULL_FB")
%>
<a name="NewFB"></a><h2><%=TXT_NEW_RECORD_SUGGESTIONS%> (<%=TXT_UNASSIGNED%>)</h2>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_SUGGESTIONS_FOR_RECORDS%></p>
<%
	If .RecordCount > 0 Then
		If user_bCanAssignFeedbackCIC Then
%>
<form action="revfeedback_assign.asp" method="get">
<%=g_strCacheFormVals%>
<%		
		End If
%>
<table class="BasicBorder cell-padding-3">
<tr class="RevTitleBox">
<%		If user_bCanAssignFeedbackCIC Then%>
	<th>&nbsp;</th>
<%		End If%>
<%If g_bMultiLingual Then%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=L",vbNullString)%>" class="RevTitleText"><%=TXT_FEEDBACK_LANGUAGE%></a></th>
<%End If%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=O",vbNullString)%>" class="RevTitleText"><%=TXT_ORG_NAMES%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=S",vbNullString)%>" class="RevTitleText"><%=TXT_SUBMITTED_BY%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=D",vbNullString)%>" class="RevTitleText"><%=TXT_DATE_SUBMITTED%></a></th>
<%		If user_bAddCIC Or user_bSuperUser Then%>
	<th><%=TXT_ACTION%></th>
<%		End If%>
</tr>
<%
		While Not .EOF
			bDifferentLang = False
			If .Fields("Culture") <> g_objCurrentLang.Culture Then
				bDifferentLang = True
			End If
%>
<tr>
<%			If user_bCanAssignFeedbackCIC Then%>
	<td><input type="checkbox" name="AssignFB" id="AssignFB_<%=fldFBID%>" value="<%=fldFBID%>"></td>
<%			End If%>
<%			If g_bMultiLingual Then%>
	<td><label for="AssignFB_<%=fldFBID%>"><%=.Fields("LanguageName")%></label></td>
<%			End If%>
	<td><%=fldOrgName.Value%></td>
	<td align="right"><%=.Fields("SUBMITTED_BY")%></td>
	<td align="right"><%=DateString(.Fields("SUBMIT_DATE"),True)%></td>
<%
			If (user_bAddCIC Or user_bSuperUserCIC) Then
%>
	<td>[&nbsp;<a href="<%=makeLink("revfeedback_view.asp","FBID=" & fldFBID,vbNullString)%>"><%=TXT_VIEW_FEEDBACK%></a>&nbsp;|&nbsp;<a href="<%=makeLink("entryform.asp","FBID=" & fldFBID & StringIf(bDifferentLang,"&UpdateLn=" & .Fields("Culture")),vbNullString)%>"><%=TXT_CREATE_RECORD%></a><%
				If user_bSuperUserCIC Then
		%>&nbsp;|&nbsp;<a href="<%=makeLink("revfeedback_delete.asp","FBID=" & fldFBID,vbNullString)%>"><%=TXT_DELETE%></a><%
				End If
	%>&nbsp;]</td>
<%
			End If
%>
</tr>
<%			.MoveNext
		Wend
%>
</table>
<%
		If user_bCanAssignFeedbackCIC Then
%>
<p><strong><%=TXT_ASSIGN_TO%></strong><%=strOwnerList%> <input type="submit" value="<%=TXT_SUBMIT%>"></p>
</form>
<%
		End If
	End If
	.Close
End With

'***************************************
' Publication Feedback
'***************************************
If user_intCanUpdatePubs <> UPDATE_NONE Then

strFeedbackSQL = "SELECT bt.MemberID, fbe.MemberID AS FB_MemberID, fbe.SUBMIT_DATE,pb.PB_ID,pb.PubCode,pfb.PB_FB_ID,pfb.BT_PB_ID,sl.Culture,sl.LanguageName AS LanguageName," & _
	"CASE WHEN u.User_ID IS NULL THEN ISNULL(fbe.SOURCE_NAME, '[" & TXT_UNKNOWN & "]') ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END AS SUBMITTED_BY, " & _
	"btd.NUM, dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL_FB" & vbCrLf & _ 
	"FROM CIC_Feedback_Publication pfb" & vbCrLf & _
	"INNER JOIN CIC_BT_PB pbr ON pfb.BT_PB_ID=pbr.BT_PB_ID" & vbCrLf & _
	"INNER JOIN CIC_Publication pb ON pbr.PB_ID=pb.PB_ID" & vbCrLf & _
	"INNER JOIN GBL_FeedbackEntry fbe ON pfb.FB_ID=fbe.FB_ID" & vbCrLf & _
	"INNER JOIN STP_Language sl ON fbe.LangID=sl.LangID" & vbCrLf & _
	"INNER JOIN GBL_BaseTable bt ON fbe.NUM=bt.NUM" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 WHEN LangID=fbe.LangID THEN 1 ELSE 2 END, LangID)" & vbCrLf & _
	"LEFT JOIN GBL_Users u ON fbe.User_ID = u.User_ID" & vbCrLf & _
	"WHERE dbo.fn_CIC_CanUpdatePub(bt.NUM,pb.PB_ID," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE())=1"

If Not Nl(g_strWhereClauseCIC) Then
	strFeedbackSQL = strFeedbackSQL & AND_CON & g_strWhereClauseCIC
End If

Select Case Request("Sort") 
	Case "L"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.LangID, fbe.SUBMIT_DATE"
	Case "O"
		strFeedbackSQL = strFeedbackSQL & FB_BTD_ORG_SORT
	Case "P"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY pb.PubCode, fbe.SUBMIT_DATE"
	Case "S"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY SUBMITTED_BY, fbe.SUBMIT_DATE"
	Case Else
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.SUBMIT_DATE"
End Select

'Response.Write("<pre>" & Server.HTMLEncode(strFeedbackSQL) & "</pre>")
'Response.Flush()

With cmdFb
	.CommandText = strFeedbackSQL
End With
With rsFb
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFb

	Set fldOrgName = .Fields("ORG_NAME_FULL_FB")
%>
<a name="PubFB"></a><h2><%=TXT_PUBLICATION_FEEDBACK%></h2>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_RECORDS_WITH_PUB_FEEDBACK%></p>
<%	If .RecordCount > 0 Then%>
<table class="BasicBorder cell-padding-3">
<tr class="RevTitleBox">
<%If g_bMultiLingual Then%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=L",vbNullString)%>" class="RevTitleText"><%=TXT_FEEDBACK_LANGUAGE%></a></th>
<%End If%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=O",vbNullString)%>" class="RevTitleText"><%=TXT_ORG_NAMES%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=P",vbNullString)%>" class="RevTitleText"><%=TXT_PUB_CODE%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=S",vbNullString)%>" class="RevTitleText"><%=TXT_SUBMITTED_BY%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=D",vbNullString)%>" class="RevTitleText"><%=TXT_DATE_SUBMITTED%></a></th>
	<th><%=TXT_ACTION%></th>
</tr>
<%
		While Not .EOF
			bDifferentLang = False
			If .Fields("Culture") <> g_objCurrentLang.Culture Then
				bDifferentLang = True
			End If
%>
<tr>
<%If g_bMultiLingual Then%>
	<td><%=.Fields("LanguageName")%></td>
<%End If%>
	<td><%=fldOrgName.Value%></td>
	<td align="right"><%=.Fields("PubCode")%></td>
	<td align="right"><%=.Fields("SUBMITTED_BY")%></td>
	<td align="right"><%=DateString(.Fields("SUBMIT_DATE"),True)%></td>
	<td>[&nbsp;<a href="<%=makeLink("revfeedback_view.asp","PBFBID=" & .Fields("PB_FB_ID"),vbNullString)%>"><%=TXT_VIEW_FEEDBACK%></a><%
			If (user_intCanUpdatePubs <> UPDATE_NONE And (Not user_bLimitedViewCIC Or user_intPBID = .Fields("PB_ID"))) Then
		%>&nbsp;|&nbsp;<a href="<%=makeLink("updatepubs/edit", "NUM=" & .Fields("NUM") & "&BTPBID=" & .Fields("BT_PB_ID"), vbNullString)%>"><%=TXT_UPDATE%></a><%
			End If
			If (user_bCanDeleteRecordCIC) And (.Fields("MemberID")=g_intMemberID Or .Fields("FB_MemberID")=g_intMemberID) Then
		%>&nbsp;|&nbsp;<a href="<%=makeLink("revfeedback_delete.asp","PBFBID=" & .Fields("PB_FB_ID"),vbNullString)%>"><%=TXT_DELETE%></a><%
			End If
	%>&nbsp;]</td>		
</tr>
<%			.MoveNext
		Wend
%>
</table>
<%
	End If
	.Close
End With

End If

'***************************************
' Feedback for Other Agencies
'***************************************
strFeedbackSQL = "SELECT bt.NUM, bt.MemberID, fbe.MemberID AS FB_MemberID, fbe.FB_ID, fbe.SUBMIT_DATE, sl.Culture, sl.LanguageName AS LanguageName," & _
	"CASE WHEN u.User_ID IS NULL THEN CASE WHEN fbe.SOURCE_NAME IS NULL THEN '[" & TXT_UNKNOWN & "]' ELSE fbe.SOURCE_NAME END ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END AS SUBMITTED_BY, " & _
	"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL_FB," & vbCrLf & _
	"bt.RECORD_OWNER AS RECORD_OWNER," & _
	"dbo.fn_CIC_CanUpdateRecord(bt.NUM," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE()) AS CAN_UPDATE" & vbCrLf & _
	"FROM GBL_FeedbackEntry fbe" & vbCrLf & _
	"INNER JOIN STP_Language sl ON fbe.LangID=sl.LangID" & vbCrLf & _
	"LEFT JOIN CIC_Feedback cfb ON fbe.FB_ID=cfb.FB_ID" & vbCrLf & _
	"LEFT JOIN CCR_Feedback ccfb ON fbe.FB_ID=ccfb.FB_ID" & vbCrLf & _	
	"LEFT JOIN GBL_Feedback fb ON fbe.FB_ID=fb.FB_ID" & vbCrLf & _
	"LEFT JOIN GBL_Users u ON fbe.User_ID=u.User_ID" & vbCrLf & _
	"INNER JOIN GBL_BaseTable bt ON fbe.NUM=bt.NUM" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 WHEN LangID=fbe.LangID THEN 1 ELSE 2 END, LangID)" & vbCrLf & _
	"WHERE (" & vbCrLf & _
	"		bt.MemberID=" & g_intMemberID & vbCrLf & _
	"		OR fbe.MemberID=" & g_intMemberID & vbCrLf & _
	"		OR dbo.fn_CIC_CanUpdateRecord(bt.NUM," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE())=1" & vbCrLf & _
	"		OR EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE NUM=bt.NUM AND ShareMemberID_Cache=" & g_intMemberID & vbCrLf & _
	"			AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=bts.ProfileID AND shp.CanViewFeedback=1))" & vbCrLf & _
	"	)" & vbCrLf & _
	"AND (fb.FB_ID IS NOT NULL OR cfb.FB_ID IS NOT NULL OR ccfb.FB_ID IS NOT NULL)" & vbCrLf & _
	"AND bt.RECORD_OWNER <> " & QsNl(user_strAgency)

If Not Nl(g_strWhereClauseCIC) Then
	strFeedbackSQL = strFeedbackSQL & AND_CON & g_strWhereClauseCIC
End If

Select Case Request("Sort") 
	Case "L"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.LangID, fbe.SUBMIT_DATE"
	Case "N" 
		strFeedbackSQL = strFeedbackSQL & " ORDER BY bt.NUM, fbe.SUBMIT_DATE"				
	Case "O"
		strFeedbackSQL = strFeedbackSQL & FB_BTD_ORG_SORT
	Case "R" 
		strFeedbackSQL = strFeedbackSQL & " ORDER BY bt.RECORD_OWNER, fbe.SUBMIT_DATE"
	Case "S"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY SUBMITTED_BY, fbe.SUBMIT_DATE"
	Case Else
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.SUBMIT_DATE"
End Select

'Response.Write(strFeedbackSQL)
'Response.Flush()

With cmdFb
	.CommandText = strFeedbackSQL
End With
With rsFb
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFb
	
	Set fldNUM = .Fields("NUM")
	Set fldFBID = .Fields("FB_ID")
	Set fldOrgName = .Fields("ORG_NAME_FULL_FB")
%>

<a name="OtherFB"></a><h2><%=TXT_FEEDBACK_EXISTING%> (<%=TXT_OTHER_AGENCIES%>)</h2>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_RECORDS_WITH_FEEDBACK%></p>
<%	If .RecordCount > 0 Then%>
<table class="BasicBorder cell-padding-3">
<tr class="RevTitleBox">
<%If g_bMultiLingual Then%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=L",vbNullString)%>" class="RevTitleText"><%=TXT_FEEDBACK_LANGUAGE%></a></th>
<%End If%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=N",vbNullString)%>" class="RevTitleText"><%=TXT_RECORD_NUM%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=O",vbNullString)%>" class="RevTitleText"><%=TXT_ORG_NAMES%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=R",vbNullString)%>" class="RevTitleText"><%=TXT_RECORD_OWNER%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=S",vbNullString)%>" class="RevTitleText"><%=TXT_SUBMITTED_BY%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=D",vbNullString)%>" class="RevTitleText"><%=TXT_DATE_SUBMITTED%></a></th>
	<th><%=TXT_ACTION%></th>
</tr>
<%
		While Not .EOF
			bDifferentLang = False
			If .Fields("Culture") <> g_objCurrentLang.Culture Then
				bDifferentLang = True
			End If
%>
<tr valign="TOP">
<%If g_bMultiLingual Then%>
	<td><%=.Fields("LanguageName")%></td>
<%End If%>
	<td><a href="<%=makeDetailsLink(fldNUM,vbNullString,vbNullString)%>"><%=fldNUM%></a></td>
	<td><%=fldOrgName.Value%></td>
	<td><%=.Fields("RECORD_OWNER")%></td>
	<td align="right"><%=.Fields("SUBMITTED_BY")%></td>
	<td align="right"><%=DateString(.Fields("SUBMIT_DATE"),True)%></td>
	<td>[&nbsp;<a href="<%=makeLink("revfeedback_view.asp","FBID=" & fldFBID,vbNullString)%>"><%=TXT_VIEW_FEEDBACK%></a><%
		If .Fields("CAN_UPDATE") = 1 Then
		%>&nbsp;|&nbsp;<a href="<%=makeLink("entryform.asp","NUM=" & fldNUM & StringIf(bDifferentLang,"&UpdateLn=" & .Fields("Culture")),vbNullString)%>"><%=TXT_UPDATE%></a><%
		End If
		If user_bSuperUserCIC And (.Fields("MemberID")=g_intMemberID Or .Fields("FB_MemberID")=g_intMemberID) Then
		%>&nbsp;|&nbsp;<a href="<%=makeLink("revfeedback_delete.asp","FBID=" & fldFBID,vbNullString)%>"><%=TXT_DELETE%></a><%
		End If%>&nbsp;]</td>
</tr>
<%			.MoveNext
		Wend
%>
</table>
<%
	End If
	.Close
End With

End If

'***************************************
' New Record Suggestions (Other)
'***************************************
strFeedbackSQL = "SELECT fbe.FB_ID, fbe.SUBMIT_DATE, fbe.FEEDBACK_OWNER, sl.Culture, sl.LanguageName AS LanguageName," & vbCrLf & _
	"""SUBMITTED_BY"" = CASE WHEN u.User_ID IS NULL THEN CASE WHEN fbe.SOURCE_NAME IS NULL THEN '[" & TXT_UNKNOWN & "]' ELSE fbe.SOURCE_NAME END ELSE u.FirstName + ' ' + u.LastName + ' (' + u.Agency + ')' END, " & _
	"dbo.fn_GBL_DisplayFullOrgName_2(NULL,fb.ORG_LEVEL_1,fb.ORG_LEVEL_2,fb.ORG_LEVEL_3,fb.ORG_LEVEL_4,fb.ORG_LEVEL_5,fb.LOCATION_NAME,fb.SERVICE_NAME_LEVEL_1,fb.SERVICE_NAME_LEVEL_2,1,1) AS ORG_NAME_FULL_FB" & vbCrLf & _
	"FROM GBL_FeedbackEntry fbe" & vbCrLf & _
	"INNER JOIN STP_Language sl ON fbe.LangID=sl.LangID" & vbCrLf & _
	"LEFT JOIN GBL_Feedback fb ON fbe.FB_ID=fb.FB_ID" & vbCrLf & _
	"LEFT JOIN CIC_Feedback cfb ON fbe.FB_ID=cfb.FB_ID" & vbCrLf & _
	"LEFT JOIN CCR_Feedback ccfb ON fbe.FB_ID=ccfb.FB_ID" & vbCrLf & _
	"LEFT OUTER JOIN GBL_Users u ON fbe.User_ID=u.User_ID" & vbCrLf & _
	"WHERE fbe.MemberID=" & g_intMemberID & vbCrLf & _
	"AND fbe.NUM IS NULL" & vbCrLf & _
	"AND fbe.FEEDBACK_OWNER <> " & QsNl(user_strAgency)

Select Case Request("Sort")
	Case "L"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.LangID, fbe.SUBMIT_DATE"
	Case "O"
		strFeedbackSQL = strFeedbackSQL & FB_ORG_SORT
	Case "R"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.FEEDBACK_OWNER, fbe.SUBMIT_DATE"
	Case "S"
		strFeedbackSQL = strFeedbackSQL & " ORDER BY SUBMITTED_BY, fbe.SUBMIT_DATE"
	Case Else
		strFeedbackSQL = strFeedbackSQL & " ORDER BY fbe.SUBMIT_DATE"
End Select

With cmdFb
	.CommandText = strFeedbackSQL
End With
With rsFb
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFb
	
	Set fldFBID = .Fields("FB_ID")
	Set fldOrgName = .Fields("ORG_NAME_FULL_FB")
%>
<a name="OtherNewFB"></a><h2><%=TXT_NEW_RECORD_SUGGESTIONS%> (<%=TXT_OTHER_AGENCIES%>)</h2>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_SUGGESTIONS_FOR_RECORDS%></p>
<%
	If .RecordCount > 0 Then
		If user_bSuperUserCIC Then
%>
<form action="revfeedback_assign.asp" method="get">
<%=g_strCacheFormVals%>
<%
		End If
%>
<table class="BasicBorder cell-padding-3">
<tr class="RevTitleBox">
<%		If user_bSuperUserCIC Then%>
	<th>&nbsp;</th>
<%		End If%>
<%If g_bMultiLingual Then%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=L",vbNullString)%>" class="RevTitleText"><%=TXT_FEEDBACK_LANGUAGE%></a></th>
<%End If%>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=O",vbNullString)%>" class="RevTitleText"><%=TXT_ORG_NAMES%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=R",vbNullString)%>" class="RevTitleText"><%=TXT_RECORD_OWNER%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=S",vbNullString)%>" class="RevTitleText"><%=TXT_SUBMITTED_BY%></a></th>
	<th><a href="<%=makeLink(ps_strThisPage,"Sort=D",vbNullString)%>" class="RevTitleText"><%=TXT_DATE_SUBMITTED%></a></th>
<%	If user_bAddCIC Or user_bSuperUserCIC Then%>
	<th><%=TXT_ACTION%></th>
<%	End If%>
</tr>
<%
		While Not .EOF
			bDifferentLang = False
			If .Fields("Culture") <> g_objCurrentLang.Culture Then
				bDifferentLang = True
			End If
%>
<tr>
<%			If user_bSuperUserCIC Then%>
	<td><input type="checkbox" name="AssignFB" id="AssignFB_<%=fldFBID%>" value="<%=fldFBID%>"></td>
<%			End If%>
<%			If g_bMultiLingual Then%>
	<td><label for="AssignFB_<%=fldFBID%>"><%=.Fields("LanguageName")%></label></td>
<%			End If%>
	<td><%=fldOrgName.Value%></td>
	<td><%=.Fields("FEEDBACK_OWNER")%></td>
	<td align="right"><%=.Fields("SUBMITTED_BY")%></td>
	<td align="right"><%=DateString(.Fields("SUBMIT_DATE"),True)%></td>
<%
			If (user_bAddCIC Or user_bSuperUserCIC) Then
%>
	<td>[&nbsp;<a href="<%=makeLink("revfeedback_view.asp","FBID=" & fldFBID,vbNullString)%>"><%=TXT_VIEW_FEEDBACK%></a>&nbsp;|&nbsp;<a href="<%=makeLink("entryform.asp","FBID=" & fldFBID & StringIf(bDifferentLang,"&UpdateLn=" & .Fields("Culture")),vbNullString)%>"><%=TXT_CREATE_RECORD%></a><%
				If user_bSuperUserCIC Then
		%>&nbsp;|&nbsp;<a href="<%=makeLink("revfeedback_delete.asp","FBID=" & fldFBID,vbNullString)%>"><%=TXT_DELETE%></a><%
				End If
	%>&nbsp;]</td>
<%
			End If
%>	
</tr>
<%			.MoveNext
		Wend
%>
</table>
<%
		If user_bSuperUserCIC Then
%>
<p><strong><%=TXT_ASSIGN_TO%></strong><%=strOwnerList%> <input type="submit" value="<%=TXT_SUBMIT%>"></p>
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
<!--#include file="includes/core/incClose.asp" -->
