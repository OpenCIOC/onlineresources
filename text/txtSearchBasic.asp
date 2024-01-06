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
Dim TXT_AGES, _
	TXT_FIND, _
	TXT_HAS_ANY, _
	TXT_REFINE_SEARCH

Sub setTxtSearchBasic()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_AGES = "&Acirc;ges"
			TXT_FIND = "Trouver"
			TXT_HAS_ANY = "Avec un code au moins"
			TXT_REFINE_SEARCH = "Préciser la recherche"
		Case Else
			TXT_AGES = "Ages"
			TXT_FIND = "Find"
			TXT_HAS_ANY = "Has any"
			TXT_REFINE_SEARCH = "Refine Search"
	End Select
End Sub

Call setTxtSearchBasic()
%>
