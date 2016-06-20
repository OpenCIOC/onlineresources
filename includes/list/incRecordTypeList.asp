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
Dim cmdListRecordType, rsListRecordType, bListRecordTypeProgOrBranch, bListRecordTypeForm

bListRecordTypeProgOrBranch = False
bListRecordTypeForm = False

Sub openRecordTypeFormListRst(intViewType, strFormType)
	Set cmdListRecordType = Server.CreateObject("ADODB.Command")
	With cmdListRecordType
		.ActiveConnection = getCurrentAdminCnn()
		Select Case strFormType
		Case "F"
			.CommandText = "dbo.sp_CIC_RecordType_l_FeedbackForm"
		Case "U"
			.CommandText = "dbo.sp_CIC_RecordType_l_UpdateForm"
		End Select
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListRecordType = Server.CreateObject("ADODB.Recordset")
	With rsListRecordType
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListRecordType
	End With
End Sub

Sub openRecordTypeListRst(bLimitUser, bFormData, bShowHidden, intCurrentValue)
	Set cmdListRecordType = Server.CreateObject("ADODB.Command")
	With cmdListRecordType
		If bLimitUser Then
			.ActiveConnection = getCurrentAdminCnn()
			If bFormData Then
				bListRecordTypeForm = True
				bListRecordTypeProgOrBranch = True
				.CommandText = "dbo.sp_CIC_RecordType_ls_Form"
				.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
			Else
				.CommandText = "dbo.sp_CIC_RecordType_ls"
			End If
			.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		Else
			.ActiveConnection = getCurrentCICBasicCnn()
			.CommandText = "dbo.sp_CIC_RecordType_l"
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
			.Parameters.Append .CreateParameter("@OverrideID", adInteger, adParamInput, 4, Nz(intCurrentValue, Null))
		End If
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListRecordType = Server.CreateObject("ADODB.Recordset")
	With rsListRecordType
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListRecordType
	End With
End Sub

Sub closeRecordTypeListRst()
	If rsListRecordType.State <> adStateClosed Then
		rsListRecordType.Close
	End If
	Set cmdListRecordType = Nothing
	Set rsListRecordType = Nothing
End Sub

Function makeRecordTypeList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn
	With rsListRecordType
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
					"<option value=""" & .Fields("RT_ID") & """"
				If strSelected = .Fields("RT_ID") Then
					strReturn = strReturn & " selected"
				End If
				If bListRecordTypeProgOrBranch Then
					If .Fields("ProgramOrBranch") Then
						strReturn = strReturn & " data-progorbranch=""true"""
					End If
				End If
				If bListRecordTypeForm Then
					If .Fields("HAS_FORM") Then
						strReturn = strReturn & " data-hasform=""true"""
					End If
				End If
				strReturn = strReturn & ">(" & .Fields("RecordType") & ")" & _
					IIf(Nl(.Fields("RecordTypeName")),vbNullString," " & .Fields("RecordTypeName")) & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeRecordTypeList = strReturn
End Function
%>
