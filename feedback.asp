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
Call setPageInfo(False, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtAgencyContact.asp" -->
<!--#include file="text/txtCommonForm.asp" -->
<!--#include file="text/txtDates.asp" -->
<!--#include file="text/txtEntryForm.asp" -->
<!--#include file="text/txtFeedback.asp" -->
<!--#include file="text/txtFeedbackCommon.asp" -->
<!--#include file="text/txtFinder.asp" -->
<!--#include file="text/txtFormSecurity.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtGeoCode.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtMonth.asp" -->
<!--#include file="text/txtRecordPages.asp" -->
<!--#include file="text/txtSubjects.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/list/incAccreditationList.asp" -->
<!--#include file="includes/list/incBoxTypeList.asp" -->
<!--#include file="includes/list/incCertificationList.asp" -->
<!--#include file="includes/list/incCurrencyList.asp" -->
<!--#include file="includes/list/incEmployeeRangeList.asp" -->
<!--#include file="includes/list/incExtraDropDownList.asp" -->
<!--#include file="includes/list/incFiscalYearEndList.asp" -->
<!--#include file="includes/list/incGeoCodeTypeList.asp" -->
<!--#include file="includes/list/incLanguagesList.asp" -->
<!--#include file="includes/list/incMappingCategoryList.asp" -->
<!--#include file="includes/list/incMonthList.asp" -->
<!--#include file="includes/list/incPaymentMethodList.asp" -->
<!--#include file="includes/list/incPaymentTermsList.asp" -->
<!--#include file="includes/list/incQualityList.asp" -->
<!--#include file="includes/list/incRecordTypeList.asp" -->
<!--#include file="includes/list/incStreetDirList.asp" -->
<!--#include file="includes/list/incStreetTypeList.asp" -->
<!--#include file="includes/list/incTypeOfProgramList.asp" -->
<!--#include file="includes/list/incWardList.asp" -->
<!--#include file="includes/mapping/incGoogleMaps.asp" -->
<!--#include file="includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="includes/update/incCICFormFbPrint.asp" -->
<!--#include file="includes/update/incCICFormUpdPrint.asp" -->
<!--#include file="includes/update/incEntryFormGeneral.asp" -->
<%
'On Error Resume Next

bFeedbackForm = True

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

Dim intRSN, _
	strNUM, _
	strFBKey, _
	bNUMError, _
	strError, _
	bHasDynamicAddField, _
	intDefaultGCType

intRSN = Request("RSN")
strNUM = Trim(Request("NUM"))
bNUMError = False
bHasDynamicAddField = False

Dim	bSuggest, _
	bUpdatePasswordRequired, _
	strUpdatePassword

bSuggest = False
bUpdatePasswordRequired = Null
strUpdatePassword = Trim(Request("FeedbackPassword"))
If Nl(strUpdatePassword) Then
	strUpdatePassword = Null
End If

Dim intRTID
intRTID = -1

If Not (Nl(intRSN) And Nl(strNUM)) Then
	If Not IsIDType(intRSN) And Not IsNUMType(strNUM) Then
		If Not IsNUMType(strNUM) Then
			strError = TXT_INVALID_ID & Server.HTMLEncode(strNUM) & "."
		Else
			strError = TXT_INVALID_RSN & Server.HTMLEncode(intRSN) & "."
		End If
		bNUMError = True
	ElseIf Nl(strNUM) Then
		intRSN = CLng(intRSN)
		Dim cmdGetNUM, rsGetNUM
		Set cmdGetNUM = Server.CreateObject("ADODB.Command")
		With cmdGetNUM
			.ActiveConnection = getCurrentCICBasicCnn()
			.CommandType = adCmdText
			.CommandText = "SELECT NUM FROM GBL_BaseTable bt WHERE bt.RSN=" & intRSN
			.CommandTimeout = 0
			Set rsGetNUM = .Execute
		End With
		If Not rsGetNUM.EOF Then
			strNUM = rsGetNUM("NUM")
			Call goToPage(ps_strThisPage,"NUM=" & strNUM,vbNullString)
		Else
			strError = TXT_NO_RECORD_EXISTS_RSN & Server.HTMLEncode(intRSN) & "."
			bNUMError = True
		End If
		intRSN = Null
	End If
Else
	intRSN = Null
	strNUM = Null
	bSuggest = True
End If

If Not bNUMError Then
	Dim intViewType
	Dim cmdFields, rsFields
	Set cmdFields = Server.CreateObject("ADODB.Command")
	With cmdFields
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_CIC_View_FeedbackFields"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@RT_ID", adInteger, adParamInput, 4, intRTID)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@LoggedIn", adBoolean, adParamInput, 1, IIf(user_bLoggedIn,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@UPDATE_PASSWORD", adVarChar, adParamInput, 21, strUpdatePassword)
	End With
	Set rsFields = Server.CreateObject("ADODB.Recordset")
	With rsFields
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdFields
	End With
