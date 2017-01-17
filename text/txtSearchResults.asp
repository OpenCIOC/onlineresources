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
'
' Purpose: 		Search Results translations.
'				Used for the OrgRecordTable Class (display of Organization/Program records)
'				and the OpRecordTable Class (display of Volunteer Opporunities),
'				as well as Statistics search results.
'
'
%>
<%
Dim TXT_ACTION_ON_SELECTED, _
	TXT_BETWEEN, _
	TXT_CATEGORIES, _
	TXT_CHANGE_DISPLAY, _
	TXT_CHECK_ALL, _
	TXT_CHECK_IN_VIEWPORT, _
	TXT_CLICK_ON, _
	TXT_CLOSE, _
	TXT_IS_NEGATIVE, _
	TXT_IS_NOT_A_NUMBER, _
	TXT_LEGEND, _
	TXT_LIST_EMPTY, _
	TXT_LIST_REMOVE, _
	TXT_LIST_REMOVE_ALL, _
	TXT_MAP_RECORD, _
	TXT_MAP_RESULTS, _
	TXT_MORE_INFO, _
	TXT_MORE_RESULTS, _
	TXT_MULTIPLE_ORGANIZATIONS, _
	TXT_NO_MATCH, _
	TXT_NO_TERMS, _
	TXT_NO_PREVIOUS, _
	TXT_OWNER, _
	TXT_PRINT_RECORD_DETAILS, _
	TXT_RECORDS_MATCH, _
	TXT_REQUEST_UPDATE, _
	TXT_SAVE_THIS_SEARCH, _
	TXT_SEARCH_RESULTS, _
	TXT_SELECT, _
	TXT_SLCT_AGENCY, _
	TXT_SLCT_AREAS_OF_INTEREST, _
	TXT_SLCT_CHANGE_OWNER, _
	TXT_SLCT_DATA_MANAGEMENT, _
	TXT_SLCT_DATA_SHARING, _
	TXT_SLCT_DELETE_RESTORE, _
	TXT_SLCT_DISTRIBUTION, _
	TXT_SLCT_EMAIL_RECORD_LIST, _
	TXT_SLCT_EMAIL_UPDATE, _
	TXT_SLCT_EXPORT, _
	TXT_SLCT_FIND_REPLACE, _
	TXT_SLCT_GEOCODE, _
	TXT_SLCT_HEADING, _
	TXT_SLCT_NAICS, _
	TXT_SLCT_NEW_REMINDER, _
	TXT_SLCT_NEW_RESULTS, _
	TXT_SLCT_PRINT, _
	TXT_SLCT_PRINT_MAP, _
	TXT_SLCT_PUBLICATION, _
	TXT_SLCT_PUBLIC_NONPUBLIC, _
	TXT_SLCT_SHARING_PROFILE, _
	TXT_SLCT_STATS, _
	TXT_SLCT_STATS_AND_REPORTING, _
	TXT_SLCT_SUBJECT, _
	TXT_SLCT_TAXONOMY, _
	TXT_SHOW_SUBJECTS, _
	TXT_SHOWING_RECORDS, _
	TXT_TO_BOTTOM, _
	TXT_TO_SIDE, _
	TXT_UNCHECK_ALL, _
	TXT_UPDATE_FEEDBACK, _
	TXT_VIEW_FULL, _
	TXT_WARNING_AGE, _
	TXT_WARNING_COMMUNITY_1, _
	TXT_WARNING_COMMUNITY_2 ,_
	TXT_WARNING_DATE_1_FIRST, _
	TXT_WARNING_DATE_1_LAST, _
	TXT_WARNING_DATE_2, _
	TXT_WARNING_DATE_TOO_EARLY, _
	TXT_WARNING_RECORD_NUM, _
	TXT_WARNING_TAXONOMY_CODE, _
	TXT_YEARS, _
	TXT_YOU_SEARCHED_FOR, _
	TXT_YOUR_PREVIOUS_SEARCH

