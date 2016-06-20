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
Dim	TXT_ALL_AGENCIES, _
	TXT_AUTO_ASSIGN_LOWEST_NUM, _
	TXT_CHECK_ALL, _
	TXT_COPY_ALL_LANGUAGES, _
	TXT_COPY_CURRENT_LANGUAGE, _
	TXT_COPY_PUBS, _
	TXT_COPY_RECORD, _
	TXT_COPY_RECORD_ID, _
	TXT_COPY_TAXONOMY, _
	TXT_CREATE_EQUIVALENT_ID, _
	TXT_CREATE_RECORD, _
	TXT_DUPLICATE_ORG_NAME_ERROR, _
	TXT_DUPLICATE_ORG_NAME_PROMPT, _
	TXT_FIELDS, _
	TXT_INST_ABOUT_NEW_RECORD, _
	TXT_INST_ABOUT_NEW_RECORD_LANG, _
	TXT_LANGUAGES, _
	TXT_LOWEST_UNUSED_FOR, _
	TXT_NO_FIELDS_TO_COPY, _
	TXT_NON_PUBLIC, _
	TXT_NOT_A_VALID_LANGUAGE, _
	TXT_RECORD_WAS_NOT_CREATED, _
	TXT_REQUIRED_FIELDS_EMPTY, _
	TXT_UNCHECK_ALL

Sub setTxtEntryForm()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ALL_AGENCIES = "all Agencies"
			TXT_AUTO_ASSIGN_LOWEST_NUM = "Automatically assign the lowest available record number"
			TXT_CHECK_ALL = "Check All"
			TXT_COPY_ALL_LANGUAGES = "Copy all available languages"
			TXT_COPY_CURRENT_LANGUAGE = "Copy only English version"
			TXT_COPY_PUBS = "Copy Publications / Headings"
			TXT_COPY_RECORD = "Copy Record"
			TXT_COPY_RECORD_ID = "You are copying record # "
			TXT_COPY_TAXONOMY = "Copy Taxonomy Indexing"
			TXT_CREATE_EQUIVALENT_ID = "You are creating an alternate language equivalent for record # "
			TXT_CREATE_RECORD = "Create Record"
			TXT_DUPLICATE_ORG_NAME_ERROR = "The name you provided is already being used by another record."
			TXT_DUPLICATE_ORG_NAME_PROMPT = "The name you provided is already being used by another record. Do you want to continue?"
			TXT_FIELDS = "Fields"
			TXT_INST_ABOUT_NEW_RECORD = "The new record will be created <strong>immediately</strong> after submitting this page. " & _
				"You will be directed to the update form for this record after it has been copied."
			TXT_INST_ABOUT_NEW_RECORD_LANG = "The new record will be created <strong>immediately</strong> after submitting this page, as an exact copy of the selected record. " & _
				"This could include fields you may not have access to on your regular update form. " & _
				"The only fields that are excluded from a copy include data management fields such as when the record you are copying was modified, updated, created, deleted, collected etc. which will all be set as new for this new record. " & _
				"<span class=""Alert"">The new record you are creating will be created as a non-public record</span> - it is strongly recommended that you do not copy this record if you are not permitted to see non-public records. " & _
				"You will be directed to the update form for this record after it has been copied."
			TXT_LANGUAGES = "Languages"
			TXT_LOWEST_UNUSED_FOR = "Lowest Unused for "
			TXT_NO_FIELDS_TO_COPY = "There are no fields available to copy."
			TXT_NON_PUBLIC = "Non-Public"
			TXT_NOT_A_VALID_LANGUAGE = "You may not create a new record with the requested language" & TXT_COLON
			TXT_RECORD_WAS_NOT_CREATED = "The record was not created"
			TXT_REQUIRED_FIELDS_EMPTY = "A required field is empty."
			TXT_UNCHECK_ALL = "Uncheck All"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ALL_AGENCIES = "toutes les agences"
			TXT_AUTO_ASSIGN_LOWEST_NUM = "Assigner automatiquement le numéro de dossier disponible le plus bas"
			TXT_CHECK_ALL = "Sélectionner tout"
			TXT_COPY_ALL_LANGUAGES = "Copier toutes les langues disponibles"
			TXT_COPY_CURRENT_LANGUAGE = "Copiez la version française uniquement"
			TXT_COPY_PUBS = "Copier les publications / en-têtes"
			TXT_COPY_RECORD = "Copier le dossier"
			TXT_COPY_RECORD_ID = "Vous effectuez une copie du dossier no. "
			TXT_COPY_TAXONOMY = "Copier l'indexation avec la Taxonomie"
			TXT_CREATE_EQUIVALENT_ID = "Vous allez créer un dossier équivalent dans une autre langue pour le dossier no. "
			TXT_CREATE_RECORD = "Créer le dossier"
			TXT_DUPLICATE_ORG_NAME_ERROR = "Le nom que vous avez fourni est déjà utilisé par un autre dossier."
			TXT_DUPLICATE_ORG_NAME_PROMPT = "Le nom que vous avez fourni est déjà utilisé par un autre dossier. Voulez-vous continuer ?"
			TXT_FIELDS = "Champs"
			TXT_INST_ABOUT_NEW_RECORD = "Le nouveau dossier sera créé <strong>immédiatement</strong> après avoir soumis cette page. " & _
				"Vous serez redirigés vers le formulaire de mise à jour de ce dossier après la copie."
			TXT_INST_ABOUT_NEW_RECORD_LANG = "Le nouveau dossier sera créé <strong>immédiatement</strong> après avoir soumis cette page, et sera une copie conforme du dossier sélectionné. " & _
				"Cela peut comprendre la copie de champs dont vous n'avez pas accès sur votre formulaire de mise à jour régulier. " & _
				"Les seuls champs exclus lors d'une procédure de copie comprennent les champs de gestion des données (tels que les dates de modification, de mise à jour, de création, de suppression, d'importation, etc. du dossier en copie) qui seront réinitialisés pour le nouveau dossier. " & _
				"<span class=""Alert"">Le nouveau dossier que vous allez créer sera interne par défaut</span> - il est fortement recommandé de ne pas copier ce dossier si vous n'avez pas l'autorisation de consulter les dossiers internes. " & _
				"Vous serez redirigés vers le formulaire de mise à jour de ce dossier après la copie."
			TXT_LANGUAGES = "Langues"
			TXT_LOWEST_UNUSED_FOR = "Numéro le plus bas non utilisé pour "
			TXT_NO_FIELDS_TO_COPY = "Il n'y a pas de champs disponibles pour copier."
			TXT_NON_PUBLIC = "Interne"
			TXT_NOT_A_VALID_LANGUAGE = "Il est possible que vous ne puissiez pas créer de nouveau dossier dans la langue requise" & TXT_COLON
			TXT_RECORD_WAS_NOT_CREATED = "Le dossier n'a pas été créé"
			TXT_REQUIRED_FIELDS_EMPTY = "Un champ obligatoire est vide."
			TXT_UNCHECK_ALL = "Désélectionner tout"
	End Select
End Sub

Call setTxtEntryForm()
Call addTextFile("setTxtEntryForm")
%>
