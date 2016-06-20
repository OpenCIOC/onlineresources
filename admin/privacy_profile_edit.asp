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
Call setPageInfo(True, DM_CIC, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtPrivacyProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incViewList.asp" -->
<%
If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

If Nl(intProfileID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"privacy_profile.asp", vbNullString)
ElseIf Not IsIDType(intProfileID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"privacy_profile.asp", vbNullString)
Else
	intProfileID = CLng(intProfileID)
End If

Dim	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
	strProfileName, _
	intUsageCount, _
	strProfileStatus, _
	bOkDelete, _
	xmlDoc, _
	xmlNode, _
	strCulture

bOkDelete = False

Dim cmdProfile, rsProfile
Set cmdProfile = Server.CreateObject("ADODB.Command")
With cmdProfile
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_PrivacyProfile_s"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
End With
Set rsProfile = cmdProfile.Execute

With rsProfile
	If .EOF Then
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intProfileID) & "." & _
			vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
			"privacy_profile.asp", vbNullString)
	Else
		strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		intUsageCount = .Fields("RecordCount")

		If intUsageCount = 0 Then
			strProfileStatus = TXT_STATUS_NO_USE & "<br>" & TXT_STATUS_DELETE
			bOkDelete = True
		Else
			strProfileStatus = TXT_STATUS_USE_1 & intUsageCount & TXT_STATUS_USE_2
			strProfileStatus = strProfileStatus & "<br>" & TXT_STATUS_NO_DELETE
		End If

		Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
		With xmlDoc
			.async = False
			.setProperty "SelectionLanguage", "XPath"
		End With

		xmlDoc.loadXML "<DESCS>" & Nz(.Fields("Names"),vbNullString) & "</DESCS>"
		End If
End With

Call makePageHeader(TXT_EDIT_PROFILE & TXT_COLON & Server.HTMLEncode(strProfileName), TXT_EDIT_PROFILE & TXT_COLON & Server.HTMLEncode(strProfileName), True, False, True, True)
%>

<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLink("privacy_profile.asp",vbNullString,vbNullString)%>"><%=TXT_RETURN_TO_PROFILES%></a> ]</p>
<form action="privacy_profile_edit2.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ProfileID" value="<%=intProfileID%>">
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox"><%=TXT_EDIT_PROFILE%></th></tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_STATUS%></td>
	<td><%=strProfileStatus%></td>
</tr>
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
<%
For Each strCulture in active_cultures() 
	Set xmlNode = xmlDoc.selectSingleNode("//DESC[@Culture=" & Qs(strCulture, SQUOTE) & "]")
	If xmlNode IS Nothing Then
		strProfileName = vbNullString
	Else 
		strProfileName = Server.HTMLEncode(Ns(xmlNode.getAttribute("ProfileName")))
	End If
%>
<tr>
	<td class="FieldLabelLeft"><label for="ProfileName_<%= strCulture %>"><%=TXT_NAME%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label></td>
	<td><input type="text" name="ProfileName_<%= strCulture %>" id="ProfileName_<%= strCulture %>" value=<%=AttrQs(Server.HTMLEncode(Ns(strProfileName)))%> size="<%=TEXT_SIZE%>" maxlength="100">
	<br><%=TXT_INST_PROFILE_NAME%></td>
</tr>
<%
Next
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MANAGE_FIELDS_TITLE%></td>
	<td>
<%
	Dim bLastState

	Set rsProfile = rsProfile.NextRecordset
	With rsProfile
		If Not .EOF Then
			bLastState = .Fields("IS_SELECTED")
		End If
		While Not .EOF
			If bLastState <> .Fields("IS_SELECTED") Then
%>
<hr>
<%
			End If
%>
	<label for="UseField_<%=.Fields("FieldID")%>"><input type="checkbox" name="UseField" id="UseField_<%=.Fields("FieldID")%>" value="<%=.Fields("FieldID")%>"<%=Checked(.Fields("IS_SELECTED"))%>>&nbsp;<strong><%=.Fields("FieldName")%></strong>&nbsp;(<%=Server.HTMLEncode(.Fields("FieldDisplay"))%>)</label><br>
<%
			bLastState = .Fields("IS_SELECTED")
			.MoveNext
		Wend
		.Close
	End With
%>
	</td>
</tr>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_SUBMIT_UPDATES%>"> <%If bOkDelete Then%><input type="submit" name="Submit" value="<%=TXT_DELETE%>"><%End If%> <input type="reset" value="<%=TXT_RESET_FORM%>"></td>
</tr>
</table>
</form>

<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
