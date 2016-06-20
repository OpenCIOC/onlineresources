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
<!--#include file="../../includes/core/adovbs.inc" -->
<!--#include file="../../includes/core/incVBUtils.asp" -->
<!--#include file="../../includes/validation/incBasicTypes.asp" -->
<!--#include file="../../includes/core/incRExpFuncs.asp" -->
<!--#include file="../../includes/core/incHandleError.asp" -->
<!--#include file="../../includes/core/incSetLanguage.asp" -->
<!--#include file="../../includes/core/incPassVars.asp" -->
<!--#include file="../../text/txtGeneral.asp" -->
<!--#include file="../../text/txtError.asp" -->
<!--#include file="../../includes/core/incConnection.asp" -->
<!--#include file="../../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_VOL, DM_VOL, "../../", "volunteer/profile/", vbNullString)
%>
<!--#include file="../../includes/core/incCrypto.asp" -->
<!--#include file="../../includes/core/incSecurity.asp" -->
<!--#include file="../../includes/core/incHeader.asp" -->
<!--#include file="../../includes/core/incFooter.asp" -->
<!--#include file="../../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../../text/txtAgencyContact.asp" -->
<!--#include file="../../text/txtCommonForm.asp" -->
<!--#include file="../../text/txtDateTimeTable.asp" -->
<!--#include file="../../text/txtEntryForm.asp" -->
<!--#include file="../../text/txtFinder.asp" -->
<!--#include file="../../text/txtFormSecurity.asp" -->
<!--#include file="../../text/txtGeneralForm.asp" -->
<!--#include file="../../text/txtReferral.asp" -->
<!--#include file="../../text/txtSearchBasicVOL.asp" -->
<!--#include file="../../text/txtUsers.asp" -->
<!--#include file="../../text/txtVOLProfile.asp" -->
<!--#include file="../../text/txtVolunteer.asp" -->
<!--#include file="../../includes/core/incFormat.asp" -->
<!--#include file="../../includes/list/incInterestGroupList.asp" -->
<!--#include file="../../includes/list/incSysLanguageList.asp" -->
<!--#include file="../../includes/update/incEntryFormGeneral.asp" -->
<!--#include file="../../includes/vprofile/incPersonalForm.asp" -->
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->
<%
If Not g_bUseVolunteerProfiles Then
	Call goToPageB(ps_strPathToStart & "volunteer/")
ElseIf Not vprofile_bLoggedIn Then
	Call goToPageB("login.asp")
End If

Const SHOW_REFERRALS = 0
Const SHOW_CRITERIA = 1
Const SHOW_PERSONAL = 2
Dim intShow, strShow
strShow = LCase(Trim(Request("ShowTab")))
Select Case strShow
Case "criteria"
	intShow = SHOW_CRITERIA
Case "personal"
	intShow = SHOW_PERSONAL
Case Else
	intShow = SHOW_REFERRALS
End Select

Dim objReturn, objErrMsg
Dim cmdProfileInfo, rsProfileInfo
Set cmdProfileInfo = Server.CreateObject("ADODB.Command")
With cmdProfileInfo
	.ActiveConnection = getCurrentVOLBasicCnn()
	.CommandText = "sp_VOL_Profile_sf"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, vprofile_strID)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsProfileInfo = Server.CreateObject("ADODB.Recordset")
With rsProfileInfo
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdProfileInfo
End With

Dim dicBasicInfo, objField
Set dicBasicInfo = Server.CreateObject("Scripting.Dictionary")

For Each objField in rsProfileInfo.Fields
	dicBasicInfo(objField.Name) = objField.Value
Next

Call addToHeader("<link rel=""stylesheet"" type=""text/css"" href=""" & ps_strPathToStart & "styles/taxonomy.css""/>")
Call makePageHeader(TXT_VOLUNTEER_PROFILE, TXT_VOLUNTEER_PROFILE, True, True, True, True)
%>
<h2><%= TXT_WELCOME & " " & dicBasicInfo("FirstName") & " " & dicBasicInfo("LastName")%>! <a class="btn btn-default" role="button" href="<%=makeLink("logout.asp", strSearchArgs, vbNullString)%>"><span class="glyphicon glyphicon-log-out" aria-hidden="true"></span> <strong><%=TXT_LOGOUT%></strong></a></h2>
</form>

