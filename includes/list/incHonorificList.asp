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
Dim cmdListHonorific, rsListHonorific

Sub openHonorificListRst()
	Set cmdListHonorific = Server.CreateObject("ADODB.Command")
	With cmdListHonorific
		.ActiveConnection = getCurrentBasicCnn()
		.CommandText = "dbo.sp_GBL_Contact_Honorific_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListHonorific = Server.CreateObject("ADODB.Recordset")
	With rsListHonorific
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListHonorific
	End With
End Sub

Sub closeHonorificListRst()
	If rsListHonorific.State <> adStateClosed Then
		rsListHonorific.Close
	End If
	Set cmdListHonorific = Nothing
	Set rsListHonorific = Nothing
End Sub

Function makeHonorificList(strSelected, strSelectName, bIncludeBlank, bIncludeAsterisk)
	Dim bTypeFound
	bTypeFound = False
	Dim strReturn
	With rsListHonorific
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			If bIncludeAsterisk Then
				strReturn = strReturn & "<option value=""*"">*</option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("Honorific") & """"
				If Not bTypeFound And strSelected = .Fields("Honorific") Then
					bTypeFound = True
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("Honorific") & "</option>"
				.MoveNext
			Wend
			If Not bTypeFound And Not Nl(strSelected) Then
				strReturn = strReturn & "<option value=" & AttrQs(strSelected) & " SELECTED>" & strSelected & "</option>"
			End If
			strReturn = strReturn & "</select>"
		End If
	End With
	makeHonorificList = strReturn
End Function
%>
