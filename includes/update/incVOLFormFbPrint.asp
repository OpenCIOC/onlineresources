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
				"<input type=""text"" name=""MIN_AGE"" id=""MIN_AGE"" size=""5"" maxlength=""5"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(decMinAge) & "> (" & TXT_IN_YEARS & ")" & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""MAX_AGE"" class=""control-label col-xs-3 col-lg-2"">" & TXT_MAX_AGE & "</label>" & _
			"<div class=""col-xs-9 col-lg-10 form-inline"">" & _
				"<input type=""text"" name=""MAX_AGE"" id=""MAX_AGE"" size=""5"" maxlength=""5"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(decMaxAge) & "> (" & TXT_IN_YEARS & ")" & _
			"</div>" & _
		"</div>"
	makeAgesContents = strReturn
End Function

Function makeMinHoursContents(rst, bUseContent)
	Dim strReturn
	Dim intMinHours, strMinHoursPer
	
	If bUseContent Then
		intMinHours = rst("MINIMUM_HOURS")
		strMinHoursPer = rst("MINIMUM_HOURS_PER")
	End If
	
	Call openMinHoursPerListRst()

	strReturn =  _
		"<div class=""form-group"">" & _
			"<label for=""MINIMUM_HOURS"" class=""control-label col-xs-4 col-lg-3"">" & TXT_MIN_HOURS & "</label>" & _
			"<div class=""col-xs-8 col-lg-9 form-inline"">" & _
				"<input type=""text"" name=""MINIMUM_HOURS"" id=""MINIMUM_HOURS"" size=""5"" maxlength=""5"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(intMinHours) & ">" & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""MINIMUM_HOURS_PER"" class=""control-label col-xs-4 col-lg-3"">" & TXT_MIN_HOURS_PER & "</label>" & _
			"<div class=""col-xs-8 col-lg-9 form-inline"">" & _
				makeMinHoursPerList(strMinHoursPer,"MINIMUM_HOURS_PER",True) & _
			"</div>" & _
		"</div>"

	Call closeMinHoursPerListRst()

	makeMinHoursContents = strReturn
End Function

