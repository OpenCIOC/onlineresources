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
Dim TXT_ARE_YOU_SURE_DELETE_FB, _
	TXT_ASSIGN_TO, _
	TXT_ASSIGNED, _
	TXT_CHOOSE_FEEDBACK, _
	TXT_CONFIRM_DELETE_FEEDBACK, _
	TXT_CREATE_RECORD, _
	TXT_FEEDBACK_EXISTING, _
	TXT_FEEDBACK_KEY, _
	TXT_FEEDBACK_LANGUAGE, _
	TXT_FOR_PUBLICATION, _
	TXT_FULL_REVIEW, _
	TXT_GENERAL_HEADINGS, _
	TXT_NEW_RECORD_SUGGESTIONS, _
	TXT_NO_CHANGES, _
	TXT_NO_FEEDBACK_OR_NOT_AVAILABLE, _
	TXT_OTHER_AGENCIES, _
	TXT_PUB_CODE, _
	TXT_PUBLICATION_FEEDBACK, _
	TXT_RECORDS_WITH_FEEDBACK, _
	TXT_RECORDS_WITH_PUB_FEEDBACK, _
	TXT_REMAINDER_HIDDEN, _
	TXT_REMOVE_RECORD, _
	TXT_REVIEW_BEFORE_DELETE, _
	TXT_REVIEW_FEEDBACK, _
	TXT_SUGGESTIONS_FOR_RECORDS, _
	TXT_SUBMITTER_IP, _
	TXT_UNASSIGNED, _
	TXT_VIEW_FEEDBACK

Sub setTxtReviewFeedback()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ARE_YOU_SURE_DELETE_FB = "Are you sure you want to delete this feedback? The submitter <em>will not</em> be automatically notified."
			TXT_ASSIGN_TO = "Assign selected record suggestions to" & TXT_COLON
			TXT_ASSIGNED = "assigned"
			TXT_CHOOSE_FEEDBACK = "Select from the feedback / suggestions below."
			TXT_CONFIRM_DELETE_FEEDBACK = "Confirm Delete Feedback"
			TXT_CREATE_RECORD = "Create"
			TXT_FEEDBACK_EXISTING = "Feedback on Existing Records"
			TXT_FEEDBACK_KEY = "Feedback Key"
			TXT_FEEDBACK_LANGUAGE = "Language"
			TXT_FOR_PUBLICATION = "For Publication"
			TXT_FULL_REVIEW = "Full Review"
			TXT_GENERAL_HEADINGS = "General Headings"
			TXT_NEW_RECORD_SUGGESTIONS = "New Record Suggestions"
			TXT_NO_CHANGES = "No Changes"
			TXT_NO_FEEDBACK_OR_NOT_AVAILABLE = "No Feedback exists for this record, or you do not have permission to View the Feedback."
			TXT_OTHER_AGENCIES = "Other Agencies"
			TXT_PUB_CODE = "Pub Code"
			TXT_PUBLICATION_FEEDBACK = "Publication Feedback"
			TXT_RECORDS_WITH_FEEDBACK = " records with feedback."
			TXT_RECORDS_WITH_PUB_FEEDBACK = " records with Publication feedback."
			TXT_REMAINDER_HIDDEN = "The remainder of this feedback is hidden because this record has a privacy profile."
			TXT_REMOVE_RECORD = "Remove Record"
			TXT_REVIEW_BEFORE_DELETE = "Please review the contents of the feedback before you delete it."
			TXT_REVIEW_FEEDBACK = "Review Feedback"
			TXT_SUBMITTER_IP = "Submitter IP"
			TXT_SUGGESTIONS_FOR_RECORDS = " suggestions for new records."
			TXT_UNASSIGNED = "Unassigned"
			TXT_VIEW_FEEDBACK = "View"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ARE_YOU_SURE_DELETE_FB = "Êtes-vous certain de vouloir supprimer cette rétroaction ? La personne qui l'a soumise <em>ne sera pas</em> automatiquement informée."
			TXT_ASSIGN_TO = "Assigner les suggestions sélectionnées à" & TXT_COLON
			TXT_ASSIGNED = "assignés"
			TXT_CHOOSE_FEEDBACK = "Sélectionner parmi les messages de rétroaction ou suggestions ci-dessous."
			TXT_CONFIRM_DELETE_FEEDBACK = "Confirmer la supression de la rétroaction"
			TXT_CREATE_RECORD = "Créer"
			TXT_FEEDBACK_EXISTING = "Rétroaction sur les dossiers existants"
			TXT_FEEDBACK_KEY = "Clé de rétroaction"
			TXT_FEEDBACK_LANGUAGE = "Langue"
			TXT_FOR_PUBLICATION = "Pour la publication"
			TXT_FULL_REVIEW = "Révision complète"
			TXT_GENERAL_HEADINGS = "En-têtes généraux"
			TXT_NEW_RECORD_SUGGESTIONS = "Suggestions de nouveaux dossiers"
			TXT_NO_CHANGES = "Pas de changement"
			TXT_NO_FEEDBACK_OR_NOT_AVAILABLE = "Aucune rétroaction n'existe pour ce dossier, ou vous n'avez pas l'autorisation de consulter la rétroaction."
			TXT_OTHER_AGENCIES = "Autres agences"
			TXT_PUB_CODE = "Code de publication"
			TXT_PUBLICATION_FEEDBACK = "Rétroaction sur les publications"
			TXT_RECORDS_WITH_FEEDBACK = " dossier(s) avec rétroaction."
			TXT_RECORDS_WITH_PUB_FEEDBACK = " dossier(s) avec rétroaction sur les publications."
			TXT_REMAINDER_HIDDEN = "Le reste de la rétroaction est caché car ce dossier a un profil de confidentialité."
			TXT_REMOVE_RECORD = "Retirer le dossier"
			TXT_REVIEW_BEFORE_DELETE = "Veuillez réviser le contenu de la rétroaction avec de la supprimer."
			TXT_REVIEW_FEEDBACK = "Révision de la rétroaction"
			TXT_SUBMITTER_IP = "Adresse IP de la personne qui soumet la rétroaction"
			TXT_SUGGESTIONS_FOR_RECORDS = " suggestion(s) de nouveau dossier."
			TXT_UNASSIGNED = "Non assigné"
			TXT_VIEW_FEEDBACK = "Consulter"
	End Select
End Sub

Call setTxtReviewFeedback()
%>
