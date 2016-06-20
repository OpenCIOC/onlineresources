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
Dim	TXT_ADVANCED_SEARCH, _
	TXT_CHANGE_VIEW, _
	TXT_CHANGE_VIEW_TEMP, _
	TXT_DELETED_RECORDS, _
	TXT_DOWNLOAD, _
	TXT_EXPORT, _
	TXT_FEEDBACK, _
	TXT_IMPORT, _
	TXT_LOGOUT, _
	TXT_MANAGE_USERS, _
	TXT_PRINT_RECORDS, _
	TXT_SAVED_SEARCH, _	
	TXT_SETUP, _
	TXT_STATS, _
	TXT_SUGGEST_RECORD, _
	TXT_SUGGEST_UPDATE, _
	TXT_VIEW

Sub setTxtMenu
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADVANCED_SEARCH = "Advanced&nbsp;Search"
			TXT_CHANGE_VIEW = "Change View"
			TXT_CHANGE_VIEW_TEMP = " (Temp.)"
			TXT_DELETED_RECORDS = "Deleted&nbsp;Records"
			TXT_DOWNLOAD = "Download"
			TXT_EXPORT = "Export"
			TXT_FEEDBACK = "Feedback"
			TXT_IMPORT = "Import"
			TXT_LOGOUT = "Logout"
			TXT_MANAGE_USERS = "Manage&nbsp;Users"
			TXT_PRINT_RECORDS = "Print Records"
			TXT_SAVED_SEARCH = "Saved&nbsp;Search"	
			TXT_SUGGEST_RECORD = "Suggest&nbsp;Record"
			TXT_SUGGEST_UPDATE = "Suggest&nbsp;an&nbsp;Update"
			TXT_SETUP = "Setup"
			TXT_STATS = "Statistics"
			TXT_VIEW = "View"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADVANCED_SEARCH = "Recherche&nbsp;avancée"
			TXT_CHANGE_VIEW = "Changer la vue"
			TXT_CHANGE_VIEW_TEMP = " (à titre temporaire)"
			TXT_DELETED_RECORDS = "Dossiers supprimés"
			TXT_DOWNLOAD = "Téléchargement"
			TXT_EXPORT = "Exportation"
			TXT_FEEDBACK = "Rétroaction"
			TXT_IMPORT = "Importation"
			TXT_LOGOUT = "Fermer la session"
			TXT_MANAGE_USERS = "Utilisateurs"
			TXT_PRINT_RECORDS = "Imprimer les dossiers"
			TXT_SAVED_SEARCH = "Recherche sauvegardée"
			TXT_SETUP = "Installation"
			TXT_STATS = "Statistiques"
			TXT_SUGGEST_RECORD = "Proposer un dossier"
			TXT_SUGGEST_UPDATE = "Proposer une mise à jour"
			TXT_VIEW = "Vue"
	End Select
End Sub

Call setTxtMenu()
Call addTextFile("setTxtMenu")
%>
