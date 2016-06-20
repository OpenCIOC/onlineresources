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
If user_bLoggedIn Then
	Call setDateFieldVars("CD1",strCFldDIDList1,strFirstDate1,strLastDate1,strFirstDateName1,strLastDateName1,strDateRange1)
	Call setDateFieldVars("CD2",strCFldDIDList2,strFirstDate2,strLastDate2,strFirstDateName2,strLastDateName2,strDateRange2)
	Call setCustFieldVars("CF1",strCFldIDList1,strCFldType1,strCFldVal1,bCFldAll1,bCFldInc1)
	Call setCustFieldVars("CF2",strCFldIDList2,strCFldType2,strCFldVal2,bCFldAll2,bCFldInc2)
End If

'--------------------------------------------------
' 1. Record Owner
'--------------------------------------------------

Dim	strRO
strRO = Trim(Request("RO"))
If Not reEquals(strRO, "[A-Z]{3}(\s*,\s*[A-Z]{3})*", True, False, True, False) Then
	strRO = Null
End If

'--------------------------------------------------
' 2. Last Email Requesting Update
'--------------------------------------------------

	Dim	intLastEmail
	
	intLastEmail = Trim(Request("LastEmail"))
	If Not Nl(intLastEmail) Then
		If Not IsNumeric(intLastEmail) Then
			strSearchErrors = strSearchErrors & strErrorCon & TXT_WARNING & TXT_WARNING_EMAIL_DATE & "&quot;" & Server.HTMLEncode(Ns(intLastEmail)) & "&quot;" & TXT_IS_NOT_A_NUMBER
			strErrorCon = "<br>"
			intLastEmail = Null
		ElseIf intLastEmail <= 0 Or intLastEmail > 999 Then
			strSearchErrors = strSearchErrors & strErrorCon & TXT_WARNING & TXT_WARNING_EMAIL_DATE & "&quot;" & Server.HTMLEncode(Ns(intLastEmail)) & "&quot;"
			strErrorCon = "<br>"
			intLastEmail = Null
		End If
	End If

'--------------------------------------------------
' 3. Public / Non-Public Search
'--------------------------------------------------

Dim strPublicStatus
strPublicStatus = Request("PublicStatus")

'--------------------------------------------------
' 4. Deleted Record Inclusion
'--------------------------------------------------

Dim bIncludeDeleted
bIncludeDeleted = Request("incDel") = "on" And g_bCanSeeDeletedDOM

'--------------------------------------------------
' 5. Email Search
'--------------------------------------------------

Dim strHasEmail
strHasEmail = Request("HasEmail")

If strHasEmail="A" Then
	strQueryString = reReplace(strQueryString,"(&)?HasEmail=A",vbNullString,False,False,False,False)
End If

'--------------------------------------------------
' 6. Custom Field Searches
'--------------------------------------------------

Dim strTmpCustSearch

If user_bLoggedIn _
	And ( _
		Not Nl(strCFldDIDList1) _
		Or Not Nl(strCFldDIDList2) _
		Or Not Nl(strCFldIDList1) _
		Or Not Nl(strCFldIDList2) _
		) Then
		Call getCustomResultsFields()
		
End If

If Nl(strCFldIDList1) Then
	strQueryString = reReplace(strQueryString,"(&)?CF1Type=.",vbNullString,False,False,False,False)
End If
If Nl(strCFldIDList2) Then
	strQueryString = reReplace(strQueryString,"(&)?CF2Type=.",vbNullString,False,False,False,False)
End If
If Nl(strCFldDIDList1) Then
	strQueryString = reReplace(strQueryString,"(&)?CD1DateType=[0-9]+",vbNullString,False,False,False,False)
End If
If Nl(strCFldDIDList2) Then
	strQueryString = reReplace(strQueryString,"(&)?CD2DateType=[0-9]+",vbNullString,False,False,False,False)
End If

