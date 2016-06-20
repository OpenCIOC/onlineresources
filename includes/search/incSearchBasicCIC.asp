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
Function checkAgeData(decAge)
	If Not Nl(decAge) Then
		If IsNumeric(decAge) Then
			decAge = CSng(decAge)
			If decAge < 0 Then
				Call handleError(TXT_WARNING & TXT_WARNING_AGE & "&quot;" & decAge & "&quot;" & TXT_IS_NEGATIVE, _
					vbNullString, vbNullString)
				decAge = Null
			End If
		Else
			Call handleError("&quot;" & decAge & "&quot;" & TXT_IS_NOT_A_NUMBER, _
				vbNullString, vbNullString)
			decAge = Null
		End If
	End If
	checkAgeData = decAge
End Function

Function checkDate(dDate)
	If Not Nl(dDate) Then
		If Not IsSmallDate(dDate) Then
			Call handleError(TXT_WARNING & TXT_WARNING_AGE & "&quot;" & dDate & "&quot;" & TXT_INVALID_DATE_FORMAT & DateString(MIN_SMALL_DATE,True) & TXT_AND_LC & DateString(MAX_SMALL_DATE,True), _
				vbNullString, vbNullString)
			dDate = Null
		Else
			dDate = DateString(dDate,False)
		End If
	End If
	checkDate = dDate
End Function


'--------------------------------------------------
' 1. Child Care Resource Status
'--------------------------------------------------

Dim strCCRStat
strCCRStat = Request("CCRStat")

'--------------------------------------------------
' 2. Communities Search
'--------------------------------------------------

Dim	strCMType, _
	strCMID, _
	strOtherCommunity, _
	intOtherCommunityID

strCMType = Request("CMType")
If Nl(strCMType) Or Not IsNumeric(strCMType) Then
	strCMID = Request("CMID")
	If Not IsIDList(strCMID) Then
		strCMID = vbNullString
	End If

	strOtherCommunity = Left(Trim(Request("OComm")),200)
	intOtherCommunityID = Trim(Request("OCommID"))
	If IsNumeric(intOtherCommunityID) Then
		intOtherCommunityID = CInt(intOtherCommunityID)
	Else
		intOtherCommunityID = vbNullString
	End If
End If

If Not Nl(strOtherCommunity) Then
	If Nl(intOtherCommunityID) Then
		Dim cmdCommID, rsCommID
		Set cmdCommID = Server.CreateObject("ADODB.Command")
		With cmdCommID
			.ActiveConnection = getCurrentCICBasicCnn()
			.CommandText = "dbo.sp_GBL_Community_s_ID"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@Community", adVarChar, adParamInput, 200, strOtherCommunity)
			.Parameters.Append .CreateParameter("@CM_ID", adInteger, adParamOutput, 4)
		End With
		Set rsCommID = cmdCommID.Execute
		Set rsCommID = rsCommID.NextRecordset
		If Nl(cmdCommID.Parameters("@CM_ID").Value) Then
			strSearchErrors = strSearchErrors & strErrorCon & TXT_WARNING & TXT_WARNING_COMMUNITY_1 & Server.HTMLEncode(Ns(strOtherCommunity)) & TXT_WARNING_COMMUNITY_2
			strErrorCon = "<br>"
			strOtherCommunity = Null
		Else
			strCMID = strCMID & IIf(Nl(strCMID),vbNullString,",") & cmdCommID.Parameters("@CM_ID").Value
		End If
		Set rsCommID = Nothing
		Set cmdCommID = Nothing
	Else
		strCMID = strCMID & IIf(Nl(strCMID),vbNullString,",") & intOtherCommunityID
	End If
End If

If Nl(strCMID) Then
	strQueryString = reReplace(strQueryString,"(&)?CMType=.",vbNullString,False,False,False,False)
End If

'--------------------------------------------------
' 3. Has Website
'--------------------------------------------------

Dim bURL
bURL = Request("HasURL") = "on"

'--------------------------------------------------
' 4. Has VOL Opportunities
'--------------------------------------------------

Dim bVol
bVol = Request("HasVol") = "on"

'--------------------------------------------------
' 5. Publication Searches
'--------------------------------------------------

Dim	intGHPBID

intGHPBID = Trim(Request("GHPBID"))
If Nl(intGHPBID) Then
	intGHPBID = Trim(Request("PubsWithGeneralHeadings"))
End If
If g_bLimitedView Then
	intGHPBID = Nz(intGHPBID,g_intPBID)
End If

If Not IsIDType(intGHPBID) Then
	intGHPBID = Null
End If

If Nl(intGHPBID) Then
	Set dicCheckListSearch("PB") = New CheckListSearch
	'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
	Call dicCheckListSearch("PB").setValues("PB","PB", IIf(user_bLoggedIn,TXT_PUBLICATIONS,TXT_CATEGORIES), False, False, "bt", "NUM", "CIC_BT_PB", "CIC_Publication", "PubCode", "ISNULL(frn.Name,fr.PubCode)", "fr.PubCode", True, Null, Null, False)
End If

'--------------------------------------------------
' 6. General Heading Searches
'--------------------------------------------------

Class HeadingSearch

Public Suffix
Public GHType
Public GHID
Public GHIDx
Public GHIDGRP
Public GHName
Public GHPBID
		
Public Sub setDataBasic(strSuffix,intGHPBID)
	Suffix = Nz(strSuffix,vbNullString)
	GHType = Request("GHType" & strSuffix)

	GHID = Request("GHID" & Suffix)
	If Nl(GHID) Then
		GHID = Request("incGHID")
	End If
	If Not Nl(GHID) Then
		GHID = Replace(GHID," ",vbNullString)
		GHID = reReplace(GHID,"(^,)|(,$)",vbNullString,False,False,True,False)
	End If
	If Not IsIDList(GHID) Then
		GHID = Null
	End If
	strQueryString = reReplace(strQueryString,"(&)?GHID" & Suffix & "=([^&$])*",vbNullString,True,False,True,False)
	If Not Nl(strQueryString) Then
		strQueryString = strQueryString & "&GHID" & Suffix & "=" & GHID
	Else
		strQueryString = "GHID" & Suffix & "=" & GHID
	End If

	GHIDGRP = Request("GHID_GRP" & Suffix)
	If Not IsIDList(GHIDGRP) Then
		GHIDGRP = Null
	End If
	If Not Nl(GHIDGRP) Then
		GHIDGRP = Replace(GHIDGRP," ",vbNullString)
		GHIDGRP = reReplace(GHIDGRP,"(^,)|(,$)",vbNullString,False,False,True,False)
		strQueryString = reReplace(strQueryString,"(&)?GHID_GRP" & Suffix & "=([^&$])*",vbNullString,True,False,True,False)
		If Not Nl(strQueryString) Then
			strQueryString = strQueryString & "&GHID_GRP" & Suffix & "=" & GHIDGRP
		Else
			strQueryString = "GHID_GRP" & Suffix & "=" & GHIDGRP
		End If
	End If

	If Nl(GHID) Then
		If GHType = "F" Then
			strQueryString = reReplace(strQueryString,"(&)?GHType" & Suffix & "=F",vbNullString,False,False,False,False)
		End If
		If GHType = "NM" Or (Nl(GHType) And Nl(GHIDGRP)) Then
			GHType = "NM"
			GHName = Trim(Request("GH" & Suffix))
		End If
	End If

	If Nl(intGHPBID) Then
		intGHPBID = Request("GHPBID" & Suffix)
	End If
	If Not IsIDType(intGHPBID) Then
		intGHPBID = Null
	End If
	GHPBID = intGHPBID
