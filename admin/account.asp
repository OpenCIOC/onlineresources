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
' Purpose:		For user to edit their own account information
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
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtUsers.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incSysLanguageList.asp" -->
<%
Call makePageHeader(TXT_EDIT_ACCOUNT & user_strLogin, TXT_EDIT_ACCOUNT & user_strLogin, True, False, True, True)
%>

<%
Dim	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
	strFirstName, _
	strLastName, _
	strInitials, _
	strEmail, _
	intStartModule, _
	intStartLanguage, _
	bCanUpdateAccount, _
	bCanUpdatePassword, _
	strUpdateAccountEmail, _
	strUpdateAccountCulture, _
	dLastLogin, _
	strLastLoginIP

Dim cmdAccount, rsAccount
Set cmdAccount = Server.CreateObject("ADODB.Command")
With cmdAccount
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_Users_s_MyAccount"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
	Set rsAccount = .Execute
End With

With rsAccount
	If Not .EOF Then
		strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strFirstName = .Fields("FirstName")
		strLastName = .Fields("LastName")
		strInitials = .Fields("Initials")
		strEmail = .Fields("Email")
		intStartModule = .Fields("StartModule")
		intStartLanguage = .Fields("StartLanguage")
		bCanUpdateAccount = .Fields("CanUpdateAccount")
		bCanUpdatePassword = .Fields("CanUpdatePassword")
		strUpdateAccountEmail = .Fields("UpdateAccountEmail")
		strUpdateAccountCulture = .Fields("UpdateAccountCulture")
		strLastLoginIP = .Fields("LastSuccessfulLoginIP")
		dLastLogin = .Fields("LastSuccessfulLogin")
		If Nl(dLastLogin) Then
			dLastLogin = TXT_UNKNOWN
		Else
			dLastLogin = DateTimeString(dLastLogin,True)
		End If
	End If
	.Close
End With

Set rsAccount = Nothing
Set cmdAccount = Nothing
%>

<form action="account2.asp" method="post" class="form-horizontal">
<%=g_strCacheFormVals%>
<input type="hidden" name="UserID" value="<%=user_intID%>">
<input type="hidden" name="CanUpdateAccount" value="<%=StringIf(bCanUpdateAccount,"on")%>">
<input type="hidden" name="UpdateAccountEmail" value="<%=strUpdateAccountEmail%>">
<input type="hidden" name="UpdateAccountCulture" value="<%=strUpdateAccountCulture%>">
<table class="BasicBorder cell-padding-4 max-width-lg">
<tr>
	<th colspan="2" class="RevTitleBox"><%=IIf(bCanUpdateAccount,TXT_EDIT_LOGIN_INFO,TXT_REQUEST_ACCOUNT_CHANGE)%></th>
</tr>
<%If bCanUpdateAccount Then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_DATE_CREATED%></td>
	<td><%=strCreatedDate%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_CREATED_BY%></td>
	<td><%=strCreatedBy%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LAST_MODIFIED%></td>
	<td><%=strModifiedDate%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MODIFIED_BY%></td>
	<td><%=strModifiedBy%></td>
</tr>
<%End If%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LAST_LOGIN%></td>
	<td><%=dLastLogin & IIf(Not Nl(strLastLoginIP), " (" & strLastLoginIP & ")",vbNullString)%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_NAME%></td>
	<td>
		<div class="form-group row">
			<label for="FirstName" class="control-label col-sm-3"><%=TXT_FIRST_NAME%></label>
			<div class="col-sm-9">
				<input name="FirstName" type="text" id="FirstName" value=<%=AttrQs(strFirstName)%> maxlength="50" class="form-control">
			</div>
		</div>
		<div class="form-group row">
			<label for="LastName" class="control-label col-sm-3"><%=TXT_LAST_NAME%></label>
			<div class="col-sm-9">
				<input name="LastName" type="text" id="LastName" value=<%=AttrQs(strLastName)%> maxlength="50" class="form-control">
			</div>
		</div>
		<div class="form-group row">
			<label for="Initials" class="control-label col-sm-3"><%=TXT_INITIALS%></label>
			<div class="col-sm-9">
				<div class="form-inline"><input type="text" name="Initials" id="Initials" value=<%=AttrQs(strInitials)%> size="6" maxlength="6" class="form-control"></div>
			</div>
		</div>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="Email"><%=TXT_EMAIL%></label></td>
	<td><input name="Email" id="Email" type="text" maxlength="60" value=<%=AttrQs(strEmail)%> class="form-control"></td>
