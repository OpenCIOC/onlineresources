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
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtReferral.asp" -->
<!--#include file="../includes/list/incAgencyList.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
If Not user_bCanManageReferrals Then
	Call securityFailure()
End If

Call addScript(ps_strPathToStart & makeAssetVer("scripts/formNewWindow.js"), "text/javascript")

Call makePageHeader(TXT_VOLUNTEER_REFERRALS, TXT_VOLUNTEER_REFERRALS, True, False, True, True)
%>

<p>[ <a href="<%=makeLinkB("referral.asp")%>"><%= TXT_REFERRALS_MAIN_MENU %></a> ]</p>
<h3><%= TXT_REFERRAL_STATS_REPORT %></h3>
<%
	Dim intThisMonth, intThisYear, dateToday, dateLastMonthFirst, dateThisMonthFirst
	intThisMonth = Month(Date())
	intThisYear = Year(Date())
	dateToday = DateString(Date(),True)
	dateThisMonthFirst = DateString(DateSerial(intThisYear,intThisMonth,1),True)
	dateLastMonthFirst = DateString(DateAdd("m",-1,dateThisMonthFirst),True)

%>
<form action="referral_stats2.asp" method="post" name="EntryForm" onSubmit="formPrintMode(this);" id="EntryForm">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="2" class="RevTitleBox"><%= TXT_CREATE_REFERRAL_STATS_REPORT %></th>
</tr>
<tr>
	<td class="FieldLabel"><label for="StartDate"><%=TXT_ON_AFTER_DATE%></label></td>
	<td><input type="text" name="StartDate" id="StartDate" size="15" maxlength="40" class="DatePicker"> <input type="BUTTON" value="<%=TXT_FIRST_OF_LAST_MONTH%>" onClick="document.EntryForm.StartDate.value='<%=dateLastMonthFirst%>'"></td>
</tr>
<tr>
	<td class="FieldLabel"><label for="EndDate"><%=TXT_BEFORE_DATE%></label></td>
	<td><input type="text" name="EndDate" id="EndDate" size="15" maxlength="40" class="DatePicker"> <input type="BUTTON" value="<%=TXT_FIRST_OF_THIS_MONTH%>" onClick="document.EntryForm.EndDate.value='<%=dateThisMonthFirst%>'"></td>
</tr>
<tr>
	<td class="FieldLabel"><%=TXT_THRESHOLD%></td>
	<td><%= TXT_OPPS_WITH %> <input name="AtLeast" title=<%=AttrQs(TXT_MIN_REFERRALS)%> type="text" size="3" maxlength="5" value="1"> <%= TXT_OR_MORE_REFERRALS %></td>
</tr>
<tr>	
	<td class="FieldLabel"><label for="STerms"><%=TXT_ORGANIZATION_KEYWORDS%></label></td>
	<td><input name="STerms" id="STerms" type="text" size="<%=TEXT_SIZE-20%>" maxlength="250"></td>
</tr>
<%
Call openAgencyListRst(DM_VOL, True, True)
	If Not rsListAgency.EOF Then
%>
<tr>	
	<td class="FieldLabel"><label for="RecordOwner"><%=TXT_RECORD_OWNER%></label></td>
	<td><%=makeAgencyList(vbNullString,"RecordOwner",True,True)%></td>
</tr>
<tr>	
	<td class="FieldLabel"><%=TXT_SHOW_PLACEMENT_COUNT%></td>
	<td><label for="Placement_Yes"><input type="radio" name="Placement" id="Placement_Yes" value="on">&nbsp;<%=TXT_YES%></label>
	<label for="Placement_No"><input type="radio" name="Placement" id="Placement_No" value="" checked>&nbsp;<%=TXT_NO%></label></td>
</tr>
<tr>	
	<td class="FieldLabel"><%=TXT_PRINT_VERSION%></td>
	<td><label for="PrintMd_Yes"><input type="radio" name="PrintMd" id="PrintMd_Yes" value="on">&nbsp;<%=TXT_YES%></label>
	<label for="PrintMd_No"><input type="radio" name="PrintMd" id="PrintMd_No" value="" checked>&nbsp;<%=TXT_NO%></label></td>
</tr>
<%
	End If
Call closeAgencyListRst()
%>
<tr>
	<td colspan="2" align="center"><input type="submit" value="<%=TXT_SEARCH%>"> <input type="reset" value="<%=TXT_CLEAR_FORM%>"></td>
</tr>
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
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
