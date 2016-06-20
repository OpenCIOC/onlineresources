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
Dim cmdListDetailFieldGroups, rsListDetailFieldGroups

Sub openDetailFieldGroupsListRst(intViewType, intDomain)
	Set cmdListDetailFieldGroups = Server.CreateObject("ADODB.Command")
	With cmdListDetailFieldGroups
		.ActiveConnection = getCurrentAdminCnn()
		Select Case intDomain
			Case DM_CIC
				.CommandText = "dbo.sp_CIC_View_DisplayFieldGroup_l"
		End Select
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
	End With
	Set rsListDetailFieldGroups = Server.CreateObject("ADODB.Recordset")
	With rsListDetailFieldGroups
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListDetailFieldGroups
	End With
End Sub

Sub closeDetailFieldGroupsListRst()
	If rsListDetailFieldGroups.State <> adStateClosed Then
		rsListDetailFieldGroups.Close
	End If
	Set cmdListDetailFieldGroups = Nothing
	Set rsListDetailFieldGroups = Nothing
End Sub

Function makeDetailFieldGroupsList(intSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListDetailFieldGroups
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
					"<option value=""" & .Fields("DisplayFieldGroupID") & """"
				If intSelected = .Fields("DisplayFieldGroupID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("DisplayFieldGroupName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeDetailFieldGroupsList = strReturn
End Function
%>
