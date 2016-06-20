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
Sub printHistoryDialogHTML(strNUM, bIncludeScript)
%>
<div id="field_history" title="<%=TXT_FIELD_HISTORY_FOR_RECORD & strNUM%>">
</div>
<div id="revision_history" title="<%=TXT_FIELD_HISTORY_FOR_RECORD & strNUM%>">
</div>
<% If bIncludeScript Then %>
<%= JSVerScriptTag("scripts/history.js") %>
<% End If %>
<%
End Sub
Sub printHistoryDialogJavaScript(bJQueryWrap)

%>
var field_history = {
	fielddiffui_url: '<%= makeLink(ps_strPathToStart & StringIf(ps_intDbArea=DM_VOL, "volunteer/") & "fielddiffui.asp", "ID=[ID]&FIELD=[FIELD]&LANG=[LANG]", vbNullString) %> #content_to_insert',
	fielddiff_url:'<%= makeLink(ps_strPathToStart & "jsonfeeds/fielddiff.asp", "DM=" & ps_intDbArea & "&ID=[ID]&LANG=[LANG]&FIELD=[FIELD]&REV=[REV]&COMP=[COMP]", vbNullString) %>',
	path_to_start: '<%= ps_strPathToStart %>',
	revhistory_url: '<%= makeLink(ps_strPathToStart & StringIf(ps_intDbArea=DM_VOL, "volunteer/") & "revhistory.asp", "ID=[ID]&LANG=[LANG]", vbNullString) %> #content_to_insert',
	txt_fielddifftitle: "<%= TXT_FIELD_HISTORY_FOR_RECORD %>",
	txt_loading: "<%= TXT_LOADING %>"
};
var do_history_init = function(jQuery) {
	init_history_dialog(jQuery, field_history)
};

<% If bJQueryWrap Then %>
jQuery(do_history_init);
<% Else %>
do_history_init(jQuery);
<% End If %>
<%

End Sub
Sub printHistoryDialog(strNUM)
	Call printHistoryDialogHTML(strNUM, True)
%><script type="text/javascript"><%
	Call printHistoryDialogJavaScript(True)
%></script><%
End Sub
%>