End Sub

Public Sub setDataAdvanced()
	GHIDx = Request("GHIDx" & Suffix)
	If Not Nl(GHIDx) Then
		GHIDx = Replace(GHIDx," ",vbNullString)
		GHIDx = reReplace(GHIDx,"(^,)|(,$)",vbNullString,False,False,True,False)
	End If
	If Not IsIDList(GHIDx) Then
		GHIDx = Null
	End If
	
	strQueryString = reReplace(strQueryString,"(&)?GHIDx" & Suffix & "=([^&$])*",vbNullString,True,False,True,False)
	If Not Nl(strQueryString) Then
		strQueryString = strQueryString & "&GHIDx" & Suffix & "=" & GHIDx
	Else
		strQueryString = "GHIDx" & Suffix & "=" & GHIDx
	End If
End Sub

Public Sub SearchHeadings()
	Select Case GHType
		Case "A"
			If Not Nl(GHPBID) Then
				strWhere = strWhere & strCon & _
					"(EXISTS(SELECT * FROM CIC_BT_PB_GH gh " & _
						"INNER JOIN CIC_BT_PB pb ON gh.BT_PB_ID = pb.BT_PB_ID " & _
						"WHERE pb.NUM=bt.NUM and pb.PB_ID=" & GHPBID & "))"
				strCon = AND_CON
			
				If bSearchDisplay Then
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"SELECT @searchData = ISNULL(pbn.Name,pb.PubCode)" & _
						" FROM CIC_Publication pb LEFT JOIN CIC_Publication_Name pbn ON pb.PB_ID=pbn.PB_ID" & _
							" AND LangID=" & g_objCurrentLang.LangID & _
						" WHERE pb.PB_ID=" & GHPBID & _
						"IF @searchData IS NOT NULL SET @searchText = @searchText + '" & vbCrLf & "<search_display_item>' + @searchData + ' " & IIf(user_bLoggedIn,TXT_HEADINGS,TXT_CATEGORIES) & TXT_COLON & "<em>" & TXT_HAS_ANY & "</em></strong>'"
				End If
			End If
		Case "N"
			If Not Nl(GHPBID) Then
				strWhere = strWhere & strCon & _
					"(EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM AND pb.PB_ID=" & GHPBID & _
					" AND NOT EXISTS(SELECT * FROM CIC_BT_PB_GH gh WHERE gh.BT_PB_ID=pb.BT_PB_ID)))"
				strCon = AND_CON
			
				If bSearchDisplay Then
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"SELECT @searchData = ISNULL(pbn.Name,pb.PubCode)" & _
						" FROM CIC_Publication pb LEFT JOIN CIC_Publication_Name pbn ON pb.PB_ID=pbn.PB_ID" & _
							" AND LangID=" & g_objCurrentLang.LangID & _
						" WHERE pb.PB_ID=" & GHPBID & _
						"IF @searchData IS NOT NULL SET @searchText = @searchText + '" & vbCrLf & "<search_display_item>' + @searchData + ' " & IIf(user_bLoggedIn,TXT_HEADINGS,TXT_CATEGORIES) & TXT_COLON & "<em>" & TXT_HAS_NONE & "</em></strong>'"
				End If
			End If
		Case "NM"
			If Not Nl(GHName) Then
				strWhere = strWhere & strCon & _
					"(EXISTS(SELECT * FROM CIC_BT_PB_GH pgh" & vbCrLf & _
					"INNER JOIN CIC_GeneralHeading gh ON pgh.GH_ID=gh.GH_ID" & StringIf(Not Nl(GHPBID)," AND gh.PB_ID=" & GHPBID) & vbCrLf & _
					"INNER JOIN CIC_GeneralHeading_Name ghn ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=@@LANGID AND ghn.Name=" & QsNl(GHName) & vbCrLf & _
					"WHERE pgh.NUM_Cache=bt.NUM))"

				If bSearchDisplay Then
					intCurrentSearch = intCurrentSearch + 1
					ReDim Preserve aSearch(intCurrentSearch)
					aSearch(intCurrentSearch) = IIf(user_bLoggedIn,TXT_HEADINGS,TXT_CATEGORIES) & TXT_COLON & "<em>" & GHName & "</em>"
				End If
				strCon = AND_CON
			End If
		Case Else
			If Not Nl(GHID) Or Not Nl(GHIDGRP) Then
				Select Case GHType
					Case "AF"
						Dim aGHID, aGHIDGRP, strGHSrch
						If Not Nl(GHID) Then
							aGHID = Split(GHID,",")
						End If
						If Not Nl(GHIDGRP) Then
							aGHIDGRP = Split(GHIDGRP,",")
						End If
						If IsArray(aGHID) Then
							If UBound(aGHID) >= 0 Then
								strGHSrch = "EXISTS(SELECT * FROM CIC_BT_PB_GH gh " & _
									"WHERE gh.NUM_Cache=bt.NUM AND gh.GH_ID="
								strWhere = strWhere & strCon & "(" & strGHSrch & _
									Join(aGHID,") AND " & strGHSrch) & "))"
								strCon = AND_CON
							End If
						End If
						If IsArray(aGHIDGRP) Then
							If UBound(aGHIDGRP) >= 0 Then
								strGHSrch = "EXISTS(SELECT * FROM CIC_BT_PB_GH pgh " & _
									"INNER JOIN CIC_GeneralHeading gh ON pgh.GH_ID=gh.GH_ID " & _
									"WHERE pgh.NUM_Cache=bt.NUM AND gh.HeadingGroup="
								strWhere = strWhere & strCon & "(" & strGHSrch & _
									Join(aGHIDGRP,") AND " & strGHSrch) & "))"
								strCon = AND_CON
							End If
						End If
					Case Else
						If Not Nl(GHID) Then
							strWhere = strWhere & strCon & _
								"(EXISTS(SELECT * FROM CIC_BT_PB_GH gh " & _
									"WHERE gh.NUM_Cache=bt.NUM AND gh.GH_ID IN (" & GHID & ")))"
							strCon = AND_CON
						End If
						If Not Nl(GHIDGRP) Then
							strWhere = strWhere & strCon & _ 
								"(EXISTS(SELECT * FROM CIC_BT_PB_GH pgh " & _
								"INNER JOIN CIC_GeneralHeading gh ON pgh.GH_ID=gh.GH_ID " & _
								"WHERE pgh.NUM_Cache=bt.NUM AND gh.HeadingGroup IN (" & GHIDGRP & ")))"
							strCon = AND_CON
						End If
				End Select
				
				strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
					"SET @searchData = NULL" & vbCrLf & _
					"DECLARE @tmpHeadings" & Suffix & " TABLE (HeadingName nvarchar(200))"

				If Not Nl(GHID) Then
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"INSERT INTO @tmpHeadings" & Suffix & " (HeadingName)" & vbCrLf & _
						"SELECT ISNULL(CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE CASE WHEN ghn.LangID=@@LANGID THEN ghn.Name ELSE '[' + ghn.Name + ']' END END,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']') AS HeadingName" & _
						" FROM CIC_GeneralHeading gh LEFT JOIN CIC_GeneralHeading_Name ghn ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=ghn.GH_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
						" WHERE gh.GH_ID IN (" & GHID & ")"
				End If

				If Not Nl(GHIDGRP) Then
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"INSERT INTO @tmpHeadings" & Suffix & " (HeadingName)" & vbCrLf & _
						"SELECT ghn.Name AS HeadingName FROM CIC_GeneralHeading_Group_Name ghn" & _
						" WHERE ghn.GroupID IN (" & GHIDGRP & ")" & _
						" AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Group_Name WHERE GroupID=ghn.GroupID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)"
				End If
					
				strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
					"SELECT @searchData = COALESCE(@searchData + '</em>" & IIf(GHType="AF",TXT_AND_LC,TXT_OR_LC) & "<em>','')" & _
						" + HeadingName FROM @tmpHeadings" & Suffix & " tm ORDER BY tm.HeadingName" & vbCrLf & _
					"IF @searchData IS NOT NULL SET @searchText = @searchText + '" & vbCrLf & "<search_display_item>" & IIf(user_bLoggedIn,TXT_HEADINGS,TXT_CATEGORIES) & TXT_COLON & "<em>' + @searchData + '</em></search_display_item>'"

			End If

			If Not Nl(GHIDx) Then
				strWhere = strWhere & strCon & _
					"(NOT EXISTS(SELECT * FROM CIC_BT_PB_GH gh WHERE gh.NUM_Cache=bt.NUM AND gh.GH_ID IN (" & GHIDx & ")))"
				strCon = AND_CON

				If bSearchDisplay Then
					strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
						"SET @searchData = NULL" & vbCrLf & _
						"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>','') + ISNULL(CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE CASE WHEN ghn.LangID=@@LANGID THEN ghn.Name ELSE '[' + ghn.Name + ']' END END,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']') FROM CIC_GeneralHeading gh LEFT JOIN CIC_GeneralHeading_Name ghn ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=ghn.GH_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID) WHERE gh.GH_ID IN (" & GHIDx & ")" & vbCrLf & _
						"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & IIf(user_bLoggedIn,TXT_HEADINGS,TXT_CATEGORIES) & TXT_COLON & "<em>" & TXT_DOES_NOT_HAVE) & " + @searchData + '</em></search_display_item>'"
				End If
			End If

	End Select
