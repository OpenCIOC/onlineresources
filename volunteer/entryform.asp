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
<!--#include file="../text/txtCommonForm.asp" -->
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtDateTimeTable.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtFieldHistory.asp" -->
<!--#include file="../text/txtFeedbackCommon.asp" -->
<!--#include file="../text/txtFinder.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incAgencyList.asp" -->
<!--#include file="../includes/list/incContactPhoneTypeList.asp" -->
<!--#include file="../includes/list/incExtraDropDownList.asp" -->
<!--#include file="../includes/list/incHonorificList.asp" -->
<!--#include file="../includes/list/incInterestGroupList.asp" -->
<!--#include file="../includes/list/incMinHourPerList.asp" -->
<!--#include file="../includes/list/incRecordNoteTypeList.asp" -->
<!--#include file="../includes/list/incVOLCommunitySetList.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="../includes/update/incEntryFormGeneral.asp" -->
<!--#include file="../includes/update/incFieldHistory.asp" -->
<!--#include file="../includes/update/incVOLFormUpdPrint.asp" -->

<%
Dim strPageTitle, _
	strNUM, _
	strVNUM, _
	intFBID, _
	bVNUMError, _
	bNUMError, _
	bFBError, _
	bRSError, _
	intFormType, _
	bNew, _
	objUpdateLang, _
	bHasEquiv, _
	strOrgName, _
	bHasDynamicAddField

bRSError = False
bNUMError = False
bVNUMError = False
bFBError = False
bHasEquiv = False
bHasDynamicAddField = False
strPageTitle = TXT_CREATE_NEW_RECORD
intFormType = EF_NEW

strVNUM = Trim(Request("VNUM"))
strNUM = Trim(Request("NUM"))

Set objUpdateLang = create_language_object()
objUpdateLang.setSystemLanguage(Nz(Request("UpdateLn"),g_objCurrentLang.Culture))

If Nl(strVNUM) Then
	intFBID = Trim(Request("FBID"))
	If Not Nl(intFBID) Then
		intFormType = EF_CREATEFB
	End If
Else
	intFormType = EF_UPDATE
End If

bNew = intFormType = EF_NEW Or intFormType = EF_CREATEFB

If bNew And Not user_bAddVOL Then
	Call securityFailure()
ElseIf user_intUpdateVOL = UPDATE_NONE Then
	Call securityFailure()
End If

Dim strRestoreCulture
strRestoreCulture = g_objCurrentLang.Culture
Call setSessionLanguage(objUpdateLang.Culture)

If Not bNew Then
	If Not IsVNUMType(strVNUM) Then
		bVNUMError = True
		Call makePageHeader(TXT_UPDATE_RECORD_TITLE, TXT_UPDATE_RECORD_TITLE, True, False, True, True)
		Call handleError(TXT_INVALID_OPID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
	End If
Else
	If intFormType = EF_CREATEFB Then
		If Not IsIDType(intFBID) Then
			bFbError = True
			Call makePageHeader(TXT_CREATE_NEW_RECORD, TXT_CREATE_NEW_RECORD, True, False, True, True)
			Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intFBID) & ".", vbNullString, vbNullString)
		Else
			intFBID = CLng(intFBID)
		End If
	Else
		If Not Nl(strNUM) Then
			If Not IsNUMType(strNUM) Then
				bNUMError = True
				Call makePageHeader(TXT_CREATE_NEW_RECORD, TXT_CREATE_NEW_RECORD, True, False, True, True)
				Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
			End If
		End If
	End If
	strVNUM = Null
End If

If intFormType = EF_NEW And Not bNUMError And Not Nl(strNUM) Then
	Dim cmdOrgName, rsOrgName
	Set cmdOrgName = Server.CreateObject("ADODB.Command")
	With cmdOrgName
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_GBL_BaseTable_s_OrgName"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		Set rsOrgName = .Execute
	End With
	If rsOrgName.EOF Then
		bNUMError = True
		Call makePageHeader(TXT_CREATE_NEW_RECORD, TXT_CREATE_NEW_RECORD, True, False, True, True)
		Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
	ElseIf intFormType = EF_NEW And Not rsOrgName.Fields("MEMBER_CAN_USE") Then
		Call securityFailure()
	Else
		strOrgName = rsOrgName.Fields("ORG_NAME_FULL")
	End If
