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
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtUsers.asp" -->
<!--#include file="../text/txtUserHistory.asp" -->
<%
If Not user_bCanManageUsers Then
	Call securityFailure()
End If

Call addScript(ps_strPathToStart & makeAssetVer("scripts/formPrintMode.js"), "text/javascript")

Call makePageHeader(TXT_REVIEW_ACCOUNT_CHANGES, TXT_REVIEW_ACCOUNT_CHANGES, True, True, True, True)

Dim bResults, _
	strUserName, _
	strAgency
	
Dim	strStartDate, _
	strEndDate, _
	bChangeName, _
	bChangeInitials, _
	bChangeEmail, _
	bChangeAgency, _
	bChangeUserType, _
	bChangeSingleLogin, _
	bChangeMyAccount, _
	bChangeCreated, _
	bChangePassword, _
	bChangeInactive, _
	bChangeOther
	
strUserName = Left(Trim(Request("UserName")),50)

If user_bSuperUser Then
	strAgency = Left(Trim(Request("Agency")),3)
End If

bResults = Request.ServerVariables("REQUEST_METHOD") = "POST" Or Not Nl(strAgency) Or Not Nl(strUserName) Or g_bPrintMode

If bResults Then
	If Not user_bSuperUser Then
		strAgency = user_strAgency
	End If
	
	strStartDate = Null
	If Not Nl(Request("StartDate")) Then
		If IsSmallDate(Request("StartDate")) Then
			strStartDate = DateValue(Request("StartDate"))
		Else
			Call handleError(Request("StartDate") & TXT_INVALID_DATE_FORMAT & DateString(MIN_SMALL_DATE,True) & TXT_AND_LC & DateString(MAX_SMALL_DATE,True), _
				vbNullString, vbNullString)
		End If
	End If
	
	strEndDate = Null
	If Not Nl(Request("EndDate")) Then
		If IsSmallDate(Request("EndDate")) Then
			strEndDate = DateValue(Request("EndDate"))
		Else
			Call handleError(Request("EndDate") & TXT_INVALID_DATE_FORMAT & DateString(MIN_SMALL_DATE,True) & TXT_AND_LC & DateString(MAX_SMALL_DATE,True), _
				vbNullString, vbNullString)
		End If
	End If

	bChangeName = Request("Change_Name") = "on"
	bChangeInitials = Request("Change_Initials") = "on"
	bChangeEmail = Request("Change_Email") = "on"
	bChangeAgency = Request("Change_Agency") = "on"
	bChangeUserType = Request("Change_UserType") = "on"
	bChangeSingleLogin = Request("Change_SingleLogin") = "on"
	bChangeMyAccount = Request("Change_MyAccount") = "on"
	bChangeCreated = Request("Change_Created") = "on"
	bChangePassword = Request("Change_Password") = "on"
	bChangeInactive = Request("Change_Inactive") = "on"
	bChangeOther = Request("Change_Other") = "on"
End If

Dim intThisMonth, intThisYear, dateToday, dateLastMonthFirst, dateThisMonthFirst

intThisMonth = Month(Date())
intThisYear = Year(Date())
dateToday = DateString(Date(),True)
dateThisMonthFirst = DateString(DateSerial(intThisYear,intThisMonth,1),True)
dateLastMonthFirst = DateString(DateAdd("m",-1,dateThisMonthFirst),True)

If Not g_bPrintMode Then
%>
<p>[ <a href="<%=makeLinkB("users.asp")%>"><%=TXT_RETURN_EDIT_USERS%></a> ]</p>
<form action="users_history.asp" method="post" name="EntryForm" onSubmit="formPrintMode(this);">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox" colspan="4"><%=TXT_NEW_SEARCH%></th>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="UserName"><%=TXT_USER_NAME%></label></td><td<%If Not user_bSuperUser Then%> colspan="3"<%End If%>><input id="UserName" name="UserName" size="30" maxlength="50"></td>
<%
If user_bSuperUser Then
	Call openAgencyListRst(DM_GLOBAL, False, False)
%>
	<td class="FieldLabelLeft"><label for="Agency"><%=TXT_AGENCY%></label></td><td><%=makeAgencyList(vbNullString, "Agency", False, True)%></td>
<%
	Call closeAgencyListRst()
