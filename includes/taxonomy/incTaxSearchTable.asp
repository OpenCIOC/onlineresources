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
' Purpose:		Print a table of Term Codes and Names.
'
'
%>
<%
'Sort Order Constants
Const SORT_BY_CODE_ASC = 0
Const SORT_BY_CODE_DESC = 1
Const SORT_BY_NAME_ASC = 2
Const SORT_BY_NAME_DESC = 3
Const SORT_BY_RELEVANCE = 4

'***************************************
' Begin Sub printTaxSearchTable
'	Print a table of Term Codes and Names.
'***************************************
Sub printTaxSearchTable()
%>
<p><%=TXT_FOUND%><strong><%=rsTaxSearch.RecordCount%></strong><%=TXT_MATCHES%>. <%If intSearchSort = SORT_BY_RELEVANCE Then%> <strong><%=TXT_SORTED_BY_RELEVANCE%></strong><%End If%></p>
<%
If Not rsTaxSearch.EOF Then

	'Icon links
	Dim strIconEdit, _
		strIconSelect, _
		strLinkSearch, _
		strIconZoom, _
		strLinkTermInfo

	'Field values
	Dim fldCode, _
		fldCdLvl, _
		fldTerm, _
		fldActive, _
		fldHasRecords, _
		fldCountRecords
	
	Dim strAltRow
	strAltRow = vbNullString

	Dim strCodeSort, strNameSort
	strCodeSort = "noplusminus"
	strNameSort = "noplusminus"
	Select Case intSearchSort
		Case SORT_BY_CODE_ASC
			strCodeSort = "up"

		Case SORT_BY_CODE_DESC
			strCodeSort = "down"

		Case SORT_BY_NAME_ASC
			strNameSort = "up"

		Case SORT_BY_NAME_DESC
			strNameSort = "down"
	End Select 
%>
<table class="NoBorder cell-padding-2" width="100%">
<thead>
<tr>
	<th class="RevTitleBox" width="130"><span class="taxHeaderSort SimulateLink TaxLink RevTitleText" data-which="0" data-state="<%= strCodeSort %>"><%=TXT_CODE%></span>&nbsp;<img src="<%=ps_strPathToStart%>images/<%= strCodeSort %>.gif" border="0"></th>
	<th class="RevTitleBox"><span class="taxHeaderSort SimulateLink TaxLink RevTitleText" data-which="1" data-state="<%= strNameSort %>"><%=TXT_NAME%></span>&nbsp;<img src="<%=ps_strPathToStart%>images/<%= strNameSort %>.gif" border="0"></th>
</tr>
</thead>
<tbody>
<% 
	With rsTaxSearch

		Set fldCode = .Fields("Code")
		Set fldCdLvl = .Fields("CdLvl")
		Set fldTerm = .Fields("Term")
		Set fldActive = .Fields("Active")
		Set fldHasRecords = .Fields("HasRecords")
		Set fldCountRecords = .Fields("CountRecords")
		
		While Not .EOF	
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
			If (intTaxSearchMode = MODE_ADVANCED And fldHasRecords) Or _
					(intTaxSearchMode = MODE_INDEX And fldActive And fldCdLvl > 1) Then
				strIconSelect = "&nbsp;<a href=""#javascript"" onClick=""parent.addBuildTerm(" & JsQs(fldCode.Value) & "," & JsQs(fldTerm.Value) & "); return false"">" & ICON_SELECT & "</a>"
			Else
				strIconSelect = vbNullString
			End If

			'If this Term has associated records, include a record count.
			'In Basic Mode, the record count is linked to a search.
			If fldCountRecords.Value > 0 Then
				If intTaxSearchMode = MODE_BASIC Then
					strLinkSearch = "&nbsp;<a class=""TaxLink"" href=""" & _
						makeLink(ps_strPathToStart & "results.asp","TMCR=on&TMC=" & fldCode.Value,vbNullString) & """>[<strong>" & fldCountRecords.Value & "</strong>]</a>"
				Else
					strLinkSearch = "&nbsp;[<strong>" & fldCountRecords.Value & "</strong>]"
				End If
			Else
				strLinkSearch = vbNullString
			End If
			
			'Link the Term Name to display more detailed Term Information.
			'If the Term is inactive, make it Alert-coloured.
			strLinkTermInfo = "<span class=""taxExpandTerm SimulateLink TaxLink" & IIf(fldActive,vbNullString,"Inactive") & """ data-closed=""true"" data-taxcode=""" & fldCode.Value & """ data-url=""" & Server.HTMLEncode(makeTaxLink(ps_strPathToStart & "jsonfeeds/tax_moreinfo.asp", "TC=" & fldCode.Value, vbNullString)) & """>" & fldTerm.Value & "</span>"
%>
<tr data-sortkey="[<%= Server.HTMLEncode(JSONQs(fldCode.Value, True)) %>, <%= Server.HTMLEncode(JSONQs(fldTerm.Value, True))%>]">
	<td class="TaxBasic<%=strAlTrow%>"><%=fldCode.Value%></td>
	<td class="TaxBasic<%=strAlTrow%>"><span class="CodeLevel1"><%=strLinkTermInfo%><%=strIconEdit%><%=strIconZoom%><%=strLinkSearch%><%=strIconSelect%></span><div class="taxDetail"></div></td>
</tr>
	
<%
			strAltRow = IIf(Nl(strAltRow),"B",vbNullString)
			.MoveNext
		Wend
	End With
%>
</tbody>
</table>
<%
End If

End Sub
'***************************************
' End Sub printTaxSearchTable
'***************************************
%>
