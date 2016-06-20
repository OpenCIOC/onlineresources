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
Dim TXT_ADD_SEARCH, _
	TXT_ARE_YOU_SURE_DELETE_SEARCH, _
	TXT_CHOOSE_SEARCH, _
	TXT_CONFIRM_DELETE_SEARCH, _
	TXT_EDIT_SEARCH, _
	TXT_ERR_WHERE_CLAUSE_LENGTH, _
	TXT_EXECUTE_OR_EDIT_SEARCH, _
	TXT_EXECUTE_SEARCH, _
	TXT_INCLUDE_DELETED, _
	TXT_INST_SEARCH_NAME, _
	TXT_INST_SEARCH_NOTES, _
	TXT_INST_SHARE, _
	TXT_INST_WHERE_CLAUSE_1, _
	TXT_INST_WHERE_CLAUSE_2, _
	TXT_MANAGE_SAVED_SEARCHES, _
	TXT_MAX_SEARCHES, _
	TXT_NO_SAVED_SEARCHES, _
	TXT_NO_SHARED_SEARCHES, _
	TXT_OWNER, _
	TXT_RETURN_SEARCHES, _
	TXT_SHARED_SEARCHES, _
	TXT_UPDATE_REJECTED, _
	TXT_UPDATE_SEARCH_FAILED, _
	TXT_UPGRADE_WARNING, _
	TXT_USE_FORM_EDIT_SEARCH, _
	TXT_WHERE_CLAUSE

Sub setTxtSavedSearch()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_SEARCH = "Add Saved Search"
			TXT_ARE_YOU_SURE_DELETE_SEARCH = "Are you sure you want to permanently delete this search?" & _
				"<br>Use your back button to return to the form if you do not want to delete."
			TXT_CHOOSE_SEARCH = "Choose a Saved Search from the list below."
			TXT_CONFIRM_DELETE_SEARCH = "Confirm Delete Saved Search"
			TXT_EDIT_SEARCH = "Edit Saved Search" & TXT_COLON
			TXT_ERR_WHERE_CLAUSE_LENGTH = "The WHERE clause cannot be longer than 30000 characters"
			TXT_EXECUTE_OR_EDIT_SEARCH = "Execute or Edit Your Saved Searches"
			TXT_EXECUTE_SEARCH = "Execute Saved Search Now"
			TXT_INCLUDE_DELETED = "Include Deleted Records"
			TXT_INST_SEARCH_NAME = "Friendly name identifying this Search. " & _
				"Names should be kept short to prevent the drop-down list of searches from becoming too wide and must be unique."
			TXT_INST_SEARCH_NOTES = "If needed, enter a description of the search to help you or others remember what it is to be used for."
			TXT_INST_SHARE = "Share this Search with other users" & TXT_COLON
			TXT_INST_WHERE_CLAUSE_1 = "The WHERE clause in the SQL statement used to display the records."
			TXT_INST_WHERE_CLAUSE_2 = "Note: Results are always restricted to the records available in the current View."
			TXT_MANAGE_SAVED_SEARCHES = "Manage Saved Searches"
			TXT_MAX_SEARCHES = "You are allowed to create [MAX] saved searches."
			TXT_NO_SAVED_SEARCHES = "You have not saved any Searches"
			TXT_NO_SHARED_SEARCHES = "There are no shared searches"
			TXT_OWNER = "Owner"
			TXT_RETURN_SEARCHES = "Return to Saved Searches"
			TXT_SHARED_SEARCHES = "Shared Searches"
			TXT_UPDATE_REJECTED = "The update was rejected for security reasons; the information sent did not appear to come from the correct page."
			TXT_UPDATE_SEARCH_FAILED = "Update Saved Search Failed"
			TXT_UPGRADE_WARNING = "Note: you may have to recreate some of your searches after a database upgrade."
			TXT_USE_FORM_EDIT_SEARCH = "Use this form to edit a Saved Search"
			TXT_WHERE_CLAUSE = "Where Clause"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_SEARCH = "Ajouter la recherche sauvegardée"
			TXT_ARE_YOU_SURE_DELETE_SEARCH = "Êtes-vous sûr de vouloir supprimer définitivement cette recherche ?" & _
				"<br>Utiliser le bouton Retour pour revenir au formulaire si vous ne voulez pas le supprimer."
			TXT_CHOOSE_SEARCH = "Sélectionnez une recherche sauvegardée dans la liste ci-dessous."
			TXT_CONFIRM_DELETE_SEARCH = "Confirmer la suppression de la recherche sauvegardée"
			TXT_EDIT_SEARCH = "Modifier la recherche sauvegardée" & TXT_COLON
			TXT_ERR_WHERE_CLAUSE_LENGTH = "La clause WHERE ne peut pas dépasser 30 000 caractères"
			TXT_EXECUTE_OR_EDIT_SEARCH = "Lancer ou Modifier vos recherches sauvegardées"
			TXT_EXECUTE_SEARCH = "Lancer la recherche sauvegardée maintenant"
			TXT_INCLUDE_DELETED = "Inclure les dossiers supprimés"
			TXT_INST_SEARCH_NAME = "Nom convivial pour identifier cette recherche.  " & _
				"Les noms devraient être courts afin d'éviter que la liste des recherches ne soit trop large et doivent être uniques."
			TXT_INST_SHARE = "Partager cette recherche avec les autres utilisateurs" & TXT_COLON
			TXT_INST_SEARCH_NOTES = "Si besoin, saisir une description de la recherche pour vous aider à vous rappeler son intérêt."
			TXT_INST_WHERE_CLAUSE_1 = "La clause WHERE dans la déclaration SQL qui est utilisée pour afficher les dossiers."
			TXT_INST_WHERE_CLAUSE_2 = "Remarque : les résultats sont toujours restreints aux dossiers disponibles dans la vue courante."
			TXT_MANAGE_SAVED_SEARCHES = "Gestion des recherches sauvegardées"
			TXT_MAX_SEARCHES = "Vous êtes autorisé à créer [MAX] recherches sauvegardées."
			TXT_NO_SAVED_SEARCHES = "Il n'y a pas de recherche sauvegardée"
			TXT_NO_SHARED_SEARCHES = "Il n'y a pas de recherche partagée"
			TXT_OWNER = "Propriétaire"
			TXT_RETURN_SEARCHES = "Retourner aux recherches sauvegardées"
			TXT_SHARED_SEARCHES = "Recherches partagées"
			TXT_UPDATE_REJECTED = "La mise à jour a été rejetée pour des raisons de sécurité ; les renseignements envoyés ne semblaient pas provenir de la page approuvée."
			TXT_UPDATE_SEARCH_FAILED = "La mise à jour de la recherche sauvegardée a échoué"
			TXT_UPGRADE_WARNING = "Remarque : vous pourriez avoir à recréer vos recherches après une mise à jour de la base de données."
			TXT_USE_FORM_EDIT_SEARCH = "Utilisez ce formulaire pour modifier une recherche sauvegardée"
			TXT_WHERE_CLAUSE = "Clause Where"
	End Select
End Sub

Call setTxtSavedSearch()
%>
