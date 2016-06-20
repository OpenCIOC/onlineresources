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
<!--#include file="../text/txtCommonForm.asp" -->
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtFeedback.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtReferral.asp" -->
<!--#include file="../text/txtVolunteer.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/update/incEntryFormGeneral.asp" -->
<!--#include file="../includes/referral/incYesVolOpInfo.asp" -->
<%
If Not user_bCanManageReferrals Then
	Call securityFailure()
End If

Const CONTACT_BY_UNKNOWN = -1
Const CONTACT_BY_OTHER = 0
Const CONTACT_BY_PHONE = 1
Const CONTACT_BY_EMAIL = 2
Const CONTACT_BY_FAX = 3
Const CONTACT_IN_PERSON = 4


Sub printContactType(intContactType, strSelectName)
	If Nl(intContactType) Then
		intContactType = -1
	End If
%>
<select name="<%=strSelectName%>" id="<%=strSelectName%>">
	<option value=""<%If intContactType = CONTACT_BY_UNKNOWN Then%> SELECTED<%End If%>> -- </option>
	<option value="<%=CONTACT_BY_PHONE%>"<%If intContactType = CONTACT_BY_PHONE Then%> SELECTED<%End If%>><%=TXT_PHONE%></option>
	<option value="<%=CONTACT_BY_EMAIL%>"<%If intContactType = CONTACT_BY_EMAIL Then%> SELECTED<%End If%>><%=TXT_EMAIL%></option>
	<option value="<%=CONTACT_BY_FAX%>"<%If intContactType = CONTACT_BY_FAX Then%> SELECTED<%End If%>><%=TXT_FAX%></option>
	<option value="<%=CONTACT_IN_PERSON%>"<%If intContactType = CONTACT_IN_PERSON Then%> SELECTED<%End If%>>In Person</option>
	<option value="<%=CONTACT_BY_OTHER%>"<%If intContactType = CONTACT_BY_OTHER Then%> SELECTED<%End If%>>Other</option>
</select>
<%
End Sub

Call makePageHeader(TXT_VOLUNTEER_REFERRAL, TXT_VOLUNTEER_REFERRAL, True, False, True, True)
%>
<%
Dim bError
bError = False

Dim bNew
bNew = False

Dim intREFID, _
	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
	strVNUM, _
	dReferralDate, _
	bFollowUpFlag, _
	strVolunteerName, _
	strVolunteerPhone, _
	strVolunteerEmail, _
	strVolunteerAddress, _
	strVolunteerCity, _
	strVolunteerPostalCode, _
	strVolunteerNotes, _
	intNotifyOrgType, _
	dNotifyOrgDate, _
	intVolunteerContactType, _
	dVolunteerContactDate, _
	bSuccessfulPlacement, _
	strOutcomeNotes, _
	strLanguage, _
	intNotesLen

intREFID = Request("REFID")
strVNUM = Nz(Request("VNUM"),Null)

If Nl(intREFID) Then
	If Nl(strVNUM) Then
		bError = True
		Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
	ElseIf Not IsVNUMType(strVNUM) Then
		bError = True
		Call handleError(TXT_INVALID_OPID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
	Else
		bNew = True
		bSuccessfulPlacement = Null
	End If
ElseIf Not IsIDType(intREFID) Then
	bError = True
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intREFID) & ".", vbNullString, vbNullString)
Else
	intREFID = CLng(intREFID)
	
	Dim cmdReferral, rsReferral
	Set cmdReferral = Server.CreateObject("ADODB.Command")
	With cmdReferral
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_VOL_OP_Referral_s"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@REF_ID", adInteger, adParamInput, 4, intREFID)
		Set rsReferral = .Execute
	End With
	With rsReferral
		If Not .EOF Then
			strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strVNUM = .Fields("VNUM")
			dReferralDate = .Fields("ReferralDate")
			bFollowUpFlag = .Fields("FollowUpFlag")
			strVolunteerName = .Fields("VolunteerName")
			strVolunteerPhone = .Fields("VolunteerPhone")
			strVolunteerEmail = .Fields("VolunteerEmail")
			strVolunteerAddress = .Fields("VolunteerAddress")
			strVolunteerCity = .Fields("VolunteerCity")
			strVolunteerPostalCode = .Fields("VolunteerPostalCode")
			strVolunteerNotes = .Fields("VolunteerNotes")
			intNotifyOrgType = .Fields("NotifyOrgType")
			dNotifyOrgDate = .Fields("NotifyOrgDate")
			intVolunteerContactType = .Fields("VolunteerContactType")
			dVolunteerContactDate = .Fields("VolunteerContactDate")
			bSuccessfulPlacement = .Fields("SuccessfulPlacement")
			strOutcomeNotes = .Fields("OutcomeNotes")
			strLanguage = .Fields("LanguageName")
		Else
			bError = True
			Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intREFID) & ".", vbNullString, vbNullString)
		End If
	End With
