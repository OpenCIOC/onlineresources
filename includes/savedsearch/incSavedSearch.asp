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

UPDATE_BUTTON = "<input class=""btn btn-default"" type=""Submit"" name=""Submit"" value=""" & TXT_UPDATE & """>"
DELETE_BUTTON = "<input class=""btn btn-default"" type=""Submit"" name=""Submit"" value=""" & TXT_DELETE & """>"
SEARCH_BUTTON = "<input class=""btn btn-default"" type=""Submit"" name=""Submit"" value=""" & TXT_SEARCH & """>"

If Not user_bDOM Then
	Call securityFailure()
End If
%>
<p><span class="AlertBubble"><%=TXT_UPGRADE_WARNING%></span></p>

<form action="savedsearch2.asp" method="get" name="PersonalSearches">
    <%=g_strCacheFormVals%>
<%
Call openSearchListRst(user_intID, ps_intDbArea)
%>
    <table class="BasicBorder cell-padding-4 full-width form-table">
        <tr>
            <th class="RevTitleBox" colspan="3"><label for="SRCHID_P"><%=TXT_EXECUTE_OR_EDIT_SEARCH%></label></th>
        </tr>
        <tr>
            

        <tr>
            <td class="field-data-cell" colspan="2">
                <p class="SmallNote"><%=Replace(TXT_MAX_SEARCHES, "[MAX]", user_intSavedSearchQuota)%></p>
                <%=makeSearchList(vbNullString,"SRCHID","P",True,True)%>
            </td>
        </tr>
        <%If Not rsListSearch.RecordCount=0 Then%>
        <tr>
            <td class="field-label-cell"><label for="PMod"><%=TXT_LAST_MODIFIED%></label></td>
            <td class="field-data-cell">
                <input class="form-control" type="text" name="PMod" id="PMod" title=<%=AttrQs(TXT_LAST_MODIFIED)%> size="<%=TEXT_SIZE%>" readonly>
            </td>
        </tr>
        <tr>
            <td class="field-label-cell"><label for="PNotes"><%=TXT_NOTES%></label></td>
            <td class="field-data-cell">
                <textarea class="form-control" name="PNotes" id="PNotes" title=<%=AttrQs(TXT_NOTES)%> rows="<%=TEXTAREA_ROWS_LONG%>" readonly></textarea>
            </td>
        </tr>
        <tr>
            <td colspan="2"><%=SEARCH_BUTTON & " " & UPDATE_BUTTON & " " & DELETE_BUTTON%></td>
        </tr>
        <%End If%>
    </table>
<%
Call closeSearchListRst()
%>
</form>

<hr>

<form action="savedsearch2.asp" method="get" name="SharedSearches">
    <%=g_strCacheFormVals%>
<%
Call openSharedSearchListRst(ps_intDbArea)
%>
    <table class="BasicBorder cell-padding-4 full-width form-table">
        <tr>
            <th class="RevTitleBox" colspan="3"><label for="SRCHID_S"><%=TXT_SHARED_SEARCHES%></label></th>
        </tr>
        <tr>
            <td colspan="2"><%=makeSharedSearchList(vbNullString,"SRCHID","S",True,True)%></td>
        </tr>
        <%If Not rsListSharedSearch.RecordCount=0 Then%>
        <tr>
            <td class="field-label-cell"><label for="SOwner"><%=TXT_OWNER%></label></td>
            <td class="field-data-cell">
                <input class="form-control" type="text" name="SOwner" id="SOwner" size="<%=TEXT_SIZE%>" title=<%=AttrQs(TXT_OWNER)%> readonly></td>
        </tr>
        <tr>
            <td class="field-label-cell"><label for="SMod"><%=TXT_LAST_MODIFIED%></label></td>
            <td class="field-data-cell">
                <input class="form-control" type="text" name="SMod" id="SMod" size="<%=TEXT_SIZE%>" title=<%=AttrQs(TXT_LAST_MODIFIED)%> readonly>
            </td>
        </tr>
        <tr>
            <td class="field-label-cell"><label for="SNotes"><%=TXT_NOTES%></label></td>
            <td class="field-data-cell">
                <textarea class="form-control" name="SNotes" id="SNotes" rows="<%=TEXTAREA_ROWS_LONG%>" title=<%=AttrQs(TXT_NOTES)%> readonly></textarea></td>
        </tr>
        <tr>
            <td colspan="2"><%=SEARCH_BUTTON%></td>
        </tr>
        <%End If%>
    </table>
<%
Call closeSharedSearchListRst()
%>
</form>
<%
Call makePageFooter(True)
%>
