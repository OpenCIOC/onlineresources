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
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../includes/update/incEntryFormGeneral.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->


<%
If Not user_bCanManageMembers Then
	Call securityFailure()
End If

Dim intVMemID, _
	bError, _
	strError
	
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

If Not bError Then

	Dim cmdMemberInv, rsMemberInv
	Set cmdMemberInv = Server.CreateObject("ADODB.Command")
	With cmdMemberInv
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		If Not Nl(intVMInvID) Then
			.CommandText = "dbo.sp_VOL_Member_Invoice_s"
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@VMINV_ID", adInteger, adParamInput, 4, intVMInvID)
		Else
			.CommandText = "dbo.sp_VOL_Member_s_MinInvoiceNumber"
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@VMEM_ID", adInteger, adParamInput, 4, intVMemID)
		End If
		Set rsMemberInv = .Execute
	End With
	If rsMemberInv.EOF Then
		bError = True
		strError = TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(IIf(Nl(intVMInvID), intVMemID, intVMInvID)) & "."
		rsMemberInv.Close()
		Set rsMemberInv = Nothing
		Set cmdMemberInv = Nothing
	End If

End If

Dim strOrgName, strNUM
strOrgName = vbNullString
If Not bError Then
	strOrgName = rsMemberInv.Fields("ORG_NAME_FULL")
	strNUM=rsMemberInv("NUM")
End If

Dim strInvoiceNumber, strInvoiceDate, strPaymentDueDate, strInvoiceAmount, _
	bInvoiceVoid, strAmountOwing, strNextInvoiceNum


Call makePageHeader("Volunteer Member Organization", "Volunteer Member Organization" & TXT_COLON & strOrgName, True, False, True, True)

If bError Then
	Call handleError(strError, vbNullString, vbNullString)
Else
	If Nl(intVMInvID) Then
		strNextInvoiceNum = rsMemberInv("NextInvoiceNum")
		If Nl(strNextInvoiceNum) Then
			strNextInvoiceNum = "1"
		End If

		rsMemberInv.Close()
		Set rsMemberInv = Nothing
		Set cmdMemberInv = Nothing

		strInvoiceNumber = vbNullString
		strInvoiceDate = vbNullString 
		strPaymentDueDate = vbNullString
		strInvoiceAmount = vbNullString
		bInvoiceVoid = False
		strAmountOwing = vbNullString
	Else
		With rsMemberInv
			strInvoiceNumber = .Fields("InvoiceNumber")
			strInvoiceDate = .Fields("InvoiceDate")
			strPaymentDueDate = .Fields("PaymentDueDate")
			strInvoiceAmount = .Fields("InvoiceAmount")
			bInvoiceVoid = .Fields("InvoiceVoid")
			strAmountOwing = .Fields("AmountOwing")
		End With

		Set rsMemberInv = rsMemberInv.NextRecordset

	End If

	Dim strOneMonth
	strOneMonth = DateString(DateAdd("m",1,Date()),True)

	%>
<h1><%=strOrgName%></h1>
<p style="font-weight:bold">[ <a href="<%=makeLink("member_invoices.asp", "VMemID=" & intVMemID, vbNullString)%>">Return to Volunteer Member Invoice Summary</a> ]</p>
		<form action="member_inv_edit2.asp" method="post" name="EntryForm">
		<%=g_strCacheFormVals%>
		<input type="hidden" name="VMemID" value="<%=intVMemID%>">
		<input type="hidden" name="VMInvID" value="<%=intVMInvID%>">

	<table class="BasicBorder cell-padding-3">
	<!--
	<tr>
		<td colspan="2" class="TitleBox" align="center"><h2><%=strOrgName%></h2></td>
	</tr>
	-->

	<tr><th colspan="2" class="RevTitleBox">Invoice Details</th></tr>
	<tr><td class="FieldLabelLeft">Invoice Number</td><td><input type="text" name="InvoiceNumber" value=<%=AttrQs(strInvoiceNumber)%> size="10" maxlength="10"><%If Nl(intVMInvID) Then%> <input type="button" value="Next Available" onClick="document.EntryForm.InvoiceNumber.value='<%=strNextInvoiceNum%>';"><%End If%></td></tr>
	<tr><td class="FieldLabelLeft">Invoice Date</td><td><%=makeDateFieldVal("InvoiceDate", strInvoiceDate, True, False, False, False, False, False)%></td></tr>
	<tr><td class="FieldLabelLeft">Payment Due Date</td><td><%=makeDateFieldVal("PaymentDueDate", strPaymentDueDate, False, False, False, False, False, False)%> <input type="button" value="1 Month" onClick="document.EntryForm.PaymentDueDate.value='<%=strOneMonth%>';"></td></tr>
	<tr><td class="FieldLabelLeft">Invoice Amount</td><td><input type="text" name="InvoiceAmount" value=<%If Nl(strInvoiceAmount) Then%>""<%Else%><%=AttrQs(FormatNumber(strInvoiceAmount, 2, -1))%><%End If%> size="10" maxlength="10"></td></tr>
	<tr><td class="FieldLabelLeft">Invoice Void</td><td><input type="checkbox" name="InvoiceVoid" <%=IIf(bInvoiceVoid, "checked", vbNullString)%>></td></tr>
	<tr>
		<td colspan="2" align="center"><input type="submit" value="<%=TXT_SUBMIT%>"> <input type="reset" value="<%=TXT_CLEAR_FORM%>"></td>
	</tr>
	</table>
	</form>
	<%
	
	If Not Nl(intVMInvID) Then
		Dim dblAmountOwing
		dblAmountOwing = CDbl(strInvoiceAmount)
	%>
	<h2>Payment History</h2>
	<%
	If rsMemberInv.EOF Then
		rsMemberInv.Close()
		Set rsMemberInv = Nothing
		Set cmdMemberInv = Nothing
		%><p>No payments have been made.</p><%
	Else
	%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox">Date</th>
	<th class="RevTitleBox">Amount</th>
	<th class="RevTitleBox">Void</th>
	<th class="RevTitleBox">Notes</th>
	<th class="RevTitleBox">Action</th>
