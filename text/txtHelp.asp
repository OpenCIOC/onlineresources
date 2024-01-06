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
Dim TXT_CANNOT_PRINT_FIELD_HELP, _
	TXT_NO_FIELD_SELECTED, _
	TXT_NO_HELP_FOR_FIELD, _
	TXT_NO_SQL_HELP

Sub setTxtHelp()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_CANNOT_PRINT_FIELD_HELP = "Cannot print field help"
			TXT_NO_FIELD_SELECTED = "No field was selected"
			TXT_NO_HELP_FOR_FIELD = "No help was found for the selected field."
			TXT_NO_SQL_HELP = "Sorry...There is currently no SQL search help available"
		Case CULTURE_FRENCH_CANADIAN
			TXT_CANNOT_PRINT_FIELD_HELP = "Impossible d'imprimer l'Aide pour les champs de renseignements."
			TXT_NO_FIELD_SELECTED = "Aucun champ n'a éte sélectionné."
			TXT_NO_HELP_FOR_FIELD = "L'aide pour le champ sélectionné n'a pas été trouvée."
			TXT_NO_SQL_HELP = "Désolé, l'aide à la recherche SQL en Français n'est pas disponible en ce moment."
	End Select
End Sub

Call setTxtHelp()
Call addTextFile("setTxtHelp")
%>
