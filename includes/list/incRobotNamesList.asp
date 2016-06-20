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
Dim cmdListRobotNames, rsListRobotNames

Sub openRobotNamesListRst()
	Set cmdListRobotNames = Server.CreateObject("ADODB.Command")
	With cmdListRobotNames
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_Robot_Name_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListRobotNames = Server.CreateObject("ADODB.Recordset")
	With rsListRobotNames
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListRobotNames
	End With
End Sub

Sub closeRobotNamesListRst()
	If rsListRobotNames.State <> adStateClosed Then
		rsListRobotNames.Close
	End If
	Set cmdListRobotNames = Nothing
	Set rsListRobotNames = Nothing
End Sub

Function makeRobotNamesList(strSelected, strSelectName, strExtraOptions, strOptGroupLabel)
	Dim strReturn
	With rsListRobotNames
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"">" & vbCrLf
			If Not Nl(strExtraOptions) Then
				strReturn = strReturn & strExtraOptions
			End If
			If Not Nl(strOptGroupLabel) Then
				strReturn = strReturn & "<optgroup label=" & AttrQs(strOptGroupLabel) & ">" & vbCrLf
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("RobotID") & """"
				If strSelected = .Fields("RobotID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & _
					IIf(Not Nl(.Fields("DisplayName")),Server.HTMLEncode(.Fields("DisplayName")),Server.HTMLEncode(Ns(.Fields("Name")))) & "</option>" & vbCrLf
				.MoveNext
			Wend
			If Not Nl(strOptGroupLabel) Then
				strReturn = strReturn & "</optgroup>"
			End If
			strReturn = strReturn & "</select>"
		End If
	End With
	makeRobotNamesList = strReturn
End Function
%>
