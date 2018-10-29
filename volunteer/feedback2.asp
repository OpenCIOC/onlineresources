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
Call setPageInfo(False, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)

%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtCommonForm.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtFeedback.asp" -->
<!--#include file="../text/txtFeedbackCommon.asp" -->
<!--#include file="../text/txtFormDataCheck.asp" -->
<!--#include file="../text/txtFormSecurity.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMonth.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/core/incSendMail.asp" -->
<!--#include file="../includes/list/incMonthList.asp" -->
<!--#include file="../includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="../includes/update/incEventSchedule.asp" -->
<!--#include file="../includes/update/incEntryFormGeneral.asp" -->
<!--#include file="../includes/update/incFeedbackFormProcessGeneral.asp" -->
<!--#include file="../includes/validation/incFormDataCheck.asp" -->
<!--#include file="../includes/validation/incVulgarCheck.asp" -->

<script language="python" runat="server">
def get_feedback_msg(culture):
	try:
		return pyrequest.dboptions[culture].FeedbackMsgVOL
	except KeyError:
		return ''

</script>
<%

'On Error Resume Next

Dim strInsertInto, strInsertValue, strUpdateList
Dim strInsSQL, strExtraSQL

Sub getNumNeeded(strFieldDisplay)
	Dim strReturn, strCon
	Dim strVNUM, strNotes, strTotal, bSelected, bSelectedOld, intNumNeeded, intNumNeededOld
	Dim strNewCommunity1, strNewCommunity2, intNewNumNeeded1, intNewNumNeeded2
	Dim bChanged
	
	bChanged = False
	
	If Not bSuggest Then
		strVNUM = rsOrg("VNUM")
	Else
		strVNUM = Null
	End If

	Dim cmdNumNeeded, rsNumNeeded
	Set cmdNumNeeded = Server.CreateObject("ADODB.Command")
	With cmdNumNeeded
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "dbo.sp_VOL_VNUMNumNeeded_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
	End With
	Set rsNumNeeded = cmdNumNeeded.Execute

	With rsNumNeeded
		While Not .EOF
			bSelected = Request("CM_ID_" & .Fields("CM_ID"))="on"
			If bSelected Then
				intNumNeeded = Trim(Request("CM_NUM_NEEDED_" & .Fields("CM_ID")))
			Else
				intNumNeeded = Null
			End If

			intNumNeededOld = .Fields("NUM_NEEDED")
			bSelectedOld = Not Nl(.Fields("OP_CM_ID"))

			If Nl(intNumNeededOld) Then
				If Not Nl(intNumNeeded) Then
					bChanged = True
				End If
			ElseIf CStr(intNumNeededOld) <> intNumNeeded _
					Or Nl(intNumNeeded) _
					Or bSelectedOld <> bSelected Then
				bChanged = True
			End If

			If bSelected Then
				strReturn = strReturn & strCon & .Fields("Community") & TXT_COLON & Nz(intNumNeeded,"--")
				strCon = " ; "
			End If
			.MoveNext
		Wend
	End With
	
	strNewCommunity1 = Trim(Request("NEW_CM_1"))
	strNewCommunity2 = Trim(Request("NEW_CM_2"))
	If Not Nl(strNewCommunity1) Then
		bChanged = True
		strReturn = strReturn & strCon & strNewCommunity1 & TXT_COLON & Nz(Trim(Request("NEW_CM_1_NUM_NEEDED")),"--")
		strCon = " ; "
	End If
	If Not Nl(strNewCommunity2) Then
		bChanged = True
		strReturn = strReturn & strCon & strNewCommunity2 & TXT_COLON & Nz(Trim(Request("NEW_CM_2_NUM_NEEDED")),"--")
		strCon = " ; "
	End If
	
	If bChanged Then
		If addInsertField("NUM_NEEDED",QsNNl(strReturn),strInsertInto,strInsertValue) Then
			Call addEmailField(strFieldDisplay,strReturn)
		End If
	End If

	strNotes = getStrSetValue("NUM_NEEDED_NOTES")
	If addInsertField("NUM_NEEDED_NOTES",QsNNl(strNotes),strInsertInto,strInsertValue) Then
		Call addEmailField(strFieldDisplay & " " & TXT_NOTES,strNotes)
	End If

	strTotal = getStrSetValue("NUM_NEEDED_TOTAL")
	If addInsertField("NUM_NEEDED_TOTAL",QsNNl(strTotal),strInsertInto,strInsertValue) Then
		Call addEmailField(strFieldDisplay & " " & TXT_NOTES,strTotal)
	End If
End Sub

