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
Dim cmdListPrivacyProfile, rsListPrivacyProfile

Sub openPrivacyProfileListRst(intCurrentValue)
	Set cmdListPrivacyProfile = Server.CreateObject("ADODB.Command")
	With cmdListPrivacyProfile
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_PrivacyProfile_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@OverrideID", adInteger, adParamInput, 4, Nz(intCurrentValue, Null))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListPrivacyProfile = Server.CreateObject("ADODB.Recordset")
	With rsListPrivacyProfile
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListPrivacyProfile
	End With
End Sub

Sub closePrivacyProfileListRst()
	If rsListPrivacyProfile.State <> adStateClosed Then
		rsListPrivacyProfile.Close
	End If
	Set cmdListPrivacyProfile = Nothing
	Set rsListPrivacyProfile = Nothing
End Sub

Function makePrivacyProfileList(intSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListPrivacyProfile
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("ProfileID") & """"
				If intSelected = .Fields("ProfileID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & Server.HTMLEncode(.Fields("ProfileName")) & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makePrivacyProfileList = strReturn
End Function
%>
