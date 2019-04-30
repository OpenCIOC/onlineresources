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
Dim strVNUMList, _
	aVNUM, _
	indVNUM, _
	strVNUMListCon

strVNUMList = reReplace(Trim(Request("VNUM")), "(\s|,|;)+", ",", False, False, True, False)
aVNUM = Split(strVNUMList,",")
strVNUMList = vbNullString
strVNUMListCon = vbNullString

For Each indVNUM in aVNUM
	If reEquals(indVNUM,"V-([A-Za-z]){3}([0-9]){4,5}",False,False,True,False) Then
		strVNUMList = strVNUMList & strVNUMListCon & Qs(indVNUM,SQUOTE)
		strVNUMListCon = ","
	Else
		strSearchErrors = strSearchErrors & strErrorCon & TXT_WARNING & TXT_WARNING_RECORD_NUM & "&quot;" & Server.HTMLEncode(Ns(indVNUM)) & "&quot;"
		strErrorCon = "<br>"
	End If
Next
'--------------------------------------------------
' A. Display Status Search
'--------------------------------------------------

Dim	strDisplayStatus
strDisplayStatus = Request("DisplayStatus")

If Not g_bCanSeeExpired Then
	strQueryString = reReplace(strQueryString,"(&)?DisplayStatus=C",vbNullString,False,False,False,False)
End If
	
'--------------------------------------------------
' B. Communities Search
'--------------------------------------------------

Dim	strCMID, _
	strSearchCMID

strCMID = Trim(Request("CMID"))
If Not IsIDList(strCMID) Then
	strCMID = vbNullString
Else
	strSearchCMID = Trim(Request("SearchCMID"))
	If Not IsIDList(strSearchCMID) Then
		strSearchCMID = vbNullString
	End If
	If Nl(strSearchCMID) And Not Nl(strCMID) Then
		Call getVolSearchComms(strCMID)
	Else
		strCommList = strCMID
		strCommSearchList = strSearchCMID
	End If
End If



'--------------------------------------------------
' C. Specific / General Area of Interest
'--------------------------------------------------

Dim strIGID

strIGID = Trim(Request("IGID"))
If Not IsIDList(strIGID) Then
	strIGID = Null
End If

