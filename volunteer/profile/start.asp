<%@  language="VBSCRIPT" %>
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

Call makePageHeader(TXT_VOLUNTEER_PROFILE, TXT_VOLUNTEER_PROFILE, True, True, True, True)
%>
<h2><%=TXT_WELCOME & " " & dicBasicInfo("FirstName") & " " & dicBasicInfo("LastName")%>!
    <a class="btn btn-default" role="button" href="<%=makeLink("logout.asp", strSearchArgs, vbNullString)%>"><span class="glyphicon glyphicon-log-out" aria-hidden="true"></span>
    <strong><%=TXT_LOGOUT%></strong></a>
</h2>

<%
Dim strCommunityIDs, strInterestIDs, strCommunityHTML, strInterestHTML, bHaveACommunity, bHaveAnInterest, strJoin
strCommunityIDs = vbNullString
strInterestIDs = vbNullString
strCommunityHTML = vbNullString
strInterestHTML = vbNullString
bHaveACommunity = False
bHaveAnInterest = False
strJoin = vbNullString

Set rsProfileInfo = rsProfileInfo.NextRecordset()
With rsProfileInfo
	If .EOF Then
		strCommunityHTML = vbNullString
	Else
		Dim strWrapClass
		Select Case g_intCommSrchWrapAtVOL
			Case 0
				strWrapClass = "col-xs-12"
			Case 1
				strWrapClass = "col-xs-12"
			Case 2
				strWrapClass = "col-xs-12 col-md-6"
			Case 3
				strWrapClass = "col-xs-12 col-sm-6 col-md-4"
			Case Else
				strWrapClass = "col-xxs-12 col-xs-6 col-md-4 col-lg-3"
		End Select

		strCommunityHTML = "<div class=""row"">" & vbCrLf
		While Not .EOF
			If .Fields("IS_SELECTED") Then
				strCommunityIDs = strCommunityIDs & StringIf(bHaveACommunity, ",") & .Fields("CM_ID")
				bHaveACommunity = True
			End If
			strCommunityHTML = strCommunityHTML & _
				"<div class=" & AttrQs(strWrapClass) & ">" & _
				"<label for=" & AttrQs("CMID_" & .Fields("CM_ID")) & ">" & _
					"<input type=""checkbox"" name=""CMID"" id=" & AttrQs("CMID_" & .Fields("CM_ID")) & " value=" & AttrQs(.Fields("CM_ID")) & Checked(.Fields("IS_SELECTED")) & "> " & _
					.Fields("Community") & _
				"</label>" & _
				"</div>"
			.MoveNext
		Wend
		strCommunityHTML = strCommunityHTML & "</div>" & vbCrLf
	End If
End With

