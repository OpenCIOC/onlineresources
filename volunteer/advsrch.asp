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
<%' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtCheckList.asp" -->
<!--#include file="../text/txtCustFields.asp" -->
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtDateTimeTable.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtGeneralSearch2.asp" -->
<!--#include file="../text/txtSearchBasic.asp" -->
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../text/txtSearchAdvanced.asp" -->
<!--#include file="../text/txtSearchAdvancedVOL.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incAgencyList.asp" -->
<!--#include file="../includes/list/incCustFieldList.asp" -->
<!--#include file="../includes/list/incLikeList.asp" -->
<!--#include file="../includes/list/incSharingProfileList.asp" -->
<!--#include file="../includes/search/incCommSrchVOL.asp" -->
<!--#include file="../includes/search/incDateSearch.asp" -->
<!--#include file="../includes/search/incSearchRecent.asp" -->
<!--#include file="../includes/search/incSharingProfileSearchForm.asp" -->
<!--#include file="../includes/search/incChecklistSearchForm.asp" -->
<%

Call makePageHeader(TXT_VOL_ADVANCED_SEARCH, TXT_VOL_ADVANCED_SEARCH, True, False, True, True)

Dim	bASrchAges, _
	bASrchBool, _
	bASrchDatesTimes, _
	bASrchEmail, _
	bASrchLastRequest, _
	bASrchOSSD, _
	bASrchOwner

' Get Advanced Search View data
Dim cmdASrchViewData, rsASrchViewData
Set cmdASrchViewData = Server.CreateObject("ADODB.Command")
With cmdASrchViewData
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_VOL_View_s_ASrch"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
End With
Set rsASrchViewData = cmdASrchViewData.Execute

' VOL View data
With rsASrchViewData
	If Not .EOF Then
		bASrchAges = .Fields("ASrchAges")
		bASrchBool = .Fields("ASrchBool")
		bASrchDatesTimes = .Fields("ASrchDatesTimes")
		bASrchEmail = .Fields("ASrchEmail")
		bASrchLastRequest = .Fields("ASrchLastRequest")
		bASrchOSSD = .Fields("ASrchOSSD")
		bASrchOwner = .Fields("ASrchOwner")
	End If
End With

Call InitializeRecentSearch()
%>
<form action="results.asp" id="EntryForm" name="EntryForm" method="get" onSubmit="formNewWindow(this);">
<%=g_strCacheFormVals%>
<p><input type="submit" value="<%=TXT_SEARCH%>"> <input type="RESET" value="<%=TXT_CLEAR_FORM%>"></p>
<table class="BasicBorder cell-padding-4 max-width-md">
<%
If bRecentSearchFound Then
	If IsArray(aLastSearchSessionInfo) Then
		strLastSearchSessionInfo = "<li class=""search-info-list"">" & Join(aLastSearchSessionInfo,"</li><li class=""search-info-list"">") & "</li>"
	Else
		strLastSearchSessionInfo = TXT_YOUR_PREVIOUS_SEARCH & " [" & strLastSearchSessionTime & "]"
	End If
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_REFINE_SEARCH%></td>
	<td>
		<div style="display:none"><input type="hidden" name="RS" value="<%=strRecentSearchKey%>"></div>
		<strong>Searched On:</strong> <%=strLastSearchSessionTime%>
		<ul><%=strLastSearchSessionInfo%></ul>
	</td>
</tr>
<%
End If
%>
<tr>
	<td class="FieldLabelLeft"><%= TXT_SEARCH_ORG_NAME %></td>
	<td><label for="SCon_A"><input type="radio" name="SCon" id="SCon_A" value="A" checked> <%=TXT_ALL_TERMS%></label>
		<label for="SCon_O"><input type="radio" name="SCon" id="SCon_O" value="O"> <%=TXT_ANY_TERMS%></label>
<%If bASrchBool Then%>
		<label for="SCon_B"><input type="radio" name="SCon" id="SCon_B" value="B"> <%=TXT_BOOLEAN%></label>
<%End If%>
	<br><input name="STerms" title=<%=AttrQs(TXT_SEARCH_ORG_NAME)%> type="text" size="<%=TEXT_SIZE-10%>" maxlength="250"></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%= TXT_SEARCH_OPPORTUNITY %></td>
	<td><label for="SConPos_A"><input type="radio" name="SConPos" id="SConPos_A" value="A" checked> <%=TXT_ALL_TERMS%></label>
		<label for="SConPos_O"><input type="radio" name="SConPos" id="SConPos_O" value="O"> <%=TXT_ANY_TERMS%></label>
<%If bASrchBool Then%>
		<label for="SConPos_B"><input type="radio" name="SConPos" id="SConPos_B" value="B"> <%=TXT_BOOLEAN%></label>
