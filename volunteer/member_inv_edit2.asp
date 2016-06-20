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

Dim intVMemID, bError, strError

intVMemID = Request("VMemID")
bError = False

If Nl(intVMemID) Then
	bError = True
	strError = TXT_NO_RECORD_CHOSEN
ElseIf Not IsIDType(intVMemID) Then
	bError = True
	strError = "Invalid Volunteer Member ID" & TXT_COLON & Server.HTMLEncode(intVMemID) & "."

End If

Dim intVMInvID
intVMInvID = Request("VMInvID")

If Nl(intVMInvID) Then
	intVMInvID = Null
ElseIf Not IsIDType(intVMInvID) Then
	If Not bError Then
		bError = True
		strError = "Invalid Invoice ID" & TXT_COLON & Server.HTMLEncode(intVMInvID) & "."
	End If
End If

Dim strInvoiceNumber, strInvoiceDate, strPaymentDueDate, strInvoiceAmount, _
	bInvoiceVoid

If Not bError Then
	strInvoiceNumber = Request("InvoiceNumber")
	If Nl(strInvoiceNumber) Then
		strInvoiceNumber = Null
	End If
End If

If Not bError Then
	strInvoiceDate = Request("InvoiceDate")
	If Not IsSmallDate(strInvoiceDate) Then
		bError = True
		strError = "The Invoice Date is invalid."
	End If
End If

If Not bError Then
	strPaymentDueDate = Request("PaymentDueDate")
	If Not IsSmallDate(strPaymentDueDate) Then
		bError = True
		strError = "The Payment Due Date is invalid."
	End If
End If

If Not bError Then
	strInvoiceAmount = Request("InvoiceAmount")
	If Not IsNumeric(strInvoiceAmount) Then
		bError = True
		strError = "The Invoice Amount is invalid."
	End If
End If

bInvoiceVoid = Not Nl(Request("InvoiceVoid"))

If Not bError Then
	Dim cmdInvoice, rsInvoice
	Set cmdInvoice = Server.CreateObject("ADODB.Command")
	With cmdInvoice
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		If Nl(intVMInvID) Then
			.CommandText = "dbo.sp_VOL_Member_Invoice_i"
			.Parameters.Append .CreateParameter("@VMINV_ID", adInteger, adParamOutput, 4)
			.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@VMEM_ID", adInteger, adParamInput, 4, intVMemID)
		Else
			.CommandText = "dbo.sp_VOL_Member_Invoice_u"
			.Parameters.Append .CreateParameter("@VMINV_ID", adInteger, adParamInput, 4, intVMInvID)
			.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		End If
		.Parameters.Append .CreateParameter("@InvoiceNumber", adVarChar, adParamInput, 10, strInvoiceNumber)
		.Parameters.Append .CreateParameter("@InvoiceDate", adDBDate, adParamInput, 2, strInvoiceDate)
		.Parameters.Append .CreateParameter("@PaymentDueDate", adDBDate, adParamInput, 2, strPaymentDueDate)
		.Parameters.Append .CreateParameter("@InvoiceAmount", adDouble, adParamInput, 8, strInvoiceAmount)
		.Parameters.Append .CreateParameter("@InvoiceVoid", adBoolean, adParamInput, 1, bInvoiceVoid)

		If Nl(intVMInvID) Then
			
		End If

		.Parameters.Append .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	End With


	Set rsInvoice = cmdInvoice.Execute

	strError = cmdInvoice.Parameters("@ErrMsg")

	If Err.Number = 0 And Nl(strError) Then
		Dim strActionType
		If Nl(intVMInvID) Then
			intVMInvID = cmdInvoice.Parameters("@VMINV_ID")
			strActionType = "added"
		Else
			strActionType = "updated"
		End If
		Call handleMessage("The Invoice was " & strActionType & " successfully.", _
			"member_inv_edit.asp", _
			"VMemID=" & intVMemID & "&VMInvID=" & intVMInvID, _
			False)
	Else
		bError = True
		strError = Server.HTMLEncode(Err.Description & " " & strError)
	End If

	Set rsInvoice = Nothing
	Set cmdInvoice = Nothing

End If

If bError Then
	Call makePageHeader("Volunteer Member Organization Invoices", "Volunteer Member Organization Invoices", True, False, True, True)

	Call handleError("The Invoice was not " & IIf(Nl(intVMInvID), "added", "updated") & TXT_COLON & strError, _
		vbNullString, _
		vbNullString)
	Call makePageFooter(False)
End If
%>

<!--#include file="../includes/core/incClose.asp" -->


