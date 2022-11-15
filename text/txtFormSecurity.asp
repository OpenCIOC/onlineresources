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

Dim TXT_DAY, _
	TXT_ENTER_TOMORROWS_DATE, _
	TXT_INST_EMAIL_PHONE, _
	TXT_INST_FULL_NAME, _
	TXT_INST_SECURITY_CHECK, _
	TXT_INST_SECURITY_CHECK_2, _
	TXT_INST_SECURITY_CHECK_FAIL, _
	TXT_MONTH, _
	TXT_SECURITY_CHECK, _
	TXT_WARNING_VULGAR, _
	TXT_YEAR

Sub setTxtFormSecurity()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_DAY = "jour" & TXT_COLON
			TXT_ENTER_TOMORROWS_DATE = "Écrire la <span class=""Alert"">date de demain</span> (<strong>" & DateString(DateAdd("d",1,Date()), True) & "</strong>)" & TXT_COLON
			TXT_INST_EMAIL_PHONE = "Veuillez saisir votre adresse de courriel ou votre numéro de téléphone."
			TXT_INST_FULL_NAME = "Veuillez saisir votre prénom et nom de famille."
			TXT_INST_SECURITY_CHECK = "Avant que vos informations puissent être envoyées, nous exigeons que vous vous soumettiez à <strong>un test de protection anti-pourriel</strong>." & _
				"Si vous avez des difficultés à réussir ce test de protection, ou si vous avez besoin d'aide, retournez à ce formulaire et utilisez les coordonnées au haut de la page pour nous contacter."
			TXT_INST_SECURITY_CHECK_2 = "Si vous avez des difficultés à réussir ce test de protection, ou si vous avez besoin d'aide, retournez à ce formulaire et utilisez les coordonnées au haut de la page pour nous contacter."
			TXT_INST_SECURITY_CHECK_FAIL = "La valeur que vous avez soumise pour le test de protection n'est PAS VALIDE et vous ne pouvez pas continuez à soumettre de l'information. Veuillez essayer à nouveau."
			TXT_MONTH = "mois" & TXT_COLON
			TXT_SECURITY_CHECK = "Test de protection"
			TXT_WARNING_VULGAR = "Nous avons identifié un langage potentiellement vulgaire ou inacceptable et ne pouvons pas accepter votre mise à jour. " & _
				"Il est possible qu'une mise à jour légitime ne passe pas le test, auquel cas nous vous prions de nous contacter par téléphone afin de résoudre le problème, en utilisant les coordonnées fournies en haut du formulaire sur la page précédente. " & _
				"Nous regrettons de devoir prendre ces mesures et de censurer le contenu soumis, mais cette restriction est malheureusement nécessaire afin d'empêcher les saisies et mises à jour inacceptables qui sont envoyées à notre base de données."
			TXT_YEAR = "année" & TXT_COLON
		Case Else
			TXT_DAY = "Day" & TXT_COLON
			TXT_ENTER_TOMORROWS_DATE = "Enter <span class=""Alert"">tomorrow's</span> date (<strong>" & DateString(DateAdd("d",1,Date()), True) & "</strong>)" & TXT_COLON
			TXT_INST_EMAIL_PHONE = "Please provide us with your Email address or telephone number"
			TXT_INST_FULL_NAME = "Please provide us with your First and Last Name"
			TXT_INST_SECURITY_CHECK = "Before your information can be sent, we require that you pass the following <strong>anti-spam security check</strong>, to ensure that this form is being submitted by a real person. " & _
				"If you are having trouble passing this security check, or need other assistance, return to this form and use the contact information at the top of the page so that we may assist you."
			TXT_INST_SECURITY_CHECK_2 = "If you are having trouble passing this security check, or need other assistance, return to the form and use the contact information at the top of the page so that we may assist you."
			TXT_INST_SECURITY_CHECK_FAIL = "The value you entered for the security check was NOT VALID and you cannot yet proceed with submitting your information. Please try again."
			TXT_MONTH = "Month" & TXT_COLON
			TXT_SECURITY_CHECK = "Security Check"
			TXT_WARNING_VULGAR = "We have detected potentially vulgar or unacceptable language and cannot accept your submission. " & _
				"It is possible that a legitimate submission may fail this test, in which case we ask that you please contact us by phone to address the issue using the contact information provided at the top of the form on the previous page. " & _
				"We regret that we must take these measures and censor submitted content, but this restriction is sadly necessary to prevent unacceptable entries and updates that were being submitted to our database."
			TXT_YEAR = "Year" & TXT_COLON
	End Select
End Sub

Call setTxtFormSecurity()
%>
