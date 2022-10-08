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
				"<div class=""input-group"">" & _
					"<input type=""text"" name=""MIN_AGE"" id=""MIN_AGE"" size=""5"" maxlength=""5"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(decMinAge) & ">" & _
					"<span class=""input-group-addon"">" & TXT_AGE_YEARS_AFTER & "</span>" & _
				"</div>"
	If bFeedback Then
		strReturn = strReturn & getFeedback("MIN_AGE",True,False)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""MAX_AGE"" class=""control-label col-xs-3 col-lg-2"">" & TXT_MAX_AGE & "</label>" & _
			"<div class=""col-xs-9 col-lg-10 form-inline"">" & _
				"<div class=""input-group"">" & _
					"<input type=""text"" name=""MAX_AGE"" id=""MAX_AGE"" size=""5"" maxlength=""5"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(decMaxAge) & ">" & _
					"<span class=""input-group-addon"">" & TXT_AGE_YEARS_AFTER & "</span>" & _
				"</div>"
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
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
	End With
	Set rsInterests = cmdInterests.Execute
	
	With rsInterests
		strReturn = _
			"<p><span class=""Alert""><span class=""glyphicon glyphicon-star"" aria-hidden=""true""></span>" & TXT_IMPORTANT & "</span>" & TXT_COLON & _
				TXT_INST_IMPORTANT_CHECK_ALL & "</p><hr>" & vbCrLf & _
			"<div id=""AI_existing_add_container"">"
		Do Until .EOF
			If .Fields("IS_SELECTED") = SQL_TRUE Then
				strReturn = strReturn & "<input name=""AI_ID"" id=""AI_ID_" & .Fields("AI_ID") & """ type=""checkbox"" value=""" & .Fields("AI_ID") & """ checked>&nbsp;<label for=""AI_ID_" & .Fields("AI_ID") & """>" & .Fields("InterestName") & "</label> ; "
				.MoveNext
			Else
				Exit Do
			End If
		Loop
		strReturn = strReturn & "</div>"
	End With
	
	rsInterests.Close
	Set rsInterests = Nothing
	Set cmdInterests = Nothing

	strReturn = strReturn & vbCrLf & _
		"<h4>" & TXT_ADD_INTERESTS & "</h4><div id=""AI_new_input_table"">"

	If Not g_bOnlySpecificInterests Then
		strReturn = strReturn & "<strong><label for=""NEW_AI"">" & TXT_FIND_BY_KEYWORD & "</label></strong>" & vbCrLf & "<br>"
	End If
		
	strReturn = strReturn & vbCrLf & _
		"<div class=""entryform-checklist-add-wrapper"">" & _
			"<div class=""entryform-checklist-add-left"">" & _
				"<input type=""text"" id=""NEW_AI"" class=""form-control"">" & _
			"</div>" & _
			"<div class=""entryform-checklist-add-right"">" & _
				"<button type=""button"" class=""btn btn-default"" id=""add_AI"">" & TXT_ADD & "</button>" & _
			"</div>" & _
		"</div>"
			
	If Not g_bOnlySpecificInterests Then
		strReturn = strReturn & _
			"<p><strong><label for=""InterestGroup"">" & TXT_FIND_BY_GENERAL_INTEREST & "</label></strong>" & vbCrLf & _
			"<br>"
		Call openInterestGroupListRst()
		strReturn = strReturn & makeInterestGroupList(vbNullString, "InterestGroup", True)
		Call closeInterestGroupListRst()

		strReturn = strReturn & "</div>"
	End If

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName, False, False)
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
	
	strReturn = "<div class=""form-group"">" & _
					"<label for=""MINIMUM_HOURS"" class=""control-label col-xs-4 col-lg-3"">" & TXT_MIN_HOURS & "</label>" & _
					"<div class=""col-xs-8 col-lg-9 form-inline"">" & _
						"<input type=""text"" name=""MINIMUM_HOURS"" id=""MINIMUM_HOURS"" size=""5"" maxlength=""5"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(intMinHours) & ">" & _
					"</div>" & _
				"</div>"
	If bFeedback Then
		strReturn = strReturn & getFeedback("MINIMUM_HOURS",True,False)
	End If

	Call openMinHoursPerListRst()

	strReturn = strReturn & _
			"<div class=""form-group"">" & _
				"<label for=""MINIMUM_HOURS_PER"" class=""control-label col-xs-4 col-lg-3"">" & TXT_MIN_HOURS_PER & "</label>" & _
				"<div class=""col-xs-8 col-lg-9 form-inline"">" & _
					makeMinHoursPerList(strMinHoursPer,"MINIMUM_HOURS_PER",True) & _
				"</div>" & _
			"</div>"
	If bFeedback Then
		strReturn = strReturn & getFeedback("MINIMUM_HOURS_PER",True,False)
	End If

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
	
	strReturn = _
		"<h4><label for=""NUM_NEEDED_NOTES"">" & TXT_NUM_NEEDED_TOTAL & "</label></h4>" & vbCrLf & _
		"<p><span class=""Alert""><span class=""glyphicon glyphicon-star"" aria-hidden=""true""></span>" & TXT_REQUIRED & "</span>. " & TXT_INST_NUM_NEEDED_TOTAL & "</p>" & vbCrLf & _
		"<div class=""form-inline form-inline-always"">" & _
			"<div class=""input-group"">" & _
				"<input type=""text"" name=""NUM_NEEDED_TOTAL"" id=""NUM_NEEDED_TOTAL"" size=""5"" maxlength=""4"" value=""" & intNumNeededTotal & """ class=""form-control"">" & _
				"<span class=""input-group-addon""><label for=""NUM_NEEDED_TOTAL"">" & TXT_INDIVIDUALS_WANTED & " (" & TXT_TOTAL & ")</label></span>" & _
			"</div>" & _
		"</div>"
		
	If bFeedback Then
		strReturn = strReturn & getFeedback("NUM_NEEDED_TOTAL",True,False)
	End If

	strReturn = strReturn & vbCrLf & _
		"<hr>" & _
		"<h4><label for=""NUM_NEEDED_NOTES"">" & TXT_COMMUNITIES & "</label></h4>" & vbCrLf & _
		"<p><span class=""Alert""><span class=""glyphicon glyphicon-star"" aria-hidden=""true""></span>" & TXT_REQUIRED & "</span>. " & TXT_INST_NUM_NEEDED_COMMUNITIES & "</p>" & vbCrLf & _
		"<div id=""CM_existing_add_container"" data-addon-label=" & AttrQs(TXT_INDIVIDUALS_WANTED & " " & TXT_OPTIONAL) & ">"

	With rsNumNeeded
		If Not .EOF Then
			While Not .EOF
				strReturn = strReturn & vbCrLf & _
					"<div class=""row-border-bottom""><div class=""row form-group"">" & vbCrLf & _
					"<label class=""control-label control-label-left col-md-4"" for=""CM_ID_" & .Fields("CM_ID") & """>" & _
					"<input type=""checkbox"" id=""CM_ID_" & .Fields("CM_ID") & """ name=""CM_ID"" value=" & AttrQs(.Fields("CM_ID")) & Checked(Not Nl(.Fields("OP_CM_ID"))) & "> " & .Fields("Community") & _
					"</label>" & vbCrLf & _
					"<div class=""col-md-8 form-inline"">" & _
						"<div class=""input-group"">" & _
							"<input type=""text"" class=""form-control"" title=" & AttrQs(.Fields("Community") & TXT_COLON & TXT_INDIVIDUALS_WANTED) & _
								" name=""CM_NUM_NEEDED_" & .Fields("CM_ID") & """" & _
								" size=""3"" maxlength=""3"" value=" & AttrQs(.Fields("NUM_NEEDED")) & ">" & _
							"<span class=""input-group-addon"">" &TXT_INDIVIDUALS_WANTED & " " & TXT_OPTIONAL & "</span>" & _
						"</div>" & _
					"</div>" & vbCrLf & _
					"</div></div>" & vbCrLf & _
				.MoveNext
			Wend
		End If
	End With

	strReturn = strReturn & vbCrLf & _
		"</div>" & vbCrLf & _
		"<h4>" & TXT_ADD_COMMUNITIES & "</h4>" & _
		"<p id=""CM_new_input_table"">" & TXT_INFO_COMMUNITIES_1 & "</p>" & vbCrLf & _
		"<div class=""entryform-checklist-add-wrapper"">" & _
			"<div class=""entryform-checklist-add-left"">" & _
				"<input type=""text"" id=""NEW_CM"" class=""form-control"">" & _
			"</div>" & _
			"<div class=""entryform-checklist-add-right"">" & _
				"<button type=""button"" class=""btn btn-default"" id=""add_CM"">" & TXT_ADD & "</button>" & _
			"</div>" & _
		"</div>"

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
			"<hr>" & vbCrLf & _
			"<h4><label for=""NUM_NEEDED_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & vbCrLf & _
			"<p>" & TXT_INST_NUM_NEEDED_NOTES & "</p>" & vbCrLf & _
			"<textarea class=""form-control"" id=""NUM_NEEDED_NOTES"" name=""NUM_NEEDED_NOTES""" & _
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
			strReturn = "<div class=""AlertBubble"">" & strReturn & "</div>"
		End If
		
	End if
	
	strReturn = strReturn & "<div class=""form-inline"">" & _
			"<input type=""text"" class=""form-control"" id=""NUM"" title=" & AttrQs(TXT_RECORD_NUM) & " name=""NUM"" size=""20"" maxlength=""20""" & _
			IIf(Not Nl(strNUM)," value=" & AttrQs(strNUM),vbNullString) & "> " & _
			"</div>" & _
			"<p>" & TXT_INST_NUM_FINDER & "</p>"

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

	strReturn = "<table class=""BasicBorder cell-padding-2 responsive-table"">" & _
		"<tr class=""FieldLabelCenterClr hidden-xs"">" &  _
		"<td>&nbsp;</td>" & _
		"<td>" & TXT_TIME_MORNING & "<br>" & TXT_TIME_BEFORE_12 & "</td>" & _
		"<td>" & TXT_TIME_AFTERNOON & "<br>" & TXT_TIME_12_6 & "</td>" & _ 
		"<td>" & TXT_TIME_EVENING & "<br>" & TXT_TIME_AFTER_6 & "</td>" & _
		"<td>" & TXT_TIME_SPECIFIC & "</td>" & _
		"</tr>"

	For i = 0 to 6
		strReturn = strReturn & "<tr>" & _
			"<td class=""field-label-cell-clr"">" & aLongs(i) & "</td>" & _
			"<td class=""text-left-xs text-center field-data-cell""><label for=""SCH_" & aShorts(i) & "_Morning""><input name=""SCH_" & aShorts(i) & "_Morning"" id=""SCH_" & aShorts(i) & "_Morning"" title=" & AttrQs(aLongs(i) & TXT_COLON & TXT_TIME_MORNING) & " TYPE=""checkbox"" "
			If bUseContent Then
				If rst("SCH_" & aShorts(i) & "_Morning") Then
					strReturn = strReturn & " checked"
				End If
			End If
		strReturn = strReturn & "> <span class=""visible-xs-inline"">" & TXT_TIME_MORNING & " - " & TXT_TIME_BEFORE_12 & "</span></label></td>" & _
			"<td class=""text-left-xs text-center field-data-cell""><label for=""SCH_" & aShorts(i) & "_Afternoon""><input name=""SCH_" & aShorts(i) & "_Afternoon"" id=""SCH_" & aShorts(i) & "_Afternoon"" title=" & AttrQs(aLongs(i) & TXT_COLON & TXT_TIME_AFTERNOON) & " TYPE=""checkbox"" "
			If bUseContent Then
				If rst("SCH_" & aShorts(i) & "_Afternoon") Then
					strReturn = strReturn & " checked"
				End If
			End If
		strReturn = strReturn & "> <span class=""visible-xs-inline"">" & TXT_TIME_AFTERNOON & " - " & TXT_TIME_12_6 & " </span></label></td>" & _
			"<td class=""text-left-xs text-center field-data-cell""><label for=""SCH_" & aShorts(i) & "_Evening""><input name=""SCH_" & aShorts(i) & "_Evening"" id=""SCH_" & aShorts(i) & "_Evening"" title=" & AttrQs(aLongs(i) & TXT_COLON & TXT_TIME_EVENING) & " TYPE=""checkbox"" "
			If bUseContent Then
				If rst("SCH_" & aShorts(i) & "_Evening") Then
					strReturn = strReturn & " checked"
				End If
			End If
		strReturn = strReturn & "> <span class=""visible-xs-inline"">" & TXT_TIME_EVENING & " - " & TXT_TIME_AFTER_6 & " </span></label></td>" & _
			"<td class=""field-data-cell""><label for=""SCH_" & aShorts(i) & "_Time""><span class=""visible-xs-inline"">" & Replace(TXT_TIME_SPECIFIC, "<br>", " ") & " </span></label><input name=""SCH_" & aShorts(i) & "_Time"" id=""SCH_" & aShorts(i) & "_Time"" TYPE=""text"" title=" & AttrQs(aLongs(i) & TXT_COLON & TXT_TITLE_SPECIFIC) & " size=""25"" maxlength=""50"" class=""form-control"""
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
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
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
	
	strReturn = "<div class=""form-group"">" & _
			"<label for=""START_DATE_FIRST"" class=""control-label col-sm-4 col-lg-3"">" & TXT_ON_OR_AFTER_DATE & "</label>" & _
			"<div class=""col-sm-8 col-lg-9 form-inline"">" & _
				"<input type=""text"" name=""START_DATE_FIRST"" id=""START_DATE_FIRST"" maxlength=""25"" value=" & AttrQs(dStartFirst) & " class=""DatePicker form-control"">" & _
			"</div>" & _
		"</div>"
	If bFeedback Then
		strReturn = strReturn & getDateFeedback("START_DATE_FIRST",True,False)
	End If
	strReturn = strReturn & _
		"<div class=""form-group"">" & _
			"<label for=""START_DATE_LAST"" class=""control-label col-sm-4 col-lg-3"">" & TXT_ON_OR_BEFORE_DATE & "</label>" & _
			"<div class=""col-sm-8 col-lg-9 form-inline"">" & _
				"<input type=""text"" name=""START_DATE_LAST"" id=""START_DATE_LAST"" maxlength=""25"" value=" & AttrQs(dStartLast) & " class=""DatePicker form-control"">" & _
			"</div>" & _
		"</div>"
	If bFeedback Then
		strReturn = strReturn & getDateFeedback("START_DATE_LAST",True,False)
	End If

	makeStartDateContents = strReturn
