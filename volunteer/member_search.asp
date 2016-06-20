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
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../includes/search/incCustFieldResults.asp" -->
<!--#include file="../includes/search/incDatesPredef.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->

<%

If Not user_bCanManageMembers Then
	Call securityFailure()
End If

Call makePageHeader("Volunteer Member Organizations Management", "Volunteer Member Organizations", True, False, True, True)

Dim strStanding, _
	strActive, _
	strMemberSinceFirstDate, _
	strMemberSinceLastDate, _
	strMemberSinceDateRange, _
	strLastRenewalFirstDate, _
	strLastRenewalLastDate, _
	strLastRenewalDateRange, _
	strNextRenewalFirstDate, _
	strNextRenewalLastDate, _
	strNextRenewalDateRange, _
	strSTermsOrg
	
Dim strJoinedSTerms, _
	strJoinedQSTerms, _
	singleSTerms(), _
	quotedSTerms(), _
	exactSTerms(), _
	displaySTerms()

strSTermsOrg = Trim(Request("OrgName"))

If Not Nl(strSTermsOrg) Then
	Call makeSearchString( _
		strSTermsOrg, _
		singleSTerms, _
		quotedSTerms, _
		exactSTerms, _
		displaySTerms, _
		False _
	)
	strJoinedSTerms = Join(singleSTerms,AND_CON)
	strJoinedQSTerms = Join(quotedSTerms,AND_CON)
End If

strStanding = UCase(Trim(Request("Standing")))

strActive = UCase(Trim(Request("Active")))
If strActive <> "Y" And strActive <> "N" Then
	strActive = vbNullString
End If

Call setDateFieldVars("MemberSince", "BYPASS", strMemberSinceFirstDate, strMemberSinceLastDate, vbNullString, vbNullString, strMemberSinceDateRange)
Call setDateFieldVars("LastRenewal", "BYPASS", strLastRenewalFirstDate, strLastRenewalLastDate, vbNullString, vbNullString, strLastRenewalDateRange)
Call setDateFieldVars("NextRenewal", "BYPASS", strNextRenewalFirstDate, strNextRenewalLastDate, vbNullString, vbNullString, strNextRenewalDateRange)

Dim strSearchSQL

strSearchSQL = "SELECT vm.VMEM_ID, vm.NUM, vm.MemberSince AS MemberSince, " & _
		"vm.NextRenewalDate, vm.Active, " & _
		"(SELECT MAX(RenewalDate) FROM VOL_Member_Renewal vmr WHERE vmr.VMEM_ID=vm.VMEM_ID) AS LastRenewalDate, " & _
		"(SELECT MAX(InvoiceDate) FROM VOL_Member_Invoice vmi WHERE vmi.VMEM_ID=vm.VMEM_ID) AS LastInvoiceDate, " & _
		"(SELECT MAX(PaymentDate) FROM VOL_Member_Payment vmp INNER JOIN VOL_Member_Invoice vmi ON vmp.VMINV_ID=vmi.VMINV_ID WHERE vmi.VMEM_ID=vm.VMEM_ID) AS LastPaymentDate, " & _
		" CASE " & _
		"	WHEN NOT EXISTS(SELECT * FROM VOL_Member_Invoice WHERE VMEM_ID=vm.VMEM_ID) THEN '?' " & _
		"	WHEN ISNULL((SELECT SUM(PaymentAmount) FROM VOL_Member_Payment vmp INNER JOIN VOL_Member_Invoice vmi ON vmp.VMINV_ID=vmi.VMINV_ID WHERE vmi.VMEM_ID=vm.VMEM_ID AND vmi.InvoiceVoid=0 AND vmi.PaymentDueDate < GETDATE()),0) < " & _
		"		ISNULL((SELECT SUM(InvoiceAmount) FROM VOL_Member_Invoice vmi WHERE vmi.VMEM_ID=vm.VMEM_ID AND vmi.InvoiceVoid=0 AND vmi.PaymentDueDate < GETDATE()),0) THEN 'A' ELSE 'G' END AS FinancialStanding, " & _
		"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & vbCrLf & _
		"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1),btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_SORT_KEY" & vbCrLf & _
		"FROM VOL_Member vm" & vbCrLf & _
		"LEFT JOIN GBL_BaseTable bt ON vm.NUM=bt.NUM" & vbCrLf & _
		"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=bt.NUM ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)"

Dim strConditions
strConditions = Array()

