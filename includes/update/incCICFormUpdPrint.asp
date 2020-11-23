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
Const WARNING_ICON_HTML = "<span class=""ui-state-error"" style=""background-color: transparent; border: none;""><span class=""ui-icon ui-icon-alert"" style=""display: inline-block; background-color: transparent; border: none; vertical-align: text-top;""></span></span>"

Function getNewNum()
	Dim cmdNewNUM, rsNewNUM
	Set cmdNewNUM = Server.CreateObject("ADODB.Command")
	With cmdNewNUM
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.fn_GBL_LowestUnusedNUM"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@RETURN_VALUE", adVarChar, adParamReturnValue, 8)
		.Parameters.Append .CreateParameter("@Agency", adChar, adParamInput, 3, user_strAgency)
		Set rsNewNUM = .Execute
	End With
	Set rsNewNUM = rsNewNUM.NextRecordset
	If Not Nl(cmdNewNUM.Parameters("@RETURN_VALUE").Value) Then
		getNewNUM = cmdNewNUM.Parameters("@RETURN_VALUE").Value
	End If
	Set rsNewNUM = Nothing
	Set cmdNewNUM = Nothing
End Function

Function makeAccessibilityContents(rst,bUseContent)
	Dim strReturn
	Dim strNUM, strNotes, intNotesLen
	If bUseContent Then
		strNUM = rst.Fields("NUM")
		strNotes = rst.Fields("ACCESSIBILITY_NOTES")
	Else
		strNUM = Null
	End If
	
	Dim cmdAccessibility, rsAccessibility
	Set cmdAccessibility = Server.CreateObject("ADODB.Command")
	With cmdAccessibility
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_NUMAccessibility_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	End With
	Set rsAccessibility = cmdAccessibility.Execute
	
	With rsAccessibility
		While Not .EOF
			strReturn = strReturn & _
				"<div class=""row-border-bottom"">" & _
					"<div class=""row form-group"">" & _
						"<label for=" & AttrQs("AC_ID_" & .FieldS("AC_ID")) & " class=""control-label control-label-left col-md-4"">" & _
							"<input name=""AC_ID"" id=""AC_ID_" & .FieldS("AC_ID") & """ type=""checkbox"" value=" & AttrQs(.Fields("AC_ID")) & Checked(.Fields("IS_SELECTED")) & ">" & _
							.Fields("AccessibilityType") & _
						"</label>" & _
						"<div class=""col-md-8"">"

			If (.Fields("LangID") = g_objCurrentLang.LangID) Then
				strReturn = strReturn & _
							"<input type=""text"" title=" & AttrQs(TXT_NOTES & TXT_COLON & .Fields("AccessibilityType")) & " name=""AC_NOTES_" & .Fields("AC_ID") & """ " & _
								" id=""AC_NOTES_" & .Fields("AC_ID") & """" & _
								" value=""" & .Fields("Notes") & """" & _
								" maxlength=" & AttrQs(MAX_LENGTH_CHECKLIST_NOTES) & _
								" class=""form-control""" & _
							">"
			Else
				strReturn = strReturn
			End If
			strReturn = strReturn & _
						"</div>" & _
					"</div>" & _
				"</div>"
			.MoveNext
		Wend
	End With
	
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & _
		"<div class=""FieldLabelLeftClr""><label for=""ACCESSIBILITY_NOTES"" class=""control-label"">" & TXT_OTHER_NOTES & "</label></div>" & _
		"<textarea name=""ACCESSIBILITY_NOTES"" id=""ACCESSIBILITY_NOTES""" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>" & _

	rsAccessibility.Close
	Set rsAccessibility = Nothing
	Set cmdAccessibility = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeAccessibilityContents = strReturn
End Function

Function makeActivityInfoEntry(dicBTACT, strHeading, strPrefix)
	Dim strReturn
	strReturn = vbNullString

	strReturn = strReturn & "<div class=""EntryFormItemBox"" id=""" & strPrefix & "container"">" & _
		"<div style=""float: right;""><button type=""button"" class=""EntryFormItemDelete ui-state-default ui-corner-all"" id=""" & strPrefix & "DELETE"">" & TXT_DELETE & "</button></div>" & _
		"<h4 class=""EntryFormItemHeader"">" & strHeading & "</h4>" & vbCrLf & _ 
		"<div id=""" & strPrefix & "DISPLAY"" class=""EntryFormItemContent"">" & _
		"<table class=""NoBorder cell-padding-2"">" 
	
	If Not Nl(dicBTACT("BT_ACT_ID")) Then
		strReturn = strReturn & "<tr>" & _
				"<td class=""FieldLabelLeftClr"">" & TXT_UNIQUE_ID & "</td>" & _
				"<td>" & dicBTACT("GUID") & "</td>" & _
			"</tr>"
	End If
	
	strReturn = strReturn & _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_STATUS & "</td>" & _
			"<td>" & makeActivityStatusList(dicBTACT("ASTAT_ID"), strPrefix & "ActivityStatus", False, vbNullString) & "</td>" & _
		"</tr>" & _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_ACTIVITY_INFO_NAME & "</td>" & _
			"<td><input type=""text"" class=""ui-autocomplete-input"" name=""" & strPrefix & "ActivityName"" maxlength=""100"" size=""" & TEXT_SIZE-20 & """ value=""" & Server.HTMLEncode(Ns(dicBTACT("ActivityName"))) & """ id=""" & strPrefix &"activity_name""></td>" & _
		"</tr>" & _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_ACTIVITY_INFO_DESCRIPTION & "</td>" & _
			"<td><textarea name=""" & strPrefix & "ActivityDescription"" cols=""" & TEXTAREA_COLS-15 & """ rows=""" & TEXTAREA_ROWS_SHORT & """ "" id=""" & strPrefix & "activity_description"">" & Server.HTMLEncode(Ns(dicBTACT("ActivityDescription"))) & "</textarea>" & _
		"</tr>" & _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_NOTES & "</td>" & _
			"<td><textarea name=""" & strPrefix & "ActivityNotes"" cols=""" & TEXTAREA_COLS-15 & """ rows=""" & TEXTAREA_ROWS_SHORT & """>" & Server.HTMLEncode(Ns(dicBTACT("Notes"))) & "</textarea></td>" & _
		"</tr>" & _
		"</table></div><div style=""clear: both;""></div></div>"

	makeActivityInfoEntry = strReturn
End Function

Dim bActivityInfoAdded
bActivityInfoAdded = False
Function makeActivityInfoContents(rst, bUseContent)
	bActivityInfoAdded = True
	
	Dim rsActivity, cmdActivity
	If bUseContent Then
		Set cmdActivity = Server.CreateObject("ADODB.Command")
		With cmdActivity
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CIC_NUMActivity_s"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		End With
		Set rsActivity = Server.CreateObject("ADODB.Recordset")
		With rsActivity
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdActivity
		End With
	End If
	

	dim dicFake
	set dicFake = Server.CreateObject("Scripting.Dictionary")
	dicFake("BT_ACT_ID") = vbNullString
	dicFake("ActivityName") = vbNullString
	dicFake("ActivityDescription") = vbNullString
	dicFake("Notes") = vbNullString
	dicFake("ASTAT_ID") = vbNullString

	Call openActivityStatusListRst(True)

	Dim strReturn
	strReturn = "<div id=""ActivityInfoEditArea"" class=""ActivityInfoEditArea EntryFormItemContainer"" data-add-tmpl=" & _
		AttrQs(Server.HTMLEncode(makeActivityInfoEntry(dicFake, TXT_ACTIVITY_NUMBER & "<span class=""EntryFormItemCount"">[COUNT]</span> " & TXT_NEW, "AI_[ID]_"))) & ">"

	Dim strBT_ACT_ID, strBT_ACT_IDCon
	strBT_ACT_ID = vbNullString
	strBT_ACT_IDCon = vbNullString

	If bUseContent Then
		With rsActivity
			If Not .EOF Then
				Dim intCount, intActID
				intCount = 0
				While Not .EOF
					intActID = rsActivity("BT_ACT_ID").Value
					strBT_ACT_ID = strBT_ACT_ID & strBT_ACT_IDCon & intActID
					strBT_ACT_IDCon = ","

					intCount = intCount + 1
					strReturn = strReturn & _
						makeActivityInfoEntry(rsActivity, TXT_ACTIVITY_NUMBER & "<span class=""EntryFormItemCount"">" & intCount & "</span>", "AI_" & intActID & "_")
					.MoveNext
				Wend
			End If
		End With
	End If

	strReturn = strReturn & "<input type=""hidden"" name=""AI_IDS"" class=""EntryFormItemContainerIds"" id=""AI_IDS"" value=" & _
		AttrQs(strBT_ACT_ID) & "></div><button class=""ui-state-default ui-corner-all EntryFormItemAdd"" type=""button"" id=""AI_add_button"">" & TXT_ADD & "</button>" 
	
	If bUseContent Then
		If rsActivity.State <> adStateClosed Then
			rsActivity.Close
		End If
		Set cmdActivity = Nothing
		Set rsActivity = Nothing
	End If

	Call closeActivityStatusListRst()

	Dim strNotes, _
		intNotesLen

	If bUseContent Then
		strNotes = rst.Fields("ACTIVITY_NOTES")
	Else
		strNotes = vbNullString
	End If

	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<h4><label for=""ACTIVITY_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & _
			"<textarea id=""ACTIVITY_NOTES"" name=""ACTIVITY_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			">" & strNotes & "</textarea>"

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If

	makeActivityInfoContents = strReturn
End Function

Dim bSiteAddress
bSiteAddress = False

Function makeAddress(rst,bMail,bUseContent)
	Dim strReturn
	Dim strAddrPrefix
	Dim strCO, _
		strBoxType, _
		strPO, _
		strLine1, _
		strLine2, _
		strBuilding, _
		strNumber, _
		strStreet, _
		strType, _
		bTypeAfter, _
		strDir, _
		strSuffix, _
		strCity, _
		strProv, _
		strCountry, _
		strPC
	
	strAddrPrefix = IIf(bMail,"MAIL_","SITE_")
	
	If bUseContent Then
		If bMail Then
			strCO = rst.Fields("MAIL_CARE_OF")
			strBoxType = rst.Fields("MAIL_BOX_TYPE")
			strPO = rst.Fields("MAIL_PO_BOX")
		End If
		strBuilding = rst(strAddrPrefix & "BUILDING")
		strLine1 = rst(strAddrPrefix & "LINE_1")
		strLine2 = rst(strAddrPrefix & "LINE_2")
		strNumber = rst(strAddrPrefix & "STREET_NUMBER")
		strStreet = rst(strAddrPrefix & "STREET")
		strType = rst(strAddrPrefix & "STREET_TYPE")
		bTypeAfter = rst(strAddrPrefix & "STREET_TYPE_AFTER")
		strDir = rst(strAddrPrefix & "STREET_DIR")
		strSuffix = rst(strAddrPrefix & "SUFFIX")
		strCity = rst(strAddrPrefix & "CITY")
		strProv = rst(strAddrPrefix & "PROVINCE")
		strCountry = rst(strAddrPrefix & "COUNTRY")
		strPC = rst(strAddrPrefix & "POSTAL_CODE")
	End If

	If Not bMail Then
		bSiteAddress = True
	End If

	Call openAddressRecordsets()
	If bMail Then
		strReturn = _
			"<div class=""row form-group"">" & _
				"<label for=""MAIL_CARE_OF"" class=""control-label col-sm-3 col-lg-2"">" & TXT_MAIL_CO & "</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
					"<input type=""text"" name=""MAIL_CARE_OF"" id=""MAIL_CARE_OF"" maxlength=""150"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strCO) & ">"
		If bFeedback Then
			strReturn = strReturn & getFeedback("MAIL_CARE_OF",True)
		End If
		strReturn = strReturn & _
				"</div>" & _
			"</div>"
		strReturn = strReturn & _
			"<div class=""row form-group"">" & _
				"<label for=""MAIL_BOX_TYPE"" class=""control-label col-sm-3 col-lg-2"">" & TXT_BOX_TYPE & "</label>" & _
				"<div class=""col-sm-9 col-lg-3"">" & _
					makeBoxTypeList(strBoxType, "MAIL_BOX_TYPE", True)
		If bFeedback Then
			strReturn = strReturn & getFeedback("MAIL_BOX_TYPE",True)
		End If
		strReturn = strReturn & _
				"</div>" & _
				"<label for=""MAIL_PO_BOX"" class=""control-label col-sm-3 col-lg-3"">" & TXT_BOX_NUMBER & "</label>" & _
				"<div class=""col-sm-9 col-lg-4"">" & _
					"<input type=""text"" name=""MAIL_PO_BOX"" id=""MAIL_PO_BOX"" maxlength=""20"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strPO) & ">"
		If bFeedback Then
			strReturn = strReturn & getFeedback("MAIL_PO_BOX",True)
		End If	
		strReturn = strReturn & _
				"</div>" & _
			"</div>"
	End If

	If Not Nl(strLine1) Or Not Nl(strLine2) Then
		strReturn = strReturn & _
			"<div class=""row form-group"">" & _
				"<label for=""" & strAddrPrefix & "LINE_1"" class=""control-label col-sm-3 col-lg-2"">" & TXT_LINE & " 1</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
					"<input type=""text"" name=""" & strAddrPrefix & "LINE_1"" id=""" & strAddrPrefix & "LINE_1"" maxlength=""255"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strLine1) & ">"
		If bFeedback Then
			strReturn = strReturn & getFeedback(strAddrPrefix & "LINE_1",True)
		End If
		strReturn = strReturn & _
				"</div>" & _
			"</div>" & _
			"<div class=""row form-group"">" & _
				"<label for=""" & strAddrPrefix & "LINE_2"" class=""control-label col-sm-3 col-lg-2"">" & TXT_LINE & " 2</label>" & _
				"<div class=""col-sm-9 col-lg-10"">" & _
					"<input type=""text"" name=""" & strAddrPrefix & "LINE_2"" id=""" & strAddrPrefix & "LINE_2"" maxlength=""255"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strLine2) & ">"
		If bFeedback Then
			strReturn = strReturn & getFeedback(strAddrPrefix & "LINE_2",True)
		End If
		strReturn = strReturn & _
				"</div>" & _
			"</div>"
	End If

	strReturn = strReturn & _
		"<div class=""row form-group"">" & _
			"<label for=""" & strAddrPrefix & "BUILDING"" class=""control-label col-sm-3 col-lg-2"">" & TXT_BUILDING & "</label>" & _
			"<div class=""col-sm-9 col-lg-10"">" & _
				"<input type=""text"" name=""" & strAddrPrefix & "BUILDING"" id=""" & strAddrPrefix & "BUILDING"" maxlength=""150"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strBuilding) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strAddrPrefix & "BUILDING",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""row form-group"">" & _
			"<label for=""" & strAddrPrefix & "STREET_NUMBER"" class=""control-label col-sm-3 col-lg-2"">" & TXT_STREET_NUMBER & "</label>" & _
			"<div class=""col-sm-9 col-lg-10 form-inline"">" & _
				"<input type=""text"" name=""" & strAddrPrefix & "STREET_NUMBER"" id=""" & strAddrPrefix & "STREET_NUMBER"" maxlength=""30"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strNumber) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strAddrPrefix & "STREET_NUMBER",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""row form-group"">" & _
			"<label for=""" & strAddrPrefix & "STREET"" class=""control-label col-sm-3 col-lg-2"">" & TXT_STREET & "</label>" & _
			"<div class=""col-sm-9 col-lg-10"">" & _
				"<input type=""text"" name=""" & strAddrPrefix & "STREET"" id=""" & strAddrPrefix & "STREET"" maxlength=""150"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strStreet) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strAddrPrefix & "STREET",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""row form-group"">" & _
			"<label for=""" & strAddrPrefix & "STREET_TYPE"" class=""control-label col-sm-3 col-md-3 col-lg-2"">" & TXT_STREET_TYPE & "</label>" & _
			"<div class=""col-sm-9 col-md-3 col-lg-4"">" & _
				makeStreetTypeList(strType,bTypeAfter,strAddrPrefix & "STREET_TYPE",True)
	If bFeedback Then
		strReturn = strReturn & getFeedback(strAddrPrefix & "STREET_TYPE",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
			"<label for=""" & strAddrPrefix & "STREET_DIR"" class=""control-label col-sm-3 col-md-3 col-lg-2"">" & TXT_STREET_DIR & "</label>" & _
			"<div class=""col-sm-9 col-md-3 col-lg-4 form-inline"">" & _
				makeStreetDirList(strDir,strAddrPrefix & "STREET_DIR",True)
	If bFeedback Then
		strReturn = strReturn & getFeedback(strAddrPrefix & "STREET_DIR",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""row form-group"">" & _
			"<label for=""" & strAddrPrefix & "SUFFIX"" class=""control-label col-sm-3 col-lg-2"">" & TXT_SUFFIX & "</label>" & _
			"<div class=""col-sm-9 col-lg-10"">" & _
				"<input type=""text"" name=""" & strAddrPrefix & "SUFFIX"" id=""" & strAddrPrefix & "SUFFIX"" maxlength=""150"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strSuffix) & ">" & _
				"<div class=""SmallNote"">" & TXT_SUFFIX_DESC & "</div>"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strAddrPrefix & "SUFFIX",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""row form-group"">" & _
			"<label for=""" & strAddrPrefix & "CITY"" class=""control-label col-sm-3 col-lg-2"">" & TXT_CITY & "</label>" & _
			"<div class=""col-sm-9 col-lg-10"">" & _
				"<input type=""text"" name=""" & strAddrPrefix & "CITY"" id=""" & strAddrPrefix & "CITY"" maxlength=""100"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strCity) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strAddrPrefix & "CITY",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""row form-group"">" & _
			"<label for=""" & strAddrPrefix & "PROVINCE"" class=""control-label col-sm-3 col-md-3 col-lg-2"">" & TXT_PROVINCE & "</label>" & _
			"<div class=""col-sm-9 col-md-3 col-lg-4"">" & _
				"<input type=""text"" name=""" & strAddrPrefix & "PROVINCE"" id=""" & strAddrPrefix & "PROVINCE"" maxlength=""2"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strProv) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strAddrPrefix & "PROVINCE",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
			"<label for=""" & strAddrPrefix & "COUNTRY"" class=""control-label col-sm-3 col-md-3 col-lg-2"">" & TXT_COUNTRY & "</label>" & _
			"<div class=""col-sm-9 col-md-3 col-lg-4"">" & _
				"<input type=""text"" name=""" & strAddrPrefix & "COUNTRY"" id=""" & strAddrPrefix & "COUNTRY"" maxlength=""40"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strCountry) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strAddrPrefix & "COUNTRY",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""row form-group"">" & _
			"<label for=""" & strAddrPrefix & "POSTAL_CODE"" class=""control-label col-sm-3 col-lg-2"">" & TXT_POSTAL_CODE & "</label>" & _
			"<div class=""col-sm-9 col-lg-10 form-inline"">" & _
				"<input type=""text"" name=""" & strAddrPrefix & "POSTAL_CODE"" id=""" & strAddrPrefix & "POSTAL_CODE"" maxlength=""10"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strPC) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strAddrPrefix & "POSTAL_CODE",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>"

	makeAddress = strReturn
