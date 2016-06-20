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

Dim bNew
bNew = False

Dim intSrchID
intSrchID = Trim(Request("SRCHID"))

If Nl(intSrchID) Then
	bNew = True
	intSrchID = Null
ElseIf Not IsIDType(intSrchID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intSrchID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_SEARCH, _
		"savedsearch.asp", vbNullString)
Else
	intSrchID = CLng(intSrchID)
End If

Dim	strCreatedDate, _
	strModifiedDate, _
	strSearchName, _
	strWhereClause, _
	strNotes, _
	bIncludeDeleted, _
	intLangID, _
	bShared

Dim intLen

Dim cmdSavedSearch, rsSavedSearch
Set cmdSavedSearch = Server.CreateObject("ADODB.Command")
With cmdSavedSearch
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_SavedSearch_s"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
	.Parameters.Append .CreateParameter("@SSRCH_ID", adInteger, adParamInput, 4, intSrchID)
	.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, ps_intDbArea)
End With
Set rsSavedSearch = cmdSavedSearch.Execute

If Not bNew Then
	With rsSavedSearch
		If .EOF Then
			Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intSrchID) & "." & _
				vbCrLf & "<br>" & TXT_CHOOSE_SEARCH, _
				"savedsearch.asp", vbNullString)
		ElseIf .Fields("User_ID") <> user_intID Then
			Call securityFailure()
		Else
			strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strSearchName = .Fields("SearchName")
			strWhereClause = .Fields("WhereClause")
			strNotes = .Fields("Notes")
			bIncludeDeleted = .Fields("IncludeDeleted")
			intLangID = .Fields("LangID")
		End If
	End With
Else
	strWhereClause = Trim(Request("WhereClause"))
	strNotes = Trim(Request("Notes"))
	bIncludeDeleted = Request("InclDel") = "on"
	intLangID = g_objCurrentLang.LangID
End If
	
Set rsSavedSearch = rsSavedSearch.NextRecordset
Dim strSharedWithSLs
	
With rsSavedSearch
	While Not .EOF
		strSharedWithSLs = strSharedWithSLs & "<br>" & _
			"<label for=" & AttrQs("SharedWithSLs_" & .Fields("SL_ID")) & "><input type=""checkbox"" name=""SharedWithSLs"" id=" & AttrQs("SharedWithSLs_" & .Fields("SL_ID")) & " value=" & attrQS(.Fields("SL_ID")) & _
			IIf(.Fields("Shared") = SQL_TRUE," CHECKED ",vbNullString) & ">&nbsp;" & _
			.Fields("SecurityLevel") & "</label>"
		.MoveNext
	Wend
End With


If Not bNew Then
	Call makePageHeader(TXT_EDIT_SEARCH & strSearchName, TXT_EDIT_SEARCH & strSearchName, True, False, True, True)
Else
	Call makePageHeader(TXT_ADD_SEARCH, TXT_ADD_SEARCH, True, False, True, True)
End If

%>

<p style="font-weight:bold">[ <a href="<%=makeLinkB("savedsearch.asp")%>"><%=TXT_RETURN_SEARCHES%></a> 
<%If Not bNew Then%>| <a href="<%=makeLink("sresults.asp", "SRCHID=" & intSrchID,vbNullString)%>"><%=TXT_EXECUTE_SEARCH%></a><%End If%>
]</p>
<form action="savedsearch_edit2.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="SRCHID" value="<%=intSrchID%>">
<input type="hidden" name="LangID" value="<%=IIf(intLangID,"on",vbNullString)%>">
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox"><%=TXT_USE_FORM_EDIT_SEARCH%></th></tr>
<%
If Not bNew Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_DATE_CREATED%></td>
	<td><%=strCreatedDate%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LAST_MODIFIED%></td>
	<td><%=strModifiedDate%></td>
</tr>
<%
End If
%>
<tr>
	<td class="FieldLabelLeft" valign="top"><label for="SearchName"><%=TXT_NAME%></label> <span class="Alert">*</span></td>
	<td><input name="SearchName" id="SearchName" value=<%=AttrQs(strSearchName)%> size="<%=TEXT_SIZE%>" maxlength="255">
	<br><%=TXT_INST_SEARCH_NAME%></td>
</tr>
<%
If user_bCanAddSQLDOM Then

If Nl(strWhereClause) Then
	intLen = 0
Else
	intLen = Len(strWhereClause)
	strWhereClause = Server.HTMLEncode(strWhereClause)
End If
%>
<tr>
	<td class="FieldLabelLeft" valign="top"><label for="WhereClause"><%=TXT_WHERE_CLAUSE%></label> <span class="Alert">*</span></td>
	<td><span class="SmallNote"><%=TXT_INST_MAX_30000%></span>
	<br><textarea name="WhereClause" id="WhereClause" wrap="soft" rows="<%=getTextAreaRows(intLen,3)%>" cols="<%=TEXTAREA_COLS%>"><%=strWhereClause%></textarea>
	<br><%=TXT_INST_WHERE_CLAUSE_1%>
	<br><span class="Alert"><%=TXT_INST_WHERE_CLAUSE_2%></span></td>
</tr>
<%
Else
%>
<div style="display:none"><input type="hidden" name="WhereClause" value=<%=AttrQs(strWhereClause)%>></div>
<%
End If

If Nl(strNotes) Then
	intLen = 0
Else
	intLen = Len(strNotes)
	strNotes = Server.HTMLEncode(strNotes)
End If
%>
<tr>
	<td class="FieldLabelLeft" valign="top"><label for="Notes"><%=TXT_NOTES%></label></td>
	<td><span class="SmallNote"><%=TXT_INST_MAX_2000%></span>
	<br><textarea name="Notes" id="Notes" wrap="soft" rows="<%=getTextAreaRows(intLen,3)%>" cols="<%=TEXTAREA_COLS%>"><%=strNotes%></textarea>
	<br><%=TXT_INST_SEARCH_NOTES%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_DELETED_RECORDS%></td>
	<td><label for="IncludeDeleted"><input name="IncludeDeleted" id="IncludeDeleted" type="checkbox"<%If bIncludeDeleted Then%> checked<%End If%>> <%=TXT_INCLUDE_DELETED%></label></td>
</tr>
<%If user_bCanManageUsers And Not Nl(strSharedWithSLs) then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SHARED%></td>
	<td><%=TXT_INST_SHARE%>
	<%=strSharedWithSLs%></td>
</tr>
<%End If%>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_SUBMIT_UPDATES%>"><%If Not bNew Then %><input type="submit" name="Submit" value="<%=TXT_DELETE%>"><%End If%> <input type="reset" value="<%=TXT_RESET_FORM%>"></td>
</tr>
</table>
</form>

<%
Call makePageFooter(True)
%>
