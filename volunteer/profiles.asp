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

<% 'Base includes%>
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
<% 'End Base includes%>
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtReferral.asp" -->
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../text/txtVOLProfile.asp" -->
<%
If Not (user_bCanAccessProfiles And g_bUseVolunteerProfiles) Then
	Call securityFailure()
End If

Call addScript(ps_strPathToStart & makeAssetVer("scripts/formPrintMode.js"), "text/javascript")

Call makePageHeader(TXT_VOL_PROFILE_SUMMARY, TXT_VOL_PROFILE_SUMMARY, True, True, True, True)

Dim dStart, _
	dEnd

If IsDate(Request("FirstDate")) Then
	dStart = CDate(Request("FirstDate"))
Else
	dStart = DateAdd("yyyy",-1,Date())
End If

If IsDate(Request("LastDate")) Then
	dEnd = CDate(Request("LastDate"))
Else
	dEnd = Date()
End If

Dim cmdProfileSummary, rsProfileSummary
Set cmdProfileSummary = Server.CreateObject("ADODB.Command")
With cmdProfileSummary
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "sp_VOL_Profile_Summary"
	.CommandType = adCmdStoredProc
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@StartDate", adDate, adParamInput, 16, dStart)
	.Parameters.Append .CreateParameter("@EndDate", adDate, adParamInput, 16, dEnd)
	.CommandTimeout = 0
	Set rsProfileSummary = .Execute
End With

Dim strYearRange
strYearRange = DateString(dStart,True) & " - " & DateString(DateAdd("d",-1,dEnd),True)
%>

<form action="<%=ps_strThisPage%>" method="post" class="form">
<%=g_strCacheFormVals%>
<div class="row form-group clear-line-below">
	<label for="FirstDate" class="control-label col-sm-4 col-md-2"><%=TXT_ON_AFTER_DATE%></label>
	<div class="col-sm-8 col-md-3">
		<input type="text" name="FirstDate" id="FirstDate" class="DatePicker form-control" size="<%=DATE_TEXT_SIZE%>" maxlength="<%=DATE_TEXT_SIZE%>" value="<%=DateString(dStart,True)%>">
	</div>
	<label for="LastDate" class="control-label col-sm-4 col-md-2"><%=TXT_BEFORE_DATE%></label>
	<div class="col-sm-8 col-md-3">
		<input type="text" name="LastDate" id="LastDate" class="DatePicker form-control" size="<%=DATE_TEXT_SIZE%>" maxlength="<%=DATE_TEXT_SIZE%>" value="<%=DateString(dEnd, True)%>">
	</div>
	<div class="col-md-2">
		<input type="submit" class="btn btn-default" value="<%=TXT_SET_DATE_RANGE%>">
	</div>
</div>
</form>

<hr />

