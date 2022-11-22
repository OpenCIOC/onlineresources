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
<!--#include file="../../text/txtCommonForm.asp" -->
<!--#include file="../../text/txtEntryForm.asp" -->
<!--#include file="../../text/txtFormDataCheck.asp" -->
<!--#include file="../../text/txtUsers.asp" -->
<!--#include file="../../text/txtVOLProfile.asp" -->
<!--#include file="../../includes/core/incFormat.asp" -->
<!--#include file="../../includes/core/incSendMail.asp" -->
<!--#include file="../../includes/validation/incFormDataCheck.asp" -->
<!--#include file="../../includes/validation/incPassSecure.asp" -->
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->
<script language="python" runat="server">
from cioc.core.security import Crypt,MakeSalt
</script>

<%
If Not g_bUseVolunteerProfiles Then
	Call goToPageB(ps_strPathToStart & "volunteer/")
End If

Dim	bNew, _
	bValidationError,_
	bSQLError, _
	strErrorList, _
	strEmail, _
	strConfirmationToken, _
	bEmailNew, _
	strFirstName, _
	strLastName, _
	strAddress, _
	strCity, _
	strProvince, _
	strPostalCode, _
	strPhone, _
	strCurPW, _
	strNewPW, _
	strCNewPW, _
	bOrgCanContact, _
	bAgreedToPrivacyPolicy, _
	intLangID, _
	intReturn

intReturn = -1

bNew = Not vprofile_bLoggedIn
bValidationError = False
bSQLError = False
strErrorList = vbNullString
strEmail = Trim(Request("Email"))
strFirstName = Trim(Request("FirstName"))
strLastName = Trim(Request("LastName"))
strAddress = Trim(Request("Address"))
strCity = Trim(Request("City"))
strProvince = Trim(Request("Province"))
strPostalCode = Trim(Request("PostalCode"))
strPhone = Trim(Request("Phone"))
strCurPW = Trim(Request("CurPW"))
strNewPW = Trim(Request("NewPW"))
strCNewPW = Trim(Request("CNewPW"))
bOrgCanContact = Request("OrgCanContact") = "on"
bAgreedToPrivacyPolicy = Request("AgreedToPrivacyPolicy") = "on"
intLangID = Trim(Request("LangID"))

If bNew Or strEmail <> vprofile_strEmail Then
	bEmailNew = True
	If Nl(strEmail) Then
		Call checkAddValidationError(TXT_EMAIL_REQUIRED)
	Else
		Call checkOneEmail(TXT_EMAIL_ADDRESS, strEmail)
	End If
	strConfirmationToken = LCase(getRandomString(32))
Else
	strEmail = Null
	bEmailNew = False
	strConfirmationToken = Null
End If

If bNew Or Not Nl(strNewPW) Then
	If Not bNew And Nl(strCurPW) Then
		Call checkAddValidationError(TXT_CURRENT_PASSWORD_REQUIRED)
	End If
	If bNew And Nl(strNewPW) Then
		Call checkAddValidationError(TXT_PASSWORD_REQUIRED_VP)
	ElseIf strNewPW <> strCNewPW Then
		Call checkAddValidationError(IIf(bNew, vbNullString, TXT_NEW_VP & " ") & TXT_PASSWORDS_MUST_MATCH_VP)
	ElseIf Not IsSecurePassword(strNewPW) Then
		Call checkAddValidationError(IIf(bNew, vbNullString, TXT_NEW_VP & " ") & TXT_PASSWORD_NOT_SECURE_VP & " " & TXT_INST_PASSWORD_2)
	End If
End If

If Nl(strFirstName) Then
	Call checkAddValidationError(TXT_FIRST_NAME_REQUIRED)
Else
	Call checkLength(TXT_FIRST_NAME, strFirstName, 50)
End If

If Nl(strLastName) Then
	Call checkAddValidationError(TXT_LAST_NAME_REQUIRED)
Else
	Call checkLength(TXT_LAST_NAME, strLastName, 50)
End If

If Nl(strAddress) Then
	strAddress = Null
Else
	Call checkLength(TXT_ADDRESS, strAddress, 150)
End If

If Nl(strCity) Then
	strCity = Null
Else
	Call checkLength(TXT_CITY, strCity, 100)
End If

If Nl(strProvince) Then
	strProvince = Null
