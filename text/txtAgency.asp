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
Dim TXT_ADD_NEW_AGENCY, _
	TXT_AGENCY_CODE, _
	TXT_CONFIRM_DELETE_AGENCY, _
	TXT_AGENCY_DELETED, _
	TXT_AGENCY_NOT_DELETED, _
	TXT_AGENCY_NOT_UPDATED, _
	TXT_AGENCY_OWNS, _
	TXT_AGENCY_NUM, _
	TXT_AGENCY_UPDATED, _
	TXT_CHOOSE_AGENCY, _
	TXT_EDIT_AGENCIES, _
	TXT_EDIT_AGENCY, _
	TXT_EDIT_AGENCY_INFO, _
	TXT_EMAIL_LANGUAGE, _
	TXT_ENFORCE_REQUIRED_FIELDS, _
	TXT_INQUIRY_PHONE, _
	TXT_INST_AGENCY_CODE, _
	TXT_INST_OWNER_CIC, _
	TXT_INST_OWNER_VOL, _
	TXT_MANAGE_AGENCIES, _
	TXT_NOT_VALID_AGENCY_CODE, _
	TXT_ORGANIZATION_RECORDS, _
	TXT_RETURN_AGENCIES, _
	TXT_STATUS_DELETE, _
	TXT_STATUS_DOES_NOT_OWN, _
	TXT_STATUS_NO_DELETE, _
	TXT_STATUS_NO_USER, _
	TXT_STATUS_USER_1, _
	TXT_STATUS_USER_2, _
	TXT_THERE_ARE_NO_AGENCIES, _
	TXT_UPDATE_AGENCY_FAILED, _
	TXT_UPDATE_EMAIL, _
	TXT_UPDATE_PHONE, _
	TXT_USER_ACCOUNT_UPDATE_DEFAULT, _
	TXT_USER_PASSWORD_UPDATE_DEFAULT, _
	TXT_USER_ACCOUNT_UPDATES, _
	TXT_VOLUNTEER_RECORDS

