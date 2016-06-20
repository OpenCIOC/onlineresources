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
Dim cmdListLanguages, rsListLanguages

Sub openLanguagesListRst(bShowHidden, bOnlyShowOnForm)
	Set cmdListLanguages = Server.CreateObject("ADODB.Command")
	With cmdListLanguages
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_Language_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@OnlyShowOnForm", adBoolean, adParamInput, 1, IIf(bOnlyShowOnForm,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListLanguages = Server.CreateObject("ADODB.Recordset")
	With rsListLanguages
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListLanguages
	End With
End Sub

Sub closeLanguagesListRst()
	If rsListLanguages.State <> adStateClosed Then
		rsListLanguages.Close
	End If
	Set cmdListLanguages = Nothing
	Set rsListLanguages = Nothing
End Sub

Function makeLanguagesList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	makeLanguagesList = makeLanguagesListBase(strSelected, strSelectName, bIncludeBlank, strOnChange, False)
End Function

Function makeLanguagesListJavaScript()
	Call openLanguagesListRst(False, False)
	makeLanguagesListJavaScript = makeLanguagesListBase(vbNullString, vbNullString, False, vbNullString, True)
	Call closeLanguagesListRst()
End Function

Function makeLanguagesListBase(strSelected, strSelectName, bIncludeBlank, strOnChange, bJavaScript)
	Dim strReturn, strCon
	With rsListLanguages
		If .RecordCount = 0 Then
			If Not bJavaScript Then
				strReturn = TXT_NO_VALUES_AVAILABLE
			Else
				strReturn = "[]"
			End If
		Else
			.MoveFirst
			If Not bJavaScript Then
				strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"""
				If Not Nl(strOnChange) Then
					strReturn = strReturn & " onChange=""" & strOnChange & """"
				End If
				strReturn = strReturn & ">"
				If bIncludeBlank Then
					strReturn = strReturn & "<option value=""""> -- </option>"
				End If
			Else
				strReturn = "["
				strCon = vbNullString
			End If
			While Not .EOF
				If Not bJavaScript Then
					strReturn = strReturn & _
						"<option value=""" & .Fields("LN_ID") & """"
					If strSelected = .Fields("LN_ID") Then
						strReturn = strReturn & " selected"
					End If
					strReturn = strReturn & ">" & .Fields("LanguageName") & "</option>"
				Else
					strReturn = strReturn & strCon & _
						"{chkid:" & JSONQs(.Fields("LN_ID"), True) & _
						",value:" & JSONQs(.Fields("LanguageName"), True) & "}"
					strCon = ","
				End If
				.MoveNext
			Wend
			If Not bJavaScript Then
				strReturn = strReturn & "</select>"
			Else
				strReturn = strReturn & "]"
			End If
		End If
	End With
	makeLanguagesListBase = strReturn
End Function

%>
