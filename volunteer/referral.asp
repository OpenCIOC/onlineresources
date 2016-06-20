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

Call makePageHeader(TXT_VOLUNTEER_REFERRALS, TXT_VOLUNTEER_REFERRALS, True, False, True, True)
%>
<h3><%= TXT_FIND_REFERRAL %></h3>
<p><%= TXT_INST_SPECIFIC_OPORTUNITY %></p>
<ul>
	<li><a href="<%=makeLinkB("referral_followup.asp")%>"><%= TXT_REFERRALS_REQUIRING_FOLLOWUP %></a></li>
	<li><a href="<%=makeLink("referral_days.asp","D=10",vbNullString)%>"><%= Replace(TXT_REFERRALS_MODIFIED_X_DAYS, "[DAYS]", "10") %></a></li>
	<li><a href="<%=makeLink("referral_days.asp","D=30",vbNullString)%>"><%= Replace(TXT_REFERRALS_MODIFIED_X_DAYS, "[DAYS]", "30") %></a></li>
	<li><a href="<%=makeLink("referral_days.asp","D=90",vbNullString)%>"><%= Replace(TXT_REFERRALS_MODIFIED_X_DAYS, "[DAYS]", "90") %></a></li>
</ul>

<%
	Dim intThisMonth, intThisYear, dateToday, dateLastMonthFirst, dateThisMonthFirst
	intThisMonth = Month(Date())
	intThisYear = Year(Date())
	dateToday = DateString(Date(),True)
	dateThisMonthFirst = DateString(DateSerial(intThisYear,intThisMonth,1),True)
	dateLastMonthFirst = DateString(DateAdd("m",-1,dateThisMonthFirst),True)

%>
<form action="referral_search.asp" method="post" name="EntryForm" id="EntryForm">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="2" class="RevTitleBox"><%= TXT_CUSTOM_REFERRAL_SEARCH %></th>
</tr>
<tr>
	<td class="FieldLabel"><%= TXT_REFERRAL_DATE %></td>
	<td>
		<table class="NoBorder cell-padding-2">
		<tr>
			<td class="FieldLabelLeftClr"><label for="RefStartDate"><%=TXT_ON_AFTER_DATE & TXT_COLON%></label></td>
			<td><input type="text" name="RefStartDate" id="RefStartDate" size="15" maxlength="40" class="DatePicker"> <input type="BUTTON" value="<%=TXT_FIRST_OF_LAST_MONTH%>" onClick="document.EntryForm.RefStartDate.value='<%=dateLastMonthFirst%>'"></td>
		</tr><tr>
			<td class="FieldLabelLeftClr"><label for="RefEndDate"><%=TXT_BEFORE_DATE & TXT_COLON%></label></td>
			<td><input type="text" name="RefEndDate" id="RefEndDate" size="15" maxlength="40" class="DatePicker"> <input type="BUTTON" value="<%=TXT_FIRST_OF_THIS_MONTH%>" onClick="document.EntryForm.RefEndDate.value='<%=dateThisMonthFirst%>'"></td>
		</tr>
		</table>
</tr>
<tr>
	<td class="FieldLabel"><%= TXT_MODIFIED_DATE %></td>
	<td>
		<table class="NoBorder cell-padding-2">
		<tr>
			<td class="FieldLabelLeftClr"><label for="ModStartDate"><%=TXT_ON_AFTER_DATE & TXT_COLON%></label></td>
			<td><input type="text" name="ModStartDate" id="ModStartDate" size="15" maxlength="40" class="DatePicker"> <input type="BUTTON" value="<%=TXT_FIRST_OF_LAST_MONTH%>" onClick="document.EntryForm.ModStartDate.value='<%=dateLastMonthFirst%>'"></td>
		</tr><tr>
			<td class="FieldLabelLeftClr"><label for="ModEndDate"><%=TXT_BEFORE_DATE & TXT_COLON%></label></td>
			<td><input type="text" name="ModEndDate" id="ModEndDate" size="15" maxlength="40" class="DatePicker"> <input type="BUTTON" value="<%=TXT_FIRST_OF_THIS_MONTH%>" onClick="document.EntryForm.ModEndDate.value='<%=dateThisMonthFirst%>'"></td>
		</tr>
		</table>
</tr>
<tr>	
	<td class="FieldLabel"><label for="STerms"><%= TXT_ORGANIZATION_KEYWORDS %></label></td>
	<td><input name="STerms" id="STerms" type="text" size="<%=TEXT_SIZE-20%>" maxlength="250"></td>
</tr>
<tr>	
	<td class="FieldLabel"><label for="PTitle"><%= TXT_POS_TITLE_KEYWORDS %></label></td>
	<td><input name="PTitle" id="PTitle" type="text" size="<%=TEXT_SIZE-20%>" maxlength="250"></td>
</tr>
<tr>	
	<td class="FieldLabel"><label for="VolunteerName"><%= TXT_VOLUNTEER_NAME %></label></td>
	<td><%=TXT_CONTAINS & TXT_COLON%>&nbsp;<input name="VolunteerName" id="VolunteerName" type="text" size="<%=TEXT_SIZE-30%>" maxlength="100"></td>
</tr>
<tr>	
	<td class="FieldLabel"><%= TXT_FOLLOW_UP %></td>
	<td>
		<label for="HasFollowUpAny"><input id="HasFollowUpAny" type="radio" name="HasFollowUp" value="" checked> <%= TXT_ANY %></label> 
		<label for="HasFollowUpReq"><input id="HasFollowUpReq" type="radio" name="HasFollowUp" value="R"> <%= TXT_IS_REQUIRED %></label> 
		<label for="HasFollowUpNotReq"><input id="HasFollowUpNotReq" type="radio" name="HasFollowUp" value="N"> <%= TXT_NOT_REQUIRED %></label> 
	</td>
</tr>
<%
Call openAgencyListRst(DM_VOL, True, True)
	If Not rsListAgency.EOF Then
%>
<tr>	
	<td class="FieldLabel"><label for="RecordOwner"><%= TXT_RECORD_OWNER %></label></td>
	<td><%=makeAgencyList(vbNullString,"RecordOwner",True,True)%></td>
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

<h3><%= TXT_OTHER_REFERRAL_TOOLS %></h3>
<ul>
<li><a href="<%=makeLinkB("referral_stats.asp")%>"><%= TXT_REFERRAL_STATS_REPORT %></a></li>
<%If user_bSuperUserVOL Then%>
<li><a href="<%=makeLinkB("referral_delete.asp")%>"><%= TXT_DELETE_OLD_REFERRALS %></a></li>
<%End If%>
</ul>
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
