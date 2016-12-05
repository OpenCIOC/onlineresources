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
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtExportProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<%
Dim intDomain, _
	strDbArea, _
	strStoredProcName

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strDbArea = DM_S_CIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strDbArea = DM_S_VOL
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Dim bError, _
	strErrorMessage

bError = False

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

If Nl(intProfileID) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
ElseIf Not IsIDType(intProfileID) Then
	bError = True
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	intProfileID = CLng(intProfileID)
End If

If Request("Submit") = TXT_DELETE Then
	Call goToPage("print_profile_delete.asp","ProfileID=" & intProfileID & "&DM=" & intDomain,vbNullString)
End If

Dim	strStyleSheet, _
	strTableClass, _
	bMsgBeforeRecord, _
	strSeparator, _
	bPageBreak, _
	bPublic, _
	strInViews, _
	strDescriptions, _
	strDesc, _
	strCulture, _
	strField, _
	strValue, _
	bGotName

strStyleSheet = Trim(Request("StyleSheet"))
strTableClass = Trim(Request("TableClass"))
strSeparator = Request("Separator")

bMsgBeforeRecord = IIf(Request("MsgBeforeRecord") = "on",SQL_TRUE,SQL_FALSE)
bPageBreak = IIf(Request("PageBreak") = "on",SQL_TRUE,SQL_FALSE)
bPublic = IIf(Request("Public") = "on",SQL_TRUE,SQL_FALSE)

strDescriptions = vbNullString
bGotName = False
For Each strCulture In active_cultures()
	strDesc = vbNullString

	For Each strField in Array("ProfileName", "PageTitle", "Header", "Footer", "DefaultMsg")
		strValue = Trim(Request(strField & "_" & strCulture))

		If strField = "ProfileName" Then
			strValue = Left(strValue, 50)
			If Not Nl(strValue) Then
				bGotName = True
			End If
		ElseIf strField = "PageTitle" Then
			strValue = Left(strValue, 100)
		End If

		If Not Nl(strValue) Then
			strDesc = strDesc & "<" & strField & ">" & XMLEncode(strValue) & "</" & strField & ">"
		End If
	Next

	If Not Nl(strDesc) Then
		strDescriptions = strDescriptions & _
			"<DESC><Culture>" & strCulture & "</Culture>" & strDesc & "</DESC>"
	End If

Next

If Not Nl(strDescriptions) Then
	strDescriptions = "<DESCS>" & strDescriptions & "</DESCS>"
End If

If Not bGotName Then
	bError = True
	strErrorMessage = TXT_NO_NAME_PROVIDED
End If

strInViews = Request("InViews")
If Nl(strInViews) Then
	strInViews = Null
End If

If Not bError Then
	Dim objReturn, objErrMsg

	Dim cmdUpdateProfile, rsUpdateProfile
	Set cmdUpdateProfile = Server.CreateObject("ADODB.Command")
	With cmdUpdateProfile 	
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_" & strDbArea & "_PrintProfile_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@StyleSheet", adVarChar, adParamInput, 150, strStyleSheet)
		.Parameters.Append .CreateParameter("@TableClass", adVarChar, adParamInput, 50, strTableClass)
		.Parameters.Append .CreateParameter("@PageBreak", adBoolean, adParamInput, 1, bPageBreak)
		.Parameters.Append .CreateParameter("@Separator", adVarChar, adParamInput, 255, strSeparator)
		.Parameters.Append .CreateParameter("@MsgBeforeRecord", adBoolean, adParamInput, 1, bMsgBeforeRecord)
		.Parameters.Append .CreateParameter("@Public", adBoolean, adParamInput, 1, bPublic)
		.Parameters.Append .CreateParameter("@InViews", adLongVarChar, adParamInput, -1, strInViews)
		.Parameters.Append .CreateParameter("@Descriptions", adVarWChar, adParamInput, -1, strDescriptions)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsUpdateProfile = cmdUpdateProfile.Execute
	Set rsUpdateProfile = rsUpdateProfile.NextRecordset

	If objReturn.Value = 0 And Err.Number = 0 Then
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
				"print_profile_edit.asp", _
				"ProfileID=" & intProfileID & "&DM=" & intDomain, _
				False)
	ElseIf Err.Number <> 0 Then
		strErrorMessage = Err.Description
	Else
		strErrorMessage = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End If
End If

If bError Or Not Nl(strErrorMessage) Then
	Call makePageHeader(TXT_UPDATE_PROFILE_FAILED, TXT_UPDATE_PROFILE_FAILED, True, False, True, True)
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & strErrorMessage, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
