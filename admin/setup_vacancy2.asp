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
<script language="python" runat="server">
def reload_db_options():
	pyrequest.dboptions._invalidate()
</script>
<%
If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Dim objReturn, objErrMsg
Dim cmdUpdateVacancy, rsUpdateVacancy
Set cmdUpdateVacancy = Server.CreateObject("ADODB.Command")
With cmdUpdateVacancy 	
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_STP_Member_u_Vacancy"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@VacancyFundedCapacity", adBoolean, adParamInput, 1, CbToSQLBool("VacancyFundedCapacity"))
	.Parameters.Append .CreateParameter("@VacancyServiceHours", adBoolean, adParamInput, 1, CbToSQLBool("VacancyServiceHours"))
	.Parameters.Append .CreateParameter("@VacancyServiceDays", adBoolean, adParamInput, 1, CbToSQLBool("VacancyServiceDays"))
	.Parameters.Append .CreateParameter("@VacancyServiceWeeks", adBoolean, adParamInput, 1, CbToSQLBool("VacancyServiceWeeks"))
	.Parameters.Append .CreateParameter("@VacancyServiceFTE", adBoolean, adParamInput, 1, CbToSQLBool("VacancyServiceFTE"))
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsUpdateVacancy = cmdUpdateVacancy.Execute
Set rsUpdateVacancy = rsUpdateVacancy.NextRecordset

Select Case objReturn.Value
	Case 0
		Call reload_db_options()
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED, _
			"setup_vacancy.asp", _
			vbNullString, _
			False)
	Case Else
		Call makePageHeader(TXT_UPDATE_VACANCY_FAILED, TXT_UPDATE_VACANCY_FAILED, True, False, True, True)
		Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			vbNullString, _
			vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
		Call makePageFooter(False)
End Select
%>
<!--#include file="../includes/core/incClose.asp" -->

