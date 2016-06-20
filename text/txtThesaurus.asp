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
Dim TXT_ACTIVE_STATUS, _
	TXT_ALL, _
	TXT_AND_NOT, _
	TXT_CHOOSE_SUBJECT, _
	TXT_CHOOSE_SOURCE, _
	TXT_CONFIRM_DELETE_SOURCE, _
	TXT_CREATE_NEW_SUBJECT, _
	TXT_CREATE_NEW_SUBJECT_TITLE, _
	TXT_EDIT_TERM, _
	TXT_IN_USE_BY_1_AT_LEAST, _
	TXT_IN_USE_BY_1_NO_MORE, _
	TXT_IN_USE_BY_2, _
	TXT_INCLUDE_OTHER_MEMBERS_LOCAL_TERMS, _
	TXT_INST_INACTIVE, _
	TXT_INST_TERM_COUNT, _
	TXT_INST_TERM_COUNT_GLOBAL, _
	TXT_MANAGE_THESAURUS, _
	TXT_MANAGE_SOURCES, _
	TXT_MANAGE_SOURCES_TITLE, _
	TXT_MANAGE_SUBJECTS, _
	TXT_MAX_RECORDS, _
	TXT_MIN_RECORDS, _
	TXT_NEW_TERM, _
	TXT_OR_NOT, _
	TXT_KEYWORDS, _
	TXT_RECORD_USE, _
	TXT_RESULTS_OPTIONS, _
	TXT_RETURN_MANAGE_THESAURUS, _
	TXT_RETURN_SEARCH, _
	TXT_SEARCH_FOR_SUBJECTS, _
	TXT_SHOW_FULL_SUBJECT_INFO, _
	TXT_SORT_BY, _
	TXT_TERM_USAGE, _
	TXT_TO_EDIT_EXISTING_TERM, _
	TXT_UNKNOWN_NO_VALUE, _
	TXT_UNUSED_TERM, _
	TXT_UPDATE_SOURCE_FAILED, _
	TXT_USE_FORM_FOR, _
	TXT_USED_FOR_ANOTHER, _
	TXT_USED_TERM

