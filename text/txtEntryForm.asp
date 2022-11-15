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
' Ensure any new languages have their TXT_CONTENT_DELETED value added here
Const CONTENT_DELETED_PATTERN = "\[(deleted|supprimé)\]"

Dim TXT_ACTIVITY_INFO_ADD_NEW, _
	TXT_ACTIVITY_INFO_CURRENT_ACTIVITIES, _
	TXT_ACTIVITY_INFO_DESCRIPTION, _
	TXT_ACTIVITY_INFO_END_DATE, _
	TXT_ACTIVITY_INFO_NAME, _
	TXT_ACTIVITY_INFO_SCHEDULE_TYPE, _
	TXT_ACTIVITY_INFO_SERVICE_CATEGORY, _
	TXT_ACTIVITY_NUMBER, _
	TXT_ADD_BUS_ROUTES, _
	TXT_ADD_COMMUNITIES, _
	TXT_ADD_DISTRIBUTIONS, _
	TXT_ADD_INTERESTS, _
	TXT_ADD_LANGUAGES, _
	TXT_ADD_LOCATION_RECORD, _
	TXT_ADD_SERVICE_RECORD, _
	TXT_ADD_SCHOOLS, _
	TXT_ADD_SUBJECTS, _
	TXT_ADDRESS_NUMBER, _
	TXT_ADDRESS_TYPE, _
	TXT_AFTER_NAME, _
	TXT_AGENCY_WARNING, _
	TXT_ALL_AGENCIES, _
	TXT_AREAS_SERVED_DISPLAY_ONLY_NOTES, _
	TXT_AUTO_ASSIGN_LOWEST_NUM, _
	TXT_AVAILABLE, _
	TXT_BEFORE_NAME, _
	TXT_BOTH_NAMES, _
	TXT_BOX_NUMBER, _
	TXT_BOX_TYPE, _
	TXT_BUILDING, _
	TXT_CANCEL, _
	TXT_CANCELLED_ERROR, _
	TXT_CAPACITY, _
	TXT_CAS_CONFIRMATION_DATE, _
	TXT_CHECK_FEEDBACK, _
	TXT_CHECKBOX_FOR_NAME_HIDE, _
	TXT_CHECKBOX_FOR_XREF, _
	TXT_CITY, _
	TXT_CONTENT_DELETED, _
	TXT_CONTENT_DELETED_EQ, _
	TXT_CONTRACT_NUMBER, _
	TXT_COMMUNITY, _
	TXT_COMMUNITY_DATABASE, _
	TXT_COMMUNITY_SET_MANAGEMENT, _
	TXT_COUNTRY, _
	TXT_CREATE_NEW_RECORD, _
	TXT_CREATE_RECORD_FEEDBACK, _
	TXT_CURRENT_VALUE, _
	TXT_CUSTOM_COMMUNITY, _
	TXT_DATE_SIGNED, _
	TXT_DATE_OF_CHANGE, _
	TXT_DAY_OF_WEEK, _
	TXT_DELETE_FEEDBACK, _
	TXT_DENOTES_TAXONOMY_HEADING, _
	TXT_DESIGNATE_CHILD_CARE_RESOURCE, _
	TXT_DISPLAY_ORG_NAME, _
	TXT_DONT_RESTORE, _
	TXT_DUPLICATE_ORG_NAME_ERROR, _
	TXT_DUPLICATE_ORG_NAME_PROMPT, _
	TXT_EDIT_EQUIVALENT, _
	TXT_EMPLOYEES, _
	TXT_ERRORS_FOUND, _
	TXT_FEE_ASSISTANCE_INFO, _
	TXT_FEEDBACK_NUM, _
	TXT_FIND_BY_GENERAL_INTEREST, _
	TXT_FIND_BY_KEYWORD, _
	TXT_FOR, _
	TXT_FOR_BROWSE_BY_LETTER_USE, _
	TXT_FULL_TIME, _
	TXT_HIDE, _
	TXT_HIDE_CANCELLED, _
	TXT_IMPORTANT, _
	TXT_INACTIVE_DATE, _
	TXT_INDICATES_SET_CANT_BE_CHANGED, _
	TXT_INDIVIDUALS_WANTED, _
	TXT_INFANT, _
	TXT_INFO_COMMUNITIES_1, _
	TXT_INFO_COMMUNITIES_2, _
	TXT_INFO_COPY, _
	TXT_INFO_COPY_OP, _
	TXT_INFO_CREATE_OP, _
	TXT_INFO_LANGUAGES, _
	TXT_INFO_LOCATED, _
	TXT_INST_APPLICATION_QUESTION, _
	TXT_INST_COPY_OP, _
	TXT_INST_DATES_AND_TIMES, _
	TXT_INST_DISPLAY_UNTIL, _
	TXT_INST_DUTIES, _
	TXT_INST_IMPORTANT_CHECK_ALL, _
	TXT_INST_NUM_NEEDED_COMMUNITIES, _
	TXT_INST_NUM_NEEDED_NOTES, _
	TXT_INST_NUM_NEEDED_TOTAL, _
	TXT_INST_POLICE_CHECK, _
	TXT_INST_POSITION_TITLE, _
	TXT_INST_VOL_CONTACT, _
	TXT_INVALID_RECORD_NUM, _
	TXT_IS, _
	TXT_KINDERGARTEN, _
	TXT_LEGEND, _
	TXT_LEGEND_HELP, _
	TXT_LEGEND_VERSIONS, _
	TXT_LICENSE_NUMBER, _
	TXT_LICENSE_RENEWAL, _
	TXT_LINE, _
	TXT_LOCATION_WARNING, _
	TXT_LOGO_ADDRESS, _
	TXT_LOGO_LINK_ADDRESS, _
	TXT_LOGO_ALT_TEXT, _
	TXT_LOGO_HOVER_TEXT, _
	TXT_LOWEST_UNUSED_FOR, _
	TXT_MAIL_ADDRESS, _
	TXT_MAIL_CO, _
	TXT_MAIN_NAME_ONLY, _
	TXT_MAP_LINK, _
	TXT_MAPPING_CATEGORY, _
	TXT_MAX_AGE, _
	TXT_ME, _
	TXT_MIN_AGE, _
	TXT_MIN_HOURS, _
	TXT_MIN_HOURS_PER, _
	TXT_NAME_FIRST, _
	TXT_NAME_LAST, _
	TXT_NEW, _
	TXT_NEW_SUBJECTS, _
	TXT_NO_CHANGES_REQUIRED, _
	TXT_NO_LONGER_APPLICABLE, _
	TXT_NO_UPDATE_UNTIL_CREATED, _
	TXT_NOT_AVAILABLE, _
	TXT_NOT_GIVEN, _
	TXT_NOTE_NUMBER, _
	TXT_NOTE_TYPE, _
	TXT_NUM_NEEDED_TOTAL, _
	TXT_OLS_USE_WARNING, _
	TXT_ON_OR_AFTER_DATE, _
	TXT_ON_OR_BEFORE_DATE, _
	TXT_ORG_RECORD_NUM, _
	TXT_OTHER_ADDRESS_TITLE, _
	TXT_OTHER_NOTES, _
	TXT_PART_TIME, _
	TXT_PAST_CHANGES_SUMMARY, _
	TXT_POSITIONS, _
	TXT_POSTAL_CODE, _
	TXT_PUBLICATION, _
	TXT_PUBLICATION_DATE, _
	TXT_PRESCHOOL, _
	TXT_PRIVACY_PROFILE, _
	TXT_PROVIDED_BY, _
	TXT_PROVINCE, _
	TXT_RECORD_ASSIGNED_TO_SETS, _
	TXT_RECORD_DELETED, _
	TXT_RECORD_NON_PUBLIC, _
	TXT_RECORD_SCHEDULED_TO_BE_DELETED, _
	TXT_REMOVE_CHILD_CARE_RESOURCE_DESIGNATION, _
	TXT_REQUIRED, _
	TXT_REQUIRED_FIELDS_EMPTY, _
	TXT_REMOVE_RECORD_REQUEST, _
	TXT_REVIEW_RECORD, _
	TXT_RESTORE, _
	TXT_SCHOOL_AGE, _
	TXT_SERVICE_NUMBER, _
	TXT_SERVICE_WARNING, _
	TXT_SIGNATORY, _
	TXT_SITE_ADDRESS, _
	TXT_SITE_CODE, _
	TXT_SORT_NAME_ONLY, _
	TXT_SPACE_AVAILABLE, _
	TXT_STREET, _
	TXT_STREET_DIR, _
	TXT_STREET_NUMBER, _
	TXT_STREET_TYPE, _
	TXT_SUFFIX, _
	TXT_SUFFIX_DESC, _
	TXT_TO_THE_THESAURUS, _
	TXT_TODDLER, _
	TXT_TOTAL_EMPLOYEES, _
	TXT_TRANSFER_OWNERSHIP, _
	TXT_UNADDED_CHECKLISTS, _
	TXT_UNADDED_CHECKLIST_ALERT, _
	TXT_UNDO, _
	TXT_UNIQUE_ID, _
	TXT_UNKNOWN_ERRORS_OCCURED, _
	TXT_UNMATCHED_SUBJECTS, _
	TXT_UNPROCESSED_TERMS, _
	TXT_UNTITLED_ADDRESS, _
	TXT_UPDATE_ADD_RECORD, _
	TXT_UPDATE_DATE, _
	TXT_UPDATE_PASSWORD, _
	TXT_UPDATE_PASSWORD_REQUIRED, _
	TXT_UPDATE_PASSWORD_ON_ALL_INFO, _
	TXT_UPDATE_PASSWORD_ON_PRIVATE_INFO, _
	TXT_UPDATE_RECORD_TITLE, _
	TXT_UPDATE_SUCCESSFUL, _
	TXT_UPDATED_BY, _
	TXT_VACANCY_INFO_ADD_NEW, _
	TXT_VACANCY_INFO_AS_OF, _
	TXT_VACANCY_INFO_CAPACITY_OF, _
	TXT_VACANCY_INFO_CURRENT_SERVICES, _
	TXT_VACANCY_INFO_DAYS_PER_WEEK, _
	TXT_VACANCY_INFO_FULL_TIME_EQUIVALENT, _
	TXT_VACANCY_INFO_FUNDED_CAPACITY_OF, _
	TXT_VACANCY_INFO_HOURS_PER_DAY, _
	TXT_VACANCY_INFO_REMOVE_NOTE, _
	TXT_VACANCY_INFO_SERVICE_TITLE, _
	TXT_VACANCY_INFO_TARGET_POPULATION, _
	TXT_VACANCY_INFO_UNITS, _
	TXT_VACANCY_INFO_VACANCY, _
	TXT_VACANCY_INFO_WAIT_LIST, _
	TXT_VACANCY_INFO_WEEKS_PER_YEAR, _
	TXT_VACANCY_INFO_NEXT_WAIT_LIST_DATE, _
	TXT_VALIDATION_ERRORS, _
	TXT_VERSIONS, _
	TXT_VIEW_CANCELLED, _
	TXT_WARD, _
	TXT_WRONG_AGENCY_WARNING, _
	TXT_XREF

