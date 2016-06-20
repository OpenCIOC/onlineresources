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

<%
Sub genToggleState(strValue, strTitle)
	Dim strRequestValue
	strRequestValue = Request("ToggleUI")
	%> <input id="ToggleUI<%=strValue%>" name="ToggleUI" value="<%=strValue%>" type="radio"<%=IIf(strRequestValue=strValue Or (strValue="None" and Nl(strRequestValue)), " checked", "")%>>&nbsp;<label for="ToggleUI<%=strValue%>"><%=strTitle%></label><%
End Sub

Sub volReferralSearchHeader()
	If Not user_bCanManageReferrals Then
		Call securityFailure()
	End If

	Call makePageHeader(TXT_VOLUNTEER_REFERRALS, TXT_VOLUNTEER_REFERRALS, True, False, True, True)
End Sub

Sub volReferralSearchPageTitle(strPageTitle, strSecondaryLink)
%>
<p>[ <a href="<%=makeLinkB("referral.asp")%>"><%= TXT_REFERRALS_MAIN_MENU %></a><%=StringIf(Not Nl(strSecondaryLink)," | " & strSecondaryLink)%> ]</p>
<h2><%=strPageTitle%></h2>
<%
End Sub

Sub volReferralSearchUpdateFollowUpFlags()
	Dim bFlagState, strRefIdList

	If Nl(Request("FollowUpSubmitCheck")) and Nl(Request("FollowUpSubmitUnCheck")) Then
		Exit Sub
	End If

	strRefIdList = Null
	If Not Nl(Request("FollowUpCheck")) Then 
		strRefIdList = Left(Trim(Request("FollowUpCheck")), 8000) 
	End If

	If Nl(strRefIdList) Then
		Exit Sub
	End If

	If Not IsIDList(strRefIdList) Then
		'Error, not empty, and not a list of IDs
		Call handleError(TXT_ERROR_FOLLOW_UP_FLAG, vbNullString, vbNullString)
		Exit Sub
	End If

	bFlagState = Nl(Request("FollowUpSubmitUnCheck"))

	Dim cmdFollowUpUpdate, rsFollowUpUpdate
	Set cmdFollowUpUpdate = Server.CreateObject("ADODB.Command")
	With cmdFollowUpUpdate
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_VOL_OP_Referral_u_FollowUp"
		.CommandType = adCmdStoredProc
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@RefIdList", adLongVarChar, adParamInput, -1, strRefIdList)
		.Parameters.Append .CreateParameter("@FollowUpFlag", adBoolean, adParamInput, 1, bFlagState)
		.CommandTimeout = 0
		Set rsFollowUpUpdate = .Execute()
	End With

	If rsFollowUpUpdate.State <> 0 Then
		Call rsFollowUpUpdate.Close()
	End If

	Set rsFollowUpUpdate = Nothing
	Set cmdFollowUpUpdate = Nothing

	Call handleMessage(TXT_FOLLOW_UP_FLAGS_UPDATED, vbNullString, vbNullString, False)

End Sub

Dim rsListReferrals
Set rsListReferrals = Server.CreateObject("ADODB.Recordset")

Sub volReferralSearchResults(bShowOwner, bShowOrgAndPos, bShowEmail) 

With rsListReferrals

%>
<p><%=TXT_FOUND%><strong><%=.RecordCount%></strong><%=TXT_MATCHES%>.</p>
<%
	If Not .EOF Then
%>
<form id="the_form" method="post">
<%= g_strCacheFormVals %>
<p id='options_ui' class="NotVisible"><strong><%= TXT_SHOW %></strong> <%Call genToggleState("None", TXT_NONE)%>

<%Call genToggleState("FollowUpFlag", TXT_FOLLOW_UP_FLAG_EDIT)%>
<%
		If g_bNoEmail Then
%>
<div style="display:none">
<%
		End If
%>
<%Call genToggleState("EmailFollowUp", TXT_EMAIL_FOLLOW_UP)%></p>
<%
		If g_bNoEmail Then
%>
</div>
<%
		End If
