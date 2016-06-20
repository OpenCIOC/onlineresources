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
Dim cmdBroaderTerms, rsBroaderTerms

Sub openBroaderTermsRst(intSubjID,bUseEquiv)
	set cmdBroaderTerms = Server.CreateObject("ADODB.Command")
	With cmdBroaderTerms
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_THS_SBJ_BroaderTerm_slf"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@SubjID", adInteger, adParamInput, 4,intSubjID)
	End With
	Set rsBroaderTerms = Server.CreateObject("ADODB.Recordset")
	With rsBroaderTerms
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdBroaderTerms
	End With
End Sub

Sub closeBroaderTermsRst()
	If rsBroaderTerms.State <> adStateClosed Then
		rsBroaderTerms.Close
	End If
	Set cmdBroaderTerms = Nothing
	Set rsBroaderTerms = Nothing
End Sub
%>
