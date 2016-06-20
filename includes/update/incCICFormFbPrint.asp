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
' Purpose: 		Contains special functions for displaying special (non-standard)
'				field types on the CIC Feedback form.
'
%>

<%
Function makeSubjectContentsFb(rst,bUseContent)
	Dim strReturn, strCon
	Dim xmlDoc, xmlNode, xmlChildNode
	Dim intID, strName
	
	strCon = vbNullString
	
	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With
	
	If bUseContent Then
		xmlDoc.loadXML Nz(rst("SUBJECTS_XML").Value,"<SUBJECTS/>")
	Else
		xmlDoc.loadXML "<SUBJECTS/>"
	End If

	Set xmlNode = xmlDoc.selectSingleNode("/SUBJECTS")

	If Not xmlNode Is Nothing Then
		For Each xmlChildNode in xmlNode.childNodes
			intID = xmlChildNode.getAttribute("ID")
			strName = xmlChildNode.getAttribute("Name")
		strReturn = strReturn & strCon & "<input type=""checkbox"" checked name=""SUBJECTS_LISTITEMS"" id=""SUBJECT_" & intID & """ value=" & AttrQs("#" & strName & "#") & ">&nbsp;<label for=""SUBJECTS_" & intID & """>" & strName & "</label>"
			strCon = " ; "
		Next
		strCon = "<br><br>"
	End If

	strReturn = strReturn & strCon & makeMemoFieldVal("SUBJECTS", _
							vbNullString, _
							TEXTAREA_ROWS_SHORT, _
							False) & _
		"<br>" & TXT_NOT_SURE_ENTER & " <a href=""javascript:openWin('" & makeLinkB("subjfind.asp") & "','sFind')"">" & TXT_SUBJECT_FINDER & "</a>."
	
	makeSubjectContentsFb = strReturn
End Function

Function makeTaxonomyContentsFb(rst,bUseContent)
	Dim strReturn
	Dim strTaxonomy
	
	If bUseContent Then
		strTaxonomy = rst("TAXONOMY")
	End If
	
	strReturn = makeMemoFieldVal("TAXONOMY", _
							strTaxonomy, _
							TEXTAREA_ROWS_LONG, _
							False) & _
		IIf(user_bLoggedIn,"<br>" & TXT_NOT_SURE_ENTER & " <a href=""javascript:openWinL('" & makeLink("tax.asp","MD=2",vbNullString) & "','tFind')"">" & TXT_TAXONOMY_FINDER & "</a>.", vbNullString)
	
	makeTaxonomyContentsFb = strReturn
End Function
%>
