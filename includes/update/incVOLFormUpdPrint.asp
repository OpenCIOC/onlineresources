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
Function getNewVNum()
	Dim cmdNewVNUM, rsNewVNUM
	Set cmdNewVNUM = Server.CreateObject("ADODB.Command")
	With cmdNewVNUM
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.fn_VOL_LowestUnusedVNUM"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@RETURN_VALUE", adVarChar, adParamReturnValue, 10)
		.Parameters.Append .CreateParameter("@Agency", adChar, adParamInput, 3, user_strAgency)
		Set rsNewVNUM = .Execute
	End With
	Set rsNewVNUM = rsNewVNUM.NextRecordset
	If Not Nl(cmdNewVNUM.Parameters("@RETURN_VALUE").Value) Then
		getNewVNUM = cmdNewVNUM.Parameters("@RETURN_VALUE").Value
	End If
	Set rsNewVNUM = Nothing
	Set cmdNewVNUM = Nothing
End Function

Function makeAccessibilityContents(rst,bUseContent)
	makeAccessibilityContents = makeStdChecklistContents(rst, bUseContent, "dbo.sp_VOL_VNUMAccessibility_s", "AC", "ACCESSIBILITY", "AccessibilityType", True, True)
End Function

Function makeAgesContents(rst, bUseContent)
	Dim strReturn
	Dim decMinAge, decMaxAge
	
	If bUseContent Then
		decMinAge = rst("MIN_AGE")
		decMaxAge = rst("MAX_AGE")
	End If
	
	strReturn = _
		"<div class=""form-group"">" & _
			"<label for=""MIN_AGE"" class=""control-label col-xs-3 col-lg-2"">" & TXT_MIN_AGE & "</label>" & _
			"<div class=""col-xs-9 col-lg-10 form-inline"">" & _
				"<input type=""text"" name=""MIN_AGE"" id=""MIN_AGE"" size=""5"" maxlength=""5"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(decMinAge) & "> (" & TXT_IN_YEARS & ")"
	If bFeedback Then
		strReturn = strReturn & getFeedback("MIN_AGE",True,False)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""MAX_AGE"" class=""control-label col-xs-3 col-lg-2"">" & TXT_MAX_AGE & "</label>" & _
			"<div class=""col-xs-9 col-lg-10 form-inline"">" & _
				"<input type=""text"" name=""MAX_AGE"" id=""MAX_AGE"" size=""5"" maxlength=""5"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(decMaxAge) & "> (" & TXT_IN_YEARS & ")"
	If bFeedback Then
		strReturn = strReturn & getFeedback("MAX_AGE",True,False)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>"

	makeAgesContents = strReturn
End Function

Function makeCommitmentLengthContents(rst,bUseContent)
	makeCommitmentLengthContents = makeStdChecklistContents(rst, bUseContent, "dbo.sp_VOL_VNUMCommitmentLength_s", "CL", "COMMITMENT_LENGTH", "CommitmentLength", True, True)
End Function

Function makeInteractionLevelContents(rst,bUseContent)
	makeInteractionLevelContents = makeStdChecklistContents(rst, bUseContent, "dbo.sp_VOL_VNUMInteractionLevel_s", "IL", "INTERACTION_LEVEL", "InteractionLevel", True, True)
End Function

