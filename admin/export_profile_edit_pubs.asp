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

Dim SUBMIT_BUTTON, _
	DELETE_BUTTON, _
	ADD_BUTTON

SUBMIT_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_UPDATE & """>"
DELETE_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_DELETE & """>"
ADD_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_ADD & """>"

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

Dim cnnProfilePubs, cmdProfilePubs, rsProfilePubs
Call makeNewAdminConnection(cnnProfilePubs)
Set cmdProfilePubs = Server.CreateObject("ADODB.Command")
With cmdProfilePubs
	.ActiveConnection = cnnProfilePubs
	.CommandText = "dbo.sp_CIC_ExportProfile_Pub_l"
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
End With
Set rsProfilePubs = cmdProfilePubs.Execute

If rsProfilePubs.EOF Then
	Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"export_profile.asp", vbNullString)
Else
	strProfileName = rsProfilePubs("ProfileName")
End If

Set rsProfilePubs = rsProfilePubs.NextRecordset

Call makePageHeader(TXT_MANAGE_PUBS_TITLE & TXT_COLON & strProfileName, TXT_MANAGE_PUBS_TITLE & TXT_COLON & strProfileName, False, False, True, False)
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a><%= makePageHelpLink() %> ]</p>
<h2><%=TXT_MANAGE_PUBS_TITLE & " (" & strProfileName & ")"%></h2>
<table class="BasicBorder cell-padding-3">
<tr><th><%=TXT_CODE%></th><th><%=TXT_INCLUDE_DESCRIPTION%></th><th><%=TXT_INCLUDE_HEADINGS%></th><th><%=TXT_ACTION%></th></tr>
<%
	With rsProfilePubs
		While Not .EOF
%>
<form action="export_profile_edit_pubs2.asp" method="post">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="ProfileID" value="<%=intProfileID%>">
<input type="hidden" name="ExportPubID" value="<%=.Fields("ExportPubID")%>">
</div>
<tr>
	<td><%=.Fields("PubCode")%></td>
	<td align="center"><input type="checkbox" name="IncludeDescription" title=<%=AttrQs(.Fields("PubCode") & TXT_COLON & TXT_INCLUDE_DESCRIPTION_NO_HTML)%><%If .Fields("IncludeDescription") Then%> checked<%End If%>></td>
	<td align="center"><input type="checkbox" name="IncludeHeadings" title=<%=AttrQs(.Fields("PubCode") & TXT_COLON & TXT_INCLUDE_HEADINGS_NO_HTML)%><%If .Fields("IncludeHeadings") Then%> checked<%End If%>></td>
	<td><%=SUBMIT_BUTTON%>&nbsp;<%=DELETE_BUTTON%></td>
</tr>
</form>
<%
			.MoveNext
		Wend
		.Close
	End With
	Set rsProfilePubs = Nothing
	Set cmdProfilePubs = Nothing

Set cmdProfilePubs = Server.CreateObject("ADODB.Command")
With cmdProfilePubs
	.ActiveConnection = cnnProfilePubs
	.CommandText = "dbo.sp_CIC_ExportProfile_Pub_l_Unused"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
End With
Set rsProfilePubs = cmdProfilePubs.Execute

Dim strReturn
With rsProfilePubs
	If .EOF Then
		strReturn = TXT_NO_VALUES_AVAILABLE
	Else
		strReturn = strReturn & "<select name=""PBID"">"
		Dim strPubName
		While Not .EOF
			strReturn = strReturn & _
				"<option value=" & AttrQs(.Fields("PB_ID")) & ">" & .Fields("PubCode") & "</option>"
			.MoveNext
		Wend
		strReturn = strReturn & "</select>"
	End If
End With
%>
<form action="export_profile_edit_pubs_add.asp" method="post">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="ProfileID" value="<%=intProfileID%>">
</div>
<tr>
	<td colspan="3"><%=strReturn%></td>
	<td><%=ADD_BUTTON%></td>
</tr>
</form>
</table>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a> ]</p>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
