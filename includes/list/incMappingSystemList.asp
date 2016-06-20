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
Dim cmdListMappingSystem, rsListMappingSystem

Sub openMappingSystemListRst(bAllLanguages)
	Set cmdListMappingSystem = Server.CreateObject("ADODB.Command")
	With cmdListMappingSystem
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_MappingSystem_l"
		.Parameters.Append .CreateParameter("@AllLanguages", adBoolean, adParamInput, 1, IIf(bAllLanguages,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListMappingSystem = Server.CreateObject("ADODB.Recordset")
	With rsListMappingSystem
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListMappingSystem
	End With
End Sub

Sub closeMappingSystemListRst()
	If rsListMappingSystem.State <> adStateClosed Then
		rsListMappingSystem.Close
	End If
	Set cmdListMappingSystem = Nothing
	Set rsListMappingSystem = Nothing
End Sub

Function makeMappingSystemList(intSelected, strSelectName, bIncludeBlank, bIncludeNew, strOnChange)
	Dim strReturn
	With rsListMappingSystem
		If .RecordCount = 0 And Not bIncludeNew Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			If .RecordCount <> 0 Then
				.MoveFirst
			End If
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"""
			If Not Nl(strOnChange) Then
				strReturn = strReturn & " onChange=""" & strOnChange & """"
			End If
			strReturn = strReturn & ">"
			If bIncludeNew Then
				strReturn = strReturn & "<option value="""">" & TXT_CREATE_NEW & "</option>"
			ElseIf bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("MAP_ID") & """"
				If intSelected = .Fields("MAP_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("MappingSystemName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeMappingSystemList = strReturn
End Function
%>