<div class="row">
	<div class="col-lg-6">
		<div class="panel panel-default max-width-lg">
			<div class="panel-heading">
				<h2><%=TXT_PROFILE_SEARCH%></h2>
			</div>
			<div class="panel-body">
				<p><%=TXT_INST_PROFILE_SEARCH%></p>
				<form action="profiles_results.asp" method="post" name="EntryForm" onsubmit="formPrintMode(this);" class="form">
					<%=g_strCacheFormVals%>
					<table class="BasicBorder cell-padding-3 full-width clear-line-below">
						<tr>
							<td class="field-label-cell"><%=TXT_COMMUNITY%></td>
							<td class="field-data-cell">
								<%
		With rsProfileSummary
			If .EOF Then
								%>
								<%=TXT_NO_COMMUNITIES_HAVE_BEEN_SELECTED%>
								<%
			Else
								%>
								<select name="CM_ID" class="form-control">
									<option selected></option>
									<option value="N"><%=TXT_NONE_SPECIFIED%></option>
									<%
				While Not .EOF
									%>
									<option value="<%=.Fields("CM_ID")%>"><%=.Fields("Community")%></option>
									<%
					.MoveNext
				Wend
									%>
								</select>
								<%
			End If
								%>
							</td>
						</tr>
						<%
		End With

		Set rsProfileSummary = rsProfileSummary.NextRecordset

		With rsProfileSummary
						%>
						<tr>
							<td class="field-label-cell"><%=TXT_AREA_OF_INTEREST%></td>
							<td class="field-data-cell">
								<%
			If .EOF Then
								%>
								<%=TXT_NO_INTERESTS_HAVE_BEEN_SELECTED%>
								<%
			Else
								%>
								<select name="AI_ID" class="form-control">
									<option selected></option>
									<option value="N"><%=TXT_NONE_SPECIFIED%></option>
									<%
				While Not .EOF
									%>
									<option value="<%=.Fields("AI_ID")%>"><%=.Fields("InterestName")%></option>
									<%
					.MoveNext
				Wend
									%>
								</select>
								<%
			End If
								%>
							</td>
						</tr>
						<tr>
							<td class="field-label-cell">
								<label for="AgeGroup"><%=TXT_AGE_GROUP%></label>
							</td>
							<td class="field-data-cell">
								<select name="AgeGroup" class="form-control">
									<option selected></option>
									<option value="N"><%=TXT_NONE_SPECIFIED%></option>
									<option value="C"><%=TXT_AGE_GROUP_CHILDREN%></option>
									<option value="Y"><%=TXT_AGE_GROUP_YOUTH%></option>
									<option value="YA"><%=TXT_AGE_GROUP_YOUNG_ADULTS%></option>
									<option value="A"><%=TXT_AGE_GROUP_ADULTS%></option>
									<option value="OA"><%=TXT_AGE_GROUP_OLDER_ADULTS%></option>
								</select>
							</td>
						</tr>
						<tr>
							<td class="field-label-cell">
								<label for="NotifyNew"><%=TXT_RECEIVES_NEW_NOTIFICATIONS%></label>
							</td>
							<td class="field-data-cell">
								<div class="radio">
									<label>
										<input type="radio" name="NotifyNew" checked>
										<%=TXT_ANY%></label>
									<label>
										<input type="radio" name="NotifyNew" value="Y">
										<%=TXT_YES%></label>
									<label>
										<input type="radio" name="NotifyNew" value="N">
										<%=TXT_NO%></label>
								</div>
							</td>
						</tr>
						<tr>
							<td class="field-label-cell">
								<%=TXT_RECEIVES_UPDATED_NOTIFICATIONS%>
							</td>
							<td class="field-data-cell">
								<div class="radio">
									<label>
										<input type="radio" name="NotifyUpdated" checked>
										<%=TXT_ANY%></label>
									<label>
										<input type="radio" name="NotifyUpdated" value="Y">
										<%=TXT_YES%></label>
									<label>
										<input type="radio" name="NotifyUpdated" value="N">
										<%=TXT_NO%></label>
								</div>
							</td>
						</tr>
						<tr>
							<td class="field-label-cell">
								<label for="AgreedPrivacy"><%=TXT_AGREED_TO_PRIVACY_POLICY%></label>
							</td>
							<td class="field-data-cell">
								<div class="radio">
									<label>
										<input type="radio" name="AgreedPrivacy">
										<%=TXT_ANY%></label>
									<label>
										<input type="radio" name="AgreedPrivacy" value="Y" checked>
										<%=TXT_YES%></label>
									<label>
										<input type="radio" name="AgreedPrivacy" value="N">
										<%=TXT_NO%></label>
								</div>
							</td>
						</tr>
						<tr>
							<td class="field-label-cell"><%=TXT_AGREED_TO_BE_CONTACTED%></td>
							<td class="field-data-cell">
								<div class="radio">
									<label>
										<input type="radio" name="OrgCanContact">
										<%=TXT_ANY%></label>
									<label>
										<input type="radio" name="OrgCanContact" value="Y" checked>
										<%=TXT_YES%></label>
									<label>
										<input type="radio" name="OrgCanContact" value="N">
										<%=TXT_NO%></label>
								</div>
							</td>
						</tr>
						<tr>
							<td class="field-label-cell"><%=TXT_ACTIVE%></td>
							<td class="field-data-cell">
								<div class="radio">
									<label>
										<input type="radio" name="Active">
										<%=TXT_ANY%></label>
									<label>
										<input type="radio" name="Active" value="Y" checked>
										<%=TXT_YES%></label>
									<label>
										<input type="radio" name="Active" value="N">
										<%=TXT_NO%></label>
								</div>
							</td>
						</tr>
						<tr>
							<td class="field-label-cell"><%=TXT_PRINT_VERSION_NW%></td>
							<td class="field-data-cell">
								<div class="radio">
									<label>
										<input type="radio" name="PrintMd" value="on">
										<%=TXT_YES%></label>
									<label>
										<input type="radio" name="PrintMd" value="" checked>
										<%=TXT_NO%></label>
								</div>
							</td>
						</tr>
					</table>
					<input type="submit" value="<%=TXT_SEARCH%>" class="btn btn-default">
					<input type="reset" value="<%=TXT_CLEAR_FORM%>" class="btn btn-default">
				</form>
				<%
		End With
				%>
				<hr />
				<form action="profiles_details.asp" method="post" class="form">
					<%=g_strCacheFormVals%>
					<table class="BasicBorder cell-padding-3 full-width clear-line-below">
						<tr>
							<td class="field-label-cell"><%=TXT_EMAIL%></td>
							<td class="field-data-cell">
								<input type="text" name="Email" size="50" class="form-control">
							</td>
						</tr>
					</table>
					<input type="submit" value="<%=TXT_SEARCH%>" class="btn btn-default">
					<input type="reset" value="<%=TXT_CLEAR_FORM%>" class="btn btn-default">
				</form>
			</div>
		</div>
	</div>
	<%
Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	%>
	<div class="col-lg-6">
		<div class="panel panel-default max-width-lg">
			<div class="panel-heading">
				<h2><%=TXT_PROFILE_VIEWS%></h2>
			</div>
			<div class="panel-body">
				<%
	If .EOF Then
				%>
				<p><%=TXT_INST_PROFILE_VIEWS%></p>
				<%
	Else
				%>
				<p><%=TXT_VIEWS_ALLOW_PROFILES%></p>
				<table class="BasicBorder cell-padding-3">
					<tr>
						<th class="RevTitleBox"><%=TXT_VIEW_NUMBER%></th>
						<th class="RevTitleBox"><%=TXT_VIEW_NAME%></th>
					</tr>
					<%
		While Not .EOF
					%>
					<tr>
						<td class="field-label-cell"><%=.Fields("ViewType")%></td>
						<td><%=.Fields("ViewName")%></td>
					</tr>
					<%
		.MoveNext
	Wend
					%>
				</table>
				<%
	End If
				%>
			</div>
		</div>
	</div>
	<%
