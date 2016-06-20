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
' Purpose: 		Functions for validating Taxonomy information from the input form.
'
'
%>

<%

' List of invalid Terms and the Term IDs for valid Terms
Dim strBadTaxTerms, _
	strNewTCs

' List of invalid Concepts and the Concept IDs for valid Concepts
Dim strBadConcepts, _
	strNewRCIDs

'***************************************
' Begin Function checkTaxTerms
'	Takes a list of Term names or codes and returns a list of non-matching Terms,
'	and IDs for Terms where a match was found.
'		strNewTerm - List of Term(s) to be validated
'		bAllowInactive - Allow a Term marked Inactive to validate successfully
'	Returns any error messages from the stored procedure.
'***************************************
Function checkTaxTerms(strNewTerm, bAllowInactive)
	Dim cmdTerm, _
		rsTerm
	
	If Not Nl(strNewTerm) Then
		Set cmdTerm = Server.CreateObject("ADODB.Command")
		With cmdTerm
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_TAX_UCheck_Terms"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
			.Parameters.Append .CreateParameter("@NewTerms", adLongVarChar, adParamInput, -1, strNewTerm)
			.Parameters.Append .CreateParameter("@BadTerms", adVarChar, adParamOutput, 8000)
			.Parameters.Append .CreateParameter("@NewTCs", adVarChar, adParamOutput, 8000)
			.Parameters.Append .CreateParameter("@AllowInactive", adBoolean, adParamInput, 1, IIf(bAllowInactive,SQL_TRUE,SQL_FALSE))
		End With
	
		Set rsTerm = cmdTerm.Execute
		Set rsTerm = rsTerm.NextRecordset

		If Not Nl(cmdTerm.Parameters("@BadTerms")) Then
			strBadTaxTerms = cmdTerm.Parameters("@BadTerms")
		End If
		If cmdTerm.Parameters("@RETURN_VALUE").Value <> 0 Or Err.Number <> 0 Then
			checkTaxTerms = TXT_ERROR & TXT_UNKNOWN_ERROR_OCCURED
		Else
			strNewTCs = cmdTerm.Parameters("@NewTCs")
		End If
	End If
End Function
'***************************************
' End Function checkTaxTerms
'***************************************


'***************************************
' Begin Function checkRelatedConcepts
'	Takes a list of Related Concept names or codes and returns a list of non-matching Concepts,
'	and IDs for Concepts where a match was found.
'		strNewConcept - List of Related Concept(s) to be validated
'	Returns any error messages from the stored procedure.
'***************************************
Function checkRelatedConcepts(strNewConcept)
	Dim cmdConcept, _
		rsConcept
	
	If Not Nl(strNewConcept) Then
		Set cmdConcept = Server.CreateObject("ADODB.Command")
		With cmdConcept
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_TAX_UCheck_Concepts"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
			.Parameters.Append .CreateParameter("@NewConcepts", adLongVarChar, adParamInput, -1, strNewConcept)
			.Parameters.Append .CreateParameter("@BadConcepts", adVarChar, adParamOutput, 8000)
			.Parameters.Append .CreateParameter("@NewTCs", adVarChar, adParamOutput, 8000)
		End With
	
		Set rsConcept = cmdConcept.Execute
		Set rsConcept = rsConcept.NextRecordset

		If Not Nl(cmdConcept.Parameters("@BadConcepts")) Then
			strBadConcepts = cmdConcept.Parameters("@BadConcepts")
		End If
		If cmdConcept.Parameters("@RETURN_VALUE").Value <> 0 Or Err.Number <> 0 Then
			checkRelatedConcepts = TXT_ERROR & TXT_UNKNOWN_ERROR_OCCURED
		Else
			strNewRCIDs = cmdConcept.Parameters("@NewTCs")
		End If
	End If
End Function
'***************************************
' End Function checkRelatedConcepts
'***************************************

'***************************************
' Begin Sub checkTaxonomyCode
'	Validates that the given code portions conform to Code specifications.
'	Any errors are added to the Error List variable for the page (strErrorList).
'		strCdLvl1 - Level 1 Code value
'		strCdLvl2 - Level 2 Code value
'		strCdLvl3 - Level 3 Code value
'		strCdLvl4 - Level 4 Code value
'		strCdLvl5 - Level 5 Code value
'		strCdLvl6 - Level 6 Code value
'***************************************
Sub checkTaxonomyCode(strCdLvl1,strCdLvl2,strCdLvl3,strCdLvl4,strCdLvl5,strCdLvl6)
	If Not reEquals(strCdLvl1,"[A-Z]",False,False,True,False) Then
		strErrorList = strErrorList & "<li>" & TXT_INVALID_TAXONOMY_CODE & "</li>"
	ElseIf Not Nl(strCdLvl2) Then
		If Not reEquals(strCdLvl2,"[A-Z]",False,False,True,False) Then
			strErrorList = strErrorList & "<li>" & TXT_INVALID_TAXONOMY_CODE & "</li>"
		End If
	ElseIf Not Nl(strCdLvl3) Then
		If Nl(strCdLvl2) Or Not reEquals(strCdLvl3,"[0-9][0-9][0-9][0-9]",True,False,True,False) Then
			strErrorList = strErrorList & "<li>" & TXT_INVALID_TAXONOMY_CODE & "</li>"
		End If
	ElseIf Not Nl(strCdLvl4) Then
		If Nl(strCdLvl3) Or Not reEquals(strCdLvl4,"[0-9][0-9][0-9][0-9]",True,False,True,False) Then
			strErrorList = strErrorList & "<li>" & TXT_INVALID_TAXONOMY_CODE & "</li>"
		End If
	ElseIf Not Nl(strCdLvl5) Then
		If Nl(strCdLvl4) Or Not reEquals(strCdLvl5,"[0-9][0-9][0-9]",True,False,True,False) Then
			strErrorList = strErrorList & "<li>" & TXT_INVALID_TAXONOMY_CODE & "</li>"
		End If
	ElseIf Not Nl(strCdLvl6) Then
		If Nl(strCdLvl5) Or Not reEquals(strCdLvl6,"[0-9][0-9]",True,False,True,False) Then
			strErrorList = strErrorList & "<li>" & TXT_INVALID_TAXONOMY_CODE & "</li>"
		End If
	End If
End Sub
'***************************************
' End Sub checkTaxonomyCode
'***************************************
%>
