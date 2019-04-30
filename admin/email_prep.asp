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
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtEmailUpdate.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incEmailUpdateMsgList.asp" -->
<!--#include file="../includes/list/incViewList.asp" -->
<!--#include file="../includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="../includes/update/incUpdateEmail.asp" -->
<%
If g_bNoEmail Then
	Call securityFailure()
End If

Call makePageHeader(TXT_PREPARE_UPDATE_REQUEST, TXT_PREPARE_UPDATE_REQUEST, True, False, True, True)

Dim intDomain, _
	bMultiRecord, _
	bError

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

bMultiRecord = getEmailUpdateMultiRecord()

Dim strIDList, bIDError
strIDList = Trim(Request("IDList"))
bIDError = False

Select Case intDomain
	Case DM_CIC
		If Not user_bCanRequestUpdateCIC Then
			Call securityFailure()
		End If
		strType = TXT_CIC
		strDbArea = DM_S_CIC
		strDbAreaPath = vbNullString
		strMainKeyLink = "NUM"
		strID = "[NUM]"
		bSuggestOpp = False
		If Not IsNUMList(strIDList) Then
			strIDList = Null
		End If
	Case DM_VOL
		If (Not bMultiRecord And Not user_bCanRequestUpdateVOL) or _
				(bMultiRecord And Not (user_bCanRequestUpdateVOL And user_bCanDoBulkOpsVOL)) Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
		strDbArea = DM_S_VOL
		strDbAreaPath = "volunteer/"
		strID = "[VNUM]"
		strNUM = "[NUM]"
		If bMultiRecord Then
			strMainKeyLink = "NUM"
		Else
			strMainKeyLink = "VNUM"
		End If
		bSuggestOpp = True
		If bMultiRecord And Not IsNUMType(strIDList) Then
			strIDList = Null
		ElseIf Not bMultiRecord And Not IsVNUMList(strIDList) Then
			strIDList = Null
		End If
	Case Else
		bError = True
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			vbNullString, _
			vbNullString)
End Select

If Not bError Then

Dim strCulture, _
	strCultureFld, _
	strCultureOrg, _
	strCulturePos

intEmailID = Request("EmailID")

If Not IsIDType(intEmailID) Then
	intEmailID = Null
End If

Call setEmailUpdateValues(intDomain, bMultiRecord, intEmailID, False)

