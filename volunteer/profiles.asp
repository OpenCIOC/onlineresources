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
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../text/txtVOLProfile.asp" -->
<%
If Not (user_bCanAccessProfiles And g_bUseVolunteerProfiles) Then
	Call securityFailure()
End If

Call addScript(ps_strPathToStart & makeAssetVer("scripts/formPrintMode.js"), "text/javascript")

Call makePageHeader(TXT_VOL_PROFILE_SUMMARY, TXT_VOL_PROFILE_SUMMARY, True, True, True, True)

Dim cmdProfileSummary, rsProfileSummary
Set cmdProfileSummary = Server.CreateObject("ADODB.Command")
With cmdProfileSummary
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "sp_VOL_Profile_Summary"
	.CommandType = adCmdStoredProc
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.CommandTimeout = 0
	Set rsProfileSummary = .Execute
End With

With rsProfileSummary

%>
<h1><%=TXT_PROFILE_SEARCH%></h1>
<p><%=TXT_INST_PROFILE_SEARCH%></p>
<form action="profiles_results.asp" method="post" name="EntryForm" onSubmit="formPrintMode(this);">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
	<tr>
		<td class="FieldLabelLeft"><%= TXT_COMMUNITY %></td>
		<td>
<%
	If .EOF Then
%>
<%= TXT_NO_COMMUNITIES_HAVE_BEEN_SELECTED %>
<%
	Else
%>
		<select name="CM_ID">
			<option selected></option>
			<option value="N"><%= TXT_NONE_SPECIFIED %></option>
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
		<td class="FieldLabelLeft"><%= TXT_AREA_OF_INTEREST %></td>
		<td>
<%
	If .EOF Then
%>
<%= TXT_NO_INTERESTS_HAVE_BEEN_SELECTED %>
<%
	Else
%>
		<select name="AI_ID">
			<option selected></option>
			<option value="N"><%= TXT_NONE_SPECIFIED %></option>
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
		<td class="FieldLabelLeft"><%= TXT_AGE_GROUP %></td>
			<td><select name="AgeGroup">
			<option selected></option>
			<option value="N"><%= TXT_NONE_SPECIFIED %></option>
			<option value="C"><%= TXT_AGE_GROUP_CHILDREN %></option>
			<option value="Y"><%= TXT_AGE_GROUP_YOUTH %></option>
			<option value="YA"><%= TXT_AGE_GROUP_YOUNG_ADULTS %></option>
			<option value="A"><%= TXT_AGE_GROUP_ADULTS %></option>
			<option value="OA"><%= TXT_AGE_GROUP_OLDER_ADULTS %></option>
			</select></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_RECEIVES_NEW_NOTIFICATIONS %></td>
		<td><input type="radio" name="NotifyNew" checked>&nbsp;<%= TXT_ANY %>
		<input type="radio" name="NotifyNew" value="Y">&nbsp;<%=TXT_YES%>
		<input type="radio" name="NotifyNew" value="N">&nbsp;<%=TXT_NO%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_RECEIVES_UPDATED_NOTIFICATIONS %></td>
		<td><input type="radio" name="NotifyUpdated" checked>&nbsp;<%= TXT_ANY %>
		<input type="radio" name="NotifyUpdated" value="Y">&nbsp;<%=TXT_YES%>
		<input type="radio" name="NotifyUpdated" value="N">&nbsp;<%=TXT_NO%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_AGREED_TO_PRIVACY_POLICY %></td>
		<td><input type="radio" name="AgreedPrivacy">&nbsp;<%= TXT_ANY %>
		<input type="radio" name="AgreedPrivacy" value="Y" checked>&nbsp;<%=TXT_YES%>
		<input type="radio" name="AgreedPrivacy" value="N">&nbsp;<%=TXT_NO%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_AGREED_TO_BE_CONTACTED %></td>
		<td><input type="radio" name="OrgCanContact">&nbsp;<%= TXT_ANY %>
		<input type="radio" name="OrgCanContact" value="Y" checked>&nbsp;<%=TXT_YES%>
		<input type="radio" name="OrgCanContact" value="N">&nbsp;<%=TXT_NO%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_ACTIVE %></td>
		<td><input type="radio" name="Active">&nbsp;<%= TXT_ANY %>
		<input type="radio" name="Active" value="Y" checked>&nbsp;<%=TXT_YES%>
		<input type="radio" name="Active" value="N">&nbsp;<%=TXT_NO%></td>
	</tr>
	<tr>	
		<td class="FieldLabelLeft"><%=TXT_PRINT_VERSION%></td>
		<td><input type="radio" name="PrintMd" value="on">&nbsp;<%=TXT_YES%>
		<input type="radio" name="PrintMd" value="" checked>&nbsp;<%=TXT_NO%></td>
	</tr>
	<tr>
		<td colspan="2" align="center"><input type="submit" value="<%=TXT_SEARCH%>"> <input type="reset" value="<%=TXT_CLEAR_FORM%>"></td>
	</tr>
