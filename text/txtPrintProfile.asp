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
Dim TXT_ADD_FIELD, _
	TXT_ADD_FIELD_FAILED, _
	TXT_APPLY_TO_RECORDS, _
	TXT_CHOOSE_FIELD, _
	TXT_CONTENT_IF_EMPTY, _
	TXT_CONTENT_STYLE, _
	TXT_CONFIRM_DELETE_FIND_AND_REPLACE, _
	TXT_DEFAULT_MSG, _
	TXT_EDIT_PROFILE, _
	TXT_FIELDS, _
	TXT_FIELD_LABEL, _
	TXT_FIELD_LABEL_STYLE, _
	TXT_FIELD_SEPARATOR, _
	TXT_FIELD_TYPE, _
	TXT_FIND_REPLACE, _
	TXT_FOOTER, _
	TXT_HEADER, _
	TXT_HEADING_LEVEL, _
	TXT_INST_APPLY_ENGLISH_OR_FRENCH, _
	TXT_INST_MSG_LOCATION, _
	TXT_INST_PAGE_BREAK, _
	TXT_INST_PAGE_TITLE, _
	TXT_INST_PUBLIC, _
	TXT_INST_RECORD_SEPARATOR, _
	TXT_INST_RUN_ORDER_NULL, _
	TXT_INST_RUN_ORDER_BETWEEN, _
	TXT_INST_STYLE_SHEET, _
	TXT_INST_TABLE_CLASS, _
	TXT_MANAGE_FIELDS_TITLE, _
	TXT_MANAGE_FIND_REPLACE, _
	TXT_MANAGE_FIND_REPLACE_TITLE, _
	TXT_MANAGE_PROFILES, _
	TXT_MATCH_ALL, _
	TXT_MSG_LOCATION, _
	TXT_OPTIONS, _
	TXT_PAGE_TITLE, _
	TXT_PUBLIC, _
	TXT_PREFIX, _
	TXT_RECORD_SEPARATOR, _
	TXT_REPLACE_COMMAND, _
	TXT_RETURN_TO_PROFILES, _
	TXT_STYLE_SHEET, _
	TXT_SUFFIX, _
	TXT_TABLE_CLASS, _
	TXT_USE_REGEX

