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
<!--#include file="../text/txtDateTimeTable.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtFinder.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/update/incVOLFormUpdPrint.asp" -->
<%
If Not user_bCanManageMembers Then
	Call securityFailure()
End If


'required for incVOLFormUpdPrint.asp
Dim bFeedback
bFeedback = False

Sub makeFieldRow(strDisplay,strContents)
%>
<tr><td class="FieldLabelLeft"><%=strDisplay%></td><td><%=IIf(Nl(strContents), "&nbsp;", strContents)%></td></tr>
<%
End Sub

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
	Dim cmdMember, rsMember
	Set cmdMember = Server.CreateObject("ADODB.Command")
	With cmdMember
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_VOL_Member_s"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VMEM_ID", adInteger, adParamInput, 4, intVMemID)
		.Parameters.Append .CreateParameter("@HTTPVals", adVarChar, adParamInput, 500, g_strCacheHTTPVals)
		.Parameters.Append .CreateParameter("@PathToStart", adVarChar, adParamInput, 50, ps_strPathToStart)
		.CommandTimeout = 0
		Set rsMember = .Execute
	End With
	If rsMember.EOF Then
		bError = True
		strError = TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intVMemID) & "."

		rsMember.Close()
		Set rsMember = Nothing
		Set cmdMember = Nothing

	End If

End If

Dim strOrgName, strNUM, strOrgNUMUI
strOrgName = vbNullString
If Not bError Then
	strOrgName = rsMember.Fields("ORG_NAME_FULL")
	strNUM = rsMember("NUM")
	strOrgNUMUI = makeNUMContents(strNUM, rsMember, True)
End If

Call makePageHeader("Volunteer Member Organization", "Volunteer Member Organization" & TXT_COLON & strOrgName, True, False, True, True)

If bError Then
	Call handleError(strError, vbNullString, vbNullString)
Else
%>
	<p style="font-weight:bold">[ <a href="<%=makeLinkB("member.asp")%>">Return to Volunteer Member Search Form</a> ]</p>
	<form action="member_details2.asp" method="post" id="EntryForm">
	<%=g_strCacheFormVals%>
	<input type="hidden" name="VMemID" value="<%=intVMemID%>">

	<table class="BasicBorder cell-padding-3">
	<tr>
		<td colspan="2" class="TitleBox" align="center"><h2><%=strOrgName%></h2></td>
	</tr>

	<tr><th colspan="2" class="RevTitleBox">Agency Details</th></tr>
	<tr><td colspan="2" align="center">[
	<%If user_bLoggedIn Or g_bUseCIC Then%>
	<a href="<%=makeDetailsLink(strNUM,vbNullString,vbNullString)%>">More Agency Info</a> |
	<%End If%>
	<a href="<%=makeLink("results.asp","NUM=" & strNUM,vbNullString)%>">Opportunities</a> |
	<%If user_bAddVOL Then%>
	<a href="<%=makeLink("entryform.asp","NUM=" & strNUM,vbNullString)%>">Create New Opportunity</a>
	<%Else%>
	<a href="<%=makeLink("feedback.asp","NUM=" & strNUM,vbNullString)%>">Suggest New Opportunity</a>
	<%
	End If
	If user_bCanRequestUpdateVOL And user_bCanDoBulkOpsVOL And Not g_bNoEmail Then
	%>
		| <a href="<%=makeLinkAdmin("email_prep.asp","IDList=" & strNUM & "&MR=1&DM=" & DM_VOL)%>">Request Update of Volunteer Opportunities</a>
	<%End If%>
	]</td></tr>
<%
	If Not Nl(rsMember("OFFICE_PHONE")) Then
		Call makeFieldRow("Office Phone",rsMember("OFFICE_PHONE"))
	End If
	If Not Nl(rsMember("FAX")) Then
		Call makeFieldRow("Fax",rsMember("FAX"))
	End If
	If Not Nl(rsMember("SITE_ADDRESS")) Then
		Call makeFieldRow("Site Address",textToHTML(rsMember("SITE_ADDRESS")))
	End If
	If Not Nl(rsMember("E_MAIL")) Then
		Call makeFieldRow("Email",rsMember("E_MAIL"))
	End If
	If Not Nl(rsMember("WWW_ADDRESS")) Then
		Call makeFieldRow("Website",rsMember("WWW_ADDRESS"))
	End If
	
	Set rsMember = rsMember.NextRecordset

%>
<tr><td class="FieldLabelLeft">Org. Record #</td><td><%= strOrgNUMUI %></td></tr>
<tr><td class="FieldLabelLeft">Member Since</td><td><input type="text" name="MemberSince" value="<%=rsMember("MemberSince")%>" class="DatePicker" size="<%= DATE_TEXT_SIZE %>" maxlength="<%= DATE_TEXT_SIZE %>"></td></tr>
<tr><td class="FieldLabelLeft">Active</td><td><input type="checkbox" name="Active"<%=IIf(rsMember("Active")," checked", vbNullString)%>></td></tr>
<tr><td colspan="2" align="center"><input type="submit" name="Submit" value="<%=TXT_UPDATE%>"> <input type="reset" value="<%=TXT_RESET_FORM%>"></td></tr>
<tr><th colspan="2" class="RevTitleBox">Invoices and Renewals</th></tr>
<tr><td colspan="2" align="center">[
	<a href="<%=makeLink("member_renewals.asp", "VMemID=" & intVMemID, vbNullString)%>">Manage Renewals</a> 
	| <a href="<%=makeLink("member_invoices.asp", "VMemID=" & intVMemID, vbNullString)%>">Manage Invoices and Payments</a>
]</td></tr>
<%
	Dim strFinancialStanding
	strFinancialStanding = rsMember("FinancialStanding")
	Select Case strFinancialStanding
		Case "G" 
			strFinancialStanding = "Up-To-Date"
		Case "A"
			strFinancialStanding = "Arrears"
		Case Else
			strFinancialStanding = TXT_UNKNOWN
	End Select

	Call makeFieldRow("Financial Standing", strFinancialStanding)
	
	Call makeFieldRow("Last Renewal Date", rsMember("LastRenewalDate"))
	Call makeFieldRow("Next Renewal Date", rsMember("NextRenewalDate"))
	Call makeFieldRow("Last Invoice Date", rsMember("LastInvoiceDate"))
	Call makeFieldRow("Last Payment Date", rsMember("LastPaymentDate"))
%>
</table>
</form>

<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/datepicker.js") %>
<script type="text/javascript">
jQuery(function() {
		init_cached_state();
		restore_cached_state();
		});
</script>

<%
	g_bListScriptLoaded = True

	rsMember.Close()
	Set rsMember = Nothing
	Set cmdMember = Nothing

End If

Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
