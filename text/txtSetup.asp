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
Dim TXT_ACTIVITY_SETUP, _
	TXT_AGENCIES, _
	TXT_ACTIVITY_STATUS, _
	TXT_APIS_SHARING_EXPORT, _
	TXT_CLASSIFICATION_SYSTEMS, _
	TXT_CHECKLIST, _
	TXT_DATA_FEED_API_KEY, _
	TXT_DATABASE_SETUP, _
	TXT_DATE, _
	TXT_DESIGN_TEMPLATES, _
	TXT_DOMAIN_NAME_MAPPING, _
	TXT_DROPDOWN, _
	TXT_EXCLUSIVELY_OWNED_BY, _
	TXT_EXCLUSIVELY_OWNED_BY_MEMBER, _
	TXT_EXCEL_PROFILES, _
	TXT_EXPORT_PROFILES, _
	TXT_EXTRA_FIELD_LENGTH, _
	TXT_EXTRA_FIELD_SETUP, _
	TXT_FIELD_DISPLAY, _
	TXT_FIELD_DISPLAY_YES_NO, _
	TXT_FIELD_HIDE, _
	TXT_FIELD_SETUP, _
	TXT_GENERAL_AREAS_OF_INTEREST, _
	TXT_GENERAL_OPTIONS, _
	TXT_GENERAL_SHARED, _
	TXT_GET_INVOLVED_API, _
	TXT_GOOGLE_ANALYTICS, _
	TXT_INCLUSION_POLICIES, _
	TXT_INST_SCH_CHKLIST, _
	TXT_INST_TEMPLATE_AND_LAYOUT_SETUP , _
	TXT_MAPPING, _
	TXT_MAPPING_CATEGORIES, _
	TXT_NAICS_SETUP, _
	TXT_MEMBERSHIP, _
	TXT_OFFLINE_TOOLS, _
	TXT_OPPORTUNITIES_EMAIL_TEXT, _
	TXT_OTHER_MEMBERS, _
	TXT_PAGE_MANAGEMENT, _
	TXT_PAGE_INFORMATION, _
	TXT_PAGE_MESSAGES, _
	TXT_PAGE_TITLES, _
	TXT_PAGES, _
	TXT_PRINT_PROFILES, _
	TXT_PRIVACY_PROFILES, _
	TXT_RADIO, _
	TXT_RETURN_TO_SETUP, _
	TXT_REQUEST_CHANGE, _
	TXT_SEARCH_AGE_GROUPS, _
	TXT_SECURITY_PRIVACY, _
	TXT_SHARING_PROFILES, _
	TXT_SHORT_CODE_GENERATOR, _
	TXT_SHOW_ON_FORMS, _
	TXT_SOCIAL_MEDIA_TYPES, _
	TXT_SPECIFIC_AREAS_OF_INTEREST, _
	TXT_STANDARD_EMAIL_TEXT, _
	TXT_TEMPLATE_AND_LAYOUT_SETUP, _
	TXT_TEMPLATE_LAYOUTS, _
	TXT_TAXONOMY, _
	TXT_TEXT, _
	TXT_THESAURUS, _
	TXT_USER_TYPES, _
	TXT_USERS, _
	TXT_VACANCY_FORM_CONFIG, _
	TXT_VACANCY_HISTORY_DOWNLOAD, _
	TXT_VACANCY_SETUP, _
	TXT_VIEWS, _
	TXT_VIEWS_TEMPLATES_SEARCH, _
	TXT_WWW