</table>
</form>
<%
End With
%>
<hr />
<form action="profiles_details.asp" method="post">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
	<tr>
		<td class="FieldLabelLeft"><%= TXT_EMAIL %></td>
		<td><input type="text" name="Email" size="50"/> <input type="submit" value="<%=TXT_SEARCH%>"></td>
	</tr>
</table>
</form>
<%
Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
%>
<h1><%= TXT_PROFILE_VIEWS %></h1>
<%
	If .EOF Then
%>
<p><%= TXT_INST_PROFILE_VIEWS %></p>
<%
	Else
%>
<p><%= TXT_VIEWS_ALLOW_PROFILES %></p>
<table class="BasicBorder cell-padding-3">
	<tr><th class="RevTitleBox"><%= TXT_VIEW_NUMBER %></th><th class="RevTitleBox"><%= TXT_VIEW_NAME %></th></tr>
<%
		While Not .EOF
%>
	<tr><td class="FieldLabelLeft"><%=.Fields("ViewType")%></td><td><%=.Fields("ViewName")%></td></tr>
<%
		.MoveNext
	Wend
%>
</table>
<%
	End If
End With
%>

<%
Set rsProfileSummary = rsProfileSummary.NextRecordset

Dim intTotalProfiles

With rsProfileSummary
%>
<h1><%= TXT_PROFILE_COUNTS %></h1>
<%
	If .EOF Then
%>
<p><%= TXT_NO_VOL_PROFILES %></p>
<%
	Else
		intTotalProfiles = Nz(.Fields("TOTAL"),0)
		If intTotalProfiles > 0 Then
%>
<table class="BasicBorder cell-padding-3">
	<tr><td class="FieldLabelLeft"><%= TXT_PROFILE_COUNT_TOTAL %></td><td><%=intTotalProfiles%></td></tr>
	<tr><td class="FieldLabelLeft"><%= TXT_PROFILE_COUNT_ACTIVE %></td><td><%=.Fields("ACTIVE")%></td></tr>
	<tr><td class="FieldLabelLeft"><%= TXT_PROFILE_COUNT_VERIFIED %></td><td><%=.Fields("VERIFIED")%></td></tr>
	<tr><td class="FieldLabelLeft"><%= TXT_PROFILE_COUNT_RECEIVE_NEW %></td><td><%=.Fields("NOTIFY_NEW")%></td></tr>
	<tr><td class="FieldLabelLeft"><%= TXT_PROFILE_COUNT_RECEIVE_UPDATED %></td><td><%=.Fields("NOTIFY_UPDATED")%></td></tr>
	<tr><td class="FieldLabelLeft"><%= TXT_PROFILE_COUNT_AGREE_CONTACT %></td><td><%=.Fields("CAN_CONTACT")%></td></tr>
	<tr><td class="FieldLabelLeft"><%= TXT_PROFILE_COUNT_AGREE_PRIVACY %></td><td><%=.Fields("AGREED_PRIVACY")%></td></tr>
</table>
<%
		Else
%>
<p><%= TXT_NO_VOL_PROFILES %></p>
<%
		End If
	End If
End With

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
%>
<h1><%= TXT_PROFILES_OVER_TIME %></h1>
<%
	If .EOF Then
%>
<p><%= TXT_NO_VOL_PROFILES %></p>
<%
	Else
