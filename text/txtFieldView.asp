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
Dim	TXT_CANNOT_ACCESS_RECORD, _
	TXT_CANNOT_PRINT_FIELD_DATA, _
	TXT_FIELD_IS_EMPTY, _
	TXT_NO_FIELD_SELECTED, _
	TXT_NO_FIELD_HISTORY

Sub setTxtFieldView()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_CANNOT_ACCESS_RECORD = "No such record exists, or you do not have permission to view the record."
			TXT_CANNOT_PRINT_FIELD_DATA = "Cannot print field contents" & TXT_COLON
			TXT_FIELD_IS_EMPTY = "The field is empty"
			TXT_NO_FIELD_SELECTED = "No field was selected"
			TXT_NO_FIELD_HISTORY = "No field history"
		Case CULTURE_FRENCH_CANADIAN
			TXT_CANNOT_ACCESS_RECORD = "Ce dossier n'existe pas ou bien vous n'avez pas l'autorisation de le consulter."
			TXT_CANNOT_PRINT_FIELD_DATA = "Il est impossible d'impriment le contenu du champ" & TXT_COLON
			TXT_FIELD_IS_EMPTY = "Le champ est vide"
			TXT_NO_FIELD_SELECTED = "Aucun champ n'a été sélectionné"
			TXT_NO_FIELD_HISTORY = "Ce champ n'a pas d'historique"
	End Select
End Sub

Call setTxtFieldView()
%>
