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
Dim TXT_CREATE_EDIT_SEARCH_TIPS, _
	TXT_DELETE_SEARCH_TIPS, _
	TXT_EDIT_SEARCH_TIPS, _
	TXT_ERR_SEARCH_TIPS_LANGUAGE, _
	TXT_ERR_SEARCH_TIPS_TEXT, _
	TXT_MANAGE_SEARCH_TIPS, _
	TXT_NO_SEARCH_TIPS, _
	TXT_PAGE_TEXT, _
	TXT_PAGE_TITLE, _
	TXT_RETURN_TO_SEARCH_TIPS_SETUP, _
	TXT_UPDATE_SEARCH_TIPS_FAILED, _
	TXT_VIEW_SEARCH_TIPS

Sub setTxtSearchTips()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_CREATE_EDIT_SEARCH_TIPS = "Create / Edit Search Tips"
			TXT_DELETE_SEARCH_TIPS = "Delete Search Tips Page"
			TXT_EDIT_SEARCH_TIPS = "Edit the text of the Search Tips page"
			TXT_ERR_SEARCH_TIPS_LANGUAGE = "You must select a valid language for the <em>Search Tips</em> page."
			TXT_ERR_SEARCH_TIPS_TEXT = "<em>Search Tips</em> page text must not exceed 20,000 characters."
			TXT_MANAGE_SEARCH_TIPS = "Manage Search Tips"
			TXT_NO_SEARCH_TIPS = "Sorry...There are currently no search tips available"
			TXT_PAGE_TEXT = "Page Text"
			TXT_PAGE_TITLE = "Page Title"
			TXT_RETURN_TO_SEARCH_TIPS_SETUP = "Return to Search Tips Setup"
			TXT_UPDATE_SEARCH_TIPS_FAILED = "Update Search Tips Failed"
			TXT_VIEW_SEARCH_TIPS = "View / Edit Search Tips"
		Case CULTURE_FRENCH_CANADIAN
			TXT_CREATE_EDIT_SEARCH_TIPS = "Créer / Modifier les conseils de recherche"
			TXT_DELETE_SEARCH_TIPS = "Supprimer la page de conseils de recherche"
			TXT_EDIT_SEARCH_TIPS = "Modifier le texte de la page de conseils de recherche"
			TXT_ERR_SEARCH_TIPS_LANGUAGE = "Vous devez sélectionner une langue valide pour la page de <em>Conseils de recherche</em>."
			TXT_ERR_SEARCH_TIPS_TEXT = "Le texte de la page de <em>Conseils de recherche</em> ne doit pas dépasser 20 000 caractères."
			TXT_MANAGE_SEARCH_TIPS = "Gérer les conseils de recherche"
			TXT_NO_SEARCH_TIPS = "Désolé. Les conseils de recherche ne sont pas disponibles pour le moment."
			TXT_PAGE_TEXT = "Texte de la page"
			TXT_PAGE_TITLE = "Titre de la page"
			TXT_RETURN_TO_SEARCH_TIPS_SETUP = "Retourner à la configuration des conseils de recherche"
			TXT_UPDATE_SEARCH_TIPS_FAILED = "La mise à jour des conseils de recherche a échoué."
			TXT_VIEW_SEARCH_TIPS = "Voir / Modifier les conseils de recherche"
	End Select
End Sub

Call setTxtSearchTips()
Call addTextFile("setTxtSearchTips")
%>