<%End If%>
	<br><input name="STermsPos" title=<%=AttrQs(TXT_SEARCH_OPPORTUNITY)%> type="text" size="<%=TEXT_SIZE-10%>" maxlength="250">
	<br><label for="STypePos_A"><input type="radio" name="STypePos" id="STypePos_A" value="A" checked> <%=TXT_WORDS_ANYWHERE%></label>
		<label for="STypePos_P"><input type="radio" name="STypePos" id="STypePos_P" value="P"> <%=TXT_POSITION_TITLE%></label>
		<label for="STypePos_S"><input type="radio" name="STypePos" id="STypePos_S" value="S"> <%=TXT_AREAS_OF_INTEREST%></label></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="VNUM"><%=TXT_RECORD_NUM%></label></td>
	<td><textarea name="VNUM" id="VNUM" cols="<%=TEXTAREA_COLS-10%>" rows="<%=TEXTAREA_ROWS_SHORT%>"></textarea>
	<br><span class="SmallNote"><%=TXT_INST_RECORD_NUM%></span></td>
</tr>
<%
Dim strCommTable, bEmptyCommTable
strCommTable = makeCommSrchTable(bEmptyCommTable, False)

If Not bEmptyCommTable Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_COMMUNITIES%></td>
	<td><%=TXT_HAS_OPPORTUNITIES_IN_COMMUNITIES%>
	<br><%=strCommTable%>
	</td>
</tr>
<%
End If
If bASrchAges Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_AGES%></td>
	<td><%=TXT_FOR_VOLUNTEER_AGED%> <input type="text" name="Age" title=<%=AttrQs(TXT_AGE)%> id="Age" size="3" maxlength="3"> (<%=TXT_IN_YEARS%>)</td>
</tr>
<%
End If

If bASrchDatesTimes Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_DATES_TIMES%></td>
	<td><%=TXT_ANY_OF_THE_DATES_TIMES%>
	<br>&nbsp;
	<!--#include file="../includes/search/incDateTimeTable.asp" --></td>
</tr>
<%
End If

If bASrchOSSD Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_OSSD_COMPONENT%></td>
	<td><label for="forOSSD"><input name="forOSSD" id="forOSSD" type="checkbox">&nbsp;<%=TXT_OSSD_SUITABLE%></label></td>
</tr>
<%
End If

Dim strOrgName

If bASrchOwner Then
	Call openAgencyListRst(DM_VOL, True, True)
	With rsListAgency
		If Not .EOF Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_RECORD_OWNER%></td>
	<td><span class="SmallNote"><%=TXT_HOLD_CTRL%></span>
	<br><select name="RO" id="RO" multiple>
<%
			While Not .EOF
				strOrgName =  IIf(Nl(.Fields("ORG_NAME_FULL")),vbNullString," - " & .Fields("ORG_NAME_FULL"))
				If Len(strOrgName) > 80 Then
					strOrgName = Left(strOrgName,80) & " ..."
				End If
				%><option value="<%=.Fields("AgencyCode")%>"><%=.Fields("AgencyCode") & strOrgName%></option><%
				.MoveNext
			Wend
%>
		</select></td>
</tr>
<%
		End If
	End With
	Call closeAgencyListRst()
End If

If bASrchLastRequest Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LAST_EMAIL_UPDATE%></td>
	<td><%=TXT_MORE_THAN%> <input type="text" name="LastEmail" title=<%=AttrQs(TXT_DAYS_SINCE_EMAIL_REQUESTING_UPDATE)%> id="LastEmail" size="3" maxlength="3"> <%=TXT_DAYS%></td>
</tr>
<%
End If

Call openCustFieldRst(DM_VOL, g_intViewTypeVOL, True, True)
Call makeDateSearchRow(1)
Call makeDateSearchRow(2)
Call closeCustFieldRst()

Call openCustFieldRst(DM_VOL, g_intViewTypeVOL, True, False)
Call makeCustomFieldSearchRow(1)
Call makeCustomFieldSearchRow(2)
Call closeCustFieldRst()

Call makeSharingProfileAdvSearchForm()

If bASrchEmail Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_EMAIL%></td>
	<td><label for="HasEmail_A"><input type="radio" name="HasEmail" id="HasEmail_A" value="A" checked>&nbsp;<%=TXT_ALL_RECORDS%></label>
		<br><label for="HasEmail_E"><input type="radio" name="HasEmail" id="HasEmail_E" value="E">&nbsp;<%=TXT_ONLY_EMAIL%></label>
		<label for="HasEmail_NE"><input type="radio" name="HasEmail" id="HasEmail_NE" value="NE">&nbsp;<%=TXT_ONLY_NO_EMAIL%></label>
		<br><label for="HasEmail_U"><input type="radio" name="HasEmail" id="HasEmail_U" value="U">&nbsp;<%=TXT_CAN_UPDATE_EMAIL%></label>
		<label for="HasEmail_NU"><input type="radio" name="HasEmail" id="HasEmail_NU" value="NU">&nbsp;<%=TXT_CANNOT_UPDATE_EMAIL%></label></td>
