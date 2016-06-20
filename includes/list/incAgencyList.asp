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
Dim cmdListAgency, rsListAgency

Sub openAgencyListRst(intDomain, bListForeignAgency, bAgencyDetail)
	Set cmdListAgency = Server.CreateObject("ADODB.Command")
	With cmdListAgency
		.ActiveConnection = getCurrentAdminCnn()
		Select Case intDomain
			Case DM_CIC
				.CommandText = "dbo.sp_CIC_Agency_l" & StringIf(bAgencyDetail,"f")
			Case DM_VOL
				.CommandText = "dbo.sp_VOL_Agency_l" & StringIf(bAgencyDetail,"f")		
			Case DM_GLOBAL
				.CommandText = "dbo.sp_GBL_Agency_l" & StringIf(bAgencyDetail,"f")
		End Select
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ListForeignAgency", adBoolean, adParamInput, 1, IIf(bListForeignAgency,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListAgency = Server.CreateObject("ADODB.Recordset")
	With rsListAgency
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListAgency
	End With
End Sub

Sub openAgencyAdminListRst()
	Set cmdListAgency = Server.CreateObject("ADODB.Command")
	With cmdListAgency
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_Agency_lf_Admin"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListAgency = Server.CreateObject("ADODB.Recordset")
	With rsListAgency
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListAgency
	End With
End Sub

Sub closeAgencyListRst()
	If rsListAgency.State <> adStateClosed Then
		rsListAgency.Close
	End If
	Set cmdListAgency = Nothing
	Set rsListAgency = Nothing
End Sub

' Drop-down list of Agencies, Code-only, keys on Code or ID, does not auto-insert selected value.
Function makeAgencyList(strSelected, strSelectName, bIncludeName, bIncludeBlank)
	Dim strReturn, _
		strOrgName
	With rsListAgency
		If .RecordCount = 0 Then
			strReturn = TXT_THERE_ARE_NO_AGENCIES
		Else
			.MoveFirst
			strOrgName = vbNullString
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				If bIncludeName Then
					strOrgName = IIf(Nl(.Fields("ORG_NAME_FULL")),vbNullString," - " & .Fields("ORG_NAME_FULL"))
					If Len(strOrgName) > 80 Then
						strOrgName = Server.HtmlEncode(Left(strOrgName,80)) & " ..."
					End If
				End If
				strReturn = strReturn & _
					"<option value=" & AttrQs(.Fields("AgencyCode"))
				If strSelected = .Fields("AgencyCode") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("AgencyCode") & strOrgName & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeAgencyList = strReturn
End Function

' Drop-down list of Agencies, Code-only, auto-inserts selected value.
' Do not use "agency detail" or "list foreign agency" options when opening recordset for this function.
Function makeRecordOwnerAgencyList(strCurAgency, strSelectName, bIncludeName)
	Dim bCodeFound
	bCodeFound = False

	Dim strReturn, _
		strOrgName
	With rsListAgency
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		strOrgName = vbNullString
		strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " class=""form-control"">"
		While Not .EOF
			If bIncludeName Then
				strOrgName = IIf(Nl(.Fields("ORG_NAME_FULL")),vbNullString," - " & .Fields("ORG_NAME_FULL"))
				If Len(strOrgName) > 80 Then
					strOrgName = Server.HTMLEncode(Left(strOrgName,80)) & " ..."
				End If
			End If
			strReturn = strReturn & _
				"<option value=" & AttrQs(.Fields("AgencyCode"))
			If strCurAgency = .Fields("AgencyCode") Then
				bCodeFound = True
				strReturn = strReturn & " selected"
			End If
			strReturn = strReturn & ">" & .Fields("AgencyCode") & strOrgName & "</option>"
			.MoveNext
		Wend
		If Not bCodeFound And Not Nl(strCurAgency) Then
			strReturn = strReturn & "<option value=" & AttrQs(strCurAgency) & " SELECTED>" & strCurAgency & "</option>"
		End If
		strReturn = strReturn & "</select>"
	End With
	makeRecordOwnerAgencyList = strReturn
End Function
%>
