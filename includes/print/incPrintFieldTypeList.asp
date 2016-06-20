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
Dim cmdFieldTypeList, rsFieldTypeList

Sub openFieldTypeListRst()
	Set cmdFieldTypeList = Server.CreateObject("ADODB.Command")
	With cmdFieldTypeList
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_PrintProfile_Fld_Type_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsFieldTypeList = Server.CreateObject("ADODB.Recordset")
	With rsFieldTypeList
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdFieldTypeList
	End With
End Sub

Sub closeFieldTypeListRst()
	If rsFieldTypeList.State <> adStateClosed Then
		rsFieldTypeList.Close
	End If
	Set cmdFieldTypeList = Nothing
	Set rsFieldTypeList = Nothing
End Sub

Function makeFieldTypeList(intSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsFieldTypeList
		If .RecordCount <> 0 Then
			.MoveFirst		
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("FieldTypeID") & """"
				If intSelected = .Fields("FieldTypeID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("FieldType") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeFieldTypeList = strReturn
End Function
%>