End With

Set rsProfileSummary = rsProfileSummary.NextRecordset

Dim intTotalProfiles, _
	intYearProfiles

With rsProfileSummary
	%>
	<div class="col-lg-6">
		<div class="panel panel-default max-width-lg">
			<div class="panel-heading">
				<h2><%=TXT_PROFILE_COUNTS%></h2>
			</div>
			<div class="panel-body no-padding">
				<%
	If .EOF Then
				%>
				<p><%=TXT_NO_VOL_PROFILES%></p>
				<%
	Else
		intTotalProfiles = Nz(.Fields("TOTAL"),0)
		intYearProfiles = Nz(.Fields("TOTAL_YR"),0)
		If intTotalProfiles > 0 Then
				%>
				<table class="BasicBorder cell-padding-3 full-width">
					<thead>
						<tr>
							<th></th>
							<th><%=TXT_TOTAL%></th>
							<th><%=strYearRange%>
								<br>
								(<%=TXT_CREATED & " / " & TXT_MODIFIED%>)
							</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td class="field-label-cell"><%=TXT_PROFILE_COUNT_TOTAL%></td>
							<td><strong><%=intTotalProfiles%></strong></td>
							<td><strong><%=intYearProfiles%></strong></td>
						</tr>
						<tr>
							<td class="field-label-cell"><%=TXT_PROFILE_COUNT_ACTIVE%></td>
							<td><strong><%=.Fields("ACTIVE")%></strong> <em>(<%=Round(.Fields("ACTIVE")*100/intTotalProfiles,0)%>%)</em></td>
							<td><strong><%=.Fields("ACTIVE_YR")%></strong> <em>(<%=Round(.Fields("ACTIVE_YR")*100/intYearProfiles,0)%>%)</em></td>
						</tr>
						<tr>
							<td class="field-label-cell"><%=TXT_PROFILE_COUNT_VERIFIED%></td>
							<td><strong><%=.Fields("VERIFIED")%></strong> <em>(<%=Round(.Fields("VERIFIED")*100/intTotalProfiles)%>%)</em></td>
							<td><strong><%=.Fields("VERIFIED_YR")%></strong> <em>(<%=Round(.Fields("VERIFIED_YR")*100/intYearProfiles)%>%)</em></td>
						</tr>
						<tr>
							<td class="field-label-cell"><%=TXT_PROFILE_COUNT_RECEIVE_NEW%></td>
							<td><strong><%=.Fields("NOTIFY_NEW")%></strong> <em>(<%=Round(.Fields("NOTIFY_NEW")*100/intTotalProfiles)%>%)</em></td>
							<td><strong><%=.Fields("NOTIFY_NEW_YR")%></strong> <em>(<%=Round(.Fields("NOTIFY_NEW_YR")*100/intYearProfiles)%>%)</em></td>
						</tr>
						<tr>
							<td class="field-label-cell"><%=TXT_PROFILE_COUNT_RECEIVE_UPDATED%></td>
							<td><strong><%=.Fields("NOTIFY_UPDATED")%></strong> <em>(<%=Round(.Fields("NOTIFY_UPDATED")*100/intTotalProfiles)%>%)</em></td>
							<td><strong><%=.Fields("NOTIFY_UPDATED_YR")%></strong> <em>(<%=Round(.Fields("NOTIFY_UPDATED_YR")*100/intYearProfiles)%>%)</em></td>
						</tr>
						<tr>
							<td class="field-label-cell"><%=TXT_PROFILE_COUNT_AGREE_CONTACT%></td>
							<td><strong><%=.Fields("CAN_CONTACT")%></strong> <em>(<%=Round(.Fields("CAN_CONTACT")*100/intTotalProfiles)%>%)</em></td>
							<td><strong><%=.Fields("CAN_CONTACT_YR")%></strong> <em>(<%=Round(.Fields("CAN_CONTACT_YR")*100/intYearProfiles)%>%)</em></td>
						</tr>
						<tr>
							<td class="field-label-cell"><%=TXT_PROFILE_COUNT_AGREE_PRIVACY%></td>
							<td><strong><%=.Fields("AGREED_PRIVACY")%></strong> <em>(<%=Round(.Fields("AGREED_PRIVACY")*100/intTotalProfiles)%>%)</em></td>
							<td><strong><%=.Fields("AGREED_PRIVACY_YR")%></strong> <em>(<%=Round(.Fields("AGREED_PRIVACY_YR")*100/intYearProfiles)%>%)</em></td>
						</tr>
					</tbody>
				</table>
				<%
		Else
				%>
				<p><%=TXT_NO_VOL_PROFILES%></p>
				<%
		End If
	End If
				%>
			</div>
		</div>
	</div>
	<%
