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
Dim cmdListStreetDir, rsListStreetDir

Sub openStreetDirListRst()
	Set cmdListStreetDir = Server.CreateObject("ADODB.Command")
	With cmdListStreetDir
		.ActiveConnection = getCurrentBasicCnn()
		.CommandText = "dbo.sp_GBL_StreetDir_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListStreetDir = Server.CreateObject("ADODB.Recordset")
	With rsListStreetDir
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListStreetDir
	End With
End Sub

Sub closeStreetDirListRst()
	If rsListStreetDir.State <> adStateClosed Then
		rsListStreetDir.Close
	End If
	Set cmdListStreetDir = Nothing
	Set rsListStreetDir = Nothing
End Sub

Function makeStreetDirList(strSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListStreetDir
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If Not .EOF Then
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " autocomplete=""off"" class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("Dir") & """"
				If strSelected = .Fields("Dir") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("DirName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeStreetDirList = strReturn
End Function

%>
