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
' Purpose:		Print a list of Level 1 Taxonomy Terms for Drill Down search
'
'
%>

<%
'***************************************
' Begin Sub printTaxDrillDownTable
'	Print a list of Level 1 Taxonomy Terms for Drill Down search
'***************************************
Sub printTaxDrillDownTable()

	'Icon links
	Dim strIconPlusMinus, _
		strIconEdit, _
		strIconSelect, _
		strIconZoom, _
		strLinkTermInfo

	'Field values
	Dim fldCode, _
		fldTerm, _
		fldActive, _
		fldHasRecords, _
		fldHasChildren

	'Base link to open a branch of child Terms
	Dim strBaseRowURL
	strBaseRowURL = makeTaxLink(ps_strPathToStart & "jsonfeeds/tax_ddrows.asp", "TC=", vbNullString)

%>
<table class="NoBorder cell-padding-2" width="100%">
<tr>
	<th class="RevTitleBox" width="140"><%=TXT_CODE%></th>
	<th class="RevTitleBox"><%=TXT_NAME%></th>
</tr>
<% 
	With rsTaxSearch
		Set fldCode = .Fields("Code")
		Set fldTerm = .Fields("Term")
		Set fldActive = .Fields("Active")
		Set fldHasRecords = .Fields("HasRecords")
		Set fldHasChildren = .Fields("HasChildren")
		
		While NOT .EOF
			'If there are child terms (Sub-Topics), create a linked icon to expand the tree
			If fldHasChildren Then
				strIconPlusMinus = "<span class=""SimulateLink taxPlusMinus"" data-taxcode=""" & Server.HTMLEncode(Replace(fldCode.Value,"-L",vbNullString)) & """ data-url=""" & Server.HTMLEncode(strBaseRowURL & fldCode.Value) & """ data-level=""1"" data-closed=""true"">" & ICON_PLUS & "</span>"
			Else
				strIconPlusMinus = ICON_NOPLUSMINUS
			End If
		
			'If we are in Basic Search Mode and the user is a Super User, include a linked edit icon
			If user_bSuperUserCIC And intTaxSearchMode = MODE_BASIC And bTaxAdmin Then
				strIconEdit = "&nbsp;<a href=""" & _
					makeLink(ps_strPathToStart & "tax_edit.asp","TC=" & fldCode.Value,vbNullString) & """>" & ICON_EDIT & "</a>"
			Else
				strIconEdit = vbNullString
			End If

			'If we are in Basic Search Mode and the Term (or its sub-Topics) have associated records, include a search link
			If fldHasRecords And intTaxSearchMode = MODE_BASIC Then
				strIconZoom = "&nbsp;<a class=""TaxLink"" href=""" & _
					makeLink(ps_strPathToStart & "results.asp","TMC=" & fldCode.Value,vbNullString) & """>" & ICON_ZOOM & "</a>"
			Else
				strIconZoom = vbNullString
			End If

			'If we are in Advanced Search Mode and the Term (or its sub-Topics) have associated records, include a select link
			'You cannot select Level 1 Terms to add to a record (so not used in Index Mode).
			If (intTaxSearchMode = MODE_ADVANCED And fldHasRecords) Then
				strIconSelect = "&nbsp;<a href=""#javascript"" onClick=""parent.addBuildTerm(" & JsQs(fldCode.Value) & "," & JsQs(fldTerm.Value) & "); return false"">" & ICON_SELECT & "</a>"
			Else
				strIconSelect = vbNullString
			End If
			
			'Link the Term Name to display more detailed Term Information.
			'If the Term is inactive, make it Alert-coloured.
			strLinkTermInfo = "&nbsp;<span class=""taxExpandTerm SimulateLink TaxLink" & IIf(fldActive,vbNullString,"Inactive") & """ data-closed=""true"" data-taxcode=""" & fldCode.Value & """ data-url=""" & Server.HTMLEncode(makeTaxLink(ps_strPathToStart & "jsonfeeds/tax_moreinfo.asp", "TC=" & fldCode.Value, vbNullString)) & """>" & fldTerm.Value & "</span>"
%>
	<tr valign="TOP" class="TaxRowLevel1">
		<td class="TaxLevel1" style="font-size:larger;"><%=fldCode.Value%></td>
		<td class="TaxLevel1"><div class="CodeLevel1" style="font-size:larger;"><%=strIconPlusMinus%><%=strLinkTermInfo%><%=strIconEdit%><%=strIconZoom%><%=strIconSelect%></div><div class="taxDetail"></div></td>
	</tr>
	
<%
			.MoveNext
		Wend
	End With
%>
</table>
<%
End Sub
'***************************************
' End Sub printDrillDownTable
'***************************************
%>
