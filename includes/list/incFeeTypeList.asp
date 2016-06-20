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
Dim cmdListFeeType, rsListFeeType

Sub openFeeTypeListRst(bShowHidden, bAllLanguages)
	Set cmdListFeeType = Server.CreateObject("ADODB.Command")
	With cmdListFeeType
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_FeeType_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@AllLanguages", adBoolean, adParamInput, 1, IIf(bAllLanguages,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListFeeType = Server.CreateObject("ADODB.Recordset")
	With rsListFeeType
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListFeeType
	End With
End Sub

Sub closeFeeTypeListRst()
	If rsListFeeType.State <> adStateClosed Then
		rsListFeeType.Close
	End If
	Set cmdListFeeType = Nothing
	Set rsListFeeType = Nothing
End Sub

Function makeFeeTypeList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn
	With rsListFeeType
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
					"<option value=""" & .Fields("FT_ID") & """"
				If strSelected = .Fields("FT_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("FeeType") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeFeeTypeList = strReturn
End Function
%>
