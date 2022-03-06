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
<!--#include file="../text/txtFormDataCheck.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/validation/incFormDataCheck.asp" -->
<!--#include file="../includes/update/incUpdateEmail.asp" -->
<!--#include file="../includes/update/incAgencyUpdateInfo.asp" -->
<%
If g_bNoEmail Then
	Call securityFailure()
End If

Call makePageHeader(TXT_PREVIEW_MESSAGE_TITLE, TXT_PREVIEW_MESSAGE_TITLE, True, False, True, True)

Dim intDomain, _
	bMultiRecord, _
	intViewType, _
	intViewTypeURL, _
	strAccessURL, _
	strErrorList, _
	strRecipientList, _
	bError

bError = False

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

bMultiRecord = getEmailUpdateMultiRecord()

strRecipientList = Trim(Request("RecipientList"))
strRecipientList = reReplace(strRecipientList,",$",vbNullString,False,False,False,False)

Call checkEmail(TXT_MESSAGE_RECIPIENT,strRecipientList)
If intDomain = DM_VOL And bMultiRecord And Nl(strRecipientList) Then
		strErrorList = strErrorList & _
			"<li>" & TXT_NO_RECIPIENT_EMAIL & "</li>"
End If

If Not Nl(strErrorList) Then
	bError = True
	Call handleError(TXT_ERROR & TXT_USE_BACK_BUTTON & "<ul>" & strErrorList & "</ul>", _
		vbNullString, _
		vbNullString)
End If

Dim aAccessURL
aAccessURL = Split(Request("AccessURL")," ")
If UBound(aAccessURL)=2 Then
	If IsIDType(aAccessURL(0)) Then
		intViewTypeURL = CInt(aAccessURL(0))
	Else
		intViewTypeURL = Null
	End If
	If IsIDType(aAccessURL(1)) Then
		intViewType = CInt(aAccessURL(1))
	Else
		intViewType = Null
	End If
	strAccessURL = aAccessURL(2)
Else
	intViewTypeURL = Null
	intViewType = Null
	strAccessURL = IIf(intDomain=DM_CIC,g_strBaseURLCIC,g_strBaseURLVOL)
End If

Dim strIDList, _
	bIDError
	
strIDList = Trim(Request("IDList"))
bIDError = False

Select Case intDomain
	Case DM_CIC
		If Not user_bCanRequestUpdateCIC Then
			Call securityFailure()
		End If
		strType = TXT_CIC
		strDbArea = DM_S_CIC
		strDbAreaPath = ""
		strMainKeyLink = "NUM"
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
	strCultureCon, _
	i

intEmailID = Request("EmailID")

If Not IsIDType(intEmailID) Then
	intEmailID = Null
End If

Call setEmailUpdateValues(intDomain, bMultiRecord, intEmailID, True)

