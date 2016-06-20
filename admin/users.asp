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
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incAgencyList.asp" -->
<!--#include file="../includes/list/incUserTypeList.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtUsers.asp" -->
<%
If Not user_bCanManageUsers Then
	Call securityFailure()
End If

Call addScript(ps_strPathToStart & "scripts/formPrintMode.js", "text/javascript")

Call makePageHeader(TXT_MANAGE_USERS, TXT_MANAGE_USERS, True, True, True, True)

If Not g_bPrintMode Then
%>
<div class="AlertBubble">
	<ul>
		<li><%=TXT_CANT_EDIT_OWN_ACCOUNT_1%></li>
		<li><%=TXT_CANT_EDIT_OWN_ACCOUNT_2%></li>
<%
	If Not user_bSuperUser Or Not user_bSuperUserGlobal Then
%>
		<li><%=IIf(user_bSuperUser, TXT_CANT_EDIT_SUPERUSERGLOBAL, TXT_CANT_EDIT_SUPERUSER)%></li>
<%
	End If
%>
	</ul>
</div>
<%
End If

Dim bResults, _
	strUserName, _
	strAgency, _
	strFirstName, _
	strLastName, _
	strEmail, _
	bInactive, _
	bLocked, _
	intSLIDCIC, _
	intSLIDVOL
	
Dim	bShowName, _
	bShowInitials, _
	bShowEmail, _
	bShowAgency, _
	bShowUserType, _
	bShowView, _
	bShowSingleLogin, _
	bShowMyAccount, _
	bShowCreated, _
	bShowModifiedDate, _
	bShowPasswordDate, _
	bShowInactiveDate

If user_bSuperUser Then
	strAgency = Left(Trim(Request("Agency")),3)
End If

bResults = Request.ServerVariables("REQUEST_METHOD") = "POST" Or Not Nl(strAgency) Or g_bPrintMode

If bResults Then
	If Not user_bSuperUser Then
		strAgency = user_strAgency
	End If
	strUserName = Left(Trim(Request("UserName")),50)
	strFirstName = Left(Trim(Request("FirstName")),50)
	strLastName = Left(Trim(Request("LastName")),50)
	strEmail = Left(Trim(Request("Email")),60)
	
	bShowName = Request("Show_Name") = "on"
	bShowInitials = Request("Show_Initials") = "on"
	bShowEmail = Request("Show_Email") = "on"
	bShowAgency = Request("Show_Agency") = "on"
	bShowUserType = Request("Show_UserType") = "on"
	bShowView = Request("Show_View") = "on"
	bShowSingleLogin = Request("Show_SingleLogin") = "on"
	bShowMyAccount = Request("Show_MyAccount") = "on"
	bShowCreated = Request("Show_Created") = "on"
	bShowModifiedDate = Request("Show_ModifiedDate") = "on"
	bShowPasswordDate = Request("Show_PasswordDate") = "on"
	bShowInactiveDate = Request("Show_InactiveDate") = "on"

	bInactive = Null
	bLocked = Null

	Select Case Request("Status")
		Case "A"
			bInactive = SQL_FALSE
		Case "I"
			bInactive = SQL_TRUE
		Case "L"
			bLocked = SQL_TRUE
	End Select

	intSLIDCIC = Request("SLIDCIC")
	If Not IsIDType(intSLIDCIC) Then
		intSLIDCIC = Null
	End If
	intSLIDVOL = Request("SLIDVOL")
	If Not IsIDType(intSLIDVOL) Then
		intSLIDVOL = Null
	End If
End If

If Not g_bPrintMode Then
%>
<p>[ <a href="<%=makeLinkB("users_edit.asp")%>"><%=TXT_CREATE_USER%></a> | <a href="<%=makeLinkB("users_history.asp")%>"><%=TXT_USER_CHANGE_HISTORY%></a> ]</p>
<form action="users.asp" method="post" name="EntryForm" onSubmit="formPrintMode(this);">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox" colspan="4"><%=TXT_NEW_SEARCH%></th>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="UserName"><%=TXT_USER_NAME%></label></td><td<%If Not user_bSuperUser Then%> colspan="3"<%End If%>><input id="UserName" name="UserName" size="30" maxlength="50"></td>
<%
If user_bSuperUser Then
	Call openAgencyListRst(DM_GLOBAL,False,False)
%>
	<td class="FieldLabelLeft"><label for="Agency"><%=TXT_AGENCY%></label></td><td><%=makeAgencyList(vbNullString, "Agency", False, True)%></td>
