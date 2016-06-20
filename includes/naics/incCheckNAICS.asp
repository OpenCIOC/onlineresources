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
Dim strNewNAICS

Sub checkNAICS()
	Dim cmdNAICS, rsNAICS
	strNewNAICS = Trim(Request("NAICS"))
	
	If Not Nl(strNewNAICS) Then
		Set cmdNAICS = Server.CreateObject("ADODB.Command")
		With cmdNAICS
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CIC_UCheck_NAICS"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
			.Parameters.Append .CreateParameter("@NewCodes", adLongVarChar, adParamInput, -1, strNewNAICS)
			.Parameters.Append .CreateParameter("@BadCodes", adVarChar, adParamOutput, 8000)
		End With
	
		Set rsNAICS = cmdNAICS.Execute
		Set rsNAICS = rsNAICS.NextRecordset

		If Not Nl(cmdNAICS.Parameters("@BadCodes")) Then
			strErrorList = strErrorList & "<li>" & TXT_INVALID_NAICS_CODES & _
				cmdNAICS.Parameters("@BadCodes") & "</li>"
		ElseIf cmdNAICS.Parameters("@RETURN_VALUE").Value <> 0 Or Err.Number <> 0 Then
			strErrorList = strErrorList & "<li>" & TXT_UNKNOWN_ERROR_NAICS & _
				IIf(Err.Number <> 0,TXT_COLON & Err.Description,".") & "</li>"
		End If
	End If
End Sub
%>