If Not Nl(strIDList) Then
	Dim strSQL
	If intDomain = DM_VOL and Not bMultiRecord Then
		strSQL = "SELECT vo.VNUM AS ID, bt.NUM, vo.FBKEY, vo.RECORD_OWNER, ISNULL(vo.UPDATE_EMAIL,(SELECT DISTINCT EMAIL + ',' FROM GBL_Contact WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM FOR XML PATH('') )) AS RECIPIENT," & vbCrLf & _
			"CASE WHEN EXISTS(SELECT * FROM VOL_Opportunity v2 INNER JOIN VOL_Opportunity_Description vd2 ON v2.VNUM=vd2.VNUM WHERE v2.NUM=vo.NUM AND v2.VNUM <> vo.VNUM AND dbo.fn_VOL_RecordInView(v2.VNUM," & Nz(intViewType,"NULL") & ",vd2.LangID,0,GETDATE())=1) THEN 1 ELSE 0 END AS HAS_OPPS"

		For Each strCulture In dicMsgData
			strCultureFld = Replace(strCulture,"-","_")
			strSQL = strSQL & "," & vbCrLf & "btd" & strCultureFld & ".NUM AS NUM_" & strCultureFld & _
				", vod" & strCultureFld & ".VNUM AS " & strCultureFld & _
				", dbo.fn_VOL_RecordInView(vo.VNUM," & Nz(intViewType,"NULL") & "," & Application("Culture_" & strCulture & "_LangID") & ",0,GETDATE()) AS IS_PUBLIC_" & strCultureFld & _
				", vod" & strCultureFld & ".POSITION_TITLE AS POSITION_TITLE_" & strCultureFld & _
				", dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd" & strCultureFld & ".ORG_LEVEL_1,btd" & strCultureFld & ".ORG_LEVEL_2,btd" & strCultureFld & ".ORG_LEVEL_3,btd" & strCultureFld & ".ORG_LEVEL_4,btd" & strCultureFld & ".ORG_LEVEL_5,btd" & strCultureFld & ".LOCATION_NAME,btd" & strCultureFld & ".SERVICE_NAME_LEVEL_1,btd" & strCultureFld & ".SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL_" & strCultureFld
		Next

		strSQL = strSQL & vbCrLf & _
			"FROM VOL_Opportunity vo" & vbCrLf & _
			"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM"

		For Each strCulture In dicMsgData
			strCultureFld = Replace(strCulture,"-","_")
			strSQL = strSQL & vbCrLf & _
				"	LEFT JOIN VOL_Opportunity_Description vod" & strCultureFld & " ON vo.VNUM=vod" & strCultureFld & ".VNUM AND vod" & strCultureFld & ".LangID=" & Application("Culture_" & strCulture & "_LangID") & vbCrLf & _
				"	LEFT JOIN GBL_BaseTable_Description btd" & strCultureFld & " ON bt.NUM=btd" & strCultureFld & ".NUM AND btd" & strCultureFld & ".LangID=" & Application("Culture_" & strCulture & "_LangID")
		Next

		strSQL = strSQL & vbCrLF & _
			"WHERE ((EXISTS(SELECT * FROM GBL_Contact WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL) OR vo.UPDATE_EMAIL IS NOT NULL) AND vo.NO_UPDATE_EMAIL=" & SQL_FALSE & ")" & vbCrLf & _
			"	AND vo.VNUM IN (" & QsStrList(strIDList) & ")"
	ElseIf intDomain = DM_VOL and bMultiRecord Then
		strSQL = "SELECT bt.NUM AS ID, " & QsNl(user_strAgency) & " AS RECORD_OWNER," & _
		"CASE WHEN EXISTS(SELECT * FROM VOL_Opportunity v2 INNER JOIN VOL_Opportunity_Description vd2 ON v2.VNUM=vd2.VNUM WHERE v2.NUM=bt.NUM AND dbo.fn_VOL_RecordInView(v2.VNUM," & Nz(intViewType,"NULL") & ",vd2.LangID,0,GETDATE())=1) THEN 1 ELSE 0 END AS HAS_OPPS"

		For Each strCulture In dicMsgData
			strCultureFld = Replace(strCulture,"-","_")
			strSQL = strSQL & "," & vbCrLf & "btd" & strCultureFld & ".NUM AS " & strCultureFld & _
				", dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd" & strCultureFld & ".ORG_LEVEL_1,btd" & strCultureFld & ".ORG_LEVEL_2,btd" & strCultureFld & ".ORG_LEVEL_3,btd" & strCultureFld & ".ORG_LEVEL_4,btd" & strCultureFld & ".ORG_LEVEL_5,btd" & strCultureFld & ".LOCATION_NAME,btd" & strCultureFld & ".SERVICE_NAME_LEVEL_1,btd" & strCultureFld & ".SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL_" & strCultureFld
		Next

		strSQL = strSQL & vbCrLf & _
			"FROM GBL_BaseTable bt"

		For Each strCulture In dicMsgData
			strCultureFld = Replace(strCulture,"-","_")
			strSQL = strSQL & vbCrLf & _
				"	LEFT JOIN GBL_BaseTable_Description btd" & strCultureFld & " ON bt.NUM=btd" & strCultureFld & ".NUM AND btd" & strCultureFld & ".LangID=" & Application("Culture_" & strCulture & "_LangID")
		Next

		strSQL = strSQL & vbCrLf & "WHERE ("
		
		strCultureCon = vbNullString
		For Each strCulture In dicMsgData
			strCultureFld = Replace(strCulture,"-","_")
			strSQL = strSQL & strCultureCon & _
				"btd" & strCultureFld & ".NUM IS NOT NULL"
			strCultureCon = OR_CON
		Next

		strSQL = strSQL & ")" & vbCrLf & _
				"	AND bt.NUM IN (" & QsStrList(strIDList) & ")"
	Else
		strSQL = "SELECT bt.NUM AS ID, bt.FBKEY, bt.RECORD_OWNER, ISNULL(bt.UPDATE_EMAIL,(SELECT DISTINCT E_MAIL + ',' FROM GBL_BaseTable_Description WHERE NUM=bt.NUM AND E_MAIL IS NOT NULL FOR XML PATH(''))) AS RECIPIENT"

		For Each strCulture In dicMsgData
			strCultureFld = Replace(strCulture,"-","_")
			strSQL = strSQL & "," & vbCrLf & "btd" & strCultureFld & ".NUM AS " & strCultureFld & _
				", dbo.fn_CIC_RecordInView(bt.NUM," & Nz(intViewType,"NULL") & "," & Application("Culture_" & strCulture & "_LangID") & ",0,GETDATE()) AS IS_PUBLIC_" & strCultureFld & _
				", dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd" & strCultureFld & ".ORG_LEVEL_1,btd" & strCultureFld & ".ORG_LEVEL_2,btd" & strCultureFld & ".ORG_LEVEL_3,btd" & strCultureFld & ".ORG_LEVEL_4,btd" & strCultureFld & ".ORG_LEVEL_5,btd" & strCultureFld & ".LOCATION_NAME,btd" & strCultureFld & ".SERVICE_NAME_LEVEL_1,btd" & strCultureFld & ".SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL_" & strCultureFld	
		Next

		strSQL = strSQL & vbCrLf & _
			"FROM GBL_BaseTable bt"

		For Each strCulture In dicMsgData
			strCultureFld = Replace(strCulture,"-","_")
			strSQL = strSQL & vbCrLf & _
				"	LEFT JOIN GBL_BaseTable_Description btd" & strCultureFld & " ON bt.NUM=btd" & strCultureFld & ".NUM AND btd" & strCultureFld & ".LangID=" & Application("Culture_" & strCulture & "_LangID")
		Next

		strSQL = strSQL & vbCrLf & "WHERE ("
		
		strCultureCon = vbNullString
		For Each strCulture In dicMsgData
			strCultureFld = Replace(strCulture,"-","_")
			strSQL = strSQL & strCultureCon & _
				"btd" & strCultureFld & ".NUM IS NOT NULL"
			strCultureCon = OR_CON
		Next
		
		strSQL = strSQL & ")" & vbCrLf & _
				"	AND ((bt.UPDATE_EMAIL IS NOT NULL OR EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=bt.NUM AND E_MAIL IS NOT NULL)) AND bt.NO_UPDATE_EMAIL=" & SQL_FALSE & ")" & vbCrLf & _
				"	AND bt.NUM IN (" & QsStrList(strIDList) & ")"
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

