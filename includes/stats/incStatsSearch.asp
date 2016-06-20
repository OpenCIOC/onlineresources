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
Call addScript(ps_strPathToStart & "scripts/formPrintMode.js", "text/javascript")

Call makePageHeader(TXT_STATS, TXT_STATS, True, True, True, True)
If user_intCanViewStatsDOM > STATS_NONE Then
	Dim strViewName
	strViewName = vbNullString
	If Not user_intCanViewStatsDOM = STATS_ALL Then
		strViewName = " ( " & IIf(ps_intDbArea = DM_CIC, g_strViewNameCIC, g_strViewNameVOL) & " )"
	End If
%>
<p>[ <span class="HighLight"><a href="<%=makeLinkB("stats.asp")%>"><%=TXT_MAIN_STATS_PAGE%></a></span>
| <a href="<%=makeLinkB("stats2.asp")%>"><%=TXT_TOTAL_RECORD_USE & strViewName%></a>
| <a href="<%=makeLinkB("stats3.asp")%>"><%=TXT_TOP_50_RECORDS & strViewName%></a>
<%	If user_intCanViewStatsDOM = STATS_ALL Then%>
| <a href="<%=makeLinkB("stats4.asp")%>"><%=TXT_USE_BY_AGENCY%></a>
| <a href="<%=makeLinkB("stats_auto.asp")%>"><%=TXT_AUTO_REPORTS%></a>
<%
End If
If user_bSuperUserDOM Then
%>
| <a href="<%=makeLinkB("stats_delete.asp")%>"><%=TXT_DELETE_STATS%></a>
<% End If%>
]</p>
<%
	Call printStatsForm(vbNullString)
%>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/datepicker.js") %>
<script type="text/javascript">
jQuery(function() {
		init_cached_state();
		restore_cached_state();
		});
</script>

	<%
	g_bListScriptLoaded = True
Else
	Call handleError(TXT_NO_PERMISSIONS, vbNullString, vbNullString)
End If

Call makePageFooter(True)
%>
