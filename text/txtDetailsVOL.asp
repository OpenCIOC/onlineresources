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
Dim	TXT_CREATE_NEW_OPP, _
	TXT_CREATE_REFERRAL, _
	TXT_FLAG_EXPIRED, _
	TXT_LIST_REFERRALS, _
	TXT_MORE_AGENCY_INFO, _
	TXT_ORGNAME, _
	TXT_OTHER_OPPORTUNITIES, _
	TXT_SUGGEST_NEW_OPPORTUNITY, _
	TXT_YES_VOLUNTEER

Sub setTxtDetailsVOL()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_CREATE_NEW_OPP = "Créer une nouvelle occasion"
			TXT_CREATE_REFERRAL = "Créer une mise en relation"
			TXT_FLAG_EXPIRED = "EXPIRÉ"
			TXT_LIST_REFERRALS = "Les mises en relation"
			TXT_MORE_AGENCY_INFO = "Informations sur l'agence"
			TXT_ORGNAME = "Nom de l'organisme"
			TXT_OTHER_OPPORTUNITIES = "Autres occasions"
			TXT_SUGGEST_NEW_OPPORTUNITY = "Proposer une nouvelle occasion"
			TXT_YES_VOLUNTEER = "J'aimerais être bénévole !"
		Case Else
			TXT_CREATE_NEW_OPP = "Create New Opportunity"
			TXT_CREATE_REFERRAL = "Create Referral"
			TXT_FLAG_EXPIRED = "EXPIRED"
			TXT_LIST_REFERRALS = "List Referrals"
			TXT_MORE_AGENCY_INFO = "More Agency Info"
			TXT_ORGNAME = "Organization Name"
			TXT_OTHER_OPPORTUNITIES = "Other Opportunities"
			TXT_SUGGEST_NEW_OPPORTUNITY = "Suggest New Opportunity"
			TXT_YES_VOLUNTEER = "Yes, I'd like to Volunteer!"
	End Select
End Sub

Call setTxtDetailsVOL()
%>
