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
Dim cmdListStreetType, rsListStreetType

Sub openStreetTypeListRst(bUnique)
	Set cmdListStreetType = Server.CreateObject("ADODB.Command")
	With cmdListStreetType
		.ActiveConnection = getCurrentBasicCnn()
		.CommandText = "dbo.sp_GBL_StreetType_l" & StringIf(bUnique,"d")
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListStreetType = Server.CreateObject("ADODB.Recordset")
	With rsListStreetType
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListStreetType
	End With
End Sub

Sub closeStreetTypeListRst()
	If rsListStreetType.State <> adStateClosed Then
		rsListStreetType.Close
	End If
	Set cmdListStreetType = Nothing
	Set rsListStreetType = Nothing
End Sub

Function makeStreetTypeList(strSelected, bSelectedAfter, strSelectName, bIncludeBlank)
	Dim bTypeFound
	bTypeFound = False
	Dim strReturn
	With rsListStreetType
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " autocomplete=""off"" class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("StreetType") & StringIf(.Fields("MULTIPLE_ORIENTATIONS"),"|" & IIf(.Fields("AfterName"),SQL_TRUE,SQL_FALSE)) & """"
				If Not bTypeFound And strSelected = .Fields("StreetType") And (bSelectedAfter = .Fields("AfterName") Or Not .Fields("MULTIPLE_ORIENTATIONS") Or Nl(bSelectedAfter)) Then
					bTypeFound = True
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & _
					.Fields("StreetType") & _
					StringIf(.Fields("LangID")<>g_objCurrentLang.LangID," (" & .Fields("LanguageName") & ")") & _
					StringIf(.Fields("MULTIPLE_ORIENTATIONS"),IIf(.Fields("AfterName")," - " & TXT_AFTER_NAME," - " & TXT_BEFORE_NAME)) & _
					"</option>"
				.MoveNext
			Wend
			If Not bTypeFound And Not Nl(strSelected) Then
				strReturn = strReturn & "<option value=" & AttrQs(strSelected) & " SELECTED>" & strSelected & "</option>"
			End If
			strReturn = strReturn & "</select>"
		End If
	End With
	makeStreetTypeList = strReturn
End Function

Function makeStreetTypeListD(strSelectName)
	Dim bTypeFound
	bTypeFound = False
	Dim strReturn
	With rsListStreetType
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"">" & _
				"<option value=""""> -- </option>"
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("StreetType") & """>" & .Fields("StreetType") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeStreetTypeListD = strReturn
End Function
%>
