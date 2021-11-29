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
Call setPageInfo(True, DM_GLOBAL, DM_CIC, "../", "import/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtImport.asp" -->
<%
If Not user_bImportPermissionCIC Then
	Call securityFailure()
End If

Dim intEFID, intERID
intEFID = Trim(Request("EFID"))
intERID = Trim(Request("ERID"))

If Nl(intEFID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & intEFID & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_DATASET, _
		"import.asp", vbNullString)
ElseIf Not IsIDType(intEFID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intEFID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_DATASET, _
		"import.asp", vbNullString)
Else
	intEFID = CLng(intEFID)
End If

If Nl(intERID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & intERID & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PRIVACY_PROFILE, _
		"import_info.asp", "EFID=" & intEFID)
ElseIf Not IsIDType(intERID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intERID) & "." & _
			TXT_PRIVACY_PROFILE_ADDED, _
		vbCrLf & "<br>" & TXT_CHOOSE_PRIVACY_PROFILE, _
		"import_info.asp", "EFID=" & intEFID)
Else
	intERID = CLng(intERID)
End If

Dim objReturn, objErrMsg

Dim cmdProfileAdd, rsProfileAdd
Set cmdProfileAdd = Server.CreateObject("ADODB.Command")
With cmdProfileAdd
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_PrivacyProfile_i_Import"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ER_ID", adInteger, adParamInput, 4, intERID)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With

'On Error Resume Next
Set rsProfileAdd = cmdProfileAdd.Execute
Set rsProfileAdd = rsProfileAdd.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_PRIVACY_PROFILE_ADDED, "import_info.asp", "EFID=" & intEFID, False)
	Case Else
		Call handleError(TXT_ADD_PROFILE_FAILED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), "import_info.asp", "EFID=" & intEFID)
End Select

Set rsProfileAdd = Nothing
Set cmdProfileAdd = Nothing
%>

<!--#include file="../includes/core/incClose.asp" -->