%>
<%
Dim Item
For Each Item In Request.Form
If Not StartsWith(Item, "ToggleUI") And Not StartsWith(Item, "FollowUp") Then
%>
<input type="hidden" name="<%=Item%>" value="<%=Server.HTMLEncode(Request.Form(Item))%>">
<% 
End If
Next 
%>
<input type="hidden" name="FollowUpEmailTo" id="EmailTo" value="O">

<%
Dim intLastCol
intLastCol = 5
if user_bSuperUserVOL And bShowOwner Then
	intLastCol = intLastCol + 1
End If
If bShowOrgAndPos Then 
	intLastCol = intLastCol + 2
End If
If bShowEmail Then
	intLastCol = intLastCol + 1
End If
If g_bMultiLingualActive Then
	intLastCol = intLastCol + 1
End If
%>
<table class="BasicBorder cell-padding-3 sortable_table" data-sortdisabled="[<%= intLastCol %>]" data-default-sort="[<%= intLastCol - 1 %>, 1]">
<thead>
<tr>
	<th class="RevTitleBox">&nbsp;</th>
	<th class="RevTitleBox">&nbsp;</th>
	<% If g_bMultiLingualActive Then %>
	<th class="RevTitleBox"><%= TXT_LANGUAGE %></th>
	<% End If %>
	<th class="RevTitleBox"><%= TXT_REFERRAL_DATE %></th>
<%If user_bSuperUserVOL And bShowOwner Then%>
	<th class="RevTitleBox"><%=TXT_RECORD_OWNER%></th>
<%End If%>
<%If bShowOrgAndPos Then %>
	<th class="RevTitleBox"><%=TXT_POSITION_TITLE%></th>
	<th class="RevTitleBox"><%=TXT_ORG_NAMES%></th>
<%End If%>
	<th class="RevTitleBox"><%= TXT_VOLUNTEER_NAME %></th>
<%If bShowEmail Then %>
	<th class="RevTitleBox"><%= TXT_VOLUNTEER_EMAIL %></th>
<%End If%>
	<th class="RevTitleBox"><%=TXT_LAST_MODIFIED%></th>
	<th class="RevTitleBox"><%=TXT_ACTION%></th>
</tr>
</thead>
<tbody>
<%

		Dim strOrgName, _
			strOrgSortKey, _
			bFollowUpFlag, _
			bPlacement, _
			dReferralDate, _
			strRecordOwner, _
			strPositionTitle, _
			strVolunteerName, _
			dModifiedDate, _
			intRefID, _
			strVolunteerEmail, _
			strLanguageName
			
		Dim i
		i = 0

		While Not .EOF
			bFollowUpFlag = .Fields("FollowUpFlag")
			bPlacement = .Fields("SuccessfulPlacement")
			dReferralDate = .Fields("ReferralDate")
			If bShowOwner Then
				strRecordOwner = .Fields("RECORD_OWNER")
			End If
			If bShowOrgAndPos Then
				strPositionTitle = .Fields("POSITION_TITLE")
			End If
			strVolunteerName = .Fields("VolunteerName")
			dModifiedDate = .Fields("MODIFIED_DATE")
			intRefID = .Fields("REF_ID")
	
			If bShowOrgAndPos Then
				strOrgName = .Fields("ORG_NAME_FULL")
				strOrgSortKey = Server.HTMLEncode(.Fields("ORG_SORT_KEY"))
			End If
	
			If bShowEmail Then
				strVolunteerEmail = .Fields("VolunteerEmail")
			End If

			strLanguageName = .Fields("LanguageName")