End Function

Function makeAltOrgContents(rst,bUseContent,strFieldDisplay)
	Dim strReturn, i
	Dim strNUM
	
	If bUseContent Then
		strNUM = rst.Fields("NUM")
	Else
		strNUM = Null
	End If

	strReturn = "<span class=""SmallNote"">" & TXT_CHECKBOX_FOR_XREF & "</span><br><table class=""NoBorder cell-padding-2 full-width"">"

	If bUseContent Then
		Dim cmdAltOrg, rsAltOrg
		Set cmdAltOrg = Server.CreateObject("ADODB.Command")
		With cmdAltOrg
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_GBL_NUMAltOrg_s"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		End With
		Set rsAltOrg = cmdAltOrg.Execute
		
		With rsAltOrg
			While Not .EOF
				strReturn = strReturn & "<tr>" & _
					"<td><input type=""checkbox"" title=" & AttrQs(TXT_XREF) & " name=""ALT_ORG_PUBLISH_" & .Fields("BT_AO_ID") & """" & IIf(.Fields("PUBLISH")," checked",vbNullString) & "></td>" & _
					"<td class=""table-cell-100""><input type=""hidden"" name=""BT_AO_ID"" value=""" & .Fields("BT_AO_ID") & """>" & _
					"<input type=""text"" name=""ALT_ORG_" & .Fields("BT_AO_ID") & """ value=" & AttrQs(.Fields("ALT_ORG")) & _
						" title=" & AttrQs(TXT_NAME) & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """ class=""form-control""></td>" & _
					"</tr>"
				.MoveNext
			Wend
			.Close
		End With

		Set rsAltOrg = Nothing
		Set cmdAltOrg = Nothing
	End If

	For i = 1 to 3
		strReturn = strReturn & "<tr>" & _
			"<td><input type=""checkbox"" title=" & AttrQs(TXT_XREF) & " name=""NEW_ALT_ORG_PUBLISH_" & i & """></td>" & _
			"<td class=""table-cell-100""><input type=""text"" title=" & AttrQs(TXT_NAME) & " name=""NEW_ALT_ORG_" & i & """ " & _ 
			" maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """ class=""form-control""></td>" & _
			"</tr>"
	Next

	strReturn = strReturn & "</table>"

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If

	makeAltOrgContents = strReturn
End Function

Dim bAreasServed
bAreasServed = False
Function makeAreasServedContents(rst,bUseContent)
	bHasDynamicAddField = True
	bAreasServed = True
	Dim strReturn
	Dim strNUM, strNotes, intNotesLen, bOnlyDisplayNotes
	If bUseContent Then
		strNUM = rst.Fields("NUM")
		strNotes = rst.Fields("AREAS_SERVED_NOTES")
		bOnlyDisplayNotes = rst.Fields("AREAS_SERVED_ONLY_DISPLAY_NOTES")
	Else
		strNUM = Null
	End If
	
	strReturn = TXT_INFO_COMMUNITIES_2
	
	strReturn = strReturn & "<table id=""CM_existing_add_table"" class=""NoBorder cell-padding-2"">"
	If Not Nl(strNUM) Then
		Dim cmdAreasServed, rsAreasServed
		Set cmdAreasServed = Server.CreateObject("ADODB.Command")
		With cmdAreasServed
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CIC_NUMAreasServed_s"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		End With
		Set rsAreasServed = cmdAreasServed.Execute
		
		With rsAreasServed
			While Not .EOF
				strReturn = strReturn & "<tr><td>" & _
					"<label for=""CM_ID_" & .Fields("CM_ID") & """><input name=""CM_ID"" id=""CM_ID_" & .Fields("CM_ID") & """ type=""checkbox"" value=""" & .Fields("CM_ID") & """ checked>&nbsp;" & _
					.Fields("Community") & .Fields("ProvinceState") & StringIf(Not Nl(.Fields("ParentCommunityName")), _
							" (" & TXT_IN & " " & .Fields("ParentCommunityName") & ")") & "</label></td><td>" & _
					"<input type=""text"" title=" & AttrQs(.Fields("Community") & TXT_COLON & TXT_NOTES) & " name=""CM_NOTES_" & .Fields("CM_ID") & """ " & _
					"id=""CM_NOTES_" & .Fields("CM_ID") & """ class=""form-control"" " & _
					"value=""" & .Fields("Notes") & """ " & _
					"size=""" & TEXT_SIZE-25 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """>" & _
					"</td></tr>"
				.MoveNext
			Wend
			.Close
		End With

		Set rsAreasServed = Nothing
		Set cmdAreasServed = Nothing
	End If

	strReturn = strReturn & "</table>"
	strReturn = strReturn & "<h4>" & TXT_ADD_COMMUNITIES & "</h4>" & _
		"<p id=""CM_new_input_table"">" & TXT_INFO_COMMUNITIES_1 & _
		"<a href=""javascript:openWin('" & makeLinkB(ps_strPathToStart & "comfind.asp") & "','cFind')"">" & TXT_COMMUNITY_FINDER & "</a></p>" & _

		"<div class=""entryform-checklist-add-wrapper"">" & _
			"<div class=""entryform-checklist-add-left"">" & _
					"<input type=""text"" id=""NEW_CM"" class=""form-control"">" & _
			"</div>" & _
			"<div class=""entryform-checklist-add-right"">" & _
				"<button type=""button"" class=""btn btn-default"" id=""add_CM"">" & TXT_ADD & "</button>" & _
			"</div>" & _
		"</div>"

	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<div class=""FieldLabelLeftClr""><label for=""AREAS_SERVED_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea name=""AREAS_SERVED_NOTES"" id=""AREAS_SERVED_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea><div><label class=""FieldLabelLeftClr"" for=""AREAS_SERVED_ONLY_DISPLAY_NOTES"">" & TXT_AREAS_SERVED_DISPLAY_ONLY_NOTES & _
			"</label> <input type=""checkbox"" name=""AREAS_SERVED_ONLY_DISPLAY_NOTES"" id=""AREAS_SERVED_ONLY_DISPLAY_NOTES"" value=""1"" " & _
			Checked(bOnlyDisplayNotes) & "></div>"

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeAreasServedContents = strReturn
End Function

Function makeAccreditationContents(rst,bUseContent)
	Dim strReturn, _
		intCurVal
		
	If bUseContent Then
		intCurVal = rst("ACCREDITED")
	Else
		intCurVal = vbNullString
	End If
	
	Call openAccreditationListRst(False, False, intCurVal)
	strReturn = makeAccreditationList(intCurVal, "ACCREDITED", True, vbNullString)
	Call closeAccreditationListRst()
	
	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True)
	End If

	makeAccreditationContents = strReturn
End Function

Function billingAddressEntry(rst, strHeading, strFPrefix, bUseContent)
	Dim strReturn
	
	Dim intAddrType, _
		strCode, _
		dCASConfirmDate, _
		strLine1, _
		strLine2, _
		strLine3, _
		strLine4, _
		strCity, _
		strProv, _
		strCountry, _
		strPC, _
		intMapLink

	If bUseContent Then
		intAddrType = rst.Fields("ADDRTYPE")
		strCode = rst.Fields("SITE_CODE")
		dCASConfirmDate = rst.Fields("CAS_CONFIRMATION_DATE")
		strLine1 = rst.Fields("LINE_1")
		strLine2 = rst.Fields("LINE_2")
		strLine3 = rst.Fields("LINE_3")
		strLine4 = rst.Fields("LINE_4")
		strCity = rst("CITY")
		strProv = rst("PROVINCE")
		strCountry = rst("COUNTRY")
		strPC = rst("POSTAL_CODE")
	Else
		strCountry = strDefaultCountry
	End If

	strReturn = strReturn & "<div class=""EntryFormItemBox"" id=""" & strFPrefix & "container"">" & _
		"<div style=""float: right;""><button type=""button"" class=""EntryFormItemDelete ui-state-default ui-corner-all"" id=""" & strFPrefix & "DELETE"">" & TXT_DELETE & "</button></div>" & _
		"<h4 class=""EntryFormItemHeader"">" & strHeading & "</h4>" & vbCrLf & _
		"<div id=""" & strFPrefix & "DISPLAY"" class=""EntryFormItemContent"">"
	
	If Not Nl(dCASConfirmDate) Then
		dCASConfirmDate = DateString(dCASConfirmDate,True)
		strReturn = strReturn & "<label class=""FieldLabelClr"">" & TXT_CAS_CONFIRMATION_DATE & TXT_COLON & "</label><span class=""Alert"">" & dCASConfirmDate & "</span><br><br>"
	End If
	
	strReturn = strReturn & _
		oaLabel(TXT_ADDRESS_TYPE, strFPrefix & "ADDR_TYPE") & _
		makeBillingAddressTypeList(intAddrType, strFPrefix & "ADDR_TYPE", False)

	If intSiteCodeLength > 0 Then
		strReturn = strReturn & _
			"<br>" & oaField(TXT_SITE_CODE, strFPrefix & "SITE_CODE", strCode, IIf(intSiteCodeLength>TEXT_SIZE,TEXT_SIZE,intSiteCodeLength+1), intSiteCodeLength)
	End If
	
	strReturn = strReturn & _
		"<br>" & oaField(TXT_LINE & " 1", strFPrefix & "LINE_1", strLine1, TEXT_SIZE, 200) & _
		"<br>" & oaField(TXT_LINE & " 2", strFPrefix & "LINE_2", strLine2, TEXT_SIZE, 200) & _
		"<br>" & oaField(TXT_LINE & " 3", strFPrefix & "LINE_3", strLine3, TEXT_SIZE, 200) & _
		"<br>" & oaField(TXT_LINE & " 4", strFPrefix & "LINE_4", strLine4, TEXT_SIZE, 200) & _
		"<br>" & oaField(TXT_CITY, strFPrefix & "CITY", strCity, TEXT_SIZE, 100) & _
		"<br>" & oaFieldAttrs(TXT_PROVINCE, strFPrefix & "PROVINCE", strProv, 2,2, " class=""Province""") & _
		"<br>" & oaField(TXT_COUNTRY, strFPrefix & "COUNTRY", strCountry, 40,40) & _
		"<br>" & oaFieldAttrs(TXT_POSTAL_CODE, strFPrefix & "POSTAL_CODE", strPC, 10,10, "class=""postal""") & _
		"</div><div id=""" & strFPRefix & "DELETED_TITLE""></div><div style=""clear: both;""></div></div>"

	billingAddressEntry = strReturn
End Function

Dim bBillingAddressesAdded
bBillingAddressesAdded = False

Function makeBillingAddressContents(rst,bUseContent)
	bBillingAddressesAdded = True
	bHasDynamicAddField = True

	Dim strReturn, i
	Dim strNUM
	
	If bUseContent Then
		strNUM = rst.Fields("NUM")
	Else
		strNUM = Null
	End If

	Dim strIDs, _
		strIDCon
		
	strIDs = vbNullString
	strIDCon = vbNullString

	Call openBillingAddressTypeListRst()

	strReturn = "<div id=""BA_AddressArea"" class=""EntryFormItemContainer sortable"" data-max-add=""25"" data-add-tmpl=" & _
		AttrQs(Server.HTMLEncode(billingAddressEntry(Null, TXT_ADDRESS_NUMBER & "<span class=""EntryFormItemCount"">[COUNT]</span> " & TXT_NEW, "BA_[ID]_",False))) & ">"
	If bUseContent Then
		Dim cmdBillingAddress, rsBillingAddress
		Set cmdBillingAddress = Server.CreateObject("ADODB.Command")
		With cmdBillingAddress
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_GBL_NUMBillingAddress_s"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		End With
		Set rsBillingAddress = cmdBillingAddress.Execute
		
		With rsBillingAddress
			Dim intAddrID
			Dim intCount
			intCount = 0
			While Not .EOF
				intAddrID = .Fields("BADDR_ID")
				strIDs = strIDs & strIDCon & intAddrID
				strIDCon = ","
				intCount = intCount + 1
				strReturn = strReturn & _
					billingAddressEntry(rsBillingAddress, TXT_ADDRESS_NUMBER & "<span class=""EntryFormItemCount"">" & intCount & "</span>", "BA_" & intAddrID & "_", True)
				.MoveNext
			Wend
			.Close
		End With

		Set rsBillingAddress = Nothing
		Set cmdBillingAddress = Nothing
	End If

	strReturn = strReturn & "<input type=""hidden"" name=""BA_IDS"" class=""EntryFormItemContainerIds"" id=""BA_IDS"" value=" & _
		AttrQs(strIDs) & "></div><button class=""ui-state-default ui-corner-all EntryFormItemAdd"" type=""button"" id=""BA_add_button"">" & TXT_ADD & "</button>" 

	Call closeBillingAddressTypeListRst()

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If

	makeBillingAddressContents = strReturn
End Function


Dim bBusRoutes
bBusRoutes = False
Function makeBusRouteContents(rst,bUseContent)
	bBusRoutes = True
	bHasDynamicAddField = True
	Dim strReturn, _
		strBusRouteList

	Dim strNUM
	If bUseContent Then
		strNUM = rst.Fields("NUM")
	Else
		strNUM = Null
	End If
	
	Dim cmdBusRoute, rsBusRoute
	Set cmdBusRoute = Server.CreateObject("ADODB.Command")
	With cmdBusRoute
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMBusRoute_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	End With
	Set rsBusRoute = cmdBusRoute.Execute
	
	With rsBusRoute
		strReturn = "<table id=""BR_existing_add_table"" class=""NoBorder cell-padding-2"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td>" & _
				"<input name=""BR_ID"" id=""BR_ID_" & .Fields("BR_ID") & """ type=""checkbox"" value=""" & .Fields("BR_ID") & """ checked>&nbsp;" & _
				.Fields("RouteNumber") & _
				StringIf(Not Nl(.Fields("RouteName"))," - " & .Fields("RouteName")) & _
				StringIf(Not Nl(.Fields("Municipality"))," (" & .Fields("Municipality") & ")") & _
				"</td></tr>"
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With

	rsBusRoute.Close
	Set rsBusRoute = Nothing
	Set cmdBusRoute = Nothing
	
	
	Call openBusRouteListRst(False)
	strReturn = strReturn & "<h4>" & TXT_ADD_BUS_ROUTES & "</h4>" & _
		"<div class=""entryform-checklist-add-wrapper"" id=""BR_new_input_table"">" & _
			"<div class=""entryform-checklist-add-left"">" & _
				Replace(makeBusRouteList(vbNullString, "NEW_BR", False, vbNullString), "name=""BR_ID""", vbNullString) & _
			"</div>" & _
			"<div class=""entryform-checklist-add-right"">" & _
				"<button type=""button"" class=""btn btn-default"" id=""add_BR"">" & TXT_ADD & "</button>" & _
			"</div>" & _
		"</div>"
	Call closeBusRouteListRst()
	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeBusRouteContents = strReturn
End Function

