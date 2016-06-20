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
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtSubjects.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="includes/thesaurus/incUseInsteadList.asp" -->
<!--#include file="includes/thesaurus/incSubjSearchUtils.asp" -->
<!--#include file="includes/thesaurus/incSubjSearchResults.asp" -->
<%
Call makePageHeader(TXT_SUBJECT_FINDER, TXT_SUBJECT_FINDER, False, False, True, False)
%>
<h1><%=TXT_SUBJECT_SEARCH_RESULTS%></h1>
<%

Dim strSearch, strSubjID, bAdmin
strSearch = Trim(Request("SubjSrch"))
strSubjID = Trim(Request("SubjID"))
bAdmin = Request("Admin") = "on" And user_bSuperUserGlobalCIC

If Nl(strSearch) And Nl(strSubjID) Then
%>
<p><%=TXT_NOTHING_TO_SEARCH%></p>
<%
Else
	Dim singleSTerms(), _
		quotedSTerms(), _
		exactSTerms(), _
		displaySTerms(), _
		strJoinedSTerms, _
		strJoinedQSTerms
	
	If Not Nl(strSearch) Then
		Call makeSearchString( _
			strSearch, _
			singleSTerms, _
			quotedSTerms, _
			exactSTerms, _
			displaySTerms, _
			False _
		)
		
		strJoinedSTerms = Join(singleSTerms,AND_CON)
		strJoinedQSTerms = Join(quotedSTerms,AND_CON)
	End If

	Call makeSubjectBox(bAdmin, strJoinedSTerms, strJoinedQSTerms, Join(exactSTerms," "), strSubjID, bAdmin, True, "subjfind_results.asp")
End If
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a> ]</p>
<%
Call makePageFooter(False)
%>
<!--#include file="includes/core/incClose.asp" -->

