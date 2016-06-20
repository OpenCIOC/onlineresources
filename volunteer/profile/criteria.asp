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

%>

<% 'Base includes %>
<!--#include file="../../includes/core/adovbs.inc" -->
<!--#include file="../../includes/core/incVBUtils.asp" -->
<!--#include file="../../includes/validation/incBasicTypes.asp" -->
<!--#include file="../../includes/core/incRExpFuncs.asp" -->
<!--#include file="../../includes/core/incHandleError.asp" -->
<!--#include file="../../includes/core/incSetLanguage.asp" -->
<!--#include file="../../includes/core/incPassVars.asp" -->
<!--#include file="../../text/txtGeneral.asp" -->
<!--#include file="../../text/txtError.asp" -->
<!--#include file="../../includes/core/incConnection.asp" -->
<!--#include file="../../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_VOL, DM_VOL, "../../", "volunteer/profile/", vbNullString)
%>
<!--#include file="../../includes/core/incCrypto.asp" -->
<!--#include file="../../includes/core/incSecurity.asp" -->
<!--#include file="../../includes/core/incHeader.asp" -->
<!--#include file="../../includes/core/incFooter.asp" -->
<!--#include file="../../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../../text/txtFormDataCheck.asp" -->
<!--#include file="../../text/txtVOLProfile.asp" -->
<!--#include file="../../includes/core/incFormat.asp" -->
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->
<!--#include file="../../includes/validation/incFormDataCheck.asp" -->
<%
If Not g_bUseVolunteerProfiles Then
	Call goToPageB(ps_strPathToStart & "volunteer/")
ElseIf Not vprofile_bLoggedIn Then
	Call goToPageB("login.asp")
End If

Dim bNotifyNew, _
	bNotifyUpdated, _
	bSCH_M_Morning, _
	bSCH_M_Afternoon, _
	bSCH_M_Evening, _
	bSCH_TU_Morning, _
	bSCH_TU_Afternoon, _
	bSCH_TU_Evening, _
	bSCH_W_Morning, _
	bSCH_W_Afternoon, _
	bSCH_W_Evening, _
	bSCH_TH_Morning, _
	bSCH_TH_Afternoon, _
	bSCH_TH_Evening, _
	bSCH_F_Morning, _
	bSCH_F_Afternoon, _
	bSCH_F_Evening, _
	bSCH_ST_Morning, _
	bSCH_ST_Afternoon, _
	bSCH_ST_Evening, _
	bSCH_SN_Morning, _
	bSCH_SN_Afternoon, _
	bSCH_SN_Evening, _
	bSQLError, _
	bValidationError, _
	strAI_ID, _
	strCMID, _
	strBirthDate, _
	strErrorList

bNotifyNew = Not Nl(Trim(Request("NotifyNew")))
bNotifyUpdated = Not Nl(Trim(Request("NotifyUpdated")))
bSCH_M_Morning = Not Nl(Trim(Request("SCH_M_Morning")))
bSCH_M_Afternoon = Not Nl(Trim(Request("SCH_M_Afternoon")))
bSCH_M_Evening = Not Nl(Trim(Request("SCH_M_Evening")))
bSCH_TU_Morning = Not Nl(Trim(Request("SCH_TU_Morning")))
bSCH_TU_Afternoon = Not Nl(Trim(Request("SCH_TU_Afternoon")))
bSCH_TU_Evening = Not Nl(Trim(Request("SCH_TU_Evening")))
bSCH_W_Morning = Not Nl(Trim(Request("SCH_W_Morning")))
bSCH_W_Afternoon = Not Nl(Trim(Request("SCH_W_Afternoon")))
bSCH_W_Evening = Not Nl(Trim(Request("SCH_W_Evening")))
bSCH_TH_Morning = Not Nl(Trim(Request("SCH_TH_Morning")))
bSCH_TH_Afternoon = Not Nl(Trim(Request("SCH_TH_Afternoon")))
bSCH_TH_Evening = Not Nl(Trim(Request("SCH_TH_Evening")))
bSCH_F_Morning = Not Nl(Trim(Request("SCH_F_Morning")))
bSCH_F_Afternoon = Not Nl(Trim(Request("SCH_F_Afternoon")))
bSCH_F_Evening = Not Nl(Trim(Request("SCH_F_Evening")))
bSCH_ST_Morning = Not Nl(Trim(Request("SCH_ST_Morning")))
bSCH_ST_Afternoon = Not Nl(Trim(Request("SCH_ST_Afternoon")))
bSCH_ST_Evening = Not Nl(Trim(Request("SCH_ST_Evening")))
bSCH_SN_Morning = Not Nl(Trim(Request("SCH_SN_Morning")))
bSCH_SN_Afternoon = Not Nl(Trim(Request("SCH_SN_Afternoon")))
bSCH_SN_Evening = Not Nl(Trim(Request("SCH_SN_Evening")))

strBirthDate= Trim(Request("BirthDate"))
strAI_ID = Trim(Request("AI_ID"))
strCMID = Trim(Request("CMID"))

bSQLError = False
bValidationError = False
strErrorList = vbNullString

If Nl(strBirthDate) Then
	strBirthDate = Null
ElseIf checkDate(TXT_DATE_OF_BIRTH, strBirthDate) Then
	strBirthDate = CDate(strBirthDate)
	If DateDiff("d", Date(), strBirthDate) > 0 Then
		checkAddValidationError(TXT_DATE_OF_BIRTH_ERROR)
	End If
End If

If Nl(strAI_ID) Then
	strAI_ID = vbNullString
