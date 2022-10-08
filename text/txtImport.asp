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
Dim TXT_ADD_PROFILE_FAILED, _
	TXT_ALL_RECORDS, _
	TXT_AND_WILL_BE_TOMORROW, _
	TXT_ARCHIVE_DATASET, _
	TXT_ARCHIVE, _
	TXT_ARE_YOU_SURE_ARCHIVE, _
	TXT_ARE_YOU_SURE_UNARCHIVE, _
	TXT_ARE_YOU_SURE_RESCHEDULE, _
	TXT_CAN_BE_RETRIED, _
	TXT_CAN_RESCHEDULE, _
	TXT_CAN_RETRY, _
	TXT_CANCEL_QUEUE, _
	TXT_CANNOT_IMPORT, _
	TXT_CASE_DELETED_CONFLICT, _
	TXT_CASE_OWNERSHIP_CONFLICT, _
	TXT_CASE_PRIVACY_CONFLICT, _
	TXT_CASE_PUBLIC_CONFLICT, _
	TXT_CHOOSE_DATASET, _
	TXT_CHOOSE_PRIVACY_PROFILE, _
	TXT_COMPLETED, _
	TXT_COULD_NOT_ADD_TAXONOMY_CODES, _
	TXT_COULD_NOT_CREATE_ACTIVITY, _
	TXT_CURRENT_NAMES, _
	TXT_DATE_LOADED, _
	TXT_DELETE_DATASET, _
	TXT_DISTRIBUTION_LIST, _
	TXT_DO_NOT_IMPORT, _
	TXT_EXISTING_DATASETS, _
	TXT_EXISTS, _
	TXT_FIELD_LIST, _
	TXT_FILE_NAME, _
	TXT_FILES_IN_IMPORT_QUEUE, _
	TXT_FOLLOWING_PUBS_ADDED_AUTOMATICALLY, _
	TXT_GENERAL_INFO, _
	TXT_IMPORT_FILE_IN_QUEUE, _
	TXT_IMPORT_FILE_NOT_IN_QUEUE, _
	TXT_IMPORT_FINISHED_AT, _
	TXT_IMPORT_NAME, _
	TXT_IMPORT_OPTIONS, _
	TXT_IMPORT_RECORD_DATA, _
	TXT_IMPORT_REPORT, _
	TXT_IMPORT_SOURCE_DATABASE_INFO, _
	TXT_IMPORT_STARTED_AT, _
	TXT_IMPORT_TOP, _
	TXT_INVALID_GEOCODE_INFO, _
	TXT_KEEP_EXISTING, _
	TXT_KEEP_EXISTING_DELETED, _
	TXT_KEEP_EXISTING_PRIVACY, _
	TXT_KEEP_EXISTING_PUBLIC, _
	TXT_LOAD_NEW_DATASET, _
	TXT_MAP_PROFILE, _
	TXT_MORE_INFO, _
	TXT_NEW_RECORD, _
	TXT_NO_DIST_CODES, _
	TXT_NO_ISSUES, _
	TXT_NO_PRIVACY_PROFILES, _
	TXT_NO_PUB_CODES, _
	TXT_NUMBER_TO_IMPORT, _
	TXT_PRIVACY_PROFILE_ADDED, _
	TXT_PRIVACY_PROFILE_LIST, _
	TXT_PRIVACY_PROFILE_MAP, _
	TXT_PRIVATE_FIELDS, _
	TXT_PROCESS_NOW, _
	TXT_PROFILE_NAME, _
	TXT_PROFILE_NAME_FRENCH, _
	TXT_PUBLICATION_LIST, _
	TXT_QUEUE_ALL, _
	TXT_QUEUE_RECORDS_FOR_LATER, _
	TXT_RECORD_WAS_SUCCESSFULLY, _
	TXT_RECORD_WAS_NOT, _
	TXT_RECORDS_IMPORTED, _
	TXT_RECORDS_OWNED_BY_OTHERS, _
	TXT_RECORDS_THAT_DONT_MATCH, _
	TXT_RECORDS_THAT_MATCH, _
	TXT_RECORDS_TO_IMPORT, _
	TXT_RECORDS_TO_RETRY, _
	TXT_RECORDS_WHERE_DELETED, _
	TXT_RECORDS_WHERE_NON_PUBLIC, _
	TXT_RESCHEDULE, _
	TXT_RESCHEDULE_ALL, _
	TXT_RESCHEDULED, _
	TXT_RESCHEDULE_RECORD, _
	TXT_RETRY_FAILED_RECORDS, _
	TXT_RETURN_TO_IMPORT, _
	TXT_RETURN_TO_LIST, _
	TXT_REVIEW_LIST_BELOW, _
	TXT_SELECT_OWNERS, _
	TXT_SELECT_PUBS, _
	TXT_SHOW_ARCHIVED_IMPORTS, _
	TXT_SHOW_UNARCHIVED_IMPORTS, _
	TXT_SKIP_FIELDS, _
	TXT_SKIP_RECORD, _
	TXT_SOURCE_DATABASE, _
	TXT_SOURCE_DATABASE_CODE, _
	TXT_TAXONOMY_INDEXING_DOES_NOT_MATCH, _
	TXT_THIS_DATASET_INCLUDES, _
	TXT_TO_IMPORT_SELECT, _
	TXT_TO_LIMIT, _
	TXT_UNABLE_LIST_FIELDS, _
	TXT_UNABLE_QUEUE_IMPORT_FILE, _
	TXT_UNARCHIVE, _
	TXT_UNARCHIVED, _
	TXT_UNARCHIVE_DATASET, _
	TXT_UNKNOWN_FIELD, _
	TXT_UNKNOWN_INACTIVE_OR_DUPLICATE_VALUE, _
	TXT_UNKNOWN_VALUE, _
	TXT_UNKNOWN_VALUE_MOVED_TO_NOTES, _
	TXT_UNMAPPED_PROFILES, _
	TXT_UNMATCHED_ICAROL_RECORDS, _
	TXT_UPDATE_DELETED, _
	TXT_UPDATE_OWNER, _
	TXT_UPDATE_PRIVACY, _
	TXT_UPDATE_PUBLIC, _
	TXT_USED_VALUE, _
	TXT_VIEW_DATA, _
	TXT_VIEW_IMPORT_DATA, _
	TXT_YOU_MAY_SELECT_OWNERS

