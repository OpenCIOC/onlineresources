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
Dim TXT_CHECKLISTS, _
	TXT_CHK_ACCESSIBILITY, _
	TXT_CHK_BILLING_ADDRESS_TYPE, _
	TXT_CHK_BOX_TYPE, _
	TXT_CHK_BUS_ROUTE, _
	TXT_CHK_COMMITMENT_LENGTH, _
	TXT_CHK_CONTACT_HONORIFIC, _
	TXT_CHK_CONTACT_PHONE_TYPE, _
	TXT_CHK_CURRENCY, _
	TXT_CHK_DISTRIBUTION, _
	TXT_CHK_EXTRA_CHECKLIST, _
	TXT_CHK_EXTRA_DROPDOWN, _
	TXT_CHK_FEES, _
	TXT_CHK_FISCAL_YEAR_END, _
	TXT_CHK_FUNDING, _
	TXT_CHK_INTERACTION_LEVEL, _
	TXT_CHK_LANGUAGE, _
	TXT_CHK_MEMBERSHIP_TYPE, _
	TXT_CHK_NOTE_TYPE, _
	TXT_CHK_PAYMENT_METHOD, _
	TXT_CHK_PAYMENT_TERMS, _
	TXT_CHK_RECORD_QUALITY, _
	TXT_CHK_RECORD_TYPE, _
	TXT_CHK_SCHOOL, _
	TXT_CHK_SEASONS, _	
	TXT_CHK_SERVICELEVEL, _
	TXT_CHK_SKILLS, _
	TXT_CHK_STREETTYPE, _
	TXT_CHK_SUITABILITY, _
	TXT_CHK_TRAINING, _
	TXT_CHK_TRANSPORTATION, _
	TXT_CHK_TYPE_OF_CARE, _
	TXT_CHK_TYPE_OF_PROGRAM, _
	TXT_CHK_VACANCY_SCHEDULE_TYPE, _
	TXT_CHK_VACANCY_SERVICE_TITLE, _
	TXT_CHK_VACANCY_TARGET_POPULATION, _
	TXT_CHK_VACANCY_UNIT_TYPE, _
	TXT_CHK_WARD, _
	TXT_DEFAULT, _
	TXT_EDIT_VALUES_FOR_LIST, _
	TXT_INST_SHARED_LISTS, _
	TXT_MAPPING_SYSTEMS, _
	TXT_SCHOOL_BOARD, _
	TXT_SCHOOL_INFO