Dim intAI_ID
Set rsProfileInfo = rsProfileInfo.NextRecordset()
With rsProfileInfo

	strInterestHTML = "<div id=""AI_existing_add_container"">"
	While Not .EOF

		' this next block of code is the only difference from the volunteer entryform version of
		bHaveAnInterest = True
		strInterestIDs = strInterestIDs & strJoin & .Fields("AI_ID")
		strJoin = ","
		' End of difference from vol entry form

		strInterestHTML = strInterestHTML & "<input name=""AI_ID"" id=""AI_ID_" & .Fields("AI_ID") & """ type=""checkbox"" value=""" & .Fields("AI_ID") & """ checked>&nbsp;<label for=""AI_ID_" & .Fields("AI_ID") & """>" & .Fields("InterestName") & "</label> ; "
		.MoveNext
	Wend
	strInterestHTML = strInterestHTML & "</div>" & vbCrLf & _
		"<h4>" & TXT_ADD_INTERESTS & "</h4><div id=""AI_new_input_table"">"

	If Not g_bOnlySpecificInterests Then
		strInterestHTML = strInterestHTML & "<strong><label for=""NEW_AI"">" & TXT_FIND_BY_KEYWORD & "</label></strong>" & vbCrLf & "<br>"
	End If

	strInterestHTML = strInterestHTML & vbCrLf & _
		"<div class=""entryform-checklist-add-wrapper"">" & _
			"<div class=""entryform-checklist-add-left"">" & _
				"<input type=""text"" id=""NEW_AI"" class=""form-control"">" & _
			"</div>" & _
			"<div class=""entryform-checklist-add-right"">" & _
				"<button type=""button"" class=""btn btn-info"" id=""add_AI""><span class=""fa fa-plus"" aria-hidden=""true""></span> " & TXT_ADD & "</button>" & _
			"</div>" & _
		"</div>"

	If Not g_bOnlySpecificInterests Then
		strInterestHTML = strInterestHTML & _
			"<p><strong><label for=""InterestGroup"">" & TXT_FIND_BY_GENERAL_INTEREST & "</label></strong>" & vbCrLf & _
			"<br>"
		Call openInterestGroupListRst()
		strInterestHTML = strInterestHTML & makeInterestGroupList(vbNullString, "InterestGroup", True)
		Call closeInterestGroupListRst()

		strInterestHTML = strInterestHTML & "</div>"
	End If

	strInterestHTML = strInterestHTML & "<p class=""hidden-xs hidden-sm"">" & _
		TXT_NOT_SURE_ENTER & "<a href=""javascript:openWin('" & makeLink(ps_strPathToStart & "volunteer/interestfind.asp","Ln=" & g_objCurrentLang.Culture,"Ln") & "','cFind')"">" & TXT_AREA_OF_INTEREST_LIST & "</a>.</p>"
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
    <h3><%=TXT_SEARCH_NOW%>!</h3>
    <p>
        <%If Not Nl(strSearchArgs) Then%>
        <a class="btn btn-info" href="<%=makeLink(ps_strPathToStart & "volunteer/results.asp", strSearchArgs, vbNullString)%>"><%=TXT_USE_MY_SAVED_SEARCH_PROFILE%></a>
        <em><%=TXT_OR_LC%></em>
        <%End If%>
        <%=TXT_START_A_NEW%><a class="btn btn-info" href="<%=makeLinkB(ps_strPathToStart & "volunteer/")%>"><%=TXT_VOLUNTEER_SEARCH%></a>
    </p>
    <%
    If .RecordCount > 1 Then
    %>
    <div>
        <h3><%=TXT_REMEMBER_WORKS_WITH_ALL_SITES%></h3>
        <ul>
            <%
        While Not .EOF
	        strSearchURL = "https://" & .Fields("AccessURL") & "/volunteer/"
	        strSearchURL = makeLink(strSearchURL, StringIf(Not Nl(.Fields("ViewType")), "UseVOLVw=" & .Fields("ViewType")), "UseVOLVw")
            %>
            <li><a href="<%=strSearchURL%>"><%=strSearchURL%></a></li>
            <%
	        .MoveNext
        Wend
            %>
        </ul>
    </div>
    <%
        End If
    %>
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
<%
    If Not .EOF Then
%>
        <li><a href="#referral_tab"><%=TXT_MY_APPLICATIONS%></a></li>
<%
    End If
