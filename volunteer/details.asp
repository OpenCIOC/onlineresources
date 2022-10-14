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
Dim bIsSEFriendlyURL
If Request.ServerVariables("HTTP_CIOC_FRIENDLY_RECORD_URL") = "on" Then
	bIsSEFriendlyURL = True
Else
	bIsSEFriendlyURL = False
End If

' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtAgencyContact.asp" -->
<!--#include file="../text/txtClientTracker.asp" -->
<!--#include file="../text/txtDetails.asp" -->
<!--#include file="../text/txtDetailsVOL.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtRecordPages.asp" -->
<!--#include file="../includes/core/incChangeViews.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/search/incMyList.asp" -->
<!--#include file="../includes/stats/incInsertStat.asp" -->
<!--#include file="../includes/update/incAgencyUpdateInfo.asp" -->

<%
Sub makeFieldRow(strDisplay,strContents)
%>
<tr>
	<td class="field-label-cell"><%=strDisplay%></td>
	<td class="field-data-cell"><%=strContents%></td>
</tr>
<%
End Sub

Dim xmlLangDoc, xmlRecordLangNode, xmlLangNode

Sub loadLanguageXML()
	Set xmlLangDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlLangDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With
	
	xmlLangDoc.loadXML "<RECORD_LANG>" & Nz(rsOrg("RECORD_LANG").Value,"") & "</RECORD_LANG>"
	Set xmlRecordLangNode = xmlLangDoc.selectSingleNode("/RECORD_LANG")
End Sub

