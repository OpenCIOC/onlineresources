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

<%
If Not user_bCanManageMembers Then
	Call securityFailure()
End If

Dim strError,bError,strTarget
strTarget = "Renewal"

bError = False
strError = vbNullString

Const ACTION_UPDATE = 1
Const ACTION_DELETE = 2
Const ACTION_ADD = 3

Dim intActionType, _
	strActionType, _
	intVMRID, _
	intVMemID, _
	intVMInvID, _
	strRenewalDate, _
	strNextRenewalDate

Select Case Request("Submit")
	Case TXT_UPDATE
		intActionType = ACTION_UPDATE
		strActionType = TXT_UPDATED
	Case TXT_DELETE
		intActionType = ACTION_DELETE
		strActionType = TXT_DELETED
	Case "Submit Changes"
		intActionType = ACTION_ADD
		strActionType = TXT_ADDED
	Case Else
		bError = True
		strError = TXT_NO_ACTION
End Select

intVMemID = Trim(Request("VMemID"))
If Not bError And Not IsIDType(intVMemID) Then
	bError = True
	strError = "Volunteer Member ID is not valid."
End If

If Not bError And intActionType <> ACTION_ADD Then
	intVMRID = Trim(Request("VMRID"))
	If Nl(intVMRID) Then
		bError = True
		strError = "No Volunteer Member Renewal selected."
	ElseIf Not IsIDType(intVMRID) Then
		bError = True
		strError = "Volunteer Member Renewal ID is not valid."
	End If
End If

intVMInvID = Trim(Request("VMInvID"))
If Nl(intVMInvID) Then
	intVMInvID = Null
ElseIf Not bError And Not IsIDType(intVMInvID) Then
	bError = True
	strError = "Invoice ID is not valid."
End If

If Not bError And intActionType <> ACTION_DELETE Then
	strRenewalDate = Trim(Request("RenewalDate"))
	If intActionType = ACTION_ADD And Nl(strRenewalDate) Then
		strRenewalDate = Null
		strActionType = TXT_UPDATED
		strTarget = "Next Renewal Date"
	ElseIf Not IsDate(strRenewalDate) Then
		bError = True
		strError = "Renewal Date is not valid."
	End If
End If

If Not bError And intActionType = ACTION_ADD Then
	strNextRenewalDate = Trim(Request("NextRenewalDate"))
	If Nl(strNextRenewalDate) Then
		strNextRenewalDate = Null
	ElseIf Not IsDate(strNextRenewalDate) Then
		bError = True
		strError = "Next Renewal Date is not valid."
	End If
End If

If Not bError Then

	Dim objReturn, objErrMsg
	Dim cmdViewComms, rsViewComms
	Set cmdViewComms = Server.CreateObject("ADODB.Command")
	With cmdViewComms
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Select Case intActionType
			Case ACTION_UPDATE
				.CommandText = "dbo.sp_VOL_Member_Renewal_u"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@VMR_ID", adInteger, adParamInput, 4, intVMRID)
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				.Parameters.Append .CreateParameter("@RenewalDate", adDBDate, adParamInput, 2, strRenewalDate)
				.Parameters.Append .CreateParameter("@VMINV_ID", adInteger, adParamInput, 4, intVMInvID)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
			Case ACTION_ADD
				.CommandText = "dbo.sp_VOL_Member_Renewal_i"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@VMEM_ID", adInteger, adParamInput, 4, intVMemID)
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				.Parameters.Append .CreateParameter("@RenewalDate", adDBDate, adParamInput, 2, strRenewalDate)
				.Parameters.Append .CreateParameter("@NextRenewalDate", adDBDate, adParamInput, 2, strNextRenewalDate)
				.Parameters.Append .CreateParameter("@VMINV_ID", adInteger, adParamInput, 4, intVMInvID)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
			Case ACTION_DELETE
				.CommandText = "dbo.sp_VOL_Member_Renewal_d"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@VMR_ID", adInteger, adParamInput, 4, intVMRID)
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
		End Select
	End With

	Set rsViewComms = cmdViewComms.Execute
	'Call rsViewComms.Close

	If objReturn.Value = 0 And Err.Number = 0 Then
		Call handleMessage("The " & strTarget & " was " & strActionType & " successfully.", _
			"member_renewals.asp", _
			"VMemID=" & intVMemID, _
			False)
	Else
		bError = True
		If Err.Number <> 0 Then
			strError = Server.HTMLEncode(Err.Description)
		Else
			strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
		End If
	End If

	Set rsViewComms = Nothing
	Set cmdViewComms = Nothing
	
End If

If bError Then
	Call makePageHeader("Volunteer Member Organization Renewals", "Volunteer Member Organization Renewals", True, False, True, True)
	Call handleError("The " & strTarget & " was not " & strActionType & TXT_COLON & strError, _
		vbNullString, _
		vbNullString)
	Call makePageFooter(False)
End If
%>


<!--#include file="../includes/core/incClose.asp" -->