End Sub

End Class

Dim objHeadingParams1, _
	objHeadingParams2

Set objHeadingParams1 = New HeadingSearch
Call objHeadingParams1.setDataBasic(vbNullString, intGHPBID)

Set objHeadingParams2 = New HeadingSearch
Call objHeadingParams2.setDataBasic("_2", vbNullString)

'--------------------------------------------------
' 7. Specific Subject Term
'--------------------------------------------------

Dim strSubjID
strSubjID = Request("SubjID")
If Not IsIDList(strSubjID) Then
	strSubjID = Null
End If

'--------------------------------------------------
' 8. Org Level Linking Search
'--------------------------------------------------
Dim strOrg1, _
	strOrg2, _
	strOrg3, _
	strOrg4, _
	strOrg5, _
	strLocation1, _
	strService1, _
	strService2

strOrg1 = Request("OL1")
strOrg2 = Request("OL2")
strOrg3 = Request("OL3")
strOrg4 = Request("OL4")
strOrg5 = Request("OL5")
strLocation1 = Request("LL1")
strService1 = Request("SL1")
strService2 = Request("SL2")


'--------------------------------------------------
' 9. Age Search
'--------------------------------------------------

Dim	intAgeGroup, _
	strAgeGroupName, _
	decAge1, _
	decAge2, _
	strAgeType, _
	intAgeTypeSpecific, _
	aAges(3), _
	dCareDate, _
	iAge

intAgeGroup = Request("AgeGroup")
If Not Nl(intAgeGroup) And IsIDType(intAgeGroup) Then
	Dim cmdAgeGroup, rsAgeGroup
	Set cmdAgeGroup = Server.CreateObject("ADODB.Command")
	With cmdAgeGroup
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_GBL_AgeGroup_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@AgeGroup_ID", adInteger, adParamInput, 4, intAgeGroup)
	End With
	Set rsAgeGroup = Server.CreateObject("ADODB.Recordset")
	With rsAgeGroup
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdAgeGroup
		If Not .EOF Then
			strAgeGroupName = .Fields("AgeGroupName")
			decAge1 = .Fields("MinAge")
			decAge2 = .Fields("MaxAge")
		End If
		.Close
	End With
	Set rsAgeGroup = Nothing
	Set cmdAgeGroup = Nothing
	decAge1 = Nz(decAge1,0)
	decAge2 = Nz(decAge2,MAX_INT)
	strAgeType = vbNullString
