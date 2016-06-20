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
Dim TXT_BLOCKED_BY_PRIVACY_PROFILE, _
	TXT_IF_YOU_DONT_HAVE_ROOM, _
	TXT_MAIL_FAX_FORM, _
	TXT_SIGNATURE, _
	TXT_YOU_CAN_CONTACT_US

Sub setTxtMailForm()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_BLOCKED_BY_PRIVACY_PROFILE = "The contents of this field are listed as private."
			TXT_IF_YOU_DONT_HAVE_ROOM = "If you do not have enough room on the form below to make the necessary changes, you may include additional pages."
			TXT_MAIL_FAX_FORM = "Mail / Fax Form"
			TXT_SIGNATURE = "Signature"
			TXT_YOU_CAN_CONTACT_US = "You can contact us or submit changes to this information" & TXT_COLON
		Case CULTURE_FRENCH_CANADIAN
			TXT_BLOCKED_BY_PRIVACY_PROFILE = "Les contenus de ce champ sont confidentiels."
			TXT_IF_YOU_DONT_HAVE_ROOM = "Si l'espace dans le formulaire ci-dessous est insuffisant pour faire toutes les modifications nécessaires, vous pouvez y ajouter des pages supplémentaires."
			TXT_MAIL_FAX_FORM = "Formulaire d'envoi par la poste ou par télécopieur"
			TXT_SIGNATURE = "Signature"
			TXT_YOU_CAN_CONTACT_US = "Vous pouvez communiquer avec nous ou soumettre des changements à cette information" & TXT_COLON
	End Select
End Sub

Call setTxtMailForm()
%>