<%
	Call closeAgencyListRst()
End If
%>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="FirstName"><%=TXT_FIRST_NAME%></label></td><td><input id="FirstName" name="FirstName" size="30" maxlength="50"></td>
	<td class="FieldLabelLeft"><label for="LastName"><%=TXT_LAST_NAME%></label></td><td><input id="LastName" name="LastName" size="30" maxlength="50"></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="Email"><%=TXT_EMAIL%></label></td><td colspan="3"><input id="Email" name="Email" size="60" maxlength="60"></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_STATUS%></td>
	<td colspan="3">
		<label><input type="radio" name="Status" value=""><%=TXT_ANY%></label>
		<label><input type="radio" name="Status" value="A" checked><%=TXT_ACTIVE%></label>
		<label><input type="radio" name="Status" value="I"><%=TXT_INACTIVE%></label>
		<%If g_intLoginRetryLimit Then%>
		<label><input type="radio" name="Status" value="L"><%=TXT_LOCKED_ACCOUNT%></label>
		<%End If%>
	</td>
</tr>
<%
	If user_bCanManageUsersCIC Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_USER_TYPE%> (<%=TXT_CIC%>)</td>
<%
	Call openUserTypeUserEditListRst(DM_CIC, user_strAgency, vbNullString)
%>
	<td colspan="3"><%=makeUserTypeList(vbNullString,"SLIDCIC",True,False)%></td>
<%
	Call closeUserTypeListRst()
%>
</tr>
<%
	End If
	If user_bCanManageUsersVOL Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_USER_TYPE%> (<%=TXT_VOLUNTEER%>)</td>
<%
	Call openUserTypeUserEditListRst(DM_VOL, user_strAgency, vbNullString)
%>
	<td colspan="3"><%=makeUserTypeList(vbNullString,"SLIDVOL",True,False)%></td>
<%
	Call closeUserTypeListRst()
%>
</tr>
<%
	End If
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SHOW_FIELDS%></td>
	<td colspan="3"><table class="NoBorder cell-padding-3">
		<tr>
			<td><label><input type="checkbox" name="Show_Name"<%=IIf(bResults,Checked(bShowName)," checked")%>><%=TXT_NAME%></label></td>
			<td><label><input type="checkbox" name="Show_Initials"<%=IIf(bResults,Checked(bShowInitials)," checked")%>><%=TXT_INITIALS%></label></td>
			<td><label><input type="checkbox" name="Show_Email"<%=IIf(bResults,Checked(bShowEmail)," checked")%>><%=TXT_EMAIL%></label></td>
		</tr>
		<tr>
			<td><label><input type="checkbox" name="Show_Agency"<%=IIf(bResults,Checked(bShowAgency)," checked")%>><%=TXT_AGENCY%></label></td>
			<td><label><input type="checkbox" name="Show_UserType"<%=IIf(bResults,Checked(bShowUserType)," checked")%>><%=TXT_USER_TYPE%></label></td>
			<td><label><input type="checkbox" name="Show_View"<%=Checked(bShowView)%>><%=TXT_VIEW%></label></td>
		</tr>
		<tr>
			<td><label><input type="checkbox" name="Show_SingleLogin"<%=Checked(bShowSingleLogin)%>><%=TXT_SINGLE_LOGIN%></label></td>
			<td><label><input type="checkbox" name="Show_MyAccount"<%=Checked(bShowMyAccount)%>><%=TXT_MY_ACCOUNT_ACCESS%></label></td>
			<td><label><input type="checkbox" name="Show_Created"<%=Checked(bShowCreated)%>><%=TXT_DATE_CREATED%></label></td>
		</tr>
		<tr>
			<td><label><input type="checkbox" name="Show_ModifiedDate"<%=Checked(bShowModifiedDate)%>><%=TXT_LAST_MODIFIED%></label></td>
			<td><label><input type="checkbox" name="Show_PasswordDate"<%=Checked(bShowPasswordDate)%>><%=TXT_PASSWORD_DATE%></label></td>
			<td><label><input type="checkbox" name="Show_InactiveDate"<%=Checked(bShowInactiveDate)%>><%=TXT_USER_INACTIVE_DATE%></label></td>
		</tr>
	</table></td>
</tr>
<tr>	
	<td class="FieldLabel"><%=TXT_PRINT_VERSION%></td>
	<td colspan="3"><label><input type="radio" name="PrintMd" value="on"><%=TXT_YES%></label>
	<label><input type="radio" name="PrintMd" value="" checked><%=TXT_NO%></label></td>
