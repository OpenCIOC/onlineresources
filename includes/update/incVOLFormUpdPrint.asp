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
	Dim strReturn
	Dim strVNUM, strNotes, intNotesLen
	If bUseContent Then
		strVNUM = rst("VNUM")
		strNotes = rst("ACCESSIBILITY_NOTES")
	Else
		strVNUM = Null
	End If
	
	Dim cnnAccessibility, cmdAccessibility, rsAccessibility
	Call makeNewAdminConnection(cnnAccessibility)
	Set cmdAccessibility = Server.CreateObject("ADODB.Command")
	With cmdAccessibility
		.ActiveConnection = cnnAccessibility
		.CommandText = "dbo.sp_VOL_VNUMAccessibility_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsAccessibility = cmdAccessibility.Execute
	
	With rsAccessibility
		strReturn = "<table class=""NoBorder cell-padding-2"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td><label for=""AC_ID_" & .Fields("AC_ID") & """><input name=""AC_ID"" id=""AC_ID_" & .Fields("AC_ID") & """ type=""checkbox"" value=""" & .Fields("AC_ID") & """"
			If .Fields("IS_SELECTED") Then
				strReturn = strReturn & " checked"
			End If
			strReturn = strReturn & ">&nbsp;" & .Fields("AccessibilityType") & "</label></td><td>" & _
				"<input type=""text"" title=" & AttrQs(.Fields("AccessibilityType") & TXT_COLON & TXT_NOTES) & " name=""AC_NOTES_" & .Fields("AC_ID") & """ " & _
				"value=""" & .Fields("Notes") & """ " & _
				"size=""" & TEXT_SIZE - 20 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """>" & _
				"</td></tr>"
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With
	
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<div class=""FieldLabelLeftClr""><label for=""ACCESSIBILITY_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea name=""ACCESSIBILITY_NOTES""" & _
			" id=""ACCESSIBILITY_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			">" & strNotes & "</textarea>"

	rsAccessibility.Close
	Set rsAccessibility = Nothing
	Set cmdAccessibility = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback("ACCESSIBILITY",False)
	End If
	makeAccessibilityContents = strReturn
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
		strReturn = strReturn & getFeedback("MIN_AGE",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""MAX_AGE"" class=""control-label col-xs-3 col-lg-2"">" & TXT_MAX_AGE & "</label>" & _
			"<div class=""col-xs-9 col-lg-10 form-inline"">" & _
				"<input type=""text"" name=""MAX_AGE"" id=""MAX_AGE"" size=""5"" maxlength=""5"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(decMaxAge) & "> (" & TXT_IN_YEARS & ")"
	If bFeedback Then
		strReturn = strReturn & getFeedback("MAX_AGE",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>"

	makeAgesContents = strReturn
End Function

Function makeCommitmentLengthContents(rst,bUseContent)
	Dim strReturn
	Dim strVNUM, strNotes, intNotesLen
	If bUseContent Then
		strVNUM = rst("VNUM")
		strNotes = rst("COMMITMENT_LENGTH_NOTES")
	Else
		strVNUM = Null
	End If
	
	Dim cnnCommitmentLength, cmdCommitmentLength, rsCommitmentLength
	Call makeNewAdminConnection(cnnCommitmentLength)
	Set cmdCommitmentLength = Server.CreateObject("ADODB.Command")
	With cmdCommitmentLength
		.ActiveConnection = cnnCommitmentLength
		.CommandText = "dbo.sp_VOL_VNUMCommitmentLength_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsCommitmentLength = cmdCommitmentLength.Execute
	
	With rsCommitmentLength
		strReturn = "<table class=""NoBorder cell-padding-2"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td><label for=""CL_ID_" & .Fields("CL_ID") & """><input name=""CL_ID"" id=""CL_ID_" & .Fields("CL_ID") & """ type=""checkbox"" value=""" & .Fields("CL_ID") & """"
			If .Fields("IS_SELECTED") Then
				strReturn = strReturn & " checked"
			End If
			strReturn = strReturn & ">&nbsp;" & .Fields("CommitmentLength") & "</label></td><td>" & _
				"<input type=""text"" title=" & AttrQs(.Fields("CommitmentLength") & TXT_COLON & TXT_NOTES) & " name=""CL_NOTES_" & .Fields("CL_ID") & """ " & _
				"value=""" & .Fields("Notes") & """ " & _
				"size=""" & TEXT_SIZE - 20 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """>" & _
				"</td></tr>"
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With
	
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<div class=""FieldLabelLeftClr""><label for=""COMMITMENT_LENGTH_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea id=""COMMITMENT_LENGTH_NOTES"" name=""COMMITMENT_LENGTH_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			">" & strNotes & "</textarea>"

	rsCommitmentLength.Close
	Set rsCommitmentLength = Nothing
	Set cmdCommitmentLength = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback("COMMITMENT_LENGTH",False)
	End If
	makeCommitmentLengthContents = strReturn
End Function

Function makeInteractionLevelContents(rst,bUseContent)
	Dim strReturn
	Dim strVNUM, strNotes, intNotesLen
	If bUseContent Then
		strVNUM = rst("VNUM")
		strNotes = rst("INTERACTION_LEVEL_NOTES")
	Else
		strVNUM = Null
	End If
	
	Dim cnnInteractionLevel, cmdInteractionLevel, rsInteractionLevel
	Call makeNewAdminConnection(cnnInteractionLevel)
	Set cmdInteractionLevel = Server.CreateObject("ADODB.Command")
	With cmdInteractionLevel
		.ActiveConnection = cnnInteractionLevel
		.CommandText = "dbo.sp_VOL_VNUMInteractionLevel_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsInteractionLevel = cmdInteractionLevel.Execute
	
	With rsInteractionLevel
		strReturn = "<table class=""NoBorder cell-padding-2"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td><label for=""IL_ID_" & .Fields("IL_ID") & """><input name=""IL_ID"" id=""IL_ID_" & .Fields("IL_ID") & """ type=""checkbox"" value=""" & .Fields("IL_ID") & """"
			If .Fields("IS_SELECTED") Then
				strReturn = strReturn & " checked"
			End If
			strReturn = strReturn & ">&nbsp;" & .Fields("InteractionLevel") & "</label></td><td>" & _
				"<input type=""text"" title=" & AttrQs(.Fields("InteractionLevel") & TXT_COLON & TXT_NOTES) & " name=""IL_NOTES_" & .Fields("IL_ID") & """ " & _
				"value=""" & .Fields("Notes") & """ " & _
				"size=""" & TEXT_SIZE - 20 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """>" & _
				"</td></tr>"
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With
	
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<div class=""FieldLabelLeftClr""><label for=""INTERACTION_LEVEL_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea id=""INTERACTION_LEVEL_NOTES"" name=""INTERACTION_LEVEL_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			">" & strNotes & "</textarea>"

	rsInteractionLevel.Close
	Set rsInteractionLevel = Nothing
	Set cmdInteractionLevel = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback("INTERACTION_LEVEL",False)
	End If
	makeInteractionLevelContents = strReturn
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
		strReturn = strReturn & getFeedback("Interests",False)
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
		strReturn = strReturn & getFeedback("MINIMUM_HOURS",True)
	End If

	Call openMinHoursPerListRst()

	strReturn = strReturn & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr""><label for=""MINIMUM_HOURS_PER"">" & TXT_MIN_HOURS_PER & "</label></td><td>" & _
			makeMinHoursPerList(strMinHoursPer,"MINIMUM_HOURS_PER",True)
	If bFeedback Then
		strReturn = strReturn & getFeedback("MINIMUM_HOURS_PER",True)
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
		strReturn = strReturn & getFeedback("NUM_NEEDED_TOTAL",True)
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
		strReturn = strReturn & getFeedback("NUM_NEEDED",False)
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
		strReturn = strReturn & getFeedback("NUM_NEEDED_NOTES",True)
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
		strReturn = strReturn & getFeedback("NUM", True)
		strReturn = strReturn & getFeedback("ORG_NAME", False)
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
		strReturn = strReturn & getFeedback("SCHEDULE_GRID",False)
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
		strReturn = strReturn & getFeedback("SCHEDULE_NOTES",True)
	End If

	makeScheduleContents = strReturn
End Function

Function makeSeasonsContents(rst,bUseContent)
	Dim strReturn
	Dim strVNUM, strNotes, intNotesLen
	If bUseContent Then
		strVNUM = rst("VNUM")
		strNotes = rst("SEASONS_NOTES")
	Else
		strVNUM = Null
	End If
	
	Dim cnnSeasons, cmdSeasons, rsSeasons
	Call makeNewAdminConnection(cnnSeasons)
	Set cmdSeasons = Server.CreateObject("ADODB.Command")
	With cmdSeasons
		.ActiveConnection = cnnSeasons
		.CommandText = "dbo.sp_VOL_VNUMSeasons_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsSeasons = cmdSeasons.Execute
	
	With rsSeasons
		strReturn = "<table class=""NoBorder cell-padding-2"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td><label for=""SSN_ID_" & .Fields("SSN_ID") & """><input name=""SSN_ID"" id=""SSN_ID_" & .Fields("SSN_ID") & """ type=""checkbox"" value=""" & .Fields("SSN_ID") & """"
			If .Fields("IS_SELECTED") Then
				strReturn = strReturn & " checked"
			End If
			strReturn = strReturn & ">&nbsp;" & .Fields("Season") & "</label></td><td>" & _
				"<input type=""text"" title=" & AttrQs(.Fields("Season") & TXT_COLON & TXT_NOTES) & " name=""SSN_NOTES_" & .Fields("SSN_ID") & """ " & _
				"value=""" & .Fields("Notes") & """ " & _
				"size=""" & TEXT_SIZE - 20 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """>" & _
				"</td></tr>"
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With
	
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<h4><label for=""SEASONS_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & _
			"<textarea id=""SEASONS_NOTES"" name=""SEASONS_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			">" & strNotes & "</textarea>"

	rsSeasons.Close
	Set rsSeasons = Nothing
	Set cmdSeasons = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback("SEASONS",False)
	End If
	makeSeasonsContents = strReturn
End Function

Function makeSkillContents(rst,bUseContent)
	Dim strReturn
	Dim strVNUM, strNotes, intNotesLen
	If bUseContent Then
		strVNUM = rst("VNUM")
		strNotes = rst("SKILLS_NOTES")
	Else
		strVNUM = Null
	End If
	
	Dim cnnSkill, cmdSkill, rsSkill
	Call makeNewAdminConnection(cnnSkill)
	Set cmdSkill = Server.CreateObject("ADODB.Command")
	With cmdSkill
		.ActiveConnection = cnnSkill
		.CommandText = "dbo.sp_VOL_VNUMSkill_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsSkill = cmdSkill.Execute
	
	With rsSkill
		strReturn = "<table class=""NoBorder cell-padding-2"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td><label for=""SK_ID_" & .Fields("SK_ID") & """><input name=""SK_ID"" id=""SK_ID_" & .Fields("SK_ID") & """ type=""checkbox"" value=""" & .Fields("SK_ID") & """"
			If .Fields("IS_SELECTED") Then
				strReturn = strReturn & " checked"
			End If
			strReturn = strReturn & ">&nbsp;" & Server.HTMLEncode(.Fields("Skill")) & "</label></td><td>" & _
				"<input type=""text"" title=" & AttrQs(.Fields("Skill") & TXT_COLON & TXT_NOTES) & " name=""SK_NOTES_" & .Fields("SK_ID") & """ " & _
				"value=""" & .Fields("Notes") & """ " & _
				"size=""" & TEXT_SIZE - 20 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """>" & _
				"</td></tr>"
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With
	
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<h4><label for=""SKILLS_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & _
			"<textarea id=""SKILLS_NOTES"" name=""SKILLS_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			">" & strNotes & "</textarea>"

	rsSkill.Close
	Set rsSkill = Nothing
	Set cmdSkill = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback("SKILLS",False)
	End If
	makeSkillContents = strReturn
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
		strReturn = strReturn & getFeedback("SOURCE_PUBLICATION",True)
	End If
	strReturn = strReturn &  _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_PUBLICATION_DATE"" class=""control-label col-sm-3"">" & TXT_PUBLICATION_DATE & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_PUBLICATION_DATE"" id=""SOURCE_PUBLICATION_DATE"" maxlength=""50"" value=" & AttrQs(dPub) & " class=""DatePicker form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_PUBLICATION_DATE",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_NAME"" class=""control-label col-sm-3"">" & TXT_NAME & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_NAME"" id=""SOURCE_NAME"" maxlength=""100"" value=" & AttrQs(strName) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_NAME",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_TITLE"" class=""control-label col-sm-3"">" & TXT_TITLE & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_TITLE"" id=""SOURCE_TITLE"" maxlength=""100"" value=" & AttrQs(strTitle) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_TITLE",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_ORG"" class=""control-label col-sm-3"">" & TXT_ORGANIZATION & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_ORG"" id=""SOURCE_ORG"" maxlength=""100"" value=" & AttrQs(strOrg) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_ORG",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_PHONE"" class=""control-label col-sm-3"">" & TXT_PHONE & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_PHONE"" id=""SOURCE_PHONE"" maxlength=""100"" value=" & AttrQs(strPhone) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_PHONE",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_FAX"" class=""control-label col-sm-3"">" & TXT_FAX & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_FAX"" id=""SOURCE_FAX"" maxlength=""100"" value=" & AttrQs(strFax) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_FAX",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_EMAIL"" class=""control-label col-sm-3"">" & TXT_EMAIL & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_EMAIL"" id=""SOURCE_EMAIL"" maxlength=""60"" value=" & AttrQs(strEmail) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_EMAIL",True)
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

Function makeSuitabilityContents(rst,bUseContent)
	Dim strReturn
	Dim strVNUM
	If bUseContent Then
		strVNUM = rst("VNUM")
	Else
		strVNUM = Null
	End If
	
	Dim cnnSuitability, cmdSuitability, rsSuitability
	Call makeNewAdminConnection(cnnSuitability)
	Set cmdSuitability = Server.CreateObject("ADODB.Command")
	With cmdSuitability
		.ActiveConnection = cnnSuitability
		.CommandText = "dbo.sp_VOL_VNUMSuitability_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsSuitability = cmdSuitability.Execute
	
	With rsSuitability
		strReturn = "<table class=""NoBorder cell-padding-2"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td><label for=""SB_ID_" & .Fields("SB_ID") & """><input name=""SB_ID"" id=""SB_ID_" & .Fields("SB_ID") & """ type=""checkbox"" value=""" & .Fields("SB_ID") & """"
			If .Fields("IS_SELECTED") Then
				strReturn = strReturn & " checked"
			End If
			strReturn = strReturn & ">&nbsp;" & .Fields("SuitableFor") & "</label></td></tr>"
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With
	
	rsSuitability.Close
	Set rsSuitability = Nothing
	Set cmdSuitability = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback("Suitability",False)
	End If
	makeSuitabilityContents = strReturn
End Function

Function makeTrainingContents(rst,bUseContent)
	Dim strReturn
	Dim strVNUM, strNotes, intNotesLen
	If bUseContent Then
		strVNUM = rst("VNUM")
		strNotes = rst("TRAINING_NOTES")
	Else
		strVNUM = Null
	End If
	
	Dim cnnTraining, cmdTraining, rsTraining
	Call makeNewAdminConnection(cnnTraining)
	Set cmdTraining = Server.CreateObject("ADODB.Command")
	With cmdTraining
		.ActiveConnection = cnnTraining
		.CommandText = "dbo.sp_VOL_VNUMTraining_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsTraining = cmdTraining.Execute
	
	With rsTraining
		strReturn = "<table class=""NoBorder cell-padding-2"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td><label for=""TRN_ID_" & .Fields("TRN_ID") & """><input name=""TRN_ID"" id=""TRN_ID_" & .Fields("TRN_ID") & """ type=""checkbox"" value=""" & .Fields("TRN_ID") & """"
			If .Fields("IS_SELECTED") Then
				strReturn = strReturn & " checked"
			End If
			strReturn = strReturn & ">&nbsp;" & .Fields("TrainingType") & "</label></td><td>" & _
				"<input type=""text"" title=" & AttrQs(.Fields("TrainingType") & TXT_COLON & TXT_NOTES) & " name=""TRN_NOTES_" & .Fields("TRN_ID") & """ " & _
				"value=""" & .Fields("Notes") & """ " & _
				"size=""" & TEXT_SIZE - 20 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """>" & _
				"</td></tr>"
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With
	
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<h4><label for=""TRAINING_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & _
			"<textarea id=""TRAINING_NOTES"" name=""TRAINING_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			">" & strNotes & "</textarea>"

	rsTraining.Close
	Set rsTraining = Nothing
	Set cmdTraining = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback("TRAINING",False)
	End If
	makeTrainingContents = strReturn
End Function

Function makeTransportationContents(rst,bUseContent)
	Dim strReturn
	Dim strVNUM, strNotes, intNotesLen
	If bUseContent Then
		strVNUM = rst("VNUM")
		strNotes = rst("TRANSPORTATION_NOTES")
	Else
		strVNUM = Null
	End If
	
	Dim cnnTransportation, cmdTransportation, rsTransportation
	Call makeNewAdminConnection(cnnTransportation)
	Set cmdTransportation = Server.CreateObject("ADODB.Command")
	With cmdTransportation
		.ActiveConnection = cnnTransportation
		.CommandText = "dbo.sp_VOL_VNUMTransportation_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsTransportation = cmdTransportation.Execute
	
	With rsTransportation
		strReturn = "<table class=""NoBorder cell-padding-2"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td><label for=""TRP_ID_" & .Fields("TRP_ID") & """><input name=""TRP_ID"" id=""TRP_ID_" & .Fields("TRP_ID") & """ type=""checkbox"" value=""" & .Fields("TRP_ID") & """"
			If .Fields("IS_SELECTED") Then
				strReturn = strReturn & " checked"
			End If
			strReturn = strReturn & ">&nbsp;" & .Fields("TransportationType") & "</label></td><td>" & _
				"<input type=""text"" title=" & AttrQs(.Fields("TransportationType") & TXT_COLON & TXT_NOTES) & " name=""TRP_NOTES_" & .Fields("TRP_ID") & """ " & _
				"value=""" & .Fields("Notes") & """ " & _
				"size=""" & TEXT_SIZE - 20 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """>" & _
				"</td></tr>"
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With
	
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<h4><label for=""TRANSPORTATION_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & _
			"<textarea id=""TRANSPORTATION_NOTES"" name=""TRANSPORTATION_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			">" & strNotes & "</textarea>"

	rsTransportation.Close
	Set rsTransportation = Nothing
	Set cmdTransportation = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback("TRANSPORTATION",False)
	End If
	makeTransportationContents = strReturn
End Function
%>
