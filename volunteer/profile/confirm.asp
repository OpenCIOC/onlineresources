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
<!--#include file="../../includes/core/adovbs.inc" -->
<!--#include file="../../includes/core/incVBUtils.asp" -->
<!--#include file="../../includes/validation/incBasicTypes.asp" -->
<!--#include file="../../includes/core/incRExpFuncs.asp" -->
<!--#include file="../../includes/core/incHandleError.asp" -->
<!--#include file="../../includes/core/incSetLanguage.asp" -->
<!--#include file="../../includes/core/incPassVars.asp" -->
<!--#include file="../../text/txtGeneral.asp" -->
<!--#include file="../../text/txtError.asp" -->
<!--#include file="../../includes/core/incConnection.asp" -->
<!--#include file="../../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_VOL, DM_VOL, "../../", "volunteer/profile/", vbNullString)
%>
<!--#include file="../../includes/core/incCrypto.asp" -->
<!--#include file="../../includes/core/incSecurity.asp" -->
<!--#include file="../../includes/core/incHeader.asp" -->
<!--#include file="../../includes/core/incFooter.asp" -->
<!--#include file="../../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../../text/txtVOLProfile.asp" -->
<!--#include file="../../includes/core/incSendMail.asp" -->
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->

<%
If Not g_bUseVolunteerProfiles Then
	Call goToPageB(ps_strPathToStart & "volunteer/")
End If

Dim strProfileID, _
	strConfirmationToken, _
	strRedirectPage, _
	strRedirectArgs, _
	strError, _
	strToEmail, _
	strFromEmail, _
	strNewConfirmationToken, _
	intReturn

strError = Null
strProfileID = Trim(Request("PID"))
strConfirmationToken = Trim(Request("CT"))
strRedirectPage = Ns(Trim(Request("page")))
strRedirectArgs = Ns(Trim(Request("args")))
strNewConfirmationToken = LCase(getRandomString(32))

If Not IsGUIDType(strProfileID) Then
	strError = TXT_INVALID_PID_VALUE
ElseIf Not IsRandomKey(strConfirmationToken) Then
	strError = TXT_INVALID_CT_VALUE
End If

If Nl(strError) Then
	Dim objReturn, objErrMsg, objToEmail, objFromEmail
	Dim cmdProfileInfo, rsProfileInfo
	Set cmdProfileInfo = Server.CreateObject("ADODB.Command")
	With cmdProfileInfo
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "dbo.sp_VOL_Profile_u_Confirm"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@Return", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, strProfileID)
		.Parameters.Append .CreateParameter("@ConfirmationToken", adChar, adParamInput, 32, strConfirmationToken)
		.Parameters.Append .CreateParameter("@NewConfirmationToken", adChar, adParamInput, 32, strNewConfirmationToken)
		Set objToEmail = .CreateParameter("@ToEmail", adVarChar, adParamOutput, 100)
		.Parameters.Append objToEmail
		Set objFromEmail = .CreateParameter("@FromEmail", adVarChar, adParamOutput, 100)
		.Parameters.Append objFromEmail
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsProfileInfo = cmdProfileInfo.Execute()

	intReturn = objReturn.Value
	If intReturn <> 0 Then
		strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End If
	strToEmail = objToEmail.Value
	strFromEmail = objFromEmail.Value

	Set rsProfileInfo = Nothing
	Set cmdProfileInfo = Nothing
End If

If Nl(strError) Then
	Dim strTargetPage, strTargetArgs, strMessage
	strTargetArgs = vbNullString
	If vprofile_strID = strProfileID Then
		Call updateVProfileLoginCookie(strToEmail)
	End If
	If vprofile_bLoggedIn Then
		strTargetPage = "start.asp"
		If Not Nl(strRedirectPage) Then
			strTargetPage = ps_strPathToStart & strRedirectPage
			strTargetArgs = strRedirectArgs
		End If
		strMessage = TXT_YOUR_EMAIL_CONFIRMED
	Else
		strTargetPage = "login.asp"
		If Not Nl(strRedirectPage) Then
			strTargetArgs = "page="&Server.URLEncode(strRedirectPage) & _
							"&args=" & Server.URLEncode(strRedirectArgs)
		End If
		If Request("ref") = "reactivate" Then
			strMessage = TXT_YOUR_ACCOUNT_REACTIVATED
		Else
			strMessage = TXT_YOUR_EMAIL_PLEASE_SIGN_IN
		End If
	End If
	Call handleMessage(strMessage, strTargetPage, strTargetArgs, False)

Else
	Call makePageHeader(TXT_VOL_PROFILE_CONFIRMATION, TXT_VOL_PROFILE_CONFIRMATION, False, True, True, True)
	Call handleError(strError, vbNullString, vbNullString)
	If intReturn = 16 Then
		' Handle Expired Confirmation Code
		Dim strAccessURL, bEmailFailed
		strAccessURL = reReplace(Request.ServerVariables("PATH_INFO"),"(.*)\/" & ps_strThisPageFull,"$1",True,False,False,False)
		strAccessURL = Request.ServerVariables("HTTP_HOST") & strAccessURL

		Dim strEmailBody
		strEmailBody = TXT_HI & "," & vbCrLf & vbCrLf & _
			TXT_ATTEMPTED_CONFIRMATION_WITH_EXPIRED_CODE & _
			" " & "https://" & strAccessURL & "/volunteer/" & vbCrLf & vbCrLf & _
			TXT_PLEASE_FOLLOW_LINK & " " & _
			TXT_COMPLETE_CONFIRMATION & vbCrLf & _
			"https://" & strAccessURL & makeLink("/volunteer/profile/confirm.asp", "PID=" & Server.URLEncode(strProfileID) & "&CT=" & Server.URLEncode(strNewConfirmationToken),vbNullString) & vbCrLf & vbCrLf & _
			TXT_LINK_EXPIRE_NOTICE
					
		bEmailFailed = sendEmail(False, strFromEmail, strToEmail, TXT_EMAIL_CONFIRMATION_SUBJECT, strEmailBody)

		%><p><%= TXT_NEW_EMAIL_SENT %></p>
		<%
	End If
	Call makePageFooter(True)
End If

%>


<!--#include file="../../includes/core/incClose.asp" -->


