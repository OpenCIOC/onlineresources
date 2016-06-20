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
' A. Equivalent Status
'--------------------------------------------------

Dim strEqStat
strEqStat = Request("EqStat")

'--------------------------------------------------
' B. Taxonomy Term List Search
'--------------------------------------------------

Dim	strTMC, _
	strATMC, _
	bTMCRestricted, _
	strTermListDisplayAll, _
	strTermListDisplayAny

'Is this a restricted search? (only search the exact Codes given, no Sub-Topics)
bTMCRestricted = Request("TMCR") = "on"

'Match all Terms list
strTMC = Request("TMC")
If Not Nl(strTMC) Then
	'Confirm that the list is a valid list of linked Codes
	'and fetch display information for the Taxonomy Term List Search menu
	'that appears at the top of the Search Results
	If Not IsLinkedTaxCodeList(strTMC) Then
		strTMC = Null
	Else

		strTermListDisplayAll = getTermListDisplay(strTMC,"TMC",StringIf(user_bLoggedIn,ps_strThisPage))
	End If
End If

'Match any Terms list
strATMC = Request("ATMC")
If Not Nl(strATMC) Then
	'Confirm that the list is a valid list of linked Codes
	'and fetch display information for the Taxonomy Term List Search menu
	'that appears at the top of the Search Results
	If Not IsLinkedTaxCodeList(strATMC) Then
		strATMC = Null
	Else
		strTermListDisplayAny = getTermListDisplay(strATMC,"ATMC",StringIf(user_bLoggedIn,ps_strThisPage))
	End If
End If

'--------------------------------------------------
' C. Specific NAICS Code
'--------------------------------------------------
Dim strNAICSCode
strNAICSCode = Request("NAICS")
If Not Nl(strNAICSCode) And Not IsNAICSType(strNAICSCode) Then
	Call handleError("Warning: " & strNAICSCode & " is not a valid NAICS Code and was ignored.", vbNullString, vbNullString)
	strNAICSCode = Null
End If

'--------------------------------------------------
' D. Postal Code Search
'--------------------------------------------------

Dim strPostalCode
strPostalCode = Trim(Request("PostalCode"))
strPostalCode = fixNastyCharacters(strPostalCode, False)
strPostalCode = fixQuotes(strPostalCode)

'--------------------------------------------------
' E. Street Address Search
'--------------------------------------------------

Dim strStreetName, _
	strStreetType, _
	strStreetDir

strStreetName = Trim(Request("StreetName"))
strStreetName = fixNastyCharacters(strStreetName, False)
strStreetName = fixQuotes(strStreetName)

strStreetType = Request("StreetType")
strStreetDir = Request("StreetDir")

'--------------------------------------------------
' F. Number of Employees Search
'--------------------------------------------------

Function checkNumEmpData(intNumEmp)
	If Not Nl(intNumEmp) Then
		If IsNumeric(intNumEmp) Then
			intNumEmp = CInt(intNumEmp)
			If intNumEmp <= 0 Then
				Call handleError(Replace(TXT_WARNING_EMPLOYEES_CRITERIA,"[CRITERIA]",Server.HTMLEncode(intNumEmp)), _
					vbNullString, vbNullString)
				intNumEmp = Null
			End If
		Else
			Call handleError(Replace(TXT_WARNING_EMPLOYEES_CRITERIA,"[CRITERIA]",Server.HTMLEncode(intNumEmp)), _
				vbNullString, vbNullString)
			intNumEmp = Null
		End If
	End If
	checkNumEmpData = intNumEmp
End Function

Dim intERID, _
	intNumEmpMin, _
	intNumEmpMax, _
	strNumEmpType, _
	strRecordEmployees

intERID = Request("ERID")
If Not Nl(intERID) Then
	If Not IsIDType(intERID) Then
		intERID = Null
	End If
	strNumEmpType = ""
Else
	intERID = Null
	intNumEmpMin = checkNumEmpData(Request("NumEmpMin"))
	intNumEmpMax = checkNumEmpData(Request("NumEmpMax"))
End If

If Not Nl(intNumEmpMin) Or Not Nl(intNumEmpMax) Then
	strNumEmpType = Request("NumEmpType")
End If

'--------------------------------------------------
' G. Accessibility Search
'--------------------------------------------------

