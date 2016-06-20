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
Dim cmdListBoxType, rsListBoxType

Sub openBoxTypeListRst()
	Set cmdListBoxType = Server.CreateObject("ADODB.Command")
	With cmdListBoxType
		.ActiveConnection = getCurrentBasicCnn()
		.CommandText = "dbo.sp_GBL_BoxType_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListBoxType = Server.CreateObject("ADODB.Recordset")
	With rsListBoxType
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListBoxType
	End With
End Sub

Sub closeBoxTypeListRst()
	If rsListBoxType.State <> adStateClosed Then
		rsListBoxType.Close
	End If
	Set cmdListBoxType = Nothing
	Set rsListBoxType = Nothing
End Sub

Function makeBoxTypeList(strSelected, strSelectName, bIncludeBlank)
	Dim bTypeFound
	bTypeFound = False
	Dim strReturn
	With rsListBoxType
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
					"<option value=""" & .Fields("BoxType") & """"
				If strSelected = .Fields("BoxType") Then
					bTypeFound = True
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("BoxType") & "</option>"
				.MoveNext
			Wend
			If Not bTypeFound And Not Nl(strSelected) Then
				strReturn = strReturn & "<option value=" & AttrQs(strSelected) & " SELECTED>" & strSelected & "</option>"
			End If
			strReturn = strReturn & "</select>"
		End If
	End With
	makeBoxTypeList = strReturn
End Function
%>
