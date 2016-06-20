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
Dim cmdListVacancyUnitType, rsListVacancyUnitType

Sub openVacancyUnitTypeListRst(bShowHidden)
	Set cmdListVacancyUnitType = Server.CreateObject("ADODB.Command")
	With cmdListVacancyUnitType
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_Vacancy_UnitType_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListVacancyUnitType = Server.CreateObject("ADODB.Recordset")
	With rsListVacancyUnitType
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListVacancyUnitType
	End With
End Sub

Sub closeVacancyUnitTypeListRst()
	If rsListVacancyUnitType.State <> adStateClosed Then
		rsListVacancyUnitType.Close
	End If
	Set cmdListVacancyUnitType = Nothing
	Set rsListVacancyUnitType = Nothing
End Sub

Function makeVacancyUnitTypeList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn
	With rsListVacancyUnitType
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
					"<option value=""" & .Fields("VUT_ID") & """"
				If strSelected = .Fields("VUT_ID") Then
					strReturn = strReturn & " SELECTED"
				End If
				strReturn = strReturn & ">" & .Fields("UnitTypeName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeVacancyUnitTypeList = strReturn
End Function
%>
