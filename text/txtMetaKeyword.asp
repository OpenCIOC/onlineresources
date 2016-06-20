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
Dim	TXT_ADD_KEYWORD, _
	TXT_CHOOSE_KEYWORD, _
	TXT_CREATE_EDIT_KEYWORD, _
	TXT_EDIT_KEYWORD, _
	TXT_INVALID_TAXONOMY_CODE, _
	TXT_MANAGE_META_KEYWORDS, _
	TXT_RETURN_TO_KEYWORD_SETUP, _
	TXT_UPDATE_KEYWORD_FAILED, _
	TXT_VIEW_EDIT_KEYWORD

Sub setTxtKeywordSetup()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_KEYWORD = "Add META Tag Keyword"
			TXT_CHOOSE_KEYWORD = "Choose a Keyword from the list below or add a new Keyword."
			TXT_CREATE_EDIT_KEYWORD = "Create / Edit Meta Tag Keyword"
			TXT_EDIT_KEYWORD = "Edit Meta Tag Keyword" & TXT_COLON
			TXT_INVALID_TAXONOMY_CODE = "The following is an invalid Taxonomy Code" & TXT_COLON
			TXT_MANAGE_META_KEYWORDS = "Manage Meta Tag Keywords"
			TXT_RETURN_TO_KEYWORD_SETUP = "Return to Meta Tag Keyword Setup"
			TXT_UPDATE_KEYWORD_FAILED = "Update Keyword Information Failed"
			TXT_VIEW_EDIT_KEYWORD = "View / Edit Keyword"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_KEYWORD = "Ajouter un mot-clé métabalise"
			TXT_CHOOSE_KEYWORD = "Sélectionnez un mot-clé dans la liste ci-dessous ou ajouter un nouveau mot-clé."
			TXT_CREATE_EDIT_KEYWORD = "Créer / Modifier un mot-clé métabalise"
			TXT_EDIT_KEYWORD = "Modifier un mot-clé métabalise" & TXT_COLON
			TXT_INVALID_TAXONOMY_CODE = "Le code taxonomique suivant est invalide" & TXT_COLON
			TXT_MANAGE_META_KEYWORDS = "Gestion des Mots-clés métabalise"
			TXT_RETURN_TO_KEYWORD_SETUP = "Retourner à la gestion des mots-clés métabalise"
			TXT_UPDATE_KEYWORD_FAILED = "La mise à jour des renseignements sur le mot-clé a échoué"
			TXT_VIEW_EDIT_KEYWORD = "Voir / Modifier le mot-clé"
	End Select
End Sub

Call setTxtKeywordSetup()
%>
