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
Dim	TXT_ABOUT_AGENCY, _
	TXT_CLICK_TO_VIEW, _
	TXT_CONCERNS, _
	TXT_COPY_RECORD, _
	TXT_CREATE_EQUIVALENT, _
	TXT_CREATE_NEW_OPP, _
	TXT_CREATE_REFERRAL, _
	TXT_DATA_MANAGEMENT, _
	TXT_DATE_DELETED, _
	TXT_DELETE_RECORD, _
	TXT_EMAIL_UPDATE_REQUEST, _
	TXT_EMAIL_UPDATE_ALL_VOL_OPP, _
	TXT_FLAG_CHECK_FEEDBACK, _
	TXT_FLAG_DELETED, _
	TXT_FLAG_EXPIRED, _
	TXT_FLAG_NON_PUBLIC, _
	TXT_FLAG_REMINDERS, _
	TXT_FLAG_TO_BE_DELETED, _
	TXT_LAST_EMAIL, _
	TXT_LIST_REFERRALS, _
	TXT_MORE_AGENCY_INFO, _
	TXT_NA, _
	TXT_OPPORTUNITY_DETAILS, _
	TXT_OTHER_OPPORTUNITIES, _
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
	TXT_SHARE, _
	TXT_SUGGEST_NEW_OPPORTUNITY, _
	TXT_VIEWING , _
	TXT_YES_VOLUNTEER, _
	TXT_YOUR_SEARCH

Sub setTxtDetails()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ABOUT_AGENCY = "Coordonnées de l'agence :"
			TXT_CLICK_TO_VIEW = "Cliquer pour visualiser."
			TXT_CONCERNS = "Si vous avez des questions ou des préoccupations sur le statut de ce dossier, communiquez avec le propriétaire du dossier"
			TXT_COPY_RECORD = "Copier le dossier"
			TXT_CREATE_EQUIVALENT = "Créer le dossier équivalent"
			TXT_CREATE_NEW_OPP = "Créer une nouvelle occasion"
			TXT_CREATE_REFERRAL = "Créer une mise en relation"
			TXT_DATA_MANAGEMENT = "Gestion de données"
			TXT_DATE_DELETED = "Date de suppression"
			TXT_DELETE_RECORD = "Supprimer le dossier"
			TXT_EMAIL_UPDATE_REQUEST = "Demander la mise à jour par courriel"
			TXT_EMAIL_UPDATE_ALL_VOL_OPP = "Demander la mise à jour des dossiers"
			TXT_FLAG_CHECK_FEEDBACK = "VÉRIFIER LA RÉTROACTION"
			TXT_FLAG_DELETED = "SUPPRIMÉ"
			TXT_FLAG_EXPIRED = "EXPIRÉ"
			TXT_FLAG_NON_PUBLIC = "INTERNE"
			TXT_FLAG_REMINDERS = "RAPPELS"
			TXT_FLAG_TO_BE_DELETED = "POUR SUPPRESSION"
			TXT_LAST_EMAIL = "Dernier courriel"
			TXT_LIST_REFERRALS = "Les mises en relation"
			TXT_NA = "S/O"
			TXT_MORE_AGENCY_INFO = "Informations sur l'agence"
			TXT_OPPORTUNITY_DETAILS = "Détails de l'opportunité : "
			TXT_OTHER_OPPORTUNITIES = "Autres occasions"
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
			TXT_SUGGEST_NEW_OPPORTUNITY = "Proposer une nouvelle occasion"
			TXT_VIEWING = "affichage"
			TXT_YES_VOLUNTEER = "J'aimerais être bénévole !"
			TXT_YOUR_SEARCH = "Votre recherche"
		Case Else
			TXT_ABOUT_AGENCY = "Agency Details: "
			TXT_CLICK_TO_VIEW = "Click to view."
			TXT_CONCERNS = "If you have questions or concerns about the status of this record, contact the record owner"
			TXT_COPY_RECORD = "Copy Record"
			TXT_CREATE_EQUIVALENT = "Create Equivalent"
			TXT_CREATE_NEW_OPP = "Create New Opportunity"
			TXT_CREATE_REFERRAL = "Create Referral"
			TXT_DATA_MANAGEMENT = "Data Management"
			TXT_DATE_DELETED = "Date Deleted"
			TXT_DELETE_RECORD = "Delete Record"
			TXT_EMAIL_UPDATE_REQUEST = "Email Update Request"
			TXT_EMAIL_UPDATE_ALL_VOL_OPP = "Request Update of Opportunities"
			TXT_FLAG_CHECK_FEEDBACK = "CHECK FEEDBACK"
			TXT_FLAG_DELETED = "DELETED"
			TXT_FLAG_EXPIRED = "EXPIRED"
			TXT_FLAG_NON_PUBLIC = "NON-PUBLIC"
			TXT_FLAG_REMINDERS = "REMINDERS"
			TXT_FLAG_TO_BE_DELETED = "TO BE DELETED"
			TXT_LAST_EMAIL = "Last Email"
			TXT_LIST_REFERRALS = "List Referrals"
			TXT_MORE_AGENCY_INFO = "More Agency Info"
			TXT_NA = "N/A"
			TXT_OPPORTUNITY_DETAILS = "Opportunity Details: "
			TXT_OTHER_OPPORTUNITIES = "Other Opportunities"
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
			TXT_SUGGEST_NEW_OPPORTUNITY = "Suggest New Opportunity"
			TXT_VIEWING = "viewing"
			TXT_YES_VOLUNTEER = "Yes, I'd like to Volunteer!"
			TXT_YOUR_SEARCH = "Your Search"
	End Select
End Sub

Call setTxtDetails()
%>
