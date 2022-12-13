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
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtCopyForm.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/list/incAgencyList.asp" -->
<!--#include file="includes/list/incRecordTypeList.asp" -->
<!--#include file="includes/update/incCICCopyFormPrint.asp" -->
<%
If Not user_bCopyCIC And user_intUpdateDOM = UPDATE_NONE Then
	Call securityFailure()
End If

Dim strNUM, _
	strNewNUM, _
	strCopyCulture, _
	bNUMError, _
	i, _
	dicOrgName, _
	strOrgName, _
	strCopyLanguage, _
	intCopyRTID, _
	strRecordTypeName
	

strNUM = Request("NUM")
Set dicOrgName = Server.CreateObject("Scripting.Dictionary")
If Not IsNUMType(strNUM) Then
	bNUMError = True
	Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
Else
	strCopyCulture = Left(Trim(Request("CopyLn")),5)

	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_GBL_BaseTable_s_CanCopy"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, user_strAgency)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@Culture", adVarChar, adParamInput, 5, strCopyCulture)
	End With
	Set rsOrg = cmdOrg.Execute
	If rsOrg.EOF Then
		bNUMError = True
		Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
	ElseIf rsOrg.Fields("CAN_UPDATE") = 0 Then
		Call securityFailure()
	Else
		For Each i in Array("ORG_LEVEL_1", "ORG_LEVEL_2", "ORG_LEVEL_3", "ORG_LEVEL_4", "ORG_LEVEL_5", "LOCATION_NAME", "SERVICE_NAME_LEVEL_1", "SERVICE_NAME_LEVEL_2")
			dicOrgName(i) = rsOrg.Fields(i).Value
		Next
		strOrgName = rsOrg.Fields("ORG_NAME_FULL")
		strCopyLanguage = rsOrg.Fields("LanguageName")
		strNewNUM = rsOrg.Fields("NewNUM")
		
		intCopyRTID = rsOrg.FieldS("CUR_RT_ID")
		strRecordTypeName = rsOrg.Fields("RecordTypeName")
		
		If Not Nl(strCopyCulture) And Nl(strCopyLanguage) Then
			bNUMError = True
			Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
			Call handleError(TXT_ERROR & TXT_NOT_A_VALID_LANGUAGE & strCopyCulture & ".", vbNullString, vbNullString)
		End If
	End If
	rsOrg.Close
	
	Set rsOrg = Nothing
	Set cmdOrg = Nothing
End If

If Not bNUMError Then

Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
%>
<h2><%=IIf(Nl(strCopyLanguage),TXT_COPY_RECORD_ID,TXT_CREATE_EQUIVALENT_ID) & strNUM & StringIf(Not Nl(strCopyLanguage)," (" & strCopyLanguage & ")")%>
	<br>
	<a href="<%=makeDetailsLink(strNUM,StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber),vbNullString)%>"><%=strOrgName%></a></h2>
<% If Nl(strCopyLanguage) Then %>
<p class="HideJs Alert">
	<%= TXT_JAVASCRIPT_REQUIRED %>
