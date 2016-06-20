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
Dim cmdListSchool, rsListSchool

Sub openSchoolListRst(bShowHidden)
	Set cmdListSchool = Server.CreateObject("ADODB.Command")
	With cmdListSchool
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_CCR_School_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListSchool = Server.CreateObject("ADODB.Recordset")
	With rsListSchool
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSchool
	End With
End Sub

Sub closeSchoolListRst()
	If rsListSchool.State <> adStateClosed Then
		rsListSchool.Close
	End If
	Set cmdListSchool = Nothing
	Set rsListSchool = Nothing
End Sub

Function makeSchoolList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	makeSchoolList = makeSchoolListBase(strSelected, strSelectName, bIncludeBlank, strOnChange, False)
End Function

Function makeSchoolListJavaScript()
	Call openSchoolListRst(False)
	makeSchoolListJavaScript = makeSchoolListBase(vbNullString, vbNullString, False, vbNullString, True)
	Call closeSchoolListRst()
End Function

Function makeSchoolListBase(strSelected, strSelectName, bIncludeBlank, strOnChange, bJavaScript)
	Dim strReturn
	
	With rsListSchool
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			If Not bJavaScript Then 
				strReturn = TXT_NO_VALUES_AVAILABLE
			Else
				strReturn = "[]"
			End IF
		Else
			Dim strCon
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
						"<option value=""" & .Fields("SCH_ID") & """"
					If strSelected = .Fields("SCH_ID") Then
						strReturn = strReturn & " selected"
					End If
					strReturn = strReturn & ">" & .Fields("SchoolName") & _
						StringIf(Not Nl(.Fields("SchoolBoard"))," (" & .Fields("SchoolBoard") & ")") & "</option>"
				Else
					strReturn = strReturn & strCon & _
						"{chkid:" & JSONQs(.Fields("SCH_ID"), True) & _
						",value:" & JSONQs(.Fields("SchoolName") & StringIf(.Fields("NEEDS_BOARD") And Not Nl(.Fields("SchoolBoard"))," (" & .Fields("SchoolBoard") & ")"), True) & _
						",label:" & JSONQs(.Fields("SchoolName") & StringIf(Not Nl(.Fields("SchoolBoard"))," (" & .Fields("SchoolBoard") & ")"), True) & "}"
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
	makeSchoolListBase = strReturn
End Function
%>
