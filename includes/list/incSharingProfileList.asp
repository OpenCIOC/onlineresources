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
Dim cmdListSharingProfile, rsListSharingProfile

Sub openSharingProfileListRst(intDomain)
	Set cmdListSharingProfile = Server.CreateObject("ADODB.Command")
	With cmdListSharingProfile
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_SharingProfile_l_RecordAddable"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 4, intDomain)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListSharingProfile = Server.CreateObject("ADODB.Recordset")
	With rsListSharingProfile
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSharingProfile
	End With
End Sub

Sub closeSharingProfileListRst()
	If rsListSharingProfile.State <> adStateClosed Then
		rsListSharingProfile.Close
	End If
	Set cmdListSharingProfile = Nothing
	Set rsListSharingProfile = Nothing
End Sub

' Drop-down list of Members
Function makeSharingProfileList(strSelected, strSelectName, bIncludeBlank, bIncludeMember)
	Dim strReturn
	With rsListSharingProfile
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=" & AttrQs(.Fields("ProfileID"))
				If strSelected = .Fields("ProfileID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">#" & .Fields("ProfileID") & " - " & Server.HTMLEncode(Ns(.Fields("Name")))
				If bIncludeMember Then
					strReturn = strReturn & " [" & Server.HTMLEncode(Ns(.Fields("MemberName"))) & "]"
				End If
				strReturn = strReturn & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeSharingProfileList = strReturn
End Function

%>
