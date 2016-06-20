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
Call setPageInfo(True, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtReviewFeedback.asp" -->
<%
If Not user_bCanAssignFeedbackCIC Then
	Call securityFailure()
End If

Dim strFBList
strFBList = Trim(Request("AssignFB"))

If Nl(strFBList) Then
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		"revfeedback.asp", vbNullString)
ElseIf Not IsIDList(strFBList) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strFBList) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_FEEDBACK, _
		"revfeedback.asp", vbNullString)
End If

Dim strAgency
strAgency = Nz(Left(Trim(Request("AssignTo")),3),user_strAgency)

Dim objReturn, objErrMsg
Dim cmdAssignFb, rsAssignFb
Set cmdAssignFb = Server.CreateObject("ADODB.Command")
With cmdAssignFb
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_Feedback_Assign"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strFBList)
	.Parameters.Append .CreateParameter("@FEEDBACK_OWNER", adVarChar, adParamInput, 3, strAgency)
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsAssignFb = cmdAssignFb.Execute
Set rsAssignFb = rsAssignFb.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_ASSIGNED, _
			"revfeedback.asp", _
			vbNullString, _
			False)
	Case Else
		Call handleError(TXT_RECORDS_WERE_NOT & TXT_ASSIGNED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			"revfeedback.asp", _
			vbNullString)
End Select
%>
<!--#include file="includes/core/incClose.asp" -->
