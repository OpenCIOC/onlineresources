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
Dim TXT_ADD_TERMS, _
	TXT_COULD_NOT_ADD_CODES, _
	TXT_EDIT_SERVICE_CATEGORIES_FOR, _
	TXT_INVALID_CODE_LIST, _
	TXT_SHOW_FIELD, _
	TXT_TERMS_FOR_THIS_RECORD, _
	TXT_UNKNOWN_ERRORS_OCCURED, _
	TXT_UPDATE_REJECTED, _
	TXT_UPDATE_TAXONOMY_TITLE

Sub setTxtTaxUpdate()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_TERMS = "Add Selected Term(s)"
			TXT_COULD_NOT_ADD_CODES = "Could not add the Code(s)" & TXT_COLON
			TXT_EDIT_SERVICE_CATEGORIES_FOR = "Edit Service Categories For" & TXT_COLON
			TXT_INVALID_CODE_LIST = "The given list of Taxonomy Codes is not valid"
			TXT_SHOW_FIELD = "Show Field" & TXT_COLON
			TXT_TERMS_FOR_THIS_RECORD = "Terms for this Record"
			TXT_UNKNOWN_ERRORS_OCCURED = "Unknown errors occurred while processing this update. " & _
				" The record may have only been partially updated. " & _
				" The specific error(s) were" & TXT_COLON
			TXT_UPDATE_REJECTED = "The update was rejected for security reasons; the information sent did not appear to come from the correct page."
			TXT_UPDATE_TAXONOMY_TITLE = "Update Service Categories"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_TERMS = "Ajouter le(s) terme(s) sélectionné(s)"
			TXT_COULD_NOT_ADD_CODES = "Le(s) code(s) suivant(s) n'a(ont) pu être ajouté(s) : " & TXT_COLON
			TXT_EDIT_SERVICE_CATEGORIES_FOR = "Modifier les catégories de service pour" & TXT_COLON
			TXT_INVALID_CODE_LIST = "La liste donnée de codes taxonomiques n'est pas valide"
			TXT_SHOW_FIELD = "Afficher le champ" & TXT_COLON
			TXT_TERMS_FOR_THIS_RECORD = "Termes pour ce dossier"
			TXT_UNKNOWN_ERRORS_OCCURED = "Des erreurs non identifiées sont survenues pendant la mise à jour. " & _
				" Il est possible que le dossier n'ait été mis à jour que partiellement. " & _
				" Les erreurs en question étaient" & TXT_COLON
			TXT_UPDATE_REJECTED = "La mise à jour a été refusée pour des raisons de sécurité; l'information soumise ne semblait pas provenir de la bonne page."
			TXT_UPDATE_TAXONOMY_TITLE = "Mettre à jour les catégories de services"
	End Select
End Sub

Call setTxtTaxUpdate()
%>
