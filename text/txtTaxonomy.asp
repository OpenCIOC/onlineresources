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
' Purpose: 		Taxonomy management translations
'
'
%>
<%
Dim TXT_ACTIVATION_TOOL, _
	TXT_ACTIVATION_RECOMENDATIONS, _
	TXT_ACTIVATION_TOOLKIT, _
	TXT_ALTERNATE_DEFINITION, _
	TXT_ALTERNATE_NAME, _
	TXT_ARE_YOU_SURE_DELETE_CONCEPT, _
	TXT_AUTHORIZED, _
	TXT_BRACKETS_ONLY_IN, _
	TXT_CHOOSE_CONCEPT, _
	TXT_CHOOSE_FACET, _
	TXT_CHOOSE_SOURCE, _
	TXT_CHOOSE_TERM, _
	TXT_COMMENTS, _
	TXT_CONCEPT_NAME, _
	TXT_CONFIRM_DELETE_CONCEPT, _
	TXT_CONFIRM_DELETE_FACET, _
	TXT_CONFIRM_DELETE_SOURCE, _
	TXT_CONFIRM_DELETE_TERM, _
	TXT_CREATE_NEW_CONCEPT, _
	TXT_CREATE_NEW_CONCEPT_TITLE, _
	TXT_CREATE_NEW_TERM, _
	TXT_CREATE_NEW_TERM_TITLE, _
	TXT_CURRENT_ACTIVATION, _
	TXT_DEFINITION, _
	TXT_EDIT_CONCEPT, _
	TXT_EDIT_TERM, _
	TXT_ENTER_VALUES_NAME_CODE, _
	TXT_FACET, _
	TXT_HEADINGS, _
	TXT_ICON_URL, _
	TXT_INST_ACTIVE, _
	TXT_INVALID_CONCEPTS, _
	TXT_INVALID_TAXONOMY_CODE, _
	TXT_INVALID_TERMS, _
	TXT_INVALID_USE_REFERENCES, _
	TXT_LOCAL_WARNING, _
	TXT_MANAGE_FACETS, _
	TXT_MANAGE_GLOBAL_ACTIVATION, _
	TXT_MANAGE_PREFERRED_TERM_LIST, _
	TXT_MANAGE_RELATED_CONCEPTS, _
	TXT_MANAGE_SOURCES, _
	TXT_MANAGE_SOURCES_TITLE, _
	TXT_MANAGE_TERMS, _
	TXT_MULTILEVEL_REPORT, _
	TXT_NEW_CONCEPT, _
	TXT_NEW_TERM, _
	TXT_NOT_VALID_CONCEPT_CODE, _
	TXT_PREFERRED_TERM, _
	TXT_PREFERRED_TERM_COMPLIANCE_REPORT, _
	TXT_RECOMMENDED_REPLACEMENTS, _
	TXT_RETURN_MANAGE_TAXONOMY, _
	TXT_ROLL_UP, _
	TXT_SEARCH_FOR_TERM, _
	TXT_SEE_ALSO, _
	TXT_STATUS_DELETE, _
	TXT_STATUS_NO_DELETE, _
	TXT_STATUS_NO_USE_RECORDS, _
	TXT_STATUS_NO_USE_TERMS, _
	TXT_STATUS_USE_RECORDS_LOCALSHARED, _
	TXT_STATUS_USE_RECORDS_TOTAL, _
	TXT_STATUS_USE_TERMS, _
	TXT_SYNCHRONIZE_RELEASE, _
	TXT_TERM_NAME, _
	TXT_TERM_PARTIALLY_UPDATED, _
	TXT_TAX_SOURCE, _
	TXT_TAXONOMY_NOT_UPTODATE, _
	TXT_TAXONOMY_UPDATE_FINISHED_AT, _
	TXT_TAXONOMY_UPDATE_INCOMPLETE, _
	TXT_TAXONOMY_UPDATE_STARTED_AT, _
	TXT_TAXONOMY_UPTODATE, _
	TXT_TO_EDIT_EXISTING_TERM, _
	TXT_UNABLE_TO_RETRIEVE_TAXONOMY_INFO, _
	TXT_UPDATE_FACET_FAILED, _
	TXT_UPDATE_CONCEPT_FAILED, _
	TXT_UPDATE_SOURCE_FAILED, _
	TXT_UPDATE_TAXONOMY, _
	TXT_UPDATE_TERM_FAILED, _
	TXT_USE_FORM_FOR_CONCEPT, _
	TXT_USE_FORM_FOR_TERM, _
	TXT_VIEW_EDIT_CONCEPT, _
	TXT_WARNING_INCOMPLETE