Sub setTxtThesaurus()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ACTIVE_STATUS = "Active Status"
			TXT_ALL = "All"
			TXT_AND_NOT = "AND NOT"
			TXT_CHOOSE_SUBJECT = "Search for a subject using the form below or add a new Subject."
			TXT_CHOOSE_SOURCE = "Choose a Source from the list below or add a new Source."
			TXT_CONFIRM_DELETE_SOURCE = "Confirm Thesaurus Source Deletion"
			TXT_CREATE_NEW_SUBJECT = "Create new Subject Term"
			TXT_CREATE_NEW_SUBJECT_TITLE = "Create New Subject Term"
			TXT_EDIT_TERM = "Edit Subject Term" & TXT_COLON
			TXT_IN_USE_BY_1_AT_LEAST = "In use by at least"
			TXT_IN_USE_BY_1_NO_MORE = "In use by no more than"
			TXT_IN_USE_BY_2 = "records."
			TXT_INCLUDE_OTHER_MEMBERS_LOCAL_TERMS = "Include Local Terms managed by other CIOC Members in this database"
			TXT_INST_INACTIVE = "Block this record from use in records, the subject finder, etc. Inactive terms continue to be visible in all areas of Thesaurus Management." & _
				"<br><span class=""Alert"">Warning: When setting a term to be inactive, you should remove all references to and from this term (including Broader, Narrower, Related, and Used For term references)</span>."
			TXT_INST_TERM_COUNT = "Term Counts only include records owned by <em>your</em> CIOC Membership."
			TXT_INST_TERM_COUNT_GLOBAL = "Term Counts include both records owned by your CIOC Membership (#) and, if applicable, records owned by other CIOC Members in your database [<em>+#</em>]."
			TXT_KEYWORDS = "Keywords"
			TXT_MANAGE_SOURCES = "Manage Thesaurus Source Values"
			TXT_MANAGE_SOURCES_TITLE = "Manage Thesaurus Source Values"
			TXT_MANAGE_SUBJECTS = "Manage Thesaurus Subjects"
			TXT_MAX_RECORDS = "Maximum Number of Records"
			TXT_MIN_RECORDS = "Minimum Number of Records"
			TXT_MANAGE_THESAURUS = "Manage Thesaurus"
			TXT_NEW_TERM = "New Term"
			TXT_OR_NOT = "OR NOT"
			TXT_RECORD_USE = "Record Use"
			TXT_RESULTS_OPTIONS = "Results Options"
			TXT_RETURN_MANAGE_THESAURUS = "Return to Manage Thesaurus"
			TXT_RETURN_SEARCH = "Return to Search Results"
			TXT_SEARCH_FOR_SUBJECTS = "Search for Subject Terms"
			TXT_SHOW_FULL_SUBJECT_INFO = "Display Full Subject Information"
			TXT_SORT_BY = "Sort By"
			TXT_TERM_USAGE = "Term Usage"
			TXT_TO_EDIT_EXISTING_TERM = "To view or edit an existing Term, search for the Term using the form below."
			TXT_UNKNOWN_NO_VALUE = "&gt;&gt; UNKNOWN / NO VALUE &lt;&lt;"
			TXT_UNUSED_TERM = "Unused Term"
			TXT_UPDATE_SOURCE_FAILED = "Update Thesaurus Source Failed"
			TXT_USE_FORM_FOR = "Use this form to create/edit Subject Term information for "
			TXT_USED_FOR_ANOTHER = "Used For Another Term"
			TXT_USED_TERM = "Used Term"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ACTIVE_STATUS = "Statut actif"
			TXT_ALL = "tous les mots-clés"
			TXT_AND_NOT = "et pas"
			TXT_CHOOSE_SUBJECT = "Chercher un sujet en utilisant le formulaire ci-dessous ou ajouter un nouveau sujet."
			TXT_CHOOSE_SOURCE = "S&eacutelectionner une source dans la liste ci-dessou ou ajouter une nouvelle source."
			TXT_CONFIRM_DELETE_SOURCE = "Confirmer la supression de la source de thésaurus."
			TXT_CREATE_NEW_SUBJECT = "Créer un nouveau mot-clé du sujet"
			TXT_CREATE_NEW_SUBJECT_TITLE = "Créer un nouveau mot-clé du sujet"
			TXT_EDIT_TERM = "Modifier le mot-clé du sujet" & TXT_COLON
			TXT_IN_USE_BY_1_AT_LEAST = "Utilisé par au moins "
			TXT_IN_USE_BY_1_NO_MORE = "Utilisé par au maximum "
			TXT_IN_USE_BY_2 = "dossiers."
			TXT_INCLUDE_OTHER_MEMBERS_LOCAL_TERMS = "Comprend des termes locaux gérés par d'autres membres CIOC dans la base de données"
			TXT_INST_INACTIVE = "Empêcher ce dossier d'être utilisé dans d'autres dossiers, la recherche par sujet, etc. Les termes inactifs sont encore visibles dans les autres rubriques de Gestion du thésaurus." & _
				"<br><span class=""Alert"">Avertissement : lors de l'attribution du statut Inactif à un terme, il est conseillé de retirer toutes références depuis et vers ce terme (Terme générique, Terme(s) spécifique(s), Voir aussi et Utilisé pour)</span>."
			TXT_INST_TERM_COUNT = "Le nombre de termes comprend seulement les dossiers appartenant à <em>votre</em> membriété CIOC."
			TXT_INST_TERM_COUNT_GLOBAL = "Le nombre de termes comprend à la fois les dossiers appartenant à votre membriété CIOC (#) et, s'il y a lieu, les dossiers appartenant à d'autres membres CIOC dans votre base de données [<em>+#</em>]."
			TXT_KEYWORDS = "Mots-clés"
			TXT_MANAGE_SOURCES = "Gestion des sources du thésaurus"
			TXT_MANAGE_SOURCES_TITLE = "Gestion des sources du thésaurus"
			TXT_MANAGE_SUBJECTS = "Gestion des mots-clés du sujet"
			TXT_MAX_RECORDS = "TR_FR -- Maximum Number of Records"
			TXT_MIN_RECORDS = "TR_FR -- Minimum Number of Records"
			TXT_MANAGE_THESAURUS = "Gestion du Thésaurus"
			TXT_NEW_TERM = "un nouveau mot-clé"
			TXT_OR_NOT = "ou pas"
			TXT_RECORD_USE = "Utilisation du dossier"
			TXT_RESULTS_OPTIONS = "Les options de résultats"
			TXT_RETURN_MANAGE_THESAURUS = "Retourne à la Gestion du Thésaurus"
			TXT_RETURN_SEARCH = "Retour aux résultats"
			TXT_SEARCH_FOR_SUBJECTS = "Rechercher des sujets"
			TXT_SHOW_FULL_SUBJECT_INFO = "Afficher toute l'information sur le sujet"
			TXT_SORT_BY = "Trier par"
			TXT_TERM_USAGE = "L'usage de terme"
			TXT_TO_EDIT_EXISTING_TERM = "Pour voir ou modifier un terme existant, chercher le terme en utilisant le formulaire ci-dessous."
			TXT_UNKNOWN_NO_VALUE = "&gt;&gt; INCONNU / SANS VALEUR &lt;&lt;"
			TXT_UNUSED_TERM = "Terme inutilisé"
			TXT_UPDATE_SOURCE_FAILED = "La mise à jour de la source du Thésaurus a échoué"
			TXT_USE_FORM_FOR = "Utiliser ce formulaire pour créer ou modifier des renseignements sur le mot-clé du sujet pour "
			TXT_USED_FOR_ANOTHER = "Utilisé par un autre terme"
			TXT_USED_TERM = "Mot-clé employé"
	End Select
End Sub

Call setTxtThesaurus()
%>