End If

If Not bError Then
	Call setOpInfo()
	If Nl(strPosition) Then
		bError = True
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
	End If
End If

If Not bError Then

%>
<p>[ <a href="<%=makeLinkB("referral.asp")%>"><%= TXT_REFERRALS_MAIN_MENU %></a> ]</p>
<h4><%=IIf(bNew,TXT_YOU_ARE_SUBMITTING_REFERRAL_REQUEST,TXT_YOU_ARE_UPDATING_REFERRAL_REQUEST)%></h4>
<table class="BasicBorder cell-padding-3">
<tr>
	<td class="FieldLabelLeft"><%=TXT_POSITION_TITLE%></td>
	<td><strong><a href="<%=makeVOLDetailsLink(strVNUM, IIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber,vbNullString),vbNullString)%>"><%=strPosition%></a></strong>
	<br><em>(<%=strOrgName%>)</em></td>
</tr>
<%If Not Nl(strDuties) Then%>
<tr>
	<td class="FieldLabelLeft"><%= TXT_DUTIES %></td>
	<td><%=strDuties%></td>
</tr>
<%End If%>
<tr>
	<td class="FieldLabelLeft"><%= TXT_CONTACT %></td>
	<td><table class="NoBorder cell-padding-2">
		<tr><td class="FieldLabelLeftClr"><%=TXT_NAME & TXT_COLON%></td><td><%=Nz(strContactName,TXT_UNKNOWN)%><%If Not Nl(strContactOrg) Then%> (<%=strContactOrg%>)<%End If%></td></tr>
		<%If Not Nl(strContactPhone) Then%> 
		<tr><td class="FieldLabelLeftClr"><%=TXT_PHONE & TXT_COLON%></td><td><%=strContactPhone%></td></tr>
		<%End If%>
		<%If Not Nl(strContactFax) Then%> 
		<tr><td class="FieldLabelLeftClr"><%=TXT_FAX & TXT_COLON%></td><td><%=strContactFax%></td></tr>
		<%End If%>
		<%If Not Nl(strContactEmail) Then%> 
		<tr><td class="FieldLabelLeftClr"><%=TXT_EMAIL & TXT_COLON%></td><td><a href="mailto:<%=strContactEmail%>"><%=strContactEmail%></a></td></tr>
		<%End If%>
	</table></td>
</tr>
</table>
<br>
<form action="referral_edit2.asp" method="GET" name="EntryForm" id="EntryForm">
<%=g_strCacheFormVals%>
<input type="hidden" name="VNUM" value="<%=strVNUM%>">
<%If Not Nl(intREFID) Then%>
<input type="hidden" name="REFID" value="<%=intREFID%>">
<%End If%>
<%If intCurSearchNumber >= 0 Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%End If%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox" colspan="2">Administration</th>
</tr>
<%If Not bNew Then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LAST_MODIFIED%></td>
	<td><%=strModifiedDate%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MODIFIED_BY%></td>
	<td><%=strModifiedBy%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_REFERRAL_LANGUAGE%></td>
	<td><%=strLanguage%></td>
