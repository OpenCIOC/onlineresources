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
<!--#include file="../includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/core/incSendMail.asp" -->
<%
Server.ScriptTimeOut = 600

Call makePageHeader(TXT_SEND_MESSAGE_TITLE, TXT_SEND_MESSAGE_TITLE, True, False, True, True)

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

Dim strBodyOpening, _
	strBodyClosing, _
	strMsgSubj

strBodyOpening = Trim(Request("BodyOpening"))
strBodyClosing  = Trim(Request("BodyClosing"))
strMsgSubj = Trim(Request("Subject"))

If Nl(strMsgSubj) Then
	Call handleError(TXT_ERROR & TXT_MESSAGE_SUBJECT_REQUIRED,vbNullString, vbNullString)
	bError = True
ElseIf Nl(strBodyOpening) Then
	bError = True
	Call handleError(TXT_ERROR & TXT_MESSAGE_OPENING_REQUIRED,vbNullString, vbNullString)
End If

If Not bError Then

Dim strIDList, _
	bIDError
	
strIDList = Trim(Request("IDList"))
bIDError = False

If Not Nl(strIDList) Then
	Dim strSQL
	strSQL = "SELECT vo.VNUM, vod.POSITION_TITLE, rf.REF_ID, rf.VolunteerName, cioc_shared.dbo.fn_SHR_GBL_DateString(rf.ReferralDate) AS ReferralDate," & _
				"bt.NUM, dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & _
				"(SELECT TOP 1 CMP_Name AS CONTACT_NAME FROM GBL_Contact AS CONTACT WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL ORDER BY CASE WHEN CONTACT.LangID=vod.LangID THEN 0 ELSE 1 END, LangID) AS CONTACT_NAME,"
	If intType = TYPE_ORG Then
		strSQL = strSQL & " (SELECT TOP 1 EMAIL AS CONTACT_EMAIL FROM GBL_Contact AS CONTACT WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL ORDER BY CASE WHEN CONTACT.LangID=vod.LangID THEN 0 ELSE 1 END, LangID) AS RECIPIENT"
	Else
		strSQL = strSQL & " rf.VolunteerEmail AS RECIPIENT, rf.VolunteerContactType, rf.VolunteerContactDate"
	End If

	strSQL = strSQL & vbCrLf & _
			"FROM VOL_OP_Referral rf" & vbCrLf & _
			"INNER JOIN VOL_Opportunity vo ON rf.VNUM=vo.VNUM" & vbCrLf & _
			"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
			"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
			"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
			"WHERE rf.REF_ID IN (" & strIDList & ")"
	If Not user_bSuperUserVOL Then
		strSQL = strSQL & " AND vo.RECORD_OWNER=" & QsNl(user_strAgency)
	End If
	If intType = TYPE_ORG Then
		strSQL = strSQL & " AND (SELECT TOP 1 EMAIL AS CONTACT_EMAIL FROM GBL_Contact AS CONTACT WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL ORDER BY CASE WHEN CONTACT.LangID=vod.LangID THEN 0 ELSE 1 END, LangID) IS NOT NULL AND vo.NO_UPDATE_EMAIL=" & SQL_FALSE & _
				" ORDER BY bt.NUM, (SELECT TOP 1 EMAIL AS CONTACT_EMAIL FROM GBL_Contact AS CONTACT WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL ORDER BY CASE WHEN CONTACT.LangID=vod.LangID THEN 0 ELSE 1 END, LangID), POSITION_TITLE, VolunteerName"
	Else
		strSQL = strSQL & " AND rf.VolunteerEmail IS NOT NULL"
	End If

	'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
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
		.LockType = adLockOptimistic
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
<p>[ <a href="<%=makeLinkB("referral.asp")%>"><%= TXT_REFERRALS_MAIN_MENU %></a> ]</p>
<h1><%=TXT_SEND_MESSAGE_TITLE%><%= TXT_TO %><%=strType%></h1>
<%
If bIDError Then
%>
<p><%=TXT_NO_RECORDS_FOR_REQUEST%></p>
<%
Else
	Dim intLastNUM, _
		strNUM, _
		strLastContactName, _
		strLastRecipient, _
		strContactName, _
		strOrgName, _
		strPosTitle, _
		strRecipient, _
		strReferralDate, _
		strReferralInfo, _
		strVolunteerName

	Call getROInfo(user_strAgency,DM_VOL)
	If Nl(strROUpdateEmail) Then
