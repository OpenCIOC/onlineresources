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
Dim strBadSubjTerms, _
	strNewSubjIDs

Function checkSubjects(strNewSubject)
	Dim objReturn, objErrMsg
	Dim cmdSubject, rsSubject
	
	If Not Nl(strNewSubject) Then
		Set cmdSubject = Server.CreateObject("ADODB.Command")
		With cmdSubject
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CIC_UCheck_Subjects"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
			.Parameters.Append objReturn
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@NewTerms", adLongVarChar, adParamInput, -1, strNewSubject)
			.Parameters.Append .CreateParameter("@BadTerms", adVarChar, adParamOutput, 8000)
			.Parameters.Append .CreateParameter("@NewIDs", adVarChar, adParamOutput, 8000)
			Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
		End With
	
		Set rsSubject = cmdSubject.Execute
		Set rsSubject = rsSubject.NextRecordset

		If Not Nl(cmdSubject.Parameters("@BadTerms")) Then
			strBadSubjTerms = cmdSubject.Parameters("@BadTerms")
		End If
		If objReturn.Value <> 0 Or Err.Number <> 0 Then
			checkSubjects = TXT_ERROR & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
		Else
			strNewSubjIDs = cmdSubject.Parameters("@NewIDs")
		End If
	End If
End Function
%>