If Not Nl(strIDList) Then
	Dim strSQL
	If intDomain = DM_VOL and Not bMultiRecord Then
		strSQL =	"SELECT vo.VNUM AS ID, vod.POSITION_TITLE AS POSITION_TITLE, vo.EMAIL_UPDATE_DATE," & vbCrLf & _
					"	dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL" & vbCrLf & _
					"	FROM VOL_Opportunity vo" & vbCrLf & _
					"	LEFT JOIN VOL_Opportunity_Description vod" & vbCrLf & _
					"		ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
					"	INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
					"	INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
					"WHERE ((EXISTS(SELECT * FROM GBL_Contact WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL) OR vo.UPDATE_EMAIL IS NOT NULL) AND vo.NO_UPDATE_EMAIL=" & SQL_FALSE & ")" & vbCrLf & _
					"	AND vo.VNUM IN (" & QsStrList(strIDList) & ")" & _
					StringIf(Not Nl(g_strWhereClauseVOL),"AND (" & Replace(g_strWhereClauseVOL,"AND shp.Active=1","AND shp.Active=1 AND shp.CanUpdateRecords=1") & ")")
	ElseIf intDomain = DM_VOL and bMultiRecord Then
		strSQL =	"SELECT bt.NUM AS ID, dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & vbCrLf & _
					"bt.EMAIL_UPDATE_DATE_VOL AS EMAIL_UPDATE_DATE, (SELECT TOP 1 EMAIL FROM GBL_Contact WHERE GblContactType='VOLCONTACT' AND GblNUM=btd.NUM AND EMAIL IS NOT NULL ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID) AS VOLCONTACT_EMAIL" & vbCrLf & _
					"	FROM GBL_BaseTable bt" & vbCrLf & _
					"	INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
					"WHERE btd.NUM IN (" & QsStrList(strIDList) & ")" & vbCrLf & _
					"	AND (" & g_strWhereClauseCICNoDel & ")" & vbCrLf & _
					"SELECT RECIPIENT," & vbCrLf & _
					"	dbo.fn_VOL_EmailUpdateOpportunities(NUM, RECIPIENT,@@LANGID) AS POS_TITLES" & vbCrLf & _
					"	FROM (SELECT NUM, ISNULL(UPDATE_EMAIL,(SELECT EMAIL FROM GBL_Contact WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND LangID=@@LANGID)) AS RECIPIENT" & vbCrLf & _
					"			FROM VOL_Opportunity vo" & vbCrLf & _
					"			LEFT JOIN VOL_Opportunity_Description vod" & vbCrLf & _
					"				ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
					"			WHERE (EXISTS(SELECT * FROM GBL_Contact WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL) OR UPDATE_EMAIL IS NOT NULL) AND" & vbCrLf & _
					"				vo.NO_UPDATE_EMAIL=" & SQL_FALSE & " AND vo.NUM IN (" & QsStrList(strIDList) & ")" & vbCrLf & _
					StringIf(Not Nl(g_strWhereClauseVOL),"AND (" & Replace(g_strWhereClauseVOL,"AND shp.Active=1","AND shp.Active=1 AND shp.CanUpdateRecords=1") & ")") & _
					"		) tmp" & vbCrLf & _
					" GROUP BY NUM, RECIPIENT"
	Else
		strSQL = "SELECT bt.NUM AS ID, bt.EMAIL_UPDATE_DATE, " & _
					"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL" & vbCrLf & _
					"FROM GBL_BaseTable bt" & vbCrLf & _
					"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM" & vbCrLf & _
					"	AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM" & vbCrLf & _
					"		ORDER BY CASE WHEN bt.UPDATE_EMAIL IS NOT NULL OR E_MAIL IS NOT NULL THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
					"WHERE ((btd.E_MAIL IS NOT NULL OR bt.UPDATE_EMAIL IS NOT NULL) AND bt.NO_UPDATE_EMAIL=" & SQL_FALSE & ")" & vbCrLf & _
					"	AND bt.NUM IN (" & QsStrList(strIDList) & ")" & _
					StringIf(Not Nl(g_strWhereClauseCIC),"AND (" & Replace(g_strWhereClauseCIC,"AND shp.Active=1","AND shp.Active=1 AND shp.CanUpdateRecords=1") & ")")
	End If
	
	'Response.Write("<pre>" & strSQL & "</pre>")
	'Response.Flush()

	Dim cmdUpdateEmail, rsUpdateEmail
	Set cmdUpdateEmail = Server.CreateObject("ADODB.Command")
	Set rsUpdateEmail = Server.CreateObject("ADODB.Recordset")
	With cmdUpdateEmail
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = strSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
	With rsUpdateEmail
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdUpdateEmail
	End With
	
	If rsUpdateEmail.EOF Then
		bIDError = True
	End If
Else
	bIDError = True
End If

%>

<h1><%=TXT_CUSTOMIZE_REQUEST%> (<%=strType%>)</h1>
<%
If bIDError Then
%>
<p><%=TXT_NO_RECORDS_FOR_REQUEST%></p>
<%
Else
	Dim strRecordDbAreaPath
	Dim dateEmailUpdate
	Dim intTimePassed
	Dim strGBLVolContact
	Dim strAccessProtocol

	strRecordDbAreaPath = strDbAreaPath
	strGBLVolContact = vbNullString
	If intDomain=DM_VOL And bMultiRecord Then
		strRecordDbAreaPath = vbNullString
		strGBLVolContact = rsUpdateEmail.Fields("VOLCONTACT_EMAIL")
	End If
	
	For Each strCulture in dicMsgData
		strCultureFld = Replace(strCulture,"-","_")
		Select Case strCulture
			Case "fr-CA"
				strCultureOrg = TXT_INSERT_RECORD_NAME_FRENCH
				strCulturePos = TXT_INSERT_POSITION_TITLE_FRENCH
			Case Else
				strCultureOrg = TXT_INSERT_RECORD_NAME_ENGLISH
				strCulturePos = TXT_INSERT_POSITION_TITLE_ENGLISH
		End Select
		Set dicRecData(strCulture) = New UpdateRecordData
		Call dicRecData(strCulture).setData( _
			strCulture, _
			Nz(Application("Culture_" + strCulture),False), _
			Nz(Application("Culture_" + strCulture),False), _
			IIf(intDomain=DM_CIC,False,True), _
			"[" & strCultureOrg & "]", _
			StringIf(intDomain=DM_VOL And Not bMultiRecord,"[" & strCulturePos & "]"), _
			vbNullString _
		)
	Next


	strAccessProtocol = IIf(get_db_option("FullSSLCompatibleBaseURL" & IIf(intDomain=DM_CIC, "CIC", "VOL")), "https://", "http://")
	strMsgTxtDisp = Replace(makeEmailUpdateMsg( _
								intDomain, _
								Null, _
								strAccessProtocol & IIf(intDomain=DM_CIC,g_strBaseURLCIC,g_strBaseURLVOL), _
								vbNullString, _
								Not(intDomain=DM_VOL And bMultiRecord) _
								), _
						vbCrLf,"<br>")

	strMsgSubjDisp = makeEmailUpdateSubj("[" & TXT_INSERT_RECORD_NUMBER & "]")

	With rsUpdateEmail
		If .RecordCount = 1 Then
			strIDList = .Fields("ID")
			dateEmailUpdate = DateString(.Fields("EMAIL_UPDATE_DATE"),True)
			If Not Nl(dateEmailUpdate) Then
				intTimePassed = DateDiff("d", dateEmailUpdate, Date())
			Else
				intTimePassed = 0
			End If
