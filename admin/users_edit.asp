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
g_bPageShouldUseSSL = True
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
<!--#include file="../includes/list/incAgencyList.asp" -->
<!--#include file="../includes/list/incUserTypeList.asp" -->
<!--#include file="../includes/list/incSysLanguageList.asp" -->
<%
If Not user_bCanManageUsers Then
	Call securityFailure()
End If

Call EnsureSSL()

Dim bNew
bNew = False

Dim	intUserID, _
	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
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
	intSavedSearchQuota, _
	bSingleLogin, _
	bCanUpdateAccount, _
	bCanUpdatePassword, _
	bInactive, _
	bTechAdmin, _
	dLastLogin, _
	strLastLoginIP, _
	intLoginAttempts, _
	dLastLoginTry, _
	strLastLoginTryIP

intUserID = Request("UserID")
If Nl(intUserID) Then
	intUserID = Null
	intSLIDCIC = Null
	intSLIDVOL = Null
	bInactive = False
	bNew = True
	strAgency = user_strAgency
ElseIf Not IsIDType(intUserID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intUserID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_USER, _
		"users.asp", vbNullString)
Else
	intUserID = CLng(intUserID)
End If

If Not bNew Then
	Dim cmdAccount, rsAccount
	Set cmdAccount = Server.CreateObject("ADODB.Command")
	With cmdAccount
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_Users_sf"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append .CreateParameter("@EditUser_ID", adInteger, adParamInput, 4, intUserID)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		Set rsAccount = .Execute
	End With

	With rsAccount
		If Not .EOF Then
			strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strLogin = .Fields("UserName")
			strFirstName = .Fields("FirstName")
			strLastName = .Fields("LastName")
			strInitials = .Fields("Initials")
			strEmail = .Fields("Email")
			strAgency = .Fields("Agency")
			intSLIDCIC = .Fields("SL_ID_CIC")
			intSLIDVOL = .Fields("SL_ID_VOL")
			intStartModule = .Fields("StartModule")
			intStartLanguage = .Fields("StartLanguage")
			intSavedSearchQuota = .Fields("SavedSearchQuota")
			bSingleLogin = .Fields("SingleLogin")
			bCanUpdateAccount = .Fields("CanUpdateAccount")
			bCanUpdatePassword = .Fields("CanUpdatePassword")
			bInactive = .Fields("Inactive")
			bTechAdmin = .Fields("TechAdmin")
			strLastLoginIP = .Fields("LastSuccessfulLoginIP")
			dLastLogin = .Fields("LastSuccessfulLogin")
			If Nl(dLastLogin) Then
				dLastLogin = TXT_UNKNOWN
			Else
				dLastLogin = DateTimeString(dLastLogin,True)
			End If
			intLoginAttempts = Nz(.Fields("LoginAttempts"),0)
			If intLoginAttempts > 0 Then
				dLastLoginTry = .Fields("LastLoginAttempt")
				If Nl(dLastLoginTry) Then
					dLastLoginTry = TXT_UNKNOWN
				Else
					dLastLoginTry = DateTimeString(dLastLoginTry,True)
				End If
				strLastLoginTryIP = .Fields("LastLoginAttemptIP")
			End If
		Else
			intUserID = Null
		End If
	End With

	Set rsAccount = Nothing
	Set cmdAccount = Nothing
End If

If bNew Then
	Call makePageHeader(TXT_CREATE_ACCOUNT, TXT_CREATE_ACCOUNT, True, False, True, True)
	If Not user_bCanManageUsers Then
		Call securityFailure()
	End If
Else
	Call makePageHeader(TXT_EDIT_ACCOUNT & strLogin, TXT_EDIT_ACCOUNT & strLogin, True, False, True, True)
End If

%>
<p>[
<a href="<%=makeLinkB("users.asp")%>"><%=TXT_RETURN_EDIT_USERS%></a> 
<%If Not bNew Then%>
| <a href="<%=makeLink("userapicreds","User_ID=" & intUserID,vbNullString)%>"><%=TXT_API_KEYS%></a>
| <a href="<%=makeLink("users_history.asp","PrintMd=on&UserName=" & strLogin,vbNullString)%>" target="_blank"><%=TXT_USER_CHANGE_HISTORY & " - <em>" & strLogin & "</em> " & TXT_NEW_WINDOW %></a>
<%End If%>
]</p>
<form action="users_edit2.asp" method="post" id="EntryForm">
<%=g_strCacheFormVals%>
<input type="hidden" name="UserID" value="<%=intUserID%>">
<table class="BasicBorder cell-padding-4">
<tr>
	<th colspan="2" class="RevTitleBox"><%=TXT_EDIT_ACCOUNT%> <%=IIf(bNew,TXT_NEW_USER,strLogin)%></th>
