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
' Purpose:		Form for modifying existing agency info or adding new
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
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtAgency.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtRecordPages.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incMemberList.asp" -->
<!--#include file="../includes/list/incSysLanguageList.asp" -->

<%
If Not user_bSuperUser Then
	Call securityFailure()
End If

Dim bNew
bNew = False

Dim intAgencyID
intAgencyID = Trim(Request("AgencyID"))

If user_bSuperUser Then
	If Nl(intAgencyID) Then
		bNew = True
		intAgencyID = Null
	ElseIf Not IsIDType(intAgencyID) Then
		Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intAgencyID) & "." & _
			vbCrLf & "<br>" & TXT_CHOOSE_AGENCY, _
			"agencies.asp", vbNullString)
	Else
		intAgencyID = CLng(intAgencyID)
	End If
Else
	intAgencyID = Null
	bNew = False
End If

Dim	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
	strAgencyCode, _
	bRecordOwnerCIC, _
	strUpdateEmailCIC, _
	strUpdatePhoneCIC, _
	strInquiryPhoneCIC, _
	strAgencyNUMCIC, _
	bRecordOwnerVOL, _
	strUpdateEmailVOL, _
	strUpdatePhoneVOL, _
	strInquiryPhoneVOL, _
	strAgencyNUMVOL, _
	bEnforceReqFields, _
	bUpdateAccountDefault, _
	bUpdatePasswordDefault, _
	strUpdateAccountEmail, _
	intUpdateAccountLangID, _
	intUserCount, _
	intGBLCount, _
	intVOLCount, _
	strMemberName, _
	intMemberID, _
	objReturn, _
	objErrMsg

If Not bNew Then
	Dim cmdAgency, rsAgency
	Set cmdAgency = Server.CreateObject("ADODB.Command")
	With cmdAgency
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.CommandText = "dbo.sp_GBL_Agency_s"
		Set objReturn = .CreateParameter("@RETURN", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, IIf(user_bSuperUserGlobal, Null, g_intMemberID))
		.Parameters.Append .CreateParameter("@AgencyID", adInteger, adParamInput, 4, intAgencyID)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsAgency = cmdAgency.Execute
	
	With rsAgency
		If .EOF Then
			rsAgency.NextRecordset

			If objReturn.Value <> 8 Then
				Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intAgencyID) & "." & _
					vbCrLf & "<br>" & TXT_CHOOSE_AGENCY, _
					"agencies.asp", vbNullString)
			Else
				Call SecurityFailure()
			End If
		Else
			intAgencyID = .Fields("AgencyID")
			intMemberID = .Fields("MemberID")
			strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strAgencyCode = .Fields("AgencyCode")
			bRecordOwnerCIC = .Fields("RecordOwnerCIC")
			strUpdateEmailCIC = .Fields("UpdateEmailCIC")
			strUpdatePhoneCIC = .Fields("UpdatePhoneCIC")
			strInquiryPhoneCIC = .Fields("InquiryPhoneCIC")
			strAgencyNUMCIC = .Fields("AgencyNUMCIC")
			bRecordOwnerVOL = .Fields("RecordOwnerVOL")
			strUpdateEmailVOL = .Fields("UpdateEmailVOL")
			strUpdatePhoneVOL = .Fields("UpdatePhoneVOL")
			strInquiryPhoneVOL = .Fields("InquiryPhoneVOL")
			strAgencyNUMVOL = .Fields("AgencyNUMVOL")
			bEnforceReqFields = .Fields("EnforceReqFields")
			bUpdateAccountDefault = .Fields("UpdateAccountDefault")
			bUpdatePasswordDefault = .Fields("UpdatePasswordDefault")
			strUpdateAccountEmail = .Fields("UpdateAccountEmail")
			intUpdateAccountLangID = .Fields("UpdateAccountLangID")
			intUserCount = .Fields("Users")
			intGBLCount = .Fields("GBLRecords")
			intVOLCount = .Fields("VOLRecords")
			strMemberName = .Fields("MemberName")
		End If
	End With

	Dim strAgencyStatus, bOkDelete
	bOkDelete = True

	If intUserCount = 0 Then
		strAgencyStatus = TXT_STATUS_NO_USER
	Else
		strAgencyStatus = TXT_STATUS_USER_1 & " <strong><a href=" & AttrQs(makeLink("users.asp","Agency=" & strAgencyCode,vbNullString)) & ">" & intUserCount & "</a></strong>" & TXT_STATUS_USER_2
		bOkDelete = False
	End If

	If intGBLCount > 0 Then
		strAgencyStatus = strAgencyStatus & "<br>" & TXT_AGENCY_OWNS & " <strong><a href=" & AttrQs(makeLink(ps_strPathToStart & "results.asp","incDel=on&RO=" & strAgencyCode,vbNullString)) & ">" & intGBLCount & "</a></strong> " & TXT_ORGANIZATION_RECORDS & "."
		bOkDelete = False
	ElseIf g_bUseCIC Or g_bUseVOL Then
		strAgencyStatus = strAgencyStatus & "<br>" & TXT_STATUS_DOES_NOT_OWN & TXT_ORGANIZATION_RECORDS
	End If
	
	If intVOLCount > 0 Then
		strAgencyStatus = strAgencyStatus & "<br>" & TXT_AGENCY_OWNS & " <strong><a href=" & AttrQs(makeLink(ps_strPathToStart & "volunteer/results.asp","incDel=on&RO=" & strAgencyCode,vbNullString)) & ">" & intVOLCount & "</a></strong> " & TXT_VOLUNTEER_RECORDS & "."
		bOkDelete = False
	ElseIf g_bUseVOL Then
		strAgencyStatus = strAgencyStatus & "<br>" & TXT_STATUS_DOES_NOT_OWN & TXT_VOLUNTEER_RECORDS
	End If
	
	If bOkDelete Then
		strAgencyStatus = strAgencyStatus & "<br>" & TXT_STATUS_DELETE
	Else
		strAgencyStatus = strAgencyStatus & "<br>" & TXT_STATUS_NO_DELETE
	End If
