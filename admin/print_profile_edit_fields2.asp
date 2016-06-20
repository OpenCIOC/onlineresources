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
Call setPageInfo(True, intDomain, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtDisplayOrder.asp" -->
<!--#include file="../text/txtPrintProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<!--#include file="../includes/validation/incDisplayOrder.asp" -->
<%
Const FTYPE_HEADING = 1
Const FTYPE_BASIC = 2
Const FTYPE_FULL = 3
Const FTYPE_CONTINUE = 4

Dim intDomain, _
	strError
	
intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

If Nl(intProfileID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
ElseIf Not IsIDType(intProfileID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	intProfileID = CLng(intProfileID)
End If

Dim intPFLDID
intPFLDID = Request("PFLDID")

If Nl(intPFLDID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_FIELD, _
		"print_profile_edit_fields.asp", "ProfileID=" & intProfileID & "&DM=" & intDomain)
ElseIf Not IsIDType(intPFLDID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intPFLDID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_FIELD, _
		"print_profile_edit_fields.asp", "ProfileID=" & intProfileID & "&DM=" & intDomain)
Else
	intProfileID = CLng(intProfileID)
End If

Dim objReturn, objErrMsg

If Request("Submit") = TXT_DELETE Then

Dim cmdDeleteField, rsDeleteField
Set cmdDeleteField = Server.CreateObject("ADODB.Command")
With cmdDeleteField
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_PrintProfile_Fld_d"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@PFLD_ID", adInteger, adParamInput, 4, intPFLDID)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 4, intDomain)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With

Set rsDeleteField = cmdDeleteField.Execute
Set rsDeleteField = rsDeleteField.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
			"print_profile_edit_fields.asp", _
			"DM=" & intDomain & "&ProfileID=" & intProfileID, _
			False)
	Case Else
		Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			"print_profile_edit_fields.asp", _
			"DM=" & intDomain & "&ProfileID=" & intProfileID)
End Select

Else

Dim intTypeID, _
	intHeadingLevel, _
	strSeparator, _
	strLabelStyle, _
	strContentStyle, _
	strDescriptions, _
	strDesc, _
	strCulture, _
	strField, _
	strValue

intTypeID = CInt(Request("FieldTypeID"))

If intTypeID = FTYPE_HEADING Then
	intHeadingLevel = Nz(Request("HeadingLevel"),1)
	If reEquals(intHeadingLevel,"[0-6]",False,False,True,False) Then
		intHeadingLevel = CInt(intHeadingLevel)
	Else
		intHeadingLevel = 1
	End If
Else
	intHeadingLevel = Null
End If

strSeparator = Null
If Not Nl(Request("Separator")) Then
	strSeparator = Request("Separator")
End If


strLabelStyle = Trim(Request("LabelStyle"))
If Nl(strLabelStyle) Then
	strLabelStyle = Null
End If
strContentStyle = Trim(Request("ContentStyle"))
If Nl(strContentStyle) Then
	strContentStyle = Null
End If

strDescriptions = vbNullString
For Each strCulture In active_cultures()
	strDesc = vbNullString

	For Each strField in Array("Label", "ContentIfEmpty", "Prefix", "Suffix")
		strValue = Trim(Request(strField & "_" & strCulture))

		If strField = "Label" Then
			strValue = Left(strValue, 50)
		Else
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

Call getDisplayOrder()

If Nl(strError) Then
	Dim cmdProfileFlds, rsProfileFlds
	Set cmdProfileFlds = Server.CreateObject("ADODB.Command")
	With cmdProfileFlds
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_PrintProfile_Fld_u"
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@PFLD_ID", adInteger, adParamInput, 4, intPFLDID)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 4, intDomain)
		.Parameters.Append .CreateParameter("@HeadingLevel", adInteger, adParamInput, 1, intHeadingLevel)
		.Parameters.Append .CreateParameter("@Separator", adVarChar, adParamInput, 50, strSeparator)
		.Parameters.Append .CreateParameter("@LabelStyle", adVarChar, adParamInput, 50, strLabelStyle)
		.Parameters.Append .CreateParameter("@ContentStyle", adVarChar, adParamInput, 50, strContentStyle)
		.Parameters.Append .CreateParameter("@DisplayOrder", adInteger, adParamInput, 1, intDisplayOrder)
		.Parameters.Append .CreateParameter("@Descriptions", adVarWChar, adParamInput, -1, strDescriptions)
		.Parameters.Append .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With

	Set rsProfileFlds = cmdProfileFlds.Execute
	Set rsProfileFlds = rsProfileFlds.NextRecordset
	
	If objReturn.Value <> 0 Then
		strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End If

End If

If Nl(strError) Then
	Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
		"print_profile_edit_fields.asp", _
		"DM=" & intDomain & "&ProfileID=" & intProfileID, _
		False)
Else
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & strError, _
		"print_profile_edit_fields.asp", _
		"DM=" & intDomain & "&ProfileID=" & intProfileID)
End If

End If
%>
<!--#include file="../includes/core/incClose.asp" -->
