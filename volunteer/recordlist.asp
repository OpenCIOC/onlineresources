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
Call setPageInfo(False, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../includes/core/incFormat.asp" -->
<%
Server.ScriptTimeOut = 1200
Response.Buffer = False

Call makePageHeader(TXT_VOLUNTEER_OPPS, TXT_VOLUNTEER_OPPS, False, False, True, False)

Dim cmdOrgList, _
	rsOrgList, _
	strSQL

Dim intPage, intPageSize

intPageSize = 500

intPage = Request("Page")
If Not IsPosTinyInt(intPage) Then
	intPage = Null
End If

Select Case Request("PS")
	Case "100"
		intPageSize = 100
	Case "250"
		intPageSize = 250
	Case "500"
		intPageSize = 500
	Case Else
		intPageSize = 1000
End Select

strSQL = "SELECT vo.VNUM, vod.POSITION_TITLE," & _
	"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL" & vbCrLf & _
	"FROM VOL_Opportunity vo" & vbCrLf & _
	"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
	"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
	"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
	"WHERE " & g_strWhereClauseVOLNoDel & vbCrLf & _
	"ORDER BY ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5," & vbCrLf & _
		"	STUFF(" & vbCrLf & _
		"		CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)" & vbCrLf & _
		"			THEN NULL" & vbCrLf & _
		"			ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +" & vbCrLf & _
		"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +" & vbCrLf & _
		"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')" & vbCrLf & _
		"			 END," & vbCrLf & _
		"		1, 2, ''" & vbCrLf & _
		"	)"

If Not Nl(intPage) Then
	strSQL = strSQL & vbCrLf & _
		"OFFSET ((" & intPage & "-1) * " & intPageSize & ") ROWS" & vbCrLf & _
		"FETCH NEXT " & intPageSize & " ROWS ONLY"
End If

Set cmdOrgList = Server.CreateObject("ADODB.Command")
With cmdOrgList
	.ActiveConnection = getCurrentCICBasicCnn()
	.CommandType = adCmdText
	.CommandText = strSQL
	.CommandTimeout = 0
End With
Set rsOrgList = Server.CreateObject("ADODB.Recordset")
With rsOrgList
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdOrgList
	Response.Write("<ol>")
	While Not .EOF
		Response.Write("<li><a href=""" & makeVOLDetailsLink(rsOrgList.Fields("VNUM"),vbNullString,vbNullString) & """>" & .Fields("ORG_NAME_FULL") & TXT_COLON & .Fields("POSITION_TITLE") & "</a></li>")
		.MoveNext
	Wend
	.Close
	Response.Write("</ol>")
End With
Set rsOrgList = Nothing
Set cmdOrgList = Nothing

Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
