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
Dim TXT_ADD_NEW_RESOURCE, _
	TXT_CONFIRM_DELETE_RESOURCE, _
	TXT_DOWNLOAD_RECORDS, _
	TXT_DOWNLOAD_STATS, _
	TXT_RESOURCE, _
	TXT_RESOURCE_NAME, _
	TXT_RESOURCE_URL, _
	TXT_UPDATE_RESOURCE_FAILED

Sub setTxtDownload()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_NEW_RESOURCE = "Add a new Download Resource URL"
			TXT_CONFIRM_DELETE_RESOURCE = "Confirm Download Resource URL Deletion"
			TXT_DOWNLOAD_RECORDS = "Access Download - Records"
			TXT_DOWNLOAD_STATS = "Access Download - Stats"
			TXT_RESOURCE = "Resource"
			TXT_RESOURCE_NAME = "Resource Name"
			TXT_RESOURCE_URL = "Resource URL"
			TXT_UPDATE_RESOURCE_FAILED = "Update Download Resource URL Failed"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_NEW_RESOURCE = "Ajouter une nouvelle URL de téléchargement de ressources"
			TXT_CONFIRM_DELETE_RESOURCE = "Confirmer la suppression de l'URL de téléchargement de ressource"
			TXT_DOWNLOAD_RECORDS = "Accéder au téléchargement - Dossiers"
			TXT_DOWNLOAD_STATS = "Accéder au téléchargement - Statistiques"
			TXT_RESOURCE = "Ressource"
			TXT_RESOURCE_NAME = "Nom de la ressource"
			TXT_RESOURCE_URL = "URL de la ressource"
			TXT_UPDATE_RESOURCE_FAILED = "La mise à jour de l'URL de téléchargement de ressource a échoué."
	End Select
End Sub

Call setTxtDownload()
%>
