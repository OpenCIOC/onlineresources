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
'
' Purpose: 		Fetch parameters and generate SQL for record searches
'				Common to multiple modules of the software.
'
%>

<%
Class CheckListSearch
	Private Tag
	Public Label
	Private FieldOptionLabel
	Private DropDown
	Private BTAlias
	Private BTKey
	Private BTRelTable
	Private DataTable
	Private DataKey
	Private DataCode
	Private CustDisplayName
	Private CustOrderBy
	Private InclCoreDataTable
	Private OtherCriteria
	Private DataTableOtherCriteria
	Private AlwaysCode
	Public SearchType
	Public IDList
	Public CodeList
	Public IDListx

	Private Sub Class_Initialize()
		DropDown = False
		InclCoreDataTable = False
	End Sub

	Sub setValues(strTag, strIDTag, strLabel, bFetchLabel, _
				bDropDown, strBTAlias, strBTKey, strBTRelTable, _
				strDataTable, strCodeField, _
				strCustDisplayName, strCustOrderBy, _
				bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria, bAlwaysCode)
		Tag = strTag
		Label = strLabel
		FieldOptionLabel = bFetchLabel
		DropDown = bDropDown
		BTAlias = strBTAlias
		BTKey = strBTKey
		BTRelTable = strBTRelTable
		DataTable = strDataTable
		If strIDTag = "Profile" Then
			DataKey = strIDTag & "ID"
		Else
			DataKey = strIDTag & "_ID"
		End If
		DataCode = strCodeField
		AlwaysCode = bAlwaysCode
		CustDisplayName = strCustDisplayName
		CustOrderBy = strCustOrderBy
		InclCoreDataTable = bInclCoreDataTable Or Not Nl(DataCode)
		OtherCriteria = StringIf(Not Nl(strOtherCriteria)," AND " & strOtherCriteria)
		DataTableOtherCriteria = StringIf(Not Nl(strDTOtherCriteria)," AND " & strDTOtherCriteria)
		SearchType = Request(Tag & "Type")
		IDList = Request(Tag & "ID")
		CodeList = Request(Tag & "Code")
		If bAlwaysCode Then
			CodeList = Null
		End If
		If Not Nl(DataCode) And bAlwaysCode Then
			If Not IsCodeList(IDList) Then
				IDList = Null
			Else
				IDList = QsStrList(IDList)
			End If
		ElseIf Not IsIDList(IDList) Then
			IDList = Null
		End If
		If Not Nl(DataCode) And Not bAlwaysCode Then
			If Not IsCodeList(CodeList) Then
				CodeList = Null
			Else
				CodeList = QsStrList(CodeList)
			End If
		End If
		IDListx = Request(Tag & "IDx")
		If Not Nl(DataCode) And bAlwaysCode Then
			If Not IsCodeList(IDListx) Then
				IDListx = Null
			Else
				IDListx = QsStrList(IDListx)
			End If
		ElseIf Not IsIDList(IDListx) Then
			IDListx = Null
		End If
		If Nl(IDList) Then
			If SearchType = "F" Then
				strQueryString = reReplace(strQueryString,"(&)?" & Tag & "Type=F",vbNullString,False,False,False,False)
			End If
		End If
		If Not Nl(IDList) Then
			IDList = Replace(IDList," ",vbNullString)
			strQueryString = reReplace(strQueryString,"(&)?" & Tag & "ID=([^&$])*",vbNullString,True,False,True,False)
			If Not Nl(strQueryString) Then
				strQueryString = strQueryString & "&" & Tag & "ID=" & IDList
			Else
				strQueryString = Tag & "ID=" & IDList
			End If
		End If
		If Not Nl(IDListx) Then
			IDListx = Replace(IDListx," ",vbNullString)
			strQueryString = reReplace(strQueryString,"(&)?" & Tag & "IDx=([^&$])*",vbNullString,True,False,True,False)
			If Not Nl(strQueryString) Then
				strQueryString = strQueryString & "&" & Tag & "IDx=" & IDListx
			Else
				strQueryString = Tag & "IDx=" & IDListx
			End If
		End If
		If Not Nl(CodeList) Then
			CodeList = Replace(CodeList," ",vbNullString)
			strQueryString = reReplace(strQueryString,"(&)?" & Tag & "Code=([^&$])*",vbNullString,True,False,True,False)
			If Not Nl(strQueryString) Then
				strQueryString = strQueryString & "&" & Tag & "Code=" & CodeList
			Else
				strQueryString = Tag & "Code=" & CodeList
			End If
		End If
	End Sub

	Sub anyValuesSearch()
		If DropDown Then
			strWhere = strWhere & strCon & "(" & BTKey & " IS NOT NULL" & OtherCriteria & ")"
		Else
			strWhere = strWhere & strCon & _
				"(EXISTS(SELECT * FROM " & BTRelTable & " pr WHERE pr." & BTKey & "=" & BTAlias & "." & BTKey & OtherCriteria & "))"
		End If
		strCon = AND_CON
	
		If bSearchDisplay Then
			If FieldOptionLabel Then
				strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
					"SET @searchText = @searchText + '" & vbCrLf & "<search_display_item>'" & _
						" + (SELECT ISNULL(FieldDisplay, FieldName) FROM GBL_FieldOption fo LEFT JOIN GBL_FieldOption_Description fod ON fo.FieldID=fod.FieldID AND fod.LangID=" & g_objCurrentLang.LangID & " WHERE FieldName='" & Label & "')" & _
						" + '" & TXT_COLON & "<em>" & TXT_HAS_ANY & "</em></search_display_item>'"
			Else
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = Label & TXT_COLON & "<em>" & TXT_HAS_ANY & "</em>"
			End If
		End If
	End Sub

	Sub noValuesSearch()
		If DropDown Then
			strWhere = strWhere & strCon & "(" & BTKey & " IS NULL" & OtherCriteria & ")"
		Else
			strWhere = strWhere & strCon & _
				"(NOT EXISTS(SELECT * FROM " & BTRelTable & " pr WHERE pr." & BTKey & "=" & BTAlias & "." & BTKey & OtherCriteria & "))"
		End If
		strCon = AND_CON
	
		If bSearchDisplay Then
			If FieldOptionLabel Then
				strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
					"SET @searchText = @searchText + '" & vbCrLf & "<search_display_item>'" & _
						" + (SELECT ISNULL(FieldDisplay, FieldName) FROM GBL_FieldOption fo LEFT JOIN GBL_FieldOption_Description fod ON fo.FieldID=fod.FieldID AND fod.LangID=" & g_objCurrentLang.LangID & " WHERE FieldName='" & Label & "')" & _
						" + '" & TXT_COLON & "<em>" & TXT_HAS_NONE & "</em></search_display_item>'"
			Else
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = Label & TXT_COLON & "<em>" & TXT_HAS_NONE & "</em>"
			End If
		End If
	End Sub

	Sub includeValuesSearch()
		If Not Nl(IDList) Then
			If DropDown Then
				If Not Nl(DataCode) And AlwaysCode Then
					strWhere = strWhere & strCon & "(" & BTKey & " IN (SELECT " & DataKey & " FROM " & DataTable & " WHERE " & DataCode & " IN (" & IDList & "))" & OtherCriteria & ")"
				Else
					strWhere = strWhere & strCon & "(" & BTKey & " IN (" & IDList & ")" & OtherCriteria & ")"
				End If
				strCon = AND_CON
			Else
				Select Case SearchType
					Case "AF"
						Dim aID, strSrch
						aID = Split(IDList,",")
						If IsArray(aID) Then
							If UBound(aID) >= 0 Then
								strSrch = "EXISTS(SELECT * FROM " & BTRelTable & " pr " & _
									"WHERE pr." & BTKey & "=" & BTAlias & "." & BTKey & OtherCriteria & _
									" AND pr." & IIf(Not Nl(DataCode) And AlwaysCode, DataCode, DataKey) & "="
								strWhere = strWhere & strCon & "(" & strSrch & Join(aID,") AND " & strSrch) & "))"
								strCon = AND_CON
							End If
						End If
					Case Else
						strWhere = strWhere & strCon & _
							"(EXISTS(SELECT * FROM " & BTRelTable & " pr " & _
								"WHERE pr." & BTKey & "=" & BTAlias & "." & BTKey & OtherCriteria & _
								" AND pr." & IIf(Not Nl(DataCode) And AlwaysCode, DataCode,DataKey) & " IN (" & IDList & ")))"
						strCon = AND_CON
				End Select
			End If
		
			If bSearchDisplay Then
				strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
					"SET @searchData = NULL" & vbCrLf & _
					"SELECT @searchData = COALESCE(@searchData + '</em>" & IIf(SearchType="AF" And Not DropDown,TXT_AND_LC,TXT_OR_LC) & "<em>','')" & _
					" + " & Nz(CustDisplayName,"frn.Name") & _
					" FROM " & StringIf(InclCoreDataTable, DataTable & " fr LEFT JOIN ") & DataTable & "_Name frn" & StringIf(InclCoreDataTable," ON fr." & DataKey & "=frn." & DataKey) & _
						" " & IIf(InclCoreDataTable,"AND","WHERE") & " frn.LangID=(SELECT TOP 1 LangID FROM " & DataTable & "_Name WHERE " & DataKey & "=frn." & DataKey & " ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
						" " & IIf(InclCoreDataTable,"WHERE","AND") & " " & IIf(Nl(DataCode) Or Not AlwaysCode,IIf(InclCoreDataTable,"fr.","frn.") & DataKey,"fr." & DataCode) & " IN (" & IDList & ")" & DataTableOtherCriteria & _
					" ORDER BY " & Nz(CustOrderBy,"frn.Name")
				
				If FieldOptionLabel Then
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"SET @searchText = @searchText + '" & vbCrLf & "<search_display_item>'" & _
							" + (SELECT ISNULL(FieldDisplay, FieldName) FROM GBL_FieldOption fo LEFT JOIN GBL_FieldOption_Description fod ON fo.FieldID=fod.FieldID AND fod.LangID=" & g_objCurrentLang.LangID & " WHERE FieldName='" & Label & "')" & _
							" + '" & TXT_COLON & "<em>' + @searchData + '</em></search_display_item>'"
				Else
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & Label & TXT_COLON & "<em>") & " + @searchData + '</em></search_display_item>'"
				End If
			End If
		End If
	End Sub
	
	Sub excludeValuesSearch()
		If Not Nl(IDListx) Then
			If DropDown Then
				If Not Nl(DataCode) And AlwaysCode Then
					strWhere = strWhere & strCon & "(" & BTKey & " NOT IN (SELECT " & DataKey & " FROM " & DataTable & " WHERE " & DataCode & " IN (" & IDListx & "))" & OtherCriteria & ")"
				Else
					strWhere = strWhere & strCon & "(" & BTKey & " NOT IN (" & IDListx & ")" & OtherCriteria & ")"
				End If
				strCon = AND_CON
			Else
				strWhere = strWhere & strCon & _
					"(NOT EXISTS(SELECT * FROM " & BTRelTable & " pr " & _
					"WHERE pr." & BTKey & "=" & BTAlias & "." & BTKey & OtherCriteria & _
					" AND pr." & IIf(Not Nl(DataCode) And AlwaysCode, DataCode, DataKey) & " IN (" & IDListx & ")))"
			End If
			strCon = AND_CON
		
			If bSearchDisplay Then
				strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
					"SET @searchData = NULL" & vbCrLf & _
					"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>','')" & _
					" + " & Nz(CustDisplayName,"frn.Name") & _
					" FROM " & StringIf(InclCoreDataTable, DataTable & " fr LEFT JOIN ") & DataTable & "_Name frn" & StringIf(InclCoreDataTable," ON fr." & DataKey & "=frn." & DataKey) & _
						" " & IIf(InclCoreDataTable,"AND","WHERE") & " frn.LangID=(SELECT TOP 1 LangID FROM " & DataTable & "_Name WHERE " & DataKey & "=frn." & DataKey & " ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
						" " & IIf(InclCoreDataTable,"WHERE","AND") & " " & IIf(Nl(DataCode) Or Not AlwaysCode,IIf(InclCoreDataTable,"fr.","frn.") & DataKey,"fr." & DataCode) & " IN (" & IDListx & ")" & DataTableOtherCriteria & _
					" ORDER BY " & Nz(CustOrderBy,"frn.Name")
				
				If FieldOptionLabel Then
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"SET @searchText = @searchText + '" & vbCrLf & "<search_display_item>'" & _
							" + (SELECT ISNULL(FieldDisplay, FieldName) FROM GBL_FieldOption fo LEFT JOIN GBL_FieldOption_Description fod ON fo.FieldID=fod.FieldID AND fod.LangID=" & g_objCurrentLang.LangID & " WHERE FieldName='" & Label & "')" & _
							" + " & QsNl(TXT_COLON & "<em>" & TXT_DOES_NOT_HAVE) & " + @searchData + '</em></search_display_item>'"
				Else
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & Label & TXT_COLON & "<em>" & TXT_DOES_NOT_HAVE) & " + @searchData + '</em></search_display_item>'"
				End If
			End If
		End If
	End Sub

	Sub includeValuesSearchCode()
		If Not Nl(CodeList) Then
			If DropDown Then
				strWhere = strWhere & strCon & "(" & BTKey & " IN (SELECT " & DataKey & " FROM " & DataTable & " WHERE " & DataCode & " IN (" & CodeList & "))" & OtherCriteria & ")"
				strCon = AND_CON
			Else
				strWhere = strWhere & strCon & _
					"(EXISTS(SELECT * FROM " & BTRelTable & " pr " & _
						"WHERE pr." & BTKey & "=" & BTAlias & "." & BTKey & OtherCriteria & _
						" AND pr." & DataKey & " IN (SELECT " & DataKey & " FROM " & DataTable & " WHERE " & DataCode & " IN (" & CodeList & "))))"
				strCon = AND_CON
			End If
		
			If bSearchDisplay Then
				strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
					"SET @searchData = NULL" & vbCrLf & _
					"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>','')" & _
					" + " & Nz(CustDisplayName,"frn.Name") & _
					" FROM " & StringIf(InclCoreDataTable, DataTable & " fr LEFT JOIN ") & DataTable & "_Name frn" & StringIf(InclCoreDataTable," ON fr." & DataKey & "=frn." & DataKey) & _
						" " & IIf(InclCoreDataTable,"AND","WHERE") & " frn.LangID=(SELECT TOP 1 LangID FROM " & DataTable & "_Name WHERE " & DataKey & "=frn." & DataKey & " ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
						" " & IIf(InclCoreDataTable,"WHERE","AND") & " " & "fr." & DataCode & " IN (" & CodeList & ")" & DataTableOtherCriteria & _
					" ORDER BY " & Nz(CustOrderBy,"frn.Name")
				
				If FieldOptionLabel Then
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"SET @searchText = @searchText + '" & vbCrLf & "<search_display_item>'" & _
							" + (SELECT ISNULL(FieldDisplay, FieldName) FROM GBL_FieldOption fo LEFT JOIN GBL_FieldOption_Description fod ON fo.FieldID=fod.FieldID AND fod.LangID=" & g_objCurrentLang.LangID & " WHERE FieldName='" & Label & "')" & _
							" + '" & TXT_COLON & "<em>' + @searchData + '</em></search_display_item>'"
				Else
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & Label & TXT_COLON & "<em>") & " + @searchData + '</em></search_display_item>'"
				End If
			End If
		End If
	End Sub
	
