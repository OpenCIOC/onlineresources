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
Call setPageInfo(False, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
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
<!--#include file="includes/search/incMyList.asp" -->
<!--#include file="includes/core/incFieldDataClass.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/core/incOrderByConst.asp" -->
<!--#include file="includes/display/incCICDisplayOptionsFields.asp" -->
<!--#include file="includes/list/incMappingCategoryList.asp" -->
<!--#include file="includes/mapping/incGoogleMaps.asp" -->
<!--#include file="includes/mapping/incMapSearchResults.asp" -->
<!--#include file="includes/search/incMakeTableClassCIC.asp" -->
<!--#include file="includes/search/incSearchRecent.asp" -->
<%
'On Error Resume Next
%>
<!--#include file="includes/search/incSearchSetupCIC.asp" -->
<!--#include file="includes/search/incSearchQString.asp" -->
<%
'--------------------------------------------------
' Previous Search Results
'--------------------------------------------------

Public Sub printSearchInfo()
%>
<p><%=TXT_YOU_SEARCHED_FOR%><strong><%=TXT_YOUR_PREVIOUS_SEARCH%></strong></p>
<%
End Sub

Dim strPrevResults, _
	bPrevError

bPrevError = False

If IsArray(aGetSearchArray) Then
	strPrevResults = Join(aGetSearchArray,"','")
	If Not Nl(strPrevResults) Then
		strPrevResults = "'" & strPrevResults & "'"
	Else
		bPrevError = True
	End If
Else
	bPrevError = True
End If

If Not Nl(strPrevResults) Then
	strWhere = strWhere & strCon & "(bt.NUM IN (" & strPrevResults & "))"
	strCon = AND_CON
End If

Call finalQStringTidy()

'--------------------------------------------------

'Check that there is at least one type of search criteria,
'unless we came from the Advanced Search page, Saved Search page, or are redisplaying existing results.
If bPrevError Then
	Call handleError(TXT_NO_PREVIOUS, _
		vbNullString, vbNullString)
Else
	If Not g_bPrintMode Then
		Response.Write(render_gtranslate_ui())
	End If

	Dim	objOrgTable
	Set objOrgTable = New OrgRecordTable	

	Call objOrgTable.setOptions(strFrom, strWhere, vbNullString, g_bCanSeeDeletedCIC, False, strQueryString, CAN_RANK_NONE, vbNullString, vbNullString, False)
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
Call makeMappingSearchFooter()
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->

