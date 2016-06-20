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
Dim cmdListActivityStatus, rsListActivityStatus

Sub openActivityStatusListRst(bAllLanguages)
	Set cmdListActivityStatus = Server.CreateObject("ADODB.Command")
	With cmdListActivityStatus
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_Activity_Status_l"
		.Parameters.Append .CreateParameter("@AllLanguages", adBoolean, adParamInput, 1, IIf(bAllLanguages,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListActivityStatus = Server.CreateObject("ADODB.Recordset")
	With rsListActivityStatus
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListActivityStatus
	End With
End Sub

Sub closeActivityStatusListRst()
	If rsListActivityStatus.State <> adStateClosed Then
		rsListActivityStatus.Close
	End If
	Set cmdListActivityStatus = Nothing
	Set rsListActivityStatus = Nothing
End Sub

Function makeActivityStatusList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn
	With rsListActivityStatus
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
					"<option value=""" & .Fields("ASTAT_ID") & """"
				If strSelected = .Fields("ASTAT_ID") Then
					strReturn = strReturn & " SELECTED"
				End If
				strReturn = strReturn & ">" & .Fields("Status") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeActivityStatusList = strReturn
End Function
%>
