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
<!--#include file="../text/txtCommonForm.asp" -->
<!--#include file="../text/txtFeedback.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../text/txtVOLProfile.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
If Not (user_bCanAccessProfiles And g_bUseVolunteerProfiles) Then
	Call securityFailure()
End If

Dim bError
bError = False

Dim strEmail, _
	strProfileID

strEmail = Left(Trim(Request("Email")),60)
strProfileID = Left(Trim(Request("ProfileID")),38)

If Not IsGUIDType(strProfileID) Or Nl(strProfileID) Then
	strProfileID = Null
End If

Call makePageHeader(TXT_VOL_PROFILE_DETAILS, TXT_VOL_PROFILE_DETAILS, True, True, True, True)

If Nl(strEmail) And Nl(strProfileID) Then
	bError = True
%>
<p><%= TXT_NO_VOL_PROFILE_EMAIL %></p>
<%
Else
	Dim objReturn, objErrMsg
	Dim cmdProfileInfo, rsProfileInfo
	Set cmdProfileInfo = Server.CreateObject("ADODB.Command")
	With cmdProfileInfo
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "sp_VOL_Profile_s_Staff"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 60, strEmail)
		.Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, strProfileID)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsProfileInfo = Server.CreateObject("ADODB.Recordset")
	With rsProfileInfo
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdProfileInfo
	End With
	
	If rsProfileInfo.State = adStateClosed Then
		bError = True
		Set rsProfileInfo = rsProfileInfo.NextRecordset
%>
<p><%=TXT_ERROR%><%=Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)%></p>
<%
	ElseIf rsProfileInfo.EOF Then
		bError = True
		Set rsProfileInfo = rsProfileInfo.NextRecordset
%>
<p><%=TXT_ERROR%><%=Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)%></p>
<%
	End If
End If

Dim bOrgCanContact

If Not bError Then
	With rsProfileInfo
		bOrgCanContact = .Fields("OrgCanContact")
%>
<p>[ <a href="<%=makeLinkB("profiles.asp")%>"><%=TXT_NEW_SEARCH%></a> ]</p>
<h2><%= TXT_VOL_PROFILE_DETAILS & " (" & Server.HTMLEncode(.FieldS("Email"))%>)</h2>
<%
		If Not bOrgCanContact Then
%>
<p><span class="AlertBubble"><%=TXT_USER_NOT_AGREED_TO_CONTACT%></span></p>
<%
		End If
%>
<table class="BasicBorder cell-padding-3">
	<tr>
		<td class="FieldLabelLeft"><%=TXT_DATE_CREATED%></td>
		<td><%=Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN)%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_LAST_MODIFIED%></td>
		<td><%=Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN)%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_ACTIVE %></td>
		<td><%=IIf(.Fields("Active"),TXT_YES,"<span class=""Alert"">" & TXT_NO & "</span>")%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_SUBSCRIPTIONS%></td>
		<td>
		<%
		If Not .Fields("NotifyNew") Then %>
			<%= TXT_SUBSCRIPTIONS_NONE %>
		<%
		Else 
			If .Fields("NotifyUpdated") Then%>
				<%= TXT_SUBSCRIPTIONS_NEW_AND_UPDATED %>
			<% Else %>
				<%= TXT_SUBSCRIPTIONS_NEW %>
			<% End If %>
		<form method="post" action="profiles_unsubscribe.asp"><input type="hidden" name="ProfileID"
		value="<%=Server.HTMLEncode(.Fields("ProfileID"))%>"><input type="submit" name="submit"
		value="<%= TXT_UNSUBSCRIBE %>"></form>
		<br><span class="SmallNote"><%= TXT_INST_UNSUBSCRIBE_STAFF %></span>
		<% End If %>
		</td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_BLOCKED %></td>
		<td><form method="post" action="profiles_block.asp"><%=IIf(.Fields("Blocked"),"<span class=""Alert"">" & TXT_YES & "</span>", TXT_NO)%> <input type="hidden" name="ProfileID" value="<%=Server.HTMLEncode(.Fields("ProfileID"))%>"><input type="submit" name="submit" value="<%= IIf(.Fields("Blocked"), TXT_UNBLOCK, TXT_BLOCK) %>"></form></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_NAME %></td>
		<td><%=.Fields("FirstName") & " " & .Fields("LastName")%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_EMAIL %></td>
		<td><%=.Fields("Email")%></td>
	</tr>
<%If bOrgCanContact Then%>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_PHONE %></td>
		<td><%=Nz(.Fields("Phone"),"&nbsp;")%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_ADDRESS %></td>
		<td><%=Nz(.Fields("Address"),vbNullString) & " " & Nz(.Fields("City"),vbNullString) & IIf(Not (Nl(.Fields("Address")) And Nl(.Fields("City"))) And Not Nl(.Fields("Province")),", ",vbNullString) & .Fields("Province") & " " & .Fields("PostalCode")%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_NOTIFICATIONS %></td>
		<td><%=IIf(Not .Fields("NotifyNew") And Not .Fields("NotifyUpdated"),"None",StringIf(.Fields("NotifyNew"),"New") & StringIf(.Fields("NotifyUpdated"),StringIf(.Fields("NotifyNew"),", ") & "Updated"))%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_DATE_OF_BIRTH %></td>
		<td><%=Nz(.Fields("BirthDate"),"&nbsp;")%></td>
	</tr>
<%End If%>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_APPLICATIONS %></td>
		<td><%=.Fields("REFERRAL_REQUESTS") & IIf(.Fields("REFERRAL_REQUESTS") = 0,vbNullString," [ <a href=""" & makeLink(ps_strPathToStart & "volunteer/referral_profile.asp",IIf(bOrgCanContact,"Email=" & Server.URLEncode(.Fields("Email")),"ProfileID=" & .Fields("ProfileID")),vbNullString) & """>" & TXT_LIST_APPLICATIONS & "</a> ]")%></td>
	</tr>
<%
	End With

	If bOrgCanContact Then
		Set rsProfileInfo = rsProfileInfo.NextRecordset
	
		Dim strCommunities, _
			strCommCon

		strCommunities = vbNullString
		strCommCon = vbNullString
	
		With rsProfileInfo
			While Not .EOF
				strCommunities = strCommunities & strCommCon & .Fields("Community")
				strCommCon = ", "
				.MoveNext
			Wend
		End With
%>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_COMMUNITIES %></td>
		<td><%=Nz(strCommunities,"&nbsp;")%></td>
	</tr>
<%
		Set rsProfileInfo = rsProfileInfo.NextRecordset
	
		Dim strInterests, _
			strInterestCon

		strInterests = vbNullString
		strInterestCon = vbNullString
	
		With rsProfileInfo
			While Not .EOF
				strInterests = strInterests & strInterestCon & .Fields("InterestName")
				strInterestCon = ", "
				.MoveNext
			Wend
		End With
%>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_AREAS_OF_INTEREST %></td>
		<td><%=Nz(strInterests,"&nbsp;")%></td>
	</tr>
<%
	End If
%>
</table>
<%
End If

Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
