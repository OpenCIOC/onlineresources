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
<!--#include file="../includes/list/incVOLMemberInvoiceList.asp" -->

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
Else
	Dim cmdMember, rsMember
	Set cmdMember = Server.CreateObject("ADODB.Command")
	With cmdMember
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_VOL_Member_Renewal_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VMEM_ID", adInteger, adParamInput, 4, intVMemID)
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

Dim strOrgName, strNextRenewalDate
strOrgName = vbNullString
If Not bError Then
	strOrgName = rsMember.Fields("ORG_NAME_FULL")
	strNextRenewalDate = rsMember.Fields("NextRenewalDate")
End If

Call makePageHeader("Volunteer Member Organization Renewals", "Volunteer Member Organization Renewals" & TXT_COLON & strOrgName, True, False, True, True)

If bError Then
	Call handleError(strError, vbNullString, vbNullString)
Else
%>
<h1><%=strOrgName%></h1>
<p style="font-weight:bold">[ <a href="<%=makeLink("member_details.asp", "VMemID=" & intVMemID, vbNullString)%>">Return to Volunteer Member Details</a> ]</p>
<h2>Renewal History</h2>
<%
	Call openVOLMemberInvoiceListRst(intVMemID, False)	

	Set rsMember = rsMember.NextRecordset
	If rsMember.EOF Then
		rsMember.Close()
		Set rsMember = Nothing
		Set cmdMember = Nothing

		%><p>No Renewals found.</p><%
	Else
%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox">Renewal Date</th>
	<th class="RevTitleBox">Invoice</th>
	<th class="RevTitleBox">Action</th>
</tr>
<%
	
	With rsMember
	Dim dRenewalDate, dInvoiceDate, intVMInvID, intVMRID

		While Not .EOF
			
			dRenewalDate = .Fields("RenewalDate")
			intVMInvID = .Fields("VMINV_ID")
			intVMRID = .Fields("VMR_ID")

%>
<tr valign="TOP">
<form method="post" action="member_renewals2.asp">
<%=g_strCacheFormVals%>
<input type="hidden" name="VMRID" value="<%=intVMRID%>">
<input type="hidden" name="VMemID" value="<%=intVMemID%>">
<td><%=makeDateFieldVal("RenewalDate", dRenewalDate, False, False, False, False, False, False)%></td>
<td><%=makeVOLMemberInvoiceList(intVMInvID, "VMInvID", True)%></td>
<td><input name="Submit" type="submit" value="<%=TXT_UPDATE%>">&nbsp;<input name="Submit" type="submit" value="<%=TXT_DELETE%>"></td>
</form>
</tr>
<%
			.MoveNext
		Wend
	End With
	rsMember.Close()
	Set rsMember = Nothing
	Set cmdMember = Nothing
%>
</table>
<%
	End If

%>
	<h2>Manage Renewals</h2>
	<form method="post" action="member_renewals2.asp" name="EntryForm">
	<%=g_strCacheFormVals%>
	<input type="hidden" name="VMemID" value="<%=intVMemID%>">
	<table class="BasicBorder cell-padding-3">
	<tr>
		<td class="FieldLabel">Add Renewal (Optional)</td>
		<td><table class="NoBorder cell-padding-2"><tr><td class="FieldLabelLeftClr">Date:</td><td><%=makeDateFieldVal("RenewalDate", vbNullString, True, False, False, False, False, False)%></td></tr>
			<tr><td class="FieldLabelLeftClr">Invoice:</td><td><%=makeVOLMemberInvoiceList(Null, "VMInvID", True)%></td></tr></td></table>
	</tr>
	<tr>
		<td class="FieldLabel">Next Renewal Date</td>
		<td><%=makeDateFieldVal("NextRenewalDate", strNextRenewalDate, False, False, False, True, False, False)%></td>
	</tr>
	<tr>
		<td colspan="2" align="center"><input name="Submit" type="submit" value="Submit Changes"> <input type="reset" value="<%=TXT_CLEAR_FORM%>"></td>
	</tr>
	</table>
	</form>

<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/datepicker.js") %>

<%
	g_bListScriptLoaded = True
	Call closeVOLMemberInvoiceListRst()	
End If

Call makePageFooter(False)

%>

<!--#include file="../includes/core/incClose.asp" -->