<%
Dim strCommunityIDs, strInterestIDs, strCommunityHTML, strInterestHTML, bHaveACommunity, bHaveAnInterest
strCommunityIDs = vbNullString
strInterestIDs = vbNullString
strCommunityHTML = vbNullString
strInterestHTML = vbNullString
bHaveACommunity = False
bHaveAnInterest = False

Set rsProfileInfo = rsProfileInfo.NextRecordset()
With rsProfileInfo
	If .EOF Then
		strCommunityHTML = "&nbsp;"
	Else
		Dim intWrapNum, intWrapAt
		intWrapAt = g_intCommSrchWrapAtVOL - 1
		intWrapNum = intWrapAt
		strCommunityHTML = "<table class=""NoBorder cell-padding-1"">" & vbCrLf
		While Not .EOF
			If .Fields("IS_SELECTED") Then
				strCommunityIDs = strCommunityIDs & StringIf(bHaveACommunity, ",") & .Fields("CM_ID")
				bHaveACommunity = True
			End If
			If intWrapNum = intWrapAt Then
				strCommunityHTML = strCommunityHTML & "<tr valign=""top"">" & vbCrLf
			End If
			strCommunityHTML = strCommunityHTML & "<td class=""checkbox-list-item""><label><input type=""checkbox"" name=""CMID"" value=""" & .Fields("CM_ID") & """ " & Checked(.Fields("IS_SELECTED")) & ">&nbsp;" & Server.HTMLEncode(.Fields("Community")) & "</label></td>" & vbCrLf
			If intWrapNum > 0 Then
				intWrapNum = intWrapNum - 1
			Else
				strCommunityHTML = strCommunityHTML & "</tr>" & vbCrLf

				intWrapNum = intWrapAt
			End If
			.MoveNext
		Wend
		If intWrapNum <> intWrapAt Then
			strCommunityHTML = strCommunityHTML & "</tr>" & vbCrLf

		End If
		strCommunityHTML = strCommunityHTML & "</table>" & vbCrLf
	End If
End With

Dim intAI_ID
Set rsProfileInfo = rsProfileInfo.NextRecordset()
With rsProfileInfo
	While Not .EOF
		intAI_ID = .Fields("AI_ID")
		strInterestIDs = strInterestIDs & StringIf(bHaveAnInterest, ",") & intAI_ID
		bHaveAnInterest = True
		strInterestHTML = strInterestHTML & "<div data-id=""" & intAI_ID & """ class=""selected_interest"">" & Server.HTMLEncode(.Fields("InterestName")) & " [ <a href=""#"" class=""remove_interest""><img src=""" & ps_strRootPath & "images/redx.gif"" alt=""" & TXT_REMOVE & """></a> ]</div>" & vbCrLf

		.MoveNext
	Wend
End With

Set rsProfileInfo = rsProfileInfo.NextRecordset()
With rsProfileInfo
If Not .EOF Then
	Dim strSearchURL, strSearchArgs, strSearchCon
	strSearchCon = vbNullString
	strSearchArgs = vbNullString
	If Not Nl(dicBasicInfo("BirthDate")) Then
		strSearchArgs = "Age=" & Server.URLEncode(Round(DateDiff("d", dicBasicInfo("BirthDate"), Date())/365,1))
		strSearchCon = "&"
	End If
	Dim aDays, aTimes, strDay, strTime, strFName
	aDays = Array("M","TU","W","TH","F", "ST", "SU")
	aTimes = Array("Morning", "Afternoon", "Evening")
	For Each strDay in aDays
		For Each strTime in aTimes
			strFName = "SCH_" & strDay & "_" & strTime
			If dicBasicInfo(strFName) Then
				strSearchArgs = strSearchArgs & strSearchCon & strFName & "=on"
				strSearchCon = "&"
			End If
		Next
	Next
	If bHaveACommunity Then
		strSearchArgs = strSearchArgs & strSearchCon & "CMID=" & strCommunityIDs
		strSearchCon = "&"
	End If
	If bHaveAnInterest Then
		strSearchArgs = strSearchArgs & strSearchCon & "AIID=" & strInterestIDs
		strSearchCon = "&"
	End If
%>
<div>
<h3><%= TXT_SEARCH_NOW %>!</h3>
<p>
<%If Not Nl(strSearchArgs) Then%>
<%= TXT_USE_MY_SAVED_SEARCH_PROFILE %><a href="<%=makeLink(ps_strPathToStart & "volunteer/results.asp", strSearchArgs, vbNullString)%>" style="font-weight:bolder"><%= TXT_SEARCH_NOW %></a>
<em><%= TXT_OR_LC %></em> 
<%End If%>
<%= TXT_START_A_NEW %><a href="<%=makeLinkB(ps_strPathToStart & "volunteer/")%>" style="font-weight:bolder"><%=TXT_VOLUNTEER_SEARCH%></a>.</p>
<%If .RecordCount <> 1 Then%>
<div>
<%= TXT_REMEMBER_WORKS_WITH_ALL_SITES %>
<ul>
<%
While Not .EOF
	strSearchURL = IIf(.Fields("DomainFullSSLCompatible") And .Fields("FullSSLCompatible"), "https://", "http://") & .Fields("AccessURL") & "/volunteer/"
	strSearchURL = makeLink(strSearchURL, StringIf(Not Nl(.Fields("ViewType")), "UseVOLVw=" & .Fields("ViewType")), "UseVOLVw")
	%><li><a href="<%=strSearchURL%>"><%=strSearchURL%></a></li><%
	.MoveNext
Wend
%>
</ul>
</div>
<%End If%>
</div>
<%
End If
End With
Set rsProfileInfo = rsProfileInfo.NextRecordset()
With rsProfileInfo

If .EOF And intShow > 0 Then
	intShow = intShow -1
End If
%>

<div id="TabbedDisplayTabArea" class="max-width-lg">
<ul>

<% If Not .EOF Then %>
<li><a href="#referral_tab"><%= TXT_MY_APPLICATIONS %></a></li>
<%End If%>
<li><a href="#search_tab"><%= TXT_MY_SEARCH_PROFILE %></a></li>
<li><a href="#personal_tab"><%= TXT_MY_PERSONAL_INFO %></a></li>
</ul>
<%
If Not .EOF Then
%>
<div id="referral_tab">
<table class="BasicBorder cell-padding-3 sortable_table"  data-sortdisabled="[4]" data-default-sort="[0,1]">
<thead>
<tr>
	<th class="RevTitleBox"><%= TXT_APPLICATION_DATE %></th>
	<th class="RevTitleBox"><%=TXT_POSITION_TITLE%></th>
	<th class="RevTitleBox"><%=TXT_ORG_NAMES%></th>
	<th class="RevTitleBox"><%= TXT_OUTCOME %></th>
	<th class="RevTitleBox"><%=TXT_ACTION%></th>
</tr>
</thead>
<tbody>
<%

		Dim bOutcomeSuccessful, strOutcomeNotes, _
				dReferralDate, _
				strPositionTitle, strOrgName, _
				intRefID, _
				strOutcome

		While Not .EOF

		bOutcomeSuccessful = .Fields("VolunteerSuccessfulPlacement")
		strOutcomeNotes = Server.HTMLEncode(Ns(.Fields("VolunteerOutcomeNotes")))
		dReferralDate = .Fields("ReferralDate")
		strPositionTitle = Server.HTMLEncode(Ns(.Fields("POSITION_TITLE")))
		strOrgName = .Fields("ORG_NAME_FULL")
		intRefID = .Fields("REF_ID")

		If Nl(bOutcomeSuccessful) Then
			strOutcome = "N"
		ElseIf bOutcomeSuccessful Then
			strOutcome = "S"
		Else
			strOutcome = "U"
		End If

%>
<tr valign="TOP" id="referral_table_row_<%=intRefID%>" data-refid="<%=intRefID%>">
	<td class="ReferralDate" data-tbl-key="<%=Nz(ISODateTimeString(dReferralDate), "1900-01-01 00:00:00")%>"><%=Nz(DateString(dReferralDate, True), "&nbsp;")%></td>
	<td class="PositionTitle"><%= Nz(strPositionTitle, "") %></td>

	<td><%=strOrgName%></td>
	<td id="referral_outcome_<%=intRefID%>" data-outcome="<%= strOutcome %>">
		<div class="OutcomeContainer" <%= StringIf(strOutcome="N", "style=""display: None""") %>>
			<strong><%= TXT_OUTCOME %>:</strong> <span class="OutcomeSuccessfull" <%=StringIf(strOutcome <> "S", "style=""display: none;""")%>><%= TXT_SUCCESSFUL %></span><span class="OutcomeUnsuccessful" <%= StringIf(strOutcome <> "U", "style=""display: none""")%>><%= TXT_UNSUCCESSFUL %></span>
		</div>
		<div class="OutcomeNotesContainer" <%= StringIf(Nl(strOutcomeNotes), "style=""display: none""") %>>
			<strong><%= TXT_NOTES %>:</strong> <span class="OutcomeNotes"><%=Server.HTMLEncode(strOutcomeNotes)%></span>
		</div>
	</td>
	<td>
		<input type="button" id="referral_outcome_edit_<%=intRefID%>" class="referral_outcome_edit btn btn-default" value="<%= TXT_OUTCOME %>">
		<input type="button" id="referral_hide_<%=intRefID%>" class="referral_hide btn btn-default" value="<%= TXT_HIDE %>">
	</td>