Sub setTxtSetup()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ACTIVITY_SETUP = "Activity Setup"
			TXT_AGENCIES = "Agencies"
			TXT_ACTIVITY_STATUS = "Activity Statuses"
			TXT_APIS_SHARING_EXPORT = "APIs, Sharing, and Export"
			TXT_CLASSIFICATION_SYSTEMS = "Classification Systems"
			TXT_CHECKLIST = "Checklist"
			TXT_DATA_FEED_API_KEY = "Basic Data Feed API Keys"
			TXT_DATABASE_SETUP = "Database Setup"
			TXT_DATE = "Date"
			TXT_DESIGN_TEMPLATES = "Design Templates"
			TXT_DOMAIN_NAME_MAPPING = "Domain Name Mapping"
			TXT_DROPDOWN = "Drop-Down"
			TXT_EXCLUSIVELY_OWNED_BY = "Setup of this item is exclusively controlled by the Agency" & TXT_COLON
			TXT_EXCLUSIVELY_OWNED_BY_MEMBER = "Setup of this item is exclusively controlled by the Member" & TXT_COLON
			TXT_EXCEL_PROFILES = "Excel Output Profiles"
			TXT_EXPORT_PROFILES = "Export Profiles"
			TXT_EXTRA_FIELD_LENGTH = "Max. Length for &quot;Extra&quot; Text Fields"
			TXT_EXTRA_FIELD_SETUP = "&quot;Extra&quot; Field Setup"
			TXT_FIELD_DISPLAY = "Field Display"
			TXT_FIELD_DISPLAY_YES_NO = "Field Display Yes/No Values"
			TXT_FIELD_HIDE = "Hidden Fields"
			TXT_FIELD_SETUP = "Field Setup"
			TXT_GENERAL_AREAS_OF_INTEREST = "General Areas of Interest"
			TXT_GENERAL_OPTIONS = "General Setup Options"
			TXT_GENERAL_SHARED = "General / Shared"
			TXT_GET_INVOLVED_API = "Get Involved API"
			TXT_GOOGLE_ANALYTICS = "Google Analytics"
			TXT_INCLUSION_POLICIES = "Record Inclusion Policies"
			TXT_INST_SCH_CHKLIST = "Note: School configuration is shared between School Escort and Schools In Area."
			TXT_INST_TEMPLATE_AND_LAYOUT_SETUP = "Note: only a designated Super User can assign these Templates and Layouts to a View for use in the database."
			TXT_MAPPING = "Mapping"
			TXT_MAPPING_CATEGORIES = "Mapping Categories"
			TXT_MEMBERSHIP = "Membership"
			TXT_NAICS_SETUP = "NAICS"
			TXT_OFFLINE_TOOLS = "Offline Tools"
			TXT_OPPORTUNITIES_EMAIL_TEXT = "All Opportunities Email Update Text"
			TXT_OTHER_MEMBERS = "Other Members"
			TXT_PAGE_MANAGEMENT = "Page Management"
			TXT_PAGE_INFORMATION = "Page Information / Setup"
			TXT_PAGE_MESSAGES = "Page Messages"
			TXT_PAGE_TITLES = "Page Titles"
			TXT_PAGES = "Pages"
			TXT_PRINT_PROFILES = "Print Profiles"
			TXT_PRIVACY_PROFILES = "Privacy Profiles"
			TXT_RADIO = "Yes/No"
			TXT_RETURN_TO_SETUP = "Return to Setup"
			TXT_REQUEST_CHANGE = "Request Change"
			TXT_SEARCH_AGE_GROUPS = "Age Groups for Searching"
			TXT_SECURITY_PRIVACY = "Security and Privacy"
			TXT_SHARING_PROFILES = "Sharing Profiles"
			TXT_SHORT_CODE_GENERATOR = "Short Code Generator (Wordpress)"
			TXT_SHOW_ON_FORMS = "Show on Forms"
			TXT_SOCIAL_MEDIA_TYPES = "Social Media Types"
			TXT_SPECIFIC_AREAS_OF_INTEREST = "Specific Areas of Interest"
			TXT_STANDARD_EMAIL_TEXT = "Standard Email Update Text"
			TXT_TEMPLATE_AND_LAYOUT_SETUP = "Design Template and Layout Setup Options"
			TXT_TEMPLATE_LAYOUTS = "Template Layouts"
			TXT_TAXONOMY = "Taxonomy"
			TXT_TEXT = "Text"
			TXT_THESAURUS = "Thesaurus"
			TXT_USER_TYPES = "User Types"
			TXT_USERS = "Users"
			TXT_VACANCY_FORM_CONFIG = "Data Entry Form Config."
			TXT_VACANCY_HISTORY_DOWNLOAD = "Vacancy Change History (CSV)"
			TXT_VACANCY_SETUP = "Vacancy Setup"
			TXT_VIEWS = "Views"
			TXT_VIEWS_TEMPLATES_SEARCH = "Views, Templates and Search"
			TXT_WWW = "Website"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ACTIVITY_SETUP = "Configuration des activités"
			TXT_AGENCIES = "Agences"
			TXT_ACTIVITY_STATUS = "Statuts des activités"
			TXT_APIS_SHARING_EXPORT = "Les API, le partage, et l'exportation"
			TXT_CLASSIFICATION_SYSTEMS = "Systèmes de classification"
			TXT_CHECKLIST = "Liste de contrôle"
			TXT_DATA_FEED_API_KEY = "Clés API pour le flux de données de base"
			TXT_DATABASE_SETUP = "Configuration de la base de données"
			TXT_DATE = "Date"
			TXT_DESIGN_TEMPLATES = "Modèles de conception"
			TXT_DOMAIN_NAME_MAPPING = "Mise en correspondance du nom de domaine"
			TXT_DROPDOWN = "Menu déroulant"
			TXT_EXCEL_PROFILES = "Profils de sortie Excel"
			TXT_EXCLUSIVELY_OWNED_BY = "La configuration de cet élément est exclusivement contrôlé par l'agence" & TXT_COLON
			TXT_EXCLUSIVELY_OWNED_BY_MEMBER = "Configuration de cet élément est exclusivement contrôlé par le membre" & TXT_COLON
			TXT_EXPORT_PROFILES = "Profils d'export"
			TXT_EXTRA_FIELD_LENGTH = "Longueur max. des champs de texte &quot;supplémentaires&quot;"
			TXT_EXTRA_FIELD_SETUP = "Configuration du champ de texte &quot;supplémentaire&quot;"
			TXT_FIELD_DISPLAY = "Affichage des champs"
			TXT_FIELD_DISPLAY_YES_NO = "Valeurs Oui / Non d'affichage des champs"
			TXT_FIELD_SETUP = "Configuration des champs"
			TXT_FIELD_HIDE = "Champs cachés"
			TXT_GENERAL_AREAS_OF_INTEREST = "Secteurs d'intérêt général"
			TXT_GENERAL_OPTIONS = "Options générales de configuration"
			TXT_GENERAL_SHARED = "Général / Partagé"
			TXT_GET_INVOLVED_API = "API Action bénévole"
			TXT_GOOGLE_ANALYTICS = "Google Analytics"
			TXT_INCLUSION_POLICIES = "Politiques d'inclusion des dossiers"
			TXT_INST_SCH_CHKLIST = "À noter : la configuration des écoles est partagée entre l'escorte aux écoles et les écoles avoisinantes"
			TXT_INST_TEMPLATE_AND_LAYOUT_SETUP = "À noter : seul un super-utilisateur désigné peut attribuer ces modèles et mises en page à une vue pour utilisation dans la base de donnée."
			TXT_MAPPING = "Cartographie"
			TXT_MAPPING_CATEGORIES = "Catégories de cartographie"
			TXT_MEMBERSHIP = "Adhésion"
			TXT_NAICS_SETUP = "SCIAN"
			TXT_OFFLINE_TOOLS = "Outils hors-ligne"
			TXT_OPPORTUNITIES_EMAIL_TEXT = "Texte de mise à jour par courriel pour Toutes les occasions de bénévolat"
			TXT_OTHER_MEMBERS = "Autres membres"
			TXT_PAGE_MANAGEMENT = "Gestion des pages"
			TXT_PAGE_INFORMATION = "Information / Configuration des pages"
			TXT_PAGE_MESSAGES = "Messages de pages"
			TXT_PAGE_TITLES = "Titres de page"
			TXT_PAGES = "Pages"
			TXT_PRINT_PROFILES = "Profils d'impression"
			TXT_PRIVACY_PROFILES = "Profils de confidentialité"
			TXT_RADIO = "Oui/Non"
			TXT_RETURN_TO_SETUP = "Retourner à la configuration"
			TXT_REQUEST_CHANGE = "Demander des changements"
			TXT_SEARCH_AGE_GROUPS = "Classes d'âge pour la recherche"
			TXT_SECURITY_PRIVACY = "Sécurité et confidentialité"
			TXT_SHARING_PROFILES = "Profils de partage"
			TXT_SHORT_CODE_GENERATOR = "TRANSLATE_FR -- Short Code Generator (Wordpress)"
			TXT_SHOW_ON_FORMS = "Afficher sur les formulaires"
			TXT_SOCIAL_MEDIA_TYPES = "Types de média sociaux"
			TXT_SPECIFIC_AREAS_OF_INTEREST = "Centres d'intérêt spécifique"
			TXT_STANDARD_EMAIL_TEXT = "Texte normalisé du courriel pour la mise à jour"
			TXT_TEMPLATE_AND_LAYOUT_SETUP = "Options pour la conception de modèles et la disposition de la mise en page"
			TXT_TEMPLATE_LAYOUTS = "Mises en page des modèles"
			TXT_TAXONOMY = "Taxonomie"
			TXT_TEXT = "Texte"
			TXT_THESAURUS = "Thésaurus"
			TXT_USER_TYPES = "Types d'utilisateurs"
			TXT_USERS = "Utilisateurs"
			TXT_VACANCY_FORM_CONFIG = "Configuration du formulaire de saisie des données"
			TXT_VACANCY_HISTORY_DOWNLOAD = "Historique des changements dans la disponibilité (CSV)"
			TXT_VACANCY_SETUP = "Configuration des places disponibles"
			TXT_VIEWS = "Vues"
			TXT_VIEWS_TEMPLATES_SEARCH = "Vues, Modèles de conception, et Recherches"
			TXT_WWW = "Site web"
	End Select
End Sub

Call setTxtSetup()
%>