</tr>
<tr>
	<td colspan="4"><input type="submit" value="<%=TXT_SEARCH%>"> <input type="RESET" value="<%=TXT_CLEAR_FORM%>"></td>
</tr>
</table>
</form>
<%
End If

If bResults Then
	Dim cmdListEditUser, rsListEditUser
	
	Set cmdListEditUser = Server.CreateObject("ADODB.Command")
	With cmdListEditUser
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_Users_l_Edit"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@UserName", adVarChar, adParamInput, 50, strUserName)
		.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, strAgency)
		.Parameters.Append .CreateParameter("@FirstName", adVarChar, adParamInput, 50, strFirstName)
		.Parameters.Append .CreateParameter("@LastName", adVarChar, adParamInput, 50, strLastName)
		.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 50, strEmail)
		.Parameters.Append .CreateParameter("@Inactive", adBoolean, adParamInput, 1, bInactive)
		.Parameters.Append .CreateParameter("@Locked", adBoolean, adParamInput, 1, bLocked)
		.Parameters.Append .CreateParameter("@SL_ID_CIC", adInteger, adParamInput, 4, intSLIDCIC)
		.Parameters.Append .CreateParameter("@SL_ID_VOL", adInteger, adParamInput, 4, intSLIDVOL)
	End With
	Set rsListEditUser = Server.CreateObject("ADODB.Recordset")
	With rsListEditUser
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListEditUser
	End With

	With rsListEditUser
		If Not g_bPrintMode Or .RecordCount=0 Then
%>
<p><%=TXT_FOUND%><strong><%=.RecordCount%></strong><%=TXT_MATCHES%>.</p>
<p class="SmallNote"><%=TXT_INDICATES_INACTIVE_USER%>
<%
			If Not Nl(g_intLoginRetryLimit) Then
%>
<br><%=TXT_INDICATES_LOCKED_ACCOUNT%>
<%
			End If
%>
</p>
<%
		End If
		If .RecordCount > 0 Then
%>
<table class="BasicBorder cell-padding-2">
<tr>
	<th class="RevTitleBox"><%=IIf(g_bPrintMode,TXT_INACTIVE,"&nbsp;")%></th>
	<th class="RevTitleBox"><%=TXT_USER_NAME%></th>
<%If bShowAgency Then%>
	<th class="RevTitleBox"><%=TXT_AGENCY%></th>
<%End If%>
<%If bShowName Then%>
	<th class="RevTitleBox"><%=TXT_FIRST_NAME%></th>
	<th class="RevTitleBox"><%=TXT_LAST_NAME%></th>
<%End If%>
<%If bShowInitials Then%>
	<th class="RevTitleBox"><%=TXT_INITIALS%></th>
<%End If%>
<%If bShowEmail Then%>
	<th class="RevTitleBox"><%=TXT_EMAIL%></th>
<%End If%>
<%If user_bCanManageUsersCIC Then%>
<%	If bShowUserType Then%>
	<th class="RevTitleBox"><%=TXT_USER_TYPE%> (<%=TXT_CIC%>)</th>
<%	End If%>
<%	If bShowView Then%>
	<th class="RevTitleBox"><%=TXT_VIEW%> (<%=TXT_CIC%>)</th>
<%	End If%>
<%End If%>
<%If user_bCanManageUsersVOL Then%>
<%	If bShowUserType Then%>
	<th class="RevTitleBox"><%=TXT_USER_TYPE%> (<%=TXT_VOLUNTEER%>)</th>
<%	End If%>
<%	If bShowView Then%>
	<th class="RevTitleBox"><%=TXT_VIEW%> (<%=TXT_VOLUNTEER%>)</th>
<%	End If%>
<%End If%>
<%If bShowSingleLogin Then%>
	<th class="RevTitleBox"><%=TXT_SINGLE_LOGIN%></th>
<%End If%>
<%If bShowMyAccount Then%>
	<th class="RevTitleBox"><%=TXT_MY_ACCOUNT_ACCESS%></th>
<%End If%>
<%If bShowCreated Then%>
	<th class="RevTitleBox"><%=TXT_DATE_CREATED%></th>
<%End If%>
<%If bShowModifiedDate Then%>
	<th class="RevTitleBox"><%=TXT_LAST_MODIFIED%></th>
<%End If%>
<%If bShowPasswordDate Then%>
	<th class="RevTitleBox"><%=TXT_PASSWORD_DATE%></th>
<%End If%>
<%If bShowInactiveDate Then%>
	<th class="RevTitleBox"><%=TXT_USER_INACTIVE_DATE%></th>
