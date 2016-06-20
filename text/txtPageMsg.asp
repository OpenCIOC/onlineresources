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
Dim	TXT_ADD_MESSAGE, _
	TXT_CHOOSE_MESSAGE, _
	TXT_CREATE_EDIT_PAGE_MESSAGE, _
	TXT_DELETE_MESSAGE, _
	TXT_EDIT_PAGE_MESSAGE, _
	TXT_ERR_MESSAGE_LANGUAGE, _
	TXT_ERR_PAGE_LIST, _
	TXT_ERR_PAGE_MESSAGE, _
	TXT_ERR_VIEW_LIST, _
	TXT_INST_LOGIN_ONLY, _
	TXT_INST_MESSAGE_TITLE, _
	TXT_INST_PAGE_MESSAGE, _
	TXT_INST_PAGES, _
	TXT_INST_PRINT_MODE, _
	TXT_INST_VIEW, _
	TXT_LOGIN_ONLY, _
	TXT_MANAGE_PAGE_MESSAGES, _
	TXT_MESSAGE_TITLE, _
	TXT_PAGE_MESSAGE, _
	TXT_RETURN_TO_MESSAGE_SETUP, _
	TXT_UPDATE_MESSAGE_FAILED, _
	TXT_USE_THIS_FORM, _
	TXT_VIEW_EDIT_MESSAGE, _
	TXT_PRINT_MODE

Sub setTxtPageMsg()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_MESSAGE = "Add New Page Message"
			TXT_CHOOSE_MESSAGE = "Choose a Message from the list below or add a new Message."
			TXT_CREATE_EDIT_PAGE_MESSAGE = "Create / Edit Page Message"
			TXT_DELETE_MESSAGE = "Delete Page Message"
			TXT_EDIT_PAGE_MESSAGE = "Edit Page Message" & TXT_COLON
			TXT_ERR_MESSAGE_LANGUAGE = "You must select a valid Language for the message."
			TXT_ERR_PAGE_LIST = "The list of Page names provided is not valid."
			TXT_ERR_PAGE_MESSAGE = "Page Message cannot exceed 4000 characters"
			TXT_ERR_VIEW_LIST = "The list of View Type IDs provided is not valid."
			TXT_INST_LOGIN_ONLY = "Visible to Logged-in Users only"
			TXT_INST_MESSAGE_TITLE = "Unique title to identify this message. Used only while managing page messages."
			TXT_INST_PAGE_MESSAGE = "This message will be printed at the top of the page before all other content. " & _
				"Keep the content brief. " & _
				"Use only when you feel a page needs to display some extra, prominent information."
			TXT_INST_PAGES = "Show the Message on the following Pages" & TXT_COLON
			TXT_INST_PRINT_MODE = "This message is visible when in Print Mode"
			TXT_INST_VIEW = "Select the View(s) in which you wish to display this message" & TXT_COLON
			TXT_LOGIN_ONLY = "Logged-in Users"
			TXT_MANAGE_PAGE_MESSAGES = "Manage Page Messages"
			TXT_MESSAGE_TITLE = "Message Title"
			TXT_PAGE_MESSAGE = "Page&nbsp;Message"
			TXT_RETURN_TO_MESSAGE_SETUP = "Return to Page Message Setup"
			TXT_UPDATE_MESSAGE_FAILED = "Update Page Message Failed"
			TXT_USE_THIS_FORM = "Use this form to edit a Page Message"
			TXT_VIEW_EDIT_MESSAGE = "View / Edit Message"
			TXT_PRINT_MODE = "Print Mode"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_MESSAGE = "Ajouter un nouveau message"
			TXT_CHOOSE_MESSAGE = "Choisir un message dans la liste ci-dessous ou ajouter un nouveau message."
			TXT_CREATE_EDIT_PAGE_MESSAGE = "Créer / modifier un message"
			TXT_DELETE_MESSAGE = "Supprimer le message"
			TXT_EDIT_PAGE_MESSAGE = "Modifier le message" & TXT_COLON
			TXT_ERR_MESSAGE_LANGUAGE = "Vous devez sélectionner une langue valide pour le message."
			TXT_ERR_PAGE_LIST = "La liste des noms de page n'est pas valide."
			TXT_ERR_PAGE_MESSAGE = "Le message de la page ne peut pas dépasser 4 000 caractères."
			TXT_ERR_VIEW_LIST = "La liste des numéros d'identifiant de type de vue n'est pas valide."
			TXT_INST_LOGIN_ONLY = "Visible pour les utilisateurs connectés seulement"
			TXT_INST_MESSAGE_TITLE = "Titre unique qui identifie le message. Utilisé uniquement pour la gestion des messages de page."
			TXT_INST_PAGE_MESSAGE = "Ce message sera affiché en haut de la page avant tout autre contenu. " & _
				"Soyez bref. " & _
				"Utiliser uniquement lorsque vous estimez que la page doit afficher bien en vue de l'information additionnelle."
			TXT_INST_PAGES = "Montrer le message sur les pages suivantes" & TXT_COLON
			TXT_INST_PRINT_MODE = "Ce message est visible en mode d'impression"
			TXT_INST_VIEW = "Sélectionner la/les vue(s) dans lesquelles vous souhaitez afficher le message" & TXT_COLON
			TXT_LOGIN_ONLY = "Les utilisateurs connectés"
			TXT_MANAGE_PAGE_MESSAGES = "Gérer les messages de page"
			TXT_MESSAGE_TITLE = "Titre du message"
			TXT_PAGE_MESSAGE = "Message de la page"
			TXT_RETURN_TO_MESSAGE_SETUP = "Retourner à la configuration des messages de page"
			TXT_UPDATE_MESSAGE_FAILED = "La mise à jour du message a échoué"
			TXT_USE_THIS_FORM = "Utilisez ce formulaire pour modifier le message"
			TXT_VIEW_EDIT_MESSAGE = "Visualiser / modifier le message"
			TXT_PRINT_MODE = "Mode d'impression"
	End Select
End Sub

Call setTxtPageMsg()
%>
