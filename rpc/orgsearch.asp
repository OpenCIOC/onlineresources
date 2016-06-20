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
<!--#include file="../includes/core/adovbs.inc" -->
<!--#include file="../includes/core/incVBUtils.asp" -->
<!--#include file="../includes/validation/incBasicTypes.asp" -->
<!--#include file="../includes/core/incRExpFuncs.asp" -->
<!--#include file="../includes/core/incHandleError.asp" -->
<!--#include file="../includes/core/incSetLanguage.asp" -->
<!--#include file="../includes/core/incPassVars.asp" -->
<!--#include file="../text/txtGeneral.asp" -->
<!--#include file="../text/txtError.asp" -->
<!--#include file="../includes/core/incConnection.asp" -->
<!--#include file="../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
g_bPageShouldUseSSL = True
g_bAllowAPILogin = True
Call setPageInfo(False, DM_GLOBAL, DM_CIC, vbNullString, "rpc/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtChecklist.asp" -->
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtFormDataCheck.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtRecordPages.asp" -->
<!--#include file="../text/txtSearchAdvanced.asp" -->
<!--#include file="../text/txtSearchAdvancedCIC.asp" -->
<!--#include file="../text/txtSearchBasic.asp" -->
<!--#include file="../text/txtSearchBasicCIC.asp" -->
<!--#include file="../text/txtSearchCCR.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../text/txtSearchResultsAdvanced.asp" -->
<!--#include file="../text/txtSearchResultsTax.asp" -->
<!--#include file="../includes/core/incFieldDataClass.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/core/incOrderByConst.asp" -->
<!--#include file="../includes/display/incCICDisplayOptionsFields.asp" -->
<!--#include file="../includes/search/incCustFieldResults.asp" -->
<!--#include file="../includes/search/incDatesPredef.asp" -->
<!--#include file="../includes/search/incMakeTableClassCIC.asp" -->
<!--#include file="../includes/search/incSearchRecent.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="../includes/taxonomy/incTaxTermSearches.asp" -->
<!--#include file="../includes/thesaurus/incSubjSearchResults.asp" -->
<%
Dim bFormatXML
bFormatXML = LCase(Ns(Request("format"))) = "xml"
If bFormatXML Then
Response.Clear %><?xml version="1.0" encoding="utf-8"?><%
Response.ContentType = "application/xml"
Response.CacheControl = "Private"
Response.Expires=-1
Else
'Set response type headers
Response.ContentType = "application/json"
Response.CacheControl = "Private"
'Response.Expires=-1
End If

Call run_response_callbacks()

'On Error Resume Next
%>
<!--#include file="../includes/search/incSearchQString.asp" -->
<%
If Not user_bLoggedIn Then
	Call HTTPBasicUnauth("CIOC RPC")
End If
If Not has_api_permission(DM_CIC, "realtimestandard") Then
	Call HTTPBasicUnauth("CIOC RPC")
End If
Call getDisplayOptionsCIC(g_intViewTypeCIC, True)

Dim bSearchDisplay
bSearchDisplay = False

Dim strFrom, _
	strWhere, _
	strCon

strFrom = "GBL_BaseTable bt " & vbCrLf & _
	"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
	"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
	"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf & _
	"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
	"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=" & g_objCurrentLang.LangID
			
strWhere = vbNullString
strCon = vbNullString
%>
<!--#include file="../includes/search/incSearchBasicCommon.asp" -->
<!--#include file="../includes/search/incSearchBasicCIC.asp" -->
<!--#include file="../includes/search/incSearchBasicCCR.asp" -->
<!--#include file="../includes/search/incSearchAdvanced.asp" -->
<!--#include file="../includes/search/incSearchAdvancedCIC.asp" -->
<% 
If Not Nl(strSearchErrors) Then
	If bFormatXML Then
%><root><error><%= XMLEncode(strSearchErrors) %></error><recordset/></root><%
	Else
%>
{ "error": <%= JSONQs(strSearchErrors,True) %>, "recordset": null}
<%
	End If
	Response.End()
End If

Call finalQStringTidy()

'--------------------------------------------------

Call setCommonBasicSearchData()
Call setCICBasicSearchData()
Call setCCRBasicSearchData()
Call setCommonAdvSearchData()
Call setCICAdvSearchData()

'Check that there is at least one type of search criteria,
'unless we came from the Advanced Search page, Saved Search page, or are redisplaying existing results.

If Nl(strWhere) And Not (bRelevancy And Not (Nl(strJoinedSTerms) And Nl(strJoinedQSTerms))) Then
	If bFormatXML Then
%><root><error><%= XMLEncode("Criteria Error") %></error><recordset/></root><%
	Else
%>{ "error": <%= JSONQs("Criteria Error",True) %>, "recordset": null }<%
	End If
Else
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

	Call objOrgTable.setOptions(strFrom, strWhere, vbNullString, False, False, strQueryString, intRelevancyType, vbNullString, vbNullString, False)
	If bFormatXML Then
	Call objOrgTable.makeXML(False)
	Else
	Call objOrgTable.makeJSON(False)
	End If
	Set objOrgTable = Nothing
End If
%>


<!--#include file="../includes/core/incClose.asp" -->

