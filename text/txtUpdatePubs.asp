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
Dim TXT_ADDITIONAL_PUBLICATIONS, _
	TXT_CONFIRM_REMOVE_PUB, _
	TXT_DESCRIPTION, _
	TXT_EDIT_PUBS_FOR, _
	TXT_ERR_DESCRIPTION, _
	TXT_EXISTING_HEADINGS, _
	TXT_HAS_DESCRIPTION, _
	TXT_HAS_FEEDBACK, _
	TXT_HAS_HEADINGS, _
	TXT_INSERT_DESCRIPTION, _
	TXT_INST_HEADINGS, _
	TXT_NO_HEADINGS_FOR_PUB, _
	TXT_PUBS_NOT_AVAILABLE_TO_EDIT, _
	TXT_SHOW_FIELD, _
	TXT_UPDATE_PUBS_TITLE, _
	TXT_WARNING_REMOVE_PUB

Sub setTxtUpdatePubs()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADDITIONAL_PUBLICATIONS = "Additional Publications"
			TXT_CONFIRM_REMOVE_PUB = "Confirm Remove Publication"
			TXT_DESCRIPTION = "Description"
			TXT_EDIT_PUBS_FOR = "Edit Publications for" & TXT_COLON
			TXT_ERR_DESCRIPTION = "Publication descriptions may not exceed 8000 characters."
			TXT_EXISTING_HEADINGS = "Existing Headings"
			TXT_HAS_DESCRIPTION = "Has Description"
			TXT_HAS_FEEDBACK = "Has Feedback"
			TXT_HAS_HEADINGS = "Has Headings"
			TXT_INSERT_DESCRIPTION = "Insert Current Description From Record"
			TXT_INST_HEADINGS = "You can add up to 4 new headings at a time."
			TXT_NO_HEADINGS_FOR_PUB = "There are no General Headings available for this publication"
			TXT_PUBS_NOT_AVAILABLE_TO_EDIT = "The publications below are associated with this record but are not available for you to edit in your current View."
			TXT_SHOW_FIELD = "Show Field" & TXT_COLON
			TXT_UPDATE_PUBS_TITLE = "Update Publications"
			TXT_WARNING_REMOVE_PUB = "If you remove a Publication, any descriptions or general headings related to this publication will also be removed from the record."
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADDITIONAL_PUBLICATIONS = "Publications complémentaires"
			TXT_CONFIRM_REMOVE_PUB = "Confirmation de la suppression de la publication"
			TXT_DESCRIPTION = "Description"
			TXT_EDIT_PUBS_FOR = "Édition des publications pour" & TXT_COLON
			TXT_ERR_DESCRIPTION = "Les descriptions des publications ne peuvent contenir plus de 7 900 caractères."
			TXT_EXISTING_HEADINGS = "En-têtes courants"
			TXT_HAS_DESCRIPTION = "a une description"
			TXT_HAS_FEEDBACK = "a de la rétroaction"
			TXT_HAS_HEADINGS = "a des en-têtes"
			TXT_INSERT_DESCRIPTION = "Insérer la description courante du dossier"
			TXT_INST_HEADINGS = "Vous pouvez ajouter 4 nouveaux en-têtes à la fois."
			TXT_NO_HEADINGS_FOR_PUB = "Il n'y a pas d'en-têtes généraux disponibles pour cette publication."
			TXT_PUBS_NOT_AVAILABLE_TO_EDIT = "Les publications ci-dessous sont associées à ce dossier mais ne peuvent pas être modifiées sur votre vue actuelle."
			TXT_SHOW_FIELD = "Afficher le champ" & TXT_COLON
			TXT_UPDATE_PUBS_TITLE = "Mise à jour des publications"
			TXT_WARNING_REMOVE_PUB = "Si vous supprimez une publication, les descriptions et les en-têtes généraux liés à cette publication seront aussi supprimés du dossier."
	End Select
End Sub

Call setTxtUpdatePubs()
%>