Sub setTxtAgency()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_NEW_AGENCY = "Add New Agency"
			TXT_AGENCY_CODE = "Agency Code"
			TXT_CONFIRM_DELETE_AGENCY = "Confirm Agency Deletion"
			TXT_AGENCY_DELETED = "The Agency was successfully deleted"
			TXT_AGENCY_NOT_DELETED = "The Agency was not deleted" & TXT_COLON
			TXT_AGENCY_NOT_UPDATED = "The Agency was not updated" & TXT_COLON
			TXT_AGENCY_OWNS = "This Agency owns"
			TXT_AGENCY_NUM = "Agency Record #"
			TXT_AGENCY_UPDATED = "The Agency was successfully updated"
			TXT_CHOOSE_AGENCY = "Choose a Agency from the list below or add a new Agency."
			TXT_EDIT_AGENCIES = "Edit Agencies"
			TXT_EDIT_AGENCY = "Edit Agency" & TXT_COLON
			TXT_EDIT_AGENCY_INFO = "Edit User Agency / Record Owner Information"
			TXT_EMAIL_LANGUAGE = "Language for Email requesting account update"
			TXT_ENFORCE_REQUIRED_FIELDS = "Enforce Required Fields"
			TXT_INQUIRY_PHONE = "Inquiry Phone"
			TXT_INST_AGENCY_CODE = "Unique 3-character code identifying the Agency."
			TXT_INST_OWNER_CIC = "If the Agency owns at least one Organization/Program record, you should fill in the following information."
			TXT_INST_OWNER_VOL = "If the Agency owns at least one Volunteer record, you should fill in the following information."
			TXT_MANAGE_AGENCIES = "Manage Agencies"
			TXT_NOT_VALID_AGENCY_CODE = " is not a valid Agency Code. Codes must be 3 letters (e.g. ACT, HAM, DUN)"
			TXT_ORGANIZATION_RECORDS = "Organization records"
			TXT_RETURN_AGENCIES = "Return to Agencies"
			TXT_STATUS_DELETE = "Because this Agency is not being used, you can delete it using the button at the bottom of the form."
			TXT_STATUS_DOES_NOT_OWN = "This Agency <strong>does not</strong> own any "
			TXT_STATUS_NO_DELETE = "Because this Agency is being used, you cannot currently delete it."
			TXT_STATUS_NO_USER = "This Agency is <strong>not</strong> being used by any Users."
			TXT_STATUS_USER_1 = "This Agency is being used by "
			TXT_STATUS_USER_2 = " Users"
			TXT_THERE_ARE_NO_AGENCIES = "There are no Agencies"
			TXT_UPDATE_AGENCY_FAILED = "Update Agency Failed"
			TXT_UPDATE_EMAIL = "Update Email"
			TXT_UPDATE_PHONE = "Update Phone"
			TXT_USER_ACCOUNT_UPDATE_DEFAULT = "By default, users can update basic information about their account"
			TXT_USER_PASSWORD_UPDATE_DEFAULT = "By default, users can update their password"
			TXT_USER_ACCOUNT_UPDATES = "User Account Updates"
			TXT_VOLUNTEER_RECORDS = "Volunteer records"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_NEW_AGENCY = "Ajout d'une nouvelle agence"
			TXT_AGENCY_CODE = "Code de l'agence"
			TXT_CONFIRM_DELETE_AGENCY = "Confirmer la suppression d'agence"
			TXT_AGENCY_DELETED = "L'agence a été supprimée avec succès"
			TXT_AGENCY_NOT_DELETED = "L'agence n'a pas été supprimée" & TXT_COLON
			TXT_AGENCY_NOT_UPDATED = "L'agence n'a pas été mise à jour" & TXT_COLON
			TXT_AGENCY_OWNS = "Cette agence est propriétaire de "
			TXT_AGENCY_NUM = "No. de dossier de l'agence"
			TXT_AGENCY_UPDATED = "L'agence a été mise à jour avec succès"
			TXT_CHOOSE_AGENCY = "Sélectionner une agence dans la liste ci-dessous ou ajouter une nouvelle agence."
			TXT_EDIT_AGENCIES = "Modification des agences"
			TXT_EDIT_AGENCY = "Modifier l'agence" & TXT_COLON
			TXT_EDIT_AGENCY_INFO = "Modification des renseignements sur l'agence de l'utilisateur ou sur le propriétaire des dossiers"
			TXT_EMAIL_LANGUAGE = "Langue du courriel pour la demande de mise à jour du compte"
			TXT_ENFORCE_REQUIRED_FIELDS = "Appliquer les champs obligatoires"
			TXT_INQUIRY_PHONE = "Téléphone du service de renseignements"
			TXT_INST_AGENCY_CODE = "Code unique à 3 caractères qui identifie l'agence"
			TXT_INST_OWNER_CIC = "Si l'agence est propriétaire d'au moins un dossier d'Organisme ou programme, vous devriez fournir les renseignements suivants."
			TXT_INST_OWNER_VOL = "Si l'agence est propriétaire d'au moins un dossier de Possibilités de bénévolat, vous devriez fournir les renseignements suivants."
			TXT_MANAGE_AGENCIES = "Gestion des agences"
			TXT_NOT_VALID_AGENCY_CODE = " n'est pas un code d'agence valide. Les codes doivent être constitués de trois lettres (par ex. ACT, HAM, DUN)."
			TXT_ORGANIZATION_RECORDS = "dossiers d'organisme"
			TXT_RETURN_AGENCIES = "Retourner aux agences"
			TXT_STATUS_DELETE = "Comme cette agence n'est pas utilisée, elle peut être supprimée en activant le bouton au bas du formulaire."
			TXT_STATUS_DOES_NOT_OWN = "Cette agence <strong>ne possède aucun</strong> "
			TXT_STATUS_NO_DELETE = "Comme cette agence est actuellement utilisée, vous ne pouvez pas la supprimer."
			TXT_STATUS_NO_USER = "Cette agence <strong>n'est utilisée par aucun</strong> utilisateur."
			TXT_STATUS_USER_1 = "Cette agence est utilisée par "
			TXT_STATUS_USER_2 = " utilisateurs"
			TXT_THERE_ARE_NO_AGENCIES = "Il n'y a pas d'agences"
			TXT_UPDATE_AGENCY_FAILED = "La mise à jour de l'agence a échoué"
			TXT_UPDATE_EMAIL = "Courriel de mise à jour"
			TXT_UPDATE_PHONE = "Téléphone de mise à jour"
			TXT_USER_ACCOUNT_UPDATE_DEFAULT = "Par défaut, les utilisateurs peuvent mettre à jour les renseignements de base sur leur compte"
			TXT_USER_PASSWORD_UPDATE_DEFAULT = "Par défaut, les utilisateurs peuvent mettre à jour leur mot de passe"
			TXT_USER_ACCOUNT_UPDATES = "Mises à jour des comptes utilisateurs"
			TXT_VOLUNTEER_RECORDS = "dossiers de bénévolat"
	End Select
End Sub

Call setTxtAgency()
%>