</tr>
<%
If Not bNew Then
%>
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
<tr>
	<td class="FieldLabelLeft"><%=TXT_LAST_LOGIN%></td>
	<td><%=dLastLogin & IIf(Not Nl(strLastLoginIP), " (" & strLastLoginIP & ")",vbNullString)%>
		<%If Nl(g_intLoginRetryLimit) And intLoginAttempts > 0 Then%>
		<br><span class="Alert"><%=TXT_LAST_ATTEMPT%><%=dLastLoginTry & IIf(Not Nl(strLastLoginTryIP), " (" & strLastLoginTryIP & ")",vbNullString) & ", " & intLoginAttempts & " " & TXT_TRIES%></span>
		<%End If%>
	</td>
</tr>
<%
If intLoginAttempts >= g_intLoginRetryLimit Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LOCKED_ACCOUNT%></td>
	<td><input type="checkbox" name="UnlockAccount" checked> <%=TXT_UNLOCK_THIS_ACCOUNT%>
	<br><span class="Alert"><%=TXT_ACCOUNT_IS_LOCKED%></span>
	<br><%=TXT_LAST_ATTEMPT%><%=dLastLoginTry & IIf(Not Nl(strLastLoginTryIP), " (" & strLastLoginTryIP & ")",vbNullString)%></td>
</tr>
<%
End If
%>
<%
End If
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_STATUS%></td>
	<td><label><input type="checkbox" name="Inactive"<%If bInactive Then%> checked<%End If%>><%=TXT_USER_IS_INACTIVE%></label>
	<% If bTechAdmin Then %>
	<br><br><%= TXT_USER_IS_TECH_ADMIN %>
	<% End If %>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_AGENCY%> <span class="Alert">*</span></td>
<%
If user_bSuperUser Then
	Call openAgencyListRst(DM_GLOBAL, False, True)%>
		<td><%=makeAgencyList(strAgency, "Agency", True, False)%></td>
<%
	Call closeAgencyListRst()
Else
%>
	<td><input type="hidden" name="Agency" value="<%=strAgency%>"><%=strAgency%></td>
<%
End If
%>
</tr>
<%
	If g_bUseCIC Then
		If user_bCanManageUsersCIC Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_USER_TYPE%> (<%=TXT_CIC%>)</td>
<%
	Call openUserTypeUserEditListRst(DM_CIC, user_strAgency, intSLIDCIC)
%>
	<td><%=makeUserTypeList(intSLIDCIC,"SLIDCIC",True,False)%></td>
<%
	Call closeUserTypeListRst()
%>
</tr>
<%
		Else
%>
<input type="hidden" name="SLIDCIC" value="<%=intSLIDCIC%>">
<%
		End If
	End If
	If g_bUseVOL Then
		If user_bCanManageUsersVOL Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_USER_TYPE%> (<%=TXT_VOLUNTEER%>)</td>
<%
	Call openUserTypeUserEditListRst(DM_VOL, user_strAgency, intSLIDVOL)
%>
	<td><%=makeUserTypeList(intSLIDVOL,"SLIDVOL",True,False)%></td>
<%
	Call closeUserTypeListRst()
%>
</tr>
<%
		Else
%>
<input type="hidden" name="SLIDVOL" value="<%=intSLIDVOL%>">
<%
		End If
	End If
%>
<%If (g_bUseCIC And g_bUseVOL) Or g_bMultiLingualActive Then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_START_PAGE%> <span class="Alert">*</span></td>
	<td>
	<%If (g_bUseCIC And g_bUseVOL) Then%>
		<select name="StartModule">
			<option value="<%=DM_CIC%>"<%=Selected(intStartModule=DM_CIC)%>><%=TXT_CIC%></option>
			<option value="<%=DM_VOL%>"<%=Selected(intStartModule=DM_VOL)%>><%=TXT_VOLUNTEER%></option>
		</select>
	<%Else%>
	<div style="display:none">
		<input type=hidden name="StartModule" value="<%=IIf(g_bUseVOL,2,1)%>" />
	</div>
	<%End If%>
	<%If g_bMultiLingualActive Then
		Call openSysLanguageListRst(True)%>
		<%=makeSysLanguageList(intStartLanguage,"StartLanguage",False,vbNullString)%>
	<%	Call closeSysLanguageListRst()%>
	<%Else%>
	<div style="display:none">
		<input type=hidden name="StartLangauge" value="<%=g_objCurrentLang.LangID%>" />
	</div>
	<%End If%>
	</td>