Function makeCCLicenseInfoContents(rst,bUseContent)
	Dim strReturn
	Dim strLCNumber, _
		dLCRenewal, _
		intLCTotal, _
		intLCInfant, _
		intLCToddler, _
		intLCPreschool, _
		intLCKindergarten, _
		intLCSchoolAge, _
		strLCNotes, _
		intNotesLen
	
	If bUseContent Then
		strLCNumber = rst("LICENSE_NUMBER")
		dLCRenewal = rst("LICENSE_RENEWAL")
		intLCTotal = rst("LC_TOTAL")
		intLCInfant = rst("LC_INFANT")
		intLCToddler = rst("LC_TODDLER")
		intLCPreschool = rst("LC_PRESCHOOL")
		intLCKindergarten = rst("LC_KINDERGARTEN")
		intLCSchoolAge = rst("LC_SCHOOLAGE")
		strLCNotes = rst("LC_NOTES")
	End If
	
	strReturn = _
		"<div class=""row form-group"">" & _
			"<label for=""LICENSE_NUMBER"" class=""control-label col-sm-3 col-lg-2"">" & TXT_LICENSE_NUMBER & "</label>" & _
			"<div class=""col-sm-9 col-lg-10"">" & _
				"<input type=""text"" name=""LICENSE_NUMBER"" id=""LICENSE_NUMBER"" maxlength=""50"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strLCNumber) & ">" & _
			"</div>" & _
		"</div>" & _
		"<div class=""row form-group"">" & _
			"<label for=""LICENSE_RENEWAL"" class=""control-label col-sm-3 col-lg-2"">" & TXT_LICENSE_RENEWAL & "</label>" & _
			"<div class=""col-sm-9 col-lg-10"">" & _
				makeDateFieldVal("LICENSE_RENEWAL",dLCRenewal,False,False,False,False,False,True) & _
			"</div>" & _
		"</div>" & _
		"<div class=""row form-group"">" & _
			"<label class=""control-label col-sm-3 col-lg-2"">" & TXT_CAPACITY & "</label>" & _
			"<div class=""col-sm-9 col-lg-10"">" & _
				"<table class=""BasicBorder cell-padding-2"">" & _
				"<tr><td class=""FieldLabelLeftClr"">" & TXT_TOTAL & "</td><td>" & _
				"<input type=""text"" name=""LC_TOTAL"" size=""3"" maxlength=""3"" value=""" & intLCTotal & """ class=""form-inline form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("LC_TOTAL",True)
	End If
	strReturn = strReturn & _
				"</td></tr>" & _
				"<tr><td class=""FieldLabelLeftClr"">" & TXT_INFANT & "</td><td>" & _
				"<input type=""text"" name=""LC_INFANT"" size=""3"" maxlength=""3"" value=""" & intLCInfant & """ class=""form-inline form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("LC_INFANT",True)
	End If
	strReturn = strReturn & _
				"</td></tr>" & _
				"<tr><td class=""FieldLabelLeftClr"">" & TXT_TODDLER & "</td><td>" & _
				"<input type=""text"" name=""LC_TODDLER"" size=""3"" maxlength=""3"" value=""" & intLCToddler & """ class=""form-inline form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("LC_TODDLER",True)
	End If
	strReturn = strReturn & _
				"</td></tr>" & _
				"<tr><td class=""FieldLabelLeftClr"">" & TXT_PRESCHOOL & "</td><td>" & _
				"<input type=""text"" name=""LC_PRESCHOOL"" size=""3"" maxlength=""3"" value=""" & intLCPreschool & """ class=""form-inline form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("LC_PRESCHOOL",True)
	End If
	strReturn = strReturn & _
				"</td></tr>" & _
				"<tr><td class=""FieldLabelLeftClr"">" & TXT_KINDERGARTEN & "</td><td>" & _
				"<input type=""text"" name=""LC_KINDERGARTEN"" size=""3"" maxlength=""3"" value=""" & intLCKindergarten & """ class=""form-inline form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("LC_KINDERGARTEN",True)
	End If
	strReturn = strReturn & _
				"</td></tr>" & _
				"<tr><td class=""FieldLabelLeftClr"">" & TXT_SCHOOL_AGE & "</td><td>" & _
				"<input type=""text"" name=""LC_SCHOOLAGE"" size=""3"" maxlength=""3"" value=""" & intLCSchoolAge & """ class=""form-inline form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("LC_SCHOOLAGE",True)
	End If
	strReturn = strReturn & _
				"</td></tr>" & _
				"</table>" & _
			"</div>" & _
		"</div>"

	If Nl(strLCNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strLCNotes)
		strLCNotes = Server.HTMLEncode(strLCNotes)
	End If

	strReturn = strReturn & _
		"<div class=""row form-group"">" & _
			"<label for=""LC_NOTES"" class=""control-label col-sm-3 col-lg-2"">" & TXT_NOTES & "</label>" & _
			"<div class=""col-sm-9 col-lg-10"">" & _
				"<textarea name=""LC_NOTES""" & _
					" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
					" class=""form-control""" & _
					">" & strLCNotes & "</textarea>"
	If bFeedback Then
		strReturn = strReturn & getFeedback("LC_NOTES",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>"
	makeCCLicenseInfoContents = strReturn
End Function

Function makeCertificationContents(rst,bUseContent)
	Dim strReturn, _
		intCurVal
		
	If bUseContent Then
		intCurVal = rst("CERTIFIED")
	Else
		intCurVal = vbNullString
	End If
	
	Call openCertificationListRst(False, False, intCurVal)
	strReturn = makeCertificationList(intCurVal, "CERTIFIED", True, vbNullString)
	Call closeCertificationListRst()
	
	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True)
	End If

	makeCertificationContents = strReturn
End Function

Function csField(strLabelText, strName, strContents)
	Dim strQName
	strQName = AttrQs(strName)
	csField = "<tr><td class=""FieldLabelLeftClr""><label class=""FieldLabelClr"" for=" & strQName & ">" & _
				strLabelText & "</label></td><td>" & strContents & "</td></tr>"
End Function
Function csInput(strLabelText, strName, strValue, strSize, strMaxLength)
	csInput = csInputAttrs(strLabelText, strName, strValue, strSize, strMaxLength, vbNullString)
End Function

