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
' Purpose:		Process changes to agency (add,update,delete)
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
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtAgency.asp" -->
<!--#include file="../text/txtFormDataCheck.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/validation/incFormDataCheck.asp" -->
<%
'On Error Resume Next

If Not user_bSuperUser Then
	Call securityFailure()
End If

Dim strErrorList

Sub checkAgencyCode(strFldVal)
	If Not Nl(strFldVal) Then
		If Not reEquals(strFldVal,"([A-Z]{3})",True,False,True,False) Then
			strErrorList = strErrorList & "<li>" & strFldVal & TXT_NOT_VALID_AGENCY_CODE & "</li>"
		End If
	End If
End Sub

Dim bNew
bNew = False

Dim	intAgencyID, _
	intMemberID, _
	strAgencyCode, _
	bRecordOwnerCIC, _
	strUpdateEmailCIC, _
	strUpdatePhoneCIC, _
	strInquiryPhoneCIC, _
	strAgencyNUMCIC, _
	bRecordOwnerVOL, _
	strUpdateEmailVOL, _
	strUpdatePhoneVOL, _
	strInquiryPhoneVOL, _
	strAgencyNUMVOL, _
	bEnforceReqFields, _
	bUpdateAccountDefault, _
	bUpdatePasswordDefault, _
	strUpdateAccountEmail, _
	intUpdateAccountLangID

intAgencyID = Trim(Request("AgencyID"))

If Nl(intAgencyID) Then
	bNew = True
	intAgencyID = Null
ElseIf Not IsIDType(intAgencyID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intAgencyID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_AGENCY, _
		"agencies.asp", vbNullString)
Else
	intAgencyID = CLng(intAgencyID)
End If

If user_bSuperUserGlobal And g_bOtherMembers Then
	intMemberID = Request("MemberID")
	Call checkID(TXT_MEMBER, intMemberID)
Else
	intMemberID = g_intMemberID
End If

If Request("Submit") = TXT_DELETE Then
	Call goToPage("agencies_delete.asp","AgencyID=" & intAgencyID,vbNullString)
End If

strAgencyCode = UCase(Request("AgencyCode"))
Call checkAgencyCode(strAgencyCode)

bRecordOwnerCIC = CbToSQLBool("RecordOwnerCIC")
strUpdateEmailCIC = Request("UpdateEmailCIC")
Call checkEmail("CIC Update Email",strUpdateEmailCIC)
strUpdatePhoneCIC = Request("UpdatePhoneCIC")
strInquiryPhoneCIC = Request("InquiryPhoneCIC")
strAgencyNUMCIC = UCase(Request("AgencyNUMCIC"))
If Not IsNUMType(strAgencyNUMCIC) Then
	strAgencyNUMCIC = Null
End If
Call checkNUM(TXT_AGENCY_NUM & " (" & TXT_CIC & ")", strAgencyNUMCIC)

bRecordOwnerVOL = CbToSQLBool("RecordOwnerVOL")
strUpdateEmailVOL = Trim(Request("UpdateEmailVOL"))
Call checkEmail("Volunteer Update Email", strUpdateEmailVOL)
strUpdatePhoneVOL = Trim(Request("UpdatePhoneVOL"))
strInquiryPhoneVOL = Trim(Request("InquiryPhoneVOL"))
strAgencyNUMVOL = UCase(Trim(Request("AgencyNUMVOL")))
If Not IsNUMType(strAgencyNUMVOL) Then
	strAgencyNUMVOL = Null
End If
Call checkNUM(TXT_AGENCY_NUM & " (" & TXT_VOLUNTEER & ")", strAgencyNUMVOL)

bEnforceReqFields = CbToSQLBool("EnforceReqFields")

bUpdateAccountDefault = CbToSQLBool("UpdateAccountDefault")
bUpdatePasswordDefault = CbToSQLBool("UpdatePasswordDefault")
strUpdateAccountEmail = Left(Trim(Request("UpdateAccountEmail")),100)
intUpdateAccountLangID = Request("UpdateAccountLangID")
If Nl(intUpdateAccountLangID) Then
	intUpdateAccountLangID = g_objCurrentLang.LangID
