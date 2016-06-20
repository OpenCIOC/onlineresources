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
Dim TXT_WARNING_SAVED_SEARCH_ID, _
	TXT_WARNING_SAVED_SEARCH_INVALID, _
	TXT_WARNING_SAVED_SEARCH_SECURITY

Sub setTxtSearchSaved()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_WARNING_SAVED_SEARCH_ID = "The following is an invalid Saved Search ID and was ignored" & TXT_COLON
			TXT_WARNING_SAVED_SEARCH_INVALID = "No such search exists, or you do not have permissions to use the search here. Saved Search criteria was ignored."
			TXT_WARNING_SAVED_SEARCH_SECURITY = "Saved Search criteria was ignored; You do not have sufficient security permissions."
		Case CULTURE_FRENCH_CANADIAN
			TXT_WARNING_SAVED_SEARCH_ID = "Ceci est un code de recherche sauvegardée non valide et a été ignoré" & TXT_COLON
			TXT_WARNING_SAVED_SEARCH_INVALID = "Soit la recherche demandée n'existe pas, soit vous n'avez pas les droits requis pour utiliser la recherche ici. Les critères relatifs aux recherches sauvegardées ont été ignorés."
			TXT_WARNING_SAVED_SEARCH_SECURITY = "Les critères relatifs aux recherches sauvegardées ont été ignorés; vous n'avez pas tous les droits d'accès sécuritaires requis."
	End Select
End Sub

Call setTxtSearchSaved()
%>