Function csInputAttrs(strLabelText, strName, strValue, strSize, strMaxLength, strExtraAttrs)
	Dim strQName
	strQName = AttrQs(strName)
	csInputAttrs = csField(strLabelText, strName, "<input type=""text"" id=" & strQName & _
				" name=" & strQName & " size=""" & strSize & """ maxlength=""" & _
				strMaxLength & """ value=" & AttrQs(strValue) & strExtraAttrs & ">")
End Function

Function contractSignatureEntry(rst, strHeading, strFPrefix, bUseContent)
	Dim strReturn
	
	Dim strSignatory, _
		strNotes, _
		dDate, _
		intSigStatus

	If bUseContent Then
		strSignatory = rst.Fields("SIGNATORY")
		strNotes = rst.Fields("NOTES")
		dDate = rst.Fields("DATE")
		intSigStatus = rst.Fields("SIGSTATUS")
	End If


	strReturn = strReturn & "<div class=""EntryFormItemBox"" id=""" & strFPrefix & "container"">" & _
		"<div style=""float: right;""><button type=""button"" class=""EntryFormItemDelete ui-state-default ui-corner-all"" id=""" & strFPrefix & "DELETE"">" & TXT_DELETE & "</button></div>" & _
		"<h4 class=""EntryFormItemHeader"">" & strHeading & "</h4>" & vbCrLf & _

		"<div id=""" & strFPrefix & "DISPLAY"" class=""EntryFormItemContent"">" & _
		"<table class=""NoBorder cell-padding-2"">" & _

		csInput(TXT_SIGNATORY, strFPrefix & "SIGNATORY", strSignatory, TEXT_SIZE, 255) & _
		csField(TXT_STATUS, strFPrefix & "SIGSTATUS", makeSignatureStatusList(intSigStatus, strFPrefix & "SIGSTATUS", False)) & _
		csInput(TXT_NOTES, strFPrefix & "NOTES", strNotes, TEXT_SIZE, 255) & _
		csInputAttrs(TXT_DATE_SIGNED, strFPrefix & "DATE", DateString(Ns(dDate),True), DATE_TEXT_SIZE, DATE_TEXT_SIZE, "class=""DatePicker""") & _
		"</table></div><div style=""clear: both;""></div></div>"

	contractSignatureEntry = strReturn
End Function

Dim bContractSignatureAdded
bContractSignatureAdded = False

Function makeContractSignatureContents(rst,bUseContent)
	bContractSignatureAdded = True
	bHasDynamicAddField = True

	Dim strReturn, i
	Dim strNUM
	
	If bUseContent Then
		strNUM = rst.Fields("NUM")
	Else
		strNUM = Null
	End If

	Dim strIDs, _
		strIDCon
		
	strIDs = vbNullString
	strIDCon = vbNullString

	Call openSignatureStatusListRst()

	strReturn = "<div id=""CS_ContractArea"" class=""EntryFormItemContainer"" data-add-tmpl=" & _
		AttrQs(Server.HTMLEncode(contractSignatureEntry(Null, TXT_CONTRACT_NUMBER & "<span class=""EntryFormItemCount"">[COUNT]</span> " & TXT_NEW, "CS_[ID]_",False))) & ">"
	If bUseContent Then
		Dim cmdContractSignature, rsContractSignature
		Set cmdContractSignature = Server.CreateObject("ADODB.Command")
		With cmdContractSignature
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_GBL_NUMContractSignature_s"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		End With
		Set rsContractSignature = cmdContractSignature.Execute
		
		With rsContractSignature
			Dim intAddrID
			Dim intCount
			intCount = 0
			While Not .EOF
				intAddrID = .Fields("CTS_ID")
				strIDs = strIDs & strIDCon & intAddrID
				strIDCon = ","
				intCount = intCount + 1
				strReturn = strReturn & _
					contractSignatureEntry(rsContractSignature, TXT_CONTRACT_NUMBER & "<span class=""EntryFormItemCount"">" & intCount & "</span>", "CS_" & intAddrID & "_", True)
				.MoveNext
			Wend
			.Close
		End With

		Set rsContractSignature = Nothing
		Set cmdContractSignature = Nothing
	End If

	strReturn = strReturn & "<input type=""hidden"" name=""CS_IDS"" class=""EntryFormItemContainerIds"" id=""CS_IDS"" value=" & _
		AttrQs(strIDs) & "></div><button class=""ui-state-default ui-corner-all EntryFormItemAdd"" type=""button"" id=""CS_add_button"">" & TXT_ADD & "</button>" 

	Call closeSignatureStatusListRst()

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If

	makeContractSignatureContents = strReturn
End Function

Dim bDistribution
bDistribution = False
Function makeDistributionContents(rst,bUseContent)
	bDistribution = True
	bHasDynamicAddField = True
	Dim strReturn
	Dim strNUM
	If bUseContent Then
		strNUM = rst.Fields("NUM")
	Else
		strNUM = Null
	End If
	
	Dim cmdDistribution, rsDistribution
	Set cmdDistribution = Server.CreateObject("ADODB.Command")
	With cmdDistribution
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMDistribution_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	End With
	Set rsDistribution = cmdDistribution.Execute
	
	strReturn = "<div id=""DST_existing_add_container"">"
	With rsDistribution
		While Not .EOF
			strReturn = strReturn & _
				"<label style=""white-space:nowrap""" & StringIf(Not Nl(.Fields("DistName"))," title=""" & .Fields("DistName") & """") & "><input name=""DST_ID"" id=""DST_ID_" & .Fields("DST_ID") & """ type=""checkbox"" value=""" & .Fields("DST_ID") & """ checked> " & .Fields("DistCode") & "</label> ; "
			.MoveNext
		Wend
	End With
	strReturn = strReturn & "</div>"
	
	strReturn = strReturn & "<h4>" & TXT_ADD_DISTRIBUTIONS & "</h4>" & _
		"<div class=""entryform-checklist-add-wrapper"" id=""DST_new_input_table"">" & _
			"<div class=""entryform-checklist-add-left"">" & _
				"<div class=""row form-group"">" & _
					"<label for=""NEW_DST"" class=""control-label control-label-left col-xs-1"">" & _
						TXT_NAME & _
					"</label>" & _
					"<div class=""col-xs-11""><input type=""text"" id=""NEW_DST"" class=""form-control""></div>" & _
				"</div>" & _
			"</div>" & _
			"<div class=""entryform-checklist-add-right"">" & _
				"<button type=""button"" class=""btn btn-default"" id=""add_DST"">" & TXT_ADD & "</button>" & _
			"</div>" & _
		"</div>"

	rsDistribution.Close
	Set rsDistribution = Nothing
	Set cmdDistribution = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeDistributionContents = strReturn
End Function

Function makeEligibilityContents(rst,bUseContent)
	Dim strReturn
	Dim decMinAge, decMaxAge, strNotes, intNotesLen
	
	If bUseContent Then
		decMinAge = rst.Fields("MIN_AGE")
		decMaxAge = rst.Fields("MAX_AGE")
		strNotes = rst.Fields("ELIGIBILITY_NOTES")
	End If
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	
	strReturn = _
		"<div class=""form-group"">" & _
			"<label for=""MIN_AGE"" class=""control-label col-xs-3"">" & TXT_MIN_AGE & "</label>" & _
			"<div class=""col-xs-9 form-inline"">" & _
				"<input type=""text"" name=""MIN_AGE"" id=""MIN_AGE"" size=""5"" maxlength=""5"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(decMinAge) & "> (" & TXT_IN_YEARS & ")"
	If bFeedback Then
		strReturn = strReturn & getFeedback("MIN_AGE", True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>"

	strReturn = strReturn & _
		"<div class=""form-group"">" & _
			"<label for=""MAX_AGE"" class=""control-label col-xs-3"">" & TXT_MAX_AGE & "</label>" & _
			"<div class=""col-xs-9 form-inline"">" & _
				"<input type=""text"" name=""MAX_AGE"" id=""MAX_AGE"" size=""5"" maxlength=""5"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(decMaxAge) & "> (" & TXT_IN_YEARS & ")"
	If bFeedback Then
		strReturn = strReturn & getFeedback("MAX_AGE", True)
	End If
		strReturn = strReturn & _
			"</div>" & _
		"</div>"

	strReturn = strReturn & _
			"<div class=""FieldLabelLeftClr""><label for=""ELIGIBILITY_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea name=""ELIGIBILITY_NOTES"" id=""ELIGIBILITY_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>"
	If bFeedback Then
		strReturn = strReturn & getFeedback("ELIGIBILITY_NOTES",True)
	End If
	makeEligibilityContents = strReturn
End Function

Function makeEmployeesContents(rst,bUseContent)
	Dim strReturn
	Dim intEmpFt, intEmpPt, intEmpTotal
	
	If bUseContent Then
		intEmpFt = rst("EMPLOYEES_FT")
		intEmpPt = rst("EMPLOYEES_PT")
		intEmpTotal = rst("EMPLOYEES_TOTAL")
	End If
	
	strReturn = _
		"<div class=""form-group row"">" & _
			"<label for=""EMPLOYEES_FT"" class=""control-label col-xs-3"">" & TXT_FULL_TIME & "</label>" & _
			"<div class=""col-xs-9 form-inline"">" & _
				"<input type=""text"" name=""EMPLOYEES_FT"" id=""EMPLOYEES_FT"" size=""6"" maxlength=""6"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(intEmpFt) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("EMPLOYEES_FT",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group row"">" & _
			"<label for=""EMPLOYEES_PT"" class=""control-label col-xs-3"">" & TXT_PART_TIME & "</label>" & _
			"<div class=""col-xs-9 form-inline"">" & _
				"<input type=""text"" name=""EMPLOYEES_PT"" id=""EMPLOYEES_PT"" size=""6"" maxlength=""6"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(intEmpPt) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("EMPLOYEES_PT",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group row"">" & _
			"<label for=""EMPLOYEES_TOTAL"" class=""control-label col-xs-3"">" & TXT_TOTAL_EMPLOYEES & "</label>" & _
			"<div class=""col-xs-9 form-inline"">" & _
				"<input type=""text"" name=""EMPLOYEES_TOTAL"" id=""EMPLOYEES_TOTAL"" size=""6"" maxlength=""6"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(intEmpTotal) & ">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("EMPLOYEES_TOTAL",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>"
		
	makeEmployeesContents = strReturn
End Function

Function makeEmployeesRangeContents(rst,bUseContent)
	Dim strReturn
	Call openEmployeeRangeListRst()
	If bUseContent Then
		strReturn = makeEmployeeRangeList(rst.Fields("EMPLOYEES_RANGE"),"EMPLOYEES_RANGE",True)
	Else
		strReturn = makeEmployeeRangeList(vbNullString,"EMPLOYEES_RANGE",True)
	End If
	Call closeEmployeeRangeListRst()
	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True)
	End If
	makeEmployeesRangeContents = strReturn
End Function

Function makeFiscalYearEndContents(rst,bUseContent)
	Dim strReturn, _
		intCurVal
		
	If bUseContent Then
		intCurVal = rst("FISCAL_YEAR_END")
	Else
		intCurVal = vbNullString
	End If
	
	Call openFiscalYearEndListRst(False, False, intCurVal)
	strReturn = makeFiscalYearEndList(intCurVal, "FISCAL_YEAR_END", True, vbNullString)
	Call closeFiscalYearEndListRst()
	
	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True)
	End If

	makeFiscalYearEndContents = strReturn
End Function

Function makeFeeContents(rst,bUseContent)
	Dim strReturn
	Dim bAssist, strAssistFrom, strAssistFor
	Dim strNUM, strNotes, intNotesLen
	If bUseContent Then
		strNUM = rst.Fields("NUM")
		bAssist = rst.Fields("FEE_ASSISTANCE_AVAILABLE")
		strAssistFrom = rst.Fields("FEE_ASSISTANCE_FROM")
		strAssistFor = rst.Fields("FEE_ASSISTANCE_FOR")
		strNotes = rst.Fields("FEE_NOTES")
	Else
		strNUM = Null
		bAssist = False
	End If
	
	Dim cmdFees, rsFees
	Set cmdFees = Server.CreateObject("ADODB.Command")
	With cmdFees
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMFeeType_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	End With
	Set rsFees = cmdFees.Execute
	
	With rsFees
		While Not .EOF
			strReturn = strReturn & _
				"<div class=""row-border-bottom"">" & _
					"<div class=""row form-group"">" & _
						"<label for=" & AttrQs("FT_ID_" & .FieldS("FT_ID")) & " class=""control-label control-label-left col-md-4"">" & _
							"<input name=""FT_ID"" id=""FT_ID_" & .FieldS("FT_ID") & """ type=""checkbox"" value=" & AttrQs(.Fields("FT_ID")) & Checked(.Fields("IS_SELECTED")) & ">" & _
							.Fields("FeeType") & _
						"</label>" & _
						"<div class=""col-md-8"">"
			If (.Fields("LangID") = g_objCurrentLang.LangID) Then
				strReturn = strReturn & _
							"<input type=""text"" title=" & AttrQs(TXT_NOTES & TXT_COLON & .Fields("FeeType")) & " name=""FT_NOTES_" & .Fields("FT_ID") & """ " & _
								" id=""FT_NOTES_" & .Fields("FT_ID") & """" & _
								" value=""" & .Fields("Notes") & """" & _
								" maxlength=" & AttrQs(MAX_LENGTH_CHECKLIST_NOTES) & _
								" class=""form-control""" & _
							">"
			Else
				strReturn = strReturn
			End If
			strReturn = strReturn & _
						"</div>" & _
					"</div>" & _
				"</div>"
			.MoveNext
		Wend
	End With
	
	strReturn = strReturn & "<h4>" & TXT_FEE_ASSISTANCE_INFO & "</h4>" & _
		"<div class=""row form-group"">" & _
			"<label for=""FEE_ASSISTANCE_AVAILABLE"" class=""control-label col-sm-3 col-lg-2"">" & TXT_AVAILABLE & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""checkbox"" name=""FEE_ASSISTANCE_AVAILABLE"" id=""FEE_ASSISTANCE_AVAILABLE""" & _ 
				IIf(bAssist," checked",vbNullString) & ">" & _
			"</div>" & _
		"</div>" & _

		"<div class=""row form-group"">" & _
			"<label for=""FEE_ASSISTANCE_FOR"" class=""control-label col-sm-3 col-lg-2"">" & TXT_FOR & "</label>" & _
			"<div class=""col-sm-9 col-lg-10"">" & _
				"<input type=""text"" name=""FEE_ASSISTANCE_FOR"" id=""FEE_ASSISTANCE_FOR"" maxlength=""200"" class=""form-control"" value=" & AttrQs(strAssistFor) & ">" & _
			"</div>" & _
		"</div>" & _
		"<div class=""row form-group"">" & _
			"<label for=""FEE_ASSISTANCE_FROM"" class=""control-label col-sm-3 col-lg-2"">" & TXT_PROVIDED_BY & "</label>" & _
			"<div class=""col-sm-9 col-lg-10"">" & _
				"<input type=""text"" name=""FEE_ASSISTANCE_FROM"" id=""FEE_ASSISTANCE_FROM"" maxlength=""200"" class=""form-control"" value=" & AttrQs(strAssistFrom) & ">" & _
			"</div>" & _
		"</div>" 
		


	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<div class=""FieldLabelLeftClr""><label for=""FEE_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea name=""FEE_NOTES"" id=""FEE_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>"

	rsFees.Close
	Set rsFees = Nothing
	Set cmdFees = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeFeeContents = strReturn
End Function

Function makeFormerOrgContents(rst,bUseContent,strFieldDisplay)
	Dim strReturn, i
	Dim strNUM
	
	If bUseContent Then
		strNUM = rst.Fields("NUM")
	Else
		strNUM = Null
	End If

	strReturn = "<span class=""SmallNote"">" & TXT_CHECKBOX_FOR_XREF & "</span><br><table class=""NoBorder cell-padding-2 full-width"">" & _
		"<tr><td>&nbsp;</td><th class=""FieldLabelLeftClr"">" & TXT_NAME & "</th><th class=""FieldLabelLeftClr"">" & TXT_DATE_OF_CHANGE & "</th></tr>"

	If bUseContent Then
		Dim cmdFormerOrg, rsFormerOrg
		Set cmdFormerOrg = Server.CreateObject("ADODB.Command")
		With cmdFormerOrg
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_GBL_NUMFormerOrg_s"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		End With
		Set rsFormerOrg = cmdFormerOrg.Execute
		With rsFormerOrg
			While Not .EOF
				strReturn = strReturn & "<tr>" & _
					"<td><input type=""checkbox"" title=" & AttrQs(TXT_XREF) & " name=""FORMER_ORG_PUBLISH_" & .Fields("BT_FO_ID") & """" & IIf(.Fields("PUBLISH")," checked",vbNullString) & "></td>" & _
					"<td class=""table-cell-100""><input type=""hidden"" name=""BT_FO_ID"" value=""" & .Fields("BT_FO_ID") & """>" & _
					"<input type=""text"" title=" & AttrQs(strFieldDisplay & TXT_COLON & TXT_NAME) & " name=""FORMER_ORG_" & .Fields("BT_FO_ID") & """ value=""" & .Fields("FORMER_ORG") & """ " & _
					" maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """ class=""form-control""></td>" & _
					"<td><div class=""form-inline""><input type=""text"" title=" & AttrQs(strFieldDisplay & TXT_COLON & TXT_DATE_OF_CHANGE) & " name=""FORMER_ORG_DATE_" & .Fields("BT_FO_ID") & """ " & _
					"value=""" & .Fields("DATE_OF_CHANGE") & """ size=""" & 12 & """ maxlength=""20"" class=""form-control""></div></td>" & _
					"</tr>"
				.MoveNext
			Wend
			.Close
		End With

		Set rsFormerOrg = Nothing
		Set cmdFormerOrg = Nothing
	End If

	For i = 1 to 3
		strReturn = strReturn & "<tr>" & _
			"<td><input type=""checkbox"" title=" & AttrQs(TXT_XREF) & " name=""NEW_FORMER_ORG_PUBLISH_" & i & """></td>" & _
			"<td class=""table-cell-100""><input type=""text"" title=" & AttrQs(strFieldDisplay & TXT_COLON & TXT_NAME) & " name=""NEW_FORMER_ORG_" & i & """ " & _
			" maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """ class=""form-control""></td>" & _
			"<td><div class=""form-inline""><input type=""text"" title=" & AttrQs(strFieldDisplay & TXT_COLON & TXT_DATE_OF_CHANGE) & " name=""NEW_FORMER_ORG_DATE_" & i & """ " & _
			"size=""" & 12 & """ maxlength=""20"" class=""form-control""></div></td>" & _
			"</tr>"
	Next

	strReturn = strReturn & "</table>"

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If

	makeFormerOrgContents = strReturn
End Function

Function makeFundingContents(rst,bUseContent)
	Dim strReturn
	Dim strNUM, strNotes, intNotesLen
	If bUseContent Then
		strNUM = rst.Fields("NUM")
		strNotes = rst.Fields("FUNDING_NOTES")
	Else
		strNUM = Null
	End If
	
	Dim cmdFunding, rsFunding
	Set cmdFunding = Server.CreateObject("ADODB.Command")
	With cmdFunding
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMFunding_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	End With
	Set rsFunding = cmdFunding.Execute
	
	With rsFunding
		While Not .EOF
			strReturn = strReturn & _
				"<div class=""row-border-bottom"">" & _
					"<div class=""row form-group"">" & _
						"<label for=" & AttrQs("FD_ID_" & .FieldS("FD_ID")) & " class=""control-label control-label-left col-md-4"">" & _
							"<input name=""FD_ID"" id=""FD_ID_" & .FieldS("FD_ID") & """ type=""checkbox"" value=" & AttrQs(.Fields("FD_ID")) & Checked(.Fields("IS_SELECTED")) & ">" & _
							.Fields("FundingType") & _
						"</label>" & _
						"<div class=""col-md-8"">"

			If (.Fields("LangID") = g_objCurrentLang.LangID) Then
				strReturn = strReturn & _
							"<input type=""text"" title=" & AttrQs(TXT_NOTES & TXT_COLON & .Fields("FundingType")) & " name=""FD_NOTES_" & .Fields("FD_ID") & """ " & _
								" id=""FD_NOTES_" & .Fields("FD_ID") & """" & _
								" value=""" & .Fields("Notes") & """" & _
								" maxlength=" & AttrQs(MAX_LENGTH_CHECKLIST_NOTES) & _
								" class=""form-control""" & _
							">"
			Else
				strReturn = strReturn
			End If
			strReturn = strReturn & _
						"</div>" & _
					"</div>" & _
				"</div>"
			.MoveNext
		Wend
	End With
	
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<div class=""FieldLabelLeftClr""><label for=""FUNDING_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea name=""FUNDING_NOTES"" id=""FUNDING_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>"

	rsFunding.Close
	Set rsFunding = Nothing
	Set cmdFunding = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeFundingContents = strReturn
End Function

Function makeGeneralHeadingFieldVal(rst,bUseContent,intPBID)
	Dim strReturn, strCon
	Dim strName, strGroup, strPrevGroup, intGHID, bTaxonomyHeading, bHasTaxonomyHeading
	Dim xmlDoc, xmlNode, xmlChildNode
	
	strCon = vbNullString
	strPrevGroup = vbNullString
	bHasTaxonomyHeading = False
	
	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With
	
	If bUseContent Then
		xmlDoc.loadXML Nz(rst(strFieldName).Value,"<HEADINGS/>")
	Else
		Dim rsGeneralHeading, cmdGeneralHeading
		Set cmdGeneralHeading = Server.CreateObject("ADODB.Command")
		With cmdGeneralHeading
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CIC_GeneralHeading_s_Entryform"
			.Parameters.Append .CreateParameter("@PB_ID", adInteger, adParamInput, 4, intPBID)
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
		End With
		Set rsGeneralHeading = Server.CreateObject("ADODB.Recordset")
		With rsGeneralHeading
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdGeneralHeading
		End With

		If Not rsGeneralHeading.EOF Then
			xmlDoc.loadXML Nz(rsGeneralHeading("HEADINGS").Value, "<HEADINGS/>")
		Else
			xmlDoc.loadXML "<HEADINGS/>"
		End If

		Call rsGeneralHeading.Close()

		Set rsGeneralHeading = Nothing
		Set cmdGeneralHeading = Nothing
	End If

	Set xmlNode = xmlDoc.selectSingleNode("/HEADINGS")
	If Not xmlNode Is Nothing Then
		For Each xmlChildNode in xmlNode.childNodes
			strName = xmlChildNode.getAttribute("Name")
			strGroup = Nz(xmlChildNode.getAttribute("Group"),vbNullString)
			intGHID = xmlChildNode.getAttribute("ID")
			bTaxonomyHeading = Nl(xmlChildNode.getAttribute("Used"))
			If bTaxonomyHeading Then
				bHasTaxonomyHeading = True
			End If
			If strGroup <> strPrevGroup Then
				If Not Nl(strGroup) Then
					strReturn = strReturn & "<h4>" & strGroup & "</h4>"
					strCon = vbNullString
				End If
				strPrevGroup = strGroup
			End If
			strReturn = strReturn & strCon & _
				"<input type=""checkbox"" name=" & AttrQs(strFieldName) & Checked(xmlChildNode.getAttribute("Selected")) & _
				StringIf(bTaxonomyHeading," disabled") & _
				" id=" & AttrQs(strFieldName & "_" & intGHID) & " value=" & AttrQs(intGHID) & ">&nbsp;<label for=" & AttrQs(strFieldName & "_" & intGHID) & ">" & _
				strName & StringIf(bTaxonomyHeading," <span class=""Alert"">**</span>") & _
				"</label>"
			strCon = vbCrLf & "<br>"
		Next
	End If

	If bFeedback Then
		strReturn = strReturn & "<br>" & getFeedback(strFieldName,False)
	End If

	If bHasTaxonomyHeading Then
		strReturn = strReturn & "<p class=""SmallNote""><span class=""Alert"">**</span> " & TXT_DENOTES_TAXONOMY_HEADING & "</p>"
	End If

	makeGeneralHeadingFieldVal = strReturn
End Function

Dim bHaveGeoCodeUI
bHaveGeoCodeUI = False

Function makeGeoCodeContents(rst,bUseContent)
	Dim strReturn
	Dim intGeoCodeType, intMapPin, decLat, decLong, strNotes

	If Not hasGoogleMapsAPI() Then
		makeGeoCodeContents = "<span class=""Alert"">" & TXT_GEOCODE_NO_MAP_KEY & "</span>"
		Exit Function
	End If

	bHaveGeoCodeUI = True
	
	If bUseContent Then
		intGeoCodeType = rst.Fields("GEOCODE_TYPE")
		intMapPin = rst.Fields("MAP_PIN")
		decLat = rst.Fields("LATITUDE")
		decLong = rst.Fields("LONGITUDE")
		strNotes = rst.Fields("GEOCODE_NOTES")
	Else
		intGeoCodeType = intDefaultGCType
	End If
	
	strReturn = "<div style=""display: none;"" class=""Alert"" id=""geocode_no_postal_code"">" & TXT_GEOCODED_WITHOUT_POSTAL & "</div>" & _
		"<div class=""row clear-line-below"">" & _
			"<div class=""col-md-6"">" & _
				"<div class=""form-group row"">" & _
					"<label class=""control-label col-sm-3 col-md-4"">" & TXT_GEOCODE_USING & "</label>" & _
					"<div class=""col-sm-9 col-md-8"">" & _
						makeGeoCodeTypeList(intGeoCodeType, "GEOCODE_TYPE", False)
	If bFeedback Then
		strReturn = strReturn & getGeoCodeFeedback()
	End If
	strReturn = strReturn & _
					"</div>" & _
				"</div>" & _
				"<div class=""form-group row"">" & _
					"<label for=""LATITUDE"" class=""control-label col-sm-3 col-md-4"">" & TXT_LATITUDE & "</label>" & _
					"<div class=""col-sm-9 col-md-8"">" & _
						"<input type=""text"" name=""LATITUDE"" id=""LATITUDE"" maxlength=""12"" value=" & AttrQs(decLat) & " class=""form-control"" readonly>"
	If bFeedback Then
		strReturn = strReturn & getFeedback("LATITUDE",True)
	End If
	strReturn = strReturn & _
					"</div>" & _
				"</div>" & _
				"<div class=""form-group row"">" & _
					"<label for=""LONGITUDE"" class=""control-label col-sm-3 col-md-4"">" & TXT_LONGITUDE & "</label>" & _
					"<div class=""col-sm-9 col-md-8"">" & _
						"<input type=""text"" name=""LONGITUDE"" id=""LONGITUDE"" maxlength=""12"" value=" & AttrQs(decLong) & " class=""form-control"" readonly>"
	If bFeedback Then
		strReturn = strReturn & getFeedback("LONGITUDE",True)
	End If
	Call openMappingCategoryListRst()
	strReturn = strReturn & _
					"</div>" & _
				"</div>" & _
				"<div class=""form-group row"">" & _
					"<label class=""control-label col-sm-3 col-md-4"" id=""MAP_PIN_LABEL"">" & TXT_MAPPING_CATEGORY & "</label>" & _
					"<div class=""col-sm-9 col-md-8"">"
	With rsListMappingCategory
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			If .RecordCount <> 0 Then
				.MoveFirst
			End If
			strReturn = strReturn & _
						"<div class=""btn-group"" style=""width:100%;"">" & _
						"<a class=""btn btn-default dropdown-toggle "" data-toggle=""dropdown"" href=""#"" id=""dropdownMAP_PIN"" style=""width:100%;""><span class=""selection pull-left"">Select an option </span> " & _
      					"<span class=""pull-right glyphiconglyphicon-chevron-down caret"" style=""float:right;margin-top:10px;""></span></a>" & _

						 "<ul class=""dropdown-menu"" id=""dropdownMAP_PINmenu"" role=""menu"" aria-labelledby=""MAP_PIN_LABEL"">"
			While Not .EOF
				strReturn = strReturn & _
					"<li><a data-value=" & AttrQs(.Fields("MapCatID")) & "><img src=" & AttrQs(ps_strPathToStart & "images/mapping/" & .Fields("MapImageSm")) & _
						 StringIf(Not Nl(.Fields("CategoryName"))," title=" & AttrQs(.Fields("CategoryName"))) & _
					"> " & Server.HTMLEncode(Ns(.Fields("CategoryName"))) & "</a></li>"
				.MoveNext
			Wend
		End If
	End With
	strReturn = strReturn & _
			"</ul> </div><div style=""display: none;""><input type=""hidden"" name=""MAP_PIN"" id=""MAP_PIN"" value=" & AttrQs(intMapPin) & "></div>"

	Call closeMappingCategoryListRst()
	strReturn = strReturn & _
					"</div>" & _
				"</div>" & _
				"<div" & StringIf(intGeocodeType<>GC_MANUAL, " style=""display: none;""") & " id=""map_refresh_ui_area"">[ <span class=""SimulateLink"" id=""map_refresh"">" & TXT_UPDATE_MAP & "</span> ]</div>" & _
			"</div>" & _
			"<div class=""col-md-6""><div id=""map_canvas"" class=""GeocodeRecordUpdate"" style=""margin:auto""></div></div>" & _
		"</div>" & _
		"<div class=""form-group row"">" & _
			"<label for=""GEOCODE_NOTES"" class=""control-label col-sm-3 col-md-2"">" & TXT_NOTES & "</label>" & _
			"<div class=""col-sm-9 col-md-10"">" & _
				"<input type=""text"" name=""GEOCODE_NOTES"" id=""GEOCODE_NOTES"" maxlength=""255"" class=""form-control"" autocomplete=""off"" value=" & AttrQs(strNotes) & ">" & _
			"</div>" & _
		"</div>" & _
		StringIf(bFeedback,getFeedback("GEOCODE_NOTES",True))


	makeGeoCodeContents = strReturn
End Function

Function makeLocationsServicesContents(rst, strFieldName, strAddTitle, strTypeWarning, bUseContent)
	Dim strReturn
	Dim strOrgNum, strName, strRecordNum, bDeleted, bNotType, bSameAgency
	Dim xmlDoc, xmlNode, xmlChildNode
	
	strReturn = "<ul class=""locations-services-list"" data-field-name=""" & strFieldName & """ data-needs-ols-type=""" & IIf(strFieldName="LOCATION_SERVICES", ".ols-type-SITE", ".ols-type-SERVICE,.ols-type-TOPIC") & """>"

	If bUseContent Then
		Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
		With xmlDoc
			.async = False
			.setProperty "SelectionLanguage", "XPath"
		End With
		xmlDoc.loadXML Nz(rst(strFieldName).Value,"<RECORDS/>")

		Set xmlNode = xmlDoc.selectSingleNode("/RECORDS")
		If Not xmlNode Is Nothing Then
			For Each xmlChildNode in xmlNode.childNodes
				strRecordNum = xmlChildNode.getAttribute("NUM")
				strName = xmlChildNode.getAttribute("ORG_NAME")
				bDeleted = xmlChildNode.getAttribute("DELETED") = "1"
				bNotType = xmlChildNode.getAttribute("NOT_TYPE") = "1"
				bSameAgency = xmlChildNode.getAttribute("SAME_AGENCY") = "1"
				strReturn = strReturn & _
					"<li><input type=""checkbox"" name=""" & strFieldName & """ value=" & AttrQs(strRecordNum) & " id=""" & strFieldName & "_" & strRecordNum & """ checked><label for=" & AttrQs(strFieldName & "_" & strRecordNum) & "" & StringIf(bDeleted," class=""AlertStrike""") & "> " & strRecordNum & "</label> <a target=""_blank"" href=" & _
						AttrQs(makeDetailsLink(strRecordNum, vbNullString, vbNullString)) & ">" & Ns(strName) & "</a>" & _
						StringIf(bNotType, " <span class=""Alert"">" & WARNING_ICON_HTML & _
								strTypeWarning & "</span>") & _
						StringIf(bNotType And Not bSameAgency, ";") & _
						StringIf(Not bSameAgency, " <span class=""Alert"">" & WARNING_ICON_HTML & _
								TXT_WRONG_AGENCY_WARNING & "</span>") & _
						"</li>"
			Next
		End If
		
	End If
	strReturn = strReturn & _
		"</ul><h4>" & strAddTitle & "</h4><p class=""locations-services-new-container""><strong>" & TXT_RECORD_NUM & "</strong> <input type=""text"" title=" & AttrQs(TXT_RECORD_NUM) & " class=""locations-services-new"" size=""9"" maxlength=""8"" value=""""> <input type=""button"" class=""locations-services-add"" value=""" & TXT_ADD & """><br>" & TXT_INST_NUM_FINDER & "</p>"

	If bUseContent Then
		Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
		With xmlDoc
			.async = False
			.setProperty "SelectionLanguage", "XPath"
		End With
		xmlDoc.loadXML Nz(rst(strFieldName & "_SUGGESTIONS").Value,"<RECORDS/>")

		Set xmlNode = xmlDoc.selectSingleNode("/RECORDS")
		If Not xmlNode Is Nothing Then
			If xmlNode.childNodes.Length > 0 Then
				strReturn = strReturn & "<ul class=""locations-services-list-suggestions"">"
				For Each xmlChildNode in xmlNode.childNodes
					strRecordNum = xmlChildNode.getAttribute("NUM")
					strName = xmlChildNode.getAttribute("ORG_NAME")
					strReturn = strReturn & _
						"<li><input type=""button"" value=" & AttrQs(strRecordNum) & " id=""" & strFieldName & "_SUGGESTIONS_" & strRecordNum & """ class=""locations-services-suggestion""> <a target=""_blank"" href=" & _
							AttrQs(makeDetailsLink(strRecordNum, vbNullString, vbNullString)) & ">" & Ns(strName) & "</a>" & _
							"</li>"
				Next
				strReturn = strReturn & "</ul>"
			End If
		End If
		
	End If

	makeLocationsServicesContents = strReturn
End Function

Dim bLocatedIn
bLocatedIn = False

Function makeLocatedInContents(rst,bUseContent)
	bLocatedIn = True
	Dim strReturn
	strReturn = vbNullString
	If bUseContent And Not bFeedbackForm Then
		If Not Nl(rsOrg("LOCATED_IN_CM")) Then
			strReturn = "<strong>" & TXT_CURRENT_VALUE & "</strong> " & rsOrg("LOCATED_IN_CM") & rsOrg("LOCATED_IN_CM_PROVINCE_PARENT") & "<br>"
		End If
	End If
	strReturn = strReturn & "<input type=""text"" name=""LOCATED_IN_CM"" id=""LOCATED_IN_CM"" maxlength=""200"" class=""form-control"""
	If bUseContent Then
		If Not bFeedbackForm Then
			strReturn = strReturn & " value=" & AttrQs(rsOrg("LOCATED_IN_CM")) & " data-display=" & AttrQs(rsOrg("LOCATED_IN_CM")) & " data-chkid=" & AttrQs(rsOrg("LOCATED_IN_CM_ID"))
		Else
			strReturn = strReturn & " value=" & AttrQs(rsOrg("LOCATED_IN_CM")) & " data-display=" & AttrQs(rsOrg("LOCATED_IN_CM"))
		End If
	End If
	strReturn = strReturn & ">"
	If Not bFeedbackForm Then
		strReturn = strReturn & "<input type=""hidden"" id=""LOCATED_IN_CM_ID"" name=""LOCATED_IN_CM_ID"" "
		If bUseContent Then
			strReturn = strReturn & " value=" & AttrQs(rsOrg("LOCATED_IN_CM_ID"))
		End If
		strReturn = strReturn & ">"
	End If
	strReturn = strReturn & _
		"<br>" & TXT_NOT_SURE_ENTER & "<a href=""javascript:openWin('" & makeLink(ps_strPathToStart & "comfind.asp","Ln=" & g_objCurrentLang.Culture,"Ln") & "','cFind')"">" & TXT_COMMUNITY_FINDER & "</a>." & _
		StringIf(user_bLoggedIn, "<br>" & TXT_INFO_LOCATED)

	If bFeedback Then
		strReturn = strReturn & getFeedback("LOCATED_IN_CM",True)
	End If
	makeLocatedInContents = strReturn
End Function

Function makeLogoAddressContents(rst, bUseContent)
	Dim strLogoAddress, _
		strLogoLink, _
		strLogoAddressProtocol, _
		strLogoLinkProtocol, _
		strLogoHoverText, _
		strLogoAltText, _
		strReturn
		
	If bUseContent Then
		strLogoAddress = rst("LOGO_ADDRESS").Value
		strLogoLink = rst("LOGO_ADDRESS_LINK").Value
		strLogoAddressProtocol = rst.Fields("LOGO_ADDRESS_PROTOCOL").Value
		strLogoLinkProtocol = rst.Fields("LOGO_ADDRESS_LINK_PROTOCOL").Value
		strLogoHoverText = rst.Fields("LOGO_ADDRESS_HOVER_TEXT").Value
		strLogoAltText = rst.Fields("LOGO_ADDRESS_ALT_TEXT").Value
		If Not Nl(strLogoAltText) Then
			strLogoAltText = Server.HTMLEncode(strLogoAltText)
		End If
	End If

	strReturn = "<div class=""row form-group"">" & _
		"<label for=""LOGO_ADDRESS"" class=""control-label col-md-3"">" & TXT_LOGO_ADDRESS & "</label>" & _
		"<div class=""col-md-9"">" & makeWebFieldVal("LOGO_ADDRESS", strLogoAddress, 200, True, strLogoAddressProtocol) & "</div>" & _
		"</div><div class=""row form-group"">" & _
		"<label for=""LOGO_ADDRESS_LINK"" class=""control-label col-md-3"">" & TXT_LOGO_LINK_ADDRESS & "</label>" & _
		"<div class=""col-md-9"">" & makeWebFieldVal("LOGO_ADDRESS_LINK", strLogoLink, 200, True, strLogoLinkProtocol) & "</div>" & _
		"</div><div class=""row form-group"">" & _
		"<label for=""LOGO_ADDRESS_ALT_TEXT"" class=""control-label col-md-3"">" & TXT_LOGO_ALT_TEXT & "</label>" & _
		"<div class=""col-md-9""><input type=""text"" id=""LOGO_ADDRESS_ALT_TEXT"" name=""LOGO_ADDRESS_ALT_TEXT"" maxlength=""255"" class=""form-control"" value=" & AttrQs(strLogoAltText) & ">"
	
	If bFeedback Then
		strReturn = strReturn & getFeedback("LOGO_ADDRESS_ALT_TEXT",True)
	End If

	strReturn = strReturn & "</div></div><div class=""row form-group"">" & _
		"<label for=""LOGO_ADDRESS_HOVER_TEXT"" class=""control-label col-md-3"">" & TXT_LOGO_HOVER_TEXT & "</label>" & _
		"<div class=""col-md-9""><textarea id=""LOGO_ADDRESS_HOVER_TEXT"" name=""LOGO_ADDRESS_HOVER_TEXT"" rows=""3"" maxlength=""500"" class=""form-control"">" & strLogoHoverText & "</textarea>"

	If bFeedback Then
		strReturn = strReturn & getFeedback("LOGO_ADDRESS_HOVER_TEXT",True)
	End If

	strReturn = strReturn & "</div></div>"

	makeLogoAddressContents = strReturn

End Function

Function makeMainAddressContents(rst,bUseContent)
	Dim strReturn
	Dim bSite, _
		bMail, _
		intAddrID

	If bUseContent Then
		bSite = rst.Fields("MAIN_ADDRESS_SITE")
		bMail = rst.Fields("MAIN_ADDRESS_MAIL")
		intAddrID = rst.Fields("MAIN_ADDRESS_ADDRID")
	Else
		bSite = False
		bMail = False
		intAddrID = Null
	End If
	
	Dim cmdMainAddress, rsMainAddress
	Set cmdMainAddress = Server.CreateObject("ADODB.Command")
	With cmdMainAddress
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMOtherAddress_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	End With
	Set rsMainAddress = cmdMainAddress.Execute
	
	With rsMainAddress
		If Not .EOF Then
			strReturn = "<select name=""MAIN_ADDRESS_ADDRID"" id=""MAIN_ADDRESS_ADDRID"">" & _
				"<option value=""""> -- </option>"
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("ADDR_ID") & """"
				If intAddrID = .Fields("ADDR_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">&nbsp;" & .Fields("Display") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With

	If Not Nl(strReturn) Then
		strReturn = "<br><input type=""radio"" name=""MAIN_ADDRESS_TYPE"" id=""MAIN_ADDRESS_TYPE"" value=""O""" & Checked(Not Nl(intAddrID)) & ">&nbsp;" & strReturn
	End If
	
	strReturn = "<label for=""MAIN_ADDRESS_TYPE_SITE""><input type=""radio"" name=""MAIN_ADDRESS_TYPE"" id=""MAIN_ADDRESS_TYPE_SITE"" value=""S""" & Checked(bSite) & ">&nbsp;" & TXT_SITE_ADDRESS & "</label>" & _
		"<br><label for=""MAIN_ADDRESS_TYPE_MAILING""><input type=""radio"" name=""MAIN_ADDRESS_TYPE"" id=""MAIN_ADDRESS_TYPE_MAILING"" value=""M""" & Checked(bMail) & ">&nbsp;" & TXT_MAIL_ADDRESS & "</label>" & _
		strReturn

	rsMainAddress.Close
	Set rsMainAddress = Nothing
	Set cmdMainAddress = Nothing

	makeMainAddressContents = strReturn
End Function

Function makeMappingSystemContents(rst,bUseContent)
	Dim strReturn
	Dim strNUM
	If bUseContent Then
		strNUM = rst.Fields("NUM")
	Else
		strNUM = Null
	End If
	
	Dim cmdMappingSystem, rsMappingSystem
	Set cmdMappingSystem = Server.CreateObject("ADODB.Command")
	With cmdMappingSystem
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_NUMMappingSystem_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	End With
	Set rsMappingSystem = cmdMappingSystem.Execute
	
	With rsMappingSystem
		strReturn = "<table class=""NoBorder cell-padding-2"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td>" & _
				"<label for=""MAP_ID_" & .Fields("MAP_ID") & """><input name=""MAP_ID"" id=""MAP_ID_" & .Fields("MAP_ID") & """ type=""checkbox"" value=""" & .Fields("MAP_ID") & """"
			If .Fields("IS_SELECTED") Then
				strReturn = strReturn & " checked"
			End If
			strReturn = strReturn & ">&nbsp;" & .Fields("Name") & "</label></td></tr>"
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With

	rsMappingSystem.Close
	Set rsMappingSystem = Nothing
	Set cmdMappingSystem = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeMappingSystemContents = strReturn
End Function

Function makeMembershipTypeContents(rst,bUseContent)
	Dim strReturn
	Dim strNUM, strNotes, intNotesLen
	If bUseContent Then
		strNUM = rst.Fields("NUM")
		strNotes = rst.Fields("MEMBERSHIP_NOTES")
	Else
		strNUM = Null
	End If
	
	Dim cmdMembershipType, rsMembershipType
	Set cmdMembershipType = Server.CreateObject("ADODB.Command")
	With cmdMembershipType
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMMembershipType_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	End With
	Set rsMembershipType = cmdMembershipType.Execute
	
	With rsMembershipType
		While Not .EOF
			strReturn = strReturn & _
				"<div class=""row-border-bottom"">" & _
					"<div class=""row form-group"">" & _
						"<label for=" & AttrQs("MT_ID_" & .FieldS("MT_ID")) & " class=""control-label control-label-left col-md-12"">" & _
							"<input name=""MT_ID"" id=""MT_ID_" & .FieldS("MT_ID") & """ type=""checkbox"" value=" & AttrQs(.Fields("MT_ID")) & Checked(.Fields("IS_SELECTED")) & ">" & _
							.Fields("MembershipType") & _
						"</label>" & _
					"</div>" & _
				"</div>"
			.MoveNext
		Wend
	End With
	
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<div class=""FieldLabelLeftClr""><label for=""MEMBERSHIP_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea name=""MEMBERSHIP_NOTES"" id=""MEMBERSHIP_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>"

	rsMembershipType.Close
	Set rsMembershipType = Nothing
	Set cmdMembershipType = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeMembershipTypeContents = strReturn
End Function

Function makeNAICSContents(rst,bUseContent)
	Dim strReturn, _
		strNAICS
	
	If bUseContent Then
		strNAICS = rst.Fields("NAICS").Value
	End If
	
	strReturn = "<div class=""SmallNote"">Use a single, 6-digit code whenever possible. If you must use multiple codes, separate with semi-colon (;)</div>" & _
		"<input type=""text"" name=""NAICS"" id=""NAICS"" size=""" & TEXT_SIZE & """ maxlength=""100"" value=" & AttrQs(strNAICS) & " class=""form-control"">" & _
		"<p>" & TXT_NOT_SURE_ENTER & " <a href=""javascript:openWin('" & makeLinkB("naicsfind.asp") & "','nFind')"">" & TXT_NAICS_FINDER & "</a>.</p>"
	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If

	makeNAICSContents = strReturn
End Function

Function makeOrgLocationServiceContents(rst,bUseContent)
	Dim strReturn
	Dim strNUM
	If bUseContent Then
		strNUM = rst.Fields("NUM")
	Else
		strNUM = Null
	End If
	
	Dim cmdExtraCheckList, rsExtraCheckList
	Set cmdExtraCheckList = Server.CreateObject("ADODB.Command")
	With cmdExtraCheckList
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_NUMOrgLocationService_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	End With
	Set rsExtraCheckList = cmdExtraCheckList.Execute
	
	With rsExtraCheckList
		strReturn = "<table class=""NoBorder cell-padding-2"" id=""OLS_SELECT"">"
		While Not .EOF
			strReturn = strReturn & "<tr><td>" & _
				"<label><input name=""OLS_ID"" id=""OLS_ID_" & .Fields("OLS_ID") & """ type=""checkbox"" value=""" & _
					.Fields("OLS_ID") & """ class=""ols-check ols-type-" & .Fields("Code") & """" 
			If .Fields("IS_SELECTED") Then
				strReturn = strReturn & " checked"

				If .Fields("CANT_UNSELECT") Then
					strReturn = strReturn & " disabled"
				End If
			End If
			strReturn = strReturn & " data-maybe-required=""" & IIf(.Fields("CANT_UNSELECT"), "true", "false") & """>&nbsp;" & .Fields("OrgLocationService") & "</label>"
			If .Fields("CANT_UNSELECT") Then
				If .Fields("IS_SELECTED") Then
					strReturn = strReturn & "<input type=""hidden"" name=""OLS_ID"" id=""OLS_ID_" & .Fields("OLS_ID") & "_forceon"" value=""" & .Fields("OLS_ID") & """>"
				ElseIf .Fields("Code") <> "TOPIC" Then
					
					strReturn = strReturn & StringIf(.Fields("Code") = "SERVICE", "<span style=""display: none"" id=""ols-type-SERVICE-warning"">") & " <span class=""Alert"">" & WARNING_ICON_HTML & _
						TXT_OLS_USE_WARNING & "</span>" & StringIf(.Fields("Code")="SERVICE", "</span>")
				End If
			End If

			strReturn = strReturn & "</td></tr>"
			.MoveNext
		Wend
		strReturn = strReturn & "</table>"
	End With

	rsExtraCheckList.Close
	Set rsExtraCheckList = Nothing
	Set cmdExtraCheckList = Nothing

	'If bFeedback Then
	'	strReturn = strReturn & getFeedback(strFieldName,False)
	'End If
	makeOrgLocationServiceContents = strReturn
End Function

Function makeOrgNameContents(rst,strName,strPublish,bUseContent)
	Dim strReturn
	Dim bPublish,strOrg
	
	If bUseContent Then
		strOrg = rst(strName)
		bPublish = rst(strPublish)
	End If
	
	strReturn = "<span class=""SmallNote"">" & TXT_CHECKBOX_FOR_XREF & "</span><br><table class=""NoBorder cell-padding-2 full-width""><tr>" & _
		"<td><input type=""checkbox"" title=" & AttrQs(TXT_XREF) & " name=""" & strPublish & """" & IIf(bPublish," checked",vbNullString) & "></td>" & _
		"<td class=""table-cell-100""><input type=""text"" id=""" & strName & """ name=""" & strName & """ maxlength=""200"" class=""form-control"" value=" & AttrQs(strOrg) & "></td>" & _
		"</tr></table>"

	If bFeedback Then
		strReturn = strReturn & getFeedback(strName,True)
	End If

	makeOrgNameContents = strReturn
End Function

Function makeLocationNameContents(rst,bUseContent)
	Dim strReturn
	Dim bHideName,strOrg
	
	If bUseContent Then
		strOrg = rst("LOCATION_NAME")
		bHideName = Not rst("DISPLAY_LOCATION_NAME")
	End If
	
	strReturn = _
		"<div class=""clear-line-below"">" & _
			"<input type=""text"" id=""LOCATION_NAME"" name=""LOCATION_NAME"" maxlength=""200"" value=" & AttrQs(strOrg) & " class=""form-control"">" & _
		"</div>"

	If bFeedback Then
		strReturn = strReturn & getFeedback("LOCATION_NAME",True)
	End If

	strReturn = strReturn & _
		"<div class=""checkbox"">" & _
			"<label for=""HIDE_LOCATION_NAME""><input type=""checkbox"" name=""HIDE_LOCATION_NAME"" id=""HIDE_LOCATION_NAME""" & Checked(bHideName) & ">" & TXT_CHECKBOX_FOR_NAME_HIDE & "</label>" & _
		"</div>"



	makeLocationNameContents = strReturn
End Function

Function makeOrgNumContents(rst, bUseContent)
	Dim strReturn
	Dim strOrgNum, bIsAgency, bDisplayOrgName, strName, strSuggestNum, strRecordType, strFullAgencyWarning
	Dim xmlDoc, xmlNode, xmlChildNode
	
	bIsAgency = False
	bDisplayOrgName = False
	If bUseContent Then
		strOrgNum = rst("ORG_NUM")
		bIsAgency = rst("ORG_NUM_IS_AGENCY") = "1"
		bDisplayOrgName = rst("DISPLAY_ORG_NAME")
	End If

	strFullAgencyWarning = " <span class=""Alert"">" & WARNING_ICON_HTML & TXT_AGENCY_WARNING & "</span>"
	
	strReturn = "<input type=""text"" id=""ORG_NUM"" name=""ORG_NUM"" size=""9"" maxlength=""8"" class=""record-num form-control form-inline clear-line-below"" value=" & AttrQs(strOrgNum) & ">" & _
		StringIf(Not bIsAgency And Not Nl(strOrgNum), strFullAgencyWarning) & _
		"<div class=""clear-line-below""><div class=""checkbox""><label for=""DISPLAY_ORG_NAME""><input type=""checkbox"" id=""DISPLAY_ORG_NAME"" name=""DISPLAY_ORG_NAME""" & Checked(bDisplayOrgName) & ">" & TXT_DISPLAY_ORG_NAME & "</label></div></div>"

	If bUseContent Then
		Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
		With xmlDoc
			.async = False
			.setProperty "SelectionLanguage", "XPath"
		End With
		xmlDoc.loadXML Nz(rst("ORG_NUM_SUGGESTIONS").Value,"<records/>")

		Set xmlNode = xmlDoc.selectSingleNode("/records")
		If Not xmlNode Is Nothing Then
			For Each xmlChildNode in xmlNode.childNodes
				strSuggestNum = xmlChildNode.getAttribute("NUM")
				strName = xmlChildNode.getAttribute("ORG_NAME")
				bIsAgency = xmlChildNode.getAttribute("IS_AGENCY") = "1"
				strReturn = strReturn & _
					"<div class=""row clear-line-below"">" & _
						"<div class=""col-xs-4 col-sm-3 col-md-2"">" & _
							"<input type=""button"" value=" & AttrQs(strSuggestNum) & " class=""suggested-num btn btn-default full-width"">" & _
						"</div>" & _
						"<div class=""col-xs-8 col-sm-9 col-md-10"">" & _
							"<a target=""_blank"" href=" & AttrQs(makeDetailsLink(strSuggestNum, vbNullString, vbNullString)) & ">" & Ns(strName) & "</a> " & _
								StringIf(Not bIsAgency, strFullAgencyWarning) & _
						"</div>" & _
					"</div>"
			Next
		End If
	End If

	makeOrgNumContents = strReturn
End Function

Function oaLabel(strLabelText, strName)
	Dim strQName
	strQName = AttrQs(strName)
	oaLabel = "<label class=""FieldLabelClr"" for=" & strQName & ">" & _
				strLabelText & "</label><br>"
End Function

Function oaField(strLabelText, strName, strValue, strSize, strMaxLength)
	oaField = oaFieldAttrs(strLabelText, strName, strValue, strSize, strMaxLength, vbNullString)
End Function

Function oaFieldAttrs(strLabelText, strName, strValue, strSize, strMaxLength, strExtraAttrs)
	Dim strQName
	strQName = AttrQs(strName)
	oaFieldAttrs = oaLabel(strLabelText, strName) &"<input type=""text"" id=" & strQName & _
				"class=""form-control"" name=" & strQName & " size=""" & strSize & """ maxlength=""" & _
				strMaxLength & """ value=" & AttrQs(strValue) & strExtraAttrs & ">"
End Function

Function otherAddressEntry(rst, strHeading, strFPrefix, bUseContent)
	Dim strReturn
	
	Dim strTitle, _
		strCode, _
		strCO, _
		strBoxType, _
		strPO, _
		strBuilding, _
		strNum, _
		strStreet, _
		strType, _
		bTypeAfter, _
		strDir, _
		strSuffix, _
		strCity, _
		strProv, _
		strCountry, _
		strPC, _
		decLat, _
		decLong, _
		intMapLink

	If bUseContent Then
		strTitle = rst.Fields("TITLE")
		strCode = rst.Fields("SITE_CODE")
		strCO = rst.Fields("CARE_OF")
		strBoxType = rst.Fields("BOX_TYPE")
		strPO = rst.Fields("PO_BOX")
		strBuilding = rst("BUILDING")
		strNum = rst("STREET_NUMBER")
		strStreet = rst("STREET")
		strType = rst("STREET_TYPE")
		bTypeAfter = rst("STREET_TYPE_AFTER")
		strDir = rst("STREET_DIR")
		strSuffix = rst("SUFFIX")
		strCity = rst("CITY")
		strProv = rst("PROVINCE")
		strCountry = rst("COUNTRY")
		strPC = rst("POSTAL_CODE")
		decLat = rst.Fields("LATITUDE")
		decLong = rst.Fields("LONGITUDE")
		intMapLink = rst("MAP_LINK")
	Else
		strCountry = strDefaultCountry
	End If

	Call openAddressRecordsets()

	strReturn = strReturn & "<div class=""EntryFormItemBox"" id=""" & strFPrefix & "container"">" & _
		"<div style=""float: right;""><button type=""button"" class=""EntryFormItemDelete ui-state-default ui-corner-all"" id=""" & strFPrefix & "DELETE"">" & TXT_DELETE & "</button></div>" & _
		"<h4 class=""EntryFormItemHeader"">" & strHeading & "</h4>" & vbCrLf & _

		"<div id=""" & strFPrefix & "DISPLAY"" class=""EntryFormItemContent"">" & _
		oaField(TXT_OTHER_ADDRESS_TITLE, strFPrefix & "TITLE", strTitle, TEXT_SIZE, 100)
	If intSiteCodeLength > 0 Then
		strReturn = strReturn & _
			"<br>" & oaField(TXT_SITE_CODE, strFPrefix & "SITE_CODE", strCode, IIf(intSiteCodeLength>TEXT_SIZE,TEXT_SIZE,intSiteCodeLength+1), intSiteCodeLength)
	End If
	strReturn = strReturn & _
		"<br>" & oaField(TXT_MAIL_CO, strFPrefix & "CARE_OF", strCO, TEXT_SIZE, 150) & _
		"<br>" & oaLabel(TXT_BOX_TYPE, strFPrefix & "BOX_TYPE") & makeBoxTypeList(strBoxType, strFPrefix & "BOX_TYPE", True) & _
		"<br>" & oaField(TXT_BOX_NUMBER, strFPrefix & "PO_BOX", strPO, 20, 20) & _
		"<br>" & oaField(TXT_BUILDING, strFPrefix & "BUILDING", strBuilding, TEXT_SIZE, 150) & _
		"<br>" & oaField(TXT_STREET_NUMBER, strFPrefix & "STREET_NUMBER", strNum, 10, 30) & _
		"<br>" & oaField(TXT_STREET, strFPrefix & "STREET", strStreet, TEXT_SIZE-20, 150) & _
		"<br>" & oaLabel(TXT_STREET_TYPE, strFPrefix & "STREET_TYPE") & makeStreetTypeList(strType, bTypeAfter, strFPrefix & "STREET_TYPE", True) & _
		"<br>" & oaLabel(TXT_STREET_DIR, strFPrefix & "STREET_DIR") & makeStreetDirList(strDir, strFPrefix & "STREET_DIR", True) & _
		"<br>" & oaField(TXT_SUFFIX, strFPrefix & "SUFFIX", strSuffix, TEXT_SIZE, 150) & _
		"<br>" & oaField(TXT_CITY, strFPrefix & "CITY", strCity, TEXT_SIZE, 100) & _
		"<br>" & oaFieldAttrs(TXT_PROVINCE, strFPrefix & "PROVINCE", strProv, 2,2, " class=""Province""") & _
		"<br>" & oaField(TXT_COUNTRY, strFPrefix & "COUNTRY", strCountry, 40,40) & _
		"<br>" & oaFieldAttrs(TXT_POSTAL_CODE, strFPrefix & "POSTAL_CODE", strPC, 10,10, "class=""postal""") & _
		"<br>" & oaField(TXT_LATITUDE, strFPrefix & "LATITUDE", CStr(Nz(decLat,vbNullString)), 12, 12) & _
		"<br>" & oaField(TXT_LONGITUDE, strFPrefix & "LONGITUDE", CStr(Nz(decLong,vbNullString)), 12, 12) & _
		"<br>" & oaLabel(TXT_MAP_LINK, strFPrefix & "MAP_LINK") & makeMappingSystemList(intMapLink, strFPrefix & "MAP_LINK", True, False, vbNullString) & _
		"</div><div id=""" & strFPRefix & "DELETED_TITLE""></div><div style=""clear: both;""></div></div>"

	otherAddressEntry = strReturn
End Function

Dim bOtherAddressesAdded
bOtherAddressesAdded = False

Function makeOtherAddressContents(rst,bUseContent)
	bOtherAddressesAdded = True
	bHasDynamicAddField = True

	Dim strReturn, i
	Dim strNUM
	
	If bUseContent Then
		strNUM = rst.Fields("NUM")
	Else
		strNUM = Null
	End If

	Dim strIDs, _
		strIDCon
		
	strIDs = vbNullString
	strIDCon = vbNullString

	strReturn = "<div id=""OA_AddressArea"" class=""EntryFormItemContainer"" data-add-tmpl=" & _
		AttrQs(Server.HTMLEncode(otherAddressEntry(Null, TXT_ADDRESS_NUMBER & "<span class=""EntryFormItemCount"">[COUNT]</span> " & TXT_NEW, "OA_[ID]_",False))) & ">"
	If bUseContent Then
		Dim cmdOtherAddress, rsOtherAddress
		Set cmdOtherAddress = Server.CreateObject("ADODB.Command")
		With cmdOtherAddress
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CIC_NUMOtherAddress_s"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		End With
		Set rsOtherAddress = cmdOtherAddress.Execute
		
		With rsOtherAddress
			Dim intAddrID
			Dim intCount
			intCount = 0
			While Not .EOF
				intAddrID = .Fields("ADDR_ID")
				strIDs = strIDs & strIDCon & intAddrID
				strIDCon = ","
				intCount = intCount + 1
				strReturn = strReturn & _
					otherAddressEntry(rsOtherAddress, TXT_ADDRESS_NUMBER & "<span class=""EntryFormItemCount"">" & intCount & "</span>", "OA_" & intAddrID & "_", True)
				.MoveNext
			Wend
			.Close
		End With

		Set rsOtherAddress = Nothing
		Set cmdOtherAddress = Nothing
	End If

	strReturn = strReturn & "<input type=""hidden"" name=""OA_IDS"" class=""EntryFormItemContainerIds"" id=""OA_IDS"" value=" & _
		AttrQs(strIDs) & "></div><button class=""ui-state-default ui-corner-all EntryFormItemAdd"" type=""button"" id=""OA_add_button"">" & TXT_ADD & "</button>" 

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If

	makeOtherAddressContents = strReturn
End Function

Function makePaymentTermsContents(rst,bUseContent)
	Dim strReturn, _
		intCurVal
		
	If bUseContent Then
		intCurVal = rst("PAYMENT_TERMS")
	Else
		intCurVal = vbNullString
	End If
	
	Call openPaymentTermsListRst(False, False,intCurVal)
	strReturn = makePaymentTermsList(intCurVal,"PAYMENT_TERMS",True, vbNullString)
	Call closePaymentTermsListRst()

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True)
	End If

	makePaymentTermsContents = strReturn
End Function

Function makePrefCurrencyContents(rst,bUseContent)
	Dim strReturn, _
		intCurVal
		
	If bUseContent Then
		intCurVal = rst("PREF_CURRENCY")
	Else
		intCurVal = vbNullString
	End If
	
	Call openCurrencyListRst(False)
	strReturn = makeCurrencyList(intCurVal,"PREF_CURRENCY",True, vbNullString)
	Call closeCurrencyListRst()

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True)
	End If

	makePrefCurrencyContents = strReturn
End Function

Function makePrefPaymentMethodContents(rst,bUseContent)
	Dim strReturn, _
		intCurVal
		
	If bUseContent Then
		intCurVal = rst("PREF_PAYMENT_METHOD")
	Else
		intCurVal = vbNullString
	End If
	
	Call openPaymentMethodListRst(False,False,intCurVal)
	strReturn = makePaymentMethodList(intCurVal,"PREF_PAYMENT_METHOD",True, vbNullString)
	Call closePaymentMethodListRst()

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True)
	End If

	makePrefPaymentMethodContents = strReturn
