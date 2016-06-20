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
g_bPageShouldUseSSL = True
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_VOL, DM_VOL, "../../", "volunteer/profile/", vbNullString)
%>
<!--#include file="../../includes/core/incCrypto.asp" -->
<!--#include file="../../includes/core/incSecurity.asp" -->
<!--#include file="../../includes/core/incHeader.asp" -->
<!--#include file="../../includes/core/incFooter.asp" -->
<!--#include file="../../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->
<!--#include file="../../text/txtUsers.asp" -->
<script language="python" runat="server">
from cioc.core.security import Crypt,MakeSalt
</script>
<%
If Not g_bUseVolunteerProfiles Then
	Call goToPageB(ps_strRootPath & "volunteer/")
ElseIf user_bLoggedIn Then
	Call goToPageB(ps_strRootPath & "volunteer/profile/loginconflict.asp")
End If

Dim strLoginName, _
	strLoginPwd, _
	strHashedPwd, _
	strLoginKey, _ 
	strRedirectPage, _
	strRedirectArgs, _
	strStartCulture, _
	bUseStartCulture, _
	bFailedLogin

strLoginName = Ns(LCase(Trim(Request.Form("LoginName"))))
strLoginPwd = Ns(Trim(Request.Form("LoginPwd")))
strRedirectPage = Ns(Trim(Request.Form("page")))
strRedirectArgs = Ns(Trim(Request.Form("args")))
bUseStartCulture = False
bFailedLogin = True
If Nl(strRedirectPage) Then
	strRedirectPage = "volunteer/profile/start.asp"
	strRedirectArgs = vbNullString
	bUseStartCulture = True
End If

Dim strCookieError
strCookieError = TXT_LOGIN_FAILED & TXT_COLON & TXT_CHECK_COOKIES

If Not (getSessionValue("session_test") = "ok") Then
	Call handleError(strCookieError, _
		"login.asp", vbNullString)
ElseIf Nl(strLoginName) Then
	Call handleError(TXT_LOGIN_FAILED & TXT_COLON & TXT_USER_NAME_REQUIRED,_
			"login.asp", vbNullString)
ElseIf Nl(strLoginPwd) Then
	Call handleError(TXT_LOGIN_FAILED & TXT_COLON & TXT_PASSWORD_REQUIRED,_
			"login.asp", vbNullString)
Else
	strLoginKey = LCase(getRandomString(32))
	
	Dim cmdLoginCheck, rsLoginCheck
	Set cmdLoginCheck = Server.CreateObject("ADODB.Command")
	With cmdLoginCheck
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "sp_VOL_Profile_LoginCheck"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 60, strLoginName)
	End With

	Dim strErrorMessage
	strErrorMessage = Replace(TXT_INVALID_USERNAME_PASSWORD, "[USER]", Request.Form("LoginName"))

	Dim intRepetitions, strHash, bUpdateHash
	bUpdateHash = False

	Set rsLoginCheck = cmdLoginCheck.Execute()
	With rsLoginCheck
		If Not .EOF Then
			strStartCulture = .Fields("StartCulture")
			If Not Nl(.Fields("Password")) Then
				bUpdateHash = True
				strHashedPwd = LCase(calcMD5Hash(strLoginPwd))
				If .Fields("Password") = strHashedPwd Then
					bFailedLogin = False
				End If
			Else
				strHash = Crypt(Trim(.Fields("PasswordHashSalt")), CStr(Request.Form("LoginPwd")), .Fields("PasswordHashRepeat"))
				If .Fields("PasswordHash") = strHash Then
					bFailedLogin = False
				End If
			End If

		End If

		If Not bFailedLogin Then
			If .Fields("Blocked") Then
				strErrorMessage = Replace(TXT_BLOCKED_USER, "[USER]", Server.HTMLEncode(Request.Form("LoginName")))
				bFailedLogin = True
			ElseIf Not .Fields("Active") Then
				strErrorMessage = Replace(TXT_INACTIVE_USER, "[USER]", Server.HTMLEncode(Request.Form("LoginName")))
				bFailedLogin = True
			End If
		End If


	End With
	Call rsLoginCheck.Close()
	Set rsLoginCheck = Nothing
	Set cmdLoginCheck = Nothing

	If Not bFailedLogin Then
		Dim strSalt, intHashRepeat
		strSalt = Null
		intHashRepeat = Null
		If bUpdateHash Then
			strSalt = MakeSalt()
			intHashRepeat = 10000
			strHash = Crypt(strSalt, strLoginPwd, intHashRepeat)
		Else
			strSalt = Null
		End If

		Dim cmdLoginCheckUpdate
		Set cmdLoginCheckUpdate = Server.CreateObject("ADODB.Command")
		With cmdLoginCheckUpdate
			.ActiveConnection = getCurrentVOLBasicCnn()
			.CommandText = "sp_VOL_Profile_u_Login"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 60, strLoginName)
			.Parameters.Append .CreateParameter("@LoginKey", adChar, adParamInput, 32, strLoginKey)
			.Parameters.Append .CreateParameter("@PasswordHash", adVarChar, adParamInput, 44, strHash)
			.Parameters.Append .CreateParameter("@PasswordHashSalt", adVarChar, adParamInput, 44, strSalt)
			.Parameters.Append .CreateParameter("@PasswordHashRepeat", adInteger, adParamInput, 4, intHashRepeat)
		End With

		cmdLoginCheckUpdate.Execute , , adExecuteNoRecords
			
		
		Dim strParamOverride
		strParamOverride = vbNullString
		If bUseStartCulture Then
			strRedirectArgs = StringIf(g_objCurrentLang.Culture<>strStartCulture, "Ln=" & strStartCulture)
			strParamOverride = StringIf(g_objCurrentLang.Culture<>strStartCulture, "Ln")
		End If
		Call setVProfileCookies(strLoginName, strLoginKey)
		Call goToPage(ps_strRootPath & strRedirectPage, strRedirectArgs, strParamOverride)

	Else
		Call clearVProfileCookies()
		Call handleError(TXT_LOGIN_FAILED & TXT_COLON & strErrorMessage, _
			"login.asp", _
			"page=" & Server.URLEncode(strRedirectPage) & "&args=" & Server.URLEncode(strRedirectArgs))
	End If
End If
%>


<!--#include file="../../includes/core/incClose.asp" -->


