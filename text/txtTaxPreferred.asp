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
%>

<%
Dim TXT_ADD_NEW_ONLY, _
	TXT_ENTER_LIST_OF_TERMS, _
	TXT_PREFERRED_TERM_LIST_UPDATED, _
	TXT_RESET_ALL, _
	TXT_TERM_LIST

Sub setTxtTaxPreferred()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_NEW_ONLY = "Add new Preferred Terms"
			TXT_ENTER_LIST_OF_TERMS = "Enter List of valid Taxonomy Terms separated by space, comma, semi-colon, or new line."
			TXT_PREFERRED_TERM_LIST_UPDATED = "The Preferred Taxonomy Term list was updated successfully."
			TXT_RESET_ALL = "Reset entire list of Preferred Terms"
			TXT_TERM_LIST = "Term List"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_NEW_ONLY = "TR_FR -- Add new Preferred Terms"
			TXT_ENTER_LIST_OF_TERMS = "TR_FR -- Enter List of valid Taxonomy Terms separated by space, comma, semi-colon, or new line."
			TXT_PREFERRED_TERM_LIST_UPDATED = "TR_FR -- The Preferred Taxonomy Term list was updated successfully."
			TXT_RESET_ALL = "TR_FR -- Reset entire list of Preferred Terms"
			TXT_TERM_LIST = "Liste des termes"
	End Select
End Sub

Call setTxtTaxPreferred()
%>
