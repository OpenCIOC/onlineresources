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
Dim TXT_ACCESSIBILITY_NOTES, _
	TXT_ALREADY_EXISTS_IN_RECORD, _
	TXT_AREAS_SERVED_NOTES, _
	TXT_COMMUNITY_REQUIRED, _
	TXT_COMMUNITY_SET_REQUIRED, _
	TXT_DISTRIBUTION_ERROR, _
	TXT_ELIGIBILITY_NOTES, _
	TXT_FEE_NOTES, _
	TXT_FUNDING_NOTES, _
	TXT_INVALID_DISTRIBUTION, _
	TXT_IS_DEFAULT_CHECKLIST, _
	TXT_LANGUAGE_NOTES, _
	TXT_LOCATED_IN_ERROR, _
	TXT_LOCATED_IN_VALUE, _
	TXT_NOT_VALID_COMMUNITY, _
	TXT_NOT_VALID_LANGUAGE, _
	TXT_NUMBER_NEEDED_NOTES, _
	TXT_NUMBER_OF_OPPORTUNITIES, _
	TXT_ORG_RECORD_NUMBER_BLANK, _
	TXT_ORG_RECORD_NUMBER_ERROR, _
	TXT_ORG_RECORD_NUMBER_INVALID, _
	TXT_ORG_RECORD_NUMBER_NOT_EXIST, _
	TXT_POSITION_TITLE_REQUIRED, _
	TXT_RECORD_NUMBER_BLANK, _
	TXT_RECORD_NUMBER_ERROR, _
	TXT_RECORD_NUMBER_INVALID, _
	TXT_RECORD_NUMBER_USED, _
	TXT_PARENT_RECORD_NUMBER_INVALID, _
	TXT_RECORD_WAS_REVIEWED, _
	TXT_SCHEDULE_NOTES, _
	TXT_SCHOOL_ESCORT_NOTES, _
	TXT_SCHOOLS_IN_AREA_NOTES, _
	TXT_SOURCE_EMAIL, _
	TXT_SOURCE_POSTAL_CODE, _
	TXT_SOURCE_PUBLICATION_DATE, _
	TXT_START_DATE_FIRST, _
	TXT_START_DATE_LAST, _
	TXT_SUGGESTIONS_REVIEWED, _
	TXT_TYPE_OF_CARE_NOTES, _
	TXT_UPDATE_REJECTED, _
	TXT_VACANCY_INFO_CAPACITY, _
	TXT_VACANCY_INFO_MODIFIED_DATE, _
	TXT_VACANCY_INFO_NOTES, _
	TXT_VACANCY_INFO_UNIT_TYPE, _
	TXT_VACANCY_INFO_UNIT_TYPE_REQUIRED, _
	TXT_VACANCY_INFO_VACANCY_CHANGED, _
	TXT_VACANCY_INFO_WAIT_LIST_DATE, _
	TXT_VALUE_FOR_NEW_COMMUNITY, _
	TXT_VALUE_FOR_NEW_LANGUAGE, _
	TXT_YOU_SUBMITTED_FEEDBACK_1, _
	TXT_YOU_SUBMITTED_FEEDBACK_2

