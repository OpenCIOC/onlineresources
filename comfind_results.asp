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
<!--#include file="text/txtFinder.asp" -->
<%
Call makePageHeader(TXT_COMMUNITY_FINDER, TXT_COMMUNITY_FINDER, False, False, True, False)
%>
<h1><%=TXT_COMMUNITY_SEARCH_RESULTS%></h1>
<%

Dim intCMID, strSearch, bSearchParams, strHTTPVals
intCMID = Request("CMID")
If Nl(intCMID) Then
	intCMID = Null
ElseIf Not IsIDType(intCMID) Then
	intCMID = Null
End If

strSearch = Trim(Request("CommSrch"))
If Len(strSearch) > 100 Then
	strSearch = Null
End If
bSearchParams = Not Nl(Trim(Request("SearchParameterKey")))

strHTTPVals = g_strCacheHTTPVals
If bSearchParams Then
	strHTTPVals = Ns(strHTTPVals) & StringIf(Not Nl(strHTTPVals), "&") & "SearchParameterKey=on"
End If

If Nl(strSearch) And Nl(intCMID) Then
%>
<p><%=TXT_NOTHING_TO_SEARCH%></p>
<%
Else
	Dim cmdCommFinder, rsCommFinder
	Set cmdCommFinder = Server.CreateObject("ADODB.Command")
	With cmdCommFinder
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_GBL_Community_ls_Finder"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@CM_ID", adInteger, adParamInput, 4, intCMID)
		.Parameters.Append .CreateParameter("@searchStr", adVarChar, adParamInput, 100, strSearch)
		.Parameters.Append .CreateParameter("@HTTPVals", adVarChar, adParamInput, 500, strHTTPVals)
		.Parameters.Append .CreateParameter("@PathToStart", adVarChar, adParamInput, 50, ps_strPathToStart)
		.Parameters.Append .CreateParameter("@SearchParameters", adBoolean, adParamInput, 1, bSearchParams)
	End With
	Set rsCommFinder = Server.CreateObject("ADODB.Recordset")
	With rsCommFinder
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdCommFinder
		If Not Nl(strSearch) Then
%>
<p><%=TXT_YOUR_SEARCH%> <em><%=strSearch%></em> <%=TXT_HAS_FOUND%> <%=rsCommFinder.RecordCount%> <%=TXT_RESULTS%>.</p>
<%
		End If
%>
<ul<%=StringIf(bSearchParams, " style=""line-height:1.75;""")%>>
<%
		While Not .EOF
%>
<li><strong><%=.Fields("Community")%></strong><%=StringIf(Not Nl(.Fields("ParentCommunityName"))," (in " & .Fields("ParentCommunityName") & ")") %>
    <% If bSearchParams Then %> <span class="HighLight">CMID=<%= .Fields("CM_ID") %></span><% End If %> <%= .Fields("ChildCommunities")%></li>
<%
			.MoveNext
		Wend
%>
</ul>
<%
		.Close
	End With

	Set rsCommFinder = Nothing
	Set cmdCommFinder = Nothing
End If
%>
<%
Call makePageFooter(False)
%>
<!--#include file="includes/core/incClose.asp" -->
