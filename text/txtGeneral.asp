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
Dim TXT_ACTION, _
	TXT_ACTIVE, _
	TXT_ADD, _
	TXT_ADDED, _
	TXT_AND, _
	TXT_AND_LC, _
	TXT_ANY, _
	TXT_ARE_YOU_SURE_DELETE, _
	TXT_AT, _
	TXT_BILINGUAL, _
	TXT_CIC, _
	TXT_CLOSE_WINDOW, _
	TXT_CREATE_NEW, _
	TXT_CODE, _
	TXT_COLON, _
	TXT_COMMUNITIES, _
	TXT_DATABASE_ADMIN_AREA, _
	TXT_DATE_APPLIES_TO, _
	TXT_DELETE, _
	TXT_DELETED, _
	TXT_DUTIES, _
	TXT_EMAIL, _
	TXT_ENGLISH, _
	TXT_EXPIRED, _
	TXT_FIELD_HELP, _
	TXT_FIRST, _
	TXT_FRENCH, _
	TXT_HELP, _
	TXT_ID, _
	TXT_IN, _
	TXT_IN_TRAINING_MODE, _
	TXT_IN_YEARS, _
	TXT_INACTIVE, _
	TXT_INDICATES_NON_AUTHORIZED, _
	TXT_INDICATES_NON_PUBLIC, _
	TXT_JAVASCRIPT_REQUIRED, _
	TXT_LANGUAGE, _
	TXT_LAST, _
	TXT_LOADING, _
	TXT_LOCAL, _
	TXT_LOCATED_IN, _
	TXT_LOCATION_NAME, _
	TXT_MEMBER, _
	TXT_MEMBER_NAME_SEP, _
	TXT_MY_LIST, _
	TXT_NAME, _
	TXT_NEW_SEARCH, _
	TXT_NEW_WINDOW, _
	TXT_NEXT, _
	TXT_NONE_SELECTED, _
	TXT_NO, _
	TXT_NO_VALUES_AVAILABLE, _
	TXT_NOT_FOUND, _
	TXT_NOTES, _
	TXT_OF, _
	TXT_OR, _
	TXT_OR_AT, _
	TXT_OR_LC, _
	TXT_ORDER, _
	TXT_ORG_NAME, _
	TXT_ORG_NAMES_SHORT, _
	TXT_ORG_NAMES, _
	TXT_ORG_SEARCH, _
	TXT_ORGANIZATION, _
	TXT_PAGE_HELP, _
	TXT_PLEASE_ENTER_TITLE, _
	TXT_POSITION_TITLE, _
	TXT_PREVIOUS, _
	TXT_PRINT_VERSION, _
	TXT_PRINTED_ON_DATE, _
	TXT_PROFILE, _
	TXT_PUBLICATIONS, _
	TXT_RECORD_NUM, _
	TXT_RECORD_OWNER, _
	TXT_RECORDS_WERE_NOT, _
	TXT_RECORDS_WERE_SUCCESSFULLY, _
	TXT_REMOVE, _
	TXT_REQUEST_DATE, _
	TXT_RETURN_PREVIOUS_SEARCH, _
	TXT_RSN, _
	TXT_SEARCH, _
	TXT_SEARCH_TIPS, _
	TXT_SENDING_EMAIL_BLOCKED, _
	TXT_SHARED, _
	TXT_SQL_HELP, _
	TXT_STATUS, _
	TXT_THERE_ARE, _
	TXT_TO, _
	TXT_TOTAL, _
	TXT_UNKNOWN, _
	TXT_UNABLE_DETERMINE_TYPE, _
	TXT_UPDATE, _
	TXT_UPDATED, _
	TXT_USAGE, _
	TXT_USER_BANNED, _
	TXT_VIEW_LIST, _
	TXT_VOLUNTEER, _
	TXT_VOLUNTEER_OPPS, _
	TXT_VOLUNTEER_SEARCH, _
	TXT_WHATS_NEW, _
	TXT_WITH, _
	TXT_WITH_LC, _
	TXT_YES, _
	TXT_YOU_MUST_BE_SIGNED_IN

