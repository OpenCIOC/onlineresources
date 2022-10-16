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
Call setPageInfo(False, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtAgencyContact.asp" -->
<!--#include file="../text/txtCommonForm.asp" -->
<!--#include file="../text/txtDetails.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtFormSecurity.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMonth.asp" -->
<!--#include file="../text/txtVolunteer.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incMonthList.asp" -->
<!--#include file="../includes/referral/incYesVolOpInfo.asp" -->
<!--#include file="../includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="../includes/vprofile/incProfileSecurity.asp" -->
<%
Dim strVNUM, _
	bVNUMError

bVNUMError = False
strVNUM = Request("VNUM")

Call makePageHeader(TXT_YES_VOLUNTEER, TXT_YES_VOLUNTEER, True, False, True, True)

If Nl(strVNUM) Then
	bVNUMError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
ElseIf Not IsVNUMType(strVNUM) Then
	bVNUMError = True
	Call handleError(TXT_INVALID_OPID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
End If

If Not bVNUMError Then
%>
<script type="text/javascript"><!--
	function validateForm() {
		formObj = document.EntryForm;
<%If Not user_bLoggedIn Then%>
		if (formObj.VolunteerName.value == "") {
			formObj.VolunteerName.focus();
			alert(<%=JsQs(TXT_INST_FULL_NAME)%>);
			return false;
		} else if ((formObj.VolunteerEmail.value  == "") && (formObj.VolunteerPhone.value  == "")) {
			formObj.VolunteerEmail.focus();
			alert(<%=JsQs(TXT_INST_EMAIL_PHONE)%>);
			return false;
<%Else%>
		if (false) {
<%End If%>
		} else {
			return true;
		}
	}
//--></script>
<%
	Call setOpInfo()
	If Nl(strPosition) Then
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
	ElseIf Not (bInView Or bInDefaultView) Then
		Call handleError(TXT_ERROR & TXT_RECORD_YOU_REQUESTED & TXT_RECORD_EXISTS_BUT, vbNullString, vbNullString)
%>
<p><%=TXT_CONCERNS & TXT_COLON%><strong><%=strROName%></strong></p>
<%
		Call getROInfo(strRecordOwner,DM_VOL)
		Call printROContactInfo(False)
	ElseIf bExpired Then
		Call handleError(TXT_ERROR & TXT_RECORD_YOU_REQUESTED & " " & TXT_HAS_EXPIRED, vbNullString, vbNullString)
%>
<p><%=TXT_CONCERNS & TXT_COLON%><strong><%=strROName%></strong></p>
<%
		Call getROInfo(strRecordOwner,DM_VOL)
		Call printROContactInfo(False)
	Else
		Call getROInfo(strRecordOwner,DM_VOL)
		Dim dicContactInfo
		Set dicContactInfo = Server.CreateObject("Scripting.Dictionary")
		If vprofile_bLoggedIn Then
		
			Dim objReturn, objErrMsg
			Dim cmdProfileInfo, rsProfileInfo
			Set cmdProfileInfo = Server.CreateObject("ADODB.Command")
			With cmdProfileInfo
				.ActiveConnection = getCurrentVOLBasicCnn()
				.CommandText = "sp_VOL_Profile_s_ReferralForm"
				.CommandType = adCmdStoredProc
				.CommandTimeout = 0
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, vprofile_strID)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
			End With
			Set rsProfileInfo = cmdProfileInfo.Execute()

			Dim objField
			For Each objField in rsProfileInfo.Fields
				dicContactInfo(objField.Name) = objField.Value
			Next

			rsProfileInfo.Close()
			Set rsProfileInfo = Nothing
			Set cmdProfileInfo = Nothing
		End If
%>
<h4><%= TXT_SUBMITTING_INFORMATION_FOR %></h4>
<h3><a href="<%=makeVOLDetailsLink(strVNUM, IIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber,vbNullString),vbNullString)%>"><%=strPosition%> (<%=strOrgName%>)</a></h3>
<%If Not Nl(strDuties) Then%>
<p><span class="FieldLabelClr"><%= TXT_DUTIES & TXT_COLON %></span> <%=strDuties%></p>
<%End If%>
<p class="Info"><%= TXT_INST_DIFFICULTIES_CONTACT %></p>
<%
Call printROContactInfo(False)
Dim strProfileLoginReturnArgs
strProfileLoginReturnArgs = "VNUM=" & strVNUM
%>
<form name="EntryForm" action="volunteer2.asp" role="form" class="form-horizontal" method="POST" onSubmit="return validateForm()">
<%=g_strCacheFormVals%>
<input type="hidden" name="VNUM" value="<%=strVNUM%>">
<%If intCurSearchNumber >= 0 Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%
	strProfileLoginReturnArgs = strProfileLoginReturnArgs & "&Number=" & intCurSearchNumber
%>
<%End If%>
<table class="BasicBorder cell-padding-4 form-table responsive-table max-width-lg clear-line-below">
<tr>
	<th class="RevTitleBox" colspan="2"><%= TXT_VOLUNTEER_FORM %></th>
</tr>
<tr>
	<td colspan="2">
<%
If Not user_bLoggedIn And g_bUseProfilesView And Not vprofile_bLoggedIn Then

	Dim strProfileLoginReturnParams
	strProfileLoginReturnParams = "page="& Server.URLEncode(ps_strThisPageFull) & "&args=" & Server.URLEncode(strProfileLoginReturnArgs)
%>
	<p><strong><em><%= TXT_DO_YOU_HAVE_PROFILE %></em></strong>
	<br><%= TXT_YOU_CAN %> <a href="<%=makeLink("profile/login.asp", strProfileLoginReturnParams, vbNullString)%>"><%= TXT_LOGIN %></a> <%= TXT_TO_YOUR_VOLUNTEER_PROFILE_OR %> <a href="<%=makeLink("profile/create.asp", strProfileLoginReturnParams, vbNullString)%>"><%= TXT_CREATE_A_PROFILE_NEW %></a>.</p>
<%
End If
%>
	<p><%= TXT_INST_FILL_FORM %></p></td>
</tr>
<tr>
	<td class="field-label-cell"><label for="VolunteerName"><%=TXT_NAME%></label></td>
	<td class="field-data-cell"><input type="Text" name="VolunteerName" id="VolunteerName" maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(dicContactInfo("FirstName")) & StringIf(Not Nl(dicContactInfo("FirstName")) And Not Nl(dicContactInfo("LastName"))," ") & Ns(dicContactInfo("LastName"))))%> class="form-control"></td></tr>
