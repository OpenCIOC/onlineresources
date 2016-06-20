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
' Purpose: 		Opens a list of Related Concepts associated with a given Term.
'
'
%>

<%
Dim cmdRelatedConceptTerm, rsRelatedConceptTerm

'***************************************
' Begin Sub openRelatedConceptTermRst
'	Open a recordset containing a list of all Related Concepts associated with a given Term
'		strCode - Code of the Term
'***************************************
Sub openRelatedConceptTermRst(strCode)
	set cmdRelatedConceptTerm = Server.CreateObject("ADODB.Command")
	With cmdRelatedConceptTerm
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_RelatedConcept_lsa"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 21, strCode)
	End With
	Set rsRelatedConceptTerm = Server.CreateObject("ADODB.Recordset")
	With rsRelatedConceptTerm
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdRelatedConceptTerm
	End With
End Sub
'***************************************
' End Sub openRelatedConceptTermRst
'***************************************


'***************************************
' Begin Sub closeRelatedConceptTermRst
'	Close the recordset containing the list of Related Concepts
'***************************************
Sub closeRelatedConceptTermRst()
	If rsRelatedConceptTerm.State <> adStateClosed Then
		rsRelatedConceptTerm.Close
	End If
	Set cmdRelatedConceptTerm = Nothing
	Set rsRelatedConceptTerm = Nothing
End Sub
'***************************************
' End Sub closeRelatedConceptTermRst
'***************************************
%>
