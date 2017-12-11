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
<!--#include file="../../text/txtUsers.asp" -->
<!--#include file="../../text/txtFormDataCheck.asp" -->
<!--#include file="../../text/txtVOLProfile.asp" -->
<!--#include file="../../includes/core/incFormat.asp" -->
<!--#include file="../../includes/core/incSendMail.asp" -->
<!--#include file="../../includes/validation/incFormDataCheck.asp" -->
<!--#include file="../../includes/validation/incPassSecure.asp" -->
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->
<%
If Not g_bUseVolunteerProfiles Then
	Call goToPageB(ps_strPathToStart & "volunteer/")
End If

Dim	bValidationError,_
	bSQLError, _
	strErrorList, _
	strEmail, _
	strConfirmationToken, _
	intReturn

intReturn = -1

bValidationError = False
bSQLError = False
strErrorList = vbNullString
strEmail = Trim(Request("Email"))

If Nl(strEmail) Then
	Call checkAddValidationError(TXT_EMAIL_REQUIRED)
Else
	Call checkOneEmail(TXT_EMAIL_ADDRESS, strEmail)
End If
strConfirmationToken = LCase(getRandomString(32))

If Not Nl(strErrorList) Then
	bValidationError = True
Else
	Dim strFromEmail, strProfileID
	
	Dim objReturn, objErrMsg, objProfileID, objFromEmail
	Dim cmdProfileInfo, rsProfileInfo
	Set cmdProfileInfo = Server.CreateObject("ADODB.Command")
	With cmdProfileInfo
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "sp_VOL_Profile_u_Reactivate"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		Set objProfileID = .CreateParameter("@ProfileID", adGUID, adParamOutput, 16)
		.Parameters.Append objProfileID
		.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 60, strEmail)
		.Parameters.Append .CreateParameter("@ConfirmationToken", adChar, adParamInput, 32, strConfirmationToken)
		Set objFromEmail = .CreateParameter("@FromEmail", adVarChar, adParamOutput, 60)
		.Parameters.Append objFromEmail
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsProfileInfo = cmdProfileInfo.Execute()
	If rsProfileInfo.State <> 0 Then
		rsProfileInfo.Close()
	End If

	If objReturn.Value <> 0 Then
		bSQLError = True
		strErrorList = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	Else
		strFromEmail = objFromEmail.Value
		strProfileID = objProfileID.Value
	End If

	Set rsProfileInfo = Nothing
	Set cmdProfileInfo = Nothing
End If

Dim strPageHeader
strPageHeader = TXT_REACTIVATE_ACCOUNT
Call makePageHeader(strPageHeader, strPageHeader, True, True, True, True)

If bSQLError Then
	Call handleError(TXT_YOUR_PROFILE_COULD_NOT_BE_REACTIVATED & strErrorList, vbNullString, vbNullString)
ElseIf bValidationError Then
	Call handleError(TXT_THERE_WERE_VALIDIATION_ERRORS, vbNullString, vbNullString)
	%><ul><%=strErrorList%></ul>
<%
Else 'Success
	Dim strAccessURL, bEmailFailed, strExtraArgs
	strAccessURL = reReplace(Request.ServerVariables("PATH_INFO"),"(.*)\/" & ps_strThisPageFull,"$1",True,False,False,False)
	strAccessURL = Request.ServerVariables("HTTP_HOST") & strAccessURL

	Dim strEmailBody
	strEmailBody = "Hi," & vbCrLf & vbCrLf & _
		TXT_YOU_REQUESTED_REACTIVATION & IIf(g_bSSL, "https://", "http://") & strAccessURL & "/volunteer/" & vbCrLf & vbCrLf & _
		TXT_PLEASE_FOLLOW_LINK & " " & TXT_FINISH_REACTIVATING_ACCOUNT & vbCrLf & _
		IIf(g_bSSL, "https://", "http://") & strAccessURL & makeLink("/volunteer/profile/confirm.asp", "PID=" & Server.URLEncode(strProfileID) & "&CT=" & Server.URLEncode(strConfirmationToken) & "&ref=reactivate",vbNullString) & vbCrLf & vbCrLf & _
		TXT_LINK_EXPIRE_NOTICE
				
	bEmailFailed = sendEmail(False, strFromEmail, strEmail, TXT_EMAIL_REACTIVATE_SUBJECT, strEmailBody)

	Call handleMessage(TXT_SUCCESS_REACTIVATE, vbNullString, vbNullString, False)

	%><p><%= TXT_EMAIL_SENT %></p>
	<%

End If

Call makePageFooter(True)
%>


<!--#include file="../../includes/core/incClose.asp" -->


