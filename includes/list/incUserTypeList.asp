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
Dim cmdListUserType, rsListUserType

Sub openUserTypeListRst(intDomain, strAgencyCode, strCurrentValues)
	Set cmdListUserType = Server.CreateObject("ADODB.Command")
	With cmdListUserType
		.ActiveConnection = getCurrentAdminCnn()
		Select Case intDomain
			Case DM_CIC
				.CommandText = "dbo.sp_CIC_SecurityLevel_l"
			Case DM_VOL
				.CommandText = "dbo.sp_VOL_SecurityLevel_l"
		End Select
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, Nz(strAgencyCode, Null))
		.Parameters.Append .CreateParameter("OverrideIDList", adLongVarChar, adParamInput, -1, Nz(strCurrentValues, Null))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListUserType = Server.CreateObject("ADODB.Recordset")
	With rsListUserType
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListUserType
	End With
End Sub

Sub openUserTypeUserEditListRst(intDomain, strAgency, intCurrentValue)
	Set cmdListUserType = Server.CreateObject("ADODB.Command")
	With cmdListUserType
		.ActiveConnection = getCurrentAdminCnn()
		Select Case intDomain
			Case DM_CIC
				.CommandText = "dbo.sp_CIC_SecurityLevel_EU_l"
			Case DM_VOL
				.CommandText = "dbo.sp_VOL_SecurityLevel_EU_l"
		End Select
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@Old_SL", adInteger, adParamInput, 4, Nz(intCurrentValue, Null))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListUserType = Server.CreateObject("ADODB.Recordset")
	With rsListUserType
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListUserType
	End With
End Sub

Sub closeUserTypeListRst()
	If rsListUserType.State <> adStateClosed Then
		rsListUserType.Close
	End If
	Set cmdListUserType = Nothing
	Set rsListUserType = Nothing
End Sub

Function makeUserTypeList(intSelected, strSelectName, bIncludeBlank, bIncludeNew)
	Dim strReturn
	With rsListUserType
		If .RecordCount = 0 And Not bIncludeNew Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			If .RecordCount <> 0 Then
				.MoveFirst
			End If
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName)  & " class=""form-control"">"
			If bIncludeNew Then
				strReturn = strReturn & "<option value="""">" & TXT_CREATE_NEW & "</option>"
			ElseIf bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("SL_ID") & """"
				If intSelected = .Fields("SL_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("SecurityLevel") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeUserTypeList = strReturn
End Function
%>

