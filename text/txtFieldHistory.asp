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
Dim TXT_FIELD_HISTORY, _
	TXT_FIELD_HISTORY_FOR_RECORD, _
	TXT_REVISION_DATE, _
	TXT_COMPARE_WITH

Sub setTxtFieldHistory()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_FIELD_HISTORY = "Historique des champs"
			TXT_FIELD_HISTORY_FOR_RECORD = "Historique des champs de ce dossier" & TXT_COLON
			TXT_REVISION_DATE = "Date de révision"
			TXT_COMPARE_WITH = "Comparer au"
		Case Else
			TXT_FIELD_HISTORY = "Field History"
			TXT_FIELD_HISTORY_FOR_RECORD = "Field History for Record" & TXT_COLON
			TXT_REVISION_DATE = "Revision Date"
			TXT_COMPARE_WITH = "Compare With"
	End Select
End Sub

Call setTxtFieldHistory()

%>
