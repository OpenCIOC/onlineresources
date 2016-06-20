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
Dim cmdHasPubDescList, rsHasPubDescList

Sub openHasPubDescRst(strIDList)
	Set cmdHasPubDescList = Server.CreateObject("ADODB.Command")
	With cmdHasPubDescList
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "SELECT DISTINCT pb.PB_ID, pb.PubCode FROM CIC_Publication pb" & _
			" INNER JOIN CIC_BT_PB pr ON pb.PB_ID=pr.PB_ID" & _
			" INNER JOIN CIC_BT_PB_Description prn ON pr.BT_PB_ID=prn.BT_PB_ID AND prn.LangID=" & g_objCurrentLang.LangID & _
			" AND pr.NUM IN (" & QsStrList(strIDList) & ")"
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
	Set rsHasPubDescList = Server.CreateObject("ADODB.Recordset")
	With rsHasPubDescList
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdHasPubDescList
	End With
End Sub

Sub closeHasPubDescRst()
	If rsHasPubDescList.State <> adStateClosed Then
		rsHasPubDescList.Close
	End If
	Set cmdHasPubDescList = Nothing
	Set rsHasPubDescList = Nothing
End Sub

Function makeHasPubDescList(aSelected, strSelectName, bIncludeBlank, bMultiple)
	Dim strReturn, indField
	With rsHasPubDescList
		If .RecordCount <> 0 Then
			.MoveFirst		
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & _
				IIf(bMultiple," MULTIPLE size=""4""",vbNullString) & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("PB_ID") & """"
				If IsArray(aSelected) And bMultiple Then
					For Each indField In aSelected
						If indField = .Fields("PubCode") Then
							strReturn = strReturn & " selected"
							Exit For
						End If
					Next
				ElseIf aSelected = .Fields("PB_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("PubCode") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeHasPubDescList = strReturn
End Function
%>
