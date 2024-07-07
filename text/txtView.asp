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
Dim TXT_ALL_TYPES, _
	TXT_CHOOSE_VIEW, _
	TXT_COMM_SUCCESSFULLY, _
	TXT_COMM_WAS_NOT, _
	TXT_CONFIRM_DELETE_FORM, _
	TXT_CREATE_NEW_FORM_FOR_TYPE, _
	TXT_DEFAULT_GROUP, _
	TXT_DETAIL_FIELD_GROUP, _
	TXT_DETAIL_FIELDS, _
	TXT_EDIT_FORM_FOR_TYPE, _
	TXT_EDIT_VIEW, _
	TXT_EDIT_VIEW_COMMS, _
	TXT_ERR_FIELD_TYPE, _
	TXT_FEEDBACK_FIELDS, _
	TXT_FIELD, _
	TXT_FIELD_LIST_NOT_UPDATED, _
	TXT_FIELD_LIST_UPDATED, _
	TXT_INST_COMMS, _
	TXT_INST_DETAIL_FIELDS, _
	TXT_MAIL_FORM_FIELDS, _
	TXT_MANAGE_FIELDS, _
	TXT_MANAGE_VIEWS, _
	TXT_NEW_COMMUNITY, _
	TXT_NO_DETAIL_FIELD_GROUPS, _
	TXT_REMOVE_GROUP, _
	TXT_SOME_FIELDS_UNAVAILABLE, _
	TXT_SPECIFY_VIEW_NAME, _
	TXT_UPDATE_FIELDS, _
	TXT_VIEW_ADDED, _
	TXT_VIEW_NOT_ADDED

Sub setTxtView()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ALL_TYPES = "All types (default form)"
			TXT_CHOOSE_VIEW = "Choose a View from the list below or add a new View."
			TXT_COMM_SUCCESSFULLY = "The search community was successfully "
			TXT_COMM_WAS_NOT = "The search community was not "
			TXT_CONFIRM_DELETE_FORM = "Confirm Delete Form for Record Type"
			TXT_CREATE_NEW_FORM_FOR_TYPE = "Create a new form for records of the type" & TXT_COLON
			TXT_DEFAULT_GROUP = "DEFAULT"
			TXT_DETAIL_FIELD_GROUP = "Field Group"
			TXT_DETAIL_FIELDS = "Details Fields"
			TXT_EDIT_FORM_FOR_TYPE = "Edit form fields for records of the type" & TXT_COLON
			TXT_EDIT_VIEW = "Edit View"
			TXT_EDIT_VIEW_COMMS = "Edit Search Communities for View"
			TXT_ERR_FIELD_TYPE = TXT_ERROR & "The field type to edit could not be determined."
			TXT_FEEDBACK_FIELDS = "Feedback Fields"
			TXT_FIELD = "Field"
			TXT_FIELD_LIST_NOT_UPDATED = "The field list was not updated" & TXT_COLON
			TXT_FIELD_LIST_UPDATED = "The field list was updated successfully"
			TXT_INST_COMMS = "Use the box below to add a new community." & _
				"<br>You can use the <a href=""javascript:openWin('" & makeLinkB(ps_strPathToStart & "comfind.asp") & "','cFind')"">Community Finder</a> to search for an appropriate value."
			TXT_INST_DETAIL_FIELDS = "Add a field by selecting a field group. Remove a field by making its field group blank."
			TXT_MAIL_FORM_FIELDS = "Mail Form Fields"
			TXT_MANAGE_FIELDS = "Manage Fields"
			TXT_MANAGE_VIEWS = "Manage Views"
			TXT_NEW_COMMUNITY = "New Community"
			TXT_NO_DETAIL_FIELD_GROUPS = "There are no Detail Field Groups available"
			TXT_REMOVE_GROUP = "Note that deleting a field group will remove all the fields in that group!"
			TXT_SOME_FIELDS_UNAVAILABLE = "Some fields may not be available to select if they are automatically added to the form/page"
			TXT_SPECIFY_VIEW_NAME = "You must specify a name for the new View"
			TXT_UPDATE_FIELDS = "Update Fields"
			TXT_VIEW_ADDED = "The View was successfully added"
			TXT_VIEW_NOT_ADDED = "The View was not added" & TXT_COLON
		Case CULTURE_FRENCH_CANADIAN
			TXT_ALL_TYPES = "Tous les types (formulaire par défaut)"
			TXT_CHOOSE_VIEW = "Sélectionner une vue dans la liste ci-dessous ou ajouter une nouvelle vue."
			TXT_COMM_SUCCESSFULLY = "La recherche par communauté a bien été "
			TXT_COMM_WAS_NOT = "La recherche par communauté n'a pas été "
			TXT_CONFIRM_DELETE_FORM = "Confirmer la suppression du formulaire pour le Type de dossier"
			TXT_CREATE_NEW_FORM_FOR_TYPE = "Créer un nouveau formulaire pour les dossiers du type" & TXT_COLON
			TXT_DEFAULT_GROUP = "DÉFAUT"
			TXT_DETAIL_FIELD_GROUP = "Groupe de champs"
			TXT_DETAIL_FIELDS = "Champs de renseignements"
			TXT_EDIT_FORM_FOR_TYPE = "Modifier les champs du formulaire pour les dossiers du type" & TXT_COLON
			TXT_EDIT_VIEW = "Modifier la vue"
			TXT_EDIT_VIEW_COMMS = "Modifier la vue de la recherche par communauté"
			TXT_ERR_FIELD_TYPE = TXT_ERROR & "Le type de champ à modifier n'a pu être déterminé."
			TXT_FEEDBACK_FIELDS = "Champs pour la rétroaction"
			TXT_FIELD = "Champ"
			TXT_FIELD_LIST_NOT_UPDATED = "La liste des champs n'a pas été mise à jour." & TXT_COLON
			TXT_FIELD_LIST_UPDATED = "La liste des champs a été mise à jour avec succès."
			TXT_INST_COMMS = "Utilisez la boîte ci-dessous pour ajouter une nouvelle communauté." & _
				"<br>Vous pouvez utiliser le <a href=""javascript:openWin('" & makeLinkB(ps_strPathToStart & "comfind.asp") & "','cFind')"">Localisateur de communautés</a> pour rechercher une valeur appropriée."
			TXT_INST_DETAIL_FIELDS = "Ajouter un champ en sélectionnant un groupe de champs. Retirer un champ en supprimant le contenu du groupe de champs."
			TXT_MAIL_FORM_FIELDS = "Champs du formulaire d'envoi par courrier"
			TXT_MANAGE_FIELDS = "Gérer les champs"
			TXT_MANAGE_VIEWS = "Gestion des vues"
			TXT_NEW_COMMUNITY = "Ajouter une nouvelle Communauté"
			TXT_NO_DETAIL_FIELD_GROUPS = "Il n'y a pas de groupe de champs de renseignements disponible."
			TXT_REMOVE_GROUP = "Attention : la suppression d'un groupe de champs éliminera tous les champs de ce groupe !"
			TXT_SOME_FIELDS_UNAVAILABLE = "Certains champs peuvent ne pas être disponibles s'ils sont automatiquement ajoutés à une page ou à un formulaire."
			TXT_SPECIFY_VIEW_NAME = "Vous devez attribuer un nom à la nouvelle vue."
			TXT_UPDATE_FIELDS = "Champs de mise à jour"
			TXT_VIEW_ADDED = "La vue a été ajoutée avec succès."
			TXT_VIEW_NOT_ADDED = "La vue n'a pas été ajoutée." & TXT_COLON
	End Select
End Sub

Call setTxtView()
%>