%>
        <li><a href="#search_tab"><%=TXT_MY_SEARCH_PROFILE%></a></li>
        <li><a href="#personal_tab"><%=TXT_MY_PERSONAL_INFO%></a></li>
    </ul>
    <%
    If Not .EOF Then
    %>
    <div id="referral_tab">
        <table class="BasicBorder cell-padding-3 sortable_table responsive-table-multicol" data-sortdisabled="[4]" data-default-sort="[0,1]">
            <thead>
                <tr class="field-header-row">
                    <th class="RevTitleBox"><%=TXT_APPLICATION_DATE%></th>
                    <th class="RevTitleBox field-header-cell"><%=TXT_POSITION_TITLE%></th>
                    <th class="RevTitleBox field-header-cell"><%=TXT_ORG_NAMES%></th>
                    <th class="RevTitleBox field-header-cell"><%=TXT_OUTCOME%></th>
                    <th class="RevTitleBox field-header-cell"><%=TXT_ACTION%></th>
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
		strPositionTitle = Nz(Server.HTMLEncode(Ns(.Fields("POSITION_TITLE"))),TXT_UNKNOWN)
		strOrgName = Nz(.Fields("ORG_NAME_FULL"),TXT_UNKNOWN)
		intRefID = .Fields("REF_ID")

		If Nl(bOutcomeSuccessful) Then
			strOutcome = "N"
		ElseIf bOutcomeSuccessful Then
			strOutcome = "S"
		Else
			strOutcome = "U"
		End If

                %>
                <tr valign="top" id="referral_table_row_<%=intRefID%>" data-refid="<%=intRefID%>">
                    <td class="ReferralDate" data-tbl-key="<%=Nz(ISODateTimeString(dReferralDate), "1900-01-01 00:00:00")%>">
                        <%=Nz(DateString(dReferralDate, True), "&nbsp;")%>
                    </td>
                    <td class="field-data-cell PositionTitle">
                        <strong><%=strPositionTitle%></strong>
                    </td>
                    <td class="field-data-cell">
                        <%=strOrgName%>
                    </td>
                    <td class="field-data-cell" id="referral_outcome_<%=intRefID%>" data-outcome="<%=strOutcome%>">
                        <div class="OutcomeContainer">
                            <strong><%=TXT_OUTCOME & TXT_COLON%></strong>
                            <span class="OutcomeUnknown" <%=StringIf(strOutcome <> "N", "style=""display: none;""")%>><%=TXT_UNKNOWN%></span>
                            <span class="OutcomeSuccessfull" <%=StringIf(strOutcome <> "S", "style=""display: none;""")%>><%=TXT_SUCCESSFUL%></span>
                            <span class="OutcomeUnsuccessful" <%= StringIf(strOutcome <> "U", "style=""display: none;""")%>><%= TXT_UNSUCCESSFUL %></span>
                        </div>
                        <div class="OutcomeNotesContainer" <%=StringIf(Nl(strOutcomeNotes), "style=""display: none;""")%>>
                            <strong><%=TXT_NOTES & TXT_COLON%></strong>
                            <span class="OutcomeNotes"><%=Server.HTMLEncode(strOutcomeNotes)%></span>
                        </div>
                    </td>
                    <td class="field-data-cell">
                        <button id="referral_outcome_edit_<%=intRefID%>" class="referral_outcome_edit btn btn-sm btn-info btn-action-list"><span class="fa fa-edit" aria-hidden="true"></span> <%=TXT_OUTCOME%></button>
                        <button id="referral_hide_<%=intRefID%>" class="referral_hide btn btn-sm btn-danger btn-action-list"><span class="fa fa-remove" aria-hidden="true"></span> <%=TXT_HIDE%></button>
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
            <h4><%=TXT_MY_SEARCH_PROFILE & TXT_COLON & TXT_VIEW_OR_UPDATE%></h4>
            <table class="BasicBorder cell-padding-4 form-table responsive-table">
                <tr>
                    <td class="field-label-cell"><%=TXT_EMAIL_NOTIFICATIONS%></td>
                    <td class="field-data-cell">
                        <input type="checkbox" name="NotifyNew" <%=Checked(dicBasicInfo("NotifyNew"))%>>
                        <%= " " & TXT_NOTIFY_ME_NEW %>
                        <br>
                        <input type="checkbox" name="NotifyUpdated" <%=Checked(dicBasicInfo("NotifyUpdated"))%>>
                        <%= " " & TXT_NOTIFY_ME_UPDATED %>
                    </td>
                </tr>
                <tr>
                    <td class="field-label-cell"><%=TXT_DATE_OF_BIRTH%></td>
                    <td class="field-data-cell"><%=Replace(TXT_INST_DATE_OF_BIRTH, "[DATE]", DateString(CDate("1979-06-21"), True))%>
                        <br>
                        <%=makeDateFieldVal("BirthDate", dicBasicInfo("BirthDate"), False, False, False, False, False, False)%>
                    </td>
                </tr>
                <tr>
                    <td class="field-label-cell">
                        <%=TXT_COMMUNITIES%>
                    </td>
                    <td class="field-data-cell">
                        <%=TXT_INST_COMMUNITIES%>
                        <%=strCommunityHTML%>
                    </td>
                </tr>
                <tr>
                    <td class="field-label-cell">
                        <%=TXT_DATES_AND_TIMES %>
                    </td>
                    <td class="field-data-cell"><%=TXT_INST_DATES_AND_TIMES_PROFILE %>
		                <table class="BasicBorder cell-padding-2 clear-line-above">
                            <tr class="FieldLabelCenterClr">
                                <td>&nbsp;</td>
                                <td><%=TXT_TIME_MORNING%><br>
                                    <%=TXT_TIME_BEFORE_12%></td>
                                <td><%=TXT_TIME_AFTERNOON%><br>
                                    <%=TXT_TIME_12_6%></td>
                                <td><%=TXT_TIME_EVENING%><br>
                                    <%=TXT_TIME_AFTER_6%></td>
                            </tr>
                            <tr>
                                <td class="FieldLabelClr"><%= TXT_DAY_MONDAY %></td>
                                <td align="center">
                                    <input name="SCH_M_Morning" type="checkbox" <%=Checked(dicBasicInfo("SCH_M_Morning"))%>></td>
                                <td align="center">
                                    <input name="SCH_M_Afternoon" type="checkbox" <%=Checked(dicBasicInfo("SCH_M_Afternoon"))%>></td>
                                <td align="center">
                                    <input name="SCH_M_Evening" type="checkbox" <%=Checked(dicBasicInfo("SCH_M_Evening"))%>></td>
                            </tr>
                            <tr>
                                <td class="FieldLabelClr"><%= TXT_DAY_TUESDAY %></td>
                                <td align="center">
                                    <input name="SCH_TU_Morning" type="checkbox" <%=Checked(dicBasicInfo("SCH_TU_Morning"))%>></td>
                                <td align="center">
                                    <input name="SCH_TU_Afternoon" type="checkbox" <%=Checked(dicBasicInfo("SCH_TU_Afternoon"))%>></td>
                                <td align="center">
                                    <input name="SCH_TU_Evening" type="checkbox" <%=Checked(dicBasicInfo("SCH_TU_Evening"))%>></td>
                            </tr>
                            <tr>
                                <td class="FieldLabelClr"><%= TXT_DAY_WEDNESDAY %></td>
                                <td align="center">
                                    <input name="SCH_W_Morning" type="checkbox" <%=Checked(dicBasicInfo("SCH_W_Morning"))%>></td>
                                <td align="center">
                                    <input name="SCH_W_Afternoon" type="checkbox" <%=Checked(dicBasicInfo("SCH_W_Afternoon"))%>></td>
                                <td align="center">
                                    <input name="SCH_W_Evening" type="checkbox" <%=Checked(dicBasicInfo("SCH_W_Evening"))%>></td>
                            </tr>
                            <tr>
                                <td class="FieldLabelClr"><%= TXT_DAY_THURSDAY %></td>
                                <td align="center">
                                    <input name="SCH_TH_Morning" type="checkbox" <%=Checked(dicBasicInfo("SCH_TH_Morning"))%>></td>
                                <td align="center">
                                    <input name="SCH_TH_Afternoon" type="checkbox" <%=Checked(dicBasicInfo("SCH_TH_Afternoon"))%>></td>
                                <td align="center">
                                    <input name="SCH_TH_Evening" type="checkbox" <%=Checked(dicBasicInfo("SCH_TH_Evening"))%>></td>
                            </tr>
                            <tr>
                                <td class="FieldLabelClr"><%= TXT_DAY_FRIDAY %></td>
                                <td align="center">
                                    <input name="SCH_F_Morning" type="checkbox" <%=Checked(dicBasicInfo("SCH_F_Morning"))%>></td>
                                <td align="center">
                                    <input name="SCH_F_Afternoon" type="checkbox" <%=Checked(dicBasicInfo("SCH_F_Afternoon"))%>></td>
                                <td align="center">
                                    <input name="SCH_F_Evening" type="checkbox" <%=Checked(dicBasicInfo("SCH_F_Evening"))%>></td>
                            </tr>
                            <tr>
                                <td class="FieldLabelClr"><%= TXT_DAY_SATURDAY %></td>
                                <td align="center">
                                    <input name="SCH_ST_Morning" type="checkbox" <%=Checked(dicBasicInfo("SCH_ST_Morning"))%>></td>
                                <td align="center">
                                    <input name="SCH_ST_Afternoon" type="checkbox" <%=Checked(dicBasicInfo("SCH_ST_Afternoon"))%>></td>
                                <td align="center">
                                    <input name="SCH_ST_Evening" type="checkbox" <%=Checked(dicBasicInfo("SCH_ST_Evening"))%>></td>
                            </tr>
                            <tr>
                                <td class="FieldLabelClr"><%= TXT_DAY_SUNDAY %></td>
                                <td align="center">
                                    <input name="SCH_SN_Morning" type="checkbox" <%=Checked(dicBasicInfo("SCH_SN_Morning"))%>></td>
                                <td align="center">
                                    <input name="SCH_SN_Afternoon" type="checkbox" <%=Checked(dicBasicInfo("SCH_SN_Afternoon"))%>></td>
                                <td align="center">
                                    <input name="SCH_SN_Evening" type="checkbox" <%=Checked(dicBasicInfo("SCH_SN_Evening"))%>></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="field-label-cell" id="FIELD_INTERESTS">
                        <%=TXT_AREAS_OF_INTEREST%>
                    </td>
                    <td class="field-data-cell InterestList">
                        <%=strInterestHTML%>
                        <button type="button" class="btn btn-danger" id="clear_interests"><span class="fa fa-remove" aria-hidden="true"></span> <%=TXT_REMOVE_ALL%></button>
                    </td>
                </tr>
                <tr>
                    <td class="field-data-cell" colspan="2">
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

