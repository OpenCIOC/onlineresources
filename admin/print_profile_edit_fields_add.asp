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
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtPrintProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<%
Dim intDomain, _
	intFldDomain, _
	strType
	
intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

intFldDomain = Request("FieldDM")
If IsNumeric(intFldDomain) Then
	intFldDomain = CInt(intFldDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strType = TXT_CIC
		intFldDomain = DM_GLOBAL
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
		If Not intFldDomain = DM_VOL Then
			intFldDomain = DM_GLOBAL
		End If
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

If Nl(intProfileID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
ElseIf Not IsIDType(intProfileID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	intProfileID = CLng(intProfileID)
End If

Dim intFieldID
intFieldID = Request("FieldID")

If Nl(intFieldID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_FIELD, _
		"print_profile_edit_fields.asp", "ProfileID=" & intProfileID & "&DM=" & intDomain)
ElseIf Not IsIDType(intFieldID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intFieldID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_FIELD, _
		"print_profile_edit_fields.asp", "ProfileID=" & intProfileID & "&DM=" & intDomain)
Else
	intFieldID = CLng(intFieldID)
End If

Dim intFieldTypeID
intFieldTypeID = Request("FieldTypeID")

If Nl(intFieldTypeID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_FIELD, _
		"print_profile_edit_fields.asp", "ProfileID=" & intProfileID & "&DM=" & intDomain)
ElseIf Not IsIDType(intFieldTypeID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intFieldTypeID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_FIELD, _
		"print_profile_edit_fields.asp", "ProfileID=" & intProfileID & "&DM=" & intDomain)
Else
	intFieldTypeID = CLng(intFieldTypeID)
End If

Dim objReturn, objErrMsg
Dim cmdAddField, rsAddField
Set cmdAddField = Server.CreateObject("ADODB.Command")
With cmdAddField
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_PrintProfile_Fld_i"
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 4, intDomain)
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
	.Parameters.Append .CreateParameter("@GBLFieldID", adInteger, adParamInput, 4, IIf(intFldDomain=DM_GLOBAL,intFieldID,Null))
	.Parameters.Append .CreateParameter("@VOLFieldID", adInteger, adParamInput, 4, IIf(intFldDomain=DM_VOL,intFieldID,Null))
	.Parameters.Append .CreateParameter("@FieldTypeID", adInteger, adParamInput, 4, intFieldTypeID)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
End With

Set rsAddField = cmdAddField.Execute
Set rsAddField = rsAddField.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
			"print_profile_edit_fields.asp", _
			"ProfileID=" & intProfileID & "&DM=" & intDomain, _
			False)
	Case Else

		Call makePageHeader(TXT_ADD_FIELD_FAILED, TXT_ADD_FIELD_FAILED, True, False, True, True)
		Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATE & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			vbNullString, _
			vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
		Call makePageFooter(False)
End Select
%>
<!--#include file="../includes/core/incClose.asp" -->
