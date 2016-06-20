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
Call setPageInfo(True, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtLowestNUM.asp" -->
<!--#include file="includes/core/incFormat.asp" -->

<%
Call makePageHeader(TXT_LOWEST_UNUSED, TXT_LOWEST_UNUSED, False, False, True, False)
%>
<h3><%=TXT_LOWEST_UNUSED%></h3>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox"><%=TXT_AGENCY%></th>
	<th class="RevTitleBox"><%=TXT_RECORD_NUM%></th>
</tr>
<%
	Dim cmdLowestNUM, rsLowestNUM
	Set cmdLowestNUM = Server.CreateObject("ADODB.Command")
	With cmdLowestNUM
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_Agency_LowestNUM_l"
		.CommandType = adCmdStoredProc
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.CommandTimeout = 0
		Set rsLowestNUM = .Execute
	End With
	With rsLowestNUM
		While Not .EOF
%>
<tr>
	<td><%=.Fields("AgencyCode") & " - " & StringIf(Not Nl(.Fields("ORG_NAME_FULL"))," - " & .Fields("ORG_NAME_FULL"))%></td>
	<td><%=.Fields("LowestNUM")%></td>
</tr>
<%
			.MoveNext
		Wend
	
	End With
%>
</table>
<%
Call makePageFooter(False)
%>

<!--#include file="includes/core/incClose.asp" -->