Set dicCheckListSearch("AI") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("AI").setValues("AI","AI", TXT_AREAS_OF_INTEREST, False, False, "vo", "VNUM", "VOL_OP_AI", "VOL_Interest", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' D. Schedule Search
'--------------------------------------------------

Dim strDateTime
strDateTime = Trim(Request("DateTime"))

If Not Nl(strDateTime) Then
	If Not reEquals(strDateTime,"(SCH_((M)|(TU)|(W)|(TH)|(F)|(ST)|(SN))_((Morning)|(Afternoon)|(Evening))=1)(\s*,\s*(SCH_((M)|(TU)|(W)|(TH)|(F)|(ST)|(SN))_((Morning)|(Afternoon)|(Evening))=1)){0,20}",False,False,True,False) Then
		strDateTime = Null
	End If
End If

'--------------------------------------------------
' E. Age Search
'--------------------------------------------------

Dim	decAge
decAge = Request("Age")
If Not Nl(decAge) Then
	If IsNumeric(decAge) Then
		decAge = CSng(decAge)
	Else
		strSearchErrors = strSearchErrors & strErrorCon & TXT_WARNING & TXT_WARNING_AGE & "&quot;" & Server.HTMLEncode(Ns(decAge)) & "&quot;" & TXT_IS_NOT_A_NUMBER
		strErrorCon = "<br>"
		decAge = Null
	End If
Else
	decAge = Null
End If

'--------------------------------------------------
' F. OSSD
'--------------------------------------------------

Dim	bOSSD
bOSSD = Request("forOSSD") = "on"

'--------------------------------------------------
' G. Accessibility
'--------------------------------------------------

Set dicCheckListSearch("AC") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("AC").setValues("AC","AC", TXT_CHK_ACCESSIBILITY, False, False, "vo", "VNUM", "VOL_OP_AC", "GBL_Accessibility", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' H. Commitment Length
'--------------------------------------------------

Set dicCheckListSearch("CL") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("CL").setValues("CL","CL", TXT_CHK_COMMITMENT_LENGTH, False, False, "vo", "VNUM", "VOL_OP_CL", "VOL_CommitmentLength", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' I. Interaction Level
'--------------------------------------------------

Set dicCheckListSearch("IL") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("IL").setValues("IL","IL", TXT_CHK_INTERACTION_LEVEL, False, False, "vo", "VNUM", "VOL_OP_IL", "VOL_InteractionLevel", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' J. Season
'--------------------------------------------------

Set dicCheckListSearch("SSN") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("SSN").setValues("SSN","SSN", TXT_CHK_SEASONS, False, False, "vo", "VNUM", "VOL_OP_SSN", "VOL_Seasons", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' K. Suitability
'--------------------------------------------------

Set dicCheckListSearch("SB") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("SB").setValues("SB","SB", TXT_CHK_SUITABILITY, False, False, "vo", "VNUM", "VOL_OP_SB", "VOL_Suitability", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
'L. Training
'--------------------------------------------------

Set dicCheckListSearch("TRN") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("TRN").setValues("TRN","TRN", TXT_CHK_TRAINING, False, False, "vo", "VNUM", "VOL_OP_TRN", "VOL_Training", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' M. Transportation
'--------------------------------------------------

Set dicCheckListSearch("TRP") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("TRP").setValues("TRP","TRP", TXT_CHK_TRANSPORTATION, False, False, "vo", "VNUM", "VOL_OP_TRP", "VOL_Transportation", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' N. Skills
'--------------------------------------------------

Set dicCheckListSearch("SK") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("SK").setValues("SK","SK", TXT_CHK_SKILLS, False, False, "vo", "VNUM", "VOL_OP_SK", "VOL_Skill", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' O. Social Media Types
'--------------------------------------------------

Set dicCheckListSearch("SM") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("SM").setValues("SM","SM", "SOCIAL_MEDIA", True, False, "vo", "VNUM", "VOL_OP_SM", "GBL_SocialMedia", Null, "ISNULL(frn.Name,fr.DefaultName)", Null, True, Null, Null, False)

'--------------------------------------------------
' P. RSN (Transitional)
'--------------------------------------------------

Dim intRSN
intRSN = Request("RSN")
If Not Nl(intRSN) Then
	If Not IsIDType(intRSN) Then
		intRSN = Null
	End If
Else
	intRSN = Null
End If

'--------------------------------------------------
' Q. Extra Checklist Search
'--------------------------------------------------
Dim strExtraChkCodes, _
	aEXCTypes, _
	indEXCType

strExtraChkCodes = Replace(Request("EXC")," ",vbNullString)
If Not IsChecklistNameList(strExtraChkCodes) Then
	strExtraChkCodes = Null
	aEXCTypes = Array()
Else
	aEXCTypes = Split(strExtraChkCodes,",")
End If

For Each indEXCType in aEXCTypes
	Set dicCheckListSearch("EXC" & indEXCType) = New CheckListSearch
	'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
	Call dicCheckListSearch("EXC" & indEXCType).setValues("EXC" & indEXCType, "EXC", "EXTRA_CHECKLIST_" & indEXCType, True, False, "vo", "VNUM", "VOL_OP_EXC", "VOL_ExtraCheckList", "Code", "ISNULL(frn.Name,fr.Code)", Null, True, "FieldName_Cache='EXTRA_CHECKLIST_" & indEXCType & "'", "FieldName='EXTRA_CHECKLIST_" & indEXCType & "'", False)
Next

'--------------------------------------------------
' R. Extra Drop-Down Search
'--------------------------------------------------

Dim strExtraDropCodes, _
	aEXDTypes, _
	indEXDType

strExtraDropCodes = Replace(Request("EXD")," ",vbNullString)
If Not IsChecklistNameList(strExtraDropCodes) Then
	strExtraChkCodes = Null
	aEXDTypes = Array()
Else
	aEXDTypes = Split(strExtraDropCodes,",")
End If

For Each indEXDType in aEXDTypes
	Set dicCheckListSearch("EXD" & indEXDType) = New CheckListSearch
	'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
	Call dicCheckListSearch("EXD" & indEXDType).setValues("EXD" & indEXDType, "EXD", "EXTRA_DROPDOWN_" & indEXDType, True, False, "vo", "VNUM", "VOL_OP_EXD", "VOL_ExtraDropDown", "Code", "ISNULL(frn.Name,fr.Code)", Null, True, "FieldName_Cache='EXTRA_DROPDOWN_" & indEXDType & "'", "FieldName='EXTRA_DROPDOWN_" & indEXDType & "'", False)
Next

'--------------------------------------------------

Call setCommonBasicSearchData()
Call setCommonAdvSearchData()

If Not Nl(strVNUMList) Then
	strWhere = strWhere & strCon & "(vo.VNUM IN (" & strVNUMList & "))"
	strCon = AND_CON

	If bSearchDisplay Then
		intCurrentSearch = intCurrentSearch + 1
		ReDim Preserve aSearch(intCurrentSearch)
		aSearch(intCurrentSearch) = TXT_RECORD_NUM & TXT_COLON & " <em>" & strVNUMList & "</em>"
	End If
End If

'--------------------------------------------------
' A. Display Status Search
'--------------------------------------------------

Select Case strDisplayStatus
	Case "A"
		If Not g_bCanSeeExpired Then
			If bSearchDisplay Then
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_DISPLAY_UNTIL & TXT_COLON & "<em>" & TXT_INCLUDE_EXPIRED & "</em>"
			End If
		End If
	Case "P"
		strWhere = strWhere & strCon & "(vo.DISPLAY_UNTIL < GETDATE())"
		strCon = AND_CON
	
		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_DISPLAY_UNTIL_DATE & TXT_COLON & "<em>" & TXT_ONLY_EXPIRED & "</em>"
		End If
	Case Else
		If Not g_bCanSeeExpired Or strDisplayStatus = "C" Then
			strWhere = strWhere & strCon & "(vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())"
			strCon = AND_CON
		
			If g_bCanSeeExpired Then
				If bSearchDisplay Then
					intCurrentSearch = intCurrentSearch + 1
					ReDim Preserve aSearch(intCurrentSearch)
					aSearch(intCurrentSearch) = TXT_DISPLAY_UNTIL_DATE & TXT_COLON & "<em>" & TXT_ONLY_CURRENT & "</em>"
				End If
			End If
		End If
End Select

'--------------------------------------------------
' B. Communities Search
'--------------------------------------------------

If Not Nl(strCommList) Then
	strWhere = strWhere & strCon & "EXISTS(SELECT * FROM VOL_OP_CM WHERE VNUM=vo.VNUM AND CM_ID IN (" & strCommSearchList & "))"
	strCon = AND_CON

	If bSearchDisplay Then
		strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
			"SET @searchData = NULL" & vbCrLf & _
			"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>','')" & _
				" + cmn.Name" & _
				" FROM GBL_Community_Name cmn" & _
				" WHERE cmn.CM_ID IN (" & strCommList & ") " & _
					" AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
				" ORDER BY cmn.Name" & vbCrLf & _
			"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & TXT_COMMUNITIES & TXT_COLON & "<em>") & " + @searchData + '</em></search_display_item>'"
	End If
End If


'--------------------------------------------------
' C. Specific / General Area of Interest
'--------------------------------------------------

Dim strWhereBefore

strWhereBefore = CStr(strWhere)
Select Case dicCheckListSearch("AI").SearchType
	Case "A"
		Call dicCheckListSearch("AI").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("AI").noValuesSearch()
	Case Else
		Call dicCheckListSearch("AI").includeValuesSearch()
End Select

Call dicCheckListSearch("AI").excludeValuesSearch()
Call dicCheckListSearch("AI").includeValuesSearchCode()

If strWhereBefore = strWhere And Not Nl(strIGID) Then
	strWhere = strWhere & strCon & _
		"(EXISTS(SELECT * FROM VOL_OP_AI ai INNER JOIN VOL_AI_IG ig ON ai.AI_ID=ig.AI_ID WHERE ai.VNUM=vo.VNUM AND ig.IG_ID IN (" & strIGID & ")))"
	strCon = AND_CON

	If bSearchDisplay Then
		strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
			"SET @searchData = NULL" & vbCrLf & _
			"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>','')" & _
			" + ign.Name" & _
			" FROM VOL_InterestGroup_Name ign" & _
			" WHERE ign.IG_ID IN (" & strIGID & ")" & _
				" AND ign.LangID=(SELECT TOP 1 LangID FROM VOL_InterestGroup_Name WHERE IG_ID=ign.IG_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
			" ORDER BY ign.Name" & vbCrLf & _
			"IF @searchData IS NOT NULL SET @searchText = @searchText + '" & vbCrLf & "<search_display_item>" & Replace(TXT_GENERAL_AREA_OF_INTEREST, "'", "''") & TXT_COLON & "<em>' + @searchData + '</em></search_display_item>'"
	End If
End If

'--------------------------------------------------
' D. Schedule Search
'--------------------------------------------------

If Not Nl(strDateTime) Then
	Dim aDates, indDateTime, strDateTimeCon, strDateTimeSQL
	strDateTimeCon = vbNullString
	aDates = Split(strDateTime,",")
	If IsArray(aDates) Then
		For Each indDateTime in aDates
			indDateTime = Trim(indDateTime)
			If Not Nl(indDateTime) Then
				strDateTimeSQL = strDateTimeSQL & strDateTimeCon & indDateTime
				strDateTimeCon = OR_CON
			End If
		Next
		If Not Nl(strDateTimeCon) Then
			strWhere = strWhere & strCon & "(" & strDateTimeSQL & ")"
			strCon = AND_CON
		End If
	End If

	If bSearchDisplay Then
		Dim aWeek, _
			indDay, _
			aTime, _
			indTime, _
			strSchedule, _
			strDayCon, _
			strTimeCon

		aWeek = Array(Array("M",TXT_DAY_MONDAY),Array("TU",TXT_DAY_TUESDAY),Array("W",TXT_DAY_WEDNESDAY),Array("TH",TXT_DAY_THURSDAY),Array("F",TXT_DAY_FRIDAY),Array("ST",TXT_DAY_SATURDAY),Array("SU",TXT_DAY_SUNDAY))
		aTime = Array(Array("Morning", TXT_TIME_MORNING),Array("Afternoon", TXT_TIME_AFTERNOON),Array("Evening", TXT_TIME_EVENING))
		strDayCon = vbNullString
		strTimeCon = vbNullString
		strSchedule = vbNullString
	
		For Each indDay in aWeek
			If InStr(strDateTime,"_" & indDay(0) & "_") Then
				strSchedule = strSchedule & strDayCon & indDay(1) & " ("
				strTimeCon = vbNullString
				For Each indTime in aTime
					If inStr(strDateTime,"_" & indDay(0) & "_" & indTime(0)) Then
						strSchedule = strSchedule & strTimeCon & indTime(1)
						strTimeCon = ", "
					End If
				Next
				strDayCon = ")</em>" & TXT_OR_LC & "<em>"
			End If
		Next
	
		intCurrentSearch = intCurrentSearch + 1
		ReDim Preserve aSearch(intCurrentSearch)
		aSearch(intCurrentSearch) = "Dates and Times" & TXT_COLON & "<em>" & strSchedule & ")</em>"
	End If
End If

'--------------------------------------------------
' E. Age Search
'--------------------------------------------------

If Not Nl(decAge) Then
	strWhere = strWhere & strCon & "((vo.MIN_AGE IS NULL OR vo.MIN_AGE<=" & decAge & _
		") AND (vo.MAX_AGE IS NULL OR (FLOOR(vo.MAX_AGE)=vo.MAX_AGE AND vo.MAX_AGE+1>" & decAge & _
		") OR (vo.MAX_AGE>=" & decAge & ")))"
	strCon = AND_CON

	If bSearchDisplay Then		
		intCurrentSearch = intCurrentSearch + 1
		ReDim Preserve aSearch(intCurrentSearch)
		aSearch(intCurrentSearch) = TXT_AGES & TXT_COLON & "<em>" & CStr(decAge) & " " & TXT_YEARS & "</em>"
	End If
End If


'--------------------------------------------------
' F. OSSD
'--------------------------------------------------

If bOSSD Then
	strWhere = strWhere & strCon & "(vo.OSSD=" & SQL_TRUE & ")"
	strCon = AND_CON

	If bSearchDisplay Then		
		intCurrentSearch = intCurrentSearch + 1
		ReDim Preserve aSearch(intCurrentSearch)
		aSearch(intCurrentSearch) = TXT_OSSD_COMPONENT & TXT_COLON & "<em>" & TXT_OSSD_SUITABLE & "</em>"
	End If
End If

'--------------------------------------------------
' G. Accessibility
'--------------------------------------------------

Select Case dicCheckListSearch("AC").SearchType
	Case "A"
		Call dicCheckListSearch("AC").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("AC").noValuesSearch()
	Case Else
		Call dicCheckListSearch("AC").includeValuesSearch()
End Select

Call dicCheckListSearch("AC").excludeValuesSearch()
Call dicCheckListSearch("AC").includeValuesSearchCode()

'--------------------------------------------------
' H. Commitment Length
'--------------------------------------------------

Select Case dicCheckListSearch("CL").SearchType
	Case "A"
		Call dicCheckListSearch("CL").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("CL").noValuesSearch()
	Case Else
		Call dicCheckListSearch("CL").includeValuesSearch()
End Select

Call dicCheckListSearch("CL").excludeValuesSearch()
Call dicCheckListSearch("CL").includeValuesSearchCode()

'--------------------------------------------------
' I. Interaction Level
'--------------------------------------------------

Select Case dicCheckListSearch("IL").SearchType
	Case "A"
		Call dicCheckListSearch("IL").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("IL").noValuesSearch()
	Case Else
		Call dicCheckListSearch("IL").includeValuesSearch()
End Select

Call dicCheckListSearch("IL").excludeValuesSearch()
Call dicCheckListSearch("IL").includeValuesSearchCode()

'--------------------------------------------------
' J. Season
'--------------------------------------------------

Select Case dicCheckListSearch("SSN").SearchType
	Case "A"
		Call dicCheckListSearch("SSN").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("SSN").noValuesSearch()
	Case Else
		Call dicCheckListSearch("SSN").includeValuesSearch()
End Select

Call dicCheckListSearch("SSN").excludeValuesSearch()
Call dicCheckListSearch("SSN").includeValuesSearchCode()

'--------------------------------------------------
' K. Suitability
'--------------------------------------------------

Select Case dicCheckListSearch("SB").SearchType
	Case "A"
		Call dicCheckListSearch("SB").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("SB").noValuesSearch()
	Case Else
		Call dicCheckListSearch("SB").includeValuesSearch()
End Select

Call dicCheckListSearch("SB").excludeValuesSearch()
Call dicCheckListSearch("SB").includeValuesSearchCode()

'--------------------------------------------------
' L. Training
'--------------------------------------------------

Select Case dicCheckListSearch("TRN").SearchType
	Case "A"
		Call dicCheckListSearch("TRN").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("TRN").noValuesSearch()
	Case Else
		Call dicCheckListSearch("TRN").includeValuesSearch()
End Select

Call dicCheckListSearch("TRN").excludeValuesSearch()
Call dicCheckListSearch("TRN").includeValuesSearchCode()

'--------------------------------------------------
' M. Transportation
'--------------------------------------------------

Select Case dicCheckListSearch("TRP").SearchType
	Case "A"
		Call dicCheckListSearch("TRP").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("TRP").noValuesSearch()
	Case Else
		Call dicCheckListSearch("TRP").includeValuesSearch()
End Select

Call dicCheckListSearch("TRP").excludeValuesSearch()
Call dicCheckListSearch("TRP").includeValuesSearchCode()

'--------------------------------------------------
' N. Skills
'--------------------------------------------------

Select Case dicCheckListSearch("SK").SearchType
	Case "A"
		Call dicCheckListSearch("SK").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("SK").noValuesSearch()
	Case Else
		Call dicCheckListSearch("SK").includeValuesSearch()
End Select

Call dicCheckListSearch("SK").excludeValuesSearch()
Call dicCheckListSearch("SK").includeValuesSearchCode()

'--------------------------------------------------
' O. Social Media
'--------------------------------------------------

Select Case dicCheckListSearch("SM").SearchType
	Case "A"
		Call dicCheckListSearch("SM").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("SM").noValuesSearch()
	Case Else
		Call dicCheckListSearch("SM").includeValuesSearch()
End Select

Call dicCheckListSearch("SM").excludeValuesSearch()

'--------------------------------------------------
' P. RSN (Transitional)
'--------------------------------------------------

If Not Nl(intRSN) Then
	strWhere = strWhere & strCon & "(bt.RSN=" & intRSN & ")"
	strCon = AND_CON
End If

'--------------------------------------------------
' Q. Extra Checklist Search
'--------------------------------------------------

For Each indEXCType In aEXCTypes
	Select Case dicCheckListSearch("EXC" & indEXCType).SearchType
		Case "A"
			Call dicCheckListSearch("EXC" & indEXCType).anyValuesSearch()
		Case "N"
			Call dicCheckListSearch("EXC" & indEXCType).noValuesSearch()
		Case Else
			Call dicCheckListSearch("EXC" & indEXCType).includeValuesSearch()
	End Select

	Call dicCheckListSearch("EXC" & indEXCType).excludeValuesSearch()
	Call dicCheckListSearch("EXC" & indEXCType).includeValuesSearchCode()
Next

'--------------------------------------------------
' R. Extra Drop-Down Search
'--------------------------------------------------

For Each indEXDType In aEXDTypes
	Select Case dicCheckListSearch("EXD" & indEXDType).SearchType
		Case "A"
			Call dicCheckListSearch("EXD" & indEXDType).anyValuesSearch()
		Case "N"
			Call dicCheckListSearch("EXD" & indEXDType).noValuesSearch()
		Case Else
			Call dicCheckListSearch("EXD" & indEXDType).includeValuesSearch()
	End Select

	Call dicCheckListSearch("EXD" & indEXDType).excludeValuesSearch()
	Call dicCheckListSearch("EXD" & indEXDType).includeValuesSearchCode()
Next

%>
