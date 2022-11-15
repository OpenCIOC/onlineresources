<%@  language="VBSCRIPT" %>
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
<!--#include file="../../text/txtFormDataCheck.asp" -->
<!--#include file="../../text/txtUsers.asp" -->
<!--#include file="../../text/txtVOLProfile.asp" -->
<!--#include file="../../text/txtVolunteer.asp" -->
<!--#include file="../../includes/core/incFormat.asp" -->
<!--#include file="../../includes/core/incSendMail.asp" -->
<!--#include file="../../includes/validation/incFormDataCheck.asp" -->
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->
<script language="python" runat="server">
from cioc.core.security import Crypt,MakeSalt
</script>
<%
If Not g_bUseVolunteerProfiles Then
	Call goToPageB(ps_strPathToStart & "volunteer/")
End If

Dim	bValidationError,_
	bSQLError, _
	strErrorList, _
	strEmail, _
	strNewPW

bValidationError = False
bSQLError = False
strErrorList = vbNullString
strEmail = Trim(Request("LoginName"))

Dim strAccessURL
strAccessURL = reReplace(Request.ServerVariables("PATH_INFO"),"(.*)\/profile/" & ps_strThisPage,"$1",True,False,False,False)
strAccessURL = Request.ServerVariables("HTTP_HOST") & strAccessURL & "/"

If Nl(strEmail) Then
	Call checkAddValidationError(TXT_EMAIL_REQUIRED)
Else
	Call checkOneEmail(TXT_EMAIL_ADDRESS, strEmail)
End If

strNewPW = getRandomPassword(10)

If Not Nl(strErrorList) Then
	bValidationError = True
Else
	Dim strHash, intHashRepeat, strSalt, strFromEmail
	strSalt = MakeSalt()
	intHashRepeat = 10000
	strHash = Crypt(strSalt, strNewPW, intHashRepeat)
	
	Dim objReturn, objErrMsg, objFromEmail
	Dim cmdProfileInfo, rsProfileInfo
	Set cmdProfileInfo = Server.CreateObject("ADODB.Command")
	With cmdProfileInfo
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "sp_VOL_Profile_u_PWReset"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 100, strEmail)
		.Parameters.Append .CreateParameter("@PasswordHash", adVarChar, adParamInput, 44, strHash)
		.Parameters.Append .CreateParameter("@PasswordHashSalt", adVarChar, adParamInput, 44, strSalt)
		.Parameters.Append .CreateParameter("@PasswordHashRepeat", adInteger, adParamInput, 4, intHashRepeat)
		Set objFromEmail = .CreateParameter("@FromEmail", adVarChar, adParamOutput, 100)
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
	End If
	Set rsProfileInfo = Nothing
	Set cmdProfileInfo = Nothing
End If

Dim strPageHeader
strPageHeader = TXT_VOL_PROFILE_PASSWORD_RESET
Call makePageHeader(strPageHeader, strPageHeader, True, True, True, True)

If bSQLError Then
	Call handleError(TXT_YOUR_PASSWORD_COULD_NOT_BE_RESET & " " & strErrorList, vbNullString, vbNullString)
ElseIf bValidationError Then
	Call handleError(TXT_THERE_WERE_VALIDIATION_ERRORS, vbNullString, vbNullString)
%><ul><%=strErrorList%></ul>
<p><%=TXT_USE_BACK_BUTTON%></p>
<%
Else
	Dim bEmailFailed, strExtraArgs

	strExtraArgs = "&page=" & Server.URLEncode(Trim(Ns(Request("page")))) & "&args=" & Server.URLEncode(Trim(Ns(Request("args"))))

	bEmailFailed = sendEmail(False, strFromEmail, strEmail, TXT_VOL_PROFILE_PASSWORD_RESET, _
		TXT_YOU_REQUESTED_PW_RESET & " " & "https://" & strAccessURL & vbCrLf & vbCrLf & _
		TXT_YOUR_NEW_PASSWORD_IS & " " & strNewPW)

	Call handleMessage(TXT_YOUR_PASSWORD_IS_RESET, vbNullString, vbNullString, False)

%>
<p><%= TXT_YOU_HAVE_BEEN_SENT_PASSWORD %></p>
<form method="post" action="login.asp?<%=strExtraArgs%>">
    <%=g_strCacheFormVals%>
    <input class="btn btn-default" type="submit" value="<%=TXT_LOGIN_NOW%>">
</form>
<%
End If

Call makePageFooter(True)
%>


<!--#include file="../../includes/core/incClose.asp" -->


