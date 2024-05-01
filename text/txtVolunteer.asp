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
Dim TXT_AT_NOSPACE, _
	TXT_DUTIES_DESCRIBED_AS, _
	TXT_DISPLAY_POSITION_DUTIES, _
	TXT_CONTACT_REQUIRED, _
	TXT_CREATE_A_PROFILE_NEW, _
	TXT_DO_YOU_HAVE_PROFILE, _
	TXT_FROM, _
	TXT_HAS_EXPIRED, _
	TXT_INFORMATION_EMAILED_TO, _
	TXT_INFORMATION_ALSO_SENT_TO, _
	TXT_INST_DIFFICULTIES_CONTACT, _
	TXT_INST_FILL_FORM, _
	TXT_INST_NOTES_1, _
	TXT_INST_NOTES_2, _
	TXT_LOGIN_TO_YOUR_VOLUNTEER_PROFILE, _
	TXT_NAME_REQUIRED, _
	TXT_NOTES_COMMENTS, _
	TXT_OPTIONAL_SURVEY, _
	TXT_ORG_SUBJECT, _
	TXT_OTHER_INFO, _
	TXT_PROBLEM_EMAIL, _
	TXT_RESPONDED_TO_THE_LISTING, _
	TXT_SOMEONE, _
	TXT_SUBMITTING_INFORMATION_FOR, _
	TXT_SUPPLIED_QUESTONS, _
	TXT_SURVEY_DISCLAIMER_1, _
	TXT_SURVEY_DISCLAIMER_2, _
	TXT_THEY_PROVIDED_INFORMATION, _
	TXT_TO_DISCUSS_THIS_OPP, _
	TXT_TO_DISCUSS_THIS_OPP_AT, _
	TXT_UNABLE_TO_CREATE_RECORD_OF_REQUEST, _
	TXT_VOL_EMAIL_SUBJECT, _
	TXT_VOL_NOTICE, _
	TXT_VOL_THANK_YOU, _
	TXT_VOL_THANK_YOU_INTEREST, _
	TXT_VOLUNTEER_FORM, _
	TXT_VOLUNTEER_SUBMISSION, _
	TXT_YOU, _
	TXT_YOU_CAN_CONTACT, _
	TXT_YOU_CAN_VIEW_LISTING

