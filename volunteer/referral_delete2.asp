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
Call setPageInfo(True, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtFormDataCheck.asp" -->
<!--#include file="../text/txtReferral.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
If Not user_bCanManageReferrals Then
	Call securityFailure()
End If

Dim bConfirmed
bConfirmed = Request("Confirmed") = "on"

Dim intREFID
intREFID = Trim(Request("REFID"))

Dim objReturn, objErrMsg
Dim strError

If Nl(intREFID) Then
	Dim dToDate
	dToDate = Request("DeleteToDate")
	If Nl(dToDate) Then
		Call handleError(TXT_NO_RECORD_CHOSEN, _
			"referral_delete.asp", vbNullString)
	ElseIf Not IsDate(dToDate) Then
		Call handleError(dToDate & TXT_INVALID_DATE_FORMAT, "referral_delete.asp", vbNullString)
	Else
		dToDate = DateValue(dToDate)
	End If
	If bConfirmed Then
		Dim cmdReferralD, rsReferralD
		Set cmdReferralD = Server.CreateObject("ADODB.Command")
		With cmdReferralD
			.ActiveConnection = getCurrentAdminCnn()
			.CommandType = adCmdStoredProc
			.CommandText = "dbo.sp_VOL_OP_Referral_Month_d"
			Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
			.Parameters.Append objReturn
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@ToDate", adDBDate, adParamInput, 4, dToDate)
			Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
			.Parameters.Append objErrMsg
			.CommandTimeout = 0
			.Execute
		End With
		
		If objReturn.Value = 0 And Err.Number = 0 Then
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
				"referral_delete.asp", _
				vbNullString, _
				False)
		Else
			If Err.Number <> 0 Then
				strError = Err.Description
			Else
				strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
			End If
			Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & strError, _
				"referral_delete.asp", _
				vbNullString)
		End If
	Else
		Call makePageHeader(TXT_CONFIRM_DELETE_REFERRALS, TXT_CONFIRM_DELETE_REFERRALS, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%>
<br>(<%=TXT_BEFORE_DATE%> &nbsp;<%=DateString(dToDate,False)%>)</span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="DeleteToDate" value="<%=dToDate%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%
		Call makePageFooter(True)
	End If
	
ElseIf Not IsIDType(intREFID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intREFID) & ".", _
		"referral_delete.asp", vbNullString)
Else
	intREFID = CLng(intREFID)


	If Not bConfirmed Then
		Call makePageHeader(TXT_CONFIRM_DELETE_REFERRAL, TXT_CONFIRM_DELETE_REFERRAL, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="REFID" value="<%=intREFID%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" value="<%=TXT_DELETE%>" class="btn btn-default">
</form>
<%
		Call makePageFooter(True)
	Else
		Dim cmdDeleteReferral, rsDeleteReferral
		Set cmdDeleteReferral = Server.CreateObject("ADODB.Command")
		With cmdDeleteReferral
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_VOL_OP_Referral_d"
			.CommandType = adCmdStoredProc
			Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
			.Parameters.Append objReturn
			.Parameters.Append .CreateParameter("@REF_ID", adInteger, adParamInput, 4, intREFID)
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
			.Parameters.Append objErrMsg
			.CommandTimeout = 0
		End With
		Set rsDeleteReferral = cmdDeleteReferral.Execute
		Set rsDeleteReferral = rsDeleteReferral.NextRecordset
	
		If objReturn.Value = 0 And Err.Number = 0 Then
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
				"referral.asp", _
				vbNullString, _
				False)
		Else
			If Err.Number <> 0 Then
				strError = Err.Description
			Else
				strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
			End If
			Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & strError, _
				"referral_edit.asp", _
				"REFID=" & intREFID)
		End If
	End If
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
