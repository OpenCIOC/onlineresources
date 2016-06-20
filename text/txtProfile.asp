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
Dim	TXT_ADD_PROFILE, _
	TXT_CHOOSE_PROFILE, _
	TXT_CONFIRM_DELETE_PROFILE, _
	TXT_COPY_PROFILE, _
	TXT_CREATE_PROFILE, _
	TXT_IN_VIEWS, _
	TXT_INST_ADD_PROFILE, _
	TXT_INST_IN_VIEWS, _
	TXT_INST_PROFILE_NAME, _
	TXT_MANAGE_FIELDS, _
	TXT_RETURN_TO_PROFILE, _
	TXT_SPECIFY_PROFILE_NAME, _
	TXT_STATUS_DELETE, _
	TXT_STATUS_NO_DELETE, _
	TXT_STATUS_NO_USE, _
	TXT_STATUS_USE_1, _
	TXT_STATUS_USE_2, _
	TXT_UPDATE_PROFILE_FAILED, _
	TXT_VIEW_EDIT_PROFILE
	
Sub setTxtProfile()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_PROFILE = "Add Profile"
			TXT_CHOOSE_PROFILE = "Choose a Profile from the list below or add a new Profile"
			TXT_CONFIRM_DELETE_PROFILE = "Confirm Profile Deletion"
			TXT_COPY_PROFILE = "Copy Profile"
			TXT_CREATE_PROFILE = "Create Profile"
			TXT_IN_VIEWS = "In Views"
			TXT_INST_ADD_PROFILE = "The initial values for the new Profile will be based on the Profile you specify." & _
				"<br>If you do not specify a Profile to copy, the new profile will be empty." & _
				"<br>When you submit, you will be taken to a form to edit the new Profile." & _
				"<br>The name for the Profile must be unique."
			TXT_INST_IN_VIEWS = "Views this profile is available in" & TXT_COLON
			TXT_INST_PROFILE_NAME = "Unique name identifying this Profile"
			TXT_MANAGE_FIELDS = "Manage Fields"
			TXT_RETURN_TO_PROFILE = "Return to Profile" & TXT_COLON
			TXT_SPECIFY_PROFILE_NAME = "You must specify a name for the new Profile"
			TXT_STATUS_DELETE = "Because this Privacy Profile is not being used, you can delete it using the button at the bottom of the form."
			TXT_STATUS_NO_DELETE = "Because this Privacy Profile is being used, you cannot currently delete it."
			TXT_STATUS_NO_USE = "This Privacy Profile is <strong>not</strong> being used by any records."
			TXT_STATUS_USE_1 = "This Privacy Profile is <strong>being used</strong> by "
			TXT_STATUS_USE_2 = " record(s)."
			TXT_UPDATE_PROFILE_FAILED = "Update Profile Failed"
			TXT_VIEW_EDIT_PROFILE = "View / Edit Profile"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_PROFILE = "Ajouter un profil"
			TXT_CHOOSE_PROFILE = "Veuillez sélectionner un profil dans la liste ci-dessous ou ajoutez un nouveau profil."
			TXT_CONFIRM_DELETE_PROFILE = "Confirmer la suppression du profil"
			TXT_COPY_PROFILE = "Copier le profil"
			TXT_CREATE_PROFILE = "Créer un profil"
			TXT_IN_VIEWS = "Dans les vues"
			TXT_INST_ADD_PROFILE = "Les valeurs initiales du nouveau profil seront basées sur le profil que vous spécifiez ci-dessous." & _
				"<br>Si vous ne spécifiez pas de profil à copier, le nouveau profil sera vide." & _
				"<br>Lors de la soumission, vous accéderez à un formulaire pour modifier le nouveau profil." & _
				"<br>Le nom du profil doit être unique."
			TXT_INST_IN_VIEWS = "Identifiez les vues dans lesquelles ce profil sera disponible" & TXT_COLON
			TXT_INST_PROFILE_NAME = "Nom unique identifiant ce profil"
			TXT_MANAGE_FIELDS = "Gérer les champs"
			TXT_RETURN_TO_PROFILE = "Retourner au profil" & TXT_COLON
			TXT_SPECIFY_PROFILE_NAME = "Vous devez attribuer un nom au nouveau profil"
			TXT_STATUS_DELETE = "Ce profil de confidentialité n'est pas utilisé : vous pouvez le supprimer en activant le bouton en bas du formulaire."
			TXT_STATUS_NO_DELETE = "Ce profil de confidentialité est actuellement utilisé : vous ne pouvez ni le supprimer, ni le rendre inactif."
			TXT_STATUS_NO_USE = "Ce profil de confidentialité <strong>n'est pas</strong> utilisé dans un dossier."
			TXT_STATUS_USE_1 = "Ce profil de confidentialité est <strong>utilisé</strong> par "
			TXT_STATUS_USE_2 = " dossier(s)."
			TXT_UPDATE_PROFILE_FAILED = "La mise à jour du profil de confidentialité a échoué."
			TXT_VIEW_EDIT_PROFILE = "Voir / Modifier le profil"
	End Select
End Sub

Call setTxtProfile()
%>
