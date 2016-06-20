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

Dim cmdListOrgLocationService, rsListOrgLocationService

Sub openOrgLocationServiceListRst()

	Set cmdListOrgLocationService = Server.CreateObject("ADODB.Command")
	
	With cmdListOrgLocationService
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_OrgLocationService_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	
	Set rsListOrgLocationService = Server.CreateObject("ADODB.Recordset")
	With rsListOrgLocationService
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListOrgLocationService
	End With
	
	Set cmdListOrgLocationService = Nothing
End Sub

Sub closeOrgLocationServiceListRst()
	If rsListOrgLocationService.State <> adStateClosed Then
		rsListOrgLocationService.Close
	End If
	Set cmdListOrgLocationService = Nothing
	Set rsListOrgLocationService = Nothing
End Sub

Function makeOrgLocationServiceList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn
	With rsListOrgLocationService
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
					"<option value=""" & .Fields("OLS_ID") & """"
				If strSelected = .Fields("OLS_ID") Then
					strReturn = strReturn & " SELECTED"
				End If
				strReturn = strReturn & ">" & .Fields("OrgLocationService") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeOrgLocationServiceList = strReturn
End Function
%>
