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
Dim TXT_ABOUT_CHANGES, _
	TXT_ABOUT_YOU, _
	TXT_ALSO_CONTACT, _
	TXT_AUTH_APPROVE_LOGIN, _
	TXT_AUTH_INTERNAL, _
	TXT_AUTH_NOT_GIVEN, _
	TXT_BEFORE_SUBMITTING, _
	TXT_CHANGES_WILL_BE_REVIEWED, _
	TXT_COMPLETE_NO_CHANGES_REQUIRED, _
	TXT_COMPLETE_UPDATE, _
	TXT_ENTER_SPECIAL_INFO, _
	TXT_FEEDBACK_FOR, _
	TXT_FEEDBACK_PASSWORD, _
	TXT_FEEDBACK_PASSWORD_ERROR, _
	TXT_FEEDBACK_PASSWORD_PRIVACY, _
	TXT_FEEDBACK_PASSWORD_REQUIRED, _
	TXT_INST_ABOUT_YOU, _
	TXT_INST_AUTH, _
	TXT_INST_FULL_OR_PARTIAL, _
	TXT_INST_SOURCE, _
	TXT_INST_YOUR_INFO, _
	TXT_JOB_TITLE, _
	TXT_NOTIFICATIONS, _
	TXT_NOTIFY_ADMIN, _
	TXT_NOTIFY_AGENCY, _
	TXT_NOT_COMPLETE_UPDATE, _
	TXT_RECORD_FEEDBACK, _
	TXT_QUESTIONS_CONTACT, _
	TXT_READ_INCLUSION, _
	TXT_RECORD_BE_UPDATED_IN, _
	TXT_REMOVE_RECORD, _
	TXT_REVIEW_NEW_EMAIL, _
	TXT_REVIEW_TERMS_OF_USE, _
	TXT_REVIEW_UPDATES, _
	TXT_SOURCE_OF_INFO, _
	TXT_SPECIAL_INSTRUCTIONS, _
	TXT_SUBMITTED_FEEDBACK_1_NAME, _
	TXT_SUBMITTED_FEEDBACK_1_SOMEONE, _
	TXT_SUBMITTED_FEEDBACK_1_YOU, _
	TXT_SUBMITTED_FEEDBACK_2, _
	TXT_SUGGEST_CHANGES_FOR, _
	TXT_SUGGEST_NEW_RECORD, _
	TXT_SUMMARY_OF_CHANGES, _
	TXT_THANKS_FOR_FEEDBACK, _
	TXT_UNABLE_SAVE_FEEDBACK, _
	TXT_VOL_HOURS, _
	TXT_VOL_HOURS_PER, _
	TXT_VOL_ON_OR_AFTER, _
	TXT_VOL_ON_OR_BEFORE, _
	TXT_VOL_SCHEDULE_NOTES, _
	TXT_VOL_YOU_ARE_SUGGESTING_FOR, _
	TXT_WE_APPRECIATE, _
	TXT_YOU_MAY_SUGGEST_LANGUAGE, _
	TXT_YOUR

