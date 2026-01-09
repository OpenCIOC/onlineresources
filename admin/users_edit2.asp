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
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtUsers.asp" -->
<!--#include file="../includes/validation/incPassSecure.asp" -->
<script language="python" runat="server">
from cioc.core.security import Crypt,MakeSalt
</script>
<%
'On Error Resume Next

If Not user_bCanManageUsers Then
	Call securityFailure()
End If

Dim bNew
bNew = False

Dim	intUserID, _
	strLogin, _
	strFirstName, _
	strLastName, _
	strInitials, _
	strEmail, _
	strAgency, _
	intSLIDCIC, _
	intSLIDVOL, _
	intStartModule, _
	intStartLanguage, _
	strHash, _
	strSalt, _
	intHashRepeat, _
	bSingleLogin, _
	bCanUpdateAccount, _
	bCanUpdatePassword, _
	bInactive, _
	bUnlockAccount, _
	intSavedSearchQuota, _
	strNewPW, _
	strCNewPW

intUserID = Request.Form("UserID")
If Nl(intUserID) Then
	intUserID = Null
	intSLIDCIC = Null
	intSLIDVOL = Null
	bInactive = False
	bUnlockAccount = False
	bNew = True
	strAgency = user_strAgency
ElseIf Not IsIDType(intUserID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intUserID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_USER, _
		"users.asp", vbNullString)
Else
	intUserID = CLng(intUserID)
End If

bInactive = CbToSQLBool("Inactive")
bUnlockAccount = CbToSQLBool("UnlockAccount")
strAgency = Nz(Request("Agency"), user_strAgency)

intSLIDCIC = Request("SLIDCIC")
If Nl(intSLIDCIC) Then
	intSLIDCIC = Null
End If
intSLIDVOL = Request("SLIDVOL")
If Nl(intSLIDVOL) Then
	intSLIDVOL = Null
End If

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
	intStartLanguage = Null
End If

strLogin = Trim(Request("UserName"))
strFirstName = Trim(Request("FirstName"))
strLastName = Trim(Request("LastName"))
strInitials = Trim(Request("Initials"))
strEmail = Trim(Request("Email"))
bSingleLogin = Request.Form("SingleLogin") = "on"
bCanUpdateAccount = Request.Form("CanUpdateAccount") = "on"
bCanUpdatePassword = Request.Form("CanUpdatePassword") = "on"
strNewPW = Request.Form("NewPW")
strCNewPW = Request.Form("CNewPW")
strHash = Null
strSalt = Null
intHashRepeat = Null