Sub setTxtImport()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_PROFILE_FAILED = "Add Privacy Profile failed"
			TXT_ALL_RECORDS = "All Records"
			TXT_AND_WILL_BE_TOMORROW = " and will be in a new import tomorrow."
			TXT_ARCHIVE_DATASET = "Archive Dataset"
			TXT_ARCHIVE = "Archive"
			TXT_ARE_YOU_SURE_ARCHIVE = "Are you sure you want to archive this item?" & _
				"<br>Use your back button to return to the form if you do not want to archive."
			TXT_ARE_YOU_SURE_UNARCHIVE = "Are you sure you want to unarchive this item?" & _
				"<br>Use your back button to return to the form if you do not want to unarchive."
			TXT_ARE_YOU_SURE_RESCHEDULE = "Are you sure you want to reschedule an import of these records?" & _
				"<br>Use your back button to return to the form if you do not want to reschedule."
			TXT_CAN_BE_RETRIED = "can be retried."
			TXT_CAN_RESCHEDULE = "Can Reschedule"
			TXT_CAN_RETRY = "Can Retry"
			TXT_CANCEL_QUEUE = "Cancel Queue"
			TXT_CANNOT_IMPORT = "Cannot Import"
			TXT_CASE_DELETED_CONFLICT = "In case of a deletion date conflict"
			TXT_CASE_OWNERSHIP_CONFLICT = "In case of an ownership conflict"
			TXT_CASE_PRIVACY_CONFLICT = "In case of a privacy profile conflict"
			TXT_CASE_PUBLIC_CONFLICT = "In case of a public status conflict"
			TXT_CHOOSE_DATASET = "Choose a dataset from the list below, or load a new dataset"
			TXT_CHOOSE_PRIVACY_PROFILE = "Choose a privacy profile from the list below"
			TXT_COMPLETED = "Completed"
			TXT_COULD_NOT_ADD_TAXONOMY_CODES = "Could not add Taxonomy codes" & TXT_COLON
			TXT_COULD_NOT_CREATE_ACTIVITY = "Could not create activity"
			TXT_CURRENT_NAMES = "Current Org. Name(s)"
			TXT_DATE_LOADED = "Date Loaded"
			TXT_DELETE_DATASET = "Delete Dataset"
			TXT_DISTRIBUTION_LIST = "Distribution List"
			TXT_DO_NOT_IMPORT = "Do Not Import Data"
			TXT_EXISTING_DATASETS = "Existing Datasets"
			TXT_EXISTS = "Exists"
			TXT_FIELD_LIST = "Field List"
			TXT_FILE_NAME = "File Name"
			TXT_FILES_IN_IMPORT_QUEUE = " file(s) in the Import Queue."
			TXT_FOLLOWING_PUBS_ADDED_AUTOMATICALLY = "The following Publication Code(s) are usually added automatically to new records in the current View. If checked, they will be added automatically to the imported records if not already present."
			TXT_GENERAL_INFO = "General Information"
			TXT_IMPORT_FILE_IN_QUEUE = "The selected file has been put into the Import Queue."
			TXT_IMPORT_FILE_NOT_IN_QUEUE = "The selected file has been removed from the Import Queue."
			TXT_IMPORT_FINISHED_AT = "Import finished at" & TXT_COLON
			TXT_IMPORT_NAME = "Import Name"
			TXT_IMPORT_OPTIONS = "Import Options"
			TXT_IMPORT_RECORD_DATA = "Import Record Data"
			TXT_IMPORT_REPORT = "Import Report"
			TXT_IMPORT_SOURCE_DATABASE_INFO = "Import Source Database information (if available)"
			TXT_IMPORT_STARTED_AT = "Import started at" & TXT_COLON
			TXT_IMPORT_TOP = "Import Top "
			TXT_INVALID_GEOCODE_INFO = "Invalid or incomplete geocoding information"
			TXT_KEEP_EXISTING = "Keep Existing Owner"
			TXT_KEEP_EXISTING_DELETED = "Keep Existing Deletion Date"
			TXT_KEEP_EXISTING_PRIVACY = "Keep Existing Privacy Profile"
			TXT_KEEP_EXISTING_PUBLIC = "Keep Existing Public Status"
			TXT_LOAD_NEW_DATASET = "Load New Dataset"
			TXT_MAP_PROFILE = "Map to Existing Profile"
			TXT_MORE_INFO = "More Info"
			TXT_NEW_RECORD = "New Record"
			TXT_NO_DIST_CODES = "No Distribution Codes to import"
			TXT_NO_ISSUES = "No Issues"
			TXT_NO_PRIVACY_PROFILES = "No Privacy Profiles to import"
			TXT_NO_PUB_CODES = "No Publication Codes to import"
			TXT_NUMBER_TO_IMPORT = "Number of Records to Import"
			TXT_PRIVACY_PROFILE_ADDED = "Privacy Profile added"
			TXT_PRIVACY_PROFILE_LIST = "Privacy Profile List"
			TXT_PRIVACY_PROFILE_MAP = "Privacy Profile Map"
			TXT_PRIVATE_FIELDS = "Private Fields"
			TXT_PROCESS_NOW = "Process Now"
			TXT_PROFILE_NAME = "Profile Name"
			TXT_PROFILE_NAME_FRENCH = "French Profile Name"
			TXT_PUBLICATION_LIST = "Publication List"
			TXT_QUEUE_ALL = "Queue All"
			TXT_QUEUE_RECORDS_FOR_LATER = "Queue records for later import"
			TXT_RECORD_WAS_SUCCESSFULLY = "The record was successfully "
			TXT_RECORD_WAS_NOT = "The record was not "
			TXT_RECORDS_IMPORTED = " records in this dataset that have been imported."
			TXT_RECORDS_OWNED_BY_OTHERS = " records in this dataset that correspond to existing records owned by other CIOC Members in this database. You cannot import these records."
			TXT_RECORDS_THAT_DONT_MATCH = " records in this dataset that do not match existing records."
			TXT_RECORDS_THAT_MATCH = " records in this dataset that correspond to existing records."
			TXT_RECORDS_TO_IMPORT = " records to import."
			TXT_RECORDS_TO_RETRY = "records to retry."
			TXT_RECORDS_WHERE_DELETED = " records where at least one language is marked for deletion."
			TXT_RECORDS_WHERE_NON_PUBLIC = " records where at least one language is marked non-public."
			TXT_RESCHEDULE = "Reschedule"
			TXT_RESCHEDULE_ALL = "Reschedule All Possible"
			TXT_RESCHEDULED = "Rescheduled"
			TXT_RESCHEDULE_RECORD = "Reschedule Record Import"
			TXT_RETRY_FAILED_RECORDS = "Retry records from previous run that reported issues"
			TXT_RETURN_TO_LIST = "Return to Record List"
			TXT_RETURN_TO_IMPORT = "Return to Import Menu"
			TXT_REVIEW_LIST_BELOW = "You can review the list of records below."
			TXT_SELECT_OWNERS = "Select Record Owner(s)"
			TXT_SELECT_PUBS = "Select Publications Codes"
			TXT_SHOW_ARCHIVED_IMPORTS = "Show Archived Imports"
			TXT_SHOW_UNARCHIVED_IMPORTS = "Show Unarchived Imports"
			TXT_SKIP_FIELDS = "Don't import private fields"
			TXT_SKIP_RECORD = "Postpone processing of entire record"
			TXT_SOURCE_DATABASE = "Source Database"
			TXT_SOURCE_DATABASE_CODE = "Source Database Code"
			TXT_TAXONOMY_INDEXING_DOES_NOT_MATCH = "Taxonomy Indexing does not allow a match for the Heading(s)" & TXT_COLON
			TXT_THIS_DATASET_INCLUDES = "This dataset includes "
			TXT_TO_IMPORT_SELECT = "To import these records into the database, select from the options below."
			TXT_TO_LIMIT = "You may wish to limit the number of records imported at one time for performance reasons." & _
				"<br>If you specify a number (X) in the box below, only the first X records will be imported." & _
				"<br>You can repeat the process as necessary to complete the import."
			TXT_UNABLE_LIST_FIELDS = "Unable to retrieve a list of fields."
			TXT_UNABLE_QUEUE_IMPORT_FILE = "Unable to add / remove the selected file from the Import Queue"
			TXT_UNARCHIVE = "Unarchive"
			TXT_UNARCHIVED = "unarchived"
			TXT_UNARCHIVE_DATASET = "Unarchive Dataset"
			TXT_UNKNOWN_FIELD = "Unknown field"
			TXT_UNKNOWN_INACTIVE_OR_DUPLICATE_VALUE = "Unknown, inactive, or duplicate value(s)"
			TXT_UNKNOWN_VALUE = "Unknown value"
			TXT_UNKNOWN_VALUE_MOVED_TO_NOTES = "Unknown value moved to notes"
			TXT_UNMAPPED_PROFILES = "In case of unmapped Privacy Profiles"
			TXT_UNMATCHED_ICAROL_RECORDS = "Unmatched iCarol Records"
			TXT_UPDATE_DELETED = "Update Deletion Date"
			TXT_UPDATE_OWNER = "Update Owner"
			TXT_UPDATE_PRIVACY = "Update Privacy Profile"
			TXT_UPDATE_PUBLIC = "Update Public Status"
			TXT_USED_VALUE = ", used "
			TXT_VIEW_DATA = "View&nbsp;Data"
			TXT_VIEW_IMPORT_DATA = "View Import Data"
			TXT_YOU_MAY_SELECT_OWNERS = "You may limit the import to one or more record owners by selecting from the list below."
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_PROFILE_FAILED = "L'ajout du Profil de confidentialité a échoué."
			TXT_ALL_RECORDS = "Tous les dossiers"
			TXT_AND_WILL_BE_TOMORROW = "TRANSLATE_FR --  and will be in a new import tomorrow."
			TXT_ARCHIVE_DATASET = "Archiver le fichier de données"
			TXT_ARCHIVE = "Archive"
			TXT_ARE_YOU_SURE_ARCHIVE = "TRANSLATE_FR -- Are you sure you want to archive this item?" & _
				"<br>Use your back button to return to the form if you do not want to archive."
			TXT_ARE_YOU_SURE_UNARCHIVE = "TRANSLATE_FR -- Are you sure you want to unarchive this item?" & _
				"<br>Use your back button to return to the form if you do not want to unarchive."
			TXT_ARE_YOU_SURE_RESCHEDULE = "TRANSLATE_FR -- Are you sure you want to reschedule an import of these records?" & _
				"<br>Use your back button to return to the form if you do not want to reschedule."
			TXT_CAN_BE_RETRIED = "TRANSLATE_FR -- can be retried."
			TXT_CAN_RESCHEDULE = "TRANSLATE_FR -- Can Reschedule"
			TXT_CAN_RETRY = "TRANSLATE_FR -- Can Retry"
			TXT_CANCEL_QUEUE = "Annuler la file d'attente"
			TXT_CANNOT_IMPORT = "Impossible d'importer"
			TXT_CASE_DELETED_CONFLICT = "Dans le cas d'un conflit sur la date de suppression"
			TXT_CASE_OWNERSHIP_CONFLICT = "En cas de désaccord sur la propriété des dossiers"
			TXT_CASE_PRIVACY_CONFLICT = "Dans le cas d'un conflit d'un profil de confidentialité"
			TXT_CASE_PUBLIC_CONFLICT = "Dans le cas d'un conflit sur le statut public"
			TXT_CHOOSE_DATASET = "Choisir un ensemble de données dans la liste ci-dessous, ou télécharger un nouvel ensemble de données"
			TXT_CHOOSE_PRIVACY_PROFILE = "Veuillez sélectionner un profil de confidentialité dans la liste ci-dessous"
			TXT_COMPLETED = "Terminé"
			TXT_COULD_NOT_ADD_TAXONOMY_CODES = "Les codes taxonomiques suivants n'ont pu être ajoutés " & TXT_COLON
			TXT_COULD_NOT_CREATE_ACTIVITY = "L'activité n'a pu être créée"
			TXT_CURRENT_NAMES = "Nom(s) d'org. actuel(s)"
			TXT_DATE_LOADED = "Date du téléchargement"
			TXT_DELETE_DATASET = "Supprimer l'ensemble de données"
			TXT_DISTRIBUTION_LIST = "Liste de distribution"
			TXT_DO_NOT_IMPORT = "Ne pas importer les données"
			TXT_EXISTING_DATASETS = "Ensembles de données existants"
			TXT_EXISTS = "Existe"
			TXT_FIELD_LIST = "Liste des champs"
			TXT_FILE_NAME = "Nom du dossier"
			TXT_FILES_IN_IMPORT_QUEUE = " dossier(s) dans la file d'attente des importations."
			TXT_FOLLOWING_PUBS_ADDED_AUTOMATICALLY = "Le ou les codes de publication suivants sont habituellement ajoutés automatiquement aux nouveaux dossiers dans la vue actuelle. En cochant cette option, ils seront ajoutés automatiquement aux dossiers importés où ils ne sont pas présents."
			TXT_GENERAL_INFO = "Renseignements généraux"
			TXT_IMPORT_FILE_IN_QUEUE = "Le dossier sélectionné a été ajouté à la file d'attente des importations."
			TXT_IMPORT_FILE_NOT_IN_QUEUE = "Le dossier sélectionné a été retiré de la file d'attente des importations."
			TXT_IMPORT_FINISHED_AT = "L'importation s'est terminé à" & TXT_COLON
			TXT_IMPORT_NAME = "Nom du fichier d'importation"
			TXT_IMPORT_OPTIONS = "Options d'importation"
			TXT_IMPORT_RECORD_DATA = "Importer les données du dossier"
			TXT_IMPORT_REPORT = "Rapport d'importation"
			TXT_IMPORT_SOURCE_DATABASE_INFO = "Importer les renseignements sur la base de données source (si disponibles)"
			TXT_IMPORT_STARTED_AT = "L'importation a commencé le" & TXT_COLON
			TXT_IMPORT_TOP = "Importer les premiers "
			TXT_INVALID_GEOCODE_INFO = "Information de géocodage invalide ou incomplète"
			TXT_KEEP_EXISTING = "Garder le propriétaire actuel"
			TXT_KEEP_EXISTING_DELETED = "Conserver la date de suppression existante"
			TXT_KEEP_EXISTING_PRIVACY = "Conserver le profil de confidentialité actuel"
			TXT_KEEP_EXISTING_PUBLIC = "Conserver le statut public existant"
			TXT_LOAD_NEW_DATASET = "Télécharger un nouvel ensemble de données"
			TXT_MAP_PROFILE = "Faire correspondre au profil existant"
			TXT_MORE_INFO = "Renseignements supplémentaires"
			TXT_NEW_RECORD = "Nouveau dossier"
			TXT_NO_DIST_CODES = "Aucun code de distribution à importer"
			TXT_NO_ISSUES = "Pas de problème"
			TXT_NO_PRIVACY_PROFILES = "Aucun profil de confidentialité à importer"
			TXT_NO_PUB_CODES = "Aucun code de publication à importer"
			TXT_NUMBER_TO_IMPORT = "Nombre de dossiers à importer"
			TXT_PRIVACY_PROFILE_ADDED = "Le profil de confidentialité a été ajouté à"
			TXT_PRIVACY_PROFILE_LIST = "Liste des profils de confidentialité"
			TXT_PRIVACY_PROFILE_MAP = "Correspondance avec le profil de confidentialité"
			TXT_PRIVATE_FIELDS = "Champs confidentiels"
			TXT_PROCESS_NOW = "Commencer le traitement"
			TXT_PROFILE_NAME = "Nom anglais du profil"
			TXT_PROFILE_NAME_FRENCH = "Nom français du profil"
			TXT_PUBLICATION_LIST = "Liste des publications"
			TXT_QUEUE_ALL = "Mettre tous les dossiers dans la file d'attente"
			TXT_QUEUE_RECORDS_FOR_LATER = "Mettre les dossiers dans la file d'attente et les importer plus tard"
			TXT_RECORD_WAS_SUCCESSFULLY = "Le dossier a bien été "
			TXT_RECORD_WAS_NOT = "Le dossier n'était pas "
			TXT_RECORDS_IMPORTED = " dossiers dans cet ensemble de données qui ont été importés."
			TXT_RECORDS_OWNED_BY_OTHERS = " dossiers dans cet ensemble de données qui correspondent à des dossiers existants appartenant à d'autres membres CIOC dans cette base de données. Vous ne pouvez pas importer ces dossiers."
			TXT_RECORDS_THAT_DONT_MATCH = " dossiers dans cet ensemble de données qui ne concordent pas avec des dossiers existants."
			TXT_RECORDS_THAT_MATCH = " dossiers dans cet ensemble de données qui concordent avec des dossiers existants."
			TXT_RECORDS_TO_IMPORT = " dossiers à importer."
			TXT_RECORDS_TO_RETRY = "TRANSLATE_FR -- records to retry."
			TXT_RECORDS_WHERE_DELETED = "TRANSLATE_FR --  records where at least one language is marked for deletion."
			TXT_RECORDS_WHERE_NON_PUBLIC = "TRANSLATE_FR --  records where at least one language is marked non-public."
			TXT_RESCHEDULE = "TRANSLATE_FR -- Reschedule"
			TXT_RESCHEDULE_ALL = "TRANSLATE_FR -- Reschedule All Possible"
			TXT_RESCHEDULED = "TRANSLATE_FR -- Rescheduled"
			TXT_RESCHEDULE_RECORD = "TRANSLATE_FR -- Reschedule Record Import"
			TXT_RETRY_FAILED_RECORDS = "TRANSLATE_FR -- Retry records from previous run that reported issues"
			TXT_RETURN_TO_LIST = "Retourner à la liste des dossiers"
			TXT_RETURN_TO_IMPORT = "Retourner au menu de l'importation"
			TXT_REVIEW_LIST_BELOW = "Vous pouvez consulter la liste des dossiers ci-dessous."
			TXT_SELECT_OWNERS = "Sélectionner le(s) propriétaire(s) du dossier"
			TXT_SELECT_PUBS = "Sélectionner les codes du publication"
			TXT_SHOW_ARCHIVED_IMPORTS = "TRANSLATE_FR -- Show Archived Imports"
			TXT_SHOW_UNARCHIVED_IMPORTS = "TRANSLATE_FR -- Show Unarchived Imports"
			TXT_SKIP_FIELDS = "Ne pas importer les champs confidentiels"
			TXT_SKIP_RECORD = "Reporter à plus tard le traitement du dossier complet"
			TXT_SOURCE_DATABASE = "Base de données source"
			TXT_SOURCE_DATABASE_CODE = "TRANSLATE_FR -- Source Database Code"
			TXT_TAXONOMY_INDEXING_DOES_NOT_MATCH = "L'indexation taxonomique ne permet pas de correspondance avec les en-têtes" & TXT_COLON
			TXT_THIS_DATASET_INCLUDES = "TRANSLATE_FR -- This dataset includes "
			TXT_TO_IMPORT_SELECT = "Pour importer ces dossiers dans la base de données, choisir parmi les options ci-dessous."
			TXT_TO_LIMIT = "Par souci d'efficacité, vous pourriez vouloir limiter le nombre de dossiers à importer à la fois." & _
				"<br>En sélectionnant un nombre (X) dans la case ci-dessous, seul les X premiers dossiers seront importés." & _
				"<br>Vous pouvez répéter l'opération autant de fois que nécessaire pour terminer l'importation."
			TXT_UNABLE_LIST_FIELDS = "Impossible de retourner une liste des champs."
			TXT_UNABLE_QUEUE_IMPORT_FILE = "Impossible d'ajouter / supprimer le dossier sélectionné de la file d'attente des importations"
			TXT_UNARCHIVE = "TRANSLATE_FR -- Unarchive"
			TXT_UNARCHIVED = "TRANSLATE_FR -- unarchived"
			TXT_UNARCHIVE_DATASET = "TRANSLATE_FR -- Unarchive Dataset"
			TXT_UNKNOWN_FIELD = "Champ inconnue"
			TXT_UNKNOWN_INACTIVE_OR_DUPLICATE_VALUE = "Valeur(s) inconnue(s), inactive(s) ou doublon(s)"
			TXT_UNKNOWN_VALUE = "Valeur inconnue"
			TXT_UNKNOWN_VALUE_MOVED_TO_NOTES = "Valeur inconnue a été déplacé dans les notes"
			TXT_UNMAPPED_PROFILES = "Au cas où il n'existe pas de correspondance avec le profil de confidentialité"
			TXT_UNMATCHED_ICAROL_RECORDS = "TRANSLATE_FR -- Unmatched iCarol Records"
			TXT_UPDATE_DELETED = "Mettre à jour la date de suppression"
			TXT_UPDATE_OWNER = "Mettre à jour le propriétaire du dossier"
			TXT_UPDATE_PRIVACY = "Mettre à jour le profil de confidentialité"
			TXT_UPDATE_PUBLIC = "Mettre à jour le statut public"
			TXT_USED_VALUE = ", utilisé "
			TXT_VIEW_DATA = "Visualiser les données"
			TXT_VIEW_IMPORT_DATA = "Visualiser les données d'importation"
			TXT_YOU_MAY_SELECT_OWNERS = "Vous pouvez limiter l'importation aux dossiers appartenant à un ou plusieurs propriétaires en sélectionnant dans la liste ci-dessous."
	End Select
End Sub

Call setTxtImport()
%>
