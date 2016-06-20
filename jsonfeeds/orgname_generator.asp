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
<% 'End Base includes %>
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<%
Response.ContentType = "application/json"
Response.CacheControl = "no-cache"

Call run_response_callbacks()

Dim strSearch

strSearch = Left(Trim(Request("term")), 100)

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

If Nl(strSearch) Then
	Response.Write("[]")
Else
	Dim strSQL, strWhere, strField, strVal
	strWhere = "btd.LangID=@@LANGID"

	Dim field


	For Each field in Array("ORG_LEVEL_1", "ORG_LEVEL_2", "ORG_LEVEL_3", "ORG_LEVEL_4", "ORG_LEVEL_5", "SERVICE_NAME_LEVEL_1", "ORG_NUM")
		strVal = Left(Trim(Request(field)),100)
		If Not Nl(strVal) Then
			If field <> "ORG_NUM" Then
				strWhere = strWhere & " AND " & field & "=" & QsNl(strVal)
			Else
				strWhere = strWhere & " AND ISNULL(ORG_NUM, bt.NUM) =" & QsNl(Nz(strVal, Left(Trim(Request("NUM")),8)))
			End If
		ElseIf Nl(strField) Then
			strField = field
			If Not Nl(strJoinedSTerms) Then
				strWhere = strWhere & vbCrLf & "AND CONTAINS(btd." & field & ",'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
			End If
			If Not Nl(strJoinedQSTerms) Then
				strWhere = strWhere & vbCrLf & "AND CONTAINS(btd." & field & ",'" & strJoinedQSTerms & "')"
			End If
		End If
	Next
	
	strSQL = "SELECT DISTINCT " & strField & " FROM GBL_BaseTable bt INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM WHERE " & strWhere & vbCrLf & _
		StringIf(Not Nl(g_strWhereClauseCICNoDel), AND_CON & g_strWhereClauseCICNoDel & vbCrLf) & _
		"ORDER BY " & strField

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

		Dim strJSONCon
		strJSONCon = vbNullString
		Response.Write("[")

		While Not .EOF
			Response.Write(strJSONCon & "{" & _
					"""value"":" & JSONQs(.Fields(strField), True) & _
					",""label"":" & JSONQs(.Fields(strField), True) & _
					"}")
			strJSONCon = ","
			.MoveNext
		Wend
		Response.Write("]")

		.Close
	End With
	
	Set rsOrgFinder = Nothing
	Set cmdOrgFinder = Nothing
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