%>
<p><%=TXT_REQUEST_UPDATE_FOR_RECORD%>
<a href="<%
	If intDomain=DM_CIC Then
		Response.Write(makeDetailsLink(.Fields("ID"),StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber), vbNullString))
	Else
		Response.Write(makeVOLDetailsLink(.Fields("ID"), StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber),vbNullString))
	End If
		%>">
<%If intDomain=DM_VOL And Not bMultiRecord Then%>
<%=.Fields("POSITION_TITLE")%> (#<%=.Fields("ID")%>) - 
<%End If%>
<%=.Fields("ORG_NAME_FULL")%>
</a></p>
<%
			If intTimePassed > 0 and intTimePassed < CInt(g_intDaysSinceLastEmail) Then
%>
<p><%=TXT_ONLY%> <%=intTimePassed%> <%=TXT_DAYS_SINCE_LAST_REQUEST%></p>
<%
			ElseIf Nl(dateEmailUpdate) Then
%>
<p><%=TXT_NO_RECORD_OF_LAST_REQUEST%></p>
<%
			Else
%>
<p><%=TXT_DATE_OF_LAST_REQUEST%><strong><%=dateEmailUpdate%></strong> (<%=TXT_DAYS_AGO_1%><strong><%=intTimePassed%></strong><%=TXT_DAYS_AGO_2%>).</p>
<%
			End If
		Else
			Dim strIDListCon
			strIDList = vbNullString
			strIDListCon = vbNullString
			While Not .EOF
				strIDList = strIDList & strIDListCon & .Fields("ID")
				strIDListCon = ","
				.MoveNext
			Wend
%>
<p><%=.RecordCount%> <%=TXT_NUMBER_OF_RECORDS_PREPARED%></p>
<%
		End If
		If intDomain = DM_VOL And bMultiRecord Then
			Set rsUpdateEmail = .NextRecordset
		Else
			.Close
			Set rsUpdateEmail = Nothing
			Set cmdUpdateEmail = Nothing
		End If
	End With
%>

<%
Call openEmailMsgListRst(intDomain, bMultiRecord)
%>
<form action="<%=ps_strThisPage%>" method="post" class="form-inline clear-line-below">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<%If intCurSearchNumber >= 0 Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%End If%>
<%If bMultiRecord Then%><input type="hidden" name="MR" value="1"><%End If%>
<%=makeEmailMsgList(intEmailID,"EmailID",False,vbNullString, TXT_CURRENT_MESSAGE)%>
<input type="submit" value=<%=AttrQs(TXT_CHANGE_MESSAGE)%> class="btn btn-default">
</form>
<%
Call closeEmailMsgListRst()
%>

<p><%=TXT_REVIEW_MESSAGE%></p>
<table class="BasicBorder cell-padding-4 max-width-lg">
<tr><th class="RevTitleBox" colspan="2"><%=TXT_CURRENT_MESSAGE%></th></tr>
<tr><td colspan="2" class="Info"><%=TXT_INST_EMAIL_LANGUAGE%></td></tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MESSAGE_SUBJECT%></td>
	<td><%=strMsgSubjDisp%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MESSAGE_BODY%></td>
	<td><%=strMsgTxtDisp%></td>
</tr>
</table>

<br>
<form action="email_preview.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="hidden" name="EmailID" value="<%=intEmailID%>">
<%If intCurSearchNumber >= 0 Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%End If%>
<%If bMultiRecord Then%><input type="hidden" name="MR" value="1"><%End If%>
<div class="max-width-lg">
<table class="BasicBorder cell-padding-4 full-width">
<tr><th class="RevTitleBox" colspan="2"><%=TXT_EDITABLE_SECTIONS%></th></tr>
<%
If intDomain = DM_VOL And bMultiRecord Then

Dim strPosTitles, bUsedCICVolContact

bUsedCICVolContact = False

%>
<tr>
<td class="FieldLabelLeft"><%=TXT_MESSAGE_RECIPIENT%></td>
<td><%
	With rsUpdateEmail
		While Not .EOF
			strRecipient = .Fields("RECIPIENT")
			strPosTitles = .Fields("POS_TITLES")
			if Not Nl(strGBLVolContact) And strRecipient = strGBLVolContact Then
				bUsedCICVolContact = True
				strPosTitles = strPosTitles & ", " & TXT_ORG_VOL_CONTACT
			End If
%>
<input type="checkbox" name="RecipientList" value="<%=strRecipient%>" checked>&nbsp;<%=strRecipient%> (<%=strPosTitles%>)<br>
<%
			.MoveNext
		Wend
		.Close
	End With
	Set rsUpdateEmail = Nothing
	Set cmdUpdateEmail = Nothing
	If Not Nl(strGBLVolContact) And Not bUsedCICVolContact Then
%>
<input type="checkbox" name="RecipientList" value="<%=strGBLVolContact%>" checked> <%=strGBLVolContact%> (<%=TXT_ORG_VOL_CONTACT%>) <br>
<%
	End If
%>
<%=TXT_OTHER%><%=TXT_COLON%><input type="text" name="RecipientList" value="" size="<%=TEXT_SIZE%>" maxlength="100">
<%
End If
%>
<%
Call openViewURLListRst(intDomain)
	If Not rsListView.EOF Then
%>
<tr>
	<td class="FieldLabelLeft"><label for="AccessURL"><%=TXT_VIEW%></label></td>
	<td><%=makeViewDomainList(vbNullString,"AccessURL",False, True)%></td>
</tr>
<%
	End If
Call closeViewListRst()
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MESSAGE_SUBJECT%></td>
	<td><table class="NoBorder cell-padding-2">
<%
	For Each strCulture in dicMsgData
%>
		<tr><td class="FieldLabelClr"><%
		Select Case strCulture
			Case "fr-CA"
				Response.Write("<label for=""NewSubject_fr-CA"">" & TXT_FRENCH & "</label>")
			Case Else
				Response.Write("<label for=""NewSubject_en-CA"">" & TXT_ENGLISH & "</label>")
		End Select
		%></td><td><input type="text" name="NewSubject_<%=strCulture%>" id="NewSubject_<%=strCulture%>" value=<%=AttrQs(dicMsgData(strCulture).StdSubject)%> size="<%=TEXT_SIZE%>" maxlength="100"></td></tr>
<%
	Next
	If g_bMultiLingualActive And dicMsgData.Count > 1 Then
%>
		<tr><td class="FieldLabelClr"><label for="NewSubjectBilingual"><%=TXT_BILINGUAL%></label></td><td><input type="text" name="NewSubjectBilingual" id="NewSubjectBilingual" value=<%=AttrQs(strStdSubjectBilingual)%> size="<%=TEXT_SIZE%>" maxlength="100"></td></tr>
<%
	End If
%>
	</table></td>
</tr>
<%
	For Each strCulture in dicMsgData
%>
<tr>
	<td class="FieldLabelLeft"><label for="NewBody_<%=strCulture%>"><%=TXT_MESSAGE_BODY%></label><%
		If g_bMultiLingualActive Then
			Select Case strCulture
				Case "fr-CA"
					Response.Write(" (" & TXT_FRENCH & ")")
				Case Else
					Response.Write(" (" & TXT_ENGLISH & ")")
			End Select
		End If
	%></td>
	<td><textarea rows="<%=TEXTAREA_ROWS_XLONG%>" name="NewBody_<%=strCulture%>" id="NewBody_<%=strCulture%>" class="form-control"><%=dicMsgData(strCulture).StdMessageBody%></textarea></td>
</tr>
<%
	Next
%>
<tr>
	<td colspan="2"><input type="submit" value="<%=TXT_PREVIEW_MESSAGE%>"></td>
</tr>
</table>
</div>
</form>
<%
End If

End If

Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
