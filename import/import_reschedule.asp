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

Dim bConfirmed
bConfirmed = Request("Confirmed") = "on"

Dim strERIDList, strEFID
strERIDList = Request("ERID")
strEFID = Request("EFID")

If Nl(strERIDList) Then
	Call makePageHeader(TXT_RESCHEDULE_RECORD, TXT_RESCHEDULE_RECORD, True, False, True, True)
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
	Call makePageFooter(False)
ElseIf Not IsIDList(strERIDList) Then
	Call makePageHeader(TXT_RESCHEDULE_RECORD, TXT_RESCHEDULE_RECORD, True, False, True, True)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strERIDList) & ".", vbNullString, vbNullString)
	Call makePageFooter(False)
Else
	strERIDList = strERIDList

If Not bConfirmed Then
	Call makePageHeader(TXT_RESCHEDULE_RECORD, TXT_RESCHEDULE_RECORD, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_RESCHEDULE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ERID" value="<%=strERIDList%>">
<input type="hidden" name="EFID" value="<%=strEFID%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" name="Submit" value="<%=TXT_RESCHEDULE%>">
</form>
<%
	Call makePageFooter(False)
Else

	Dim objReturn, objErrMsg

	Dim cmdRescheduleImportData, rsRescheduleImportData
	Set cmdRescheduleImportData = Server.CreateObject("ADODB.Command")

	With cmdRescheduleImportData
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Data_u_Reschedule_iCarol"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ER_ID_List", adLongVarChar, adParamInput, -1, strERIDList)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With

	Set rsRescheduleImportData = cmdRescheduleImportData.Execute
	Set rsRescheduleImportData = rsRescheduleImportData.NextRecordset

	Select Case objReturn.Value
		Case 0
			Call handleMessage(TXT_RECORD_WAS_SUCCESSFULLY & TXT_RESCHEDULED & TXT_AND_WILL_BE_TOMORROW, _
				"import_report.asp", _
				"EFID=" & strEFID, _
				False)
		Case Else
			Call handleError(TXT_RECORD_WAS_NOT & TXT_RESCHEDULED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
				"import_report.asp", _
				"EFID=" & strEFID)
	End Select
	
End If

End If
%>
<!--#include file="../includes/core/incClose.asp" -->
