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
Dim	TXT_AGENCY, _
	TXT_LOWEST_UNUSED

Sub setTxtLowestNUM()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_AGENCY = "Agency"
			TXT_LOWEST_UNUSED = "Lowest Unused Record # for all Agencies"
		Case CULTURE_FRENCH_CANADIAN
			TXT_AGENCY = "Agence"
			TXT_LOWEST_UNUSED = "Le numéro le plus bas non utilisé par toutes les agences"
	End Select
End Sub

Call setTxtLowestNUM()
%>