End If

If Not bVNUMError And Not bFBError And Not bNUMError Then

Dim cnnFields, cmdFields, rsFields
Call makeNewAdminConnection(cnnFields)
Set cmdFields = Server.CreateObject("ADODB.Command")
With cmdFields
	.ActiveConnection = cnnFields
	.CommandType = adCmdStoredProc
	.CommandText = "sp_VOL_View_UpdateFields"
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
End With
Set rsFields = Server.CreateObject("ADODB.Recordset")
With rsFields
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFields
End With

Dim bEnforceReqFields

With rsFields
	If .EOF Then
		bRSError = True
		Call handleError(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
	Else
		bEnforceReqFields = .Fields("EnforceReqFields")
	End If
End With

Set rsFields = rsFields.NextRecordSet

If Not bNew And Not bRSError Then
	Dim strSQL, strCon

	strSQL = _
		"SELECT sln.LangID, sln.LanguageName " & vbCrLf & _
			"FROM STP_LANGUAGE sln" & vbCrLf & _
			"INNER JOIN VOL_Opportunity_Description vod " & _
			"	ON sln.LangID=vod.LangID WHERE VNUM='" & strVNUM & "' " & vbCrLf & _
		"SELECT vo.OP_ID, vo.VNUM,vod.POSITION_TITLE,vo.RECORD_OWNER," & _
		"bt.NUM," & vbCrLf & _
		"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & _
		"vod.DELETION_DATE,vod.CREATED_DATE,vod.CREATED_BY,vod.UPDATE_DATE,vod.UPDATED_BY,vod.UPDATE_SCHEDULE,vod.MODIFIED_DATE,vod.MODIFIED_BY," & _
		"btd.NON_PUBLIC AS CIC_NON_PUBLIC, btd.DELETION_DATE AS CIC_DELETION_DATE, " & vbCrLf & _
		"dbo.fn_VOL_CanUpdateRecord(vo.VNUM," & user_intID & "," & g_intViewTypeVOL & ",@@LANGID,GETDATE()) AS CAN_UPDATE"
	With rsFields
		While Not .EOF
			If Not Nl(.Fields("FieldSelect")) And _
				Not reEquals(.Fields("FieldName"), _
						"((OP_ID)|(VNUM)|(NUM)|(POSITION_TITLE)(RECORD_OWNER)|(CREATED_DATE)|(UPDATE(_DATE)|(_SCHEDULE)|(D_BY)))", _
						True,False,True,False) Then
				strSQL = strSQL & ", " & .Fields("FieldSelect")
			End If
			.MoveNext
		Wend
		If Not .RecordCount = 0 Then
			.MoveFirst
		End If
	End With
	
	strSQL = strSQL & vbCrLf & _
		"FROM VOL_Opportunity vo" & vbCrLf & _
		"LEFT JOIN VOL_Opportunity_Description vod ON vo.VNUM = vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
		"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
		"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=bt.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & _
		"WHERE vo.VNUM=" & QsN(strVNUM)
		
	'Response.Write("<pre>" & strSQL & "</pre>")
	'Response.Flush()
	
	Dim cmdOrg, rsOrg, strVersions
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandText = strSQL
		.CommandTimeout = 0
		Set rsOrg = .Execute
	End With
	If Err.Number <> 0 Then
		bRSError = True
		Call handleError(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
	Else	
		Dim strVersionCon
		strVersionCon = vbNullString
		strVersions = "[ "
		With rsOrg
			While Not .EOF
				strVersions = strVersions & strVersionCon & _
					"<span class=""SimulateLink HistorySummary NoLineLink"" data-cioclang=""" & .Fields("LangID") & """ data-ciocid=""" & strVNUM & """>" & _
						"<img src=""" & ps_strPathToStart & "images/versions.gif"" width=""17"" height=""17"" alt=" & AttrQs(TXT_FIELD_HISTORY & TXT_COLON) & ">" & _
						"&nbsp;" & .Fields("LanguageName") & _
						"</span>"
				strVersionCon = " | "
				.MoveNext
			Wend
		End With
		strVersions = strVersions & " ]"
		Set rsOrg = rsOrg.NextRecordSet
	End If
	If Not bRSError And rsOrg.EOF Then
		bVNUMError = True
		Call handleError(TXT_NO_RECORD_EXISTS_VNUM & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
	Else
		strNUM = rsOrg.Fields("NUM")
		strOrgName = rsOrg.Fields("ORG_NAME_FULL")
	End If
End If

If intFormType <> EF_UPDATE Then
	Dim strNewVNUM
	strNewVNUM = getNewVNUM()
End If

Dim cmdFb, rsFb
If intFormType = EF_CREATEFB Then
	Set cmdFb = Server.CreateObject("ADODB.Command")
	With cmdFb
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_VOL_Feedback_s"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@FB_ID", adInteger, adParamInput, 4, intFBID)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
	End With
	Set rsFb = Server.CreateObject("ADODB.Recordset")
	With rsFb
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdFb
	
		If Not .EOF Then
			If .Fields("Error") <> 0 Then
				bFbError = True
				Call handleError(Nz(.Fields("ErrMsg"),TXT_UNKNOWN_ERROR_OCCURED),vbNullString,vbNullString)
			End If
		End If

		If Not bFbError Then
			Set rsFb = rsFb.NextRecordset
			Set rsFb = rsFb.NextRecordSet
			If .EOF Then
				bFBError = True
				Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intFBID) & ".", vbNullString, vbNullString)
			Else
				bFeedback = True
			End If
		End If
	End With
