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
Dim cmdListVOLMemberInvoice, rsListVOLMemberInvoice

Sub openVOLMemberInvoiceListRst(intVMemID, bFull)
	Set cmdListVOLMemberInvoice = Server.CreateObject("ADODB.Command")
	With cmdListVOLMemberInvoice
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_VOL_Member_Invoice_l" & StringIf(bFull,"f")
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VMEM_ID", adInteger, adParamInput, 4, intVMemID)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListVOLMemberInvoice = Server.CreateObject("ADODB.Recordset")
	With rsListVOLMemberInvoice
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListVOLMemberInvoice
	End With
End Sub

Sub closeVOLMemberInvoiceListRst()
	If rsListVOLMemberInvoice.State <> adStateClosed Then
		rsListVOLMemberInvoice.Close
	End If
	Set cmdListVOLMemberInvoice = Nothing
	Set rsListVOLMemberInvoice = Nothing
End Sub
Function makeVOLMemberInvoiceList(intSelected, strSelectName, bIncludeBlank)
	Dim strReturn, intVMInvID, strInvNum
	With rsListVOLMemberInvoice
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				intVMInvID = .Fields("VMINV_ID")
				strInvNum = .Fields("InvoiceNumber")
				strReturn = strReturn & _
					"<option value=""" & intVMInvID & """"
				If intSelected = intVMInvID Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("InvoiceDate") & IIf(Nl(strInvNum), vbNullString, " (" & strInvNum & ")") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeVOLMemberInvoiceList = strReturn
End Function
%>
