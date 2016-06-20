<%@LANGUAGE="VBSCRIPT"%>
<%Option Explicit%>

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
'
' Purpose:		Main setup menu
'
%>

<% 'Base includes %>
<!--#include file="../includes/core/adovbs.inc" -->
<!--#include file="../includes/core/incVBUtils.asp" -->
<!--#include file="../includes/validation/incBasicTypes.asp" -->
<!--#include file="../includes/core/incRExpFuncs.asp" -->
<!--#include file="../includes/core/incHandleError.asp" -->
<!--#include file="../includes/core/incSetLanguage.asp" -->
<!--#include file="../includes/core/incPassVars.asp" -->
<!--#include file="../text/txtGeneral.asp" -->
<!--#include file="../text/txtError.asp" -->
<!--#include file="../includes/core/incConnection.asp" -->
<!--#include file="../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_CIC, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtVacancySetup.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<%
If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Call makePageHeader(TXT_MANAGE_VACANCY_SETUP, TXT_MANAGE_VACANCY_SETUP, True, True, True, True)

Dim cmdVacancySetup, rsVacancySetup
Set cmdVacancySetup = Server.CreateObject("ADODB.Command")
With cmdVacancySetup
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_STP_Member_s_Vacancy"
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
End With
Set rsVacancySetup = cmdVacancySetup.Execute
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> ]</p>
<p class="Info"><%=TXT_INST_VACANCY_SETUP%></p>
<form action="setup_vacancy2.asp" method="post">
<%=g_strCacheFormVals%>
<p><label for="VacancyFundedCapacity"><input type="checkbox" name="VacancyFundedCapacity" id="VacancyFundedCapacity"<%=Checked(rsVacancySetup.Fields("VacancyFundedCapacity"))%>>&nbsp;<%=TXT_VACANCY_FUNDED_CAPACITY%></label>
<br><label for="VacancyServiceHours"><input type="checkbox" name="VacancyServiceHours" id="VacancyServiceHours"<%=Checked(rsVacancySetup.Fields("VacancyServiceHours"))%>>&nbsp;<%=TXT_VACANCY_HOURS_PER_DAY%></label>
<br><label for="VacancyServiceDays"><input type="checkbox" name="VacancyServiceDays" id="VacancyServiceDays"<%=Checked(rsVacancySetup.Fields("VacancyServiceDays"))%>>&nbsp;<%=TXT_VACANCY_DAYS_PER_WEEK%></label>
<br><label for="VacancyServiceWeeks"><input type="checkbox" name="VacancyServiceWeeks" id="VacancyServiceWeeks"<%=Checked(rsVacancySetup.Fields("VacancyServiceWeeks"))%>>&nbsp;<%=TXT_VACANCY_WEEKS_PER_YEAR%></label>
<br><label for="VacancyServiceFTE"><input type="checkbox" name="VacancyServiceFTE" id="VacancyServiceFTE"<%=Checked(rsVacancySetup.Fields("VacancyServiceFTE"))%>>&nbsp;<%=TXT_VACANCY_FULL_TIME_EQUIVALENT%></label></p>
<p><input type="submit" value="<%=TXT_SUBMIT_UPDATES%>"></p>
</form>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->

