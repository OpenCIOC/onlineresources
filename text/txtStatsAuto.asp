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
Dim TXT_AR_GENERATE, _
	TXT_AR_DATA_MANAGEMENT, _
	TXT_AR_RECORD_VIEW_BY_OWNER, _
	TXT_AR_RECORD_VIEW_BY_VIEW, _
	TXT_AR_UNIQUE_IP_BY_OWNER, _
	TXT_AR_UNIQUE_IP_BY_VIEW, _
	TXT_AR_UNIQUE_IP_TOTAL

Sub setTxtStatsAuto()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_AR_GENERATE = "Generate Quick Report"
			TXT_AR_DATA_MANAGEMENT = "Data Management Report"
			TXT_AR_RECORD_VIEW_BY_OWNER = "Record Views by Record Owner"
			TXT_AR_RECORD_VIEW_BY_VIEW = "Record Views by View"
			TXT_AR_UNIQUE_IP_BY_OWNER = "Number of Unique IPs by Record Owner"
			TXT_AR_UNIQUE_IP_BY_VIEW = "Number of Unique IPs by View"
			TXT_AR_UNIQUE_IP_TOTAL = "Total Number of Unique IPs"
		Case CULTURE_FRENCH_CANADIAN
			TXT_AR_GENERATE = "Générer un rapport rapide"
			TXT_AR_DATA_MANAGEMENT = "Rapport de gestion des données"
			TXT_AR_RECORD_VIEW_BY_OWNER = "Dossiers consultés par propriétaire"
			TXT_AR_RECORD_VIEW_BY_VIEW = "Dossiers consultés par type de vue"
			TXT_AR_UNIQUE_IP_BY_OWNER = "Nombre d'adresses IP uniques par propriétaire"
			TXT_AR_UNIQUE_IP_BY_VIEW = "Nombre d'adresses IP uniques par type de vue"
			TXT_AR_UNIQUE_IP_TOTAL = "Nombre total d'adresse IP uniques"
	End Select
End Sub

Call setTxtStatsAuto()
%>