%>
<table class="BasicBorder cell-padding-3">
	<tr><th class="RevTitleBox"><%=TXT_CREATED_DATE%></th><th class="RevTitleBox"><%=TXT_COUNT%></th></tr>
<%
		While Not .EOF
%>
	<tr><td class="FieldLabelLeft"><%=.Fields("CREATED_MONTH")%></td><td><%=.Fields("TOTAL")%></td></tr>
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
	If Not .EOF Then
%>
<br>
<table class="BasicBorder cell-padding-3">
	<tr><th class="RevTitleBox"><%= TXT_LAST_MODIFIED %></th><th class="RevTitleBox"><%= TXT_COUNT %></th></tr>
<%
		While Not .EOF
%>
	<tr><td class="FieldLabelLeft"><%=.Fields("LAST_MODIFIED")%></td><td><%=.Fields("TOTAL")%></td></tr>
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
	If Not .EOF Then
%>
<br>
<table class="BasicBorder cell-padding-3">
	<tr><th class="RevTitleBox"><%= TXT_APPLICATION_DATE %></th><th class="RevTitleBox"><%= TXT_PROFILE_COUNT %></th><th class="RevTitleBox"><%= TXT_APPLICATION_COUNT %></th></tr>
<%
		While Not .EOF
%>
	<tr><td class="FieldLabelLeft"><%=.Fields("APPLICATION_DATE")%></td><td><%=.Fields("TOTAL_PROFILES")%></td><td><%=.Fields("TOTAL_APPLICATIONS")%></td></tr>
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
<h1><%= TXT_CRITERIA_DEMOGRAPHICS %></h1>
<%
	If .EOF Then
%>
<p><%= TXT_NO_VOL_PROFILES %></p>
<%
	Else
%>
<h2><%= TXT_AGE_GROUPS %></h2>
<table class="BasicBorder cell-padding-3">
	<tr><th class="RevTitleBox"><%= TXT_AGE_GROUP %></th><th class="RevTitleBox"><%= TXT_COUNT %></th></tr>
<%
		While Not .EOF
%>
	<tr><td class="FieldLabelLeft"><%=.Fields("AGE_GROUP")%></td><td><%=.Fields("TOTAL")%></td></tr>
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
	If Not .EOF Then
%>
<h2><%= TXT_COMMUNITIES %></h2>
<p><%= TXT_OF_UC %><strong><%=intTotalProfiles%></strong><%= TXT_TOTAL_PROFILES %><strong><%=.Fields("NO_COMMUNITIES_SPECIFIED")%></strong><%= TXT_DID_NOT_SELECT_ANY %></p>
<%
	End If
End With

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	If Not .EOF Then
%>
<table class="BasicBorder cell-padding-3">
	<tr><th class="RevTitleBox"><%= TXT_COMMUNITY %></th><th class="RevTitleBox"><%= TXT_COUNT %></th></tr>
<%
		While Not .EOF
%>
	<tr><td class="FieldLabelLeft"><%=.Fields("Community")%></td><td><%=.Fields("TOTAL")%></td></tr>
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
	If Not .EOF Then
%>
<h2><%= TXT_AREAS_OF_INTEREST %></h2>
<p>Of <strong><%=intTotalProfiles%></strong> total Profiles, <strong><%=.Fields("NO_INTERESTS_SPECIFIED")%></strong> did not select any specific areas of interest. The following chart shows the <strong>top 25</strong> selected interests.</p>
<%
	End If
End With

Set rsProfileSummary = rsProfileSummary.NextRecordset

With rsProfileSummary
	If Not .EOF Then
%>
<table class="BasicBorder cell-padding-3">
	<tr><th class="RevTitleBox"><%= TXT_INTEREST %></th><th class="RevTitleBox"><%= TXT_COUNT %></th></tr>
<%
		While Not .EOF
%>
	<tr><td class="FieldLabelLeft"><%=.Fields("InterestName")%></td><td><%=.Fields("TOTAL")%></td></tr>
<%
			.MoveNext
		Wend
%>
</table>
<%
	End If
End With

Call makePageFooter(True)
%>

<!--#include file="../includes/core/incClose.asp" -->
