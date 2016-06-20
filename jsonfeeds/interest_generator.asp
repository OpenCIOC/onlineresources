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
<% 'End Base includes %>
<!--#include file="../text/txtFinder.asp" -->
<!--#include file="../includes/list/incInterestList.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<%
Response.ContentType = "application/json"
Response.CacheControl = "no-cache"

Call run_response_callbacks()

Dim intIGID
intIGID = Request("IGID")

Dim strSearch, bShowAll
strSearch = Left(Trim(Request("term")),100)
bShowAll = Request("ShowAll") = "on"

If Nl(intIGID) And Nl(strSearch) And Not bShowAll Then
	Response.Write("[]")
Else
	If bShowAll Then
		Call openInterestListRstCountInView()
	ElseIf Not Nl(intIGID) Then
		Call openInterestListRst(intIGID, False)
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
	
		Dim strSQL
		
		If Nl(strJoinedSTerms) And Nl(strJoinedQSTerms) Then
			strSQL = Null
		Else
			strSQL = "DECLARE @searchStr varchar(max)" & vbCrLf & _
				"SET @searchStr = " & QsNl(strSearch & "%") & vbCrLf & _
				"SELECT TOP 20 ai.AI_ID, ai.[Name] AS LIST_VALUE, CASE WHEN ai.[Name] LIKE @searchStr THEN 0 ELSE 1 END AS STARTS_WITH FROM VOL_Interest_Name ai WHERE ai.LangID=@@LANGID AND NOT EXISTS(SELECT * FROM VOL_Interest_InactiveByMember WHERE ai.AI_ID=AI_ID AND MemberID=" & g_intMemberID & ") AND "
			If Not Nl(strJoinedSTerms) Then
				strSQL = strSQL & vbCrLf & "CONTAINS(ai.Name,'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')"
			End If
			If Not Nl(strJoinedQSTerms) Then
				strSQL = strSQL & vbCrLf & StringIf(Not Nl(strJoinedSTerms),AND_CON) & "CONTAINS(ai.Name,'" & strJoinedQSTerms & "')"
			End If
			strSQL = strSQL & vbCrLf & _
				"ORDER BY CASE WHEN ai.Name LIKE @searchStr THEN 0 ELSE 1 END, ai.Name"
		End If
		
		Set cmdListInterest = Server.CreateObject("ADODB.Command")
		With cmdListInterest
			.ActiveConnection = getCurrentVOLBasicCnn()
			.CommandText = strSQL
			.CommandType = adCmdText
			.CommandTimeout = 0
		End With
		Set rsListInterest = Server.CreateObject("ADODB.Recordset")
		With rsListInterest
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdListInterest
		End With
	End If
	
	With rsListInterest
		If .EOF Then
			Response.Write("[]")
		Else
			Dim strJSONCon
			strJSONCon = vbNullString
			
			Response.Write("[")

			While Not .EOF
				Response.Write(strJSONCon & "{""chkid"":" & JSONQs(.Fields("AI_ID"), True) & _ 
						",""value"":" & JSONQs(.Fields(IIf(Not Nl(intIGID) or bShowAll,"InterestName","LIST_VALUE")), True))
				If bShowAll Then
					Response.Write(",""count"":" & JSONQs(.Fields("NumOpps"),True))
				End If
				Response.Write("}")
				strJSONCon = ","
				.MoveNext
			Wend
			Response.Write("]")
		End If
	End With

	Call closeInterestListRst()
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
