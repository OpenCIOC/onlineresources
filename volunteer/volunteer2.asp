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
Dim bApi
bApi = Not Nl(Request("api"))
If bApi Then
g_bAllowAPILogin = True
End If
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
<!--#include file="../text/txtDetailsVOL.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtFormSecurity.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMonth.asp" -->
<!--#include file="../text/txtVolunteer.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/core/incSendMail.asp" -->
<!--#include file="../includes/list/incMonthList.asp" -->
<!--#include file="../includes/referral/incYesVolOpInfo.asp" -->
<!--#include file="../includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="../includes/validation/incVulgarCheck.asp" -->
<!--#include file="../includes/vprofile/incProfileSecurity.asp" -->
<%
Dim bFormatXML
bFormatXML = LCase(Ns(Request("format"))) = "xml"
If Not bApi Then
Call makePageHeader(TXT_YES_VOLUNTEER, TXT_YES_VOLUNTEER, True, False, True, True)
ElseIf bFormatXML Then
Response.Clear %><?xml version="1.0" encoding="utf-8"?><%
Response.ContentType = "application/xml"
Response.CacheControl = "Private"
Response.Expires=-1

Call run_response_callbacks()
Else
'Set response type headers
Response.ContentType = "application/json"
Response.CacheControl = "Private"
'Response.Expires=-1

Call run_response_callbacks()
End If
%>
<%
'On Error Resume Next

Dim strVNUM, _
	bVNUMError
	
bVNUMError = False
strVNUM = Request("VNUM")
'If bApi Then
	Dim intOPID
	intOPID = Trim(Request("OPID"))
	If IsIDType(intOPID) And Nl(strVNUM) Then
		intOPID = CLng(intOPID)
		Dim cmdGetVNUM, rsGetVNUM
		Set cmdGetVNUM = Server.CreateObject("ADODB.Command")
		With cmdGetVNUM
			.ActiveConnection = getCurrentVOLBasicCnn()
			.CommandType = adCmdText
			.CommandText = "SELECT VNUM FROM VOL_Opportunity vo WHERE vo.OP_ID=" & intOPID
			.CommandTimeout = 0
			Set rsGetVNUM = .Execute
		End With
		If Not rsGetVNUM.EOF Then
			strVNUM = rsGetVNUM("VNUM")
		End If
	End If
'End IF

Sub handleErrorAPI(strErrorMsg, strRedirect, strHTTPVals)
	If bFormatXML Then
	%><root><error><%= Server.HTMLEncode(strErrorMsg) %></error></root><%
	Else
%>{"error": true, "errinfo": <%= JSONQs(strErrorMsg, True) %>}<%
	End If
	%><!--#include file="../includes/core/incClose.asp" --><%
	Response.End()
End Sub

Dim handleErrorSelected
If bApi Then
	Set handleErrorSelected = GetRef("handleErrorAPI")
	If Not user_bLoggedIn Then
		Call HTTPBasicUnauth("CIOC RPC")
	End If
	If Not has_api_permission(DM_VOL, "realtimestandard") Then
		Call HTTPBasicUnauth("CIOC RPC")
	End If
Else
	Set handleErrorSelected = GetRef("handleError")
End If

If Nl(strVNUM) Then
	bVNUMError = True
	Call handleErrorSelected(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
ElseIf Not IsVNUMType(strVNUM) Then
	bVNUMError = True
	Call handleErrorSelected(TXT_INVALID_OPID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
ElseIf Not user_bLoggedIn And Not bApi And (isVulgar(Request.QueryString) Or isVulgar(Request.Form)) Then
	bVNUMError = True
	Call handleErrorSelected(TXT_WARNING & TXT_WARNING_VULGAR, vbNullString, vbNullString)
Else
	Dim indItem

	Dim bSecurityCheckOkay
	bSecurityCheckOkay = False

	Dim intSCheckDay, _
		intSCheckMonth, _
		intSCheckYear

	intSCheckDay = Trim(Request("sCheckDay"))
	intSCheckMonth = Trim(Request("sCheckMonth"))
	intSCheckYear = Trim(Request("sCheckYear"))
	
	On Error Resume Next
	If Not (Nl(intSCheckDay) Or Nl(intSCheckMonth) Or Nl(intSCheckYear)) Then
		If IsPosSmallInt(intSCheckDay) And IsPosSmallInt(intSCheckMonth) And IsPosSmallInt(intSCheckYear) Then
			If DateSerial(intSCheckYear,intSCheckMonth,intSCheckDay) = DateAdd("d",1,Date()) Then
				If Err.number = 0 Then
					bSecurityCheckOkay = True
				End If
			End If
		End If
	End If
	On Error GoTo 0

	If Not ((user_bLoggedIn And Not bApi) Or vprofile_bLoggedIn Or bSecurityCheckOkay) Then
		bVNUMError = True
		If Not bApi Then
%>
<h3 class="Alert"><%=TXT_SECURITY_CHECK%></h3>
<p><span class="AlertBubble"><%=TXT_INST_SECURITY_CHECK_FAIL%></span></p>
<p><%=TXT_INST_SECURITY_CHECK_2%></p>
<form action="<%=ps_strThisPage%>" method="post" class="form-horizontal">
<div style="display:none">
<%
		For Each indItem In Request.QueryString()
			If Not reEquals(indItem,"sCheck.+",False,False,True,False) Then
				%><input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.QueryString(indItem))%>><%
			End If
		Next
		For Each indItem In Request.Form()
			If Not reEquals(indItem,"sCheck.+",False,False,True,False) Then
				%><input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.Form(indItem))%>><%
			End If
		Next