End If

If Not bSuggest And Not bNUMError Then
	Dim strSQL, strCon

	strSQL = "SELECT bt.RSN, bt.NUM, btd.LangID, bt.FBKEY, bt.RECORD_OWNER, cbt.RECORD_TYPE AS CUR_RT_ID," & _
		"dbo.fn_CIC_RecordInView(bt.NUM," & g_intViewTypeCIC & ",btd.LangID,0,GETDATE()) AS IN_VIEW," & _
		"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & _
		"btd.SOURCE_NAME, btd.SOURCE_TITLE, btd.SOURCE_ORG, btd.SOURCE_PHONE, btd.SOURCE_EMAIL," & _
		"btd.UPDATE_DATE, btd.UPDATE_SCHEDULE, btd.MODIFIED_DATE," & _
		"bt.PRIVACY_PROFILE, bt.UPDATE_PASSWORD, bt.UPDATE_PASSWORD_REQUIRED"

	With rsFields
		While Not .EOF
			If Not Nl(.Fields("FieldSelect")) And _
					Not reEquals(.Fields("FieldName"), "(RSN)|(NUM)",True,False,True,False) Then
				strSQL = strSQL & "," & vbCrLf & .Fields("FieldSelect")
			End If
			.MoveNext
		Wend
		If Not .RecordCount = 0 Then
			.MoveFirst
		End If
	End With

	strSQL = strSQL & vbCrLf & _
		"FROM GBL_BaseTable bt " & vbCrLf & _
		"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=bt.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=(SELECT TOP 1 LangID FROM CIC_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbcrLf & _
		"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
		"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=(SELECT TOP 1 LangID FROM CCR_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)"

	If Not Nl(intRSN) Then
		strSQL = strSQL & vbCrLf & "WHERE bt.RSN=" & intRSN
	Else
		strSQL = strSQL & vbCrLf & "WHERE bt.NUM=" & QsNl(strNUM)
	End If

	If Not user_bLoggedIn Then
		strSQL = strSQL & vbCrLf & AND_CON & "(bt.MemberID=" & g_intMemberID & " OR (" & g_strWhereClauseCICNoDel & "))"
	End If

	'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
	'Response.Flush()

	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandType = adCmdText
		.CommandText = strSQL
		.CommandTimeout = 0
		Set rsOrg = .Execute
	End With

	strFbKey = Left(Trim(Request("Key")),6)

	If rsOrg.EOF Then
		bNUMError = True
		If Nl(strNUM) Then
			strError = TXT_NO_RECORD_EXISTS_RSN & Server.HTMLEncode(intRSN) & "."
		Else
			strError = TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strNUM) & "."
		End If
	ElseIf Not rsOrg.Fields("IN_VIEW") And (user_bLoggedIn Or Not g_bAllowFeedbackNotInViewCIC Or strFbKey<>rsOrg.Fields("FBKEY")) Then
		Call securityFailure()
	Else
		bUpdatePasswordRequired = rsOrg.Fields("UPDATE_PASSWORD_REQUIRED")
		If (bUpdatePasswordRequired = False And Nl(rsOrg.Fields("PRIVACY_PROFILE"))) Or _
				(user_bLoggedIn And Not g_bRespectPrivacyProfile) Then
			bUpdatePasswordRequired = Null
		End If
		If Nl(bUpdatePasswordRequired) Then
			strUpdatePassword = Null
		ElseIf Not Nl(strUpdatePassword) Then
			If strUpdatePassword <> rsOrg.Fields("UPDATE_PASSWORD") Then
				strError = TXT_FEEDBACK_PASSWORD_ERROR
				strUpdatePassword = Null
			End If
		End If
	End If