Else
	Call checkLength(TXT_PROVINCE, strProvince, 2)
End If

If Nl(strPostalCode) Then
	strPostalCode = Null
Else
	Call checkPostalCode(TXT_POSTAL_CODE, strPostalCode)
End If

If Nl(strPhone) Then
	strPhone = Null
Else
	Call checkLength(TXT_PHONE, strPhone, 100)
End If

If bNew Then
	intLangID = g_objCurrentLang.LangID
ElseIf Not g_bMultiLingualActive Then
	intLangID = Null
Else
	If Nl(intLangID) Then
		intLangID = Null
	ElseIf Not IsLangID(intLangID) Then
		intLangID = Null
	Else
		intLangID = CInt(intLangID)
	End If
End If

Dim strHash, intHashRepeat, strSalt
If Nl(strErrorList) And Not bNew And Not Nl(strCurPW) Then
	Dim cmdLoginCheck, rsLoginCheck
	Set cmdLoginCheck = Server.CreateObject("ADODB.Command")
	With cmdLoginCheck
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "sp_VOL_Profile_LoginCheck"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 100, vprofile_strEmail)
	End With


	Set rsLoginCheck = cmdLoginCheck.Execute()
	With rsLoginCheck
		If Not .EOF Then
			strHash = Crypt(Trim(.Fields("PasswordHashSalt")), CStr(strCurPW), .Fields("PasswordHashRepeat"))
			If .Fields("PasswordHash") <> strHash Then
				Call checkAddValidationError(TXT_INVALID_OLD_PASSWORD)
			End If
		End If
	End With
	rsLoginCheck.Close()
	Set rsLoginCheck = Nothing
	Set cmdLoginCheck = Nothing
End If

If Not Nl(strErrorList) Then
	bValidationError = True
