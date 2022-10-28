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
Dim cmdListPub, rsListPub

Sub openPubListRst(bHasHeadings, bUsedHeadings)
	Set cmdListPub = Server.CreateObject("ADODB.Command")
	With cmdListPub
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_CIC_Publication_l"
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@HasHeadings", adBoolean, adParamInput, 1, IIf(bHasHeadings,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@UsedHeadings", adBoolean, adParamInput, 1, IIf(Nl(bUsedHeadings),Null,IIf(bUsedHeadings,SQL_TRUE,SQL_FALSE)))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListPub = Server.CreateObject("ADODB.Recordset")
	With rsListPub
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListPub
	End With
End Sub

Sub closePubListRst()
	If rsListPub.State <> adStateClosed Then
		rsListPub.Close
	End If
	Set cmdListPub = Nothing
	Set rsListPub = Nothing
End Sub

Function makePubList(intSelected, intExcluded, strSelectName, strSelectID ,bNonPublic, bIncludeBlank, bIncludeNew)
	Dim strReturn
	With rsListPub
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If Nl(strSelectID) Then
			strSelectID = strSelectName
		End If
		If .EOF And Not bIncludeNew Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectID) & " class=""form-control"">"
			If bIncludeNew Then
				strReturn = strReturn & "<option value="""">" & TXT_CREATE_NEW & "</option>"
			ElseIf bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			Dim strPubName
			While Not .EOF
				If intExcluded <> .Fields("PB_ID") Then
					If g_bUsePubNamesOnly Then
						strPubName = .Fields("PubName")
					Else
						strPubName = .Fields("PubCode") & _
						IIf(Nl(.Fields("PubName")),vbNullString," - " & .Fields("PubName"))
					End If
					If Nl(bNonPublic) Or bNonPublic Then
						strPubName = strPubName & IIf(.Fields("NonPublic")," *",vbNullString)
					End If
					strReturn = strReturn & _
						"<option value=""" & .Fields("PB_ID") & """"
					If intSelected = .Fields("PB_ID") Then
						strReturn = strReturn & " selected"
					End If
					strReturn = strReturn & ">" & strPubName & "</option>"
				End If
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makePubList = strReturn
End Function

Function makePubTableList(strSelectName, bNonPublic, intWrapAt, strTableAdd)
	Dim strReturn, intWrapNum
	With rsListPub
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			If intWrapAt > 0 Then
				intWrapAt = intWrapAt - 1
			Else
				intWrapAt = 0
			End If
			intWrapNum = intWrapAt
			strReturn = strReturn & "<table class=""NoBorder cell-padding-2"" " & strTableAdd & ">"
			Dim strPubName
			While Not .EOF
				If intWrapNum = intWrapAt Then
					strReturn = strReturn & "<tr valign=""top"">"
				End If
				strPubName = .Fields("PubName")
				If Nl(strPubName) Then
					strPubName = .Fields("PubCode")
				End If
				If Nl(bNonPublic) Or bNonPublic Then
					strPubName = strPubName & IIf(.Fields("NonPublic")," *",vbNullString)
				End If
				strReturn = strReturn & vbCrLf & "<td><input type=""checkbox"" name=" & AttrQs(strSelectName) & " value=""" & _
					.Fields("PB_ID") & """>&nbsp;" & strPubName
				strReturn = strReturn & "</td>"
				If intWrapNum > 0 Then
					intWrapNum = intWrapNum - 1
				Else
					strReturn = strReturn & "</tr>"
					intWrapNum = intWrapAt
				End If
				.MoveNext
			Wend
			If intWrapNum <> intWrapAt Then
				strReturn = strReturn & "</tr>"
			End If
			strReturn = strReturn & vbCrLf & "</table>"
		End If
	End With
	makePubTableList = strReturn
End Function
%>
