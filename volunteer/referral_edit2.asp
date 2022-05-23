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
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtFormDataCheck.asp" -->
<!--#include file="../text/txtReferral.asp" -->
<!--#include file="../text/txtVolunteer.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/core/incSendMail.asp" -->
<!--#include file="../includes/referral/incYesVolOpInfo.asp" -->
<!--#include file="../includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="../includes/validation/incFormDataCheck.asp" -->
<%
'On Error Resume Next

If Not user_bCanManageReferrals Then
	Call securityFailure()
End If

Dim bError, _
	strErrorList, _
	strErrorMessage
bError = False

Dim bNew
bNew = False

Dim intREFID, _
	strVNUM

intREFID = Request("REFID")
strVNUM = Request("VNUM")
If Nl(intREFID) Then
	If Nl(strVNUM) Then
		bError = True
		strErrorMessage = TXT_NO_RECORD_CHOSEN
	Else
		intREFID = Null
		bNew = True
		bSuccessfulPlacement = Null
	End If
ElseIf Not IsIDType(intREFID) Then
	bError = True
	strErrorMessage = TXT_INVALID_ID & Server.HTMLEncode(intREFID) & "."
Else
	intREFID = CLng(intREFID)
End If

If Request("Submit") = TXT_DELETE Then
	Call goToPage("referral_delete2.asp","REFID=" & intREFID,vbNullString)
End If

If Not bError Then
	If Not IsVNUMType(strVNUM) Then
		bError = True
		strErrorMessage = TXT_INVALID_OPID & Server.HTMLEncode(strVNUM) & "."
	Else
		Call setOpInfo()
		If Nl(strPosition) Then
			bError = True
			strErrorMessage = TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strVNUM) & "."
		End If
	End If
End If

