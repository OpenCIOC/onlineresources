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
'
' Purpose:		Submit volunteer feedback, suggest new volunteer record
'
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
<!--#include file="../text/txtAgencyContact.asp" -->
<!--#include file="../text/txtCommonForm.asp" -->
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtDateTimeTable.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtFeedback.asp" -->
<!--#include file="../text/txtFeedbackCommon.asp" -->
<!--#include file="../text/txtFinder.asp" -->
<!--#include file="../text/txtFormSecurity.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtMonth.asp" -->
<!--#include file="../text/txtRecordPages.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incExtraDropDownList.asp" -->
<!--#include file="../includes/list/incMinHourPerList.asp" -->
<!--#include file="../includes/list/incMonthList.asp" -->
<!--#include file="../includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="../includes/update/incEntryFormGeneral.asp" -->
<!--#include file="../includes/update/incVOLFormFbPrint.asp" -->
<% 
'On Error Resume Next

Dim objUpdateLang, _
	strUpdateLang

strUpdateLang = Request("UpdateLn")
If Not IsCulture(strUpdateLang) Then
	strUpdateLang = vbNullString
End If

If Nl(strUpdateLang) Then
	strUpdateLang = Request("Ln")
	If Not IsCulture(strUpdateLang) Then
		strUpdateLang = vbNullString
	End If
End If

Set objUpdateLang = create_language_object()
objUpdateLang.setSystemLanguage(Nz(strUpdateLang,g_objCurrentLang.Culture))

Dim strRestoreCulture
strRestoreCulture = g_objCurrentLang.Culture
Call setSessionLanguage(objUpdateLang.Culture)

Dim intOPID, _
	strVNUM, _
	strNUM, _
	strFBKey, _
	bVNUMError, _
	bNUMError, _
	strError

intOPID = Request("OPID")
strVNUM = Request("VNUM")
strNUM = Trim(Request("NUM"))
bVNUMError = False
bNUMError = False
Dim	bSuggest

bSuggest = False

If Not (Nl(intOPID) And Nl(strVNUM)) Then
	If Not IsIDType(intOPID) And Not IsVNUMType(strVNUM) Then
		If Not IsVNUMType(strVNUM) Then
			strError = TXT_INVALID_ID & Server.HTMLEncode(strVNUM) & "."
		Else
			strError = TXT_INVALID_OPID & Server.HTMLEncode(intOPID) & "."
		End If
		bVNUMError = True
	ElseIf Nl(strVNUM) Then
		intOPID = CLng(intOPID)
		Dim cmdGetVNUM, rsGetVNUM
		Set cmdGetVNUM = Server.CreateObject("ADODB.Command")
		With cmdGetVNUM
			.ActiveConnection = getCurrentVOLBasicCnn()
			.CommandType = adCmdText
			.CommandText = "SELECT VNUM FROM VOL_Opportunity vo WHERE vo.OP_ID=" & intOPID
			.CommandTimeout = 0
			Set rsGetVNUM = .Execute
		End With
		If Not rsGetVNUM.EOF Then
			strVNUM = rsGetVNUM("VNUM")
			Call goToPage(ps_strThisPage,"VNUM=" & strVNUM,vbNullString)
		Else
			strError = TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intOPID) & "."
			bVNUMError = True
		End If
		intOPID = Null
	End If
Else
	intOPID = Null
	strVNUM = Null
	bSuggest = True
	If Not Nl(strNUM) Then
		If Not IsNUMType(strNUM) Then
			strError = TXT_INVALID_ID & Server.HTMLEncode(strNUM) & "."
			bNUMError = True
		End If
	End If
End If

If Not bVNUMError Then
	Dim intViewType
	Dim cmdFields, rsFields
	Set cmdFields = Server.CreateObject("ADODB.Command")
	With cmdFields
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_VOL_View_FeedbackFields"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsFields = Server.CreateObject("ADODB.Recordset")
	With rsFields
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdFields
	End With
End If

