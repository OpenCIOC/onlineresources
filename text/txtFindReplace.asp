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
Dim TXT_ADD_NOTE_IN, _
	TXT_ADD_ONLY_UNUSED, _
	TXT_AFTER_TEXT, _
	TXT_BEFORE_TEXT, _
	TXT_CHK_AREAS_SERVED, _
	TXT_CHECKLIST_TOOL, _
	TXT_CLEAR_FIELD_TOOL, _
	TXT_CODES_WITH_DESCRIPTIONS, _
	TXT_CONTACT_TOOL, _
	TXT_ERASE_FIELD, _
	TXT_ERASE_IN_ALL_RECORDS, _
	TXT_FIND_AND_REPLACE_TOOL, _
	TXT_FIND_REPLACE_ON_SELECTED, _
	TXT_FOR_THE_TEXT, _
	TXT_I_KNOW_WHAT_IM_DOING, _
	TXT_IGNORE_WHITESPACE, _
	TXT_IM_REALLY_SURE, _
	TXT_IM_SURE, _
	TXT_IN_BASETABLE, _
	TXT_INST_INSERT, _
	TXT_INST_MATCH_CONTACTS, _
	TXT_INST_NEW_CONTACT_INFO, _
	TXT_INST_NO_VALIDATION, _
	TXT_INST_REPLACE_DIFFERENT, _
	TXT_INST_RESTRICTIONS, _
	TXT_LOOK_IN_FIELDS, _
	TXT_LOOK_IN_CHECK_NOTES, _
	TXT_LOOK_IN_CONTACT, _
	TXT_LOOK_IN_PUB_DESCRIPTIONS, _
	TXT_MATCH_CONTACTS, _
	TXT_NAME_TOOL, _
	TXT_NEW_CONTACT_INFO, _
	TXT_NOT_ALL_FIELDS_AVAILABLE, _
	TXT_NOTE_APPEND_DATE, _
	TXT_NOTES_ADD_ONLY, _
	TXT_ONLY_IN_LANGUAGE, _
	TXT_OPTIONS, _
	TXT_PREPEND_APPEND, _
	TXT_PUT_TEXT, _
	TXT_RECORD_NOTE_TOOL, _
	TXT_SCHOOL_ESCORT, _
	TXT_SCHOOLS_IN_AREA, _
	TXT_THERE_ARE_SIX_TOOLS, _
	TXT_TOOL_1, _
	TXT_TOOL_2, _
	TXT_TOOL_3, _
	TXT_TOOL_4, _
	TXT_TOOL_5, _
	TXT_TOOL_6, _
	TXT_TOOL_7, _
	TXT_URL, _
	TXT_USE_WITH_CAUTION, _
	TXT_WHOLE_FIELD