End If

Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)

If bNUMError Then
	Call handleError(strError, vbNullString, vbNullString)
End If

Dim strFeedbackBlurb, _
	strTermsOfUseURL, _
	bDataUseAuth, _
	bDataUseAuthPhone, _
	intInclusionPolicyID

bDataUseAuth = False

Dim cmdViewFb, rsViewFb
Set cmdViewFb = Server.CreateObject("ADODB.Command")
With cmdViewFb
	.ActiveConnection = getCurrentCICBasicCnn()
	.CommandText = "dbo.sp_CIC_View_Fb_s"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
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
	If Not bNUMError Then
		Call getROInfo(rsOrg.Fields("RECORD_OWNER"),DM_CIC)
		strOrgName = rsOrg.Fields("ORG_NAME_FULL")
%>
<h2><%=TXT_SUGGEST_CHANGES_FOR%>
<br>
<%		If rsOrg.Fields("IN_VIEW") Then%>
<em><a href="<%=makeDetailsLink(rsOrg("NUM"),StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber),vbNullString)%>"><%=strOrgName%></a></em>
<%		Else%>
<em><%=strOrgName%></em>
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
%>
<h2><%=TXT_SUGGEST_NEW_RECORD%></h2>
<%	If Not Nl(intInclusionPolicyID) Then %>
<p><span class="AlertBubble"><%=TXT_READ_INCLUSION%></span></p>
<%
	End If
End If

If Not Nl(bUpdatePasswordRequired) And Nl(strUpdatePassword) Then
	If bUpdatePasswordRequired Then
	%> <p><span class="AlertBubble"><%=TXT_FEEDBACK_PASSWORD_REQUIRED%></span></p><%
	Else
	%> <p><span class="AlertBubble"><%=TXT_FEEDBACK_PASSWORD_PRIVACY%></span></p><%
	End If
%>
<form name="PasswordForm" method="post">
<%=g_strCacheFormVals%>
<div style="display:none"><input type="hidden" name="NUM" value="<%=rsOrg("NUM")%>"></div>
<%If intCurSearchNumber >= 0 And Not bSuggest Then%>
<div style="display:none"><input type="hidden" name="Number" value="<%=intCurSearchNumber%>"></div>
<%End If%>
<p><strong><%=TXT_FEEDBACK_PASSWORD%></strong> <input type="password" name="FeedbackPassword" value=""> <input type="submit" name="submit" value="<%=TXT_SUBMIT%>"></p>
</form>
<%
End If

If (Not Nl(strUpdatePassword) Or Nl(bUpdatePasswordRequired) Or Not bUpdatePasswordRequired) And _
		(bSuggest Or Not bNUMError) Then
%>
<form id="EntryForm" name="EntryForm" action="feedback2.asp" role="form" class="form-horizontal" method="post">
<div style="display:none">
<input name="transaction-amount" autocomplete="transaction-amount">
<%=g_strCacheFormVals%>
<input type="hidden" name="UpdateLn" value="<%=g_objCurrentLang.Culture%>" />
<%If Not bSuggest Then%>
<input type="hidden" name="NUM" value="<%=rsOrg("NUM")%>">
<input type="hidden" name="CUR_RT_ID" value="<%=rsOrg("CUR_RT_ID")%>">
<%If Not Nl(strFbKey) Then%>
<input type="hidden" name="Key" value="<%=strFBKey%>">
<%End If%>
<%End If%>
<%If intCurSearchNumber >= 0 And Not bSuggest Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%End If%>
<%If Not Nl(strUpdatePassword) Then%>
<input type="hidden" name="FeedbackPassword" value="<%=Server.HTMLEncode(strUpdatePassword)%>">
<%End If%>
</div>
<%
	If Not bSuggest Then
%>
<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
		<h2><%=TXT_REVIEW_RECORD & rsOrg("NUM")%></h2>
	</div>
	<div class="panel-body no-padding">
		<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
