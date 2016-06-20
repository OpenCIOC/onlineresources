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

Dim cmdListSubjectTerm, rsListSubjectTerm

Sub openUsedSubjectTermListRst()
	Set cmdListSubjectTerm = Server.CreateObject("ADODB.Command")
	With cmdListSubjectTerm
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_THS_Subject_l_Used"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListSubjectTerm = Server.CreateObject("ADODB.Recordset")
	With rsListSubjectTerm
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSubjectTerm
	End With
End Sub

Sub closeUsedSubjectTermListRst()
	If rsListSubjectTerm.State <> adStateClosed Then
		rsListSubjectTerm.Close
	End If
	Set cmdListSubjectTerm = Nothing
	Set rsListSubjectTerm = Nothing
End Sub

Function makeSubjectTermList(intSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListSubjectTerm
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("Subj_ID") & """"
				If intSelected = .Fields("Subj_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("SubjectTerm") & StringIf(Not .Fields("Authorized"), " *") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeSubjectTermList = strReturn
End Function
%>

