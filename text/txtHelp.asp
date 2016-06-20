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
Dim TXT_CANNOT_PRINT_PAGE_HELP, _
	TXT_CANNOT_PRINT_FIELD_HELP, _
	TXT_NO_FIELD_SELECTED, _
	TXT_NO_HELP_FOR_FIELD, _
	TXT_NO_HELP_FOR_PAGE, _
	TXT_NO_PAGE_CHOSEN, _
	TXT_NO_SQL_HELP, _
	TXT_VIEW_CURRENT_HELP

Sub setTxtHelp()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_CANNOT_PRINT_PAGE_HELP = "Cannot print page help" & TXT_COLON
			TXT_CANNOT_PRINT_FIELD_HELP = "Cannot print field help"
			TXT_NO_FIELD_SELECTED = "No field was selected"
			TXT_NO_HELP_FOR_FIELD = "No help was found for the selected field."
			TXT_NO_HELP_FOR_PAGE = "No help was found for the selected page."
			TXT_NO_PAGE_CHOSEN = "No page was chosen"
			TXT_NO_SQL_HELP = "Sorry...There is currently no SQL search help available"
			TXT_VIEW_CURRENT_HELP = "View the current help"
		Case CULTURE_FRENCH_CANADIAN
			TXT_CANNOT_PRINT_PAGE_HELP = "Impossible d'imprimer l'Aide à la page" & TXT_COLON
			TXT_CANNOT_PRINT_FIELD_HELP = "Impossible d'imprimer l'Aide pour les champs de renseignements."
			TXT_NO_FIELD_SELECTED = "Aucun champ n'a éte sélectionné."
			TXT_NO_HELP_FOR_FIELD = "L'aide pour le champ sélectionné n'a pas été trouvée."
			TXT_NO_HELP_FOR_PAGE = "L'aide pour la page sélectionnée n'a pas été trouvée."
			TXT_NO_PAGE_CHOSEN = "Aucune page n'a été sélectionnée."
			TXT_NO_SQL_HELP = "Désolé, l'aide à la recherche SQL en Français n'est pas disponible en ce moment."
			TXT_VIEW_CURRENT_HELP = "Visualiser l'aide courante"
	End Select
End Sub

Call setTxtHelp()
Call addTextFile("setTxtHelp")
%>