%>
	<p><%= TXT_UNABLE_TO_SEND_MESSAGES %> (<%=TXT_NO_AGENCY_EMAIL_FOR & user_strAgency%></p>
<%
	Else
	With rsReferralEmail
		intLastNUM = .Fields("NUM")
		strLastContactName = .Fields("CONTACT_NAME")
		strLastRecipient = .Fields("RECIPIENT")
		strReferralInfo = vbNullString

		While Not .EOF
			strNUM = .Fields("NUM")
			strContactName = .Fields("CONTACT_NAME")
			strOrgName = .Fields("ORG_NAME_FULL")
			strPosTitle = .Fields("POSITION_TITLE")
			strRecipient = .Fields("RECIPIENT")
			strReferralDate = .Fields("ReferralDate")
			strVolunteerName = .Fields("VolunteerName")

			If intType=TYPE_VOL Then
				strReferralInfo = _
					TXT_REFERRAL_DATE & TXT_COLON & strReferralDate & vbCrLf & _
					TXT_POSITION & " " & strPosTitle & vbCrLf & _
					TXT_ORGANIZATION & TXT_COLON & strOrgName & vbCrLf & vbCrLf
				Call sendEmail(False, strROUpdateEmail & " <" & strROUpdateEmail & ">",strRecipient, strMsgSubj, strBodyOpening & vbCrLf & vbCrLf & strReferralInfo & strBodyClosing)
				Response.Write(TXT_EMAIL_SENT_TO & "<strong>" & strRecipient & "</strong> (" & strVolunteerName & ") about:<div style=""margin-left:4em;"">" & Replace(Trim(strReferralInfo), vbCrLf, "<br>") & "</div>" & vbCrLf)
				.Fields("VolunteerContactDate") = Now()
				.Fields("VolunteerContactType") = 2 'CONTACT_BY_EMAIL
				.Update

			Else
				If strNUM<>intLastNUM Or strRecipient<>strLastRecipient Then
					Call sendEmail(False, strROUpdateEmail & " <" & strROUpdateEmail & ">",strLastRecipient, strMsgSubj, strBodyOpening & vbCrLf & vbCrLf & strReferralInfo & strBodyClosing)
				Response.Write(TXT_EMAIL_SENT_TO & "<strong>" & strLastRecipient & "</strong>"& IIf(Not Nl(strLastContactName), " (" & strLastContactName & ")", vbNullString) & " about:<div style=""margin-left:4em;"">" & Replace(Trim(strReferralInfo), vbCrLf, "<br>") & "</div>" & vbCrLf)


					intLastNUM = strNUM
					strLastContactName = strContactName
					strLastRecipient = strRecipient
					strReferralInfo = vbNullString

				End If
				strReferralInfo = strReferralInfo & _
					TXT_REFERRAL_DATE & TXT_COLON & strReferralDate & vbCrLf & _
					TXT_POSITION & " " & strPosTitle & vbCrLf & _
					TXT_VOLUNTEER & TXT_COLON & strVolunteerName & vbCrLf & vbCrLf
			End If
				

			.MoveNext
		Wend

		If intType=TYPE_ORG Then
			Call sendEmail(False, strROUpdateEmail & " <" & strROUpdateEmail & ">",strLastRecipient, strMsgSubj, strBodyOpening & vbCrLf & vbCrLf & strReferralInfo & strBodyClosing)
			Response.Write(TXT_EMAIL_SENT_TO & "<strong>" & strLastRecipient & "</strong>"& IIf(Not Nl(strLastContactName), " (" & strLastContactName & ")", vbNullString) & " about:<div style=""margin-left:4em;"">" & Replace(Trim(strReferralInfo), vbCrLf, "<br>") & "</div>" & vbCrLf)
		End If
	End With
	End If

End If

End If
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->


