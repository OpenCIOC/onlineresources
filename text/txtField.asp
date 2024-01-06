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
Dim	TXT_CHANGE_EXTRA_FIELD_FAILED, _
	TXT_CREATE_EDIT_EXTRA_FIELDS, _
	TXT_DISPLAY, _
	TXT_FIELD_LENGTH, _
	TXT_FULL_TEXT_INDEX, _
	TXT_GLOBAL_HELP, _
	TXT_INST_FIELD_LENGTH, _
	TXT_INST_FIELD_NAME, _
	TXT_NEW_FIELD, _
	TXT_NO_CHANGES_MADE, _
	TXT_NO_YEAR, _
	TXT_REQUIRED, _
	TXT_UPDATE_FIELD_HELP, _
	TXT_UPDATE_LOCAL_FIELD_HELP, _
	TXT_VIEW_EDIT_FIELD_HELP

Sub setTxtField()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_CHANGE_EXTRA_FIELD_FAILED = "Change &quot;Extra&quot; Field Setup Failed"
			TXT_CREATE_EDIT_EXTRA_FIELDS = "Create / Edit &quot;Extra&quot; Fields"
			TXT_DISPLAY = "Display"
			TXT_FIELD_LENGTH = "Max. Length (1-8000)"
			TXT_FULL_TEXT_INDEX = "Full-Text Indexed"
			TXT_GLOBAL_HELP = "(Global Help)"
			TXT_INST_FIELD_LENGTH = "Field length must be between a number from 1-8000"
			TXT_INST_FIELD_NAME = "Field Name must be alpha-numeric; no special characters or spaces allowed. Maximum 25 characters."
			TXT_NEW_FIELD = "New Field"
			TXT_NO_CHANGES_MADE = "No changes were made"
			TXT_NO_YEAR = "No Year"
			TXT_UPDATE_FIELD_HELP = "Update Field Help"
			TXT_UPDATE_LOCAL_FIELD_HELP = "Update Local Field Help"
			TXT_VIEW_EDIT_FIELD_HELP = "Edit Field Help"
		Case CULTURE_FRENCH_CANADIAN
			TXT_CHANGE_EXTRA_FIELD_FAILED = "La modification de la gestion du champ &quot;supplémentair&quot;e a échoué"
			TXT_CREATE_EDIT_EXTRA_FIELDS = "Créer / Modifier des champs &quot;supplémentaires&quot;"
			TXT_DISPLAY = "Affichage"
			TXT_FIELD_LENGTH = "Longueur maximum (1-8000)"
			TXT_FULL_TEXT_INDEX = "Indexé en texte intégral"
			TXT_GLOBAL_HELP = "(Aide globale)"
			TXT_INST_FIELD_LENGTH = "La longueur du champs doit être un nombre compris entre 1 et 8 000"
			TXT_INST_FIELD_NAME = "Le nom du champ doit être alpha-numérique ; les caractères spéciaux et les espaces ne sont pas autorisés. 25 caractères maximum."
			TXT_NEW_FIELD = "TR_FR -- New Field"
			TXT_NO_CHANGES_MADE = "Aucune modification n'a été effectuée"
			TXT_NO_YEAR = "Pas d'année"
			TXT_UPDATE_FIELD_HELP = "Mise à jour de l'aide sur les champs"
			TXT_UPDATE_LOCAL_FIELD_HELP = "Mettre à jour l'aide locale sur les champs"
			TXT_VIEW_EDIT_FIELD_HELP = "Modifier l'aide sur les champs"
	End Select
End Sub

Call setTxtField()
%>
