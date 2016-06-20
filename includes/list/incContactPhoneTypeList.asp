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
Dim cmdListContactPhoneType, rsListContactPhoneType

Sub openContactPhoneTypeListRst()
	Set cmdListContactPhoneType = Server.CreateObject("ADODB.Command")
	With cmdListContactPhoneType
		.ActiveConnection = getCurrentBasicCnn()
		.CommandText = "dbo.sp_GBL_Contact_PhoneType_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListContactPhoneType = Server.CreateObject("ADODB.Recordset")
	With rsListContactPhoneType
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListContactPhoneType
	End With
End Sub

Sub closeContactPhoneTypeListRst()
	If rsListContactPhoneType.State <> adStateClosed Then
		rsListContactPhoneType.Close
	End If
	Set cmdListContactPhoneType = Nothing
	Set rsListContactPhoneType = Nothing
End Sub

Function makeContactPhoneTypeList(strSelected, strSelectName, bIncludeBlank, bIncludeAsterisk)
	Dim bTypeFound
	bTypeFound = False
	Dim strReturn
	With rsListContactPhoneType
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			If bIncludeAsterisk Then
				strReturn = strReturn & "<option value=""*"">*</option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("PhoneType") & """"
				If Not bTypeFound And strSelected = .Fields("PhoneType") Then
					bTypeFound = True
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("PhoneType") & "</option>"
				.MoveNext
			Wend
			If Not bTypeFound And Not Nl(strSelected) Then
				strReturn = strReturn & "<option value=" & AttrQs(strSelected) & " SELECTED>" & strSelected & "</option>"
			End If
			strReturn = strReturn & "</select>"
		End If
	End With
	makeContactPhoneTypeList = strReturn
End Function
%>
