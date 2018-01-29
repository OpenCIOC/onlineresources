<%@LANGUAGE="VBSCRIPT"%><%Option Explicit%><?xml version="1.0" encoding="UTF-8"?>

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
'
' Purpose:		Generate XML File for Resource Type Registration Request from Client Tracker
'				Conforms to Client Tracker Schema registration.xsd
'
'
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
Call setPageInfo(False, DM_CIC, DM_CIC, "../", "ct/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtClientTracker.asp" -->
<!--#include file="../includes/search/incMyList.asp" -->

<%
'Set response type headers
Response.ContentType = "application/xml"
Response.CacheControl = "Private"
Response.Expires=-1

Call run_response_callbacks()
%>
<%
If Not ctClientCanMakeRequest() Then
%>
<response xmlns="https://clienttracker.cioc.ca/schema/">
	<error><%=TXT_CT_ACCESS_DENIED%></error>
</response>
<%
Else
%>
<response xmlns="https://clienttracker.cioc.ca/schema/">
	<resourceType>
		<name><%=XMLEncode(g_strDatabaseNameCIC)%></name>
		<launchURL><%=XMLEncode(IIf(g_bSSL, "https://", "http://") & Request.ServerVariables("HTTP_HOST") & Left(Request.ServerVariables("PATH_INFO"),Len(Request.ServerVariables("PATH_INFO"))-Len(ps_strThisPage)) & makeLink("ctlaunch.asp","ctid=[CTID]&login=[LOGIN]&key=[KEY]",vbNullString))%></launchURL>
		<resourceInfoURL><%=XMLEncode(IIf(g_bSSL, "https://", "http://") & Request.ServerVariables("HTTP_HOST") & Left(Request.ServerVariables("PATH_INFO"),Len(Request.ServerVariables("PATH_INFO"))-Len(ps_strThisPage)) & makeLink("ctfetch.asp","num=[ID]",vbNullString))%></resourceInfoURL>
		<resourceSummaryURL><%=XMLEncode(IIf(g_bSSL, "https://", "http://") & Request.ServerVariables("HTTP_HOST") & Left(Request.ServerVariables("PATH_INFO"),Len(Request.ServerVariables("PATH_INFO"))-Len(ps_strThisPageFull)) & makeLink("printlist.asp","IDList=[IDS]",vbNullString))%></resourceSummaryURL>
		<resourceEmailURL><%=XMLEncode(IIf(g_bSSL, "https://", "http://") & Request.ServerVariables("HTTP_HOST") & Left(Request.ServerVariables("PATH_INFO"),Len(Request.ServerVariables("PATH_INFO"))-Len(ps_strThisPageFull)) & makeLink("recordlist","IDList=[IDS]",vbNullString))%></resourceEmailURL>
	</resourceType>
</response>
<%
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