Function makeNumNeededContents(rst,bUseContent)
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
		"<div class=""form-group"">" & _
			"<label for=""NUM_NEEDED_TOTAL"" class=""control-label col-xs-4 col-lg-3"">" & TXT_NUM_POSITIONS & " (" & TXT_TOTAL & ")</label>" & _
			"<div class=""col-xs-8 col-lg-9 form-inline"">" & _
				"<input type=""text"" name=""NUM_NEEDED_TOTAL"" id=""NUM_NEEDED_TOTAL"" size=""5"" maxlength=""4"" value=""" & intNumNeededTotal & """ class=""form-control"">" & _
			"</div>" & _
		"</div>" & _
		"<table class=""BasicBorder cell-padding-2"">" & _
		"<tr><th class=""RevTitleBox"">&nbsp;</th><th class=""RevTitleBox"">" & TXT_COMMUNITY & "</th><th class=""RevTitleBox"">" & TXT_NUM_POSITIONS & "</th></tr>"
	
	With rsNumNeeded
		If Not .EOF Then
			While Not .EOF
				strReturn = strReturn & _
					"<tr>" & _
						"<td><input type=""checkbox"" id=""CM_ID_" & .Fields("CM_ID") & """ name=""CM_ID_" & .Fields("CM_ID") & """ value=""on""" & Checked(Not Nl(.Fields("OP_CM_ID"))) & "></td>" & _
						"<td class=""FieldLabelLeftClr""><label for=""CM_ID_" & .Fields("CM_ID") & """>" & .Fields("Community") & "</label></td>" & _
						"<td><div class=""form-inline text-center""><input type=""text"" name=""CM_NUM_NEEDED_" & .Fields("CM_ID") & """ title=" & AttrQs(TXT_POSITIONS & TXT_COLON & .Fields("Community")) & _
							" size=""3"" maxlength=""3"" value=" & AttrQs(.Fields("NUM_NEEDED")) & " class=""form-control""></div></td>" & _
					"</tr>"
				.MoveNext
			Wend
		End If
	End With

	strReturn = strReturn & _
		"<tr>" & _
			"<td colspan=""2""><div class=""form-inline""><input type=""text"" name=""NEW_CM_0"" id=""NEW_CM_0"" title=" & AttrQs(TXT_CUSTOM_COMMUNITY & " 1") & " size=""40"" maxlength=""200"" class=""form-control""></div></td>" & _
			"<td><div class=""form-inline text-center""><input type=""text"" name=""NEW_CM_0_NUM_NEEDED"" title=" & AttrQs(TXT_POSITIONS & TXT_COLON & TXT_CUSTOM_COMMUNITY & " 1") & " size=""3"" maxlength=""3"" class=""form-control""></div></td>" & _
		"</tr>" & _
		"<tr>" & _
			"<td colspan=""2""><div class=""form-inline""><input type=""text"" name=""NEW_CM_1"" id=""NEW_CM_1"" title=" & AttrQs(TXT_CUSTOM_COMMUNITY & " 2") & " size=""40"" maxlength=""200"" class=""form-control""></div></td>" & _
			"<td><div class=""form-inline text-center""><input type=""text"" name=""NEW_CM_1_NUM_NEEDED"" title=" & AttrQs(TXT_POSITIONS & TXT_COLON & TXT_CUSTOM_COMMUNITY & " 2") & " size=""3"" maxlength=""3"" class=""form-control""></div></td>" & _
		"</tr>" & _
	"</table>"

	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & _
		"<h4><label for=""NUM_NEEDED_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & _
		"<textarea name=""NUM_NEEDED_NOTES""" & _
			" id=""NUM_NEEDED_NOTES""" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>"

	makeNumNeededContents = strReturn
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

	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<h4><label for=""SCHEDULE_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & _
			"<textarea name=""SCHEDULE_NOTES""" & _
			" id=""SCHEDULE_NOTES""" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>"

	makeScheduleContents = strReturn
End Function

Function makeStartDateContents(rst,bUseContent)
	Dim strReturn
	Dim dStartFirst, dStartLast
	
	If bUseContent Then
		dStartFirst = DateString(rst("START_DATE_FIRST"),True)
		dStartLast = DateString(rst("START_DATE_LAST"),True)
	End If
	
	strReturn = _
		"<div class=""form-group"">" & _
			"<label for=""START_DATE_FIRST"" class=""control-label col-sm-4 col-lg-3"">" & TXT_ON_OR_AFTER_DATE & "</label>" & _
			"<div class=""col-sm-8 col-lg-9 form-inline"">" & _
				"<input type=""text"" name=""START_DATE_FIRST"" id=""START_DATE_FIRST"" maxlength=""25"" value=" & AttrQs(dStartFirst) & " class=""DatePicker form-control"">" & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""START_DATE_LAST"" class=""control-label col-sm-4 col-lg-3"">" & TXT_ON_OR_BEFORE_DATE & "</label>" & _
			"<div class=""col-sm-8 col-lg-9 form-inline"">" & _
				"<input type=""text"" name=""START_DATE_LAST"" id=""START_DATE_LAST"" maxlength=""25"" value=" & AttrQs(dStartLast) & " class=""DatePicker form-control"">" & _
			"</div>" & _
		"</div>"

	makeStartDateContents = strReturn
End Function

Function makeAreaOfInterestContents(rst,bUseContent)
	Dim strReturn
	Dim strInterests
	
	If bUseContent Then
		strInterests = rst("INTERESTS")
	End If
	
	strReturn = makeMemoFieldVal("INTERESTS", _
							strInterests, _
							TEXTAREA_ROWS_SHORT, _
							False _
							) & _
		"<br>" & TXT_NOT_SURE_ENTER & " <a href=""javascript:openWin('" & makeLinkB("interestfind.asp") & "','sFind')"">" & TXT_AREA_OF_INTEREST_FINDER & "</a>."
	
	makeAreaOfInterestContents = strReturn
End Function
%>
