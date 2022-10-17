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
Call setPageInfo(False, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtChecklist.asp" -->
<!--#include file="../text/txtClientTracker.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtRecordPages.asp" -->
<!--#include file="../text/txtSearchBasic.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../includes/core/incFieldDataClass.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/core/incOrderByConst.asp" -->
<!--#include file="../includes/display/incVOLDisplayOptionsFields.asp" -->
<!--#include file="../includes/search/incMakeTableClassVOL.asp" -->
<!--#include file="../includes/search/incMyList.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="../includes/search/incSearchRecent.asp" -->
<%
'On Error Resume Next
%>
<!--#include file="../includes/search/incSearchSetupVOL.asp" -->
<!--#include file="../includes/search/incSearchQString.asp" -->
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
	strWhere = strWhere & strCon & "(vo.VNUM IN (" & strRecordList & "))"
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

	Dim objOpTable

	Set objOpTable = New OpRecordTable

	Call objOpTable.setOptions(strFrom, strWhere, vbNullString, g_bCanSeeDeletedVOL, vbNullString, vbNullString)

	Call objOpTable.enableListViewMode()

	Call objOpTable.makeTable()

	Set objOpTable = Nothing

End If
%>

<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->