%>
<tr>
	<td style="white-space: nowrap;" data-tbl-key="<%=CInt(Nz(bFollowUpFlag, "0"))%>"><input name="FollowUpCheck" type="checkbox" value="<%=intRefID%>" title=<%=AttrQs(TXT_FOLLOW_UP)%> class="FollowUpUIChecks NotVisible" id="FollowUpCheck_<%=intRefID%>"> 
		<img width="15" height="15" src="<%=ps_strPathToStart%>images/<%=IIf(bFollowUpFlag, "redflag.gif", "spacer.gif")%>"></td>
	<td data-tbl-key="<%=CInt(Nz(bPlacement, "1"))%>"><%If Nl(bPlacement) Then%>&nbsp;<%Else%><img src="<%=ps_strPathToStart%>images/<%=IIf(bPlacement, "greencheck.gif", "redx.gif")%>"><%End If%></td>
	<% If g_bMultiLingualActive Then %>
		<td><%= strLanguageName %></td>
	<% End If %>
	<td data-tbl-key="<%=Nz(ISODateTimeString(dReferralDate), "1900-01-01 00:00:00")%>"><%=Nz(DateString(dReferralDate, True), "&nbsp;")%></td>
<%If user_bSuperUserVOL And bShowOwner Then%>
	<td><%= Nz(strRecordOwner, "&nbsp;") %></td>
<%End If%>
<%If bShowOrgAndPos Then %>
	<td><%= Nz(strPositionTitle, "&nbsp;") %></td>

	<td data-tbl-key="<%=strOrgSortKey%>"><%=strOrgName%></td>
<%End If%>
	<td><%= Nz(strVolunteerName, "&nbsp;")%></td>
<%If bShowEmail Then%>
	<td data-tbl-key="<%=strVolunteerEmail%>"><%If Nl(strVolunteerEmail) Then%>&nbsp;<%Else%><a href="mailto:<%=strVolunteerEmail%>"><%=strVolunteerEmail%></a><%End If%></td>
<%End If%>
	<td data-tbl-key="<%=Nz(ISODateTimeString(dModifiedDate), "1900-01-01 00:00:00")%>"><%= Nz(DateString(dModifiedDate, True), "&nbsp;") %></td>
	<td style="white-space: nowrap;">
	<a href="<%=makeLink("referral_edit.asp","REFID=" & intRefID & IIf(intCurSearchNumber >= 0,"&Number=" & intCurSearchNumber,vbNullString),vbNullString)%>"><%=TXT_UPDATE%></a>	</td>
</tr>
<%
			i = i + 1
			If i Mod 500 = 0 Then
				Response.Flush
			End If
			.MoveNext
		Wend
%>
</tbody>
</table>
<p class="FollowUpUI NotVisible"><strong><%= TXT_FOLLOW_UP_FLAG %></strong> 
	<input id="FollowUpCheckAll" type="button" value=<%= AttrQs(TXT_CHECK_ALL)%>> 
	<input id="FollowUpUnCheckAll" type="button" value=<%= AttrQs(TXT_UNCHECK_ALL)%>>
	<input type="submit" id="FollowUpSubmitCheck" name="FollowUpSubmitCheck" value=<%= AttrQs(TXT_ADD_FOLLOW_UP_FLAG) %>>
	<input type="submit" id="FollowUpSubmitUnCheck" name="FollowUpSubmitUnCheck" value=<%= AttrQs(TXT_REMOVE_FOLLOW_UP_FLAG) %>>
</p>
<%
		If g_bNoEmail Then
%>
<div style="display:none">
<%
		End If
%>
<p class="FollowUpEmailUI NotVisible"><strong><%= TXT_FOLLOW_UP_EMAIL %></strong> 
	<input id="FollowUpEmailCheckAll" type="button" value=<%= AttrQs(TXT_CHECK_ALL) %>> 
	<input id="FollowUpEmailUnCheckAll" type="button" value=<%= AttrQs(TXT_UNCHECK_ALL) %>> 
	<input type="submit" id="FollowUpEmailOrg" value=<%= AttrQs(TXT_SEND_TO_ORGANIZATION) %>>
	<input type="submit" id="FollowUpEmailVol" value=<%= AttrQs(TXT_SEND_TO_VOLUNTEER) %>>
<%
		If g_bNoEmail Then
%>
</div>
<%
		End If
%>
</form>
<%
	End If
End With

Call rsListReferrals.Close()
Set rsListReferrals = Nothing
%>

<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/referralsearch.js") %>

<% 
g_bListScriptLoaded = True
End Sub

%>