Else
	bUpdateAccountDefault = True
	bUpdatePasswordDefault = True
End If

If Not bNew Then
	Call makePageHeader(TXT_EDIT_AGENCY & strAgencyCode, TXT_EDIT_AGENCY & strAgencyCode, True, False, True, True)
Else
	Call makePageHeader(TXT_ADD_NEW_AGENCY, TXT_ADD_NEW_AGENCY, True, False, True, True)
End If

%>
<%If user_bSuperUser Then%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLinkB("agencies.asp")%>"><%=TXT_RETURN_AGENCIES%></a> ]</p>
<%Else%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> ]</p>
<%End If%>
<form action="agencies_edit2.asp" method="post" class="form-horizontal">
<%=g_strCacheFormVals%>
<input type="hidden" name="AgencyID" value="<%=intAgencyID%>">


<div class="panel panel-default max-width-lg">
<div class="panel-heading">
	<h2><%=TXT_EDIT_AGENCY_INFO%></h2>
</div>
<div class="panel-body no-padding">
	<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
<%
If Not bNew Then
%>
<tr>
	<td class="field-label-cell"><%=TXT_STATUS%></td>
	<td class="field-data-cell"><%=strAgencyStatus%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_DATE_CREATED%></td>
	<td class="field-data-cell"><%=strCreatedDate%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_CREATED_BY%></td>
	<td class="field-data-cell"><%=strCreatedBy%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_LAST_MODIFIED%></td>
	<td class="field-data-cell"><%=strModifiedDate%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_MODIFIED_BY%></td>
	<td class="field-data-cell"><%=strModifiedBy%></td>
</tr>
<%
End If
If user_bSuperUserGlobal And g_bOtherMembers Then
%>
<tr>
	<td class="field-label-cell"><label for="MemberID"><%= TXT_MEMBER %></label></td>
<%
	If bNew Then
		Call openMemberListRst()
%><td class="field-data-cell"><%= makeMemberList(g_intMemberID, "MemberID", False) %></td><%
		Call closeMemberListRst()
	Else
%>
<td class="field-data-cell"><%= Server.HTMLEncode(strMemberName) %>
<input type="hidden" name="MemberID" value="<%=intMemberID%>"></td>
<%
	End If
%>
</tr>
<%
End If
%>
<tr>
	<td class="field-label-cell">
		<label for="AgencyCode"><%=TXT_AGENCY_CODE%></label>
		<span class="glyphicon glyphicon-question-sign" title=<%=AttrQs(TXT_INST_AGENCY_CODE)%>></span>
		<span class="Alert">*</span></td>
	<td class="field-data-cell">
		<div class="form-inline">
			<input type="text" name="AgencyCode" id="AgencyCode" value=<%=AttrQs(strAgencyCode)%> size="3" maxlength="3" class="form-control">
		</div>
	</td>