End Function

Function makeQualityContents(rst,bUseContent)
	Dim strReturn, _
		intCurVal
		
	If bUseContent Then
		intCurVal = rst.Fields("QUALITY").Value
	Else
		intCurVal = vbNullString
	End If
	Call openQualityListRst(False,intCurVal)
	If bUseContent Then
		strReturn = makeQualityList(intCurVal,"QUALITY",True,vbNullString)
	Else
		strReturn = makeQualityList(vbNullString,"QUALITY",True,vbNullString)
	End If
	Call closeQualityListRst()
	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True)
	End If
	makeQualityContents = strReturn
End Function

Function makeRecordPrivacyContents(rst,bUseContent)
	Dim bPrivacyProfiles, _
		strUpdatePassword, _
		bUpdatePasswordRequired, _
		intCurrentValue, _
		strReturn
	
	bPrivacyProfiles = False
	intCurrentValue = Null

	If bUseContent Then
		intCurrentValue = rst.Fields("PRIVACY_PROFILE").Value
	End If

	Call openPrivacyProfileListRst(intCurrentValue)
	If rsListPrivacyProfile.RecordCount > 0 Then
		bPrivacyProfiles = True
		strReturn = strReturn & _
			"<div class=""row form-group"">" & _
				"<label for=""PRIVACY_PROFILE"" class=""control-label col-sm-6 col-md-4"">" & TXT_PRIVACY_PROFILE & "</label>" & _
				"<div class=""col-sm-6 col-md-8"">"
		If bUseContent Then
			strReturn = strReturn & makePrivacyProfileList(intCurrentValue, "PRIVACY_PROFILE", True)
		Else
			strReturn = strReturn & makePrivacyProfileList(vbNullString, "PRIVACY_PROFILE", True)
		End If
		strReturn = strReturn & _
				"</div>" & _
			"</div>"
		Call closePrivacyProfileListRst()
	End If

	If bUseContent Then
		strUpdatePassword = rsOrg("UPDATE_PASSWORD")
		bUpdatePasswordRequired = rsOrg("UPDATE_PASSWORD_REQUIRED")
	Else
		strUpdatePassword = Null
		bUpdatePasswordRequired = Null
	End If
	
	strReturn = strReturn & _
		"<div class=""row form-group"">" & _
			"<label for=""UPDATE_PASSWORD"" class=""control-label col-sm-6 col-md-4"">" & TXT_UPDATE_PASSWORD & "</label>" & _
			"<div class=""col-sm-6 col-md-8"">" & _
				makeTextFieldVal("UPDATE_PASSWORD", strUpdatePassword, 20, False) & _
			"</div>" & _
		"</div>" & _
		"<div class=""row form-group"">" & _
			"<label class=""control-label col-sm-6 col-md-4"">" & TXT_UPDATE_PASSWORD_REQUIRED & "</label>" & _
			"<div class=""col-sm-6 col-md-8"">" & _
				"<label for=""UPDATE_PASSWORD_REQUIRED_NO""><input type=""radio"" name=""UPDATE_PASSWORD_REQUIRED"" id=""UPDATE_PASSWORD_REQUIRED_NO"" value=""""" & _
					Checked(Nl(bUpdatePasswordRequired)) & ">" & TXT_NO & "</label>" & vbCrLf & _
				"<label for=""UPDATE_PASSWORD_REQUIRED_ALL""><input type=""radio"" name=""UPDATE_PASSWORD_REQUIRED"" id=""UPDATE_PASSWORD_REQUIRED_ALL"" value=" & AttrQs(SQL_TRUE) & _
					Checked(bUpdatePasswordRequired) & ">" & TXT_UPDATE_PASSWORD_ON_ALL_INFO & "</label>" & vbCrLf & _
				"<label for=""UPDATE_PASSWORD_REQUIRED_PRIVATE""><input type=""radio"" name=""UPDATE_PASSWORD_REQUIRED"" id=""UPDATE_PASSWORD_REQUIRED_PRIVATE"" value=" & AttrQs(SQL_FALSE) & _
					Checked(Not bUpdatePasswordRequired) & ">" & TXT_UPDATE_PASSWORD_ON_PRIVATE_INFO & "</label>" & _
			"</div>" & _
		"</div>"

	makeRecordPrivacyContents = strReturn
End Function

Function makeRecordTypeContents(rst,bUseContent)
	Dim strReturn, _
		intCurVal, _
		strLimit

	If Not bFeedbackForm And bUseContent Then
		strLimit = Not rst.Fields("LIMIT_RECORDTYPE")
	End If
		
	If bUseContent Then
		intCurVal = rst.Fields("RECORD_TYPE").Value
	Else
		intCurVal = vbNullString
	End If

	Call openRecordTypeListRst(Not bFeedbackForm,False,False,intCurVal)
	If bUseContent Then
		strReturn = makeRecordTypeList(intCurVal,"RECORD_TYPE",strLimit,vbNullString)
	Else
		strReturn = makeRecordTypeList(vbNullString,"RECORD_TYPE",True,vbNullString)
	End If
	Call closeRecordTypeListRst()
	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True)
	End If
	makeRecordTypeContents = strReturn
End Function

Dim bSchoolsInArea
bSchoolsInArea = False
Function makeSchoolsInAreaContents(rst,bUseContent)
	bSchoolsInArea = True
	bHasDynamicAddField = True
	Dim strReturn
	Dim strNUM, strNotes, intNotesLen, strSchoolList
	If bUseContent Then
		strNUM = rst.Fields("NUM")
		strNotes = rst.Fields("SCHOOLS_IN_AREA_NOTES")
	Else
		strNUM = Null
	End If
	
	strReturn = strReturn & "<table id=""INAREA_SCH_existing_add_table"" class=""NoBorder cell-padding-2"">"
	If Not Nl(strNUM) Then
		Dim cmdSchoolsInArea, rsSchoolsInArea
		Set cmdSchoolsInArea = Server.CreateObject("ADODB.Command")
		With cmdSchoolsInArea
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CCR_NUMSchoolsInArea_s"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		End With
		Set rsSchoolsInArea = cmdSchoolsInArea.Execute
		
		With rsSchoolsInArea
			While Not .EOF
				strReturn = strReturn & "<tr><td>" & _
					"<input name=""INAREA_SCH_ID"" id=""INAREA_SCH_ID_" & .Fields("SCH_ID") & """ type=""checkbox"" value=""" & .Fields("SCH_ID") & """ checked>&nbsp;" & _
					.Fields("SchoolName") & IIf(Nl(.Fields("SchoolBoard")),vbNullString," (" & .Fields("SchoolBoard") & ")") & "</td><td>" & _
					"<input type=""text"" name=""INAREA_SCH_NOTES_" & .Fields("SCH_ID") & """ " & _
					"id=""INAREA_SCH_NOTES_" & .Fields("SCH_ID") & """ class=""form-control"" " & _
					"value=""" & .Fields("Notes") & """ " & _
					"size=""" & TEXT_SIZE-25 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """>" & _
					"</td></tr>"
				.MoveNext
			Wend
			.Close
		End With

		Set rsSchoolsInArea = Nothing
		Set cmdSchoolsInArea = Nothing
	End If
	strReturn = strReturn & "</table>"

	strReturn = strReturn & "<h4>" & TXT_ADD_SCHOOLS & "</h4>" & _
		"<div class=""entryform-checklist-add-wrapper"" id=""INAREA_SCH_new_input_table"">" & _
			"<div class=""entryform-checklist-add-left"">" & _
				"<div class=""row form-group"">" & _
					"<label for=""NEW_INAREA_SCH"" class=""control-label control-label-left col-xs-1"">" & _
						TXT_NAME & _
					"</label>" & _
					"<div class=""col-xs-11""><input type=""text"" id=""NEW_INAREA_SCH"" class=""form-control""></div>" & _
				"</div>" & _
			"</div>" & _
			"<div class=""entryform-checklist-add-right"">" & _
				"<button type=""button"" class=""btn btn-default"" id=""add_INAREA_SCH"">" & TXT_ADD & "</button>" & _
			"</div>" & _
		"</div>"

	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & _
			"<div class=""FieldLabelLeftClr""><label for=""SCHOOLS_IN_AREA_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea name=""SCHOOLS_IN_AREA_NOTES"" id=""SCHOOLS_IN_AREA_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>"

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeSchoolsInAreaContents = strReturn
End Function

Dim bSchoolEscort
bSchoolEscort = False
Function makeSchoolEscortContents(rst,bUseContent)
	bSchoolEscort = True
	bHasDynamicAddField = True
	Dim strReturn
	Dim strNUM, strNotes, intNotesLen, strSchoolList
	If bUseContent Then
		strNUM = rst.Fields("NUM")
		strNotes = rst.Fields("SCHOOL_ESCORT_NOTES")
	Else
		strNUM = Null
	End If
	
	strReturn = strReturn & "<table id=""ESCORT_SCH_existing_add_table"" class=""NoBorder cell-padding-2"">"
	If Not Nl(strNUM) Then
		Dim cmdSchoolEscort, rsSchoolEscort
		Set cmdSchoolEscort = Server.CreateObject("ADODB.Command")
		With cmdSchoolEscort
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CCR_NUMSchoolEscort_s"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		End With
		Set rsSchoolEscort = cmdSchoolEscort.Execute
		
		With rsSchoolEscort
			While Not .EOF
				strReturn = strReturn & "<tr><td>" & _
					"<input name=""ESCORT_SCH_ID"" id=""ESCORT_SCH_ID_" & .Fields("SCH_ID") & """ type=""checkbox"" value=""" & .Fields("SCH_ID") & """ checked>&nbsp;" & _
					.Fields("SchoolName") & IIf(Nl(.Fields("SchoolBoard")),vbNullString," (" & .Fields("SchoolBoard") & ")") & "</td><td>" & _
					"<input type=""text"" name=""ESCORT_SCH_NOTES_" & .Fields("SCH_ID") & """" & _
					" id=""ESCORT_SCH_NOTES_" & .Fields("SCH_ID") & """" & _
					" value=""" & .Fields("Notes") & """ class=""form-control""" & _
					" size=""" & TEXT_SIZE-25 & """ maxlength=""" & MAX_LENGTH_CHECKLIST_NOTES & """>" & _
					"</td></tr>"
				.MoveNext
			Wend
			.Close
		End With

		Set rsSchoolEscort = Nothing
		Set cmdSchoolEscort = Nothing
	End If
	strReturn = strReturn & "</table>"

	strReturn = strReturn & "<h4>" & TXT_ADD_SCHOOLS & "</h4>" & _
		"<div class=""entryform-checklist-add-wrapper"" id=""ESCORT_SCH_new_input_table"">" & _
			"<div class=""entryform-checklist-add-left"">" & _
				"<div class=""row form-group"">" & _
					"<label for=""NEW_ESCORT_SCH"" class=""control-label control-label-left col-xs-1"">" & _
						TXT_NAME & _
					"</label>" & _
					"<div class=""col-xs-11""><input type=""text"" id=""NEW_ESCORT_SCH"" class=""form-control""></div>" & _
				"</div>" & _
			"</div>" & _
			"<div class=""entryform-checklist-add-right"">" & _
				"<button type=""button"" class=""btn btn-default"" id=""add_ESCORT_SCH"">" & TXT_ADD & "</button>" & _
			"</div>" & _
		"</div>"

	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & _
			"<div class=""FieldLabelLeftClr""><label for=""SCHOOL_ESCORT_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea name=""SCHOOL_ESCORT_NOTES"" id=""SCHOOL_ESCORT_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>"

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeSchoolEscortContents = strReturn
End Function

Function makeServiceLevelContents(rst,bUseContent)
	Dim strReturn
	Dim strNUM
	If bUseContent Then
		strNUM = rst.Fields("NUM")
	Else
		strNUM = Null
	End If
	
	Dim cmdServiceLevel, rsServiceLevel
	Set cmdServiceLevel = Server.CreateObject("ADODB.Command")
	With cmdServiceLevel
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMServiceLevel_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	End With
	Set rsServiceLevel = cmdServiceLevel.Execute
	
	With rsServiceLevel
		While Not .EOF
			strReturn = strReturn & _
				"<div class=""row-border-bottom"">" & _
					"<div class=""row form-group"">" & _
						"<label for=" & AttrQs("SL_ID_" & .FieldS("SL_ID")) & " class=""control-label control-label-left col-md-12"">" & _
							"<input name=""SL_ID"" id=""SL_ID_" & .FieldS("SL_ID") & """ type=""checkbox"" value=" & AttrQs(.Fields("SL_ID")) & Checked(.Fields("IS_SELECTED")) & ">" & _
							.Fields("ServiceLevel") & _
						"</label>" & _
					"</div>" & _
				"</div>"
			.MoveNext
		Wend
	End With

	rsServiceLevel.Close
	Set rsServiceLevel = Nothing
	Set cmdServiceLevel = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback("SERVICE_LEVEL",False)
	End If
	makeServiceLevelContents = strReturn