</tr>
<%End If%>
<tr>
	<td class="FieldLabelLeft"><label for="ReferralDate"><%= TXT_DATE_OF_REQUEST %></label></td>
	<td><%=makeDateFieldVal("ReferralDate",IIf(bNew,DateString(Date(),True),dReferralDate),True,False,False,False,False,False)%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%= TXT_FOLLOW_UP_REQUIRED %></td>
	<td><label for="FollowUpFlag_Yes"><input type="radio" name="FollowUpFlag" id="FollowUpFlag_Yes" value="on"<%=IIf(bFollowUpFlag," checked",vbNullString)%>>&nbsp;<%=TXT_YES%></label> <label for="FollowUpFlag_No"><input type="radio" name="FollowUpFlag" id="FollowUpFlag_No" value=""<%=IIf(Not bFollowUpFlag," checked",vbNullString)%>>&nbsp;<%=TXT_NO%></label></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="VolunteerContactDate"><%= TXT_VOLUNTEER_CONTACT %></label></td>
	<td><%= TXT_VOL_LAST_CONTACT %>
	<br><%=makeDateFieldVal("VolunteerContactDate",dVolunteerContactDate,True,False,False,False,False,False)%>
	<br><label for="VolunteerContactType"><%= TXT_CONTACTED_BY %></label> <%Call printContactType(intVolunteerContactType,"VolunteerContactType")%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="NotifyOrgDate"><%= TXT_POSITION_CONTACT %></label></td>
	<td><%= TXT_ORG_LAST_CONTACT %>
	<br><%=makeDateFieldVal("NotifyOrgDate",dNotifyOrgDate,True,False,False,False,False,False)%>
	<br><label for="NotifyOrgType"><%= TXT_CONTACTED_BY %></label> <%Call printContactType(intNotifyOrgType,"NotifyOrgType")%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%= TXT_SUCCESSFUL_PLACEMENT %></td>
	<td><label for="SuccessfulPlacement_Unknown"><input type="radio" name="SuccessfulPlacement" id="SuccessfulPlacement_Unknown" value=""<%=IIf(Nl(bSuccessfulPlacement)," checked",vbNullString)%>>&nbsp;<%=TXT_UNKNOWN%> </label>
		<label for="SuccessfulPlacement_Yes"><input type="radio" name="SuccessfulPlacement" id="SuccessfulPlacement_Yes" value="<%=SQL_TRUE%>"<%=IIf(bSuccessfulPlacement," checked",vbNullString)%>>&nbsp;<%=TXT_YES%> </label>
		<label for="SuccessfulPlacement_No"><input type="radio" name="SuccessfulPlacement" id="SuccessfulPlacement_No" value="<%=SQL_FALSE%>"<%=IIf(Not bSuccessfulPlacement," checked",vbNullString)%>>&nbsp;<%=TXT_NO%></label></td>
</tr>
<%
If Nl(strOutcomeNotes) Then
	intNotesLen = 0
Else
	intNotesLen = Len(strVolunteerNotes)
	strOutcomeNotes = Server.HTMLEncode(strOutcomeNotes)
End If
%>
<tr>
	<td class="FieldLabelLeft"><label for="OutcomeNotes"><%= TXT_OUTCOME_NOTES %></label></td>
	<td><span class="SmallNote"><%=TXT_INST_MAX_4000%></span>
	<br><textarea name="OutcomeNotes" id="OutcomeNotes" wrap="virtual" rows="<%=getTextAreaRows(intNotesLen,TEXTAREA_ROWS_LONG)%>" cols="<%=TEXTAREA_COLS%>"><%=strOutcomeNotes%></textarea></td>
</tr>
<tr>
	<th class="RevTitleBox" colspan="2"><%= TXT_ABOUT_VOLUNTEER %></th>
</tr>
<tr>
	<td colspan="2"><%= TXT_INST_VOL_DETAILS %></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="VolunteerName"><%=TXT_NAME%></label></td>
	<td><input type="text" name="VolunteerName" id="VolunteerName" size="<%=TEXT_SIZE%>" maxlength="100" value=<%=AttrQs(strVolunteerName)%>></td></tr>