</tr>
<%If g_bUseVOL Or g_bUseCIC Then%>
<tr>
	<td class="field-label-cell">
		<%=TXT_RECORD_OWNER%> (<%=TXT_CIC%>)
		<span class="glyphicon glyphicon-question-sign" title=<%=AttrQs(TXT_INST_OWNER_CIC)%>></span>
	</td>
	<td class="field-data-cell">
		<div class="clear-line-below">
			<label for="RecordOwnerCIC"><input type="checkbox" name="RecordOwnerCIC" id="RecordOwnerCIC"<%=Checked(bRecordOwnerCIC Or intGBLCount > 0)%> <%=StringIf(intGBLCount > 0, " disabled")%>><%=TXT_AGENCY_OWNS & " " & TXT_ORGANIZATION_RECORDS%></label>
		</div>
		<div class="form-group row">
			<label for="UpdateEmailCIC" class="control-label col-sm-3"><%=TXT_UPDATE_EMAIL%><%If intGBLCount > 0 Then%> <span class="Alert">*</span><%End If%></label>
			<div class="col-sm-9">
				<input type="text" name="UpdateEmailCIC" id="UpdateEmailCIC" value=<%=AttrQs(strUpdateEmailCIC)%> maxlength="100" class="form-control">
			</div>
		</div>
		<div class="form-group row">
			<label for="UpdatePhoneCIC" class="control-label col-sm-3"><%=TXT_UPDATE_PHONE%></label>
			<div class="col-sm-9">
				<input type="text" name="UpdatePhoneCIC" id="UpdatePhoneCIC" value=<%=AttrQs(strUpdatePhoneCIC)%> maxlength="60" class="form-control">
			</div>
		</div>
		<div class="form-group row">
			<label for="InquiryPhoneCIC" class="control-label col-sm-3"><%=TXT_INQUIRY_PHONE%></label>
			<div class="col-sm-9">
				<input type="text" name="InquiryPhoneCIC" id="InquiryPhoneCIC" value=<%=AttrQs(strInquiryPhoneCIC)%> maxlength="60" class="form-control">
			</div>
		</div>
		<div class="form-group row">
			<label for="InquiryPhoneCIC" class="control-label col-sm-3"><label for="AgencyNUMCIC"><%=TXT_AGENCY_NUM%></label><%If intGBLCount > 0 Then%> <span class="Alert">*</span><%End If%></label>
			<div class="col-sm-9 form-inline">
				<input type="text" name="AgencyNUMCIC" id="AgencyNUMCIC" value=<%=AttrQs(strAgencyNUMCIC)%> size="9" maxlength="8" class="form-control">
				<%If Not Nl(strAgencyNUMCIC) Then%>
				<a href="<%=makeDetailsLink(strAgencyNUMCIC,vbNullString,vbNullString)%>" target="_blank"><span class="glyphicon glyphicon-new-window" title=<%=AttrQs(TXT_RECORD_DETAILS)%>></span></a><%End If%>
				<br><%=TXT_INST_NUM_FINDER%>
			</div>
		</div>
	</td>
</tr>
<%Else%>
<div style="display:none">
<input type="hidden" name="RecordOwnerCIC" value="<%=IIf(bRecordOwnerCIC,"on",vbNullString)%>">
<input type="hidden" name="UpdateEmailCIC" value=<%=AttrQs(strUpdateEmailCIC)%>>
<input type="hidden" name="UpdatePhoneCIC" value=<%=AttrQs(strUpdatePhoneCIC)%>>
<input type="hidden" name="InquiryPhoneCIC" value=<%=AttrQs(strInquiryPhoneCIC)%>>
<input type="hidden" name="AgencyNUMCIC" value=<%=AttrQs(strAgencyNUMCIC)%>>
</div>
<%End If%>
<%If g_bUseVOL Then%>
<tr>
	<td class="field-label-cell">
		<%=TXT_RECORD_OWNER%> (<%=TXT_VOLUNTEER%>)
		<span class="glyphicon glyphicon-question-sign" title=<%=AttrQs(TXT_INST_OWNER_VOL)%>></span>
	</td>
	<td class="field-data-cell">
		<div class="clear-line-below">
			<label for="RecordOwnerVOL"><input type="checkbox" name="RecordOwnerVOL" id="RecordOwnerVOL"<%=Checked(bRecordOwnerVOL Or intVOLCount > 0)%> <%=StringIf(intVOLCount > 0, " disabled")%>><%=TXT_AGENCY_OWNS & " " & TXT_VOLUNTEER_RECORDS%></label>
		</div>
		<div class="form-group row">
			<label for="UpdateEmailVOL" class="control-label col-sm-3"><%=TXT_UPDATE_EMAIL%><%If intVOLCount > 0 Then%> <span class="Alert">*</span><%End If%></label>
			<div class="col-sm-9">
				<input type="text" name="UpdateEmailVOL" id="UpdateEmailVOL" value=<%=AttrQs(strUpdateEmailVOL)%> maxlength="100" class="form-control">
			</div>
		</div>
		<div class="form-group row">
			<label for="UpdatePhoneVOL" class="control-label col-sm-3"><%=TXT_UPDATE_PHONE%></label>
			<div class="col-sm-9">
				<input type="text" name="UpdatePhoneVOL" id="UpdatePhoneVOL" value=<%=AttrQs(strUpdatePhoneVOL)%> maxlength="60" class="form-control">
			</div>
		</div>
		<div class="form-group row">
			<label for="InquiryPhoneVOL" class="control-label col-sm-3"><%=TXT_INQUIRY_PHONE%></label>
			<div class="col-sm-9">
				<input type="text" name="InquiryPhoneVOL" id="InquiryPhoneVOL" value=<%=AttrQs(strInquiryPhoneVOL)%> maxlength="60" class="form-control">
			</div>
		</div>
		<div class="form-group row">
			<label for="InquiryPhoneVOL" class="control-label col-sm-3"><label for="AgencyNUMVOL"><%=TXT_AGENCY_NUM%></label><%If intVOLCount > 0 Then%> <span class="Alert">*</span><%End If%></label>
			<div class="col-sm-9 form-inline form-inline-always">
				<input type="text" name="AgencyNUMVOL" id="AgencyNUMVOL" value=<%=AttrQs(strAgencyNUMVOL)%> size="9" maxlength="8" class="form-control">
				<%If Not Nl(strAgencyNUMVOL) Then%>
				<a href="<%=makeDetailsLink(strAgencyNUMVOL,vbNullString,vbNullString)%>" target="_blank"><span class="glyphicon glyphicon-new-window" title=<%=AttrQs(TXT_RECORD_DETAILS)%>></span></a><%End If%>
				<br><%=TXT_INST_NUM_FINDER%>
			</div>
		</div>
	</td>
