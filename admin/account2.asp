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
'
' Purpose:		Process user account updates
'
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
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../text/txtUsers.asp" -->
<!--#include file="../includes/core/incSendMail.asp" -->
<!--#include file="../includes/validation/incPassSecure.asp" -->
<script language="python" runat="server">
from cioc.core.security import Crypt,MakeSalt
</script>
<%
Dim	intUserID, _
	bCanUpdateAccount, _
	bPasswordOnlyForm, _
	strFirstName, _
	strLastName, _
	strInitials, _
	strEmail, _
	intStartModule, _
	intStartLanguage, _
	strOldPW, _
	strNewPW, _
	strCNewPW, _
	bChangePassword, _
	strUpdateAccountEmail, _
	strUpdateAccountCulture, _
	strNotes

bCanUpdateAccount = Request("CanUpdateAccount")="on"
bPasswordOnlyForm = Request("PasswordOnlyForm")="on"

If Not bPasswordOnlyForm Then
	strFirstName = Trim(Request("FirstName"))
	strLastName = Trim(Request("LastName"))
	strInitials = Trim(Request("Initials"))
	strEmail = Trim(Request("Email"))

	intStartModule = Request("StartModule")
	If Not IsPosSmallInt(intStartModule) Then
		intStartModule = Null
	Else
		intStartModule = CInt(intStartModule)
	End If
	If intStartModule<>DM_CIC And intStartModule<>DM_VOL Then
		insStartModule = Null
	End If

	intStartLanguage = Request("StartLanguage")
	If Not IsLangID(intStartLanguage) Then
		insStartLanguage = Null
	End If
Else
	strFirstName = user_strUserFirstName
	strLastName = user_strUserLastName
	strInitials = user_strInitials
	strEmail = user_strEmail
	intStartModule = Null
	intStartLanguage = Null
End If

