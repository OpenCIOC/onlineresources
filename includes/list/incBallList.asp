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
Dim cmdListVolBall, rsListVolBall

Sub openVolBallListRst()
	Set cmdListVolBall = Server.CreateObject("ADODB.Command")
	With cmdListVolBall
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "dbo.sp_VOL_Ball_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListVolBall = Server.CreateObject("ADODB.Recordset")
	With rsListVolBall
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListVolBall
	End With
End Sub

Sub closeVolBallListRst()
	If rsListVolBall.State <> adStateClosed Then
		rsListVolBall.Close
	End If
	Set cmdListVolBall = Nothing
	Set rsListVolBall = Nothing
End Sub

Function makeVolBallList(intSelected, strSelectName, strSelectID, bIncludeBlank)
	Dim strReturn
	With rsListVolBall
		If Nl(strSelectID) Then
			strSelectID = strSelectName
		End If
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectID) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			Dim strVolBallName
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("BallID") & """"
				If intSelected = .Fields("BallID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("Colour") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeVolBallList = strReturn
End Function
%>