</tr>
<%
			.MoveNext
		Wend
%>
</tbody>
</table>

</div>
<%
End If
End With
%>
<div id="search_tab">
<form method="post" action="criteria.asp" id="criteria_form">
<div style="display: none;">
<%=g_strCacheFormVals%>
</div>
<table class="BasicBorder cell-padding-4">
	<tr><th colspan="2" class="RevTitleBox"><%= TXT_SEARCH_PROFILE %></th></tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_EMAIL_NOTIFICATIONS %></td>
		<td><input type="checkbox" name="NotifyNew"<%=Checked(dicBasicInfo("NotifyNew"))%>> <%= " " & TXT_NOTIFY_ME_NEW %>
			<br><input type="checkbox" name="NotifyUpdated"<%=Checked(dicBasicInfo("NotifyUpdated"))%>> <%= " " & TXT_NOTIFY_ME_UPDATED %>
		</td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_DATE_OF_BIRTH %></td>
		<td><%= Replace(TXT_INST_DATE_OF_BIRTH, "[DATE]", DateString(CDate("1979-06-21"), True)) %>
			<br><%=makeDateFieldVal("BirthDate", dicBasicInfo("BirthDate"), False, False, False, False, False, False)%>
		</td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_COMMUNITIES %></td>
		<td><%= TXT_INST_COMMUNITIES %>
		<br><%=strCommunityHTML%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_DATES_AND_TIMES %></td>
		<td><%= TXT_INST_DATES_AND_TIMES %>
		<br>&nbsp;
		<table class="BasicBorder cell-padding-2">
			<tr class="FieldLabelCenterClr">
				<td>&nbsp;</td>
				<td><%= TXT_TIME_MORNING %><br><%= TXT_TIME_BEFORE_12 %></td>
				<td><%= TXT_TIME_AFTERNOON %><br><%= TXT_TIME_12_6 %></td>
				<td><%= TXT_TIME_EVENING %><br><%= TXT_TIME_AFTER_6 %></td>
			</tr>
			<tr>
				<td class="FieldLabelClr"><%= TXT_DAY_MONDAY %></td>
				<td align="center"><input name="SCH_M_Morning" type="checkbox"<%=Checked(dicBasicInfo("SCH_M_Morning"))%>></td>
				<td align="center"><input name="SCH_M_Afternoon" type="checkbox"<%=Checked(dicBasicInfo("SCH_M_Afternoon"))%>></td>
				<td align="center"><input name="SCH_M_Evening" type="checkbox"<%=Checked(dicBasicInfo("SCH_M_Evening"))%>></td>
			</tr>
			<tr>
				<td class="FieldLabelClr"><%= TXT_DAY_TUESDAY %></td>
				<td align="center"><input name="SCH_TU_Morning" type="checkbox"<%=Checked(dicBasicInfo("SCH_TU_Morning"))%>></td>
				<td align="center"><input name="SCH_TU_Afternoon" type="checkbox"<%=Checked(dicBasicInfo("SCH_TU_Afternoon"))%>></td>
				<td align="center"><input name="SCH_TU_Evening" type="checkbox"<%=Checked(dicBasicInfo("SCH_TU_Evening"))%>></td>
			</tr>
			<tr>
				<td class="FieldLabelClr"><%= TXT_DAY_WEDNESDAY %></td>
				<td align="center"><input name="SCH_W_Morning" type="checkbox"<%=Checked(dicBasicInfo("SCH_W_Morning"))%>></td>
				<td align="center"><input name="SCH_W_Afternoon" type="checkbox"<%=Checked(dicBasicInfo("SCH_W_Afternoon"))%>></td>
				<td align="center"><input name="SCH_W_Evening" type="checkbox"<%=Checked(dicBasicInfo("SCH_W_Evening"))%>></td>
			</tr>
			<tr>
				<td class="FieldLabelClr"><%= TXT_DAY_THURSDAY %></td>
				<td align="center"><input name="SCH_TH_Morning" type="checkbox"<%=Checked(dicBasicInfo("SCH_TH_Morning"))%>></td>
				<td align="center"><input name="SCH_TH_Afternoon" type="checkbox"<%=Checked(dicBasicInfo("SCH_TH_Afternoon"))%>></td>
				<td align="center"><input name="SCH_TH_Evening" type="checkbox"<%=Checked(dicBasicInfo("SCH_TH_Evening"))%>></td>
			</tr>
			<tr>
				<td class="FieldLabelClr"><%= TXT_DAY_FRIDAY %></td>
				<td align="center"><input name="SCH_F_Morning" type="checkbox" <%=Checked(dicBasicInfo("SCH_F_Morning"))%>></td>
				<td align="center"><input name="SCH_F_Afternoon" type="checkbox" <%=Checked(dicBasicInfo("SCH_F_Afternoon"))%>></td>
				<td align="center"><input name="SCH_F_Evening" type="checkbox" <%=Checked(dicBasicInfo("SCH_F_Evening"))%>></td>
			</tr>
			<tr>
				<td class="FieldLabelClr"><%= TXT_DAY_SATURDAY %></td>
				<td align="center"><input name="SCH_ST_Morning" type="checkbox"<%=Checked(dicBasicInfo("SCH_ST_Morning"))%>></td>
				<td align="center"><input name="SCH_ST_Afternoon" type="checkbox"<%=Checked(dicBasicInfo("SCH_ST_Afternoon"))%>></td>
				<td align="center"><input name="SCH_ST_Evening" type="checkbox"<%=Checked(dicBasicInfo("SCH_ST_Evening"))%>></td>
			</tr>
			<tr>
				<td class="FieldLabelClr"><%= TXT_DAY_SUNDAY %></td>
				<td align="center"><input name="SCH_SN_Morning" type="checkbox" <%=Checked(dicBasicInfo("SCH_SN_Morning"))%>></td>
				<td align="center"><input name="SCH_SN_Afternoon" type="checkbox"<%=Checked(dicBasicInfo("SCH_SN_Afternoon"))%>></td>
				<td align="center"><input name="SCH_SN_Evening" type="checkbox"<%=Checked(dicBasicInfo("SCH_SN_Evening"))%>></td>
			</tr>
		</table>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_AREAS_OF_INTEREST %></td>
		<td class="InterestList">
			<div class="TermList" id="selected_interests">
				<%=strInterestHTML%>
				<span class="NoSelectedInterests<%=StringIf(bHaveAnInterest, " NotVisible")%>"><%= TXT_NO_INTERESTS %></span>
				<input type="hidden" value="<%=strInterestIDs%>" name="AI_ID" class="selected_interests_input">
			</div>
			<p><a href="#javascript" class="btn btn-info" id="interests_button"><%= TXT_FIND_INTERESTS %></a> <a href="#javascript" class="btn btn-info" id="clear_interests"><%= TXT_REMOVE_ALL %></a></p>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<input type="submit" name="Submit" value="<%=TXT_SUBMIT%>" class="btn btn-default">
			<input type="reset" value="<%=TXT_RESET_FORM%>" id="criteria_reset_button" class="btn btn-default">
		</td>
	</tr>
