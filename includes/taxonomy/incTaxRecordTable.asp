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
' Purpose:		Print a list of Record numbers and Organization/Program names.
'				Names are linked to display a list of associated Taxonomy Terms if available.
'
'
%>
<%
'***************************************
' Begin Sub printTaxRecordTable
'	Print a list of Record numbers and Organization/Program names.
'	Names are linked to display a list of associated Taxonomy Terms if available.
'***************************************
Sub printTaxRecordTable()
%>
<p><%=TXT_FOUND%><strong><%=rsTaxSearch.RecordCount%></strong><%=TXT_MATCHES%></p>
<%
If Not rsTaxSearch.EOF Then

	Dim strAltRow
	strAltRow = vbNullString
	
	Dim fldNUM, _
		fldOrgName, _
		fldHasTerms
	
	Dim strOrgName

%>
<table class="NoBorder cell-padding-2" width="100%">
<tr>
	<th class="RevTitleBox" width="140"><%=TXT_RECORD_NUM%></a></th>
	<th class="RevTitleBox"><%=TXT_NAME%></th>
</tr>
<% 
	With rsTaxSearch
		If Not .EOF Then
			Set fldNUM = .Fields("NUM")
			Set fldOrgName = .FieldS("ORG_NAME_FULL")
			Set fldHasTerms = .Fields("HAS_TERMS")
			
			While Not .EOF
				If fldHasTerms Then
					strOrgName = "<span class=""TaxLink SimulateLink taxExpandTerm"" data-closed=""true"" data-url=""" & Server.HTMLEncode(makeTaxLink(ps_strPathToStart & "jsonfeeds/tax_recordterms.asp", "NUM=" & fldNUM.Value, vbNullString)) & """>" & fldOrgName.Value & "</a>"
				End If
%>
<tr valign="TOP">
	<td class="TaxBasic<%=strAlTrow%>"><%=fldNUM.Value%></td>
	<td class="TaxBasic<%=strAlTrow%>"><div><%=strOrgName%></div><div class="taxDetail"></div></td>
</tr>
	
<%
				strAltRow = IIf(Nl(strAltRow),"B",vbNullString)
				.MoveNext
			Wend
		End If
	End With
%>
</table>
<%
End If

End Sub
'***************************************
' End Function printTaxRecordTable
'***************************************
%>
