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
Dim	TXT_AS_OF, _
	TXT_CT_ACCESS_DENIED, _
	TXT_CT_ADD_RECORD, _
	TXT_CT_CLIENT_TRACKER, _
	TXT_CT_ERR_SERVER_COMMUNICATION, _
	TXT_CT_ERR_SERVER_INVALID, _
	TXT_CT_ERR_SERVER_MSG, _
	TXT_CT_NOT_LAUNCHED, _
	TXT_CT_RECORD_ADDED

Sub setTxtClientTracker()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_AS_OF = "as of "
			TXT_CT_ACCESS_DENIED = "Access denied."
			TXT_CT_ADD_RECORD = "Add&nbsp;Record"
			TXT_CT_CLIENT_TRACKER = "Client&nbsp;Tracker"
			TXT_CT_ERR_SERVER_COMMUNICATION = "There was an error communicating with the Client Tracker server"
			TXT_CT_ERR_SERVER_INVALID = "The Client Tracker server gave an invalid response"
			TXT_CT_ERR_SERVER_MSG = "The Client Tracker server returned an error"
			TXT_CT_NOT_LAUNCHED = "Current session not associated with a Client Tracker user."
			TXT_CT_RECORD_ADDED = "Record&nbsp;Added"
		Case CULTURE_FRENCH_CANADIAN
			TXT_AS_OF = "à partir du "
			TXT_CT_ACCESS_DENIED = "Accès refusé."
			TXT_CT_ADD_RECORD = "Ajouter le dossier"
			TXT_CT_CLIENT_TRACKER = "Suivi des clients"
			TXT_CT_ERR_SERVER_COMMUNICATION = "Il y a eu une erreur de communication avec le serveur de Suivi des clients"
			TXT_CT_ERR_SERVER_INVALID = "Le serveur de Suivi des client a envoyé une réponse invalide"
			TXT_CT_ERR_SERVER_MSG = "Le serveur de Suivi des clients a retourné une erreur"
			TXT_CT_NOT_LAUNCHED = "La session en cours n'est pas associé à un utilisateur du Suivi des clients."
			TXT_CT_RECORD_ADDED = "Dossier ajouté"
	End Select
End Sub

Call setTxtClientTracker()
%>