Sub setTxtSearchResults
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ACTION_ON_SELECTED = "Action sur les dossiers sélectionnés"
			TXT_BETWEEN = "entre"
			TXT_CATEGORIES = "Catégories"
			TXT_CHANGE_DISPLAY = "Changer&nbsp;les&nbsp;options&nbsp;d'affichage"
			TXT_CHECK_ALL = "Sélectionner tout"
			TXT_CHECK_IN_VIEWPORT = "Sélectionner les dossiers cartographiés"
			TXT_CLICK_ON = "Cliquer sur "
			TXT_CLOSE = "Fermer"
			TXT_IS_NEGATIVE = " est négatif"
			TXT_IS_NOT_A_NUMBER = " n'est pas un nombre"
			TXT_LEGEND = "Légende"
			TXT_LIST_EMPTY = "La liste est actuellement vide."
			TXT_LIST_REMOVE = "Supprimer"
			TXT_LIST_REMOVE_ALL = "Supprimer tous de la liste"
			TXT_MAP_RECORD = "Cartographier le dossier"
			TXT_MAP_RESULTS = "Cartographier les résultats"
			TXT_MORE_INFO = "Renseignements supplémentaires"
			TXT_MORE_RESULTS = "Plus de résultats :"
			TXT_MULTIPLE_ORGANIZATIONS = "Plusieurs organismes avec la même localisation sur la carte"
			TXT_NO_MATCH = "Il n'y a pas de dossier correspondant à vos critères. Veuillez modifier votre recherche en étant moins restrictif et réessayez."
			TXT_NO_TERMS = "Vous n'avez saisi aucune valeur de recherche ou alors votre recherche ne contenait que des mots inconnus." & _
				"<br>Veuillez revenir en arrière et recommencer une <a href=""" & makeLinkB("~/" & StringIf(ps_intDbArea = DM_VOL, "volunteer/")) & """>" & TXT_NEW_SEARCH & "</a>."
			TXT_NO_PREVIOUS = "Votre précédente recherche n'a pu être retrouvée. Soit vous n'avez pas autorisé les cookies, soit votre session a expiré." & _
				"<br>Veuillez revenir en arrière et recommencer une <a href=""" & makeLinkB("~/" & StringIf(ps_intDbArea = DM_VOL, "volunteer/")) & """>" & TXT_NEW_SEARCH & "</a>."
			TXT_OWNER = "Propriétaire"
			TXT_PRINT_RECORD_DETAILS = "TRANSLATE_FR -- Print Record Details"
			TXT_RECORDS_MATCH = " dossier(s) correspondant à vos critères."
			TXT_REQUEST_UPDATE = "Demander une mise à jour"
			TXT_SAVE_THIS_SEARCH = "Sauvegarder cette recherche"
			TXT_SEARCH_RESULTS = "Résultats de la recherche"
			TXT_SELECT = "TRANSLATE_FR -- Select"
			TXT_SLCT_AGENCY = "Modifier l'agence"
			TXT_SLCT_AREAS_OF_INTEREST = "Ajouter/Supprimer des centres d'intérêt"
			TXT_SLCT_CHANGE_OWNER = "Changer le propriétaire du dossier"
			TXT_SLCT_DATA_MANAGEMENT = "Gestion de données"
			TXT_SLCT_DATA_SHARING = "Partage de données"
			TXT_SLCT_DELETE_RESTORE = "Supprimer / Restaurer les dossiers"
			TXT_SLCT_DISTRIBUTION = "Ajouter / Supprimer un code de distribution"
			TXT_SLCT_EMAIL_RECORD_LIST = "TRANSLATE_FR -- Email Record List"
			TXT_SLCT_EMAIL_UPDATE = "Demander une mise à jour par courriel"
			TXT_SLCT_EXPORT = "Exporter les dossiers"
			TXT_SLCT_FIND_REPLACE = "Outil rechercher et remplacer"
			TXT_SLCT_GEOCODE = "Mettre à jour le géocodage"
			TXT_SLCT_HEADING = "Ajouter / Supprimer un en-tête"
			TXT_SLCT_NAICS = "Ajouter / Supprimer un code SCIAN"
			TXT_SLCT_NEW_REMINDER = "Nouveau Rappel"
			TXT_SLCT_NEW_RESULTS = "Nouvel ensemble de résultats"
			TXT_SLCT_PRINT = "Imprimer la liste"
			TXT_SLCT_PRINT_MAP = "Imprimer la carte (99 max.)"
			TXT_SLCT_PUBLIC_NONPUBLIC = "Rendre les dossiers publics / internes"
			TXT_SLCT_SHARING_PROFILE = "Ajouter / Supprimer au profil de partage"
			TXT_SLCT_PUBLICATION = "Ajouter / Supprimer un code de publication"
			TXT_SLCT_STATS = "Générer un rapport statistique"
			TXT_SLCT_STATS_AND_REPORTING = "Statistiques et rapports"
			TXT_SLCT_SUBJECT = "Ajouter / Supprimer un mot-clé du sujet"
			TXT_SLCT_TAXONOMY = "Ajouter / Supprimer un terme de la Taxonomie"
			TXT_SHOW_SUBJECTS = "Afficher la barre latérale des sujets"
			TXT_SHOWING_RECORDS = "Affichage des dossiers "
			TXT_TO_BOTTOM = "Vers le bas"
			TXT_TO_SIDE = "Sur le côté"
			TXT_UNCHECK_ALL = "Désélectionner tout"
			TXT_UPDATE_FEEDBACK = "Mettre à jour la rétroaction"
			TXT_VIEW_FULL = " pour voir les détails complets du dossier"
			TXT_WARNING_AGE = "Certains critères d'âge ont été ignorés ; "
			TXT_WARNING_COMMUNITY_1 = "Impossible de trouver le nom de la communauté &quot;"
			TXT_WARNING_COMMUNITY_2 = "&quot; ; la recherche sur cette communauté a été ignorée. " & _
				"Pour chercher parmi les noms de communautés disponibles, utilisez le " & _
				"<a href=""javascript:openWin('" & makeLinkB(ps_strPathToStart & "comfind.asp") & "','cFind')"">Localisateur de communautés</a>."
			TXT_WARNING_DATE_1_FIRST = "Les critères à la date ou après ont été ignorés" & TXT_COLON
			TXT_WARNING_DATE_1_LAST = "Les critères à la date ou avant ont été ignorés" & TXT_COLON
			TXT_WARNING_DATE_2 = " n'est pas un format de date valide (p. ex.. " & DateString(Date(),True) & ")"
			TXT_WARNING_DATE_TOO_EARLY = " est antérieur au « 1 janvier 1900 »"
			TXT_WARNING_RECORD_NUM = "Le no. de dossier invalide a été ignoré" & TXT_COLON
			TXT_WARNING_TAXONOMY_CODE = "Le code taxonomique suivant n'est pas valide et a été ignoré " & TXT_COLON
			TXT_YEARS = "années"
			TXT_YOU_SEARCHED_FOR = "Vous avez effectué une recherche sur" & TXT_COLON
			TXT_YOUR_PREVIOUS_SEARCH = "les résultats de votre recherche précédente"
		Case Else
			TXT_ACTION_ON_SELECTED = "Action on Selected Records"
			TXT_BETWEEN = "between"
			TXT_CATEGORIES = "Categories"
			TXT_CHANGE_DISPLAY = "Change&nbsp;Display&nbsp;Options"
			TXT_CHECK_ALL = "Check All"
			TXT_CHECK_IN_VIEWPORT = "Check in Viewport"
			TXT_CLICK_ON = "Click on the "
			TXT_CLOSE = "Close"
			TXT_IS_NEGATIVE = " is negative"
			TXT_IS_NOT_A_NUMBER = " is not a number"
			TXT_LEGEND = "Legend"
			TXT_LIST_EMPTY = "List is currently empty."
			TXT_LIST_REMOVE = "Remove"
			TXT_LIST_REMOVE_ALL = "Remove All from List"
			TXT_MAP_RECORD = "Map Record"
			TXT_MAP_RESULTS = "Map Results"
			TXT_MORE_INFO = "More info"
			TXT_MORE_RESULTS = "More Results:"
			TXT_MULTIPLE_ORGANIZATIONS = "Multiple organizations with a similar map location"
			TXT_NO_MATCH = "There are no records that match your criteria. Please modify your search to be less restrictive and try again."
			TXT_NO_TERMS = "You did not enter any search values or your search contained only ignored words." & _
				"<br>Please go back or start a <a href=""" & makeLinkB("~/" & StringIf(ps_intDbArea = DM_VOL, "volunteer/")) & """>" & TXT_NEW_SEARCH & "</a>."
			TXT_NO_PREVIOUS = "We were unable to retrieve your previous search. Either you do not have cookies enabled, or your session has expired." & _
				"<br>Please go back or start a <a href=""" & makeLinkB("~/" & StringIf(ps_intDbArea = DM_VOL, "volunteer/")) & """>" & TXT_NEW_SEARCH & "</a>."
			TXT_OWNER = "Owner"
			TXT_PRINT_RECORD_DETAILS = "Print Record Details"
			TXT_RECORDS_MATCH = " record(s) that match your criteria."
			TXT_REQUEST_UPDATE = "Request Update"
			TXT_SAVE_THIS_SEARCH = "Save This Search"
			TXT_SEARCH_RESULTS = "Search Results"
			TXT_SELECT = "Select"
			TXT_SLCT_AGENCY = "Change Agency"
			TXT_SLCT_AREAS_OF_INTEREST = "Add/Remove Areas of Interest"
			TXT_SLCT_CHANGE_OWNER = "Change Record Owner"
			TXT_SLCT_DATA_MANAGEMENT = "Data Management"
			TXT_SLCT_DATA_SHARING = "Data Sharing"
			TXT_SLCT_DELETE_RESTORE = "Delete/Restore Records"
			TXT_SLCT_DISTRIBUTION = "Add/Remove Distribution Code"
			TXT_SLCT_EMAIL_RECORD_LIST = "Email Record List"
			TXT_SLCT_EMAIL_UPDATE = "Email Update Request"
			TXT_SLCT_EXPORT = "Export Records"
			TXT_SLCT_FIND_REPLACE = "Find and Replace Utility"
			TXT_SLCT_GEOCODE = "Update Geocoding"
			TXT_SLCT_HEADING = "Add/Remove Heading"
			TXT_SLCT_NAICS = "Add/Remove NAICS Code"
			TXT_SLCT_NEW_REMINDER = "New Reminder"
			TXT_SLCT_NEW_RESULTS = "New Results Set"
			TXT_SLCT_PRINT = "Print List"
			TXT_SLCT_PRINT_MAP = "Print Map (Max 99)"
			TXT_SLCT_PUBLIC_NONPUBLIC = "Set Records Public / Non-Public"
			TXT_SLCT_SHARING_PROFILE = "Add/Remove from Sharing Profile"
			TXT_SLCT_PUBLICATION = "Add/Remove Pub Code"
			TXT_SLCT_STATS = "Generate Stats Report"
			TXT_SLCT_STATS_AND_REPORTING = "Stats and Reporting"
			TXT_SLCT_SUBJECT = "Add/Remove Subject Term"
			TXT_SLCT_TAXONOMY = "Add/Remove Taxonomy Term"
			TXT_SHOW_SUBJECTS = "Show Subjects Sidebar"
			TXT_SHOWING_RECORDS = "Showing records "
			TXT_TO_BOTTOM = "To Bottom"
			TXT_TO_SIDE = "To Side"
			TXT_UNCHECK_ALL = "Uncheck All"
			TXT_UPDATE_FEEDBACK = "Update/Fb"
			TXT_VIEW_FULL = " to view the full details of the record"
			TXT_WARNING_AGE = "Some age criteria was ignored; "
			TXT_WARNING_COMMUNITY_1 = "Unable to find community name &quot;"
			TXT_WARNING_COMMUNITY_2 = "&quot;; this community search was ignored. " & _
				"To search through available community names, use the " & _
				"<a href=""javascript:openWin('" & makeLinkB(ps_strPathToStart & "comfind.asp") & "','cFind')"">Community Finder</a>."
			TXT_WARNING_DATE_1_FIRST = "On or after date criteria was ignored" & TXT_COLON
			TXT_WARNING_DATE_1_LAST = "On or before date criteria was ignored" & TXT_COLON
			TXT_WARNING_DATE_2 = " is not an acceptable date format (e.g. " & DateString(Date(),True) & ")"
			TXT_WARNING_DATE_TOO_EARLY = " is before ""1 Jan 1900"""
			TXT_WARNING_RECORD_NUM = "Invalid Record # was ignored" & TXT_COLON
			TXT_WARNING_TAXONOMY_CODE = "The following is an invalid Taxonomy Code and was ignored" & TXT_COLON
			TXT_YEARS = "years"
			TXT_YOU_SEARCHED_FOR = "You performed a search for" & TXT_COLON
			TXT_YOUR_PREVIOUS_SEARCH = "your previous search results"
	End Select
End Sub

Call setTxtSearchResults
%>
