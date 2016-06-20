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
If user_intSavedSearchQuota < 1 Then
	Call securityFailure()
End If

Call makePageHeader(TXT_MANAGE_SAVED_SEARCHES, TXT_MANAGE_SAVED_SEARCHES, True, True, True, True)

Dim UPDATE_BUTTON, _
	DELETE_BUTTON, _
	SEARCH_BUTTON

UPDATE_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_UPDATE & """>"
DELETE_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_DELETE & """>"
SEARCH_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_SEARCH & """>"

If Not user_bDOM Then
	Call securityFailure()
End If
%>
<p><span class="AlertBubble"><%=TXT_UPGRADE_WARNING%></span></p>

<form action="savedsearch2.asp" method="get" name="PersonalSearches">
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox" colspan="3"><%=TXT_EXECUTE_OR_EDIT_SEARCH%></th>
</tr>
<tr>
<%=g_strCacheFormVals%>
<%
Call openSearchListRst(user_intID, ps_intDbArea)
%>
<tr><td colspan="2">
	<span class="SmallNote"><%=Replace(TXT_MAX_SEARCHES, "[MAX]", user_intSavedSearchQuota)%></span>
	<br><%=makeSearchList(vbNullString,"SRCHID","P",True,True)%>
</td></tr>
<%If Not rsListSearch.RecordCount=0 Then%>
<tr><td class="FieldLabelLeft"><%=TXT_LAST_MODIFIED%></td><td><input type="text" name="PMod" id="PMod" title=<%=AttrQs(TXT_LAST_MODIFIED)%> size="<%=TEXT_SIZE%>" readonly></td></tr>
<tr><td class="FieldLabelLeft"><%=TXT_NOTES%></td><td><textarea name="PNotes" id="PNotes" title=<%=AttrQs(TXT_NOTES)%> rows="<%=TEXTAREA_ROWS_LONG%>" cols="<%=TEXTAREA_COLS%>" readonly></textarea></td></tr>
<tr><td colspan="2" align="center"><%=SEARCH_BUTTON & " " & UPDATE_BUTTON & " " & DELETE_BUTTON%></td></tr>
<%End If%>
<%
Call closeSearchListRst()
%>
</table>
</form>
<br>
<form action="savedsearch2.asp" method="get" name="SharedSearches">
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox" colspan="3"><%=TXT_SHARED_SEARCHES%></th>
</tr>
<%=g_strCacheFormVals%>
<%
Call openSharedSearchListRst(ps_intDbArea)
%>
<tr><td colspan="2"><%=makeSharedSearchList(vbNullString,"SRCHID","S",True,True)%></td></tr>
<%If Not rsListSharedSearch.RecordCount=0 Then%>
<tr><td class="FieldLabelLeft"><%=TXT_OWNER%></td><td><input type="text" name="SOwner" id="SOwner" size="<%=TEXT_SIZE%>" title=<%=AttrQs(TXT_OWNER)%> readonly></td></tr>
<tr><td class="FieldLabelLeft"><%=TXT_LAST_MODIFIED%></td><td><input type="text" name="SMod" id="SMod" size="<%=TEXT_SIZE%>" title=<%=AttrQs(TXT_LAST_MODIFIED)%> readonly></td></tr>
<tr><td class="FieldLabelLeft"><%=TXT_NOTES%></td><td><textarea name="SNotes" id="SNotes" rows="<%=TEXTAREA_ROWS_LONG%>" cols="<%=TEXTAREA_COLS%>" title=<%=AttrQs(TXT_NOTES)%> readonly></textarea></td></tr>
<tr><td colspan="2" align="center"><%=SEARCH_BUTTON%></td></tr>
<%End If%>
<%
Call closeSharedSearchListRst()
%>
</table>
</form>
<%
Call makePageFooter(True)
%>