End Function

Function makeStdChecklistContents(rst, bUseContent, strSP, strPrefix, strFieldName, strNameField, bItemNotes, bGeneralNotes)
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
		While Not .EOF
			strReturn = strReturn & vbCrLf & _
				"<div class=" & AttrQs(IIf(bGeneralNotes,"row-border-bottom","row-border-top")) & ">" & _
					"<div class=""row form-group"">" & _
						"<label for=" & AttrQs(strPrefix & "_ID_" & .Fields(strPrefix & "_ID")) & " class=""control-label control-label-left " & IIf(bItemNotes,"col-md-4","col-md-12") & """>" & _
							"<input name=" & AttrQs(strPrefix & "_ID") & _
								" id=" & AttrQs(strPrefix & "_ID_" & .Fields(strPrefix & "_ID")) & _
								" type=""checkbox"" value=" & AttrQs(.Fields(strPrefix & "_ID")) & Checked(.Fields("IS_SELECTED")) & ">" & _
							Server.HTMLEncode(.Fields(strNameField)) & _
						"</label>"
			If bItemNotes Then
				strReturn = strReturn & vbCrLf & _
						"<div class=""col-md-8"">"
				If .Fields("LangID") = g_objCurrentLang.LangID Then
					strReturn = strReturn & _
						"<input type=""text"" title=" & AttrQs(TXT_NOTES & TXT_COLON & .Fields(strNameField)) & _
							" name=" & AttrQs(strPrefix & "_NOTES_" & .Fields(strPrefix & "_ID")) & _
							" id=" & AttrQs(strPrefix & "_NOTES_" & .Fields(strPrefix & "_ID")) & _
							" value=" & AttrQs(.Fields("Notes")) & _
							" maxlength=" & AttrQs(MAX_LENGTH_CHECKLIST_NOTES) & _
							" class=""form-control""" & _
						">"
				End If
			End If
			strReturn = strReturn & _
						"</div>" & _
					"</div>"
			If bFeedback Then
				strReturn = strReturn & getStdChecklistFeedback(strPrefix, strFieldName, bItemNotes, .Fields(strPrefix & "_ID"), .Fields("IS_SELECTED"), strItemNote, .Fields(strNameField), TXT_FEEDBACK_NUM, TXT_COLON, TXT_UPDATE, TXT_CONTENT_DELETED)
			End If
			strReturn = strReturn & _
				"</div>"
			.MoveNext
		Wend
	End With
	
	If bGeneralNotes Then
		If Nl(strNotes) Then
			intNotesLen = 0
		Else
			intNotesLen = Len(strNotes)
			strNotes = Server.HTMLEncode(strNotes)
		End If
		strReturn = strReturn & "<h4><label for=" & AttrQs(strFieldName & "_NOTES") & ">" & TXT_OTHER_NOTES & "</label></h4>" & _
				"<textarea class=""form-control"" id=" & AttrQs(strFieldName & "_NOTES") & " name=" & AttrQs(strFieldName & "_NOTES") & _
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
	Dim strReturn

	strReturn = _
		"<p><span class=""Alert""><span class=""glyphicon glyphicon-star"" aria-hidden=""true""></span>" & TXT_IMPORTANT & "</span>" & TXT_COLON & _
		TXT_INST_IMPORTANT_CHECK_ALL & "</p><hr>" & vbCrLf & _
		makeStdChecklistContents(rst, bUseContent, "dbo.sp_VOL_VNUMSuitability_s", "SB", "SUITABILITY", "SuitableFor", False, False)
	makeSuitabilityContents = strReturn
End Function

Function makeTrainingContents(rst,bUseContent)
	makeTrainingContents = makeStdChecklistContents(rst, bUseContent, "dbo.sp_VOL_VNUMTraining_s", "TRN", "TRAINING", "TrainingType", True, True)
End Function

Function makeTransportationContents(rst,bUseContent)
	makeTransportationContents = makeStdChecklistContents(rst, bUseContent, "dbo.sp_VOL_VNUMTransportation_s", "TRP", "TRANSPORTATION", "TransportationType", True, True)
End Function
%>
