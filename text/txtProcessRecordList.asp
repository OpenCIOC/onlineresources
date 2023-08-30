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
Dim TXT_BULK_EMAIL_REQUEST, _
	TXT_CREATE_NEW_REMINDER, _
	TXT_EMAIL_RECORD_LIST, _
	TXT_NEXT_STEP, _
	TXT_PREPARE_EMAIL, _
	TXT_PREPARE_EMAIL_RECORD_LIST, _
	TXT_PREPARE_EXPORT, _
	TXT_PREPARE_STATS_REPORT, _
	TXT_RESTORE_RECORDS, _
	TXT_SELECTED_CHANGE_OWNER, _
	TXT_SELECTED_DELETE, _
	TXT_SELECTED_EXPORT, _
	TXT_SELECTED_PUBLIC_NONPUBLIC, _
	TXT_SELECTED_SHARING_PROFILE, _
	TXT_SET_DELETION_DATE, _
	TXT_SET_NONPUBLIC, _
	TXT_SET_PUBLIC

Sub setTxtProcessRecordList()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_BULK_EMAIL_REQUEST = "Bulk Email Update Request"
			TXT_CREATE_NEW_REMINDER = "Create New Reminder"
			TXT_EMAIL_RECORD_LIST = "Email Record List"
			TXT_NEXT_STEP = "Next &gt;&gt;"
			TXT_PREPARE_EMAIL = "Use the following pages to prepare an Email update request for the selected records."
			TXT_PREPARE_EMAIL_RECORD_LIST = "Use the following page to prepare an Email of the list of selected records."
			TXT_PREPARE_EXPORT = "Use the following pages to prepare an export for the selected records."
			TXT_PREPARE_STATS_REPORT = "Please indicate your preferences for the statistical report on the selected records."
			TXT_RESTORE_RECORDS = "Restore Records"
			TXT_SELECTED_CHANGE_OWNER = "Change Ownership of the Selected Records"
			TXT_SELECTED_DELETE = "Delete or Restore Selected Records"
			TXT_SELECTED_PUBLIC_NONPUBLIC = "Mark Selected Records Public / Non-Public"
			TXT_SELECTED_SHARING_PROFILE = "Add/Remove Selected Records from Sharing Profile"
			TXT_SELECTED_EXPORT = "Selected Record Export"
			TXT_SET_DELETION_DATE = "Set Deletion Date"
			TXT_SET_NONPUBLIC = "Set Records Non-Public"
			TXT_SET_PUBLIC = "Set Records Public"
		Case CULTURE_FRENCH_CANADIAN
			TXT_BULK_EMAIL_REQUEST = "Demande de mise à jour par courriel en nombre"
			TXT_CREATE_NEW_REMINDER = "Créer un nouveau Rappel"
			TXT_EMAIL_RECORD_LIST = "Envoyer la liste des dossiers par courriel"
			TXT_NEXT_STEP = "Prochain &gt;&gt;"
			TXT_PREPARE_EMAIL = "Utiliser les pages suivantes pour préparer une demande de mise à jour par courriel pour les dossiers sélectionnés."
			TXT_PREPARE_EMAIL_RECORD_LIST = "Utilisez la page suivante pour préparer un e-mail de la liste des dossiers sélectionnés."
			TXT_PREPARE_EXPORT = "Utiliser les pages suivantes pour préparer un export des dossiers sélectionnés."
			TXT_PREPARE_STATS_REPORT = "Veuillez préciser vos préférences pour le rapport statistique sur les dossiers sélectionnés."
			TXT_RESTORE_RECORDS = "Restaurer les dossiers"
			TXT_SELECTED_CHANGE_OWNER = "Modifier la propriété des dossiers sélectionnés"
			TXT_SELECTED_DELETE = "Supprimer ou restaurer les dossiers sélectionnés"
			TXT_SELECTED_EXPORT = "Export des dossiers sélectionnés"
			TXT_SELECTED_PUBLIC_NONPUBLIC = "Marquer les dossiers sélectionnés Public / Interne"
			TXT_SELECTED_SHARING_PROFILE = "Ajouter / Supprimer les dossiers sélectionnés au profil de partage"
			TXT_SET_DELETION_DATE = "Établir la date de suppression"
			TXT_SET_NONPUBLIC = "Rendre les dossiers internes"
			TXT_SET_PUBLIC = "Rendre les dossiers publics"
	End Select
End Sub

Call setTxtProcessRecordList()
%>
