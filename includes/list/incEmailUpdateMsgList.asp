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
Dim cmdListEmailMsg, rsListEmailMsg

Sub openEmailMsgListRst(intDomain, bMultiRecord)
	Set cmdListEmailMsg = Server.CreateObject("ADODB.Command")
	With cmdListEmailMsg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_StandardEmailUpdate_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, intDomain)
		.Parameters.Append .CreateParameter("@StdForMultipleRecords", adBoolean, adParamInput, 1, bMultiRecord)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListEmailMsg = Server.CreateObject("ADODB.Recordset")
	With rsListEmailMsg
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListEmailMsg
	End With
End Sub

Sub closeEmailMsgListRst()
	If rsListEmailMsg.State <> adStateClosed Then
		rsListEmailMsg.Close
	End If
	Set cmdListEmailMsg = Nothing
	Set rsListEmailMsg = Nothing
End Sub

Function makeEmailMsgList(strSelected, strSelectName, bIncludeBlank, strOnChange, strSelectTitle)
	Dim strReturn, strCon
	With rsListEmailMsg
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " title=" & AttrQs(strSelectTitle) & " id=" & AttrQs(strSelectName) & " class=""form-control"""
			If Not Nl(strOnChange) Then
				strReturn = strReturn & " onChange=""" & strOnChange & """"
			End If
			strReturn = strReturn & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("EmailID") & """"
				If strSelected = .Fields("EmailID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("Name") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With

	makeEmailMsgList = strReturn
End Function

%>
