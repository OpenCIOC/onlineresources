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
<!--#include file="text/txtChecklist.asp" -->
<!--#include file="text/txtClientTracker.asp" -->
<!--#include file="text/txtFormDataCheck.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtGeneralSearch1.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtRecordPages.asp" -->
<!--#include file="text/txtSearchBasic.asp" -->
<!--#include file="text/txtSearchBasicCIC.asp" -->
<!--#include file="text/txtSearchResults.asp" -->
<!--#include file="text/txtSubjects.asp" -->
<!--#include file="includes/search/incMyList.asp" -->
<!--#include file="includes/core/incFieldDataClass.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/core/incOrderByConst.asp" -->
<!--#include file="includes/display/incCICDisplayOptionsFields.asp" -->
<!--#include file="includes/list/incMappingCategoryList.asp" -->
<!--#include file="includes/mapping/incGoogleMaps.asp" -->
<!--#include file="includes/mapping/incMapSearchResults.asp" -->
<!--#include file="includes/search/incCustFieldResults.asp" -->
<!--#include file="includes/search/incSearchRecent.asp" -->
<!--#include file="includes/search/incMakeTableClassCIC.asp" -->
<!--#include file="includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="includes/taxonomy/incTaxTermSearches.asp" -->
<!--#include file="includes/thesaurus/incUseInsteadList.asp" -->
<!--#include file="includes/thesaurus/incSubjSearchResults.asp" -->
<!--#include file="includes/thesaurus/incSubjSearchUtils.asp" -->
<%
'On Error Resume Next
%>
<!--#include file="includes/search/incSearchSetupCIC.asp" -->
<!--#include file="includes/search/incSearchQString.asp" -->
<%
bSearchDisplay = Not g_bPrintMode
%>
<!--#include file="includes/search/incSearchBasicCommon.asp" -->
<!--#include file="includes/search/incSearchBasicCIC.asp" -->
<!--#include file="includes/search/incSearchSubjectBox.asp" -->
<% 
If Not Nl(strSearchErrors) Then
	Call handleError(strSearchErrors, _
		vbNullString, vbNullString)
End If

Call finalQStringTidy()

'--------------------------------------------------

Call setCommonBasicSearchData()
Call setCICBasicSearchData()

'Check that there is at least one type of search criteria,
'unless we came from the Advanced Search page, Saved Search page, or are redisplaying existing results.

If Nl(strWhere) And Not (bRelevancy And Not (Nl(strJoinedSTerms) And Nl(strJoinedQSTerms))) Then
	Call handleError("<p>" & TXT_NO_TERMS & "</p>", _
		vbNullString, vbNullString)
Else
	If Not g_bPrintMode Then
		Response.Write(render_gtranslate_ui())
	End If
	If Not bHideSubjectBox Then
%>
<div class="cioc-grid-row">
	<div id="results-column" class="cioc-col-sm-9 cioc-col-md-10 cioc-col-md-push-2 cioc-col-sm-push-3">
<%
	End If

	Dim	objOrgTable, _
		intRelevancyType

	Set objOrgTable = New OrgRecordTable

	If Nl(strJoinedSTerms) Then
		If Nl(strJoinedQSTerms) Then
			intRelevancyType = CAN_RANK_NONE
		Else
			intRelevancyType = CAN_RANK_QUOTED
		End If
	ElseIf Nl(strJoinedQSTerms) Then
		intRelevancyType = CAN_RANK_SIMPLE
	Else
		intRelevancyType = CAN_RANK_BOTH
	End If

	Call objOrgTable.setOptions(strFrom, strWhere, strSearchInfoSSNotes, False, bHideSubjectBox And bCanShowSubjectBox, strQueryString, intRelevancyType, vbNullString, vbNullString, False)
%>
	<div id="SearchResultsArea">
	<!--#include file="includes/search/incSearchInfo.asp" -->
<%
	Call objOrgTable.makeTable()
%>
	</div>
<%
	Set objOrgTable = Nothing
	
	If Not bHideSubjectBox Then
%>
	</div>
	<div id="subjects_column" class="cioc-col-sm-3 cioc-col-md-2 cioc-col-md-pull-10 cioc-col-sm-pull-9">
	<%Call printSubjectBox%>
	</div>
</div>
<%
	End If
End If

If Not bInlineMode Then
Call makeMappingSearchFooter()
%><!--#include file="includes/search/incDynamicSubjectsSidebar.asp" --><%
Call makePageFooter(True)
End If
%>
<!--#include file="includes/core/incClose.asp" -->

