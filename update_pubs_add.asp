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
<!--#include file="includes/core/adovbs.inc" -->
<!--#include file="includes/core/incVBUtils.asp" -->
<!--#include file="includes/validation/incBasicTypes.asp" -->
<!--#include file="includes/core/incRExpFuncs.asp" -->
<!--#include file="includes/core/incHandleError.asp" -->
<!--#include file="includes/core/incSetLanguage.asp" -->
<!--#include file="includes/core/incPassVars.asp" -->
<!--#include file="text/txtGeneral.asp" -->
<!--#include file="text/txtError.asp" -->
<!--#include file="includes/core/incConnection.asp" -->
<!--#include file="includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtUpdatePubs.asp" -->
<%
If user_intCanUpdatePubs = UPDATE_NONE Or user_bLimitedViewCIC Then
	Call securityFailure()
End If

Dim strNUM
strNUM = Request("NUM")

If Nl(strNUM) Then
	Call makePageHeader(TXT_UPDATE_PUBS_TITLE, TXT_UPDATE_PUBS_TITLE, True, False, True, True)
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
	Call makePageFooter(True)
ElseIf Not IsNUMType(strNUM) Then
	Call makePageHeader(TXT_UPDATE_PUBS_TITLE, TXT_UPDATE_PUBS_TITLE, True, False, True, True)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
	Call makePageFooter(True)
Else

Dim intPBID
intPBID = Request("PBID")

If Nl(intPBID) Then
	Call makePageHeader(TXT_UPDATE_PUBS_TITLE, TXT_UPDATE_PUBS_TITLE, True, False, True, True)
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
	Call makePageFooter(True)
ElseIf Not IsIDType(intPBID) Then
	Call makePageHeader(TXT_UPDATE_PUBS_TITLE, TXT_UPDATE_PUBS_TITLE, True, False, True, True)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intPBID) & ".", vbNullString, vbNullString)
	Call makePageFooter(True)
Else
	intPBID = CLng(intPBID)

Dim objReturn, objErrMsg
Dim cmdAddPublication, rsAddPublication
Set cmdAddPublication = Server.CreateObject("ADODB.Command")
With cmdAddPublication
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_NUMPub_i"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	.Parameters.Append .CreateParameter("@PB_ID", adInteger, adParamInput, 4, intPBID)
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With

Set rsAddPublication = cmdAddPublication.Execute
Set rsAddPublication = rsAddPublication.NextRecordset

Select Case cmdAddPublication.Parameters("@RETURN_VALUE").Value
	Case 0
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_ADDED, _
			"update_pubs.asp", _
			"NUM=" & strNUM & _
			IIf(intCurSearchNumber >= 0,"&Number=" & intCurSearchNumber, vbNullString), _
			False)
	Case Else
		Call handleError(TXT_RECORDS_WERE_NOT & TXT_ADDED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			"update_pubs.asp", _
			"NUM=" & strNUM & _
			IIf(intCurSearchNumber >= 0,"&Number=" & intCurSearchNumber, vbNullString))
End Select

End If

End If
%>
<!--#include file="includes/core/incClose.asp" -->
