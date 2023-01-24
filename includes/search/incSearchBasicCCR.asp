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
'--------------------------------------------------
' 1. Type of Program Search
'--------------------------------------------------

Set dicCheckListSearch("TOP") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("TOP").setValues("TOP","TOP", TXT_TYPE_OF_PROGRAM, False, True, "bt", "ccbt.TYPE_OF_PROGRAM", Null, "CCR_TypeOfProgram", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' 2. Type of Care Search
'--------------------------------------------------

Set dicCheckListSearch("TOC") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("TOC").setValues("TOC","TOC", TXT_TYPE_OF_CARE, False, False, "bt", "NUM", "CCR_BT_TOC", "CCR_TypeOfCare", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' 3. Schools in Area Search
'--------------------------------------------------

Set dicCheckListSearch("SCHA") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("SCHA").setValues("SCHA","SCHA", TXT_LOCAL_SCHOOLS, False, False, "bt", "NUM", "CCR_BT_SCH", "CCR_School", Null, Null, Null, False, "InArea=" & SQL_TRUE, Null, False)

'--------------------------------------------------
' 4. School Escort Search
'--------------------------------------------------

Set dicCheckListSearch("SCHE") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("SCHE").setValues("SCHE","SCHE", TXT_ESCORTS_TO, False, False, "bt", "NUM", "CCR_BT_SCH", "CCR_School", Null, Null, Null, False, "Escort=" & SQL_TRUE, Null, False)

'--------------------------------------------------
' 5. Child Care Subsidy
'--------------------------------------------------

Dim bCCSubsidy, _
	strCCSubsidyNP

bCCSubsidy = Request("CCSubsidy") = "on"
strCCSubsidyNP = Request("CCSubsidyNP")

If strCCSubsidyNP = "on" Then
	strCCSubsidyNP = "Y"
End If

'--------------------------------------------------
' 6. Child Care Space
'--------------------------------------------------

Dim bCCSpace
bCCSpace = Request("CCSpace") = "on"

'--------------------------------------------------

Sub setCCRBasicSearchData()

'--------------------------------------------------
' 1. Type of Program Search
'--------------------------------------------------

	Select Case dicCheckListSearch("TOP").SearchType
		Case "A"
			Call dicCheckListSearch("TOP").anyValuesSearch()
		Case "N"
			Call dicCheckListSearch("TOP").noValuesSearch()
		Case Else
			Call dicCheckListSearch("TOP").includeValuesSearch()
	End Select

	Call dicCheckListSearch("TOP").includeValuesSearchCode()

'--------------------------------------------------
' 2. Type of Care Search
'--------------------------------------------------

	Select Case dicCheckListSearch("TOC").SearchType
		Case "A"
			Call dicCheckListSearch("TOC").anyValuesSearch()
		Case "N"
			Call dicCheckListSearch("TOC").noValuesSearch()
		Case Else
			Call dicCheckListSearch("TOC").includeValuesSearch()
	End Select

	Call dicCheckListSearch("TOC").includeValuesSearchCode()

'--------------------------------------------------
' 3. Schools in Area Search
'--------------------------------------------------

	Select Case dicCheckListSearch("SCHA").SearchType
		Case "A"
			Call dicCheckListSearch("SCHA").anyValuesSearch()
		Case "N"
			Call dicCheckListSearch("SCHA").noValuesSearch()
		Case Else
			If Not Nl(dicCheckListSearch("SCHA").IDList) Then
				Select Case dicCheckListSearch("SCHA").SearchType
					Case "AF"
						Dim aSCHAID, strSCHASrch
						aSCHAID = Split(dicCheckListSearch("SCHA").IDList,",")
						If IsArray(aSCHAID) Then
							If UBound(aSCHAID) >= 0 Then
								strSCHASrch = "EXISTS(SELECT * FROM CCR_BT_SCH sch " & _
									"WHERE sch.InArea=" & SQL_TRUE & " AND sch.NUM=bt.NUM AND sch.SCH_ID="
								strWhere = strWhere & strCon & "(" & strSCHASrch & _
									Join(aSCHAID,") AND " & strSCHASrch) & "))"
								strCon = AND_CON
							End If
						End If
					Case Else
						strWhere = strWhere & strCon & _
							"(EXISTS(SELECT * FROM CCR_BT_SCH sch " & _
								"WHERE sch.InArea=" & SQL_TRUE & " AND sch.NUM=bt.NUM AND sch.SCH_ID IN (" & dicCheckListSearch("SCHA").IDList & ")))"
						strCon = AND_CON
				End Select
			
				If bSearchDisplay Then
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"SET @searchData = NULL" & vbCrLf & _
						"SELECT @searchData = COALESCE(@searchData + '</em>" & IIf(dicCheckListSearch("SCHA").SearchType="AF",TXT_AND_LC,TXT_OR_LC) & "<em>','')" & _
							" + schn.Name + CASE WHEN sch.SchoolBoard IS NULL THEN '' ELSE ' (' + sch.SchoolBoard + ')' END" & _
							" FROM CCR_School sch INNER JOIN CCR_School_Name schn ON sch.SCH_ID=schn.SCH_ID" & _
								" AND schn.LangID=(SELECT TOP 1 LangID FROM CCR_School_Name WHERE SCH_ID=schn.SCH_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
							" WHERE sch.SCH_ID IN (" & dicCheckListSearch("SCHA").IDList & ") ORDER BY schn.Name, sch.SchoolBoard" & vbCrLf & _
						"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & dicCheckListSearch("SCHA").Label & TXT_COLON & "<em>") & " + @searchData + '</em></search_display_item>'"
				End If
			End If
	End Select

'--------------------------------------------------
' 4. School Escort Search
'--------------------------------------------------

	Select Case dicCheckListSearch("SCHE").SearchType
		Case "A"
			Call dicCheckListSearch("SCHE").anyValuesSearch()
		Case "N"
			Call dicCheckListSearch("SCHE").noValuesSearch()
		Case Else
			If Not Nl(dicCheckListSearch("SCHE").IDList) Then
				Select Case dicCheckListSearch("SCHE").SearchType
					Case "AF"
						Dim aSCHEID, strSCHESrch
						aSCHEID = Split(dicCheckListSearch("SCHE").IDList,",")
						If IsArray(aSCHEID) Then
							If UBound(aSCHEID) >= 0 Then
								strSCHESrch = "EXISTS(SELECT * FROM CCR_BT_SCH sch " & _
									"WHERE sch.Escort=" & SQL_TRUE & " AND sch.NUM=bt.NUM AND sch.SCH_ID="
								strWhere = strWhere & strCon & "(" & strSCHESrch & _
									Join(aSCHEID,") AND " & strSCHESrch) & "))"
								strCon = AND_CON
							End If
						End If
					Case Else
						strWhere = strWhere & strCon & _
							"(EXISTS(SELECT * FROM CCR_BT_SCH sch " & _
								"WHERE sch.Escort=" & SQL_TRUE & " AND sch.NUM=bt.NUM AND sch.SCH_ID IN (" & dicCheckListSearch("SCHE").IDList & ")))"
						strCon = AND_CON
				End Select
			
				If bSearchDisplay Then
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"SET @searchData = NULL" & vbCrLf & _
						"SELECT @searchData = COALESCE(@searchData + '</em>" & IIf(dicCheckListSearch("SCHE").SearchType="AF",TXT_AND_LC,TXT_OR_LC) & "<em>','')" & _
							" + schn.Name + CASE WHEN sch.SchoolBoard IS NULL THEN '' ELSE ' (' + sch.SchoolBoard + ')' END" & _
							" FROM CCR_School sch INNER JOIN CCR_School_Name schn ON sch.SCH_ID=schn.SCH_ID" & _
								" AND schn.LangID=(SELECT TOP 1 LangID FROM CCR_School_Name WHERE SCH_ID=schn.SCH_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
							" WHERE sch.SCH_ID IN (" & dicCheckListSearch("SCHE").IDList & ") ORDER BY schn.Name, sch.SchoolBoard" & vbCrLf & _
						"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & dicCheckListSearch("SCHE").Label & TXT_COLON & "<em>") & " + @searchData + '</em></search_display_item>'"
				End If
			End If
	End Select


'--------------------------------------------------
' 5. Child Care Subsidy
'--------------------------------------------------

	If bCCSubsidy Then
		strWhere = strWhere & strCon & "(ccbt.SUBSIDY=" & SQL_TRUE & ")"
		strCon = AND_CON
	
		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_LIMIT_SUBSIDY
		End If
	End If

	Select Case strCCSubsidyNP
		Case "Y"
			strWhere = strWhere & strCon & "(ccbt.SUBSIDY_NAMED_PROGRAM=" & SQL_TRUE & ")"
			strCon = AND_CON
	
			If bSearchDisplay Then
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = g_strSubsidyNamedProgram
			End If
		Case "N"
			strWhere = strWhere & strCon & "(ccbt.SUBSIDY_NAMED_PROGRAM=" & SQL_FALSE & ")"
			strCon = AND_CON
	
			If bSearchDisplay Then
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = g_strSubsidyNamedProgram & " - " & TXT_NO
			End If
		Case "U"
			strWhere = strWhere & strCon & "(ccbt.SUBSIDY_NAMED_PROGRAM IS NULL)"
			strCon = AND_CON
	
			If bSearchDisplay Then
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = g_strSubsidyNamedProgram & " - " & TXT_UNKNOWN
			End If
	End Select

'--------------------------------------------------
' 6. Child Care Space
'--------------------------------------------------

	If bCCSpace Then
		strWhere = strWhere & strCon & "(ccbt.SPACE_AVAILABLE=" & SQL_TRUE & ")"
		strCon = AND_CON
	
		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_LIMIT_SPACE_AVAILABLE
		End If
	End If

End Sub
%>
