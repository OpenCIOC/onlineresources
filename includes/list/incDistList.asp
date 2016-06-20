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
Dim cmdListDist, rsListDist

Sub openDistListRst(bShowHidden)
	Set cmdListDist = Server.CreateObject("ADODB.Command")
	With cmdListDist
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_Distribution_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListDist = Server.CreateObject("ADODB.Recordset")
	With rsListDist
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListDist
	End With
End Sub

Sub closeDistListRst()
	If rsListDist.State <> adStateClosed Then
		rsListDist.Close
	End If
	Set cmdListDist = Nothing
	Set rsListDist = Nothing
End Sub

Function makeDistList(intSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn
	With rsListDist
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
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
					"<option value=""" & .Fields("DST_ID") & """"
				If intSelected = .Fields("DST_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & _
					.Fields("DistCode") & StringIf(Not Nl(.Fields("DistName"))," - " & .Fields("DistName")) & _
					"</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeDistList = strReturn
End Function

Function makeDistTableList(strSelectName)
	Dim strReturn, _
		intWrapNum, _
		intWrapAt

	With rsListDist
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
					"<td><input type=""checkbox"" name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName & "_" & .Fields("DST_ID")) & _
					" value=" & AttrQs(.Fields("DST_ID")) & ">&nbsp;" & _
					"<label for=" & AttrQs(strSelectName & "_" & .Fields("DST_ID")) & ">" & _
					.Fields("DistCode") & StringIf(Not Nl(.Fields("DistName"))," - " & .Fields("DistName")) & _
					"</label></td>"
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
	makeDistTableList = strReturn
End Function
%>