Dim bInterests
bInterests = False
Function makeInterestsContents(rst,bUseContent)
	bHasDynamicAddField = True
	bInterests = True
	
	Dim strReturn
	Dim strVNUM
	If bUseContent Then
		strVNUM = rst("VNUM")
	Else
		strVNUM = Null
	End If
	
	Dim cnnInterests, cmdInterests, rsInterests
	Call makeNewAdminConnection(cnnInterests)
	Set cmdInterests = Server.CreateObject("ADODB.Command")
	With cmdInterests
		.ActiveConnection = cnnInterests
		.CommandText = "dbo.sp_VOL_VNUMInterest_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsInterests = cmdInterests.Execute
	
	With rsInterests
		strReturn = strReturn & "<div id=""AI_existing_add_container"">"
		While Not .EOF
			strReturn = strReturn & "<input name=""AI_ID"" id=""AI_ID_" & .Fields("AI_ID") & """ type=""checkbox"" value=""" & .Fields("AI_ID") & """ checked>&nbsp;<label for=""AI_ID_" & .Fields("AI_ID") & """>" & .Fields("InterestName") & "</label> ; "
			.MoveNext
		Wend
		strReturn = strReturn & "</div>"
	End With
	
	rsInterests.Close
	Set rsInterests = Nothing
	Set cmdInterests = Nothing

	strReturn = strReturn & vbCrLf & _
		"<h4>" & TXT_ADD_INTERESTS & "</h4><p id=""AI_new_input_table"">"

	If Not g_bOnlySpecificInterests Then
		strReturn = strReturn & "<strong><label for=""NEW_AI"">" & TXT_FIND_BY_KEYWORD & "</label></strong>" & vbCrLf & "<br>"
	End If
		
	strReturn = strReturn & TXT_NOT_SURE_ENTER & "<a href=""javascript:openWinL('" & makeLink("interestfind.asp","Ln=" & g_objCurrentLang.Culture,"Ln") & "','aiFind')"">" & TXT_AREA_OF_INTEREST_FINDER & "</a>." & vbCrLf & _
		"<br><input type=""text"" id=""NEW_AI"" size=""" & TEXT_SIZE & """ maxlength=""200"">" & _
		"&nbsp;<button type=""button"" class=""ui-state-default ui-corner-all"" id=""add_AI"">" & TXT_ADD & "</button></p>"
			
	If Not g_bOnlySpecificInterests Then
		strReturn = strReturn & _
			"<p><strong><label for=""InterestGroup"">" & TXT_FIND_BY_GENERAL_INTEREST & "</label></strong>" & vbCrLf & _
			"<br>"
		Call openInterestGroupListRst()
		strReturn = strReturn & makeInterestGroupList(vbNullString, "InterestGroup", True)
		Call closeInterestGroupListRst()

		strReturn = strReturn & "</p>"
	End If

	If bFeedback Then
		strReturn = strReturn & getFeedback("INTERESTS",False,False)
	End If
	makeInterestsContents = strReturn
End Function

Function makeMinHoursContents(rst, bUseContent)
	Dim strReturn
	Dim intMinHours, strMinHoursPer
	
	If bUseContent Then
		intMinHours = rst("MINIMUM_HOURS")
		strMinHoursPer = rst("MINIMUM_HOURS_PER")
	End If
	
	strReturn = "<table class=""NoBorder cell-padding-2"">" & _
			"<tr><td class=""FieldLabelLeftClr""><label for=""MINIMUM_HOURS"">" & TXT_MIN_HOURS & "</label></td><td>" & _
			"<input type=""text"" id=""MINIMUM_HOURS"" name=""MINIMUM_HOURS""" & _
			" size=""5"" maxlength=""5"" value=""" & intMinHours & """>"
	If bFeedback Then
		strReturn = strReturn & getFeedback("MINIMUM_HOURS",True,False)
	End If

	Call openMinHoursPerListRst()

	strReturn = strReturn & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr""><label for=""MINIMUM_HOURS_PER"">" & TXT_MIN_HOURS_PER & "</label></td><td>" & _
			makeMinHoursPerList(strMinHoursPer,"MINIMUM_HOURS_PER",True)
	If bFeedback Then
		strReturn = strReturn & getFeedback("MINIMUM_HOURS_PER",True,False)
	End If
	strReturn = strReturn & "</td></tr>" & _
			"</table>"

	Call closeMinHoursPerListRst()

	makeMinHoursContents = strReturn
End Function

Dim bNumNeeded
bNumNeeded = False

Function makeNumNeededContents(rst,bUseContent)
	bHasDynamicAddField = True
	bNumNeeded = True

	Dim strReturn
	Dim strVNUM, _
		intNumNeededTotal, _
		strNotes, _
		intNotesLen

	If bUseContent Then
		With rst
			strVNUM = .Fields("VNUM")
			intNumNeededTotal = .Fields("NUM_NEEDED_TOTAL")
			strNotes = .Fields("NUM_NEEDED_NOTES")
		End With
	Else
		strVNUM = Null
	End If

	Dim cnnNumNeeded, cmdNumNeeded, rsNumNeeded
	Call makeNewAdminConnection(cnnNumNeeded)
	Set cmdNumNeeded = Server.CreateObject("ADODB.Command")
	With cmdNumNeeded
		.ActiveConnection = cnnNumNeeded
		.CommandText = "dbo.sp_VOL_VNUMNumNeeded_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
	End With
	Set rsNumNeeded = cmdNumNeeded.Execute
	
	strReturn = "<span class=""FieldLabelLeftClr""><label for=""NUM_NEEDED_TOTAL"">" & TXT_NUM_POSITIONS & " (" & TXT_TOTAL & ")</label></span> " & _
		"<input type=""text"" name=""NUM_NEEDED_TOTAL"" id=""NUM_NEEDED_TOTAL"" size=""5"" maxlength=""4"" value=""" & intNumNeededTotal & """>"
		
	If bFeedback Then
		strReturn = strReturn & getFeedback("NUM_NEEDED_TOTAL",True,False)
	End If

	strReturn = strReturn & vbCrLf & _
		"<br>&nbsp;<table id=""CM_existing_add_table"" class=""BasicBorder cell-padding-2"">" & _
		"<tr><th class=""RevTitleBox"">&nbsp;</th><th class=""RevTitleBox"">" & TXT_COMMUNITY & "</th><th class=""RevTitleBox"">" & TXT_NUM_POSITIONS & "</th></tr>"

	With rsNumNeeded
		If Not .EOF Then
			While Not .EOF
				strReturn = strReturn & "<tr>" & _
					"<td><input type=""checkbox"" id=""CM_ID_" & .Fields("CM_ID") & """ name=""CM_ID"" value=" & AttrQs(.Fields("CM_ID")) & Checked(Not Nl(.Fields("OP_CM_ID"))) & "></td>" & _
					"<td class=""FieldLabelLeftClr""><label for=""CM_ID_" & .Fields("CM_ID") & """>" & .Fields("Community") & "</label></td>" & _
					"<td align=""center""><input type=""text"" title=" & AttrQs(.Fields("Community") & TXT_COLON & TXT_NUM_POSITIONS) & " name=""CM_NUM_NEEDED_" & .Fields("CM_ID") & """" & _
					" size=""3"" maxlength=""3"" value=" & AttrQs(.Fields("NUM_NEEDED")) & "></td></tr>"
				.MoveNext
			Wend
		End If
	End With

	strReturn = strReturn & "</table>" & _
		"<h4>" & TXT_ADD_COMMUNITIES & "</h4>" & _
		"<p>" & TXT_NOT_SURE_ENTER & "<a href=""javascript:openWin('" & makeLinkB(ps_strPathToStart & "comfind.asp") & "','cFind')"">" & TXT_COMMUNITY_FINDER & "</a>.</p>" & _
		"<table id=""CM_new_input_table"" class=""NoBorder cell-padding-2"">"

	strReturn = strReturn & "<tr>" & _
			"<td class=""FieldLabelClr""><label for=""NEW_CM"">" & TXT_NAME & "</label></td>" & _
			"<td><input type=""text"" id=""NEW_CM"" " & _
			"size=""" & TEXT_SIZE & """ maxlength=""100""></td>" & _
			"<td><button type=""button"" class=""ui-state-default ui-corner-all"" id=""add_CM"">" & TXT_ADD & "</button></td>" & _
			"</tr>"
	strReturn = strReturn & "</table>"

	If bFeedback Then
		strReturn = strReturn & getFeedback("NUM_NEEDED",False,False)
	End If

	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If

	strReturn = strReturn & vbCrLf & _
			"<div class=""FieldLabelLeftClr""><label for=""NUM_NEEDED_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea id=""NUM_NEEDED_NOTES"" name=""NUM_NEEDED_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			">" & strNotes & "</textarea>"

	If bFeedback Then
		strReturn = strReturn & getFeedback("NUM_NEEDED_NOTES",True,False)
	End If
	makeNumNeededContents = strReturn
End Function

Function makeNUMContents(strNUM, rsOrg, bUseData)
	Dim strReturn
	strReturn = vbNullString

	If bUseData Then
		If Not Nl(rsOrg.Fields("CIC_DELETION_DATE")) Then
			If rsOrg.Fields("CIC_DELETION_DATE") > Now() Then
				strReturn = TXT_RECORD_SCHEDULED_TO_BE_DELETED & DateString(rsOrg.Fields("CIC_DELETION_DATE"), True)
			Else
				strReturn = Replace(TXT_RECORD_DELETED,"[NUM]",strNUM)
			End If
		ElseIf rsOrg.Fields("CIC_NON_PUBLIC") Then
			strReturn = Replace(TXT_RECORD_NON_PUBLIC,"[NUM]",strNUM)
		End If
		
		If Not Nl(strReturn) Then
			strReturn = "<span class=""Alert"">" & strReturn & "</span><br>"
		End If
		
	End if
	
	strReturn = strReturn & "<input type=""text"" id=""NUM"" title=" & AttrQs(TXT_RECORD_NUM) & " name=""NUM"" size=""20"" maxlength=""20""" & _
		IIf(Not Nl(strNUM),"value=" & AttrQs(strNUM),vbNullString) & "> " & _
		TXT_INST_NUM_FINDER	
	If bFeedback Then
		strReturn = strReturn & getFeedback("NUM", True,False)
		strReturn = strReturn & getFeedback("ORG_NAME", False,False)
	End If
	makeNUMContents = strReturn
