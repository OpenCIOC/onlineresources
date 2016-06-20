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
' Purpose:		Results from "Areas of Interest" Finder
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
Call setPageInfo(False, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtFinder.asp" -->
<!--#include file="../text/txtBrowse.asp" -->
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../includes/list/incInterestList.asp" -->
<!--#include file="../includes/list/incInterestGroupList.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<%
Dim bProfileSearch
bProfileSearch = Not Nl(Trim(Request("ProfileSearch")))

If Not bProfileSearch Then
Call makePageHeader(TXT_AREA_OF_INTEREST_FINDER, TXT_AREA_OF_INTEREST_FINDER, False, False, True, False)
	If Not g_bOnlySpecificInterests Then
%>
<form action="interestfind.asp" method="post">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-2">
<%
	Call openInterestGroupListRst()
%>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_GENERAL_AREA_OF_INTEREST & TXT_COLON%></td>
		<td><%=makeInterestGroupList(vbNullString,"IGID",False)%>&nbsp;<input type="submit" value="<%=TXT_SEARCH%>">
		<br><%= TXT_OR_LC %><a href="<%= makeLink("~/volunteer/interestfind.asp", "ShowAll=on", vbNullString) %>"><%= TXT_SHOW_ALL %></a> <%= TXT_AREAS_OF_INTEREST %></td>
	</tr>
<%
	Call closeInterestGroupListRst() 
%>
</table>
</form>
<%	End If %>
<h1><%=TXT_AREA_OF_INTEREST_SEARCH_RESULTS%></h1>
<%
End If

Dim intIGID, bAllInterests
intIGID = Request("IGID")
bAllInterests = Not Nl(Trim(Request("ShowAll")))
If bAllInterests Then
	intIGID = vbNullString
End If


If Nl(intIGID) And Not g_bOnlySpecificInterests And Not bAllInterests Then
%>
<p><%=TXT_NOTHING_TO_SEARCH%></p>
<%
Else
	Call openInterestListRst(intIGID, False)
	
	With rsListInterest
		If Not .EOF Then
%>
<ul id="interest_list">
<%
			While Not .EOF
%>
	<li<%=StringIf(bProfileSearch, " data-id=""" & .Fields("AI_ID") & """ id=""result_" & .Fields("AI_ID") & """ class=""InterestResult""") %>><%=StringIf(bProfileSearch, "<span class=""source_interest_text"">") & .Fields("InterestName") & StringIf(bProfileSearch, "</span> <span class=""interest_ui"">[ <a class=""interest_add"" href=""#"" id=""interest_add_" & .Fields("AI_ID") & """>" & TXT_ADD & "</a><span class=""interest_added NotVisible"" id=""interest_added_" & .Fields("AI_ID") & """><img src=""" & ps_strRootPath & "images/greencheck.gif"" alt=""" & Server.HTMLEncode(TXT_ADDED) & """></span> ]</span>")%></li>
<%
				.MoveNext
			Wend
%>
</ul>
<%			
		End If
	End With

	Call closeInterestListRst()
End If
%>
<%
If Not bProfileSearch Then
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
