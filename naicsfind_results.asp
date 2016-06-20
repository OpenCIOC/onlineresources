<%@LANGUAGE="VBSCRIPT"%>
<%Option Explicit%>

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

<% 'Base includes %>
<!--#include file="includes/core/adovbs.inc" -->
<!--#include file="includes/core/incVBUtils.asp" -->
<!--#include file="includes/validation/incBasicTypes.asp" -->
<!--#include file="includes/core/incRExpFuncs.asp" -->
<!--#include file="includes/core/incHandleError.asp" -->
<!--#include file="includes/core/incSetLanguage.asp" -->
<!--#include file="includes/core/incPassVars.asp" -->
<!--#include file="text/txtGeneral.asp" -->
<!--#include file="text/txtError.asp" -->
<!--#include file="includes/core/incConnection.asp" -->
<!--#include file="includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtFinder.asp" -->
<!--#include file="text/txtGeneralSearch1.asp" -->
<!--#include file="text/txtNAICS.asp" -->
<!--#include file="includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="includes/naics/incNAICSCodeType.asp" -->
<!--#include file="includes/naics/incNAICSSearchUtils.asp" -->
<!--#include file="includes/naics/incNAICSSearchResults.asp" -->
<!--#include file="includes/naics/incNAICSExclusionList.asp" -->
<!--#include file="includes/naics/incNAICSExampleList.asp" -->
<%
Call makePageHeader(TXT_NAICS_FINDER, TXT_NAICS_FINDER, False, False, True, False)

Dim strSearch, strSearchCon, strSearchType, strNAICSCode
strSearch = Trim(Request("STerms"))
strSearchCon = Trim(Request("SCon"))
strSearchType = Trim(Request("SType"))

strNAICSCode = Trim(Request("NAICS"))
If Not (Nl(strNAICSCode) Or IsNAICSType(strNAICSCode)) Then
	Call handleError(TXT_INVALID_CODE & strNAICSCode & ".", vbNullString, vbNullString)
	strNAICSCode = Null
End If
If Nl(strSearch) And Nl(strNAICSCode) Then
%>
<p><%=TXT_NOTHING_TO_SEARCH%></p>
<%
Else
	Dim strJoinedSTerms, _
		strJoinedQSTerms, _
		strExactSTerms, _
		singleSTerms(), _
		quotedSTerms(), _
		exactSTerms(), _
		displaySTerms()
	
	If Not Nl(strSearch) Then
		Call makeSearchString( _
			strSearch, _
			singleSTerms, _
			quotedSTerms, _
			exactSTerms, _
			displaySTerms, _
			False _
		)
		
		Select Case strSearchCon
			Case "O"
				strJoinedSTerms = Join(singleSTerms,OR_CON)
				strJoinedQSTerms = Join(quotedSTerms,OR_CON)
			Case Else
				strJoinedSTerms = Join(singleSTerms,AND_CON)
				strJoinedQSTerms = Join(quotedSTerms,AND_CON)
		End Select
		strExactSTerms = Join(exactSTerms," ")
	Else
		ReDim singleSTerms(-1)
		ReDim quotedSTerms(-1)
		ReDim exactSTerms(-1)
	End If
	Call makeNAICSBox(strSearchType,strJoinedSTerms,strJoinedQSterms,strExactSTerms,strNAICSCode,False,True,"naicsfind_results.asp")
End If

Call makePageFooter(False)
%>
<!--#include file="includes/core/incClose.asp" -->