Sub setTxtVolunteer()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_AT_NOSPACE = "à"
			TXT_DUTIES_DESCRIBED_AS = "où les fonctions sont décrites ainsi :"
			TXT_CONTACT_REQUIRED = "Vous devez fournir un téléphone, un courriel ou une adresse afin que nous puissions vous contacter.<br>Veuillez utiliser le bouton Retour pour revenir au formulaire."
			TXT_CREATE_A_PROFILE_NEW = "créer un nouveau profil"
			TXT_DO_YOU_HAVE_PROFILE = "Avez-vous un profil de bénévole ?"
			TXT_FROM = "de"
			TXT_HAS_EXPIRED = "a expiré."
			TXT_INFORMATION_EMAILED_TO = "L'information que vous avez fournie a été envoyée par courriel à :"
			TXT_INFORMATION_ALSO_SENT_TO = "Cette information a également été envoyée à :"
			TXT_INST_DIFFICULTIES_CONTACT = "Si vous rencontrez des difficultés pour soumettre ce formulaire, vous pouvez nous contacter :"
			TXT_INST_FILL_FORM = "Veuillez spécifier votre <strong>nom</strong>, votre <strong>ville</strong> et une manière de vous contacter : <strong>courriel</strong> or <strong>téléphone</strong>."
			TXT_INST_NOTES_1 = "S'il y a des notes spécifiques que vous souhaitez communiquer à"
			TXT_INST_NOTES_2 = "veuillez les saisir ici :"
			TXT_LOGIN_TO_YOUR_VOLUNTEER_PROFILE = "Ouvrir une session à votre profil de bénévole maintenant"
			TXT_NAME_REQUIRED = "Vous devez fournir votre nom.<br>Veuillez utiliser le bouton Retour pour revenir au formulaire."
			TXT_NOTES_COMMENTS = "Notes/Commentaires"
			TXT_OPTIONAL_SURVEY = "Enquête facultative"
			TXT_ORG_SUBJECT = "Un bénévole pour :"
			TXT_OTHER_INFO = "Informations Complémentaires"
			TXT_PROBLEM_EMAIL = "Un problème est survenu lors de l'envoi d'un courriel à"
			TXT_RESPONDED_TO_THE_LISTING = "avez répondu à l'inscription pour"
			TXT_SOMEONE = "Quelqu'un"
			TXT_SUBMITTING_INFORMATION_FOR = "Vous soumettez des informations pour le poste :"
			TXT_SUPPLIED_QUESTONS = " a demandé les informations supplémentaires suivantes :"
			TXT_SURVEY_DISCLAIMER_1 = "Nous apprécions votre temps pour nous fournir des informations supplémentaires pour nous aider à comprendre et à améliorer notre service. Les informations de cette section ne seront pas envoyées à "
			TXT_SURVEY_DISCLAIMER_2 = ", et n'est pas connecté à vos informations personnelles."
			TXT_THEY_PROVIDED_INFORMATION = "Ils ont fourni les renseignements suivants :"
			TXT_TO_DISCUSS_THIS_OPP = "Pour discuter de cette occasion, veuillez contacter"
			TXT_TO_DISCUSS_THIS_OPP_AT = "pour discuter de cette occasion à :"
			TXT_UNABLE_TO_CREATE_RECORD_OF_REQUEST = "Nous n'avons pas pu créer de dossier pour cette demande. Veuillez communiquer avec nous par téléphone."
			TXT_VOL_EMAIL_SUBJECT = "Merci pour votre intérêt dans le bénévolat"
			TXT_VOL_NOTICE = "Préavis du bénévole"
			TXT_VOL_THANK_YOU = "Merci pour votre intérêt dans le bénévolat !"
			TXT_VOL_THANK_YOU_INTEREST = "Merci de préciser votre intérêt pour le poste :"
			TXT_VOLUNTEER_FORM = "Formulaire de bénévole"
			TXT_VOLUNTEER_SUBMISSION = "Soumission du bénévole"
			TXT_YOU = "Vous"
			TXT_YOU_CAN_CONTACT = "Vous pouvez contacter"
			TXT_YOU_CAN_VIEW_LISTING = "Vous pouvez voir la liste actuelle sur :"
		Case Else
			TXT_AT_NOSPACE = "at"
			TXT_DUTIES_DESCRIBED_AS = "where the duties were described as:"
			TXT_DISPLAY_POSITION_DUTIES = "Display the position duties"
			TXT_CONTACT_REQUIRED = "You must provide a phone, Email, or address so we can contact you.<br>Please use your back button to return to the form."
			TXT_CREATE_A_PROFILE_NEW = "create a new Profile"
			TXT_DO_YOU_HAVE_PROFILE = "Do you have a Volunteer Profile?"
			TXT_FROM = "from"
			TXT_HAS_EXPIRED = "has expired."
			TXT_INFORMATION_EMAILED_TO = "The information you provided was Emailed to:"
			TXT_INFORMATION_ALSO_SENT_TO = "This information was also sent to:"
			TXT_INST_DIFFICULTIES_CONTACT = "If you have any difficulties submitting this form, you can contact us:"
			TXT_INST_FILL_FORM = "Please fill in your <strong>Name</strong>, your <strong>City / Town</strong> and at least one way of contacting you: <strong>Email</strong> or <strong>Phone</strong>."
			TXT_INST_NOTES_1 = "If there is some special note you'd like to pass along to"
			TXT_INST_NOTES_2 = "please enter it here:"
			TXT_LOGIN_TO_YOUR_VOLUNTEER_PROFILE = "Login to your Volunteer Profile now"
			TXT_NAME_REQUIRED = "You must provide your name.<br>Please use your back button to return to the form."
			TXT_NOTES_COMMENTS = "Notes / Comments"
			TXT_OPTIONAL_SURVEY = "Optional Survey"
			TXT_ORG_SUBJECT = "A volunteer for:"
			TXT_OTHER_INFO = "Additional Information"
			TXT_PROBLEM_EMAIL = "There was a problem sending an Email to"
			TXT_RESPONDED_TO_THE_LISTING = "responded to the listing for the"
			TXT_SOMEONE = "Someone"
			TXT_SUBMITTING_INFORMATION_FOR = "You are submitting information for the position:"
			TXT_SUPPLIED_QUESTONS = " has requested the following additional information:"
			TXT_SURVEY_DISCLAIMER_1 = "We appreciate your time in providing additional information to help us understand and improve our service. Information in this section will not be sent to "
			TXT_SURVEY_DISCLAIMER_2 = ", and is not connected to your personal information."
			TXT_THEY_PROVIDED_INFORMATION = "They provided the following information:"
			TXT_TO_DISCUSS_THIS_OPP = "To discuss this opportunity, please contact"
			TXT_TO_DISCUSS_THIS_OPP_AT = "to discuss this opportunity at:"
			TXT_UNABLE_TO_CREATE_RECORD_OF_REQUEST = "We were unable to create a record of this request. Please contact us by phone."
			TXT_VOL_EMAIL_SUBJECT = "Thank you for your interest in volunteering"
			TXT_VOL_NOTICE = "Volunteer Notice"
			TXT_VOL_THANK_YOU = "Thank you for your interest in Volunteering!"
			TXT_VOL_THANK_YOU_INTEREST = "Thank you for indicating your interest in the position:"
			TXT_VOLUNTEER_FORM = "Volunteer Form"
			TXT_VOLUNTEER_SUBMISSION = "Volunteer Submission"
			TXT_YOU = "You"
			TXT_YOU_CAN_CONTACT = "You can contact"
			TXT_YOU_CAN_VIEW_LISTING = "You can view the current listing at:"
	End Select
End Sub

Call setTxtVolunteer()
%>