End With
	%>
</div>


<%
Dim intCurMonth, _
	intYearTotal

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
%>
<hr />
<h1><%=TXT_PROFILES_OVER_TIME%></h1>
<%
	If .EOF Then
%>
<p><%=TXT_NO_VOL_PROFILES%></p>
<%
	Else
%>
<h2><%=TXT_PROFILE_COUNT & TXT_COLON & TXT_CREATED_DATE%></h2>
<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox"><%=TXT_YEAR%></th>
		<%
		For intCurMonth = 1 to 12
		%>
		<th class="RevTitleBox"><%=MonthName(intCurMonth, True)%></th>
		<%
		Next
		%>
		<th class="RevTitleBox"><%=TXT_TOTAL%></th>
	</tr>
	<%

		While Not .EOF
			intYearTotal = 0
	%>
	<tr>
		<td class="field-label-cell"><%=.Fields("CREATED_YEAR")%></td>
		<%

		For intCurMonth = 1 to 12
			intYearTotal = intYearTotal + .Fields(CStr(intCurMonth))
		%>
		<td class="field-data-cell"><%=.Fields(CStr(intCurMonth))%></td>
		<%
		Next
		%>
		<td><strong><%=intYearTotal%></strong></td>
	</tr>
	<%
			.MoveNext
		Wend
	%>