Sub getScheduleGrid(strFieldDisplay)
	Dim strOldValue
	Dim cmdScheduleGrid, rsScheduleGrid
	Set cmdScheduleGrid = Server.CreateObject("ADODB.Command")
	With cmdScheduleGrid
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "cioc_shared.dbo.fn_SHR_VOL_FullSchedule"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@RETURN_VALUE", adVarChar, adParamReturnValue, 8000)
		.Parameters.Append .CreateParameter("@SCH_M_Morning", adBoolean, adParamInput, 1, IIf(Request("SCH_M_Morning")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_M_Afternoon", adBoolean, adParamInput, 1, IIf(Request("SCH_M_Afternoon")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_M_Evening", adBoolean, adParamInput, 1, IIf(Request("SCH_M_Evening")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_M_Time", adVarChar, adParamInput, 50, Nz(Request("SCH_M_Time"),Null))
		.Parameters.Append .CreateParameter("@SCH_TU_Morning", adBoolean, adParamInput, 1, IIf(Request("SCH_TU_Morning")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_TU_Afternoon", adBoolean, adParamInput, 1, IIf(Request("SCH_TU_Afternoon")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_TU_Evening", adBoolean, adParamInput, 1, IIf(Request("SCH_TU_Evening")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_TU_Time", adVarChar, adParamInput, 50, Nz(Request("SCH_TU_Time"),Null))
		.Parameters.Append .CreateParameter("@SCH_W_Morning", adBoolean, adParamInput, 1, IIf(Request("SCH_W_Morning")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_W_Afternoon", adBoolean, adParamInput, 1, IIf(Request("SCH_W_Afternoon")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_W_Evening", adBoolean, adParamInput, 1, IIf(Request("SCH_W_Evening")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_W_Time", adVarChar, adParamInput, 50, Nz(Request("SCH_W_Time"),Null))
		.Parameters.Append .CreateParameter("@SCH_TH_Morning", adBoolean, adParamInput, 1, IIf(Request("SCH_TH_Morning")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_TH_Afternoon", adBoolean, adParamInput, 1, IIf(Request("SCH_TH_Afternoon")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_TH_Evening", adBoolean, adParamInput, 1, IIf(Request("SCH_TH_Evening")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_TH_Time", adVarChar, adParamInput, 50, Nz(Request("SCH_TH_Time"),Null))
		.Parameters.Append .CreateParameter("@SCH_F_Morning", adBoolean, adParamInput, 1, IIf(Request("SCH_F_Morning")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_F_Afternoon", adBoolean, adParamInput, 1, IIf(Request("SCH_F_Afternoon")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_F_Evening", adBoolean, adParamInput, 1, IIf(Request("SCH_F_Evening")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_F_Time", adVarChar, adParamInput, 50, Nz(Request("SCH_F_Time"),Null))
		.Parameters.Append .CreateParameter("@SCH_ST_Morning", adBoolean, adParamInput, 1, IIf(Request("SCH_ST_Morning")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_ST_Afternoon", adBoolean, adParamInput, 1, IIf(Request("SCH_ST_Afternoon")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_ST_Evening", adBoolean, adParamInput, 1, IIf(Request("SCH_ST_Evening")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_ST_Time", adVarChar, adParamInput, 50, Nz(Request("SCH_ST_Time"),Null))
		.Parameters.Append .CreateParameter("@SCH_SN_Morning", adBoolean, adParamInput, 1, IIf(Request("SCH_SN_Morning")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_SN_Afternoon", adBoolean, adParamInput, 1, IIf(Request("SCH_SN_Afternoon")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_SN_Evening", adBoolean, adParamInput, 1, IIf(Request("SCH_SN_Evening")="on",SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@SCH_SN_Time", adVarChar, adParamInput, 50, Nz(Request("SCH_SN_Time"),Null))
		.Parameters.Append .CreateParameter("@SCHEDULE_NOTES", adLongVarChar, adParamInput, -1, Null)
		Set rsScheduleGrid = .Execute
	End With
	Set rsScheduleGrid = rsScheduleGrid.NextRecordset
	strFieldVal = cmdScheduleGrid.Parameters("@RETURN_VALUE").Value
	If Not bSuggest Then
		strOldValue = rsOrg("SCHEDULE_GRID")
		If Not Nl(strOldValue) Then
			If strOldValue = strFieldVal Then
				strFieldVal = Null
			ElseIf Nl(strFieldVal) Then
				strFieldVal = TXT_CONTENT_DELETED
			End If
		End If
	End If
	If addInsertField("SCHEDULE_GRID",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
		Call addEmailField(strFieldDisplay,strFieldVal)
	End If
	Set rsScheduleGrid = Nothing
	Set cmdScheduleGrid = Nothing
End Sub

Sub getAgeFields(strFieldDisplay)
	Dim strFieldVal
	strFieldVal = getStrSetValue("MIN_AGE")
	If addInsertField("MIN_AGE",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
		Call addEmailField(TXT_MIN_AGE,strFieldVal)
	End If
	strFieldVal = getStrSetValue("MAX_AGE")
	If addInsertField("MAX_AGE",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
		Call addEmailField(TXT_MAX_AGE,strFieldVal)
	End If
End Sub
Sub getAccessibilityFields(strFieldDisplay)
	Dim strSP

	If ps_intDbArea = DM_CIC Then
		strSP = "dbo.sp_GBL_NUMAccessibility_s"
		Call getChecklistFeedback(strFieldDisplay, strSP, "AC", "ACCESSIBILITY", "AccessibilityType", strInsertIntoFB, strInsertValueFB, True)
	Else
		strSP = "dbo.sp_VOL_VNUMAccessibility_s"
		Call getChecklistFeedback(strFieldDisplay, strSP, "AC", "ACCESSIBILITY", "AccessibilityType", strInsertInto, strInsertValue, True)
	End If

End Sub

Sub getChecklistFeedback(strFieldDisplay, strSP, strPrefix, strFieldName, strNameField, ByRef strInsertInto, ByRef strInsertValue, bNotes)
	Dim strKey, strNotes, strKeyName, intKeyLength

	If ps_intDbArea = DM_CIC Then
		strKeyName = "NUM"
		intKeyLength = 8
	Else
		strKeyName = "VNUM"
		intKeyLength = 10
	End If

	If Not bSuggest Then
		strKey = rsOrg(strKeyName)
		If bNotes Then
			strNotes = rsOrg(strFieldName & "_NOTES")
		End If
	Else
		strKey = vbNullString
		strNotes = vbNullString
	End If

	Dim strIDList
	strIDList = Replace(Trim(Request(strPrefix & "_ID")), " ", vbNullString)

	Dim cmdChecklist, rsChecklist
	Set cmdChecklist = Server.CreateObject("ADODB.Command")
	With cmdChecklist
		.ActiveConnection = getCurrentBasicCnn()
		.CommandText = strSP
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@" & strKeyName, adVarChar, adParamInput, intKeyLength, strKey)
	End With
	Set rsChecklist = cmdChecklist.Execute
	
	Dim strXML, strEmailText, strEmailCon, bChanged, indID, bChecked, strNote
	bChanged = False
	strEmailCon = vbNullString
	strEmailText = vbNullString
	strXML = vbNullString

	If Nl(strIDList) Or Not IsIDList(strIDList) Then
		strIDList = vbNullString
	Else
		strIDList = "<" & Replace(strIDList, ",", "><") & ">"
	End If

	With rsChecklist
		While Not .EOF
			bChecked = InStr(strIDList, "<" & .Fields(strPrefix & "_ID") & ">") > 0 
			If bChecked Then
				strEmailText = strEmailText & strEmailCon & .Fields(strNameField)
				If bNotes Then
					strNote = Trim(Request(strPrefix & "_NOTES_" & .Fields(strPrefix & "_ID")))
					If Not Nl(strNote) Then
						strEmailText = strEmailText & TXT_COLON & strNote
					End If
					If Ns(strNote) <> Ns(.Fields("Notes")) Then
						bChanged = True
					End If
				End If
				strEmailCon = " ; "
				strXML = strXML & "<" & strPrefix & " ID=" & XMLQs(.Fields(strPrefix & "_ID")) & StringIf(Not Nl(strNote), " NOTE=" & XMLQs(strNote)) & "/>"
					
			End If
			If .Fields("IS_SELECTED") <> IIf(bChecked, 1, 0) Then
				bChanged = True
				If Not bChecked Then
					strEmailText = strEmailText & strEmailCon & .Fields(strNameField) & TXT_COLON & TXT_CONTENT_DELETED
					strEmailCon = " ; "
				End If
			End If
			.MoveNext
		Wend
		.Close
	End With

	If Not Nl(strXML) Then
		strXML = "<" & strPrefix & "S>" & strXML & "</" & strPrefix & "S>"
	End If
	If bNotes Then
		strNote = Trim(Request(strFieldName & "_NOTES"))
		If Not Nl(strNote) Then
			strXML = strXML & "<NOTE>" & XMLEncode(strNote) & "</NOTE>"
			strEmailText = strEmailText & strEmailCon & strNote
		End If
		If Ns(strNote) <> Ns(strNotes) Then
			bChanged = True
			If Nl(strNote) Then
				strEmailText = strEmailText & strEmailCon & TXT_NOTES & TXT_COLON & TXT_CONTENT_DELETED
			End If
		End If
	End If
	strXML = "<" & strFieldName & ">" & strXML & "</" & strFieldName & ">"

	If bChanged Then
		Call addInsertField(strFieldName, QsNl(strXML), strInsertInto,strInsertValue)
	End If
	If Not Nl(strEmailText) Then
		Call addEmailField(strFieldDisplay, strEmailText)
	End If
End Sub

Dim strVNUM, _
	bVNUMError, _
	bSuggest

bVNUMError = False
bSuggest = False

strVNUM = Trim(Request("VNUM"))

If Not Nl(strVNUM) Then
	If Not IsVNUMType(strVNUM) Then
		bVNUMError = True
		Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
		Call handleError(TXT_INVALID_OPID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
		Call makePageFooter(True)
	End If
Else
	strVNUM = Null
	bSuggest = True
End If

If Not user_bLoggedIn And (isVulgar(Request.QueryString) Or isVulgar(Request.Form)) Then
	bVNUMError = True
	Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
	Call handleError(TXT_WARNING & TXT_WARNING_VULGAR, vbNullString, vbNullString)
	Call makePageFooter(True)
End If

If Not bVNUMError Then

Dim indItem, _
	strErrorList

Dim strSourceName, _
	strSourceTitle, _
	strSourceOrg, _
	strSourcePhone, _
	strSourceEmail

strSourceName = Trim(CStr(Request("SOURCE_NAME")))
strSourceTitle = Trim(CStr(Request("SOURCE_TITLE")))
strSourceOrg = Trim(CStr(Request("SOURCE_ORG")))
strSourcePhone = Trim(CStr(Request("SOURCE_PHONE")))
strSourceEmail = Trim(CStr(Request("SOURCE_EMAIL")))

If Not user_bLoggedIn Then

Call checkEmail(TXT_YOUR & TXT_EMAIL, strSourceEmail)

If Nl(strSourceName) Or (Nl(strSourcePhone) And Nl(strSourceEmail)) Or Not Nl(strErrorList) Then
	bVNUMError = True
%>
<%
Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
%>
<h3 class="Alert"><%=TXT_ABOUT_YOU%></h3>
<p><%=TXT_INST_ABOUT_YOU%></p>
<%
If Not Nl(strErrorList) Then
%>
<ul><%=strErrorList%></ul>
<%
End If
%>
<form action="feedback2.asp" method="post">
<%


	For Each indItem In Request.QueryString()
		If (indItem <> "SOURCE_NAME") And (indItem <> "SOURCE_EMAIL") And (indItem <> "SOURCE_PHONE") Then
%>
<input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.QueryString(indItem))%>>
<%
		End If
	Next%>
<%
	For Each indItem In Request.Form()
		If (indItem <> "SOURCE_NAME") And (indItem <> "SOURCE_EMAIL") And (indItem <> "SOURCE_PHONE") Then
%>
<input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.Form(indItem))%>>
<%
		End If
	Next
%>
<table class="BasicBorder cell-padding-3 form-table responsive-table">
<%
	Call printRow("SOURCE_NAME",TXT_YOUR & TXT_NAME, makeTextFieldVal("SOURCE_NAME", strSourceName, 60, False), False,False,False,True,False,False, False)
	Call printRow("SOURCE_EMAIL",TXT_YOUR & TXT_EMAIL, makeTextFieldVal("SOURCE_EMAIL", strSourceEmail, 60, False), False,False,False,True,False,False, False)
	Call printRow("SOURCE_PHONE",TXT_YOUR & TXT_PHONE, makeTextFieldVal("SOURCE_PHONE", strSourcePhone, 60, False), False,False,False,True,False,False, False)
%>
</table>
<p><input type="submit" value="<%=TXT_SUBMIT%>" class="btn btn-default"></p>
</form>
<%
Call makePageFooter(True)
%>
<%
End If

End If

End If

Dim bSecurityCheckOkay
bSecurityCheckOkay = False

If Not bVNUMError Then

	Dim intSCheckDay, _
		intSCheckMonth, _
		intSCheckYear

	intSCheckDay = Trim(Request("sCheckDay"))
	intSCheckMonth = Trim(Request("sCheckMonth"))
	intSCheckYear = Trim(Request("sCheckYear"))
	
	On Error Resume Next
	If Not (Nl(intSCheckDay) Or Nl(intSCheckMonth) Or Nl(intSCheckYear)) Then
		If IsPosSmallInt(intSCheckDay) And IsPosSmallInt(intSCheckMonth) And IsPosSmallInt(intSCheckYear) Then
			If DateSerial(intSCheckYear,intSCheckMonth,intSCheckDay) = DateAdd("d",1,Date()) Then
				If Err.number = 0 Then
					bSecurityCheckOkay = True
				End If
			End If
		End If
	End If
	On Error GoTo 0

	If Not (user_bLoggedIn Or bSecurityCheckOkay) Then
		bVNUMError = True

		Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
%>
<h3 class="Alert"><%=TXT_SECURITY_CHECK%></h3>
<p><span class="AlertBubble"><%=TXT_INST_SECURITY_CHECK_FAIL%></span></p>
<p><%=TXT_INST_SECURITY_CHECK_2%></p>
<form action="feedback2.asp" method="post" class="form-horizontal">

<%
		For Each indItem In Request.QueryString()
			If Not reEquals(indItem,"sCheck.+",False,False,True,False) Then
				%><input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.QueryString(indItem))%>><%
			End If
		Next
		For Each indItem In Request.Form()
			If Not reEquals(indItem,"sCheck.+",False,False,True,False) Then
				%><input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.Form(indItem))%>><%
			End If
		Next
%>
<p><%=TXT_ENTER_TOMORROWS_DATE%></p>
<div class="form-group">
	<label for="sCheckDay" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_DAY%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10">
		<input id="sCheckDay" name="sCheckDay" type="text" size="5" maxlength="8" class="form-control">
	</div>
</div>
<div class="form-group">
	<label for="sCheckMonth" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_MONTH%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10 col-md-11">
		<%Call printMonthList("sCheckMonth")%></label>
	</div>
</div>
<div class="form-group">
	<label for="sCheckYear" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_YEAR%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10 col-md-11">
		<input id="sCheckYear" name="sCheckYear" type="text" size="5" maxlength="8" class="form-control">
	</div>
</div>
<div class="form-group">
	<div class="col-sm-offset-2 col-xs-offset-4 col-sm-10 col-xs-8 col-md-offset-1 col-md-11">
		<input type="submit" value="<%=TXT_SUBMIT%>" class="btn btn-default">
	</div>
</div>
</form>
<%
		Call makePageFooter(True)
	End If
End If

If Not bVNUMError Then

Dim cmdFields, rsFields
Set cmdFields = Server.CreateObject("ADODB.Command")
With cmdFields
	.ActiveConnection = getCurrentVOLBasicCnn()
	.CommandType = adCmdStoredProc
	.CommandText = "dbo.sp_VOL_View_FeedbackFields"
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
	.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
End With
Set rsFields = Server.CreateObject("ADODB.Recordset")
With rsFields
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFields
End With

If Not bSuggest Then
	Dim strSQL, strCon

	strSQL = "SELECT vo.VNUM,vo.FBKEY,vod.POSITION_TITLE,vo.RECORD_OWNER," & vbCrLf & _
		"cioc_shared.dbo.fn_SHR_VOL_FullSchedule(SCH_M_Morning,SCH_M_Afternoon,SCH_M_Evening,SCH_M_Time,SCH_TU_Morning,SCH_TU_Afternoon,SCH_TU_Evening,SCH_TU_Time,SCH_W_Morning,SCH_W_Afternoon,SCH_W_Evening,SCH_W_Time,SCH_TH_Morning,SCH_TH_Afternoon,SCH_TH_Evening,SCH_TH_Time,SCH_F_Morning,SCH_F_Afternoon,SCH_F_Evening,SCH_F_Time,SCH_ST_Morning,SCH_ST_Afternoon,SCH_ST_Evening,SCH_ST_Time,SCH_SN_Morning,SCH_SN_Afternoon,SCH_SN_Evening,SCH_SN_Time,Null) AS SCHEDULE_GRID," & vbCrLf & _
		"bt.NUM, dbo.fn_GBL_DisplayFullOrgName_Agency_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2) AS ORG_NAME_FULL," & vbCrLf & _
		"vod.SOURCE_NAME, vod.SOURCE_TITLE, vod.SOURCE_ORG, vod.SOURCE_PHONE, vod.SOURCE_EMAIL," & vbCrLf & _
		"vo.UPDATE_EMAIL, (SELECT TOP 1 EMAIL FROM GBL_Contact WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) CONTACT_EMAIL_OLD," & vbCrLf & _
		"dbo.fn_VOL_RecordInView(vo.VNUM," & g_intViewTypeVOL & ",vod.LangID,0,GETDATE()) AS IN_VIEW"

	'Does this record have an Equivalent Record
	Dim indCulture, _
		objSysLang

	If g_bMultiLingual Then
		For Each indCulture In Application("Cultures")
			If indCulture <> g_objCurrentLang.Culture Then
				Set objSysLang = create_language_object()
				objSysLang.setSystemLanguage(indCulture)
				If objSysLang.Active Then
					strSQL = strSQL & ",CAST(CASE WHEN EXISTS(SELECT * FROM VOL_Opportunity_Description vod2 WHERE vod2.VNUM=vo.VNUM AND LangID=" & objSysLang.LangID & ") " & _
						"THEN 1 ELSE 0 END AS bit) AS HAS_" & Replace(indCulture,"-","_")
				End If
			End If
		Next
	End If

	With rsFields
		While Not .EOF
			If Not Nl(.Fields("FieldSelect")) And _
					Not reEquals(.Fields("FieldName"), "(POSITION_TITLE)|(SOURCE_*)|(UPDATE_EMAIL)",True,False,True,False) Then
				strSQL = strSQL & "," & vbCrLf & .Fields("FieldSelect")
			End If
			.MoveNext
		Wend
		If Not .RecordCount = 0 Then
			.MoveFirst
		End If
	End With
	
	strSQL = strSQL & vbCrLf & _
		"FROM VOL_Opportunity vo" &  vbCrLf & _
		"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
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
	If rsOrg.EOF Then
		bVNUMError = True
		Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
		Call handleError(TXT_NO_RECORD_EXISTS_VNUM & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
		Call makePageFooter(True)
	End If
End If

End If

If Not bVNUMError Then

Dim dicExtraFb, tmpExtraItem
Set dicExtraFb = Server.CreateObject("Scripting.Dictionary")

Dim strFBKey

strInsertInto = "MemberID,LangID,SUBMIT_DATE,IPAddress,FEEDBACK_OWNER"
strInsertValue = g_intMemberID & "," & g_objCurrentLang.LangID & _
		"," & QsN(DateString(Date(),False) & " " & Time()) & _
		"," & QsN(getRemoteIP()) & _
		"," & QsNl(StringIf(Not Nl(g_strAssignSuggestionsToVOL) And bSuggest,g_strAssignSuggestionsToVOL))

If Not bSuggest Then
	strFBKey = Left(Trim(Request("Key")),6)
	If Not Nl(strFBKey) Then
		strInsertInto = strInsertInto & ",FBKEY"
		strInsertValue = strInsertValue & "," & QsNl(strFbKey)
	End If
	Call addInsertField("VNUM",QsNNl(strVNUM),strInsertInto,strInsertValue)
	Select Case Request("FType")
		Case "F"
			Call addInsertField("FULL_UPDATE",SQL_TRUE,strInsertInto,strInsertValue)
			strFieldVal = Replace(Replace(TXT_COMPLETE_UPDATE, "<strong>", ""), "</strong>", "")
		Case "N"
			Call addInsertField("FULL_UPDATE",SQL_TRUE,strInsertInto,strInsertValue)
			Call addInsertField("NO_CHANGES",SQL_TRUE,strInsertInto,strInsertValue)
			strFieldVal = Replace(Replace(TXT_COMPLETE_NO_CHANGES_REQUIRED, "<strong>", ""), "</strong>", "")
		Case "D"
			Call addInsertField("REMOVE_RECORD",SQL_TRUE,strInsertInto,strInsertValue)
			strFieldVal = Replace(Replace(TXT_REMOVE_RECORD, "<strong>", ""), "</strong>", "")
		Case "P"
			strFieldVal = Replace(Replace(TXT_NOT_COMPLETE_UPDATE, "<strong>", ""), "</strong>", "")
	End Select
	Call addEmailField(TXT_ABOUT_CHANGES, strFieldVal)
	Call getROInfo(rsOrg("RECORD_OWNER"),DM_VOL)
End If

If user_bLoggedIn Then
	Call addInsertField("User_ID",user_intID,strInsertInto,strInsertValue)
End If

Dim intVOLVw
intVOLVw = Request("UseVOLVw")
If Not IsIDType(intVOLVw) Then
	intVOLVw = Null
End If
If Not Nl(intVOLVw) Then
	Call addInsertField("ViewType",intVOLVw,strInsertInto,strInsertValue)
End If

Dim strAccessURL
strAccessURL = Request.ServerVariables("HTTP_HOST")

If strAccessURL <> g_strBaseURLVOL Then
	Call addInsertField("AccessURL",QsNNl(strAccessURL),strInsertInto,strInsertValue)
End If

Dim strFbNotes
strFbNotes = Trim(Request("FB_NOTES"))
If Not Nl(strFBNotes) Then
	Call addInsertField("FB_NOTES",QsNNl(strFbNotes),strInsertInto,strInsertValue)
End If
If user_bLoggedIn Then
	Call addInsertField("SOURCE_NAME",QsNNl(getStrSetValue("SOURCE_NAME")),strInsertInto,strInsertValue)
	Call addInsertField("SOURCE_TITLE",QsNNl(getStrSetValue("SOURCE_TITLE")),strInsertInto,strInsertValue)
	Call addInsertField("SOURCE_ORG",QsNNl(getStrSetValue("SOURCE_ORG")),strInsertInto,strInsertValue)
	Call addInsertField("SOURCE_PHONE",QsNNl(getStrSetValue("SOURCE_PHONE")),strInsertInto,strInsertValue)
	Call addInsertField("SOURCE_EMAIL",QsNNl(getStrSetValue("SOURCE_EMAIL")),strInsertInto,strInsertValue)
Else
	Call addInsertField("SOURCE_NAME",QsNNl(strSourceName),strInsertInto,strInsertValue)
	Call addInsertField("SOURCE_TITLE",QsNNl(strSourceTitle),strInsertInto,strInsertValue)
	Call addInsertField("SOURCE_ORG",QsNNl(strSourceOrg),strInsertInto,strInsertValue)
	Call addInsertField("SOURCE_PHONE",QsNNl(strSourcePhone),strInsertInto,strInsertValue)
	Call addInsertField("SOURCE_EMAIL",QsNNl(strSourceEmail),strInsertInto,strInsertValue)
End If

If bSuggest Then
	Dim strNUM
	strNUM = Request("NUM")
	If Not Nl(strNUM) Then
		Call addInsertField("NUM",QsNNl(strNUM),strInsertInto,strInsertValue)
	Else
		Call addInsertField("ORG_NAME",QsNNl(getStrSetValue("ORG_NAME")),strInsertInto,strInsertValue)
	End If
End If

Dim strOldEmail, _
	strNewEmail

If Not bSuggest Then
	strOldEmail = Nz(rsOrg("UPDATE_EMAIL"),rsOrg("CONTACT_EMAIL_OLD"))
Else
	strOldEmail = vbNullString
End If

Dim strFieldName, _
	strFieldVal, _
	strFieldValDisplay

While Not rsFields.EOF
	strFieldName = rsFields.Fields("FieldName")
	Select Case strFieldName
		Case "ACCESSIBILITY"
			Call getAccessibilityFields(rsFields.Fields("FieldDisplay"))
		Case "AGES"
			Call getAgeFields(rsFields.Fields("FieldDisplay"))
		Case "CONTACT"
			Call getContactFields(strFieldName, rsFields.Fields("FieldDisplay"),strInsertInto,strInsertValue)
		Case "COMMITMENT_LENGTH"
			Call getChecklistFeedback(strFieldName, "dbo.sp_VOL_VNUMCommitmentLength_s", "CL", "COMMITMENT_LENGTH", "CommitmentLength", strInsertInto, strInsertValue, True)
		Case "EVENT_SCHEDULE"
			Call getEventScheduleFields(rsFields.Fields("FieldDisplay"))
		Case "INTERACTION_LEVEL"
			Call getChecklistFeedback(strFieldName, "dbo.sp_VOL_VNUMInteractionLevel_s", "IL", "INTERACTION_LEVEL", "InteractionLevel", strInsertInto, strInsertValue, True)
		Case "MINIMUM_HOURS"
			strFieldVal = getStrSetValue("MINIMUM_HOURS")
			If addInsertField("MINIMUM_HOURS",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
				Call addEmailField(rsFields.Fields("FieldDisplay") & " " & TXT_VOL_HOURS,strFieldVal)
			End If
			strFieldVal = getStrSetValue("MINIMUM_HOURS_PER")
			strFieldValDisplay = getDropDownValue(strFieldVal,"dbo.fn_VOL_DisplayMinHoursPer",True,Null)
			If addInsertField("MINIMUM_HOURS_PER",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
				Call addEmailField(TXT_VOL_HOURS_PER & " " & rsFields.Fields("FieldDisplay"),strFieldValDisplay)
			End If
		Case "NUM_NEEDED"
			Call getNumNeeded(rsFields.Fields("FieldDisplay"))
		Case "SCHEDULE"
			Call getScheduleGrid(rsFields.Fields("FieldDisplay"))
			strFieldVal = getStrSetValue("SCHEDULE_NOTES")
			If addInsertField("SCHEDULE_NOTES",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
				Call addEmailField(TXT_VOL_SCHEDULE_NOTES,strFieldVal)
			End If
		Case "SOCIAL_MEDIA"
			Call getSocialMediaField(strFieldName, strInsertInto, strInsertValue)
		Case "START_DATE"
			strFieldVal = getDateSetValue("START_DATE_FIRST")
			If addInsertField("START_DATE_FIRST",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
				Call addEmailField(rsFields.Fields("FieldDisplay") & " " & TXT_VOL_ON_OR_AFTER,strFieldVal)
			End If
			strFieldVal = getDateSetValue("START_DATE_LAST")
			If addInsertField("START_DATE_LAST",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
				Call addEmailField(rsFields.Fields("FieldDisplay") & " " & TXT_VOL_ON_OR_BEFORE,strFieldVal)
			End If
		Case "SEASONS"
			Call getChecklistFeedback(strFieldVal, "dbo.sp_VOL_VNUMSeasons_s", "SSN", "SEASONS", "Season", strInsertInto, strInsertValue, True)
		Case "SKILLS"
			Call getChecklistFeedback(strFieldVal, "dbo.sp_VOL_VNUMSkill_s", "SK", "SKILLS", "Skill", strInsertInto, strInsertValue, True)
		Case "SUITABILITY"
			Call getChecklistFeedback(strFieldVal, "dbo.sp_VOL_VNUMSuitability_s", "SB", "SUITABILITY", "SuitableFor", strInsertInto, strInsertValue, False)
		Case "TRAINING"
			Call getChecklistFeedback(strFieldVal, "dbo.sp_VOL_VNUMTraining_s", "TRN", "TRAINING", "TrainingType", strInsertInto, strInsertValue, True)
		Case "TRANSPORTATION"
			Call getChecklistFeedback(strFieldVal, "dbo.sp_VOL_VNUMTransportation_s", "TRP", "TRANSPORTATION", "TransportationType", strInsertInto, strInsertValue, True)
		Case Else
			If rsFields.Fields("ExtraFieldType") = "l" Then
				strFieldVal = getBasicListSetValue(strFieldName,"#","#")
			ElseIf rsFields.Fields("ExtraFieldType") = "p" Then
				strFieldVal = getStrSetValue(strFieldName)
				strFieldValDisplay = getDropDownValue(strFieldVal,"dbo.fn_VOL_DisplayExtraDropDown",True,strFieldName)
			ElseIf rsFields.Fields("FormFieldType") = "c" Then
				strFieldVal = getCbSetValue(strFieldName, rsFields.Fields("CheckboxOnText"), rsFields.Fields("CheckboxOffText"))				
			ElseIf rsFields.Fields("FormFieldType") = "d" Then
				strFieldVal = getDateSetValue(strFieldName)
			Else
				strFieldVal = getStrSetValue(strFieldName)
			End If
			If reEquals(rsFields.Fields("ExtraFieldType"),"a|d|e|l|p|r|t|w",False,False,True,False) Then
				If Not Nl(strFieldVal) Then
					dicExtraFb.Add strFieldName, strFieldVal
					Call addEmailField(rsFields.Fields("FieldDisplay"),Nz(strFieldValDisplay,strFieldVal))
				End If									
			Else
				If addInsertField(strFieldName,QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
					Call addEmailField(rsFields.Fields("FieldDisplay"),strFieldVal)
				End If
			End If
			If Not bSuggest Then
				If strFieldName = "UPDATE_EMAIL" Then
					If Not Nl(Trim(Request("UPDATE_EMAIL"))) Then
						strNewEmail = Trim(Request("UPDATE_EMAIL"))
						If strNewEmail = strOldEmail Then
							strNewEmail = vbNullString
						End If
					ElseIf Not Nl(rsOrg("UPDATE_EMAIL")) Then
						If Not Nl(Trim(Request("CONTACT_EMAIL"))) Then
							strNewEmail = Trim(Request("CONTACT_EMAIL"))
						Else
							strNewEmail = TXT_DELETED
						End If
					End If
				End If
				If strFieldName = "CONTACT" And Nl(strNewEmail) And Nl(rsOrg("UPDATE_EMAIL")) Then
					If Not Nl(Trim(Request("CONTACT_EMAIL"))) Then
						strNewEmail = Trim(Request("CONTACT_EMAIL"))
						If strNewEmail = strOldEmail Then
							strNewEmail = vbNullString
						End If
					ElseIf Not Nl(rsOrg("CONTACT_EMAIL")) Then
						strNewEmail = TXT_DELETED
					End If
				End If
			End If
	End Select
	rsFields.MoveNext
Wend

strExtraSQL = vbNullString
Dim aTmp, iTmp
aTmp = dicExtraFb.Keys
For Each iTmp In aTmp
	If Not Nl(iTmp) Then
		strExtraSQL = strExtraSQL & vbCrLf & _
			"IF EXISTS(SELECT * FROM VOL_FieldOption fo WHERE fo.ExtraFieldType IN ('a','d','e','l','p','r','t','w') AND fo.FieldName=" & QsNl(iTmp) & ") BEGIN " & _
			"INSERT INTO VOL_Feedback_Extra" & " " & _
				"(FB_ID,FieldName,[Value]) " & _
			"VALUES (@FB_ID," & _
				QsNl(iTmp) & "," & _
				QsNl(dicExtraFb(iTmp)) & _
			") END"
	End If
Next

strInsSQL = "DECLARE @FB_ID int; INSERT INTO VOL_Feedback (" & strInsertInto & ") VALUES (" & strInsertValue & ") ; SET @FB_ID=SCOPE_IDENTITY() "

If Not Nl(strExtraSQL) Then
	strInsSQL = strInsSQL & vbCrLf & strExtraSQL & vbCrLf
End If

'Response.Write("<pre>" & Server.HTMLEncode(strInsSQL) & "</pre>")
'Response.Flush()

Dim cmdInsertFb, bFbSQLError, strFbSQLError, strErrorDetails, objErr
Set cmdInsertFb = Server.CreateObject("ADODB.Command")
With cmdInsertFb
	.ActiveConnection = getCurrentVOLBasicCnn()
	.CommandType = adCmdText
	.CommandText = strInsSQL
	On Error Resume Next
	.Execute
	If Err.Number <> 0 Or .ActiveConnection.Errors.Count > 0 Then
		bFbSQLError = True
		strFbSQLError = TXT_UNKNOWN_ERROR_OCCURED
		strInsSQLError = Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED)
		strErrorDetails =  Ns(user_strMod) & vbCrLf & Ns(user_strAgency) & vbCrLf & Ns(g_strMemberName) & _
							vbCrLf & g_intMemberID & vbCrLf & g_strApplicationInstance & vbCrLf & _
							Ns(Err.Number) & vbCrLf & Hex(IIf(Nl(Err.Number), 0, Err.Number)) & vbCrLf & _
							Ns(Err.Source) & vbCrLf &  Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED) & vbCrLf
		For Each objErr in .ActiveConnection.Errors
			strErrorDetails = strErrorDetails & "Description: " & Ns(objErr.Description) & vbCrLf & _
							"Help context: " & Ns(objErr.HelpContext) & vbCrLf & _
							"Help file: "  & Ns(objErr.HelpFile) & vbCrLf & _
							"Native error: " & Ns(objErr.NativeError) & vbCrLf & _
							"Error number: " & Ns(objErr.Number) & vbCrLf & _
							"Error source: " & Ns(objErr.Source) & vbCrLf & _
							"SQL state: " & Ns(objErr.SQLState) & vbCrLf
		Next

		Call sendEmail(True, "qw4afPcItA5KJ18NH4nV@cioc.ca", "qw4afPcItA5KJ18NH4nV@cioc.ca", "Entryform SQL Error", strErrorDetails & strInsSQL)
	End if
	On Error Goto 0
End With

If Err.Number = 0 And Not bFbSQLError Then
	If bSuggest Then
		Call makePageHeader(TXT_SUGGEST_NEW_RECORD, TXT_SUGGEST_NEW_RECORD, True, False, True, True)
	Else
		If Not g_bNoEmail Then
			Call sendNotifyEmails(strVNUM, rsOrg.Fields("POSITION_TITLE") & " (" & rsOrg.Fields("ORG_NAME_FULL") & ")",strOldEmail,strNewEmail,rsOrg("IN_VIEW"),IIf(get_db_option("DomainDefaultViewSSLCompatibleVOL"), "https://", "http://") & strAccessURL,intVOLVw,strFbKey,rsOrg("FBKEY"))
		End If
		If Not rsOrg("IN_VIEW") Then
			Call makePageHeader(TXT_THANKS_FOR_FEEDBACK, TXT_THANKS_FOR_FEEDBACK, True, False, True, True)
			bSuggest = True
		End If
	End If

	Dim strFeedbackMsg
	strFeedbackMsg = get_feedback_msg(g_objCurrentLang.Culture)
	'If Nl(strFeedbackMsg) And strRestoreCulture <> g_objCurrentLang.Culture Then
	'	strFeedbackMsg = get_feedback_msg(strRestoreCulture)
	'End If

	Dim strOtherLangList
	strOtherLangList = vbNullString

	If Not bSuggest And g_bMultiLingual Then
		For Each indCulture In Application("Cultures")
			If indCulture <> g_objCurrentLang.Culture Then
				Set objSysLang = create_language_object()
				objSysLang.setSystemLanguage(indCulture)
				If objSysLang.Active Then
					If rsOrg("HAS_" & Replace(indCulture,"-","_")) Then
						strOtherLangList = strOtherLangList & "<li>" & _
						"<a href=""" & makeLink("feedback.asp","VNUM=" & strVNUM & "&Ln=" & indCulture,vbNullString) & """>" & TXT_SUGGEST_UPDATE & " - <strong>" & objSysLang.LanguageName & "</strong></a>" & _
						"</li>"
					End If
				End If
			End If
		Next
	End If
	
	If Not bSuggest Then
		Call handleVOLDetailsMessage(strFeedbackMsg & _
			StringIf(Not Nl(strOtherLangList),"<p class=""Alert"">" & TXT_EDIT_EQUIVALENT & "<ul>" & strOtherLangList & "</ul></p>"), _
			strVNUM, _
			vbNullString, _
			False)
	Else
%>
<p class="Info"><%= strFeedbackMsg %></p>
<%
	End If
	
	If bSuggest Then
		Call makePageFooter(True)
	End If
Else
	Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
	Call handleError(TXT_UNABLE_SAVE_FEEDBACK & strFbSQLError, vbNullString, vbNullString)
	Call makePageFooter(True)
End If

End If
%>

<!--#include file="../includes/core/incClose.asp" -->
