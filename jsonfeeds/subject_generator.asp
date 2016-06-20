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
Call setPageInfo(False, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<% 'End Base includes %>
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<%
Response.ContentType = "application/json"
Response.CacheControl = "no-cache"

Call run_response_callbacks()

Dim strSearch,bAll,intSkipSubj
strSearch = Left(Trim(Request("term")),100)
bAll = not Nl(Trim(Request("ShowAll")))
intSkipSubj = Left(Trim(Request("SkipSubj")), 20)

If IsIDType(intSkipSubj) Then
intSkipSubj = CInt(intSkipSubj)
Else
intSkipSubj = vbNullString
End If


If Nl(strSearch) Then
	Response.Write("[]")
Else
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
	
	If Nl(strJoinedSTerms) And Nl(strJoinedQSTerms) Then
		Response.Write("[]")
	Else
		Dim strSQL
		strSQL = "DECLARE @searchStr varchar(max)" & vbCrLf & _
			"SET @searchStr = " & QsNl(strSearch & "%") & vbCrLf & _
			"SELECT TOP 20 sj.Subj_ID, sjn.Name AS LIST_VALUE FROM THS_Subject sj INNER JOIN THS_Subject_Name sjn ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=@@LANGID" & vbCrLf & _
			"WHERE "
		If Not Nl(strJoinedSTerms) Then
			strSQL = strSQL & vbCrLf & " CONTAINS(sjn.Name,'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
		End If
		If Not Nl(strJoinedQSTerms) Then
			strSQL = strSQL & vbCrLf & StringIf(Not Nl(strJoinedSTerms), " AND ") & " CONTAINS(sjn.Name,'" & strJoinedQSTerms & "')"
		End If
		strSQL = strSQL & StringIf(Not bAll, " AND (sj.Authorized=1 OR sj.MemberID IS NULL OR sj.MemberID=" & g_intMemberID & ") AND NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=" & g_intMemberID & " AND Subj_ID=sj.Subj_ID) AND Used=1") & _
				StringIf(not Nl(intSkipSubj), " AND sj.Subj_ID<>" & intSkipSubj) & vbCrLf & _
			"ORDER BY CASE WHEN sjn.Name LIKE @searchStr THEN 0 ELSE 1 END, sjn.Name"
		
		'Response.Write("<pre>" & strSQL & "</pre>")
		'Response.Flush()

		Dim cmdSubjFinder, rsSubjFinder
		Set cmdSubjFinder = Server.CreateObject("ADODB.Command")
		With cmdSubjFinder
			.ActiveConnection = getCurrentCICBasicCnn()
			.CommandText = strSQL
			.CommandType = adCmdText
			.CommandTimeout = 0
		End With
		Set rsSubjFinder = Server.CreateObject("ADODB.Recordset")
		With rsSubjFinder
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdSubjFinder
	
			Dim strJSONCon
			strJSONCon = vbNullString
			Response.Write("[")
	
			While Not .EOF
				Response.Write(strJSONCon & "{""chkid"":" & JSONQs(.Fields("Subj_ID"), True) & _ 
						",""value"":" & JSONQs(.Fields("LIST_VALUE"), True) & _
						"}")
				strJSONCon = ","
				.MoveNext
			Wend
			Response.Write("]")
	
			.Close
		End With
		
		Set rsSubjFinder = Nothing
		Set cmdSubjFinder = Nothing
	End If
End If
%>
<!--#include file="../includes/core/incClose.asp" -->

