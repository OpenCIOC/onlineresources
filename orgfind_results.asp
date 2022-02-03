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
Call setPageInfo(False, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtFinder.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/search/incNormalizeSearchTerms.asp" -->
<%
Call makePageHeader(TXT_ORG_FINDER, TXT_ORG_FINDER, False, False, True, False)
%>
<h1><%=TXT_ORG_SEARCH_RESULTS%></h1>
<%
'On Error Resume Next

Dim strSTerms, _
	strNUM
strSTerms = Trim(Request("OrgSrch"))

Dim strJoinedSTerms, _
	strJoinedQSTerms, _
	strDisplaySTerms, _
	singleSTerms(), _
	quotedSTerms(), _
	exactSTerms(), _
	displaySTerms()

If Not Nl(strSTerms) Then
	If IsNUMType(strSTerms) Then
		strNUM = strSTerms
		strDisplaySTerms = strNUM
	Else
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
	End If
Else
	ReDim singleSTerms(-1)
	ReDim quotedSTerms(-1)
	ReDim exactSTerms(-1)
End If

If Nl(strJoinedSTerms) And Nl(strJoinedQSTerms) And Nl(strNUM) Then
%>
<p><%=TXT_NOTHING_TO_SEARCH%></p>
<%
Else
	Dim strSQL, _
		strAlertColumn
		
	strSQL = "SELECT bt.NUM,bt.MemberID," & _
		"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & _
		"btd.CMP_LocatedIn AS LOCATED_IN_CM," & _
		"dbo.fn_GBL_NUMToOrgLocationService(bt.NUM) AS OLS"
	
	If g_bAlertColumnVOL Then
		strSQL = strSQL & _
			",btd.NON_PUBLIC" & _
			",CASE WHEN cbtd.COMMENTS IS NULL " & _
				"THEN 0 ELSE 1 END AS HAS_COMMENTS" & _
			",CASE WHEN btd.DELETION_DATE > GETDATE() "& _
				"THEN 1 ELSE 0 END AS TO_BE_DELETED" & _
			",CASE WHEN btd.DELETION_DATE <= GETDATE() "& _
				"THEN 1 ELSE 0 END AS IS_DELETED" & _
			",CASE WHEN EXISTS(SELECT * FROM GBL_FeedbackEntry fbe WHERE fbe.NUM=bt.NUM " & _
					"AND (EXISTS(SELECT * FROM GBL_Feedback fb WHERE fbe.FB_ID=fb.FB_ID) OR EXISTS(SELECT * FROM CIC_Feedback fb WHERE fbe.FB_ID=fb.FB_ID))) " & _
			"THEN 1 ELSE 0 END AS HAS_FEEDBACK" & _
			",CASE WHEN EXISTS(SELECT * FROM CIC_BT_PB pbr INNER JOIN CIC_Feedback_Publication pf ON pbr.BT_PB_ID=pf.BT_PB_ID WHERE pbr.NUM=bt.NUM) " & _
				"THEN 1 ELSE 0 END AS HAS_PUB_FEEDBACK" & _
			",CASE WHEN EXISTS(SELECT * FROM VOL_Opportunity vo INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM WHERE vo.NUM=bt.NUM " & _
				" AND " & g_strWhereClauseVOLNoDel & ") " & _
				"THEN 1 ELSE 0 END AS HAS_VOL_OPPS" & vbCrLf
	End If
	
	strSQL = strSQL & " FROM GBL_BaseTable bt" & vbCrLf & _
		"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf & _
		"WHERE "

	If Not Nl(strNUM) Then
		strSQL = strSQL & "bt.NUM=" & QsNl(strNUM)
	Else
		If Not Nl(strJoinedSTerms) Then
			strSQL = strSQL & "CONTAINS(btd.SRCH_Org,'" & strJoinedSTerms & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')" & vbCrLf	
		End If
		If Not Nl(strJoinedQSTerms) Then
			strSQL = strSQL & StringIf(Not Nl(strJoinedSTerms),AND_CON) & "CONTAINS(btd.SRCH_Org,'" & strJoinedQSTerms & "')" & vbCrLf	
		End If
	End If
	
	strSQL = strSQL & IIf(Not Nl(g_strWhereClauseCIC), AND_CON & g_strWhereClauseCIC & vbCrLf, vbNullString) & _
		"ORDER BY CASE WHEN bt.MemberID=" & g_intMemberID & " THEN 0 ELSE 1 END, " & _
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
<table class="BasicBorder cell-padding-2 table-striped">
	<thead>
		<tr>
			<%If g_bAlertColumnVOL Then%><th width="5" class="RevTitleBox">&nbsp;</th><%End If%>
			<th class="RevTitleBox"><%=TXT_RECORD_NUM%></th>
			<th class="RevTitleBox"><%=TXT_NAME%></th>
			<th class="RevTitleBox"><%=TXT_LOCATED_IN%></th>
		</tr>
	</thead>
	<tbody>
<%
				While Not .EOF
					strAlertColumn = vbNullString
					If g_bAlertColumnVOL Then
						If .Fields("IS_DELETED") Then
							strAlertColumn = "X"
						ElseIf .Fields("TO_BE_DELETED") Then
							strAlertColumn = "P"
						End If
						If .Fields("HAS_COMMENTS") And user_bCommentAlertCIC Then
							strAlertColumn = strAlertColumn & "C"
						End If
						If user_bFeedbackAlertCIC Then
							If .Fields("HAS_FEEDBACK") Or .Fields("HAS_PUB_FEEDBACK") Then
								strAlertColumn = strAlertColumn & "F"
							End If
						End If
						If ps_intDbArea = DM_CIC And g_bUseVOL And g_bVolunteerLink Then
							If .Fields("HAS_VOL_OPPS") Then
								strAlertColumn = strAlertColumn & "V"
							End If
						End If
						If Nl(strAlertColumn) Then
							strAlertColumn = "&nbsp;"
						Else
							strAlertColumn = "<span style=""font-weight:bold"">" & strAlertColumn & "</span>"
						End If
					End If

%>
		<tr>
			<%If g_bAlertColumnVOL Then%><td width="5"<%If .Fields("NON_PUBLIC") Then%> class="AlertBox"<%End If%>><%=strAlertColumn%></td><%End If%>
			<td style="<%=IIf(.Fields("MemberID")=g_intMemberID,"font-weight:bold;","font-style:italic;")%>"><%=.Fields("NUM")%></td>
			<td><a href="<%=makeDetailsLink(.Fields("NUM"),vbNullString,vbNullString)%>" target="_blank"><%=.Fields("ORG_NAME_FULL")%></a>
			<%If Not Nl(.Fields("OLS")) Then%>
				<span style="font-size:smaller; font-style:italic; white-space:nowrap;">(<%=.Fields("OLS")%>)</span>
			<%End If%>
			</td>
			<td><%=.Fields("LOCATED_IN_CM")%></td>
		</tr>
<%
					.MoveNext
				Wend
%>
	</tbody>
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
<!--#include file="includes/core/incClose.asp" -->