If Nl(intUserID) And Nl(Trim(strNewPW)) Then
	Call makePageHeader(TXT_UPDATE_ACCOUNT_FAILED, TXT_UPDATE_ACCOUNT_FAILED, True, False, True, True)
	Call handleError(TXT_ACCOUNT_NOT_UPDATED & TXT_PASSWORD_REQUIRED, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
	%><!--#include file="../includes/core/incClose.asp" --><%
	Response.End()
End If

If Not Nl(Trim(strNewPW)) And strNewPW <> strCNewPW Then
	Call makePageHeader(TXT_UPDATE_ACCOUNT_FAILED, TXT_UPDATE_ACCOUNT_FAILED, True, False, True, True)
	Call handleError(TXT_ACCOUNT_NOT_UPDATED & TXT_PASSWORDS_MUST_MATCH, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
	%><!--#include file="../includes/core/incClose.asp" --><%
	Response.End()
End If

If Not Nl(Trim(strNewPW)) Then
	strSalt = MakeSalt()
	intHashRepeat = 10000
	strHash = Crypt(strSalt, strNewPW, intHashRepeat)
End If

intSavedSearchQuota = Trim(Request("SavedSearchQuota"))
If Not IsNumeric(intSavedSearchQuota) Or Nl(intSavedSearchQuota) Then
	intSavedSearchQuota = 0
Else
	intSavedSearchQuota = CInt(intSavedSearchQuota)
End If
If intSavedSearchQuota < 0 Then
	intSavedSearchQuota = 0
ElseIf intSavedSearchQuota > MAX_TINY_INT Then
	intSavedSearchQuota = MAX_TINY_INT
End If

Dim objReturn, objErrMsg
Dim cmdUpdateAccount, rsUpdateAccount
Set cmdUpdateAccount = Server.CreateObject("ADODB.Command")
With cmdUpdateAccount
 	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_Users_uf"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInputOutput, 4, intUserID)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@Inactive", adBoolean, adParamInput, 1, bInactive)
	.Parameters.Append .CreateParameter("@UnlockAccount", adBoolean, adParamInput, 1, bUnlockAccount)
	.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, strAgency)
	.Parameters.Append .CreateParameter("@SL_ID_CIC", adInteger, adParamInput, 4, intSLIDCIC)
	.Parameters.Append .CreateParameter("@SL_ID_VOL", adInteger, adParamInput, 4, intSLIDVOL)
	.Parameters.Append .CreateParameter("@StartModule", adInteger, adParamInput, 1, intStartModule)
	.Parameters.Append .CreateParameter("@StartLanguage", adInteger, adParamInput, 2, intStartLanguage)
	.Parameters.Append .CreateParameter("@UserName", adVarChar, adParamInput, 50, strLogin)
	.Parameters.Append .CreateParameter("@FirstName", adVarChar, adParamInput, 50, strFirstName)
	.Parameters.Append .CreateParameter("@LastName", adVarChar, adParamInput, 50, strLastName)
	.Parameters.Append .CreateParameter("@Initials", adVarChar, adParamInput, 6, strInitials)
	.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 100, strEmail)
	.Parameters.Append .CreateParameter("@SavedSearchQuota", adInteger, adParamInput, 4, intSavedSearchQuota)
	.Parameters.Append .CreateParameter("@PasswordHash", adVarChar, adParamInput, 44, strHash)
	.Parameters.Append .CreateParameter("@PasswordHashSalt", adVarChar, adParamInput, 44, strSalt)
	.Parameters.Append .CreateParameter("@PasswordHashRepeat", adInteger, adParamInput, 4, intHashRepeat)
	.Parameters.Append .CreateParameter("@SingleLogin", adBoolean, adParamInput, 1, IIf(bSingleLogin,SQL_TRUE,SQL_FALSE))
	.Parameters.Append .CreateParameter("@CanUpdateAccount", adBoolean, adParamInput, 1, IIf(bCanUpdateAccount,SQL_TRUE,SQL_FALSE))
	.Parameters.Append .CreateParameter("@CanUpdatePassword", adBoolean, adParamInput, 1, IIf(bCanUpdatePassword,SQL_TRUE,SQL_FALSE))
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With

Set rsUpdateAccount = cmdUpdateAccount.Execute
Set rsUpdateAccount = rsUpdateAccount.NextRecordset

Dim bInsecurePW, _
	strErrMsg

bInsecurePW = Not Nl(strNewPW) And Not IsSecurePassword(strNewPW)
If Not Nl(objErrMsg.Value) Then
	strErrMsg = Server.HTMLEncode(objErrMsg.Value)
Else
	strErrMsg = vbNullString
End If

Select Case objReturn.Value
	Case 0
		If bNew Then
			intUserID = cmdUpdateAccount.Parameters("@User_ID").Value
		End If
		If Not bInsecurePW And Nl(objErrMsg.Value) Then
			Call handleMessage(TXT_ACCOUNT_UPDATED, _
				"users_edit.asp", _
				"UserID=" & intUserID, _
				False)
		Else
			Call handleMessage(TXT_ACCOUNT_UPDATED & _
					StringIf(bInsecurePW,"</p><p class=""Alert"">" & TXT_WARNING & TXT_PASSWORD_NOT_SECURE & "<br>" & TXT_INST_PASSWORD_2) & _
					StringIf(Not Nl(strErrMsg),"</p><p class=""Alert"">" & TXT_WARNING & strErrMsg), _
				"users_edit.asp", _
				"UserID=" & intUserID, _
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
%>
<!--#include file="../includes/core/incClose.asp" -->
