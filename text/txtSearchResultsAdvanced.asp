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
Dim TXT_ALL_AVAILABLE_RECORDS, _
	TXT_CUSTOM_SEARCH, _
	TXT_DELETED_EXCLUDED, _
	TXT_EXPIRED_EXCLUDED, _
	TXT_WARNING_ADD_SQL, _
	TXT_WARNING_EMAIL_DATE

Sub setTxtSearchResultsAdvanced()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ALL_AVAILABLE_RECORDS = "all available records"
			TXT_CUSTOM_SEARCH = "custom search"
			TXT_DELETED_EXCLUDED = "excluding deleted records"
			TXT_EXPIRED_EXCLUDED = "excluding expired records"
			TXT_WARNING_ADD_SQL = "Add SQL criteria was ignored; You do not have sufficient security permissions."
			TXT_WARNING_EMAIL_DATE = "Last Email Update Request criteria was ignored" & TXT_COLON
		Case CULTURE_FRENCH_CANADIAN
			TXT_ALL_AVAILABLE_RECORDS = "tous les dossiers disponibles"
			TXT_CUSTOM_SEARCH = "recherche personnalisée"
			TXT_DELETED_EXCLUDED = "les dossiers supprimés sont exclus"
			TXT_EXPIRED_EXCLUDED = "les dossiers qui ont expiré en sont exclus"
			TXT_WARNING_ADD_SQL = TXT_WARNING & "La demande d'ajout de critères SQL a été ignorée; vous n'avez pas tous les droits d'accès sécuritaires requis."
			TXT_WARNING_EMAIL_DATE = "Les critères relatifs à la dernière demande de mise à jour par courriel ont été ignorés" & TXT_COLON
		End Select
End Sub

Call setTxtSearchResultsAdvanced()
%>