End Class

Dim dicCheckListSearch
Set dicCheckListSearch = Server.CreateObject("Scripting.Dictionary")

Dim strSearchInfoSQL, _
	strSearchInfo

strSearchInfo = vbNullString
strSearchInfoSQL = "DECLARE @searchText [varchar](max)," & vbCrLf & _
	"@searchData [varchar](max)" & vbCrLf & _
	"SET @searchText = ''"

Dim aSearch, _
	intCurrentSearch, _
	indSearch

intCurrentSearch = -1
ReDim aSearch(intCurrentSearch)

Dim strSearchErrors, _
	strErrorCon

strSearchErrors = vbNullString
strErrorCon = vbNullString

'--------------------------------------------------
' 1. Keyword Search
'--------------------------------------------------
Dim strSTermsOrg, _
	strSTypeOrg, _
	intSConOrg, _
	strSTermsPos, _
	intSConPos

Dim strJoinedSTerms, _
	strJoinedQSTerms, _
	strJoinedSTermsPos, _
	strJoinedQSTermsPos, _
	strContains, _
	strContainsQ, _
	strBTKey

Dim singleSTerms(), _
	quotedSTerms(), _
	exactSTerms(), _
	displaySTerms(), _
	singleSTermsPos(), _
	quotedSTermsPos(), _
	exactSTermsPos(), _
	displaySTermsPos()