End Function

Function makeSortAsContents(rst,bUseContent)
	Dim strReturn
	Dim bUseLetter, strSortAs
	
	If bUseContent Then
		strSortAs = rst("SORT_AS")
		bUseLetter = rst("SORT_AS_USELETTER")
	End If
	
	strReturn = _
		"<div class=""clear-line-below"">" & _
			makeValidatedTextFieldVal("SORT_AS", _
				strSortAs, _
				rsFields.Fields("MaxLength"), _
				rsFields.Fields("CanUseFeedback"), _
				vbNullString _
			) & _
		"</div>"

	strReturn = strReturn & _
		"<div class=""FieldLabelLeftClr"">" & TXT_FOR_BROWSE_BY_LETTER_USE & "</div>" & _
		makeCBFieldVal("SORT_AS_USELETTER", _
					bUseLetter, _
					TXT_SORT_NAME_ONLY, _
					TXT_MAIN_NAME_ONLY, _
					TXT_BOTH_NAMES, _
					True, _
					False _
					)

	makeSortAsContents = strReturn
End Function

Function makeSourceContents(rst,bUseContent)
	Dim strReturn
	Dim strName,strTitle,strOrg,strPhone,strFax,strEmail,strBuilding,strAddress,strCity,strProvince,strPostalCode
	
	If bUseContent Then
		strName = rst.Fields("SOURCE_NAME")
		strTitle = rst.Fields("SOURCE_TITLE")
		strOrg = rst.Fields("SOURCE_ORG")
		strPhone = rst.Fields("SOURCE_PHONE")
		strFax = rst.Fields("SOURCE_FAX")
		strEmail = rst.Fields("SOURCE_EMAIL")
		strBuilding = rst.Fields("SOURCE_BUILDING")
		strAddress = rst.Fields("SOURCE_ADDRESS")
		strCity = rst.Fields("SOURCE_CITY")
		strProvince = rst.Fields("SOURCE_PROVINCE")
		strPostalCode = rst.Fields("SOURCE_POSTAL_CODE")
	End If
	
	strReturn = _
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
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_BUILDING"" class=""control-label col-sm-3"">" & TXT_BUILDING & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_BUILDING"" id=""SOURCE_BUILDING"" maxlength=""150"" value=" & AttrQs(strBuilding) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_BUILDING",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_ADDRESS"" class=""control-label col-sm-3"">" & TXT_ADDRESS & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_ADDRESS"" id=""SOURCE_ADDRESS"" maxlength=""150"" value=" & AttrQs(strAddress) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_ADDRESS",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_CITY"" class=""control-label col-sm-3"">" & TXT_CITY & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input type=""text"" name=""SOURCE_CITY"" id=""SOURCE_CITY"" maxlength=""100"" value=" & AttrQs(strCity) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_CITY",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_PROVINCE"" class=""control-label col-sm-3"">" & TXT_PROVINCE & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<div class=""form-inline""><input type=""text"" name=""SOURCE_PROVINCE"" id=""SOURCE_PROVINCE"" size=""3"" maxlength=""2"" value=" & AttrQs(strProvince) & " class=""form-control""></div>"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_PROVINCE",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>" & _
		"<div class=""form-group"">" & _
			"<label for=""SOURCE_POSTAL_CODE"" class=""control-label col-sm-3"">" & TXT_POSTAL_CODE & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<div class=""form-inline""><input type=""text"" name=""SOURCE_POSTAL_CODE"" id=""SOURCE_POSTAL_CODE"" size=""20"" maxlength=""20"" value=" & AttrQs(strPostalCode) & " class=""form-control""></div>"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SOURCE_POSTAL_CODE",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>"

	makeSourceContents = strReturn
