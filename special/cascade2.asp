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
<script language="python" runat="server">
from cioc.core.security import Crypt,MakeSalt
try:
	from cioc.core.security import needs_ssl_domains, render_ssl_domain_list
except ImportError:
	def needs_ssl_domains(request):
		return False
	
def l_needs_ssl_domains():
	return needs_ssl_domains(pyrequest)
</script>
<%
g_bPageShouldUseSSL = True
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_GLOBAL, DM_GLOBAL, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtUsers.asp" -->
<!--#include file="../includes/vprofile/incProfileSecurity.asp" -->
<%
' In order for IE to accept our login cookie in an IFrame, we need to set this header
' http://support.microsoft.com/default.aspx/kb/323752
Call Response.addHeader("P3P", "CP=""CAO PSA OUR""")

Dim strSrcDB, _
	strAction, _
	strLoginName, _
	strLoginPwd, _
	strRedirectTarget, _
	bFailedLogin

strSrcDB = Nz(Request.Form("srcdb"),vbNullString)
strAction = Nz(Request.Form("log_in_out"),vbNullString)
strLoginName = Nz(Request.Form("LoginName"),vbNullString)
strLoginPwd = Nz(Request.Form("LoginPwd"),vbNullString)
bFailedLogin = True

If l_needs_ssl_domains() Then
	strRedirectTarget = strSrcDB & "/special/cascade_failure.html"

ElseIf strAction = "Login" Then

	Dim cmdLoginCheck, rsLoginCheck
	Set cmdLoginCheck = Server.CreateObject("ADODB.Command")
	With cmdLoginCheck
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "sp_GBL_LoginCheck"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@UserName", adVarChar, adParamInput, 30, strLoginName)
		.Parameters.Append .CreateParameter("@IPAddress", adVarChar, adParamInput, 20, getRemoteIP())
	End With
	Set rsLoginCheck = cmdLoginCheck.Execute

	If Not rsLoginCheck.EOF Then
		Call BannedUserCallback(getRemoteIP())
	End If

	Set rsLoginCheck = rsLoginCheck.NextRecordset

	Dim strSingleLoginKey		
	strSingleLoginKey = Null

	With rsLoginCheck
		If Not .EOF Then
			Dim intRepetitions, strHash
			strHash = Crypt(Trim(.Fields("PasswordHashSalt")), CStr(Request.Form("LoginPwd")), .Fields("PasswordHashRepeat"))
			If strHash = .Fields("PasswordHash") Then
				If Not .Fields("Inactive") And (Nl(g_intLoginRetryLimit) Or .Fields("LoginAttempts") < g_intLoginRetryLimit) Then
					bFailedLogin = False
				End If
			End If
		End If

		If Not bFailedLogin Then
			If .Fields("SingleLogin") Then
				strSingleLoginKey = MakeSalt()
			End If
		End If
				
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

		If Not bFailedLogin Then
			Call clearVProfileCookies()

			Dim strUserUID, strIPAddress
			strUserUID = .Fields("UserUID").Value
			strIPAddress = getRemoteIP()

			Call do_login(strLoginName, strUserUID & strLoginName & strSingleLoginKey)
			strRedirectTarget = strSrcDB & "/special/cascade_success.html"
		Else
			strRedirectTarget = strSrcDB & "/special/cascade_failure.html"
		End If

		.Close
		Set rsLoginCheck = Nothing
	End With
Else
	' These cookies are not used anymore but clear them out anyway
	Response.Cookies(g_strDatabaseCode & "_Login") = " "
	Response.Cookies(g_strDatabaseCode & "_Login").Expires = Date() - 1
	Response.Cookies(g_strDatabaseCode & "_Key") = " "
	Response.Cookies(g_strDatabaseCode & "_Key").Expires = Date() - 1
	Call do_logout()
	strRedirectTarget = strSrcDB & "/special/cascade_success.html"
End If
Call run_response_callbacks()
%>
<html><head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<meta http-equiv="refresh" content="0;URL=<%=strRedirectTarget%>">
	<meta http-equiv="Pragma" content="no-cache">
	<meta name="ROBOTS" content="NOINDEX,FOLLOW">
</head><body></body></html>
<!--#include file="../includes/core/incClose.asp" -->
