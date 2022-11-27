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
Dim cmdListPrintProfile, rsListPrintProfile

Sub openPrintProfileListRst(intDomain, intViewType)
	Dim strDbArea
	Select Case intDomain
		Case DM_CIC
			strDbArea = DM_S_CIC
		Case DM_VOL
			strDbArea = DM_S_VOL
	End Select
	Set cmdListPrintProfile = Server.CreateObject("ADODB.Command")
	With cmdListPrintProfile
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_" & strDbArea & "_PrintProfile_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
	End With
	Set rsListPrintProfile = Server.CreateObject("ADODB.Recordset")
	With rsListPrintProfile
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListPrintProfile
	End With
End Sub

Sub closePrintProfileListRst()
	If rsListPrintProfile.State <> adStateClosed Then
		rsListPrintProfile.Close
	End If
	Set cmdListPrintProfile = Nothing
	Set rsListPrintProfile = Nothing
End Sub

Function makePrintProfileList(intSelected, strSelectName, strSelectId, bIncludeBlank)
	Dim strReturn
	With rsListPrintProfile
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & StringIf(Not Nl(strSelectID)," id=" & AttrQs(strSelectID)) & " class=""form-control"">"
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
	makePrintProfileList = strReturn
End Function
%>
