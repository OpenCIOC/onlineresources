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
Dim cmdListWard, rsListWard

Sub openWardListRst(bShowHidden, intCurrentValue)
	Set cmdListWard = Server.CreateObject("ADODB.Command")
	With cmdListWard
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_CIC_Ward_l"
		.CommandType = adCmdStoredProc
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@OverrideID", adInteger, adParamInput, 4, Nz(intCurrentValue, Null))
		.CommandTimeout = 0
	End With
	Set rsListWard = Server.CreateObject("ADODB.Recordset")
	With rsListWard
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListWard
	End With
End Sub

Sub closeWardListRst()
	If rsListWard.State <> adStateClosed Then
		rsListWard.Close
	End If
	Set cmdListWard = Nothing
	Set rsListWard = Nothing
End Sub

Function makeWardList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn, _
		strWardName, _
		strMunicipality

	With rsListWard
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " autocomplete=""off""" & " class=""form-control"""
			If Not Nl(strOnChange) Then
				strReturn = strReturn & " onChange=""" & strOnChange & """"
			End If
			strReturn = strReturn & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strWardName = .Fields("WardName")
				strMunicipality = .Fields("Municipality")
				strReturn = strReturn & _
					"<option value=""" & .Fields("WD_ID") & """"
				If strSelected = .Fields("WD_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & _
					StringIf(Not Nl(strWardName),strWardName & " (") & _
					StringIf(Not Nl(strMunicipality),strMunicipality & " ") & TXT_WARD & " " & .Fields("WardNumber") & _
					StringIf(Not Nl(strWardName),")") & _
					"</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeWardList = strReturn
End Function
%>
