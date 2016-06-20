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
<!--#include file="../../includes/core/adovbs.inc" -->
<!--#include file="../../includes/core/incVBUtils.asp" -->
<!--#include file="../../includes/validation/incBasicTypes.asp" -->
<!--#include file="../../includes/core/incRExpFuncs.asp" -->
<!--#include file="../../includes/core/incHandleError.asp" -->
<!--#include file="../../includes/core/incSetLanguage.asp" -->
<!--#include file="../../includes/core/incPassVars.asp" -->
<!--#include file="../../text/txtGeneral.asp" -->
<!--#include file="../../text/txtError.asp" -->
<!--#include file="../../includes/core/incConnection.asp" -->
<!--#include file="../../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_VOL, DM_VOL, "../../", "volunteer/profile/", vbNullString)
%>
<!--#include file="../../includes/core/incCrypto.asp" -->
<!--#include file="../../includes/core/incSecurity.asp" -->
<!--#include file="../../includes/core/incHeader.asp" -->
<!--#include file="../../includes/core/incFooter.asp" -->
<!--#include file="../../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../../text/txtFormDataCheck.asp" -->
<!--#include file="../../text/txtGeneralForm.asp" -->
<!--#include file="../../includes/core/incFormat.asp" -->
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->
<!--#include file="../../includes/validation/incFormDataCheck.asp" -->
<%
If Not g_bUseVolunteerProfiles Then
	Call goToPageB(ps_strPathToStart & "volunteer/")
ElseIf Not vprofile_bLoggedIn Then
	Call goToPage("login.asp", "page=" & Server.URLEncode(ps_strThisPageFull) & "&args="&Server.URLEncode("RefID="& Trim(Request("RefID"))), vbNullString)
End If

Dim intRefID, _
	bConfirmed,_
	bSQLError, _
	bValidationError, _
	strErrorList

bSQLError = False
bValidationError = False
strErrorList = vbNullString

intRefID = Trim(Request("RefID"))
Call checkID("Application ID", intRefID)

bConfirmed = Not Nl(Trim(Request("Confirm")))

Dim strNotes, bSuccessfulPlacement
strNotes = Null
bSuccessfulPlacement = Null

If Not Nl(strErrorList) Then
	bValidationError = True
ElseIf bConfirmed Then
	Dim objReturn, objErrMsg
	Dim cmdOutcomeData, rsOutcomeData
	Set cmdOutcomeData = Server.CreateObject("ADODB.Command")
	With cmdOutcomeData
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "sp_VOL_OP_Referral_u_VProfile_Hide"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@Return", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, vprofile_strID)
		.Parameters.Append .CreateParameter("@REF_ID", adInteger, adParamInput, 4, intRefID)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsOutcomeData = cmdOutcomeData.Execute()

	If objReturn.Value <> 0 Then
		bSQLError = True
		strErrorList = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End If
	Set rsOutcomeData = Nothing
	Set cmdOutcomeData = Nothing
End If
If bSQLError Then
	Call handleError(TXT_ERROR & strErrorList, vbNullString, vbNullString)
ElseIf bValidationError Then
	Call handleError(TXT_ERROR, vbNullString, vbNullString)
	%><ul><%=strErrorList%></ul>
	<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a> ]</p><%
End If
%>

<!--#include file="../../includes/core/incClose.asp" -->


