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
' Purpose: 		Opens a list of Facets and can produce a drop-down list.
'
'
%>

<%
Dim cmdListTaxonomyFacet, rsListTaxonomyFacet

'***************************************
' Begin Sub openTaxonomyFacetListRst
'	Open a recordset containing a list of all Facets
'		bSortEq - False = Sort by English Name; True = Sort by French Name
'***************************************
Sub openTaxonomyFacetListRst()
	Set cmdListTaxonomyFacet = Server.CreateObject("ADODB.Command")
	With cmdListTaxonomyFacet
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_Facet_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListTaxonomyFacet = Server.CreateObject("ADODB.Recordset")
	With rsListTaxonomyFacet
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListTaxonomyFacet
	End With
End Sub
'***************************************
' End Sub openTaxonomyFacetListRst
'***************************************


'***************************************
' Begin Sub closeTaxonomyFacetListRst
'	Close the recordset containing the list of Facets
'***************************************
Sub closeTaxonomyFacetListRst()
	If rsListTaxonomyFacet.State <> adStateClosed Then
		rsListTaxonomyFacet.Close
	End If
	Set cmdListTaxonomyFacet = Nothing
	Set rsListTaxonomyFacet = Nothing
End Sub
'***************************************
' End Sub openTaxonomyFacetListRst
'***************************************


'***************************************
' Begin Function makeTaxonomyFacetList
'	Return the HTML for a drop-down list of the list of Facets.
'		intSelected - An Optional ID number indicating a value in the list to be marked SELECTED
'		strSelectName - The name of the drop-down list (select name)
'		bIncludeBlank - Include a blank entry for no selection
'		bIncludeNew - Include the >> CREATE NEW << entry
'		bMultiple - If true, the list is multiple-select; otherwise, it is a drop-down.
'***************************************
Function makeTaxonomyFacetList(intSelected, strSelectName, strSelectId, bIncludeBlank, bIncludeNew, bMultiple)
	Dim strReturn
	With rsListTaxonomyFacet
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF And Not bIncludeNew Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select id=" & AttrQs(strSelectId) & " name=" & AttrQs(strSelectName) & IIf(bMultiple," MULTIPLE",vbNullString) & " class=""form-control"">"
			If bIncludeNew Then
				strReturn = strReturn & "<option value="""">" & TXT_CREATE_NEW & "</option>"
			ElseIf bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("FC_ID") & """"
				If intSelected = .Fields("FC_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("Facet") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeTaxonomyFacetList = strReturn
End Function
'***************************************
' End Function makeTaxonomyFacetList
'***************************************
%>

