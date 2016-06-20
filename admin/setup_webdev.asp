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
'
' Purpose:		Main setup menu
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
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtSetup.asp" -->
<%
If Not user_bWebDev Then
	Call securityFailure()
End If

Call makePageHeader(TXT_DATABASE_SETUP, TXT_DATABASE_SETUP, True, True, True, True)
%>
<h2><%=TXT_TEMPLATE_AND_LAYOUT_SETUP%></h2>
<p class="Info"><%=TXT_INST_TEMPLATE_AND_LAYOUT_SETUP%></p>
<ul>
	<li><a href="<%=makeLinkB("template")%>"><%=TXT_DESIGN_TEMPLATES%></a></li>
	<li><a href="<%=makeLinkB("layout")%>"><%=TXT_TEMPLATE_LAYOUTS%></a></li>
	<li><a href="<%=makeLink("pages", "DM=" & DM_CIC, vbNullString)%>"><%=TXT_PAGES%> (<%= TXT_CIC %>)</a></li>
	<li><a href="<%=makeLink("pages", "DM=" & DM_VOL, vbNullString)%>"><%=TXT_PAGES%> (<%= TXT_VOLUNTEER %>)</a></li>
</ul>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->

