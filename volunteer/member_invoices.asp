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
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incVOLMemberInvoiceList.asp" -->

<%
Function InvoiceVoidClass(bInvoiceVoid)
	If bInvoiceVoid Then
		InvoiceVoidClass = "class=""InvoiceVoid"""
	Else
		InvoiceVoidClass = vbNullString
	End If
End Function


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
Else

	Call openVOLMemberInvoiceListRst(intVMemID, True)
	If rsListVOLMemberInvoice.EOF Then
		bError = True
		strError = TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intVMemID) & "."
		closeVOLMemberInvoiceListRst()
	End If

End If

Dim strOrgName
strOrgName = vbNullString
If Not bError Then
	strOrgName = rsListVOLMemberInvoice.Fields("ORG_NAME_FULL")
End If

Call addToHeader("<style type=""text/css"">.InvoiceVoid { font-style:italic; text-decoration:line-through; background-color:#CCCCCC };</style>")
Call makePageHeader("Volunteer Member Organization Renewals", "Volunteer Member Organization Renewals" & TXT_COLON & strOrgName, True, False, True, True)

If bError Then
	Call handleError(strError, vbNullString, vbNullString)
Else
%>
<h1><%=strOrgName%></h1>
<p style="font-weight:bold">[ <a href="<%=makeLink("member_details.asp", "VMemID=" & intVMemID, vbNullString)%>">Return to Volunteer Member Details</a> ]</p>
<h2>Invoice History</h2>
<%
	Set rsListVOLMemberInvoice = rsListVOLMemberInvoice.NextRecordset
	If rsListVOLMemberInvoice.EOF Then
		'Call closeVOLMemberInvoiceListRst()

		%><p>No Invoices found.</p><%

	'Else
	End If
	If True Then
%>

<table class="BasicBorder cell-padding-2 sortable_table" data-default-sort="[0]" data-sort-disabled="[5]">
<thead>
	<tr class="RevTitleBox">
		<th>#</th>
		<th>Date</th>
		<th>Due</th>
		<th>Invoice Amount</th>
		<th>Amount Owing</th>
		<th>Action</th>
	</tr>
</thead>
<tbody>
<%
	With rsListVOLMemberInvoice
	Dim strInvoiceNumber, dInvoiceDate, dPaymentDueDate, _
		dblInvoiceAmount, bInvoiceVoid, dblAmountOwing, bPastDue, bMoneyOwed, dNow

	dNow = Now()
	
	While Not .EOF
		strInvoiceNumber = .Fields("InvoiceNumber")
		dInvoiceDate = .Fields("InvoiceDate")
		dPaymentDueDate = .Fields("PaymentDueDate")
		dblInvoiceAmount = .Fields("InvoiceAmount")
		bInvoiceVoid = .Fields("InvoiceVoid")
		If bInvoiceVoid Then
			dblAmountOwing = 0
		Else
			dblAmountOwing = CDbl(.Fields("AmountOwing"))
		End If
		bMoneyOwed = dblAmountOwing > 0
		bPastDue = DateDiff("d", dNow, dInvoiceDate) < 0 And bMoneyOwed

%>
	<tr>
		<td <%=InvoiceVoidClass(bInvoiceVoid)%> data-tbl-key="<%=strInvoiceNumber%>"><%=strInvoiceNumber%></td>
		<td <%=InvoiceVoidClass(bInvoiceVoid)%> data-tbl-key="<%=ISODateString(dInvoiceDate)%>"><%=DateString(dInvoiceDate, True)%></td>
		<td <%=InvoiceVoidClass(bInvoiceVoid)%> data-tbl-key="<%=ISODateString(dPaymentDueDate)%>"><%If bPastDue Then%><span class="Alert"><%End If%><%=DateString(dPaymentDueDate, True)%><%If bPastDue Then%></span><%End If%></td>
		<td <%=InvoiceVoidClass(bInvoiceVoid)%> data-tbl-key="<%=FormatNumber(CDbl(dblInvoiceAmount) * 100,0)%>"><%=FormatCurrency(dblInvoiceAmount, 2)%></td>
		<td <%=InvoiceVoidClass(bInvoiceVoid)%> data-tbl-key="<%=FormatNumber(dblAmountOwing * 100,0)%>"><%If bMoneyOwed Then%><span class="Alert"><%End If%><%=FormatCurrency(dblAmountOwing, 2)%><%If bMoneyOwed Then%></span><%End If%></td>
		<td><form action="member_inv_edit.asp" method="post"><%=g_strCacheFormVals%><input type="hidden" name="VMemID" value=<%=AttrQs(intVMemID)%>><input type="hidden" name="VMInvID" value=<%=AttrQs(.Fields("VMINV_ID"))%>><input type="submit" name="Submit" value="View/Edit"></form></td>
	</tr>
<%
		.MoveNext
	Wend
	End With
%>
</tbody>
</table>


<%
		Call closeVOLMemberInvoiceListRst()	
	End If
%>
<p style="font-weight:bold"> <a href="<%=makeLink("member_inv_edit.asp", "VMemID=" & intVMemID, vbNullString)%>">Add New Invoice</a></p>

<%


End If

%>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/tablesort.js") %>

<% 
g_bListScriptLoaded = True
Call makePageFooter(True)
Call makePageFooter(False)

%>
<!--#include file="../includes/core/incClose.asp" -->


