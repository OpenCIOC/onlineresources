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
Dim TXT_ADD_POLICY, _
	TXT_CHOOSE_POLICY, _
	TXT_CREATE_EDIT_INCLUSION_POLICY, _
	TXT_DELETE_POLICY, _
	TXT_EDIT_POLICY, _
	TXT_ERR_POLICY_LANGUAGE, _
	TXT_ERR_POLICY_TEXT, _
	TXT_INST_POLICY_TITLE, _
	TXT_MANAGE_INCLUSION_POLICIES, _
	TXT_POLICY_CONTENT, _
	TXT_POLICY_TITLE, _
	TXT_RECORD_INCLUSION_POLICY, _
	TXT_RETURN_TO_POLICY_SETUP, _
	TXT_SORRY_NOT_AVAILABLE, _
	TXT_UPDATE_POLICY_FAILED, _
	TXT_USE_THIS_FORM, _
	TXT_VIEW_CURRENT_POLICY, _
	TXT_VIEW_EDIT_POLICY

Sub setTxtInclusion()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_POLICY = "Add New Inclusion Policy"
			TXT_CHOOSE_POLICY = "Choose a Policy from the list below or add a new Policy."
			TXT_CREATE_EDIT_INCLUSION_POLICY = "Create / Edit Inclusion Policy"
			TXT_DELETE_POLICY = "Delete Inclusion Policy"
			TXT_EDIT_POLICY = "Edit Inclusion Policy" & TXT_COLON
			TXT_ERR_POLICY_LANGUAGE = "You must select a valid language for the Policy."
			TXT_ERR_POLICY_TEXT = "Inclusion Policy must not exceed 20,000 characters."
			TXT_INST_POLICY_TITLE = "Unique title to identify this policy. Used only while managing policies."
			TXT_MANAGE_INCLUSION_POLICIES = "Manage Inclusion Policies"
			TXT_POLICY_CONTENT = "Policy Content"
			TXT_POLICY_TITLE = "Policy Title"
			TXT_RECORD_INCLUSION_POLICY = "Record Inclusion Policy"
			TXT_RETURN_TO_POLICY_SETUP = "Return to Inclusion Policy Setup"
			TXT_SORRY_NOT_AVAILABLE = "Sorry...our inclusion policy is not currently available"
			TXT_UPDATE_POLICY_FAILED = "Update Inclusion Policy Failed"
			TXT_USE_THIS_FORM = "Use this form to edit a Record Inclusion Policy"
			TXT_VIEW_CURRENT_POLICY = "View the current Inclusion Policy page"
			TXT_VIEW_EDIT_POLICY = "View / Edit Policy"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_POLICY = "Ajouter une nouvelle politique d'inclusion"
			TXT_CHOOSE_POLICY = "Sélectionner une politique dans la liste ci-dessous ou ajouter une nouvelle politique."
			TXT_CREATE_EDIT_INCLUSION_POLICY = "Créer / Modifier une politique d'inclusion"
			TXT_DELETE_POLICY = "Supprimer la politique d'inclusion"
			TXT_EDIT_POLICY = "Modifier la politique d'inclusion" & TXT_COLON
			TXT_ERR_POLICY_LANGUAGE = "Vous devez sélectionner une langue valide pour la politique."
			TXT_ERR_POLICY_TEXT = "La politique d'inclusion ne doit pas dépasser 20 000 caractères."
			TXT_INST_POLICY_TITLE = "Titre unique qui identifie cette politique. Utilisé uniquement pour la gestion des politiques."
			TXT_MANAGE_INCLUSION_POLICIES = "Gérer les politiques d'inclusion"
			TXT_POLICY_CONTENT = "Contenu de la politique"
			TXT_POLICY_TITLE = "Nom de la politique"
			TXT_RECORD_INCLUSION_POLICY = "Politique d'inclusion d'un dossier"
			TXT_RETURN_TO_POLICY_SETUP = "Retourner à la configuration de la politique d'inclusion"
			TXT_SORRY_NOT_AVAILABLE = "Désolé, notre politique d'inclusion n'est pas disponible en ce moment."
			TXT_UPDATE_POLICY_FAILED = "La mise à jour de la politique d'inclusion a échoué."
			TXT_USE_THIS_FORM = "Utiliser ce formulaire pour modifier une politique d'inclusion"
			TXT_VIEW_CURRENT_POLICY = "Visualiser la page actuelle de la politique d'inclusion"
			TXT_VIEW_EDIT_POLICY = "Voir / Modifier la politique"
	End Select
End Sub

Call setTxtInclusion()
%>
