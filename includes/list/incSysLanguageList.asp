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
Dim cmdListSysLanguage, rsListSysLanguage

Sub openSysLanguageListRst(bActive)
	Set cmdListSysLanguage = Server.CreateObject("ADODB.Command")
	With cmdListSysLanguage
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_STP_Language_l"
		.Parameters.Append .CreateParameter("@Active", adBoolean, adParamInput, 1, IIf(bActive,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListSysLanguage = Server.CreateObject("ADODB.Recordset")
	With rsListSysLanguage
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSysLanguage
	End With
End Sub

Sub closeSysLanguageListRst()
	If rsListSysLanguage.State <> adStateClosed Then
		rsListSysLanguage.Close
	End If
	Set cmdListSysLanguage = Nothing
	Set rsListSysLanguage = Nothing
End Sub

Function makeSysLanguageList(intSelected, strSelectName, bIncludeBlank, strClassName)
	Dim strReturn
	With rsListSysLanguage
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & _
				"<select name=" & AttrQs(strSelectName) & _
				" id=" & AttrQs(strSelectName) & _
				StringIf(Not Nl(strClassName)," class=" & AttrQs(strClassName)) & _
				" class=""form-control""" & _
				">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			Dim strSysLanguageName
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("LangID") & """"
				If intSelected = .Fields("LangID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("LanguageName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeSysLanguageList = strReturn
End Function
%>