<%
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
	End If

	Dim intPrevGroupID, _
		strGroupContents, _
		strGroupHeader, _
		strFieldName, _
		strFieldContents, _
		strFieldVal, _
		strFieldDisplay, _
		bHasLabel

	intPrevGroupID = vbNullString

	While Not rsFields.EOF
	If intPrevGroupID <> rsFields.Fields("DisplayFieldGroupID") Then
		If Not (Nl(intPrevGroupID) And bSuggest) Then
%>
		</table>
	</div>
</div>
<%
		End If
		intPrevGroupID = rsFields.Fields("DisplayFieldGroupID")
%>
<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
		<h2><%=rsFields.Fields("DisplayFieldGroupName")%></h2>
	</div>
	<div class="panel-body no-padding">
		<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
<%
		End If
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
					Case "ACCREDITED"
						strFieldVal = makeAccreditationContents(rsOrg, Not bSuggest)
					Case "CC_LICENSE_INFO"
						strFieldVal = makeCCLicenseInfoContents(rsOrg, Not bSuggest)
					Case "CERTIFIED"
						strFieldVal = makeCertificationContents(rsOrg, Not bSuggest)
					Case "CONTACT_1"
						strFieldVal = makeContactContents(rsOrg, strFieldName, Not bSuggest)
					Case "CONTACT_2"
						strFieldVal = makeContactContents(rsOrg, strFieldName, Not bSuggest)			
					Case "ELIGIBILITY"
						strFieldVal = makeEligibilityContents(rsOrg, Not bSuggest)
					Case "EMPLOYEES"
						strFieldVal = makeEmployeesContents(rsOrg, Not bSuggest)
					Case "EMPLOYEES_RANGE"
						strFieldVal = makeEmployeesRangeContents(rsOrg, Not bSuggest)
					Case "EVENT_SCHEDULE"
						strFieldVal = makeEventScheduleContents(rsOrg, Not bSuggest)
					Case "EXEC_1"
						strFieldVal = makeContactContents(rsOrg, strFieldName, Not bSuggest)
					Case "EXEC_2"
						strFieldVal = makeContactContents(rsOrg, strFieldName, Not bSuggest)
					Case "EXTRA_CONTACT_A"
						strFieldVal = makeContactContents(rsOrg, strFieldName, Not bSuggest)
					Case "FISCAL_YEAR_END"
						strFieldVal = makeFiscalYearEndContents(rsOrg, Not bSuggest)
					Case "GEOCODE"
						strFieldVal = makeGeoCodeContents(rsOrg, Not bSuggest)
					Case "LANGUAGES"
						strFieldVal = makeLanguageContents(rsOrg, Not bSuggest)
					Case "LEGAL_ORG"
						If Not bSuggest Then
							strFieldContents = rsOrg.Fields(strFieldName)
						End If
						strFieldVal = makeTextFieldVal(strFieldName, strFieldContents, rsFields.Fields("MaxLength"), False)
					Case "LOCATED_IN_CM"
						strFieldVal = makeLocatedInContents(rsOrg, Not bSuggest)
					Case "LOGO_ADDRESS"
						strFieldVal = makeLogoAddressContents(rsOrg, Not bSuggest)
					Case "MAIL_ADDRESS"
						strFieldVal = makeAddress(rsOrg, True, Not bSuggest)
					Case "NAICS"
						strFieldVal = makeNAICSContents(rsOrg, Not bSuggest)
					Case "ORG_LEVEL_2"
						If Not bSuggest Then
							strFieldContents = rsOrg.Fields(strFieldName)
						End If
						strFieldVal = makeTextFieldVal(strFieldName, strFieldContents, rsFields.Fields("MaxLength"), False)
					Case "ORG_LEVEL_3"
						If Not bSuggest Then
							strFieldContents = rsOrg.Fields(strFieldName)
						End If
						strFieldVal = makeTextFieldVal(strFieldName, strFieldContents, rsFields.Fields("MaxLength"), False)
					Case "ORG_LEVEL_4"
						If Not bSuggest Then
							strFieldContents = rsOrg.Fields(strFieldName)
						End If
						strFieldVal = makeTextFieldVal(strFieldName, strFieldContents, rsFields.Fields("MaxLength"), False)
					Case "ORG_LEVEL_5"
						If Not bSuggest Then
							strFieldContents = rsOrg.Fields(strFieldName)
						End If
						strFieldVal = makeTextFieldVal(strFieldName, strFieldContents, rsFields.Fields("MaxLength"), False)
					Case "SERVICE_NAME_LEVEL_1"
						If Not bSuggest Then
							strFieldContents = rsOrg.Fields(strFieldName)
						End If
						strFieldVal = makeTextFieldVal(strFieldName, strFieldContents, rsFields.Fields("MaxLength"), False)
					Case "SERVICE_NAME_LEVEL_2"
						If Not bSuggest Then
							strFieldContents = rsOrg.Fields(strFieldName)
						End If
						strFieldVal = makeTextFieldVal(strFieldName, strFieldContents, rsFields.Fields("MaxLength"), False)
					Case "SITE_ADDRESS"
						strFieldVal = makeAddress(rsOrg, False, Not bSuggest)
					Case "SOCIAL_MEDIA"
						strFieldVal = makeSocialMediaFieldVal(rsOrg, Not bSuggest)
					Case "PAYMENT_TERMS"
						strFieldVal = makePaymentTermsContents(rsOrg, Not bSuggest)
					Case "PREF_CURRENCY"
						strFieldVal = makePrefCurrencyContents(rsOrg, Not bSuggest)
					Case "PREF_PAYMENT_METHOD"
						strFieldVal = makePrefPaymentMethodContents(rsOrg, Not bSuggest)
					Case "QUALITY"
						strFieldVal = makeQualityContents(rsOrg, Not bSuggest)
					Case "RECORD_TYPE"
						strFieldVal = makeRecordTypeContents(rsOrg, Not bSuggest)
					Case "SPACE_AVAILABLE"
						strFieldVal = makeSpaceAvailableContents(rsOrg, Not bSuggest)
					Case "SUBJECTS"
						strFieldVal = makeSubjectContentsFb(rsOrg, Not bSuggest)
					Case "TAXONOMY"
						strFieldVal = makeTaxonomyContentsFb(rsOrg, Not bSuggest)			
					Case "TYPE_OF_PROGRAM"
						strFieldVal = makeTypeOfProgramContents(rsOrg, Not bSuggest)
					Case "VOLCONTACT"
						strFieldVal = makeContactContents(rsOrg, strFieldName, Not bSuggest)
					Case "WARD"
						strFieldVal = makeWardContents(rsOrg, Not bSuggest)
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
									False, _
									rsFields.Fields("WYSIWYG") _
									)
						End Select
				End Select
			' The default case is the memo (long-text) field type
			Case Else
				strFieldVal = makeMemoFieldVal(strFieldName, _
					strFieldContents, _
					TEXTAREA_ROWS_SHORT, _
					False, _
					rsFields.Fields("WYSIWYG") _
					)
		End Select
		bHasLabel = False
		If rsFields.Fields("UseDisplayForFeedback") _
					Or reEquals(strFieldName,"(NAICS)|(ORG_NUM)|(ORG_LEVEL_[1-5])|(SERVICE_NAME_LEVEL_[1-5])|(LOCATION_NAME)|(LOCATED_IN_CM)|(SORT_AS)|(LEGAL_ORG)",True,True,True,False) _
					Or reEquals(rsFields.Fields("FormFieldType"),"d|m|t|u",True,True,True,False) _
					Or rsFields.Fields("ExtraFieldType") = "p" _
					Or rsFields.Fields("ValidateType") = "n" _
                Then
			bHasLabel = True
		End If
		strFieldDisplay = rsFields.Fields("FieldDisplay")
		If strFieldName = "ORG_LEVEL_1" Or strFieldName = "ORG_LEVEL_2" Or strFieldName = "ORG_LEVEL_3" Then
			strFieldDisplay = Nz(get_view_data_cic("OrgLevel" & Right(strFieldName, 1) & "Name"), strFieldDisplay)
		End If
		Call printRow(strFieldName,strFieldDisplay,strFieldVal, True,rsFields.Fields("HasHelp"),False,Not rsFields.Fields("AllowNulls"),False,False,bHasLabel)
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
		makeTextFieldVal("SOURCE_EMAIL", strSourceEmail, 100, False), _
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
		<%	If user_bSuppressEmailCIC And Not g_bNoEmail Then%>
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
<%= JSVerScriptTag("scripts/feedback.js") %>
<%= JSVerScriptTag("scripts/cultures/globalize.culture." & Nz(strUpdateLang,g_objCurrentLang.Culture) & ".js") %>
<% g_bListScriptLoaded = True %>
<script type="text/javascript">
jQuery(function($) {

	configure_feedback_submit_button();
	configure_entry_form_button();

	init_cached_state();
<%
If bLanguages Then
%>
	entryform.languages_source = <%= makeLanguagesListJavaScript() %>;
	init_languages($, "<%= TXT_NOT_FOUND %>");
<%
End If
If bHasSchedule Then
%> 
	init_entryform_items($('.EntryFormItemContainer'),'<%= TXT_DELETE %>', '<%= TXT_RESTORE %>'); 
<%
End If
If bLocatedIn Or bSiteAddress Then
%>
	entryform.community_complete_url = "<%= makeLinkB(ps_strPathToStart & "jsonfeeds/community_generator.asp") %>";
<%
End If
If bLocatedIn Then
%>
	init_community_autocomplete($, 'LOCATED_IN_CM', entryform.community_complete_url, 3)
<%
End If
If bSiteAddress Then
%>
	init_community_autocomplete($, 'SITE_CITY', entryform.community_complete_url, 3)
<%
End If
%>
	restore_cached_state();

<%
If bHasSchedule Then
%>
	init_schedule($)
<%
End If
%>

<% If bHaveGeoCodeUI Then %>
	pageconstants = {};
	pageconstants.txt_geocode_address_changed = "<%=TXT_GEOCODE_ADDRESS_CHANGED%>";
	pageconstants.txt_geocode_intersection_change = "<%=TXT_GEOCODE_ADDRESS_CHANGED%>";
	pageconstants.culture= "<%=Nz(strUpdateLang,g_objCurrentLang.Culture)%>";
	Globalize.culture(pageconstants.culture);

	pageconstants.txt_geocode_unknown_address= "<%=TXT_GEOCODE_UNKNOWN_ADDRESS%>";
	pageconstants.txt_geocode_map_key_fail= "<%=TXT_GEOCODE_MAP_KEY_FAIL%>";
	pageconstants.txt_geocode_too_many_queries= "<%=TXT_GEOCODE_TOO_MANY_QUERIES%>";
	pageconstants.txt_geocode_unknown_error= "<%= TXT_GEOCODE_UNKNOWN_ERROR & TXT_COLON%>";
	initialize_maps(pageconstants.culture, <%= JSONQs(getGoogleMapsKeyArg(), True)%>, entryform_maps_loaded);
<% End If %>
});
</script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/6.1.0/tinymce.min.js" integrity="sha512-dr3qAVHfaeyZQPiuN6yce1YuH7YGjtUXRFpYK8OfQgky36SUfTfN3+SFGoq5hv4hRXoXxAspdHw4ITsSG+Ud/g==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script type="text/javascript">
        tinymce.init({
			selector: '.WYSIWYG',
            plugins: 'lists autolink link image charmap preview searchreplace visualblocks fullscreen table',
            toolbar: 'undo redo styles bullist numlist link | bold italic | cut copy paste searchreplace',
			menubar: false,
			statusbar: false,
            convert_urls: false,
            cleanup: true,
			schema: 'html5',
            formats: {
                underline: { inline: 'u', exact: true }
            },
            style_formats: [
                { title: 'Paragraph', format: 'p' },
                { title: 'Heading 1', format: 'h1' },
                { title: 'Heading 2', format: 'h2' },
                { title: 'Heading 3', format: 'h3' },
                { title: 'Heading 4', format: 'h4' }
            ]
        });
</script>
<%

Call setSessionLanguage(strRestoreCulture)

End If ' bNUMError
Call makePageFooter(True)
%>

<!--#include file="includes/core/incClose.asp" -->

