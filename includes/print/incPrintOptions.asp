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
<script language="python" runat="server">
from cioc.web.gbl import printlist
def render_printlist_form():
	view_class = getattr(printlist, f"PrintRecordList{pyrequest.pageinfo.DbAreaS}")
	view_object = view_class(pyrequest)
	form, bottomjs = view_object.render_form_and_get_bottomjs_fn()
	Response.Write(form)
	set_bottom_js_fn(bottomjs)

</script>
<% If False Then %>
<form action="printlist.asp" method="post" id="EntryForm">
<%=g_strCacheFormVals%>
<input type="hidden" name="Picked" value="on">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox"><%=TXT_INST_CUSTOMIZE%></th></tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_PROFILE%></td>
<%
	Call openPrintProfileListRst(ps_intDbArea, g_intViewTypeDOM)
%>
	<td><%=makePrintProfileList(vbNullString,"ProfileID","ProfileID",False)%></td>
<%
	Call closePrintProfileListRst()
%>
</tr>
<%
	If ps_intDbArea = DM_CIC Then
		If Not g_bLimitedView Then
			Call getPublicationOptionList()
			If bHavePublications Then
		%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_PUBLICATIONS%></td>
	<td>
<%
			If Not Nl(strIDList) Then
%>
<%=TXT_FURTHER_LIMIT_SELECTION%><br>&nbsp;<br>
<%		
			End If
			Call makePublicationUI()
%>
	</td>
</tr>
		<%
			End If
		Else
			Call getGeneralHeadingOptionList(g_intPBID)
		%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_HEADINGS%></td>
	<td>
<%
			If Not Nl(strIDList) Then
%>
<%=TXT_FURTHER_LIMIT_SELECTION%><br>&nbsp;<br>
<%		
			End If
			Call makeGeneralHeadingUI()
%>
	</td>
</tr>
		<%
		End If
	ElseIf ps_intDbArea = DM_VOL Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SORT_BY%></td>
	<td><input name="SortBy" type="radio" value="O" checked>&nbsp;<%=TXT_ORG_NAMES%>
	<br><input name="SortBy" type="radio" value="P">&nbsp;<%=TXT_POSITION_TITLE%>
	<br><input name="SortBy" type="radio" value="C">&nbsp;<%=TXT_DATE_CREATED%>
	<br><input name="SortBy" type="radio" value="M">&nbsp;<%=TXT_LAST_MODIFIED%>
	</td>
</tr>
<%
	End If
%>
<%If g_bCanSeeDeletedDOM Then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_DELETED_RECORDS%></td>
	<td><label for="IncludeDeleted"><input name="IncludeDeleted" id="IncludeDeleted" type="checkbox"><%=TXT_INCLUDE_DELETED%></label></td>
</tr>
<%End If%>
<%If ps_intDbArea = DM_VOL And g_bCanSeeExpired Then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_EXPIRED_RECORDS%></td>
	<td><input name="IncludeExpired" type="checkbox"><%=TXT_INCLUDE_EXPIRED%></td>
</tr>
<%End If%>
</table>
<input type="submit" value="<%=TXT_NEXT%> >>">
</form>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<% g_bListScriptLoaded = True %>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/advsrch.js") %>
<script type="text/javascript">
jQuery(function($) {
	init_cached_state()
	init_pubs_dropdown('<%=makeLinkB(ps_strPathToStart & "jsonfeeds/heading_searchform.asp")%>');
	restore_cached_state();
})
</script>

<% Else
Call render_printlist_form()
End If %>

