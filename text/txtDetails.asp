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
Dim	TXT_CLICK_TO_VIEW, _
	TXT_CONCERNS, _
	TXT_COPY_RECORD, _
	TXT_CREATE_EQUIVALENT, _
	TXT_DATA_MANAGEMENT, _
	TXT_DATE_DELETED, _
	TXT_DELETE_RECORD, _
	TXT_EMAIL_UPDATE_REQUEST, _
	TXT_EMAIL_UPDATE_ALL_VOL_OPP, _
	TXT_FLAG_CHECK_FEEDBACK, _
	TXT_FLAG_DELETED, _
	TXT_FLAG_NON_PUBLIC, _
	TXT_FLAG_REMINDERS, _
	TXT_FLAG_TO_BE_DELETED, _
	TXT_LAST_EMAIL, _
	TXT_NA, _
	TXT_OTHER_RESULTS, _
	TXT_READ_LESS, _
	TXT_READ_MORE, _
	TXT_RECORD_EXISTS_BUT, _
	TXT_RECORD_USE, _
	TXT_RECORD_YOU_REQUESTED, _
	TXT_REMINDER_COUNT_MULTIPLE, _
	TXT_REMINDER_COUNT_SINGLE, _
	TXT_REMINDER_DUE_MULTIPLE, _
	TXT_REMINDER_DUE_SINGLE, _
	TXT_REMINDERS, _
	TXT_RESTORE_RECORD, _
	TXT_SHARE

Sub setTxtDetails()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_CLICK_TO_VIEW = "Cliquer pour visualiser."
			TXT_CONCERNS = "Si vous avez des questions ou des préoccupations sur le statut de ce dossier, communiquez avec le propriétaire du dossier"
			TXT_COPY_RECORD = "Copier le dossier"
			TXT_CREATE_EQUIVALENT = "Créer le dossier équivalent"
			TXT_DATA_MANAGEMENT = "Gestion de données"
			TXT_DATE_DELETED = "Date de suppression"
			TXT_DELETE_RECORD = "Supprimer le dossier"
			TXT_EMAIL_UPDATE_REQUEST = "Demander la mise à jour par courriel"
			TXT_EMAIL_UPDATE_ALL_VOL_OPP = "Mettre à jour par courriel toutes les demandes d'occasion de bénévolat"
			TXT_FLAG_CHECK_FEEDBACK = "VÉRIFIER LA&nbsp;RÉTROACTION"
			TXT_FLAG_DELETED = "SUPPRIMÉ"
			TXT_FLAG_NON_PUBLIC = "INTERNE"
			TXT_FLAG_REMINDERS = "RAPPELS"
			TXT_FLAG_TO_BE_DELETED = "POUR&nbsp;SUPPRESSION"
			TXT_LAST_EMAIL = "Dernier courriel"
			TXT_NA = "S/O"
			TXT_OTHER_RESULTS = "Autres résultats de recherche : "
			TXT_READ_LESS = "[moins]"
			TXT_READ_MORE = "[lire plus]"
			TXT_RECORD_EXISTS_BUT = " existe dans la base de données, mais l'accès y est restreint depuis cette zone. Ce dossier peut être incomplet ou en attente d'une mise à jour ; le programme ou service n'est peut être plus offert ; ou le type de service peut avoir changé, ce qui rend la présence du dossier inappropriée."
			TXT_RECORD_USE = "Consultations du dossier"
			TXT_RECORD_YOU_REQUESTED = "Le dossier que vous avez demandé "
			TXT_REMINDER_COUNT_MULTIPLE = "Il y a [COUNT] rappels. "
			TXT_REMINDER_COUNT_SINGLE = "Il y a 1 rappel. "
			TXT_REMINDER_DUE_MULTIPLE = "[COUNT] sont en retard. "
			TXT_REMINDER_DUE_SINGLE = "1 en retard."
			TXT_REMINDERS = "Rappels"
			TXT_RESTORE_RECORD = "Restaurer le dossier"
			TXT_SHARE = "Partager : "
		Case Else
			TXT_CLICK_TO_VIEW = "Click to view."
			TXT_CONCERNS = "If you have questions or concerns about the status of this record, contact the record owner"
			TXT_COPY_RECORD = "Copy Record"
			TXT_CREATE_EQUIVALENT = "Create Equivalent"
			TXT_DATA_MANAGEMENT = "Data Management"
			TXT_DATE_DELETED = "Date Deleted"
			TXT_DELETE_RECORD = "Delete Record"
			TXT_EMAIL_UPDATE_REQUEST = "Email Update Request"
			TXT_EMAIL_UPDATE_ALL_VOL_OPP = "Email Update All Volunteer Opportunities Request"
			TXT_FLAG_CHECK_FEEDBACK = "CHECK&nbsp;FEEDBACK"
			TXT_FLAG_DELETED = "DELETED"
			TXT_FLAG_NON_PUBLIC = "NON&nbsp;PUBLIC"
			TXT_FLAG_REMINDERS = "REMINDERS"
			TXT_FLAG_TO_BE_DELETED = "TO&nbsp;BE&nbsp;DELETED"
			TXT_LAST_EMAIL = "Last Email"
			TXT_NA = "N/A"
			TXT_OTHER_RESULTS = "Other Search Results: "
			TXT_READ_LESS = "[less]"
			TXT_READ_MORE = "[read more]"
			TXT_RECORD_EXISTS_BUT = " exists in the database, but access to it has been restricted from this area. This record may be incomplete or waiting to be updated, the program or service may no longer be offered, or the type of service may have changed making it no longer appropriate for the record to be listed here."
			TXT_RECORD_USE = "Record Use"
			TXT_RECORD_YOU_REQUESTED = "The record you requested "
			TXT_REMINDER_COUNT_MULTIPLE = "There are [COUNT] reminders. "
			TXT_REMINDER_COUNT_SINGLE = "There is 1 reminder. "
			TXT_REMINDER_DUE_MULTIPLE = "[COUNT] are due. "
			TXT_REMINDER_DUE_SINGLE = "1 is due."
			TXT_REMINDERS = "Reminders"
			TXT_RESTORE_RECORD = "Restore"
			TXT_SHARE = "Share: "
	End Select
End Sub

Call setTxtDetails()
%>