Sub setTxtEntryForm2()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ACCESSIBILITY_NOTES = "Accessibility Notes"
			TXT_ALREADY_EXISTS_IN_RECORD = " already exists in the record. You should change the existing notes if necessary rather than adding it again."
			TXT_AREAS_SERVED_NOTES = "Areas Served Notes"
			TXT_COMMUNITY_REQUIRED = "You must select at least one Community of Need"
			TXT_COMMUNITY_SET_REQUIRED = "You must assign this record to at least one Community Set"
			TXT_DISTRIBUTION_ERROR = "An unknown error occurred processing new Distribution codes."
			TXT_ELIGIBILITY_NOTES = "Eligibility Notes"
			TXT_FEE_NOTES = "Fee Notes"
			TXT_FUNDING_NOTES = "Funding Notes"
			TXT_INVALID_DISTRIBUTION = "The following are invalid Distribution codes" & TXT_COLON
			TXT_IS_DEFAULT_CHECKLIST = " cannot be selected as a &quot;new&quot; value because it already occurs in the default list."
			TXT_LANGUAGE_NOTES = "Language Notes"
			TXT_LOCATED_IN_ERROR = "An unknown error occurred processing Located In Community."
			TXT_LOCATED_IN_VALUE = "The Located In Community value "
			TXT_NOT_VALID_COMMUNITY = " is not a valid community name."
			TXT_NOT_VALID_LANGUAGE = " is not a valid language name."
			TXT_NUMBER_NEEDED_NOTES = "Number Needed Notes"
			TXT_NUMBER_OF_OPPORTUNITIES = "Number of Opportunities"
			TXT_ORG_RECORD_NUMBER_BLANK = "You must specify an Organization Record #"
			TXT_ORG_RECORD_NUMBER_ERROR = "An unknown error occurred checking Organization Record #."
			TXT_ORG_RECORD_NUMBER_INVALID = "is an invalid Organization Record #"
			TXT_ORG_RECORD_NUMBER_NOT_EXIST = "The Organization Record # [NUM] does not exist."
			TXT_POSITION_TITLE_REQUIRED = "You must specify a Position Title"
			TXT_RECORD_NUMBER_BLANK = "Record Number cannot be blank."
			TXT_RECORD_NUMBER_ERROR = "An unknown error occurred checking the Record Number."
			TXT_RECORD_NUMBER_INVALID = "Record Number is not in the correct format (e.g. ACT0001)."
			TXT_RECORD_NUMBER_USED = "The Record Number is already in use" & TXT_COLON
			TXT_PARENT_RECORD_NUMBER_INVALID = "The Parent Agency Record Number is not a Valid Record Number"
			TXT_RECORD_WAS_REVIEWED = "The record has been reviewed."
			TXT_SCHEDULE_NOTES = "Schedule Notes"
			TXT_SCHOOL_ESCORT_NOTES = "School Escort Notes"
			TXT_SCHOOLS_IN_AREA_NOTES = "Schools in Area Notes"
			TXT_SOURCE_EMAIL = "Source Email"
			TXT_SOURCE_POSTAL_CODE = "Source Postal Code"
			TXT_SOURCE_PUBLICATION_DATE = "Source Publication Date"
			TXT_START_DATE_FIRST = "Start Date First"
			TXT_START_DATE_LAST = "Start Date Last"
			TXT_SUGGESTIONS_REVIEWED = "Your suggestions have been reviewed"
			TXT_TYPE_OF_CARE_NOTES = "Type of Care Notes"
			TXT_UPDATE_REJECTED = "The update was rejected for security reasons; the information sent did not appear to come from the correct page."
			TXT_VACANCY_INFO_CAPACITY = "Availability Info Capacity"
			TXT_VACANCY_INFO_MODIFIED_DATE = "Modified Date"
			TXT_VACANCY_INFO_NOTES = "Availability Info Notes"
			TXT_VACANCY_INFO_UNIT_TYPE = "Unit Type"
			TXT_VACANCY_INFO_UNIT_TYPE_REQUIRED = "Unit Type is a required field."
			TXT_VACANCY_INFO_VACANCY_CHANGED = "Vacancy information was changed while you were editing this record. Please review the changes below to determine if corrections will be required to the vacancy value for this record to accommodate these changes."
			TXT_VACANCY_INFO_WAIT_LIST_DATE = "Wait List Date"
			TXT_VALUE_FOR_NEW_COMMUNITY = "The value given for new Community #"
			TXT_VALUE_FOR_NEW_LANGUAGE = "The value given for new Language #"
			TXT_YOU_SUBMITTED_FEEDBACK_1 = "You submitted feedback suggesting that the entry for "
			TXT_YOU_SUBMITTED_FEEDBACK_2 = " be updated in "
		Case CULTURE_FRENCH_CANADIAN
			TXT_ACCESSIBILITY_NOTES = "Notes sur l'accessibilité"
			TXT_ALREADY_EXISTS_IN_RECORD = " existe déjà dans le dossier. Il est conseillé de modifier les notes existantes si nécessaire, plutôt que les ajouter de nouveau."
			TXT_AREAS_SERVED_NOTES = "Notes sur les régions desservies"
			TXT_COMMUNITY_REQUIRED = "Vous devez sélectionner au moins une communauté ayant des besoins particuliers"
			TXT_COMMUNITY_SET_REQUIRED = "Vous devez affecter ce dossier à un ensemble de communautés au minimum"
			TXT_DISTRIBUTION_ERROR = "Une erreur d'origine inconnue s'est produite lors du traitement des codes de distribution."
			TXT_ELIGIBILITY_NOTES = "Notes sur l'admissibilité"
			TXT_FEE_NOTES = "Notes sur les honoraires"
			TXT_FUNDING_NOTES = "Notes sur le financement"
			TXT_INVALID_DISTRIBUTION = "Les codes de distribution suivants ne sont pas valides" & TXT_COLON
			TXT_IS_DEFAULT_CHECKLIST = " ne peut être sélectionné comme &quot;nouvelle&quot; valeur car elle apparaît déjà dans la liste par défaut."
			TXT_LANGUAGE_NOTES = "Notes sur les langues"
			TXT_LOCATED_IN_ERROR = "Une erreur d'origine inconnue s'est produite lors du traitement de Situé dans la communauté."
			TXT_LOCATED_IN_VALUE = "La valeur de Situé dans la communauté "
			TXT_NOT_VALID_COMMUNITY = " n'est pas un nom de communauté valide."
			TXT_NOT_VALID_LANGUAGE = " n'est pas une langue valide."
			TXT_NUMBER_NEEDED_NOTES = "Notes sur le nombre requis"
			TXT_NUMBER_OF_OPPORTUNITIES = "Nombre d'occasions"
			TXT_ORG_RECORD_NUMBER_BLANK = "Vous devez préciser un numéro de dossier d'organisme"
			TXT_ORG_RECORD_NUMBER_ERROR = "Une erreur inconnue est survenue lors de la vérification du numéro de dossier d'organisme."
			TXT_ORG_RECORD_NUMBER_INVALID = "est un numéro d'organisme invalide"
			TXT_ORG_RECORD_NUMBER_NOT_EXIST = "Le numéro d'organisme [NUM] n'existe pas."
			TXT_POSITION_TITLE_REQUIRED = "Vous devez préciser un titre de poste"
			TXT_RECORD_NUMBER_BLANK = "Le numéro du dossier ne peut être vide."
			TXT_RECORD_NUMBER_ERROR = "Une erreur d'origine inconnue s'est produite lors du traitement du numéro de dossier."
			TXT_RECORD_NUMBER_INVALID = "Le numéro de dossier n'est pas dans un format correct (p. ex. ABC1234)."
			TXT_RECORD_NUMBER_USED = "Le numéro de dossier est déjà utilisé" & TXT_COLON
			TXT_PARENT_RECORD_NUMBER_INVALID = "Le numéro de dossier de l'agence parent n'est pas un numéro de dossier valide"
			TXT_RECORD_WAS_REVIEWED = "Le dossier a été révisé."
			TXT_SCHEDULE_NOTES = "Notes sur les horaires"
			TXT_SCHOOL_ESCORT_NOTES = "Notes sur le Raccompagnement scolaire"
			TXT_SCHOOLS_IN_AREA_NOTES = "Notes sur les écoles dans la région"
			TXT_SOURCE_EMAIL = "Courriel de la source"
			TXT_SOURCE_POSTAL_CODE = "Code postal de la source"
			TXT_SOURCE_PUBLICATION_DATE = "Date de la publication source"
			TXT_START_DATE_FIRST = "Première date de départ"
			TXT_START_DATE_LAST = "Dernière date de départ"
			TXT_SUGGESTIONS_REVIEWED = "Vos suggestions ont été révisées"
			TXT_TYPE_OF_CARE_NOTES = "Notes sur le type de garde"
			TXT_UPDATE_REJECTED = "La mise à jour a été rejetée pour des raisons de sécurité ; les renseignements envoyés ne semblaient pas provenir de la page approuvée."
			TXT_VACANCY_INFO_CAPACITY = "La capacité dans les renseignements sur les places libres"
			TXT_VACANCY_INFO_MODIFIED_DATE = "Date de modification"
			TXT_VACANCY_INFO_NOTES = "Notes sur la disponibilité"
			TXT_VACANCY_INFO_UNIT_TYPE = "Type d'unité"
			TXT_VACANCY_INFO_UNIT_TYPE_REQUIRED = "Le type d'unité est un champ obligatoire."
			TXT_VACANCY_INFO_VACANCY_CHANGED = "TRANSLATE_FR -- Vacancy information was changed while you were editing this record. Please review the changes below to determine if corrections will be required to the vacancy value for this record to accommodate these changes."
			TXT_VACANCY_INFO_WAIT_LIST_DATE = "Date de la liste d'attente"
			TXT_VALUE_FOR_NEW_COMMUNITY = "La valeur fournie pour la nouvelle communauté no. "
			TXT_VALUE_FOR_NEW_LANGUAGE = "La valeur fournie pour la nouvelle langue no. "
			TXT_YOU_SUBMITTED_FEEDBACK_1 = "Vous avez soumis une rétroaction suggérant que l'entrée pour "
			TXT_YOU_SUBMITTED_FEEDBACK_2 = " soit mise à jour dans la "
	End Select
End Sub

Call setTxtEntryForm2()
Call addTextFile("setTxtEntryForm2")
%>
