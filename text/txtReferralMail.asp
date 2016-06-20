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
Dim TXT_CUSTOMIZE_REFERRAL_FOLLOW_UP_MAIL, _
	TXT_LIST_OF_REFERRALS_PLACEHOLDER, _
	TXT_MESSAGE_CLOSING, _
	TXT_MESSAGE_OPENING, _
	TXT_MESSAGE_OPENING_REQUIRED, _
	TXT_MESSAGE_SUBJECT_REQUIRED, _
	TXT_POSITION, _
	TXT_PREVIEW_REFERRAL_FOLLOW_UP_MAIL, _
	TXT_REFERRAL_DETAILS_PLACEHOLDER, _
	TXT_REFERRAL_INFORMATION, _
	TXT_UNABLE_TO_DETERMINE_RECIPIENT, _
	TXT_UNABLE_TO_SEND_MESSAGES, _
	TXT_YOU_ARE_EMAILING_FOLLOW_UP_REQUEST_FOR

Sub setTxtReferralMail()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_CUSTOMIZE_REFERRAL_FOLLOW_UP_MAIL = "Personnaliser le courriel de suivi de mise en relation"
			TXT_LIST_OF_REFERRALS_PLACEHOLDER = "[LIST OF REFERRALS]"
			TXT_MESSAGE_CLOSING = "Conclusion du message"
			TXT_MESSAGE_OPENING = "Introduction du message"
			TXT_MESSAGE_OPENING_REQUIRED = "Une introduction au message est nécessaire."
			TXT_MESSAGE_SUBJECT_REQUIRED = "Une conclusion au message est nécessaire."
			TXT_POSITION = "Poste :"
			TXT_PREVIEW_REFERRAL_FOLLOW_UP_MAIL = "Prévisualiser le courriel de suivi pour la mise en relation"
			TXT_REFERRAL_DETAILS_PLACEHOLDER = "[REFERRAL DETAILS]"
			TXT_REFERRAL_INFORMATION = "Information sur la mise en relation"
			TXT_UNABLE_TO_DETERMINE_RECIPIENT = "Le type de destinataire n'a pas pu être déterminé (organisme ou bénévole)"
			TXT_UNABLE_TO_SEND_MESSAGES = "Le ou les messages n'ont pas pu être envoyés :"
			TXT_YOU_ARE_EMAILING_FOLLOW_UP_REQUEST_FOR = "Vous envoyez par courriel une demande de suivi pour les mises en relation suivantes :"
		Case Else
			TXT_CUSTOMIZE_REFERRAL_FOLLOW_UP_MAIL = "Customize Referral Follow-Up Email"
			TXT_LIST_OF_REFERRALS_PLACEHOLDER = "[LIST OF REFERRALS]"
			TXT_MESSAGE_CLOSING = "Message Closing"
			TXT_MESSAGE_OPENING = "Message Opening"
			TXT_MESSAGE_OPENING_REQUIRED = "A Message Opening is required."
			TXT_MESSAGE_SUBJECT_REQUIRED = "A Message Subject is required."
			TXT_POSITION = "Position:"
			TXT_PREVIEW_REFERRAL_FOLLOW_UP_MAIL = "Preview Referral Follow-Up Email"
			TXT_REFERRAL_DETAILS_PLACEHOLDER = "[REFERRAL DETAILS]"
			TXT_REFERRAL_INFORMATION = "Referral Information"
			TXT_UNABLE_TO_DETERMINE_RECIPIENT = "Unable to determine type of recipient (Organization or Volunteer)"
			TXT_UNABLE_TO_SEND_MESSAGES = "Unable to send message(s):"
			TXT_YOU_ARE_EMAILING_FOLLOW_UP_REQUEST_FOR = "You are emailing a follow-up request for the following referrals:"
	End Select
End Sub

Call setTxtReferralMail()
%>
