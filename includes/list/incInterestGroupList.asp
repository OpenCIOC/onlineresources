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
Dim cmdListInterestGroup, rsListInterestGroup

Sub openInterestGroupListRst()
	Set cmdListInterestGroup = Server.CreateObject("ADODB.Command")
	With cmdListInterestGroup
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "dbo.sp_VOL_InterestGroup_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListInterestGroup = Server.CreateObject("ADODB.Recordset")
	With rsListInterestGroup
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListInterestGroup
	End With
End Sub

Sub closeInterestGroupListRst()
	If rsListInterestGroup.State <> adStateClosed Then
		rsListInterestGroup.Close
	End If
	Set cmdListInterestGroup = Nothing
	Set rsListInterestGroup = Nothing
End Sub

Function makeInterestGroupList(intSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListInterestGroup
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
					"<option value=""" & .Fields("IG_ID") & """"
				If intSelected = .Fields("IG_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("InterestGroupName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeInterestGroupList = strReturn
End Function

Function makeInterestGroupTableList(strSelectName)
	Dim strReturn, _
		intWrapNum, _
		intWrapAt

	With rsListInterestGroup
		If .RecordCount > 0 Then
			If .RecordCount > 50 Then
				intWrapAt = 2
			ElseIf .RecordCount > 14 Then
				intWrapAt = 1
			Else
				intWrapAt = 0
			End If
			.MoveFirst
		End If

		intWrapNum = intWrapAt

		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = "<table class=""NoBorder cell-padding-2"">"
			While Not .EOF
				If intWrapNum = intWrapAt Then
					strReturn = strReturn & "<tr valign=""top"">"
				End If
				strReturn = strReturn & _
					"<td><input type=""checkbox"" name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName & "_" & .Fields("IG_ID")) & _
					" value=" & AttrQs(.Fields("IG_ID")) & ">&nbsp;" & _
					"<label for=" & AttrQs(strSelectName & "_" & .Fields("IG_ID")) & ">" & .Fields("InterestGroupName") & "</label></td>"
				If intWrapNum > 0 Then
					intWrapNum = intWrapNum - 1
				Else
					strReturn = strReturn & "</tr>"
					intWrapNum = intWrapAt
				End If
				.MoveNext
			Wend
			strReturn = strReturn & "</table>"
		End If
	End With
	makeInterestGroupTableList = strReturn
End Function
%>
