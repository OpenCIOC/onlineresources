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
Call setPageInfo(True, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtPrintList.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/print/incPrintProfileList.asp" -->
<!--#include file="../includes/publication/incPubList.asp" -->

<%
Call makePageHeader(TXT_PRINT_RECORD_LIST, TXT_PRINT_RECORD_LIST, True, False, True, True)

Dim bProfilePicked, _
	strIDList, _
	strOB, _
	intProfileID, _
	strMessage, _
	intLen

bProfilePicked = Request("Picked") = "on"
strIDList = Request("IDList")
intProfileID = Request("ProfileID")

If Nl(strIDList) Then
	Call handleError(TXT_NO_RECORDS_TO_PRINT, vbNullString, vbNullString)
ElseIf Nl(intProfileID) Then
	If bProfilePicked Then
		Call handleError(TXT_NO_PROFILE_CHOSEN, vbNullString, vbNullString)
	End If
%>
<!--#include file="../includes/print/incPrintOptions.asp" -->
<%
Else
	Dim cmdProfileMessage, rsProfileMessage
	Set cmdProfileMessage = Server.CreateObject("ADODB.Command")
	With cmdProfileMessage
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_PrintProfile_Msg_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, ps_intDbArea)
	End With
	Set rsProfileMessage = cmdProfileMessage.Execute
	If Not rsProfileMessage.EOF Then
		strMessage = rsProfileMessage.Fields("DefaultMsg")
	End If
	rsProfileMessage.Close
	Set rsProfileMessage = Nothing
	Set cmdProfileMessage = Nothing
%>
<form action="printlist2.asp" method="post" target="_BLANK">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="ProfileID" value="<%=intProfileID%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="hidden" name="SortBy" value="<%=Request("SortBy")%>">
<%If Request("IncludeDeleted")="on" Then%>
<input type="hidden" name="IncludeDeleted" value="on">
<%End If%>
<%If Request("IncludeExpired")="on" Then%>
<input type="hidden" name="IncludeExpired" value="on">
<%End If%>
</div>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox"><%=TXT_INST_CUSTOMIZE%></th></tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MESSAGE%></td>
<%
If Nl(strMessage) Then
	intLen = 0
Else
	intLen = Len(strMessage)
	strMessage = Server.HTMLEncode(strMessage)
End If
%>
	<td><span class="SmallNote"><%=TXT_HTML_ALLOWED%></span>
	<br><textarea name="Msg" wrap="soft" rows="<%=getTextAreaRows(intLen,5)%>" cols="<%=TEXTAREA_COLS%>"><%=strMessage%></textarea></td>
</tr>
</table>
<input type="submit" value="<%=TXT_NEXT & " " & TXT_NEW_WINDOW%> >>">
</form>
<%
End If
Call makePageFooter(True)
%>

<!--#include file="../includes/core/incClose.asp" -->
