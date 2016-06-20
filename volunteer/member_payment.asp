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

Dim strError,bError

bError = False
strError = vbNullString

Const ACTION_UPDATE = 1
Const ACTION_ADD = 2

Dim intActionType, _
	strActionType, _
	intVMInvID, _
	intVMPmtID, _
	strPaymentDate, _
	strPaymentAmount, _
	bPaymentVoid,_
	strNotes

Select Case Request("Submit")
	Case TXT_UPDATE
		intActionType = ACTION_UPDATE
		strActionType = TXT_UPDATED
	Case TXT_ADD
		intActionType = ACTION_ADD
		strActionType = TXT_ADDED
	Case Else
		bError = True
		strError = TXT_NO_ACTION
End Select

intVMInvID = Trim(Request("VMInvID"))
If Not bError And Not IsIDType(intVMInvID) Then
	bError = True
	strError = "Volunteer Invoice ID is not valid."
End If

If Not bError And intActionType <> ACTION_ADD Then
	intVMPmtID = Trim(Request("VMPmtID"))
	If Nl(intVMPmtID) Then
		bError = True
		strError = "No Volunteer Payment selected."
	ElseIf Not IsIDType(intVMPmtID) Then
		bError = True
		strError = "Volunteer Member Payment ID is not valid."
	End If
End If

strPaymentDate = Trim(Request("PaymentDate"))
If Not bError And Not IsSmallDate(strPaymentDate) Then
	bError = True
	strError = "Payment Date is not valid."
End If

strPaymentAmount = Trim(Request("PaymentAmount"))
If Not bError And Not IsNumeric(strPaymentAmount) Then
	bError = True
	strError = "Payment Amount is not valid."
End If

bPaymentVoid = Not Nl(Trim(Request("PaymentVoid")))

strNotes = Trim(Request("Notes"))
If Nl(strNotes) Then
	strNotes = Null
End If

If Not bError Then

Dim objReturn, objErrMsg
Dim cmdPayment, rsPayment
Set cmdPayment = Server.CreateObject("ADODB.Command")
With cmdPayment
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	Select Case intActionType
		Case ACTION_UPDATE
			.CommandText = "dbo.sp_VOL_Member_Payment_u"
			.Parameters.Append .CreateParameter("@VMPMT_ID", adInteger, adParamInput, 4, intVMPmtID)
			.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		Case ACTION_ADD
			.CommandText = "dbo.sp_VOL_Member_Payment_i"
			.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@VMINV_ID", adInteger, adParamInput, 4, intVMInvID)
	End Select
	.Parameters.Append .CreateParameter("@PaymentDate", adDBDate, adParamInput, 2, strPaymentDate)
	.Parameters.Append .CreateParameter("@PaymentAmount", adDouble, adParamInput, 8, strPaymentAmount)
	.Parameters.Append .CreateParameter("@PaymentVoid", adBoolean, adParamInput, 1, bPaymentVoid)
	.Parameters.Append .CreateParameter("@Notes", adVarChar, adParamInput, 255, strNotes)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
	.CommandTimeout = 0
End With

Set rsPayment = cmdPayment.Execute
Set rsPayment = rsPayment.NextRecordset

If Err.Number = 0 And objReturn.Value = 0 Then
	Call handleMessage("The Payment was " & strActionType & " successfully.", _
		"member_inv_edit.asp", _
		"VMInvID=" & intVMInvID & "&VMemID=" & Trim(Request("VMemID")), _
		False)
Else
	bError = True
	strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
End If

Set rsPayment = Nothing
Set cmdPayment = Nothing

End If

If bError Then
	Call makePageHeader("Volunteer Member Organization Payment", "Volunteer Member Organization Payment", True, False, True, True)

	Call handleError("The Payment was not " & strActionType & TXT_COLON & strError, _
		vbNullString, _
		vbNullString)
	Call makePageFooter(False)
End If

%>
<!--#include file="../includes/core/incClose.asp" -->