End Function

Function makeScheduleContents(rst,bUseContent)
	Dim strReturn
	Dim strNotes, intNotesLen
	Dim aShorts, aLongs
	aShorts = Array("M","TU","W","TH","F","ST","SN")
	aLongs = Array(TXT_DAY_MONDAY,TXT_DAY_TUESDAY,TXT_DAY_WEDNESDAY,TXT_DAY_THURSDAY,TXT_DAY_FRIDAY,TXT_DAY_SATURDAY,TXT_DAY_SUNDAY)
	Dim i

	If bUseContent Then
		strNotes = rsOrg("SCHEDULE_NOTES")
	End If

	strReturn = "<table class=""NoBorder cell-padding-2"">" & _
		"<tr class=""FieldLabelCenterClr""><td>&nbsp;</td><td>" & TXT_TIME_MORNING & "<br>" & TXT_TIME_BEFORE_12 & "</td><td>" & TXT_TIME_AFTERNOON & "<br>" & TXT_TIME_12_6 & "</td><td>" & TXT_TIME_EVENING & "<br>" & TXT_TIME_AFTER_6 & "</td><td>" & TXT_TIME_SPECIFIC & "</td></tr>"
	For i = 0 to 6
		strReturn = strReturn & "<tr>" & _
			"<td class=""FieldLabelClr"">" & aLongs(i) & "</td>" & _
			"<td ALIGN=""CENTER""><input title=" & AttrQs(aLongs(i) & TXT_COLON & TXT_TIME_MORNING) & " name=""SCH_" & aShorts(i) & "_Morning"" TYPE=""checkbox"" "
			If bUseContent Then
				If rst("SCH_" & aShorts(i) & "_Morning") Then
					strReturn = strReturn & " checked"
				End If
			End If
		strReturn = strReturn & "></td>" & _
			"<td ALIGN=""CENTER""><input title=" & AttrQs(aLongs(i) & TXT_COLON & TXT_TIME_AFTERNOON) & " name=""SCH_" & aShorts(i) & "_Afternoon"" TYPE=""checkbox"" "
			If bUseContent Then
				If rst("SCH_" & aShorts(i) & "_Afternoon") Then
					strReturn = strReturn & " checked"
				End If
			End If
		strReturn = strReturn & "></td>" & _
			"<td ALIGN=""CENTER""><input title=" & AttrQs(aLongs(i) & TXT_COLON & TXT_TIME_EVENING) & " name=""SCH_" & aShorts(i) & "_Evening"" TYPE=""checkbox"" "
			If bUseContent Then
				If rst("SCH_" & aShorts(i) & "_Evening") Then
					strReturn = strReturn & " checked"
				End If
			End If
		strReturn = strReturn & "></td>" & _
			"<td><input title=" & AttrQs(aLongs(i) & TXT_COLON & TXT_TITLE_SPECIFIC) & " name=""SCH_" & aShorts(i) & "_Time"" TYPE=""text"" size=""25"" maxlength=""50"" "
			If bUseContent Then
				strReturn = strReturn & " value=" & AttrQs(rst("SCH_" & aShorts(i) & "_Time"))
			End If
		strReturn = strReturn & "></td>" & _
			"</tr>"
	Next
	strReturn = strReturn & "</table>"

	If bFeedback Then
		strReturn = strReturn & getFeedback("SCHEDULE_GRID",False,False)
	End If

	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<h4><label for=""SCHEDULE_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & _
			"<textarea id=""SCHEDULE_NOTES"" name=""SCHEDULE_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			">" & strNotes & "</textarea>"

	If bFeedback Then
		strReturn = strReturn & getFeedback("SCHEDULE_NOTES",True,False)
	End If

	makeScheduleContents = strReturn