Dim strDisplaySTerms, _
	strDisplaySTermsPos

Dim	bRelevancy

Select Case Request("SCon")
	Case "O"
		intSConOrg = JTYPE_OR
	Case "B"
		intSConOrg = JTYPE_BOOLEAN
	Case Else
		intSConOrg = JTYPE_AND
End Select

If intSConOrg = JTYPE_BOOLEAN And Not user_bLoggedIn Then
	intSConOrg = JTYPE_AND
End If

strSTermsOrg = Trim(Request("STerms"))
strSTypeOrg = Request("SType")

If ps_intDbArea = DM_VOL Then
	If Request("SType") = "P" Then
		strSTermsPos = strSTermsOrg
		strSTermsOrg = vbNullString
		intSConPos = JTYPE_AND
	Else
		strSTermsPos = Trim(Request("STermsPos"))
		Select Case Request("SConPos")
			Case "O"
				intSConPos = JTYPE_OR
			Case "B"
				intSConPos = JTYPE_BOOLEAN
			Case Else
				intSConPos = JTYPE_AND
		End Select

		If intSConPos = JTYPE_BOOLEAN And Not user_bLoggedIn Then
			intSConPos = JTYPE_AND
		End If
	End If
End If

If ps_intDbArea = DM_CIC Then
	bRelevancy = (opt_intOrderByCIC = OB_RELEVANCY)