Sub setTxtGeneral()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ACTION = "Action"
			TXT_ACTIVE = "Actif"
			TXT_ADD = "Ajouter"
			TXT_ADDED = "ajouté(s)"
			TXT_AND = "ET"
			TXT_AND_LC = " et "
			TXT_ANY = "Tout"
			TXT_ARE_YOU_SURE_DELETE = "Êtes-vous sûr de vouloir supprimer définitivement ce dossier ?" & _
				"<br>Utiliser le bouton Retour pour revenir au formulaire si vous ne voulez pas le supprimer."
			TXT_AT = " au "
			TXT_BILINGUAL = "Bilingue"
			TXT_CIC = "CIC"
			TXT_CLOSE_WINDOW = "Fermer la fenêtre"
			TXT_CODE = "Code"
			TXT_COLON = " : "
			TXT_COMMUNITIES = "Communautés"
			TXT_CREATE_NEW = "&gt;&gt; CRÉER &lt;&lt;"
			TXT_DATABASE_ADMIN_AREA = "Domaine de la gestion de la base de données"
			TXT_DATE_APPLIES_TO = "TR_FR -- Date Applies To"
			TXT_DELETE = "Supprimer"
			TXT_DELETED = "supprimé(s)"
			TXT_DUTIES = "Fonctions"
			TXT_EMAIL = "Courriel"
			TXT_ENGLISH = "Anglais"
			TXT_EXPIRED = "a expiré"
			TXT_FIELD_HELP = "Aide pour les champs de renseignements"
			TXT_FIRST = "Premier"
			TXT_FRENCH = "Français"
			TXT_HELP = "Aide"
			TXT_ID = "Identificateur"
			TXT_IN = "dans"
			TXT_IN_TRAINING_MODE = "La base de données est en mode Formation."
			TXT_IN_YEARS = "en années"
			TXT_INACTIVE = "Inactif"
			TXT_INDICATES_NON_AUTHORIZED = "* signifie non-autorisé (local)"
			TXT_INDICATES_NON_PUBLIC = "* signifie interne"
			TXT_JAVASCRIPT_REQUIRED = "Cet page requiert JavaScript pour fonctionner correctement."
			TXT_LANGUAGE = "Langue"
			TXT_LAST = "Dernier"
			TXT_LOADING = "Chargement..."
			TXT_LOCAL = "Local"
			TXT_LOCATED_IN = "Situé à"
			TXT_LOCATION_NAME = "Nom de site"
			TXT_MEMBER = "Membre"
			TXT_MEMBER_NAME_SEP = "; "
			TXT_MY_LIST = "Ma liste"
			TXT_NAME = "Nom"
			TXT_NEW_SEARCH = "Nouvelle recherche"
			TXT_NEW_WINDOW = "(nouvelle fenêtre)"
			TXT_NEXT = "Suivant"
			TXT_NO = "Non"
			TXT_NONE_SELECTED = "Aucun objet sélectionné"
			TXT_NO_VALUES_AVAILABLE = "<em>Il n'y a pas de valeur disponible.</em>"
			TXT_NOT_FOUND = "Introuvable"
			TXT_NOTES = "Notes"
			TXT_OF = " de "
			TXT_OR = "OU"
			TXT_OR_AT = " ou au "
			TXT_OR_LC = " ou "
			TXT_ORDER = "Ordre"
			TXT_ORG_NAME = "nom de l'organisme / programme"
			TXT_ORG_NAMES = "Nom(s) d'organisme / programme"
			TXT_ORG_NAMES_SHORT = "Nom(s) d'org."
			TXT_ORG_SEARCH = "Recherche d'un organisme / programme"
			TXT_ORGANIZATION = "Organisme"
			TXT_PAGE_HELP = "Aide sur la page"
			TXT_PLEASE_ENTER_TITLE = "Veuillez saisir un titre pour le rapport"
			TXT_POSITION_TITLE = "Titre de poste"
			TXT_PREVIOUS = "Précédent"
			TXT_PRINT_VERSION = "Version&nbsp;imprimable&nbsp;" & TXT_NEW_WINDOW
			TXT_PRINTED_ON_DATE = "Imprimé le" & TXT_COLON
			TXT_PROFILE = "Profil"
			TXT_PUBLICATIONS = "Publications"
			TXT_RECORD_NUM = "No. de dossier"
			TXT_RECORD_OWNER = "Propriétaire du dossier"
			TXT_RECORDS_WERE_NOT = "Les dossiers n'ont pas été "
			TXT_RECORDS_WERE_SUCCESSFULLY = "Les dossiers ont bien été "
			TXT_RETURN_PREVIOUS_SEARCH = "Retourner aux résultats de la recherche précédente"
			TXT_RSN = "RSN"
			TXT_SEARCH = "Rechercher"
			TXT_SEARCH_TIPS = "Conseils de recherche"
			TXT_SENDING_EMAIL_BLOCKED = "Cette base de données a été configurée pour bloquer les courriels sortants."
			TXT_SHARED = "Partagé"
			TXT_SQL_HELP = "Aide SQL"
			TXT_STATUS = "Statut"
			TXT_THERE_ARE = "Il y a "
			TXT_TO = " à "
			TXT_TOTAL = "Total"
			TXT_UNKNOWN = "Inconnu(e)"
			TXT_UNABLE_DETERMINE_TYPE = "Il est impossible de déterminer le type de module (CIC ou Bénévolat)."
			TXT_UPDATE = "Mettre à jour"
			TXT_UPDATED = "mis à jour"
			TXT_USAGE = "Utilisation"
			TXT_USER_BANNED = "Votre accès à la base de données a été suspendu en raison d'un usage douteux. Si vous croyez qu'il s'agit d'une erreur, veuillez nous contacter."
			TXT_VIEW_LIST = "Voir la liste"
			TXT_VOLUNTEER = "Bénévolat"
			TXT_VOLUNTEER_OPPS = "Occasions de bénévolat"
			TXT_VOLUNTEER_SEARCH = "Rechercher des occasions de bénévolat"
			TXT_WITH = "Avec"
			TXT_WITH_LC = "avec"
			TXT_YES = "Oui"
			TXT_YOU_MUST_BE_SIGNED_IN = "Vous devez vous connecter à la base de données pour accéder à la page demandée."
		Case Else
			TXT_ACTION = "Action"
			TXT_ACTIVE = "Active"
			TXT_ADD = "Add"
			TXT_ADDED = "added"
			TXT_AND = "AND"
			TXT_AND_LC = " and "
			TXT_ANY = "Any"
			TXT_ARE_YOU_SURE_DELETE = "Are you sure you want to permanently delete this item?" & _
				"<br>Use your back button to return to the form if you do not want to delete."
			TXT_AT = " at "
			TXT_BILINGUAL = "Bilingual"
			TXT_CIC = "CIC"
			TXT_CLOSE_WINDOW = "Close Window"
			TXT_CODE = "Code"
			TXT_COLON = ": "
			TXT_COMMUNITIES = "Communities"
			TXT_CREATE_NEW = "&gt;&gt; CREATE NEW &lt;&lt;"
			TXT_DATABASE_ADMIN_AREA = "Database Admin Area"
			TXT_DATE_APPLIES_TO = "Date Applies To"
			TXT_DELETE = "Delete"
			TXT_DELETED = "deleted"
			TXT_DUTIES = "Duties"
			TXT_EMAIL = "Email"
			TXT_ENGLISH = "English"
			TXT_EXPIRED = "expired"
			TXT_FIELD_HELP = "Field Help"
			TXT_FIRST = "First"
			TXT_FRENCH = "French"
			TXT_HELP = "Help"
			TXT_ID = "ID"
			TXT_IN = "in"
			TXT_IN_TRAINING_MODE = "The database is in training mode"
			TXT_IN_YEARS = "in years"
			TXT_INACTIVE = "Inactive"
			TXT_INDICATES_NON_AUTHORIZED = "* indicates non-authorized (local)"
			TXT_INDICATES_NON_PUBLIC = "* indicates non-public"
			TXT_JAVASCRIPT_REQUIRED = "JavaScript is required to use this page."
			TXT_LANGUAGE = "Language"
			TXT_LAST = "Last"
			TXT_LOADING = "Loading..."
			TXT_LOCAL = "Local"
			TXT_LOCATED_IN = "Located In"
			TXT_LOCATION_NAME = "Site name"
			TXT_MEMBER = "Member"
			TXT_MEMBER_NAME_SEP = "; "
			TXT_MY_LIST = "My List"
			TXT_NAME = "Name"
			TXT_NEW_SEARCH = "New Search"
			TXT_NEW_WINDOW = "(New Window)"
			TXT_NEXT = "Next"
			TXT_NO = "No"
			TXT_NONE_SELECTED = "None Selected"
			TXT_NO_VALUES_AVAILABLE = "<em>There are no values available</em>"
			TXT_NOT_FOUND = "Not Found"
			TXT_NOTES = "Notes"
			TXT_OF = " of "
			TXT_OR = "OR"
			TXT_OR_AT = " or "
			TXT_OR_LC = " or "
			TXT_ORDER = "Order"
			TXT_ORG_NAME = "organization / program name"
			TXT_ORG_NAMES = "Organization / Program Name(s)"
			TXT_ORG_NAMES_SHORT = "Org. Name(s)"
			TXT_ORG_SEARCH = "Organization / Program Search"
			TXT_ORGANIZATION = "Organization"
			TXT_PAGE_HELP = "Page Help"
			TXT_PLEASE_ENTER_TITLE = "Please enter a Title for the report"
			TXT_POSITION_TITLE = "Position Title"
			TXT_PREVIOUS = "Previous"
			TXT_PRINT_VERSION = "Print&nbsp;Version&nbsp;" & TXT_NEW_WINDOW
			TXT_PRINTED_ON_DATE = "Printed on" & TXT_COLON
			TXT_PROFILE = "Profile"
			TXT_PUBLICATIONS = "Publications"
			TXT_RECORD_NUM = "Record #"
			TXT_RECORD_OWNER = "Record Owner"
			TXT_RECORDS_WERE_NOT = "The record(s) were not "
			TXT_RECORDS_WERE_SUCCESSFULLY = "The record(s) were successfully "
			TXT_REMOVE = "Remove"
			TXT_REQUEST_DATE = "Request Date"
			TXT_RETURN_PREVIOUS_SEARCH = "Return to Previous Search Results"
			TXT_RSN = "RSN"
			TXT_SEARCH = "Search"
			TXT_SEARCH_TIPS = "Search&nbsp;Tips"
			TXT_SENDING_EMAIL_BLOCKED = "This database has been configured to block all outgoing Email."
			TXT_SHARED = "Shared"
			TXT_SQL_HELP = "SQL&nbsp;Help"
			TXT_STATUS = "Status"
			TXT_THERE_ARE = "There are "
			TXT_TO = " to "
			TXT_TOTAL = "Total"
			TXT_UNKNOWN = "Unknown"
			TXT_UNABLE_DETERMINE_TYPE = "Unable to determine the type of module (CIC or Volunteer)"
			TXT_UPDATE = "Update"
			TXT_UPDATED = "updated"
			TXT_USAGE = "Usage"
			TXT_USER_BANNED = "You have been banned from the database because of unusual usage patterns. If you believe this to be an error, please contact us."
			TXT_VIEW_LIST = "View List"
			TXT_VOLUNTEER = "Volunteer"
			TXT_VOLUNTEER_OPPS = "Volunteer Opportunities"
			TXT_VOLUNTEER_SEARCH = "Volunteer Opportunities Search"
			TXT_WHATS_NEW = "What's New"
			TXT_WITH = "With"
			TXT_WITH_LC = "with"
			TXT_YES = "Yes"
			TXT_YOU_MUST_BE_SIGNED_IN = "You must be signed in to the database to view the page you requested."
	End Select
End Sub

Call setTxtGeneral()
Call addTextFile("setTxtGeneral")
%>
