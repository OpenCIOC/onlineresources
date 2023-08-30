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
Dim TXT_ALL_RECORDS, _
	TXT_CAN_UPDATE_EMAIL, _
	TXT_CANNOT_UPDATE_EMAIL, _
	TXT_DAYS_SINCE_EMAIL_REQUESTING_UPDATE, _
	TXT_DELETED_STATUS, _
	TXT_DISPLAY_SEARCH_DETAILS, _
	TXT_DOES_NOT_HAVE, _
	TXT_EXCLUDE_VALUES, _
	TXT_HAS_ALL_FROM, _
	TXT_HAS_ANY_FROM, _
	TXT_HAS_EQUIVALENT, _
	TXT_HAS_NO_EQUIVALENT, _
	TXT_HAS_NONE, _
	TXT_INCLUDE, _
	TXT_INCLUDE_DELETED, _
	TXT_INCLUDE_EXPIRED, _
	TXT_INCLUDE_VALUES, _
	TXT_INST_RECORD_NUM, _
	TXT_LAST_EMAIL_UPDATE, _
	TXT_NO_MORE_THAN, _
	TXT_MORE_THAN, _
	TXT_MY_SHARING_PROFILES, _
	TXT_NOT_CONTAINS, _
	TXT_ONLY_EMAIL, _
	TXT_ONLY_MINE, _
	TXT_ONLY_NO_EMAIL, _
	TXT_ONLY_NONPUBLIC, _
	TXT_ONLY_NOT_MINE, _
	TXT_ONLY_PUBLIC, _
	TXT_PUBLIC_STATUS, _
	TXT_SHARED_RECORDS, _
	TXT_SQL

Sub setTxtSearchAdvanced()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ALL_RECORDS = "All&nbsp;Records"
			TXT_CAN_UPDATE_EMAIL = "Can send update requests"
			TXT_CANNOT_UPDATE_EMAIL = "Cannot send update requests"
			TXT_DAYS_SINCE_EMAIL_REQUESTING_UPDATE = "Days since last email requesting update"			
			TXT_DELETED_STATUS = "Deleted&nbsp;Status"
			TXT_DISPLAY_SEARCH_DETAILS = "Display the details of my search"
			TXT_DOES_NOT_HAVE = "Does not have" & TXT_COLON
			TXT_EXCLUDE_VALUES = "Exclude"
			TXT_HAS_ALL_FROM = "Has all from" & TXT_COLON
			TXT_HAS_ANY_FROM = "Has any from" & TXT_COLON
			TXT_HAS_EQUIVALENT = "Has Equivalent Record"
			TXT_HAS_NO_EQUIVALENT = "Has <strong>no</strong> Equivalent Record"
			TXT_HAS_NONE = "Has none"
			TXT_INCLUDE = "Include"
			TXT_INCLUDE_VALUES = "Include"
			TXT_INCLUDE_DELETED = "Include deleted records"
			TXT_INCLUDE_EXPIRED = "Include expired records"
			TXT_INST_RECORD_NUM = "You may list multiple Record #'s"
			TXT_LAST_EMAIL_UPDATE = "Last Email Requesting&nbsp;Update"
			TXT_MORE_THAN = "More&nbsp;than"
			TXT_MY_SHARING_PROFILES = "My Sharing Profiles"
			TXT_NO_MORE_THAN = "no more than"
			TXT_NOT_CONTAINS = "Does&nbsp;not&nbsp;contain"
			TXT_ONLY_EMAIL = "Only&nbsp;with&nbsp;Email"
			TXT_ONLY_MINE = "Only "
			TXT_ONLY_NO_EMAIL = "Only&nbsp;without&nbsp;Email"
			TXT_ONLY_NONPUBLIC = "Only&nbsp;Non-Public"
			TXT_ONLY_NOT_MINE = "NOT "
			TXT_ONLY_PUBLIC = "Only&nbsp;Public"
			TXT_PUBLIC_STATUS = "Public&nbsp;Status"
			TXT_SHARED_RECORDS = "Shared Records"
			TXT_SQL = "SQL"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ALL_RECORDS = "Tous&nbsp;les&nbsp;dossiers"
			TXT_CAN_UPDATE_EMAIL = "Peut envoyer des demandes de mise à jour"
			TXT_CANNOT_UPDATE_EMAIL = "Ne peut pas envoyer de demandes de mise à jour"
			TXT_DAYS_SINCE_EMAIL_REQUESTING_UPDATE = "TR_FR -- Days since last email requesting update"			
			TXT_DELETED_STATUS = "Statut supprimé"
			TXT_DISPLAY_SEARCH_DETAILS = "Afficher les détails de ma recherche"
			TXT_DOES_NOT_HAVE = "N'a pas de" & TXT_COLON
			TXT_EXCLUDE_VALUES = "Exclure les valeurs"
			TXT_HAS_ALL_FROM = "Avec tous" & TXT_COLON
			TXT_HAS_NONE = "Aucun"
			TXT_INCLUDE = "Inclure les"
			TXT_HAS_ANY_FROM = "Avec l'un de" & TXT_COLON
			TXT_HAS_EQUIVALENT = "Disponible dans une autre langue"
			TXT_HAS_NO_EQUIVALENT = "Non disponible dans une autre langue"
			TXT_INCLUDE_DELETED = "Inclure les dossiers supprimés"
			TXT_INCLUDE_EXPIRED = "Inclure les dossiers expirés"
			TXT_INCLUDE_VALUES = "Inclure les valeurs"
			TXT_INST_RECORD_NUM = "Vous pouvez saisir plusieurs numéros de dossiers"
			TXT_LAST_EMAIL_UPDATE = "Dernier&nbsp;courriel demandant la&nbsp;mise&nbsp;à&nbsp;jour"
			TXT_MORE_THAN = "Plus&nbsp;de"
			TXT_MY_SHARING_PROFILES = "Mes profils de partage"
			TXT_NO_MORE_THAN = "pas plus de"
			TXT_NOT_CONTAINS = "Ne&nbsp;contient&nbsp;pas"
			TXT_ONLY_EMAIL = "Seulement&nbsp;avec&nbsp;un&nbsp;courriel"
			TXT_ONLY_MINE = "Seulement "
			TXT_ONLY_NO_EMAIL = "Seulement&nbsp;sans&nbsp;courriel"
			TXT_ONLY_NONPUBLIC = "Seulement&nbsp;les&nbsp;dossiers&nbsp;internes"
			TXT_ONLY_NOT_MINE = "PAS "
			TXT_ONLY_PUBLIC = "Seulement&nbsp;les&nbsp;dossiers&nbsp;publics"
			TXT_PUBLIC_STATUS = "Statut&nbsp;public"
			TXT_SHARED_RECORDS = "Dossiers partagés"
			TXT_SQL = "SQL"
	End Select
End Sub

Call setTxtSearchAdvanced()
%>