Else
	bRelevancy = False
End If

If Not Nl(strSTermsOrg) Then
	Call makeSearchString( _
		strSTermsOrg, _
		singleSTerms, _
		quotedSTerms, _
		exactSTerms, _
		displaySTerms, _
		intSConOrg = JTYPE_BOOLEAN _
	)

	Select Case intSConOrg
		Case JTYPE_BOOLEAN
			strJoinedSTerms = vbNullString
			strJoinedQSTerms = Join(exactSTerms," ")
			strDisplaySTerms = Join(exactSTerms," ")
		Case JTYPE_OR
			strJoinedSTerms = Join(singleSTerms,OR_CON)
			strJoinedQSTerms = Join(quotedSTerms,OR_CON)
			strDisplaySTerms = Join(displaySTerms," " & TXT_OR & " ")
		Case JTYPE_AND
			strJoinedSTerms = Join(singleSTerms,AND_CON)
			strJoinedQSTerms = Join(quotedSTerms,AND_CON)
			strDisplaySTerms = Join(displaySTerms," " & TXT_AND & " ")
	End Select
Else
	ReDim singleSTerms(-1)
	ReDim quotedSTerms(-1)
	ReDim exactSTerms(-1)
End If

If ps_intDbArea = DM_VOL Then
	If Not Nl(strSTermsPos) Then
		Call makeSearchString( _
			strSTermsPos, _
			singleSTermsPos, _
			quotedSTermsPos, _
			exactSTermsPos, _
			displaySTermsPos, _
			intSConPos = JTYPE_BOOLEAN _
		)
	End If

	Select Case intSConPos
		Case JTYPE_BOOLEAN
			strJoinedSTermsPos = vbNullString
			strJoinedQSTermsPos = Join(exactSTermsPos," ")
			strDisplaySTermsPos = Join(displaySTermsPos," ")
		Case JTYPE_OR
			strJoinedSTermsPos = Join(singleSTermsPos,OR_CON)
			strJoinedQSTermsPos = Join(quotedSTermsPos,OR_CON)
			strDisplaySTermsPos = Join(displaySTermsPos,OR_CON)
		Case JTYPE_AND
			strJoinedSTermsPos = Join(singleSTermsPos,AND_CON)
			strJoinedQSTermsPos = Join(quotedSTermsPos,AND_CON)
			strDisplaySTermsPos = Join(displaySTermsPos,AND_CON)
	End Select