<tr>
	<td class="field-label-cell"><label for="VolunteerEmail"><%=TXT_EMAIL%></label></td>
	<td class="field-data-cell"><input type="Text" name="VolunteerEmail" id="VolunteerEmail" maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(vprofile_strEmail)))%> class="form-control"></td>
</tr>
<tr>
	<td class="field-label-cell"><label for="VolunteerPhone"><%=TXT_PHONE%></label></td>
	<td class="field-data-cell"><input type="Text" name="VolunteerPhone" id="VolunteerPhone" maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(dicContactInfo("Phone"))))%> class="form-control"></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_ADDRESS%></td>
	<td class="field-data-cell">
		<div class="row form-group">
			<label class="control-label col-sm-3" for="VolunteerAddress"><%=TXT_ADDRESS%></label>
			<div class="col-sm-9">
				<input type="Text" name="VolunteerAddress" id="VolunteerAddress"  maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(dicContactInfo("Address"))))%> class="form-control">
			</div>
		</div>
		<div class="row form-group">
			<label class="control-label col-sm-3" for="VolunteerCity"><%=TXT_CITY%></label>
			<div class="col-sm-9">
				<input type="Text" name="VolunteerCity" id="VolunteerCity"  maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(dicContactInfo("City"))))%> class="form-control">
			</div>
		</div>
		<div class="row form-group">
			<label class="control-label col-sm-3" for="VolunteerPostalCode"><%=TXT_POSTAL_CODE%></label>
			<div class="col-sm-9 form-inline">
				<input type="Text" name="VolunteerPostalCode" id="VolunteerPostalCode"  maxlength="10" value=<%=AttrQs(Server.HTMLEncode(Ns(dicContactInfo("PostalCode"))))%> class="form-control">
			</div>
		</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell"><label for="VolunteerNotes"><%= TXT_NOTES_COMMENTS %></label></td>
	<td class="field-data-cell"><%= TXT_INST_NOTES_1 %>
	<br><%If Not Nl(strROName) Then%><strong><%=strROName%></strong><%= TXT_OR_LC %><br><%End If%><strong><%=strOrgName%></strong>
	<br><%= TXT_INST_NOTES_2 %>
	<br><textarea name="VolunteerNotes" id="VolunteerNotes" wrap="soft" rows="<%=TEXTAREA_ROWS_LONG%>" class="form-control"></textarea></td>
</tr>
</table>
<%If Not user_bLoggedIn And Not vprofile_bLoggedIn Then%>
<h3 class="Alert"><%=TXT_SECURITY_CHECK%></h3>
<p><%=TXT_ENTER_TOMORROWS_DATE%></p>
<div class="form-group">
	<label for="sCheckDay" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_DAY%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10">
		<input id="sCheckDay" name="sCheckDay" type="text" size="5" maxlength="8" class="form-control">
	</div>
</div>
<div class="form-group">
	<label for="sCheckMonth" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_MONTH%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10 col-md-11">
		<%Call printMonthList("sCheckMonth")%></label>
	</div>
</div>
<div class="form-group">
	<label for="sCheckYear" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_YEAR%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10 col-md-11">
		<input id="sCheckYear" name="sCheckYear" type="text" size="5" maxlength="8" class="form-control">
	</div>
</div>
<%End If%>

<p><input type="submit" value="<%=TXT_SUBMIT%>" class="btn btn-default"> <input type="reset" value="<%=TXT_RESET_FORM%>" class="btn btn-default"></p>
<%
	End If
End If
%>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/search_params.js") %>
<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
