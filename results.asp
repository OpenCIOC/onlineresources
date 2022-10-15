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
<!--#include file="text/txtCustFields.asp" -->
<!--#include file="text/txtDates.asp" -->
<!--#include file="text/txtFormDataCheck.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtGeneralSearch1.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtRecordPages.asp" -->
<!--#include file="text/txtSearchAdvanced.asp" -->
<!--#include file="text/txtSearchAdvancedCIC.asp" -->
<!--#include file="text/txtSearchBasic.asp" -->
<!--#include file="text/txtSearchBasicCIC.asp" -->
<!--#include file="text/txtSearchCCR.asp" -->
<!--#include file="text/txtSearchResults.asp" -->
<!--#include file="text/txtSearchResultsAdvanced.asp" -->
<!--#include file="text/txtSearchResultsTax.asp" -->
<!--#include file="text/txtSubjects.asp" -->
<!--#include file="includes/core/incFieldDataClass.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/core/incOrderByConst.asp" -->
<!--#include file="includes/display/incCICDisplayOptionsFields.asp" -->
<!--#include file="includes/list/incMappingCategoryList.asp" -->
<!--#include file="includes/mapping/incGoogleMaps.asp" -->
<!--#include file="includes/mapping/incMapSearchResults.asp" -->
<!--#include file="includes/search/incCustFieldResults.asp" -->
<!--#include file="includes/search/incMakeTableClassCIC.asp" -->
<!--#include file="includes/search/incMyList.asp" -->
<!--#include file="includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="includes/search/incSearchRecent.asp" -->
<!--#include file="includes/taxonomy/incTaxTermSearches.asp" -->
<!--#include file="includes/thesaurus/incUseInsteadList.asp" -->
<!--#include file="includes/thesaurus/incSubjSearchResults.asp" -->
<!--#include file="includes/thesaurus/incSubjSearchUtils.asp" -->
<!--#include file="includes/search/incDatesPredef.asp" -->
<!--#include file="includes/search/incSearchInfo.asp" -->
<%
'On Error Resume Next

Public Sub printSearchInfo()

If Not g_bPrintMode Then	
	If Nl(strWhere) And Not (opt_intOrderByCIC = OB_RELEVANCY And Not (Nl(strJoinedSTerms) And Nl(strJoinedQSTerms))) Then

%>
	<p><%=TXT_YOU_SEARCHED_FOR%><strong><%=TXT_ALL_AVAILABLE_RECORDS & StringIf(Not bIncludeDeleted And g_bCanSeeDeletedCIC," (" & TXT_DELETED_EXCLUDED & ")")%></strong></p>
<%
	Else
		If Not Nl(strTermListDisplayAll & strTermListDisplayAny) Then
			strMoreSearchInfoRefineNotes = TXT_TAX_CRITERIA & TXT_COLON & "<ul>"
%>
	<p><%=TXT_YOUR_TAX_CRITERIA%></p>
	<ul>
<%
			If Not Nl(strTermListDisplayAll) Then
				strMoreSearchInfoRefineNotes = strMoreSearchInfoRefineNotes & _
					"<li><strong>" & TXT_MUST_MATCH_TERMS & "</strong>" & strTermListDisplayAll & "</li>"
	%>
		<li><strong><%=TXT_MUST_MATCH_TERMS%></strong><%=strTermListDisplayAll%></li>
	<%
			End If
			If Not Nl(strTermListDisplayAny) Then
				strMoreSearchInfoRefineNotes = strMoreSearchInfoRefineNotes & _
						"<li><strong>" & TXT_MATCH_ANY_TERMS & "</strong>" & strTermListDisplayAny & "</li>"
	%>
			<li><strong><%=TXT_MATCH_ANY_TERMS%></strong><%=strTermListDisplayAny%></li>
	<%
				End If
				If bTMCRestricted Then
					strMoreSearchInfoRefineNotes = strMoreSearchInfoRefineNotes & _
						"<li><strong>" & TXT_RESTRICT & "</strong></li>"
	%>
			<li><strong><%=TXT_RESTRICT%></strong></li>
	<%
				End If
				strMoreSearchInfoRefineNotes = strMoreSearchInfoRefineNotes & "</ul>"
%>
	</ul>
<%
			If user_bLoggedIn And user_bCIC Then