ElseIf Not IsLangID(intUpdateAccountLangID) Then
	intUpdateAccountLangID = g_objCurrentLang.LangID
End If

If Not Nl(strErrorList) Then
	Call makePageHeader(TXT_UPDATE_AGENCY_FAILED, TXT_UPDATE_AGENCY_FAILED, True, False, True, True)
	Call handleError(TXT_AGENCY_NOT_UPDATED & "<ul>" & strErrorList & "</ul>", _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
Else
	Dim objReturn, objErrMsg
	Dim cmdUpdateAgency, rsUpdateAgency
	Set cmdUpdateAgency = Server.CreateObject("ADODB.Command")
	With cmdUpdateAgency 	
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_Agency_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@AgencyID", adInteger, adParamInputOutput, 4, intAgencyID)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, intMemberID)
		.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, strAgencyCode)
		.Parameters.Append .CreateParameter("@RecordOwnerCIC", adBoolean, adParamInput, 1, bRecordOwnerCIC)
		.Parameters.Append .CreateParameter("@UpdateEmailCIC", adVarChar, adParamInput, 100, strUpdateEmailCIC)
		.Parameters.Append .CreateParameter("@UpdatePhoneCIC", adVarChar, adParamInput, 60, strUpdatePhoneCIC)
		.Parameters.Append .CreateParameter("@InquiryPhoneCIC", adVarChar, adParamInput, 60, strInquiryPhoneCIC)
		.Parameters.Append .CreateParameter("@AgencyNUMCIC", adVarChar, adParamInput, 8, strAgencyNUMCIC)
		.Parameters.Append .CreateParameter("@RecordOwnerVOL", adBoolean, adParamInput, 1, bRecordOwnerVOL)
		.Parameters.Append .CreateParameter("@UpdateEmailVOL", adVarChar, adParamInput, 100, strUpdateEmailVOL)
		.Parameters.Append .CreateParameter("@UpdatePhoneVOL", adVarChar, adParamInput, 60, strUpdatePhoneVOL)
		.Parameters.Append .CreateParameter("@InquiryPhoneVOL", adVarChar, adParamInput, 60, strInquiryPhoneVOL)
		.Parameters.Append .CreateParameter("@AgencyNUMVOL", adVarChar, adParamInput, 8, strAgencyNUMVOL)
		.Parameters.Append .CreateParameter("@EnforceReqFields", adBoolean, adParamInput, 1, bEnforceReqFields)
		.Parameters.Append .CreateParameter("@UpdateAccountDefault", adBoolean, adParamInput, 1, bUpdateAccountDefault)
		.Parameters.Append .CreateParameter("@UpdatePasswordDefault", adBoolean, adParamInput, 1, bUpdatePasswordDefault)
		.Parameters.Append .CreateParameter("@UpdateAccountEmail", adVarChar, adParamInput, 100, strUpdateAccountEmail)
		.Parameters.Append .CreateParameter("@UpdateAccountLangID", adInteger, adParamInput, 4, intUpdateAccountLangID)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With

	Set rsUpdateAgency = cmdUpdateAgency.Execute
	Set rsUpdateAgency = rsUpdateAgency.NextRecordset

	Select Case objReturn.Value
		Case 0
			If bNew Then
				intAgencyID = cmdUpdateAgency.Parameters("@AgencyID").Value
			End If
			Call handleMessage(TXT_AGENCY_UPDATED, _
					"agencies_edit.asp", _
					"AgencyID=" & intAgencyID, _
					False)
	Case Else
		Dim strErrorMessage
		Call makePageHeader(TXT_UPDATE_AGENCY_FAILED, TXT_UPDATE_AGENCY_FAILED, True, False, True, True)
		Call handleError(TXT_AGENCY_NOT_UPDATED & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			vbNullString, _
			vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
		Call makePageFooter(False)
	End Select

	Set rsUpdateAgency = Nothing
	Set cmdUpdateAgency = Nothing
End If
%>

<!--#include file="../includes/core/incClose.asp" -->