</table>
<%
	End If
End With

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	If .EOF Then
%>
<p><%=TXT_NO_VOL_PROFILES%></p>
<%
	Else
%>
<h2><%=TXT_PROFILE_COUNT & TXT_COLON & TXT_LAST_MODIFIED%></h2>
<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox"><%=TXT_YEAR%></th>
		<%
		For intCurMonth = 1 to 12
		%>
		<th class="RevTitleBox"><%=MonthName(intCurMonth, True)%></th>
		<%
		Next
		%>
		<th class="RevTitleBox"><%=TXT_TOTAL%></th>
	</tr>
	<%

		While Not .EOF
			intYearTotal = 0
	%>
	<tr>
		<td class="field-label-cell"><%=.Fields("MODIFIED_YEAR")%></td>
		<%

		For intCurMonth = 1 to 12
			intYearTotal = intYearTotal + .Fields(CStr(intCurMonth))
		%>
		<td class="field-data-cell"><%=.Fields(CStr(intCurMonth))%></td>
		<%
		Next
		%>
		<td><strong><%=intYearTotal%></strong></td>
	</tr>
	<%
			.MoveNext
		Wend
	%>
</table>
<%
	End If
End With

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	If .EOF Then
%>
<p><%=TXT_NONE%></p>
<%
	Else
%>
<h2><%=TXT_PROFILE_COUNT & TXT_COLON & TXT_REFERRAL_DATE%></h2>
<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox"><%=TXT_YEAR%></th>
		<%
		For intCurMonth = 1 to 12
		%>
		<th class="RevTitleBox"><%=MonthName(intCurMonth, True)%></th>
		<%
		Next
		%>
		<th class="RevTitleBox"><%=TXT_TOTAL%></th>
	</tr>
	<%

		While Not .EOF
			intYearTotal = 0
	%>
	<tr>
		<td class="field-label-cell"><%=.Fields("PROFILE_REFERRAL_YEAR")%></td>
		<%

		For intCurMonth = 1 to 12
			intYearTotal = intYearTotal + .Fields(CStr(intCurMonth))
		%>
		<td class="field-data-cell"><%=.Fields(CStr(intCurMonth))%></td>
		<%
		Next
		%>
		<td><strong><%=intYearTotal%></strong></td>
	</tr>
	<%
			.MoveNext
		Wend
	%>
</table>
<%
	End If
End With

%>
<hr />
<h1><%=TXT_APPLICATIONS_OVER_TIME%></h1>
<%

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	If .EOF Then
%>
<p><%=TXT_NONE%></p>
<%
	Else
%>
<h2><%=TXT_APPLICATION_COUNT & TXT_COLON & TXT_USERS_WITH_A_PROFILE%></h2>
<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox"><%=TXT_YEAR%></th>
		<%
		For intCurMonth = 1 to 12
		%>
		<th class="RevTitleBox"><%=MonthName(intCurMonth, True)%></th>
		<%
		Next
		%>
		<th class="RevTitleBox"><%=TXT_TOTAL%></th>
	</tr>
	<%

		While Not .EOF
			intYearTotal = 0
	%>
	<tr>
		<td class="field-label-cell"><%=.Fields("REFERRAL_P_YEAR")%></td>
		<%

		For intCurMonth = 1 to 12
			intYearTotal = intYearTotal + .Fields(CStr(intCurMonth))
		%>
		<td class="field-data-cell"><%=.Fields(CStr(intCurMonth))%></td>
		<%
		Next
		%>
		<td><strong><%=intYearTotal%></strong></td>
	</tr>
	<%
			.MoveNext
		Wend
	%>
