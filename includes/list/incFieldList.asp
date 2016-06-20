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
Dim cmdFieldList, rsFieldList

Sub openFieldListRst(intDomain)
	Set cmdFieldList = Server.CreateObject("ADODB.Command")
	With cmdFieldList
		.ActiveConnection = getCurrentAdminCnn()
		Select Case intDomain
			Case DM_CIC
				.CommandText = "dbo.sp_CIC_Fields_l"
			Case DM_VOL
				.CommandText = "dbo.sp_VOL_Fields_l"
			Case Else
				.CommandText = "dbo.sp_GBL_Fields_l"
		End Select
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsFieldList = Server.CreateObject("ADODB.Recordset")
	With rsFieldList
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdFieldList
	End With
End Sub

Sub closeFieldListRst()
	If rsFieldList.State <> adStateClosed Then
		rsFieldList.Close
	End If
	Set cmdFieldList = Nothing
	Set rsFieldList = Nothing
End Sub

Function makeFieldList(intSelected, strSelectName, bUseID, bIncludeBlank)
	Dim strReturn
	With rsFieldList
		If .RecordCount <> 0 Then
			.MoveFirst		
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				If bUseID Then
					strReturn = strReturn & _
						"<option value=""" & .Fields("FieldID") & """"
					If intSelected = .Fields("FieldID") Then
						strReturn = strReturn & " selected"
					End If
				Else
					strReturn = strReturn & _
						"<option value=""" & .Fields("FieldName") & """"
					If intSelected = .Fields("FieldName") Then
						strReturn = strReturn & " selected"
					End If
				End If
				strReturn = strReturn & ">" & .Fields("FieldName") & _
					StringIf(Not Nl(.Fields("FieldDisplay"))," (" & .Fields("FieldDisplay") & ")") & _
					"</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeFieldList = strReturn
End Function
%>