%>
</div>
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
<div class="form-group">
	<div class="col-sm-offset-2 col-xs-offset-4 col-sm-10 col-xs-8 col-md-offset-1 col-md-11">
		<input type="submit" value="<%=TXT_SUBMIT%>" class="btn btn-default">
	</div>
</div>
</form>
<%
		Else
			Call handleErrorSelected(TXT_INST_SECURITY_CHECK_FAIL, vbNullString, vbNullString)
		End If
	End If
End If
	
If Not bVNUMError Then
	Call setOpInfo()
	If Nl(strPosition) Then
		Call handleErrorSelected(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
	Else
		Call getROInfo(strRecordOwner,DM_VOL)
		
		Dim strAccessURL
		strAccessURL = Request.ServerVariables("HTTP_HOST")
		
		Dim strSubject, strSender, strRecipient, strMsgText
		Dim strSentTo, strDetailLink, strRespondedToListing, strContactInfo
		strDetailLink = TXT_YOU_CAN_VIEW_LISTING & _
			vbCrLf & _
			"https://" & strAccessURL & makeVOLDetailsLink(strVNUM, vbNullString, vbNullString)
		strRespondedToListing = " " & TXT_RESPONDED_TO_THE_LISTING & " " & strPosition & _
			" " & TXT_WITH_LC & " " & strOrgName & _
			" " & TXT_DUTIES_DESCRIBED_AS & vbCrLf & strDuties
		strContactInfo = TXT_TO_DISCUSS_THIS_OPP & " " & _
			IIf(Nl(strContactName),strContactOrg,strContactName & " " & TXT_FROM & " " & strContactOrg) & " " & TXT_AT_NOSPACE & TXT_COLON & _
			IIf(Nl(strContactPhone),vbNullString,vbCrLf & TXT_PHONE & TXT_COLON & strContactPhone) & _
			IIf(Nl(strContactFax),vbNullString,vbCrLf & TXT_FAX & TXT_COLON & strContactFax) & _
			IIf(Nl(strContactEmail),vbNullString,vbCrLf & TXT_EMAIL & TXT_COLON & strContactEmail)
		Dim strVolunteerName, _
			strVolunteerPhone, _
			strVolunteerEmail, _
			strVolunteerAddress, _
			strVolunteerCity, _
			strVolunteerPostalCode, _
			strVolunteerNotes, _
			strFullVolunteerInfo, _
			bOrgEmailed

		strVolunteerName = Trim(Request("VolunteerName"))
		strVolunteerPhone = Trim(Request("VolunteerPhone"))
		strVolunteerEmail = Trim(Request("VolunteerEmail"))
		strVolunteerAddress = Trim(Request("VolunteerAddress"))
		strVolunteerCity = Trim(Request("VolunteerCity"))
		strVolunteerPostalCode = Trim(Request("VolunteerPostalCode"))
		strVolunteerNotes = Trim(Request("VolunteerNotes"))
		bOrgEmailed = False

		If Nl(strVolunteerName) Then
			Call handleErrorSelected(TXT_NAME_REQUIRED, vbNullString, vbNullString)
		ElseIf (Nl(strVolunteerPhone) And Nl(strVolunteerEmail) And Nl(strVolunteerAddress)) Then
			Call handleErrorSelected(TXT_CONTACT_REQUIRED, vbNullString, vbNullString)
		Else	
			strFullVolunteerInfo = TXT_NAME & TXT_COLON & strVolunteerName & _
				IIf(Nl(strVolunteerPhone),vbNullString,vbCrLf & TXT_PHONE & TXT_COLON & strVolunteerPhone) & _
				IIf(Nl(strVolunteerEmail),vbNullString,vbCrLf & TXT_EMAIL & TXT_COLON & strVolunteerEmail) & _
				IIf(Nl(strVolunteerAddress),vbNullString,vbCrLf & TXT_ADDRESS & TXT_COLON & strVolunteerAddress) & _
				IIf(Nl(strVolunteerCity),vbNullString,vbCrLf & TXT_CITY & TXT_COLON & strVolunteerCity) & _
				IIf(Nl(strVolunteerPostalCode),vbNullString,vbCrLf & TXT_POSTAL_CODE & TXT_COLON & strVolunteerPostalCode) & _
				IIf(Nl(strVolunteerNotes),vbNullString,vbCrLf & TXT_NOTES & TXT_COLON & strVolunteerNotes)
			strSender = strROUpdateEmail & " <" & strROUpdateEmail & ">"
			
			'Email the Volunteer
			If Not Nl(strVolunteerEmail) Then
				strRecipient = strVolunteerEmail
				strSubject = TXT_VOL_EMAIL_SUBJECT
				strMsgText = TXT_YOU & strRespondedToListing
				If Not Nl(strContactEmail) Or Not Nl(strROUpdateEmail) Then
					strMsgText = strMsgText & _
						vbCrLf & vbCrLf & TXT_INFORMATION_EMAILED_TO & " "
					If Not Nl(strContactEmail) Then
						strMsgText = strMsgText & vbCrLf & Nz(strContactName,strContactEmail) & " " & TXT_FROM & " " & strContactOrg & " (" & strContactEmail & ")"
					End If
					If Not Nl(strROUpdateEmail) Then
						strMsgText = strMsgText & vbCrLf & strROName & " (" & strROUpdateEmail & ")"
					End If
				End If
				strMsgText = strMsgText & vbCrLf & vbCrLf & strContactInfo & _
					vbCrLf & vbCrLf & strDetailLink & _
					vbCrLf & vbCrLf & TXT_VOL_THANK_YOU
				If Not sendEmail(False, strSender,strRecipient,strSubject,strMsgText) Then
					Call handleErrorSelected(TXT_WARNING & TXT_PROBLEM_EMAIL & " " & strRecipient & ".", vbNullString, vbNullString)
				End If
			End If
			
			'Notify the Agency
			If Not Nl(strContactEmail) Then
				strRecipient = strContactEmail
				strSubject = TXT_VOL_NOTICE
				strMsgText = TXT_SOMEONE & strRespondedToListing & _
					vbCrLf & vbCrLf & TXT_THEY_PROVIDED_INFORMATION & _
					vbCrLf & strFullVolunteerInfo & _
					vbCrLf & vbCrLf & strDetailLink
				strSentTo = strSentTo & "<br><strong>" & Nz(strContactName,strContactEmail) & " " & TXT_FROM & " " & strContactOrg & "</strong> (" & strContactEmail & ")"
				If Not sendEmail(False, strSender,strRecipient,strSubject,strMsgText) Then
					Call handleErrorSelected(TXT_WARNING & TXT_PROBLEM_EMAIL & " " & strRecipient & ".", vbNullString, vbNullString)
				Else
					bOrgEmailed = True
				End If
			End If

			'Notify the Record Owner
			If Not Nl(strROUpdateEmail) Then
				strRecipient = strROUpdateEmail
				strSubject = TXT_ORG_SUBJECT & " " & strPosition & " (" & strOrgName & ")"
				strMsgText = TXT_SOMEONE & strRespondedToListing & _
					vbCrLf & vbCrLf & TXT_THEY_PROVIDED_INFORMATION & _
					vbCrLf & strFullVolunteerInfo
				If Not Nl(strContactEmail) Then
					strMsgText = strMsgText & _
						vbCrLf & vbCrLf & TXT_INFORMATION_ALSO_SENT_TO & strContactName & " " & TXT_FROM & " " & strContactOrg & " (" & strContactEmail & ")"
				End If
				strMsgText = strMsgText & _
					vbCrLf & vbCrLf & strDetailLink
				If Not Nl(strSentTo) Then
					strSentTo = strSentTo & "<br>" & TXT_AND_LC
				End If
				strSentTo = strSentTo & "<br><strong>" & strROName & "</strong> ("  & strROUpdateEmail & ")"
				If Not sendEmail(False, strSender,strRecipient,strSubject,strMsgText) Then
					Call handleErrorSelected(TXT_WARNING & TXT_PROBLEM_EMAIL & " " & strRecipient & ".", vbNullString, vbNullString)
				End If
			End If
			
			Dim cmdInsertReferral, rsInsertReferral
			Set cmdInsertReferral = Server.CreateObject("ADODB.Command")
			With cmdInsertReferral
				.ActiveConnection = getCurrentVOLBasicCnn()
				.CommandText = "dbo.sp_VOL_OP_Referral_u"
				.CommandType = adCmdStoredProc
				.CommandTimeout = 0
				.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append .CreateParameter("@REF_ID", adInteger, adParamOutput, 4, Null)
				.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, IIf(Nl(user_strMod) Or bApi,vbNullString,user_strMod & " ") & "[" & TXT_VOLUNTEER_SUBMISSION & "]")
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
				.Parameters.Append .CreateParameter("@ReferralDate", adDBDate, adParamInput, 2, Now())
				.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, Nz(Request("UseVOLVw"),Null))
				.Parameters.Append .CreateParameter("@AccessURL", adVarChar, adParamInput, 160, strAccessURL & "/volunteer")
				.Parameters.Append .CreateParameter("@FollowUpFlag", adBoolean, adParamInput, 1, SQL_TRUE)
				.Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, vprofile_strID)
				.Parameters.Append .CreateParameter("@VolunteerName", adVarWChar, adParamInput, 100, strVolunteerName)
				.Parameters.Append .CreateParameter("@VolunteerPhone", adVarWChar, adParamInput, 100, strVolunteerPhone)
				.Parameters.Append .CreateParameter("@VolunteerEmail", adVarChar, adParamInput, 100, strVolunteerEmail)
				.Parameters.Append .CreateParameter("@VolunteerAddress", adVarWChar, adParamInput, 100, strVolunteerAddress)
				.Parameters.Append .CreateParameter("@VolunteerCity", adVarWChar, adParamInput, 100, strVolunteerCity)
				.Parameters.Append .CreateParameter("@VolunteerPostalCode", adVarChar, adParamInput, 100, strVolunteerPostalCode)
				.Parameters.Append .CreateParameter("@VolunteerNotes", adVarWChar, adParamInput, 4000, Left(strVolunteerNotes,4000))
				.Parameters.Append .CreateParameter("@NotifyOrgType", adInteger, adParamInput, 4, IIf(bOrgEmailed,1,Null))
				.Parameters.Append .CreateParameter("@NotifyOrgDate", adDBDate, adParamInput, 2, IIf(bOrgEmailed,Now(),Null))
				.Parameters.Append .CreateParameter("@VolunteerContactType", adInteger, adParamInput, 4, Null)
				.Parameters.Append .CreateParameter("@VolunteerContactDate", adDBDate, adParamInput, 2, Null)
				.Parameters.Append .CreateParameter("@SuccessfulPlacement", adBoolean, adParamInput, 1, Null)
				.Parameters.Append .CreateParameter("@OutcomeNotes", adVarChar, adParamInput, 4000, Null)
				.Parameters.Append .CreateParameter("@ErrMsg", adVarChar, adParamOutput, 500)
			End With
			Set rsInsertReferral = cmdInsertReferral.Execute
			Set rsInsertReferral = rsInsertReferral.NextRecordset
			
			If cmdInsertReferral.Parameters("@RETURN_VALUE").Value <> 0 Or Err.Number <> 0 Then
				Call handleErrorSelected(TXT_WARNING & TXT_UNABLE_TO_CREATE_RECORD_OF_REQUEST, _
					vbNullString, _
					vbNullString)
			End If
			
			Set rsInsertReferral = Nothing			
			Set cmdInsertReferral = Nothing
