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
<!--#include file="../text/txtBrowse.asp" -->
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../includes/list/incAlphaList.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<% 
Dim bInlineMode
bInlineMode = Not Nl(Trim(Request("InlineMode")))

If Not bInlineMode Then
Call makePageHeader(Nz(ps_strTitle,TXT_BROWSE_ORG_W_OPS), Nz(ps_strTitle,TXT_BROWSE_ORG_W_OPS), True, True, False, True)
End If

Dim strChosenLetter, strLettersList
strChosenLetter = Trim(Request("Let"))

If Not reEquals(strChosenLetter,"([A-Z])|(0\-9)",True,False,True,False) Then
	strChosenLetter = vbNullString
End If

If Not (bInlineMode And Nl(strChosenLetter)) Then
strLettersList = makeAlphaList(strChosenLetter, True, ps_strThisPage, True)
%>
<%=strLettersList%>
<hr>
<%
End If
Dim cmdOrg, rsOrg, rsOrgCount
Set cmdOrg = Server.CreateObject("ADODB.Command")
With cmdOrg
	.ActiveConnection = getCurrentVOLBasicCnn()
	.CommandText = "dbo.sp_VOL_BrowseByOrg"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@Letter", adVarChar, adParamInput, 3, strChosenLetter)		
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
End With

Set rsOrg = Server.CreateObject("ADODB.Recordset")
With rsOrg
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdOrg
End With

If Not bInlineMode Then
%>
<p><%=TXT_FOUND%><strong><%=rsOrg.RecordCount%></strong><%=TXT_MATCHES%>.</p>
<%
End If
%>
<ul class="no-bullet-list" id="browse_by_org_list">
<%
With rsOrg
	While Not .EOF
%>
	<li><a style="font-weight:bold;" href="<%=makeLink("results.asp","NUM=" & rsOrg("NUM"),vbNullString)%>"><%=.Fields("ORG_NAME_FULL")%></a> <span class="badge"><%=rsOrg("OpCount")%></span></li>
	<%
		.MoveNext
	Wend
End With
%>
</ul>
<%
If Not bInlineMode Then
Call makePageFooter(True)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
