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
Call setPageInfo(True, DM_CIC, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtPrivacyProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<%
'On Error Resume Next

If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Dim bError, _
	strErrorMessage

bError = False

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

If Nl(intProfileID) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"privacy_profile.asp", vbNullString)
ElseIf Not IsIDType(intProfileID) Then
	bError = True
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"privacy_profile.asp", vbNullString)
Else
	intProfileID = CLng(intProfileID)
End If

If Request("Submit") = TXT_DELETE Then
	Call goToPage("privacy_profile_delete.asp","ProfileID=" & intProfileID,vbNullString)
End If

Dim	strProfileName, _
	strIDList, _
	strDescriptions, _
	strCulture

strDescriptions = vbNullString
For Each strCulture In active_cultures()
	strProfileName = Left(Trim(Request("ProfileName_" & strCulture)),100)
	If Not Nl(strProfileName) Then
		strDescriptions = strDescriptions & _
			"<DESC><Culture>" & strCulture & "</Culture><ProfileName>" & _
			XMLEncode(strProfileName) & "</ProfileName></DESC>"
	End If
Next
If Not Nl(strDescriptions) Then
	strDescriptions = "<DESCS>" & strDescriptions & "</DESCS>"
End If


strIDList = Trim(Request("UseField"))
If Nl(strIDList) Then
	strIDList = Null
End If

If Not bError Then
	Dim cmdUpdateProfile, rsUpdateProfile
	Set cmdUpdateProfile = Server.CreateObject("ADODB.Command")
	With cmdUpdateProfile 	
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_PrivacyProfile_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Descriptions", adVarWChar, adParamInput, -1, strDescriptions)
		.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strIDList)
		.Parameters.Append .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	End With
	Set rsUpdateProfile = cmdUpdateProfile.Execute
	Set rsUpdateProfile = rsUpdateProfile.NextRecordset

	If cmdUpdateProfile.Parameters("@RETURN_VALUE").Value = 0 And Err.Number = 0 Then
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
				"privacy_profile_edit.asp", _
				"ProfileID=" & intProfileID, _
				False)
	ElseIf Err.Number <> 0 Then
		strErrorMessage = Err.Description
	Else
		strErrorMessage = cmdUpdateProfile.Parameters("@ErrMsg").Value
	End If
End If

If bError Or Not Nl(strErrorMessage) Then
	Call makePageHeader(TXT_UPDATE_PROFILE_FAILED, TXT_UPDATE_PROFILE_FAILED, True, False, True, True)
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATE & TXT_COLON & strErrorMessage, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
