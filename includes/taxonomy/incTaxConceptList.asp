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
' Purpose: 		Opens a list of Related Concepts and can produce a drop-down list.
'
'
%>

<%
Dim cmdListRelatedConcept, rsListRelatedConcept

'***************************************
' Begin Sub openRelatedConceptListRst
'	Open a recordset containing a list of all Related Concepts
'		bSortEq - False = Sort by English Name; True = Sort by French Name
'		bAll - False = Include values for bSortEq language, True = Include values from both languages
'***************************************
Sub openRelatedConceptListRst(bAll)
	Set cmdListRelatedConcept = Server.CreateObject("ADODB.Command")
	With cmdListRelatedConcept
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_RelatedConcept_l" & IIf(bAll,"a",vbNullString)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListRelatedConcept = Server.CreateObject("ADODB.Recordset")
	With rsListRelatedConcept
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListRelatedConcept
	End With
End Sub
'***************************************
' End Sub openRelatedConceptListRst
'***************************************


'***************************************
' Begin Sub closeRelatedConceptListRst
'	Close the recordset containing the list of Related Concepts
'***************************************
Sub closeRelatedConceptListRst()
	If rsListRelatedConcept.State <> adStateClosed Then
		rsListRelatedConcept.Close
	End If
	Set cmdListRelatedConcept = Nothing
	Set rsListRelatedConcept = Nothing
End Sub
'***************************************
' End Sub openRelatedConceptListRst
'***************************************


'***************************************
' Begin Function makeRelatedConceptList
'	Return the HTML for a drop-down list of the list of Related Concepts.
'		intSelected - An Optional ID number indicating a value in the list to be marked SELECTED
'		strSelectName - The name of the drop-down list (select name)
'		bIncludeBlank - Include a blank entry for no selection
'		bIncludeNew - Include the >> CREATE NEW << entry
'***************************************
Function makeRelatedConceptList(intSelected, strSelectName, bIncludeBlank, bIncludeNew)
	Dim strReturn
	
	Dim fldRCID, _
		fldCode, _
		fldConceptName

	With rsListRelatedConcept
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			Set fldRCID = .Fields("RC_ID")
			Set fldCode = .Fields("Code")
			Set fldConceptName = .Fields("ConceptName")
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeNew Then
				strReturn = strReturn & "<option value="""">" & TXT_CREATE_NEW & "</option>"
			ElseIf bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & fldRCID.Value & """"
				If intSelected = fldRCID.Value Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & fldConceptName.Value & " (" & fldCode.Value & ")</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeRelatedConceptList = strReturn
End Function
'***************************************
' End Function makeRelatedConceptList
'***************************************
%>