<h1><%=TXT_PREVIEW_MESSAGE_TITLE%> (<%=strType%>)</h1>
<%
If bIDError Then
%>
<p><%=TXT_NO_RECORDS_FOR_REQUEST%></p>
<%
Else
	Dim strPosTitleList, _
		strPosTitleCon

	strPosTitleList = vbNullString
	strPosTitleCon = vbNullString

	With rsUpdateEmail
		If intDomain = DM_VOL and bMultiRecord Then
			strRecipient = strRecipientList
		Else
			strRecipient = .Fields("RECIPIENT")
			If Right(strRecipient, 1) = "," Then 
				strRecipient = Left(strRecipient, Len(strRecipient)-1) ' trim extra comma
			End If

		End If

		If intDomain = DM_CIC Then
			For Each strCulture in dicMsgData
				strCultureFld = Replace(strCulture,"-","_")
				Set dicRecData(strCulture) = New UpdateRecordData
				Call dicRecData(strCulture).setData( _
					strCulture, _
					Not Nl(.Fields(strCultureFld)), _
					.Fields("IS_PUBLIC_" & strCultureFld), _
					False, _
					.Fields("ORG_NAME_FULL_" & strCultureFld), _
					vbNullString, _
					.Fields("FBKEY") _
				)
			Next
		ElseIf bMultiRecord Then
			For Each strCulture in dicMsgData
				strCultureFld = Replace(strCulture,"-","_")
				Set dicRecData(strCulture) = New UpdateRecordData
				Call dicRecData(strCulture).setData( _
					strCulture, _
					Not Nl(.Fields(strCultureFld)), _
					False, _
					.Fields("HAS_OPPS"), _
					.Fields("ORG_NAME_FULL_" & strCultureFld), _
					vbNullString, _
					vbNullString _
				)
			Next
		Else
			For Each strCulture in dicMsgData
				strCultureFld = Replace(strCulture,"-","_")
				Set dicRecData(strCulture) = New UpdateRecordData
				Call dicRecData(strCulture).setData( _
					strCulture, _
					Not Nl(.Fields(strCultureFld)), _
					.Fields("IS_PUBLIC_" & strCultureFld), _
					.Fields("HAS_OPPS"), _
					.Fields("ORG_NAME_FULL_" & strCultureFld), _
					.Fields("POSITION_TITLE_" & strCultureFld), _
					.Fields("FBKEY") _
				)
			Next
		End If
		
		strID = .Fields("ID")

		If intDomain = DM_VOL And Not bMultiRecord Then
			strNUM = .Fields("NUM")

			For Each indCulture In aMsgCultures
				If dicRecData.Exists(indCulture) Then
					If dicRecData(indCulture).HasLang Then
						strCultureFld = Replace(indCulture,"-","_")
						strPosTitleList = strPosTitleList & strPosTitleCon & .Fields("POSITION_TITLE_" & strCultureFld)
						strPosTitleCon = " / "
					End If
				End If
			Next
			strNUMDesc = strPosTitleList & " - #" & strID
		Else
			strNUM = strID
			strNUMDesc = strNUM
		End If
		
		strMsgTxtDisp = Replace(makeEmailUpdateMsg( _
								intDomain, _
								intViewTypeURL, _
								"https://" & strAccessURL, _
								.Fields("RECORD_OWNER"), _
								Not(intDomain=DM_VOL And bMultiRecord) _
								), _
						vbCrLf,"<br>")
						
		strMsgSubjDisp = makeEmailUpdateSubj(strNUMDesc)
