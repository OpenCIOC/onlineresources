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
Dim cmdListExportProfile, rsListExportProfile

Sub openExportProfileListRst(bAllLanguages,bAdmin)
	Set cmdListExportProfile = Server.CreateObject("ADODB.Command")
	With cmdListExportProfile
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ExportProfile_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, IIf(bAdmin,Null,g_intViewTypeCIC))
		.Parameters.Append .CreateParameter("@AllLanguages", adBoolean, adParamInput, 1, IIf(bAllLanguages,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListExportProfile = Server.CreateObject("ADODB.Recordset")
	With rsListExportProfile
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListExportProfile
	End With
End Sub

Sub closeExportProfileListRst()
	If rsListExportProfile.State <> adStateClosed Then
		rsListExportProfile.Close
	End If
	Set cmdListExportProfile = Nothing
	Set rsListExportProfile = Nothing
End Sub

Function makeExportProfileList(intSelected, strSelectName, strSelectId, bIncludeBlank)
	Dim strReturn
	With rsListExportProfile
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectId) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("ProfileID") & """"
				If intSelected = .Fields("ProfileID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("ProfileName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeExportProfileList = strReturn
End Function
%>
