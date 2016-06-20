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
Dim TXT_ABOUT_VOLUNTEER, _
	TXT_ADD_FOLLOW_UP_FLAG, _
	TXT_CONFIRM_DELETE_REFERRAL, _
	TXT_CONFIRM_DELETE_REFERRALS, _
	TXT_CONTACT, _
	TXT_CONTACTED_BY, _
	TXT_CREATE_REFERRAL_STATS_REPORT, _
	TXT_CUSTOM_REFERRAL_SEARCH, _
	TXT_DATE_OF_REQUEST, _
	TXT_DELETE_OLD_REFERRALS, _
	TXT_EMAIL_FOLLOW_UP, _
	TXT_ERROR_FOLLOW_UP_FLAG, _
	TXT_FIND_REFERRAL, _
	TXT_FOLLOW_UP, _
	TXT_FOLLOW_UP_EMAIL, _
	TXT_FOLLOW_UP_FLAG, _
	TXT_FOLLOW_UP_FLAG_EDIT, _
	TXT_FOLLOW_UP_FLAGS_UPDATED, _
	TXT_FOLLOW_UP_REQUIRED, _
	TXT_GRAND_TOTAL, _
	TXT_INST_DELETE_REFERRALS_1, _
	TXT_INST_DELETE_REFERRALS_2, _
	TXT_INST_DELETE_REFERRALS_3, _
	TXT_INST_DELETE_REFERRALS_4, _
	TXT_INST_DELETE_REFERRALS_5, _
	TXT_INST_DELETE_REFERRALS_6, _
	TXT_INST_DELETE_REFERRALS_7, _
	TXT_INST_SPECIFIC_OPORTUNITY, _
	TXT_INST_VOL_DETAILS, _
	TXT_MIN_REFERRALS, _
	TXT_MODIFIED_DATE, _
	TXT_NO_PROFILE_GIVEN, _
	TXT_NONE, _
	TXT_NOT_REQUIRED, _
	TXT_NUMBER_REFERRALS_TO_DELETE, _
	TXT_OPPS_WITH, _
	TXT_OR_MORE_REFERRALS, _
	TXT_ORG_LAST_CONTACT, _
	TXT_ORGANIZATION_KEYWORDS, _
	TXT_OTHER_REFERRAL_TOOLS, _
	TXT_OUTCOME_NOTES, _
	TXT_PAST_REFERRALS_FOR_POSITION, _
	TXT_PLACEMENTS, _
	TXT_POS_TITLE_KEYWORDS, _
	TXT_POS_LAST_CONTACT, _
	TXT_POSITION_CONTACT, _
	TXT_POTENTIAL_VOL_EMAIL, _
	TXT_POTENTIAL_VOL_POSTAL_CODE, _
	TXT_PROFILE_DETAILS, _
	TXT_REFERRAL_COUNT, _
	TXT_REFERRAL_DATE, _
	TXT_REFERRAL_LANGUAGE, _
	TXT_REFERRAL_STATS_REPORT, _
	TXT_REFERRAL_SEARCH_RESULTS, _
	TXT_REFERRALS_FOR_PROFILE, _
	TXT_REFERRALS_MAIN_MENU, _
	TXT_REFERRALS_MODIFIED_X_DAYS, _
	TXT_REFERRALS_REQUIRING_FOLLOWUP, _
	TXT_REMOVE_FOLLOW_UP_FLAG, _
	TXT_IS_REQUIRED, _
	TXT_RETURN_TO_STATISTICS_SEARCH, _
	TXT_SEND_TO_ORGANIZATION, _
	TXT_SEND_TO_VOLUNTEER, _
	TXT_SHOW, _
	TXT_SHOW_PLACEMENT_COUNT, _
	TXT_SUCCESSFUL_PLACEMENT, _
	TXT_THRESHOLD, _
	TXT_VIEW_PROFILE_LINK, _
	TXT_VOL_LAST_CONTACT, _
	TXT_VOL_LAST_CONTACT_DATE, _
	TXT_VOLUNTEER_CONTACT, _
	TXT_VOLUNTEER_CONTACT_MISSING, _
	TXT_VOLUNTEER_EMAIL, _
	TXT_VOLUNTEER_EMAIL_MISSING, _
	TXT_VOLUNTEER_NAME, _
	TXT_VOLUNTEER_REFERRAL_STATISTICS, _
	TXT_VOLUNTEER_REFERRAL, _
	TXT_VOLUNTEER_REFERRALS, _
	TXT_YOU_ARE_SUBMITTING_REFERRAL_REQUEST, _
	TXT_YOU_ARE_UPDATING_REFERRAL_REQUEST

