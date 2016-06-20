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
'
' Purpose: 
'
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
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtAgency.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<%

Dim bError, _
	strErrorMessage

bError = False

If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
	bError = True
End If

If Not bError Then
	Dim	strShowForeignAgencies
	strShowForeignAgencies = Request("ShowForeignAgency")

	Dim objReturn, objErrMsg

	Dim cmdUpdateAgency, rsUpdateAgency
	Set cmdUpdateAgency = Server.CreateObject("ADODB.Command")
	With cmdUpdateAgency 	
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_Agency_u_Foreign"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 1, g_intMemberID)
		.Parameters.Append .CreateParameter("@ForeignAgencies", adLongVarChar, adParamInput, -1, Nz(strShowForeignAgencies,Null))
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With

	Set rsUpdateAgency = cmdUpdateAgency.Execute
	Set rsUpdateAgency = rsUpdateAgency.NextRecordset

	Select Case objReturn.Value
		Case 0
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
				"agencies.asp", _
				vbNullString, _
				False)
		Case Else
			strErrorMessage = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End Select
End If

If bError Or Not Nl(strErrorMessage) Then
	Call makePageHeader(TXT_UPDATE_AGENCY_FAILED, TXT_UPDATE_AGENCY_FAILED, True, False, True, True)
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & strErrorMessage, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
