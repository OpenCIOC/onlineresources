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
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../text/txtUsers.asp" -->
<!--#include file="../text/txtVOLProfile.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
If Not (user_bCanAccessProfiles And g_bUseVolunteerProfiles) Then
	Call securityFailure()
End If

Call makePageHeader(TXT_VOL_PROFILE_SEARCH_RESULTS, TXT_VOL_PROFILE_SEARCH_RESULTS, True, True, True, True)

If Not g_bPrintMode Then
%>
<p>[ <a href="<%=makeLinkB("profiles.asp")%>"><%=TXT_NEW_SEARCH%></a> ]</p>
<h1><%= TXT_VOL_PROFILE_SEARCH_RESULTS %></h1>
<%
End If

Dim strWhere, _
	strCMID, _
	strAIID, _
	strAgeGroup, _
	bNotifyNew, _
	bNotifyUpdated, _
	bAgreedPrivacy, _
	bOrgCanContact, _
	bActive
	
strWhere = vbNullString

strWhere = "vp.MemberID=" & g_intMemberID & " AND vp.Verified=1"

strCMID = Request("CM_ID")
If strCMID = "N" Then
	strWhere = strWhere & AND_CON & "NOT EXISTS(SELECT * FROM VOL_Profile_CM vpc WHERE vpc.ProfileID=vp.ProfileID)"
ElseIf IsIDType(strCMID) Then
	strCMID = CInt(strCMID)
	strWhere = strWhere & AND_CON & "EXISTS(SELECT * FROM VOL_Profile_CM vpc WHERE vpc.ProfileID=vp.ProfileID AND vpc.CM_ID=" & strCMID & ")"
End If

strAIID = Request("AI_ID")
If strAIID = "N" Then
	strWhere = strWhere & AND_CON & "NOT EXISTS(SELECT * FROM VOL_Profile_AI pai WHERE pai.ProfileID=vp.ProfileID)"
ElseIf IsIDType(strAIID) Then
	strAIID = CInt(strAIID)
	strWhere = strWhere & AND_CON & "EXISTS(SELECT * FROM VOL_Profile_AI pai WHERE pai.ProfileID=vp.ProfileID AND pai.AI_ID=" & strAIID & ")"
End If

strAgeGroup = Request("AgeGroup")
Select Case strAgeGroup
	Case "N"
		strWhere = strWhere & AND_CON & "vp.BirthDate IS NULL"
	Case "C"
		strWhere = strWhere & AND_CON & "DATEDIFF(yy,vp.BirthDate,GETDATE()) <= 12"
	Case "Y"
		strWhere = strWhere & AND_CON & "DATEDIFF(yy,vp.BirthDate,GETDATE()) > 12 AND DATEDIFF(yy,vp.BirthDate,GETDATE()) <= 17"
	Case "YA"
		strWhere = strWhere & AND_CON & "DATEDIFF(yy,vp.BirthDate,GETDATE()) > 17 AND DATEDIFF(yy,vp.BirthDate,GETDATE()) <= 25"
	Case "A"
		strWhere = strWhere & AND_CON & "DATEDIFF(yy,vp.BirthDate,GETDATE()) > 25 AND DATEDIFF(yy,vp.BirthDate,GETDATE()) <= 59"
	Case "OA"
		strWhere = strWhere & AND_CON & "DATEDIFF(yy,vp.BirthDate,GETDATE()) > 59"
End Select

bNotifyNew = Request("NotifyNew")
If bNotifyNew ="Y" Then
	strWhere = strWhere & AND_CON & "vp.NotifyNew=" & SQL_TRUE
ElseIf bNotifyNew ="N" Then
	strWhere = strWhere & AND_CON & "vp.NotifyNew=" & SQL_FALSE
End If

bNotifyUpdated = Request("NotifyUpdated")
If bNotifyUpdated ="Y" Then
	strWhere = strWhere & AND_CON & "vp.NotifyUpdated=" & SQL_TRUE
ElseIf bNotifyUpdated ="N" Then
	strWhere = strWhere & AND_CON & "vp.NotifyUpdated=" & SQL_FALSE
End If

bAgreedPrivacy = Request("AgreedPrivacy")
If bAgreedPrivacy ="Y" Then
	strWhere = strWhere & AND_CON & "vp.AgreedToPrivacyPolicy=" & SQL_TRUE
ElseIf bAgreedPrivacy ="N" Then
	strWhere = strWhere & AND_CON & "vp.AgreedToPrivacyPolicy=" & SQL_FALSE
End If

bOrgCanContact = Request("OrgCanContact")
If bOrgCanContact ="Y" Then
	strWhere = strWhere & AND_CON & "vp.OrgCanContact=" & SQL_TRUE
ElseIf bOrgCanContact ="N" Then
	strWhere = strWhere & AND_CON & "vp.OrgCanContact=" & SQL_FALSE
End If

