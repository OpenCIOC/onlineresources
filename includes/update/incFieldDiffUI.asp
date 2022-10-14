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
Response.CacheControl = "no-cache"
%>
<!doctype html>
<html>
<body>
<div id="content_to_insert">
<%
Dim	strFieldName, _
	strID, _
	intLangID, _
	bNoData

bNoData = False
strFieldName = TrimAll(Request("FIELD"))
strID = TrimAll(Request("ID"))
intLangID = TrimAll(Request("LANG"))

If Nl(strID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
ElseIf ps_intDbArea=DM_CIC And Not IsNUMType(strID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strID) & ".", vbNullString, vbNullString)
ElseIf ps_intDbArea=DM_VOL And Not IsVNUMType(strID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strID) & ".", vbNullString, vbNullString)
Else

If Not Nl(strFieldName) Then
	If Nl(intLangID) Then
		intLangID = g_objCurrentLang.LangID
	ElseIf Not IsLangID(intLangID) Then
		intLangID = g_objCurrentLang.LangID
	End If
	Dim cmdFieldContent, rsFieldContent
	Set cmdFieldContent = Server.CreateObject("ADODB.Command")
	With cmdFieldContent
		.ActiveConnection = getCurrentAdminCnn()
		If ps_intDbArea = DM_VOL Then
			.CommandText = "dbo.sp_VOL_Opportunity_History_sf"
		Else
			.CommandText = "dbo.sp_GBL_BaseTable_History_sf"
		End If
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@FieldName", adVarChar, adParamInput, 100, strFieldName)
		If ps_intDbArea = DM_VOL Then
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strID)
		Else
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strID)
		End If
		.Parameters.Append .CreateParameter("@UserID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, ps_intDbAreaViewType)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 4, intLangID)
	End With

	Set rsFieldContent = cmdFieldContent.Execute 

	Dim bCanSeeHistory
	With rsFieldContent
		If Not .EOF Then
			bCanSeeHistory = .Fields("CAN_SEE_HISTORY")
		Else
			bCanSeeHistory = False
		End If
	End With

	If bCanSeeHistory Then

		Set rsFieldContent = rsFieldContent.NextRecordset
		If Not rsFieldContent.EOF Then
	%>
	<table class="NoBorder cell-padding-2">
	<tr><th><%= TXT_LANGUAGE %></th><th><%= TXT_REVISION_DATE %></th><th><%= TXT_COMPARE_WITH %></th></tr>
	<tr>
		<td>
			<select id="HistoryLanguage">
		<%
			With rsFieldContent
				While Not .EOF 
					%><option value="<%= .Fields("LangID")%>"><%= .Fields("LanguageName") %></option><%
					.MoveNext
				Wend
			End With
		%>
			</select>
		</td>
		<%
			Dim aHistory(), dicHistTmp, i, fld
			ReDim aHistory(-1)
			i = 0

			Set rsFieldContent = rsFieldContent.NextRecordset
			With rsFieldContent
				While Not .EOF
					ReDim Preserve aHistory(i)
					Set dicHistTmp = Server.CreateObject("Scripting.Dictionary")
					Set aHistory(i) = dicHistTmp
					For Each fld in .Fields
						dicHistTmp(fld.Name) = fld.Value
					Next
					.MoveNext
					i = i + 1
				Wend
			End With
		%>
		<td>
			<select id="HistoryRevision" class="HistorySelect">
		<%
			For i = 0 to UBound(aHistory)
				Set dicHistTmp = aHistory(i)	
				%><option value="<%= dicHistTmp("HST_ID") %>"><%= DateTimeString(dicHistTmp("MODIFIED_DATE"), True)%> (<%= dicHistTmp("MODIFIED_BY")%>)</option><%
			Next
		%>
			</select>
		</td>
		<td>
			<select id="HistoryCompare" class="HistorySelect">
			<option value=""> </option>
		<%
			For i = 0 to UBound(aHistory)
				Set dicHistTmp = aHistory(i)	
				%><option value="<%= dicHistTmp("HST_ID") %>"><%= DateTimeString(dicHistTmp("MODIFIED_DATE"), True)%> (<%= dicHistTmp("MODIFIED_BY")%>)</option><%
			Next
		%>
			</select>
		</td>
	</tr>
	</table>
	<div>
	<%
		Dim strFieldContent
		Set rsFieldContent = rsFieldContent.NextRecordset
		If Not rsFieldContent.EOF Then
			strFieldContent = rsFieldContent("FieldDisplay")
		End If
		If Not Nl(strFieldContent) Then
%>
<p id="HistoryFieldContent"><%=textToHTML(strFieldContent)%></p>
<%
		Else
%>
<p id="HistoryFieldContent"><em>(<%=TXT_FIELD_IS_EMPTY%>)</em></p>
<%
		End If
	%>
		
	</div>
	<%
		Else
			Call handleError(TXT_CANNOT_PRINT_FIELD_DATA & TXT_CANNOT_ACCESS_RECORD, vbNullString, vbNullString)
		End If

	Else
		Call handleError(TXT_CANNOT_PRINT_FIELD_DATA & TXT_CANNOT_ACCESS_RECORD, vbNullString, vbNullString)
	End If

	rsFieldContent.Close
	Set rsFieldContent = Nothing
	Set cmdFieldContent = Nothing
Else
	Call handleError(TXT_CANNOT_PRINT_FIELD_DATA & TXT_NO_FIELD_SELECTED, vbNullString, vbNullString)
End If

End If
%>
</div>
</body>
</html>
<%
'Call makePageFooter(False)
%>

