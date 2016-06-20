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
Const TXT_RECORD_BILINGUAL = "Record / Dossier"
Const TXT_INSERT_RECORD_NAME_ENGLISH = "RECORD ORGANIZATION / PROGRAM NAME"
Const TXT_INSERT_POSITION_TITLE_ENGLISH = "POSITION TITLE"
Const TXT_INSERT_RECORD_NAME_FRENCH = "NOM DU DOSSIER DE L'ORGANISME / PROGRAMME"
Const TXT_INSERT_POSITION_TITLE_FRENCH = "TITRE DU POSTE"

Dim	TXT_CHANGE_MESSAGE, _
	TXT_CONTACT_LEADER, _
	TXT_CUSTOMIZE_REQUEST, _
	TXT_CURRENT_MESSAGE, _
	TXT_DATE_OF_LAST_REQUEST, _
	TXT_DAYS_AGO_1, _
	TXT_DAYS_AGO_2, _
	TXT_DAYS_SINCE_LAST_REQUEST, _
	TXT_DETAIL_LINK, _
	TXT_EDIT_STANDARD_TEXT, _
	TXT_EDITABLE_SECTIONS, _
	TXT_EMAIL_SENT_TO, _
	TXT_FEEDBACK_LINK, _
	TXT_FEEDBACK_LINK_DESCRIPTION, _
	TXT_HERE_IS_A_PREVIEW, _
	TXT_INSERT_CONTACT_INFO, _
	TXT_INSERT_DETAIL_LINK, _
	TXT_INSERT_FEEDBACK_LINK, _
	TXT_INSERT_OWNER_ADDRESS, _
	TXT_INSERT_OWNER_AGENCY, _
	TXT_INSERT_OWNER_EMAIL, _
	TXT_INSERT_OWNER_FAX, _
	TXT_INSERT_OWNER_MAIL_ADDRESS, _
	TXT_INSERT_OWNER_PHONE, _
	TXT_INSERT_RECORD_NAME, _
	TXT_INSERT_RECORD_NUMBER, _
	TXT_INST_EMAIL_LANGUAGE, _
	TXT_MAX_255, _
	TXT_MAX_1500, _
	TXT_MESSAGE_BODY, _
	TXT_MESSAGE_CONTACT, _
	TXT_MESSAGE_GREETING, _
	TXT_MESSAGE_RECIPIENT, _
	TXT_MESSAGE_SENDER, _
	TXT_MESSAGE_SUBJECT, _
	TXT_NO_AGENCY_EMAIL_FOR, _
	TXT_NO_RECIPIENT_EMAIL, _
	TXT_NO_RECORD_OF_LAST_REQUEST, _
	TXT_NO_RECORDS_FOR_REQUEST, _
	TXT_NOTE_RETURN_TO_SEARCH, _
	TXT_NUMBER_OF_RECORDS_PREPARED, _
	TXT_ONLY, _
	TXT_ORG_VOL_CONTACT, _
	TXT_OTHER, _
	TXT_OTHER_LANG_FOLLOWS, _
	TXT_PREPARE_UPDATE_REQUEST, _
	TXT_PREVIEW_MESSAGE, _
	TXT_PREVIEW_MESSAGE_TITLE, _
	TXT_RECORD, _
	TXT_REQUEST_UPDATE_FOR_RECORD, _
	TXT_RETURN_TO_RECORD, _
	TXT_REVIEW_MESSAGE, _
	TXT_SEND_MESSAGE, _
	TXT_SEND_MESSAGE_TITLE, _
	TXT_TEXT_WAS_NOT_UPDATED, _
	TXT_TEXT_WAS_UPDATED, _
	TXT_UNABLE_TO_SEND_EMAIL_TO, _
	TXT_UPDATE_EMAIL_TEXT_FAILED

