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
<!--#include file="../text/txtSearchTips.asp" -->
<%
'On Error Resume Next

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

Dim	intSearchTipsID, _
	intLangID, _
	strLanguageName, _
	strPageTitle, _
	strPageText

intSearchTipsID = Trim(Request("SearchTipsID"))
If Nl(intSearchTipsID) Then
	intSearchTipsID = Null
ElseIf Not IsIDType(intSearchTipsID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intSearchTipsID) & ".", _
		"setup_searchtips.asp", vbNullString)
Else
	intSearchTipsID = CLng(intSearchTipsID)
End If

If Request("Submit") = TXT_DELETE Then
	Call goToPage("setup_searchtips_delete.asp","DM=" & intDomain & "&SearchTipsID=" & intSearchTipsID,vbNullString)
End If

strPageTitle = Request("PageTitle")
If Nl(strPageTitle) Then
	strPageTitle = Null
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

strPageText = Trim(Request("PageText"))
If Len(strPageText) > 30000 Then
	strError = TXT_ERR_SEARCH_TIPS_TEXT
End If
If Nl(strPageText) Then
	strPageText = Null
End If

If Nl(strError) Then
	Dim objReturn, objErrMsg
	Dim cmdPageInfo, rsPageInfo
	Set cmdPageInfo = Server.CreateObject("ADODB.Command")
	With cmdPageInfo
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_GBL_SearchTips_u"
		.CommandTimeout = 0
		.Prepared = False
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@SearchTipsID", adInteger, adParamInputOutput, 4, intSearchTipsID)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2, intLangID)
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, intDomain)
		.Parameters.Append .CreateParameter("@PageTitle", adVarWChar, adParamInput, 50, strPageTitle)
		.Parameters.Append .CreateParameter("@PageText", adVarWChar, adParamInput, -1, strPageText)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
		Set rsPageInfo = .Execute
		Set rsPageInfo = rsPageInfo.NextRecordset
		
		Select Case objReturn.Value
			Case 0
				If Nl(intSearchTipsID) Then
					intSearchTipsID = .Parameters("@SearchTipsID")
				End If
				Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
					"setup_searchtips_edit.asp", _
					"DM=" & intDomain & "&SearchTipsID=" & intSearchTipsID, _
					False)
			Case Else
				strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
		End Select
	
		Set rsPageInfo = Nothing
		Set cmdPageInfo = Nothing
	End With
End If

If Not Nl(strError) Then
	Call makePageHeader(TXT_UPDATE_SEARCH_TIPS_FAILED, TXT_UPDATE_SEARCH_TIPS_FAILED, True, False, True, True)
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & strError, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