Sub setTxtTaxonomy()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ACTIVATION_TOOL = "Drill-Down Activation Tool"
			TXT_ACTIVATION_TOOLKIT = "Activation Toolkit"
			TXT_ACTIVATION_RECOMENDATIONS = "Activation Recommendation Report"
			TXT_ALTERNATE_DEFINITION = "Alternate Definition"
			TXT_ALTERNATE_NAME = "Alternate Name"
			TXT_ARE_YOU_SURE_DELETE_CONCEPT = "Are you sure you want to permanently delete this Concept?" & _
				"<br>Deleting a Related Concept permanently removes all references to the Concept." & _
				"<br>Use your back button to return to the form if you do not want to delete."
			TXT_AUTHORIZED = "Authorized"
			TXT_BRACKETS_ONLY_IN = "Items in brackets are only available in "
			TXT_CHOOSE_CONCEPT = "Choose a Related Concept from the list below or add a new Concept."
			TXT_CHOOSE_FACET = "Choose a  Facet from the list below or add a new Facet."
			TXT_CHOOSE_SOURCE = "Choose a Source from the list below or add a new Source."
			TXT_CHOOSE_TERM = "Search for an existing Term or add a new Term."
			TXT_CONCEPT_NAME = "Concept Name"
			TXT_CREATE_NEW_CONCEPT = "Create New Related Concept"
			TXT_CREATE_NEW_CONCEPT_TITLE = "Create New Related Concept"
			TXT_CREATE_NEW_TERM = "Create New Taxonomy Term"
			TXT_CREATE_NEW_TERM_TITLE = "Create New Taxonomy Term"
			TXT_COMMENTS = "Comments"
			TXT_CONFIRM_DELETE_CONCEPT = "Confirm Related Concept Deletion"
			TXT_CONFIRM_DELETE_FACET = "Confirm Taxonomy Facet Deletion"
			TXT_CONFIRM_DELETE_SOURCE = "Confirm Taxonomy Source Deletion"
			TXT_CONFIRM_DELETE_TERM = "Confirm Taxonomy Term Deletion"
			TXT_CURRENT_ACTIVATION = "Taxonomy Activation and Usage Report"
			TXT_DEFINITION = "Definition"
			TXT_EDIT_TERM = "Edit Taxonomy Term" & TXT_COLON
			TXT_EDIT_CONCEPT = "Edit Related Concept" & TXT_COLON
			TXT_ENTER_VALUES_NAME_CODE = "Enter new values by English or French name, or by Code.<br>Separate multiple entries with a semi-colon (;)"
			TXT_FACET = "Facet"
			TXT_HEADINGS = "Headings"
			TXT_ICON_URL = "Icon URL"
			TXT_INST_ACTIVE = "Only Active Terms are available for use when indexing records." & _
				"<br>Inactive Terms cannot be added to records and are not displayed in searches, except where required to display the Taxonomy hierarchy." & _
				"<br>A <em>Rolled-up Term</em> is an Inactive Term that will be treated as a new Use Reference for the parent Term."
			TXT_INVALID_CONCEPTS = "The following Concepts are invalid" & TXT_COLON
			TXT_INVALID_TAXONOMY_CODE = "Taxonomy Code is invalid"
			TXT_INVALID_TERMS = "The following Terms are invalid" & TXT_COLON
			TXT_INVALID_USE_REFERENCES = "The following Use References could not be added/updated" & TXT_COLON
			TXT_LOCAL_WARNING = "You are <em>strongly</em> encougaged to avoid the use of Local Terms." & _
				"<br>Visit the <a href=""http://www.211taxonomy.org/resources/faqs"" target=""_BLANK"">FAQ on 211Taxonomy.org</a> " & _
				"for more information if you believe you require a new Term to meet your needs."
			TXT_MANAGE_FACETS = "Manage Taxonomy Facet Values"
			TXT_MANAGE_GLOBAL_ACTIVATION = "Manage Global Activation (applies to all CIOC Members in this database)"
			TXT_MANAGE_PREFERRED_TERM_LIST = "Manage Preferred Taxonomy Term List"
			TXT_MANAGE_RELATED_CONCEPTS = "Manage Related Concept Values"
			TXT_MANAGE_SOURCES = "Manage Taxonomy Source Values"
			TXT_MANAGE_SOURCES_TITLE = "Manage Taxonomy Source Values"
			TXT_MANAGE_TERMS = "Manage Taxonomy Terms"
			TXT_MULTILEVEL_REPORT  = "Multi-Level Activation Report"
			TXT_NEW_CONCEPT = "New Concept"
			TXT_NEW_TERM = "New Term"
			TXT_NOT_VALID_CONCEPT_CODE = " is not a valid Related Concept Code (e.g. AA, AA-1234)"
			TXT_PREFERRED_TERM  = "Preferred Term"
			TXT_PREFERRED_TERM_COMPLIANCE_REPORT = "Preferred Term Compliance Report"
			TXT_RECOMMENDED_REPLACEMENTS = "Recommended Replacement Terms"
			TXT_RETURN_MANAGE_TAXONOMY = "Return to Manage Taxonomy"
			TXT_ROLL_UP = "Roll up to higher level Term"
			TXT_SEARCH_FOR_TERM = "Search for Taxonomy Terms"
			TXT_SEE_ALSO = "See Also References"
			TXT_STATUS_DELETE = "Because this Term is not being used, you can make it inactive, or delete it using the button at the bottom of the form."
			TXT_STATUS_NO_DELETE = "Because this Term is being used, you cannot currently delete it or make it inactive."
			TXT_STATUS_NO_USE_RECORDS = "This Term <strong>is not</strong> used by any records."
			TXT_STATUS_NO_USE_TERMS = "This Concept <strong>is not</strong> associated with any Terms."
			TXT_STATUS_USE_RECORDS_LOCALSHARED = "This Term is being used by <strong>%d1</strong> local record(s) and <strong>%d2</strong> record(s) shared with you by other members."
			TXT_STATUS_USE_RECORDS_TOTAL = "This Term is being used by <strong>%d</strong> records in total in this database."
			TXT_STATUS_USE_TERMS = " Terms are associated with this Concept."
			TXT_SYNCHRONIZE_RELEASE = "The following Release of the Taxonomy is available for you to synchronize with" & TXT_COLON
			TXT_TERM_NAME = "Term Name"
			TXT_TERM_PARTIALLY_UPDATED = "The Taxonomy Term was only <span class=""Alert"">partially updated</span>"
			TXT_TAX_SOURCE = "Source"
			TXT_TAXONOMY_NOT_UPTODATE = "It appears that your Taxonomy is <em>not</em> up-to-date, based on a check of your list of Terms and Related Concepts. " & _
				"You can run the updater below to ensure full compatibility with the above-listed Taxonomy version."
			TXT_TAXONOMY_UPDATE_FINISHED_AT = "Taxonomy update finished at" & TXT_COLON
			TXT_TAXONOMY_UPDATE_INCOMPLETE = "Note: Your Taxonomy update is incomplete. " & _
				"The following Term(s) need to be deleted, but there are records associated with the Term(s) and there is no single replacement Term available. " & _
				"Please update the records using these Term(s) and perform the Taxonomy update again to complete the process."
			TXT_TAXONOMY_UPDATE_STARTED_AT = "Taxonomy updated started at" & TXT_COLON
			TXT_TAXONOMY_UPTODATE = "It appears that your Taxonomy is <em>probably</em> already up-to-date, based on a check of your list of Terms and Related Concepts. " & _
				"You can still choose to run the updater to ensure full compatibility with the above-listed Taxonomy version."
			TXT_TO_EDIT_EXISTING_TERM = "To edit an existing term, search for the term while working in <em>Admin Mode</em> and click the edit icon next to the Term."
			TXT_UNABLE_TO_RETRIEVE_TAXONOMY_INFO = "Taxonomy information cannot be retrieved. You will not be able to run the Taxonomy updater at this time."
			TXT_UPDATE_FACET_FAILED = "Update Taxonomy Facet Failed"
			TXT_UPDATE_CONCEPT_FAILED = "Update Related Concept Failed"
			TXT_UPDATE_SOURCE_FAILED = "Update Taxonomy Source Failed"
			TXT_UPDATE_TERM_FAILED = "Update Taxonomy Term Failed"
			TXT_UPDATE_TAXONOMY = "Update Taxonomy Version"
			TXT_USE_FORM_FOR_CONCEPT = "Use this form to create/edit Related Concept information for "
			TXT_USE_FORM_FOR_TERM = "Use this form to create/edit Taxonomy Term information for "
			TXT_VIEW_EDIT_CONCEPT = "View / Edit Concept"
			TXT_WARNING_INCOMPLETE = "Warning: If this page has fully stopped loading and you do not see a note indicating that this process has finished (" & TXT_TAXONOMY_UPDATE_FINISHED_AT & " ____ ), then you may need to reload this page to complete the process."
		Case CULTURE_FRENCH_CANADIAN
			TXT_ACTIVATION_TOOL = "Outil d'activation hiérarchique"
			TXT_ACTIVATION_TOOLKIT = "Outils d'activation"
			TXT_ACTIVATION_RECOMENDATIONS = "Rapport de recommandation d'activation"
			TXT_ALTERNATE_DEFINITION = "Définition alternative"
			TXT_ALTERNATE_NAME = "Nom alternatif"
			TXT_ARE_YOU_SURE_DELETE_CONCEPT = "Êtes-vous sûr de vouloir supprimer ce concept définitivement ?" & _
				"<br>En supprimant un concept associé définitivement, les références à ce concept seront retirées." & _
				"<br>Utiliser le bouton Retour pour revenir au formulaire si vous ne voulez pas le supprimer."
			TXT_AUTHORIZED = "Autorisé"
			TXT_BRACKETS_ONLY_IN = "Les articles entre crochets ne sont disponibles que dans "
			TXT_CHOOSE_CONCEPT = "Sélectionner un concept associé dans la liste ci-dessous ou ajouter un nouveau concept."
			TXT_CHOOSE_FACET = "Sélectionner une facette dans la liste ci-dessous ou ajouter une nouvelle facette."
			TXT_CHOOSE_SOURCE = "Sélectionner une source dans la liste ci-dessous ou ajouter une nouvelle source."
			TXT_CHOOSE_TERM = "Rechercher un terme existant ou ajouter un nouveau terme."
			TXT_COMMENTS = "Commentaires"
			TXT_CONCEPT_NAME = "Nom du concept"
			TXT_CREATE_NEW_CONCEPT = "Créer un nouveau concept associé"
			TXT_CREATE_NEW_CONCEPT_TITLE = "Créer un nouveau concept associé"
			TXT_CREATE_NEW_TERM = "Créer un nouveau terme de la taxonomie"
			TXT_CREATE_NEW_TERM_TITLE = "Création d'un nouveau terme de la taxonomie"
			TXT_CONFIRM_DELETE_CONCEPT = "Confirmer la suppression du concept associé"
			TXT_CONFIRM_DELETE_FACET = "Confirmer la suppression de la facette taxonomique"
			TXT_CONFIRM_DELETE_SOURCE = "Confirmer la suppression de la source taxonomique"
			TXT_CONFIRM_DELETE_TERM = "Confirmer la suppression du terme taxonomique"
			TXT_CURRENT_ACTIVATION = "TR_FR -- Taxonomy Activation and Usage Report"
			TXT_DEFINITION = "Définition"
			TXT_EDIT_CONCEPT = "Modifier le concept associé" & TXT_COLON
			TXT_EDIT_TERM = "Modifier le terme de la taxonomie" & TXT_COLON
			TXT_ENTER_VALUES_NAME_CODE = "Saisir de nouvelles valeurs par nom français ou anglais ou par code.<br>Séparer plusieurs entrées par un point-virgule (;)."
			TXT_FACET = "Facette"
			TXT_HEADINGS = "En-têtes"
			TXT_ICON_URL = "URL de l'icône"
			TXT_INST_ACTIVE = "Seuls les termes actifs sont disponibles pour l'indexation des dossiers." & _
				"<br>Les termes inactifs ne peuvent pas être associés à des dossiers et ne sont pas affichés lors de la recherche, sauf pour consulter la hiérarchie de la Taxonomie." & _
				"<br>Un <em>terme déroulé</em> est un terme inactif qui sera considéré comme un nouveau synonyme du terme générique."
			TXT_INVALID_CONCEPTS = "Les concepts suivants sont invalides" & TXT_COLON
			TXT_INVALID_TAXONOMY_CODE = "Le code taxonomique est invalide"
			TXT_INVALID_TERMS = "Les termes suivants sont invalides" & TXT_COLON
			TXT_INVALID_USE_REFERENCES = "Les synonymes suivants n'ont pu être ajoutés ou mis à jour" & TXT_COLON
			TXT_LOCAL_WARNING = "L'utilisation de termes locaux est <em>fortement</em> déconseillée." & _
				"<br>Consultez <a href=""http://www.211taxonomy.org/resources/faqs"" target=""_BLANK"">la FAQ sur 211Taxonomy.org</a> " & _
				"(en anglais) pour des renseignements supplémentaires, si vous estimez qu'un nouveau terme doit être créé pour répondre à vos besoins."
			TXT_MANAGE_FACETS = "Gestion des valeurs des facettes taxonomiques"
			TXT_MANAGE_GLOBAL_ACTIVATION = "Gère l'activation globale (s'applique à tous les membres CIOC dans cette base de données)"
			TXT_MANAGE_PREFERRED_TERM_LIST = "TR_FR -- Manage Preferred Taxonomy Term List"
			TXT_MANAGE_RELATED_CONCEPTS = "Gestion des valeurs des concepts associés"
			TXT_MANAGE_SOURCES = "Gestion des valeurs des sources taxonomiques"
			TXT_MANAGE_SOURCES_TITLE = "Gestion des valeurs sources taxonomique"
			TXT_MANAGE_TERMS = "Gestion des termes de la taxonomie"
			TXT_MULTILEVEL_REPORT  = "Rapport d'activation multi-niveaux"
			TXT_NEW_CONCEPT = "Nouveau concept"
			TXT_NEW_TERM = "Nouveau terme"
			TXT_NOT_VALID_CONCEPT_CODE = " n'est pas un code de concept associé valide (par ex.. AA, AA-123)"
			TXT_PREFERRED_TERM  = "Terme préféré"
			TXT_PREFERRED_TERM_COMPLIANCE_REPORT = "TR_FR -- Preferred Term Compliance Report"
			TXT_RECOMMENDED_REPLACEMENTS = "Recommandations pour les remplacements"
			TXT_RETURN_MANAGE_TAXONOMY = "Retourner à Gestion de la Taxonomie"
			TXT_ROLL_UP = "Retourner au terme du niveau supérieur"
			TXT_SEARCH_FOR_TERM = "Chercher des termes taxonomiques"
			TXT_SEE_ALSO = "Renvois (Voir aussi)"
			TXT_STATUS_DELETE = "Ce terme n'est pas utilisé : vous pouvez le rendre inactif, ou le supprimer en activant le bouton en bas du formulaire."
			TXT_STATUS_NO_DELETE = "Ce terme est actuellement utilisé : vous ne pouvez pas le supprimer, ni le rendre inactif."
			TXT_STATUS_NO_USE_RECORDS = "Ce terme <strong>n'est pas</strong> utilisé dans un dossier."
			TXT_STATUS_NO_USE_TERMS = "Ce concept <strong>n'est pas</strong> associé a un terme."
			TXT_STATUS_USE_RECORDS_LOCALSHARED = "Ce terme est utilisé par <strong>%d1</strong> de dossier(s) locale(s) et <strong>%d2</strong> dossier(s) partagé avec vous par d'autres membres."
			TXT_STATUS_USE_RECORDS_TOTAL = "Ce terme est utilisé par <strong>d%</strong> dossier(s) au total dans cette base de données."
			TXT_STATUS_USE_TERMS = " dossiers utilisent ce terme."
			TXT_STATUS_USE_TERMS = " Des termes sont associés à ce concept."
			TXT_SYNCHRONIZE_RELEASE = "La version suivante de la Taxonomie est prête à être synchronisée" & TXT_COLON
			TXT_TERM_NAME = "Nom du terme"
			TXT_TERM_PARTIALLY_UPDATED = "Le terme de la taxonomie n'a été que <span class=""Alert"">partiellement mis à jour</span>"
			TXT_TAX_SOURCE = "Source"
			TXT_TAXONOMY_NOT_UPTODATE = "Il semble que votre Taxonomie <em>n'est pas</em> à jour, d'après la vérification de votre liste de termes et de concepts associés. " & _
				"Vous pouvez lancer l'outil de mise à jour ci-dessous pour garantir la compatibilité complète avec la version de la Taxonomie disponible plus haut."
			TXT_TAXONOMY_UPDATE_FINISHED_AT = "Mise à jour de la Taxonomie terminée à" & TXT_COLON
			TXT_TAXONOMY_UPDATE_INCOMPLETE = "Remarque : la mise à jour de votre Taxonomie est incomplète. " & _
				"Les termes suivants doivent être supprimés, mais il existe des dossiers associés à ce ou ces termes et il n'existe pas de terme de remplacement disponible. " & _
				"Veuillez mettre à jour les dossiers qui utilisent ces termes et relancer la mise à jour de la Taxonomie pour terminer le processus."
			TXT_TAXONOMY_UPDATE_STARTED_AT = "Mise à jour de la Taxonomie commencée à" & TXT_COLON
			TXT_TAXONOMY_UPTODATE = "Il semble que votre Taxonomie est <em>probablement</em> à jour, d'après la vérification de votre liste de termes et de concepts associés. " & _ 
				"Vous pouvez lancer l'outil de mise à jour à tout moment pour garantir la compatibilité complète avec la version de la Taxonomie disponible plus haut."
			TXT_TO_EDIT_EXISTING_TERM = "Pour modifier un terme existant, recherchez le terme en <em>Mode de gestion</em> et cliquez l'icône de modification à côté du terme."
			TXT_UNABLE_TO_RETRIEVE_TAXONOMY_INFO = "Les renseignements sur la Taxonomie ne peuvent être retrouvés. Vous ne pourrez pas lancer l'outil de mise à jour de la Taxonomie pour le moment."
			TXT_UPDATE_FACET_FAILED = "La mise à jour de la facette taxonomique a échoué"
			TXT_UPDATE_CONCEPT_FAILED = "La mise à jour du concept associé a échoué"
			TXT_UPDATE_SOURCE_FAILED = "La mise à jour de la source taxonomique a échoué"
			TXT_UPDATE_TERM_FAILED = "La mise à jour du terme  de la taxonomie a échoué"
			TXT_UPDATE_TAXONOMY = "Mettre à jour la version de la Taxonomie"
			TXT_USE_FORM_FOR_CONCEPT = "Utiliser ce formulaire pour créer / modifier les informations du concept associé pour "
			TXT_USE_FORM_FOR_TERM = "Utiliser ce formulaire pour créer / modifier les informations du terme de la taxonomie pour "
			TXT_VIEW_EDIT_CONCEPT = "Voir / Modifier le concept"
			TXT_WARNING_INCOMPLETE = "Attention : si cette page a totalement cessé de se charger et si vous ne voyez pas de note indiquant que le processus est terminé (" & TXT_TAXONOMY_UPDATE_FINISHED_AT & " ____ ), alors vous pourriez avoir à recharger cette page pour terminer le processus."
	End Select
End Sub

Call setTxtTaxonomy()
%>
