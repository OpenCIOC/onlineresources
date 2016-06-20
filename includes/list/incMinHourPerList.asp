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
Dim cmdListMinHoursPer, rsListMinHoursPer

Sub openMinHoursPerListRst()
	Set cmdListMinHoursPer = Server.CreateObject("ADODB.Command")
	With cmdListMinHoursPer
		.ActiveConnection = getCurrentBasicCnn()
		.CommandText = "dbo.sp_VOL_MinHoursPer_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListMinHoursPer = Server.CreateObject("ADODB.Recordset")
	With rsListMinHoursPer
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListMinHoursPer
	End With
End Sub

Sub closeMinHoursPerListRst()
	If rsListMinHoursPer.State <> adStateClosed Then
		rsListMinHoursPer.Close
	End If
	Set cmdListMinHoursPer = Nothing
	Set rsListMinHoursPer = Nothing
End Sub

Function makeMinHoursPerList(strSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListMinHoursPer
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " autocomplete=""off"" class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("HPER_ID") & """"
				If strSelected = .Fields("HPER_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("Name") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeMinHoursPerList = strReturn
End Function
%>
