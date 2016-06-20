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

<%
Call makePageHeader(TXT_DELETE_STATS_TITLE, TXT_DELETE_STATS_TITLE, True, True, True, True)
%>

<p>[ <a href="<%=makeLinkB("stats.asp")%>"><%=TXT_MAIN_STATS_PAGE%></a>
| <a href="<%=makeLinkB("stats2.asp")%>"><%=TXT_TOTAL_RECORD_USE%></a>
| <a href="<%=makeLinkB("stats3.asp")%>"><%=TXT_TOP_50_RECORDS%></a>
| <a href="<%=makeLinkB("stats4.asp")%>"><%=TXT_USE_BY_AGENCY%></a>
<%If user_bSuperUserDOM Then%>
| <span class="HighLight"><a href="<%=makeLinkB("stats_delete.asp")%>"><%=TXT_DELETE_STATS%></a></span>
<%End If%>
]</p>

<h1><%=TXT_DELETE_STATS_TITLE%></h1>
<%
Dim bConfirmed
bConfirmed = Request("Confirmed") = "on"

Dim dToDate
dToDate = Request("DeleteToDate")
If Nl(dToDate) Then
	Call handleError(TXT_NO_DATE_CHOSEN, "stats_delete.asp", "DM=" & intDomain)
ElseIf Not IsDate(dToDate) Then
	Call handleError(dToDate & TXT_INVALID_DATE_FORMAT, "stats_delete.asp", "DM=" & intDomain)
Else
	dToDate = DateValue(dToDate)
End If

If bConfirmed Then
	Dim cmdStatD, rsStatD
	Set cmdStatD = Server.CreateObject("ADODB.Command")
	With cmdStatD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_" & ps_strDbArea & "_Stats_Month_d"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ToDate", adDBDate, adParamInput, 4, dToDate)
		.CommandTimeout = 0
		.Execute
	End With
%>
<p><%=TXT_STATS_WERE_DELETED%></p>
<%	
Else
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%>
<br>(<%=TXT_DELETE & " " & TXT_BEFORE_DATE & TXT_COLON & DateString(dToDate,False)%>)</span></p>
<form action="<%=ps_strThisPage%>" method="post">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="DeleteToDate" value="<%=dToDate%>">
<input type="hidden" name="Confirmed" value="on">
</div>
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%End If%>
<%
Call makePageFooter(True)
%>
