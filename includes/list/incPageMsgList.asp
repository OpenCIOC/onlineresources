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
Dim cmdListPageMsg, rsListPageMsg

Sub openPageMsgListRst()
	Set cmdListPageMsg = Server.CreateObject("ADODB.Command")
	With cmdListPageMsg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_PageMsg_l"
		.CommandType = adCmdStoredProc
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.CommandTimeout = 0
	End With
	Set rsListPageMsg = Server.CreateObject("ADODB.Recordset")
	With rsListPageMsg
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListPageMsg
	End With
End Sub

Sub closePageMsgListRst()
	If rsListPageMsg.State <> adStateClosed Then
		rsListPageMsg.Close
	End If
	Set cmdListPageMsg = Nothing
	Set rsListPageMsg = Nothing
End Sub

Function makePageMsgList(intSelected, strSelectName, bIncludeNew)
	Dim strReturn
	With rsListPageMsg
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF And Not bIncludeNew Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeNew Then
				strReturn = strReturn & "<option value="""">" & TXT_CREATE_NEW & "</option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("PageMsgID") & """"
				If intSelected = .Fields("PageMsgID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("MsgTitle") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makePageMsgList = strReturn
End Function
%>

