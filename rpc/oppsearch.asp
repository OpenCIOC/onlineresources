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
g_bAllowAPILogin = True
Call setPageInfo(False, DM_VOL, DM_VOL, "../", "rpc/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtChecklist.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtRecordPages.asp" -->
<!--#include file="../text/txtSearchAdvanced.asp" -->
<!--#include file="../text/txtSearchAdvancedVOL.asp" -->
<!--#include file="../text/txtSearchBasic.asp" -->
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../text/txtSearchResultsAdvanced.asp" -->
<!--#include file="../includes/core/incFieldDataClass.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/core/incOrderByConst.asp" -->
<!--#include file="../includes/display/incVOLDisplayOptionsFields.asp" -->
<!--#include file="../includes/search/incCommSrchVOLList.asp" -->
<!--#include file="../includes/search/incCustFieldResults.asp" -->
<!--#include file="../includes/search/incMakeTableClassVOL.asp" -->
<!--#include file="../includes/search/incSearchRecent.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
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
If Not has_api_permission(DM_VOL, "realtimestandard") Then
	Call HTTPBasicUnauth("CIOC RPC")
End If
Call getDisplayOptionsVOL(g_intViewTypeVOL, True)

Dim bSearchDisplay
bSearchDisplay = False

Dim strFrom, _
	strWhere, _
	strCon

strFrom = "VOL_Opportunity vo" & vbCrLf & _
	"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
	"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)"
strWhere = vbNullString
strCon = vbNullString

%>
<!--#include file="../includes/search/incSearchBasicCommon.asp" -->
<!--#include file="../includes/search/incSearchAdvanced.asp" -->
<!--#include file="../includes/search/incSearchVOL.asp" -->
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

'Check that there is at least one type of search criteria,
'unless we came from the Advanced Search page, Saved Search page, or are redisplaying existing results.
Dim bShowAllRecords, _
	strExclusions

bShowAllRecords = Nl(strWhere) Or _
	((Not g_bCanSeeExpired And strDisplayStatus<>"A") And strWhere = "(vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())")

If bShowAllRecords Then
	If bFormatXML Then
%><root><error><%= XMLEncode("Criteria Error") %></error><recordset/></root><%
	Else
%>{ "error": <%= JSONQs("Criteria Error",True) %>, "recordset": null }<%
	End If
Else
	Dim objOpTable
	Set objOpTable = New OpRecordTable

	Call objOpTable.setOptions(strFrom, strWhere, vbNullString, False, vbNullString, vbNullString)
	If bFormatXML Then
	Call objOpTable.makeXML()
	Else
	Call objOpTable.makeJSON()
	End If
	Set objOpTable = Nothing

End If
%>

<!--#include file="../includes/core/incClose.asp" -->