</table>
<%
	End If
End With

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	If .EOF Then
%>
<p><%=TXT_NONE%></p>
<%
	Else
%>
<h2><%=TXT_APPLICATION_COUNT & TXT_COLON & TXT_USERS_WITHOUT_A_PROFILE%></h2>
<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox"><%=TXT_YEAR%></th>
		<%
		For intCurMonth = 1 to 12
		%>
		<th class="RevTitleBox"><%=MonthName(intCurMonth, True)%></th>
		<%
		Next
		%>
		<th class="RevTitleBox"><%=TXT_TOTAL%></th>
	</tr>
	<%

		While Not .EOF
			intYearTotal = 0
	%>
	<tr>
		<td class="field-label-cell"><%=.Fields("REFERRAL_NP_YEAR")%></td>
		<%

		For intCurMonth = 1 to 12
			intYearTotal = intYearTotal + .Fields(CStr(intCurMonth))
		%>
		<td class="field-data-cell"><%=.Fields(CStr(intCurMonth))%></td>
		<%
		Next
		%>
		<td><strong><%=intYearTotal%></strong></td>
	</tr>
	<%
			.MoveNext
		Wend
	%>
</table>
<%
	End If
End With

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
%>
<hr />
<h1><%=TXT_CRITERIA_DEMOGRAPHICS%></h1>
<%
	If .EOF Then
%>
<p><%=TXT_NO_VOL_PROFILES%></p>
<%
	Else
%>
<h2><%=TXT_AGE_GROUPS%></h2>
<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox"><%=TXT_AGE_GROUP%></th>
		<th class="RevTitleBox"><%=TXT_COUNT%></th>
		<th class="RevTitleBox"><%=strYearRange%>
			<br>
			(<%=TXT_CREATED & " / " & TXT_MODIFIED%>)
		</th>
	</tr>
	<%
		While Not .EOF
	%>
	<tr>
		<td class="field-label-cell"><%=.Fields("AGE_GROUP")%></td>
		<td><strong><%=.Fields("TOTAL")%></strong>  <em>(<%=Round(.Fields("TOTAL")*100/intTotalProfiles,0)%>%)</em></td>
		<td><strong><%=.Fields("THIS_YEAR")%></strong> <em>(<%=Round(.Fields("THIS_YEAR")*100/intYearProfiles,0)%>%)</em></td>
	</tr>
	<%
			.MoveNext
		Wend
	%>
</table>
<%
	End If
End With

Dim intRowCount

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	If Not .EOF Then
%>
<hr />
<h2><%=TXT_CITY%></h2>
<p><%=TXT_OF_UC%><strong><%=intTotalProfiles%></strong><%=TXT_TOTAL_PROFILES%><strong><%=.Fields("NO_CITY_SPECIFIED")%></strong> did not provide a home city.</p>
	<%
	End If
End With
%>
<div class="row">
<%

intRowCount = 0

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	If Not .EOF Then
	%>
	<div class="col-md-6">
		<table class="BasicBorder cell-padding-3 full-width clear-line-below">
			<tr>
				<th colspan="2">
					<h3><%=TXT_TOTAL%></h3>
				</th>
			</tr>
			<tr>
				<th class="RevTitleBox"><%=TXT_CITY%></th>
				<th class="RevTitleBox"><%=TXT_COUNT%></th>
			</tr>
			<tbody>
				<%
		While Not .EOF
		intRowCount = intRowCount + 1
		If intRowCount = 25 Then
				%>
			</tbody>
			<tbody class="collapse" id="CityShowAll">
				<%
		End If
				%>
				<tr>
					<td class="field-label-cell"><%=.Fields("City")%></td>
					<td><%=.Fields("TOTAL")%></td>
				</tr>
				<%
			.MoveNext
		Wend
				%>
			</tbody>
		</table>
		<button class="btn btn-default" data-toggle="collapse" href="#CityShowAll" aria-expanded="false" aria-controls="CityShowAll"><%=TXT_TOGGLE_DISPLAY_ALL%></button>
	</div>
	<%
	End If
