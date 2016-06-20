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
Dim cmdListExcelProfile, rsListExcelProfile

Sub openExcelProfileListRst(intDomain, intViewType)
	Dim strDbArea
	Select Case intDomain
		Case DM_CIC
			strDbArea = DM_S_CIC
		Case DM_VOL
			strDbArea = DM_S_VOL
	End Select
	Set cmdListExcelProfile = Server.CreateObject("ADODB.Command")
	With cmdListExcelProfile
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_" & strDbArea & "_ExcelProfile_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListExcelProfile = Server.CreateObject("ADODB.Recordset")
	With rsListExcelProfile
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListExcelProfile
	End With
End Sub

Sub closeExcelProfileListRst()
	If rsListExcelProfile.State <> adStateClosed Then
		rsListExcelProfile.Close
	End If
	Set cmdListExcelProfile = Nothing
	Set rsListExcelProfile = Nothing
End Sub

Function makeExcelProfileList(intSelected, strSelectName, bIncludeBlank, bIncludeNew, strOnChange)
	Dim strReturn
	With rsListExcelProfile
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF And Not bIncludeNew Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"""
			If Not Nl(strOnChange) Then
				strReturn = strReturn & " onChange=""" & strOnChange & """"
			End If
			strReturn = strReturn & ">"
			If bIncludeNew Then
				strReturn = strReturn & "<option value="""">" & TXT_CREATE_NEW & "</option>"
			ElseIf bIncludeBlank Then
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
	makeExcelProfileList = strReturn
End Function
%>
