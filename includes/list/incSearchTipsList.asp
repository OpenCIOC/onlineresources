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
Dim cmdListSearchTips, rsListSearchTips

Sub openSearchTipsListRst(intDomain)
	Set cmdListSearchTips = Server.CreateObject("ADODB.Command")
	With cmdListSearchTips
		.ActiveConnection = getCurrentAdminCnn()
		Select Case intDomain
			Case DM_CIC
				.CommandText = "dbo.sp_CIC_SearchTips_l"			
			Case DM_VOL
				.CommandText = "dbo.sp_VOL_SearchTips_l"
		End Select
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	End With
	Set rsListSearchTips = Server.CreateObject("ADODB.Recordset")
	With rsListSearchTips
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSearchTips
	End With
End Sub

Sub closeSearchTipsListRst()
	If rsListSearchTips.State <> adStateClosed Then
		rsListSearchTips.Close
	End If
	Set cmdListSearchTips = Nothing
	Set rsListSearchTips = Nothing
End Sub

Function makeSearchTipsList(intSelected, strSelectName, bIncludeBlank, bIncludeNew)
	Dim strReturn
	With rsListSearchTips
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
					"<option value=""" & .Fields("SearchTipsID") & """"
				If intSelected = .Fields("SearchTipsID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("PageTitle") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeSearchTipsList = strReturn
End Function
%>