If bCanUpdateAccount Then
	Dim strSalt, strHash, intHashRepeat
	strSalt = Null
	strHash = Null
	intHashRepeat = Null

	strOldPW = Request("OldPW")
	strNewPW = Request("NewPW")
	strCNewPW = Request("CNewPW")

	Dim intDefaultStartModule
	intDefaultStartModule = Null
	If Not Nl(Trim(strNewPW)) Then
		Dim cmdLoginCheck, rsLoginCheck
		Set cmdLoginCheck = Server.CreateObject("ADODB.Command")
		With cmdLoginCheck
			.ActiveConnection = getCurrentBasicCnn()
			.CommandText = "sp_GBL_LoginCheck"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@UserName", adVarChar, adParamInput, 50, user_strLogin)
			.Parameters.Append .CreateParameter("@IPAddress", adVarChar, adParamInput, 20, getRemoteIP())
		End With
		Set rsLoginCheck = cmdLoginCheck.Execute

		If Not rsLoginCheck.EOF Then
			Call BannedUserCallback(getRemoteIP())
		End If

		Set rsLoginCheck = rsLoginCheck.NextRecordset

		Dim bFailedLogin, bLockedAccount, strSingleLoginKey, intTriesLeft
		strSingleLoginKey = Null
		bLockedAccount = False
		bFailedLogin = True
		With rsLoginCheck

			If Not .EOF Then
				strHash = Crypt(Trim(rsLoginCheck("PasswordHashSalt")), strOldPW, rsLoginCheck("PasswordHashRepeat"))
				strSingleLoginKey = .Fields("SingleLoginKey")
				If Not Nl(g_intLoginRetryLimit) And .Fields("LoginAttempts") >= g_intLoginRetryLimit Then
					bLockedAccount = True
				Else
					If strHash = .Fields("PasswordHash") Then
							bFailedLogin = False
					ElseIf Not Nl(g_intLoginRetryLimit) Then
						intTriesLeft = g_intLoginRetryLimit - (.Fields("LoginAttempts") + 1)
						If intTriesLeft <= 0 Then
							intTriesLeft = Null

							If Not (Nl(.Fields("AgencyEmail")) And Nl(.Fields("Email"))) Then
								Dim strTo, strFrom, strEmailMessage, strAgencyEmail, strUserEmail
								strAgencyEmail = .Fields("AgencyEmail")
								strUserEmail = .Fields("Email")
								If strAgencyEmail = strUserEmail Then
									strUserEmail = Null
								End If
								strFrom = Nz(strAgencyEmail,strUserEmail)
								strTo = Nz(strAgencyEmail,vbNullString) & StringIf(Not Nl(strAgencyEmail) And Not Nl(strUserEmail),",") & Nz(strUserEmail,vbNullString)
								strEmailMessage = TXT_USER_NAME & TXT_COLON & user_strLogin & vbCrLf & vbCrLf & _
									TXT_ACCOUNT_IS_LOCKED & vbCrLf & vbCrLf & _
									TXT_LAST_ATTEMPT & DateTimeString(Now(),True) & " (" & getRemoteIP() & ") https://" & Request.ServerVariables("SERVER_NAME") & vbCrLf & vbCrLf & _
									TXT_REPEATED_ATTEMPTS_BLOCKS_IP
								Call sendEmail(True, strFrom, strTo, TXT_LOCKED_ACCOUNT, strEmailMessage)
							End If
						End If
					End If
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
					.Parameters.Append .CreateParameter("@UserName", adVarChar, adParamInput, 30, user_strLogin)
					.Parameters.Append .CreateParameter("@Success", adBoolean, adParamInput, 1, IIf(bFailedLogin,SQL_FALSE,SQL_TRUE))
					.Parameters.Append .CreateParameter("@IPAddress", adVarChar, adParamInput, 20, getRemoteIP())
					.Parameters.Append .CreateParameter("@SingleLoginKey", adChar, adParamInput, 44, strSingleLoginKey)
				End With

				cmdLoginCheckUpdate.Execute , , adExecuteNoRecords
			End If
		End With

		If bLockedAccount Then
			Call makePageHeader(TXT_UPDATE_ACCOUNT_FAILED, TXT_UPDATE_ACCOUNT_FAILED, True, False, True, True)
			Call handleError(TXT_ACCOUNT_NOT_UPDATED & TXT_ACCOUNT_IS_LOCKED, _
				vbNullString, _
				vbNullString)
			Call makePageFooter(False)
			%><!--#include file="../includes/core/incClose.asp" --><%
			Response.End()
		ElseIf bFailedLogin Then
			Call makePageHeader(TXT_UPDATE_ACCOUNT_FAILED, TXT_UPDATE_ACCOUNT_FAILED, True, False, True, True)
			Call handleError(TXT_ACCOUNT_NOT_UPDATED & TXT_INVALID_OLD_PASSWORD, _
				vbNullString, _
				vbNullString)
			Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
			Call makePageFooter(False)
			%><!--#include file="../includes/core/incClose.asp" --><%
			Response.End()
		End If

		If strNewPW <> strCNewPW Then
			Call makePageHeader(TXT_UPDATE_ACCOUNT_FAILED, TXT_UPDATE_ACCOUNT_FAILED, True, False, True, True)
			Call handleError(TXT_ACCOUNT_NOT_UPDATED & TXT_PASSWORDS_MUST_MATCH, _
				vbNullString, _
				vbNullString)
			Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
			Call makePageFooter(False)
			%><!--#include file="../includes/core/incClose.asp" --><%
			Response.End()
		End If
		intDefaultStartModule = rsLoginCheck("StartModule")

		strSalt = MakeSalt()
		intHashRepeat = 500000
		strHash = Crypt(strSalt, strNewPW, intHashRepeat)
	End If

	If Nl(intStartModule) Then
		intStartModule = Nz(intDefaultStartModule, IIf(g_bUseCIC, DM_CIC, DM_VOL))
	End If
	If Not g_bMultiLingualActive Then
		intStartLanguage = g_objCurrentLang.LangID
	End If

	Dim objReturn, objErrMsg

	Dim cmdUpdateAccount, rsUpdateAccount
	Set cmdUpdateAccount = Server.CreateObject("ADODB.Command")
	With cmdUpdateAccount
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_Users_u_MyAccount"
		.CommandType = adCmdStoredProc
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@FirstName", adVarChar, adParamInput, 50, strFirstName)
		.Parameters.Append .CreateParameter("@LastName", adVarChar, adParamInput, 50, strLastName)
		.Parameters.Append .CreateParameter("@Initials", adVarChar, adParamInput, 6, strInitials)
		.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 100, strEmail)
		.Parameters.Append .CreateParameter("@StartModule", adInteger, adParamInput, 1, intStartModule)
		.Parameters.Append .CreateParameter("@StartLanguage", adInteger, adParamInput, 2, intStartLanguage)
		.Parameters.Append .CreateParameter("@PasswordHash", adVarChar, adParamInput, 44, strHash)
		.Parameters.Append .CreateParameter("@PasswordHashSalt", adVarChar, adParamInput, 44, strSalt)
		.Parameters.Append .CreateParameter("@PasswordHashRepeat", adInteger, adParamInput, 4, intHashRepeat)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
		.CommandTimeout = 0
	End With

	Set rsUpdateAccount = cmdUpdateAccount.Execute
	Set rsUpdateAccount = rsUpdateAccount.NextRecordset

	Select Case objReturn.Value
		Case 0
			If Nl(objErrMsg.Value) Then
				Call handleMessage(TXT_ACCOUNT_UPDATED, _
					ps_strRootPath & "admin/account.asp", _
					vbNullString, _
					False)
			Else
				Call handleMessage(TXT_ACCOUNT_UPDATED & "</p><p class=""Alert"">" & TXT_WARNING & Server.HTMLEncode(objErrMsg.Value) & "</p>", _
					ps_strRootPath & "admin/account.asp", _
					vbNullString, _
					False)
			End If
		Case Else
			Call makePageHeader(TXT_UPDATE_ACCOUNT_FAILED, TXT_UPDATE_ACCOUNT_FAILED, True, False, True, True)
			Call handleError(TXT_ACCOUNT_NOT_UPDATED & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
				vbNullString, _
				vbNullString)
			Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
			Call makePageFooter(False)
	End Select