If Not Nl(strJoinedSTerms) Then
	ReDim Preserve strConditions(UBound(strConditions)+1)
	strConditions(UBound(strConditions)) = "CONTAINS(btd.SRCH_Org, '" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
End If

If Not Nl(strJoinedQSTerms) Then
	ReDim Preserve strConditions(UBound(strConditions)+1)
	strConditions(UBound(strConditions)) = "CONTAINS(btd.SRCH_Org, '" & strJoinedQSTerms & "')"
End If

If Not Nl(strStanding) Then
	Select Case strStanding
		Case "G"
			ReDim Preserve strConditions(UBound(strConditions)+1)
			strConditions(UBound(strConditions)) = "(EXISTS(SELECT * FROM VOL_Member_Invoice WHERE VMEM_ID=vm.VMEM_ID) " & _
				"AND (ISNULL((SELECT SUM(PaymentAmount) FROM VOL_Member_Payment vmp INNER JOIN VOL_Member_Invoice vmi ON vmp.VMINV_ID=vmi.VMINV_ID WHERE vmi.VMEM_ID=vm.VMEM_ID AND vmi.InvoiceVoid=0 AND vmi.PaymentDueDate < GETDATE()),0) >= " & _
				"ISNULL((SELECT SUM(InvoiceAmount) FROM VOL_Member_Invoice vmi WHERE vmi.VMEM_ID=vm.VMEM_ID AND vmi.InvoiceVoid=0 AND vmi.PaymentDueDate < GETDATE()),0)))"
		Case "A"
			ReDim Preserve strConditions(UBound(strConditions)+1)
			strConditions(UBound(strConditions)) = "(ISNULL((SELECT SUM(PaymentAmount) FROM VOL_Member_Payment vmp INNER JOIN VOL_Member_Invoice vmi ON vmp.VMINV_ID=vmi.VMINV_ID WHERE vmi.VMEM_ID=vm.VMEM_ID AND vmi.InvoiceVoid=0 AND vmi.PaymentDueDate < GETDATE()),0) < " & _
				"ISNULL((SELECT SUM(InvoiceAmount) FROM VOL_Member_Invoice vmi WHERE vmi.VMEM_ID=vm.VMEM_ID AND vmi.InvoiceVoid=0 AND vmi.PaymentDueDate < GETDATE()),0))"
		Case "U"
			ReDim Preserve strConditions(UBound(strConditions)+1)
			strConditions(UBound(strConditions)) = "NOT EXISTS(SELECT * FROM VOL_Member_Invoice WHERE VMEM_ID=vm.VMEM_ID)"
	End Select
End If

If Not Nl(strActive) Then
	ReDim Preserve strConditions(UBound(strConditions)+1)
	strConditions(UBound(strConditions)) = "(Active = " & IIf(strActive="Y", SQL_TRUE, SQL_FALSE) & ")"
End If

Dim strTmpDateSearch

strTmpDateSearch = getDateSearchStringS("vm.MemberSince", strMemberSinceFirstDate, strMemberSinceLastDate, strMemberSinceDateRange)
If Not Nl(strTmpDateSearch) And strTmpDateSearch <> "()" Then
	ReDim Preserve strConditions(UBound(strConditions)+1)
	strConditions(UBound(strConditions)) = strTmpDateSearch
End If

strTmpDateSearch = getDateSearchStringS("(SELECT MAX(RenewalDate) FROM VOL_Member_Renewal vmr WHERE vmr.VMEM_ID=vm.VMEM_ID)", strLastRenewalFirstDate, strLastRenewalLastDate, strLastRenewalDateRange)
If Not Nl(strTmpDateSearch) And strTmpDateSearch <> "()" Then
	ReDim Preserve strConditions(UBound(strConditions)+1)
	strConditions(UBound(strConditions)) = strTmpDateSearch
End If

strTmpDateSearch = getDateSearchStringS("NextRenewalDate", strNextRenewalFirstDate, strNextRenewalLastDate, strNextRenewalDateRange)
If Not Nl(strTmpDateSearch) And strTmpDateSearch <> "()" Then
	ReDim Preserve strConditions(UBound(strConditions)+1)
	strConditions(UBound(strConditions)) = strTmpDateSearch
End If


If UBound(strConditions) >= 0 Then
	strSearchSQL = strSearchSQL & " WHERE " & Join(strConditions, AND_CON)
End If

'Response.Write(Server.HTMLEncode(strSearchSQL) & "<br>")
'Response.Flush

