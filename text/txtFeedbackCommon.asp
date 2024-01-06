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
Dim TXT_AUTH_APPROVE, _
	TXT_AUTH_CONTACT, _
	TXT_AUTH_GIVEN, _
	TXT_AUTH_GIVEN_FOR, _
	TXT_AUTH_INQUIRIES, _
	TXT_AUTH_INQUIRIES_ONLY, _
	TXT_AUTH_NOT_RECEIVED, _
	TXT_AUTHORIZATION, _
	TXT_CONTACT_SUBMITTER, _
	TXT_DATE_SUBMITTED, _
	TXT_FEEDBACK_ID, _
	TXT_FEEDBACK_NOTES, _
	TXT_FEEDBACK_OWNER, _
	TXT_INTERNAL_REVIEW, _
	TXT_PLEASE_SELECT_OPTIONS, _
	TXT_SUBMITTED_BY, _
	TXT_SUBMITTER_EMAIL, _
	TXT_USE_INQUIRY, _
	TXT_USE_OF_INFO, _
	TXT_USE_ONLINE, _
	TXT_USE_PRINT, _
	TXT_VIEW_RECORD_AT

Sub setTxtFeedbackCommon()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_AUTH_APPROVE = "J'autorise que ces informations soient utilisées en conformité avec la politique des conditions d'utilisation."
			TXT_AUTH_CONTACT = "Je ne puis autoriser l'utilisation de ce dossier en ce moment. Prière de communiquer directement avec moi."
			TXT_AUTH_GIVEN = "Une autorisation a été accordée pour utilisation de cette information."
			TXT_AUTH_GIVEN_FOR = "Une autorisation a été accordée pour utilisation de cette information aux fins suivantes" & TXT_COLON
			TXT_AUTH_INQUIRIES = "J'autorise que cette information soit utilisée uniquement lors de demandes d'information par téléphone ou en personne."
			TXT_AUTH_INQUIRIES_ONLY = "Une autorisation a été accordée uniquement pour les demandes d'information."
			TXT_AUTH_NOT_RECEIVED = "Aucune autorisation explicite n'a été obtenue pour l'utilisation de cette information."
			TXT_AUTHORIZATION = "Autorisation pour utilisation des données"
			TXT_CONTACT_SUBMITTER = "Prière de communiquer avec la personne faisant la soumission pour discuter de l'utilisation de cette information."
			TXT_DATE_SUBMITTED = "Date de soumission"
			TXT_FEEDBACK_ID = "L'identificateur de la rétroaction"
			TXT_FEEDBACK_NOTES = "Notes sur la rétroaction"
			TXT_FEEDBACK_OWNER = "Propriétaire de la rétroaction"
			TXT_INTERNAL_REVIEW = "Ceci n'a été qu'une révision interne."
			TXT_PLEASE_SELECT_OPTIONS = "PRIÈRE DE CHOISIR L'UNE DES OPTIONS SUIVANTES" & TXT_COLON
			TXT_SUBMITTED_BY = "Soumis par"
			TXT_SUBMITTER_EMAIL = "Le courriel de la personne faisant la soumission"
			TXT_USE_INQUIRY = "Demandes d'information par téléphone et en personne"
			TXT_USE_OF_INFO = "Utilisation de l'information"
			TXT_USE_ONLINE = "Recherches en ligne pour le grand public"
			TXT_USE_PRINT = "Publications imprimées"
			TXT_VIEW_RECORD_AT = "Vous pouvez visualiser le dossier au" & TXT_COLON
		Case Else
			TXT_AUTH_APPROVE = "I authorize this information for use as outlined in the Terms of Use policy."
			TXT_AUTH_CONTACT = "I cannot authorize this record at this time. Please contact me directly."
			TXT_AUTH_GIVEN = "Authorization was given to use this information."
			TXT_AUTH_GIVEN_FOR = "Authorization was given to use this information for the following purposes" & TXT_COLON
			TXT_AUTH_INQUIRIES = "I authorize this information for use in telephone / in person inquiries only."
			TXT_AUTH_INQUIRIES_ONLY = "Authorization was given for inquiries only."
			TXT_AUTH_NOT_RECEIVED = "No explicit authorization was received for the use of this information."
			TXT_AUTHORIZATION = "Data Use Authorization"
			TXT_CONTACT_SUBMITTER = "Please contact the submitter to discuss the use of this information."
			TXT_DATE_SUBMITTED = "Date Submitted"
			TXT_FEEDBACK_ID = "Feedback ID"
			TXT_FEEDBACK_NOTES = "Feedback Notes"
			TXT_FEEDBACK_OWNER = "Feedback Owner"
			TXT_INTERNAL_REVIEW = "This was an internal review only."
			TXT_PLEASE_SELECT_OPTIONS = "PLEASE SELECT ONE OF THE FOLLOWING OPTIONS" & TXT_COLON
			TXT_SUBMITTED_BY = "Submitted By"
			TXT_SUBMITTER_EMAIL = "Submitter Email"
			TXT_USE_INQUIRY = "Telephone and in-person inquiries"
			TXT_USE_OF_INFO = "Use of this Information"
			TXT_USE_ONLINE = "Online public searches"
			TXT_USE_PRINT = "Printed Publications"
			TXT_VIEW_RECORD_AT = "You can view the record at" & TXT_COLON
	End Select
End Sub

Call setTxtFeedbackCommon()
Call addTextFile("setTxtFeedbackCommon")
%>
