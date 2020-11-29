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
Call setPageInfo(True, DM_CIC, DM_CIC, "../", "import/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtImport.asp" -->

<%
If Not user_bImportPermissionCIC Then
	Call securityFailure()
End If

Dim bConfirmed, bUnarchive
bConfirmed = Request("Confirmed") = "on"
bUnarchive = Request("Unarchive") = "on"

Dim intEFID
intEFID = Request("EFID")

If Nl(intEFID) Then
	Call makePageHeader(TXT_ARCHIVE_DATASET, IIf(bUnarchive, TXT_UNARCHIVE_DATASET, TXT_ARCHIVE_DATASET), True, False, True, True)
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
	Call makePageFooter(False)
ElseIf Not IsIDType(intEFID) Then
	Call makePageHeader(TXT_ARCHIVE_DATASET, IIf(bUnarchive, TXT_UNARCHIVE_DATASET, TXT_ARCHIVE_DATASET), True, False, True, True)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intEFID) & ".", vbNullString, vbNullString)
	Call makePageFooter(False)
Else
	intEFID = CLng(intEFID)

If Not bConfirmed Then
	Call makePageHeader(TXT_ARCHIVE_DATASET, IIf(bUnarchive, TXT_UNARCHIVE_DATASET, TXT_ARCHIVE_DATASET), True, False, True, True)
%>
<p><span class="AlertBubble"><%=IIf(bUnarchive,TXT_ARE_YOU_SURE_UNARCHIVE,TXT_ARE_YOU_SURE_ARCHIVE)%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="EFID" value="<%=intEFID%>">
<input type="hidden" name="Confirmed" value="on">
<% If bUnarchive Then %>
<input type="hidden" name="Unarchive" value="on">
<% End If %>
<input type="submit" name="Submit" value="<%=IIf(bUnarchive, TXT_UNARCHIVE, TXT_ARCHIVE)%>">
</form>
<%
	Call makePageFooter(False)
Else

	Dim objReturn, objErrMsg

	Dim cmdDeleteImportEntry, rsDeleteImportEntry
	Set cmdDeleteImportEntry = Server.CreateObject("ADODB.Command")

	With cmdDeleteImportEntry
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_u_Archive"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@EF_ID", adInteger, adParamInput, 4, intEFID)
		.Parameters.Append .CreateParameter("@Unarchive", adBoolean, adParamInput, 1, IIf(bUnarchive, SQL_TRUE, SQL_FALSE))
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With

	Set rsDeleteImportEntry = cmdDeleteImportEntry.Execute
	Set rsDeleteImportEntry = rsDeleteImportEntry.NextRecordset

	Select Case objReturn.Value
		Case 0
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & IIf(bUnarchive, TXT_UNARCHIVED, TXT_ARCHIVED), _
				"import.asp", _
				StringIf(bUnarchive, "Archived=on"), _
				False)
		Case Else
			Call handleError(TXT_RECORDS_WERE_NOT & IIf(bUnarchive, TXT_UNARCHIVED, TXT_ARCHIVED) & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
				"import.asp", _
				StringIf(bUnarchive, "Archived=on"))
	End Select
	
End If

End If
%>
<!--#include file="../includes/core/incClose.asp" -->
