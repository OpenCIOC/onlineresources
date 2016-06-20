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
<!--#include file="../text/txtEmailUpdate.asp" -->
<!--#include file="../text/txtReferral.asp" -->
<!--#include file="../text/txtReferralMail.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
If g_bNoEmail Then
	Call securityFailure()
End If

Call makePageHeader(TXT_CUSTOMIZE_REFERRAL_FOLLOW_UP_MAIL, TXT_CUSTOMIZE_REFERRAL_FOLLOW_UP_MAIL, True, False, True, True)

Const TYPE_ORG = 1
Const TYPE_VOL = 2
Dim intType, _
	strType, _
	bError

bError = False

Select Case Trim(Request("FollowUpEmailTo"))
	Case "O"
		strType = TXT_ORGANIZATION
		intType = TYPE_ORG
	Case "V"
		strType = TXT_VOLUNTEER
		intType = TYPE_VOL
	
	Case Else
		bError = True
		Call handleError(TXT_UNABLE_TO_DETERMINE_RECIPIENT, _
				vbNullString, vbNullString)
End Select

If Not bError Then

Dim strIDList, bIDError
strIDList = Trim(Request("FollowUpCheck"))
bIDError = False


If Not Nl(strIDList) Then
	Dim strSQL
	strSQL = "SELECT vo.VNUM, vod.POSITION_TITLE, rf.REF_ID, rf.VolunteerName, cioc_shared.dbo.fn_SHR_GBL_DateString(rf.ReferralDate) AS ReferralDate," & _
				"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL" & _
				" FROM VOL_Opportunity vo" & _
				" INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID " & _
				"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
				"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=bt.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
				" INNER JOIN VOL_OP_Referral rf ON vo.VNUM=rf.VNUM" & _
				" WHERE rf.REF_ID in (" & strIDList & ")"
	If Not user_bSuperUserVOL Then
		strSQL = strSQL & " AND vo.RECORD_OWNER=" & QsNl(user_strAgency)
	End If
	If intType = TYPE_ORG Then
		strSQL = strSQL & " AND (SELECT TOP 1 EMAIL AS CONTACT_EMAIL FROM GBL_Contact AS CONTACT WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL) IS NOT NULL AND vo.NO_UPDATE_EMAIL=" & SQL_FALSE & _
				" ORDER BY vo.NUM, (SELECT TOP 1 EMAIL AS CONTACT_EMAIL FROM GBL_Contact AS CONTACT WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL ORDER BY CASE WHEN CONTACT.LangID=vod.LangID THEN 0 ELSE 1 END, LangID), POSITION_TITLE, VolunteerName"
	Else
		strSQL = strSQL & " AND rf.VolunteerEmail IS NOT NULL"
	End If
	
	'Response.Write(strSQL)
	'Response.Flush()

	Dim cmdReferralEmail, rsReferralEmail
	Set cmdReferralEmail = Server.CreateObject("ADODB.Command")
	Set rsReferralEmail = Server.CreateObject("ADODB.Recordset")
	With cmdReferralEmail
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = strSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
	With rsReferralEmail
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdReferralEmail
	End With
	
	If rsReferralEmail.EOF Then
		bIDError = True
	End If
Else
	bIDError = True
End If
%>
<h1><%= TXT_CUSTOMIZE_REFERRAL_FOLLOW_UP_MAIL %><%= TXT_TO %><%=strType%></h1>
<%
If bIDError Then
%>
<p><%=TXT_NO_RECORDS_FOR_REQUEST%></p>
<%
Else
%>
<p><%= TXT_YOU_ARE_EMAILING_FOLLOW_UP_REQUEST_FOR %>
<ul>
<%
	With rsReferralEmail
		While Not .EOF
			%><li><a href="<%=makeVOLDetailsLink(.Fields("VNUM"), vbNullString, vbNullString)%>"><%=.Fields("POSITION_TITLE") & " - " & .Fields("ORG_NAME_FULL")%></a> (<%=.Fields("VolunteerName")%>: <%=.Fields("ReferralDate")%>)</li><%
			.MoveNext
		Wend
	End With
%>
</ul></p>
<form method="post" action="referral_email_preview.asp">
<%=g_strCacheFormVals%>
<input type="hidden" name="FollowUpEmailTo" value="<%=IIf(intType=TYPE_ORG,"O", "V")%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<table class="BasicBorder cell-padding-4">
<tr><th class="RevTitleBox" colspan="2"><%=TXT_CURRENT_MESSAGE%></th></tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MESSAGE_SUBJECT%></td>
	<td><input type="text" name="Subject" value="" size="<%=TEXT_SIZE%>" maxlength="100"></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%= TXT_MESSAGE_OPENING %></td>
	<td><textarea cols="<%=TEXTAREA_COLS%>" rows="<%=TEXTAREA_ROWS_XLONG%>" name="BodyOpening"></textarea></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%= TXT_REFERRAL_INFORMATION %></td>
	<td><%If intType=TYPE_ORG Then%><%= TXT_LIST_OF_REFERRALS_PLACEHOLDER%><%Else%><%= TXT_REFERRAL_DETAILS_PLACEHOLDER %><%End If%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%= TXT_MESSAGE_CLOSING %></td>
	<td><textarea cols="<%=TEXTAREA_COLS%>" rows="<%=TEXTAREA_ROWS_XLONG%>" name="BodyClosing"></textarea></td>
</tr>
<tr>
	<td colspan="2"><input type="submit" value="<%=TXT_PREVIEW_MESSAGE%>"></td>
</tr>
</table>
</form>
<%


End If
End If

Call makePageFooter(False)
%>


<!--#include file="../includes/core/incClose.asp" -->


