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
ElseIf ps_intDbArea = DM_CIC And Not IsNUMType(strID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strID) & ".", vbNullString, vbNullString)
ElseIf ps_intDbArea = DM_VOL And Not IsIDType(strID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strID) & ".", vbNullString, vbNullString)
Else
	If Nl(intLangID) Then
		intLangID = g_objCurrentLang.LangID
	ElseIf Not IsLangID(intLangID) Then
		intLangID = g_objCurrentLang.LangID
	End If
	Dim cmdFieldContent, rsFieldContent
	Set cmdFieldContent = Server.CreateObject("ADODB.Command")
	With cmdFieldContent
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_" & IIf(ps_intDbArea=DM_VOL, "VOL_Opportunity", "GBL_BaseTable") & "_History_sl"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
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
			%><ul><%
			Dim dModifiedDate, dLastModifiedDate, strModifiedBy, strLastModifiedBy
			With rsFieldContent
				dModifiedDate = .Fields("MODIFIED_DATE")
				strModifiedBy = .Fields("MODIFIED_BY")
				dLastModifiedDate = dModifiedDate
				strLastModifiedBy = strModifiedBy

				While Not .EOF 
					%><li><span class="HistoryFieldsToggle SimulateLink"><%= DateTimeString(dModifiedDate, True) %> (<%= strModifiedBy %>)</span> <ul><%
					While Not .EOF And dLastModifiedDate = dModifiedDate And strLastModifiedBy = strModifiedBy 
						%><li><span class="FieldHistoryJump SimulateLink" data-fieldname="<%= .Fields("FieldName") %>"><%= .Fields("FieldDisplay") %></span></li><%
						.MoveNext
						If Not .EOF Then
							dModifiedDate = .Fields("MODIFIED_DATE")
							strModifiedBy = .Fields("MODIFIED_BY")
						End If
					Wend
					%></ul></li><%
					dLastModifiedDate = dModifiedDate
					strLastModifiedBy = strModifiedBy
				Wend
			End With
			%></ul><%
		Else
			Call handleError(TXT_CANNOT_PRINT_FIELD_DATA & TXT_NO_FIELD_HISTORY, vbNullString, vbNullString)
		End If

	Else
		Call handleError(TXT_CANNOT_PRINT_FIELD_DATA & TXT_CANNOT_ACCESS_RECORD, vbNullString, vbNullString)
	End If

	rsFieldContent.Close
	Set rsFieldContent = Nothing
	Set cmdFieldContent = Nothing
End If

%>
<%
'Call makePageFooter(False)
%>
</div>
</body>
</html>