<tr>
	<td class="FieldLabelLeft"><label for="VolunteerEmail"><%=TXT_EMAIL%></label></td>
	<td><input type="text" name="VolunteerEmail" id="VolunteerEmail" size="<%=TEXT_SIZE%>" maxlength="60" value=<%=AttrQs(strVolunteerEmail)%>></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="VolunteerPhone"><%=TXT_PHONE%></label></td>
	<td><input type="text" name="VolunteerPhone" id="VolunteerPhone" size="<%=TEXT_SIZE%>" maxlength="100" value=<%=AttrQs(strVolunteerPhone)%>></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_ADDRESS%></td>
	<td><table class="NoBorder cell-padding-2">
		<tr><td class="FieldLabelLeftClr"><label for="VolunteerAddress"><%=TXT_ADDRESS%></label></td><td><input type="text" name="VolunteerAddress" id="VolunteerAddress" size="<%=TEXT_SIZE-20%>" maxlength="100" value=<%=AttrQs(strVolunteerAddress)%>></td></tr>
		<tr><td class="FieldLabelLeftClr"><label for="VolunteerCity"><%=TXT_CITY%></label></td><td><input type="text" name="VolunteerCity" id="VolunteerCity" size="<%=TEXT_SIZE-20%>" maxlength="100" value=<%=AttrQs(strVolunteerCity)%>></td></tr>
		<tr><td class="FieldLabelLeftClr"><label for="VolunteerPostalCode"><%=TXT_POSTAL_CODE%></label></td><td><input type="text" name="VolunteerPostalCode" id="VolunteerPostalCode" size="10" maxlength="10" value=<%=AttrQs(strVolunteerPostalCode)%>></td></tr>
	</table></td>
</tr>
<%
If Nl(strVolunteerNotes) Then
	intNotesLen = 0
Else
	intNotesLen = Len(strVolunteerNotes)
	strVolunteerNotes = Server.HTMLEncode(strVolunteerNotes)
End If
%>
<tr>
	<td class="FieldLabelLeft"><label for="VolunteerNotes"><%= TXT_NOTES_COMMENTS %></label></td>
	<td><span class="SmallNote"><%=TXT_INST_MAX_4000%></span>
	<br><textarea name="VolunteerNotes" id="VolunteerNotes" wrap="virtual" rows="<%=getTextAreaRows(intNotesLen,TEXTAREA_ROWS_LONG)%>" cols="<%=TEXTAREA_COLS%>"><%=strVolunteerNotes%></textarea></td>
</tr>
</table>
<%If bNew And Not g_bNoEmail Then%>
<h3 class="Alert"><%=TXT_NOTIFICATIONS%></h3>
<p><strong><%=TXT_NOTIFY_AGENCY%></strong>&nbsp;&nbsp;<label for="NotifyAgency_N"><input type="radio" name="NotifyAgency" id="NotifyAgency_N" value="N" checked>&nbsp;<%=TXT_NO%></label>&nbsp;&nbsp;<label for="NotifyAgency_Y"><input type="radio" name="NotifyAgency" id="NotifyAgency_Y" value="Y">&nbsp;<%=TXT_YES%></label>
<br><strong><%=TXT_NOTIFY_ADMIN%></strong>&nbsp;&nbsp;<label for="NotifyAdmin_N"><input type="radio" name="NotifyAdmin" id="NotifyAdmin_N" value="N" checked>&nbsp;<%=TXT_NO%></label>&nbsp;&nbsp;<label for="NotifyAdmin_Y"><input type="radio" name="NotifyAdmin" id="NotifyAdmin_Y" value="Y">&nbsp;<%=TXT_YES%></label></p>
<%End If%>

<p><input type="submit" name="Submit" value="<%=TXT_SUBMIT%>"> <%If Not bNew Then%><input type="submit" name="Submit" value="<%=TXT_DELETE%>"><%End If%> <input type="RESET" value="<%=TXT_RESET_FORM%>"></p>
</form>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>

<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/datepicker.js") %>
<script type="text/javascript">
jQuery(function() {
		init_cached_state();
		restore_cached_state();
		});
</script>

<%
	g_bListScriptLoaded = True
End If
%>
<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
