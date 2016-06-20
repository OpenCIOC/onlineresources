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
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../includes/search/incCommSrchVOL.asp" -->
<%
Call makePageHeader(TXT_STUDENT_VOLUNTEERS, TXT_STUDENT_VOLUNTEERS, True, False, False, True)
%>
<h2><%= TXT_SEARCH_STUDENT_OPPS %></h2>
<form action="search<%=IIf(g_bOnlySpecificInterests,3,2)%>.asp" name="EntryForm" method="get">
<%=g_strCacheFormVals%>
<h4><%= TXT_AGE %></h4>
<p><label for="Age"><%= TXT_SELECT_YOUR_AGE %></label>&nbsp;<select name="Age" id="Age">
<option></option>
<option value="10">10</option>
<option value="11">11</option>
<option value="12">12</option>
<option value="13">13</option>
<option value="14">14</option>
<option value="15">15</option>
<option value="16">16</option>
<option value="17">17</option>
<option value="18">18</option>
<option value="19">19</option>
<option value="20">20</option>
<option value="21">21</option>
<option value="22">22</option>
<option value="23">23</option>
<option value="24">24</option>
<option value="25">25</option>
</select></p>
<%
Dim strCommTable, bEmptyCommTable
strCommTable = makeCommSrchTable(bEmptyCommTable, False)

If Not bEmptyCommTable Then
%>
<h4><%= TXT_COMMUNITIES %></h4>
<p><%= TXT_INST_SELECT_COMMUNITIES %></p>
<%=strCommTable%>
<%
End If
If g_bUseOSSD Then
%>
<h4><%= TXT_OSSD_COMPONENT_LONG_FORM %></h4>
<p><label for="forOSSD"><input name="forOSSD" id="forOSSD" type="checkbox"><%= TXT_INST_OSSD_COMPONENT %></label></p>
<%
End If
%>
<p><input type="submit" value="<%= TXT_NEXT %> >>"></p>
</form>

<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
