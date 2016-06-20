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
Dim TXT_BY_EMAIL_AT, _
	TXT_BY_FAX_AT, _
	TXT_BY_MAIL_AT, _
	TXT_ONLINE_AT, _
	TXT_BY_PHONE_AT

Sub setTxtAgencyContact()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_BY_EMAIL_AT = "Par <strong>courriel</strong> au" & TXT_COLON
			TXT_BY_FAX_AT = "Par <strong>télécopieur</strong> au" & TXT_COLON
			TXT_BY_MAIL_AT = "Par <strong>courrier</strong> à" & TXT_COLON
			TXT_ONLINE_AT = "<strong>En ligne</strong> via l'option « Proposer une mise à jour » au" & TXT_COLON
			TXT_BY_PHONE_AT = "Par <strong>téléphone</strong> au" & TXT_COLON
		Case Else
			TXT_BY_EMAIL_AT = "By <strong>Email</strong> at" & TXT_COLON
			TXT_BY_FAX_AT = "By <strong>Fax</strong> at" & TXT_COLON
			TXT_BY_MAIL_AT = "By <strong>Mail</strong> at" & TXT_COLON
			TXT_ONLINE_AT = "<strong>Online</strong> using the ""Suggest Update"" option at" & TXT_COLON
			TXT_BY_PHONE_AT = "By <strong>Phone</strong> at" & TXT_COLON
	End Select
End Sub

Call setTxtAgencyContact()
%>