'--------------------------------------------------
' 7. Add SQL
'--------------------------------------------------

	Dim strLimitSQL
	
	If user_bLoggedIn Then
		strLimitSQL = Trim(Request("Limit"))
		If Not Nl(strLimitSQL) Then
			If Not (user_bCanAddSQLCIC And ps_intDbArea=DM_CIC _
					Or user_bCanAddSQLVOL And ps_intDbArea=DM_VOL _
				) Then
				Call handleError(TXT_WARNING & TXT_WARNING_ADD_SQL, _
					vbNullString, vbNullString)
				strLimitSQL = Null
			End If
		End If
	End If

'--------------------------------------------------
' 8. Refine Search
'--------------------------------------------------

	If user_bLoggedIn Then
		Call InitializeRecentSearch()
	End If

'--------------------------------------------------

Sub setCommonAdvSearchData()

'--------------------------------------------------
' 1. Record Owner
'--------------------------------------------------

	If Not Nl(strRO) Then
		strWhere = strWhere & strCon & "(" & strMainTable & ".RECORD_OWNER IN ('" & reReplace(strRO,"\s*,\s*","','",False,False,True,False) & "'))"
		strCon = AND_CON
		
		If bSearchDisplay Then			
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_RECORD_OWNER & TXT_COLON & "<em>" & reReplace(strRO,"\s*,\s*","</em>" & TXT_OR_LC & "<em>",False,False,True,False) & "</em>"
		End If
	End If
	

'--------------------------------------------------
' 2. Last Email Requesting Update
'--------------------------------------------------

	If Not Nl(intLastEmail) Then
		strWhere = strWhere & strCon & "(" & strMainTable & _
				".EMAIL_UPDATE_DATE < DATEADD(d,-" & intLastEmail & ",CONVERT(varchar(12),GETDATE(),106))" & _
				" OR " & strMainTable & ".EMAIL_UPDATE_DATE IS NULL)" 
		strCon = AND_CON
		
		If bSearchDisplay Then			
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_LAST_EMAIL_UPDATE & TXT_COLON & TXT_MORE_THAN & " <em>" & intLastEmail & "</em>" & " " & TXT_DAYS
		End If
	End If
	
'--------------------------------------------------
' 3. Public / Non-Public Search
'--------------------------------------------------

	Select Case strPublicStatus
		Case "N"
			strPublicStatus = SQL_TRUE
			If bSearchDisplay Then			
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_PUBLIC_STATUS & TXT_COLON & "<em>" & TXT_ONLY_NONPUBLIC & "</em>"
			End If
		Case "P"
			strPublicStatus = SQL_FALSE
			If bSearchDisplay Then			
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_PUBLIC_STATUS & TXT_COLON & "<em>" & TXT_ONLY_PUBLIC & "</em>"
			End If
		Case Else
			strPublicStatus = Null
	End Select
	
	If Not Nl(strPublicStatus) Then
		strWhere = strWhere & strCon & "(" & strMainTableLn & ".NON_PUBLIC=" & strPublicStatus & ")"
		strCon = AND_CON
	End If
	
'--------------------------------------------------
' 4. Deleted Record Exclusion
'--------------------------------------------------

	If bSearchDisplay And bIncludeDeleted Then			
		intCurrentSearch = intCurrentSearch + 1
		ReDim Preserve aSearch(intCurrentSearch)
		aSearch(intCurrentSearch) = TXT_DELETED_STATUS & TXT_COLON & "<em>" & TXT_INCLUDE_DELETED & "</em>"
	End If