bActive = Request("Active")
If bActive ="Y" Then
	strWhere = strWhere & AND_CON & "vp.Active=" & SQL_TRUE
ElseIf bActive ="N" Then
	strWhere = strWhere & AND_CON & "vp.Active=" & SQL_FALSE
End If

Dim cmdProfileSearch, rsProfileSearch
Set cmdProfileSearch = Server.CreateObject("ADODB.Command")
With cmdProfileSearch
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "SELECT vp.ProfileID," & _
		"cioc_shared.dbo.fn_SHR_GBL_DateString(vp.CREATED_DATE) AS CREATED_DATE," & _
		"(SELECT COUNT(*) FROM VOL_OP_Referral rf WHERE rf.ProfileID=vp.ProfileID) AS REFERRAL_REQUESTS," & _
		"CASE WHEN OrgCanContact=1 THEN FirstName ELSE cioc_shared.dbo.fn_SHR_GBL_AnonString(FirstName) END AS FirstName," & _
		"CASE WHEN OrgCanContact=1 THEN LastName ELSE cioc_shared.dbo.fn_SHR_GBL_AnonString(LastName) END AS LastName," & _
		"CASE WHEN OrgCanContact=1 THEN Email ELSE cioc_shared.dbo.fn_SHR_GBL_AnonString(Email) END AS Email," & _
		"Active, OrgCanContact" & vbCrLf & _
		"FROM VOL_Profile vp" & vbCrLf & _
		"WHERE " & strWhere & vbCrLf & _
		"ORDER BY LastName, FirstName, Email"
	.CommandType = adCmdText
	.CommandTimeout = 0
End With

Set rsProfileSearch = Server.CreateObject("ADODB.Recordset")
With rsProfileSearch
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdProfileSearch
End With

Dim fldProfileID, _
	fldCreatedDate, _
	fldFirstName, _
	fldLastName, _
	fldEmail, _
	fldReferrals, _
	fldActive, _
	fldOrgCanContact

With rsProfileSearch
	If .EOF Then
%>
<p><%=TXT_NO_MATCH%></p>
<%
	Else
		Set fldProfileID = .Fields("ProfileID")
		Set fldCreatedDate = .Fields("CREATED_DATE")
		Set fldFirstName = .Fields("FirstName")
		Set fldLastName = .Fields("LastName")
		Set fldEmail = .Fields("Email")
		Set fldReferrals = .Fields("REFERRAL_REQUESTS")
		Set fldActive = .Fields("Active")
		Set fldOrgCanContact = .Fields("OrgCanContact")
		If Not g_bPrintMode Then
%>
<p><%=TXT_THERE_ARE%> <strong><%=.RecordCount%></strong> <%=TXT_RECORDS_MATCH%>
<br><%=TXT_CLICK_ON & " " & TXT_THE_PROFILE_ID  & " " & TXT_VIEW_FULL%></p>
<%
		End If
%>
<br>
<table class="BasicBorder cell-padding-3">
	<tr>
<%
		If Not g_bPrintMode Then
%>
		<th class="RevTitleBox">&nbsp;</th>
<%
		End If
%>
		<th class="RevTitleBox"><%=TXT_LAST_NAME%></th>
		<th class="RevTitleBox"><%=TXT_FIRST_NAME%></th>
		<th class="RevTitleBox"><%=TXT_EMAIL%></th>
		<th class="RevTitleBox"><%=TXT_APPLICATIONS%></th>
		<th class="RevTitleBox"><%=TXT_CREATED_DATE%></th>
<%
		If Not g_bPrintMode Then
%>
		<th class="RevTitleBox">&nbsp;</th>
<%
		End If
%>
	</tr>
<%
		While Not .EOF
%>
	<tr>
<%
		If Not g_bPrintMode Then
%>
		<td><%If fldActive Then%>&nbsp;<%Else%><img src="<%=ps_strPathToStart%>images/redx.gif" width="15" height="15"><%End If%></td>
<%
		End If
%>
		<td><%=fldLastName%></td>
		<td><%=fldFirstName%></td>
		<td><%=fldEmail%></td>
		<td><%=IIf(fldReferrals = 0 Or g_bPrintMode,fldReferrals,"<a href=""" & makeLink(ps_strPathToStart & "volunteer/referral_profile.asp",IIf(fldOrgCanContact,"Email=" & Server.URLEncode(fldEmail),"ProfileID=" & fldProfileID.Value),vbNullString) & """>" & fldReferrals & "</a>")%></td>
		<td><%=fldCreatedDate%></td>
<%
		If Not g_bPrintMode Then
%>
		<td><a href="<%=makeLink("profiles_details.asp",IIf(fldOrgCanContact,"Email=" & Server.URLEncode(fldEmail),"ProfileID=" & fldProfileID.Value),vbNullString)%>"><%= TXT_MORE_INFO %></a></td>
<%
		End If
%>
	</tr>
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
