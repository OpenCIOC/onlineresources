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
' Purpose: 		Opens a list of Taxonomy Sources and can produce a drop-down list.
'
'
%>

<%
Dim cmdListTaxonomySource, rsListTaxonomySource

'***************************************
' Begin Sub openTaxonomySourceListRst
'	Open a recordset containing a list of all Taxonomy Sources
'		bSortEq - False = Sort by English Name; True = Sort by French Name
'***************************************
Sub openTaxonomySourceListRst()
	Set cmdListTaxonomySource = Server.CreateObject("ADODB.Command")
	With cmdListTaxonomySource
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_Source_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListTaxonomySource = Server.CreateObject("ADODB.Recordset")
	With rsListTaxonomySource
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListTaxonomySource
	End With
End Sub
'***************************************
' End Sub openTaxonomySourceListRst
'***************************************


'***************************************
' Begin Sub closeTaxonomySourceListRst
'	Close the recordset containing the list of Taxonomy Sources
'***************************************
Sub closeTaxonomySourceListRst()
	If rsListTaxonomySource.State <> adStateClosed Then
		rsListTaxonomySource.Close
	End If
	Set cmdListTaxonomySource = Nothing
	Set rsListTaxonomySource = Nothing
End Sub
'***************************************
' End Sub closeTaxonomySourceListRst
'***************************************


'***************************************
' Begin Function makeTaxonomySourceList
'	Return the HTML for a drop-down list of the list of Taxonomy Sources.
'		intSelected - An Optional ID number indicating a value in the list to be marked SELECTED
'		strSelectName - The name of the drop-down list (select name)
'		bIncludeBlank - Include a blank entry for no selection
'		bIncludeNew - Include the >> CREATE NEW << entry
'		bMultiple - If true, the list is multiple-select; otherwise, it is a drop-down.
'***************************************
Function makeTaxonomySourceList(intSelected, strSelectName, strSelectId, bIncludeBlank, bIncludeNew, bMultiple)
	Dim strReturn
	With rsListTaxonomySource
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
				If bMultiple Then
					strReturn = strReturn & "<option value=""_X_"">" & TXT_UNKNOWN_NO_VALUE & "</option>"				
				Else
					strReturn = strReturn & "<option value=""""> -- </option>"
				End If
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("TAX_SRC_ID") & """"
				If intSelected = .Fields("TAX_SRC_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("SourceName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeTaxonomySourceList = strReturn
End Function
'***************************************
' End Function makeTaxonomySourceList
'***************************************
%>

