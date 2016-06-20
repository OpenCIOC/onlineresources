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
Dim cmdListVacancyServiceTitle, rsListVacancyServiceTitle

Sub openVacancyServiceTitleListRst(bShowHidden, bAllLanguages)
	Set cmdListVacancyServiceTitle = Server.CreateObject("ADODB.Command")
	With cmdListVacancyServiceTitle
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_Vacancy_ServiceTitle_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@AllLanguages", adBoolean, adParamInput, 1, IIf(bAllLanguages,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListVacancyServiceTitle = Server.CreateObject("ADODB.Recordset")
	With rsListVacancyServiceTitle
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListVacancyServiceTitle
	End With
End Sub

Sub closeVacancyServiceTitleListRst()
	If rsListVacancyServiceTitle.State <> adStateClosed Then
		rsListVacancyServiceTitle.Close
	End If
	Set cmdListVacancyServiceTitle = Nothing
	Set rsListVacancyServiceTitle = Nothing
End Sub

Function makeVacancyServiceTitleList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn
	With rsListVacancyServiceTitle
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName)
			If Not Nl(strOnChange) Then
				strReturn = strReturn & " onChange=""" & strOnChange & """"
			End If
			strReturn = strReturn & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("VST_ID") & """"
				If strSelected = .Fields("VST_ID") Then
					strReturn = strReturn & " SELECTED"
				End If
				strReturn = strReturn & ">" & .Fields("ServiceTitle") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeVacancyServiceTitleList = strReturn
End Function
%>
