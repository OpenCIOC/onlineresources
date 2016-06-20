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
<!--#include file="text/txtGeneralHeading.asp" -->
<!--#include file="includes/core/incRExpFuncs.asp" -->
<%
If Not user_intCanUpdatePubs = UPDATE_ALL Then
	Call securityFailure()
End If

Dim bError
bError = False

Dim	intPBID, _
	intCopyPBID, _
	strCopyGHList

intPBID = Request("PBID")
If Nl(intPBID) Then
	intPBID = Null
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUB, _
		"publication", vbNullString)
ElseIf Not IsIDType(intPBID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intPBID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUB, _
		"publication", vbNullString)
Else
	intPBID = CLng(intPBID)
End If

intCopyPBID = Request("CopyPBID")
If Nl(intCopyPBID) Then
	intCopyPBID = Null
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUB, _
		"publication", vbNullString)
ElseIf Not IsIDType(intPBID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intCopyPBID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUB, _
		"publication", vbNullString)
Else
	intCopyPBID = CLng(intCopyPBID)
End If

strCopyGHList = Request("IDList")
If Nl(strCopyGHList) Then
	strCopyGHList = Null
	bError = True
	Call makePageHeader(TXT_UPDATE_HEADING_FAILED, TXT_UPDATE_HEADING_FAILED, True, False, True, True)
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_USE_BACK_BUTTON, _
		vbNullString, vbNullString)
	Call makePageFooter(True)
ElseIf Not IsIDList(strCopyGHList) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strCopyGHList) & ".", _
		"publication/edit", "PB_ID=" & intPBID)
End If

If user_bLimitedViewCIC And Not user_intPBID=intPBID Then
	Call securityFailure()
End If

If Not bError Then

Dim objReturn, objErrMsg

Dim cmdUpdateGeneralHeading, rsUpdateGeneralHeading
Set cmdUpdateGeneralHeading = Server.CreateObject("ADODB.Command")
With cmdUpdateGeneralHeading
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Prepared = False
	.CommandText = "dbo.sp_CIC_GeneralHeading_u_Copy"
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@PB_ID", adInteger, adParamInput, 4, intPBID)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@SuperUserGlobal", adBoolean, adParamInput, 1, IIf(user_bSuperUserGlobalCIC,SQL_TRUE,SQL_FALSE))
	.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strCopyGHList)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With

Set rsUpdateGeneralHeading = cmdUpdateGeneralHeading.Execute
Set rsUpdateGeneralHeading = rsUpdateGeneralHeading.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED, _
			"pubs_edit_gh_copy.asp", "PBID=" & intPBID & "&CopyPBID=" & intCopyPBID, False)
	Case Else
		Call makePageHeader(TXT_UPDATE_HEADING_FAILED, TXT_UPDATE_HEADING_FAILED, True, False, True, True)
		Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			vbNullString, _
			vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
		Call makePageFooter(True)
End Select

If Err.Number = 0 Then
	
Else
	Dim strErrorMessage
	strErrorMessage = Err.Description
	
End If

End If
%>
<!--#include file="includes/core/incClose.asp" -->

