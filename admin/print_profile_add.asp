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
<% 'End Base includes %>
<!--#include file="../text/txtPrintProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<%
Dim intDomain, _
	strType, _
	strDbArea

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strDbArea = DM_S_CIC
		strType = TXT_CIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strDbArea = DM_S_VOL
		strType = TXT_VOLUNTEER
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Dim strProfileName, _
	intProfileID
	
intProfileID = Request("ProfileID")

If Nl(intProfileID) Then
	intProfileID = Null
ElseIf Not IsIDType(intProfileID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	intProfileID = CLng(intProfileID)
End If

strProfileName = Trim(Request("ProfileName"))

If Nl(strProfileName) Then
	Call handleError(TXT_SPECIFY_PROFILE_NAME, _
		"print_profile.asp", "DM=" & intDomain)
End If

Dim cmdInsertProfile, rsInsertProfile
Set cmdInsertProfile = Server.CreateObject("ADODB.Command")
With cmdInsertProfile
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_" & strDbArea & "_PrintProfile_i"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ProfileName", adVarChar, adParamInput, 50, strProfileName)
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInputOutput, 4, intProfileID)
	.Parameters.Append .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
End With
Set rsInsertProfile = cmdInsertProfile.Execute
Set rsInsertProfile = rsInsertProfile.NextRecordset

If cmdInsertProfile.Parameters("@RETURN_VALUE").Value = 0 And Err.Number = 0 Then
	Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_ADDED, _
		"print_profile_edit.asp", _
		"ProfileID=" & cmdInsertProfile.Parameters("@ProfileID") & "&DM=" & intDomain, _
		False)
Else
	Dim strErrorMessage
	If Err.Number <> 0 Then
		strErrorMessage = Err.Description
	Else
		strErrorMessage = cmdInsertProfile.Parameters("@ErrMsg").Value
	End If
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_ADDED & TXT_COLON & strErrorMessage, _
		"print_profile.asp", _
		"DM=" & intDomain)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
