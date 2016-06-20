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
Dim cmdListComm, rsListComm

Sub openCommListRst()
	Set cmdListComm = Server.CreateObject("ADODB.Command")
	With cmdListComm
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_GBL_Community_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListComm = Server.CreateObject("ADODB.Recordset")
	With rsListComm
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListComm
	End With
End Sub

Sub closeCommListRst()
	If rsListComm.State <> adStateClosed Then
		rsListComm.Close
	End If
	Set cmdListComm = Nothing
	Set rsListComm = Nothing
End Sub

Function makeCommList(intSelected, strSelectName, bIncludeBlank, bIncludeNew, intExcludeID, strOnChange)
	Dim strReturn, _
		fldCMID, _
		fldCommunity, _
		fldAuthorized
	
	With rsListComm
		If .RecordCount = 0 And Not bIncludeNew Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			Set fldCMID = .Fields("CM_ID")
			Set fldCommunity = .Fields("Community")
			Set fldAuthorized = .Fields("Authorized")
			
			If .RecordCount <> 0 Then
				.MoveFirst
			End If
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & "  class=""form-control"""
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
				If Nl(intExcludeID) Or fldCMID.Value <> intExcludeID Then
					strReturn = strReturn & _
						"<option value=""" & fldCMID.Value & """"
					If intSelected = fldCMID.Value Then
						strReturn = strReturn & " selected"
					End If
					strReturn = strReturn & ">" & _
							fldCommunity.Value & _
							StringIf(Not fldAuthorized.Value," *") & _
							"</option>"
				End If
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeCommList = strReturn
End Function
%>
