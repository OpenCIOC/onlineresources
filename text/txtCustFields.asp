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
Dim TXT_ALL_FIELDS_MUST_MATCH, _
	TXT_INCLUDE_FIELDS_IN_DISPLAY, _
	TXT_IS_NULL, _
	TXT_NOT_NULL, _
	TXT_SOME_FIELDS_NOT_AVAILABLE


Sub setTxtCustFields()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ALL_FIELDS_MUST_MATCH = "<strong>All</strong> the selected fields must match"
			TXT_INCLUDE_FIELDS_IN_DISPLAY = "Include selected field(s) in results display table *"
			TXT_IS_NULL = "Is Null"
			TXT_NOT_NULL = "Is Not Null"
			TXT_SOME_FIELDS_NOT_AVAILABLE = "* Note: Some fields are not available as custom results fields"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ALL_FIELDS_MUST_MATCH = "Il doit y avoir concordance de <strong>tous</strong> les champs sélectionnés."
			TXT_INCLUDE_FIELDS_IN_DISPLAY = "Inclure le(s) champ(s) sélectionné(s) dans le tableau d'affichage des résultats. *"
			TXT_IS_NULL = "Est nul"
			TXT_NOT_NULL = "N'est pas nul"
			TXT_SOME_FIELDS_NOT_AVAILABLE = "* Note : Certains champs ne sont pas disponibles en tant que champs de résultats personnalisés."
	End Select
End Sub

Call setTxtCustFields()
%>
