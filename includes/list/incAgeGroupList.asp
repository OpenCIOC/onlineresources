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
Dim cmdListAgeGroup, rsListAgeGroup

Sub openAgeGroupListRst(bCCR)
	Set cmdListAgeGroup = Server.CreateObject("ADODB.Command")
	With cmdListAgeGroup
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_GBL_AgeGroup_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@CCR", adBoolean, adParamInput, 1, IIf(bCCR,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListAgeGroup = Server.CreateObject("ADODB.Recordset")
	With rsListAgeGroup
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListAgeGroup
	End With
End Sub

Sub closeAgeGroupListRst()
	If rsListAgeGroup.State <> adStateClosed Then
		rsListAgeGroup.Close
	End If
	Set cmdListAgeGroup = Nothing
	Set rsListAgeGroup = Nothing
End Sub

Function makeAgeGroupList(intSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListAgeGroup
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("AgeGroup_ID") & """"
				If intSelected = .Fields("AgeGroup_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("AgeGroupName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeAgeGroupList = strReturn
End Function
%>

