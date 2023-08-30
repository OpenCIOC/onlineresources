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
Dim TXT_DATE_OF_BIRTH, _
	TXT_ESCORTS_TO, _
	TXT_LIMIT_SPACE_AVAILABLE, _
	TXT_LIMIT_SUBSIDY, _
	TXT_LOCAL_SCHOOLS, _
	TXT_SPACE_AVAILABLE, _
	TXT_TYPE_OF_CARE, _
	TXT_TYPE_OF_PROGRAM

Sub setTxtSearchCCR()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_DATE_OF_BIRTH = "Date of Birth"
			TXT_ESCORTS_TO = "Escorts to / from School"
			TXT_LIMIT_SPACE_AVAILABLE = "Only show programs reporting space available"
			TXT_LIMIT_SUBSIDY = "Only show programs offering subsidized spaces"
			TXT_LOCAL_SCHOOLS = "Local schools"
			TXT_SPACE_AVAILABLE = "Space Available"
			TXT_TYPE_OF_CARE = "Type of Care Needed"
			TXT_TYPE_OF_PROGRAM = "Type of Program"
		Case CULTURE_FRENCH_CANADIAN
			TXT_DATE_OF_BIRTH = "Date de naissance"
			TXT_ESCORTS_TO = "Accompagne à"
			TXT_LIMIT_SPACE_AVAILABLE = "Afficher uniquement les programmes qui ont des places disponibles"
			TXT_LIMIT_SUBSIDY = "Afficher uniquement les programmes qui offrent des places subventionnées"
			TXT_LOCAL_SCHOOLS = "Les écoles locales"
			TXT_SPACE_AVAILABLE = "Espace disponible"
			TXT_TYPE_OF_CARE = "Type de garde d'enfants requise"
			TXT_TYPE_OF_PROGRAM = "Type de programme"
	End Select
End Sub

Call setTxtSearchCCR()
%>
