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
Dim cmdListSignatureStatus, rsListSignatureStatus

Sub openSignatureStatusListRst()
	Set cmdListSignatureStatus = Server.CreateObject("ADODB.Command")
	With cmdListSignatureStatus
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_SignatureStatus_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListSignatureStatus = Server.CreateObject("ADODB.Recordset")
	With rsListSignatureStatus
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSignatureStatus
	End With
End Sub

Sub closeSignatureStatusListRst()
	If rsListSignatureStatus.State <> adStateClosed Then
		rsListSignatureStatus.Close
	End If
	Set cmdListSignatureStatus = Nothing
	Set rsListSignatureStatus = Nothing
End Sub

Function makeSignatureStatusList(strSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListSignatureStatus
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("SIG_ID") & """"
				If strSelected = .Fields("SIG_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("Name") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeSignatureStatusList = strReturn
End Function
%>