ElseIf intFormType = EF_UPDATE Then
	Set cmdFb = Server.CreateObject("ADODB.Command")
	With cmdFb
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_VOL_Feedback_l_VNUM"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
	End With
	Set rsFb = Server.CreateObject("ADODB.Recordset")
	With rsFb
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdFb
		If Not .EOF Then
			bFeedback = True
		End If
	End With
End If

End If

If Not bVNUMError And Not bFBError And Not bNUMError Then

Select Case intFormType
	Case EF_UPDATE
		If Not rsOrg("CAN_UPDATE")=1 Then
			Call securityFailure()
		End If
		Call makePageHeader(TXT_UPDATE_RECORD_TITLE, TXT_UPDATE_RECORD_TITLE, True, False, True, True)
%>
<h2><%= TXT_UPDATE_RECORD_TITLE %>:
<br><a href="<%=makeVOLDetailsLink(rsOrg("VNUM"), IIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber,vbNullString),vbNullString)%>"><%=rsOrg("POSITION_TITLE") & " (" & strOrgName & ")"%></a></h2>
<%
	Case EF_NEW
		If Not user_bAddVOL Then
			Call securityFailure()
		End If
		Call makePageHeader(TXT_CREATE_NEW_RECORD, TXT_CREATE_NEW_RECORD, True, False, True, True)
%>
<h2><%= TXT_CREATE_NEW_RECORD %></h2>
<%If Not Nl(strOrgName) Then%>
<p><%= TXT_INFO_CREATE_OP %><strong><a href="<%=makeDetailsLink(strNUM,vbNullString,vbNullString)%>"><%=strOrgName%></a></strong> (<%= TXT_RECORD_NUM & TXT_COLON %> <%=strNUM%>)</p>
<%End If%>
<%
	Case EF_CREATEFB
		If (Not user_bAddVOL) Then
			Call securityFailure()
		End If
		Call makePageHeader(TXT_CREATE_RECORD_FEEDBACK, TXT_CREATE_RECORD_FEEDBACK, True, False, True, True)