%>
<p><%=.RecordCount%> <%=TXT_NUMBER_OF_RECORDS_PREPARED%></p>
<p><%=TXT_REVIEW_MESSAGE%></p>
<%
		.Close
	End With
	Set rsUpdateEmail = Nothing
	Set cmdUpdateEmail = Nothing
%>
<p><%=TXT_HERE_IS_A_PREVIEW%></p>
<form action="email_send.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="AccessURL" value="<%=Nz(intViewTypeURL,vbNullString) & " " & Nz(intViewType,vbNullString) & " " & strAccessURL %>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="hidden" name="EmailID" value="<%=intEmailID%>">
<%If intCurSearchNumber >= 0 Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%End If%>
<%
	For Each strCulture in dicMsgData
%>
<input type="hidden" name="NewSubject_<%=strCulture%>" value=<%=AttrQs(dicMsgData(strCulture).StdSubject)%>>
<input type="hidden" name="NewBody_<%=strCulture%>" value=<%=AttrQs(dicMsgData(strCulture).StdMessageBody)%>>
<%
	Next
%>
<input type="hidden" name="NewSubjectBilingual" value=<%=AttrQs(strStdSubjectBilingual)%>>
<%If bMultiRecord Then%>
<input type="hidden" name="RecipientList" value=<%=AttrQs(strRecipientList)%>>
<input type="hidden" name="MR" value="1">
<%End If%>
<table class="BasicBorder cell-padding-4 max-width-lg">
<tr>
	<td class="FieldLabelLeft"><%=TXT_MESSAGE_SENDER%></td>
	<td><%=strROUpdateEmail%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MESSAGE_RECIPIENT%></td>
	<td><%=strRecipient%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MESSAGE_SUBJECT%></td>
	<td><%=strMsgSubjDisp%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MESSAGE_BODY%></td>
	<td><%=strMsgTxtDisp%></td>
</tr>
<tr>
	<td colspan="2"><input type="submit" value="<%=TXT_SEND_MESSAGE%>"></td>
</tr>
</table>
</form>
<%
End If

End If

Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