Dim cmdSearchResults, rsSearchResults

Set cmdSearchResults = Server.CreateObject("ADODB.Command")
With cmdSearchResults
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strSearchSQL
	.CommandType = adCmdText
	.CommandTimeout = 0
End With
Set rsSearchResults = Server.CreateObject("ADODB.Recordset")
With rsSearchResults
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdSearchResults

%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("member.asp")%>">Return to Volunteer Member Search Form</a> ]</p>
<h1>Volunteer Member Organization Search Results</h1>
<p><%=TXT_FOUND%><strong><%=.RecordCount%></strong><%=TXT_MATCHES%>.</p>
<%
If Not .EOF Then
%>
<table class="BasicBorder cell-padding-3 sortable_table" data-sortdisabled="[8]" data-default-sort="[2,0]">
<thead>
<tr>
	<th class="RevTitleBox">&nbsp;</th>
	<th class="RevTitleBox">$</th>
	<th class="RevTitleBox"><%=TXT_ORG_NAMES%></th>
	<th class="RevTitleBox">Member Since</th>
	<th class="RevTitleBox">Next Renewal</th>
	<th class="RevTitleBox">Last Renewal</th>
	<th class="RevTitleBox">Last Invoice</th>
	<th class="RevTitleBox">Last Payment</th>
	<th class="RevTitleBox">Action</th>
</tr>
</thead>
<tbody>
<%
		Dim intVMemID, strOrgName, strOrgSortKey, dMemberSince, dNextRenewal, dLastRenewal, _
				dLastInvoice, dLastPayment, strDispStanding, bActive

		While Not .EOF

		intVMemID = .Fields("VMEM_ID")

		strOrgName = .Fields("ORG_NAME_FULL")
		strOrgSortKey = Server.HTMLEncode(.Fields("ORG_SORT_KEY"))

		dMemberSince = .Fields("MemberSince")
		dNextRenewal = .Fields("NextRenewalDate")
		dLastRenewal = .Fields("LastRenewalDate")
		dLastInvoice = .Fields("LastInvoiceDate")
		dLastPayment = .Fields("LastPaymentDate")

		strDispStanding = .Fields("FinancialStanding")
		bActive = .Fields("Active")

%>
<tr valign="TOP">
	<td data-tbl-key="<%=IIf(bActive, "a", "b")%>"><%=IIf(bActive, vbNullString,"<img src=""" & ps_strPathToStart & "/images/redx.gif"">")%></td>
	<td align="center" data-tbl-key="<%=strDispStanding%>"><%
		Select Case strDispStanding
			Case "A"
				%><img width="15" height="15" src="<%=ps_strPathToStart%>/images/redflag.gif"><%			
			Case "G"
				%><img width="15" height="15" src="<%=ps_strPathToStart%>/images/greencheck.gif"><%	
			Case Else
				%>?<%	
		End Select
%></td>
	<td data-tbl-key="<%=strOrgSortKey%>"><%=strOrgName%></td>
	<td data-tbl-key="<%=Nz(ISODateTimeString(dMemberSince), "1900-01-01 00:00:00")%>"><%=Nz(DateString(dMemberSince, True), "&nbsp;")%></td>
	<td data-tbl-key="<%=Nz(ISODateTimeString(dNextRenewal), "1900-01-01 00:00:00")%>"><%=Nz(DateString(dNextRenewal, True), "&nbsp;")%></td>
	<td data-tbl-key="<%=Nz(ISODateTimeString(dLastRenewal), "1900-01-01 00:00:00")%>"><%=Nz(DateString(dLastRenewal, True), "&nbsp;")%></td>
	<td data-tbl-key="<%=Nz(ISODateTimeString(dLastInvoice), "1900-01-01 00:00:00")%>"><%=Nz(DateString(dLastInvoice, True), "&nbsp;")%></td>
	<td data-tbl-key="<%=Nz(ISODateTimeString(dLastPayment), "1900-01-01 00:00:00")%>"><%=Nz(DateString(dLastPayment, True), "&nbsp;")%></td>
	<td><a href="<%=makeLink("member_details.asp", "VMemID=" & intVMemID, vbNullString)%>">Details</a></td>
</tr>
<%
		.MoveNext
	Wend
%>
</tbody>
</table>

<%
End If
End With

Call rsSearchResults.Close()
Set rsSearchResults = Nothing
Set cmdSearchResults = Nothing

%>


<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/tablesort.js") %>

<% 
g_bListScriptLoaded = True
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->


