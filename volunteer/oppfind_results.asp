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
Call setPageInfo(False, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtFinder.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<%
Call makePageHeader(TXT_OPP_FINDER, TXT_OPP_FINDER, False, False, True, False)
%>
<h1><%=TXT_OPP_SEARCH_RESULTS%></h1>
<%
'On Error Resume Next

Dim strSTerms
strSTerms = Trim(Request("OppSrch"))

Dim strJoinedSTerms, _
	strJoinedQSTerms, _
	strDisplaySTerms, _
	singleSTerms(), _
	quotedSTerms(), _
	exactSTerms(), _
	displaySTerms()

If Not Nl(strSTerms) Then
	Call makeSearchString( _
		strSTerms, _
		singleSTerms, _
		quotedSTerms, _
		exactSTerms, _
		displaySTerms, _
		False _
	)
	strJoinedSTerms = Join(singleSTerms,AND_CON)
	strJoinedQSTerms = Join(quotedSTerms,AND_CON)
	strDisplaySTerms = Join(displaySTerms," " & TXT_AND & " ")
Else
	ReDim singleSTerms(-1)
	ReDim quotedSTerms(-1)
	ReDim exactSTerms(-1)
End If

If Nl(strJoinedSTerms) And Nl(strJoinedQSTerms) Then
%>
<p><%=TXT_NOTHING_TO_SEARCH%></p>
<%
Else
	Dim strSQL, _
		strAlertColumn
		
	strSQL = "SELECT vo.VNUM, vod.POSITION_TITLE, bt.NUM," & _
		"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL"
	
	strSQL = strSQL & " FROM VOL_Opportunity vo " & vbCrLf & _
		"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM = vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
		"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
		"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf & _
		"WHERE ("
	
	If Not Nl(strJoinedSTerms) Then
		strSQL = strSQL & "CONTAINS(vod.POSITION_TITLE,'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')" & vbCrLf	
	End If
	If Not Nl(strJoinedQSTerms) Then
		strSQL = strSQL & StringIf(Not Nl(strJoinedSTerms),AND_CON) & "CONTAINS(vod.POSITION_TITLE,'" & strJoinedQSTerms & "')" & vbCrLf	
	End If
	
	strSQL = strSQL & ") OR ("
		If Not Nl(strJoinedSTerms) Then
			strSQL = strSQL & "CONTAINS(btd.SRCH_Org,'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')" & vbCrLf	
		End If
		If Not Nl(strJoinedQSTerms) Then
			strSQL = strSQL & StringIf(Not Nl(strJoinedSTerms),AND_CON) & "CONTAINS(btd.SRCH_Org,'" & strJoinedQSTerms & "')" & vbCrLf	
		End If
	strSQL = strSQL & ")"

	strSQL = strSQL & IIf(Not Nl(g_strWhereClauseCIC), AND_CON & g_strWhereClauseCIC & vbCrLf, vbNullString) & _
		"ORDER BY POSITION_TITLE," & _
		"ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5," & vbCrLf & _
		"	STUFF(" & vbCrLf & _
		"		CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)" & vbCrLf & _
		"			THEN NULL" & vbCrLf & _
		"			ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +" & vbCrLf & _
		"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +" & vbCrLf & _
		"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')" & vbCrLf & _
		"			 END," & vbCrLf & _
		"		1, 2, ''" & vbCrLf & _
		"	)"
	
	'Response.Write("<pre>" & strSQL & "</pre>")
	'Response.Flush()

	Dim cmdOrgFinder, rsOrgFinder
	Set cmdOrgFinder = Server.CreateObject("ADODB.Command")
	With cmdOrgFinder
		.ActiveConnection = getCurrentBasicCnn()
		.CommandText = strSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
	Set rsOrgFinder = Server.CreateObject("ADODB.Recordset")
	With rsOrgFinder
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdOrgFinder
		If Err.Number <> 0 Then
			Call handleError(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
		Else
%>
<p><%=TXT_YOUR_SEARCH%> <em><%=strDisplaySTerms%></em> <%=TXT_HAS_FOUND%> <%=rsOrgFinder.RecordCount%> <%=TXT_RESULTS%>.</p>
<%
			If Not .EOF Then
%>
<table class="BasicBorder cell-padding-2">
<tr>
	<th class="RevTitleBox"><%=TXT_ID%></th>
	<th class="RevTitleBox"><%=TXT_POSITION_TITLE%></th>
	<th class="RevTitleBox"><%=TXT_NAME%></th>
</tr>
<%
				While Not .EOF

%>
<tr>
	<td class="NoWrap"><%=.Fields("VNUM")%></td>
	<td><%=.Fields("POSITION_TITLE")%></td>
	<td><%=.Fields("ORG_NAME_FULL")%></td>
</tr>
<%
					.MoveNext
				Wend
%>
</table>
<%
			End If
		End If
		.Close
	End With
	
	Set rsOrgFinder = Nothing
	Set cmdOrgFinder = Nothing
End If
%>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