Sub setTxtFindReplace()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_NOTE_IN = "New Note in"
			TXT_ADD_ONLY_UNUSED = "You may only replace with / add a value that is not already being used in the record."
			TXT_AFTER_TEXT = "After the existing text"
			TXT_BEFORE_TEXT = "Before the existing text"
			TXT_CHK_AREAS_SERVED = "Areas Served"
			TXT_CHECKLIST_TOOL = "Checklist Tool"
			TXT_CLEAR_FIELD_TOOL = "Clear Field Tool"
			TXT_CODES_WITH_DESCRIPTIONS = "The following are the codes with descriptions in the selected records"
			TXT_CONTACT_TOOL = "Contact Tool"
			TXT_ERASE_FIELD = "Erase field"
			TXT_ERASE_IN_ALL_RECORDS = "Erase the field in all selected records"
			TXT_FIND_AND_REPLACE_TOOL = "Find and Replace Tool"
			TXT_FIND_REPLACE_ON_SELECTED = "Find and Replace on selected records"
			TXT_FOR_THE_TEXT = "For the text"
			TXT_I_KNOW_WHAT_IM_DOING = "I know what I'm doing. Go ahead and delete it!"
			TXT_IGNORE_WHITESPACE = "Ignore Whitespace Differences"
			TXT_IM_REALLY_SURE = "I'm really sure"
			TXT_IM_SURE = "I'm sure"
			TXT_IN_BASETABLE = "In the field"
			TXT_INST_INSERT = "Remember to include a space character before or after your text if you need one!" & _
				"<br>Once the new text is added, the field will be trimmed to remove any excess space."
			TXT_INST_MATCH_CONTACTS = "Optional - enter in details to match contacts with specific values in the specified field(s)." & _
				"<br>If you do not select any criteria to match, then all of the chosen contact types will have their details replaced with the newly provided data."
			TXT_INST_NEW_CONTACT_INFO = "Required - enter in the <span class=""Alert"">full and complete new value</span> for any of the fields you want to replace." & _
				"<br>All existing values in the specified field(s) will be replaced with what you provide." & _
				"<br>Erase a field by entering an asterisk (<b>*</b>)." & _
				"<br>If you do not enter a value in a specified field, the existing contents will be left as-is."
			TXT_INST_NO_VALIDATION = "Field validation will not be performed during these operations; it is your responsibility to make sure the values you use conform to the fields in question."
			TXT_INST_REPLACE_DIFFERENT = "The values for Find and Replace must be different."
			TXT_INST_RESTRICTIONS = "Note that there are restrictions on the fields available for find and replace."
			TXT_LOOK_IN_FIELDS = "Look in field(s)"
			TXT_LOOK_IN_CHECK_NOTES = "Look in<br>Checklist Notes"
			TXT_LOOK_IN_CONTACT = "Look in Contact Field"
			TXT_LOOK_IN_PUB_DESCRIPTIONS = "Look in<br>Publication Description(s)"
			TXT_MATCH_CONTACTS = "Match Contacts with..."
			TXT_NAME_TOOL = "Name Tool"
			TXT_NEW_CONTACT_INFO = "New Contact Info"
			TXT_NOT_ALL_FIELDS_AVAILABLE = "Not all fields are available in this tool. This tool only works with fields that have one value per record, and does not include data management fields such as modified, created, or updated information. Some values - like Contact, Checklist or Drop-Down fields - have their own Find and Replace tools. Some data types may not be available. You must know the underlying names of the fields to use this tool; friendly names are not available."
			TXT_NOTE_APPEND_DATE = "Note: If you are working with a date field, the existing value will be replaced with the value you provide."
			TXT_NOTES_ADD_ONLY = "Only available when inserting a new checklist item that supports notes."
			TXT_ONLY_IN_LANGUAGE = "You are currently performing find and replace on <strong>English</strong> records. To do a find and replace on <strong>French</strong> records, you must be using the database in French mode. Some changes to shared information may affect all languages."
			TXT_OPTIONS = "Options"
			TXT_PREPEND_APPEND = "Prepend / Append Tool"
			TXT_PUT_TEXT = "Put the new text"
			TXT_RECORD_NOTE_TOOL = "Record Note Tool"
			TXT_SCHOOL_ESCORT = "School Escort"
			TXT_SCHOOLS_IN_AREA = "Schools in Area"
			TXT_THERE_ARE_SIX_TOOLS = "There are six tools available to make mass changes to fields" & TXT_COLON
			TXT_TOOL_1 = "The <strong>Find and Replace Tool</strong> is used to replace text with a given string or remove a string of text across one or more fields"
			TXT_TOOL_2 = "The <strong>Prepend / Append Tool</strong> is used to add a string to the beginning or end of the selected field."
			TXT_TOOL_3 = "The <strong>Clear Field Tool</strong> is used to erase all contents of the selected field. <span class=""Alert"">Please be careful!</span>"
			TXT_TOOL_4 = "The <strong>Checklist Tool</strong> is used to add, remove or replace a checklist item."
			TXT_TOOL_5 = "The <strong>Name Tool</strong> is used to add, remove or alter a Former or Alternate Name."
			TXT_TOOL_6 = "The <strong>Contact Tool</strong> is used to update all or part of a contact record."
			TXT_TOOL_7 = "The <strong>Record Note Tool</strong> is used to add a new note to the selected records."
			TXT_URL = "URL"
			TXT_USE_WITH_CAUTION = "Please use this tool with extreme caution, as the results cannot be undone."
			TXT_WHOLE_FIELD = "Whole Field Only"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_NOTE_IN = "Nouvelle note dans le"
			TXT_ADD_ONLY_UNUSED = "Seule une valeur qui n'est pas déjà utilisée dans le dossier peut être ajoutée ou peut remplacer une autre valeur."
			TXT_AFTER_TEXT = "Après le texte existant"
			TXT_BEFORE_TEXT = "Avant le texte existant"
			TXT_CHK_AREAS_SERVED = "Régions desservies"
			TXT_CHECKLIST_TOOL = "Outil Liste de contrôle"
			TXT_CLEAR_FIELD_TOOL = "Outil Effacer le contenu du champ"
			TXT_CODES_WITH_DESCRIPTIONS = "Voici les codes avec des descriptions dans les dossiers sélectionnés."
			TXT_CONTACT_TOOL = "Outil Contact"
			TXT_ERASE_FIELD = "Effacer le contenu du champ"
			TXT_ERASE_IN_ALL_RECORDS = "Effacer le contenu du champ dans tous les dossiers sélectionnés"
			TXT_FIND_AND_REPLACE_TOOL = "Outil Rechercher et Remplacer"
			TXT_FIND_REPLACE_ON_SELECTED = "Rechercher et Remplacer dans les dossiers sélectionnés"
			TXT_FOR_THE_TEXT = "Pour le texte"
			TXT_I_KNOW_WHAT_IM_DOING = "Je sais ce que je fais. Continuer et supprimer !"
			TXT_IGNORE_WHITESPACE = "Ignorer les différences entre les blancs"
			TXT_IM_REALLY_SURE = "Je suis absolument certain(e)"
			TXT_IM_SURE = "Je suis certain(e)"
			TXT_IN_BASETABLE = "Dans le champ"
			TXT_INST_INSERT = "N'oubliez pas d'insérer un espace avant ou après votre texte, s'il y a lieu !" & _
				"<br>Après l'ajout du nouveau texte, le champ sera ajusté afin d'éliminer tout espace superflu."
			TXT_INST_MATCH_CONTACTS = "Optionnel - saisir les détails pour faire correspondre les contacts contenant les valeurs spécifiques dans le(s) champ(s) spécifié(s)." & _
				"<br>Si vous ne sélectionnez aucun critère de correspondance, la nouvelle donnée fournie remplacera les détails de tous les types de contact sélectionnés."
			TXT_INST_NEW_CONTACT_INFO = "Requis - saisir la <span class=""Alert"">nouvelle valeur complète</span> pour n'importe quels champs que vous souhaitez remplacer." & _
				"<br>Toutes les valeurs existantes dans le ou les champ spécifiés seront remplacées par celle que vous avez fournie." & _
				"<br>Effacer le contenu d'un champ en saisissant une astérisque (<b>*</b>)." & _
				"<br>Si vous ne saisissez pas de valeur dans un champ spécifié, les contenus existants seront laissés tels quels."
			TXT_INST_NO_VALIDATION = "Les champs ne seront pas validés au cours de ces opérations ; vous devez vous assurer que les valeurs que vous utilisez sont conformes aux champs en question."
			TXT_INST_REPLACE_DIFFERENT = "Les valeurs de Rechercher et Remplacer doivent être différentes."
			TXT_INST_RESTRICTIONS = "Notez que des restrictions s'appliquent aux champs disponibles pour la fonction Rechercher et remplacer."
			TXT_LOOK_IN_CONTACT = "Chercher dans le champ Contact"
			TXT_LOOK_IN_FIELDS = "Rechercher dans le(s) champ(s)"
			TXT_LOOK_IN_CHECK_NOTES = "Rechercher dans les notes<br>des listes de contrôle"
			TXT_LOOK_IN_PUB_DESCRIPTIONS = "Rechercher dans<br>les descriptions des publications"
			TXT_MATCH_CONTACTS = "Faire correspondre les contacts avec..."
			TXT_NAME_TOOL = "Outil Nom"
			TXT_NEW_CONTACT_INFO = "Nouvelle information contact"
			TXT_NOT_ALL_FIELDS_AVAILABLE = "Tous les champs ne sont pas disponibles dans cet outil. Cet outil ne marche qu'avec les champs qui ont une valeur par dossier, et il ne comprend pas les champs de gestion des données, comme les informations de modification, création et mise à jour. Certaines valeurs - comme les champs de Contact, à liste de contrôle ou à liste déroulante - ont leur propre outil Rechercher/Remplacer. Certains types de données peuvent ne pas être disponibles. Vous devez connaître les noms CIOC des champs pour utiliser cet outil ; les noms d'affichage ne sont pas disponibles."
			TXT_NOTES = "Notes"
			TXT_NOTE_APPEND_DATE = "Remarque : si vous travaillez sur champs de date, la valeur existante sera remplacée par la valeur que vous fournissez."
			TXT_NOTES_ADD_ONLY = "Disponible uniquement en insérant un nouvel élément dans la liste de contrôle qui prend en charge les notes."
			TXT_ONLY_IN_LANGUAGE = "Vous effectuez présentement l'action Rechercher et Remplacer sur des dossiers en <strong>français</strong>. Pour effectuer une action Rechercher et Remplacer sur des dossiers en <strong>anglais</strong>, vous devez utiliser la base de données en mode Anglais. Quelques changements à l'information qui est partagée peut affecter toutes les langues."
			TXT_OPTIONS = "Options"
			TXT_PREPEND_APPEND = "Outil Préfixe/Suffixe"
			TXT_PUT_TEXT = "Placer le nouveau texte"
			TXT_RECORD_NOTE_TOOL = "Outil de notes aux dossiers"
			TXT_SCHOOL_ESCORT = "Accompagnement à l'école"
			TXT_SCHOOLS_IN_AREA = "Écoles dans les environs"
			TXT_THERE_ARE_SIX_TOOLS = "Six outils sont disponibles pour faire des modifications d'ensemble à des champs" & TXT_COLON
			TXT_TOOL_1 = "L'<strong>Outil Rechercher et Remplacer</strong> sert à remplacer un texte par une chaîne de caractères donnée ou à effacer une chaîne de caractères dans un ou plusieurs champs."
			TXT_TOOL_2 = "L'<strong>Outil Préfixe/Suffixe</strong> sert à ajouter une chaîne de caractères au début ou à la fin du champ sélectionné."
			TXT_TOOL_3 = "L'<strong>Outil Effacer le contenu du champ</strong> sert à effacer tout le contenu d'un champ sélectionné. <span class=""Alert"">Veuillez rester prudent !</span>"
			TXT_TOOL_4 = "L'<strong>Outil Liste de contrôle</strong> sert à ajouter, retirer ou remplacer un élément dans une liste de contrôle."
			TXT_TOOL_5 = "L' <strong>Outil Nom</strong> sert à ajouter, retirer ou modifier un nom alternatif ou antérieur."
			TXT_TOOL_6 = "L'<strong>Outil Contact</strong> sert à mettre à jour l'ensemble ou une partie des informations de contact."
			TXT_TOOL_7 = "L'<strong>Outil de notes aux dossiers</strong> est utilisé pour ajouter une nouvelle note aux dossiers sélectionnés."
			TXT_URL = "URL"
			TXT_USE_WITH_CAUTION = "Veuillez utiliser cet outil avec grande prudence, car l'action ne peut être annulée."
			TXT_WHOLE_FIELD = "Le champ en entier uniquement"
	End Select
End Sub

Call setTxtFindReplace()
%>