</p>
<div class="HideNoJs">
	<% End If %>
	<p><%=IIf(Nl(strCopyLanguage),TXT_INST_ABOUT_NEW_RECORD,TXT_INST_ABOUT_NEW_RECORD_LANG)%></p>
	<hr>
	<form action="copy2.asp" method="post" name="RecordList" id="RecordList">
		<div style="display: none">
			<%=g_strCacheFormVals%>
			<input type="hidden" name="NUM" value="<%=strNUM%>">
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
		<table class="BasicBorder cell-padding-3 full-width clear-line-below form-table responsive-table">
			<tr valign="top">
				<td class="field-label-cell" id="FIELD_RECORD_NUM"><%=TXT_RECORD_NUM%> <span class="Alert">*</span></td>
				<td class="field-data-cell form-inline" data-field-display-name="<%=TXT_RECORD_NUM%>" data-field-required="true">
					<input class="form-control" type="checkbox" name="AutoAssignNUM" checked onclick="changeAutoAssign(this, document.RecordList.NewNUM, document.RecordList.NewNUMButton);"> <%=TXT_AUTO_ASSIGN_LOWEST_NUM%>
					<br>
					<input class="form-control" type="text" id="NewNUM" name="NewNUM" maxlength="8" size="9" disabled class="record-num">
					<input type="button" id="NewNUMButton" value="<%=TXT_LOWEST_UNUSED_FOR & user_strAgency%>" onclick="document.RecordList.NewNUM.value='<%=strNewNUM%>';" disabled>
					[ <a href="javascript:openWin('<%=makeLinkB("numfind.asp")%>','aFind')"><%=TXT_LOWEST_UNUSED_FOR & TXT_ALL_AGENCIES%></a> ]
				</td>
			</tr>
			<%
	If user_bSuperUserCIC Then
		Call openAgencyListRst(DM_CIC, True, True)
			%>
			<tr valign="top">
				<td class="field-label-cell"><%=TXT_RECORD_OWNER%></td>
				<td><%=makeRecordOwnerAgencyList(user_strAgency, "Owner", True)%></td>
			</tr>
			<%
		Call closeAgencyListRst()
	End If
	If user_intCanUpdatePubs = UPDATE_ALL Then
			%>
			<tr valign="top">
				<td class="field-label-cell"><%=TXT_COPY_PUBS%></td>
				<td>
					<input type="radio" name="CopyPubs" id="CopyPubs_N" value="" checked> <%=TXT_NO%>
					<input type="radio" name="CopyPubs" id="CopyPubs_Y" value="on"> <%=TXT_YES%>
				</td>
			</tr>
			<%
	End If
	If user_intCanIndexTaxonomy <> UPDATE_NONE Then
			%>

			<tr valign="top">
				<td class="field-label-cell"><%=TXT_COPY_TAXONOMY%></td>
				<td>
					<input type="radio" name="CopyTaxonomy" id="CopyTaxonomy_N" value="" checked> <%=TXT_NO%>
					<input type="radio" name="CopyTaxonomy" id="CopyTaxonomy_Y" value="on"> <%=TXT_YES%>
				</td>
			</tr>
			<%
	End If
			%>
			<tr valign="top">
				<td class="field-label-cell"><%=TXT_LANGUAGES%></td>
				<td>
					<input type="radio" name="CopyOnlyCurrentLang" id="CopyOnlyCurrentLang_N" value="" checked> <%=TXT_COPY_ALL_LANGUAGES%>
					<br>
					<input type="radio" name="CopyOnlyCurrentLang" id="CopyOnlyCurrentLang_Y" value="on"> <%=TXT_COPY_CURRENT_LANGUAGE%></td>
			</tr>
			<%
	If g_bCanSeeNonPublicCIC Then
			%>
			<tr valign="top">
				<td class="field-label-cell"><%=TXT_NON_PUBLIC%></td>
				<td>
					<input type="radio" name="NonPublic" value="on" checked> <%=TXT_YES%>
					<input type="radio" name="NonPublic" value=""> <%=TXT_NO%>
				</td>
			</tr>
			<%
	End If
			%>
		</table>
		<%
	Call printCopyFieldsForm(intCopyRTID, strNUM, strRecordTypeName)
End If

		%>
		<p id="required_field_error_box" class="NotVisible">
			<span class="Alert"><%= TXT_REQUIRED_FIELDS_EMPTY %></span>
			<div id="required_field_error_list">
			</div>
		</p>
		<% If g_intPreventDuplicateOrgNames <> 0 Then %>
		<div id="duplicate_name_error_box" class="NotVisible">
			<p><span class="AlertBubble"><%= TXT_DUPLICATE_ORG_NAME_ERROR %></span></p>
		</div>
		<% End If %>
		<div id="validation_error_box" class="NotVisible">
			<p><span class="AlertBubble"><%= TXT_VALIDATION_ERRORS_MESSAGE %></span></p>
		</div>
		<p>
			<input class="btn btn-default" type="submit" value="<%=TXT_CREATE_RECORD & StringIf(Not Nl(strCopyLanguage)," (" & strCopyLanguage & ")")%>">
		</p>
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

		var org_levels = {
<%
			Dim key, field
		key = Array("ORG_LEVEL_1", "ORG_LEVEL_2", "ORG_LEVEL_3", "ORG_LEVEL_4", "ORG_LEVEL_5", "LOCATION_NAME", "SERVICE_NAME_LEVEL_1", "SERVICE_NAME_LEVEL_2")
	For Each field in key
		Response.Write(StringIf(field <> "ORG_LEVEL_1", ",") & JSONQs(field, True) & ": " & JSONQs(dicOrgName(field), True))
		Next
			%>
};
	init_record_type_form('<%= strNUM %>', '<%= makeLinkB("copy_form.asp") %>', org_levels);

<% If g_intPreventDuplicateOrgNames <> 0 And Nl(strCopyCulture) Then %>
		jQuery(function() {
			init_validate_duplicate_org_names({
				selector: '#RecordList',
				org_levels: org_levels,
				confirm_string: <%= JSONQs(TXT_DUPLICATE_ORG_NAME_PROMPT, True) %>,
				prefix: "O",
		<% If g_intPreventDuplicateOrgNames = 2 Then %>
			only_warn: false,
		<% End If %>
			url: <%= JSONQs(makeLinkB("jsonfeeds/orgname_checker.asp"), True) %>
	});
});
<% End If %>

}) ();
</script>
<%

Call makePageFooter(False)

%>
<!--#include file="includes/core/incClose.asp" -->