ElseIf Not IsIDList(strAI_ID) Then
	checkAddValidationError(TXT_AREA_OF_INTEREST_ERROR)
End If

If Nl(strCMID) Then
	strCMID = vbNullString
ElseIf Not IsIDList(strCMID) Then
	checkAddValidationError(TXT_COMMUNITY_ERROR)
End If


If Not Nl(strErrorList) Then
	bValidationError = True
Else
	Dim objReturn, objErrMsg
	Dim cmdCriteriaUpdate, rsCriteriaUpdate
	Set cmdCriteriaUpdate = Server.CreateObject("ADODB.Command")
	With cmdCriteriaUpdate
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "sp_VOL_Profile_u_Search"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@Return", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, vprofile_strID)
		.Parameters.Append .CreateParameter("@NotifyNew", adBoolean, adParamInput, 1, bNotifyNew)
		.Parameters.Append .CreateParameter("@NotifyUpdated", adBoolean, adParamInput, 1, bNotifyUpdated)
		.Parameters.Append .CreateParameter("@BirthDate", adDBDate, adParamInput, 1, strBirthDate)
		.Parameters.Append .CreateParameter("@SCH_M_Morning", adBoolean, adParamInput, 1, bSCH_M_Morning)
		.Parameters.Append .CreateParameter("@SCH_M_Afternoon", adBoolean, adParamInput, 1, bSCH_M_Afternoon)
		.Parameters.Append .CreateParameter("@SCH_M_Evening", adBoolean, adParamInput, 1, bSCH_M_Evening)
		.Parameters.Append .CreateParameter("@SCH_TU_Morning", adBoolean, adParamInput, 1, bSCH_TU_Morning)
		.Parameters.Append .CreateParameter("@SCH_TU_Afternoon", adBoolean, adParamInput, 1, bSCH_TU_Afternoon)
		.Parameters.Append .CreateParameter("@SCH_TU_Evening", adBoolean, adParamInput, 1, bSCH_TU_Evening)
		.Parameters.Append .CreateParameter("@SCH_W_Morning", adBoolean, adParamInput, 1, bSCH_W_Morning)
		.Parameters.Append .CreateParameter("@SCH_W_Afternoon", adBoolean, adParamInput, 1, bSCH_W_Afternoon)
		.Parameters.Append .CreateParameter("@SCH_W_Evening", adBoolean, adParamInput, 1, bSCH_W_Evening)
		.Parameters.Append .CreateParameter("@SCH_TH_Morning", adBoolean, adParamInput, 1, bSCH_TH_Morning)
		.Parameters.Append .CreateParameter("@SCH_TH_Afternoon", adBoolean, adParamInput, 1, bSCH_TH_Afternoon)
		.Parameters.Append .CreateParameter("@SCH_TH_Evening", adBoolean, adParamInput, 1, bSCH_TH_Evening)
		.Parameters.Append .CreateParameter("@SCH_F_Morning", adBoolean, adParamInput, 1, bSCH_F_Morning)
		.Parameters.Append .CreateParameter("@SCH_F_Afternoon", adBoolean, adParamInput, 1, bSCH_F_Afternoon)
		.Parameters.Append .CreateParameter("@SCH_F_Evening", adBoolean, adParamInput, 1, bSCH_F_Evening)
		.Parameters.Append .CreateParameter("@SCH_ST_Morning", adBoolean, adParamInput, 1, bSCH_ST_Morning)
		.Parameters.Append .CreateParameter("@SCH_ST_Afternoon", adBoolean, adParamInput, 1, bSCH_ST_Afternoon)
		.Parameters.Append .CreateParameter("@SCH_ST_Evening", adBoolean, adParamInput, 1, bSCH_ST_Evening)
		.Parameters.Append .CreateParameter("@SCH_SN_Morning", adBoolean, adParamInput, 1, bSCH_SN_Morning)
		.Parameters.Append .CreateParameter("@SCH_SN_Afternoon", adBoolean, adParamInput, 1, bSCH_SN_Afternoon)
		.Parameters.Append .CreateParameter("@SCH_SN_Evening", adBoolean, adParamInput, 1, bSCH_SN_Evening)
		.Parameters.Append .CreateParameter("@AI_IDList", adLongVarChar, adParamInput, -1, strAI_ID)
		.Parameters.Append .CreateParameter("@CM_IDList", adLongVarChar, adParamInput, -1, strCMID)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsCriteriaUpdate = cmdCriteriaUpdate.Execute()
	If rsCriteriaUpdate.State <> 0 Then
		rsCriteriaUpdate.Close()
	End If

	If objReturn.Value <> 0 Then
		bSQLError = True
		strErrorList = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End If
End If
If bSQLError Or bValidationError Then
	Dim strPageHeader
	strPageHeader = TXT_UPDATE_VOL_PROFILE_CRITERIA
	Call makePageHeader(strPageHeader, strPageHeader, True, True, True, True)
Else
	Call handleMessage(TXT_SUCCESS_CRITERIA, "start.asp", "ShowTab=Criteria", False)
End If
If bSQLError Then
	Call handleError(TXT_ERROR_UPDATING_PROFILE & strErrorList, vbNullString, vbNullString)
ElseIf bValidationError Then
	Call handleError(TXT_THERE_WERE_VALIDIATION_ERRORS, vbNullString, vbNullString)
	%><ul><%=strErrorList%></ul>
	<p><%=TXT_USE_BACK_BUTTON%></p><%
End If
If bSQLError Or bValidationError Then
	Call makePageFooter(True)
End If
%>
<!--#include file="../../includes/core/incClose.asp" -->