%>
<h2><%=TXT_CREATE_RECORD_FEEDBACK%></h2>
<%
End Select
%>
<p class="HideJs Alert">
<%= TXT_JAVASCRIPT_REQUIRED %>
</p>
<div class="HideNoJs">
<table aria-hidden="true" class="BasicBorder cell-padding-3 max-width-lg clear-line-below">
	<tr>
		<th class="RevTitleBox" colspan="2"><%=TXT_LEGEND%></th>
	</tr>
	<tr>
		<td><span class="glyphicon glyphicon-question-sign medium-icon"></span></td>
		<td><%=TXT_LEGEND_HELP%></td>
	</tr>
	<% If Not bNew Then %>
	<tr>
		<td><span class="glyphicon glyphicon-duplicate medium-icon"></span></td>
		<td><%=TXT_LEGEND_VERSIONS%></td>
	</tr>
	<% End If %>
</table>

<form id="EntryForm" name="EntryForm" action="entryform2.asp" role="form" class="form-horizontal" method="post" lang="<%=objUpdateLang.Culture%>">
<div style="display: none;">
<input name="transaction-amount" autocomplete="transaction-amount">
<%=g_strCacheFormVals%>
<input type="hidden" name="UpdateLn" value="<%=objUpdateLang.Culture%>">
</div>
<%
Call openVOLCommunitySetListRst(CSET_RECORD, strVNUM)
If rsListVOLCommunitySet.RecordCount=1 Then
%>
<input type="hidden" name="CommunitySetID" value="<%=rsListVOLCommunitySet("CommunitySetID")%>">
<%
Else
%>
<p><strong><%=TXT_RECORD_ASSIGNED_TO_SETS%></strong>
<%=makeVolCommunitySetCheckList("CommunitySetID")%>
<br><%=TXT_INDICATES_SET_CANT_BE_CHANGED%></p>
<%
End If
Call closeVOLCommunitySetListRst()
%>
<%If intFormType = EF_UPDATE Then%>
<input type="hidden" name="OPID" value="<%=rsOrg("OP_ID")%>">
<%	If intCurSearchNumber >= 0 Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%	End If
	If Not Nl(rsOrg("UPDATE_DATE")) Then%>
<input type="hidden" name="OLD_UPDATE_DATE" value="<%=DateString(rsOrg("UPDATE_DATE"),True)%>">
<%	End If
End If
If intFormType = EF_CREATEFB Then
%>
<input type="hidden" name="FBID" value="<%=intFBID%>">
<%
End If
%>
<%

Dim i, dicFb
If bFeedback Then
	Set dicFb = Server.CreateObject("Scripting.Dictionary")
	i=1
%>
<p><span class="AlertBubble"><%=TXT_CHECK_FEEDBACK%></span></p>
<table class="NoBorder cell-padding-2 clear-line-below">
<%
	With rsFb
		.MoveFirst
		While Not .EOF
%>
<tr>
	<td class="FieldLabelLeftClr"><%=TXT_FEEDBACK_NUM%><%=i%><%If g_bMultiLingual Then%> (<%=.Fields("LanguageName")%>)<%End If%><%=TXT_COLON%></td>
	<td class="Alert"><%=TXT_SUBMITTED_BY & TXT_COLON%><%=.Fields("SUBMITTED_BY")%>
	<%If Not Nl(.Fields("SUBMITTED_BY_EMAIL")) Then%><br><%=TXT_SUBMITTER_EMAIL & TXT_COLON%><a href="mailto:<%=.Fields("SUBMITTED_BY_EMAIL")%>"><%=.Fields("SUBMITTED_BY_EMAIL")%></a><%End If%>
<%If .Fields("REMOVE_RECORD") Then%>
	<br><%=TXT_REMOVE_RECORD_REQUEST%>
<%Else%>
	<br><%=TXT_FULL_UPDATE & TXT_COLON%><%If .Fields("FULL_UPDATE") Then%><%=TXT_YES%><%If .Fields("NO_CHANGES") Then%> (<%=TXT_NO_CHANGES_REQUIRED%>)<%End If%><%Else%><%=TXT_NO%><%End If%>
