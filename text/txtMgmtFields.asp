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
Dim TXT_CREATED_BY, _
	TXT_DATE_CREATED, _
	TXT_DISPLAY_UNTIL, _
	TXT_LAST_MODIFIED, _
	TXT_LAST_UPDATE, _
	TXT_MANAGED_BY, _
	TXT_MODIFIED_BY, _
	TXT_NEXT_REVIEW, _
	TXT_SOURCE, _
	TXT_UPDATE_SCHEDULE

Sub setTxtMgmtFields()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_CREATED_BY = "Créé par"
			TXT_DATE_CREATED = "Date de création"
			TXT_DISPLAY_UNTIL = "Afficher jusqu'au"
			TXT_LAST_MODIFIED = "Dernière modification"
			TXT_LAST_UPDATE = "Dernière mise à jour complète"
			TXT_MANAGED_BY = "Géré par"
			TXT_MODIFIED_BY = "Dernière modification par"
			TXT_NEXT_REVIEW = "Prochaine mise à jour"
			TXT_SOURCE = "Provenance"
			TXT_UPDATE_SCHEDULE = "Calendrier des mises à jour"
		Case Else
			TXT_CREATED_BY = "Created by"
			TXT_DATE_CREATED = "Date Created"
			TXT_DISPLAY_UNTIL = "Display Until"
			TXT_LAST_MODIFIED = "Last Modified"
			TXT_LAST_UPDATE = "Last Full Update"
			TXT_MANAGED_BY = "Managed By"
			TXT_MODIFIED_BY = "Last Modified by"
			TXT_NEXT_REVIEW = "Next Scheduled Review"
			TXT_SOURCE = "Source"
			TXT_UPDATE_SCHEDULE = "Update Schedule"
	End Select
End Sub

Call setTxtMgmtFields()
Call addTextFile("setTxtMgmtFields")
%>
