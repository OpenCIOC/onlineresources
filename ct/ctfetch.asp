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
' Purpose:		Generate XML File for Record Info Request from Client Tracker
'				Conforms to Client Tracker Schema resourceinfo.xsd
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
<!--#include file="../includes/core/incFormat.asp" -->

<%
'Set response type headers
Response.ContentType = "application/xml"
Response.CacheControl = "Private"
Response.Expires=-1
%>
<%
Dim strNUM
strNUM = UCase(Request("num"))

Call run_response_callbacks()

If Not ctClientCanMakeRequest() Then
%>
<response xmlns="https://clienttracker.cioc.ca/schema/">
	<error><%=TXT_CT_ACCESS_DENIED%></error>
</response>
<%
ElseIf Nl(strNUM) Then
%>
<response xmlns="https://clienttracker.cioc.ca/schema/">
	<error><%=TXT_NO_RECORD_CHOSEN%></error>
</response>
<%
ElseIf Not reEquals(strNUM,"([A-Z]){3}([0-9]){4,5}",False,False,True,False) Then
%>
<response xmlns="https://clienttracker.cioc.ca/schema/">
	<error><%=TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strNUM)%></error>
</response>
<%
Else

Dim cmdOrg, rsOrg
Set cmdOrg = Server.CreateObject("ADODB.Command")
With cmdOrg
	.ActiveConnection = getCurrentCICBasicCnn()
	.CommandType = adCmdText
	.CommandText = "SELECT bt.NUM," & _
		"dbo.fn_GBL_DisplayFullOrgName_2(btd.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL" & vbCrLf & _
		"FROM GBL_BaseTable bt" & vbCrLf & _
		"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
		"WHERE bt.NUM=" & QsNl(strNUM)
	.CommandTimeout = 0
	Set rsOrg = .Execute
End With

If Not rsOrg.EOF Then
%>
<response xmlns="https://clienttracker.cioc.ca/schema/">
	<resourceInfo>
		<id><%=strNUM%></id>
		<name><%=XMLEncode(rsOrg.Fields("ORG_NAME_FULL"))%></name>
		<url><%=XMLEncode(IIf(g_bSSL, "https://", "http://") & Request.ServerVariables("HTTP_HOST") & Left(Request.ServerVariables("PATH_INFO"),Len(Request.ServerVariables("PATH_INFO"))-Len(ps_strThisPageFull)) & makeDetailsLink(strNUM,vbNullString,vbNullString))%></url>
	</resourceInfo>
</response>
<%
Else
%>
<response xmlns="https://clienttracker.cioc.ca/schema/">
	<error><%=TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strNUM)%></error>
</response>
<%
End If

End If
%>

<!--#include file="../includes/core/incClose.asp" -->