<%End If%>
<%If Not g_bPrintMode Then%>
	<th class="RevTitleBox"><%=TXT_ACTION%></th>
<%End If%>
</tr>
<%
		End If

		Dim bLockedAccount

		While Not .EOF
			If Not Nl(g_intLoginRetryLimit) Then
				bLockedAccount = .Fields("LoginAttempts") >= g_intLoginRetryLimit
			Else
				bLockedAccount = False
			End If
%>
<tr>
	<td><%=IIf(.Fields("Inactive"),"<span class=""Alert"">" & IIf(g_bPrintMode,TXT_YES,"*") & "</span>",StringIf(Not bLockedAccount,"&nbsp;"))%>
	<%If Not g_bPrintMode And bLockedAccount Then%>
	<span class="Alert HighLight">X</span>
	<%End If%>
	</td>
	<td><%=.Fields("UserName")%></td>
<%If bShowAgency Then%>
	<td><%=.Fields("Agency")%></td>
<%End If%>
<%If bShowName Then%>
	<td><%=.Fields("FirstName")%></td>
	<td><%=.Fields("LastName")%></td>
<%End If%>
<%If bShowInitials Then%>
	<td><%=.Fields("Initials")%></td>
<%End If%>
<%If bShowEmail Then%>
	<td><%=.Fields("Email")%></td>
<%End If%>
<%If user_bCanManageUsersCIC Then%>
<%	If bShowUserType Then%>
	<td><%=.Fields("SecurityLevelCIC")%></td>
<%	End If%>
<%	If bShowView Then%>
	<td><%=Nz(.Fields("ViewNameCIC"),"<em>[" & TXT_DATABASE_DEFAULT & "]</em>")%></td>
<%	End If%>
<%End If%>
<%If user_bCanManageUsersVOL Then%>
<%	If bShowUserType Then%>
	<td><%=.Fields("SecurityLevelVOL")%></td>
<%	End If%>
<%	If bShowView Then%>
	<td><%=Nz(.Fields("ViewNameVOL"),"<em>[" & TXT_DATABASE_DEFAULT & "]</em>")%></td>
<%	End If%>
<%End If%>
<%If bShowSingleLogin Then%>
	<td><%=IIf(.Fields("SingleLogin"),TXT_YES,"&nbsp;")%></td>
<%End If%>
<%If bShowMyAccount Then%>
	<td><%
	If .Fields("CanUpdateAccount") Then
		Response.Write(TXT_NAME & "; " & TXT_INITIALS & "; " & TXT_EMAIL & StringIf(.Fields("CanUpdatePassword"),"; "))
	End If
	If .Fields("CanUpdatePassword") Then
		Response.Write(TXT_PASSWORD)
	End If
%></td>
<%End If%>
<%If bShowCreated Then%>
	<td><%=Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN)%></td>
<%End If%>
<%If bShowModifiedDate Then%>
	<td><%=Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN)%></td>
<%End If%>
<%If bShowPasswordDate Then%>
	<td><%=Nz(DateString(.Fields("PasswordChanged"),True),TXT_UNKNOWN)%></td>
<%End If%>
<%If bShowInactiveDate Then%>
	<td><%=IIf(.Fields("Inactive"),"<span class=""Alert"">" & TXT_INACTIVE & "</span>", "<strong>" & TXT_ACTIVE & "</strong>") & " - " & Nz(DateString(.Fields("ActiveStatusChanged"),True),TXT_UNKNOWN)%></td>
<%End If%>
<%If Not g_bPrintMode Then%>
	<td><%If .Fields("UserName")=user_strLogin Then%>&nbsp;<%Else%><a href="<%=makeLink("users_edit.asp","UserID=" & .Fields("User_ID"),vbNullString)%>"><%=TXT_UPDATE%></a> | <a href="<%=makeLink("userapicreds","User_ID=" & .Fields("User_ID"),vbNullString)%>"><%=TXT_API_KEYS%></a> | <a href="<%=makeLink("users_history.asp","UserName=" & Server.URLEncode(.Fields("UserName")), vbNullString) %>"><%= TXT_USER_CHANGE_HISTORY %></a><%End If%></td>
<%End If%>
</tr>
<%
			.MoveNext
		Wend
		If .RecordCount > 0 Then
%>
</table>
<%
		End If
	End With
	
	If rsListEditUser.State <> adStateClosed Then
		rsListEditUser.Close
	End If
	Set cmdListEditUser = Nothing
	Set rsListEditUser = Nothing
End If
%>

<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