If Not bApi Then
%>
<p class="Info"><%= TXT_VOL_THANK_YOU_INTEREST %></p>
<h4><a href="<%=makeVOLDetailsLink(strVNUM, IIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber,vbNullString),vbNullString)%>"><%=strPosition%> (<%=strOrgName%>)</a></h4>
<p><%= TXT_INFORMATION_EMAILED_TO %> <%=strSentTo%></p>
<p><%= TXT_YOU_CAN_CONTACT %> <strong><%=Nz(strContactName,strContactEmail)%></strong> (<%=strContactOrg%>) <%= TXT_TO_DISCUSS_THIS_OPP_AT %>
<%If Not Nl(strContactPhone) Then%><br><%=TXT_PHONE & TXT_COLON%><strong><%=strContactPhone%></strong><%End If%>
<%If Not Nl(strContactFax) Then%><br><%=TXT_FAX & TXT_COLON%><strong><%=strContactFax%></strong><%End If%>
<%If Not Nl(strContactEmail) Then%><br><%=TXT_EMAIL & TXT_COLON%><strong><a href="mailto:<%=strContactEmail%>"><%=strContactEmail%></a></strong><%End If%>
</p>
<p><%= TXT_VOL_THANK_YOU %></p>
<%
ElseIf bFormatXML Then
%><root><error/></root><%
Else
%>{"error": false, "errinfo": null}<%
End If
		End If
	End If
End If

Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