</tr>
<%Else%>
<div style="display:none">
	<input type=hidden name="StartModule" value="<%=IIf(g_bUseVOL,2,1)%>" />
	<input type=hidden name="StartLangauge" value="<%=g_objCurrentLang.LangID%>" />
</div>
<%End If%>
<tr>
	<td class="FieldLabelLeft"><label for="UserName"><%=TXT_USER_NAME%></label> <span class="Alert">*</span></td>
	<td><input type="text" name="UserName" id="UserName" value=<%=AttrQs(strLogin)%> size="30" maxlength="50" autocomplete="off"></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_NAME%> <span class="Alert">*</span></td>
	<td><table class="NoBorder cell-padding-2">
		<tr>
			<td class="FieldLabelClr"><label for="FirstName"><%=TXT_FIRST_NAME%></label></td>
			<td><input name="FirstName" type="text" id="FirstName" value=<%=AttrQs(strFirstName)%> size="30" maxlength="50" autocomplete="off"> 
			</td>
		</tr>
		<tr>
			<td class="FieldLabelClr"><label for="LastName"><%=TXT_LAST_NAME%></label></td>
			<td><input name="LastName" type="text" id="LastName" value=<%=AttrQs(strLastName)%> size="30" maxlength="50" autocomplete="off"> 
			</td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td class="FieldLabelClr"><label for="Initials"><%=TXT_INITIALS%></label></td>
			<td><input type="text" name="Initials" id="Initials" value=<%=AttrQs(strInitials)%> size="6" maxlength="6" autocomplete="off"></td>
		</tr>
	</table></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="Email"><%=TXT_EMAIL%></label> <span class="Alert">*</span></td>
	<td><input name="Email" id="Email" type="text" size="50" maxlength="60" value=<%=AttrQs(strEmail)%> autocomplete="off"></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SAVED_SEARCH%></td>
	<td><%=TXT_MAXIMUM_OF%><input name="SavedSearchQuota" title=<%=AttrQs(TXT_USER_MAX_SEARCHES)%> id="SavedSearchQuota" type="text" size="3" maxlength="3" value=<%=AttrQs(intSavedSearchQuota)%>><%=TXT_SAVED_SEARCHES%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SINGLE_LOGIN%></td>
	<td><label for="SingleLogin"><input id="SingleLogin" name="SingleLogin" type="checkbox" <%= Checked(bSingleLogin) %>> <%=TXT_INST_SINGLE_LOGIN%></label></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_ACCOUNT_UPDATES%></td>
	<td><label for="CanUpdateAccount"><input id="CanUpdateAccount" name="CanUpdateAccount" type="checkbox" <%= Checked(bCanUpdateAccount) %>> <%=TXT_INST_ACCOUNT_UPDATES_1%></label>
	<br><label for="CanUpdatePassword"><input id="CanUpdatePassword" name="CanUpdatePassword" type="checkbox" <%= Checked(bCanUpdatePassword) %>> <%=TXT_INST_ACCOUNT_UPDATES_2%></label></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=IIf(bNew,TXT_PASSWORD,TXT_CHANGE_PASSWORD)%></td>
	<td><%=TXT_INST_PASSWORD_1%>
	<br><%=TXT_INST_PASSWORD_2%>
	<%If Not bNew Then%><br><%=TXT_INST_PASSWORD_3%><%End If%>
	<table class="NoBorder cell-padding-2">
		<tr>
			<td class="FieldLabelClr"><label for="NewPW"><%=TXT_NEW_PASSWORD%></label></td>
			<td><input name="NewPW" id="NewPW" type="password" size="20" autocomplete="off"></td>
		</tr>
		<tr>
			<td class="FieldLabelClr"><label for="CNewPW"><%=TXT_CONFIRM_PASSWORD%></label></td>
			<td><input name="CNewPW" id="CNewPW" type="password" size="20" autocomplete="off"></td>
		</tr>
	</table></td>
</tr>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_SUBMIT_UPDATES%>"> <input type="reset" value="<%=TXT_RESET_FORM%>"></td>
</tr>
</table>
</form>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/ciocbasic.js") %>
<script type="text/javascript">
	jQuery(function($) {
		init_cached_state();
		restore_cached_state();
	});
</script>

<%
g_bListScriptLoaded = True
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
