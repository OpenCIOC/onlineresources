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
<%
Call makePageHeader(TXT_SUBJECT_FINDER, TXT_SUBJECT_FINDER, False, False, True, False)
%>
<form action="subjfind_results.asp" target="mainFrame" method="post">
<%=g_strCacheFormVals%>
<%If Request("Admin")="on" And user_bSuperUserCIC Then%>
<input type="hidden" name="Admin" value="on">
<%End If%>
<table class="BasicBorder cell-padding-2">
	<tr>
		<td class="FieldLabelLeft"><label for="SubjSrch"><%=TXT_CONTAINS & TXT_COLON%></label></td>
		<td>
			<input name="SubjSrch" id="SubjSrch" TYPE="text" size="30" maxlength="100">
			<input type="submit" name="Submit" value="<%=TXT_SEARCH%>">
		</td>
	</tr>
</table>
</form>
<%
Call makePageFooter(False)
%>
<!--#include file="includes/core/incClose.asp" -->
