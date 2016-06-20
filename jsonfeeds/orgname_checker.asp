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

Dim singleSTerms(), _
	quotedSTerms(), _
	exactSTerms(), _
	displaySTerms(), _
	strJoinedSTerms, _
	strJoinedQSTerms

Dim strSQL, strWhere, strField, strVal, strNUM
strWhere = "btd.LangID=@@LANGID"
strNUM = Left(Trim(Request("NUM")), 8)

Dim field

If Request.QueryString("OLS_ID").Count = 0 Then
For Each field in Array("ORG_LEVEL_1", "ORG_LEVEL_2", "ORG_LEVEL_3", "ORG_LEVEL_4", "ORG_LEVEL_5")
	strVal = Left(Trim(Request(field)),100)
	If Not Nl(strVal) Then
		strWhere = strWhere & " AND " & field & "=" & QsNl(strVal)
	ElseIf Nl(strField) Then
		strWhere = strWhere & " AND " & field & " IS NULL"
	End If
Next

If Not Nl(strNUM) Then
	strWhere = strWhere & " AND bt.NUM <> " & QsNl(strNUM)
End If

strSQL = "SELECT 'AGENCY' AS CODE, COUNT(*) AS CNT FROM GBL_BaseTable bt INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM WHERE " & strWhere 

Else

Dim strInsertLine, strValuesLine, intOLS_IDList
strSQL = "SET NOCOUNT ON DECLARE @SITEVALUES TABLE (NUM varchar(8), ORG_NUM nvarchar(8)"
strInsertLine = ") INSERT INTO @SITEVALUES (NUM, ORG_NUM"
If Nl(strNUM) Then
strValuesLine = ") VALUES (NULL," & QsNl(Request("ORG_NUM"))
Else
strValuesLine = ") SELECT bt.NUM, " & IIf(Request.QueryString("ORG_NUM").Count = 0, "ORG_NUM",  QsNl(Request("ORG_NUM")))
End If

For Each field in Array("ORG_LEVEL_1", "ORG_LEVEL_2", "ORG_LEVEL_3", "ORG_LEVEL_4", "ORG_LEVEL_5", "SERVICE_NAME_LEVEL_1", "SERVICE_NAME_LEVEL_2", "LOCATION_NAME")
	strSQL = strSQL & ", " & vbCrLf & field & " nvarchar(255)"
	strInsertLine = strInsertLine & ", " & field
	If Nl(strNUM) Then
		strValuesLine = strValuesLine & ", " & QsNl(Request(field))
	Else
		strValuesLine = strValuesLine & ", " & IIf(Request.QueryString(field).Count = 0, field,  QsNl(Request(field)))
	End If
Next

strSQL = strSQL & strInsertLine & strValuesLine
If Nl(strNUM) Then
	strSQL = strSQL & ")"
Else
	strSQL = strSQL & " FROM GBL_BaseTable bt INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID WHERE bt.NUM = " & QsNl(strNUM)
End If


strSQL = strSQL & " DECLARE @OLS_IDs TABLE (OLS_ID int, CODE varchar(20)) "

intOLS_IDList = Request("OLS_ID")
If IsIDList(intOLS_IDList) Then
	strSQL = strSQL & "INSERT INTO @OLS_IDs (OLS_ID, CODE) SELECT ols.OLS_ID, ols.CODE FROM GBL_OrgLocationService ols INNER JOIN dbo.fn_GBL_ParseIntIDList(" & QsNl(intOLS_IDList) & ", ',') intid ON intid.ItemID=ols.OLS_ID "
End If

Dim strViolationTemplate 
strViolationTemplate = _
	" IF EXISTS(SELECT * FROM @OLS_IDs WHERE CODE='[TYPE]') BEGIN" & vbCrLf & _
			"INSERT INTO @VIOLATIONS SELECT '[TYPE]', COUNT(*) FROM @SITEVALUES sv WHERE EXISTS(SELECT * FROM GBL_BaseTable_Description btd INNER JOIN GBL_BaseTable bt ON btd.NUM=bt.NUM WHERE btd.LangID=@@LANGID AND ISNULL(sv.NUM, '') <> btd.NUM"

strSQL = strSQL & "DECLARE @VIOLATIONS TABLE (CODE varchar(20), CNT int) " & vbCrLf & _
	Replace(strViolationTemplate, "[TYPE]", "AGENCY") &  " AND (EXISTS(SELECT * FROM GBL_BT_OLS btols INNER JOIN GBL_OrgLocationService ols ON btols.OLS_ID=ols.OLS_ID WHERE btols.NUM=btd.NUM AND ols.CODE='AGENCY') OR NOT EXISTS(SELECT * FROM GBL_BT_OLS ols WHERE ols.NUM=btd.NUM))"
For Each field in Array("ORG_LEVEL_1", "ORG_LEVEL_2", "ORG_LEVEL_3", "ORG_LEVEL_4", "ORG_LEVEL_5")
	strSQL = strSQL & " AND ISNULL(" & field & ", '') = ISNULL(sv." & field & ", '')"
Next

strSQL = strSQL & ") END " & vbCrLF & _
	Replace(strViolationTemplate, "[TYPE]", "SITE") & " AND ISNULL(ORG_NUM, bt.NUM) = ISNULL(ISNULL(sv.ORG_NUM, sv.NUM), '') AND LOCATION_NAME=sv.LOCATION_NAME ) END" & vbCrLF & _
	Replace(strViolationTemplate, "[TYPE]", "SERVICE") & " AND ISNULL(ORG_NUM, bt.NUM) = ISNULL(ISNULL(sv.ORG_NUM, sv.NUM), '')"
For Each field in Array("SERVICE_NAME_LEVEL_1", "SERVICE_NAME_LEVEL_2")
	strSQL = strSQL & " AND " & field & " = sv." & field
Next

strSQL = strSQL & ") END SELECT * FROM @VIOLATIONS"

End If

'Response.Write(strSQL)

Response.Write("[")
Dim bFirst
bFirst = True

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

	While Not .EOF
		If Not bFirst Then
			Response.Write(",")
		End If
		Response.Write("{""type"": ")
		Response.Write(JSONQs(.Fields("CODE"), True))
		Response.Write(", ""count"": ")
		Response.Write(.Fields("CNT"))
		Response.Write("}")
		bFirst = False
		.MoveNext
	Wend

	.Close
End With

Response.Write("]")

Set rsOrgFinder = Nothing
Set cmdOrgFinder = Nothing
%>
<!--#include file="../includes/core/incClose.asp" -->
