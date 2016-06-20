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
<!--#include file="text/txtGeneralSearch2.asp" -->
<!--#include file="text/txtNAICS.asp" -->
<!--#include file="includes/naics/incNAICSSearchUtils.asp" -->
<!--#include file="includes/naics/incNAICSSearchResults.asp" -->
<!--#include file="includes/naics/incNAICSSectorList.asp" -->
<%
Call makePageHeader(TXT_NAICS_FINDER,TXT_NAICS_FINDER, False, False, True, False)

Dim bKeyword
bKeyword = Request("SType") <> "S"
%>
<table class="BasicBorder cell-padding-2" align="center">
<tr>
	<th class="TitleBox" colspan="2"><%=TXT_NAICS%></th>
</tr>
<tr>
	<th class="RevTitleBox" colspan="2"><%=TXT_KEYWORD_SEARCH%></th>
</tr>
<form action="naicsfind_results.asp" method="post">
<div style="display:none">
<%=g_strCacheFormVals%>
</div>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SEARCH_IN%></td>
	<td><label><input type="radio" name="SType" id="SType_C" value="C"><%= TXT_CLASSIFICATION_NAME_ONLY %></label>
	<br><label><input type="radio" name="SType" id="SType_A" value="A" checked><%= TXT_NAME_DESC_EXAMPLES %></label></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_KEYWORDS%></td>
	<td><span class="SmallNote"><%= TXT_KEYWORD_HINT %></span>
	<br><label><input type="radio" name="SCon" id="SCon_A" value="A" checked><%=TXT_ALL_TERMS%></label>
	<label><input type="radio" name="SCon" id="SCon_O" value="O"><%=TXT_ANY_TERMS%></label>
	<br><input name="STerms" title="<%= TXT_SEARCH_TERMS %>" TYPE="text" size="30" maxlength="100"><input type="submit" name="Submit" value="Submit"></td>
</tr>
</form>
<tr>
	<th class="RevTitleBox" colspan="2"><%=TXT_SPECIFIC_CODE%></th>
</tr>
<form action="naicsfind_results.asp" method="post">
<div style="display:none">
<%=g_strCacheFormVals%>
</div>
<tr>
	<td class="FieldLabelLeft"><label for="CodeText"><%=TXT_CODE & TXT_COLON%></label></td>
	<td><input name="NAICS" TYPE="text" id="CodeText" size="6" maxlength="6"><input type="submit" name="Submit" value="Submit"></td>
</tr>
</form>
<tr>
	<th class="RevTitleBox" colspan="2"><%=TXT_SECTOR_SEARCH%></th>
</tr>
<tr>
	<td colspan="2"><%=makeSectorTable("naicsfind_results.asp")%></td>
</tr>
</table>
<br>
<p class="SmallNote"><%=TXT_NAICS_USE_FOOTER%></p>
<%
Call makePageFooter(False)
%>
<!--#include file="includes/core/incClose.asp" -->