%>
	<p><%=TXT_NEW_SEARCH_W_TERMS%>
		[ <a href="<%=makeLink("taxsrch.asp","TMC=" & strTMC & "&ATMC=" & strATMC & IIf(bTMCRestricted,"&TMCR=on",vbNullString),vbNullString)%>"><%=TXT_EDIT_TERM_LIST%></a>
		| <a href="<%=makeLink("advsrch.asp","TMC=" & strTMC & "&ATMC=" & strATMC & IIf(bTMCRestricted,"&TMCR=on",vbNullString),vbNullString)%>"><%=TXT_ADD_CRITERIA%> (<%=TXT_ADVANCED_SEARCH%>)</a>
		]</p>
<%
			End If
%>
	<hr>
<%
		End If
		Response.Write(strSearchDetails)

		strSearchInfoRefineNotes = strSearchInfoRefineNotes & StringIf(Not (Nl(strSearchInfoRefineNotes) Or Nl(strMoreSearchInfoRefineNotes)),"-{|}-") & strMoreSearchInfoRefineNotes
	End If
End If

End Sub

Dim strReferer
strReferer = Request.ServerVariables("HTTP_REFERER")
%>
<!--#include file="includes/search/incSearchSetupCIC.asp" -->
<!--#include file="includes/search/incSearchQString.asp" -->
<%
If Request("NewWindow") = "on" Then
	Call setSessionValue("NewWindowCIC", "on")
Else
	Call setSessionValue("NewWindowCIC", Null)
End If

If Not reEquals(strReferer,"advsrch.asp",True,False,False,False) Then
	bSearchDisplay = Not g_bPrintMode And Not bInlineMode
ElseIf Request("SearchDisplay")="on" Then
	bSearchDisplay = Not g_bPrintMode
	Call setSessionValue("SearchDisplayCIC", "on")
Else
	bSearchDisplay = False
	Call setSessionValue("SearchDisplayCIC", Null)
End If

%>
<!--#include file="includes/search/incSearchBasicCommon.asp" -->
<!--#include file="includes/search/incSearchBasicCIC.asp" -->
<!--#include file="includes/search/incSearchBasicCCR.asp" -->
<!--#include file="includes/search/incSearchAdvanced.asp" -->
<!--#include file="includes/search/incSearchAdvancedCIC.asp" -->
<!--#include file="includes/search/incSearchSubjectBox.asp" -->
<%
If Not Nl(strSearchErrors) Then
	Call handleError(strSearchErrors, _
		vbNullString, vbNullString)
End If

'--------------------------------------------------

Call setCommonBasicSearchData()
Call setCICBasicSearchData()
Call setCCRBasicSearchData()
Call setCommonAdvSearchData()
Call setCICAdvSearchData()

'--------------------------------------------------

Call finalQStringTidy()

'--------------------------------------------------
'Check that there is at least one type of search criteria,
'unless we came from the Advanced Search page, Saved Search page, or are redisplaying existing results.

Dim strMoreSearchInfoRefineNotes

If Not (reEquals(strReferer,"advsrch.asp",True,False,False,False) _
			Or reEquals(strReferer,"results.asp",True,False,False,False) And g_bPrintMode) _
		And Nl(strWhere) And Not bIncludeDeleted Then
	Call handleError("<p>" & TXT_NO_TERMS & "</p>", _
		vbNullString, vbNullString)
Else
	If Not g_bPrintMode Then
		Response.Write(render_gtranslate_ui())
	End If
	If Not bHideSubjectBox Then
%>
<div class="row">
	<div id="subjects_column" class="hidden-xs col-sm-3 col-md-3">
		<%Call printSubjectBox%>
	</div>
	<div id="results-column" class="col-xs-12 col-sm-9 col-md-9">
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

	Call setSearchDetails()

	Call objOrgTable.setOptions(strFrom, strWhere, strSearchInfoSSNotes, bIncludeDeleted, bHideSubjectBox And bCanShowSubjectBox, strQueryString, intRelevancyType, decNearLatitude, decNearLongitude, bNearSort)
%>
		<div id="SearchResultsArea">
<%
	Call objOrgTable.makeTable()
%>
		</div>
<%
	Set objOrgTable = Nothing
	
	If Not bHideSubjectBox Then
%>
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