End With

Set rsProfileSummary = rsProfileSummary.NextRecordset

intRowCount = 0

With rsProfileSummary
	If Not .EOF Then
	%>
	<div class="col-md-6">
		<table class="BasicBorder cell-padding-3 full-width clear-line-below">
			<tr>
				<th colspan="2">
					<h3><%=strYearRange%> (<%=TXT_CREATED & " / " & TXT_MODIFIED%>)</h3>
				</th>
			</tr>
			<tr>
				<th class="RevTitleBox"><%=TXT_CITY%></th>
				<th class="RevTitleBox"><%=TXT_COUNT%></th>
			</tr>
			<tbody>
				<%
		While Not .EOF
		intRowCount = intRowCount + 1
		If intRowCount = 25 Then
				%>
			</tbody>
			<tbody class="collapse" id="CityShowAll2">
				<%
		End If
				%>
				<tr>
					<td class="field-label-cell"><%=.Fields("City")%></td>
					<td><%=.Fields("THIS_YEAR")%></td>
				</tr>
				<%
			.MoveNext
		Wend
				%>
			</tbody>
		</table>
		<button class="btn btn-default" data-toggle="collapse" href="#CityShowAll2" aria-expanded="false" aria-controls="CityShowAll2"><%=TXT_TOGGLE_DISPLAY_ALL%></button>
	</div>
<%
	End If
End With
%>
</div>
<%

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	If Not .EOF Then
%>
<hr />
<h2><%=TXT_SEARCH & TXT_COLON & TXT_COMMUNITIES%></h2>
<p><%=TXT_OF_UC%><strong><%=intTotalProfiles%></strong><%=TXT_TOTAL_PROFILES%><strong><%=.Fields("NO_COMMUNITIES_SPECIFIED")%></strong><%=TXT_DID_NOT_SELECT_ANY%></p>
	<%
	End If
End With
%>
<div class="row">
<%

intRowCount = 0

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	If Not .EOF Then
	%>
	<div class="col-md-6">
		<table class="BasicBorder cell-padding-3 full-width clear-line-below">
			<tr>
				<th colspan="2">
					<h3><%=TXT_TOTAL%></h3>
				</th>
			</tr>
			<tr>
				<th class="RevTitleBox"><%=TXT_COMMUNITY%></th>
				<th class="RevTitleBox"><%=TXT_COUNT%></th>
			</tr>
			<tbody>
				<%
		While Not .EOF
		intRowCount = intRowCount + 1
		If intRowCount = 25 Then
				%>
			</tbody>
			<tbody class="collapse" id="CommunityShowAll">
				<%
		End If
				%>
				<tr>
					<td class="field-label-cell"><%=.Fields("Community")%></td>
					<td><%=.Fields("TOTAL")%></td>
				</tr>
				<%
			.MoveNext
		Wend
				%>
			</tbody>
		</table>
		<button class="btn btn-default" data-toggle="collapse" href="#CommunityShowAll" aria-expanded="false" aria-controls="CommunityShowAll"><%=TXT_TOGGLE_DISPLAY_ALL%></button>
	</div>
	<%
	End If
End With

Set rsProfileSummary = rsProfileSummary.NextRecordset

intRowCount = 0

