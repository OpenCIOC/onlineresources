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
' Purpose: 		Manages the maintenance of Taxonomy Search Settings, 
'				Search Modes and Search Types while working across multiple
'				Taxonomy pages and frames
'
'
%>

<%
'Search Mode Constants
Const MODE_BASIC = 0
Const MODE_ADVANCED = 1
Const MODE_FINDER = 2
Const MODE_INDEX = 3

'Search Type Constants
Const SEARCH_KEYWORD = 0
Const SEARCH_CODE = 1
Const SEARCH_DRILL_DOWN = 2
Const SEARCH_CONCEPT = 3
Const SEARCH_SUGGEST_LINK = 4
Const SEARCH_SUGGEST_TERM = 5
Const SEARCH_BY_RECORD = 6

Dim	dirTaxHTTPVals, _
	strTaxCacheHTTPVals, _
	strTaxCacheFormVals, _
	intTaxSearchMode, _
	intTaxSearchType, _
	bTaxAdmin, _
	bTaxInactive, _
	bTaxWithRecords

Set dirTaxHTTPVals = Server.CreateObject("Scripting.Dictionary")

'Current Search Mode
intTaxSearchMode = Request("MD")
If Not IsNumeric(intTaxSearchMode) Then
	intTaxSearchMode = MODE_BASIC
Else
	intTaxSearchMode = CInt(intTaxSearchMode)
End If
dirTaxHTTPVals.Add "MD", intTaxSearchMode

'Current Search Type
intTaxSearchType = Request("ST")
If Not IsNumeric(intTaxSearchType) Then
	intTaxSearchType = SEARCH_KEYWORD
Else
	intTaxSearchType = CInt(intTaxSearchType)
	Select Case intTaxSearchType
		Case SEARCH_SUGGEST_LINK
			If Not (intTaxSearchMode = MODE_INDEX Or intTaxSearchMode = MODE_ADVANCED) Then
				intTaxSearchType = SEARCH_KEYWORD
			End If
		Case SEARCH_SUGGEST_TERM
			If Not (intTaxSearchMode = MODE_INDEX Or intTaxSearchMode = MODE_ADVANCED) Then
				intTaxSearchType = SEARCH_KEYWORD
			End If
		Case SEARCH_BY_RECORD
			If Not intTaxSearchMode = MODE_INDEX Then
				intTaxSearchType = SEARCH_KEYWORD
			End If
	End Select
End If
dirTaxHTTPVals.Add "ST", intTaxSearchType

'Admin Mode?
If Request("AM") = "on" And intTaxSearchMode = MODE_BASIC And user_bSuperUserCIC Then
	bTaxAdmin = True
	dirTaxHTTPVals.Add "AM", "on"
Else
	bTaxAdmin = False
End If

'Show Inactive Terms?
If Request("IA") = "on" Then
	bTaxInactive = True
	dirTaxHTTPVals.Add "IA", "on"
ElseIf Not bTaxAdmin Then
	bTaxInactive = False
Else
	bTaxInactive = True
End If

'Show only Terms with Records?
If Request("WR") = "on" Then
	bTaxWithRecords = True
	dirTaxHTTPVals.Add "WR", "on"
Else
	bTaxWithRecords = False
End If

'***************************************
' Begin Function getTaxHTTPVals
'	Generates an HTTP query string or hidden form fields
'	to maintain request values across pages. 
'		strExcludeKeys - exclude the given keys from the list generated
'		bForm - True -> format for a FORM, False -> format a query string
'***************************************
Function getTaxHTTPVals(strExcludeKeys, bForm)
	Dim aTmp, _
		strKey, _
		strReturn

	aTmp = dirTaxHTTPVals.Keys
	strReturn = getHTTPVals(strExcludeKeys, bForm)
	
	For Each strKey in aTmp
		If Not reEquals(strExcludeKeys,"(^|,)" & strKey & "($|,)",True,True,False,False) Then
			If bForm Then
				strReturn = strReturn & "<input type=""hidden"" name=""" & _
					strKey & """ value=""" & dirTaxHTTPVals(strKey) & """>"
			Else
				strReturn = strReturn & IIf(Nl(strReturn),vbNullString,"&") & _
					strKey & "=" & Server.URLEncode(dirTaxHTTPVals(strKey))
			End If
		End If
	Next
	
	getTaxHTTPVals = strReturn
End Function
'***************************************
' End Function getTaxHTTPVals
'***************************************

'***************************************
' Begin Function makeTaxLink
'	Creates a link with an HTTP query string on the end
'	to maintain request values across pages. 
'		strToURL - base link to page we are linking to
'		strHTTPVals - additional items to add to the Query string
'			(other than those being passed page ot page)
'		strExcludeKeys - exclude the given keys from the list generated
'***************************************
Function makeTaxLink(strToURL, strHTTPVals, strExcludeKeys)
	Dim strReturn, _
		strPassVars

	If Not Nl(strExcludeKeys) Then
		strPassVars = getTaxHTTPVals(strExcludeKeys, False)
	Else
		strPassVars = strTaxCacheHTTPVals
	End If
	If Not Nl(strHTTPVals) Then
		strPassVars = IIf(Nl(strPassVars),vbNullString,strPassVars & "&") & strHTTPVals
	End If
	
	strReturn = strToURL & IIf(Nl(strPassVars),vbNullString,"?" & strPassVars)
	
	makeTaxLink = strReturn
End Function
'***************************************
' End Function makeTaxLink
'***************************************

'***************************************
' Begin Function makeTaxLinkB
'	Creates a link with an HTTP query string on the end
'	to maintain request values across pages.
'	Simplified function which does not allow you to change query string values.
'		strToURL - base link to page we are linking to
'***************************************
Function makeTaxLinkB(strToURL)
	makeTaxLinkB = makeTaxLink(strToURL,vbNullString,vbNullString)
End Function
'***************************************
' End Function makeTaxLinkB
'***************************************

'Cache the current values to make linking more efficient where possible.
strTaxCacheHTTPVals = getTaxHTTPVals(vbNullString, False)
strTaxCacheFormVals = getTaxHTTPVals(vbNullString, True)
%>
