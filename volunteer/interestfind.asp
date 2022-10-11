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
<!--#include file="../text/txtBrowse.asp" -->
<!--#include file="../text/txtFinder.asp" -->
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incInterestList.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<%
Dim bProfileSearch
bProfileSearch = Not Nl(Trim(Request("ProfileSearch")))

Dim intIGID, bGroupByGroup, bGroupInfo
intIGID = Request("IGID")
If Not IsIDType(intIGID) Then
	intIGID = Null
End If

bGroupByGroup = Not g_bOnlySpecificInterests And Nl(intIGID) And Not bProfileSearch
bGroupInfo = Not (bProfileSearch Or Nl(intIGID))

If Not bProfileSearch Then
Call makePageHeader(TXT_AREA_OF_INTEREST_LIST, TXT_AREA_OF_INTEREST_LIST, False, False, True, False)
%>
<h1><%=TXT_AREA_OF_INTEREST_LIST%></h1>
<%
End If

Call openInterestListRst(intIGID, bGroupByGroup, bGroupInfo)

	If bGroupInfo Then
%>
<h4><%=TXT_YOU_SEARCHED_FOR & Server.HTMLEncode(strListGroupNames)%></h4>
<%
	End If
	
	With rsListInterest
		If Not .EOF Then
			If bGroupByGroup Then
				intIGID = vbNullString
			Else
%>
<ul id="interest_list">
<%
			End If
			While Not .EOF
				If bGroupByGroup Then
					If intIGID <> .Fields("IG_ID") Then
%>
	<%=StringIf(Not Nl(intIGID),"</ul>")%>
	<h4><%=Server.HTMLEncode(.Fields("GroupName"))%></h4>
	<ul id="interest_list_<%=.Fields("IG_ID")%>">
<%
						intIGID = .Fields("IG_ID")
					End If
				End If
%>
	<li class="InterestResult" <%If bProfileSearch Then%> data-id="<%=.Fields("AI_ID")%>" id="result_<%=.Fields("AI_ID")%>"<%End If%>>
		<%If bProfileSearch Then %><span class="source_interest_text"><%End If%>
		<%=Server.HTMLEncode(.Fields("InterestName"))%>
		<%If bProfileSearch Then %></span>
			<span class="interest_ui">
				<a class="btn btn-xs btn-info interest_add" href="#" id="interest_add_<%=.Fields("AI_ID")%>">
					<%=TXT_ADD%>
				</a>
				<span class="interest_added NotVisible" id="interest_added_<%=.Fields("AI_ID")%>">
					<img src="<%=ps_strRootPath%>images/greencheck.gif" alt=<%=AttrQs(TXT_ADDED)%>>
				</span>
			</span>
		<%End If%>
	</li>
<%
				.MoveNext
			Wend
%>
</ul>
<%			
		Else
%>
<p><%=TXT_NO_MATCHES%></p>
<%
		End If
	End With

Call closeInterestListRst()
%>
<%
If Not bProfileSearch Then
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