'--------------------------------------------------
' 5. Email Search
'--------------------------------------------------

	If Not Nl(strHasEmail) Then
		Dim strSecondaryEmail
		If ps_intDbArea = DM_VOL Then
			strSecondaryEmail = "(SELECT TOP 1 EMAIL AS CONTACT_EMAIL FROM GBL_Contact AS CONTACT WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL IS NOT NULL)"
		Else
			strSecondaryEmail = "(SELECT TOP 1 E_MAIL FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND btd2.E_MAIL IS NOT NULL)"
		End If
		
		Select Case strHasEmail
			Case "E"
				strWhere = strWhere & strCon & "(" & strMainTable & ".UPDATE_EMAIL IS NOT NULL OR " & strSecondaryEmail & " IS NOT NULL)"
				strCon = AND_CON
				
				If bSearchDisplay Then			
					intCurrentSearch = intCurrentSearch + 1
					ReDim Preserve aSearch(intCurrentSearch)
					aSearch(intCurrentSearch) = TXT_EMAIL & TXT_COLON & "<em>" & TXT_ONLY_EMAIL & "</em>"
				End If
			Case "NE"
				strWhere = strWhere & strCon & "(" & strMainTable & ".UPDATE_EMAIL IS NULL AND " & strSecondaryEmail & " IS NULL)"
				strCon = AND_CON
				
				If bSearchDisplay Then			
					intCurrentSearch = intCurrentSearch + 1
					ReDim Preserve aSearch(intCurrentSearch)
					aSearch(intCurrentSearch) = TXT_EMAIL & TXT_COLON & "<em>" & TXT_ONLY_NO_EMAIL & "</em>"
				End If
			Case "U"
				strWhere = strWhere & strCon & "((" & strMainTable & ".UPDATE_EMAIL IS NOT NULL OR " & strSecondaryEmail & " IS NOT NULL) AND " & strMainTable & ".NO_UPDATE_EMAIL=" & SQL_FALSE & ")"
				strCon = AND_CON

				If g_bOtherMembers Then
					strWhere = strWhere & strCon & "(bt.MemberID=" & g_intMemberID & _
						" OR EXISTS(SELECT * FROM " & IIf(ps_intDbArea=DM_CIC,"GBL_BT","VOL_OP") & "_SharingProfile pr" & _
						" INNER JOIN GBL_SharingProfile shp ON pr.ProfileID=shp.ProfileID AND shp.Active=1 AND shp.CanUpdateRecords=1" & _
						" AND (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_" & ps_strDbArea & "_View WHERE ProfileID=shp.ProfileID AND ViewType=" & g_intViewTypeDOM & "))" & _
						" WHERE " & strMainKey & "=" & strMainTable & "." & strMainKey & " AND ShareMemberID_Cache=" & g_intMemberID & "))"
					strCon = AND_CON
				End If
				
				If bSearchDisplay Then			
					intCurrentSearch = intCurrentSearch + 1
					ReDim Preserve aSearch(intCurrentSearch)
					aSearch(intCurrentSearch) = TXT_EMAIL & TXT_COLON & "<em>" & TXT_CAN_UPDATE_EMAIL & "</em>"
				End If
			Case "NU"
				If g_bOtherMembers Then
					strWhere = strWhere & strCon & "(" & _
						"((" & strMainTable & ".UPDATE_EMAIL IS NULL AND " & strSecondaryEmail & " IS NULL) OR " & strMainTable & ".NO_UPDATE_EMAIL=" & SQL_TRUE & ")" & _
						" OR NOT (bt.MemberID=" & g_intMemberID & _
						" OR EXISTS(SELECT * FROM " & IIf(ps_intDbArea=DM_CIC,"GBL_BT","VOL_OP") & "_SharingProfile pr" & _
						" INNER JOIN GBL_SharingProfile shp ON pr.ProfileID=shp.ProfileID AND shp.Active=1 AND shp.CanUpdateRecords=1" & _
						" AND (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_" & ps_strDbArea & "_View WHERE ProfileID=shp.ProfileID AND ViewType=" & g_intViewTypeDOM & "))" & _
						" WHERE " & strMainKey & "=" & strMainTable & "." & strMainKey & " AND ShareMemberID_Cache=" & g_intMemberID & "))" & _
						")"
					strCon = AND_CON
				Else
					strWhere = strWhere & strCon & "((" & strMainTable & ".UPDATE_EMAIL IS NULL AND " & strSecondaryEmail & " IS NULL) OR " & strMainTable & ".NO_UPDATE_EMAIL=" & SQL_TRUE & ")"
				End If
				strCon = AND_CON
				
				If bSearchDisplay Then			
					intCurrentSearch = intCurrentSearch + 1
					ReDim Preserve aSearch(intCurrentSearch)
					aSearch(intCurrentSearch) = TXT_EMAIL & TXT_COLON & "<em>" & TXT_CANNOT_UPDATE_EMAIL & "</em>"
				End If
		End Select
	End If