With rsProfileSummary
	If Not .EOF Then
	%>
	<div class="col-md-6">
		<table class="BasicBorder cell-padding-3 full-width clear-line-below">
			<tr>
				<th colspan="2">
					<h3><%=strYearRange%> (<%=TXT_CREATED & " / " & TXT_MODIFIED%>)</h3>
				</th>
			</tr>
			<tr>
				<th class="RevTitleBox"><%=TXT_COMMUNITY%></th>
				<th class="RevTitleBox"><%=TXT_COUNT%></th>
			</tr>
			<tbody>
				<%
		While Not .EOF
		intRowCount = intRowCount + 1
		If intRowCount = 25 Then
				%>
			</tbody>
			<tbody class="collapse" id="CommunityShowAll2">
				<%
		End If
				%>
				<tr>
					<td class="field-label-cell"><%=.Fields("Community")%></td>
					<td><%=.Fields("THIS_YEAR")%></td>
				</tr>
				<%
			.MoveNext
		Wend
				%>
			</tbody>
		</table>
		<button class="btn btn-default" data-toggle="collapse" href="#CommunityShowAll2" aria-expanded="false" aria-controls="CommunityShowAll2"><%=TXT_TOGGLE_DISPLAY_ALL%></button>
	</div>
<%
	End If
End With
%>
</div>
<%

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	If Not .EOF Then
%>
<hr />
<h2><%=TXT_SEARCH & TXT_COLON & TXT_AREAS_OF_INTEREST%></h2>
<p><%=TXT_OF_UC%><strong><%=intTotalProfiles%></strong><%=TXT_TOTAL_PROFILES%><strong><%=.Fields("NO_INTERESTS_SPECIFIED")%></strong> did not select any specific areas of interest.</p>
	<%
	End If
End With
%>
<div class="row">
<%

Set rsProfileSummary = rsProfileSummary.NextRecordset

intRowCount = 0

With rsProfileSummary
	If Not .EOF Then
	%>
	<div class="col-md-6">
		<table class="BasicBorder cell-padding-3 full-width clear-line-below">
			<tr>
				<th colspan="2">
					<h3><%=TXT_TOTAL%></h3>
				</th>
			</tr>
			<tr>
				<th class="RevTitleBox"><%=TXT_INTEREST%></th>
				<th class="RevTitleBox"><%=TXT_COUNT%></th>
			</tr>
			<tbody>
				<%
		While Not .EOF
		intRowCount = intRowCount + 1
		If intRowCount = 25 Then
				%>
			</tbody>
			<tbody class="collapse" id="InterestShowAll">
				<%
		End If
				%>
				<tr>
					<td class="field-label-cell"><%=.Fields("InterestName")%></td>
					<td><%=.Fields("TOTAL")%></td>
				</tr>
				<%
			.MoveNext
		Wend
				%>
			</tbody>
		</table>
		<button class="btn btn-default" data-toggle="collapse" href="#InterestShowAll" aria-expanded="false" aria-controls="InterestShowAll"><%=TXT_TOGGLE_DISPLAY_ALL%></button>
	</div>
	<%
	End If
End With

Set rsProfileSummary = rsProfileSummary.NextRecordset

intRowCount = 0

With rsProfileSummary
	If Not .EOF Then
	%>
	<div class="col-md-6">
		<table class="BasicBorder cell-padding-3 full-width clear-line-below">
			<tr>
				<th colspan="2">
					<h3><%=strYearRange%> (<%=TXT_CREATED & " / " & TXT_MODIFIED%>)</h3>
				</th>
			</tr>
			<tr>
				<th class="RevTitleBox"><%=TXT_INTEREST%></th>
				<th class="RevTitleBox"><%=TXT_COUNT%></th>
			</tr>
			<tbody>
				<%
		While Not .EOF
		intRowCount = intRowCount + 1
		If intRowCount = 25 Then
				%>
			</tbody>
			<tbody class="collapse" id="InterestShowAll2">
				<%
		End If
				%>
				<tr>
					<td class="field-label-cell"><%=.Fields("InterestName")%></td>
					<td><%=.Fields("THIS_YEAR")%></td>
				</tr>
				<%
			.MoveNext
		Wend
				%>
			</tbody>
		</table>
		<button class="btn btn-default" data-toggle="collapse" href="#InterestShowAll2" aria-expanded="false" aria-controls="InterestShowAll2"><%=TXT_TOGGLE_DISPLAY_ALL%></button>
	</div>
	<%
	End If
End With
%>
</div>
<%

Call makePageFooter(True)
%>

<!--#include file="../includes/core/incClose.asp" -->
