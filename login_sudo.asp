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
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_GLOBAL, DM_GLOBAL, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtUsers.asp" -->
<!--#include file="includes/validation/incPassSecure.asp" -->
<!--#include file="includes/vprofile/incProfileSecurity.asp" -->
<script language="python" runat="server">
from cioc.core.security import MakeSalt
</script>
<%
Dim strLoginName, _
	bFailedLogin

strLoginName = Ns(Request("LoginName"))
bFailedLogin = True

If Len(strLoginName) > 30 Or Not user_bSuperUserCIC Or (g_bUseVOL And Not user_bSuperUserVOL) Then
	Call securityFailure()
End If

If Nl(Trim(Request("LoginName"))) Then
	Call handleError(TXT_LOGIN_FAILED & TXT_COLON & TXT_USER_NAME_REQUIRED,_
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
		.Parameters.Append .CreateParameter("@UserName", adVarChar, adParamInput, 30, strLoginName)
		.Parameters.Append .CreateParameter("@IPAddress", adVarChar, adParamInput, 20, getRemoteIP())
	End With
	Set rsLoginCheck = cmdLoginCheck.Execute

	If Not rsLoginCheck.EOF Then
		Call BannedUserCallback(getRemoteIP())
	End If

	Set rsLoginCheck = rsLoginCheck.NextRecordset

	Dim strErrorMessage
	strErrorMessage = Replace(TXT_INVALID_USERNAME_PASSWORD, "[USER]", Server.HTMLEncode(Request("LoginName")))

	Dim strSingleLoginKey
	strSingleLoginKey = Null

	With rsLoginCheck

		If Not .EOF Then
			If Not .Fields("Inactive") Then
				bFailedLogin = False
			Else
				strErrorMessage = Replace(TXT_INACTIVE_USER, "[USER]", Server.HTMLEncode(Request("LoginName")))
			End If
		End If

		If Not bFailedLogin Then
			If .Fields("SingleLogin") Then
				strSingleLoginKey = MakeSalt()
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

			Call clearVProfileSession()
			Dim strUserUID
			strUserUID = .Fields("UserUID").Value

			Call do_login(strLoginName, strUserUID & strLoginName & strSingleLoginKey)

			Call goToPage( _
				ps_strPathToStart & StringIf(.Fields("StartModule") = DM_VOL,"volunteer/"), _
				StringIf(g_objCurrentLang.Culture<>.Fields("StartCulture"),"Ln=" & .Fields("StartCulture")), _
				StringIf(g_objCurrentLang.Culture<>.Fields("StartCulture"),"Ln") _
				)

			%><!--#include file="includes/core/incClose.asp" --><%
			Response.End()
		Else
			Call handleError(TXT_LOGIN_FAILED & TXT_COLON & strErrorMessage, _
				"login.asp", _
				vbNullString)
		End If
	End With
End If
%>
<!--#include file="includes/core/incClose.asp" -->
