﻿<%@LANGUAGE="VBSCRIPT"%>
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
<%
'On Error Resume Next
%>
<!--#include file="includes/search/incSearchSetupCIC.asp" -->
<!--#include file="includes/search/incSearchQString.asp" -->
<%
Public Sub printSearchInfo()
%>
<p><%=TXT_YOU_SEARCHED_FOR%><strong><%=strSearchInfoRefineNotes%></strong></p>
<%
End Sub

Dim strRecordList, _
	bListCriteria


bListCriteria = False

strRecordList = myListGenerateCriteria()

If Not Nl(strRecordList) Then
	bListCriteria = True
	strWhere = strWhere & strCon & "(bt.NUM IN (" & strRecordList & "))"
	strCon = AND_CON
End If

Call finalQStringTidy()

'--------------------------------------------------

If Not g_bPrintMode Then
	Response.Write(render_gtranslate_ui())
End If
If bListCriteria Then
	%><div id="no_records_message" style="display:none;"><%
End If
	%><p><%= TXT_LIST_EMPTY %></p><%
If bListCriteria Then
	%></div><%

	strSearchInfoRefineNotes = IIf(g_bEnableListModeCT, TXT_CT_CLIENT_TRACKER,TXT_MY_LIST) & TXT_COLON & "<em>" & TXT_AS_OF & DateTimeString(Now(),True) & "</em>"

	Dim	objOrgTable

	Set objOrgTable = New OrgRecordTable	

	Call objOrgTable.setOptions(strFrom, strWhere, vbNullString, g_bCanSeeDeletedCIC, False, strQueryString, CAN_RANK_NONE, vbNullString, vbNullString, False)

	Call objOrgTable.enableListViewMode()

	Call objOrgTable.makeTable()

	Set objOrgTable = Nothing
End If
%>

<%
Call makeMappingSearchFooter()
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->

