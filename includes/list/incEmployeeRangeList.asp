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
Dim cmdListEmployeeRange, rsListEmployeeRange

Sub openEmployeeRangeListRst()
	Set cmdListEmployeeRange = Server.CreateObject("ADODB.Command")
	With cmdListEmployeeRange
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_EmployeeRange_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListEmployeeRange = Server.CreateObject("ADODB.Recordset")
	With rsListEmployeeRange
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListEmployeeRange
	End With
End Sub

Sub closeEmployeeRangeListRst()
	If rsListEmployeeRange.State <> adStateClosed Then
		rsListEmployeeRange.Close
	End If
	Set cmdListEmployeeRange = Nothing
	Set rsListEmployeeRange = Nothing
End Sub

Function makeEmployeeRangeList(strSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListEmployeeRange
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("ER_ID") & """"
				If strSelected = .Fields("ER_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("Range") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeEmployeeRangeList = strReturn
End Function
%>
