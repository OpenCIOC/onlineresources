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
Call setPageInfo(True, DM_GLOBAL, DM_CIC, "../", "import/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtImport.asp" -->
<%
Dim intProfileID, _
	strProfileName, _
	bError, _
	strErrMessage, _
	xmlDoc, _
	xmlNode, _
	strCulture, _
	strValue

bError = False
strErrMessage = vbNullString

If Not user_bImportPermissionCIC Then
	Call securityFailure()
End If

intProfileID = Trim(Request("ProfileID"))
If Nl(intProfileID) Then
	bError = True
	strErrMessage = TXT_NO_RECORD_CHOSEN & "."
ElseIf Not IsIDType(intProfileID) Then
	bError = True
	strErrMessage = TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." 
Else
	intProfileID = CLng(intProfileID)
End If

If Not bError Then

Dim cnnProfileFields, cmdProfileFields, rsProfileFields
Call makeNewAdminConnection(cnnProfileFields)
Set cmdProfileFields = Server.CreateObject("ADODB.Command")
With cmdProfileFields
	.ActiveConnection = cnnProfileFields
	.CommandText = "dbo.sp_GBL_PrivacyProfile_s"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
End With
Set rsProfileFields = cmdProfileFields.Execute

If rsProfileFields.EOF Then
	bError = True
	strErrMessage = TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intProfileID) & "."
Else
	strProfileName = rsProfileFields("ProfileName")
End If

End If

If Not bError Then

	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With

	xmlDoc.loadXML "<DESCS>" & Nz(rsProfileFields.Fields("Names"),vbNullString) & "</DESCS>"

Set rsProfileFields = rsProfileFields.NextRecordset

strProfileName = Server.HTMLEncode(strProfileName)

Call makePageHeader(strProfileName, strProfileName, False, False, True, False)
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a><%= makePageHelpLink() %> ]</p>

<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox"><%=TXT_PRIVATE_FIELDS & " (" & strProfileName & ")"%></th></tr>
<% 
For Each strCulture in active_cultures() 
	Set xmlNode = xmlDoc.selectSingleNode("//DESC[@Culture=" & Qs(strCulture, SQUOTE) & "]")
	If xmlNode IS Nothing Then
		strValue = vbNullString
	Else 
		strValue = Server.HTMLEncode(Ns(xmlNode.getAttribute("ProfileName")))
	End If
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_NAME%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</td>
	<td><%=strValue%></td>
</tr>
<%
Next
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_PRIVATE_FIELDS%></td>
	<td>
<%
	With rsProfileFields
		While Not .EOF
			If .Fields("IS_SELECTED") Then
%>
			<strong><%=Server.HTMLEncode(.Fields("FieldName"))%></strong>&nbsp;(<%=Server.HTMLEncode(.Fields("FieldDisplay"))%>)<br>
<%
			End If
			.MoveNext
		Wend
		.Close
	End With
%>
	</td>
</tr>
</table>

<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a> ]</p>
<%
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
