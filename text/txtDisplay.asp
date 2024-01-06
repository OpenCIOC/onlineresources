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
Dim TXT_ALERT_BOX, _
	TXT_ASCENDING, _
	TXT_CHANGE_RESULTS_DISPLAY, _
	TXT_CLEAR_SELECTIONS, _
	TXT_CUSTOM_FIELDS, _
	TXT_CUSTOM_SPECIFY, _
	TXT_DESCENDING, _
	TXT_EMAIL_UPDATE_REQUEST, _
	TXT_LIST_CLIENT_TRACKER, _
	TXT_ORDER_RESULTS_BY, _
	TXT_RELEVANCY, _
	TXT_SELECT_CHECKBOX, _
	TXT_SET_AS_DEFAULT, _
	TXT_SETTINGS_NOT_UPDATED, _
	TXT_SETTINGS_UPDATED, _
	TXT_SETTINGS_SAVED, _
	TXT_SHOW_FIELDS, _
	TXT_SHOW_OPTIONS, _
	TXT_SORT, _
	TXT_UPDATE_DISPLAY, _
	TXT_USE_TABLE_FORMAT, _
	TXT_USE_TABLE_SORT, _
	TXT_WEB_ENABLE

Sub setTxtDisplay()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ALERT_BOX = "Alert Box"
			TXT_ASCENDING = "Ascending"
			TXT_CHANGE_RESULTS_DISPLAY = "Change Results Display"
			TXT_CLEAR_SELECTIONS = "Clear Selections"
			TXT_CUSTOM_FIELDS = "Custom Fields"
			TXT_CUSTOM_SPECIFY = "Custom (Specify)"
			TXT_DESCENDING = "Descending"
			TXT_EMAIL_UPDATE_REQUEST = "Email Update Request"
			TXT_LIST_CLIENT_TRACKER = "List/Client&nbsp;Tracker"
			TXT_ORDER_RESULTS_BY = "Order Results By"
			TXT_RELEVANCY = "Relevancy"
			TXT_SELECT_CHECKBOX = "Select Checkbox"
			TXT_SET_AS_DEFAULT = "Save these settings as my default"
			TXT_SETTINGS_NOT_UPDATED = "Unable to save display settings. " & _
				"It would appear your browser does not support session information. " & _
				"This may be because your current session has expired, or because your browser rejected the session cookie. " & _
				"Make sure cookies are accepted and try again."
			TXT_SETTINGS_UPDATED = "Display settings updated. " & _
				"These changes will last for the duration of your session, " & _
				"and will apply to all future searches. " & _
				"Note that your session may not last as long as your login, so you may have to periodically update your display settings. " & _
				"You will need to refresh your current search to see the changes."
			TXT_SETTINGS_SAVED = "Display settings saved. " & _
				"These settings will now be used as your default whenever you log in to the database."
			TXT_SHOW_FIELDS = "Show Fields"
			TXT_SHOW_OPTIONS = "Show Options"
			TXT_SORT = "Sort"
			TXT_UPDATE_DISPLAY = "Update Display"
			TXT_USE_TABLE_FORMAT = "Use Table Format"
			TXT_USE_TABLE_SORT = "Show sort options on results page"
			TXT_WEB_ENABLE = "Web-enable Custom Fields"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ALERT_BOX = "Boîte d'alerte"
			TXT_ASCENDING = "Croissant"
			TXT_CHANGE_RESULTS_DISPLAY = "Modifier l'affichage des résultats"
			TXT_CLEAR_SELECTIONS = "Effacer les sélections"
			TXT_CUSTOM_FIELDS = "Champs personnalisés"
			TXT_CUSTOM_SPECIFY = "Champ personnalisé (spécifier)"
			TXT_DESCENDING = "Décroissant"
			TXT_EMAIL_UPDATE_REQUEST = "Demander la mise à jour par courriel"
			TXT_LIST_CLIENT_TRACKER = "Liste/Traceur de clients"
			TXT_ORDER_RESULTS_BY = "Trier les résultats par"
			TXT_RELEVANCY = "Pertinence"
			TXT_SELECT_CHECKBOX = "Afficher les cases à cocher"
			TXT_SET_AS_DEFAULT = "Sauvegarder les réglages comme réglages par défaut"
			TXT_SETTINGS_NOT_UPDATED = "Il n'est pas possible d'enregistrer les réglages d'affichage. " & _
				"Il semble que votre navigateur ne supporte pas les informations de session. " & _
				"Cela peut être du à l'expiration de votre session courante, ou parce que votre navigateur a rejeté le cookie de la session. " & _
				"Assurez vous que les cookies sont acceptés et essayez de nouveau."
			TXT_SETTINGS_UPDATED = "Les réglages d'affichage ont été mis à jour. " & _
				"Ces modifications seront maintenues jusqu'à la fin de la session, " & _
				"et s'appliqueront à toute nouvelle recherche. " & _
				"Prenez note que la durée autorisée de votre session peut être plus courte que votre période d'accès au site, de telle sorte que vous devrez de temps à autre effectuer une mise à jour de vos réglages d'affichage. " & _
				"Vous aurez besoin de rafraîchir la recherche en cours afin de voir les modifications."
			TXT_SETTINGS_SAVED = "Les réglages d'affichage ont sauvegardé. " & _
				"Ces réglages seront utilisés par défaut quand vous vous connecterez à la base de données."
			TXT_SHOW_FIELDS = "Afficher les champs"
			TXT_SHOW_OPTIONS = "Afficher les options"
			TXT_SORT = "Tri"
			TXT_UPDATE_DISPLAY = "Mettre à jour l'affichage"
			TXT_USE_TABLE_FORMAT = "Utiliser le format tableau"
			TXT_USE_TABLE_SORT = "Afficher les options de tri sur la page de résultats"
			TXT_WEB_ENABLE = "Adapter les champs personnalisés au Web"
	End Select
End Sub

Call setTxtDisplay()
%>
