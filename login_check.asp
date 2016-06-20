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
g_bPageShouldUseSSL = True
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_GLOBAL, DM_GLOBAL, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtUsers.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/core/incSendMail.asp" -->
<!--#include file="includes/validation/incPassSecure.asp" -->
<!--#include file="includes/vprofile/incProfileSecurity.asp" -->
<script language="python" runat="server">
from cioc.core.security import Crypt, MakeSalt
try:
	from cioc.core.security import needs_ssl_domains, render_ssl_domain_list
except ImportError:
	def needs_ssl_domains(request):
		return False
	
def l_needs_ssl_domains():
	return needs_ssl_domains(pyrequest)

def l_render_ssl_domain_list():
	return render_ssl_domain_list(pyrequest)
</script>
<%
If l_needs_ssl_domains() Then
	Call makePageHeader(TXT_DATABASE_LOGIN, TXT_DATABASE_LOGIN, True, False, True, True)
%>
	<p class="AlertBubble"><%= TXT_CANT_LOGIN_NON_SECURE_DOMAIN %></p>
	<p><%= TXT_SECURE_DOMAIN_LIST %></p>
	<%= l_render_ssl_domain_list() %>
<% 
	Call makePageFooter(True)
%>
	<!--#include file="includes/core/incClose.asp" -->
<%
	Response.End
End If

Dim strLoginName, _
	strLoginPwd, _
	bFailedLogin, _
	bLockedAccount, _
	intTriesLeft

strLoginName = Ns(Request.Form("LoginName"))
strLoginPwd = Ns(Request.Form("LoginPwd"))
bFailedLogin = True
bLockedAccount = False

If Len(strLoginName) > 30 Then
	Call securityFailure()
End If

Dim strCookieError
strCookieError = TXT_LOGIN_FAILED & TXT_COLON & TXT_CHECK_COOKIES

If Not (getSessionValue("session_test") = "ok") Then
	Call handleError(strCookieError, _
		"login.asp", vbNullString)
ElseIf Nl(Trim(Request.Form("LoginName"))) Then
	Call handleError(TXT_LOGIN_FAILED & TXT_COLON & TXT_USER_NAME_REQUIRED,_
			"login.asp", vbNullString)
ElseIf Nl(Trim(Request.Form("LoginPwd"))) Then
	Call handleError(TXT_LOGIN_FAILED & TXT_COLON & TXT_PASSWORD_REQUIRED,_
			"login.asp", vbNullString)