</tr>
	<%
		With rsMemberInv
		Dim intVMPmtID, strPaymentDate, dblPaymentAmount, bPaymentVoid, strNotes

			While Not .EOF
				
				intVMPmtID = .Fields("VMPMT_ID")
				strPaymentDate = .Fields("PaymentDate")
				dblPaymentAmount = .Fields("PaymentAmount")
				bPaymentVoid = .Fields("PaymentVoid")
				strNotes = .Fields("Notes")
				If Nl(strNotes) Then
					strNotes = vbNullString
				End If

				dblAmountOwing = dblAmountOwing - CDbl(dblPaymentAmount)
%>
<tr valign="TOP">
<form method="post" action="member_payment.asp">
<%=g_strCacheFormVals%>
<input type="hidden" name="VMPmtID" value="<%=intVMPmtID%>">
<input type="hidden" name="VMInvID" value="<%=intVMInvID%>">
<input type="hidden" name="VMemID" value="<%=intVMemID%>">
<td><%=makeDateFieldVal("PaymentDate", strPaymentDate, False, False, False, False, False, False)%></td>
<td><input type="text" name="PaymentAmount" value=<%=AttrQs(FormatNumber(dblPaymentAmount,2, True))%> size="10" maxlength="10"></td>
<td><input type="checkbox" name="PaymentVoid" <%=IIf(bPaymentVoid,"checked", vbNullString)%>></td>
<td><input type="text" name="Notes" value=<%=AttrQs(strNotes)%> size="<%=TEXT_SIZE%>" maxlength="<%=MAX_LENGTH_CHECKLIST_NOTES%>"></td>
<td><input name="Submit" type="submit" value="<%=TXT_UPDATE%>"></td>
</form>
</tr>
<%
				.MoveNext

			Wend
		End With

		rsMemberInv.Close()
		Set rsMemberInv = Nothing
		Set cmdMemberInv = Nothing
%>
</table>
<%
		End If
%>
	<h2>Add Payment</h2>
	<form method="post" action="member_payment.asp" name="PaymentForm">
	<%=g_strCacheFormVals%>
	<input type="hidden" name="VMInvID" value="<%=intVMInvID%>">
	<input type="hidden" name="VMemID" value="<%=intVMemID%>">
	<table class="BasicBorder cell-padding-3">
	<tr>
		<td class="FieldLabelLeft">Payment Date</td>
		<td><%=makeDateFieldVal("PaymentDate", strPaymentDate, False, False, False, False, False, False)%> <input type="button" value="<%=TXT_TODAY%>" onClick="document.PaymentForm.PaymentDate.value='<%=DateString(Now(), True)%>';"></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft">Payment Amount</td>
		<td><input type="text" name="PaymentAmount" size="10" maxlength="10"> <input type="button" value="Full Payment" onClick="document.PaymentForm.PaymentAmount.value='<%=FormatNumber(dblAmountOwing, 2, True)%>';"></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft">Payment Notes</td>
		<td><input type="text" name="Notes" size="<%=TEXT_SIZE%>" maxlength="<%=MAX_LENGTH_CHECKLIST_NOTES%>"></td>
	</tr>
	<tr>
		<td colspan="2" align="center"><input name="Submit" type="submit" value="<%=TXT_ADD%>"> <input type="reset" value="<%=TXT_CLEAR_FORM%>"></td>
	</tr>
	</table>
	</form>
<%
	End If
%>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/datepicker.js") %>

<%
	g_bListScriptLoaded = True
End If

Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->


