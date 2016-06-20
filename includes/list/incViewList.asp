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
Dim cmdListView, rsListView

Sub openViewListRst(intDomain, strAgencyCode, strCurrentValues)
	Set cmdListView = Server.CreateObject("ADODB.Command")
	With cmdListView
		.ActiveConnection = getCurrentAdminCnn()
		Select Case intDomain
			Case DM_CIC
				.CommandText = "dbo.sp_CIC_View_l"
			Case DM_VOL
				.CommandText = "dbo.sp_VOL_View_l"
		End Select
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, Nz(strAgencyCode, Null))
		.Parameters.Append .CreateParameter("@AllAgencies", adBoolean, adParamInput, 1, SQL_FALSE)
		.Parameters.Append .CreateParameter("OverrideIDList", adLongVarChar, adParamInput, -1, Nz(strCurrentValues, Null))
	End With
	Set rsListView = Server.CreateObject("ADODB.Recordset")
	With rsListView
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListView
	End With
End Sub

Sub openViewURLListRst(intDomain)
	Set cmdListView = Server.CreateObject("ADODB.Command")
	With cmdListView
		.ActiveConnection = getCurrentAdminCnn()
		Select Case intDomain
			Case DM_CIC
				.CommandText = "dbo.sp_CIC_View_DomainMap_l"
			Case DM_VOL
				.CommandText = "dbo.sp_VOL_View_DomainMap_l"
		End Select
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListView = Server.CreateObject("ADODB.Recordset")
	With rsListView
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListView
	End With
End Sub

Sub closeViewListRst()
	If rsListView.State <> adStateClosed Then
		rsListView.Close
	End If
	Set cmdListView = Nothing
	Set rsListView = Nothing
End Sub

Function makeViewList(intSelected, strSelectName, bIncludeBlank, bMultiple)
	Dim strReturn, _
		fldViewType

	With rsListView
		If .RecordCount > 0 Then
			.MoveFirst
			Set fldViewType = .Fields("ViewType")
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & _
							StringIf(bMultiple, " multiple") & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & fldViewType.Value & """"
				If intSelected = fldViewType.Value Or Nl(fldViewType.Value) Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">#" & fldViewType.Value & " - " & .Fields("ViewName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeViewList = strReturn
End Function

Function makeViewDomainList(strSelected, strSelectName, bIncludeBlank, bIncludeProtocol)
	Dim strReturn
	With rsListView
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("URLViewType") & " " & .Fields("ViewType") & " " & .Fields("AccessURL") & StringIf(bIncludeProtocol, " " & .Fields("Protocol")) & """"
				If (strSelected = .Fields("URLViewType") & " " & .Fields("ViewType") & " " & .Fields("AccessURL")) Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & StringIf(.Fields("DEFAULT_VIEW"),"* ") & .Fields("ViewName") & " &nbsp; (" & .Fields("AccessURL") & ")</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeViewDomainList = strReturn
End Function
%>