Else
	Dim strFromEmail, strProfileID
	strHash = Null
	intHashRepeat = Null
	strSalt = Null

	If Not Nl(strNewPW) Then
		strSalt = MakeSalt()
		intHashRepeat = 10000
		strHash = Crypt(strSalt, strNewPW, intHashRepeat)
	End If
	
	Dim objReturn, objErrMsg, objProfileID, objFromEmail
	Dim cmdProfileInfo, rsProfileInfo
	Set cmdProfileInfo = Server.CreateObject("ADODB.Command")
	With cmdProfileInfo
		.ActiveConnection = getCurrentVOLBasicCnn()
		If bNew Then
			.CommandText = "sp_VOL_Profile_i_Basic"
		Else
			.CommandText = "sp_VOL_Profile_u_Basic"
		End If
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		If bNew Then
			Set objProfileID = .CreateParameter("@ProfileID", adGUID, adParamOutput, 16)
		Else
			Set objProfileID = .CreateParameter("@ProfileID", adGUID, adParamInput, 16, vprofile_strID)
		End If
		.Parameters.Append objProfileID
		.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 100, strEmail)
		.Parameters.Append .CreateParameter("@PasswordHash", adVarChar, adParamInput, 44, strHash)
		.Parameters.Append .CreateParameter("@PasswordHashSalt", adVarChar, adParamInput, 44, strSalt)
		.Parameters.Append .CreateParameter("@PasswordHashRepeat", adInteger, adParamInput, 4, intHashRepeat)
		.Parameters.Append .CreateParameter("@FirstName", adVarWChar, adParamInput, 50, strFirstName)
		.Parameters.Append .CreateParameter("@LastName", adVarWChar, adParamInput, 50, strLastName)
		.Parameters.Append .CreateParameter("@Phone", adVarWChar, adParamInput, 100, strPhone)
		.Parameters.Append .CreateParameter("@Address", adVarWChar, adParamInput, 150, strAddress)
		.Parameters.Append .CreateParameter("@City", adVarWChar, adParamInput, 100, strCity)
		.Parameters.Append .CreateParameter("@Province", adVarChar, adParamInput, 2, strProvince)
		.Parameters.Append .CreateParameter("@PostalCode", adVarChar, adParamInput, 20, strPostalCode)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 4, intLangID)
		.Parameters.Append .CreateParameter("@OrgCanContact", adBoolean, adParamInput, 1, IIf(bOrgCanContact,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@AgreedToPrivacyPolicy", adBoolean, adParamInput, 1, IIf(bAgreedToPrivacyPolicy,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@ConfirmationToken", adChar, adParamInput, 32, strConfirmationToken)
		Set objFromEmail = .CreateParameter("@FromEmail", adVarChar, adParamOutput, 100)
		.Parameters.Append objFromEmail
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsProfileInfo = cmdProfileInfo.Execute()
	If rsProfileInfo.State <> 0 Then
		rsProfileInfo.Close()
	End If

	intReturn = objReturn.Value

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
If bSQLError Or bValidationError Or bEmailNew Or bNew Then
	Dim strPageHeader
	If bNew Then
		strPageHeader = TXT_CREATE_VOL_PROFILE
	Else
		strPageHeader = TXT_UPDATE_VOL_PROFILE_INFO
	End If
	Call makePageHeader(strPageHeader, strPageHeader, True, True, True, True)

Else
	Call handleMessage(TXT_YOUR_PERSONAL_INFORMATION_WAS_SUCCESSFULLY_UPDATED, "start.asp", "ShowTab=Personal", False)
End If

If bSQLError Then
	Call handleError(IIf(bNew, TXT_YOUR_PROFILE_COULD_NOT_BE_CREATED, TXT_ERROR_UPDATING_PROFILE) & " " & strErrorList, vbNullString, vbNullString)
	If intReturn = 20 Then
	%>
	<p><%= TXT_WOULD_YOU_LIKE_TO_REACTIVATE %></p>
	<form method="post" action="reactivate.asp">
	<input type="hidden" name="Email" value="<%=strEmail%>">
	<input class="btn btn-default" type="submit" name="Reactivate" value="Reactivate">
	</form>
	<%
	End If
ElseIf bValidationError Then
	Call handleError(TXT_THERE_WERE_VALIDIATION_ERRORS, vbNullString, vbNullString)
	%><ul><%=strErrorList%></ul>
	<p><%=TXT_USE_BACK_BUTTON%></p><%
ElseIf bEmailNew Or bNew Then
	Dim strAccessURL, bEmailFailed, strExtraArgs
	strAccessURL = reReplace(Request.ServerVariables("PATH_INFO"),"(.*)\/" & ps_strThisPageFull,"$1",True,False,False,False)
	strAccessURL = Request.ServerVariables("HTTP_HOST") & strAccessURL

	If bNew Then
		strExtraArgs = "&page=" & Server.URLEncode(Trim(Ns(Request("page")))) & "&args=" & Server.URLEncode(Trim(Ns(Request("args"))))
	Else
		strExtraArgs = vbNullString
	End If

	Dim strEmailBody
	strEmailBody = TXT_HI & " " & strFirstName & "," & vbCrLf & vbCrLf & _
		IIf(bNew, TXT_YOU_SIGNED_UP_FOR, TXT_YOU_SUBMITTED_EMAIL_CHANGE) & _
		" " & "https://" & strAccessURL & "/volunteer/" & vbCrLf & vbCrLf & _
		TXT_PLEASE_FOLLOW_LINK & " " & _
		IIf(bNew, TXT_FINISH_CREATING_ACCOUNT, TXT_CONFIRM_EMAIL_ADDRESS) & vbCrLf & _
		"https://" & strAccessURL & makeLink("/volunteer/profile/confirm.asp", "PID=" & Server.URLEncode(strProfileID) & "&CT=" & Server.URLEncode(strConfirmationToken) & strExtraArgs,vbNullString) & vbCrLf & vbCrLf & _
		TXT_LINK_EXPIRE_NOTICE
				
	bEmailFailed = sendEmail(False, strFromEmail, strEmail, TXT_EMAIL_SUBJECT, strEmailBody)

	Call handleMessage(IIf(bNew, TXT_SUCCESS_CREATE, TXT_SUCCESS_UPDATE), vbNullString, vbNullString, False)

	%><p><%= TXT_EMAIL_SENT %></p>
	<%If Not bNew Then%>
	<p><a href="<%=makeLink("start.asp", "Show=Personal", vbNullString)%>"><%= TXT_RETURN_TO_PROFILE_PAGE %></a></p><%
	End If

End If
If bSQLError Or bValidationError Or bEmailNew Or bNew Then
	Call makePageFooter(True)
End If
%>


<!--#include file="../../includes/core/incClose.asp" -->


