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
Dim cmdListCertification, rsListCertification

Sub openCertificationListRst(bShowHidden, bAllLanguages, intCurrentValue)
	Set cmdListCertification = Server.CreateObject("ADODB.Command")
	With cmdListCertification
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_CIC_Certification_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@AllLanguages", adBoolean, adParamInput, 1, IIf(bAllLanguages,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@OverrideID", adInteger, adParamInput, 4, Nz(intCurrentValue, Null))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListCertification = Server.CreateObject("ADODB.Recordset")
	With rsListCertification
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListCertification
	End With
End Sub

Sub closeCertificationListRst()
	If rsListCertification.State <> adStateClosed Then
		rsListCertification.Close
	End If
	Set cmdListCertification = Nothing
	Set rsListCertification = Nothing
End Sub

Function makeCertificationList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn
	With rsListCertification
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"""
			If Not Nl(strOnChange) Then
				strReturn = strReturn & " onChange=""" & strOnChange & """"
			End If
			strReturn = strReturn & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("CRT_ID") & """"
				If strSelected = .Fields("CRT_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("Certification") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeCertificationList = strReturn
End Function
%>