Else
	ReDim singleSTermsPos(-1)
	ReDim quotedSTermsPos(-1)
	ReDim exactSTermsPos(-1)
End If

'--------------------------------------------------
' 2. Specific Organization Record Number
'--------------------------------------------------

Dim strNUMList, _
	aNUM, _
	indNUM, _
	strNUMListCon

strNUMList = reReplace(Trim(Request("NUM")), "(\s|,|;)+", ",", False, False, True, False)
aNUM = Split(strNUMList,",")
strNUMList = vbNullString
strNUMListCon = vbNullString

For Each indNUM in aNUM
	If reEquals(indNUM,"([A-Za-z]){3}([0-9]){4,5}",False,False,True,False) Then
		strNUMList = strNUMList & strNUMListCon & Qs(indNUM,SQUOTE)
		strNUMListCon = ","
	Else
		strSearchErrors = strSearchErrors & strErrorCon & TXT_WARNING & TXT_WARNING_RECORD_NUM & "&quot;" & Server.HTMLEncode(Ns(indNUM)) & "&quot;"
		strErrorCon = "<br>"
	End If
Next

'--------------------------------------------------
' 3. Mine / Shared With Me
'-------------------------------------------------

Dim strSharedWMe

strSharedWMe = Trim(Request("Shared"))

