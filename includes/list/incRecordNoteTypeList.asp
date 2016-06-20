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
Dim cmdListRecordNoteType, rsListRecordNoteType

Sub openRecordNoteTypeListRst()
	Set cmdListRecordNoteType = Server.CreateObject("ADODB.Command")
	With cmdListRecordNoteType
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_RecordNote_Type_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListRecordNoteType = Server.CreateObject("ADODB.Recordset")
	With rsListRecordNoteType
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListRecordNoteType
	End With
End Sub

Sub closeRecordNoteTypeListRst()
	If rsListRecordNoteType.State <> adStateClosed Then
		rsListRecordNoteType.Close
	End If
	Set cmdListRecordNoteType = Nothing
	Set rsListRecordNoteType = Nothing
End Sub

Function makeRecordNoteTypeList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn, strCon
	With rsListRecordNoteType
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"""
			If Not Nl(strOnChange) Then
				strReturn = strReturn & " onChange=""" & strOnChange & """"
			End If
			strReturn = strReturn & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("NoteTypeID") & """"
				If strSelected = .Fields("NoteTypeID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & StringIf(.Fields("HighPriority"),"[ ! ] ") & .Fields("NoteTypeName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeRecordNoteTypeList = strReturn
End Function

%>
