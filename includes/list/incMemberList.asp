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
Dim cmdListMember, rsListMember

Sub openMemberListRst()
	Set cmdListMember = Server.CreateObject("ADODB.Command")
	With cmdListMember
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_STP_Member_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListMember = Server.CreateObject("ADODB.Recordset")
	With rsListMember
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListMember
	End With
End Sub

Sub closeMemberListRst()
	If rsListMember.State <> adStateClosed Then
		rsListMember.Close
	End If
	Set cmdListMember = Nothing
	Set rsListMember = Nothing
End Sub

' Drop-down list of Members
Function makeMemberList(strSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListMember
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=" & AttrQs(.Fields("MemberID"))
				If strSelected = .Fields("MemberID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">#" & .Fields("MemberID") & Server.HTMLEncode(StringIf(Not Nl(.Fields("MemberName")), " - " & .Fields("MemberName"))) & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeMemberList = strReturn
End Function

%>
