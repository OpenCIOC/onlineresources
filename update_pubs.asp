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
<!--#include file="text/txtUpdatePubs.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<%
If user_intCanUpdatePubs = UPDATE_NONE Or user_bLimitedViewCIC Then
	Call securityFailure()
End If

Call makePageHeader(TXT_UPDATE_PUBS_TITLE, TXT_UPDATE_PUBS_TITLE, True, False, True, True)
%>
<%
Dim SUBMIT_BUTTON, _
	DELETE_BUTTON, _
	ADD_BUTTON

SUBMIT_BUTTON = "<input type=""Submit"" value=""" & TXT_UPDATE & """>"
DELETE_BUTTON = "<input type=""Submit"" name=""Delete"" value=""" & TXT_DELETE & """>"
ADD_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_ADD & """>"

Dim strNUM
strNUM = Request("NUM")

Dim bNUMError
bNUMError = False

If Nl(strNUM) Then
	bNUMError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
ElseIf Not IsNUMType(strNUM) Then
	bNUMError = True
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
End If

Dim objReturn, objErrMsg

Dim strOrgName

If Not bNUMError Then
	Dim cmdPublication, rsPublication
	Set cmdPublication = Server.CreateObject("ADODB.Command")
	With cmdPublication
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMPub_l"
		.CommandType = adCmdStoredProc
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 1, g_intViewTypeCIC)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
		.CommandTimeout = 0
	End With
	Set rsPublication = cmdPublication.Execute
	If rsPublication.EOF Then
		bNUMError = True
		Set rsPublication = rsPublication.NextRecordset
		Set rsPublication = rsPublication.NextRecordset
		Set rsPublication = rsPublication.NextRecordset
		Select Case objReturn.Value
			Case 0
				Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
			Case Else
				Call handleError(Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
		End Select
	End If
End If

If Not bNUMError Then
	With rsPublication
%>
<h2><%=TXT_EDIT_PUBS_FOR%>
<br><a href="<%=makeDetailsLink(strNUM, StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber),vbNullString)%>"><%=.Fields("ORG_NAME_FULL")%></a></h2>

<table class="BasicBorder cell-padding-2">
	<thead>
		<tr>
			<th class="RevTitleBox"><%=TXT_CODE%></th>
			<th class="RevTitleBox"><%=TXT_NAME%></th>
			<th class="RevTitleBox"><%=TXT_HAS_DESCRIPTION%></th>
			<th class="RevTitleBox"><%=TXT_HAS_HEADINGS%></th>
			<th class="RevTitleBox"><%=TXT_HAS_FEEDBACK%></th>
			<th class="RevTitleBox"><%=TXT_ACTION%></th>
		</tr>
	</thead>
	<tbody>
<%
	End With
	Set rsPublication = rsPublication.NextRecordset
	With rsPublication
		While Not .EOF
%>

<form action="<%= ps_strPathToStart & makeLinkB("updatepubs/edit") %>" method="get">
<%=g_strCacheFormVals%>
<input type="hidden" name="NUM" value="<%= strNUM %>">
<input type="hidden" name="BTPBID" value="<%= .Fields("BT_PB_ID") %>">
<%			If intCurSearchNumber >= 0 Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%			End If%>
		<tr>
			<td class="FieldLabelLeftClr"><%=.Fields("PubCode")%></td>
			<td><%=Server.HTMLEncode(Ns(.Fields("PubName")))%></td>
			<td align="center" class="Alert"><%If .Fields("HAS_DESCRIPTION") Then%><img src="<%=ps_strPathToStart%>images/greencheck.gif"><%Else%>&nbsp;<%End If%></td>
			<td align="center" class="Alert"><%If .Fields("HAS_GENHEADINGS") Then%><img src="<%=ps_strPathToStart%>images/greencheck.gif"><%Else%>&nbsp;<%End If%></td>
			<td align="center" class="Alert"><%If .Fields("HAS_FEEDBACK") Then%><img src="<%=ps_strPathToStart%>images/redflag.gif"><%Else%>&nbsp;<%End If%></td>
			<td><%=SUBMIT_BUTTON%>&nbsp;<%=DELETE_BUTTON%></td>
		</tr>
</form>
<%
			.MoveNext
		Wend
	End With

	Dim cnnListPub, cmdListPub, rsListPub
	Dim strReturn
	Call makeNewAdminConnection(cnnListPub)
	Set cmdListPub = Server.CreateObject("ADODB.Command")
	With cmdListPub
		.ActiveConnection = cnnListPub
		.CommandText = "dbo.sp_CIC_NUMPub_l_Unused"
		.CommandType = adCmdStoredProc
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 1, g_intViewTypeCIC)
		.CommandTimeout = 0
		Set rsListPub = .Execute
	End With

	With rsListPub
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=""PBID"">"
			Dim strPubName
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("PB_ID") & """"
				strPubName = .Fields("PubCode") & _
					IIf(Nl(.Fields("PubName")),vbNullString," - " & .Fields("PubName")) & _
					IIf(.Fields("NonPublic") = SQL_FALSE, vbNullString, " *")
				strReturn = strReturn & ">" & strPubName & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
%>
<form action="update_pubs_add.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="NUM" value="<%=strNUM%>">
<%			If intCurSearchNumber >= 0 Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%			End If%>
	<tr>
		<td colspan="5"><%=strReturn%></td>
		<td><%=ADD_BUTTON%></td>
	</tr>
</form>
	</tbody>
</table>
<%

	Set rsPublication = rsPublication.NextRecordset
	With rsPublication
		If Not .EOF Then
%>
<h3><%=TXT_ADDITIONAL_PUBLICATIONS%></h3>
<p><%=TXT_PUBS_NOT_AVAILABLE_TO_EDIT%></p>
<table class="BasicBorder cell-padding-2">
<tr>
	<th><%=TXT_CODE%></th>
	<th><%=TXT_NAME%></th>
</tr>
<%
			While Not .EOF
%>
<tr>
	<td><%=.Fields("PubCode")%></td>
	<td><%=Server.HTMLEncode(Ns(.Fields("PubName")))%></td>
</tr>
<%
				.MoveNext
			Wend
%>
</table>
<%
		End If
	End With

End If
%>
<%
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->

