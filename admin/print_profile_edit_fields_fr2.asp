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
<!--#include file="../text/txtPrintProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<!--#include file="../includes/validation/incDisplayOrder.asp" -->
<%
Sub getRunOrder()
	intRunOrder = Trim(Request("RunOrder"))
	If Nl(intRunOrder) Then
		strError = TXT_INST_RUN_ORDER_NULL
		intRunOrder = Null
	ElseIf Not IsDisplayOrderType(intRunOrder) Then
		strError = TXT_INST_RUN_ORDER_BETWEEN & MAX_TINY_INT
		intRunOrder = Null
	Else
		intRunOrder = CInt(intRunOrder)
	End If
End Sub

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

Dim intPFLDID
intPFLDID = Trim(Request("PFLDID"))

If Nl(intPFLDID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
ElseIf Not IsIDType(intPFLDID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intPFLDID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	intPFLDID = CLng(intPFLDID)
End If

Dim intPFLDRPID
intPFLDRPID = Trim(Request("PFLDRPID"))

If Nl(intPFLDRPID) Then
	intPFLDRPID = Null
ElseIf Not IsIDType(intPFLDRPID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intPFLDRPID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	intPFLDRPID = CLng(intPFLDRPID)
End If

If Request("Submit") = TXT_DELETE Then
If Not Request("Confirmed") = "on" Or Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
	Call makePageHeader(TXT_CONFIRM_DELETE_FIND_AND_REPLACE, TXT_CONFIRM_DELETE_FIND_AND_REPLACE, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="PFLDID" value="<%=intPFLDID%>">
<input type="hidden" name="PFLDRPID" value="<%=intPFLDRPID%>">
<input type="hidden" name="DM" value="<%= intDomain %>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%
	Call makePageFooter(False)

Else

If Nl(intPFLDRPID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
End If

Dim objReturn, objErrMsg
Dim cmdDeleteField, rsDeleteField
Set cmdDeleteField = Server.CreateObject("ADODB.Command")
With cmdDeleteField
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_PrintProfile_Fld_FindReplace_d"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@PFLD_RP_ID", adInteger, adParamInput, 4, intPFLDRPID)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 4, intDomain)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsDeleteField = cmdDeleteField.Execute

If objReturn.Value = 0 And Err.Number = 0 Then
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
			"print_profile_edit_fields_fr.asp", _
			"DM=" & intDomain & "&PFLDID=" & intPFLDID, _
			False)
Else
	If Err.Number <> 0 Then
		strError = Err.Description
	Else
		strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End If
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & strError, _
		"print_profile_edit_fields_fr.asp", _
		"DM=" & intDomain & "&PFLDID=" & intPFLDID)
End If


End If

Else

Dim intRunOrder, _
	strLookFor, _
	strReplaceWith, _
	strLangID, _
	bRegEx, _
	bMatchCase, _
	bMatchAll		

Call getRunOrder()

strLookFor = Request("LookFor")
strReplaceWith = Request("ReplaceWith")
bRegEx = Request("RegEx") = "on"
bMatchCase = Request("MatchCase") = "on"
bMatchAll = Request("MatchAll") = "on"

strLangID = Trim(Request("LangID"))
If Nl(strLangID) Then
	strError = TXT_INST_APPLY_ENGLISH_OR_FRENCH
ElseIf Not IsIDList(strLangID) Then
	strError = TXT_INST_APPLY_ENGLISH_OR_FRENCH
End If


If Nl(strError) Then
	Dim cmdProfileFlds, rsProfileFlds
	Set cmdProfileFlds = Server.CreateObject("ADODB.Command")
	With cmdProfileFlds
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_GBL_PrintProfile_Fld_FindReplace_u"
		.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append .CreateParameter("@PFLD_RP_ID", adInteger, adParamInput, 4, intPFLDRPID)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 4, intDomain)
		.Parameters.Append .CreateParameter("@PFLD_ID", adInteger, adParamInput, 4, intPFLDID)
		.Parameters.Append .CreateParameter("@RunOrder", adInteger, adParamInput, 1, intRunOrder)
		.Parameters.Append .CreateParameter("@LookFor", adVarWChar, adParamInput, 500, strLookFor)
		.Parameters.Append .CreateParameter("@ReplaceWith", adVarWChar, adParamInput, 500, strReplaceWith)
		.Parameters.Append .CreateParameter("@RegEx", adBoolean, adParamInput, 1, IIf(bRegEx,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@MatchCase", adBoolean, adParamInput, 1, IIf(bMatchCase,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@MatchAll", adBoolean, adParamInput, 1, IIf(bMatchAll,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@LangID", adLongVarChar, adParamInput, -1, strLangID)
		.Parameters.Append .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.CommandTimeout = 0
	End With
	Set rsProfileFlds = cmdProfileFlds.Execute
	If cmdProfileFlds.Parameters("@RETURN_VALUE").Value <> 0 Then
		strError = cmdProfileFlds.Parameters("@ErrMsg").Value
	ElseIf Err.Number <> 0 Then
		strError = Err.Description
	End If
End If

If Nl(strError) Then
	Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
		"print_profile_edit_fields_fr.asp", _
		"DM=" & intDomain & "&PFLDID=" & intPFLDID, _
		False)
Else
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & strError, _
		"print_profile_edit_fields_fr.asp", _
		"DM=" & intDomain & "&PFLDID=" & intPFLDID)
End If

End If
%>
<!--#include file="../includes/core/incClose.asp" -->