'--------------------------------------------------
' 6. Custom Field Searches
'--------------------------------------------------

	Dim strCFldFind, _
		strCFldFindCon

	If Not Nl(strCFldDIDList1) Then
		strTmpCustSearch = getDateSearchString(aCFldDSelect1, strFirstDate1, strLastDate1, strDateRange1)
		If Not Nl(strTmpCustSearch) Then
			strWhere = strWhere & strCon & strTmpCustSearch
			strCon = AND_CON
			
			strCFldFind = vbNullString
			strCFldFindCon = vbNullString
			
			If strDateRange1 = "N" Then
				strCFldFind = "<em>" & TXT_IS_NULL & "</em>"
				strCFldFindCon = TXT_AND_LC
			ElseIf strDateRange1 = "NN" Then
				strCFldFind = "<em>" & TXT_NOT_NULL & "</em>"
				strCFldFindCon = TXT_AND_LC
			End If
			If Nl(strFirstDate1) Then
				strCFldFind = strCFldFind & strCFldFindCon & TXT_BEFORE_DATE & " <em>'" & strLastDateName1 & "'</em>"
				strCFldFindCon = TXT_AND_LC
			ElseIf Nl(strLastDate1) Then
				strCFldFind = strCFldFind & strCFldFindCon & TXT_ON_AFTER_DATE & " <em>'" & strFirstDateName1 & "'</em>"
				strCFldFindCon = TXT_AND_LC
			Else
				strCFldFind = strCFldFind & strCFldFindCon & TXT_BETWEEN & " <em>'" & strFirstDateName1 & "'</em>" & TXT_AND_LC & "<em>'" & strLastDateName1 & "'</em>"
				strCFldFindCon = TXT_AND_LC
			End If
			
			If bSearchDisplay Then			
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = "<em>" & Join(aCFldDDisplay1,"</em>" & IIf(bCFldAll1,TXT_AND_LC,TXT_OR_LC) & " <em>") & "</em> " & strCFldFind
			End If
		End If
	End If
	If Not Nl(strCFldDIDList2) Then
		strTmpCustSearch = getDateSearchString(aCFldDSelect2, strFirstDate2, strLastDate2, strDateRange2)
		If Not Nl(strTmpCustSearch) Then
			strWhere = strWhere & strCon & strTmpCustSearch
			strCon = AND_CON
			
			strCFldFind = vbNullString
			strCFldFindCon = vbNullString
			
			If strDateRange2 = "N" Then
				strCFldFind = "<em>" & TXT_IS_NULL & "</em>"
				strCFldFindCon = TXT_AND_LC
			ElseIf strDateRange2 = "NN" Then
				strCFldFind = "<em>" & TXT_NOT_NULL & "</em>"
				strCFldFindCon = TXT_AND_LC
			End If
			If Nl(strFirstDate2) Then
				strCFldFind = strCFldFind & strCFldFindCon & TXT_BEFORE_DATE & " <em>'" & strLastDateName2 & "'</em>"
				strCFldFindCon = TXT_AND_LC
			ElseIf Nl(strLastDate2) Then
				strCFldFind = strCFldFind & strCFldFindCon & TXT_ON_AFTER_DATE & " <em>'" & strFirstDateName2 & "'</em>"
				strCFldFindCon = TXT_AND_LC
			Else
				strCFldFind = strCFldFind & strCFldFindCon & TXT_BETWEEN & " <em>'" & strFirstDateName2 & "'</em>" & TXT_AND_LC & "<em>'" & strLastDateName2 & "'</em>"
				strCFldFindCon = TXT_AND_LC
			End If
			
			If bSearchDisplay Then			
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = "<em>" & Join(aCFldDDisplay2,"</em>" & IIf(bCFldAll1,TXT_AND_LC,TXT_OR_LC) & " <em>") & "</em> " & strCFldFind
			End If
		End If
	End If
	If Not Nl(strCFldIDList1) Then
		strTmpCustSearch = getCustSearchString(aCFldSelect1,strCFldType1,strCFldVal1,bCFldAll1)
		If Not Nl(strTmpCustSearch) Then
			strWhere = strWhere & strCon & strTmpCustSearch
			strCon = AND_CON
			
			Select Case strCFldType1
				Case "L"
					strCFldFind = "<em>'" & strCFldVal1 & "'</em>"
				Case "NL"
					strCFldFind = "<em>" & TXT_NOT_CONTAINS & " '" & strCFldVal1 & "'</em>"
				Case "N"
					strCFldFind = "<em>" & TXT_IS_NULL & "</em>"
				Case "NN"
					strCFldFind = "<em>" & TXT_NOT_NULL & "</em>"
			End Select
			
			If bSearchDisplay Then			
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_FIND & " " & strCFldFind & " " & TXT_IN & " <em>" & Join(aCFldDisplay1,"</em>" & IIf(bCFldAll1,TXT_AND_LC,TXT_OR_LC) & " <em>") & "</em>"
			End If
		End If
	End If
	If Not Nl(strCFldIDList2) Then
		strTmpCustSearch = getCustSearchString(aCFldSelect2,strCFldType2,strCFldVal2,bCFldAll2)
		If Not Nl(strTmpCustSearch) Then
			strWhere = strWhere & strCon & strTmpCustSearch
			strCon = AND_CON
			
			Select Case strCFldType2
				Case "L"
					strCFldFind = "<em>'" & strCFldVal2 & "'</em>"
				Case "NL"
					strCFldFind = "<em>" & TXT_NOT_CONTAINS & " '" & strCFldVal2 & "'</em>"
				Case "N"
					strCFldFind = "<em>" & TXT_IS_NULL & "</em>"
				Case "NN"
					strCFldFind = "<em>" & TXT_NOT_NULL & "</em>"
			End Select
			
			If bSearchDisplay Then			
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_FIND & " " & strCFldFind & " " & TXT_IN & " <em>" & Join(aCFldDisplay2,"</em>" & IIf(bCFldAll2,TXT_AND_LC,TXT_OR_LC) & " <em>") & "</em>"
			End If
		End If
	End If

'--------------------------------------------------
' 7. Add SQL
'--------------------------------------------------

	If Not Nl(strLimitSQL) Then
		strWhere = strWhere & strCon & "(" & strLimitSQL & ")"
		strCon = AND_CON
		
		If bSearchDisplay Then			
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_SQL & TXT_COLON & "<em>" & TXT_CUSTOM_SEARCH & "</em>"
		End If
	End If

'--------------------------------------------------
' 8. Refine Search
'--------------------------------------------------

	Dim indRecentSearch

	If bRecentSearchFound Then
		strWhere = strWhere & strCon & "(" & strLastSearchSessionSQL & ")"
		strCon = AND_CON

		If bSearchDisplay Then
			If IsArray(aLastSearchSessionInfo) Then
				For Each indRecentSearch in aLastSearchSessionInfo
					intCurrentSearch = intCurrentSearch + 1
					ReDim Preserve aSearch(intCurrentSearch)
					aSearch(intCurrentSearch) = indRecentSearch
				Next
			Else
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_YOUR_PREVIOUS_SEARCH & " [" & strLastSearchSessionTime & "]"
			End If
		End If
	End If

End Sub
%>
