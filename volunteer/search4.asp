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
<!--#include file="../text/txtDateTimeTable.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<%
Call makePageHeader(TXT_VOLUNTEER_SEARCH_STEP & IIf(g_bOnlySpecificInterests,"3","4"), TXT_VOLUNTEER_SEARCH_STEP & IIf(g_bOnlySpecificInterests,"3","4"), True, False, False, True)
%>
<%
Dim strCMID, _
	strSearchCMID, _
	decAge, _
	bOSSD, _
	strIGID

strCMID = Trim(Request("CMID"))
strSearchCMID = Trim(Request("SearchCMID"))

decAge = Request("Age")
If Not Nl(decAge) Then
	If IsNumeric(decAge) Then
		decAge = CSng(decAge)
	Else
		decAge = Null
	End IF
Else
	decAge = Null
End If
bOSSD = Request("forOSSD") = "on"
strIGID = Trim(Request("IGID"))

If Not IsIDList(strIGID) Then
	strIGID = Null
End If
%>
<h2><%= TXT_DAYS_AND_TIMES %></h2>
<p><%= TXT_INST_SELECT_DAYS_AND_TIMES %></p>
<form action="results.asp" name="EntryForm" method="get">
<div style="display:none">
<%=g_strCacheFormVals%>
<%If Not Nl(strCMID) Then%>
<input type="hidden" name="CMID" value="<%=strCMID%>">
<input type="hidden" name="SearchCMID" value="<%=strSearchCMID%>">
<%End If%>
<%If Not Nl(decAge) Then%>
<input type="hidden" name="Age" value="<%=decAge%>">
<%End If%>
<%If bOSSD Then%>
<input type="hidden" name="forOSSD" value="on">
<%End If%>
<%If Not Nl(Request("AIID")) Then%>
<input type="hidden" name="AIID" value="<%=Request("AIID")%>">
<%ElseIf Not Nl(Request("IGID")) Then%>
<input type="hidden" name="IGID" value="<%=Request("IGID")%>">
<%End If%>
</div>
<!--#include file="../includes/search/incDateTimeTable.asp" -->
<input class="btn btn-default clear-line-above" type="submit" value="<%= TXT_GET_MATCHES %>">
</form>

<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