Sub setTxtReferral()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ABOUT_VOLUNTEER = "À propos du bénévole potentiel"
			TXT_ADD_FOLLOW_UP_FLAG = "Ajouter un marqueur de suivi"
			TXT_CONFIRM_DELETE_REFERRAL = "Confirmer la suppression de la mise en relation"
			TXT_CONFIRM_DELETE_REFERRALS = "Confirmer la suppression des mises en relation"
			TXT_CONTACT = "Contact"
			TXT_CONTACTED_BY = "Contacté par :"
			TXT_CREATE_REFERRAL_STATS_REPORT = "Créer un rapport statistique des mises en relation"
			TXT_CUSTOM_REFERRAL_SEARCH = "Recherche avancée sur les mises en relation"
			TXT_DATE_OF_REQUEST = "Date de la demande"
			TXT_DELETE_OLD_REFERRALS = "Supprimer les mises en relation anciennes"
			TXT_EMAIL_FOLLOW_UP = "Suivi par courriel"
			TXT_ERROR_FOLLOW_UP_FLAG = "Erreur lors de la configuration des marqueurs de suivi."
			TXT_FIND_REFERRAL = "Trouver une mise en relation"
			TXT_FOLLOW_UP = "Suivi"
			TXT_FOLLOW_UP_EMAIL = "Courriel de suivi :"
			TXT_FOLLOW_UP_FLAG = "Marqueur de suivi :"
			TXT_FOLLOW_UP_FLAG_EDIT = "Modification du marqueur de suivi"
			TXT_FOLLOW_UP_FLAGS_UPDATED = "Signets de suivi mis à jour"
			TXT_FOLLOW_UP_REQUIRED = "Suivi requis"
			TXT_GRAND_TOTAL = "Total général"
			TXT_INST_DELETE_REFERRALS_1 = "Ainsi, vous souhaitez supprimer les mises en relation anciennes ?"
			TXT_INST_DELETE_REFERRALS_2 = "Purger périodiquement vos mises en relation rend le comptage des dossiers plus efficace et réduit la taille de votre téléchargement quotidien mais <span class=""""Alert"""">soyez sûr d'avoir une copie d'archive !</span>"
			TXT_INST_DELETE_REFERRALS_3 = "Vous pouvez récupérer le tableau des mises en relation dans votre téléchargement quotidien."
			TXT_INST_DELETE_REFERRALS_4 = "Attribuez un nom unique à votre base de données d'archive, et vérifiez qu'elle contient le nombre correct de dossier avant de supprimer vos mises en relation."
			TXT_INST_DELETE_REFERRALS_5 = "Conserver un copie des dossiers actuels avec les mises en relations est une bonne idée, car vous aurez un instantané exact pour cette période."
			TXT_INST_DELETE_REFERRALS_6 = "C'est particulièrement important si vous supprimez les dossiers définitivement."
			TXT_INST_DELETE_REFERRALS_7 = "Il est recommandé de conserver les mises en relation dans la base de données pendant au moins 6 mois ; toutefois, vous pouvez prévoir votre archivage à chaque fin d'année, etc."
			TXT_INST_SPECIFIC_OPORTUNITY = "Pour obtenir la liste des mises en relations pour une occasion spécifique, ou pour créer une nouvelle mise en relation, consulter la page d'information de l'occasion."
			TXT_INST_VOL_DETAILS = "Veuillez préciser le <strong>nom</strong> et la <strong>ville</strong> du bénévole potentiel, ainsi qu'une manière de le contacter : <strong>courriel</strong>, <strong>téléphone</strong> ou <strong>adresse postale</strong>."
			TXT_MIN_REFERRALS = "TR_FR -- Minimum Referrals"
			TXT_MODIFIED_DATE = "Date de modification"
			TXT_NO_PROFILE_GIVEN = "Aucun courriel de profil de bénévole n'a été fourni."
			TXT_NONE = "Aucun"
			TXT_NOT_REQUIRED = "Non requis"
			TXT_NUMBER_REFERRALS_TO_DELETE = "Nombre d'occasions à supprimer"
			TXT_OPPS_WITH = "Occasions avec"
			TXT_OR_MORE_REFERRALS = "mise(s) en relation ou plus"
			TXT_ORG_LAST_CONTACT = "La personne contact pour ce poste a été contactée pour la dernière fois au sujet de cette mise en relation :"
			TXT_ORGANIZATION_KEYWORDS = "Mots-clés d'organisme"
			TXT_OTHER_REFERRAL_TOOLS = "Autres outils sur les mises en relation"
			TXT_OUTCOME_NOTES = "Notes sur le résultat"
			TXT_PAST_REFERRALS_FOR_POSITION = "Mises en relation passées pour ce poste :"
			TXT_PLACEMENTS = "Placements"
			TXT_POS_TITLE_KEYWORDS = "Mots-clés du titre du poste"
			TXT_POS_LAST_CONTACT = "Date du dernier contact avec la personne contact pour le poste"
			TXT_POSITION_CONTACT = "Contact du poste"
			TXT_POTENTIAL_VOL_EMAIL = "Courriel du bénévole potentiel"
			TXT_POTENTIAL_VOL_POSTAL_CODE = "Code postal du bénévole potentiel"
			TXT_PROFILE_DETAILS = "Détails du profil"
			TXT_REFERRAL_COUNT = "Nombre de mises en relation"
			TXT_REFERRAL_DATE = "Date de mise en relation"
			TXT_REFERRAL_LANGUAGE = "Langue de mise en relation"
			TXT_REFERRAL_STATS_REPORT = "Rapport statistique des mises en relation"
			TXT_REFERRAL_SEARCH_RESULTS = "Résultats de recherche sur le mises en relation"
			TXT_REFERRALS_FOR_PROFILE = "Mises en relation pour le profil"
			TXT_REFERRALS_MAIN_MENU = "Menu principal des mises en relation"
			TXT_REFERRALS_MODIFIED_X_DAYS = "Mises en relation modifiées dans les [DAYS] derniers jours"
			TXT_REFERRALS_REQUIRING_FOLLOWUP = "Mises en relation nécessitant un suivi"
			TXT_REMOVE_FOLLOW_UP_FLAG = "Supprimer le marqueur de suivi"
			TXT_IS_REQUIRED = "Requis"
			TXT_RETURN_TO_STATISTICS_SEARCH = "Revenir à la recherche sur les rapports statistiques"
			TXT_SEND_TO_ORGANIZATION = "Envoyer à l'organisme"
			TXT_SEND_TO_VOLUNTEER = "Envoyer au bénévole"
			TXT_SHOW = "Afficher :"
			TXT_SHOW_PLACEMENT_COUNT = "Afficher le nombre de placements"
			TXT_SUCCESSFUL_PLACEMENT = "Placement réussi"
			TXT_THRESHOLD = "Limite"
			TXT_VIEW_PROFILE_LINK = "Voir le lien du profil"
			TXT_VOL_LAST_CONTACT = "Le bénévole potentiel a été contacté à propos de ce poste pour la dernière fois :"
			TXT_VOL_LAST_CONTACT_DATE = "Dernière date de contact du bénévole potentiel"
			TXT_VOLUNTEER_CONTACT = "Contact du bénévole"
			TXT_VOLUNTEER_CONTACT_MISSING = "Vous devez fournir un téléphone, un courriel ou une adresse pour le bénévole potentiel"
			TXT_VOLUNTEER_EMAIL = "Courriel du bénévole"
			TXT_VOLUNTEER_EMAIL_MISSING = "Vous devez fournir le nom du bénévole potentiel"
			TXT_VOLUNTEER_NAME = "Nom du bénévole"
			TXT_VOLUNTEER_REFERRAL_STATISTICS = "Statistiques sur les mises en relation du bénévole"
			TXT_VOLUNTEER_REFERRAL = "Mise en relation du bénévole"
			TXT_VOLUNTEER_REFERRALS = "Mises en relation du bénévole"
			TXT_YOU_ARE_SUBMITTING_REFERRAL_REQUEST = "Vous soumettez une demande de mise en relation pour ce poste :"
			TXT_YOU_ARE_UPDATING_REFERRAL_REQUEST = "Vous mettez à jour une demande de mise en relation pour ce poste :"
		Case Else
			TXT_ABOUT_VOLUNTEER = "About the Potential Volunteer"
			TXT_ADD_FOLLOW_UP_FLAG = "Add Follow-Up Flag"
			TXT_CONFIRM_DELETE_REFERRAL = "Confirm Delete Referral"
			TXT_CONFIRM_DELETE_REFERRALS = "Confirm Delete Referrals"
			TXT_CONTACT = "Contact"
			TXT_CONTACTED_BY = "Contacted by:"
			TXT_CREATE_REFERRAL_STATS_REPORT = "Create Referral Statistics Report"
			TXT_CUSTOM_REFERRAL_SEARCH = "Custom Referral Search"
			TXT_DATE_OF_REQUEST = "Date of Request"
			TXT_DELETE_OLD_REFERRALS = "Delete Old Referrals"
			TXT_EMAIL_FOLLOW_UP = "Email Follow-Up"
			TXT_ERROR_FOLLOW_UP_FLAG = "TRANSLATE_FR -- Error setting follow up flags."
			TXT_FIND_REFERRAL = "Find a Referral"
			TXT_FOLLOW_UP = "Follow-Up"
			TXT_FOLLOW_UP_EMAIL = "Follow Up Email:"
			TXT_FOLLOW_UP_FLAG = "Follow Up Flag:"
			TXT_FOLLOW_UP_FLAG_EDIT = "Follow-Up Flag Editing"
			TXT_FOLLOW_UP_FLAGS_UPDATED = "Follow Up Flags Updated"
			TXT_FOLLOW_UP_REQUIRED = "Follow-up Required"
			TXT_GRAND_TOTAL = "Grand Total"
			TXT_INST_DELETE_REFERRALS_1 = "So...you want to delete old Referrals?"
			TXT_INST_DELETE_REFERRALS_2 = "Periodically clearing out your Referrals makes the record counts more meaningful, and reduces the size of your daily download...but <span class=""Alert"">ensure that you have an archived copy first!</span>"
			TXT_INST_DELETE_REFERRALS_3 = "You can grab the Referrals table out of your daily download."
			TXT_INST_DELETE_REFERRALS_4 = "Give your archive database a unique file name, and confirm that it has the correct records before you delete your Referrals."
			TXT_INST_DELETE_REFERRALS_5 = "It's a good idea to keep a copy of the actual records along with the Referrals, so you that you have an accurate snapshot of that period of time."
			TXT_INST_DELETE_REFERRALS_6 = "This is especially important if you permanently delete records."
			TXT_INST_DELETE_REFERRALS_7 = "It is recommended to leave at least 6 months of Referrals in your database, however you may want to time your archiving to your year end etc."
			TXT_INST_SPECIFIC_OPORTUNITY = "To get a list of Referrals for a specific Opportunity, or to create a new Referral, go to the details page of the Opportunity."
			TXT_INST_VOL_DETAILS = "Please fill in the potential Volunteer's <strong>Name</strong>, their <strong>Town/City</strong> and one way of contacting them: <strong>Email</strong>, <strong>Phone</strong> or <strong>Address</strong>."
			TXT_MIN_REFERRALS = "Minimum Referrals"
			TXT_MODIFIED_DATE = "Modified Date"
			TXT_NO_PROFILE_GIVEN = "Aucun courriel de profil de bénévole n'a été fourni."
			TXT_NONE = "None"
			TXT_NOT_REQUIRED = "Not Required"
			TXT_NUMBER_REFERRALS_TO_DELETE = "# Referrals to Delete"
			TXT_OPPS_WITH = "Opportunities with"
			TXT_OR_MORE_REFERRALS = "or more Referrals"
			TXT_ORG_LAST_CONTACT = "The Contact Person for this position was last contacted about this Referral:"
			TXT_ORGANIZATION_KEYWORDS = "Organization Keywords"
			TXT_OTHER_REFERRAL_TOOLS = "Other Referral Tools"
			TXT_OUTCOME_NOTES = "Outcome Notes"
			TXT_PAST_REFERRALS_FOR_POSITION = "Past Referrals for the Position:"
			TXT_PLACEMENTS = "Placements"
			TXT_POS_TITLE_KEYWORDS = "Position Title Keywords"
			TXT_POS_LAST_CONTACT = "Position Contact Person's Last Contact Date"
			TXT_POSITION_CONTACT = "Position Contact"
			TXT_POTENTIAL_VOL_EMAIL = "Potential Volunteer's Email"
			TXT_POTENTIAL_VOL_POSTAL_CODE = "Potential Volunteer's Postal Code"
			TXT_PROFILE_DETAILS = "Profile Details"
			TXT_REFERRAL_COUNT = "Referral Count"
			TXT_REFERRAL_DATE = "Referral Date"
			TXT_REFERRAL_LANGUAGE = "Referral Language"
			TXT_REFERRAL_STATS_REPORT = "Referral Statistics Report"
			TXT_REFERRAL_SEARCH_RESULTS = "Referral Search Results"
			TXT_REFERRALS_FOR_PROFILE = "Referrals for Profile"
			TXT_REFERRALS_MAIN_MENU = "Referrals Main Menu"
			TXT_REFERRALS_MODIFIED_X_DAYS = "Referrals Modified in the Past [DAYS] Days"
			TXT_REFERRALS_REQUIRING_FOLLOWUP = "Referrals Requiring Follow-up"
			TXT_REMOVE_FOLLOW_UP_FLAG = "Remove Follow-Up Flag"
			TXT_IS_REQUIRED = "Required"
			TXT_RETURN_TO_STATISTICS_SEARCH = "Return to Statistics Report Search"
			TXT_SEND_TO_ORGANIZATION = "Send to Organization"
			TXT_SEND_TO_VOLUNTEER = "Send to Volunteer"
			TXT_SHOW = "Show:"
			TXT_SHOW_PLACEMENT_COUNT = "Show Placement Count"
			TXT_SUCCESSFUL_PLACEMENT = "Successful Placement"
			TXT_THRESHOLD = "Threshold"
			TXT_VIEW_PROFILE_LINK = "View Profile Link"
			TXT_VOL_LAST_CONTACT = "The Potential Volunteer was last contacted about this position:"
			TXT_VOL_LAST_CONTACT_DATE = "Potential Volunteer's Last Contact Date"
			TXT_VOLUNTEER_CONTACT = "Volunteer Contact"
			TXT_VOLUNTEER_CONTACT_MISSING = "You must provide a phone, Email, or addressfor the Potential Volunteer"
			TXT_VOLUNTEER_EMAIL = "Volunteer Email"
			TXT_VOLUNTEER_EMAIL_MISSING = "You must provide the name of the Potential Volunteer"
			TXT_VOLUNTEER_NAME = "Volunteer Name"
			TXT_VOLUNTEER_REFERRAL_STATISTICS = "Volunteer Referral Statistics"
			TXT_VOLUNTEER_REFERRAL = "Volunteer Referral"
			TXT_VOLUNTEER_REFERRALS = "Volunteer Referrals"
			TXT_YOU_ARE_SUBMITTING_REFERRAL_REQUEST = "You are submitting a Referral request for the position:"
			TXT_YOU_ARE_UPDATING_REFERRAL_REQUEST = "You are updating a Referral request for the position:"
	End Select
End Sub

Call setTxtReferral()
%>
