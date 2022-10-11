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
Dim strListGroupNames
Dim cmdListInterest, rsListInterest

Sub openInterestListRstCountInView()
	Set cmdListInterest = Server.CreateObject("ADODB.Command")
	With cmdListInterest
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "dbo.sp_VOL_Interest_lc"
		.Parameters.Append .CreateParameter("@Viewtype", adInteger, adParamInput, 4, g_intViewTypeVOL)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListInterest = Server.CreateObject("ADODB.Recordset")
	With rsListInterest
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListInterest
	End With

	strListGroupNames = vbNullString
End Sub

Sub openInterestListRst(strIGIDList, bGroupByGroup, bIncludeGroup)
	Set cmdListInterest = Server.CreateObject("ADODB.Command")
	With cmdListInterest
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "dbo.sp_VOL_Interest_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@IGIDList", adLongVarChar, adParamInput, -1, Nz(strIGIDList,Null))
		.Parameters.Append .CreateParameter("@GroupByGroup", adBoolean, adParamInput, 1, IIf(bGroupByGroup,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@IncludeIGListNames", adBoolean, adParamInput, 1, IIf(bIncludeGroup,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListInterest = Server.CreateObject("ADODB.Recordset")
	With rsListInterest
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListInterest
	End With

	strListGroupNames = vbNullString
	If bIncludeGroup Then
		If Not rsListInterest.EOF Then
			strListGroupNames = rsListInterest.Fields("GroupNames")
		End If
		Set rsListInterest = rsListInterest.NextRecordset
	End If
End Sub

Sub closeInterestListRst()
	If rsListInterest.State <> adStateClosed Then
		rsListInterest.Close
	End If
	Set cmdListInterest = Nothing
	Set rsListInterest = Nothing
End Sub

Function makeInterestList(intSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListInterest
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
					"<option value=""" & .Fields("AI_ID") & """"
				If intSelected = .Fields("AI_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("InterestName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeInterestList = strReturn
End Function

Function makeInterestTableList(strSelectName)
	Dim strReturn, _
		intWrapNum, _
		intWrapAt

	With rsListInterest
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
			strReturn = "<table class=""NoBorder cell-padding-2"" >"
			While Not .EOF
				If intWrapNum = intWrapAt Then
					strReturn = strReturn & "<tr valign=""top"">"
				End If
				strReturn = strReturn & _
					"<td><input type=""checkbox"" name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName & "_" & .Fields("AI_ID")) & _
					" value=" & AttrQs(.Fields("AI_ID")) & ">&nbsp;" & _
					"<label for=" & AttrQs(strSelectName & "_" & .Fields("AI_ID")) & ">" & .Fields("InterestName") & "</label></td>"
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
	makeInterestTableList = strReturn
End Function
%>

