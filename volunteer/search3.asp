<%@  language="VBSCRIPT" %>
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
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../includes/search/incCommSrchVOLList.asp" -->
<%
Dim strCMID, _
	strCMIDList, _
	decAge, _
	bOSSD, _
	strIGID, _
	bNoInterests

strCMID = Trim(Request("CMID"))
If Not IsIDList(strCMID) Then
	strCMID = vbNullString
End If
strCMIDList = Trim(Request("CMIDList"))
If Not IsIDList(strCMIDList) Then
	strCMIDList = vbNullString
End If

If Not Nl(strCMIDList) Then
	strCMID = strCMID & StringIf(Not Nl(strCMID),",") & strCMIDList
	strCMID = Replace(strCMID," ",vbNullString)
End If

Call getVolSearchComms(strCMID)

decAge = Request("Age")
If Not Nl(decAge) Then
	If IsNumeric(decAge) Then
		decAge = CSng(decAge)
	Else
		decAge = Null
	End IF
Else
	decAge = Null
End If
bOSSD = Request("forOSSD") = "on"

strIGID = Trim(Request("IGID"))
If Not IsIDList(strIGID) Then
	strIGID = Null
End If

Sub makeSrch3Table()
	Dim strReturn, strSQL
	Dim cmdSrch3, rsSrch3

	strSQL = "SELECT ai.AI_ID, ain.Name AS InterestName, COUNT(DISTINCT pr.VNUM) AS NUM_POS" & vbCrLf & _
			"FROM VOL_InterestGroup ig" & vbCrLf & _
			"INNER JOIN VOL_AI_IG sr ON sr.IG_ID=ig.IG_ID" & vbCrLf & _
			"INNER JOIN VOL_Interest ai ON ai.AI_ID=sr.AI_ID" & vbCrLf & _
			"INNER JOIN VOL_Interest_Name ain ON ai.AI_ID=ain.AI_ID AND LangID=@@LANGID" & vbCrLf & _
			"INNER JOIN VOL_OP_AI pr ON ai.AI_ID=pr.AI_ID" & vbCrLf & _
			"INNER JOIN VOL_Opportunity vo ON pr.VNUM = vo.VNUM" & vbCrLf & _
			"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
			"WHERE " & StringIf(Not g_bCanSeeExpired, "(vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE()) AND ") & g_strWhereClauseVOLNoDel

	If Not Nl(strIGID) Then
		strSQL = strSQL & AND_CON & "(sr.IG_ID IN (" & strIGID & "))"
	End If
	If Not Nl(strCMID) Then
		strSQL = strSQL & AND_CON & "EXISTS(SELECT * FROM  VOL_OP_CM WHERE VNUM=vo.VNUM AND CM_ID IN (" & strCommSearchList & "))"
	End If
	If bOSSD Then
		strSQL = strSQL & AND_CON & "(vo.OSSD=" & SQL_TRUE & ")"
	End If
	If Not Nl(decAge) Then
		strSQL = strSQL & AND_CON & "((vo.MIN_AGE IS NULL OR vo.MIN_AGE<=" & decAge & _
		") AND (vo.MAX_AGE IS NULL OR (FLOOR(vo.MAX_AGE)=vo.MAX_AGE AND vo.MAX_AGE+1>" & decAge & _
		") OR (vo.MAX_AGE>=" & decAge & ")))"
	End If
	strSQL = strSQL & "GROUP BY ai.AI_ID, ain.Name" & vbCrLf & _
		"ORDER BY ain.Name"
		
	'Response.Write("<!--" & Server.HTMLEncode(strSQL) & "-->")
	'Response.Flush()


	Set cmdSrch3 = Server.CreateObject("ADODB.Command")
	With cmdSrch3
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandType = adCmdText
		.CommandText = strSQL
		.CommandTimeout = 0
	End With
	Set rsSrch3 = cmdSrch3.Execute
	With rsSrch3
		If .EOF Then
			bNoInterests = True
%>
<p><span class="AlertBubble"><%= TXT_NO_SPECIFIC_INTERESTS_FOUND %></span></p>
<%
		Else
%>
<div class="row clear-line-below">
<%
			While Not .EOF
%>
	<div class="col-xs-12 col-sm-6 col-md-4 clear-line-below">
		<label>
			<input type="checkbox" name="AIID" value="<%=rsSrch3("AI_ID")%>">
			<%=Server.HTMLEncode(.Fields("InterestName"))%>
		</label>
		<span class="badge"><%= .Fields("NUM_POS") %></span>
	</div>
<%
				.MoveNext
			Wend
%>
</div>
<%
		End If
	End With

End Sub

%>
<%
Call makePageHeader(TXT_VOLUNTEER_SEARCH_STEP & IIf(g_bOnlySpecificInterests,"2","3"), TXT_VOLUNTEER_SEARCH_STEP & IIf(g_bOnlySpecificInterests,"2","3"), True, False, False, True)
%>
<h2><%=IIf(g_bOnlySpecificInterests,TXT_AREAS_OF_INTEREST,TXT_SPECIFIC_AREA_OF_INTEREST)%></h2>
<p><%=IIf(g_bOnlySpecificInterests,TXT_INST_SELECT_SPECIFIC_INTERESTS_2,TXT_INST_SELECT_SPECIFIC_INTERESTS_1)%></p>
<form action="<%= IIf(g_bUseDatesTimes, "search4.asp", "results.asp") %>" name="EntryForm" method="GET">
    <div style="display: none">
        <%=g_strCacheFormVals%>
        <%If Not Nl(strCommList) Then%>
        <input type="hidden" name="CMID" value="<%=strCommList%>">
        <%End If%>
        <%If Not Nl(decAge) Then%>
        <input type="hidden" name="Age" value="<%=decAge%>">
        <%End If%>
        <%If bOSSD Then%>
        <input type="hidden" name="forOSSD" value="on">
        <%End If%>
        <%If Not Nl(strIGID) Then%>
        <input type="hidden" name="IGID" value="<%=strIGID%>">
        <%End If%>
    </div>
<%
	Call makeSrch3Table()
	If Not bNoInterests Then
%>
	<input class="btn btn-default" type="submit" value="<%= TXT_NEXT %> >>">
<%
	End If
%>
</form>
<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