Else
	Dim cmdLoginCheck, rsLoginCheck
	Set cmdLoginCheck = Server.CreateObject("ADODB.Command")
	With cmdLoginCheck
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "sp_GBL_LoginCheck"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@UserName", adVarChar, adParamInput, 50, strLoginName)
		.Parameters.Append .CreateParameter("@IPAddress", adVarChar, adParamInput, 20, getRemoteIP())
	End With
	Set rsLoginCheck = cmdLoginCheck.Execute

	If Not rsLoginCheck.EOF Then
		Call BannedUserCallback(getRemoteIP())
	End If

	Set rsLoginCheck = rsLoginCheck.NextRecordset

	Dim strErrorMessage
	strErrorMessage = Replace(TXT_INVALID_USERNAME_PASSWORD, "[USER]", Request.Form("LoginName"))

	Dim strSingleLoginKey		
	strSingleLoginKey = Null

	With rsLoginCheck
			
		If Not .EOF Then
			If Not Nl(g_intLoginRetryLimit) And (.Fields("LoginAttempts") >= g_intLoginRetryLimit) Then
				strErrorMessage = TXT_ACCOUNT_IS_LOCKED
				bLockedAccount = True
			Else
				Dim intRepetitions, strHash
				strHash = Crypt(Trim(.Fields("PasswordHashSalt")), CStr(Request.Form("LoginPwd")), .Fields("PasswordHashRepeat"))

				If strHash = .Fields("PasswordHash") Then
					If .Fields("Inactive") Then
						strErrorMessage = Replace(TXT_INACTIVE_USER, "[USER]", Server.HTMLEncode(Request.Form("LoginName")))
					Else
						bFailedLogin = False
					End If
				ElseIf Not Nl(g_intLoginRetryLimit) Then
					intTriesLeft = g_intLoginRetryLimit - (.Fields("LoginAttempts") + 1)
					If intTriesLeft <= 0 Then
						intTriesLeft = Null
						strErrorMessage = TXT_ACCOUNT_IS_LOCKED

						If Not (Nl(.Fields("AgencyEmail")) And Nl(.Fields("Email"))) Then
							Dim strTo, strFrom, strMessage, strAgencyEmail, strUserEmail
							strAgencyEmail = .Fields("AgencyEmail")
							strUserEmail = .Fields("Email")
							If strAgencyEmail = strUserEmail Then
								strUserEmail = Null
							End If
							strFrom = Nz(strAgencyEmail,strUserEmail)
							strTo = Nz(strAgencyEmail,vbNullString) & StringIf(Not Nl(strAgencyEmail) And Not Nl(strUserEmail),",") & Nz(strUserEmail,vbNullString)
							strMessage = TXT_USER_NAME & TXT_COLON & strLoginName & vbCrLf & vbCrLf & _
								TXT_ACCOUNT_IS_LOCKED & vbCrLf & vbCrLf & _
								TXT_LAST_ATTEMPT & DateTimeString(Now(),True) & " (" & getRemoteIP() & IIf(g_bSSL,") https://", ") http://") & Request.ServerVariables("SERVER_NAME") & "/login.asp" & vbCrLf & vbCrLf & _
								TXT_REPEATED_ATTEMPTS_BLOCKS_IP
							Call sendEmail(True, strFrom, strTo, Null, TXT_LOCKED_ACCOUNT, strMessage)
						End If
					End If 
				End If
			End If
		End If

		If Not bFailedLogin Then
			If .Fields("SingleLogin") Then
				strSingleLoginKey = MakeSalt()
			End If
		End If

		If Not bLockedAccount Then
			Dim cnnLoginCheckUpdate
			Call makeNewAdminConnection(cnnLoginCheckUpdate)

			Dim cmdLoginCheckUpdate
			Set cmdLoginCheckUpdate = Server.CreateObject("ADODB.Command")
			With cmdLoginCheckUpdate
				.ActiveConnection = cnnLoginCheckUpdate
				.CommandText = "sp_GBL_Users_u_Login"
				.CommandType = adCmdStoredProc
				.CommandTimeout = 0
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				.Parameters.Append .CreateParameter("@UserName", adVarChar, adParamInput, 30, strLoginName)
				.Parameters.Append .CreateParameter("@Success", adBoolean, adParamInput, 1, IIf(bFailedLogin,SQL_FALSE,SQL_TRUE))
				.Parameters.Append .CreateParameter("@IPAddress", adVarChar, adParamInput, 20, getRemoteIP())
				.Parameters.Append .CreateParameter("@SingleLoginKey", adChar, adParamInput, 44, strSingleLoginKey)
			End With

			cmdLoginCheckUpdate.Execute , , adExecuteNoRecords
		End If

		If Not bFailedLogin Then
			Call clearVProfileCookies()
			Dim strUserUID
			strUserUID = .Fields("UserUID").Value

			Call do_login(strLoginName, strUserUID & strLoginName & strSingleLoginKey)

			If IsSecurePassword(strLoginPwd) Then
				
				Call goToPage( _
					ps_strPathToStart & StringIf(.Fields("StartModule") = DM_VOL,"volunteer/"), _
					StringIf(g_objCurrentLang.Culture<>.Fields("StartCulture"),"Ln=" & .Fields("StartCulture")), _
					StringIf(g_objCurrentLang.Culture<>.Fields("StartCulture"),"Ln") _
					)
			Else
				Call handleError(TXT_PASSWORD_NOT_SECURE & "<br>" & TXT_INST_PASSWORD_2, ps_strPathToStart & "admin/account.asp", vbNullString)
			End If

			%><!--#include file="includes/core/incClose.asp" --><%
			Response.End()
		Else
			Response.Cookies(g_strDatabaseCode & "_Login") = " "
			Response.Cookies(g_strDatabaseCode & "_Login").Expires = Date() - 1
			Response.Cookies(g_strDatabaseCode & "_Key") = " "
			Response.Cookies(g_strDatabaseCode & "_Key").Expires = Date() - 1
			Call handleError(TXT_LOGIN_FAILED & TXT_COLON & strErrorMessage, _
				"login.asp", _
				"TriesLeft=" & intTriesLeft)
		End If
	End With
End If
%>
<!--#include file="includes/core/incClose.asp" -->