</table>
</form>
</div>
<div id="personal_tab">
<% 
Call VOLProfilePersonalForm(False, dicBasicInfo)
%>
</div>
</div>

<div id="interest_dialog" style="display: none;">
<div class="InterestList" style="margin: 0px 10px 0px 10px; padding: 0px; float: right;">
	<div class="TermListTitle"><%= TXT_SELECTED_INTERESTS %></div>
		<div class="TermList" id="dlg_selected_interests">
		</div>

		<p><a href="#javascript" class="btn btn-default" id="accept_button"><%= TXT_ACCEPT_AND_CLOSE %></a> <a href="#javascript" class="btn btn-default" id="clear_button"><%= TXT_REMOVE_ALL %></a></p>
	</div>

	<% If Not g_bOnlySpecificInterests Then %>
	<div>
	<form action="<%=ps_strPathToStart & "interestfind.asp"%>" id="interest_search_form">
	<%=g_strCacheFormVals%>
	<input type="hidden" name="ProfileSearch" value="on">
	<table class="BasicBorder cell-padding-2">
	<%
		Call openInterestGroupListRst()
	%>
		<tr>
			<td class="FieldLabelLeft"><%= TXT_AREA_OF_INTEREST %></td>
			<td><%=makeInterestGroupList(vbNullString,"IGID",False)%>&nbsp;<input type="submit" value="<%=TXT_SEARCH%>"></td>
		</tr>
	<%
		Call closeInterestGroupListRst() 
	%>
	</table>
	</form>
	</div>
	<% End If %>