End Function

Function makeSpaceAvailableContents(rst,bUseContent)
	Dim strReturn
	Dim bSpaceAvailable, _
		strNotes, _
		dSpaceAvailable
	
	If bUseContent Then
		bSpaceAvailable = rst.Fields("SPACE_AVAILABLE")
		strNotes = rst.Fields("SPACE_AVAILABLE_NOTES")
		dSpaceAvailable = rst.Fields("SPACE_AVAILABLE_DATE")
	Else
		bSpaceAvailable = Null
		strNotes = vbNullString
		dSpaceAvailable = Null
	End If

	strReturn = _
		"<div class=""form-group row"">" & _
			"<label for=""SPACE_AVAILABLE"" class=""control-label col-sm-3"">" & TXT_SPACE_AVAILABLE & "</label>" & _
			"<div class=""col-sm-9"">" & _
				makeCBFieldVal("SPACE_AVAILABLE",bSpaceAvailable,TXT_YES,TXT_NO,TXT_UNKNOWN,True,True)
	If bFeedback Then
		strReturn = strReturn & getCbFeedback("SPACE_AVAILABLE",TXT_YES,TXT_NO)
	End If
	strReturn = strReturn & _
 			"</div>" & _
		"</div>" & _
		"<div class=""form-group row"">" & _
			"<label for=""SPACE_AVAILABLE_NOTES"" class=""control-label col-sm-3"">" & TXT_NOTES & "</label>" & _
			"<div class=""col-sm-9"">" & _
				"<input name=""SPACE_AVAILABLE_NOTES"" type=""text"" maxlength=""255"" autocomplete=""off"" value=" & AttrQs(strNotes) & " class=""form-control"">"
	If bFeedback Then
		strReturn = strReturn & getFeedback("SPACE_AVAILABLE_NOTES",True)
	End If
	strReturn = strReturn & _
 			"</div>" & _
		"</div>" & _
		"<div class=""form-group row"">" & _
			"<label for=""SPACE_AVAILABLE_DATE"" class=""control-label col-sm-3"">" & TXT_DATE_OF_CHANGE & "</label>" & _
			"<div class=""col-sm-9 form-inline"">" & _
				makeDateFieldVal("SPACE_AVAILABLE_DATE",dSpaceAvailable,True,False,False,False,False,True)
	If bFeedback Then
		strReturn = strReturn & getFeedback("SPACE_AVAILABLE_DATE",True)
	End If
	strReturn = strReturn & _
			"</div>" & _
		"</div>"

	makeSpaceAvailableContents = strReturn
End Function

Dim bSubjects
bSubjects = False

Function makeSubjectContents(rst,bUseContent)
	bSubjects = True
	bHasDynamicAddField = True
	Dim strReturn
	Dim strNUM

	If bUseContent Then
		strNUM = rst.Fields("NUM")
	Else
		strNUM = Null
	End If
	
	If Not Nl(strNUM) Then
		Dim cmdSubject, rsSubject
		Set cmdSubject = Server.CreateObject("ADODB.Command")
		With cmdSubject
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CIC_NUMAuthorizedTerms_s"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		End With
		Set rsSubject = cmdSubject.Execute
	
		With rsSubject
			If Not .EOF Then
				strReturn = "<h4>" & TXT_AUTHORIZED_SUBJECTS & "</h4>"
				While Not .EOF
					strReturn = strReturn & cbSubject(.Fields("Subj_ID"),.Fields("SubjectTerm"),True) & " ; "
					.MoveNext
				Wend
			End If
		End With
	
		rsSubject.Close
	
		cmdSubject.CommandText = "dbo.sp_CIC_NUMLocalTerms_s"
		Set rsSubject = cmdSubject.Execute
	
		With rsSubject
			If Not .EOF Then
				strReturn = strReturn & vbCrLf & "<h4>" & TXT_LOCAL_SUBJECTS & "</h4>"
				While Not .EOF
					strReturn = strReturn & cbSubject(.Fields("Subj_ID"),.Fields("SubjectTerm"),True) & " ; "
					.MoveNext
				Wend
			End If
		End With
	
		rsSubject.Close
		Set rsSubject = Nothing
		Set cmdSubject = Nothing
	End If

	strReturn = strReturn & vbCrLf & _
		"<h4 class=""NotVisible"" id=""Subj_existing_add_title"">" & TXT_NEW_SUBJECTS & "</h4>" & _
		"<div id=""Subj_existing_add_container""></div>" & _
		"<h4><label for=""NEW_Subj"">" & TXT_ADD_SUBJECTS & "</label></h4>" & _
		"<p id=""Subj_new_input_table"">" & TXT_NOT_SURE_ENTER & "<a href=""javascript:openWin('" & makeLink("subjfind.asp","Ln=" & g_objCurrentLang.Culture,"Ln") & "','sFind')"">" & TXT_SUBJECT_FINDER & "</a>.</p>" & _
		"<div class=""entryform-checklist-add-wrapper"">" & _
			"<div class=""entryform-checklist-add-left"">" & _
					"<input type=""text"" id=""NEW_Subj"" class=""form-control"">" & _
			"</div>" & _
			"<div class=""entryform-checklist-add-right"">" & _
				"<button type=""button"" class=""btn btn-default"" id=""add_Subj"">" & TXT_ADD & "</button>" & _
			"</div>" & _
		"</div>"

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeSubjectContents = strReturn
End Function

Function makeTypeOfCareContents(rst,bUseContent)
	Dim strReturn
	Dim strNUM, strNotes, intNotesLen
	If bUseContent Then
		strNUM = rst.Fields("NUM")
		strNotes = rst.Fields("TYPE_OF_CARE_NOTES")
	Else
		strNUM = Null
	End If
	
	Dim cmdTypeOfCare, rsTypeOfCare
	Set cmdTypeOfCare = Server.CreateObject("ADODB.Command")
	With cmdTypeOfCare
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CCR_NUMTypeOfCare_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	End With
	Set rsTypeOfCare = cmdTypeOfCare.Execute
	
	With rsTypeOfCare
		While Not .EOF
			strReturn = strReturn & _
				"<div class=""row-border-bottom"">" & _
					"<div class=""row form-group"">" & _
						"<label for=" & AttrQs("TOC_ID_" & .FieldS("TOC_ID")) & " class=""control-label control-label-left col-md-4"">" & _
							"<input name=""TOC_ID"" id=""TOC_ID_" & .FieldS("TOC_ID") & """ type=""checkbox"" value=" & AttrQs(.Fields("TOC_ID")) & Checked(.Fields("IS_SELECTED")) & ">" & _
							.Fields("TypeOfCare") & _
						"</label>" & _
						"<div class=""col-md-8"">"
			If (.Fields("LangID") = g_objCurrentLang.LangID) Then
				strReturn = strReturn & _
							"<input type=""text"" title=" & AttrQs(TXT_NOTES & TXT_COLON & .Fields("TypeOfCare")) & " name=""TOC_NOTES_" & .Fields("TOC_ID") & """ " & _
								" id=""TOC_NOTES_" & .Fields("TOC_ID") & """" & _
								" value=""" & .Fields("Notes") & """" & _
								" maxlength=" & AttrQs(MAX_LENGTH_CHECKLIST_NOTES) & _
								" class=""form-control""" & _
							">"
			Else
				strReturn = strReturn
			End If
			strReturn = strReturn & _
						"</div>" & _
					"</div>" & _
				"</div>"
			.MoveNext
		Wend
	End With
	
	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<div class=""FieldLabelLeftClr""><label for=""TYPE_OF_CARE_NOTES"">" & TXT_OTHER_NOTES & "</label></div>" & _
			"<textarea name=""TYPE_OF_CARE_NOTES"" id=""TYPE_OF_CARE_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>"

	rsTypeOfCare.Close
	Set rsTypeOfCare = Nothing
	Set cmdTypeOfCare = Nothing

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If
	makeTypeOfCareContents = strReturn
