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
' Purpose:		Select format and records for export
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
Call setPageInfo(True, DM_VOL, DM_VOL, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtCopyForm.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incAgencyList.asp" -->
<!--#include file="../includes/update/incVOLCopyFormPrint.asp" -->
<%
If Not user_bCopyVOL And user_intUpdateDOM = UPDATE_NONE Then
	Call securityFailure()
End If

Dim strVNUM, _
	strNewVNUM, _
	strCopyCulture, _
	bVNUMError, _
	i, _
	strOrgName, _
	strPosTitle, _
	strCopyLanguage
	

strVNUM = Request("VNUM")
If Not IsVNUMType(strVNUM) Then
	bVNUMError = True
	Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
Else
	strCopyCulture = Left(Trim(Request("CopyLn")),5)

	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_VOL_Opportunity_s_CanCopy"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
		.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, user_strAgency)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
		.Parameters.Append .CreateParameter("@Culture", adVarChar, adParamInput, 5, strCopyCulture)
	End With
	Set rsOrg = cmdOrg.Execute
	If rsOrg.EOF Then
		bVNUMError = True
		Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
	ElseIf rsOrg.Fields("CAN_UPDATE") = 0 Then
		Call securityFailure()
	Else
		strOrgName = rsOrg.Fields("ORG_NAME_FULL")
		strPosTitle = rsOrg.Fields("POSITION_TITLE")
		strCopyLanguage = rsOrg.Fields("LanguageName")
		strNewVNUM = rsOrg.Fields("NewVNUM")
				
		If Not Nl(strCopyCulture) And Nl(strCopyLanguage) Then
			bVNUMError = True
			Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
			Call handleError(TXT_ERROR & TXT_NOT_A_VALID_LANGUAGE & strCopyCulture & ".", vbNullString, vbNullString)
		End If
	End If
	rsOrg.Close
	
	Set rsOrg = Nothing
	Set cmdOrg = Nothing
End If

If Not bVNUMError Then

Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
%>
<h2><%=IIf(Nl(strCopyLanguage),TXT_COPY_RECORD_ID,TXT_CREATE_EQUIVALENT_ID) & strVNUM & StringIf(Not Nl(strCopyLanguage)," (" & strCopyLanguage & ")")%>
<br><a href="<%=makeDetailsLink(strVNUM, StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber),vbNullString)%>"><%=strOrgName%> (<%=strPosTitle%>)</a></h2>
<% If Nl(strCopyLanguage) Then %>
<p class="HideJs Alert">
<%= TXT_JAVASCRIPT_REQUIRED %>
</p>
<div class="HideNoJs">
<% End If %>
<p><%=IIf(Nl(strCopyLanguage),TXT_INST_ABOUT_NEW_RECORD,TXT_INST_ABOUT_NEW_RECORD_LANG)%></p>
<hr>
<form action="copy2.asp" method="post" name="RecordList" id="RecordList">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="VNUM" value="<%=strVNUM%>">
<%If Not Nl(strCopyLanguage) Then%>
<input type="hidden" name="CopyLn" value="<%=strCopyCulture%>">
<%End If%>
<%If intCurSearchNumber >= 0 Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%End If%>
</div>
<%
If Nl(strCopyLanguage) Then
%>
<table class="BasicBorder cell-padding-3">
<tr valign="top">
	<td class="FieldLabelLeft" id="FIELD_RECORD_VNUM"><%=TXT_RECORD_NUM%> <span class="Alert">*</span></td>
	<td data-field-display-name="<%=TXT_RECORD_NUM%>" data-field-required="true">
		<input type="checkbox" name="AutoAssignVNUM" checked onClick="changeAutoAssign(this, document.RecordList.NewVNUM, document.RecordList.NewVNUMButton);">&nbsp;<%=TXT_AUTO_ASSIGN_LOWEST_NUM%>
		<br><input type="text" id="NewVNUM" name="NewVNUM" maxlength="10" size="11" disabled class="record-vnum">
		<input type="button" id="NewVNUMButton" value="<%=TXT_LOWEST_UNUSED_FOR & user_strAgency%>" onClick="document.RecordList.NewVNUM.value='<%=strNewVNUM%>';" disabled>
		[ <a href="javascript:openWin('<%=makeLinkB("numfind.asp")%>','aFind')"><%=TXT_LOWEST_UNUSED_FOR & TXT_ALL_AGENCIES%></a> ]</td>
</tr>
<%
	If user_bSuperUserVOL Then
		Call openAgencyListRst(DM_VOL, True, True)
%>
<tr valign="top">
	<td class="FieldLabelLeft"><%=TXT_RECORD_OWNER%></td>
	<td><%=makeRecordOwnerAgencyList(user_strAgency, "Owner", True)%></td>
</tr>
<%
		Call closeAgencyListRst()
	End If
%>
<tr valign="top">
	<td class="FieldLabelLeft"><%=TXT_LANGUAGES%></td>
	<td><input type="radio" name="CopyOnlyCurrentLang" id="CopyOnlyCurrentLang_N" value="" checked>&nbsp;<%=TXT_COPY_ALL_LANGUAGES%>
		<br><input type="radio" name="CopyOnlyCurrentLang" id="CopyOnlyCurrentLang_Y" value="on">&nbsp;<%=TXT_COPY_CURRENT_LANGUAGE%></td>
</tr>
<%
	If g_bCanSeeNonPublicVOL Then
%>
<tr valign="top">
	<td class="FieldLabelLeft"><%=TXT_NON_PUBLIC%></td>
	<td><input type="radio" name="NonPublic" value="on" checked>&nbsp;<%=TXT_YES%>
		<input type="radio" name="NonPublic" value="">&nbsp;<%=TXT_NO%></td>
</tr>
<%
	End If
%>
</table>
<%
	Call printCopyFieldsForm(strVNUM)
End If

%>
<p id="required_field_error_box" class="NotVisible">
<span class="Alert"><%= TXT_REQUIRED_FIELDS_EMPTY %></span>
<div id="required_field_error_list">
</div>
</p>
<p><input type="submit" value="<%=TXT_CREATE_RECORD & StringIf(Not Nl(strCopyLanguage)," (" & strCopyLanguage & ")")%>"></p>
</form>
<%
End If
If Nl(strCopyLanguage) Then
%>
</div>
<% End If %>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/copy.js") %>
<% g_bListScriptLoaded = True %>
<script type="text/javascript">
(function() {
init_client_validation('#RecordList', '<%= TXT_VALIDATION_ERRORS_TITLE %>');
})();
</script>
<%

Call makePageFooter(False)

%>
<!--#include file="../includes/core/incClose.asp" -->
