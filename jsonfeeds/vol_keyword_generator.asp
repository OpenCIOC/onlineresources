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
Call setPageInfo(False, DM_VOL, DM_VOL, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<% 'End Base includes %>
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<%
Response.ContentType = "application/json"
Response.CacheControl = "no-cache"

Call run_response_callbacks()

Dim strSearch, _
	strSearchType, _
	strSQL, _
	strTaxNameField

strSearch = Left(Trim(Request("term")), 100)
strSearchType = Trim(Request("SearchType"))

Dim singleSTerms(), _
	quotedSTerms(), _
	exactSTerms(), _
	displaySTerms(), _
	strJoinedSTerms, _
	strJoinedQSTerms

If Not Nl(strSearch) Then
	Call makeSearchString( _
		strSearch & "*", _
		singleSTerms, _
		quotedSTerms, _
		exactSTerms, _
		displaySTerms, _
		False _
	)
	
	strJoinedSTerms = Join(singleSTerms,AND_CON)
	strJoinedQSTerms = Join(quotedSTerms,AND_CON)
End If

Dim i

If Nl(strSearch) Then
	Response.Write("[]")
Else
	If Nl(strJoinedSTerms) And Nl(strJoinedQSTerms) Then
		strSQL = Null
	Else
		strSQL = "DECLARE @searchStr varchar(max)" & vbCrLf & _
			"SET @searchStr = " & QsNl(strSearch & "%") & vbCrLf & _
			"SELECT TOP 20 LIST_VALUE, QUOTE FROM ("
		For i = 1 to 5
			strSQL = strSQL & vbCrLf & _
				StringIf(i > 1,"UNION ") & "SELECT ORG_LEVEL_" & i & " AS LIST_VALUE, CASE WHEN ORG_LEVEL_" & i & " LIKE @searchStr THEN 0 ELSE 1 END AS STARTS_WITH, CAST(1 AS bit) AS QUOTE" & vbCrLf & _
			"FROM VOL_Opportunity vo " & vbCrLf & _
			"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
			"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
			"WHERE "
				If Not Nl(strJoinedSTerms) Then
					strSQL = strSQL & vbCrLf & "CONTAINS(btd.ORG_LEVEL_" & i & ",'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
				End If
				If Not Nl(strJoinedQSTerms) Then
					strSQL = strSQL & vbCrLf & StringIf(Not Nl(strJoinedSTerms),AND_CON) & "CONTAINS(btd.ORG_LEVEL_" & i & ",'" & strJoinedQSTerms & "')"
				End If
			strSQL = strSQL & StringIf(Not Nl(g_strWhereClauseVOLNoDel), AND_CON & g_strWhereClauseVOLNoDel)
		Next
		strSQL = strSQL & vbCrLf & _
			"UNION SELECT LEGAL_ORG AS LIST_VALUE, CASE WHEN ORG_LEVEL_5 LIKE @searchStr THEN 0 ELSE 1 END AS STARTS_WITH, CAST(1 AS bit) AS QUOTE" & vbCrLf & _
			"FROM VOL_Opportunity vo " & vbCrLf & _
			"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
			"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
			"WHERE "
			If Not Nl(strJoinedSTerms) Then
				strSQL = strSQL & vbCrLf & "CONTAINS(btd.LEGAL_ORG,'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
			End If
			If Not Nl(strJoinedQSTerms) Then
				strSQL = strSQL & vbCrLf & StringIf(Not Nl(strJoinedSTerms),AND_CON) & "CONTAINS(btd.LEGAL_ORG,'" & strJoinedQSTerms & "')"
			End If					
		strSQL = strSQL & StringIf(Not Nl(g_strWhereClauseVOLNoDel), AND_CON & g_strWhereClauseVOLNoDel) & vbCrLf & _
				"UNION SELECT ALT_ORG COLLATE Latin1_General_100_CI_AI AS LIST_VALUE, CASE WHEN ALT_ORG LIKE @searchStr COLLATE Latin1_General_100_CI_AI THEN 0 ELSE 1 END AS STARTS_WITH, CAST(1 AS bit) AS QUOTE" & vbCrLf & _
				"FROM GBL_BT_ALTORG ao" & vbCrLf & _
				"INNER JOIN GBL_BaseTable bt ON ao.NUM=bt.NUM" & vbCrLf & _
				"INNER JOIN VOL_Opportunity vo ON bt.NUM=vo.NUM" & vbCrLf & _
				"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
				"WHERE ao.LangID=@@LANGID"
				If Not Nl(strJoinedSTerms) Then
					strSQL = strSQL & vbCrLf & " AND CONTAINS(ao.ALT_ORG,'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
				End If
				If Not Nl(strJoinedQSTerms) Then
					strSQL = strSQL & vbCrLf & " AND CONTAINS(ao.ALT_ORG,'" & strJoinedQSTerms & "')"
				End If
		strSQL = strSQL & StringIf(Not Nl(g_strWhereClauseVOLNoDel), AND_CON & g_strWhereClauseVOLNoDel) & vbCrLf & _
				"UNION SELECT FORMER_ORG COLLATE Latin1_General_100_CI_AI AS LIST_VALUE, CASE WHEN FORMER_ORG LIKE @searchStr COLLATE Latin1_General_100_CI_AI THEN 0 ELSE 1 END AS STARTS_WITH, CAST(1 AS bit) AS QUOTE" & vbCrLf & _
				"FROM GBL_BT_FORMERORG fo" & vbCrLf & _
				"INNER JOIN GBL_BaseTable bt ON fo.NUM=bt.NUM" & vbCrLf & _
				"INNER JOIN VOL_Opportunity vo ON bt.NUM=vo.NUM" & vbCrLf & _
				"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
				"WHERE fo.LangID=@@LANGID"
				If Not Nl(strJoinedSTerms) Then
					strSQL = strSQL & vbCrLf & " AND CONTAINS(fo.FORMER_ORG,'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
				End If
				If Not Nl(strJoinedQSTerms) Then
					strSQL = strSQL & vbCrLf & " AND CONTAINS(fo.FORMER_ORG,'" & strJoinedQSTerms & "')"
				End If
		strSQL = strSQL & StringIf(Not Nl(g_strWhereClauseVOLNoDel), AND_CON & g_strWhereClauseVOLNoDel)

		If strSearchType = "P" Then
			strSQL = strSQL & vbCrLf & _
				"UNION SELECT POSITION_TITLE AS LIST_VALUE, CASE WHEN POSITION_TITLE LIKE @searchStr THEN 0 ELSE 1 END AS STARTS_WITH, CAST(0 AS bit) AS QUOTE" & vbCrLf & _
				"FROM VOL_Opportunity vo " & vbCrLf & _
				"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
				"WHERE "
				If Not Nl(strJoinedSTerms) Then
					strSQL = strSQL & vbCrLf & "CONTAINS(vod.POSITION_TITLE,'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
				End If
				If Not Nl(strJoinedQSTerms) Then
					strSQL = strSQL & vbCrLf & StringIf(Not Nl(strJoinedSTerms),AND_CON) & "CONTAINS(vod.POSITION_TITLE,'" & strJoinedQSTerms & "')"
				End If
			strSQL = strSQL & StringIf(Not Nl(g_strWhereClauseVOLNoDel), AND_CON & g_strWhereClauseVOLNoDel) & vbCrLf & _
				"UNION SELECT ain.[Name] AS LIST_VALUE, CASE WHEN ain.[Name] LIKE @searchStr THEN 0 ELSE 1 END AS STARTS_WITH, CAST(0 AS bit) AS QUOTE" & vbCrLf & _
				"FROM VOL_Interest_Name ain" & vbCrLf & _
				"WHERE ain.LangID=@@LANGID"
				If Not Nl(strJoinedSTerms) Then
					strSQL = strSQL & vbCrLf & " AND CONTAINS(ain.Name,'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
				End If
				If Not Nl(strJoinedQSTerms) Then
					strSQL = strSQL & vbCrLf & " AND CONTAINS(ain.Name,'" & strJoinedQSTerms & "')"
				End If
			strSQL = strSQL & AND_CON & _
					"EXISTS(SELECT * FROM VOL_OP_AI pr" & vbCrLf & _
					"INNER JOIN VOL_Opportunity vo ON pr.VNUM=vo.VNUM" & vbCrLf & _
					"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
					"WHERE pr.AI_ID=ain.AI_ID" & _
					StringIf(Not Nl(g_strWhereClauseVOLNoDel), AND_CON & g_strWhereClauseVOLNoDel) & ")"
		End If

		strSQL = strSQL & vbCrLf & _
				") x" & vbCrLf & _
				"ORDER BY STARTS_WITH, LIST_VALUE"
	End If
End If

If Not Nl(strSQL) Then
	'Response.Write(strSQL)
	'Response.Flush()
	
	Dim cmdKeywordGen, rsKeywordGen
	Set cmdKeywordGen = Server.CreateObject("ADODB.Command")
	With cmdKeywordGen
		.ActiveConnection = getCurrentBasicCnn()
		.CommandText = strSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
	Set rsKeywordGen = Server.CreateObject("ADODB.Recordset")
	With rsKeywordGen
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdKeywordGen

		Dim strJSONCon
		strJSONCon = vbNullString
		Response.Write("[")

		While Not .EOF
			Response.Write(strJSONCon & "{" & _
					"""value"":" & JSONQs(.Fields("LIST_VALUE"), True) & _
					",""label"":" & JSONQs(.Fields("LIST_VALUE"), True) & _
					",""quote"":" & IIf(.Fields("QUOTE") = 0, "false", "true") & _
					"}")
			strJSONCon = ","
			.MoveNext
		Wend
		Response.Write("]")

		.Close
	End With
	
	Set rsKeywordGen = Nothing
	Set cmdKeywordGen = Nothing
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
