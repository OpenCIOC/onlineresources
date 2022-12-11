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
'
' Purpose: 		Display a drop-down list of a user's own saved searches
'
%>

<%
Call addScript(ps_strPathToStart & makeAssetVer("scripts/savedSearchInfo.js"), "text/javascript")

Dim cmdListSearch, rsSearchComm, rsListSearch, rsListSharedSearch

Sub openSearchListRst(user_intID, intDomain)
	Set cmdListSearch = Server.CreateObject("ADODB.Command")
	With cmdListSearch
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_SavedSearch_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, intDomain)
	End With
	Set rsListSearch = Server.CreateObject("ADODB.Recordset")
	With rsListSearch
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSearch
	End With
End Sub

Sub closeSearchListRst()
	If rsListSearch.State <> adStateClosed Then
		rsListSearch.Close
	End If
	Set cmdListSearch = Nothing
	Set rsListSearch = Nothing
End Sub

Sub openSharedSearchListRst(intDomain)
	Set cmdListSearch = Server.CreateObject("ADODB.Command")
	With cmdListSearch
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_SavedSearch_l_Shared"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, intDomain)
	End With
	Set rsListSharedSearch = Server.CreateObject("ADODB.Recordset")
	With rsListSharedSearch
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSearch
	End With
End Sub

Sub closeSharedSearchListRst()
	If rsListSharedSearch.State <> adStateClosed Then
		rsListSharedSearch.Close
	End If
	Set cmdListSearch = Nothing
	Set rsListSearch = Nothing
End Sub

Function makeSearchList(intSelected, strSelectName, strJSName, bIncludeBlank, intExcludeID)
	Dim strReturn, _
		strJS

	With rsListSearch
		If .RecordCount = 0 Then
			strReturn = TXT_NO_SAVED_SEARCHES
		Else
			If Not .RecordCount = 0 Then
				.MoveFirst
			End If
			strReturn = strReturn & "<select id=" & AttrQs(strSelectName & "_" & strJSName) & " name=" & AttrQs(strSelectName) & " title=" & AttrQs(TXT_EXECUTE_OR_EDIT_SEARCH) & "class=""form-control"" onChange=""changeList('" & strJSName & "',this,false);"">"
			strJS = "<script type='text/javascript'>" & vbCrLf & _
				"newSavedSearchList(" & JsQs(strJSName) & ");"
			
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				If Nl(intExcludeID) Or .Fields("SSrch_ID") <> intExcludeID Then
					strReturn = strReturn & _
						"<option value=""" & .Fields("SSrch_ID") & """"
					If intSelected = .Fields("SSrch_ID") Then
						strReturn = strReturn & " selected"
					End If
					strReturn = strReturn & ">" & .Fields("Searchname") & IIf(.Fields("Shared")," *",vbNullString) & "</option>"
					strJS = strJS & vbCrLf & "newSavedSearch(" & _
						JsQs(strJsName) & "," & _
						JsQs(.Fields("SSrch_ID")) & "," & _
						JsQs(.Fields("Searchname")) & "," & _
						JsQs(Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN)) & "," & _
						JsQs(user_strLogin) & "," & _
						JsQs(.Fields("Notes")) & ");"
				End If
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
			strJS = strJS & vbCrLf & "</script>" 
			
			strReturn = strJS & vbCrLf & strReturn
		End If
	End With
	makeSearchList = strReturn
End Function

Function makeSharedSearchList(intSelected, strSelectName, strJSName, bIncludeBlank, intExcludeID)
	Dim strReturn, _
		strJS

	With rsListSharedSearch
		If .RecordCount = 0 Then
			strReturn = TXT_NO_SHARED_SEARCHES
		Else
			If Not .RecordCount = 0 Then
				.MoveFirst
			End If
			
			strReturn = strReturn & "<select id=" & AttrQs(strSelectName & "_" & strJSName) & " name=" & AttrQs(strSelectName) & " title=" & AttrQs(TXT_SHARED_SEARCHES) & "class=""form-control"" onChange=""changeList('" & strJSName & "',this,true);"">"
			strJS = "<script type='text/javascript'>" & vbCrLf & _
				"newSavedSearchList(" & JsQs(strJSName) & ");"

			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			
			While Not .EOF
				If Nl(intExcludeID) Or .Fields("SSrch_ID") <> intExcludeID Then
					strReturn = strReturn & _
						"<option value=""" & .Fields("SSrch_ID") & """"
					If intSelected = .Fields("SSrch_ID") Then
						strReturn = strReturn & " selected"
					End If
					strReturn = strReturn & ">" & .Fields("Searchname") & "</option>"
					strJS = strJS & vbCrLf & "newSavedSearch(" & _
						JsQs(strJsName) & "," & _
						JsQs(.Fields("SSrch_ID")) & "," & _
						JsQs(.Fields("Searchname")) & "," & _
						JsQs(Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN)) & "," & _
						JsQs(.Fields("UserName")) & "," & _
						JsQs(.Fields("Notes")) & ");"
				End If
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
			strJS = strJS & vbCrLf & "</script>" 
			
			strReturn = strJS & vbCrLf & strReturn
		End If
	End With
	
	makeSharedSearchList = strReturn
End Function
%>