'--------------------------------------------------

Dim strMainTable, _
	strMainTableLn, _
	strMainKey

Select Case ps_intDbArea
	Case DM_CIC
		strMainTable = "bt"
		strMainTableLn = "btd"
		strMainKey = "NUM"
	Case DM_VOL
		strMainTable = "vo"
		strMainTableLn = "vod"
		strMainKey = "VNUM"
End Select

Sub setCommonBasicSearchData()

'--------------------------------------------------
' 1. Keyword Search
'--------------------------------------------------

	Select Case ps_intDbArea
		Case DM_CIC
			If Not (Nl(strJoinedSTerms) And Nl(strJoinedQSterms)) Then
				If bSearchDisplay Then
					intCurrentSearch = intCurrentSearch + 1
					ReDim Preserve aSearch(intCurrentSearch)
					aSearch(intCurrentSearch) = TXT_FIND & " <em>" & Server.HTMLEncode(Replace(strDisplaySTerms,SQUOTE & SQUOTE,SQUOTE)) & "</em>"
				End IF
			
				strContains = vbNullString
				strContainsQ = vbNullString
			
				Select Case strSTypeOrg
					'Search by Subject
					Case "S"
						If Not Nl(strJoinedSTerms) Then
							strContains = IIf(bRelevancy, _
								"CIC_BaseTable_Description,", _
								"cbtd.") & _
								"SRCH_Subjects,'" & strJoinedSTerms & "'"
							strBTKey = "cbtd.CBTD_ID"
						End If
					
						If Not Nl(strJoinedQSTerms) Then
							strContainsQ = IIf(bRelevancy, _
								"CIC_BaseTable_Description,", _
								"cbtd.") & _
								"SRCH_Subjects,'" & strJoinedQSTerms & "'"
							strBTKey = "cbtd.CBTD_ID"
						End If
					
						If bSearchDisplay Then
							aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & " " & TXT_IN & " <em>" & TXT_SUBJECTS & "</em>"
						End If

					'Search by Service Category (Taxonomy)
					Case "T"
						If Not Nl(strJoinedSTerms) Then
							strContains = IIf(bRelevancy, _
								"CIC_BaseTable_Description,", _
								"cbtd.") & _
								"SRCH_Taxonomy,'" & strJoinedSTerms & "'"
							strBTKey = "cbtd.CBTD_ID"
						End If
					
						If Not Nl(strJoinedQSTerms) Then
							strContainsQ = IIf(bRelevancy, _
								"CIC_BaseTable_Description,", _
								"cbtd.") & _
								"SRCH_Taxonomy,'" & strJoinedQSTerms & "'"
							strBTKey = "cbtd.CBTD_ID"
						End If

						If bSearchDisplay Then
							aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & " " & TXT_IN & " <em>" & TXT_SERVICE_CATEGORIES & "</em>"
						End If

					'Search Organization and Program Names
					Case "O"
						If Not Nl(strJoinedSTerms) Then
							strContains = IIf(bRelevancy, _
								"GBL_BaseTable_Description,", _
								"btd.") & _
								"SRCH_Org,'" & strJoinedSTerms & "'"
							strBTKey = "btd.BTD_ID"
						End If
					
						If Not Nl(strJoinedQSTerms) Then
							strContainsQ = IIf(bRelevancy, _
								"GBL_BaseTable_Description,", _
								"btd.") & _
								"SRCH_Org,'" & strJoinedQSTerms & "'"
							strBTKey = "btd.BTD_ID"
						End If

						If bSearchDisplay Then
							aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & " " & TXT_IN & " <em>" & Nz(get_view_data_cic("OrgProgramNames"), TXT_ORG_NAMES) & "</em>"
						End If

					'Search Anywhere
					Case Else
						If Not Nl(strJoinedSTerms) Then
							strContains = IIf(bRelevancy, _
								"GBL_BaseTable_Description,", _
								"btd.") & _
								"SRCH_Anywhere,'" & strJoinedSTerms & "'"
							strBTKey = "btd.BTD_ID"
						End If
					
						If Not Nl(strJoinedQSTerms) Then
							strContainsQ = IIf(bRelevancy, _
								"GBL_BaseTable_Description,", _
								"btd.") & _
								"SRCH_Anywhere,'" & strJoinedQSTerms & "'"
							strBTKey = "btd.BTD_ID"
						End If

						If bSearchDisplay Then
							aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & " " & TXT_IN & " <em>" & TXT_WORDS_ANYWHERE & "</em>"
						End If
				End Select
				If bRelevancy Then
					If Not Nl(strContains) Then
						strFrom = strFrom & IIf(Nl(strContainsQ) Or intSConOrg <> JTYPE_OR," INNER"," LEFT") & " JOIN CONTAINSTABLE(" & strContains & ",LANGUAGE '" & g_objCurrentLang.LanguageAlias & "') kt ON kt.[KEY]=" & strBTKey
					End If
					If Not Nl(strContainsQ) Then
						strFrom = strFrom & IIf(Nl(strContains) Or intSConOrg <> JTYPE_OR," INNER"," LEFT") & " JOIN CONTAINSTABLE(" & strContainsQ & ") ktq ON ktq.[KEY]=" & strBTKey
					End If
					If Not (Nl(strContains) Or Nl(strContainsQ)) And intSConOrg = JTYPE_OR Then
						strWhere = strWhere & strCon & "(kt.[KEY] IS NOT NULL OR ktq.[KEY] IS NOT NULL)"
						strcon = AND_CON
					End If			
				Else
					strWhere = strWhere & strCon & "("
					If Not Nl(strContains) Then
						strWhere = strWhere & "CONTAINS(" & strContains & ",LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
					End If
					If Not Nl(strContainsQ) Then
						strWhere = strWhere & StringIf(Not Nl(strContains),IIf(intSConOrg = JTYPE_OR,OR_CON,AND_CON)) & "CONTAINS(" & strContainsQ & ")"
						strCon = AND_CON
					End If
					strWhere = strWhere & ")"
					strCon = AND_CON
				End If
			End If
		Case DM_VOL
			If Not (Nl(strJoinedSTerms) And Nl(strJoinedQSTerms)) Then
				strContains = vbNullString
				strContainsQ = vbNullString
			
				If Not Nl(strJoinedSTerms) Then
					strContains = "btd.SRCH_Org,'" & strJoinedSTerms & "'"
				End If
			
				If Not Nl(strJoinedQSTerms) Then
					strContainsQ = "btd.SRCH_Org,'" & strJoinedQSTerms & "'"
				End If

				strWhere = strWhere & strCon & "("
				If Not Nl(strContains) Then
					strWhere = strWhere & "CONTAINS(" & strContains & ",LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
				End If
				If Not Nl(strContainsQ) Then
					strWhere = strWhere & StringIf(Not Nl(strContains),IIf(intSConOrg = JTYPE_OR,OR_CON,AND_CON)) & "CONTAINS(" & strContainsQ & ")"
					strCon = AND_CON
				End If
				strWhere = strWhere & ")"
				strCon = AND_CON
			
				If bSearchDisplay Then
					intCurrentSearch = intCurrentSearch + 1
					ReDim Preserve aSearch(intCurrentSearch)
					aSearch(intCurrentSearch) = TXT_FIND & " <em>" & Server.HTMLEncode(Replace(strDisplaySTerms,SQUOTE & SQUOTE,SQUOTE)) & "</em>" & " " & TXT_IN & " <em>" & Nz(get_view_data_cic("OrgProgramNames"), TXT_ORG_NAMES) & "</em>"
				End If
			End If
			If Not (Nl(strJoinedSTermsPos) And Nl(strJoinedQSTermsPos)) Then
				strContains = vbNullString
				strContainsQ = vbNullString
			
				If bSearchDisplay Then
					intCurrentSearch = intCurrentSearch + 1
					ReDim Preserve aSearch(intCurrentSearch)
					aSearch(intCurrentSearch) = TXT_FIND & " <em>" & Server.HTMLEncode(Replace(strDisplaySTermsPos,SQUOTE & SQUOTE,SQUOTE)) & "</em>"
				End If
			
				Select Case Request("STypePos")
					'Search Position Title
					Case "P"
						If Not Nl(strJoinedSTermsPos) Then
							strContains = "vod.POSITION_TITLE,'" & strJoinedSTermsPos & "'"
						End If
					
						If Not Nl(strJoinedQSTermsPos) Then
							strContainsQ = "vod.POSITION_TITLE,'" & strJoinedQSTermsPos & "'"
						End If
					
						If bSearchDisplay Then
							aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & " " & TXT_IN & " <em>" & TXT_POSITION_TITLE & "</em>"
						End If
					'Search Ares of Interest
					Case "S"
						If Not Nl(strJoinedSTermsPos) Then
							strContains = "vod.CMP_Interests,'" & strJoinedSTermsPos & "'"
						End If
					
						If Not Nl(strJoinedQSTermsPos) Then
							strContainsQ = "vod.CMP_Interests,'" & strJoinedQSTermsPos & "'"
						End If
					
						If bSearchDisplay Then
							aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & " " & TXT_IN & " <em>Areas of Interest</em>"
						End If
					'Search Anywhere
					Case Else
						If Not Nl(strJoinedSTermsPos) Then
							strContains = "vod.SRCH_Anywhere,'" & strJoinedSTermsPos & "'"
						End If
					
						If Not Nl(strJoinedQSTermsPos) Then
							strContainsQ = "vod.SRCH_Anywhere,'" & strJoinedQSTermsPos & "'"
						End If

						If bSearchDisplay Then
							aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & " " & TXT_IN & " <em>" & TXT_WORDS_ANYWHERE & "</em>"
						End If
				End Select

				strWhere = strWhere & strCon & "("
				If Not Nl(strContains) Then
					strWhere = strWhere & "CONTAINS(" & strContains & ",LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
				End If
				If Not Nl(strContainsQ) Then
					strWhere = strWhere & StringIf(Not Nl(strContains),IIf(intSConPos = JTYPE_OR,OR_CON,AND_CON)) & "CONTAINS(" & strContainsQ & ")"
					strCon = AND_CON
				End If
				strWhere = strWhere & ")"
				strCon = AND_CON
			
			End If
	End Select

	'Response.Write(strWhere)
	'Response.Flush()