Else
	strAgeType = Request("AgeType")
	intAgeTypeSpecific = Request("AgeTypeSpecific")
	decAge1 = checkAgeData(Request("Age1"))
	decAge2 = checkAgeData(Request("Age2"))
	dCareDate = Nz(checkDate(Trim(Request("CareDate"))),Date())

	Dim bGotDOB
	bGotDOB = False

	If Not Nl(intAgeTypeSpecific) Then
		If IsNumeric(intAgeTypeSpecific) Then
			intAgeTypeSpecific = 0 + intAgeTypeSpecific
			If intAgeTypeSpecific < 0 Or intAgeTypeSpecific > 3 Then
				intAgeTypeSpecific = Null
			End If
		Else
			intAgeTypeSpecific = Null
		End If
	End If

	If strAgeType = "S" And Nl(intAgeTypeSpecific) Then
		strAgeType = Null
	End If

	For iAge = 0 to 3
		Dim strDOB
		strDob = Trim(Request("DOB" & iAge))
		If Not Nl(strDOB) Then
			strDOB = checkDate(strDOB)
			If Not Nl(strDOB) Then
				bGotDOB = True
				aAges(iAge) = Round(DateDiff("d",strDob,dCareDate)/365,1)
				If strAgeType = "A" Then
					If aAges(iAge) > decAge2 Or Nl(decAge2) Then
						decAge2 = aAges(iAge)
					End If
					If aAges(iAge) < decAge1 Or Nl(decAge1) Then
						decAge1 = aAges(iAge)
					End If
				End If
			End If
		End If
	Next

	If strAgeType = "S" And Not Nl(intAgeTypeSpecific) Then
		If Not Nl(aAges(intAgeTypeSpecific)) Then
			decAge1 = aAges(intAgeTypeSpecific)
		End If
	End If

	If Nl(decAge1) And Not Nl(decAge2) Then
		decAge1 = decAge2
	ElseIf Nl(decAge2) And Not Nl(decAge1) Then
		decAge2 = decAge1
	End If
End If

'--------------------------------------------------
' 10. Bus Route Search
'--------------------------------------------------

Set dicCheckListSearch("BR") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("BR").setValues("BR","BR", TXT_ON_BUS_ROUTE, False, False, "bt", "NUM", "CIC_BT_BR", "CIC_BusRoute", Null, _
	"CASE WHEN fr.RouteNumber IS NULL THEN '' ELSE '(' + fr.RouteNumber + ')' END + CASE WHEN frn.Name IS NULL OR fr.RouteNumber IS NULL THEN '' ELSE ' ' + frn.Name END", "fr.RouteNumber", True, Null, Null, False)

'--------------------------------------------------
' 11. Located Near
'--------------------------------------------------

Dim	strNearAddress, _
	bNearSort, _
	bNearUnmapped

strNearAddress = Request("GeoLocatedNearAddress")
bNearSort = Request("GeoLocatedNearSort") = "on"
bNearUnmapped = Request("GeoLocatedNearUnmapped") = "on"

decNearLatitude = Trim(Request("GeoLocatedNearLatitude"))
decNearLongitude = Trim(Request("GeoLocatedNearLongitude"))

If g_objCurrentLang.Culture = CULTURE_FRENCH_CANADIAN Then
	decNearLatitude = Replace(decNearLatitude,".",",")
	decNearLongitude = Replace(decNearLongitude,".",",")
End If

If Nl(decNearLatitude) Or Nl(decNearLongitude) Then
	decNearLatitude = vbNullString
	decNearLongitude = vbNullString
ElseIf Not IsNumeric(decNearLatitude) Or Not IsNumeric(decNearLongitude) Then
	decNearLatitude = vbNullString
	decNearLongitude = vbNullString
Else
	decNearLatitude = CDbl(decNearLatitude)
	decNearLongitude = CDbl(decNearLongitude)
	If Not (decNearLatitude >= -180 And decNearLatitude <= 180 And decNearLongitude >= -180 and decNearLongitude <= 180) Then
		decNearLatitude = vbNullString
		decNearLongitude = vbNullString
	End If
	If Not Nl(decNearLatitude) And Nl(strNearAddress) Then
		strNearAddress = decNearLatitude & ", " & decNearLongitude
	End If
End If

If IsNumeric(strCMType) Then
decNearDistance = strCMType
Else
decNearDistance = Trim(Request("GeoLocatedNearDistance"))
End If
If Nl(decNearDistance) Then
	decNearDistance = vbNullString
ElseIf Not IsNumeric(decNearDistance) Then
	decNearDistance = vbNullString
Else
	decNearDistance = CDbl(decNearDistance)
	decNearDistance = Round(decNearDistance,2)
	If decNearDistance > 20000 Then
		decNearDistance = 20000
	ElseIf decNearDistance < 0.01 Then
		decNearDistance = 0.01
	End If
End If

'--------------------------------------------------
' 12. Vacancy
'--------------------------------------------------

Dim intVacancyTP, _
	strVacancy

intVacancyTP = Request("VacancyTP")

If Not IsIDType(intVacancyTP) Then
	intVacancyTP = Null
End If

strVacancy = Request("Vacancy")
If Not (strVacancy = "Y" Or strVacancy = "W") Then
	strVacancy = vbNullString
End If

'--------------------------------------------------
' 13. OCG Number
'--------------------------------------------------

Dim strOCG

strOCG = Trim(Request("OCG"))

'--------------------------------------------------
' 13. Organization NUM
'--------------------------------------------------

Dim strOrgNUM

strOrgNUM = Request("ORGNUM")
If Not IsNUMType(strOrgNUM) Then
	strOrgNUM = Null
End If

'--------------------------------------------------
' 14. Service NUM (Locations for Service)
'--------------------------------------------------

Dim strServiceNUM

strServiceNUM = Request("SERVICENUM")
If Not IsNUMType(strServiceNUM) Then
	strServiceNUM = Null
End If

'--------------------------------------------------
' N. Language Search
'--------------------------------------------------

