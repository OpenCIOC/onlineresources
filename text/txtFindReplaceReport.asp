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
Dim TXT_AND_REPLACE_IT_WITH, _
	TXT_COULD_NOT_REPLACE_IN, _
	TXT_FIELDS_MATCHED, _
	TXT_FIND_REPLACE_REPORT, _
	TXT_INST_CONFIRM_CLEAR, _
	TXT_INST_NO_TEXT_APPEND, _
	TXT_INST_NO_TEXT_FIND, _
	TXT_INST_NO_TEXT_REPLACE, _
	TXT_INST_PRINT_REPORT, _
	TXT_LIST_ALTERED_RECORDS, _
	TXT_ORIGINAL_LIST, _
	TXT_RECORD, _
	TXT_RECORDS_WERE_ALTERED, _
	TXT_RETURNED_RESULTS, _
	TXT_TEXT_TOO_LONG, _
	TXT_YOUR_SEARCH_TO_FIND

Sub setTxtFindReplaceReport()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_AND_REPLACE_IT_WITH = "and replace it with" & TXT_COLON
			TXT_COULD_NOT_REPLACE_IN = "Could not replace in"
			TXT_FIELDS_MATCHED = "Field(s) Matched"
			TXT_FIND_REPLACE_REPORT = "Find and Replace Report"
			TXT_INST_CONFIRM_CLEAR = "You must check the box confirming you want to delete the contents of the field"
			TXT_INST_NO_TEXT_APPEND = "You have not specified text to append/prepend"
			TXT_INST_NO_TEXT_FIND = "You have not specified text to find"
			TXT_INST_NO_TEXT_REPLACE = "You have not specified a new value for the field"
			TXT_INST_PRINT_REPORT = "You should print the report below for your records, and confirm that the find and replace was successful by examining a few records."
			TXT_LIST_ALTERED_RECORDS = "List of Altered Records"
			TXT_ORIGINAL_LIST = "Original List of Records for Find/Replace"
			TXT_RECORD = "Record"
			TXT_RECORDS_WERE_ALTERED = " records were altered. Use the button below to execute a search on altered records or "
			TXT_RETURNED_RESULTS = "returned the following results...."
			TXT_TEXT_TOO_LONG = "text too long"
			TXT_YOUR_SEARCH_TO_FIND = "Your search to find" & TXT_COLON
		Case CULTURE_FRENCH_CANADIAN
			TXT_AND_REPLACE_IT_WITH = "et remplacer par" & TXT_COLON
			TXT_COULD_NOT_REPLACE_IN = "N'a pas pu remplacer dans"
			TXT_FIELDS_MATCHED = "Champ(s) apparié(s)"
			TXT_FIND_REPLACE_REPORT = "Rapport Rechercher/Remplacer"
			TXT_INST_CONFIRM_CLEAR = "Vous devez cocher le bouton confirmant que vous voulez supprimer les contenus du champ"
			TXT_INST_NO_TEXT_APPEND = "Vous n'avez pas précisé de texte à ajouter en suffixe/préfixe"
			TXT_INST_NO_TEXT_FIND = "Vous n'avez pas précisé de texte à rechercher"
			TXT_INST_NO_TEXT_REPLACE = "Vous n'avez pas précisé de nouvelle valeur pour le champ"
			TXT_INST_PRINT_REPORT = "Il est conseillé d'imprimer le rapport ci-dessous à des fins de référence et de vérifier que l'action Rechercher/Remplacer a réussi en examinant quelques dossiers."
			TXT_LIST_ALTERED_RECORDS = "Liste des dossiers modifiés"
			TXT_ORIGINAL_LIST = "Liste originale des dossiers pour Rechercher/Remplacer"
			TXT_RECORD = "Dossier"
			TXT_RECORDS_WERE_ALTERED = " dossiers ont été modifiés. Utiliser le bouton ci-dessous pour faire une recherche sur les dossiers modifiés ou "
			TXT_RETURNED_RESULTS = "a retourné les résultats suivants...."
			TXT_TEXT_TOO_LONG = "le texte est trop long"
			TXT_YOUR_SEARCH_TO_FIND = "Votre recherche pour trouver" & TXT_COLON
	End Select
End Sub

Call setTxtFindReplaceReport()
%>
