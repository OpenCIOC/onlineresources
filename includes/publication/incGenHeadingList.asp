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
Dim strListGenHeadingPub
Dim cmdListGenHeading, rsListGenHeading

Sub openGenHeadingListRst(intPBID, bUsed, bNonPublic, bIncludePub)
	Set cmdListGenHeading = Server.CreateObject("ADODB.Command")
	With cmdListGenHeading
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_GeneralHeading_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@PB_ID", adInteger, adParamInput, 4, intPBID)
		.Parameters.Append .CreateParameter("@Used", adBoolean, adParamInput, 1, IIf(Nl(bUsed),Null,IIf(bUsed,SQL_TRUE,SQL_FALSE)))
		.Parameters.Append .CreateParameter("@NonPublic", adBoolean, adParamInput, 1, IIf(bNonPublic,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@IncludePubName", adBoolean, adParamInput, 1, IIf(bIncludePub,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListGenHeading = Server.CreateObject("ADODB.Recordset")
	With rsListGenHeading
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListGenHeading
	End With

	strListGenHeadingPub = vbNullString
	If bIncludePub Then
		If Not rsListGenHeading.EOF Then
			strListGenHeadingPub = rsListGenHeading.Fields("PubName")
		End If
		Set rsListGenHeading = rsListGenHeading.NextRecordset
	End If
End Sub

Sub closeGenHeadingListRst()
	If rsListGenHeading.State <> adStateClosed Then
		rsListGenHeading.Close
	End If
	Set cmdListGenHeading = Nothing
	Set rsListGenHeading = Nothing
End Sub

Function makeGenHeadingList(intSelected, strSelectName, bIncludeBlank, bIncludeNew)
	Dim strReturn
	With rsListGenHeading
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF And Not bIncludeNew Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & ">"
			If bIncludeNew Then
				strReturn = strReturn & "<option value="""">" & TXT_CREATE_NEW & "</option>"
			ElseIf bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			Dim strGenHeadingName
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("GH_ID") & """"
				If intSelected = .Fields("GH_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("GeneralHeading") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeGenHeadingList = strReturn
End Function

Function makeGenHeadingTableList(strSelectName, intWrapAt, strTableAdd)
	Dim strReturn, intWrapNum
	With rsListGenHeading
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
			Dim strGenHeadingName
			While Not .EOF
				If intWrapNum = intWrapAt Then
					strReturn = strReturn & "<tr valign=""top"">"
				End If
				strReturn = strReturn & vbCrLf & "<td><input type=""checkbox"" name=" & AttrQs(strSelectName) & " value=""" & _
					.Fields("GH_ID") & """>&nbsp;" & .Fields("GeneralHeading")
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
	makeGenHeadingTableList = strReturn
End Function
%>
