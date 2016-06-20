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
<!--#include file="../text/txtCustFields.asp" -->
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtDateTimeTable.asp" -->
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
<!--#include file="../includes/search/incMyList.asp" -->
<!--#include file="../includes/search/incSearchRecent.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="../includes/search/incDatesPredef.asp" -->
<%
'On Error Resume Next

Dim strReferer
strReferer = Request.ServerVariables("HTTP_REFERER")
%>
<!--#include file="../includes/search/incSearchSetupVOL.asp" -->
<!--#include file="../includes/search/incSearchQString.asp" -->
<%

If Request("NewWindow") = "on" Then
	Call setSessionValue("NewWindowVOL", "on")
Else
	Call setSessionValue("NewWindowVOL", Null)
End If

If Not reEquals(strReferer,"advsrch.asp",True,False,False,False) Then
	bSearchDisplay = Not g_bPrintMode
ElseIf Request("SearchDisplay")="on" Then
	bSearchDisplay = Not g_bPrintMode
	Call setSessionValue("SearchDisplayVOL", "on")
Else
	bSearchDisplay = False
	Call setSessionValue("SearchDisplayVOL", Null)
End If
%>
<!--#include file="../includes/search/incSearchBasicCommon.asp" -->
<!--#include file="../includes/search/incSearchAdvanced.asp" -->
<!--#include file="../includes/search/incSearchVOL.asp" -->
<%
If Not Nl(strSearchErrors) Then
	Call handleError(strSearchErrors, _
		vbNullString, vbNullString)
End If

Call finalQStringTidy()
'--------------------------------------------------

'Check that there is at least one type of search criteria,
'unless we came from the Advanced Search page, Saved Search page, or are redisplaying existing results.
Dim bShowAllRecords, _
	strExclusions

bShowAllRecords = Nl(strWhere) Or _
	((Not g_bCanSeeExpired And strDisplayStatus<>"A") And strWhere = "(vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())")

strExclusions = vbNullString
If Not bIncludeDeleted And g_bCanSeeDeletedCIC Then
	strExclusions = TXT_DELETED_EXCLUDED
End If
If Not g_bCanSeeExpired And strDisplayStatus<>"A" Then
	strExclusions = strExclusions & StringIf(Not Nl(strExclusions)," ; ") & TXT_EXPIRED_EXCLUDED
End If

If Not (reEquals(strReferer,"advsrch.asp",True,False,False,False) _
			Or (reEquals(strReferer,"results.asp",True,False,False,False) And g_bPrintMode)) _
		And bShowAllRecords Then
	Call handleError("<p>" & TXT_NO_TERMS & "</p>", _
		vbNullString, vbNullString)
Else
	If Not g_bPrintMode Then
		Response.Write(render_gtranslate_ui())
		If bShowAllRecords Then
%>
<p><%=TXT_YOU_SEARCHED_FOR%><strong><%=TXT_ALL_AVAILABLE_RECORDS & StringIf(Not Nl(strExclusions)," (" & strExclusions & ")")%></strong></p>
<%
		Else
%>
<!--#include file="../includes/search/incSearchInfo.asp" -->
<%
		End If
	End If

	Dim objOpTable
	Set objOpTable = New OpRecordTable

	Call objOpTable.setOptions(strFrom, strWhere, strSearchInfoSSNotes, bIncludeDeleted, vbNullString, vbNullString)
	Call objOpTable.makeTable()
	Set objOpTable = Nothing

End If
%>

<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->

