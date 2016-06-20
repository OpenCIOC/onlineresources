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
Dim TXT_AFTER_HRS_PHONE, _
	TXT_BOLD_FIELD, _
	TXT_CRISIS_PHONE, _
	TXT_DOT_LEADER, _
	TXT_EXPIRED_RECORDS, _
	TXT_FAX, _
	TXT_FIELD_DATA_WIDTH, _
	TXT_FONT_FAMILY, _
	TXT_FONT_SIZE, _
	TXT_FOR_WEB, _
	TXT_FOR_WORD, _
	TXT_FORMAT_FOR, _
	TXT_FURTHER_LIMIT_SELECTION, _
	TXT_INCLUDE_CROSS_REF, _
	TXT_INCLUDE_FIELDS, _
	TXT_INST_CUSTOMIZE, _
	TXT_INST_DOT_LEADER, _
	TXT_INST_NAME_INDEX, _
	TXT_INST_SUBJECT_INDEX, _
	TXT_LABEL_AS, _
	TXT_LIMIT_FIELD, _
	TXT_MESSAGE, _
	TXT_NAME_INDEX, _
	TXT_NO_PROFILE_CHOSEN, _
	TXT_NO_RECORDS_TO_PRINT, _
	TXT_OFFICE_PHONE, _
	TXT_PRINT_RECORD_LIST, _
	TXT_SEE, _
	TXT_SEE_ALSO, _
	TXT_SORT_BY, _
	TXT_SUBJECT_INDEX, _
	TXT_TDD_PHONE, _
	TXT_TOLL_FREE_PHONE

Sub setTxtPrintList()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_AFTER_HRS_PHONE = "After Hours" & TXT_COLON
			TXT_BOLD_FIELD = "Apply Bold Formatting"
			TXT_CRISIS_PHONE = "Crisis" & TXT_COLON
			TXT_DOT_LEADER = "Dot Leaders"
			TXT_EXPIRED_RECORDS = "Expired Records"
			TXT_FAX = "Fax" & TXT_COLON
			TXT_FIELD_DATA_WIDTH = "Field Data Width"
			TXT_FONT_SIZE = "Font Size"
			TXT_FONT_FAMILY = "Font Family"
			TXT_FOR_WEB = "printing online"
			TXT_FOR_WORD = "use in Microsoft Word"
			TXT_FORMAT_FOR = "Format Output For"
			TXT_FURTHER_LIMIT_SELECTION = "Further limit your selection using" & TXT_COLON
			TXT_INCLUDE_FIELDS = "Include Fields"
			TXT_INCLUDE_CROSS_REF = "Include Cross-Reference Names"
			TXT_INST_CUSTOMIZE = "Use this form to customize print options"
			TXT_INST_DOT_LEADER = "Include Dot Leaders"
			TXT_INST_NAME_INDEX = "Use this form to generate a Name Index"
			TXT_INST_SUBJECT_INDEX = "Use this form to generate a Subject Index"
			TXT_LABEL_AS = "Label" & TXT_COLON
			TXT_LIMIT_FIELD = "Records must have data in at least one of the selected fields"
			TXT_MESSAGE = "Report Message"
			TXT_NAME_INDEX = "Name Index"
			TXT_NO_PROFILE_CHOSEN = "No Print Profile was chosen."
			TXT_NO_RECORDS_TO_PRINT = "No records were chosen to print."
			TXT_OFFICE_PHONE = "Office" & TXT_COLON
			TXT_PRINT_RECORD_LIST = "Print Record List"
			TXT_SEE = "See"
			TXT_SEE_ALSO = "See&nbsp;Also"
			TXT_SORT_BY = "Sort By"
			TXT_SUBJECT_INDEX = "Subject Index"
			TXT_TDD_PHONE = "TTY/TDD" & TXT_COLON
			TXT_TOLL_FREE_PHONE = "Toll Free" & TXT_COLON
		Case CULTURE_FRENCH_CANADIAN
			TXT_AFTER_HRS_PHONE = "Tél. après fermeture" & TXT_COLON
			TXT_BOLD_FIELD = "Utilisez une mise en forme de caractères gras"
			TXT_CRISIS_PHONE = "Tél. d'urgence" & TXT_COLON
			TXT_DOT_LEADER = "Ligne de points"
			TXT_EXPIRED_RECORDS = "Dossiers expirés"
			TXT_FAX = "Télécopieur" & TXT_COLON
			TXT_FIELD_DATA_WIDTH = "Largeur du champs des données"
			TXT_FONT_SIZE = "Grandeur de la police"
			TXT_FONT_FAMILY = "Famille de police"
			TXT_FOR_WEB = "imprimer en ligne"
			TXT_FOR_WORD = "l'usage dans le Microsoft Word"
			TXT_FORMAT_FOR = "Composer le résultat pour"
			TXT_FURTHER_LIMIT_SELECTION = "D'autres limites à votre sélection" & TXT_COLON
			TXT_INCLUDE_CROSS_REF = "Inclure les noms de renvois réciproques"
			TXT_INCLUDE_FIELDS = "Inclure les champs"
			TXT_INST_CUSTOMIZE = "Utiliser ce formulaire pour personnaliser les options d'impression"
			TXT_INST_DOT_LEADER = "Inclure les lignes de points"
			TXT_INST_NAME_INDEX = "Utilisez ce formulaire pour générer un index des noms."
			TXT_INST_SUBJECT_INDEX = "Utilisez ce formulaire pour générer un index des sujets."
			TXT_LABEL_AS = "Label" & TXT_COLON
			TXT_LIMIT_FIELD = "Les dossiers doivent avoir des données dans au moins un des champs sélectionnés."
			TXT_MESSAGE = "Message de rapport"
			TXT_NAME_INDEX = "Index des noms"
			TXT_NO_PROFILE_CHOSEN = "Aucun profil d'impression n'a été choisi."
			TXT_NO_RECORDS_TO_PRINT = "Aucun dossier n'a été choisi pour impression."
			TXT_OFFICE_PHONE = "Tél. de bureau" & TXT_COLON
			TXT_PRINT_RECORD_LIST = "Imprimer la liste des dossiers"
			TXT_SEE = "Voir"
			TXT_SEE_ALSO = "Voir également"
			TXT_SORT_BY = "Trier par"
			TXT_SUBJECT_INDEX = "Index des sujets"
			TXT_TDD_PHONE = "Tél. ATS-ATME" & TXT_COLON
			TXT_TOLL_FREE_PHONE = "Tél. sans frais" & TXT_COLON
	End Select
End Sub

Call setTxtPrintList()

%>