Sub setTxtPrintProfile()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_FIELD = "Add New Field"
			TXT_ADD_FIELD_FAILED = "Add Field Failed"
			TXT_APPLY_TO_RECORDS = "Apply to Records in LANG "
			TXT_CHOOSE_FIELD = "Choose a Field from the list below or add a new Field"
			TXT_CONTENT_IF_EMPTY = "Content if Empty"
			TXT_CONTENT_STYLE = "Content CSS Class"
			TXT_CONFIRM_DELETE_FIND_AND_REPLACE = "Confirm Delete of Find & Replace Command"
			TXT_DEFAULT_MSG = "Default Message"
			TXT_EDIT_PROFILE = "Edit Print Profile"
			TXT_FIELDS = "Fields"
			TXT_FIELD_LABEL = "Label"
			TXT_FIELD_LABEL_STYLE = "Label Style"
			TXT_FIELD_TYPE = "Field Type"
			TXT_FIELD_SEPARATOR = "Separator"
			TXT_FIND_REPLACE = "Find and Replace"
			TXT_FOOTER = "Footer"
			TXT_HEADER = "Header"
			TXT_HEADING_LEVEL = "Heading Level"
			TXT_INST_APPLY_ENGLISH_OR_FRENCH = "Find and Replace command must apply to at least one of English or French"
			TXT_INST_MSG_LOCATION = "Repeat the message before each record"
			TXT_INST_PAGE_BREAK = "Start each record on a new page when printing"
			TXT_INST_PAGE_TITLE = "Title to appear in the title bar of the web browser."
			TXT_INST_PUBLIC = "Available for use on public views"
			TXT_INST_RECORD_SEPARATOR = "Optional Text/HTML to appear between records (e.g. new line, etc)"
			TXT_INST_RUN_ORDER_BETWEEN = "Run Order must be a number between 0 and "
			TXT_INST_RUN_ORDER_NULL = "Run Order cannot be NULL"
			TXT_INST_STYLE_SHEET = "Please use the full URL (e.g. https://www.example.com/style.css)."
			TXT_INST_TABLE_CLASS = "Stylesheet's CLASS name for the HTML TABLE containing any tabular record data"
			TXT_MANAGE_FIELDS_TITLE = "Manage Print Profile Fields"
			TXT_MANAGE_FIND_REPLACE = "Manage Find &amp; Replace Commands for this field"
			TXT_MANAGE_FIND_REPLACE_TITLE = "Manage Find &amp; Replace Commands"
			TXT_MANAGE_PROFILES = "Manage Print Profiles"
			TXT_MATCH_ALL = "Match All Instances"
			TXT_MSG_LOCATION = "Message Location"
			TXT_OPTIONS = "Options"
			TXT_PAGE_TITLE = "Page Title"
			TXT_PUBLIC = "Public"
			TXT_PREFIX = "Prefix"
			TXT_RECORD_SEPARATOR = "Record Separator"
			TXT_REPLACE_COMMAND = "Replace Command"
			TXT_RETURN_TO_PROFILES = "Return to Print Profiles"
			TXT_STYLE_SHEET = "Stylesheet (CSS)"
			TXT_SUFFIX = "Suffix"
			TXT_TABLE_CLASS = "Table Class (CSS)"
			TXT_USE_REGEX = "Use Regular Expressions (For Advanced Users)"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_FIELD = "Ajout d'un nouveau champ"
			TXT_ADD_FIELD_FAILED = "L'ajout du champ a échoué."
			TXT_APPLY_TO_RECORDS = "Appliquer aux dossiers en LANG"
			TXT_CHOOSE_FIELD = "Sélectionnez un champs de la liste ci-dessous ou ajouter un nouveau champ." 
			TXT_CONTENT_IF_EMPTY = "Le contenu si le champ est vide"
			TXT_CONTENT_STYLE = "Le classe du contenu (CSS)"
			TXT_CONFIRM_DELETE_FIND_AND_REPLACE = "Confirmer la suppression de la commande trouver et remplacer"
			TXT_DEFAULT_MSG = "Message par défaut"
			TXT_EDIT_PROFILE = "Éditer le profil d'impression"
			TXT_FIELDS = "Champs"
			TXT_FIELD_LABEL = "Label du champ"
			TXT_FIELD_LABEL_STYLE = "Le style du label"
			TXT_FIELD_TYPE = "Type de champ"
			TXT_FIELD_SEPARATOR = "Séparateur"
			TXT_FIND_REPLACE = "Rechercher et Remplacer"
			TXT_FOOTER = "Bas de page"
			TXT_HEADER = "En-tête"
			TXT_HEADING_LEVEL = "Niveau de titre"
			TXT_INST_APPLY_ENGLISH_OR_FRENCH = "La commande Trouver et remplacer doit se rapporter à au moins un des dossiers anglais ou français."
			TXT_INST_MSG_LOCATION = "Répéter le message avant chaque dossier"
			TXT_INST_PAGE_BREAK = "Présenter chaque dossier sur une nouvelle page, lors de l'impression"
			TXT_INST_PAGE_TITLE = "Titre apparaissant dans la barre de titre du navigateur Web."
			TXT_INST_PUBLIC = "TRANSLATE_FR -- Available for use on public views"
			TXT_INST_RECORD_SEPARATOR = "Texte/HTLM facultatif apparaissant entre les dossiers (par exemple, nouvelle ligne, etc.)"
			TXT_INST_RUN_ORDER_BETWEEN = "L'ordre d'exécution doit être un chiffre entre 0 et "
			TXT_INST_RUN_ORDER_NULL = "L'ordre d'exécution ne peut pas être nul."
			TXT_INST_STYLE_SHEET = "Prière d'utiliser l'adresse URL complète (par exemple, https://www.example.com/style.css)."
			TXT_INST_TABLE_CLASS = "Nom de CLASS, dans la feuille de style,  pour la TABLE HTLM contenant des données de dossiers sous mode tabulaire"
			TXT_MANAGE_FIELDS_TITLE = "Gestion des champs pour l'impression"
			TXT_MANAGE_FIND_REPLACE = "Gestion des commandes trouver et remplacer de ce champs."
			TXT_MANAGE_FIND_REPLACE_TITLE = "Gestion des commandes trouver et remplacer."
			TXT_MANAGE_PROFILES = "Gestion des profils de l'impression"
			TXT_MATCH_ALL = "Appareiller toutes les instances"
			TXT_MSG_LOCATION = "Endroit de message"
			TXT_OPTIONS = "Options"
			TXT_PAGE_TITLE = "Titre de page"
			TXT_PUBLIC = "Public"
			TXT_PREFIX = "Préfixe"
			TXT_RECORD_SEPARATOR = "Séparateur de dossiers"
			TXT_REPLACE_COMMAND = "Commander de remplacer"
			TXT_RETURN_TO_PROFILES = "Retourner aux profils de l'impression"
			TXT_STYLE_SHEET = "Feuille de style (CSS)"
			TXT_SUFFIX = "Suffixe"
			TXT_TABLE_CLASS = "Le classe de table (CSS)"
			TXT_USE_REGEX = "Utilisez les expressions d'ordre général (pour usagers chevronnés."
	End Select
End Sub

Call setTxtPrintProfile()

%>
