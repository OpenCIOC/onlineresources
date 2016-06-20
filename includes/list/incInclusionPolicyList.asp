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
Dim cmdListInclusionPolicy, rsListInclusionPolicy

Sub openInclusionPolicyListRst()
	Set cmdListInclusionPolicy = Server.CreateObject("ADODB.Command")
	With cmdListInclusionPolicy
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_InclusionPolicy_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	End With
	Set rsListInclusionPolicy = Server.CreateObject("ADODB.Recordset")
	With rsListInclusionPolicy
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListInclusionPolicy
	End With
End Sub

Sub closeInclusionPolicyListRst()
	If rsListInclusionPolicy.State <> adStateClosed Then
		rsListInclusionPolicy.Close
	End If
	Set cmdListInclusionPolicy = Nothing
	Set rsListInclusionPolicy = Nothing
End Sub

Function makeInclusionPolicyList(intSelected, strSelectName, bIncludeBlank, bIncludeNew)
	Dim strReturn
	With rsListInclusionPolicy
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF And Not bIncludeNew Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeNew Then
				strReturn = strReturn & "<option value="""">" & TXT_CREATE_NEW & "</option>"
			ElseIf bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("InclusionPolicyID") & """"
				If intSelected = .Fields("InclusionPolicyID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("PolicyTitle") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeInclusionPolicyList = strReturn
End Function
%>