<%End If%>
	<%If Not Nl(.Fields("FB_NOTES")) Then%><br><%=TXT_NOTES & TXT_COLON%><%=.Fields("FB_NOTES")%><%End If%></td>
</tr>
<%
			i=i+1
			dicFb(.Fields("Culture").Value) = .Fields("LanguageName")
			.MoveNext
		Wend
	End With
%>
</table>
<br>
<%
End If
If Not bNew Then
%>
<p class="Info"><%=TXT_PAST_CHANGES_TO_THIS_RECORD & strVersions%>
</p>
<%
End If
%>
<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
		<%If Not bNew Then%>
		<h2><%=TXT_REVIEW_RECORD & rsOrg("VNUM")%></h2>
		<%Else%>
		<h2><%=TXT_CREATE_NEW_RECORD%></h2>
		<%End If%>
	</div>
	<div class="panel-body no-padding">
		<table class="BasicBorder cell-padding-4 full-width inset-table form-table responsive-table">
<%
Dim strFieldName, _
	strFieldContents, _
	strFieldVal, _
	bEquivalentField, _
	bHasLabel

Call printAutoFields(rsOrg, intFormType = EF_UPDATE)
Call printUpdatedFields(rsOrg, intFormType = EF_UPDATE, False)
Call printRecordOwner(rsOrg, Not bNew)
If intFormType <> EF_UPDATE Then
	Call printRow("VNUM", TXT_RECORD_NUM, _
		"<input type=""checkbox"" name=""AutoAssignVNUM"" id=""AutoAssignVNUM"" checked onClick=""changeAutoAssign(this, document.EntryForm.VNUM, document.EntryForm.VNUMButton);"">&nbsp;<label for=""AutoAssignVNUM"">" & TXT_AUTO_ASSIGN_LOWEST_NUM & "</label>" & _
		"<br><input type=""text"" name=""VNUM"" title=" & AttrQs(TXT_RECORD_NUM) & " size=""11"" maxlength=""10"" disabled class=""record-num"">" & _
		" <input type=""button"" id=""VNUMButton"" value=""" & TXT_LOWEST_UNUSED_FOR & "" & user_strAgency & """ onClick=""document.EntryForm.VNUM.value='" & strNewVNUM & "';"" disabled>" & _
		" [ <a href=""javascript:openWin('" & makeLinkB("vnumfind.asp") & "','aFind')"">" & TXT_LOWEST_UNUSED_FOR & TXT_ALL_AGENCIES & "</a> ]", _
		True,True,False,True,bEnforceReqFields,False,False)
End If
If intFormType <> EF_UPDATE Then
	strFieldVal = makeNUMContents(strNUM, Null, False)
	Call printRow("NUM",TXT_ORG_RECORD_NUM, _
		strFieldVal, _
		True,True,False,True,False,False,True)
	strFieldVal = makeTextFieldVal("POSITION_TITLE", _
			vbNullString, _
			150, _
			True)
	Call printRow("POSITION_TITLE",TXT_POSITION_TITLE, _
		strFieldVal, _
		True,True,False,True,False,False,True)
End If

While Not rsFields.EOF
	strFieldName = rsFields.Fields("FieldName")
	strFieldVal = Null
	bFieldHasFeedback = False
	If Not (bNew Or rsFields.Fields("FormFieldType") = "f") Then
		strFieldContents = rsOrg(strFieldName)
	Else
		strFieldContents = Null
	End If
	If Not (intFormType <> EF_UPDATE And reEquals(rsFields.Fields("FieldName"), "(VNUM)|(RECORD_OWNER)|(NUM)|(POSITION_TITLE)",True,False,True,False)) Then
		Select Case rsFields.Fields("FormFieldType")
			Case "c"
				strFieldVal = makeCBFieldVal(strFieldName, _
					strFieldContents, _
					rsFields.Fields("CheckboxOnText"), _
					rsFields.Fields("CheckboxOffText"), _
					TXT_UNKNOWN, _
					rsFields.Fields("AllowNulls"), _
					rsFields.Fields("CanUseFeedback") _
					)
			Case "d"
				strFieldVal = makeDateFieldVal(strFieldName, _
					strFieldContents, _
					IIf(strFieldName="REQUEST_DATE",True,False),False,False,False,False, _
					rsFields.Fields("CanUseFeedback") _
					)
			Case "m"
				strFieldVal = makeMemoFieldVal(strFieldName, _
					strFieldContents, _
					TEXTAREA_ROWS_LONG, _
					rsFields.Fields("CanUseFeedback") _
					)
			Case "t"
				If rsFields.Fields("ValidateType") = "w" Then
					Dim strProtocol
					If Not (bNew) Then
						strProtocol = rsOrg(strFieldName + "_PROTOCOL")
					Else
						strProtocol = vbNullString
					End If
					strFieldVal = makeWebFieldVal(strFieldName, _
						strFieldContents, _
						rsFields.Fields("MaxLength"), _
						rsFields.Fields("CanUseFeedback"), _
						strProtocol _
						)
				Else
					strFieldVal = makeTextFieldVal(strFieldName, _
							strFieldContents, _
							rsFields.Fields("MaxLength"), _
							rsFields.Fields("CanUseFeedback") _
							)
				End If
			Case "u"
				strFieldVal = makeUserFieldVal(strFieldName, _
					strFieldContents, _
					rsFields.Fields("CanUseFeedback") _
					)
			Case "f"
				Select Case strFieldName
					Case "ACCESSIBILITY"
						strFieldVal = makeAccessibilityContents(rsOrg, Not bNew)
					Case "AGES"
						strFieldVal = makeAgesContents(rsOrg, Not bNew)
					Case "COMMITMENT_LENGTH"
						strFieldVal = makeCommitmentLengthContents(rsOrg, Not bNew)
					Case "CONTACT"
						strFieldVal = makeContactFieldVal(rsOrg, strFieldName, Not bNew)
					Case "INTERACTION_LEVEL"
						strFieldVal = makeInteractionLevelContents(rsOrg, Not bNew)
					Case "INTERESTS"
						strFieldVal = makeInterestsContents(rsOrg, Not bNew)
					Case "INTERNAL_MEMO"
						strFieldVal = makeRecordNoteFieldVal(rsOrg, strFieldName, Not bNew)
					Case "MINIMUM_HOURS"
						strFieldVal = makeMinHoursContents(rsOrg, Not bNew)
					Case "NUM"
						If Not bNew Then
							strNUM = rsOrg("NUM")
						End If
						strFieldVal = makeNUMContents(strNUM, rsOrg, True)
					Case "NUM_NEEDED"
						strFieldVal = makeNumNeededContents(rsOrg, Not bNew)
					Case "RECORD_OWNER"
						strFieldVal = makeRecordOwnerFieldVal(rsOrg, Not bNew)
					Case "SCHEDULE"
						strFieldVal = makeScheduleContents(rsOrg, Not bNew)
					Case "SEASONS"
						strFieldVal = makeSeasonsContents(rsOrg, Not bNew)
					Case "SKILLS"
						strFieldVal = makeSkillContents(rsOrg, Not bNew)
					Case "SOCIAL_MEDIA"
						strFieldVal = makeSocialMediaFieldVal(rsOrg, Not bNew)
					Case "SOURCE"
						strFieldVal = makeSourceContents(rsOrg, Not bNew)
					Case "START_DATE"
						strFieldVal = makeStartDateContents(rsOrg, Not bNew)
					Case "SUITABILITY"
						strFieldVal = makeSuitabilityContents(rsOrg, Not bNew)
					Case "TRAINING"
						strFieldVal = makeTrainingContents(rsOrg, Not bNew)
					Case "TRANSPORTATION"
						strFieldVal = makeTransportationContents(rsOrg, Not bNew)
					Case Else
						Select Case Ns(rsFields.Fields("ExtraFieldType"))
							Case "l"
								strFieldVal = makeExtraCheckListContents(rsOrg, Not bNew, False)
							Case "p"
								strFieldVal = makeExtraDropDownContents(rsOrg, Not bNew, False)
							Case Else
								If Not bNew Then
									strFieldContents = rsOrg(strFieldName)
								Else
									strFieldContents = vbNullString
								End If
								strFieldVal = makeMemoFieldVal(strFieldName, _
									strFieldContents, _
									TEXTAREA_ROWS_LONG, _
									True)
						End Select
				End Select
		End Select
		bEquivalentField = bHasEquiv
		If bEquivalentField Then
			bEquivalentField = rsFields.Fields("EquivalentSource")
		End If
		bHasLabel = False
		If reEquals(rsFields.Fields("FormFieldType"),"d|m|t|u",True,True,True,False) _
					Or rsFields.Fields("ExtraFieldType") = "p" _
					Or rsFields.Fields("ValidateType") = "n" _
				Then
			bHasLabel = True
		End If
		Call printRow(strFieldName,rsFields.Fields("FieldDisplay"),strFieldVal, _
			True,rsFields.Fields("HasHelp"),Nz(rsFields.Fields("ChangeHistory"), 0) > 0 And Not bNew,Not rsFields.Fields("AllowNulls"),False,bFieldHasFeedback,bHasLabel)
	End If
	rsFields.MoveNext
Wend
%>
		</table>
	</div>
</div>

<%
Call closeRecordNoteTypeRecordsets()

Dim indFbLang
If bFullUpdate Then
	If bFeedback Then
		For Each indFbLang In dicFb
%>
<p class="Alert"><label><input type="checkbox" name="DeleteFeedback" id="DeleteFeedback_<%=indFBLang%>" value="<%=indFbLang%>" <%=Checked(indFbLang=g_objCurrentLang.Culture)%>><%=TXT_DELETE_FEEDBACK%><%If g_bMultiLingual Then%> (<%=dicFb(indFbLang)%>)<%End If%></label></p>
<%
		Next
	End If
End If
%>

<div id="unadded_checklist_error_box" class="NotVisible">
<span class="Alert"><%= TXT_UNADDED_CHECKLISTS %></span>
<div id="unadded_checklist_error_list">
</div>
</div>
<p>
	<input type="button" id="SUBMIT_BUTTON" class="btn btn-default" value="<%=TXT_SUBMIT_UPDATES%>">
	<input type="reset" class="btn btn-default" value="<%=TXT_RESET_FORM%>">
</p>

</form>
</div>
<%
End If

%>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/ventryform.js") %>
<% 
g_bListScriptLoaded = True
If Not bNew Then
Call printHistoryDialogHTML(strVNUM, False)
End If

%>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<%
%>
<script type="text/javascript">
jQuery(function($) {
	
	configure_entry_form_button();

	init_cached_state();

	init_entryform_notes($('.EntryFormNotesContainer'), '<%= TXT_VIEW_CANCELLED %>', '<%= TXT_HIDE_CANCELLED %>');
<%
If bInterests Then
%>
	entryform.interest_complete_url = "<%= makeLinkB(ps_strPathToStart & "jsonfeeds/interest_generator.asp") %>";
	init_interests("<%= TXT_NOT_FOUND %>");
<%
End If
If bNumNeeded Then
%>
	entryform.community_complete_url = "<%= makeLinkB(ps_strPathToStart & "jsonfeeds/community_generator.asp") %>";
	init_num_needed("<%= TXT_NOT_FOUND %>");
<%
End If
%>
	restore_cached_state();

	init_check_for_autochecklist(<%=JSONQs(TXT_UNADDED_CHECKLIST_ALERT,True)%>);
<%
If Not bNew Then
Call printHistoryDialogJavaScript(False)
End If
%>
});
</script>
<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->

