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
Dim TXT_ALL_OF, _
	TXT_ANY_OF, _
	TXT_CHANGED_BY, _
	TXT_CHANGE_DATE, _
	TXT_NEW_RECORD, _
	TXT_OTHER_CHANGE, _
	TXT_PASSWORD_CHANGED, _
	TXT_REVIEW_ACCOUNT_CHANGES, _
	TXT_REVISION_TYPE

Sub setTxtUserHistory()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ALL_OF = "<strong>All</strong> of the following"
			TXT_ANY_OF = "<strong>Any</strong> of the following"
			TXT_CHANGED_BY = "Changed By"
			TXT_CHANGE_DATE = "Change Date"
			TXT_NEW_RECORD = "New Account Created"
			TXT_OTHER_CHANGE = "Other Change"
			TXT_PASSWORD_CHANGED = "Password Changed"
			TXT_REVIEW_ACCOUNT_CHANGES = "Review Account Change History"
			TXT_REVISION_TYPE = "Type of Change"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ALL_OF = "<strong>Tous</strong> parmi les suivants"
			TXT_ANY_OF = "<strong>Au moins un</strong> parmi les suivants"
			TXT_CHANGED_BY = "Changé par"
			TXT_CHANGE_DATE = "Date du changement"
			TXT_NEW_RECORD = "Nouveau compte créé"
			TXT_OTHER_CHANGE = "Autre changement"
			TXT_PASSWORD_CHANGED = "Mot de passe modifié"
			TXT_REVIEW_ACCOUNT_CHANGES = "Consulter l'historique des changements sur le compte"
			TXT_REVISION_TYPE = "Type de changement"
	End Select
End Sub

Call setTxtUserHistory()
%>
