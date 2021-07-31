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
Dim TXT_ADD_PUB_CODE_FAILED, _
	TXT_CHOOSE_PUBLICATION, _
	TXT_CONVERT_LINE1_LINE2_ADDRESSES_FOR_COMPATIBILITY, _
	TXT_DB_NAME, _
	TXT_DB_URL, _
	TXT_DIST_LIST_NOT_UPDATED, _
	TXT_DIST_LIST_UPDATED, _
	TXT_EDIT_PROFILE, _
	TXT_FIELD_LIST_NOT_UPDATED, _
	TXT_FIELD_LIST_UPDATED, _
	TXT_INCLUDE_DATA, _
	TXT_INCLUDE_DESCRIPTION, _
	TXT_INCLUDE_DESCRIPTION_NO_HTML, _
	TXT_INCLUDE_HEADINGS, _
	TXT_INCLUDE_HEADINGS_NO_HTML, _
	TXT_INST_EXPORT_IN_LANGUAGES, _
	TXT_LINE1_LINE2_HANDLING, _
	TXT_MANAGE_DISTRIBUTIONS, _
	TXT_MANAGE_DISTS_TITLE, _
	TXT_MANAGE_FIELDS_TITLE, _
	TXT_MANAGE_PROFILES, _
	TXT_MANAGE_PUBLICATIONS, _
	TXT_MANAGE_PUBS_TITLE, _
	TXT_PRIVACY_PROFILE_EXPORT, _
	TXT_PRIVACY_PROFILE_SKIP, _
	TXT_RETURN_TO_PROFILES, _
	TXT_SOURCE_DATABASE_INFO, _
	TXT_SUBMIT_RECORD_CHANGES_TO, _
	TXT_UPDATE_PUB_CODE_FAILED

Sub setTxtExportProfile()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_PUB_CODE_FAILED = "L'ajout du code de publication a échoué."
			TXT_CHOOSE_PUBLICATION = "Veuillez sélectionner une publication dans la liste ci-dessous."
			TXT_CONVERT_LINE1_LINE2_ADDRESSES_FOR_COMPATIBILITY = "TRANSLATE_FR -- Convert Line 1/Line 2 addresses for compatibility"
			TXT_DB_NAME = "Nom de la base de données"
			TXT_DB_URL = "URL de la base de données"
			TXT_DIST_LIST_NOT_UPDATED = "La mise à jour de la liste des codes de distribution a échoué" & TXT_COLON
			TXT_DIST_LIST_UPDATED = "La liste des codes de distribution a été mise à jour avec succès."
			TXT_EDIT_PROFILE = "Modifier le profil d'exportation"
			TXT_FIELD_LIST_NOT_UPDATED = "La mise à jour de la liste des champs a échoué." & TXT_COLON
			TXT_FIELD_LIST_UPDATED = "La liste des champs a été mise à jour avec succès."
			TXT_INCLUDE_DATA = "Inclure les données"
			TXT_INCLUDE_DESCRIPTION = "Inclure<br>la description"
			TXT_INCLUDE_DESCRIPTION_NO_HTML = "Inclure la description"
			TXT_INCLUDE_HEADINGS = "Inclure<br>les en-têtes"
			TXT_INCLUDE_HEADINGS_NO_HTML = "Inclure les en-têtes"
			TXT_INST_EXPORT_IN_LANGUAGES = "Exporter les données dans les langues suivantes" & TXT_COLON
			TXT_LINE1_LINE2_HANDLING = "TRANSLATE_FR -- Line 1/Line 2 Address Handling"
			TXT_MANAGE_DISTRIBUTIONS = "Gérer les distributions"
			TXT_MANAGE_DISTS_TITLE = "Gérer les codes de distribution pour l'exportation"
			TXT_MANAGE_FIELDS_TITLE = "Gérer les champs d'exportation"
			TXT_MANAGE_PROFILES = "Gérer les profils d'exportation"
			TXT_MANAGE_PUBLICATIONS = "Gérer les publications"
			TXT_MANAGE_PUBS_TITLE = "Gérer les codes de publications pour l'exportation"
			TXT_PRIVACY_PROFILE_EXPORT = "Exporter les profils de confidentialité"
			TXT_PRIVACY_PROFILE_SKIP = "Ne pas exporter les champs confidentiels"
			TXT_RETURN_TO_PROFILES = "Retourner aux profils d'exportation"
			TXT_SOURCE_DATABASE_INFO = "Renseignements sur la base de données source"
			TXT_SUBMIT_RECORD_CHANGES_TO = "Envoyer les modifications aux dossier à"
			TXT_UPDATE_PUB_CODE_FAILED = "La mise à jour du code de publication pour l'exportation a échoué."
		Case Else
			TXT_ADD_PUB_CODE_FAILED = "Add Publication Code Failed"
			TXT_CHOOSE_PUBLICATION = "Choose a Publication from the list below"
			TXT_CONVERT_LINE1_LINE2_ADDRESSES_FOR_COMPATIBILITY = "Convert Line 1/Line 2 addresses for compatibility"
			TXT_DB_NAME = "Database Name"
			TXT_DB_URL = "Database URL"
			TXT_DIST_LIST_NOT_UPDATED = "The Distribution Code list was not updated" & TXT_COLON
			TXT_DIST_LIST_UPDATED = "The Distribution Code list was updated successfully"
			TXT_EDIT_PROFILE = "Edit Export Profile"
			TXT_FIELD_LIST_NOT_UPDATED = "The field list was not updated" & TXT_COLON
			TXT_FIELD_LIST_UPDATED = "The field list was updated successfully"
			TXT_INCLUDE_DATA = "Include Data"
			TXT_INCLUDE_DESCRIPTION = "Include<br>Description"
			TXT_INCLUDE_DESCRIPTION_NO_HTML = "Include Description"
			TXT_INCLUDE_HEADINGS = "Include<br>Headings"
			TXT_INCLUDE_HEADINGS_NO_HTML = "Include Headings"
			TXT_INST_EXPORT_IN_LANGUAGES = "Export data in the following languages" & TXT_COLON
			TXT_LINE1_LINE2_HANDLING = "Line 1/Line 2 Address Handling"
			TXT_MANAGE_DISTRIBUTIONS = "Manage Distributions"
			TXT_MANAGE_DISTS_TITLE = "Manage Export Distribution Codes"
			TXT_MANAGE_FIELDS_TITLE = "Manage Export Fields"
			TXT_MANAGE_PROFILES = "Manage Export Profiles"
			TXT_MANAGE_PUBLICATIONS = "Manage Publications"
			TXT_MANAGE_PUBS_TITLE = "Manage Export Publication Codes"
			TXT_PRIVACY_PROFILE_EXPORT = "Export Privacy Profiles"
			TXT_PRIVACY_PROFILE_SKIP = "Do not export private fields"
			TXT_RETURN_TO_PROFILES = "Return to Export Profiles"
			TXT_SOURCE_DATABASE_INFO = "Source Database Info"
			TXT_SUBMIT_RECORD_CHANGES_TO = "Submit Record Changes To"
			TXT_UPDATE_PUB_CODE_FAILED = "Update Export Publication Failed"
	End Select
End Sub

Call setTxtExportProfile()
%>