</tr>
<%If (g_bUseCIC And g_bUseVOL) Or g_bMultiLingualActive Then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_START_PAGE%></td>
	<td>
		<div class="form-inline">
			<%If (g_bUseCIC And g_bUseVOL) Then%>
			<select name="StartModule" class="form-control">
				<option value="<%=DM_CIC%>"<%=Selected(intStartModule=DM_CIC)%>><%=TXT_CIC%></option>
				<option value="<%=DM_VOL%>"<%=Selected(intStartModule=DM_VOL)%>><%=TXT_VOLUNTEER%></option>
			</select>
			<%End If%>
			<%If g_bMultiLingualActive Then
				Call openSysLanguageListRst(True)%>
				<%=makeSysLanguageList(intStartLanguage,"StartLanguage",False,vbNullString)%></td>
			<%	Call closeSysLanguageListRst()
			End If%>
		</div>
	</td>
</tr>
<%Else%>
<div style="display:none">
	<input type=hidden name="StartModule" value="<%=IIf(g_bUseVOL,2,1)%>" />
	<input type=hidden name="StartLangauge" value="<%=g_objCurrentLang.LangID%>" />
</div>
<%End If%>
<%
If bCanUpdateAccount <> bCanUpdatePassword Then
	If Not bCanUpdateAccount Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_NOTES%></td>
	<td><textarea name="Notes" rows="<%=TEXTAREA_ROWS_SHORT%>" class="form-control"></textarea></td>
</tr>
<%
	End If
%>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=IIf(bCanUpdateAccount,TXT_SUBMIT_UPDATES,TXT_SEND_REQUEST)%>" class="btn btn-default"> <input type="reset" value="<%=TXT_RESET_FORM%>" class="btn btn-default"></td>
</tr>
</table>
</form>
<br>
<form action="account2.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="UserID" value="<%=user_intID%>">
<input type="hidden" name="CanUpdateAccount" value="<%=StringIf(bCanUpdatePassword,"on")%>">
<input type="hidden" name="PasswordOnlyForm" value="on">
<input type="hidden" name="UpdateAccountEmail" value="<%=strUpdateAccountEmail%>">
<input type="hidden" name="UpdateAccountCulture" value="<%=strUpdateAccountCulture%>">
<table class="BasicBorder cell-padding-4 max-width-lg">
<tr>
	<th colspan="2" class="RevTitleBox"><%=IIf(bCanUpdatePassword,TXT_EDIT_LOGIN_INFO,TXT_REQUEST_ACCOUNT_CHANGE)%></th>
</tr>
<%
End If
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_CHANGE_PASSWORD%></td>
	<td>
<%
If bCanUpdatePassword Then
%>
		<%=TXT_INST_PASSWORD_1%>
		<br><%=TXT_INST_PASSWORD_2%>
		<br><%=TXT_INST_PASSWORD_3%>
		<div class="form-group row">
			<label for="OldPW" class="control-label col-sm-3"><%=TXT_OLD_PASSWORD%></label>
			<div class="col-sm-9">
				<input type="password" name="OldPW" id="OldPW" autocomplete="off" class="form-control">
			</div>
		</div>
		<div class="form-group row">
			<label for="NewPW" class="control-label col-sm-3"><%=TXT_NEW_PASSWORD%></label>
			<div class="col-sm-9">
				<input type="password" name="NewPW" id="NewPW" autocomplete="off" class="form-control">
			</div>
		</div>
		<div class="form-group row">
			<label for="CNewPW" class="control-label col-sm-3"><%=TXT_CONFIRM_PASSWORD%></label>
			<div class="col-sm-9">
				<input type="password" name="CNewPW" id="CNewPW" autocomplete="off" class="form-control">
			</div>
		</div>

<%
Else
%>
		<div class="checkbox">
			<label for="ChangePassword"><input type="checkbox" name="ChangePassword" id="ChangePassword"> <%=TXT_SEND_NEW_PASSWORD%></label>
		</div>
<%
End If
%>
	</td>
</tr>
<%
If Not bCanUpdatePassword Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_NOTES%></td>
	<td><textarea name="Notes" rows="<%=TEXTAREA_ROWS_SHORT%>" cols="<%=TEXTAREA_COLS%>" class="form-control"></textarea></td>
</tr>
<%
End If
%>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=IIf(bCanUpdatePassword,TXT_SUBMIT_UPDATES,TXT_SEND_REQUEST)%>" class="btn btn-default"> <input type="reset" value="<%=TXT_RESET_FORM%>" class="btn btn-default">
	<% If bCanUpdatePassword Then %>
		<a href="<%=makeLinkB("userapicreds")%>" class="btn btn-default"><%=TXT_API_KEYS%></a>
	<% End If %>
	</td>
</tr>
</table>
</form>

<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
