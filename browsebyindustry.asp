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
<!--#include file="text/txtBrowse.asp" -->
<!--#include file="text/txtFinder.asp" -->
<!--#include file="text/txtGeneralSearch1.asp" -->
<!--#include file="text/txtNAICS.asp" -->
<!--#include file="includes/naics/incNAICSCodeType.asp" -->
<!--#include file="includes/naics/incNAICSSearchUtils.asp" -->
<% 
If Not g_bUseNAICSView Then
	Call goToPageB("~/")
End If

Dim bInlineMode
bInlineMode = Not Nl(Trim(Request("InlineMode")))

If Not bInlineMode Then
Call makePageHeader(Nz(ps_strTitle,TXT_INDUSTRY_SEARCH), Nz(ps_strTitle,TXT_INDUSTRY_SEARCH), True, True, False, True)
End If

Dim strStatsCanNAICSLink
Select Case g_objCurrentLang.Culture
	Case CULTURE_FRENCH_CANADIAN
		strStatsCanNAICSLink = "http://www.statcan.gc.ca/subjects-sujets/standard-norme/naics-scian/2002/naics-scian-02intro-fra.htm"
	Case Else
		strStatsCanNAICSLink = "http://www.statcan.gc.ca/subjects-sujets/standard-norme/naics-scian/2002/naics-scian-02intro-eng.htm"
End Select
Dim strChosenCode
strChosenCode = Request("NAICS")
If Nl(strChosenCode) Then
	strChosenCode = Null
ElseIf Len(strChosenCode) > 6 Then
	Call handleError(TXT_INVALID_CODE, _
		vbNullString, _
		vbNullString)
	Call makePageFooter(False)
	%><!--#include file="../includes/core/incClose.asp" --><%
	Response.End()
End If

Dim dispSubjTerm
Dim cmdNAICS, rsNAICS, rsNAICSCount
Set cmdNAICS = Server.CreateObject("ADODB.Command")
With cmdNAICS
	.ActiveConnection = getCurrentCICBasicCnn()
	.CommandText = "dbo.sp_CIC_BrowseByIndustry"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 6, strChosenCode)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 1, g_intViewTypeCIC)
End With

Set rsNAICS = Server.CreateObject("ADODB.Recordset")
With rsNAICS
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdNAICS
End With

%>
<h3><%=TXT_BROWSE_BUSINESS_USING%> <a href="<%=strStatsCanNAICSLink%>"><%=TXT_NAICS%></a></h3>
<p><%=TXT_INST_INDUSTRY_SEARCH%> <strong><a href="javascript:openWin('<%=makeLinkB("naicsfind.asp")%>','sFind')"><%=TXT_NAICS_FINDER%></a></strong></p>
<p><%=TXT_FOUND%><strong><%=rsNAICS.RecordCount%></strong><%=TXT_MATCHES%>. <%If Not Nl(strChosenCode) Then%>[ <a href="<%=makeLinkB("browsebyindustry.asp")%>"><%=TXT_RETURN_TO_TOP_LEVEL%></a>&nbsp;|&nbsp;<a href="<%=makeLink("browsebyindustry.asp","NAICS=" & IIf(Len(strChosenCode)>NAICS_SECTOR,Left(strChosenCode,Len(strChosenCode)-1),vbNullString),vbNullString)%>"><%=TXT_UP_ONE_LEVEL%></a>&nbsp;]<%End If%></p>
<table class="BasicBorder cell-padding-2">
<%
With rsNAICS
	While Not .EOF
		Response.Write(getBrowseNAICSInfo(rsNAICS("Code"), rsNAICS("Classification"), rsNAICS("UsageCount")))
		.MoveNext
	Wend
	.Close
End With

Set rsNAICS = Nothing
Set cmdNAICS = Nothing
%>
</table>
<br>
<p class="SmallNote"><%=TXT_NAICS_USE_FOOTER%></p>
<%
If Not bInlineMode Then
Call makePageFooter(True)
End If
%>
<!--#include file="includes/core/incClose.asp" -->