Else
	If Not bPasswordOnlyForm Then
		strFirstName = StringIf(strFirstName <> user_strUserFirstName,strFirstName)
		strLastName = StringIf(strLastName <> user_strUserLastName,strLastName)
		strInitials = StringIf(strInitials <> user_strInitials,strInitials)
		strEmail = StringIf(strEmail <> user_strEmail,strEmail)
	End If

	bChangePassword = Request("ChangePassword")="on"
	strNotes = Trim(Request("Notes"))
	strUpdateAccountEmail = Nz(Request("UpdateAccountEmail"),IIf(user_bCIC Or Not user_bVOL,Nz(g_strDefaultEmailCIC,g_strDefaultEmailVOL),Nz(g_strDefaultEmailVOL,g_strDefaultEmailCIC)))
	strUpdateAccountCulture = Nz(Request("UpdateAccountCulture"),g_objCurrentLang.Culture)
	If Not IsCulture(strUpdateAccountCulture) Then
		strUpdateAccountCulture = g_objCurrentLang.Culture
	End If

	Dim strRestoreCulture
	strRestoreCulture = g_objCurrentLang.Culture
	Call setSessionLanguage(strUpdateAccountCulture)

	Dim strMessage
	strMessage = TXT_USER_REQUEST_1 & user_strLogin & TXT_USER_REQUEST_2 & vbCrLf & vbCrLf

	If Not bPasswordOnlyForm Then
		If Not Nl(strFirstName) Then
			strMessage = strMessage & TXT_FIRST_NAME & TXT_COLON & strFirstName & vbCrLf
		End If
		If Not Nl(strLastName) Then
			strMessage = strMessage & TXT_LAST_NAME & TXT_COLON & strLastName & vbCrLf
		End If
		If Not Nl(strInitials) Then
			strMessage = strMessage & TXT_INITIALS & TXT_COLON & strInitials & vbCrLf
		End If
		If Not Nl(strEmail) Then
			strMessage = strMessage & TXT_EMAIL & TXT_COLON & strEmail & vbCrLf
		End If
	End If

	If bChangePassword Then
		strMessage = strMessage & TXT_CHANGE_PASSWORD & TXT_COLON & TXT_SEND_NEW_PASSWORD & vbCrLf
	End If
	If Not Nl(strNotes) Then
		strMessage = strMessage & TXT_NOTES & TXT_COLON & strNotes & vbCrLf
	End If

	strMessage = strMessage & vbCrLf & _
		" * * * * * * " & vbCrLf & vbCrLf & _
		TXT_THIS_USERS_ACCOUNT_INFO & vbCrLf & vbCrLf & _
		TXT_FIRST_NAME & TXT_COLON & Nz(user_strUserFirstName,TXT_UNKNOWN) & vbCrLf & _
		TXT_LAST_NAME & TXT_COLON & Nz(user_strUserLastName,TXT_UNKNOWN) & vbCrLf & _
		TXT_INITIALS & TXT_COLON & Nz(user_strInitials,TXT_UNKNOWN) & vbCrLf & _
		TXT_EMAIL & TXT_COLON & Nz(user_strEmail,TXT_UNKNOWN) & vbCrLf & vbCrLf & _
		TXT_LOGIN_TO_DATABASE & "https://" & IIf(user_bCIC Or Not user_bVOL,g_strBaseURLCIC,g_strBaseURLVOL) & "/login.asp"

	Call setSessionLanguage(strRestoreCulture)

	Call makePageHeader(TXT_EDIT_ACCOUNT & user_strLogin, TXT_EDIT_ACCOUNT & user_strLogin, True, False, True, True)

	If Not Nl(strUpdateAccountEmail) Then
		If (bPasswordOnlyForm Or (Nl(strFirstName) And Nl(strLastName) And Nl(strInitials) And Nl(strEmail) And Nl(strNotes))) And Not bChangePassword Then
%>
<p class="Alert"><%=TXT_UNABLE_TO_SEND_REQUEST & " " & TXT_NO_CHANGES%></p>
<%
		Else
			If sendEmail(True, strUpdateAccountEmail, Nz(strEmail,user_strEmail), _
				TXT_REQUEST_ACCOUNT_CHANGE_FOR & IIf(user_bCIC Or Not user_bVOL,Nz(g_strDatabaseNameCIC,g_strDatabaseNameVOL),Nz(g_strDatabaseNameVOL,g_strDatabaseNameCIC)), _
				strMessage) Then
%>
<p class="Info"><%=TXT_REQUEST_SENT%></p>
<%
			Else
%>
<p class="Alert"><%=TXT_UNABLE_TO_SEND_REQUEST%></p>
<%
			End If
		End If
	Else
%>
<p class="Alert"><%=TXT_UNABLE_TO_SEND_REQUEST%></p>
<%
	End If
	Call makePageFooter(False)
End If

%>
<!--#include file="../includes/core/incClose.asp" -->
