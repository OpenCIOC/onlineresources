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
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../text/txtExportProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<%
If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

If Nl(intProfileID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"export_profile.asp", vbNullString)
ElseIf Not IsIDType(intProfileID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"export_profile.asp", vbNullString)
Else
	intProfileID = CLng(intProfileID)
End If

Dim		strProfileName

Dim cnnProfileFields, cmdProfileFields, rsProfileFields
Call makeNewAdminConnection(cnnProfileFields)
Set cmdProfileFields = Server.CreateObject("ADODB.Command")
With cmdProfileFields
	.ActiveConnection = cnnProfileFields
	.CommandText = "dbo.sp_CIC_ExportProfile_Fld_l"
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
End With
Set rsProfileFields = cmdProfileFields.Execute

If rsProfileFields.EOF Then
	Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"export_profile.asp", vbNullString)
Else
	strProfileName = rsProfileFields("ProfileName")
End If

Set rsProfileFields = rsProfileFields.NextRecordset

Call makePageHeader(TXT_MANAGE_FIELDS_TITLE & TXT_COLON & strProfileName, TXT_MANAGE_FIELDS_TITLE & TXT_COLON & strProfileName, False, False, True, False)
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a><%= makePageHelpLink() %> ]</p>
<h2><%=TXT_MANAGE_FIELDS_TITLE & " (" & strProfileName & ")"%></h2>
<form action="export_profile_edit_fields2.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ProfileID" value="<%=intProfileID%>">
<%
	Dim bLastState

	With rsProfileFields
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
<label for="UseField_<%=.Fields("FieldID")%>"><input type="checkbox" name="UseField" id="UseField_<%=.Fields("FieldID")%>" value="<%=.Fields("FieldID")%>"<%If .Fields("IS_SELECTED") Then%> checked<%End If%>>&nbsp;<strong><%=.Fields("FieldName")%></strong>&nbsp;(<%=.Fields("FieldDisplay")%>)</label><br>
<%
			bLastState = .Fields("IS_SELECTED")
			.MoveNext
		Wend
		.Close
	End With
%>
<p><input type="submit" value="<%=TXT_SUBMIT%>"> <input type="reset" value="<%=TXT_RESET_FORM%>"></p>
</form>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a> ]</p>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
