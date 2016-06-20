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
Dim TXT_ALL_TERMS, _
	TXT_ANY_TERMS, _
	TXT_BOOLEAN, _
	TXT_SEARCH_IN, _
	TXT_SEARCH_TERMS

Sub setTxtGeneralSearch2()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ALL_TERMS = "All&nbsp;the&nbsp;terms"
			TXT_ANY_TERMS = "Any&nbsp;of&nbsp;the&nbsp;terms"
			TXT_BOOLEAN = "Boolean"
			TXT_SEARCH_IN = "Search In"
			TXT_SEARCH_TERMS = "Search Terms"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ALL_TERMS = "Tous&nbsp;les&nbsp;mots"
			TXT_ANY_TERMS = "N'importe quels mots"
			TXT_BOOLEAN = "Booléen"
			TXT_SEARCH_IN = "Chercher dans"
			TXT_SEARCH_TERMS = "Mots de recherche"
	End Select
End Sub

Call setTxtGeneralSearch2()
%>