End Function

Function makeSeasonsContents(rst,bUseContent)
	makeSeasonsContents = makeStdChecklistContents(rst, bUseContent, "dbo.sp_VOL_VNUMSeasons_s", "SSN", "SEASONS", "Season", True, True)
End Function

Function makeSkillContents(rst,bUseContent)
	makeSkillContents = makeStdChecklistContents(rst, bUseContent, "dbo.sp_VOL_VNUMSkill_s", "SK", "SKILLS", "Skill", True, True)
End Function

Function makeSourceContents(rst,bUseContent)
	Dim strReturn
	Dim strPub,dPub,strName,strTitle,strOrg,strPhone,strFax,strEmail
	
	If bUseContent Then
		strPub = rst("SOURCE_PUBLICATION")
		dPub = rst("SOURCE_PUBLICATION_DATE")
		strName = rst("SOURCE_NAME")
		strTitle = rst("SOURCE_Title")
		strOrg = rst("SOURCE_ORG")
		strPhone = rst("SOURCE_PHONE")
		strFax = rst("SOURCE_FAX")
		strEmail = rst("SOURCE_EMAIL")
	End If
	
	strReturn = _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_PUBLICATION"" class=""control-label col-sm-3"">" & TXT_PUBLICATION & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_PUBLICATION"" id=""SOURCE_PUBLICATION"" maxlength=""100"" value=" & AttrQs(strPub) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_PUBLICATION",True,False)
	End If
	strReturn = strReturn &  _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_PUBLICATION_DATE"" class=""control-label col-sm-3"">" & TXT_PUBLICATION_DATE & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_PUBLICATION_DATE"" id=""SOURCE_PUBLICATION_DATE"" maxlength=""50"" value=" & AttrQs(dPub) & " class=""DatePicker form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_PUBLICATION_DATE",True,False)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_NAME"" class=""control-label col-sm-3"">" & TXT_NAME & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_NAME"" id=""SOURCE_NAME"" maxlength=""100"" value=" & AttrQs(strName) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_NAME",True,False)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_TITLE"" class=""control-label col-sm-3"">" & TXT_TITLE & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_TITLE"" id=""SOURCE_TITLE"" maxlength=""255"" value=" & AttrQs(strTitle) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_TITLE",True,False)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_ORG"" class=""control-label col-sm-3"">" & TXT_ORGANIZATION & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_ORG"" id=""SOURCE_ORG"" maxlength=""100"" value=" & AttrQs(strOrg) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_ORG",True,False)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_PHONE"" class=""control-label col-sm-3"">" & TXT_PHONE & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_PHONE"" id=""SOURCE_PHONE"" maxlength=""100"" value=" & AttrQs(strPhone) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_PHONE",True,False)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_FAX"" class=""control-label col-sm-3"">" & TXT_FAX & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_FAX"" id=""SOURCE_FAX"" maxlength=""100"" value=" & AttrQs(strFax) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_FAX",True,False)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_EMAIL"" class=""control-label col-sm-3"">" & TXT_EMAIL & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_EMAIL"" id=""SOURCE_EMAIL"" maxlength=""100"" value=" & AttrQs(strEmail) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_EMAIL",True,False)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>"

	makeSourceContents = strReturn