<div id="confirm_hide_dialog" style="display: none;">
    <h3><%= TXT_CONFIRM_APPLICATION_HIDE %></h3>
    <form style="display:none" id="hide_confirm_form">
        <%=g_strCacheFormVals%>
        <input type="hidden" name="RefID" id="hide_confirm_refid" value="">
        <input type="hidden" name="Confirm" value="on">
    </form>
    <p><%= TXT_INST_CONFIRM_APPLICATION_HIDE %></p>
    <input class="btn btn-default" type="button" name="Submit" value="<%= TXT_HIDE %>" id="confirm_okay">
    <input class="btn btn-default" type="button" value="<%= TXT_CANCEL %>" id="confirm_cancel">
</div>

<div id="outcome_dialog" style="display: none;">
    <h2 id="outcome_dialog_title"><%=strPositionTitle%> (<%=dReferralDate%>)</h2>
    <form id="outcome_form">
        <div style="display: none">
            <%=g_strCacheFormVals%>
            <input type="hidden" name="RefID" id="outcome_refid" value="">
        </div>
        <table class="BasicBorder cell-padding-3">
            <tr>
                <td class="field-label-cell"><%= TXT_OUTCOME %></td>
                <td class="field-data-cell">
                    <select class="form-control" name="Outcome" id="outcome_state">
                        <option value="N"><%=TXT_UNKNOWN%></option>
                        <option value="S"><%=TXT_SUCCESSFUL%></option>
                        <option value="U"><%=TXT_UNSUCCESSFUL%></option>
                    </select>
                </td>
            </tr>
            <tr>
                <td class="field-label-cell"><%=TXT_NOTES%></td>
                <td class="field-data-cell">
                    <textarea class="form-control" cols="<%=TEXTAREA_COLS%>" rows="<%=TEXTAREA_ROWS_XLONG%>" name="Notes" id="outcome_notes"></textarea>
                </td>
            </tr>
            <tr>
                <td class="field-data-cell" colspan="2">
                    <input class="btn btn-default" type="submit" name="Submit" value="<%=TXT_SUBMIT%>">
                    <input class="btn btn-default" type="button" value="<%=TXT_CANCEL%>" id="outcome_cancel">
                </td>
            </tr>
        </table>
    </form>
</div>

<form class="NotVisible" name="stateForm" id="stateForm">
    <textarea id="cache_form_values"></textarea>
</form>
<%
    Dim strInterestGenURL
    strInterestGenURL = makeLinkB(ps_strPathToStart & "jsonfeeds/interest_generator.asp")
%>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/vprofiles.js") %>
<script type="text/javascript">

    (function () {
        init_vprofiles(<%=intShow%>, "<%=ps_strRootPath%>", "<%=TXT_REMOVE%>", "<%=TXT_NOT_FOUND%>", "<%=strInterestGenURL%>");
    })();
</script>
<%
Call makePageFooter(True)
%>
<!--#include file="../../includes/core/incClose.asp" -->
