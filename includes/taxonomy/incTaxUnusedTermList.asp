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
'
' Purpose: 		Opens a list of Unused Terms (synonyms) for the given Term.
'
'
%>

<%
Dim cmdUnusedTerms, rsUnusedTerms

'***************************************
' Begin Sub openUnusedTermsRst
'	Open a recordset containing a list of all Unused Terms (Use References) associated with a given Term
'		strCode - Code of the Term
'		bEquiv - True = Select French Unused Terms, False = Select French Unused Terms
'***************************************
Sub openUnusedTermsRst(strCode)
	set cmdUnusedTerms = Server.CreateObject("ADODB.Command")
	With cmdUnusedTerms
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_Unused_lsa"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 21, strCode)
	End With
	Set rsUnusedTerms = Server.CreateObject("ADODB.Recordset")
	With rsUnusedTerms
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdUnusedTerms
	End With
End Sub
'***************************************
' End Sub openUnusedTermsRst
'***************************************


'***************************************
' Begin Sub closeUnusedTermsRst
'	Close the recordset containing the list of Unused Terms (Use References)
'***************************************
Sub closeUnusedTermsRst()
	If rsUnusedTerms.State <> adStateClosed Then
		rsUnusedTerms.Close
	End If
	Set cmdUnusedTerms = Nothing
	Set rsUnusedTerms = Nothing
End Sub
'***************************************
' End Sub closeUnusedTermsRst
'***************************************
%>
