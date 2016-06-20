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
' Purpose:		Add or remove Download Resource URLs
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
<!--#include file="../text/txtDownload.asp" -->
<!--#include file="../includes/validation/incFormDataCheck.asp" -->
<%
Dim intDomain, _
	strType

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strType = TXT_CIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			ps_strPathToStart, _
			vbNullString)
End Select

Const ACTION_UPDATE = 1
Const ACTION_DELETE = 2
Const ACTION_ADD = 3

Dim bConfirmed
bConfirmed = False

Dim intURLID, _
	intActionType, _
	strActionType

Select Case Request("Submit")
	Case TXT_DELETE
		bConfirmed = Request("Confirmed") = "on"
		intActionType = ACTION_DELETE
		strActionType = TXT_DELETED
	Case TXT_ADD
		intActionType = ACTION_ADD
		strActionType = TXT_ADDED
	Case Else
		Call handleError(TXT_NO_ACTION, "download.asp", "DM=" & intDomain)
End Select			

If intActionType = ACTION_DELETE And Not bConfirmed Then
	Call makePageHeader(TXT_CONFIRM_DELETE_RESOURCE & " (" & strType & ")", TXT_CONFIRM_DELETE_RESOURCE & " (" & strType & ")", True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="URLID" value="<%=Request("URLID")%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%
	Call makePageFooter(False)
Else
	Dim strResourceNameXML, _
		strResourceURL

	If Not Nl(Request("URLID")) Then
		If IsIDType(Request("URLID")) Then
			intURLID = CInt(Request("URLID"))
		End If
	End If
	If intActionType <> ACTION_DELETE Then
		strResourceURL = Trim(Request("ResourceURL"))
		Dim strCulture, _
			strResourceName, _
			intLangID

		strResourceNameXML = vbNullString
		For Each strCulture In active_cultures()
			strResourceName = Left(Trim(Request("ResourceName_" & strCulture)),50)
			intLangID = Application("Culture_" & strCulture & "_LangID")
			If Not Nl(strResourceName) And Not Nl(intLangID) Then
				strResourceNameXML = strResourceNameXML & _
					"<NM V=" & XMLQs(strResourceName) & " LANG=" & XMLQs(intLangID) & " />"
			End If
		Next
		strResourceNameXML = "<URL>" & strResourceNameXML & "</URL>"
	End If

	Dim objReturn, objErrMsg
	Dim cmdDownloadURL, rsDownloadURL
	Set cmdDownloadURL = Server.CreateObject("ADODB.Command")
	With cmdDownloadURL
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Prepared = False
		Select Case intActionType
			Case ACTION_DELETE
				.CommandText = "dbo.sp_GBL_DownloadURL_d"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@URL_ID", adInteger, adParamInput, 4, intURLID)
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
			Case ACTION_ADD
				.CommandText = "dbo.sp_GBL_DownloadURL_i"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, intDomain)
				.Parameters.Append .CreateParameter("@ResourceURL", adVarChar, adParamInput, 150, strResourceURL)
				.Parameters.Append .CreateParameter("@ResourceNames", adVarWChar, adParamInput, -1, strResourceNameXML)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
		End Select
	End With

	Set rsDownloadURL = cmdDownloadURL.Execute
	Set rsDownloadURL = rsDownloadURL.NextRecordset
	
	Select Case objReturn.Value
		Case 0
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & strActionType, _
				"download.asp", _
				"DM=" & intDomain, _
				False)
		Case Else
			Call makePageHeader(TXT_UPDATE_RESOURCE_FAILED & " (" & strType & ")", TXT_UPDATE_RESOURCE_FAILED & " (" & strType & ")", True, False, True, True)
			Call handleError(TXT_RECORDS_WERE_NOT & strActionType & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
				vbNullString, _
				vbNullString)
			Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
			Call makePageFooter(False)
	End Select
		
	Set rsDownloadURL = Nothing
	Set cmdDownloadURL = Nothing
	
End If
%>
<!--#include file="../includes/core/incClose.asp" -->

