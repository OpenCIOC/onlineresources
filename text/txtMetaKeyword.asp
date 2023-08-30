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
Dim	TXT_INVALID_TAXONOMY_CODE, _

Sub setTxtKeywordSetup()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_INVALID_TAXONOMY_CODE = "The following is an invalid Taxonomy Code" & TXT_COLON
		Case CULTURE_FRENCH_CANADIAN
			TXT_INVALID_TAXONOMY_CODE = "Le code taxonomique suivant est invalide" & TXT_COLON
	End Select
End Sub

Call setTxtKeywordSetup()
%>