Set dicCheckListSearch("LN") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("LN").setValues("LN","LN", TXT_CHK_LANGUAGE, False, False, "bt", "NUM", "CIC_BT_LN", "GBL_Language", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------

Sub setCICBasicSearchData()

'--------------------------------------------------
' 1. Child Care Resource Status
'--------------------------------------------------

	Select Case strCCRStat
		Case "R"
			strWhere = strWhere & strCon & "(ccbt.NUM IS NOT NULL)"
			strCon = AND_CON
		
			If bSearchDisplay Then
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_CHILD_CARE_RESOURCE
			End If
		Case "N"
			strWhere = strWhere & strCon & "(ccbt.NUM IS NULL)"
			strCon = AND_CON
		
			If bSearchDisplay Then
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_EXCLUDE_CHILD_CARE_RESOURCES
			End If
	End Select

'--------------------------------------------------
' 2. Communities Search
'--------------------------------------------------

	If Not Nl(strCMID) Then
		Dim cnnComm, cmdComm, rsComm, strCommList
		Call makeNewAdminConnection(cnnComm)
		Set cmdComm = Server.CreateObject("ADODB.Command")
		With cmdComm
			.ActiveConnection = cnnComm
			.CommandText = "SELECT dbo.fn_GBL_Community_s_Search('" & strCMID & "') AS SearchList"
			.CommandType = adCmdText
			.CommandTimeout = 0
		End With
		Set rsComm = cmdComm.Execute
		With rsComm
			If Not .EOF Then
				strCommList = .Fields("SearchList")
				If Nl(strCommList) Then
					' Not a valid CMID set search list to -1
					strCommList = "-1"
				End If
				If strCMType = "L" Then
					strWhere = strWhere & strCon & _
					"(bt.LOCATED_IN_CM IS NULL OR bt.LOCATED_IN_CM IN (" & strCommList & "))"
				Else
					strWhere = strWhere & strCon & _
					"(EXISTS(SELECT cm.BT_CM_ID FROM CIC_BT_CM cm WHERE cm.NUM=bt.NUM AND cm.CM_ID IN (" & strCommList & ")))"
				End If
				strCon = AND_CON
			End If
			.Close
		End With
		Set rsComm = Nothing
		Set cmdComm = Nothing
		Set cnnComm = Nothing
	
		If bSearchDisplay Then
			strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
				"SET @searchData = NULL" & vbCrLf & _
				"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>','')" & _
				" + cmn.Name" & _
				" FROM GBL_Community_Name cmn" & _
				" WHERE cmn.CM_ID IN (" & strCMID & ") " & _
					" AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
				"IF @searchData IS NOT NULL SET @searchText = @searchText + '" & vbCrLf & "<search_display_item>" & IIf(strCMType="L",TXT_LOCATED_IN_COMM,TXT_SERVING_COMM) & TXT_COLON & "<em>' + @searchData + '</em></search_display_item>'"
		End If
	End If

'--------------------------------------------------
' 3. Has Website
'--------------------------------------------------

	If bURL Then
		strWhere = strWhere & strCon & "(btd.WWW_ADDRESS IS NOT NULL)"
		strCon = AND_CON
	
		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = Nz(get_view_data_cic("OrganizationsWithWWW"), TXT_WITH_WEBSITE)
		End If
	End If

'--------------------------------------------------
' 4. Has VOL Opportunities
'--------------------------------------------------

	If bVol Then
		strWhere = strWhere & strCon & "(EXISTS(SELECT * FROM VOL_Opportunity vo INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM WHERE vo.NUM=bt.NUM" & _
			StringIf (Not g_bCanSeeExpired," AND (vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())") & _
			" AND " & g_strWhereClauseVOLNoDel & "))"
		strCon = AND_CON

		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = Nz(get_view_data_cic("OrganizationsWithVolOps"), TXT_WITH_VOL)
		End If
	End If

'--------------------------------------------------
' 5. Publication Searches
'--------------------------------------------------

	If Nl(intGHPBID) Then
		Select Case dicCheckListSearch("PB").SearchType
			Case "A"
				Call dicCheckListSearch("PB").anyValuesSearch()
			Case "N"
				Call dicCheckListSearch("PB").noValuesSearch()
			Case Else
				Call dicCheckListSearch("PB").includeValuesSearch()
		End Select
		Call dicCheckListSearch("PB").includeValuesSearchCode()
	End If

'--------------------------------------------------
' 6. General Heading Searches
'--------------------------------------------------

Call objHeadingParams1.SearchHeadings()
Call objHeadingParams2.SearchHeadings()

'--------------------------------------------------
' 7. Specific Subject Term
'--------------------------------------------------

	If Not Nl(strSubjID) Then
		Dim aSubjID, strSubjSrch
		aSubjID = Split(strSubjID,",")
		If IsArray(aSubjID) Then
			If UBound(aSubjID) >= 0 Then
				strSubjSrch = "EXISTS(SELECT * FROM CIC_BT_SBJ sj WHERE sj.NUM=bt.NUM AND sj.Subj_ID="
				strWhere = strWhere & strCon & "(" & strSubjSrch & _
					Join(aSubjID,") AND " & strSubjSrch) & "))"
				strCon = AND_CON
			
				strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
					"SET @searchData = NULL" & vbCrLf & _
					"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_AND_LC & "<em>','') + sjn.Name" & vbCrLf & _
					"	FROM THS_Subject sj INNER JOIN THS_Subject_Name sjn ON sj.Subj_ID=sjn.Subj_ID" & vbCrLf & _
					"		AND sjn.LangID=(SELECT TOP 1 LangID FROM THS_Subject_Name WHERE Subj_ID=sjn.Subj_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
					"WHERE sj.Subj_ID IN (" & strSubjID & ")" & vbCrLf & _
					"ORDER BY sjn.Name" & vbCrLf & _
					"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & TXT_SUBJECTS & TXT_COLON & "<em>") & " + @searchData + '</em></search_display_item>'"
			End If
		End If
	End If

'--------------------------------------------------
' 8. Name Level Linking Search
'--------------------------------------------------

	Dim strOrgName, _
		strOrgNameCon
	
	strOrgNameCon = vbNullString

	If Not Nl(strOrg1) Then
		strWhere = strWhere & strCon & "(btd.ORG_LEVEL_1=" & QsN(strOrg1) & ")"
		strCon = AND_CON
		strOrgName = strOrg1
		strOrgNameCon = ", "
	End If
	If Not Nl(strOrg2) Then
		strWhere = strWhere & strCon & "(btd.ORG_LEVEL_2=" & QsN(strOrg2) & ")"
		strCon = AND_CON
		strOrgName = strOrgName & strOrgNameCon & strOrg2
		strOrgNameCon = ", "
	End If
	If Not Nl(strOrg3) Then
		strWhere = strWhere & strCon & "(btd.ORG_LEVEL_3=" & QsN(strOrg3) & ")"
		strCon = AND_CON
		strOrgName = strOrgName & strOrgNameCon & strOrg3
		strOrgNameCon = ", "
	End If
	If Not Nl(strOrg4) Then
		strWhere = strWhere & strCon & "(btd.ORG_LEVEL_4=" & QsN(strOrg4) & ")"
		strCon = AND_CON
		strOrgName = strOrgName & strOrgNameCon & strOrg4
		strOrgNameCon = ", "
	End If
	If Not Nl(strOrg5) Then
		strWhere = strWhere & strCon & "(btd.ORG_LEVEL_5=" & QsN(strOrg5) & ")"
		strCon = AND_CON
		strOrgName = strOrgName & strOrgNameCon & strOrg5
		strOrgNameCon = ", "
	End If
	If Not Nl(strLocation1) Then
		strWhere = strWhere & strCon & "(" & _
			"btd.LOCATION_NAME=" & QsN(strLocation1) & _
			" OR EXISTS(SELECT * FROM GBL_BT_LOCATION_SERVICE ls INNER JOIN GBL_BaseTable_Description lbtd ON ls.LOCATION_NUM=lbtd.NUM AND lbtd.LangID=@@LANGID AND lbtd.LOCATION_NAME=" & QsN(strLocation1) & " WHERE SERVICE_NUM=bt.NUM)" & _
			")"
		strCon = AND_CON
		strOrgNameCon = ", "
	End If
	If Not Nl(strService1) Then
		strWhere = strWhere & strCon & "(" & QsN(strService1) & " IN (btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2))"
		strCon = AND_CON
		strOrgName = strOrgName & strOrgNameCon & strService1
		strOrgNameCon = ", "
	End If
	If Not Nl(strService2) Then
		strWhere = strWhere & strCon & "(" & QsN(strService2) & " IN (btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2))"
		strCon = AND_CON
		strOrgName = strOrgName & strOrgNameCon & strService2
		strOrgNameCon = ", "
	End If

	If Not Nl(strOrgName) And bSearchDisplay Then
		intCurrentSearch = intCurrentSearch + 1
		ReDim Preserve aSearch(intCurrentSearch)
		aSearch(intCurrentSearch) = Nz(get_view_data_cic("OrgProgramNames"), TXT_ORG_NAMES) & TXT_COLON & " <em>" & strOrgName & "</em>"
	End If

	If Not Nl(strLocation1) And bSearchDisplay Then
		intCurrentSearch = intCurrentSearch + 1
		ReDim Preserve aSearch(intCurrentSearch)
		aSearch(intCurrentSearch) = TXT_LOCATION_NAME & TXT_COLON & " <em>" & strLocation1 & "</em>"
	End If

'--------------------------------------------------
' 9. Age Search
'--------------------------------------------------
	Dim strAgeCrit, _
		strAgeCritCon, _
		strAgeList, _
		strAgeListCon

	strAgeCrit = vbNullString
	strAgeCritCon = vbNullString
	strAgeList = vbNullString
	strAgeListCon = vbNullString

	If Not Nl(decAge1) Then
		If strAgeType="A" Then
			'Match All In Range
			strAgeCrit = "(" & _
				"(cbt.MIN_AGE IS NULL OR " & ConvertFloatSQL(decAge1) & ">=cbt.MIN_AGE)" & _
					" AND " & _
				"(cbt.MAX_AGE IS NULL OR (" & _
					"(FLOOR(cbt.MAX_AGE)=cbt.MAX_AGE AND " & ConvertFloatSQL(decAge2) & "<FLOOR(cbt.MAX_AGE)+1)" & _
					" OR (" & ConvertFloatSQL(decAge2) & "<=cbt.MAX_AGE)" & _
				"))" & _
			")"
		
			If bSearchDisplay Then		
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				If decAge1 = decAge2 Then
					aSearch(intCurrentSearch) = TXT_AGES & TXT_COLON & " <em>" & decAge1 & " " & TXT_YEARS & "</em>"
				Else
					aSearch(intCurrentSearch) = TXT_AGES & TXT_COLON & " <em>" & decAge1 & TXT_TO & decAge2 & " " & TXT_YEARS & "</em>"
				End If
			End If
		Else
			'Match Any In Range
			strAgeCrit = "(" & _
				"(cbt.MIN_AGE IS NULL OR " & ConvertFloatSQL(decAge2) & ">=cbt.MIN_AGE)" & _
					" AND " & _
				"(cbt.MAX_AGE IS NULL OR (" & _
					"(FLOOR(cbt.MAX_AGE)=cbt.MAX_AGE AND " & ConvertFloatSQL(decAge1) & "<FLOOR(cbt.MAX_AGE)+1)" & _
					" OR (" & ConvertFloatSQL(decAge1) & "<=cbt.MAX_AGE)" & _
				"))" & _
			")"

			If bSearchDisplay Then		
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				If Not Nl(strAgeGroupName) Then
					aSearch(intCurrentSearch) = TXT_AGES & TXT_COLON & " <em>" & strAgeGroupName & "</em>"
				ElseIf decAge1 = decAge2 Then
					aSearch(intCurrentSearch) = TXT_AGES & TXT_COLON & " <em>" & decAge1 & " " & TXT_YEARS & "</em>"
				Else
					aSearch(intCurrentSearch) = TXT_AGES & TXT_COLON & " <em>" & TXT_BETWEEN & " " & decAge1 & TXT_AND_LC & decAge2 & " " & TXT_YEARS & "</em>"
				End If
			End If
		End If
	ElseIf IsArray(aAges) Then
		'Match Any Age
		For Each iAge in aAges
			If Not Nl(iAge) Then
				strAgeCrit = strAgeCrit & strAgeCritCon & "(" & _
					"(cbt.MIN_AGE IS NULL OR " & ConvertFloatSQL(iAge) & ">=cbt.MIN_AGE)" & _
						" AND " & _
					"(cbt.MAX_AGE IS NULL OR (" & _
						"(FLOOR(cbt.MAX_AGE)=cbt.MAX_AGE AND " & ConvertFloatSQL(iAge) & "<FLOOR(cbt.MAX_AGE)+1)" & _
						" OR (" & ConvertFloatSQL(iAge) & "<=cbt.MAX_AGE)" & _
					"))" & _
				")"
				strAgeCritCon = OR_CON

				If bSearchDisplay Then			
					strAgeList = strAgeList & strAgeListCon & "<em>" & iAge & " " & TXT_YEARS & "</em>"
				End If
				strAgeListCon = TXT_OR_LC
			End If
		Next
	
		If bSearchDisplay And Not Nl(strAgeList) Then		
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_AGES & TXT_COLON & strAgeList
		End If
	End If

	If Not Nl(strAgeCrit) Then
		strWhere = strWhere & strCon & "(" & strAgeCrit & ")"
		strCon = AND_CON
	End If

'--------------------------------------------------
' 10. Bus Route Search
'--------------------------------------------------

	Select Case dicCheckListSearch("BR").SearchType
		Case "A"
			Call dicCheckListSearch("BR").anyValuesSearch()
		Case "N"
			Call dicCheckListSearch("BR").noValuesSearch()
		Case Else
			Call dicCheckListSearch("BR").includeValuesSearch()
	End Select

	Call dicCheckListSearch("BR").excludeValuesSearch()

End Sub

'--------------------------------------------------
' 11. Located Near
'--------------------------------------------------

Function LatitudePlusDistance(decLatitude, decDistance)
	LatitudePlusDistance = decLatitude + Sqr((decDistance * decDistance) / 2962.0142838318594408653463771574)
End Function

Function LongitudePlusDistance(decLongitude, decLatitude, decDistance)
	LongitudePlusDistance = decLongitude + Sqr((decDistance * decDistance) / (2972.8846779582612542750338025929 * COS((2 * decLatitude) / 114.591559026165) * COS((2 * decLatitude) / 114.591559026165)))
End Function

If Not Nl(decNearLatitude) And Not Nl(decNearLongitude) Then
	Dim decMaxLatitude, decMaxLongitude, decMinLatitude, decMinLongitude
	If Not Nl(decNearDistance) Then
		decMaxLatitude = LatitudePlusDistance(decNearLatitude, decNearDistance)
		decMaxLongitude = LongitudePlusDistance(decNearLongitude, decNearLatitude, decNearDistance)
		decMinLatitude = 2 * decNearLatitude - decMaxLatitude
		decMinLongitude = 2 * decNearLongitude - decMaxLongitude
	End If

	strParamSQL = "DECLARE @NearLatitude [decimal](11,7)," & vbCrLf & _
				"@NearLongitude [decimal](11,7)," & vbCrLf & _
				"@MinLatitude [decimal](11,7)," & vbCrLf & _
				"@MinLongitude [decimal](11,7)," & vbCrLf & _
				"@MaxLatitude [decimal](11,7)," & vbCrLf & _
				"@MaxLongitude [decimal](11,7)" & vbCrLf & _
				"SET @NearLatitude = ?" & vbCrLf & _
				"SET @NearLongitude = ?" & vbCrLf & _
				"SET @MinLatitude = ?" & vbCrLf & _
				"SET @MinLongitude = ?" & vbCrLf & _
				"SET @MaxLatitude = ?" & vbCrLf & _
				"SET @MaxLongitude = ?" & vbCrLf

	With cmdOrgList
		.Parameters.Append .CreateParameter("@NearLatitude", adDecimal, adParamInput)
		.Parameters("@NearLatitude").Precision = 11
		.Parameters("@NearLatitude").NumericScale = 7
		.Parameters("@NearLatitude") = Null
		.Parameters("@NearLatitude").Value = decNearLatitude
		.Parameters.Append .CreateParameter("@NearLongitude", adDecimal, adParamInput)
		.Parameters("@NearLongitude").Precision = 11
		.Parameters("@NearLongitude").NumericScale = 7
		.Parameters("@NearLongitude") = Null
		.Parameters("@NearLongitude").Value = decNearLongitude
		.Parameters.Append .CreateParameter("@MinLatitude", adDecimal, adParamInput)
		.Parameters("@MinLatitude").Precision = 11
		.Parameters("@MinLatitude").NumericScale = 7
		.Parameters("@MinLatitude") = Null
		.Parameters("@MinLatitude").Value = Nz(decMinLatitude,0)
		.Parameters.Append .CreateParameter("@MinLongitude", adDecimal, adParamInput)
		.Parameters("@MinLongitude").Precision = 11
		.Parameters("@MinLongitude").NumericScale = 7
		.Parameters("@MinLongitude") = Null
		.Parameters("@MinLongitude").Value = Nz(decMinLongitude,0)
		.Parameters.Append .CreateParameter("@MaxLatitude", adDecimal, adParamInput)
		.Parameters("@MaxLatitude").Precision = 11
		.Parameters("@MaxLatitude").NumericScale = 7
		.Parameters("@MaxLatitude") = Null
		.Parameters("@MaxLatitude").Value = Nz(decMaxLatitude,0)
		.Parameters.Append .CreateParameter("@MaxLongitude", adDecimal, adParamInput)
		.Parameters("@MaxLongitude").Precision = 11
		.Parameters("@MaxLongitude").NumericScale = 7
		.Parameters("@MaxLongitude") = Null
		.Parameters("@MaxLongitude").Value = Nz(decMaxLongitude,0)
	End With

	If Not Nl(decNearDistance) Then
		strWhere = strWhere & strCon
		strCon = AND_CON
	
		If bNearUnmapped Then
			strWhere = strWhere & "(bt.GEOCODE_TYPE = 0 OR "
		End If
	
		strWhere = strWhere & _
			"(bt.LONGITUDE BETWEEN @MinLongitude AND @MaxLongitude" & _
			" AND bt.LATITUDE BETWEEN @MinLatitude AND @MaxLatitude" & _
			" AND cioc_shared.dbo.fn_SHR_GEO_CalculateDistance(bt.LONGITUDE, bt.LATITUDE, @NearLongitude, @NearLatitude) <= " & decNearDistance & ")"

		If bNearUnmapped Then
			strWhere = strWhere & ")"
		End If
	
		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_WITHIN & " " & decNearDistance & " km " & TXT_OF & "<em>" & strNearAddress & "</em>" & StringIf(bNearUnmapped," (" & TXT_INCLUDE_UNMAPPED_RECORDS & ")")
		End If
	End If
End If


'--------------------------------------------------
' 12. Vacancy
'--------------------------------------------------

If Nl(strVacancy) And Not Nl(intVacancyTP) Then
	strWhere = strWhere & strCon & _
		"(EXISTS(SELECT * FROM CIC_BT_VUT vut INNER JOIN CIC_BT_VUT_TP vtp ON vut.BT_VUT_ID=vtp.BT_VUT_ID WHERE vut.NUM=bt.NUM AND vtp.VTP_ID=" & intVacancyTP & ")" & vbCrLf & _
		"OR EXISTS(SELECT * FROM CIC_BT_VUT vut WHERE vut.NUM=bt.NUM AND NOT EXISTS(SELECT * FROM CIC_BT_VUT_TP vtp WHERE vtp.BT_VUT_ID=vut.BT_VUT_ID)))"
	strCon = AND_CON
ElseIf Not Nl(strVacancy) Then
	If Nl(intVacancyTP) Then
		Select Case strVacancy
			Case "Y"
				strWhere = strWhere & strCon & _
					"(EXISTS(SELECT * FROM CIC_BT_VUT vut WHERE vut.NUM=bt.NUM AND vut.Vacancy > 0))"
				strCon = AND_CON
			Case "W"
				strWhere = strWhere & strCon & _
					"(EXISTS(SELECT * FROM CIC_BT_VUT vut WHERE vut.NUM=bt.NUM AND (vut.Vacancy > 0 OR vut.WaitList=1)))"
				strCon = AND_CON
		End Select
	Else
		Select Case strVacancy
			Case "Y"
				strWhere = strWhere & strCon & _
					"(EXISTS(SELECT * FROM CIC_BT_VUT vut INNER JOIN CIC_BT_VUT_TP vtp ON vut.BT_VUT_ID=vtp.BT_VUT_ID WHERE vut.NUM=bt.NUM AND vut.Vacancy > 0 AND vtp.VTP_ID=" & intVacancyTP & ")" & vbCrLf & _
					"OR EXISTS(SELECT * FROM CIC_BT_VUT vut WHERE vut.NUM=bt.NUM AND vut.Vacancy > 0 AND NOT EXISTS(SELECT * FROM CIC_BT_VUT_TP vtp WHERE vtp.BT_VUT_ID=vut.BT_VUT_ID)))"
				strCon = AND_CON	
			Case "W"
				strWhere = strWhere & strCon & _
					"(EXISTS(SELECT * FROM CIC_BT_VUT vut INNER JOIN CIC_BT_VUT_TP vtp ON vut.BT_VUT_ID=vtp.BT_VUT_ID WHERE vut.NUM=bt.NUM AND (vut.Vacancy > 0 OR vut.WaitList=1) AND vtp.VTP_ID=" & intVacancyTP & ")" & vbCrLf & _
					"OR EXISTS(SELECT * FROM CIC_BT_VUT vut WHERE vut.NUM=bt.NUM AND (vut.Vacancy > 0 OR vut.WaitList=1) AND NOT EXISTS(SELECT * FROM CIC_BT_VUT_TP vtp WHERE vtp.BT_VUT_ID=vut.BT_VUT_ID)))"
				strCon = AND_CON	
		End Select
	End If
End If

If Not Nl(intVacancyTP) Then
	If bSearchDisplay Then
		strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
			"SET @searchData = NULL" & vbCrLf & _
			"SELECT @searchData = vtpn.Name" & _
			" FROM CIC_Vacancy_TargetPop_Name vtpn" & _
			" WHERE vtpn.VTP_ID IN (" & intVacancyTP & ")" & _
			" AND vtpn.LangID=(SELECT TOP 1 LangID FROM CIC_Vacancy_TargetPop_Name WHERE VTP_ID=vtpn.VTP_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
			"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & TXT_HAS_CAPACITY_FOR & "<em>") & " + @searchData + '</em></search_display_item>'"
	End If
End If

If Not Nl(strVacancy) Then
	If bSearchDisplay Then
		Select Case strVacancy
			Case "Y"
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_VACANCY & TXT_COLON & "<em>" & TXT_HAS_VACANCIES & "</em>"
			Case "W"
				intCurrentSearch = intCurrentSearch + 1
				ReDim Preserve aSearch(intCurrentSearch)
				aSearch(intCurrentSearch) = TXT_VACANCY & TXT_COLON & "<em>" & TXT_HAS_VACANCIES_OR_WAITLIST & "</em>"
		End Select
	End If
End If

'--------------------------------------------------
' 13. OCG Number
'--------------------------------------------------

If Not Nl(strOCG) Then
	strWhere = strWhere & strCon & "(cbt.OCG_NO=" & QsNl(strOCG) & ")"
	strCon = AND_CON
	
	If bSearchDisplay Then
		intCurrentSearch = intCurrentSearch + 1
		ReDim Preserve aSearch(intCurrentSearch)
		aSearch(intCurrentSearch) = TXT_OCG & strOCG
	End If
End If

'--------------------------------------------------
' 13. Organization NUM
'--------------------------------------------------

If Not Nl(strOrgNUM) Then
	strWhere = strWhere & strCon & "(" & QsNl(strOrgNUM) & " IN (bt.NUM, bt.ORG_NUM))"
	strCon = AND_CON
	
	If bSearchDisplay Then
		strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
			"SET @searchData = NULL" & vbCrLf & _
			"SET @searchData = dbo.fn_GBL_DisplayFullOrgName(" & QsNl(strOrgNUM) & ",@@LANGID)" & vbCrLf & _
			"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & Nz(get_view_data_cic("Organization"), TXT_ORGANIZATION) & TXT_COLON & "<em>") & " + @searchData + '</em></search_display_item>'"
	End If
End If

'--------------------------------------------------
' 14. Service NUM
'--------------------------------------------------

If Not Nl(strServiceNUM) Then
	strWhere = strWhere & strCon & "(" & _
		"(bt.NUM=" & QsNl(strServiceNUM) & AND_CON & _
		" EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code='SITE' WHERE pr.NUM=bt.NUM))" & _
		" OR EXISTS(SELECT * FROM GBL_BT_LOCATION_SERVICE ls WHERE SERVICE_NUM=" & QsNl(strServiceNUM) & " AND LOCATION_NUM=bt.NUM)" & _
		")"
	strCon = AND_CON
	
	If bSearchDisplay Then
		strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
			"SET @searchData = NULL" & vbCrLf & _
			"SET @searchData = dbo.fn_GBL_DisplayServiceName(" & QsNl(strServiceNUM) & ",@@LANGID,1)" & vbCrLf & _
			"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & TXT_LOCATIONS_FOR_SERVICE & TXT_COLON & "<em>") & " + @searchData + '</em></search_display_item>'"
	End If

End If

'--------------------------------------------------
' N. Language Search
'--------------------------------------------------

Select Case dicCheckListSearch("LN").SearchType
	Case "A"
		Call dicCheckListSearch("LN").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("LN").noValuesSearch()
	Case Else
		Call dicCheckListSearch("LN").includeValuesSearch()
End Select

Call dicCheckListSearch("LN").excludeValuesSearch()
Call dicCheckListSearch("LN").includeValuesSearchCode()

%>
