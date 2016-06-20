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
' Purpose: 		Opens a list of Terms related to the given Term
'
'
%>

<%
Dim cmdSeeAlsoTerms, rsSeeAlsoTerms

'***************************************
' Begin Sub openSeeAlsoTermsRst
'	Open a recordset containing a list of other related Terms ("See Also") associated with a given Term
'		strCode - Code of the Term
'***************************************
Sub openSeeAlsoTermsRst(strCode)
	set cmdSeeAlsoTerms = Server.CreateObject("ADODB.Command")
	With cmdSeeAlsoTerms
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_SeeAlso_lsa"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 21, strCode)
	End With
	Set rsSeeAlsoTerms = Server.CreateObject("ADODB.Recordset")
	With rsSeeAlsoTerms
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdSeeAlsoTerms
	End With
End Sub
'***************************************
' End Sub openSeeAlsoTermsRst
'***************************************

'***************************************
' Begin Sub closeSeeAlsoTermsRst
'	Close the recordset containing the list of "See Also" Terms
'***************************************
Sub closeSeeAlsoTermsRst()
	If rsSeeAlsoTerms.State <> adStateClosed Then
		rsSeeAlsoTerms.Close
	End If
	Set cmdSeeAlsoTerms = Nothing
	Set rsSeeAlsoTerms = Nothing
End Sub
'***************************************
' End Sub closeSeeAlsoTermsRst
'***************************************
%>