End If
%>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_CHANGE_DATE%></td>
	<td colspan="3"><table class="NoBorder cell-padding-2">
	<tr>
		<td class="FieldLabelClr"><label for="StartDate"><%=TXT_ON_AFTER_DATE%></label></td>
		<td><input type="text" name="StartDate" id="StartDate" size="15" maxlength="40" class="DatePicker"> <input type="BUTTON" value="<%=TXT_FIRST_OF_LAST_MONTH%>" onClick="document.EntryForm.StartDate.value='<%=dateLastMonthFirst%>'"></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><label for="EndDate"><%=TXT_BEFORE_DATE%></label></td>
		<td><input type="text" name="EndDate" id="EndDate" size="15" maxlength="40" class="DatePicker"> <input type="BUTTON" value="<%=TXT_FIRST_OF_THIS_MONTH%>" onClick="document.EntryForm.EndDate.value='<%=dateThisMonthFirst%>'"></td>
	</tr>
	</table></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_REVISION_TYPE%></td>
	<td colspan="3"><table class="NoBorder cell-padding-3">
		<tr>
			<td colspan="3"><label for="Change_Join_O"><input type="radio" name="Change_Join" id="Change_Join_O" value="O" checked>&nbsp;<%=TXT_ANY_OF%></label>
			<label for="Change_Join_A"><input type="radio" name="Change_Join" id="Change_Join_A" value="A">&nbsp;<%=TXT_ALL_OF%></label>
			</td>
		</tr>
		<tr>
			<td><label for="Change_Created"><input type="checkbox" name="Change_Created" id="Change_Created"><%=TXT_NEW_RECORD%></label></td>
			<td><label for="Change_Agency"><input type="checkbox" name="Change_Agency" id="Change_Agency"><%=TXT_AGENCY%></label></td>
			<td><label for="Change_Inactive"><input type="checkbox" name="Change_Inactive" id="Change_Inactive"><%=TXT_INACTIVE%></label></td>
		</tr>
		<tr>

			<td><label for="Change_Name"><input type="checkbox" name="Change_Name" id="Change_Name"><%=TXT_NAME%></label></td>
			<td><label for="Change_Initials"><input type="checkbox" name="Change_Initials" id="Change_Initials"><%=TXT_INITIALS%></label></td>
			<td><label for="Change_Email"><input type="checkbox" name="Change_Email" id="Change_Email"><%=TXT_EMAIL%></label></td>
		</tr>
		<tr>
			<td><label for="Change_UserType"><input type="checkbox" name="Change_UserType" id="Change_UserType"><%=TXT_USER_TYPE%></label></td>
			<td><label for="Change_SingleLogin"><input type="checkbox" name="Change_SingleLogin" id="Change_SingleLogin"><%=TXT_SINGLE_LOGIN%></label></td>
			<td><label for="Change_MyAccount"><input type="checkbox" name="Change_MyAccount" id="Change_MyAccount"><%=TXT_MY_ACCOUNT_ACCESS%></label></td>

		</tr>
		<tr>
			<td><label for="Change_Password"><input type="checkbox" name="Change_Password" id="Change_Password"><%=TXT_PASSWORD%></label></td>
			<td><label for="Change_Other"><input type="checkbox" name="Change_Other" id="Change_Other"><%=TXT_OTHER_CHANGE%></label></td>
			<td>&nbsp;</td>
		</tr>
	</table></td>
</tr>
<tr>	
	<td class="FieldLabel"><%=TXT_PRINT_VERSION%></td>
	<td colspan="3"><label for="PrintMd_Yes"><input type="radio" name="PrintMd" id="PrintMd_Yes" value="on">&nbsp;<%=TXT_YES%></label>
	<label for="PrintMd_No"><input type="radio" name="PrintMd" id="PrintMd_No" value="" checked>&nbsp;<%=TXT_NO%></label></td>
</tr>
<tr>
	<td colspan="4" align="center"><input type="submit" value="<%=TXT_SEARCH%>"> <input type="RESET" value="<%=TXT_CLEAR_FORM%>"></td>
</tr>
</table>
</form>
<%
End If

