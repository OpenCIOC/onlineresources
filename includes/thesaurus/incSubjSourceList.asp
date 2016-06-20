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
Dim cmdListSubjectSource, rsListSubjectSource

Sub openSubjectSourceListRst()
	Set cmdListSubjectSource = Server.CreateObject("ADODB.Command")
	With cmdListSubjectSource
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_THS_Source_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListSubjectSource = Server.CreateObject("ADODB.Recordset")
	With rsListSubjectSource
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSubjectSource
	End With
End Sub

Sub closeSubjectSourceListRst()
	If rsListSubjectSource.State <> adStateClosed Then
		rsListSubjectSource.Close
	End If
	Set cmdListSubjectSource = Nothing
	Set rsListSubjectSource = Nothing
End Sub

Function makeSubjectSourceList(intSelected, strSelectName, bIncludeBlank, bIncludeNew, bMultiple)
	Dim strReturn
	With rsListSubjectSource
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF And Not bIncludeNew Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & IIf(bMultiple," MULTIPLE",vbNullString) & ">"
			If bIncludeNew Then
				strReturn = strReturn & "<option value="""">" & TXT_CREATE_NEW & "</option>"
			ElseIf bIncludeBlank Then
				If bMultiple Then
					strReturn = strReturn & "<option value=""_X_"">" & TXT_UNKNOWN_NO_VALUE & "</option>"				
				Else
					strReturn = strReturn & "<option value=""""> -- </option>"
				End If
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("SRC_ID") & """"
				If intSelected = .Fields("SRC_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("SourceName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeSubjectSourceList = strReturn
End Function
%>