Sub setTxtFeedback()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ABOUT_CHANGES = "Nature des changements apportés"
			TXT_ABOUT_YOU = "Renseignements personnels"
			TXT_ALSO_CONTACT = "Vous pouvez également nous contacter pour tout changement à apporter à ces renseignements" & TXT_COLON
			TXT_AUTH_APPROVE_LOGIN = "J'ai obtenu, de la part de la source de cette information, une autorisation écrite ou verbale pour les utilisations suivantes" & TXT_COLON
			TXT_AUTH_INTERNAL = "Ceci est une révision interne."
			TXT_AUTH_NOT_GIVEN = "Je n'ai pas obtenu de la part de la source de cette information une autorisation explicite d'utilisation. Voir les notes ci-jointes."
			TXT_BEFORE_SUBMITTING = "Avant de soumettre, veuillez nous fournir de plus amples renseignements ..."
			TXT_CHANGES_WILL_BE_REVIEWED = "Veuillez noter que les changements suggérés ne seront pas effectués avant d'avoir été vérifiés par notre personnel de gestion des données."
			TXT_COMPLETE_NO_CHANGES_REQUIRED = "J'ai révisé <strong>toute</strong> l'information présentée dans ce dossier et <strong>aucun changement</strong> n'est requis. "
			TXT_COMPLETE_UPDATE = "Ceci est <strong>une mise à jour complète</strong>. J'ai révisé <strong>toute</strong> l'information présentée dans ce dossier et apporté les corrections requises."
			TXT_ENTER_SPECIAL_INFO = "Si vous voulez transmettre des renseignements particuliers aux personnes qui font la révision des dossiers, veuillez les inscrire ici" & TXT_COLON
			TXT_FEEDBACK_FOR = "Rétroaction pour" & TXT_COLON
			TXT_FEEDBACK_PASSWORD = "Le mot de passe pour la rétroaction"
			TXT_FEEDBACK_PASSWORD_ERROR = "Le mot de passe pour la rétroaction n'est pas valide."
			TXT_FEEDBACK_PASSWORD_PRIVACY = "Un mot de passe est requis afin d'effectuer une rétroaction sur certains champs de ce dossier. Saisir votre mot de passe ci-dessous afin d'effectuer une rétroaction sur tous les champs."
			TXT_FEEDBACK_PASSWORD_REQUIRED = "Un mot de passe est requis afin de soumettre une rétroaction pour ce dossier."
			TXT_INST_ABOUT_YOU = "Vous <strong>devez</strong> nous fournir notre nom et un numéro de téléphone ou une adresse courriel valide."
			TXT_INST_AUTH = "Veuillez indiquer si vous autorisez l'utilisation de cette information"
			TXT_INST_FULL_OR_PARTIAL = "Veuillez indiquer s'il s'agit d'une mise à jour complète ou partielle."
			TXT_INST_SOURCE = "Le tableau suivant permet la transmission de l'information sur la personne-ressource pour la mise à jour de ce dossier (la personne qui fournit le contenu). " & _
				"<strong>Ce n'est probablement pas vous</strong>." & _
				"<br>L'information provenant de votre compte d'accès sera automatiquement ajoutée à la rétroaction afin que le destinataire puisse identifier sa provenance."
			TXT_INST_YOUR_INFO = "Veuillez nous fournir votre nom complet. Nous vous conseillons <strong>fortement</strong> de fournir une adresse courriel afin de faciliter la mise à jour efficace de votre information."
			TXT_JOB_TITLE = "Désignation du poste"
			TXT_NOT_COMPLETE_UPDATE = "Ceci <strong>n'est pas une mise à jour complète</strong>. Je n'ai révisé ou modifié <strong>qu'une partie</strong> de l'information dans ce dossier."
			TXT_NOTIFICATIONS = "Notifications"
			TXT_NOTIFY_ADMIN = "Aviser le gestionnaire du dossier?"
			TXT_NOTIFY_AGENCY = "Aviser l'agence?"
			TXT_QUESTIONS_CONTACT = "Si vous avez des préoccupations ou des questions, prière de communiquer avec le "
			TXT_READ_INCLUSION = "Veuillez lire notre <a href=""javascript:openWin('" & makeLinkB("inclusion.asp") & "','incPolicy')"">politique d'inclusion des dossiers</a>  avant de proposer un nouveau dossier."
			TXT_RECORD_BE_UPDATED_IN = "soit mise à jour dans la "
			TXT_RECORD_FEEDBACK = "Rétroaction sur le dossier"
			TXT_REMOVE_RECORD = "Ce dossier n'est plus valide. <strong>Veuillez le retirer</strong>."
			TXT_REVIEW_NEW_EMAIL = "Pour révision : nouvelle adresse courriel fournie pour votre dossier dans "
			TXT_REVIEW_TERMS_OF_USE = "Consulter notre politique sur <em>les Conditions d'utilisation</em>"
			TXT_REVIEW_UPDATES = "Pour révision : mises à jour de votre dossier dans "
			TXT_SOURCE_OF_INFO = "Source de l'information"
			TXT_SPECIAL_INSTRUCTIONS = "Directives particulières"
			TXT_SUBMITTED_FEEDBACK_1_NAME = " a soumis"
			TXT_SUBMITTED_FEEDBACK_1_SOMEONE = "Quelqu'un a soumis"
			TXT_SUBMITTED_FEEDBACK_1_YOU = "Vous avez soumis"
			TXT_SUBMITTED_FEEDBACK_2 = " une rétroaction proposant que l'entrée pour"
			TXT_SUGGEST_CHANGES_FOR = "Suggérer des changements pour" & TXT_COLON
			TXT_SUGGEST_NEW_RECORD = "Proposer un nouveau dossier"
			TXT_SUMMARY_OF_CHANGES = "Ce qui suit est un sommaire des changements suggérés au(x) champ(s) dans la base de données" & TXT_COLON
			TXT_THANKS_FOR_FEEDBACK = "Merci de votre rétroaction"
			TXT_UNABLE_SAVE_FEEDBACK = "Il nous a été impossible de sauvegarder votre rétroaction" & TXT_COLON
			TXT_VOL_HOURS = "(heures)"
			TXT_VOL_HOURS_PER = "(heures par)"
			TXT_VOL_ON_OR_AFTER = "(à cette date ou après)"
			TXT_VOL_ON_OR_BEFORE = "(à cette date ou avant)"
			TXT_VOL_SCHEDULE_NOTES = "Notes sur les horaires"
			TXT_VOL_YOU_ARE_SUGGESTING_FOR = "Vous proposez un nouveau dossier pour l'organisme :"
			TXT_WE_APPRECIATE = "Nous apprécions le temps et les efforts que vous consacrez à maintenir la base de données à jour. L'information que vous soumettez sera révisée par "
			TXT_YOU_MAY_SUGGEST_LANGUAGE = "Vous mai utiliser ce formulaire pour proposer une version française de ce dossier."
			TXT_YOUR = "Votre "
		Case Else
			TXT_ABOUT_CHANGES = "About These Changes"
			TXT_ABOUT_YOU = "About You"
			TXT_ALSO_CONTACT = "You can also contact us about changes to this information" & TXT_COLON
			TXT_AUTH_APPROVE_LOGIN = "I received verbal/written authorization from the source for the following uses of this information" & TXT_COLON
			TXT_AUTH_INTERNAL = "This is an internal review."
			TXT_AUTH_NOT_GIVEN = "I did not receive explicit authorization from the source for the use of this information. See Notes."
			TXT_BEFORE_SUBMITTING = "Before submitting, please provide us with some additional information..."
			TXT_CHANGES_WILL_BE_REVIEWED = "Please note that the suggested changes will not be added until they are reviewed by our data management staff."
			TXT_COMPLETE_NO_CHANGES_REQUIRED = "I have reviewed <strong>all</strong> the information in this record and <strong>no changes</strong> were required."
			TXT_COMPLETE_UPDATE = "This is a <strong>complete update</strong>. I have reviewed <strong>all</strong> the information in this record and made the necessary corrections."
			TXT_ENTER_SPECIAL_INFO = "If there is some special information you wish to pass along to those reviewing the record, please enter it here" & TXT_COLON
			TXT_FEEDBACK_FOR = "Feedback For" & TXT_COLON
			TXT_FEEDBACK_PASSWORD = "Feedback Password"
			TXT_FEEDBACK_PASSWORD_ERROR = "The feedback password provided is invalid.."
			TXT_FEEDBACK_PASSWORD_PRIVACY = "A password is required in order to provide feedback on some fields in this record. Enter the password below to provide feedback on all fields."
			TXT_FEEDBACK_PASSWORD_REQUIRED = "A password is required to submit feedback on this record."
			TXT_INST_ABOUT_YOU = "You <strong>must</strong> provide us with your name and phone or Email."
			TXT_INST_AUTH = "Please indicate whether you authorize use of this information"
			TXT_INST_FULL_OR_PARTIAL = "Please indicate whether this is a full or partial update."
			TXT_INST_SOURCE = "The following table is for filling in the source information for this record (the person who provides the content). " & _
				"<strong>This probably isn't you</strong>." & _
				"<br>The information from your login account will be automatically tagged on the feedback so the recipient will know it came from you."
			TXT_INST_YOUR_INFO = "Please leave us your full name. You are <strong>strongly</strong> encouraged to leave us an email address so that we can expedite keeping your information current."
			TXT_JOB_TITLE = "Job Title / Position"
			TXT_NOT_COMPLETE_UPDATE = "This is <strong>not a complete update</strong>. I have only reviewed or modified <strong>some</strong> of the information in this record."
			TXT_NOTIFICATIONS = "Notifications"
			TXT_NOTIFY_ADMIN = "Notify Record Administrator?"
			TXT_NOTIFY_AGENCY = "Notify Agency?"
			TXT_QUESTIONS_CONTACT = "If you have any questions or concerns, please contact "
			TXT_READ_INCLUSION = "Please read our <a href=""javascript:openWin('" & makeLinkB("inclusion.asp") & "','incPolicy')"">Record Inclusion Policy</a> before suggesting a new record."
			TXT_RECORD_BE_UPDATED_IN = "be updated in "
			TXT_RECORD_FEEDBACK = "Record Feedback"
			TXT_REMOVE_RECORD = "This record is no longer valid. <strong>Please remove</strong>."
			TXT_REVIEW_NEW_EMAIL = "For Review: New Email address given for your record in "
			TXT_REVIEW_TERMS_OF_USE = "Review our <em>Terms of Use</em> Policy"
			TXT_REVIEW_UPDATES = "For Review: Updates to your record in "
			TXT_SOURCE_OF_INFO = "Source of this Information"
			TXT_SPECIAL_INSTRUCTIONS = "Special Instructions"
			TXT_SUBMITTED_FEEDBACK_1_NAME = " submitted"
			TXT_SUBMITTED_FEEDBACK_1_SOMEONE = "Someone submitted"
			TXT_SUBMITTED_FEEDBACK_1_YOU = "You submitted"
			TXT_SUBMITTED_FEEDBACK_2 = " feedback suggesting that the entry"
			TXT_SUGGEST_CHANGES_FOR = "Suggest Changes For" & TXT_COLON
			TXT_SUGGEST_NEW_RECORD = "Suggest New Record"
			TXT_SUMMARY_OF_CHANGES = "The following is a summary of the suggested changes to field(s) in the database" & TXT_COLON
			TXT_THANKS_FOR_FEEDBACK = "Thank you for your feedback"
			TXT_UNABLE_SAVE_FEEDBACK = "We were unable to save your feedback" & TXT_COLON
			TXT_VOL_HOURS = "(hours)"
			TXT_VOL_HOURS_PER = "(hours per)"
			TXT_VOL_ON_OR_AFTER = "(On or after)"
			TXT_VOL_ON_OR_BEFORE = "(On or before)"
			TXT_VOL_SCHEDULE_NOTES = "Schedule Notes"
			TXT_VOL_YOU_ARE_SUGGESTING_FOR = "You are suggesting a new record for the organization:"
			TXT_WE_APPRECIATE = "We appreciate your time and efforts in keeping the database current. The information you submit will be reviewed by "
			TXT_YOU_MAY_SUGGEST_LANGUAGE = "You may use this form to suggest a new English-language version of this record."
			TXT_YOUR = "Your "
	End Select
End Sub

Call setTxtFeedback()
Call addTextFile("setTxtFeedback")
%>
