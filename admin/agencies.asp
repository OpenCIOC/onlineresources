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
' Purpose:		List agencies to edit, add new agency
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
<!--#include file="../text/txtAgency.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incAgencyList.asp" -->

<%
If Not user_bSuperUser Then
	Call securityFailure()
End If
%>
<%
Call makePageHeader(TXT_MANAGE_AGENCIES, TXT_MANAGE_AGENCIES, True, False, True, True)
%>
<h2><%=TXT_EDIT_AGENCIES%></h2>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> 
| <a href="agencies_edit.asp"><%=TXT_ADD_NEW_AGENCY%></a> ]</p>
<%
Call openAgencyAdminListRst()
With rsListAgency
	If .RecordCount = 0 Then
		%><p class="Alert"><%= TXT_THERE_ARE_NO_AGENCIES %></p><%
	Else
%>
<table class="BasicBorder cell-padding-4 max-width-lg">
	<thead>
	<tr>
		<th class="RevTitleBox"><%=TXT_CODE%></th>
		<th class="RevTitleBox"><%=TXT_ORG_NAMES%></th>
		<th class="RevTitleBox"><%=TXT_USERS%></th>
		<th class="RevTitleBox"><%=TXT_USAGE & " - " & TXT_CIC%></th>
<%
		If g_bUseVOL Then
%>
		<th class="RevTitleBox"><%=TXT_USAGE & " - " & TXT_VOLUNTEER%></th>
<%
		End If
%>
		<th class="RevTitleBox"><%=TXT_ACTION%></th>
	</tr>
	</thead>
	<tbody class="alternating-highlight">
<%
		.MoveFirst
		While Not .EOF
%>
	<tr>
		<td><%=.Fields("AgencyCode")%></td>
		<td><%=.Fields("ORG_NAME_FULL")%></td>
		<td><%=.Fields("UserCount")%></td>
		<td><%=.Fields("CICRecordCount")%> <%If .Fields("CICRecordCountDel")>0 Then%> <em>(+ <%=.Fields("CICRecordCountDel") & " " & TXT_DELETED%>)</em><%End If%></td>
<%
			If g_bUseVOL Then
%>
		<td><%=.Fields("VOLRecordCount")%> <%If .Fields("VOLRecordCountDel")>0 Then%> <em>(+ <%=.Fields("VOLRecordCountDel") & " " & TXT_DELETED%>)</em><%End If%></td>
<%
			End If
%>
		<td><a href="<%=makeLink("agencies_edit.asp","AgencyID=" & .Fields("AgencyID"),vbNullString)%>"><%=TXT_UPDATE%></a></td>
	</tr>
<%
			.MoveNext
		Wend
%>
	</tbody>
</table>
<%
	End If
End With

If g_bOtherMembers Then

Set rsListAgency = rsListAgency.NextRecordset

With rsListAgency
	If .RecordCount > 0 Then
%>
<h2><%=TXT_EDIT_AGENCIES & TXT_COLON & TXT_OTHER_MEMBERS%></h2>
<form action="agencies_others.asp" method="post">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-4 max-width-lg">
	<tr>
		<th class="RevTitleBox"><%=TXT_CODE%></th>
		<th class="RevTitleBox"><%=TXT_ORG_NAMES%></th>
		<th class="RevTitleBox"><%=TXT_MEMBERSHIP%></th>
		<th class="RevTitleBox"><%=TXT_SHOW_ON_FORMS%></th>
<% If user_bSuperUserGlobal Then %>
		<th class="RevTitleBox"><%=TXT_ACTION%></th>
<% End If %>
	</tr>
<%
		.MoveFirst
		While Not .EOF
%>
	<tr>
		<td><%=.Fields("AgencyCode")%></td>
		<td><%=.Fields("ORG_NAME_FULL")%></td>
		<td<%=StringIf(Not .Fields("Active")," style=""text-decoration:line-through""")%>><%=Nz(.Fields("MemberName"),TXT_UNKNOWN)%></td>
		<td style="text-align:center"><input name="ShowForeignAgency" title="<%=.Fields("AgencyCode") & TXT_COLON & TXT_SHOW_ON_FORMS%>" type="checkbox"<%=Checked(.Fields("ShowForeignAgency"))%> value="<%= .Fields("AgencyID") %>"></td>
<% If user_bSuperUserGlobal Then %>
		<td><a href="<%=makeLink("agencies_edit.asp","AgencyID=" & .Fields("AgencyID"),vbNullString)%>"><%=TXT_UPDATE%></a></td>
<% End If %>
	</tr>
<%
			.MoveNext
		Wend
%>
</table>
<input type="submit" value="<%= TXT_UPDATE %>">
</form>
<%
	End If
End With

End If

Call closeAgencyListRst()

Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