</tr>
<%
End If
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_DISPLAY_UNTIL_DATE%></td>
	<td><label for="DisplayStatus_A"><input type="radio" name="DisplayStatus" id="DisplayStatus_A" value="A"<%If g_bCanSeeExpired Then%> checked<%End If%>>&nbsp;<%=TXT_ALL_RECORDS%></label>
		<label for="DisplayStatus_C"><input type="radio" name="DisplayStatus" id="DisplayStatus_C" value="C"<%If Not g_bCanSeeExpired Then%> checked<%End If%>>&nbsp;<%=TXT_ONLY_CURRENT%></label>
		<label for="DisplayStatus_P"><input type="radio" name="DisplayStatus" id="DisplayStatus_P" value="P">&nbsp;<%=TXT_ONLY_EXPIRED%></label></td>
</tr>
<%
If g_bCanSeeNonPublicVOL Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_PUBLIC_STATUS%></td>
	<td><label for="PublicStatus_A"><input type="radio" name="PublicStatus" id="PublicStatus_A" value="" checked>&nbsp;<%=TXT_ALL_RECORDS%></label>
		<label for="PublicStatus_P"><input type="radio" name="PublicStatus" id="PublicStatus_P" value="P">&nbsp;<%=TXT_ONLY_PUBLIC%></label>
		<label for="PublicStatus_N"><input type="radio" name="PublicStatus" id="PublicStatus_N" value="N">&nbsp;<%=TXT_ONLY_NONPUBLIC%></label></td>
</tr>
<%
End If

If g_bCanSeeDeletedVOL Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_DELETED_STATUS%></td>
	<td><label for="incDel"><input name="incDel" id="incDel" type="checkbox"> <%=TXT_INCLUDE_DELETED%></label></td>
</tr>
<%
End If

If user_bCanAddSQLVOL Then
%>
<tr>
	<td class="FieldLabelLeft"><label for="Limit"><%=TXT_SQL%></label></td>
	<td><a href="javascript:openWinXL('<%=makeLink("sql_help.asp",vbNullString,vbNullString)%>','sqlHelp')"><%=TXT_SQL_HELP%></a>
	<br><textarea name="Limit" id="Limit" cols="<%=TEXTAREA_COLS-10%>" rows="<%=TEXTAREA_ROWS_LONG%>"></textarea></td>
</tr>
<%
End If

Dim bHaveAChecklist

Set rsASrchViewData = rsASrchViewData.NextRecordset

With rsASrchViewData
	If Not .EOF Then
		bHaveAChecklist = True
%>
<tr>
	<td class="FieldLabelLeft"><label for="CheckListSource"><%=TXT_CHECKLISTS%></label></td>
	<td><div id="CheckListSourceContainer">
	<select id="CheckListSource">
<%
		While Not .EOF
%>
		<option value="<%=.Fields("ChecklistSearch")%>" id="Chk<%=.Fields("ChecklistSearch")%>"><%=.Fields("FieldDisplay")%></option>

<%
			.MoveNext
		Wend
%>
	</select> <input type="button" id="AddChecklistCriteria" value="<%=TXT_ADD%>"></div>
	</td>
</tr>
<%
	End If
End With

rsASrchViewData.Close
Set rsASrchViewData = Nothing
%>
</table>
<%
Dim bSearchDisplay, _
	bNewWindow
bSearchDisplay = getSessionValue("SearchDisplayVOL") = "on"
bNewWindow = getSessionValue("NewWindowVOL") = "on"
%>
<p><label for="NewWindow"><input type="checkbox" name="NewWindow" id="NewWindow"<%=Checked(bNewWindow)%>>&nbsp;<%=TXT_SEARCH_RESULTS_NEW_WINDOW%></label>
<br><label for="SearchDisplay"><input type="checkbox" name="SearchDisplay" id="SearchDisplay"<%=Checked(bSearchDisplay)%>>&nbsp;<%=TXT_DISPLAY_SEARCH_DETAILS%></label></p>

<p><input type="submit" value="<%=TXT_SEARCH%>"> <input type="RESET" id="ResetForm" value="<%=TXT_CLEAR_FORM%>"></p>
</form>

<%If bHaveAChecklist Then%>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>

<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/advsrch.js") %>
<% g_bListScriptLoaded = True %>

<script type="text/javascript">
jQuery(function($) {
	init_cached_state()
	init_checklist_search('<%=makeLinkB(ps_strPathToStart & "jsonfeeds/checklist_searchform.asp")%>');
	init_pre_fill_search_parameters('<%=makeLinkB(ps_strPathToStart & "jsonfeeds/checklist_searchform.asp")%>');
	init_find_box({
		P: "<%= makeLink(ps_strPathToStart & "jsonfeeds/vol_keyword_generator.asp", "SearchType=P", vbNullString) %>", 
		O: "<%= makeLink(ps_strPathToStart & "jsonfeeds/vol_keyword_generator.asp", "SearchType=O", vbNullString) %>", 
			}, $('#EntryForm'));
	restore_cached_state();
});
</script>

<%
End If
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
