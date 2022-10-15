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
<!--#include file="text/txtClientTracker.asp" -->
<!--#include file="text/txtFormDataCheck.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtGeneralSearch1.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtRecordPages.asp" -->
<!--#include file="text/txtSearchBasic.asp" -->
<!--#include file="text/txtSearchResults.asp" -->
<!--#include file="text/txtSearchResultsTax.asp" -->
<!--#include file="text/txtSearchTaxPublic.asp" -->
<!--#include file="includes/core/incFieldDataClass.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/core/incOrderByConst.asp" -->
<!--#include file="includes/display/incCICDisplayOptionsFields.asp" -->
<!--#include file="includes/list/incMappingCategoryList.asp" -->
<!--#include file="includes/mapping/incGoogleMaps.asp" -->
<!--#include file="includes/mapping/incMapSearchResults.asp" -->
<!--#include file="includes/search/incMakeTableClassCIC.asp" -->
<!--#include file="includes/search/incMyList.asp" -->
<!--#include file="includes/search/incSearchRecent.asp" -->
<!--#include file="includes/taxonomy/incTaxTermSearches.asp" -->
<%
'On Error Resume Next
%>
<!--#include file="includes/search/incSearchSetupCIC.asp" -->
<!--#include file="includes/search/incSearchQString.asp" -->
<%
'--------------------------------------------------
' A. Taxonomy Code Search
'--------------------------------------------------

Public Sub printSearchInfo()
	If Not Nl(strTermCodeDisplay) And Not g_bPrintMode Then
		strSearchInfoRefineNotes = TXT_BROWSE_BY_SERVICE_CATEGORY & TXT_COLON & strTermName & StringIf(bLRestricted," <em>(" & TXT_RESTRICT & ")</em>")
		Response.Write(strTermCodeDisplay)
		If Not user_bLoggedIn Then
%>
<p class="SmallNote"><%=TXT_TAXONOMY_DISCLAIMER%></p>
<%
		End If
	End If
End Sub

Dim strTaxCode, _
	bLRestricted, _
	strTermName, _
	strTermCodeDisplay, _
	strTermCodeWarning

bLRestricted = False

'Check for Unrestricted or Restricted Code Search (can't have both!)
strTaxCode = Request("TC")
If Nl(strTaxCode) Then
	strTaxCode = Request("TCR")
	bLRestricted = True
End If

'If we have a Code, confirm that it is a valid, active Code,
'and fetch display information for the Taxonomy Code Search menu
'that appears at the top of the Search Results
If Not Nl(strTaxCode) Then
	If Not IsTaxonomyCodeType(strTaxCode) Then
		Call handleError(TXT_WARNING & TXT_WARNING_TAXONOMY_CODE & strTaxCode, _
				vbNullString, vbNullString)
		strTaxCode = Null
	Else
		strTermCodeDisplay = getTermCodeDisplay(strTaxCode, bLRestricted, strTermName, strTermCodeWarning)
		If Not Nl(strTermCodeWarning) Then
			Call handleError(TXT_WARNING & strTermCodeWarning, _
					vbNullString, vbNullString)
		End If
	End If
End If

'--------------------------------------------------
' A. Taxonomy Code Search
'--------------------------------------------------

Dim strTaxCodeSrch
strTaxCodeSrch = getTermCodeSQL("bt",strTaxCode,bLRestricted)

If Not Nl(strTaxCodeSrch) Then
	strWhere = strWhere & strCon & "(" & strTaxCodeSrch & ")"
	strCon = AND_CON
End If

Call finalQStringTidy()

'--------------------------------------------------

'Check that there is at least one type of search criteria,
'unless we came from the Advanced Search page, Saved Search page, or are redisplaying existing results.
If Nl(strWhere) Then
	Call handleError("<p>" & TXT_NO_TERMS & "</p>", _
		vbNullString, vbNullString)
Else
	If Not g_bPrintMode Then
		Response.Write(render_gtranslate_ui())
	End If

	Dim	objOrgTable
	Set objOrgTable = New OrgRecordTable

	Call objOrgTable.setOptions(strFrom, strWhere, vbNullString, False, False, strQueryString, CAN_RANK_NONE, vbNullString, vbNullString, False)
%>
		<div id="SearchResultsArea">
<%
	Call objOrgTable.makeTable()
%>
		</div>
<%
	Set objOrgTable = Nothing
End If
%>

<%
If Not bInlineMode Then
Call makeMappingSearchFooter()
Call makePageFooter(True)
End If
%>
<!--#include file="includes/core/incClose.asp" -->

