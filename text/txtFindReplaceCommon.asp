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
Dim TXT_CLEAR_FIELD, _
	TXT_INSERT_TEXT, _
	TXT_INST_SPECIFY_FIELD, _
	TXT_LOOK_FOR, _
	TXT_MATCH_CASE, _
	TXT_REPLACE, _
	TXT_REPLACE_WITH

Sub setTxtFindReplaceCommon()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_CLEAR_FIELD = "Clear Field"
			TXT_INSERT_TEXT = "Insert the text"
			TXT_INST_SPECIFY_FIELD = "You must specify a field."
			TXT_LOOK_FOR = "Look For"
			TXT_MATCH_CASE = "Match Case"
			TXT_REPLACE = "Replace"
			TXT_REPLACE_WITH = "Replace with"
		Case CULTURE_FRENCH_CANADIAN
			TXT_CLEAR_FIELD = "Effacer le contenu du champ"
			TXT_INSERT_TEXT = "Insérer le texte"
 			TXT_INST_SPECIFY_FIELD = "Vous devez spécifier un champ."
			TXT_LOOK_FOR = "Rechercher"
			TXT_MATCH_CASE = "Respecter la casse"
			TXT_REPLACE = "Remplacer"
			TXT_REPLACE_WITH = "Remplacer par"
	End Select
End Sub

Call setTxtFindReplaceCommon()
%>