End Function

Function makeStartDateContents(rst,bUseContent)
	Dim strReturn
	Dim dStartFirst, dStartLast
	
	If bUseContent Then
		dStartFirst = DateString(rst("START_DATE_FIRST"),True)
		dStartLast = DateString(rst("START_DATE_LAST"),True)
	End If
	
	strReturn = "<table class=""NoBorder cell-padding-3"">" & _
			"<tr><td class=""FieldLabelLeftClr""><label for=""START_DATE_FIRST"">" & TXT_ON_OR_AFTER_DATE & "</label></td><td>" & _
			"<input type=""text"" class=""DatePicker"" name=""START_DATE_FIRST"" id=""START_DATE_FIRST""" & _
			" size=""20"" maxlength=""25"" value=""" & dStartFirst & """>"
	If bFeedback Then
		strReturn = strReturn & getDateFeedback("START_DATE_FIRST",True,False)
	End If
	strReturn = strReturn & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr""><label for=""START_DATE_LAST"">" & TXT_ON_OR_BEFORE_DATE & "</label></td><td>" & _
			"<input type=""text"" class=""DatePicker"" name=""START_DATE_LAST"" id=""START_DATE_LAST""" & _
			" size=""20"" maxlength=""25"" value=""" & dStartLast & """>"
	If bFeedback Then
		strReturn = strReturn & getDateFeedback("START_DATE_LAST",True,False)
	End If
	strReturn = strReturn & "</td></tr>" & _
			"</table>"

	makeStartDateContents = strReturn
End Function

Function makeStdChecklistContents(rst,bUseContent, strSP, strPrefix, strFieldName, strNameField, bItemNotes, bGeneralNotes)
	Dim strReturn
	Dim strVNUM, strNotes, intNotesLen, strItemNote, strJunk
	If bUseContent Then
		strVNUM = rst("VNUM")
		If bGeneralNotes Then
			strNotes = rst(strFieldName & "_NOTES")
		End If
	Else
		strVNUM = Null
	End If

	If bFeedback Then
		bFieldHasFeedback = prepStdChecklistFeedback(rsFb, bGeneralNotes, strFieldName)
	End If


	
	Dim cnnChecklist, cmdChecklist, rsChecklist
	Call makeNewAdminConnection(cnnChecklist)
	Set cmdChecklist = Server.CreateObject("ADODB.Command")
	With cmdChecklist
		.ActiveConnection = cnnChecklist
		.CommandText = strSP
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsChecklist = cmdChecklist.Execute
	
	With rsChecklist
		strReturn = "<table class=""NoBorder cell-padding-2"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td><label for=""" & strPrefix & "_ID_" & .Fields(strPrefix & "_ID") & """><input name=""" & strPrefix & "_ID"" id=""" & strPrefix & "_ID_" & .Fields(strPrefix & "_ID") & """ type=""checkbox"" value=""" & .Fields(strPrefix & "_ID") & """"
			If .Fields("IS_SELECTED") Then
				strReturn = strReturn & " checked"
			End If
			strReturn = strReturn & ">&nbsp;" & .Fields(strNameField) & "</label></td>"
			If bItemNotes Then
				strItemNote = .Fields("Notes")
				strReturn = strReturn & "<td><input type=""text"" title=" & AttrQs(.Fields(strNameField) & TXT_COLON & TXT_NOTES) & " name=""" & strPrefix & "_NOTES_" & .Fields(strPrefix & "_ID") & """ " & _
				"ID=""" & strPrefix & "_NOTES_" & .Fields(strPrefix & "_ID") & """ " & _
				"value=""" & strItemNote & """ " & _
				"size=""" & TEXT_SIZE - 20 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """></td>"

			End If
			strReturn = strReturn & "</tr>"
			If bFeedback Then
				strReturn = strReturn & getStdChecklistFeedback(strPrefix, strFieldName, bItemNotes, .Fields(strPrefix & "_ID"), .Fields("IS_SELECTED"), strItemNote, .Fields(strNameField), TXT_FEEDBACK_NUM, TXT_COLON, TXT_UPDATE, TXT_CONTENT_DELETED)
			End If
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With
	
	If bGeneralNotes Then
		If Nl(strNotes) Then
			intNotesLen = 0
		Else
			intNotesLen = Len(strNotes)
			strNotes = Server.HTMLEncode(strNotes)
		End If
		strReturn = strReturn & "<h4><label for=""" & strFieldName & "_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & _
				"<textarea id=""" & strFieldName & "_NOTES"" name=""" & strFieldName & "_NOTES""" & _
				" cols=""" & TEXTAREA_COLS & """" & _
				" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
				">" & strNotes & "</textarea>"
		If bFeedback Then
			strReturn = strReturn & getStdChecklistNotesFeedback(strFieldName, strNotes, TXT_FEEDBACK_NUM, TXT_COLON, TXT_UPDATE, TXT_CONTENT_DELETED)
		End If
	End If

	rsChecklist.Close
	Set rsChecklist = Nothing
	Set cmdChecklist = Nothing

	makeStdChecklistContents = strReturn

End Function
Function makeSuitabilityContents(rst,bUseContent)
	makeSuitabilityContents = makeStdChecklistContents(rst, bUseContent, "dbo.sp_VOL_VNUMSuitability_s", "SB", "SUITABILITY", "SuitableFor", False, False)
End Function

Function makeTrainingContents(rst,bUseContent)
	makeTrainingContents = makeStdChecklistContents(rst, bUseContent, "dbo.sp_VOL_VNUMTraining_s", "TRN", "TRAINING", "TrainingType", True, True)
End Function

Function makeTransportationContents(rst,bUseContent)
	makeTransportationContents = makeStdChecklistContents(rst, bUseContent, "dbo.sp_VOL_VNUMTransportation_s", "TRP", "TRANSPORTATION", "TransportationType", True, True)
End Function
%>