If Not bSuggest And Not bVNUMError Then
	Dim strSQL, strCon

	strSQL = "SELECT vo.VNUM,vod.LangID,vo.FBKEY,vo.RECORD_OWNER,vod.POSITION_TITLE," & vbCrLf & _
		"dbo.fn_VOL_RecordInView(vo.VNUM," & g_intViewTypeVOL & ",vod.LangID,0,GETDATE()) AS IN_VIEW," & vbCrLf & _
		"bt.NUM,dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & vbCrLf & _
		"vod.SOURCE_NAME, vod.SOURCE_TITLE, vod.SOURCE_ORG, vod.SOURCE_PHONE, vod.SOURCE_EMAIL," & vbCrLf & _
		"vod.UPDATE_DATE, vod.UPDATE_SCHEDULE, vod.MODIFIED_DATE"

	With rsFields
		While Not .EOF
			If Not Nl(.Fields("FieldSelect")) And _
					Not reEquals(.Fields("FieldName"), "(POSITION_TITLE)",True,False,True,False) Then
				strSQL = strSQL & "," & vbCrLf & .Fields("FieldSelect")
			End If
			.MoveNext
		Wend
		If Not .RecordCount = 0 Then
			.MoveFirst
		End If
	End With

	strSQL = strSQL & vbCrLf & _
		"FROM VOL_Opportunity vo" &  vbCrLf & _
		"LEFT JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vo.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
		"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
		"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=bt.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
		"WHERE vo.VNUM=" & QsN(strVNUM)

	If Not user_bLoggedIn Then
		strSQL = strSQL & vbCrLf & AND_CON & "(vo.MemberID=" & g_intMemberID & " OR (" & g_strWhereClauseVOLNoDel & "))"
	End If

	'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
	'Response.Flush()

	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandType = adCmdText
		.CommandText = strSQL
		.CommandTimeout = 0
		Set rsOrg = .Execute
	End With

	strFbKey = Left(Trim(Request("Key")),6)

	If rsOrg.EOF Then
		bVNUMError = True
		If Nl(strVNUM) Then
			strError = TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intOPID) & "."
		Else
			strError = TXT_NO_RECORD_EXISTS_VNUM & Server.HTMLEncode(strVNUM) & "."
		End If
	ElseIf Not rsOrg.Fields("IN_VIEW") And (user_bLoggedIn Or Not g_bAllowFeedbackNotInViewVOL Or strFbKey<>rsOrg.Fields("FBKEY")) Then
		Call securityFailure()
	End If
End If

Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)

If bVNUMError Then
	Call handleError(strError, vbNullString, vbNullString)
Else

Dim strFeedbackBlurb, _
	strTermsOfUseURL, _
	bDataUseAuth, _
	bDataUseAuthPhone, _
	intInclusionPolicyID

bDataUseAuth = False

Dim cmdViewFb, rsViewFb
Set cmdViewFb = Server.CreateObject("ADODB.Command")
With cmdViewFb
	.ActiveConnection = getCurrentVOLBasicCnn()
	.CommandText = "dbo.sp_VOL_View_Fb_s"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
End With
Set rsViewFb = cmdViewFb.Execute
With rsViewFb
	If Not .EOF Then
		bDataUseAuth = .Fields("DataUseAuth")
		bDataUseAuthPhone = .Fields("DataUseAuthPhone")
		strFeedbackBlurb = .Fields("FeedbackBlurb")
		strTermsOfUseURL = .Fields("TermsOfUseURL")
		intInclusionPolicyID = .Fields("InclusionPolicy")
	End If
	.Close