End Function


Function makeTypeOfProgramContents(rst,bUseContent)
	Dim strReturn, _
		intCurVal
		
	If bUseContent Then
		intCurVal = rst("TYPE_OF_PROGRAM")
	Else
		intCurVal = vbNullString
	End If
	
	Call openTypeOfProgramListRst(False,False,intCurVal)
	strReturn = makeTypeOfProgramList(intCurVal,"TYPE_OF_PROGRAM",True, vbNullString)
	Call closeTypeOfProgramListRst()

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True)
	End If

	makeTypeOfProgramContents = strReturn
End Function

Dim strVacancyServiceTitleUI, bHasVacancyServiceTitles
strVacancyServiceTitleUI = vbNullString
bHasVacancyServiceTitles = False

Sub makeVacancyServiceTitleUI() 'strBTVUTExtra)
	If Nl(strVacancyServiceTitleUI) Then
		Call openVacancyServiceTitleListRst(False,False)
		With rsListVacancyServiceTitle
			If .RecordCount = 0 Then
				strVacancyServiceTitleUI = "var service_titles = [];"
			Else
				bHasVacancyServiceTitles = True
				strVacancyServiceTitleUI = "var service_titles = ["
				Dim strCon
				strCon = vbNullString
				While Not .EOF
					strVacancyServiceTitleUI = strVacancyServiceTitleUI & strCon & JsQs(.Fields("ServiceTitle")) 
					strCon = ","
					.MoveNext
				Wend
				strVacancyServiceTitleUI = strVacancyServiceTitleUI & "];"
			End If
		End With
		Call closeVacancyServiceTitleListRst()
	End If

End Sub

Function makeVacancyInfoEntry(dicBTVUT, strHeading, strPrefix, dicBTVTP, dicVacancyTargetPop, aVacancyTargetPopOrder, bUseContent)
	Dim strReturn
	strReturn = vbNullString
	Call makeVacancyServiceTitleUI()
	strReturn = strReturn & "<div class=""EntryFormItemBox"" id=""" & strPrefix & "container"">" & _
		"<div style=""float: right;""><button type=""button"" class=""EntryFormItemDelete ui-state-default ui-corner-all"" id=""" & strPrefix & "DELETE"">" & TXT_DELETE & "</button></div>" & _
		"<h4 class=""EntryFormItemHeader"">" & strHeading & "</h4>" & vbCrLf & _ 
		"<div id=""" & strPrefix & "DISPLAY"" class=""EntryFormItemContent"">" & _
		"<table class=""NoBorder cell-padding-2"">"

	If bUseContent Then
		strReturn = strReturn & _
			"<tr>" & _
				"<td class=""FieldLabelLeftClr"">" & TXT_UNIQUE_ID & "</td>" & _
				"<td>" & dicBTVUT("GUID") & "</td>" & _
			"</tr>"
	End If
	strReturn = strReturn & _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_VACANCY_INFO_SERVICE_TITLE & "</td>" & _
			"<td><input class=""ui-autocomplete-input ServiceTitleField Info"" type=""text"" name=""" & strPrefix & "ServiceTitle"" maxlength=""100"" size=""" & TEXT_SIZE-20 & """ value=""" & Server.HTMLEncode(Ns(dicBTVUT("ServiceTitle"))) & """ id=""" & strPrefix &"vacancy_service_title""></td>" & _
		"</tr>" & _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_VACANCY_INFO_CAPACITY_OF & "</td>" & _
			"<td><input type=""text"" name=""" & strPrefix & "VUT_Capacity"" size=""4"" maxlength=""4"" value=""" & StringIf(bUseContent, dicBTVUT("Capacity")) & """ class=""posint"">"
			
	If bUseContent Then
		strReturn = strReturn & "&nbsp;<em>" & Server.HTMLEncode(Ns(dicBTVUT("UnitTypeName"))) & "</em>"
	Else
		Call openVacancyUnitTypeListRst(False)
		strReturn = strReturn & "&nbsp;" & makeVacancyUnitTypeList(vbNullString, strPrefix & "VUT_ID", False, vbNullString)
		Call closeVacancyUnitTypeListRst()
	End If
	
	strReturn = strReturn & "</td>" & _
		"</tr>" & _
		StringIf(bVacancyFundedCapacity, _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_VACANCY_INFO_FUNDED_CAPACITY_OF & "</td>" & _
			"<td><input type=""text"" name=""" & strPrefix & "VUT_FundedCapacity"" size=""4"" maxlength=""4"" value=""" & StringIf(bUseContent, dicBTVUT("FundedCapacity")) & """ class=""posint"">&nbsp;" & _
			IIf(bUseContent,"<em>" & Server.HTMLEncode(Ns(dicBTVUT("UnitTypeName"))) & "</em>",TXT_VACANCY_INFO_UNITS) & "</td>" & _
		"</tr>") & _
		StringIf(bVacancyServiceHours, _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_VACANCY_INFO_HOURS_PER_DAY & "</td>" & _
			"<td><input type=""text"" name=""" & strPrefix & "VUT_HoursPerDay"" size=""4"" maxlength=""6"" value=""" & StringIf(bUseContent, dicBTVUT("HoursPerDay")) & """ class=""posdbl""></td>" & _
		"</tr>") & _
		StringIf(bVacancyServiceDays, _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_VACANCY_INFO_DAYS_PER_WEEK & "</td>" & _
			"<td><input type=""text"" name=""" & strPrefix & "VUT_DaysPerWeek"" size=""4"" maxlength=""6"" value=""" & StringIf(bUseContent, dicBTVUT("DaysPerWeek")) & """ class=""posdbl""></td>" & _
		"</tr>") & _
		StringIf(bVacancyServiceWeeks, _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_VACANCY_INFO_WEEKS_PER_YEAR & "</td>" & _
			"<td><input type=""text"" name=""" & strPrefix & "VUT_WeeksPerYear"" size=""4"" maxlength=""6"" value=""" & StringIf(bUseContent, dicBTVUT("WeeksPerYear")) & """ class=""posdbl""></td>" & _
		"</tr>") & _
		StringIf(bVacancyServiceFTE, _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_VACANCY_INFO_FULL_TIME_EQUIVALENT & "</td>" & _
			"<td><input type=""text"" name=""" & strPrefix & "VUT_FTE"" size=""4"" maxlength=""6"" value=""" & StringIf(bUseContent, dicBTVUT("FullTimeEquivalent")) & """ class=""posdbl""></td>" & _
		"</tr>") & _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_VACANCY_INFO_VACANCY & TXT_OF & "</td>" & _
			"<td><input type=""hidden"" name=""" & strPrefix & "VUT_LastVacancyChange"" value=""" & StringIf(bUseContent, dicBTVUT("LastVacancyChange")) & """><input type=""text"" name=""" & strPrefix & "VUT_Vacancy"" size=""4"" maxlength=""4"" value=""" & StringIf(bUseContent, dicBTVUT("Vacancy")) & """>&nbsp;" & _
			IIf(bUseContent,"<em>" & Server.HTMLEncode(Ns(dicBTVUT("UnitTypeName"))) & "</em>",TXT_VACANCY_INFO_UNITS) & _
			", <strong>" & TXT_VACANCY_INFO_AS_OF & "</strong> " & makeDateFieldVal(strPrefix & "VacancyModifiedDate", StringIf(bUseContent, Ns(dicBTVUT("MODIFIED_DATE"))), True, False, False, False, False, False) & "</td>" & _
		"</tr>" & _
		"<tr>" & _
			"<td class=""FieldLabelLeftClr"">" & TXT_VACANCY_INFO_TARGET_POPULATION & "</td>" & _
			"<td>"

	Dim strVTPCON, intVTPID
	strVTPCON = vbNullString
	
	For Each intVTPID in aVacancyTargetPopOrder
		strReturn = strReturn & strVTPCON 
		strReturn = strReturn & "<input type=""checkbox"" name=""" & strPrefix & "VTP_ID"" value=""" & intVTPID & """" & _
		Checked(dicBTVTP.Exists(strPrefix & intVTPID)) & ">&nbsp;"
		strReturn = strReturn & Server.HTMLEncode(Ns(dicVacancyTargetPop(intVTPID)))
		strVTPCON = "," & vbCrLf
	Next

	strReturn = strReturn & "</td>" & _
		"</tr>" & _
		"</table>" & _
		"<p><strong>" & TXT_VACANCY_INFO_WAIT_LIST & "</strong> " & TXT_IS & " " & _
		"<input type=""radio"" name=""" & strPrefix & "WaitList"" value=""""" & Checked(Nl(dicBTVUT("WaitList"))) & ">&nbsp;" & TXT_UNKNOWN & _
		"<input type=""radio"" name=""" & strPrefix & "WaitList"" value=""" & SQL_TRUE & """" & Checked(dicBTVUT("WaitList") = True) & ">&nbsp;" & TXT_AVAILABLE & _
		"<input type=""radio"" name=""" & strPrefix & "WaitList"" value=""" & SQL_FALSE & """" & Checked(dicBTVUT("WaitList") = False) & ">&nbsp;" & TXT_NOT_AVAILABLE & vbCrLf & _
		"<br>" & TXT_VACANCY_INFO_NEXT_WAIT_LIST_DATE & _
		" " & makeDateFieldVal(strPrefix & "WaitListDate", StringIf(bUseContent, Ns(dicBTVUT("WaitListDate"))), False, False, False, False, False, False) & "</p>" & _
		"<p><strong>" & TXT_NOTES & "</strong>" & TXT_COLON & _
		"<br><textarea name=""" & strPrefix & "VacancyServiceNotes"" cols=""" & TEXTAREA_COLS & """ rows=""" & TEXTAREA_ROWS_SHORT & """>" & Server.HTMLEncode(StringIf(bUseContent, Ns(dicBTVUT("Notes")))) & "</textarea></p>" & _
		"</div><div style=""clear: both;""></div></div>"

	makeVacancyInfoEntry = strReturn
End Function

Dim bVacancyAdded
bVacancyAdded = False
Function makeVacancyInfoContents(rst, bUseContent)
	
	Dim dicVacancyTargetPop, _
		aVacancyTargetPopOrder(), _
		i, _
		dicTmp

	bVacancyAdded = True
			
	Set dicVacancyTargetPop = Server.CreateObject("Scripting.Dictionary")
	i = 0

	Call openVacancyTargetPopListRst(False,Null)
	ReDim aVacancyTargetPopOrder(rsListVacancyTargetPop.RecordCount-1)

	With rsListVacancyTargetPop
		While Not .EOF
			dicVacancyTargetPop(.Fields("VTP_ID").Value) = .Fields("TargetPopulation").Value
			aVacancyTargetPopOrder(i) = .Fields("VTP_ID").Value
			i= i + 1
			.MoveNext
		Wend
	End With
	Call closeVacancyTargetPopListRst()
	
	Dim dicBTVTP
	Set dicBTVTP = Server.CreateObject("Scripting.Dictionary")

	Dim rsVacancy, cmdVacancy
	If bUseContent Then
		Set cmdVacancy = Server.CreateObject("ADODB.Command")
		With cmdVacancy
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CIC_NUMVacancy_s"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		End With
		Set rsVacancy = Server.CreateObject("ADODB.Recordset")
		With rsVacancy
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdVacancy
		End With


		With rsVacancy
			While Not .EOF
				dicBTVTP("VI_" & .Fields("BT_VUT_ID").Value & "_" & .Fields("VTP_ID").Value ) = True
				.MoveNext
			Wend
		End With

		Set rsVacancy = rsVacancy.NextRecordset
	End If

	dim dicFake
	set dicFake = Server.CreateObject("Scripting.Dictionary")
	dicFake("ServiceTitle") = vbNullString
	dicFake("UnitTypeName") = vbNullString
	dicFake("Capacity") = vbNullString
	dicFake("FundedCapacity") = vbNullString
	dicFake("Vacancy") = vbNullString
	dicFake("LastVacancyChange") = vbNullString
	dicFake("HoursPerDay") = vbNullString
	dicFake("DaysPerWeek") = vbNullString
	dicFake("WeeksPerYear") = vbNullString
	dicFake("FullTimeEquivalent") = vbNullString
	dicFake("WaitList") = vbNullString
	dicFake("WaitListDate") = vbNullString

	Dim strReturn
	strReturn = "<div id=""VacancyInfoEditArea"" class=""VacancyInfoEditArea EntryFormItemContainer"" data-add-tmpl=" & _
		AttrQs(Server.HTMLEncode(makeVacancyInfoEntry(dicFake, TXT_SERVICE_NUMBER & "<span class=""EntryFormItemCount"">[COUNT]</span> " & TXT_NEW, "VI_[ID]_", dicBTVTP, dicVacancyTargetPop, aVacancyTargetPopOrder, False))) & ">"

	Dim strBT_VUT_ID, strBT_VUT_IDCon
	strBT_VUT_ID = vbNullString
	strBT_VUT_IDCon = vbNullString

	If bUseContent Then
		With rsVacancy
			If Not .EOF Then
				Dim intCount, intVutID
				intCount = 0

				While Not .EOF
					intVutID = rsVacancy("BT_VUT_ID").Value

					strBT_VUT_ID = strBT_VUT_ID & strBT_VUT_IDCon & intVutID
					strBT_VUT_IDCon = ","

					intCount = intCount + 1

					strReturn = strReturn & makeVacancyInfoEntry(rsVacancy, TXT_SERVICE_NUMBER & "<span class=""EntryFormItemCount"">" & intCount & "</span>", "VI_" & intVutID & "_",dicBTVTP, dicVacancyTargetPop, aVacancyTargetPopOrder, True)

					.MoveNext
				Wend
			End If
		End With
	End If


	strReturn = strReturn & "<input type=""hidden"" name=""VI_IDS"" class=""EntryFormItemContainerIds"" id=""VI_IDS"" value=" & _
		AttrQs(strBT_VUT_ID) & "></div><button class=""ui-state-default ui-corner-all EntryFormItemAdd"" type=""button"" id=""VI_add_button"">" & TXT_ADD & "</button>" 
	
	If bUseContent Then
		If rsVacancy.State <> adStateClosed Then
			rsVacancy.Close
		End If
		Set cmdVacancy = Nothing
		Set rsVacancy = Nothing
	End If

	Dim strNotes, _
		intNotesLen

	If bUseContent Then
		strNotes = rst.Fields("VACANCY_NOTES")
	Else
		strNotes = vbNullString
	End If

	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & "<h4><label for=""VACANCY_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & _
			"<textarea id=""VACANCY_NOTES"" name=""VACANCY_NOTES""" & _
			" cols=""" & TEXTAREA_COLS & """" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			">" & strNotes & "</textarea>"

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,False)
	End If

	makeVacancyInfoContents = strReturn
End Function

Function makeWardContents(rst,bUseContent)
	Dim strReturn, _
		intCurVal
		
	If bUseContent Then
		intCurVal = rst.Fields("WARD").Value
	Else
		intCurVal = vbNullString
	End If

	Call openWardListRst(False,intCurVal)

	If bUseContent Then
		strReturn = makeWardList(intCurVal,"WARD",True,vbNullString)
	Else
		strReturn = makeWardList(vbNullString,"WARD",True,vbNullString)
	End If
	Call closeWardListRst()

	If bFeedback Then
		strReturn = strReturn & getFeedback(strFieldName,True)
	End If
	makeWardContents = strReturn
End Function

Function getUseInsteads(ByVal intSubjID, bUseAll)
	Dim strSubjectTerm, aSubjIDs, intSubjIndex, strReturn, strCon
	strCon = vbNullString
	intSubjIndex = 0
	Dim cnnUseInstead, cmdUseInstead, rsUseInstead
	Call makeNewAdminConnection(cnnUseInstead)
	Set cmdUseInstead = Server.CreateObject("ADODB.Command")
	With cmdUseInstead
		.ActiveConnection = cnnUseInstead
		.CommandText = "dbo.sp_THS_SBJ_UseInstead_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@SubjID", adInteger, adParamInput, 4, intSubjID)
	End With
	Set rsUseInstead = Server.CreateObject("ADODB.Recordset")
	With rsUseInstead
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdUseInstead
	End With
	ReDim aSubjIDs(rsUseInstead.RecordCount -1)
	With rsUseInstead
		While Not .EOF
			strSubjectTerm = "<em>" & rsUseInstead("SubjectTerm") & "</em>"
			strReturn = strReturn & strCon & cbSubject(rsUseInstead("Subj_ID"),strSubjectTerm, False)
			strCon = IIf(bUseAll," and "," or ")
			intSubjIndex = intSubjIndex + 1
			.MoveNext
		Wend
		.Close
	End With
	Set rsUseInstead = Nothing
	Set cmdUseInstead = Nothing
	
	cnnUseInstead.Close
	Set cnnUseInstead = Nothing

	getUseInsteads = strReturn
End Function

Function cbSubject(ByVal intSubjID, ByVal strSubjectTerm, bChecked)
	cbSubject = "<label style=""white-space:nowrap""><input type=""checkbox"" name=""Subj_ID"" id=""Subj_ID_" & intSubjID & """ value=""" & _
		intSubjID & """" & IIf(bChecked," checked",vbNullString) & "> " & strSubjectTerm & "</label>"
End Function

Function getSubjectInfo(ByVal intSubjID, ByVal strSubjectTerm, ByVal bUsed, ByVal bUseAll)
	Dim strReturn
	If bUsed Then
		strReturn = cbSubject(intSubjID,strSubjectTerm,False)
	Else
		strReturn = strSubjectTerm & " use " & getUseInsteads(intSubjID,bUseAll) 
	End If
	getSubjectInfo = strReturn
End Function
%>