Sub setTxtChecklist()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_CHECKLISTS = "Checklists"
			TXT_CHK_ACCESSIBILITY = "Accessibility"
			TXT_CHK_BILLING_ADDRESS_TYPE = "Billing Address Type"
			TXT_CHK_BOX_TYPE = "Postal Box Type"
			TXT_CHK_BUS_ROUTE = "Bus Route"
			TXT_CHK_COMMITMENT_LENGTH = "Commitment Length"
			TXT_CHK_CONTACT_HONORIFIC = "Contact Honorific"
			TXT_CHK_CONTACT_PHONE_TYPE = "Contact Phone Type"
			TXT_CHK_CURRENCY = "Currency"
			TXT_CHK_DISTRIBUTION = "Distribution"
			TXT_CHK_EXTRA_CHECKLIST = "&quot;Extra&quot; Checklist"
			TXT_CHK_EXTRA_DROPDOWN = "&quot;Extra&quot; Drop-Down"
			TXT_CHK_FEES = "Fees"
			TXT_CHK_FISCAL_YEAR_END = "Fiscal Year End"
			TXT_CHK_FUNDING = "Funding"
			TXT_CHK_INTERACTION_LEVEL = "Interaction Level"
			TXT_CHK_LANGUAGE = "Language"
			TXT_CHK_MEMBERSHIP_TYPE = "Membership Type"
			TXT_CHK_NOTE_TYPE = "Note Type"
			TXT_CHK_PAYMENT_METHOD = "Payment Method"
			TXT_CHK_PAYMENT_TERMS = "Payment Terms"
			TXT_CHK_RECORD_QUALITY = "Record Quality"
			TXT_CHK_RECORD_TYPE = "Record Type"
			TXT_CHK_SCHOOL = "School"
			TXT_CHK_SEASONS = "Seasons"
			TXT_CHK_SERVICELEVEL = "Service Level"
			TXT_CHK_SKILLS = "Skills / Experience"
			TXT_CHK_STREETTYPE = "Street Type"
			TXT_CHK_SUITABILITY = "Suitable for"
			TXT_CHK_TRAINING = "Training"
			TXT_CHK_TRANSPORTATION = "Transportation"
			TXT_CHK_TYPE_OF_CARE = "Type of Care"
			TXT_CHK_TYPE_OF_PROGRAM = "Type of Program"
			TXT_CHK_VACANCY_SCHEDULE_TYPE = "Schedule Type"
			TXT_CHK_VACANCY_SERVICE_TITLE = "Service Title"
			TXT_CHK_VACANCY_TARGET_POPULATION = "Target Population"
			TXT_CHK_VACANCY_UNIT_TYPE = "Unit Type"
			TXT_CHK_WARD = "Ward"
			TXT_DEFAULT = "Default"
			TXT_EDIT_VALUES_FOR_LIST = "Edit Values for Checklist" & TXT_COLON
			TXT_INST_SHARED_LISTS = "Shared items are used across different CIOC modules (CIC and Volunteer)." & _
				"<br>Please be courteous and talk to your database partners (if any) before modifying shared items."
			TXT_MAPPING_SYSTEMS = "Mapping Systems"
			TXT_SCHOOL_BOARD = "School Board"
			TXT_SCHOOL_INFO = "School Information"
		Case CULTURE_FRENCH_CANADIAN
			TXT_CHECKLISTS = "Listes de contrôle"
			TXT_CHK_ACCESSIBILITY = "Accessibilité"
			TXT_CHK_BILLING_ADDRESS_TYPE = "Type d'adresse de facturation"
			TXT_CHK_BOX_TYPE = "Types de case postale"
			TXT_CHK_BUS_ROUTE = "Ligne de bus"
			TXT_CHK_COMMITMENT_LENGTH = "Durée d'engagement"
			TXT_CHK_CONTACT_HONORIFIC = "Titres honorifiques des contacts"
			TXT_CHK_CONTACT_PHONE_TYPE = "Types de téléphone des contacts"
			TXT_CHK_CURRENCY = "Devise"
			TXT_CHK_DISTRIBUTION = "Distribution"
			TXT_CHK_EXTRA_CHECKLIST = "Liste de contrôle &quot;supplémentaire&quot;"
			TXT_CHK_EXTRA_DROPDOWN = "Liste déroulante &quot;supplémentaire&quot;"
			TXT_CHK_FEES = "Honoraires"
			TXT_CHK_FISCAL_YEAR_END = "Fin de l'année fiscale"
			TXT_CHK_FUNDING = "Bailleurs de fonds"
			TXT_CHK_INTERACTION_LEVEL = "Niveau d'interaction"
			TXT_CHK_LANGUAGE = "Langue"
			TXT_CHK_MEMBERSHIP_TYPE = "Type de membriété"
			TXT_CHK_NOTE_TYPE = "Type de note"
			TXT_CHK_PAYMENT_METHOD = "Méthode de paiement"
			TXT_CHK_PAYMENT_TERMS = "Modalités de paiement"
			TXT_CHK_RECORD_QUALITY = "Qualité du dossier"
			TXT_CHK_RECORD_TYPE = "Type de dossier"
			TXT_CHK_VACANCY_SCHEDULE_TYPE = "Type d'horaire"
			TXT_CHK_SCHOOL = "École"
			TXT_CHK_SEASONS = "Saisons"
			TXT_CHK_SERVICELEVEL = "Niveau de service"
			TXT_CHK_SKILLS = "Compétences / expérience"
			TXT_CHK_STREETTYPE = "Type de rue"
			TXT_CHK_SUITABILITY = "Convient pour"
			TXT_CHK_TRAINING = "Formation"
			TXT_CHK_TRANSPORTATION = "Transport"
			TXT_CHK_TYPE_OF_CARE = "Type de garde"
			TXT_CHK_TYPE_OF_PROGRAM = "Type de programme"
			TXT_CHK_VACANCY_SERVICE_TITLE = "Nom du service"
			TXT_CHK_VACANCY_TARGET_POPULATION = "Public cible"
			TXT_CHK_VACANCY_UNIT_TYPE = "Type d'unité"
			TXT_CHK_WARD = "Quartier"
			TXT_DEFAULT = "Défaut"
			TXT_EDIT_VALUES_FOR_LIST = "Modifier les valeurs de la liste de contrôle" & TXT_COLON
			TXT_INST_SHARED_LISTS = "Éléments partagés sont utilisés dans différents modules du CIOC (CIC et Bénévolat)." & _
				"<br>Veuillez communiquer avec vos partenaires (s'il y a lieu) avant de modifier les éléments partagés."
			TXT_MAPPING_SYSTEMS = "Systèmes cartographiques"
	End Select
End Sub

Call setTxtChecklist()
%>