End With
Set rsViewFb = Nothing
Set cmdViewFb = Nothing
%>
<script type="text/javascript"><!--
	function validateForm() {
		formObj = document.EntryForm;
<%If Not user_bLoggedIn Then%>
		if (formObj.SOURCE_NAME.value == "") {
			formObj.SOURCE_NAME.focus();
			alert(<%=JsQs(TXT_INST_FULL_NAME)%>);
			return false;
		} else if ((formObj.SOURCE_EMAIL.value == "") && (formObj.SOURCE_PHONE.value == "")) {
			formObj.SOURCE_EMAIL.focus();
			alert(<%=JsQs(TXT_INST_EMAIL_PHONE)%>);
			return false;
<%Else%>
		if (false) {
<%End If%>
<%If bDataUseAuth Then%>
		} else	if (!(formObj.Auth[0].checked || formObj.Auth[1].checked || formObj.Auth[2].checked)) {
			alert(<%=JsQs(TXT_INST_AUTH)%>);
			return false;
<%End If%>
<%If Not bSuggest Then%>
		} else if (!(formObj.FType[0].checked || formObj.FType[1].checked || formObj.FType[2].checked || formObj.FType[3].checked)) {
			alert(<%=JsQs(TXT_INST_FULL_OR_PARTIAL)%>);
			return false;
<%End If%>
		} else {
			return true;
		}
	}
//--></script>
<%
Dim strOrgName

If Not bSuggest Then
	If Not bVNUMError Then
		Call getROInfo(rsOrg("RECORD_OWNER"),DM_VOL)
		strOrgName = rsOrg.Fields("ORG_NAME_FULL")
%>
<h2><%=TXT_SUGGEST_CHANGES_FOR%>
<br>
<%		If rsOrg.Fields("IN_VIEW") Then%>
<em><a href="<%=makeVOLDetailsLink(rsOrg("VNUM"), StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber),vbNullString)%>"><%=rsOrg("POSITION_TITLE") & " (" & strOrgName & ")"%></a></em>
<%		Else%>
<%=rsOrg("POSITION_TITLE") & " (" & strOrgName & ")"%>
<%		End If%>
</h2>

<%
		If rsOrg.Fields("LangID") <> g_objCurrentLang.LangID Then
%>
<p><span class="AlertBubble"><%=TXT_RECORD_NOT_AVAILABLE_LANGUAGE & " " & TXT_YOU_MAY_SUGGEST_LANGUAGE%></span></p>
<%
		End If
%>
<p><%=TXT_WE_APPRECIATE%> <strong><%=strROName%></strong></p>
<%
		If Not user_bLoggedIn Then
%>
<p><%=strFeedbackBlurb%></p>
<p><%=TXT_ALSO_CONTACT%></p>
<%
			Call printROContactInfo(False)
		End If
	End If
Else
	If Not bNUMError And Not Nl(strNUM) Then
		Dim cnnOrgName, cmdOrgName, rsOrgName
		Call makeNewAdminConnection(cnnOrgName)
		Set cmdOrgName = Server.CreateObject("ADODB.Command")
		With cmdOrgName
			.ActiveConnection = cnnOrgName
			.CommandType = adCmdStoredProc
			.CommandText = "sp_GBL_BaseTable_s_OrgName"
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
			Set rsOrgName = .Execute
		End With
		If rsOrgName.EOF Then
			bNUMError = True
			Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
		ElseIf bSuggest And Not rsOrgName.Fields("MEMBER_CAN_USE") Then
			bNUMError = True
			Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
		Else
			strOrgName = rsOrgName.Fields("ORG_NAME_FULL")
		End If
		rsOrgName.Close
		Set rsOrgName = Nothing
		Set cmdOrgName = Nothing
	End If

	If bNUMError Then
		strNUM = Null
	End If
%>
<h2><%=TXT_SUGGEST_NEW_RECORD%></h2>
<%	If Not Nl(strOrgName) Then%>
<p><%= TXT_VOL_YOU_ARE_SUGGESTING_FOR %>
<br><strong><%=strOrgName%></strong></p>
<%	End If%>
<%	If Not Nl(intInclusionPolicyID) Then %>
<p><span class="AlertBubble"><%=TXT_READ_INCLUSION%></span></p>
<%
	End If
End If
%>
<form id="EntryForm" name="EntryForm" action="feedback2.asp" role="form" class="form-horizontal" method="post">
<div style="display:none">
<input name="transaction-amount" autocomplete="transaction-amount">
<%=g_strCacheFormVals%>
<input type="hidden" name="UpdateLn" value="<%=g_objCurrentLang.Culture%>" />
<%If Not bSuggest Then%>
<input type="hidden" name="VNUM" value="<%=rsOrg("VNUM")%>">
<%If Not Nl(strFbKey) Then%>
<input type="hidden" name="Key" value="<%=strFBKey%>">
<%End If%>
<%End If%>
<%If bSuggest And Not Nl(strNUM) Then%>
<input type="hidden" name="NUM" value="<%=strNUM%>">
<%End If%>
<%If intCurSearchNumber >= 0 And Not bSuggest Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%End If%>
</div>
<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
		<%If Not bSuggest Then%>
		<h2><%=TXT_REVIEW_RECORD & rsOrg("VNUM")%></h2>
		<%Else%>
		<h2><%=TXT_CREATE_NEW_RECORD%></h2>
		<%End If%>
	</div>
	<div class="panel-body no-padding">
		<table class="BasicBorder cell-padding-4 full-width inset-table form-table responsive-table">
<%
	If Not bSuggest Then
		Dim strModifiedDate, _
			strUpdateDate, _
			strUpdateSchedule

		strModifiedDate = Nz(DateString(rsOrg.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN)
		strUpdateDate = Nz(DateString(rsOrg.Fields("UPDATE_DATE"),True),TXT_UNKNOWN)
		strUpdateSchedule = Nz(DateString(rsOrg.Fields("UPDATE_SCHEDULE"),True),TXT_UNKNOWN)

		Call printRow("MODIFIED_DATE", _
			TXT_LAST_MODIFIED, _
			strModifiedDate, _
			True,False,False,False,False,False,False)
		Call printRow("UPDATE_DATE", _
			TXT_LAST_UPDATE, _
			strUpdateDate, _
			True,False,False,False,False,False,False)
		Call printRow("UPDATE_SCHEDULE", _
			TXT_NEXT_REVIEW, _
			strUpdateSchedule, _
			True,False,False,False,False,False,False)
	ElseIf Nl(strNUM) Then
		Call printRow("ORG_NAME", _
			TXT_ORG_NAMES, _
			makeTextFieldVal("ORG_NAME", vbNullString, 255, False), _
			True,False,False,False,False,False,False)
	End If

	Dim strFieldName, _
		strFieldContents, _
		strFieldVal, _
		bHasLabel

	While Not rsFields.EOF
		strFieldName = rsFields.Fields("FieldName")
		strFieldVal = Null
		If Not (bSuggest Or rsFields.Fields("FormFieldType") = "f") Then
			strFieldContents = rsOrg(strFieldName)
		Else
			strFieldContents = Null
		End If
		Select Case rsFields.Fields("FormFieldType")
			' "Checkbox" field type
			Case "c"
				strFieldVal = makeCBFieldVal(strFieldName, _
					strFieldContents, _
					rsFields.Fields("CheckboxOnText"), _
					rsFields.Fields("CheckboxOffText"), _
					TXT_UNKNOWN, _
					rsFields.Fields("AllowNulls"), _
					False _
					)
			' "Date" field type
			Case "d"
				strFieldVal = makeDateFieldValFull(strFieldName, _
					strFieldContents, _
					IIf(strFieldName="COLLECTED_DATE",True,False),False,False,False,False, _
					False, _
					Ns(rsFields.Fields("ExtraFieldType"))="a" _
					)
			' "Text" field type, for single-line short text fields < 255 characters.
			Case "t"
				If rsFields.Fields("ValidateType") = "w" Then
					strFieldVal = makeWebFieldVal(strFieldName, _
						strFieldContents, _
						rsFields.Fields("MaxLength"), _
						False, _
						vbNullString _
						)
				Else
					strFieldVal = makeTextFieldVal(strFieldName, _
						strFieldContents, _
						rsFields.Fields("MaxLength"), _
						False _
						)
				End If
			' "User" field type, holds a user's name or initials
			Case "u"
				strFieldVal = makeUserFieldVal(strFieldName, _
					strFieldContents, _
					False _
					)
			' "Function" field type, a specialized function determines the display
			Case "f"
				Select Case strFieldName
					Case "AGES"
						strFieldVal = makeAgesContents(rsOrg, Not bSuggest)
					Case "CONTACT"
						strFieldVal = makeContactContents(rsOrg, strFieldName, Not bSuggest)
					Case "DUTIES"
						strFieldVal = makeMemoFieldVal(strFieldName, _
							strFieldContents, _
							TEXTAREA_ROWS_LONG, _
							False _
							)
					Case "INTERESTS"
						strFieldVal = makeAreaOfInterestContents(rsOrg, Not bSuggest)
					Case "MINIMUM_HOURS"
						strFieldVal = makeMinHoursContents(rsOrg, Not bSuggest)
					Case "NUM_NEEDED"
						strFieldVal = makeNumNeededContents(rsOrg, Not bSuggest)
					Case "SCHEDULE"
						strFieldVal = makeScheduleContents(rsOrg, Not bSuggest)
					Case "SOCIAL_MEDIA"
						strFieldVal = makeSocialMediaFieldVal(rsOrg, Not bSuggest)
					Case "START_DATE"
						strFieldVal = makeStartDateContents(rsOrg, Not bSuggest)
					Case Else
						Select Case Ns(rsFields.Fields("ExtraFieldType"))
							Case "l"
								strFieldVal = makeExtraCheckListContents(rsOrg, Not bSuggest, True)
							Case "p"
								strFieldVal = makeExtraDropDownContents(rsOrg, Not bSuggest, True)
							Case Else
								If Not bSuggest Then
									strFieldContents = rsOrg(strFieldName)
								Else
									strFieldContents = vbNullString
								End If
								'We don't have a special function for this field - treat it as a memo/long-text field (the default)
								strFieldVal = makeMemoFieldVal(strFieldName, _
									strFieldContents, _
									TEXTAREA_ROWS_SHORT, _
									False _
									)
						End Select
				End Select
			' The default case is the memo (long-text) field type
			Case Else
				strFieldVal = makeMemoFieldVal(strFieldName, _
					strFieldContents, _
					TEXTAREA_ROWS_SHORT, _
					False _
					)
		End Select
		bHasLabel = False
		If rsFields.Fields("UseDisplayForFeedback") _
					Or reEquals(rsFields.Fields("FormFieldType"),"d|m|t|u",True,True,True,False) _
					Or rsFields.Fields("ExtraFieldType") = "p" _
					Or rsFields.Fields("ValidateType") = "n" _
				Then
			bHasLabel = True
		End If
		Call printRow(strFieldName,rsFields.Fields("FieldDisplay"),strFieldVal, _
			True,rsFields.Fields("HasHelp"),False,Not rsFields.Fields("AllowNulls"),False,False,bHasLabel)
		rsFields.MoveNext
	Wend
	rsFields.Close
	Set rsFields = Nothing
	Set cmdFields = Nothing
%>
		</table>
	</div>
</div>

<%
Dim strSourcePrefix
If user_bLoggedIn Then
	strSourcePrefix = vbNullString
Else
	strSourcePrefix = TXT_YOUR
End If
%>

<div class="panel panel-default max-width-lg">
	<div class="panel-heading"><h2><%=TXT_BEFORE_SUBMITTING%></h2></div>
	<div class="panel-body">
		<h3 class="Alert"><%=IIf(user_bLoggedIn,TXT_SOURCE_OF_INFO,TXT_ABOUT_YOU)%></h3>
		<p><%=IIf(user_bLoggedIn,TXT_INST_SOURCE,TXT_INST_YOUR_INFO)%></p>
		<table class="BasicBorder cell-padding-3 clear-line-below full-width form-table responsive-table">
<%
Dim strSourceName, strSourceEmail, strSourcePhone, strSourceOrg, strSourceTitle
If Not bSuggest And user_bLoggedIn Then
	strSourceName = rsOrg("SOURCE_NAME")
	strSourceEmail = rsOrg("SOURCE_EMAIL")
	strSourcePhone = rsOrg("SOURCE_PHONE")
	strSourceOrg = rsOrg("SOURCE_ORG")
	strSourceTitle = rsOrg("SOURCE_TITLE")
End If
Call printRow("SOURCE_NAME",strSourcePrefix & TXT_NAME, _
		makeTextFieldVal("SOURCE_NAME", strSourceName, 60, False), _
		False,False,False,Not user_bLoggedIn,False,False,True)
Call printRow("SOURCE_EMAIL",strSourcePrefix & TXT_EMAIL, _
		makeTextFieldVal("SOURCE_EMAIL", strSourceEmail, 60, False), _
		False,False,False,Not user_bLoggedIn,False,False,True)
Call printRow("SOURCE_PHONE",strSourcePrefix & TXT_PHONE, _
		makeTextFieldVal("SOURCE_PHONE", strSourcePhone, 100, False), _
		False,False,False,Not user_bLoggedIn,False,False,True)
Call printRow("SOURCE_ORG",strSourcePrefix & TXT_ORGANIZATION, _
		makeTextFieldVal("SOURCE_ORG", strSourceOrg, 100, False), _
		False,False,False,False,False,False,True)
Call printRow("SOURCE_TITLE",strSourcePrefix & TXT_JOB_TITLE, _
		makeTextFieldVal("SOURCE_TITLE", strSourceTitle, 100, False), _
		False,False,False,False,False,False,True)
%>
		</table>

		<h3 class="Alert"><label for="FB_NOTES"><%=TXT_SPECIAL_INSTRUCTIONS%></label></h3>
		<p><%=TXT_ENTER_SPECIAL_INFO%></p>
		<p><textarea name="FB_NOTES" id="FB_NOTES" rows="<%=TEXTAREA_ROWS_LONG%>" class="form-control"></textarea></p>

		<%If bDataUseAuth Or Not Nl(strTermsOfUseURL) Then%>
		<h3 class="Alert"><%=TXT_USE_OF_INFO%></h3>
		<%	If Not Nl(strTermsOfUseURL) Then%>
		<p><a href="<%=strTermsOfUseURL%>" target="_BLANK"><%=TXT_REVIEW_TERMS_OF_USE%>&nbsp;<%=TXT_NEW_WINDOW%></a></p>
		<%	End If%>
		<%	If bDataUseAuth Then%>
		<p><%=TXT_PLEASE_SELECT_OPTIONS%></p>
		<table class="NoBorder cell-padding-2 clear-line-below">
		<%		If user_bLoggedIn Then%>
			<tr>
				<td><input type="radio" name="Auth" value="I"></td>
				<td><%=TXT_AUTH_INTERNAL%></td>
			</tr>
			<tr>
				<td><input type="radio" name="Auth" value="N"></td>
				<td><%=TXT_AUTH_NOT_GIVEN%></td>
			</tr>
			<tr>
				<td><input type="radio" name="Auth" value="A"></td>
				<td><%=TXT_AUTH_APPROVE_LOGIN%></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td><table class="NoBorder cell-padding-2">
					<%If bDataUseAuthPhone Then%>
					<tr>
						<td><input type="checkbox" name="AuthInquiry"></td>
						<td><%=TXT_USE_INQUIRY%></td>
					</tr>
					<%End If%>
					<tr>
						<td><input type="checkbox" name="AuthOnline"></td>
						<td><%=TXT_USE_ONLINE%></td>
					</tr>
					<tr>
						<td><input type="checkbox" name="AuthPrint"></td>
						<td><%=TXT_USE_PRINT%></td>
					</tr>
				</table></td>
			</tr>
		<%		Else%>
			<tr>
				<td><input type="radio" name="Auth" value="A"></td>
				<td><%=TXT_AUTH_APPROVE%></td>
			</tr>
			<%If bDataUseAuthPhone Then%>
			<tr>
				<td><input type="radio" name="Auth" value="E"></td>
				<td><%=TXT_AUTH_INQUIRIES%></td>
			</tr>
			<%End If%>
			<tr>
				<td><input type="radio" name="Auth" value="C"></td>
				<td><%=TXT_AUTH_CONTACT%></td>
			</tr>
		<%		End If%>
		</table>
		<%	End If
		End If%>

		<%If Not bSuggest Then%>
		<h3 class="Alert"><%=TXT_ABOUT_CHANGES%></h3>
		<p><%=TXT_PLEASE_SELECT_OPTIONS%></p>
		<table class="NoBorder cell-padding-2 clear-line-below">
			<tr>
				<td><input type="radio" name="FType" id="FType_F" value="F"></td>
				<td><label for="FType_F"><%=TXT_COMPLETE_UPDATE%></label></td>
			</tr>
			<tr>
				<td><input type="radio" name="FType" id="FType_N" value="N"></td>
				<td><label for="FType_N"><%=TXT_COMPLETE_NO_CHANGES_REQUIRED%></label></td>
			</tr>
			<tr>
				<td><input type="radio" name="FType" id="FType_P" value="P"></td>
				<td><label for="FType_P"><%=TXT_NOT_COMPLETE_UPDATE%></label></td>
			</tr>
			<tr>
				<td><input type="radio" name="FType" id="FType_D" value="D"></td>
				<td><label for="FType_D"><%=TXT_REMOVE_RECORD%></label></td>
			</tr>
		</table>
		<%	If user_bSuppressEmailVOL And Not g_bNoEmail Then%>
		<h3 class="Alert"><%=TXT_NOTIFICATIONS%></h3>
		<p><strong><%=TXT_NOTIFY_AGENCY%></strong>&nbsp;&nbsp;<label for="NotifyAgency_N"><input type="radio" name="NotifyAgency" id="NotifyAgency_N" value="N" checked>&nbsp;<%=TXT_NO%></label>&nbsp;&nbsp;<label for="NotifyAgency_Y"><input type="radio" name="NotifyAgency" id="NotifyAgency_Y" value="Y">&nbsp;<%=TXT_YES%></label>
		<br><strong><%=TXT_NOTIFY_ADMIN%></strong>&nbsp;&nbsp;<label for="NotifyAdmin_N"><input type="radio" name="NotifyAdmin" id="NotifyAdmin_N" value="N" checked>&nbsp;<%=TXT_NO%></label>&nbsp;&nbsp;<label for="NotifyAdmin_Y"><input type="radio" name="NotifyAdmin" id="NotifyAdmin_Y" value="Y">&nbsp;<%=TXT_YES%></label></p>
		<%	End If
		End If%>

<%If Not user_bLoggedIn Then%>
<h3 class="Alert"><%=TXT_SECURITY_CHECK%></h3>
<p><%=TXT_INST_SECURITY_CHECK%></p>
<p><%=TXT_ENTER_TOMORROWS_DATE%></p>
<div class="form-group">
	<label for="sCheckDay" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_DAY%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10">
		<input id="sCheckDay" name="sCheckDay" type="text" size="5" maxlength="8" class="form-control">
	</div>
</div>
<div class="form-group">
	<label for="sCheckMonth" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_MONTH%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10 col-md-11">
		<%Call printMonthList("sCheckMonth")%></label>
	</div>
</div>
<div class="form-group">
	<label for="sCheckYear" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_YEAR%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10 col-md-11">
		<input id="sCheckYear" name="sCheckYear" type="text" size="5" maxlength="8" class="form-control">
	</div>
</div>
<%End If%>
	</div>
</div>

<p>
	<input type="submit" id="SUBMIT_BUTTON" class="btn btn-default" value="<%=TXT_SUBMIT_UPDATES%>">
	<input type="reset" class="btn btn-default" value="<%=TXT_RESET_FORM%>">
</p>

</form>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>

<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/vfeedback.js") %>
<% g_bListScriptLoaded = True %>
<script type="text/javascript">
jQuery(function($) {

	configure_feedback_submit_button();
	configure_entry_form_button();

	init_cached_state();
	restore_cached_state();
});
</script>
<%

Call setSessionLanguage(strRestoreCulture)

End If ' bVNUMError

Call makePageFooter(True)
%>

<!--#include file="../includes/core/incClose.asp" -->