Function linkOtherLangs(bSkipFirst)
	Dim strReturn, _
		strCon

	strReturn = vbNullString
	strCon = StringIf(Not bSkipFirst, " ")

	If g_bMultiLingual Then
	
		Dim bLangActive, bCanSeeLang
		
		For Each xmlLangNode In xmlRecordLangNode.childNodes
			If xmlLangNode.getAttribute("Culture") <> strCurCulture Then
				bLangActive = CInt(Nz(xmlLangNode.getAttribute("Active"),SQL_FALSE)) = SQL_TRUE
				bCanSeeLang = CInt(Nz(xmlLangNode.getAttribute("CAN_SEE"),SQL_FALSE)) = SQL_TRUE
				If bCanSeeLang Then
					If xmlLangNode.getAttribute("Active") Then
						strReturn = strReturn & vbCrLf & strCon & _
							"<a role=""button"" class=""btn btn-info link-btn"" href=""" & makeVOLDetailsLink(strVNUM, strNumberLink & "&Ln=" & xmlLangNode.getAttribute("Culture"), "Ln") & """> " & _
							 xmlLangNode.getAttribute("LanguageName") & _
							"</a>"
					Else
						strReturn = strReturn & vbCrLf & strCon & _
							"<a role=""button"" class=""btn btn-info link-btn"" href=""" & makeVOLDetailsLink(strVNUM, strDetailsNumberLink & StringIf(Not Nl(strDetailsNumberLink), "&") & "TmpLn=" & xmlLangNode.getAttribute("Culture"), vbNullString) & """> " & _
							xmlLangNode.getAttribute("LanguageName") & _
							"</a>"
					End If
					strCon = " "
				End If
			End If
		Next
	End If
	linkOtherLangs = strReturn
End Function

Function reminderNotice()
	Dim xmlReminderDoc, xmlRemindersNode
	Set xmlReminderDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlReminderDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With
	
	xmlReminderDoc.loadXML Nz(rsOrg("REMINDERS").Value,"<reminders Total=""0"" PastDue=""0""/>")
	Set xmlRemindersNode = xmlReminderDoc.selectSingleNode("/reminders")
	Dim strReturn, _
		intDue, _
		intCount, _
		strBorderType, _
		strIconType

	intCount = CInt(Nz(xmlRemindersNode.getAttribute("Total"), 0))
	intDue = CInt(Nz(xmlRemindersNode.getAttribute("PastDue"), 0))
	strBorderType = vbNullString

	If intDue > 0 Then
		strBorderType = " btn-alert-border"
		strIconType = "fa fa-warning"
	ElseIf intcount > 0 Then
		strBorderType = " btn-warning-border"
		strIconType = "fa fa-exclamation-circle"
	Else
		strIconType = "fa fa-clock-o"
	End If

	strReturn = "<span class=""HideNoJs"">" & _
		"<a id=""reminders"" class=""btn btn-info" & strBorderType & """" & _
		" title=""" & IIf(intCount=1,TXT_REMINDER_COUNT_SINGLE, Replace(TXT_REMINDER_COUNT_MULTIPLE, "[COUNT]", intCount)) & _ 
			StringIf (intDue > 0, IIf(intDue = 1, TXT_REMINDER_DUE_SINGLE, Replace(TXT_REMINDER_DUE_MULTIPLE, "[COUNT]", intDue))) & " " & TXT_CLICK_TO_VIEW & """>" & _
		"<span class=""" & strIconType & """ aria-hidden=""true""></span> " & TXT_FLAG_REMINDERS & "</a></span>"

	reminderNotice = strReturn
End Function
	

'On Error Resume Next

Dim intOPID, _
	strVNUM, _
	bVNUMError

intOPID = Request("OPID")
strVNUM = UCase(Trim(Request("VNUM")))
bVNUMError = False

If Nl(intOPID) And Nl(strVNUM) Then
	Call makePageHeader(TXT_RECORD_DETAILS, TXT_RECORD_DETAILS, True, False, True, True)
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
	bVNUMError = True
ElseIf Not IsIDType(intOPID) And Not IsVNUMType(strVNUM) Then
	Call makePageHeader(TXT_RECORD_DETAILS, TXT_RECORD_DETAILS, True, False, True, True)
	If Not IsNUMType(strVNUM) Then
		Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
	Else
		Call handleError(TXT_INVALID_OPID & Server.HTMLEncode(intOPID) & ".", vbNullString, vbNullString)
	End If
	bVNUMError = True
ElseIf Nl(strVNUM) Then
	intOPID = CLng(intOPID)
	Dim cmdGetVNUM, rsGetVNUM
	Set cmdGetVNUM = Server.CreateObject("ADODB.Command")
	With cmdGetVNUM
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandType = adCmdText
		.CommandText = "SELECT VNUM FROM VOL_Opportunity vo WHERE vo.OP_ID=" & intOPID
		.CommandTimeout = 0
		Set rsGetVNUM = .Execute
	End With
	If Not rsGetVNUM.EOF Then
		strVNUM = rsGetVNUM("VNUM")
		Response.Status = "301 Moved Permanently"
		Response.AddHeader "Location", makeVOLDetailsLink(strVNUM, vbNullString, vbNullString) 
		%><!--#include file="../includes/core/incClose.asp" --><%
		Response.End
	Else
		Call makePageHeader(TXT_RECORD_DETAILS, TXT_RECORD_DETAILS, True, False, True, True)
		Call handleError(TXT_NO_RECORD_EXISTS_VNUM & intOPID & ".", vbNullString, vbNullString)
		bVNUMError = True
	End If
	intOPID = Null
End If 'Check OPID / VNUM

If Not bVNUMError Then

Dim strCurCulture, _
	strRestoreCulture

strCurCulture = Left(Trim(Request("TmpLn")),5)
strRestoreCulture = g_objCurrentLang.Culture

If Not Nl(Application("Culture_" & strCurCulture)) Then
	If Not Nl(Application("Culture_" & strCurCulture & "_LanguageAlias")) Then
		Call setSessionLanguage(strCurCulture)
	Else
		strCurCulture = g_objCurrentLang.Culture
	End If
Else
	strCurCulture = g_objCurrentLang.Culture
End If

Dim cmdFields, rsFields
Set cmdFields = Server.CreateObject("ADODB.Command")
With cmdFields
	.ActiveConnection = getCurrentVOLBasicCnn()
	.CommandType = adCmdStoredProc
	.CommandText = "sp_VOL_View_DisplayFields"
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
	.Parameters.Append .CreateParameter("@WebEnable", adBoolean, adParamInput, 1, IIf(g_bPrintMode,SQL_FALSE,SQL_TRUE))
	.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	.Parameters.Append .CreateParameter("@HTTPVals", adVarChar, adParamInput, 500, Nz(g_strCacheHTTPVals,Null))
	.Parameters.Append .CreateParameter("@PathToStart", adVarChar, adParamInput, 50, ps_strPathToStart)
End With
Set rsFields = Server.CreateObject("ADODB.Recordset")
With rsFields
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFields
End With

Dim strSQL, _
	strCon

strSQL = "SELECT vo.MemberID, vod.POSITION_TITLE," & _
	"dbo.fn_VOL_RecordInView(vo.VNUM," & g_intViewTypeVOL & ",vod.LangID,0,GETDATE()) AS IN_VIEW," & _
	IIf(user_bVOL,"dbo.fn_VOL_RecordInView(vo.VNUM," & user_intViewVOL & ",vod.LangID,0,GETDATE()) AS IN_DEFAULT_VIEW,","0 AS IN_DEFAULT_VIEW,") & _
	"dbo.fn_CIC_RecordInView(bt.NUM," & g_intViewTypeCIC & ",btd.LangID,0,GETDATE()) AS IN_CIC_VIEW," & _
	"dbo.fn_VOL_VNUMToReferrals(" & g_intMemberID & ",vo.VNUM) AS REFERRALS,"
If user_bLoggedIn Then
	'SQL for information Flags:
	'- Can the user update this record?
	'- Can an Email update request be sent to this record?
	'- Does this record have feedback?

	strSQL = strSQL & "dbo.fn_VOL_CanUpdateRecord(vo.VNUM," & user_intID & "," & g_intViewTypeVOL & ",@@LANGID,GETDATE()) AS CAN_UPDATE," & vbCrLf & _
	"dbo.fn_VOL_Reminders(vo.VNUM," & user_intID & ",@@LANGID,GETDATE()) AS REMINDERS,"
End If
strSQL = strSQL & "CASE WHEN EXISTS(SELECT FB_ID FROM VOL_Feedback fb WHERE fb.VNUM=vo.VNUM) " & _
		"THEN 1 ELSE 0 END AS HAS_FEEDBACK," & _
	"CASE WHEN ((EXISTS(SELECT * FROM GBL_Contact WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL) OR vo.UPDATE_EMAIL IS NOT NULL) AND vo.NO_UPDATE_EMAIL=0) " & _
		"THEN 1 ELSE 0 END AS CAN_EMAIL," & _
	"vo.VNUM, vo.OP_ID, vod.OPD_ID, vo.RECORD_OWNER," & _
	"vod.NON_PUBLIC," & _
	"cioc_shared.dbo.fn_SHR_GBL_DateString(vod.MODIFIED_DATE) AS MODIFIED_DATE," & vbCrLf & _
	"cioc_shared.dbo.fn_SHR_GBL_DateString(vod.UPDATE_DATE) AS UPDATE_DATE," & vbCrLf & _
	"cioc_shared.dbo.fn_SHR_GBL_DateString(vod.UPDATE_SCHEDULE) AS UPDATE_SCHEDULE," & vbCrLf & _
	"cioc_shared.dbo.fn_SHR_GBL_DateString(vod.DELETION_DATE) AS DELETION_DATE," & vbCrLf & _
	"cioc_shared.dbo.fn_SHR_GBL_DateString(vo.DISPLAY_UNTIL) AS DISPLAY_UNTIL"
	
If g_bDataMgmtFieldsVOL Then
	strSQL = strSQL & "," & vbCrLf & _
		"cioc_shared.dbo.fn_SHR_GBL_DateString(vod.CREATED_DATE) AS CREATED_DATE"
End If

If user_bCanRequestUpdateVOL Then
	strSQL = strSQL & "," & vbCrLf & _
		"cioc_shared.dbo.fn_SHR_GBL_DateString(vo.EMAIL_UPDATE_DATE) AS EMAIL_UPDATE_DATE"
End If

'Does this record have an Equivalent Record
strSQL = strSQL & "," & vbCrLf & _
	"(SELECT Culture,LangID,LanguageName,LanguageAlias,LCID,Active," & _
	"CASE WHEN EXISTS(SELECT * FROM VOL_Opportunity_Description WHERE VNUM=vo.VNUM AND LangID=LANG.LangID) THEN 1 ELSE 0 END AS HAS_LANG," & vbCrLf & _
	"dbo.fn_VOL_RecordInView(vo.VNUM," & g_intViewTypeVOL & ",LangID,0,GETDATE()) AS CAN_SEE" & vbCrLf & _
	StringIf(user_bLoggedIn, ",dbo.fn_VOL_CanCreateEquivalent(vo.VNUM," & user_intID & "," & g_intViewTypeVOL & ",LangID,GETDATE(),@@LANGID) AS CAN_UPDATE" & vbCrLf) & _
	"FROM STP_Language LANG WHERE " & IIf(g_bViewOtherLangsVOL,"ActiveRecord=1","EXISTS(SELECT * FROM VOL_View_Description WHERE ViewType=" & g_intViewTypeVOL & " AND LangID=LANG.LangID)") & vbCrLf & _
	"ORDER BY CASE WHEN Active=1 THEN 0 ELSE 1 END, LanguageName FOR XML AUTO) AS RECORD_LANG"

'Get SQL for fetching custom data to display for this record in this View
With rsFields
	While Not .EOF
		If Not reEquals(.Fields("FieldName"), _
				"((VNUM)|(OP_ID)|(RECORD_OWNER)|(NON_PUBLIC)|(DELETION_DATE)|(UPDATE_DATE)|(UPDATE_SCHEDULE)|(MODIFIED_DATE)|(DISPLAY_UNTIL)|(POSITION_TITLE)|(REFERRALS)" & StringIf(g_bDataMgmtFieldsVOL,"|(CREATED_DATE)") & StringIf(user_bCanRequestUpdateVOL,"|(EMAIL_UPDATE_DATE)") & ")", _
				True,False,True,False) Then
				strSQL = strSQL & "," & vbCrLf & .Fields("FieldSelect")
		End If
		.MoveNext
	Wend
	If Not .RecordCount = 0 Then
		.MoveFirst
	End If
End With

strSQL = strSQL & vbCrLf & ",vod.VNUM AS LangVNUM" & vbCrLf & _
	"FROM VOL_Opportunity vo" & vbCrLf & _
	"LEFT JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
	"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
	"WHERE vo.VNUM=" & QsN(strVNUM)

'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
'Response.Flush()

Dim cmdOrg, rsOrg
Set cmdOrg = Server.CreateObject("ADODB.Command")
With cmdOrg
	.ActiveConnection = getCurrentVOLBasicCnn()
	.CommandType = adCmdText
	.CommandText = strSQL
	.CommandTimeout = 0
	Set rsOrg = .Execute
End With

Call setSessionLanguage(strRestoreCulture)

If Err.Number <> 0 Then
	Call makePageHeader(TXT_RECORD_DETAILS, TXT_RECORD_DETAILS, True, False, True, True)
	Call handleError(TXT_ERROR & Nz(Err.Description,TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
	bVNUMError = True
ElseIf rsOrg.EOF Then
	If bIsSEFriendlyURL Then
		Response.Status = "404 Not Found"
	End If
	Call makePageHeader(TXT_RECORD_DETAILS, TXT_RECORD_DETAILS, True, False, True, True)
	Call handleError(TXT_NO_RECORD_EXISTS_VNUM & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
	bVNUMError = True
End If

End If 'bVNUMError

If Not bVNUMError Then
	Dim strNumberLink, _
		strDetailsNumberLink, _
		strVNUMLink, _
		strVNUMNumberLink, _
		strIDListLink

	strNumberLink = "Number=" & intCurSearchNumber
	strVNUMLink = "VNUM=" & strVNUM
	strDetailsNumberLink = StringIf(intCurSearchNumber >= 0, strNumberLink)
	strVNUMNumberLink = strVNUMLink & StringIf(intCurSearchNumber >= 0,"&" & strNumberLink)
	strIDListLink = "IDList=" & strVNUM & StringIf(intCurSearchNumber >= 0,"&" & strNumberLink)

	If Nl(rsOrg("OPD_ID")) Then
		Dim strOtherLangList
		Call loadLanguageXML()
		strOtherLangList = linkOtherLangs(True)
		Call makePageHeader(TXT_RECORD_DETAILS, TXT_RECORD_DETAILS, True, False, True, True)
		Call handleError(TXT_ERROR & TXT_RECORD_NOT_AVAILABLE_LANGUAGE & StringIf(Not Nl(strOtherLangList),"<br>" & TXT_RECORD_DETAILS & TXT_COLON & strOtherLangList), vbNullString, vbNullString)
		bVNUMError = True
	ElseIf Not (rsOrg("IN_DEFAULT_VIEW") Or rsOrg("IN_VIEW")) Then
		Call getROInfo(rsOrg("RECORD_OWNER"),ps_intDbArea)
		Call makePageHeader(TXT_RECORD_DETAILS, TXT_RECORD_DETAILS, True, False, True, True)
		Call handleError(TXT_ERROR & TXT_RECORD_YOU_REQUESTED & TXT_RECORD_EXISTS_BUT, vbNullString, vbNullString)
	%>
<p><%=TXT_CONCERNS & TXT_COLON%><strong><%=strROName%></strong></p>
	<%
		Call printROContactInfo(False)
		bVNUMError = True
	End If
End If 'bVNUMError

If Not bVNUMError Then

Call loadLanguageXML()
Call setSessionLanguage(strCurCulture)

Dim bExpired, bDeleted
bExpired = False
If Not Nl(rsOrg("DISPLAY_UNTIL")) Then
	If DateValue(rsOrg("DISPLAY_UNTIL")) < Date() Then
		bExpired = True
	End If
End If
bDeleted = False
If Not Nl(rsOrg("DELETION_DATE")) Then
	If CDate(rsOrg("DELETION_DATE")) <= Date() Then
		bDeleted = True
	End If
End If

Dim strOrgName
strOrgName = rsOrg.Fields("ORG_NAME_FULL")

Call makePageHeader(TXT_RECORD_DETAILS, rsOrg("POSITION_TITLE") & " (" & strOrgName & ")", True, False, IIf(g_bPrintMode,True,False), True)

If Not g_bPrintMode And Nl(Request("UseVOLVwTmp")) Then
	Call insertStat(rsOrg("OP_ID"),False,strVNUM)
End If

If Not g_bPrintMode Then

Response.Write(render_gtranslate_ui())

Dim strFormAction, strChangeViewExtraSkip
If Nl(strRecordRoot) Then
	strFormAction = ps_strThisPage
	strChangeViewExtraSkip = vbNullString
Else
	strFormAction = strVNUM
	strChangeViewExtraSkip = "(VNUM)"
End If


'Other Search Results Bar
Dim bSearchList
bSearchList = intLastSearchNumber >= intCurSearchNumber And intLastSearchNumber >= 0

If (bSearchList or user_bVOL) Then
%>
<div class="row clear-line-below">
<%
	If bSearchList Then
%>
<!-- Other Search Results -->
<div class="col-sm-12 <%=StringIf(user_bVOL," col-md-6 col-lg-8")%>">
	<div id="search-list-top">
		<div class="row">
			<div class="col-sm-5 <%=StringIf(user_bVOL,IIf(intCurSearchNumber > 0 and intCurSearchNumber < intLastSearchNumber,"col-md-12","col-md-5") & " col-lg-4")%>">
				<a href="<%=makeLinkB("~/volunteer/presults.asp")%>" role="button" class="btn">
					<span class="fa fa-list" aria-hidden="true"></span>
					<%=TXT_YOUR_SEARCH & " (" & TXT_VIEWING & " " & intCurSearchNumber+1 & TXT_OF & intLastSearchNumber+1 & ")"%>
				</a>
			</div>
			<div class="col-sm-7 <%=StringIf(user_bVOL,IIf(intCurSearchNumber > 0 and intCurSearchNumber < intLastSearchNumber,"col-md-12","col-md-7") & " col-lg-8")%>">
<%
		If intCurSearchNumber > 0 Then
%>
				<a id="first_link_top" data-num=<%=AttrQs(aGetSearchArray(0))%> href="<%=makeVOLDetailsLink(aGetSearchArray(0), "Number=0",vbNullString)%>" role="button" class="btn">
					<span class="fa fa-fast-backward" aria-hidden="true"></span> <%=TXT_FIRST%>
				</a>
				<a id="prev_link_top" data-num=<%=AttrQs(aGetSearchArray(0))%> href="<%=makeVOLDetailsLink(aGetSearchArray(intCurSearchNumber-1), "Number=" & intCurSearchNumber-1,vbNullString)%>" role="button" class="btn">
					<span class="fa fa-step-backward" aria-hidden="true"></span> <%=TXT_PREVIOUS%>
				</a>
<%
		End If
		If intCurSearchNumber < intLastSearchNumber Then
%>
				<a id="next_link_top" data-num=<%=AttrQs(aGetSearchArray(0))%> href="<%=makeVOLDetailsLink(aGetSearchArray(intCurSearchNumber+1), "Number=" & intCurSearchNumber+1,vbNullString)%>" role="button" class="btn">
					<%=TXT_NEXT%> <span class="fa fa-step-forward" aria-hidden="true"></span>
				</a>
				<a id="last_link_top" data-num=<%=AttrQs(aGetSearchArray(0))%> href="<%=makeVOLDetailsLink(aGetSearchArray(intLastSearchNumber), "Number=" & intLastSearchNumber,vbNullString)%>" role="button" class="btn">
					<%=TXT_LAST%> <span class="fa fa-fast-forward" aria-hidden="true"></span>
				</a>
<%
		End If
%>
			</div>
		</div>
	</div>
</div>
<%
	End If 'bSearchList

	If user_bVOL Then
%>
<!-- Change Views -->
<div class="col-sm-12 <%=StringIf(bSearchList," col-md-6 col-lg-4")%>">
	<form class="form" action="<%=strFormAction%>" id="change_view_form" name="ChangeViewForm">
	<div class="text-right">
<%
	Call printChangeViewsFormContents(True,DM_VOL,strChangeViewExtraSkip)
%>
	</div>
	</form>
</div>
<%
	End If 'user_bVOL
%>
</div>
<%
End If 'bSearchList or user_bVOL

End If 'g_bPrintMode

Dim bReferral
bReferral = user_bSuperUserVOL Or (user_strAgency=rsOrg("RECORD_OWNER") And user_bCanManageReferrals)
%>
<!-- Record Admin Header -->
<div class="record-details">
	<div class="RecordDetailsHeader TitleBox">
		<div class="row">
			<div class="col-md-<%=IIf(g_bPrintMode And Not (bExpired Or bDeleted),12,8)%>">
				<h2><%=rsOrg("POSITION_TITLE")%></h2>
				<h3>(<%=strOrgName%>)</h3>
			</div>
<%
If Not g_bPrintMode Or bExpired Or bDeleted Then
%>
			<div class="col-md-4 apply-button-box">
<%
	If bExpired Or bDeleted Then
%>
				<div class="AlertBubble"><span class="fa fa-warning" aria-hidden="true"></span> <%If bDeleted Then%><%=TXT_FLAG_DELETED%><%End If%><%If bDeleted And bExpired Then%> | <%End If%><%If bExpired Then%><%=TXT_FLAG_EXPIRED%><%End If%></div>
<%
	ElseIf Not g_bPrintMode Then
%>
				<form action="/volunteer/<%=IIf(bReferral,"referral_edit.asp","volunteer.asp")%>" method="post">
				<div style="display:none">
					<%=g_strCacheFormVals%>
					<input type="hidden" name="VNUM" value="<%=rsOrg("VNUM")%>">
					<%If intCurSearchNumber >= 0 Then%><input type="hidden" name="Number" value="<%=intCurSearchNumber%>"><%End If%>
				</div>
				<button id="VolApplyButton" type="submit" class="btn btn-lg btn-info"><span class="glyphicon glyphicon-check" aria-hidden="true"></span> <strong><%=IIf(bReferral,TXT_CREATE_REFERRAL,TXT_YES_VOLUNTEER)%></strong></button>
				</form>
<%
	End If
%>
			</div>
<%
End If
%>
		</div>
	</div>

	<div class="record-details-action">
<%


If Not g_bPrintMode Then
%>

		<!-- Quick Access Record Menu -->
		<div class="HideListUI clear-line-below">
			<% Call myListDetailsAddRecord(CStr(strVNUM)) %>
			<a role="button" class="btn btn-info link-btn" href="<%=makeLink("~/volunteer/feedback.asp",strVNUMNumberLink,vbNullString)%>"><span class="fa fa-edit" aria-hidden="true"></span> <%=TXT_SUGGEST_UPDATE%></a>
	<%= linkOtherLangs(False) %>
<%
	If bReferral And rsOrg("REFERRALS") > 0 Then
%>
			<a role="button" class="btn btn-info link-btn" href="<%=makeLink("~/volunteer/referral_list.asp",strVNUMNumberLink,vbNullString)%>"><span class="fa fa-external-link-square" aria-hidden="true"></span> <%= TXT_LIST_REFERRALS %> (<%=rsOrg("REFERRALS")%>)</a>
<%
	End If
	If (user_bLoggedIn Or g_bPrintModePublic) And Not Nl(g_intPrintDesignVOL) Then
%>
			<a role="button" class="btn btn-info link-btn hidden-xs" href="<%=makeVOLDetailsLink(strVNUM, "PrintMd=on&UseVOLVwTmp=" & Request("UseVOLVwTmp"),vbNullString)%>" target="_BLANK"><span class="fa fa-print" aria-hidden="true"></span> <%=TXT_PRINT_VERSION%></a>
<%
	End If
	If user_bFeedbackAlertVOL And rsOrg("HAS_FEEDBACK") Then
%>
			<a role="button" class="btn btn-info link-btn btn-alert-border" href="<%=makeLink("~/volunteer/revfeedback_view.asp",strVNUMNumberLink,vbNullString)%>"><%=TXT_FLAG_CHECK_FEEDBACK%></a>
<%
	End If
	If user_bLoggedIn Then
%>
		<%= reminderNotice() %>
<%
	End If
	If rsOrg("NON_PUBLIC") Then
%>
			<span class="AlertBubble"><%=TXT_FLAG_NON_PUBLIC%></span>
<%
	End If
	If Not Nl(rsOrg("DELETION_DATE")) And Not bDeleted Then
%>
			<span class="AlertBubble"><%=TXT_FLAG_TO_BE_DELETED%></span>
<%
	End If
%>
		</div>
				<!-- End Quick Access Menu -->
<%

	If user_bLoggedIn Then
		Dim strCreateEquivalent,bHasLang,bCanEdit
		strCreateEquivalent = vbNullString

		If g_bMultiLingual Then
			For Each xmlLangNode In xmlRecordLangNode.childNodes
				bHasLang = CInt(Nz(xmlLangNode.getAttribute("HAS_LANG"),SQL_FALSE)) = SQL_TRUE
				bCanEdit = CInt(Nz(xmlLangNode.getAttribute("CAN_UPDATE"),SQL_FALSE)) = SQL_TRUE
				If Not bHasLang And bCanEdit Then
					strCreateEquivalent = strCreateEquivalent & "<option href=""" & makeLink("~/volunteer/copy.asp",strVNUMNumberLink & "&CopyLn=" & xmlLangNode.getAttribute("Culture"),vbNullString) & """>" & TXT_CREATE_EQUIVALENT & " - " & xmlLangNode.getAttribute("LanguageName") & "</option>"
				End If
			Next
		End If

		If ( _
			rsOrg("CAN_UPDATE") = 1 Or _
			(rsOrg("CAN_UPDATE") = -2 And Not Nl(strCreateEquivalent)) Or _
			user_bSuperUserVOL Or _
			user_bCopyVOL Or _
			(user_bCanRequestUpdateVOL And (user_bSuperUserVOL Or (user_strAgency = rsOrg("RECORD_OWNER"))) And rsOrg("CAN_EMAIL") And Not g_bNoEmail) _
			) Then

%>
		<div class="row clear-line-below">
			<!-- Action Menu -->
			<div class="col-md-6 col-lg-6">
				<div class="form-inline-always">
					<div class="form-group">
						<label class="control-label" for="ActionList"><%=TXT_ACTION & TXT_COLON%></label>
						<select name="ActionList" id="ActionList" onchange="do_drop_down_navigation()" class="form-control">
							<option selected></option>
<%
			If rsOrg("CAN_UPDATE") = 1 Or rsOrg("CAN_UPDATE") = -2 Or (rsOrg("CAN_UPDATE") <> 0 And user_bCopyVOL) Then
%>
							<optgroup label="<%=TXT_DATA_MANAGEMENT%>">
<%
				If rsOrg("CAN_UPDATE") <> -2 Then
%>
								<option id="AL_Update" href="<%=makeLink("~/volunteer/entryform.asp",strVNUMNumberLink,vbNullString)%>"><%=TXT_UPDATE_RECORD%></option>
<%
				End If
%>
					<%= strCreateEquivalent %>
<%
				If user_bCopyVOL Then
%>
								<option id="AL_Copy" href="<%=makeLink("~/volunteer/copy.asp",strVNUMLink,vbNullString)%>"><%=TXT_COPY_RECORD%></option>
<%
				End If
				If (user_bSuperUserVOL Or user_bCanDeleteRecordVOL) And rsOrg("CAN_UPDATE")=1 Then
					If Nl(rsOrg("DELETION_DATE")) Then
%>
								<option href="<%=makeLink("~/volunteer/delete_mark.asp","IdList=" & rsOrg("OPD_ID"),vbNullString)%>"><%=TXT_DELETE_RECORD%></option>
<%
					Else
%>
								<option href="<%=makeLink("~/volunteer/delete_mark.asp","IdList=" & rsOrg("OPD_ID") & "&Unmark=on",vbNullString)%>"><%=TXT_RESTORE_RECORD%></option>
<%
					End If
				End If
%>
							</optgroup>
<%
			End If 'Update, Copy, Delete

			If user_bCanRequestUpdateVOL And (user_bSuperUserVOL Or user_strAgency = rsOrg("RECORD_OWNER")) And rsOrg("CAN_EMAIL") And Not g_bNoEmail Then
%>
							<optgroup label="Request Update">
								<option href="<%=makeLinkAdmin("email_prep.asp",strIDListLink & "&DM=" & DM_VOL)%>"><%=TXT_EMAIL_UPDATE_REQUEST%></option>
							</optgroup>
<%
			End If
%>
						</select>
					</div>
				</div>
			</div>
			<!-- End Action Menu -->
		</div>
<%
		End If 'Update, Copy, Delete, Email
	End If 'user_bLoggedIn
End If 'Not g_bPrintMode

'Data Management Info
%>
		<div class="<%If user_bLoggedIn And Not g_bPrintMode Then%>record-details-top-border<%End If%>">
			<div class="row">
				<div class="col-sm-4 col-md-3 record-details-admin-fields"><strong>Position ID<%=TXT_COLON%></strong> <%=rsOrg("VNUM")%></div>
<%
If g_bLastModifiedDateVOL Then
%>
				<div class="col-sm-4 col-md-3 record-details-admin-fields"><strong><%=TXT_LAST_MODIFIED%></strong><%=TXT_COLON%><span class="NoWrap"><%=Nz(rsOrg("MODIFIED_DATE"),TXT_UNKNOWN)%></span></div>
<%
End If
%>
				<div class="col-sm-4 col-md-3 record-details-admin-fields"><strong><%=TXT_LAST_UPDATE%></strong><%=TXT_COLON%><span class="NoWrap"><%=Nz(rsOrg("UPDATE_DATE"),TXT_UNKNOWN)%></span></div>
<%
If g_bDataMgmtFieldsVOL Then
	Dim dUpdateSchedule, strUpdateSchedule
	dUpdateSchedule = Null
	If Not Nl(rsOrg("UPDATE_SCHEDULE")) Then
		dUpdateSchedule = DateValue(rsOrg("UPDATE_SCHEDULE"))	
	End If
	If Now() > dUpdateSchedule Or Nl(dUpdateSchedule) Then
		strUpdateSchedule = "<span class=""Alert"">" & Nz(rsOrg("UPDATE_SCHEDULE"),TXT_UNKNOWN) & "</span>"
	Else
		strUpdateSchedule = rsOrg("UPDATE_SCHEDULE")
	End If
%>
				<div class="col-sm-4 col-md-3 record-details-admin-fields"><strong><%=TXT_UPDATE_SCHEDULE%></strong><%=TXT_COLON%><span class="NoWrap"><%=strUpdateSchedule%></span></div>
				<div class="col-sm-4 col-md-3 record-details-admin-fields"><strong><%=TXT_RECORD_OWNER%></strong><%=TXT_COLON%><%=rsOrg("RECORD_OWNER")%></div>
				<div class="col-sm-4 col-md-3 record-details-admin-fields"><strong><%=TXT_DATE_CREATED%></strong><%=TXT_COLON%><%=IIf(Nl(rsOrg("CREATED_DATE")),TXT_UNKNOWN,DateString(rsOrg("CREATED_DATE"),True))%></div>
				<div class="col-sm-4 col-md-3 record-details-admin-fields"><strong><%=TXT_DATE_DELETED%></strong><%=TXT_COLON%><span class="<%If bDeleted Then%>Alert <%End If%> %>NoWrap"><%=IIf(Nl(rsOrg("DELETION_DATE")),TXT_NA,DateString(rsOrg("DELETION_DATE"),True))%></span></div>
<%
	If user_bCanRequestUpdateVOL Then
%>
				<div class="col-sm-4 col-md-3 record-details-admin-fields"><strong><%=TXT_LAST_EMAIL%><%=TXT_COLON%></strong><%=Nz(rsOrg("EMAIL_UPDATE_DATE"),TXT_NA)%></div>
<%
	End If
End If
If Not g_bPrintMode And g_bSocialMediaShareVOL Then
%>
				<div class="col-sm-4 col-md-3 hidden-xs record-details-admin-fields"><table border="0" class="NoBorder"><tr><td><span style="padding-right:0.5em; font-weight: bold;"><%=TXT_SHARE%></span></td><td><div class="addthis_inline_share_toolbox"></div></td></tr></table></div>
<%
End If
%>
			</div>
		</div>
	</div>
	<!-- End Admin Section -->

</div>
<!-- End Opportunity Info Header -->

<!-- Opportunity Details Section -->
<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
		<h3><span class="glyphicon glyphicon-user" aria-hidden="true"></span> <%=TXT_OPPORTUNITY_DETAILS & rsOrg("POSITION_TITLE")%></h3>
	</div>
	<div class="panel-body no-padding">
		<table class="BasicBorder cell-padding-4 full-width inset-table responsive-table">
<%
	Dim strFieldName, strFieldContents, bOrgFields
	bOrgFields = False
	While Not (rsFields.EOF Or bOrgFields)
		strFieldName = rsFields.Fields("FieldName")
		bOrgFields = Not rsFields.Fields("IS_VOL")
		If Not bOrgFields Then
			If Not Nl(rsOrg(strFieldName)) Then
				If rsFields.Fields("CheckMultiline") Then
					strFieldContents = textToHTML(rsOrg(strFieldName))
				Else
					strFieldContents = rsOrg(strFieldName)
				End If
				Call makeFieldRow(rsFields.Fields("FieldDisplay"),strFieldContents)
			End If
			rsFields.MoveNext
		End If
	Wend
%>
		</table>
	</div>
</div>

<!-- Agency Details Section -->
<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
		<h3><span class="fa icon-commerical-building" aria-hidden="true"></span> <%=TXT_ABOUT_AGENCY & strOrgName%></h3>
	</div>
	<div class="panel-body no-padding">
<%
	If Not g_bPrintMode Then
%>
		<div class="record-details-action text-center">
<%
		If (user_bLoggedIn Or g_bUseCIC) And rsOrg("IN_CIC_VIEW") Then
%>
			<a role="button" class="btn btn-info link-btn" href="<%=makeDetailsLink(rsOrg("NUM"),vbNullString,vbNullString)%>"><span class="fa fa-info-circle" aria-hidden="true"></span> <%= TXT_MORE_AGENCY_INFO %></a>
<%
		End If
%>
			<a role="button" class="btn btn-info link-btn" href="<%=makeLink("~/volunteer/results.asp","NUM=" & rsOrg("NUM"),vbNullString)%>"><span class="fa fa-users" aria-hidden="true"></span> <%= TXT_OTHER_OPPORTUNITIES %></a>
<%
		If user_bAddVOL Then
%>
			<a role="button" class="btn btn-info link-btn" href="<%=makeLink("~/volunteer/entryform.asp","NUM=" & rsOrg("NUM"),vbNullString)%>"><span class="fa fa-plus" aria-hidden="true"></span> <%=TXT_CREATE_NEW_OPP%></a>
<%
		Else
%>
			<a role="button" class="btn btn-info link-btn" href="<%=makeLink("~/volunteer/feedback.asp","NUM=" & rsOrg("NUM"),vbNullString)%>"><span class="fa fa-plus" aria-hidden="true"></span> <%= TXT_SUGGEST_NEW_OPPORTUNITY %></a>
<%
		End If
		If user_bCanRequestUpdateVOL And user_bCanDoBulkOpsVOL And Not g_bNoEmail Then
%>
			<a role="button" class="btn btn-info link-btn" href="<%=makeLinkAdmin("email_prep.asp","IDList=" & rsOrg("NUM") & "&MR=1&DM=" & DM_VOL)%>"><span class="fa fa-envelope" aria-hidden="true"></span> <%=TXT_EMAIL_UPDATE_ALL_VOL_OPP%></a>
<%
		End If
%>
		</div>
<%
	End If
%>
		<table class="BasicBorder cell-padding-4 full-width inset-table responsive-table">
<%
	While Not rsFields.EOF
		strFieldName = rsFields.Fields("FieldName")
		If Not reEquals(strFieldName, "((NUM)|(ORG_NAME_FULL))",True,False,True,False) Then
			If Not Nl(rsOrg(strFieldName)) Then
				If rsFields.Fields("CheckMultiline") Then
					strFieldContents = textToHTML(rsOrg(strFieldName))
				Else
					strFieldContents = rsOrg(strFieldName)
				End If
				Call makeFieldRow(rsFields.Fields("FieldDisplay"),strFieldContents)
			End If
		End If
		rsFields.MoveNext
	Wend

	rsFields.Close
	Set rsFields = Nothing
	Set cmdFields = Nothing
%>
		</table>
	</div>
</div>

<%
If user_bLoggedIn And Not g_bPrintMode Then
%>
<div id="reminder-dialog" style="display: none;">
	<div id="existing-reminders-page"></div>
</div>

<div id="reminder-edit-dialog" style="display: none;">
</div>
<%
End If
%>

<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/details.js") %>
<% g_bListScriptLoaded = True %>
<script type="text/javascript">
	(function() {
		var initialize = function() {
			init_cached_state();

			var target = document.getElementById('ActionList');
			if (!target) {
				return;
			}
			target.options[0].selected = true;
			<% If user_bLoggedIn Then %>
				initialize_reminders('<%= TXT_REMINDERS %>', <%= JSONQs(makeLinkB("~/jsonfeeds/users"), True) %>,
						<%= JSONQs(makeLink("~/reminders", "VNUM=" & strVNUM, vbNullString), True) %>, 
						<%= JSONQs(makeLinkB("~/reminders/dismiss/IDIDID"), True) %>,
						"<%= TXT_COLON %>",
						<%= JSONQS(TXT_READ_MORE, True)%>, <%= JSONQs(TXT_READ_LESS, True) %>,
						<%= JSONQs(TXT_LOADING, True) %>,
						<%= JSONQs(makeLinkB("~/reminders/delete/IDIDID"), True) %>,
						<%= JSONQs(TXT_NOT_FOUND, True) %>);
			<% End If %>

				do_drop_down_navigation()
		};

		jQuery(initialize);
	})()
	<% If g_bSocialMediaShareVOL Then %>
	var addthis_exclude = 'print';
	<% End If %>
</script>
<%
	If Not g_bPrintMode And g_bSocialMediaShareVOL Then
%>
<script type="text/javascript" src="//s7.addthis.com/js/250/addthis_widget.js#pubid=ra-4f7b02c913a929bb"></script>
<%
	End If
End If

Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
