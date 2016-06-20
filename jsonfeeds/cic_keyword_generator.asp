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
Response.CacheControl = "private"
Call Response.AddHeader("Access-Control-Allow-Origin", "*")

Call run_response_callbacks()

Dim strSearch, _
	strSearchType, _
	strSQL

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

If Nl(strSearch) Or (Nl(strJoinedSTerms) And Nl(strJoinedQSTerms)) Or (strSearchType <> "O" And strSearchType <> "S" And strSearchType <> "A" And strSearchType <> "T") Then
	Response.Write("[]")
Else
	strSQL =  _
	"DECLARE @MemberID int = ?," & vbCrLf & _
	"@SearchStr varchar(4000) = ?," & vbCrLf & _
	"@KeywordType char(1) = ?," & vbCrLf & _
	"@FormsOf nvarchar(4000) = ?," & vbCrLf & _
	"@Contains nvarchar(500) = ?," & vbCrLf & _
	"@ViewType int = ?," & vbCrLf & _
	"@CanSeeNonPublic bit = ?," & vbCrLf & _
	"@PB_ID int = ?" & vbCrLf & _
	"SET NOCOUNT ON" & vbCrLf & _
	"DECLARE @Language varchar(100)" & vbCrLf & _
	"SELECT @Language=LanguageAlias FROM dbo.STP_Language WHERE LangID=@@LANGID" & vbCrLf & _
	"SELECT TOP 20 LIST_VALUE, QUOTE" & vbCrLf & _
	"FROM (" & vbCrLf & _
	"SELECT DISTINCT" & vbCrLf & _
	"	Name AS LIST_VALUE," & vbCrLf & _
	"	CASE WHEN Name LIKE @searchStr THEN 0 ELSE 1 END AS STARTS_WITH," & vbCrLf & _
	"	CAST(MIN(CASE WHEN ky.KeywordType='O' THEN 1 ELSE 0 END) AS bit) AS QUOTE" & vbCrLf & _
	"FROM GBL_Keywords ky" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable bt" & vbCrLf & _
	"	ON bt.NUM = ky.NUM" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd" & vbCrLf & _
	"	ON btd.NUM = bt.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
	"WHERE " & vbCrLf 
	If Not Nl(strJoinedSTerms) Then
		strSQL = strSQL & "	CONTAINS(Name,@FormsOf,LANGUAGE @Language) AND " & vbCrLf
	End If
	If Not Nl(strJoinedQSTerms) Then
		strSQL = strSQL & "	CONTAINS(Name,@Contains) AND " & vbCrLf
	End If
	strSQL = strSQL & _
	"	ky.LangID=@@LANGID" & vbCrLf & _
	"	AND (@KeywordType IS NULL OR ky.KeywordType=@KeywordType)" & vbCrLf & _
	"	AND (" & vbCrLf & _
	"		ky.NUM IS NULL" & vbCrLf & _
	"		OR (" & vbCrLf & _
	"			(@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))" & vbCrLf & _
	"			AND (bt.MemberID=@MemberID" & vbCrLf & _
	"					OR EXISTS(SELECT *" & vbCrLf & _
	"						FROM GBL_BT_SharingProfile pr" & vbCrLf & _
	"						INNER JOIN GBL_SharingProfile shp" & vbCrLf & _
	"							ON pr.ProfileID=shp.ProfileID" & vbCrLf & _
	"								AND shp.Active=1" & vbCrLf & _
	"								AND (" & vbCrLf & _
	"									shp.CanUseAnyView=1" & vbCrLf & _
	"									OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)" & vbCrLf & _
	"								)" & vbCrLf & _
	"						WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)" & vbCrLf & _
	"				)" & vbCrLf & _
	"			AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)" & vbCrLf & _
	"		)" & vbCrLf & _
	"	)" & vbCrLf & _
	"GROUP BY Name " & _
	") x" & vbCrLf & _
	"ORDER BY STARTS_WITH, LIST_VALUE"
	
	'Response.Write(strSQL)
	'Response.Flush

	Dim cmdKeywordGen, rsKeywordGen
	Set cmdKeywordGen = Server.CreateObject("ADODB.Command")
	With cmdKeywordGen
		.ActiveConnection = getCurrentBasicCnn()
		.CommandText = strSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@SearchString", adVarWChar, adParamInput, 255, strSearch & "%")
		.Parameters.Append .CreateParameter("@KeywordType", adChar, adParamInput, 1, IIf(strSearchType = "A", Null, strSearchType))
		.Parameters.Append .CreateParameter("@FormsOf", adVarWChar, adParamInput, 4000, NlNl(strJoinedSTerms))
		.Parameters.Append .CreateParameter("@Contains", adVarWChar, adParamInput, 500, NlNl(strJoinedQSTerms))
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@CanSeeNonPublic", adBoolean, adParamInput, 1, g_bCanSeeNonPublicCIC)
		.Parameters.Append .CreateParameter("@PB_ID", adInteger, adParamInput, 4, g_intPBID)
	End With
	Set rsKeywordGen = Server.CreateObject("ADODB.Recordset")
	With rsKeywordGen
		.CursorLocation = adUseClient
		.CursorType = adOpenForwardOnly
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
