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
Dim TXT_ERROR, _
	TXT_INVALID_CODE, _
	TXT_INVALID_ID, _
	TXT_INVALID_RSN, _
	TXT_INVALID_LANGUAGE, _
	TXT_INVALID_OPID, _
	TXT_NO_ACTION, _
	TXT_NO_NAME_PROVIDED, _
	TXT_NO_RECORD_CHOSEN, _
	TXT_NO_RECORD_EXISTS_ID, _
	TXT_NO_RECORD_EXISTS_RSN, _
	TXT_NO_RECORD_EXISTS_VNUM, _
	TXT_SERVICE_UNAVAILABLE_TITLE, _
	TXT_SERVICE_UNAVAILABLE_BODY, _
	TXT_SRCH_ERROR, _
	TXT_UNKNOWN_ERROR_OCCURED, _
	TXT_USE_BACK_BUTTON, _
	TXT_USING_GOOGLE_SEARCH, _
	TXT_VALIDATION_ERRORS_MESSAGE, _
	TXT_VALIDATION_ERRORS_TITLE, _
	TXT_WARNING

Sub setTxtError()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ERROR = "Erreur : "
			TXT_INVALID_CODE = TXT_ERROR & "Le code suivant est invalide" & TXT_COLON
			TXT_INVALID_ID = TXT_ERROR & "L'identifiant suivant est invalide" & TXT_COLON
			TXT_INVALID_RSN = TXT_ERROR & "Le numéro RSN suivant est invalide" & TXT_COLON
			TXT_INVALID_LANGUAGE = TXT_ERROR & "La langue suivante est invalide" & TXT_COLON
			TXT_INVALID_OPID = TXT_ERROR & "L'identifiant d'occasion de bénévolat suivant est invalide" & TXT_COLON
			TXT_NO_ACTION = TXT_ERROR & "Impossible d'établir le type d'action"
			TXT_NO_NAME_PROVIDED = "Aucun nom fourni"
			TXT_NO_RECORD_CHOSEN = TXT_ERROR & "Aucun dossier n'a été sélectionné"
			TXT_NO_RECORD_EXISTS_ID = TXT_ERROR & "Il n'existe pas de dossier avec l'identifiant" & TXT_COLON
			TXT_NO_RECORD_EXISTS_RSN = TXT_ERROR & "Il n'existe pas de dossier avec le numéro RSN" & TXT_COLON
			TXT_NO_RECORD_EXISTS_VNUM = TXT_ERROR & "Il n'existe pas de dossier avec l'identifiant d'occasion de bénévolat" & TXT_COLON
			TXT_SERVICE_UNAVAILABLE_TITLE = "Le système est temporairement indisponible"
			TXT_SERVICE_UNAVAILABLE_BODY = "La base de données est temporairement indisponible. Veuillez réessayer plus tard."
			TXT_SRCH_ERROR = "Une erreur s'est produite pendant la recherche" & TXT_COLON
			TXT_UNKNOWN_ERROR_OCCURED = "Une erreur d'origine inconnue s'est produite"
			TXT_USE_BACK_BUTTON = "Veuillez utiliser le bouton Retour pour revenir au formulaire."
			TXT_USING_GOOGLE_SEARCH = "Utiliser la recherche Google quand CIOC est hors ligne"
			TXT_VALIDATION_ERRORS_MESSAGE = "Ce dossier contient des erreurs de validation."
			TXT_VALIDATION_ERRORS_TITLE = "Erreurs de validation"
			TXT_WARNING = "Attention : "
		Case Else
			TXT_ERROR = "Error: "
			TXT_INVALID_CODE = TXT_ERROR & "The following is an invalid Code" & TXT_COLON
			TXT_INVALID_ID = TXT_ERROR & "The following is an invalid ID" & TXT_COLON
			TXT_INVALID_RSN = TXT_ERROR & "The following is an invalid RSN" & TXT_COLON
			TXT_INVALID_LANGUAGE = TXT_ERROR & "The following is an invalid language" & TXT_COLON
			TXT_INVALID_OPID = TXT_ERROR & "The following is an invalid Opportunity ID" & TXT_COLON
			TXT_NO_ACTION = TXT_ERROR & "Unable to determine the type of action"
			TXT_NO_NAME_PROVIDED = "No Name Provided"
			TXT_NO_RECORD_CHOSEN = TXT_ERROR & "No record was chosen"
			TXT_NO_RECORD_EXISTS_ID = TXT_ERROR & "No record exists with the ID" & TXT_COLON
			TXT_NO_RECORD_EXISTS_RSN = TXT_ERROR & "No record exists with the RSN" & TXT_COLON
			TXT_NO_RECORD_EXISTS_VNUM = TXT_ERROR & "No record exists with the Opportunity ID" & TXT_COLON
			TXT_SERVICE_UNAVAILABLE_TITLE = "System temporarily unavailable"
			TXT_SERVICE_UNAVAILABLE_BODY = "The database is temporarily unavailable. Please check back later."
			TXT_SRCH_ERROR = "An Error occurred during the search" & TXT_COLON
			TXT_UNKNOWN_ERROR_OCCURED = "An unknown error occurred"
			TXT_USE_BACK_BUTTON = "Please use your back button to return to the form."
			TXT_USING_GOOGLE_SEARCH = "Using Google to search when CIOC is offline"
			TXT_VALIDATION_ERRORS_MESSAGE = "This record contains validation errors."
			TXT_VALIDATION_ERRORS_TITLE = "Validation Errors"
			TXT_WARNING = "Warning: "
	End Select
End Sub

Call setTxtError()
Call addTextFile("setTxtError")
%>