'--------------------------------------------------
' 2. Specific Organization Record Number
'--------------------------------------------------

	If Not Nl(strNUMList) Then
		strWhere = strWhere & strCon & "(bt.NUM IN (" & strNUMList & "))"
		strCon = AND_CON
	
		If bSearchDisplay Then
			If ps_intDbArea = DM_CIC Then
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_RECORD_NUM & TXT_COLON & " <em>" & strNUMList & "</em>"
			Else
				strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
					"SET @searchData = NULL" & vbCrLf & _
					"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>', '')" & _
					" + dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME)" & _
					" FROM GBL_BaseTable bt INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM " & _
					" AND LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
					"WHERE bt.NUM IN (" & strNUMList & ")" & vbCrLf & _
					"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & Nz(get_view_data_cic("OrgProgramNames"), TXT_ORG_NAMES) & TXT_COLON & "<em>") & " + @searchData + '</em></search_display_item>'"
			End If
		End If
	End If

'--------------------------------------------------
' 2. Specific Organization Record Number
'--------------------------------------------------

	If Not Nl(strSharedWMe) Then
		Select Case strSharedWMe
			Case "Y"
				strWhere = strWhere & strCon & "(" & strMainTable & ".MemberID<>" & g_intMemberID & ")"
				strCon = AND_CON
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_SHARED_RECORDS & TXT_COLON & "<em>" & TXT_ONLY_NOT_MINE & g_strMemberNameDOM & "</em>"
			Case "N"
				strWhere = strWhere & strCon & "(" & strMainTable & ".MemberID=" & g_intMemberID & ")"
				strCon = AND_CON
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_SHARED_RECORDS & TXT_COLON & "<em>" & TXT_ONLY_MINE & g_strMemberNameDOM & "</em>"
		End Select
	End If

End Sub
%>
