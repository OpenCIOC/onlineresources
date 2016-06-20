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
Dim strNewQLPIDs

Sub checkViewQuickListPublication()
	Dim strNewQLP, cmdQLP, rsQLP
	strNewQLP = Trim(Request("QLP_NEW"))
	
	If Not Nl(strNewQLP) Then
		Set cmdQLP = Server.CreateObject("ADODB.Command")
		With cmdQLP
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CIC_View_QuickListPub_Check"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@NewCodes", adLongVarChar, adParamInput, -1, strNewQLP)
			.Parameters.Append .CreateParameter("@BadCodes", adVarChar, adParamOutput, 8000)
			.Parameters.Append .CreateParameter("@NewIDs", adVarChar, adParamOutput, 8000)
		End With
	
		Set rsQLP = cmdQLP.Execute
		Set rsQLP = rsQLP.NextRecordset

		If Not Nl(cmdQLP.Parameters("@BadCodes")) Then
			bError = True
			strErrorList = strErrorList & "<li>" & TXT_INVALID_PUBLICATION & _
				cmdQLP.Parameters("@BadCodes") & "</li>"
		ElseIf cmdQLP.Parameters("@RETURN_VALUE").Value <> 0 Or Err.Number <> 0 Then
			bError = True
			strErrorList = strErrorList & "<li>" & TXT_UNKNOWN_ERROR & _
				IIf(Err.Number <> 0,TXT_COLON & Err.Description,".") & "</li>"
		Else
			strNewQLPIDs = cmdQLP.Parameters("@NewIDs")
		End If
	End If
End Sub
%>