Set dicCheckListSearch("AC") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("AC").setValues("AC","AC", TXT_CHK_ACCESSIBILITY, False, False, "bt", "NUM", "GBL_BT_AC", "GBL_Accessibility", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' I. Distribution Searches
'--------------------------------------------------

Set dicCheckListSearch("DST") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("DST").setValues("DST","DST", TXT_CHK_DISTRIBUTION, False, False, "bt", "NUM", "CIC_BT_DST", "CIC_Distribution", "DistCode", "ISNULL(frn.Name,fr.DistCode)", "DistCode", True, Null, Null, False)

'--------------------------------------------------
' J. Extra Checklist Search
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
	Call dicCheckListSearch("EXC" & indEXCType).setValues("EXC" & indEXCType, "EXC", "EXTRA_CHECKLIST_" & indEXCType, True, False, "bt", "NUM", "CIC_BT_EXC", "CIC_ExtraCheckList", "Code", "ISNULL(frn.Name,fr.Code)", Null, True, "FieldName_Cache='EXTRA_CHECKLIST_" & indEXCType & "'", "FieldName='EXTRA_CHECKLIST_" & indEXCType & "'", False)
Next

'--------------------------------------------------
' K. Extra Drop-Down Search
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
	Call dicCheckListSearch("EXD" & indEXDType).setValues("EXD" & indEXDType, "EXD", "EXTRA_DROPDOWN_" & indEXDType, True, False, "bt", "NUM", "CIC_BT_EXD", "CIC_ExtraDropDown", "Code", "ISNULL(frn.Name,fr.Code)", Null, True, "FieldName_Cache='EXTRA_DROPDOWN_" & indEXDType & "'", "FieldName='EXTRA_DROPDOWN_" & indEXDType & "'", False)
Next

'--------------------------------------------------
' L. Funding Search
'--------------------------------------------------

Set dicCheckListSearch("FD") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("FD").setValues("FD","FD", TXT_CHK_FUNDING, False, False, "bt", "NUM", "CIC_BT_FD", "CIC_Funding", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' M. Fee Type Search
'--------------------------------------------------

Set dicCheckListSearch("FT") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("FT").setValues("FT","FT", TXT_CHK_FEES, False, False, "bt", "NUM", "CIC_BT_FT", "CIC_FeeType", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' O. Membership Search
'--------------------------------------------------

Set dicCheckListSearch("MT") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("MT").setValues("MT","MT", "MEMBERSHIP", True, False, "bt", "NUM", "CIC_BT_MT", "CIC_MembershipType", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' P. Service Level Search
'--------------------------------------------------

Set dicCheckListSearch("SL") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("SL").setValues("SL","SL", TXT_CHK_SERVICELEVEL, False, False, "bt", "NUM", "CIC_BT_SL", "CIC_ServiceLevel", "ServiceLevelCode", "'(' + CAST(fr.ServiceLevelCode AS varchar) + ') ' + ISNULL(frn.Name,'')", "fr.ServiceLevelCode", True, Null, Null, False)

'--------------------------------------------------
' Q. Ward Search
'--------------------------------------------------

Set dicCheckListSearch("WD") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("WD").setValues("WD","WD", TXT_CHK_WARD, False, True, "bt", "cbt.WARD", "Code", "CIC_Ward", "WardNumber", Null, "fr.Municipality, fr.WardNumber, frn.Name", True, Null, Null, False)

'--------------------------------------------------
' R. Has VOL Opportunities (Specific)
'--------------------------------------------------

Dim strVolType
strVolType = Request("VolType")

'--------------------------------------------------
' S. Publication Search (Adv)
'--------------------------------------------------

'--------------------------------------------------
' T. General Heading Search (Adv)
'--------------------------------------------------

Call objHeadingParams1.setDataAdvanced()

'--------------------------------------------------
' U. Type of Program Search (Adv)
'--------------------------------------------------

'--------------------------------------------------
' V. Type of Care Search (Adv)
'--------------------------------------------------

'--------------------------------------------------
' W. Schools in Area Search (Adv)
'--------------------------------------------------

'--------------------------------------------------
' X. School Escort Search (Adv)
'--------------------------------------------------

'--------------------------------------------------
' Y. Record Quality
'--------------------------------------------------

Set dicCheckListSearch("RQ") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("RQ").setValues("RQ","RQ", TXT_CHK_RECORD_QUALITY, False, True, "bt", "cbt.QUALITY", Null, "CIC_Quality", "Quality", "'(' + fr.Quality + ') ' + ISNULL(frn.Name,'')", "fr.Quality", True, Null, Null, True)

'--------------------------------------------------
' Z. Record Type
'--------------------------------------------------

Set dicCheckListSearch("RT") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("RT").setValues("RT","RT", TXT_CHK_RECORD_TYPE, False, True, "bt", "cbt.RECORD_TYPE", Null, "CIC_RecordType", "RecordType", "'(' + fr.RecordType + ') ' + ISNULL(frn.Name,'')", "fr.RecordType", True, Null, Null, True)

'--------------------------------------------------
' AA. Fiscal Year End Search
'--------------------------------------------------

Set dicCheckListSearch("FYE") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("FYE").setValues("FYE","FYE", TXT_CHK_FISCAL_YEAR_END, False, True, "bt", "cbt.FISCAL_YEAR_END", "Code", "CIC_FiscalYearEnd", Null, Null, Null, False, Null, Null, False)

'--------------------------------------------------
' BB. Payment Terms
'--------------------------------------------------

Set dicCheckListSearch("PYT") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("PYT").setValues("PYT","PYT", TXT_CHK_PAYMENT_TERMS, False, True, "bt", "cbt.PAYMENT_TERMS", "Code", "GBL_PaymentTerms", Null, Null, Null, False, Null, Null, False)

'--------------------------------------------------
' CC. Preferred Currency
'--------------------------------------------------

Set dicCheckListSearch("CUR") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("CUR").setValues("CUR","CUR", TXT_CHK_CURRENCY, False, True, "bt", "cbt.PREF_CURRENCY", "Code", "GBL_Currency", Null, "fr.Currency + CASE WHEN frn.Name IS NOT NULL THEN ' (' + frn.Name + ')' ELSE '' END", "fr.Currency", True, Null, Null, False)

'--------------------------------------------------
' DD. Preferred Payment Method
'--------------------------------------------------

Set dicCheckListSearch("PAY") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("PAY").setValues("PAY","PAY", TXT_CHK_PAYMENT_METHOD, False, True, "bt", "cbt.PREF_PAYMENT_METHOD", "Code", "GBL_PaymentMethod", Null, Null, Null, False, Null, Null, False)


'--------------------------------------------------
' EE. Exact Areas Served
'--------------------------------------------------

Set dicCheckListSearch("ECM") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("ECM").setValues("ECM","CM", TXT_AREAS_SERVED_EXACT, False, False, "bt", "NUM", "CIC_BT_CM", "GBL_Community", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' FF. Exact Areas Served
'--------------------------------------------------

Set dicCheckListSearch("ELCM") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("ELCM").setValues("ELCM","CM", TXT_LOCATED_IN_EXACT, False, True, "bt", "bt.LOCATED_IN_CM", Null, "GBL_Community", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' GG. Mapping Systems
'--------------------------------------------------

Set dicCheckListSearch("MAP") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("MAP").setValues("MAP","MAP", "MAP_LINK", True, False, "bt", "NUM", "GBL_BT_MAP", "GBL_MappingSystem", Null, Null, Null, False, Null, Null, False)

'--------------------------------------------------
' HH. Accreditation
'--------------------------------------------------

Set dicCheckListSearch("ACR") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("ACR").setValues("ACR","ACR", "ACCREDITED", True, True, "bt", "cbt.ACCREDITED", Null, "CIC_Accreditation", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' II. Certification
'--------------------------------------------------

Set dicCheckListSearch("CRT") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("CRT").setValues("CRT","CRT", "CERTIFIED", True, True, "bt", "cbt.CERTIFIED", Null, "CIC_Certification", "Code", Null, Null, False, Null, Null, False)

'--------------------------------------------------
' JJ. Social Media Types
'--------------------------------------------------

Set dicCheckListSearch("SM") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("SM").setValues("SM","SM", "SOCIAL_MEDIA", True, False, "bt", "NUM", "GBL_BT_SM", "GBL_SocialMedia", Null, "ISNULL(frn.Name,fr.DefaultName)", Null, True, Null, Null, False)

'--------------------------------------------------
' KK. Organization-Location-Service
'--------------------------------------------------

Set dicCheckListSearch("OLS") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("OLS").setValues("OLS","OLS", "ORG_LOCATION_SERVICE", True, False, "bt", "NUM", "GBL_BT_OLS", "GBL_OrgLocationService", "Code", "ISNULL(frn.Name,fr.Code)", Null, True, Null, Null, False)

'--------------------------------------------------
' LL. Sharing Profile
'--------------------------------------------------

Set dicCheckListSearch("Share") = New CheckListSearch
'strTag, strIDTag, strLabel, bFetchLabel, bDropDown, strBTAlias, strBTKey, strBTRelTable, strDataTable, strCodeField, strCustDisplayName, strCustOrderBy, bInclCoreDataTable, strOtherCriteria, strDTOtherCriteria
Call dicCheckListSearch("Share").setValues("Share","Profile", "SHARED_WITH", True, False, "bt", "NUM", "GBL_BT_SHARINGPROFILE", "GBL_SharingProfile", Null, "frn.Name", Null, True, Null, Null, False)

'--------------------------------------------------

Sub setCICAdvSearchData()

'--------------------------------------------------
' A. Equivalent Status
'--------------------------------------------------

Select Case strEqStat
	Case "E"
		strWhere = strWhere & strCon & _
			"(EXISTS(SELECT * FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND btd2.LangID<>@@LANGID))"
		strCon = AND_CON
	
		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_FRENCH & TXT_COLON & "<em>" & TXT_HAS_EQUIVALENT & "</em>"
		End If
	Case "N"
		strWhere = strWhere & strCon & _
			"(NOT EXISTS(SELECT * FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND btd2.LangID<>@@LANGID))"
		strCon = AND_CON
	
		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_FRENCH & TXT_COLON & "<em>" & TXT_HAS_NO_EQUIVALENT & "</em>"
		End If
End Select

'--------------------------------------------------
' B. Taxonomy Term List Search
'--------------------------------------------------

Dim strTaxListSrch
strTaxListSrch = getTermListSQL("bt",strTMC,strATMC,bTMCRestricted)

If Not Nl(strTaxListSrch) Then
	strWhere = strWhere & strCon & "(" & strTaxListSrch & ")"
	strCon = AND_CON
End If

'--------------------------------------------------
' C. Specific NAICS Code
'--------------------------------------------------

If Not Nl(strNAICSCode) Then
	strWhere = strWhere & strCon & "(EXISTS(SELECT * FROM CIC_BT_NC pr WHERE pr.NUM=bt.NUM AND " & _
		"EXISTS(SELECT * FROM NAICS nc WHERE nc.Code ='" & strNAICSCode & "' AND " & _
			"pr.Code LIKE ISNULL(nc.SearchChildren,'" & strNAICSCode & "')+'%')" & _
		"))"
	strCon = AND_CON

	If bSearchDisplay Then
		strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
			"SET @searchData = NULL" & vbCrLf & _
			"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>','') + '(' + nc.Code + ') ' + ncd.Classification " & _
			"FROM NAICS nc INNER JOIN NAICS_Description ncd ON nc.Code=ncd.Code AND ncd.LangID=(SELECT TOP 1 LangID FROM NAICS_Description WHERE Code=nc.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END) " & _
			" WHERE nc.Code=" & strNAICSCode & vbCrLf & _
			"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & TXT_NAICS_SHORT & TXT_COLON & "<em>") & " + @searchData + '</em></search_display_item>'"
	End If
End If

'--------------------------------------------------
' D. Postal Code Search
'--------------------------------------------------

If Not Nl(strPostalCode) Then
	strWhere = strWhere & strCon & "(" & _
		"(bt.SITE_POSTAL_CODE LIKE '" & strPostalCode & "%') OR " & _
		"(bt.MAIL_POSTAL_CODE LIKE '" & strPostalCode & "%') OR " & _
		"(EXISTS(SELECT * FROM CIC_BT_OTHERADDRESS oa WHERE oa.NUM=bt.NUM AND oa.POSTAL_CODE LIKE '" & strPostalCode & "%'))" & _
		")"
	strCon = AND_CON

	If bSearchDisplay Then
		intCurrentSearch = intCurrentSearch + 1
		ReDim Preserve aSearch(intCurrentSearch)
		aSearch(intCurrentSearch) = TXT_POSTAL_CODE & TXT_COLON & TXT_BEGINS_WITH & " <em>'" & strPostalCode & "'</em>"
	End If
End If

'--------------------------------------------------
' E. Street Address Search
'--------------------------------------------------

If Not Nl(strStreetName) Then
	strWhere = strWhere & strCon & _
		"(btd.SITE_STREET LIKE '" & strStreetName & "')"
	strCon = AND_CON

	If bSearchDisplay Then
		intCurrentSearch = intCurrentSearch + 1
		ReDim Preserve aSearch(intCurrentSearch)
		aSearch(intCurrentSearch) = TXT_STREET_ADDRESS & TXT_COLON & " <em>'" & strStreetName
	End If

	If Not Nl(strStreetType) Then
		strWhere = strWhere & strCon & _
			"(btd.SITE_STREET_TYPE=" & QsN(strStreetType) & ")"
		strCon = AND_CON
	
		If bSearchDisplay Then
			aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & " " & strStreetType
		End If
	End If
	If Not Nl(strStreetDir) Then
		strWhere = strWhere & strCon & _
			"(btd.SITE_STREET_DIR=" & QsN(strStreetDir) & ")"
		strCon = AND_CON
	
		If bSearchDisplay Then
			aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & " " & strStreetDir
		End If
	End If

	If bSearchDisplay Then
		aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & "'</em>"
	End If
End If

'--------------------------------------------------
' F. Number of Employees Search
'--------------------------------------------------

Dim strEmpTypeName

Select Case strNumEmpType
	Case "F"
		strRecordEmployees = "(ISNULL(cbt.EMPLOYEES_FT,0))"
		strEmpTypeName = TXT_FULL_TIME
	Case "P"
		strRecordEmployees = "(ISNULL(cbt.EMPLOYEES_PT,0))"
		strEmpTypeName = TXT_PART_TIME_SEASONAL
	Case Else
		strRecordEmployees = "(ISNULL(cbt.EMPLOYEES_TOTAL,0))"
		strEmpTypeName = TXT_TOTAL_EMPLOYEES
End Select

If Not Nl(intNumEmpMin) Or Not Nl(intNumEmpMax) Then

	If bSearchDisplay Then
		intCurrentSearch = intCurrentSearch + 1
		ReDim Preserve aSearch(intCurrentSearch)
		aSearch(intCurrentSearch) = TXT_NUMBER_EMPLOYEES & TXT_COLON
	End If

	If Not Nl(intNumEmpMin) Then
		strWhere = strWhere & strCon & _
			"(" & strRecordEmployees & ">=" & intNumEmpMin & ")"
		strCon = AND_CON
	
		If bSearchDisplay Then
			aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & TXT_AT_LEAST & " <em>" & intNUMEmpMin & "</em>"
		End If
	End If

	If Not Nl(intNumEmpMax) Then
		strWhere = strWhere & strCon & _
			"(" & strRecordEmployees & "<=" & intNumEmpMax & ")"
		strCon = AND_CON
	
		If bSearchDisplay Then
			aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & StringIf(Not Nl(intNumEmpMin),TXT_AND_LC) & TXT_NO_MORE_THAN & " <em>" & intNUMEmpMax & "</em>"
		End If
	End If

	If bSearchDisplay Then
		aSearch(intCurrentSearch) = aSearch(intCurrentSearch) & " (" & strEmpTypeName & ")"
	End If
End If

If Not Nl(intERID) Then
	strWhere = strWhere & strCon & "(EMPLOYEES_RANGE=" & intERID & ")"
	strCon = AND_CON

	If bSearchDisplay Then
		strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
			"SET @searchText = @searchText + '" & vbCrLf & "<search_display_item>" & TXT_NUMBER_EMPLOYEES & TXT_COLON & _
				"<em>' + (SELECT CAST(MinNumber AS varchar) + ISNULL((SELECT '-' + CAST(MIN(MinNumber) - 1 AS varchar) FROM CIC_EmployeeRange WHERE MinNumber > er.MinNumber), '+') FROM CIC_EmployeeRange er WHERE ER_ID=" & intERID & ") + '</em></search_display_item>'"
	End If
End If

'--------------------------------------------------
' G. Accessibility Search
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
' I. Distribution Searches
'--------------------------------------------------

Select Case dicCheckListSearch("DST").SearchType
	Case "A"
		Call dicCheckListSearch("DST").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("DST").noValuesSearch()
	Case Else
		Call dicCheckListSearch("DST").includeValuesSearch()
End Select

Call dicCheckListSearch("DST").excludeValuesSearch()
Call dicCheckListSearch("DST").includeValuesSearchCode()

'--------------------------------------------------
' J. Extra Checklist Search
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
' K. Extra Drop-Down Search
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

'--------------------------------------------------
' L. Funding Search
'--------------------------------------------------

Select Case dicCheckListSearch("FD").SearchType
	Case "A"
		Call dicCheckListSearch("FD").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("FD").noValuesSearch()
	Case Else
		Call dicCheckListSearch("FD").includeValuesSearch()
End Select

Call dicCheckListSearch("FD").excludeValuesSearch()
Call dicCheckListSearch("FD").includeValuesSearchCode()

'--------------------------------------------------
' M. Fee Type Search
'--------------------------------------------------

Select Case dicCheckListSearch("FT").SearchType
	Case "A"
		Call dicCheckListSearch("FT").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("FT").noValuesSearch()
	Case Else
		Call dicCheckListSearch("FT").includeValuesSearch()
End Select

Call dicCheckListSearch("FT").excludeValuesSearch()
Call dicCheckListSearch("FT").includeValuesSearchCode()

'--------------------------------------------------
' O. Membership Search
'--------------------------------------------------

Select Case dicCheckListSearch("MT").SearchType
	Case "A"
		Call dicCheckListSearch("MT").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("MT").noValuesSearch()
	Case Else
		Call dicCheckListSearch("MT").includeValuesSearch()
End Select

Call dicCheckListSearch("MT").excludeValuesSearch()
Call dicCheckListSearch("MT").includeValuesSearchCode()

'--------------------------------------------------
' P. Service Level Search
'--------------------------------------------------

Select Case dicCheckListSearch("SL").SearchType
	Case "A"
		Call dicCheckListSearch("SL").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("SL").noValuesSearch()
	Case Else
		Call dicCheckListSearch("SL").includeValuesSearch()
End Select

Call dicCheckListSearch("SL").excludeValuesSearch()
Call dicCheckListSearch("SL").includeValuesSearchCode()

'--------------------------------------------------
' Q. Ward Search
'--------------------------------------------------

Select Case dicCheckListSearch("WD").SearchType
	Case "A"
		Call dicCheckListSearch("WD").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("WD").noValuesSearch()
	Case Else
		If Not Nl(dicCheckListSearch("WD").IDList) Then
			strWhere = strWhere & strCon & _
				"(cbt.WARD IN (" & dicCheckListSearch("WD").IDList & "))"
			strCon = AND_CON
		
			If bSearchDisplay Then
				strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
					"SET @searchData = NULL" & vbCrLf & _
					"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>','')" & _
						" + CASE WHEN wdn.Name IS NOT NULL THEN wdn.Name + ' (' ELSE '' END" & _
						" + CASE WHEN cmn.Name IS NOT NULL THEN cmn.Name + ' ' ELSE '' END + '" & dicCheckListSearch("WD").Label & " ' + CAST(wd.WardNumber AS varchar)" & _
						" + CASE WHEN wdn.Name IS NOT NULL THEN ')' ELSE '' END" & _
						" FROM CIC_Ward wd" & _
						"	LEFT JOIN CIC_Ward_Name wdn ON wd.WD_ID=wdn.WD_ID AND wdn.LangID=" & g_objCurrentLang.LangID & _
						"	LEFT JOIN GBL_Community cm ON wd.Municipality=cm.CM_ID" & _
						"	LEFT JOIN GBL_Community_Name cmn ON cm.CM_ID=cmn.CM_ID" & _
						"		AND cmn.LangID = (SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
						" WHERE wd.WD_ID IN (" & dicCheckListSearch("WD").IDList & ")" & _
						" ORDER BY wd.WardNumber" & vbCrLf & _
					"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & dicCheckListSearch("WD").Label & TXT_COLON & "<em>") & " + @searchData + '</em></search_display_item>'"
			End If
		End If
End Select

If Not Nl(dicCheckListSearch("WD").IDListx) Then
	strWhere = strWhere & strCon & _
		"(cbt.WARD IS NULL OR cbt.WARD NOT IN (" & dicCheckListSearch("WD").IDListx & "))"
	strCon = AND_CON

	If bSearchDisplay Then
		strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
			"SET @searchData = NULL" & vbCrLf & _
			"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>','')" & _
				" + CASE WHEN wdn.Name IS NOT NULL THEN wdn.Name + ' (' ELSE '' END" & _
				" + CASE WHEN cmn.Name IS NOT NULL THEN cmn.Name + ' ' ELSE '' END + '" & dicCheckListSearch("WD").Label & " ' + CAST(wd.WardNumber AS varchar)" & _
				" + CASE WHEN wdn.Name IS NOT NULL THEN ')' ELSE '' END" & _
				" FROM CIC_Ward wd" & _
				"	LEFT JOIN CIC_Ward_Name wdn ON wd.WD_ID=wdn.WD_ID AND wdn.LangID=" & g_objCurrentLang.LangID & _
				"	LEFT JOIN GBL_Community cm ON wd.Municipality=cm.CM_ID" & _
				"	LEFT JOIN GBL_Community_Name cmn ON cm.CM_ID=cmn.CM_ID" & _
				"		AND cmn.LangID = (SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
				" WHERE wd.WD_ID IN (" & dicCheckListSearch("WD").IDListx & ")" & _
				" ORDER BY wd.WardNumber" & vbCrLf & _
			"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & dicCheckListSearch("WD").Label & TXT_COLON & "<em>" & TXT_DOES_NOT_HAVE) & " + @searchData + '</em></search_display_item>'"
	End If
End If

'--------------------------------------------------
' R. Has VOL Opportunities (Specific)
'--------------------------------------------------

Select Case strVolType
	Case "A"
		strWhere = strWhere & strCon & "(EXISTS(SELECT * FROM VOL_Opportunity vo WHERE vo.NUM=bt.NUM))"
		strCon = AND_CON
	
		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_VOLUNTEER_OPPS & TXT_COLON & "<em>" & TXT_HAS_ANY_OPPS & "</em>"
		End If
	Case "V"
		strWhere = strWhere & strCon & "(EXISTS(SELECT * FROM VOL_Opportunity vo INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM WHERE vo.NUM=bt.NUM"
		If Not Nl(g_strWhereClauseVOL) Then
			strWhere = strWhere & " AND " & g_strWhereClauseVOL
		End If
		strWhere = strWhere & "))"
		strCon = AND_CON
	
		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_VOLUNTEER_OPPS & TXT_COLON & "<em>" & TXT_HAS_ANY_OPPS & " " & TXT_IN_THIS_VIEW & "</em>"
		End If
	Case "C"
		strWhere = strWhere & strCon & "(EXISTS(SELECT * FROM VOL_Opportunity vo INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM WHERE vo.NUM=bt.NUM" & _
			" AND (vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())" & _
			" AND " & g_strWhereClauseVOLNoDel & "))"
		strCon = AND_CON
	
		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_VOLUNTEER_OPPS & TXT_COLON & "<em>" & TXT_HAS_CURRENT_OPPS & " " & TXT_IN_THIS_VIEW & "</em>"
		End If
	Case "P"
		strWhere = strWhere & strCon & "(EXISTS(SELECT * FROM VOL_Opportunity vo INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM WHERE vo.NUM=bt.NUM" & _
			" AND (vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())" & _
			" AND " & g_strWhereClauseVOLNoDel

		If g_bCanSeeNonPublicVOL Then
			strWhere = strWhere & " AND (vod.NON_PUBLIC=0)"
		End If

		strWhere = strWhere & "))"
		strCon = AND_CON
	
		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_VOLUNTEER_OPPS & TXT_COLON & "<em>" & TXT_HAS_PUBLIC_OPPS & " " & TXT_IN_THIS_VIEW & "</em>"
		End If
	Case "N"
		strWhere = strWhere & strCon & "(NOT EXISTS(SELECT * FROM VOL_Opportunity vo WHERE vo.NUM=bt.NUM))"
		strCon = AND_CON

		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_VOLUNTEER_OPPS & TXT_COLON & "<em>" & TXT_HAS_NO_OPPS & "</em>"
		End If
	Case "E"
		strWhere = strWhere & strCon & "(EXISTS(SELECT * FROM VOL_Opportunity vo WHERE vo.NUM=bt.NUM))" & _
			" AND (NOT EXISTS(SELECT * FROM VOL_Opportunity vo INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM WHERE vo.NUM=bt.NUM" & _
				" AND (vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())" & _
				" AND (vod.DELETION_DATE IS NULL OR vod.DELETION_DATE >= GETDATE())" & _
			"))"
		strCon = AND_CON

		If bSearchDisplay Then
			intCurrentSearch = intCurrentSearch + 1
			ReDim Preserve aSearch(intCurrentSearch)
			aSearch(intCurrentSearch) = TXT_VOLUNTEER_OPPS & TXT_COLON & "<em>" & TXT_HAS_NO_CURRENT_OPPS & "</em>"
		End If
End Select

'--------------------------------------------------
' S. Publication Searches (Adv)
'--------------------------------------------------

If Nl(intGHPBID) Then
	Call dicCheckListSearch("PB").excludeValuesSearch()
End If

'--------------------------------------------------
' T. General Heading Searches (Adv)
'--------------------------------------------------

'--------------------------------------------------
' U. Type of Care (Adv)
'--------------------------------------------------

Call dicCheckListSearch("TOC").excludeValuesSearch()

'--------------------------------------------------
' V. Type of Program (Adv)
'--------------------------------------------------

Call dicCheckListSearch("TOP").excludeValuesSearch()

'--------------------------------------------------
' W. Schools in Area Search (Adv)
'--------------------------------------------------

If Not Nl(dicCheckListSearch("SCHA").IDListx) Then
	strWhere = strWhere & strCon & _
		"(NOT EXISTS(SELECT * FROM CCR_BT_SCH sch " & _
			"WHERE sch.InArea=" & SQL_TRUE & " AND sch.NUM=bt.NUM AND sch.SCH_ID IN (" & dicCheckListSearch("SCHA").IDListx & ")))"
	strCon = AND_CON

	If bSearchDisplay Then
		strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
			"SET @searchData = NULL" & vbCrLf & _
			"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>','')" & _
				" + schn.Name + CASE WHEN sch.SchoolBoard IS NULL THEN '' ELSE ' (' + sch.SchoolBoard + ')' END" & _
				" FROM CCR_School sch INNER JOIN CCR_School_Name schn ON sch.SCH_ID=schn.SCH_ID" & _
					" AND schn.LangID=(SELECT TOP 1 LangID FROM CCR_School_Name WHERE SCH_ID=schn.SCH_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
				" WHERE sch.SCH_ID IN (" & dicCheckListSearch("SCHA").IDListx & ") ORDER BY schn.Name, sch.SchoolBoard" & vbCrLf & _
			"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & dicCheckListSearch("SCHA").Label & TXT_COLON & "<em>" & TXT_DOES_NOT_HAVE) & " + @searchData + '</em></search_display_item>'"
	End If
End If

'--------------------------------------------------
' X. School Escort Search (Adv.)
'--------------------------------------------------

If Not Nl(dicCheckListSearch("SCHE").IDListx) Then
	strWhere = strWhere & strCon & _
		"(NOT EXISTS(SELECT * FROM CCR_BT_SCH sch " & _
			"WHERE sch.Escort=" & SQL_TRUE & " AND sch.NUM=bt.NUM AND sch.SCH_ID IN (" & dicCheckListSearch("SCHE").IDListx & ")))"
	strCon = AND_CON

	If bSearchDisplay Then
		strSearchInfoSQL = strSearchInfoSQL & vbCrLf & _
			"SET @searchData = NULL" & vbCrLf & _
			"SELECT @searchData = COALESCE(@searchData + '</em>" & TXT_OR_LC & "<em>','')" & _
				" + schn.Name + CASE WHEN sch.SchoolBoard IS NULL THEN '' ELSE ' (' + sch.SchoolBoard + ')' END" & _
				" FROM CCR_School sch INNER JOIN CCR_School_Name schn ON sch.SCH_ID=schn.SCH_ID" & _
					" AND schn.LangID=(SELECT TOP 1 LangID FROM CCR_School_Name WHERE SCH_ID=schn.SCH_ID ORDER BY CASE WHEN LangID=" & g_objCurrentLang.LangID & " THEN 0 ELSE 1 END, LangID)" & _
				" WHERE sch.SCH_ID IN (" & dicCheckListSearch("SCHE").IDListx & ") ORDER BY schn.Name, sch.SchoolBoard" & vbCrLf & _
			"IF @searchData IS NOT NULL SET @searchText = @searchText + " & QsNl(vbCrLf & "<search_display_item>" & dicCheckListSearch("SCHE").Label & TXT_COLON & "<em>" & TXT_DOES_NOT_HAVE) & " + @searchData + '</em></search_display_item>'"
	End If
End If

'--------------------------------------------------
' Y. Record Quality Search
'--------------------------------------------------

Select Case dicCheckListSearch("RQ").SearchType
	Case "A"
		Call dicCheckListSearch("RQ").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("RQ").noValuesSearch()
	Case Else
		Call dicCheckListSearch("RQ").includeValuesSearch()
End Select

Call dicCheckListSearch("RQ").excludeValuesSearch()

'--------------------------------------------------
' Z. Record Type Search
'--------------------------------------------------

Select Case dicCheckListSearch("RT").SearchType
	Case "A"
		Call dicCheckListSearch("RT").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("RT").noValuesSearch()
	Case Else
		Call dicCheckListSearch("RT").includeValuesSearch()
End Select

Call dicCheckListSearch("RT").excludeValuesSearch()

'--------------------------------------------------
' AA. Fiscal Year End Search
'--------------------------------------------------

Select Case dicCheckListSearch("FYE").SearchType
	Case "A"
		Call dicCheckListSearch("FYE").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("FYE").noValuesSearch()
	Case Else
		Call dicCheckListSearch("FYE").includeValuesSearch()
End Select

Call dicCheckListSearch("FYE").excludeValuesSearch()
Call dicCheckListSearch("FYE").includeValuesSearchCode()

'--------------------------------------------------
' BB. Payment Terms Search
'--------------------------------------------------

Select Case dicCheckListSearch("PYT").SearchType
	Case "A"
		Call dicCheckListSearch("PYT").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("PYT").noValuesSearch()
	Case Else
		Call dicCheckListSearch("PYT").includeValuesSearch()
End Select

Call dicCheckListSearch("PYT").excludeValuesSearch()
Call dicCheckListSearch("PYT").includeValuesSearchCode()

'--------------------------------------------------
' CC. Preferred Currency Search
'--------------------------------------------------

Select Case dicCheckListSearch("CUR").SearchType
	Case "A"
		Call dicCheckListSearch("CUR").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("CUR").noValuesSearch()
	Case Else
		Call dicCheckListSearch("CUR").includeValuesSearch()
End Select

Call dicCheckListSearch("CUR").excludeValuesSearch()
Call dicCheckListSearch("CUR").includeValuesSearchCode()

'--------------------------------------------------
' DD. Preferred Payment Method Search
'--------------------------------------------------

Select Case dicCheckListSearch("PAY").SearchType
	Case "A"
		Call dicCheckListSearch("PAY").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("PAY").noValuesSearch()
	Case Else
		Call dicCheckListSearch("PAY").includeValuesSearch()
End Select

Call dicCheckListSearch("PAY").excludeValuesSearch()
Call dicCheckListSearch("PAY").includeValuesSearchCode()

'--------------------------------------------------
' EE. Areas Served Exact Match Search
'--------------------------------------------------

Select Case dicCheckListSearch("ECM").SearchType
	Case "A"
		Call dicCheckListSearch("ECM").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("ECM").noValuesSearch()
	Case Else
		Call dicCheckListSearch("ECM").includeValuesSearch()
End Select

Call dicCheckListSearch("ECM").excludeValuesSearch()
Call dicCheckListSearch("ECM").includeValuesSearchCode()

'--------------------------------------------------
' FF. Located In Community Exact Match Search
'--------------------------------------------------

Select Case dicCheckListSearch("ELCM").SearchType
	Case "A"
		Call dicCheckListSearch("ELCM").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("ELCM").noValuesSearch()
	Case Else
		Call dicCheckListSearch("ELCM").includeValuesSearch()
End Select

Call dicCheckListSearch("ELCM").excludeValuesSearch()
Call dicCheckListSearch("ELCM").includeValuesSearchCode()

'--------------------------------------------------
' GG. Mapping System Search
'--------------------------------------------------

Select Case dicCheckListSearch("MAP").SearchType
	Case "A"
		Call dicCheckListSearch("MAP").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("MAP").noValuesSearch()
	Case Else
		Call dicCheckListSearch("MAP").includeValuesSearch()
End Select

Call dicCheckListSearch("MAP").excludeValuesSearch()

'--------------------------------------------------
' HH. Accreditation Search
'--------------------------------------------------

Select Case dicCheckListSearch("ACR").SearchType
	Case "A"
		Call dicCheckListSearch("ACR").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("ACR").noValuesSearch()
	Case Else
		Call dicCheckListSearch("ACR").includeValuesSearch()
End Select

Call dicCheckListSearch("ACR").excludeValuesSearch()
Call dicCheckListSearch("ACR").includeValuesSearchCode()

'--------------------------------------------------
' II. Certification Search
'--------------------------------------------------

Select Case dicCheckListSearch("CRT").SearchType
	Case "A"
		Call dicCheckListSearch("CRT").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("CRT").noValuesSearch()
	Case Else
		Call dicCheckListSearch("CRT").includeValuesSearch()
End Select

Call dicCheckListSearch("CRT").excludeValuesSearch()
Call dicCheckListSearch("CRT").includeValuesSearchCode()

'--------------------------------------------------
' JJ. Social Media Types Search
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
' KK. Organization-Location-Service Search
'--------------------------------------------------

Select Case dicCheckListSearch("OLS").SearchType
	Case "A"
		Call dicCheckListSearch("OLS").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("OLS").noValuesSearch()
	Case Else
		Call dicCheckListSearch("OLS").includeValuesSearch()
End Select

Call dicCheckListSearch("OLS").excludeValuesSearch()
Call dicCheckListSearch("OLS").includeValuesSearchCode()

'--------------------------------------------------
' LL. Sharing Profile Search
'--------------------------------------------------

Select Case dicCheckListSearch("Share").SearchType
	Case "A"
		Call dicCheckListSearch("Share").anyValuesSearch()
	Case "N"
		Call dicCheckListSearch("Share").noValuesSearch()
	Case Else
		Call dicCheckListSearch("Share").includeValuesSearch()
End Select

Call dicCheckListSearch("Share").excludeValuesSearch()

'--------------------------------------------------

End Sub
%>