</tr>
<%Else%>
<div style="display:none">
<input type="hidden" name="RecordOwnerVOL" value="<%=IIf(bRecordOwnerVOL,"on",vbNullString)%>">
<input type="hidden" name="UpdateEmailVOL" value=<%=AttrQs(strUpdateEmailVOL)%>>
<input type="hidden" name="UpdatePhoneVOL" value=<%=AttrQs(strUpdatePhoneVOL)%>>
<input type="hidden" name="InquiryPhoneVOL" value=<%=AttrQs(strInquiryPhoneVOL)%>>
<input type="hidden" name="AgencyNUMVOL" value=<%=AttrQs(strAgencyNUMVOL)%>>
</div>
<%End If%>
<tr>
	<td class="field-label-cell"><%=TXT_ENFORCE_REQUIRED_FIELDS%> <span class="Alert">*</span></td>
	<td class="field-data-cell"><label for="EnforceReqFields_Yes"><input type="radio" name="EnforceReqFields" id="EnforceReqFields_Yes"<%=Checked(bEnforceReqFields)%> value="on">&nbsp;<%=TXT_YES%></label>
		<label for="EnforceReqFields_No"><input type="radio" name="EnforceReqFields" id="EnforceReqFields_No"<%=Checked(Not bEnforceReqFields)%> value="">&nbsp;<%=TXT_NO%></label></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_USER_ACCOUNT_UPDATES%> <span class="Alert">*</span></td>
	<td class="field-data-cell">
		<div class="clear-line-below">
			<div class="checkbox">
				<label for="UpdateAccountDefault"><input type="checkbox" name="UpdateAccountDefault"<%=Checked(bUpdateAccountDefault)%>><%=TXT_USER_ACCOUNT_UPDATE_DEFAULT%></label>
			</div>
			<div class="checkbox">
				<label for="UpdatePasswordDefault"><input type="checkbox" name="UpdatePasswordDefault"<%=Checked(bUpdatePasswordDefault)%>><%=TXT_USER_PASSWORD_UPDATE_DEFAULT%></label>
			</div>
		</div>
		<div class="form-group row">
			<label for="UpdateAccountEmail" class="control-label col-sm-3"><%=TXT_UPDATE_EMAIL & TXT_COLON%></label>
			<div class="col-sm-9">
				<input type="text" id="UpdateAccountEmail" name="UpdateAccountEmail" value=<%=AttrQs(strUpdateAccountEmail)%> maxlength="100" class="form-control">
			</div>
		</div>
		<div class="form-group row">
			<label for="UpdateAccountLangID" class="control-label col-sm-3"><%=TXT_EMAIL_LANGUAGE & TXT_COLON%></label>
			<div class="col-sm-9">
			<%Call openSysLanguageListRst(True)%>
				<%=makeSysLanguageList(intUpdateAccountLangID,"UpdateAccountLangID",False,vbNullString)%>
			<%Call closeSysLanguageListRst()%>
			</div>
		</div>
</tr>
<tr>
	<td colspan="2" class="field-data-cell">
		<input type="submit" name="Submit" value="<%=TXT_SUBMIT_UPDATES%>" class="btn btn-default">
		<%If bOkDelete Then%><input type="submit" name="Submit" value="<%=TXT_DELETE%>" class="btn btn-default"><%End If%>
		<input type="reset" value="<%=TXT_RESET_FORM%>" class="btn btn-default">
	</td>
</tr>

	</table>
	</div>
</div>
</form>

<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