If bResults Then
	Dim strSQL, _
		strSQLCon, _
		strSQLConType
	
	If Request("Change_Join") = "A" Then
		strSQLConType = AND_CON
	Else
		strSQLConType = OR_CON
	End If
		
	strSQLCon = vbCrLf & "WHERE"
	
	strSQL = "SELECT u.UserName AS CUR_UserName, u.Agency CUR_Agency, uh.MODIFIED_DATE, uh.MODIFIED_BY," & vbCrLf & _
			"CHANGES	= CASE WHEN uh.NewAccount=1 THEN " & QsNl(TXT_NEW_RECORD) & " + '; ' ELSE '' END" & vbCrLF & _
			"			+ CASE WHEN uh.UserName IS NOT NULL THEN " & QsNl(TXT_USER_NAME & TXT_COLON) & " + uh.UserName + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.Agency IS NOT NULL THEN " & QsNl(TXT_AGENCY & TXT_COLON) & " + uh.Agency + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.FirstName IS NOT NULL THEN " & QsNl(TXT_FIRST_NAME & TXT_COLON) & " + uh.FirstName + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.LastName IS NOT NULL THEN " & QsNl(TXT_LAST_NAME & TXT_COLON) & " + uh.LastName + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.Initials IS NOT NULL THEN " & QsNl(TXT_INITIALS & TXT_COLON) & " + uh.Initials + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.Email IS NOT NULL THEN " & QsNl(TXT_EMAIL & TXT_COLON) & " + uh.Email + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.SL_ID_CIC IS NOT NULL THEN " & QsNl(TXT_USER_TYPE & " (" & TXT_CIC & ")" & TXT_COLON) & " + uh.SL_ID_CIC + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.SL_ID_VOL IS NOT NULL THEN " & QsNl(TXT_USER_TYPE & " (" & TXT_VOLUNTEER & ")" & TXT_COLON) & " + uh.SL_ID_VOL + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.SingleLogin IS NOT NULL THEN " & QsNl(TXT_SINGLE_LOGIN & TXT_COLON) & " + CASE WHEN uh.SingleLogin=1 THEN " & QsNl(TXT_YES) & " ELSE " & QsNl(TXT_NO) & " END + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.CanUpdateAccount IS NOT NULL THEN " & QsNl(TXT_MY_ACCOUNT_ACCESS & TXT_COLON) & " + CASE WHEN uh.CanUpdateAccount=1 THEN " & QsNl(TXT_YES) & " ELSE " & QsNl(TXT_NO) & " END + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.StartModule IS NOT NULL OR uh.StartLanguage IS NOT NULL THEN " & _
							QsNl(TXT_START_PAGE & TXT_COLON) & _
							" + CASE WHEN uh.StartModule=1 THEN " & QsNl(TXT_CIC) & " WHEN uh.StartModule=2 THEN " & QsNl(TXT_VOLUNTEER) & " ELSE '' END" & _
							" + CASE WHEN uh.StartModule IS NOT NULL AND uh.StartLanguage IS NOT NULL THEN ' ' ELSE '' END" & _
							" + ISNULL((SELECT LanguageName FROM STP_Language WHERE LangID=uh.StartLanguage),'') + " & _
							"'; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.SavedSearchQuota IS NOT NULL THEN " & QsNl(TXT_SAVED_SEARCH & TXT_COLON) & " + CAST(uh.SavedSearchQuota AS varchar) + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.Inactive IS NOT NULL THEN " & QsNl(TXT_INACTIVE & TXT_COLON) & " + CASE WHEN uh.Inactive=1 THEN " & QsNl(TXT_YES) & " ELSE " & QsNl(TXT_NO) & " END + '; ' ELSE '' END" & vbCrLf & _
			"			+ CASE WHEN uh.PasswordChange=1 THEN " & QsNl(TXT_PASSWORD_CHANGED) & " + '; ' ELSE '' END" & vbCrLf & _
			"FROM GBL_Users_History uh" & vbCrLf & _
			"INNER JOIN GBL_Users u ON uh.User_ID=u.User_ID"

	If Not Nl(strStartDate) Then
		strSQL = strSQL & strSQLCon & "(uh.MODIFIED_DATE >= " & QsN(DateString(strStartDate,True)) & ")"
		strSQLCon = strSQLConType	
	End If
	If Not Nl(strEndDate) Then
		strSQL = strSQL & strSQLCon & "(uh.MODIFIED_DATE < " & QsN(DateString(strEndDate,True)) & ")"
		strSQLCon = strSQLConType	
	End If
	If Not Nl(strUserName) Then
		strSQL = strSQL & strSQLCon & "(u.UserName=" & QsNl(strUserName) & ")"
		strSQLCon = strSQLConType
	End If
	If Not Nl(strAgency) Then
		strSQL = strSQL & strSQLCon & "(u.Agency=" & QsNl(strAgency) & ")"
		strSQLCon = strSQLConType
	End If
	If bChangeName Then
		strSQL = strSQL & strSQLCon & "(uh.FirstName IS NOT NULL OR uh.LastName IS NOT NULL)"
		strSQLCon = strSQLConType
	End If
	If bChangeInitials Then
		strSQL = strSQL & strSQLCon & "(uh.Initials IS NOT NULL)"
		strSQLCon = strSQLConType
	End If
	If bChangeEmail Then
		strSQL = strSQL & strSQLCon & "(uh.Email IS NOT NULL)"
		strSQLCon = strSQLConType
	End If
	If bChangeAgency Then
		strSQL = strSQL & strSQLCon & "(uh.Agency IS NOT NULL)"
		strSQLCon = strSQLConType
	End If
	If bChangeUserType Then
		strSQL = strSQL & strSQLCon & "(uh.SL_ID_CIC IS NOT NULL OR uh.SL_ID_VOL IS NOT NULL)"
		strSQLCon = strSQLConType
	End If
	If bChangeSingleLogin Then
		strSQL = strSQL & strSQLCon & "(uh.SingleLogin IS NOT NULL)"
		strSQLCon = strSQLConType
	End If
	If bChangeMyAccount Then
		strSQL = strSQL & strSQLCon & "(uh.CanUpdateAccount IS NOT NULL)"
		strSQLCon = strSQLConType
	End If
	If bChangeCreated Then
		strSQL = strSQL & strSQLCon & "(uh.NewAccount=" & SQL_TRUE & ")"
		strSQLCon = strSQLConType
	End If
	If bChangePassword Then
		strSQL = strSQL & strSQLCon & "(uh.PasswordChange=" & SQL_TRUE & ")"
		strSQLCon = strSQLConType
	End If
	If bChangeInactive Then
		strSQL = strSQL & strSQLCon & "(uh.Inactive IS NOT NULL)"
		strSQLCon = strSQLConType
	End If
	If bChangeOther Then
		strSQL = strSQL & strSQLCon & "(uh.SavedSearchQuota IS NOT NULL OR uh.StartModule IS NOT NULL OR uh.StartLanguage IS NOT NULL)"
		strSQLCon = strSQLConType
	End If

	strSQL = strSQL & vbCrLf & _
			"ORDER BY uh.MODIFIED_DATE DESC"
			
	'Response.Write(strSQL)
	'Response.Flush()

	Dim cmdListEditUser, rsListEditUser
		
	Set cmdListEditUser = Server.CreateObject("ADODB.Command")
	With cmdListEditUser
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = strSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
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
<%
		End If
		If .RecordCount > 0 Then
%>
<table class="BasicBorder cell-padding-2">
<tr>
	<th class="RevTitleBox"><%=TXT_USER_NAME%></th>
<%If user_bSuperUser Then%>
	<th class="RevTitleBox"><%=TXT_AGENCY%></th>
<%End If%>
	<th class="RevTitleBox"><%=TXT_CHANGE_DATE%></th>
	<th class="RevTitleBox"><%=TXT_CHANGED_BY%></th>
	<th class="RevTitleBox"><%=TXT_ACTION%></th>
</tr>
<%
		End If
		While Not .EOF
%>
<tr>
	<td><%=.Fields("CUR_UserName")%></td>
<%If user_bSuperUser Then%>
	<td><%=.Fields("CUR_Agency")%></td>
<%End If%>
	<td><%=DateTimeString(.Fields("MODIFIED_DATE"),True)%></td>
	<td><%=.Fields("MODIFIED_BY")%></td>
	<td><%=.Fields("CHANGES")%></td>
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

<%= makeJQueryScriptTags() %>
<%=JSVerScriptTag("scripts/datepicker.js")%>
<%
g_bListScriptLoaded = True
	
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