If bError Then
	Call makePageHeader(TXT_VOLUNTEER_REFERRAL, TXT_VOLUNTEER_REFERRAL, True, False, True, True)
	Call handleError(strErrorMessage, _
			vbNullString, _
			vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(True)
Else
	Dim	dReferralDate, _
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
		bNotifyAgency, _
		bNotifyAdmin

	dReferralDate = Nz(Trim(Request("ReferralDate")),Null)
	If checkDate(TXT_DATE_OF_REQUEST, dReferralDate) Then
		If Not Nl(dReferralDate) Then
			dReferralDate = CDate(dReferralDate)
		End If
	End If
	bFollowUpFlag = CbToSQLBool("FollowUpFlag")
	strVolunteerName = Trim(Request("VolunteerName"))
	strVolunteerPhone = Trim(Request("VolunteerPhone"))
	strVolunteerEmail = Trim(Request("VolunteerEmail"))
	Call checkEmail(TXT_POTENTIAL_VOL_EMAIL, strVolunteerEmail)
	strVolunteerAddress = Trim(Request("VolunteerAddress"))
	strVolunteerCity = Trim(Request("VolunteerCity"))
	strVolunteerPostalCode = Trim(Request("VolunteerPostalCode"))
	Call checkPostalCode(TXT_POTENTIAL_VOL_POSTAL_CODE,strVolunteerPostalCode)
	strVolunteerNotes = Left(Trim(Request("VolunteerNotes")),4000)
	intNotifyOrgType = Nz(Request("NotifyOrgType"),Null)
	dNotifyOrgDate = Nz(Trim(Request("NotifyOrgDate")),Null)
	If checkDate(TXT_POS_LAST_CONTACT, dNotifyOrgDate) Then
		If Not Nl(dNotifyOrgDate) Then
			dNotifyOrgDate = CDate(dNotifyOrgDate)
		End If
	End If
	intVolunteerContactType = Nz(Request("VolunteerContactType"),Null)
	dVolunteerContactDate = Nz(Trim(Request("VolunteerContactDate")),Null)
	If checkDate(TXT_VOL_LAST_CONTACT_DATE, dVolunteerContactDate) Then
		If Not Nl(dVolunteerContactDate) Then
			dVolunteerContactDate = CDate(dVolunteerContactDate)
		End If
	End If
	bSuccessfulPlacement = Nz(Request("SuccessfulPlacement"),Null)
	strOutcomeNotes = Left(Trim(Request("OutcomeNotes")),4000)

	bNotifyAdmin = Request("NotifyAdmin") = "Y"
	bNotifyAgency = Request("NotifyAgency") = "Y"

	If Nl(strVolunteerName) Then
		strErrorList = strErrorList & "<li>" & TXT_VOLUNTEER_EMAIL_MISSING & "</li>"
	End If
	If (Nl(strVolunteerPhone) And Nl(strVolunteerEmail) And Nl(strVolunteerAddress)) Then
		strErrorList = strErrorList & "<li>" & TXT_VOLUNTEER_CONTACT_MISSING & "</li>"
	End If

	'If there are errors identified, print the list of errors
	If Not Nl(strErrorList) Then
		Call makePageHeader(TXT_VOLUNTEER_REFERRAL, TXT_VOLUNTEER_REFERRAL, True, False, True, True)
		Call handleError(TXT_RECORDS_WERE_NOT & IIf(bNew,TXT_ADDED,TXT_UPDATED) & TXT_COLON & "<ul>" & strErrorList & "</ul>", _
			vbNullString, _
			vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
		Call makePageFooter(True)
	Else
		Dim strAccessURL
		If Nl(intREFID) Then
			strAccessURL = reReplace(Request.ServerVariables("PATH_INFO"),"(.*)\/" & ps_strThisPage,"$1",True,False,False,False)
			strAccessURL = Request.ServerVariables("HTTP_HOST") & strAccessURL
		Else
			strAccessURL = Null
		End If
		
		Dim cmdUpdateReferral, rsUpdateReferral
		Set cmdUpdateReferral = Server.CreateObject("ADODB.Command")
		With cmdUpdateReferral
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_VOL_OP_Referral_u"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
			.Parameters.Append .CreateParameter("@REF_ID", adInteger, adParamInputOutput, 4, intREFID)
			.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
			.Parameters.Append .CreateParameter("@ReferralDate", adDBDate, adParamInput, 1, dReferralDate)
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, Null)
			.Parameters.Append .CreateParameter("@AccessURL", adVarChar, adParamInput, 160, strAccessURL)
			.Parameters.Append .CreateParameter("@FollowUpFlag", adBoolean, adParamInput, 1, bFollowUpFlag)
			.Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, Null)
			.Parameters.Append .CreateParameter("@VolunteerName", adVarWChar, adParamInput, 100, strVolunteerName)
			.Parameters.Append .CreateParameter("@VolunteerPhone", adVarWChar, adParamInput, 100, strVolunteerPhone)
			.Parameters.Append .CreateParameter("@VolunteerEmail", adVarChar, adParamInput, 100, strVolunteerEmail)
			.Parameters.Append .CreateParameter("@VolunteerAddress", adVarWChar, adParamInput, 100, strVolunteerAddress)
			.Parameters.Append .CreateParameter("@VolunteerCity", adVarWChar, adParamInput, 100, strVolunteerCity)
			.Parameters.Append .CreateParameter("@VolunteerPostalCode", adVarChar, adParamInput, 100, strVolunteerPostalCode)
			.Parameters.Append .CreateParameter("@VolunteerNotes", adVarChar, adParamInput, 4000, strVolunteerNotes)
			.Parameters.Append .CreateParameter("@NotifyOrgType", adInteger, adParamInput, 4, intNotifyOrgType)
			.Parameters.Append .CreateParameter("@NotifyOrgDate", adDBDate, adParamInput, 1, dNotifyOrgDate)
			.Parameters.Append .CreateParameter("@VolunteerContactType", adInteger, adParamInput, 4, intVolunteerContactType)
			.Parameters.Append .CreateParameter("@VolunteerContactDate", adDBDate, adParamInput, 1, dVolunteerContactDate)
			.Parameters.Append .CreateParameter("@SuccessfulPlacement", adBoolean, adParamInput, 1, bSuccessfulPlacement)
			.Parameters.Append .CreateParameter("@OutcomeNotes", adVarWChar, adParamInput, 4000, strOutcomeNotes)
			.Parameters.Append .CreateParameter("@ErrMsg", adVarChar, adParamOutput, 500)
		End With
		Set rsUpdateReferral = cmdUpdateReferral.Execute
		Set rsUpdateReferral = rsUpdateReferral.NextRecordset
		
		If cmdUpdateReferral.Parameters("@RETURN_VALUE").Value <> 0 Or Err.Number <> 0 Then
			'There was an error executing the stored procedure.
			'Print any error messages from the ASP or Stored Procedure
			If Err.Number <> 0 Then
				strErrorMessage = Err.Description
			Else
				strErrorMessage = cmdUpdateReferral.Parameters("@ErrMsg")
			End If
			Call makePageHeader(TXT_VOLUNTEER_REFERRAL, TXT_VOLUNTEER_REFERRAL, True, False, True, True)
			Call handleError(TXT_RECORDS_WERE_NOT & IIf(bNew,TXT_ADDED,TXT_UPDATED) & TXT_COLON & strErrorMessage, _
				vbNullString, _
				vbNullString)
			Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
			Call makePageFooter(True)
		Else
			If bNotifyAgency Or bNotifyAdmin Then
				Call getROInfo(strRecordOwner,DM_VOL)
			
				Dim strSubject, strSender, strRecipient, strMsgText
				Dim strSentTo, strDetailLink, strRespondedToListing, strContactInfo
				strDetailLink = TXT_YOU_CAN_VIEW_LISTING & " " & _
					vbCrLf & _
					"https://" & g_strBaseURLVOL & "/volunteer/" & StringIf(Nl(strRecordRoot), "details.asp?VNUM=") & strRecordRoot & strVNUM
				strRespondedToListing = " " & TXT_RESPONDED_TO_THE_LISTING & " " & strPosition & _
					" " & TXT_WITH & " " & strOrgName & _
					" " & TXT_DUTIES_DESCRIBED_AS & vbCrLf & strDuties
				strContactInfo = TXT_TO_DISCUSS_THIS_OPP & _
					IIf(Nl(strContactName),strContactOrg,strContactName & " " & TXT_FROM & " " & strContactOrg) & " " & TXT_AT_NOSPACE & TXT_COLON & _
					IIf(Nl(strContactPhone),vbNullString,vbCrLf & TXT_PHONE & TXT_COLON & strContactPhone) & _
					IIf(Nl(strContactFax),vbNullString,vbCrLf & TXT_FAX & TXT_COLON & strContactFax) & _
					IIf(Nl(strContactEmail),vbNullString,vbCrLf & TXT_EMAIL & TXT_COLON & strContactEmail)
		
				Dim strFullVolunteerInfo, _
					bOrgEmailed
		
				bOrgEmailed = False
			
				strFullVolunteerInfo = TXT_NAME & TXT_COLON & strVolunteerName & _
					IIf(Nl(strVolunteerPhone),vbNullString,vbCrLf & TXT_PHONE & TXT_COLON & strVolunteerPhone) & _
					IIf(Nl(strVolunteerEmail),vbNullString,vbCrLf & TXT_EMAIL & TXT_COLON & strVolunteerEmail) & _
					IIf(Nl(strVolunteerAddress),vbNullString,vbCrLf & TXT_ADDRESS & TXT_COLON & strVolunteerAddress) & _
					IIf(Nl(strVolunteerCity),vbNullString,vbCrLf & TXT_CITY & TXT_COLON & strVolunteerCity) & _
					IIf(Nl(strVolunteerPostalCode),vbNullString,vbCrLf & TXT_POSTAL_CODE & TXT_COLON & strVolunteerPostalCode) & _
					IIf(Nl(strVolunteerNotes),vbNullString,vbCrLf & TXT_NOTES & TXT_COLON & strVolunteerNotes)
				strSender = strROUpdateEmail & " <" & strROUpdateEmail & ">"
				
				'Notify the Agency
				If bNotifyAgency And Not Nl(strContactEmail) Then
					strRecipient = strContactEmail
					strSubject = TXT_VOL_NOTICE
					strMsgText = TXT_SOMEONE & strRespondedToListing & _
						vbCrLf & vbCrLf & TXT_THEY_PROVIDED_INFORMATION & _
						vbCrLf & strFullVolunteerInfo & _
						vbCrLf & vbCrLf & strDetailLink
					If Not sendEmail(False, strSender,strRecipient,strSubject,strMsgText) Then
						strErrorList = strErrorList & "<li>" & TXT_PROBLEM_EMAIL & " " & strRecipient & ".</li>"
					Else
						bOrgEmailed = True
					End If
				End If
	
				'Notify the Record Owner
				If bNotifyAdmin And Not Nl(strROUpdateEmail) Then
					strRecipient = strROUpdateEmail
					strSubject = TXT_ORG_SUBJECT & " " & strPosition & " (" & strOrgName & ")"
					strMsgText = TXT_SOMEONE & strRespondedToListing & _
						vbCrLf & vbCrLf & TXT_THEY_PROVIDED_INFORMATION & _
						vbCrLf & strFullVolunteerInfo
					If bNotifyAgency And Not Nl(strContactEmail) Then
						strMsgText = strMsgText & _
							vbCrLf & vbCrLf & TXT_INFORMATION_ALSO_SENT_TO & " " & strContactName & " " & TXT_FROM & " " & strContactOrg & " (" & strContactEmail & ")"
					End If
					strMsgText = strMsgText & _
						vbCrLf & vbCrLf & strDetailLink
					If Not sendEmail(False, strSender,strRecipient,strSubject,strMsgText) Then
						strErrorList = strErrorList & "<li>" & TXT_PROBLEM_EMAIL & " " & strRecipient & ".</li>"
					End If
				End If

			End If

			If bNew Then
				intREFID = cmdUpdateReferral.Parameters("@REF_ID").Value
			End If

			If Not Nl(strErrorList) Then
				Call handleError(TXT_WARNING & "<ul>" & strErrorList & "</ul>", _
						"referral_edit.asp", _
						"REFID=" & intREFID)
			Else
				Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
					"referral_edit.asp", _
					"REFID=" & intREFID, _
					False)
			End If
			
			Set rsUpdateReferral = Nothing			
			Set cmdUpdateReferral = Nothing
			
		End If 'Error in SP
	End If 'Not Nl(strErrorList)
End If 'Not bError
%>
<!--#include file="../includes/core/incClose.asp" -->
