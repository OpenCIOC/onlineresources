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
Dim TXT_EDIT_PROFILE, _
	TXT_FIELD_LIST_NOT_UPDATED, _
	TXT_FIELD_LIST_UPDATED, _
	TXT_MANAGE_FIELDS_TITLE, _
	TXT_MANAGE_PROFILES, _
	TXT_RETURN_TO_PROFILES

Sub setTxtPrivacyProfile()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_EDIT_PROFILE = "Edit Privacy Profile"
			TXT_FIELD_LIST_NOT_UPDATED = "The field list was not updated" & TXT_COLON
			TXT_FIELD_LIST_UPDATED = "The field list was updated successfully"
			TXT_MANAGE_FIELDS_TITLE = "Manage Private Fields"
			TXT_MANAGE_PROFILES = "Manage Privacy Profiles"
			TXT_RETURN_TO_PROFILES = "Return to Privacy Profiles"
		Case CULTURE_FRENCH_CANADIAN
			TXT_EDIT_PROFILE = "Modifier le profil de confidentialité"
			TXT_FIELD_LIST_NOT_UPDATED = "La mise à jour de la liste des champs a échoué." & TXT_COLON
			TXT_FIELD_LIST_UPDATED = "La liste des champs a été mise à jour avec succès."
			TXT_MANAGE_FIELDS_TITLE = "Gérer les champs confidentiels"
			TXT_MANAGE_PROFILES = "Gérer les profils de confidentialité"
			TXT_RETURN_TO_PROFILES = "Retourner aux profils de confidentialité"
	End Select
End Sub

Call setTxtPrivacyProfile()
%>

