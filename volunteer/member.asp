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
<!--#include file="../text/txtCustFields.asp" -->
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtDateTimeTable.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtFinder.asp" -->
<!--#include file="../includes/search/incDateSearch.asp" -->
<!--#include file="../includes/update/incEntryFormGeneral.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/update/incVOLFormUpdPrint.asp" -->

<%
If Not user_bCanManageMembers Then
	Call securityFailure()
End If


Call makePageHeader("Volunteer Member Organizations Management", "Volunteer Member Organizations", True, False, True, True)
%>

<h1>Volunteer Member Organizations Management</h1>

<form action="member_search.asp" method="post" name="SearchForm">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="2" class="RevTitleBox">Member Search</th>
</tr>
<tr>
	<td class="FieldLabel">Organization Name</td>
	<td><input type="text" size="50" maxlength="250" name="OrgName"></td>
</tr>
<tr>
	<td class="FieldLabel">Financial Standing</td>
	<td style="white-space: nowrap;">
		<input id="StandingAny" type="radio" name="Standing" value="" checked> <label for="StandingAny">Any</label>
		<input id="StandingGood" type="radio" name="Standing" value="G"> <label for="StandingGood">Up-To-Date</label>
		<input id="StandingArrears" type="radio" name="Standing" value="A"> <label for="StandingArrears">In Arrears</label>
		<input id="StandingUnknown" type="radio" name="Standing" value="U"> <label for="StandingUnknown">Unknown</label>
	</td>
</tr>
<tr>
	<td class="FieldLabel">Active</td>
	<td style="white-space: nowrap;">
		<input id="ActiveAny" type="radio" name="Active" value="" checked> <label for="ActiveAny">Any</label>
		<input id="ActiveYes" type="radio" name="Active" value="Y"> <label for="ActiveYes">Yes</label>
		<input id="ActiveNo" type="radio" name="Active" value="N"> <label for="ActiveNo">No</label>
	</td>
</tr>
<tr>
	<td class="FieldLabel">Member Since</td>
	<td><%Call printDateSearchTable("MemberSince")%></td> 
</tr>
<tr>
	<td class="FieldLabel">Last Renewal</td>
	<td><%Call printDateSearchTable("LastRenewal")%></td>
</tr>
<tr>
	<td class="FieldLabel">Next Renewal</td>
	<td><%Call printDateSearchTable("NextRenewal")%></td>
</tr>
<tr>
	<td colspan="2" align="center"><input type="submit" value="<%=TXT_SEARCH%>"> <input type="reset" value="<%=TXT_CLEAR_FORM%>"></td>
</tr>
</table>
</form>

<br>

<form method="post" action="member_details2.asp" name="EntryForm">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="2" class="RevTitleBox">Member Add</th>
</tr>
<tr>
	<td class="FieldLabel">Org. Record #</td>
	<td><%=makeNUMContents(vbNullString, Null, False)%></td>
</tr>
<tr>
	<td class="FieldLabel">Member Since</td>
	<td><%=makeDateFieldVal("MemberSince", vbNullString, True, False, False, False, False, False)%></td>
</tr>
<tr>
	<td class="FieldLabel">Next Renewal Date</td>
	<td><%=makeDateFieldVal("NextRenewalDate", vbNullString, False, False, False, True, False, False)%></td>
</tr>
<tr>
	<td colspan="2" align="center"><input type="submit" name="Submit" value="<%=TXT_ADD%>"> <input type="reset" value="<%=TXT_CLEAR_FORM%>"></td>
</tr>
</table>
</form>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/datepicker.js") %>

<%
g_bListScriptLoaded = True
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->


