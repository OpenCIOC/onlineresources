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
<!--#include file="../text/txtInclusion.asp" -->
<%

Dim bNew
bNew = False

Dim strError

Dim	intInclusionPolicyID, _
	strPolicyTitle, _
	intLangID, _
	strPolicyText

intInclusionPolicyID = Trim(Request("InclusionPolicyID"))
If Nl(intInclusionPolicyID) Then
	bNew = True
	intInclusionPolicyID = Null
ElseIf Not IsIDType(intInclusionPolicyID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intInclusionPolicyID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_POLICY, _
		"setup_inclusion.asp", vbNullString)
Else
	intInclusionPolicyID = CLng(intInclusionPolicyID)
End If

If Request("Submit") = TXT_DELETE Then
	Call goToPage("setup_inclusion_delete.asp","InclusionPolicyID=" & intInclusionPolicyID,vbNullString)
End If

strPolicyTitle = Request("PolicyTitle")
If Nl(strPolicyTitle) Then
	strPolicyTitle = Null
End If

intLangID = Trim(Request("LangID"))
If Nl(intLangID) Then
	intLangID = Null
	strError = TXT_ERR_POLICY_LANGUAGE
ElseIf Not IsNumeric(intLangID) Then
	strError = TXT_ERR_POLICY_LANGUAGE & " " & TXT_INVALID_ID & Server.HTMLEncode(intLangID) & "."
ElseIf Not intLangID >= 0 And intLangID <= MAX_SMALL_INT Then
	strError = TXT_ERR_POLICY_LANGUAGE & " " & TXT_INVALID_ID & Server.HTMLEncode(intLangID) & "."
Else
	intLangID = CLng(intLangID)
End If

strPolicyText = Trim(Request("PolicyText"))
If Len(strPolicyText) > 30000 Then
	strError = TXT_ERR_POLICY_TEXT
End If
If Nl(strPolicyText) Then
	strPolicyText = Null
End If

If Nl(strError) Then
	Dim objReturn, objErrMsg
	Dim cmdPageInfo, rsPageInfo
	Set cmdPageInfo = Server.CreateObject("ADODB.Command")
	With cmdPageInfo
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_GBL_InclusionPolicy_u"
		.CommandTimeout = 0
		.Prepared = False
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@InclusionPolicyID", adInteger, adParamInputOutput, 4, intInclusionPolicyID)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 4, intLangID)
		.Parameters.Append .CreateParameter("@PolicyTitle", adVarWChar, adParamInput, 50, strPolicyTitle)
		.Parameters.Append .CreateParameter("@PolicyText", adLongVarChar, adParamInput, -1, strPolicyText)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With

	Set rsPageInfo = cmdPageInfo.Execute
	Set rsPageInfo = rsPageInfo.NextRecordset
		
	Select Case objReturn.Value
		Case 0
			If Nl(intInclusionPolicyID) Then
				intInclusionPolicyID = cmdPageInfo.Parameters("@InclusionPolicyID")
			End If
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
				"setup_inclusion_edit.asp", _
				"InclusionPolicyID=" & intInclusionPolicyID, _
				False)
		Case Else
		strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End Select
	
	Set rsPageInfo = Nothing
	Set cmdPageInfo = Nothing
End If

If Not Nl(strError) Then
	Call makePageHeader(TXT_UPDATE_POLICY_FAILED, TXT_UPDATE_POLICY_FAILED, True, False, True, True)
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & strError, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