Sub setTxtEmailUpdate()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_CHANGE_MESSAGE = "Change Message"
			TXT_CONTACT_LEADER = ""
			TXT_CURRENT_MESSAGE = "Current Message"
			TXT_CUSTOMIZE_REQUEST = "Customize Update Email Request"
			TXT_DATE_OF_LAST_REQUEST = "You last emailed an update request on" & TXT_COLON
			TXT_DAYS_AGO_1 = vbNullString
			TXT_DAYS_AGO_2 = " days ago"
			TXT_DAYS_SINCE_LAST_REQUEST = " day(s) have passed since the last Email Notification about this record was sent."
			TXT_DETAIL_LINK = "Detail Link"
			TXT_EDIT_STANDARD_TEXT = "Edit the standard text for an email update request"
			TXT_EDITABLE_SECTIONS = "Editable Sections"
			TXT_EMAIL_SENT_TO = "Email sent to" & TXT_COLON
			TXT_FEEDBACK_LINK = "Feedback Link"
			TXT_FEEDBACK_LINK_DESCRIPTION = "Go to this URL to suggest changes" & TXT_COLON
			TXT_HERE_IS_A_PREVIEW = "Here is a preview of the first email in the queue. If you are happy with this, click the send button."
			TXT_INSERT_CONTACT_INFO = "RECORD OWNER AGENCY CONTACT INFO"
			TXT_INSERT_DETAIL_LINK = "LINK TO DETAILS PAGE"
			TXT_INSERT_FEEDBACK_LINK = "LINK TO FEEDBACK PAGE"
			TXT_INSERT_OWNER_ADDRESS = "RECORD OWNER AGENCY ADDRESS"
			TXT_INSERT_OWNER_AGENCY = "RECORD OWNER AGENCY NAME"
			TXT_INSERT_OWNER_EMAIL = "RECORD OWNER AGENCY EMAIL"
			TXT_INSERT_OWNER_FAX = "RECORD OWNER AGENCY FAX"
			TXT_INSERT_OWNER_MAIL_ADDRESS = "RECORD OWNER AGENCY MAIL"
			TXT_INSERT_OWNER_PHONE = "RECORD OWNER AGENCY PHONE"
			TXT_INSERT_RECORD_NAME = TXT_INSERT_RECORD_NAME_ENGLISH
			TXT_INSERT_RECORD_NUMBER = "RECORD NUMBER"
			TXT_INST_EMAIL_LANGUAGE = "Records with multiple languages will be sent in all available languages for which message setup has been configured, with a Bilingual Subject. Records having only one language will be sent in only that language with a unilingual subject."
			TXT_MAX_255 = "Maximum 255 characters. Do <strong>not</strong> use HTML."
			TXT_MAX_1500 = "Maximum 1500 characters. Do <strong>not</strong> use HTML."
			TXT_MESSAGE_BODY = "Message Body"
			TXT_MESSAGE_CONTACT = "Contact"
			TXT_MESSAGE_GREETING = "Greeting"
			TXT_MESSAGE_RECIPIENT = "Recipient"
			TXT_MESSAGE_SENDER = "Sender"
			TXT_MESSAGE_SUBJECT = "Subject"
			TXT_NO_AGENCY_EMAIL_FOR = "No agency Email for" & TXT_COLON
			TXT_NO_RECIPIENT_EMAIL = "No Recipient Email given"
			TXT_NO_RECORD_OF_LAST_REQUEST = "We don't have a record of the last day you sent an Email update to this listing."
			TXT_NO_RECORDS_FOR_REQUEST = "Your criteria returned no records that have Emails for updating purposes."
			TXT_NOTE_RETURN_TO_SEARCH = "Note: This is an exact list of your previous search results, and does not use your search criteria." & _
				"<br>If you want to create a new list of records needing to be emailed, begin a new search."
			TXT_NUMBER_OF_RECORDS_PREPARED = " record(s) are being prepared for an update request."
			TXT_ONLY = "Only "
			TXT_ORG_VOL_CONTACT = "Organization Volunteer Contact"
			TXT_OTHER = "Other"
			TXT_OTHER_LANG_FOLLOWS = "Avis : La version française de ce message suit."
			TXT_PREPARE_UPDATE_REQUEST = "Prepare Update Email Request"
			TXT_PREVIEW_MESSAGE = "Preview the Email Message"
			TXT_PREVIEW_MESSAGE_TITLE = "Preview the Email Message"
			TXT_RECORD = "Record"
			TXT_REQUEST_UPDATE_FOR_RECORD = "You are requesting an update for record" & TXT_COLON
			TXT_RETURN_TO_RECORD = "Return to record" & TXT_COLON
			TXT_REVIEW_MESSAGE = "Please take a moment and review the Email Message before sending."
			TXT_SEND_MESSAGE = "Send the Email Message"
			TXT_SEND_MESSAGE_TITLE = "Send the Email Message"
			TXT_TEXT_WAS_NOT_UPDATED = "The text was not updated" & TXT_COLON
			TXT_TEXT_WAS_UPDATED = "The text was successfully updated"
			TXT_UNABLE_TO_SEND_EMAIL_TO = "Unable to send message to" & TXT_COLON
			TXT_UPDATE_EMAIL_TEXT_FAILED = "Update Email Text Failed"
		Case CULTURE_FRENCH_CANADIAN
			TXT_CHANGE_MESSAGE = "Changer le message"
			TXT_CONTACT_LEADER = "Le "
			TXT_CURRENT_MESSAGE = "Message actuel"
			TXT_CUSTOMIZE_REQUEST = "Personnalisation de la demande de mise à jour par courriel"
			TXT_DATE_OF_LAST_REQUEST = "Votre dernière demande de mise à jour par courriel a été faite le" & TXT_COLON
			TXT_DAYS_SINCE_LAST_REQUEST = " jours se sont écoulés depuis le dernier envoi de l'avis par courriel."
			TXT_DAYS_AGO_1 = "depuis "
			TXT_DAYS_AGO_2 = " jours"
			TXT_DETAIL_LINK = "Lien vers le dossier"
			TXT_EDIT_STANDARD_TEXT = "Modifier le texte type pour une demande de mise à jour par courriel"
			TXT_EDITABLE_SECTIONS = "Sections modifiables"
			TXT_EMAIL_SENT_TO = "Courriel envoyé à" & TXT_COLON
			TXT_FEEDBACK_LINK = "Lien vers la rétroaction"
			TXT_FEEDBACK_LINK_DESCRIPTION = "Allez à cette adresse URL pour proposer des changements" & TXT_COLON
			TXT_HERE_IS_A_PREVIEW = "Voici une prévisualisation du premier courriel dans la file d'attente. S'il convient à vos besoins, cliquez sur le bouton d'envoi."
			TXT_INSERT_CONTACT_INFO = "COORDONNÉES DE L'AGENCE PROPRIÉTAIRE DU DOSSIER"
			TXT_INSERT_DETAIL_LINK = "LIEN VERS LA PAGE DE RENSEIGNEMENTS"
			TXT_INSERT_FEEDBACK_LINK = "LIEN VERS LA PAGE DE RÉTROACTION"
			TXT_INSERT_OWNER_ADDRESS = "ADRESSE DE L'AGENCE PROPRIÉTAIRE DU DOSSIER"
			TXT_INSERT_OWNER_AGENCY = "NOM DE L'AGENCE PROPRIÉTAIRE DU DOSSIER"
			TXT_INSERT_OWNER_EMAIL = "COURRIEL DE L'AGENCE PROPRIÉTAIRE DU DOSSIER"
			TXT_INSERT_OWNER_FAX = "TÉLÉCOPIEUR DE L'AGENCE PROPRIÉTAIRE DU DOSSIER"
			TXT_INSERT_OWNER_MAIL_ADDRESS = "ADRESSE POSTALE DE L'AGENCE PROPRIÉTAIRE DU DOSSIER"
			TXT_INSERT_OWNER_PHONE = "TÉLÉPHONE DE L'AGENCE PROPRIÉTAIRE DU DOSSIER"
			TXT_INSERT_RECORD_NAME = "NOM DE L'ORGANISME IDENTIFIÉ AU DOSSIER"
			TXT_INSERT_RECORD_NUMBER = "NUMÉRO DE DOSSIER"
			TXT_INST_EMAIL_LANGUAGE = "Pour les dossiers qui sont disponibles en plusieurs langues, le courriel sera envoyé dans toutes les langues pour lesquelles il existe des messages disponibles, avec un énoncé d'objet bilingue. Pour les dossiers qui sont disponibles dans une seule langue, un courriel sera envoyé uniquement dans cette langue, avec un énoncé d'objet monolingue."
			TXT_MAX_255 = "255 caractères maximum. <strong>Ne pas</strong> utiliser de langage HTLM."
			TXT_MAX_1500 = "1500 caractères maximum. <strong>Ne pas</strong> utiliser de langage HTLM."
			TXT_MESSAGE_BODY = "Corps du message"
			TXT_MESSAGE_CONTACT = "Contactez-nous"
			TXT_MESSAGE_GREETING = "Message d'accueil"
			TXT_MESSAGE_RECIPIENT = "Destinataire"
			TXT_MESSAGE_SENDER = "Expéditeur"
			TXT_MESSAGE_SUBJECT = "Objet"
			TXT_NO_AGENCY_EMAIL_FOR = "Il n'y a pas d'adresse de courriel d'agence pour" & TXT_COLON
			TXT_NO_RECIPIENT_EMAIL = "Veuillez indiquer l'adresse courriel du destinataire"
			TXT_NO_RECORD_OF_LAST_REQUEST = "Il n'existe aucune information concernant la dernière fois que vous avez fait parvenir un courriel de mise à jour pour cette inscription."
			TXT_NO_RECORDS_FOR_REQUEST = "Vos critères de recherche n'ont retourné aucun dossier ayant un courriel de mise à jour."
			TXT_NOTE_RETURN_TO_SEARCH = "Remarque : ceci est une liste exacte des résultats de votre précédente recherche, sans tenir compte de vos critères de recherche." & _
				"<br>Si vous désirez établir une nouvelle liste de dossiers à envoyer par courriel, faites une nouvelle recherche."
			TXT_NUMBER_OF_RECORDS_PREPARED = " dossier(s) est(sont) en train d'être préparé(s) pour une demande de mise à jour."
			TXT_ONLY = "Seulement "
			TXT_ORG_VOL_CONTACT = "Contact bénévolat de l'organisme"
			TXT_OTHER = "Autre"
			TXT_OTHER_LANG_FOLLOWS = "Note : The English version of this message follows below."
			TXT_PREPARE_UPDATE_REQUEST = "Préparation de la demande de mise à jour par courriel"
			TXT_PREVIEW_MESSAGE = "Prévisualiser le courriel"
			TXT_PREVIEW_MESSAGE_TITLE = "Prévisualisation du courriel"
			TXT_RECORD = "Dossier"
			TXT_REQUEST_UPDATE_FOR_RECORD = "Vous demandez une mise à jour du dossier" & TXT_COLON
			TXT_RETURN_TO_RECORD = "Retourner au dossier" & TXT_COLON
			TXT_REVIEW_MESSAGE = "Veuillez prendre le temps de réviser le contenu du courriel avant de l'envoyer."
			TXT_SEND_MESSAGE = "Envoyer le courriel"
			TXT_SEND_MESSAGE_TITLE = "Envoi des courriels"
			TXT_TEXT_WAS_NOT_UPDATED = "Le texte n'a pas été mis à jour" & TXT_COLON
			TXT_TEXT_WAS_UPDATED = "Le texte a bien été mis à jour."
			TXT_UNABLE_TO_SEND_EMAIL_TO = "Impossible d'envoyer le message au" & TXT_COLON
			TXT_UPDATE_EMAIL_TEXT_FAILED = "La mise à jour du texte du courriel a échoué."
	End Select
End Sub

Call setTxtEmailUpdate()
Call addTextFile("setTxtEmailUpdate")
%>
