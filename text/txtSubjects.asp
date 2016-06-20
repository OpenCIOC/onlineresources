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
Dim TXT_AUTHORIZED, _
	TXT_AUTHORIZED_SUBJECTS, _
	TXT_BROADER_TERMS, _
	TXT_DATA_MANAGEMENT, _
	TXT_EXACT_MATCH, _
	TXT_HIDE_SUBJECTS, _
	TXT_LOCAL_SUBJECTS, _
	TXT_NARROWER_TERMS, _
	TXT_NO_EXACT_MATCH, _
	TXT_PARTIAL_MATCH, _
	TXT_RELATED_TERMS, _
	TXT_SUBJECT_CATEGORY, _
	TXT_SUBJECT_NOTES, _
	TXT_SUBJECT_SOURCE, _
	TXT_USE, _
	TXT_USED_FOR

Sub setTxtSubjects
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_AUTHORIZED = "Authorized"
			TXT_AUTHORIZED_SUBJECTS = "Authorized Subjects"
			TXT_BROADER_TERMS = "Broader Term(s)"
			TXT_DATA_MANAGEMENT = "Data Management"
			TXT_EXACT_MATCH = "Exact Match"
			TXT_HIDE_SUBJECTS = "Hide Subjects"
			TXT_LOCAL_SUBJECTS = "Local Subjects"
			TXT_NARROWER_TERMS = "Narrower Term(s)"
			TXT_NO_EXACT_MATCH = "No Exact Match Found"
			TXT_PARTIAL_MATCH = "Partial&nbsp;Match"
			TXT_RELATED_TERMS = "Related Term(s)"
			TXT_SUBJECT_CATEGORY = "Category"
			TXT_SUBJECT_NOTES = "Notes"
			TXT_SUBJECT_SOURCE = "Source"
			TXT_USE = "use"
			TXT_USED_FOR = "Used&nbsp;For"
		Case CULTURE_FRENCH_CANADIAN
			TXT_AUTHORIZED = "Autorisé"
			TXT_AUTHORIZED_SUBJECTS = "Sujets autorisés"
			TXT_BROADER_TERMS = "Termes génériques"
			TXT_DATA_MANAGEMENT = "Gestion de données"
			TXT_EXACT_MATCH = "Concordance exacte"
			TXT_HIDE_SUBJECTS = "Cacher les sujets"
			TXT_LOCAL_SUBJECTS = "Sujets locaux"
			TXT_NARROWER_TERMS = "Termes spécifiques"
			TXT_NO_EXACT_MATCH = "Une concordance exacte n'a pas été trouvée."
			TXT_PARTIAL_MATCH = "Concordance&nbsp;partielle"
			TXT_RELATED_TERMS = "Termes apparentés"
			TXT_SUBJECT_CATEGORY = "Catégorie"
			TXT_SUBJECT_NOTES = "Notes"
			TXT_SUBJECT_SOURCE = "Source"
			TXT_USE = "employer"
			TXT_USED_FOR = "Employé pour"
	End Select
End Sub

Call setTxtSubjects()
Call addTextFile("setTxtSubjects")
%>