<div>
	<h3><%=TXT_AREA_OF_INTEREST_SEARCH_RESULTS%></h3>
	<div id="results_area">
	<p><%=TXT_NOTHING_TO_SEARCH%></p>
	</div>
</div>

</div><!-- dialog -->
<div id="confirm_hide_dialog" style="display: none;">
<h3><%= TXT_CONFIRM_APPLICATION_HIDE %></h3>
<form style="display:none" id="hide_confirm_form">
<%=g_strCacheFormVals%>
<input type="hidden" name="RefID" id="hide_confirm_refid" value="">
<input type="hidden" name="Confirm" value="on">
</form>
<p><%= TXT_INST_CONFIRM_APPLICATION_HIDE %></p>
<input type="button" name="Submit" value="<%= TXT_HIDE %>" id="confirm_okay"> <input type="button" value="<%= TXT_CANCEL %>" id="confirm_cancel">
</div>

<div id="outcome_dialog" style="display: none;">
<h2 id="outcome_dialog_title"><%=strPositionTitle%> (<%=dReferralDate%>)</h1>
<form id="outcome_form">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hiden" name="RefID" id="outcome_refid" value="">
</div>
<table class="BasicBorder cell-padding-3">
	<tr>
		<td class="FieldLabelLeft"><%= TXT_OUTCOME %></td>
		<td>
			<select name="Outcome" id="outcome_state">
				<option value="N"><%= TXT_UNKNOWN %></option>
				<option value="S"><%= TXT_SUCCESSFUL %></option>
				<option value="U"><%= TXT_UNSUCCESSFUL %></option>
			</select>
		</td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_NOTES %></td>
		<td><textarea cols="<%=TEXTAREA_COLS%>" rows="<%=TEXTAREA_ROWS_XLONG%>" name="Notes" id="outcome_notes"></textarea></td>
	</tr>
	<tr>
		<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_SUBMIT%>"> <input type="button" value="<%=TXT_CANCEL%>" id="outcome_cancel"></td>
	</tr>
</table>
</form>
</div>

<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/vprofiles.js") %>
<script type="text/javascript">
(function() {
init_vprofiles(<%= intShow %>, "<%= ps_strRootPath %>", "<%= TXT_REMOVE %>", <%= IIf(g_bOnlySpecificInterests, """" & makeLink("~/volunteer/interestfind.asp", "ProfileSearch=on", vbNullString) & """", "null") %>);
})();
</script>
<%
Call makePageFooter(True)
%>
<!--#include file="../../includes/core/incClose.asp" -->