Sub setTxtEntryForm()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ACTIVITY_INFO_CURRENT_ACTIVITIES = "Activités courantes"
			TXT_ACTIVITY_INFO_DESCRIPTION = "Description de l'activité"
			TXT_ACTIVITY_INFO_END_DATE = "Date de fin"
			TXT_ACTIVITY_INFO_NAME = "Nom de l'activité"
			TXT_ACTIVITY_INFO_SCHEDULE_TYPE = "Type de calendrier"
			TXT_ACTIVITY_INFO_SERVICE_CATEGORY = "Catégorie de service"
			TXT_ACTIVITY_NUMBER = "Activité no."
			TXT_ADD_BUS_ROUTES = "Ajouter des nouvelles lignes de bus"
			TXT_ADD_COMMUNITIES = "Ajouter des nouvelles communautés"
			TXT_ADD_DISTRIBUTIONS = "Ajouter des nouveaux codes de distribution"
			TXT_ADD_INTERESTS = "Ajouter des nouveaux intérêts"
			TXT_ADD_LANGUAGES = "Ajouter des nouvelles langues"
			TXT_ADD_LOCATION_RECORD = "Ajouter un nouveau dossier de site"
			TXT_ADD_SERVICE_RECORD = "Ajouter un nouveau dossier de service"
			TXT_ADD_SCHOOLS = "Ajouter des nouvelles écoles"
			TXT_ADD_SUBJECTS = "Ajouter des nouveaux sujets"
			TXT_ADDRESS_NUMBER = "Adresse no."
			TXT_ADDRESS_TYPE = "Type d'adresse"
			TXT_AFTER_NAME = "Après le nom"
			TXT_AGENCY_WARNING = "Pas une agence"
			TXT_ALL_AGENCIES = "toutes les agences"
			TXT_AREAS_SERVED_DISPLAY_ONLY_NOTES = "Afficher uniquement les notes"
			TXT_AUTO_ASSIGN_LOWEST_NUM = "Assigner automatiquement le numéro de dossier disponible le plus bas"
			TXT_AVAILABLE = "Disponible"
			TXT_BEFORE_NAME = "Avant le nom"
			TXT_BOTH_NAMES = "des deux noms"
			TXT_BOX_NUMBER = "Numéro de case postale"
			TXT_BOX_TYPE = "Type de case postale"
			TXT_BUILDING = "Édifice"
			TXT_CANCEL = "Annuler"
			TXT_CANCELLED_ERROR = "Annulation en raison d'une erreur"
			TXT_CAPACITY = "Capacité"
			TXT_CAS_CONFIRMATION_DATE = "Date de confirmation de la SAE"
			TXT_CHECK_FEEDBACK = "Vérifier la rétroaction"
			TXT_CHECKBOX_FOR_NAME_HIDE = "Cocher la case pour cacher le nom dans les résultats"
			TXT_CHECKBOX_FOR_XREF = "Cocher la case pour publier le nom comme renvoi"
			TXT_CITY = "Municipalité"
			TXT_COMMUNITY = "Communauté"
			TXT_COMMUNITY_DATABASE = "la base de données d'information communautaire"
			TXT_COMMUNITY_SET_MANAGEMENT = "Gerer les ensembles de communautés"
			TXT_CONTENT_DELETED = "[supprimé]"
			TXT_CONTRACT_NUMBER = "Signature du contrat no."
			TXT_COUNTRY = "Pays"
			TXT_CREATE_NEW_RECORD = "Créer un nouveau dossier"
			TXT_CREATE_RECORD_FEEDBACK = "Créer un nouveau dossier à partir de la rétroaction"
			TXT_CURRENT_VALUE = "La valeur courante :"
			TXT_CUSTOM_COMMUNITY = "Autre communauté"
			TXT_DATE_SIGNED = "Date"
			TXT_DATE_OF_CHANGE = "Date du changement"
			TXT_DAY_OF_WEEK = "Jour de la semaine"
			TXT_DELETE_FEEDBACK = "Supprimer la rétroaction"
			TXT_DENOTES_TAXONOMY_HEADING = "désigne un en-tête basé sur la Taxonomie, ajouté automatiquement selon l'indexation taxonomique courante du dossier."
			TXT_DESIGNATE_CHILD_CARE_RESOURCE = "Désigner ce dossier comme ressource de garde à l'enfance"
			TXT_DISPLAY_ORG_NAME = "Afficher le nom d'organisme"
			TXT_DONT_RESTORE = "Ne pas restaurer"
			TXT_DUPLICATE_ORG_NAME_ERROR = "Le nom que vous avez fourni est déjà utilisé par un autre dossier."
			TXT_DUPLICATE_ORG_NAME_PROMPT = "Le nom que vous avez fourni est déjà utilisé par un autre dossier. Voulez-vous continuer ?"
			TXT_EDIT_EQUIVALENT = "Ce dossier est également disponible dans d'autres langues. Si vous ne l'avez pas déjà fait, veuillez consulter la ou les autres versions de ce dossier maintenant."
			TXT_EMPLOYEES = "Nombre d'employés"
			TXT_ERRORS_FOUND = "Le dossier n'a pas été mis à jour en raison des erreurs suivantes"
			TXT_FEE_ASSISTANCE_INFO = "Renseignements sur l'aide pour les honoraires"
			TXT_FEEDBACK_NUM = "Rétroaction no. "
			TXT_FIND_BY_GENERAL_INTEREST = "Trouver par <em>centre d'intérêt général</em> :"
			TXT_FIND_BY_KEYWORD = "Trouver par mot-clé :"
			TXT_FOR = "Pour"
			TXT_FOR_BROWSE_BY_LETTER_USE = "Pour le recherche &quot;Explorer par ...&quot;, utilisez la première lettre" & TXT_COLON
			TXT_FULL_TIME = "Temps plein"
			TXT_HIDE = "Cacher"
			TXT_HIDE_CANCELLED = "Cacher les notes supprimées"
			TXT_IMPORTANT = "Importante"
			TXT_INACTIVE_DATE = "Date inactive"
			TXT_INDICATES_SET_CANT_BE_CHANGED = "<span class=""""Alerte"""">*</span> signifie que cet ensemble des communautés est requis (parce qu'il est utilisé dans la vue actuelle, ou appartient à un autre membre CIOC dans cette base de données avec qui ce dossier est partagé)."
			TXT_INDIVIDUALS_WANTED = "personnes sont recherchées"
			TXT_INFANT = "Nourrissons"
			TXT_INFO_COMMUNITIES_1 = "Vous devez utiliser un nom valide compris dans la liste complète des communautés. " & _
				"Commencez à saisir un nom de communauté pour afficher une liste de correspondances possibles ; " & _
				"sélectionnez une communauté et cliquez sur &quot;Ajouter&quot;."
			TXT_INFO_COMMUNITIES_2 = "Pour une recherche exacte, utilisez le niveau de communauté le plus large possible." & _
				"<br>Les communautés de niveau supérieur et inférieur sont automatiquement comprises dans la recherche. " & _
				"<br>Vous pouvez préciser la définition de la région desservie en utilisant le champ Notes ou bien le champ Frontières."
			TXT_INFO_COPY = "Veuillez effectuer les changements appropriés avant de soumettre la page. Vous <em>devez</em> assigner un nouveau numéro de dossier à ce dossier."
			TXT_INFO_COPY_OP = "Vous copiez un dossier avec l'ID d'occasion :"
			TXT_INFO_CREATE_OP = "Vous êtes en train de créer une nouvelle occasion pour l'organisme : "
			TXT_INFO_LANGUAGES = "Vous devez utiliser un nom de langue valide compris dans la liste de contrôle des langues."
			TXT_INFO_LOCATED = "Pour une recherche exacte, utilisez le niveau de communauté le plus précis possible." & _
				"<br>Si le champ est vide, le dossier apparaîtra dans <em>toutes</em> les recherches basées sur le champ &quot;Situé dans la communauté &quot;."
			TXT_INST_APPLICATION_QUESTION = "Optionnel. Les questions de candidature font partie du formulaire lorsqu'un bénévole potentiel exprime son intérêt pour le poste."
			TXT_INST_COPY_OP = "Veuillez faire les changements appropriés avant de soumettre."
			TXT_INST_DATES_AND_TIMES = "Sélectionnez toutes les dates et heures où vous pourriez avoir besoin de bénévoles. Les bénévoles utilisant une recherche par date et heure trouveront des postes correspondant à au moins une des dates et heures sélectionnées."
			TXT_INST_DUTIES = "Fournissez une description détaillée du poste et des activités prévues."
			TXT_INST_DISPLAY_UNTIL = "Optionnel. Si vous choisissez de fournir une date &quot;Afficher jusqu'au&quot;, l'enregistrement sera <strong>supprimé des nouvelles recherches</strong> à cette date. " & _
				"Le dossier peut toujours être consulté via un lien direct, mais sera marqué comme expiré et n'acceptera pas les candidatures."
			TXT_INST_IMPORTANT_CHECK_ALL = "Cette information est nécessaire pour certains types de recherches. Veuillez prendre soin de sélectionner TOUTES les valeurs applicables."
			TXT_INST_NUM_NEEDED_COMMUNITIES = "Dans quelle(s) zone(s) géographique(s) comptez-vous chercher des volontaires pour ce poste ? Si un nombre spécifique de bénévoles est nécessaire dans une communauté particulière, vous pouvez fournir un nombre de personnes recherchées dans cette communauté."
			TXT_INST_NUM_NEEDED_NOTES = "Indiquez toute autre information pertinente sur le nombre de personnes dont vous avez besoin pour le poste de bénévole et les communautés où vous recherchez des bénévoles."
			TXT_INST_NUM_NEEDED_TOTAL = "Indiquez le nombre de bénévoles individuels recherchés pour ce poste."
			TXT_INST_POLICE_CHECK = "Indiquez si ce poste nécessite un contrôle de police actuel / un dépistage du secteur vulnérable. Il est également recommandé d'inclure des détails supplémentaires sur vos exigences de sélection dans la description du poste."
			TXT_INST_POSITION_TITLE = "Utilisez un titre court et descriptif. Évitez les titres génériques tels que &quot;Helper&quot; ou &quot;Assistant&quot;."
			TXT_INST_VOL_CONTACT = "Ces informations de contact sont fournies aux candidats pour compléter le processus de candidature, et la personne de contact recevra un e-mail de notification lorsque les volontaires manifesteront leur intérêt pour un poste. " & _
				"Veuillez vous assurer que le nom et l'adresse e-mail sont exacts et à jour."
			TXT_INVALID_RECORD_NUM = "No de dossier invalide"
			TXT_IS = "est"
			TXT_KINDERGARTEN = "École maternelle"
			TXT_LEGEND = "Légende"
			TXT_LEGEND_HELP = "Renseignements sur l'utilisation et les normes des champs"
			TXT_LEGEND_VERSIONS = "Autres versions de ce champ (versions précédentes et autres langues)"
			TXT_LICENSE_NUMBER = "No. de permis"
			TXT_LICENSE_RENEWAL = "Date de renouvellement"
			TXT_LINE = "Ligne"
			TXT_LOCATION_WARNING = "Pas un site"
			TXT_LOGO_ADDRESS = "Adresse du logo"
			TXT_LOGO_LINK_ADDRESS = "Adresse du lien du logo"
			TXT_LOGO_ALT_TEXT = "Texte alternatif du logo"
			TXT_LOGO_HOVER_TEXT = "Titre du logo"
			TXT_LOWEST_UNUSED_FOR = "Numéro le plus bas non utilisé pour "
			TXT_MAIL_ADDRESS = "Adresse postale"
			TXT_MAIL_CO = "Aux soins de"
			TXT_MAIN_NAME_ONLY = "du nom de dossier principal"
			TXT_MAP_LINK = "Lien de la carte"
			TXT_MAPPING_CATEGORY = "Catégorie de mappage"
			TXT_MAX_AGE = "Âge maximal"
			TXT_ME = "Moi"
			TXT_MIN_AGE = "Âge minimal"
			TXT_MIN_HOURS = "Minimum d'heures"
			TXT_MIN_HOURS_PER = "Minimum d'heures par"
			TXT_NAME_FIRST = "Prénom"
			TXT_NAME_LAST = "Nom"
			TXT_NEW = "(nouveau)"
			TXT_NEW_SUBJECTS = "Nouveaux sujets"
			TXT_NO_CHANGES_REQUIRED = "pas de changement requis"
			TXT_NO_LONGER_APPLICABLE = "No Longer Applicable"
			TXT_NO_UPDATE_UNTIL_CREATED = "Vous ne pouvez pas mettre à jour ce champ avant que le dossier n'ait été créé."
			TXT_NOT_AVAILABLE = "Pas disponible"
			TXT_NOT_GIVEN = "[non précisé]"
			TXT_NOTE_NUMBER = "Note # "
			TXT_NOTE_TYPE = "Type de note"
			TXT_NUM_NEEDED_TOTAL = "Nombre de bénévoles recherchés"
			TXT_OLS_USE_WARNING = "Attention : Ce dossier est utilisé dans cette capacité !"
			TXT_ON_OR_AFTER_DATE = "À cette date ou après"
			TXT_ON_OR_BEFORE_DATE = "À cette date ou avant"
			TXT_ORG_RECORD_NUM = "Numéro de dossier d'org."
			TXT_OTHER_ADDRESS_TITLE = "Titre de l'adresse"
			TXT_OTHER_NOTES = "Autre / Notes générales"
			TXT_PART_TIME = "Temps partiel / Saisonnier"
			TXT_PAST_CHANGES_SUMMARY = "Changements historiques" & TXT_COLON
			TXT_POSITIONS = "Nombre de postes pour"
			TXT_POSTAL_CODE = "Code postal"
			TXT_PUBLICATION = "Publication"
			TXT_PUBLICATION_DATE = "Date de publication"
			TXT_PRESCHOOL = "Enfants d'âge préscolaire"
			TXT_PRIVACY_PROFILE = "Profil de confidentialité"
			TXT_PROVIDED_BY = "Fourni par"
			TXT_PROVINCE = "Province"
			TXT_RECORD_ASSIGNED_TO_SETS = "Ce dossier est attribué à l'<em>ensemble de communautés</em> suivant"
			TXT_RECORD_DELETED = "Le dossier [NUM] a été supprimé."
			TXT_RECORD_NON_PUBLIC = "Le dossier [NUM] est interne."
			TXT_RECORD_SCHEDULED_TO_BE_DELETED = "La suppression du dossier sélectionné est prévue le "
			TXT_REMOVE_CHILD_CARE_RESOURCE_DESIGNATION = "Supprimer la désignation comme ressource de garde à l'enfance"
			TXT_REQUIRED = "Obligatoire"
			TXT_REQUIRED_FIELDS_EMPTY = "Un champ obligatoire est vide."
			TXT_REMOVE_RECORD_REQUEST = "Supprimer ce dossier (invalide)"
			TXT_REVIEW_RECORD = "Révision des renseignements pour le dossier" & TXT_COLON
			TXT_RESTORE = "Restaurer"
			TXT_SCHOOL_AGE = "Enfants d'âge scolaire"
			TXT_SERVICE_NUMBER = "Service no. "
			TXT_SERVICE_WARNING = "Pas un service"
			TXT_SIGNATORY = "Signataire"
			TXT_SITE_ADDRESS = "Adresse du site"
			TXT_SITE_CODE = "Code du site"
			TXT_SORT_NAME_ONLY = "du nom de tri"
			TXT_SPACE_AVAILABLE = "Places disponibles ?"
			TXT_STREET = "Nom de rue"
			TXT_STREET_DIR = "Orientation"
			TXT_STREET_NUMBER = "Numéro de rue"
			TXT_STREET_TYPE = "Type de rue"
			TXT_SUFFIX = "Suffixe"
			TXT_SUFFIX_DESC = "(par ex. unité 12, bureau 201, 2e étage, R.R.2)"
			TXT_TO_THE_THESAURUS = "au Thésaurus"
			TXT_TODDLER = "Tout-petits"
			TXT_TOTAL_EMPLOYEES = "Total employés"
			TXT_TRANSFER_OWNERSHIP = "Cocher cette case pour transférer la propriété des données partagées vers "
			TXT_UNADDED_CHECKLISTS = "Édition des listes de contrôle incomplète pour :"
			TXT_UNADDED_CHECKLIST_ALERT = "Il y a une liste de contrôle ou plus qui n'a pas été ajoutée. Voulez-vous continuer ?"
			TXT_UNDO = "Annuler"
			TXT_UNIQUE_ID = "Identifiant unique"
			TXT_UNKNOWN_ERRORS_OCCURED = "Des erreurs d'origine inconnue se sont produites lors du traitement de cette mise à jour. " & _
				"Le dossier peut ne pas avoir été mis à jour / créé, ou peut n'avoir été mis à jour que partiellement. " & _
				"L'erreur spécifique était" & TXT_COLON
			TXT_UNMATCHED_SUBJECTS = "La mise à jour n'a pas été traitée intégralement. Veuillez vérifier les termes de sujets ci-dessous."
			TXT_UNPROCESSED_TERMS = "Mots-clés non traités"
			TXT_UNTITLED_ADDRESS = "Adresse sans nom"
			TXT_UPDATE_ADD_RECORD = "Mettre à jour / Créer un dossier"
			TXT_UPDATE_DATE = "Date de mise à jour"
			TXT_UPDATE_PASSWORD = "Mot de passe pour la rétroaction"
			TXT_UPDATE_PASSWORD_REQUIRED = "La rétroaction nécessite-t-elle un mot de passe ?"
			TXT_UPDATE_PASSWORD_ON_ALL_INFO = "Pour tous les champs"
			TXT_UPDATE_PASSWORD_ON_PRIVATE_INFO = "Pour tous les champs internes"
			TXT_UPDATE_RECORD_TITLE = "Mise à jour du dossier"
			TXT_UPDATE_SUCCESSFUL = "La mise à jour a été traitée avec succès."
			TXT_UPDATED_BY = "Mis à jour par"
			TXT_VACANCY_INFO_ADD_NEW = "Ajouter un nouveau type de service" & TXT_COLON
			TXT_VACANCY_INFO_AS_OF = "à partir du"
			TXT_VACANCY_INFO_CAPACITY_OF = "<strong>Capacité</strong> de"
			TXT_VACANCY_INFO_CURRENT_SERVICES = "Services actuels" & TXT_COLON
			TXT_VACANCY_INFO_DAYS_PER_WEEK = "Jours par semaine"
			TXT_VACANCY_INFO_FULL_TIME_EQUIVALENT = "Équivalent temps plein (ETP)"
			TXT_VACANCY_INFO_FUNDED_CAPACITY_OF = "<strong>Capacité financée</strong> de"
			TXT_VACANCY_INFO_HOURS_PER_DAY = "Heures par jour"
			TXT_VACANCY_INFO_REMOVE_NOTE = "Effacer la capacité ou la réinitialiser à 0 supprimera le service."
			TXT_VACANCY_INFO_SERVICE_TITLE = "Titre du service"
			TXT_VACANCY_INFO_TARGET_POPULATION = "Public(s) cible(s)"
			TXT_VACANCY_INFO_UNITS = "unités"
			TXT_VACANCY_INFO_VACANCY = "Disponibilité"
			TXT_VACANCY_INFO_WAIT_LIST = "La liste d'attente"
			TXT_VACANCY_INFO_WEEKS_PER_YEAR = "Semaines par an"
			TXT_VACANCY_INFO_NEXT_WAIT_LIST_DATE = "Date de la prochaine <strong>liste d'attente</strong> est"
			TXT_VALIDATION_ERRORS = "Ce dossier contient des erreurs de validation."
			TXT_VERSIONS = "Versions de ce champ"
			TXT_VIEW_CANCELLED = "Voir les notes qui ont été annulés"
			TXT_WARD = "Quartier"
			TXT_WRONG_AGENCY_WARNING = "Agence incorrecte"
			TXT_XREF = "Nom de renvois réciproque"
		Case Else
			TXT_ACTIVITY_INFO_CURRENT_ACTIVITIES = "Current Activities"
			TXT_ACTIVITY_INFO_DESCRIPTION = "Activity Description"
			TXT_ACTIVITY_INFO_END_DATE = "End Date"
			TXT_ACTIVITY_INFO_NAME = "Activity Name"
			TXT_ACTIVITY_INFO_SCHEDULE_TYPE = "Scheduling Type"
			TXT_ACTIVITY_INFO_SERVICE_CATEGORY = "Service Category"
			TXT_ACTIVITY_NUMBER = "Activity #"
			TXT_ADD_BUS_ROUTES = "Add New Bus Routes"
			TXT_ADD_COMMUNITIES = "Add New Communities"
			TXT_ADD_DISTRIBUTIONS = "Add New Distribution Codes"
			TXT_ADD_INTERESTS = "Add New Interests"
			TXT_ADD_LANGUAGES = "Add New Languages"
			TXT_ADD_LOCATION_RECORD = "Add New Location Record"
			TXT_ADD_SERVICE_RECORD = "Add New Service Record"
			TXT_ADD_SCHOOLS = "Add New Schools"
			TXT_ADD_SUBJECTS = "Add New Subjects"
			TXT_ADDRESS_NUMBER = "Address #"
			TXT_ADDRESS_TYPE = "Address Type"
			TXT_AFTER_NAME = "After Name"
			TXT_AGENCY_WARNING = "Not an Agency"
			TXT_ALL_AGENCIES = "all Agencies"
			TXT_AREAS_SERVED_DISPLAY_ONLY_NOTES = "Only Display Notes"
			TXT_AUTO_ASSIGN_LOWEST_NUM = "Automatically assign the lowest available record number"
			TXT_AVAILABLE = "Available"
			TXT_BEFORE_NAME = "Before Name"
			TXT_BOTH_NAMES = "Both Names"
			TXT_BOX_NUMBER = "Postal Box Number"
			TXT_BOX_TYPE = "Postal Box Type"
			TXT_BUILDING = "Building"
			TXT_CANCEL = "Cancel"
			TXT_CANCELLED_ERROR = "Cancelled Due to Error"
			TXT_CAPACITY = "Capacity"
			TXT_CAS_CONFIRMATION_DATE = "CAS Confirmation Date"
			TXT_CHECK_FEEDBACK = "Check Feedback"
			TXT_CHECKBOX_FOR_NAME_HIDE = "Select the checkbox to hide the name in search results"
			TXT_CHECKBOX_FOR_XREF = "Select the checkbox to publish the name as a Cross-Reference"
			TXT_CITY = "City"
			TXT_COMMUNITY = "Community"
			TXT_COMMUNITY_DATABASE = "the Community Information database"
			TXT_COMMUNITY_SET_MANAGEMENT = "Manage Community Sets"
			TXT_CONTENT_DELETED = "[deleted]"
			TXT_CONTRACT_NUMBER = "Contract Signature #"
			TXT_COMMUNITY = "Community"
			TXT_COUNTRY = "Country"
			TXT_CREATE_NEW_RECORD = "Create New Record"
			TXT_CREATE_RECORD_FEEDBACK = "Create Record From Feedback"
			TXT_CURRENT_VALUE = "Current Value:"
			TXT_CUSTOM_COMMUNITY = "Custom Community"
			TXT_DATE_SIGNED = "Date"
			TXT_DATE_OF_CHANGE = "Date of Change"
			TXT_DAY_OF_WEEK = "Day of Week"
			TXT_DELETE_FEEDBACK = "Delete Feedback"
			TXT_DENOTES_TAXONOMY_HEADING = "denotes a Taxonomy-based Heading, added automatically according to the record's current Taxonomy Indexing." 
			TXT_DESIGNATE_CHILD_CARE_RESOURCE = "Designate this record as a Child Care Resource"
			TXT_DISPLAY_ORG_NAME = "Display Org Name"
			TXT_DONT_RESTORE = "Don't Restore"
			TXT_DUPLICATE_ORG_NAME_ERROR = "The name you provided is already being used by another record."
			TXT_DUPLICATE_ORG_NAME_PROMPT = "The name you provided is already being used by another record. Do you want to continue?"
			TXT_EDIT_EQUIVALENT = "This record is also available in other languages. If you have not already done so, please review the other version(s) of this record now."
			TXT_EMPLOYEES = "Number of Employees"
			TXT_ERRORS_FOUND = "The record was not updated because the following errors were found"
			TXT_FEE_ASSISTANCE_INFO = "Fee Assistance Information"
			TXT_FEEDBACK_NUM = "Feedback #"
			TXT_FIND_BY_GENERAL_INTEREST = "Find by <em>General Area of Interest</em>:"
			TXT_FIND_BY_KEYWORD = "Find by Keyword:"
			TXT_FOR = "For"
			TXT_FOR_BROWSE_BY_LETTER_USE = "For &quot;Browse by&quot; searches, use the first letter from" & TXT_COLON
			TXT_FULL_TIME = "Full-time"
			TXT_HIDE = "Hide"
			TXT_HIDE_CANCELLED = "Hide Cancelled Notes"
			TXT_INACTIVE_DATE = "Inactive Date"
			TXT_INDICATES_SET_CANT_BE_CHANGED = "<span class=""Alert"">*</span> indicates that this Community Set is required (because it is used in the current View, or belongs to another CIOC Member in this database with whom this record is shared)."
			TXT_INDIVIDUALS_WANTED = "individuals wanted"
			TXT_IMPORTANT = "Important"
			TXT_INFANT = "Infants"
			TXT_INFO_COMMUNITIES_1 = "You must use a valid name from the available list of communities. " & _
				"Begin typing a community name to see a list of possible matches; " & _
				"select a community and click the &quot;Add&quot; button."
			TXT_INFO_COMMUNITIES_2 = "For accurate searching, use the most broad Community applicable." & _
				"<br>All broader and narrower communities are included in searches automatically. " & _
				"<br>You can refine the definition of the area served in the notes field provided or in the Boundaries field."
			TXT_INFO_COPY = "Please make the appropriate changes before submitting. You <em>must</em> give this record a new record number."
			TXT_INFO_COPY_OP = "You are copying a record with Opportunity ID: "
			TXT_INFO_CREATE_OP = "You are creating a new opportunity for the organization: "
			TXT_INFO_LANGUAGES = "You must use a valid language name from the languages checklists."
			TXT_INFO_LOCATED = "For accurate searching, use the most narrow Community applicable." & _
				"<br>If you leave this field blank, this record will come up in <em>all</em> &quot;Located In Community&quot; searches."
			TXT_INST_APPLICATION_QUESTION = "Optional. Application questions become part of the form when a potential volunteer expresses interest in the position."
			TXT_INST_COPY_OP = "Please make the appropriate changes before submitting."
			TXT_INST_DATES_AND_TIMES = "Select any / all dates and times you may need volunteers. Volunteers using a date and time search will find positions that match at least one of their selected dates and times."
			TXT_INST_DISPLAY_UNTIL = "Optional. If you choose to provide a &quot;Display Until&quot; date, the record will be <strong>removed from new searches</strong> on that date. " & _
				"The record may still be viewed through a direct link, but will be marked as expired, and will not accept applications."
			TXT_INST_DUTIES = "Provide a detailed description of the position and its expected activities."
			TXT_INST_IMPORTANT_CHECK_ALL = "This information is required for some types of searches. Please take care to select ALL applicable values."
			TXT_INST_NUM_NEEDED_COMMUNITIES = "From which geographic area(s) you do expect to seek volunteers for this position? If a specific number of volunteers are needed from a particular community, you may optionally provide a count of individuals wanted from that community."
			TXT_INST_NUM_NEEDED_NOTES = "Indicate any other relevant information about the number of individuals you need for the volunteer position, and the communities where you are seeking volunteers."
			TXT_INST_NUM_NEEDED_TOTAL = "Indicate the number of individual volunteers being sought for this position."
			TXT_INST_POLICE_CHECK = "Indicate whether this position requires a current police check / vulnerable sector screening. It is also recommended that you include additional details on your screening requirements in the description of the position."
			TXT_INST_POSITION_TITLE = "Use a short, descriptive title. Avoid generic titles such as &quot;Helper&quot; or &quot;Assistant&quot;"
			TXT_INST_VOL_CONTACT = "This contact information is provided to potential volunteers to complete the application process, and the contact will receive a notification email when volunteers express their interest in a position. " & _
				"Please ensure that the posting includes an accurate and up-to-date name and Email."
			TXT_INVALID_RECORD_NUM = "Invalid Record #"
			TXT_IS = "is"
			TXT_KINDERGARTEN = "Kindergarten"
			TXT_LEGEND = "Legend"
			TXT_LEGEND_HELP = "Field use and standards information"
			TXT_LEGEND_VERSIONS = "Other versions of this field (past versions, other languages)"
			TXT_LICENSE_NUMBER = "License #"
			TXT_LICENSE_RENEWAL = "Renewal Date"
			TXT_LINE = "Line"
			TXT_LOCATION_WARNING = "Not a Location"
			TXT_LOGO_ADDRESS = "Logo Address"
			TXT_LOGO_LINK_ADDRESS = "Logo Link Address"
			TXT_LOGO_ALT_TEXT = "Logo Alt Text"
			TXT_LOGO_HOVER_TEXT = "Logo Hover (Title) Text"
			TXT_LOWEST_UNUSED_FOR = "Lowest Unused for "
			TXT_MAIL_ADDRESS = "Mailing Address"
			TXT_MAIL_CO = "Mail Care of"
			TXT_MAIN_NAME_ONLY = "Main Record Name only"
			TXT_MAP_LINK = "Map Link"
			TXT_MAPPING_CATEGORY = "Mapping Category"
			TXT_MAX_AGE = "Maximum Age"
			TXT_ME = "Me"
			TXT_MIN_AGE = "Minimum Age"
			TXT_MIN_HOURS = "Minimum Hours"
			TXT_MIN_HOURS_PER = "Minimum Hours Per"
			TXT_NAME_FIRST = "First"
			TXT_NAME_LAST = "Last"
			TXT_NEW = "(new)"
			TXT_NEW_SUBJECTS = "New Subjects"
			TXT_NO_CHANGES_REQUIRED = "no changes required"
			TXT_NO_LONGER_APPLICABLE = "No Longer Applicable"
			TXT_NO_UPDATE_UNTIL_CREATED = "You cannot update this field until the record has been created."
			TXT_NOT_AVAILABLE = "Not Available"
			TXT_NOT_GIVEN = "[not given]"
			TXT_NOTE_NUMBER = "Note #"
			TXT_NOTE_TYPE = "Note Type"
			TXT_NUM_NEEDED_TOTAL = "Number of Volunteers Wanted"
			TXT_OLS_USE_WARNING = "Warning: This record is being used in this capacity!"
			TXT_ON_OR_AFTER_DATE = "On or after the date"
			TXT_ON_OR_BEFORE_DATE = "On or before the date"
			TXT_ORG_RECORD_NUM = "Org. Record #"
			TXT_OTHER_ADDRESS_TITLE = "Address Title"
			TXT_OTHER_NOTES = "Other / General Notes"
			TXT_PART_TIME = "Part Time / Seasonal"
			TXT_PAST_CHANGES_SUMMARY = "Past record changes" & TXT_COLON
			TXT_POSITIONS = "Number of Positions for"
			TXT_POSTAL_CODE = "Postal Code"
			TXT_PUBLICATION = "Publication"
			TXT_PUBLICATION_DATE = "Publication Date"
			TXT_PRESCHOOL = "Preschool"
			TXT_PRIVACY_PROFILE = "Privacy Profile"
			TXT_PROVIDED_BY = "Provided&nbsp;By"
			TXT_PROVINCE = "Province"
			TXT_RECORD_ASSIGNED_TO_SETS = "This record is assigned to the following <em>Community Sets</em>"
			TXT_RECORD_DELETED = "Record [NUM] is deleted."
			TXT_RECORD_NON_PUBLIC = "Record [NUM] is non-public"
			TXT_RECORD_SCHEDULED_TO_BE_DELETED = "The selected record is scheduled to be deleted on "
			TXT_REMOVE_CHILD_CARE_RESOURCE_DESIGNATION = "Remove Child Care Resource designation"
			TXT_REQUIRED = "Required"
			TXT_REQUIRED_FIELDS_EMPTY = "A required field is empty."
			TXT_REMOVE_RECORD_REQUEST = "Delete this record (not valid)"
			TXT_REVIEW_RECORD = "Review Information For Record" & TXT_COLON
			TXT_RESTORE = "Restore"
			TXT_SCHOOL_AGE = "School Age"
			TXT_SERVICE_NUMBER = "Service #"
			TXT_SERVICE_WARNING = "Not a Service"
			TXT_SIGNATORY = "Signatory"
			TXT_SITE_ADDRESS = "Site Address"
			TXT_SITE_CODE = "Site Code"
			TXT_SORT_NAME_ONLY = "Sort Name only"
			TXT_SPACE_AVAILABLE = "Space Available?"
			TXT_STREET = "Street Name"
			TXT_STREET_DIR = "Street Direction"
			TXT_STREET_NUMBER = "Street Number"
			TXT_STREET_TYPE = "Street Type"
			TXT_SUFFIX = "Suffix"
			TXT_SUFFIX_DESC = "(e.g. Unit 12, Suite 201, 2nd Flr, RR 2)"
			TXT_TO_THE_THESAURUS = "to the Thesaurus"
			TXT_TODDLER = "Toddlers"
			TXT_TOTAL_EMPLOYEES = "Total Employees"
			TXT_TRANSFER_OWNERSHIP = "Check this box to transfer shared data ownership to "
			TXT_UNADDED_CHECKLISTS = "Checklist editing incomplete for:"
			TXT_UNADDED_CHECKLIST_ALERT = "There is one or more checklist items that have not been added. Do you want to continue?"
			TXT_UNDO = "Undo"
			TXT_UNIQUE_ID = "Unique ID"
			TXT_UNKNOWN_ERRORS_OCCURED = "Unknown errors occurred while processing this update. " & _
				" The record may not have been updated/created, or may have only been partially updated. " & _
				" The specific error was" & TXT_COLON
			TXT_UNMATCHED_SUBJECTS = "The update was not fully processed. Please review the subject terms below."
			TXT_UNPROCESSED_TERMS = "Unprocessed Terms"
			TXT_UNTITLED_ADDRESS = "Untitled Address"
			TXT_UPDATE_ADD_RECORD = "Update/Add Record"
			TXT_UPDATE_DATE = "Update Date"
			TXT_UPDATE_PASSWORD = "Feedback password"
			TXT_UPDATE_PASSWORD_REQUIRED = "Feedback requires password?"
			TXT_UPDATE_PASSWORD_ON_ALL_INFO = "For all fields"
			TXT_UPDATE_PASSWORD_ON_PRIVATE_INFO = "For private fields"
			TXT_UPDATE_RECORD_TITLE = "Update Record"
			TXT_UPDATE_SUCCESSFUL = "The update was processed successfully"
			TXT_UPDATED_BY = "Updated&nbsp;By"
			TXT_VACANCY_INFO_ADD_NEW = "Add New Type of Service" & TXT_COLON
			TXT_VACANCY_INFO_AS_OF = "as of"
			TXT_VACANCY_INFO_CAPACITY_OF = "<strong>Capacity</strong> of"
			TXT_VACANCY_INFO_CURRENT_SERVICES = "Current Services" & TXT_COLON
			TXT_VACANCY_INFO_DAYS_PER_WEEK = "Days per week"
			TXT_VACANCY_INFO_FULL_TIME_EQUIVALENT = "Full-time Equivalent (FTE)"
			TXT_VACANCY_INFO_FUNDED_CAPACITY_OF = "<strong>Funded Capacity</strong> of"
			TXT_VACANCY_INFO_HOURS_PER_DAY = "Hours per day"
			TXT_VACANCY_INFO_REMOVE_NOTE = "Clearing or setting the Capacity to 0 will delete the service."
			TXT_VACANCY_INFO_SERVICE_TITLE = "Service Title"
			TXT_VACANCY_INFO_TARGET_POPULATION = "Target population(s)"
			TXT_VACANCY_INFO_UNITS = "units"
			TXT_VACANCY_INFO_VACANCY = "Availability"
			TXT_VACANCY_INFO_WAIT_LIST = "Wait list"
			TXT_VACANCY_INFO_WEEKS_PER_YEAR = "Weeks per year"
			TXT_VACANCY_INFO_NEXT_WAIT_LIST_DATE = "Next available <strong>wait list date</strong> is"
			TXT_VALIDATION_ERRORS = "This record contains validation errors."
			TXT_VERSIONS = "Versions of this field"
			TXT_VIEW_CANCELLED = "View Cancelled Notes"
			TXT_WARD = "Ward"
			TXT_WRONG_AGENCY_WARNING = "Wrong Agency"
			TXT_XREF = "Cross-reference Name"
	End Select
End Sub

Call setTxtEntryForm()
Call addTextFile("setTxtEntryForm")
%>
