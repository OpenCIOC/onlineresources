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
Call setPageInfo(True, DM_CIC, DM_CIC, "../", "import/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtImport.asp" -->
<%
Const CNF_KEEP_EXISTING = 0
Const CNF_TAKE_NEW = 1
Const CNF_DO_NOT_IMPORT = 2

'Ensure user has super user privileges
If Not user_bImportPermissionCIC Then
	Call securityFailure()
End If

'Error variables
Dim strErrorMessage

'Import Entry variables
Dim intEFID, _
	intOwnerConflict, _
	intPrivacyProfileConflict, _
	intPublicConflict, _
	intDeletedConflict, _
	bImportSourceDb, _
	bCancelQ, _
	bUnmappedPrivacySkipFields, _
	strPrivacyMap, _
	strPrivacyMapCon, _
	strAutoAddPubs


intEFID = Trim(Request("EFID"))
If Nl(intEFID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_DATASET, _
		"import.asp", vbNullString)
ElseIf Not IsIDType(intEFID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intEFID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_DATASET, _
		"import.asp", vbNullString)
Else
	intEFID = CLng(intEFID)
End If

intOwnerConflict = Request("OwnerConflict")
If IsNumeric(intOwnerConflict) Then
	intOwnerConflict = CInt(intOwnerConflict)
End If
Select Case intOwnerConflict
	Case CNF_KEEP_EXISTING
	Case CNF_TAKE_NEW
	Case Else
		intOwnerConflict = CNF_DO_NOT_IMPORT
End Select

intPrivacyProfileConflict = Request("PrivacyConflict")
If IsNumeric(intPrivacyProfileConflict) Then
	intPrivacyProfileConflict = CInt(intPrivacyProfileConflict)
End If
Select Case intPrivacyProfileConflict
	Case CNF_KEEP_EXISTING
	Case CNF_TAKE_NEW
	Case Else
		intPrivacyProfileConflict = CNF_DO_NOT_IMPORT
End Select

intPublicConflict = Request("PublicConflict")
If IsNumeric(intPublicConflict) Then
	intPublicConflict = CInt(intPublicConflict)
End If
Select Case intPublicConflict
	Case CNF_KEEP_EXISTING
	Case CNF_TAKE_NEW
	Case Else
		intPublicConflict = CNF_DO_NOT_IMPORT
End Select

intDeletedConflict = Request("DeletedConflict")
If IsNumeric(intDeletedConflict) Then
	intDeletedConflict = CInt(intDeletedConflict)
End If
Select Case intDeletedConflict
	Case CNF_KEEP_EXISTING
	Case CNF_TAKE_NEW
	Case Else
		intDeletedConflict = CNF_DO_NOT_IMPORT
End Select

bImportSourceDb = Request("ImportSourceDb") = "on"

bUnmappedPrivacySkipFields = Trim(Request("QUnmappedPrivacySkipFields")) = "F"

bCancelQ = Request("CancelQ") = "on"

strPrivacyMap = vbNullString
strPrivacyMapCon = vbNullString

If Not bCancelQ Then
Dim strERID, strProfileID
For Each strERID in Split(Request("PrivacyProfiles"), ",")
	If IsIDType(strERID) Then
		strProfileID = Trim(Request("QProfileMap_" & strERID))
		If IsIDType(strERID) Then
			strPrivacyMap = strPrivacyMap & strPrivacyMapCon & strERID & "," & strProfileID
			strPrivacyMapCon = ";"
		End If
	End If
Next
End If

strAutoAddPubs = Request("AutoAddPubs")
If Not IsIDList(strAutoAddPubs) Then
	strAutoAddPubs = Null
End If

'Send the updated information to the selected procedure
Dim objReturn, objErrMsg
Dim cmdUpdateMappingSystem, rsUpdateMappingSystem
Set cmdUpdateMappingSystem = Server.CreateObject("ADODB.Command")
With cmdUpdateMappingSystem 	
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_u_Q"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@EF_ID", adInteger, adParamInput, 4, intEFID)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@QBy", adVarChar, adParamInput, 50, IIf(bCancelQ,Null,user_strMod))
	.Parameters.Append .CreateParameter("@QOwnerConflict", adInteger, adParamInput, 2, intOwnerConflict)
	.Parameters.Append .CreateParameter("@QImportSourceDbInfo", adBoolean, adParamInput, 1, IIf(bImportSourceDb,SQL_TRUE,SQL_FALSE))
	.Parameters.Append .CreateParameter("@QUnmappedPrivacySkipFields", adBoolean, adParamInput, 1, IIf(bUnmappedPrivacySkipFields,SQL_TRUE,SQL_FALSE))
	.Parameters.Append .CreateParameter("@QPrivacyProfileConflict", adInteger, adParamInput, 2, intPrivacyProfileConflict)
	.Parameters.Append .CreateParameter("@QPublicConflict", adInteger, adParamInput, 2, intPublicConflict)
	.Parameters.Append .CreateParameter("@QDeletedConflict", adInteger, adParamInput, 2, intDeletedConflict)
	.Parameters.Append .CreateParameter("@QPrivacyMap", adVarChar, adParamInput, -1, strPrivacyMap)
	.Parameters.Append .CreateParameter("@QAutoAddPubs", adVarChar, adParamInput, -1, strAutoAddPubs)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsUpdateMappingSystem = cmdUpdateMappingSystem.Execute
Set rsUpdateMappingSystem = rsUpdateMappingSystem.NextRecordset

'If there was no error from running the stored procedure, return to the Mapping System Edit page;
'Otherwise, grab the error message if any so it can be printed to the user.
If objReturn.Value = 0 And Err.Number = 0 Then
	Call handleMessage(IIf(bCancelQ,TXT_IMPORT_FILE_NOT_IN_QUEUE,TXT_IMPORT_FILE_IN_QUEUE), _
			"import.asp", _
			vbNullString, _
			False)
Else
	If Err.Number <> 0 Then
		strErrorMessage = Err.Description
	Else
		strErrorMessage = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End If
	Call makePageHeader(TXT_IMPORT_RECORD_DATA, TXT_IMPORT_RECORD_DATA, True, False, True, True)
	Call handleError(TXT_UNABLE_QUEUE_IMPORT_FILE & TXT_COLON & strErrorMessage, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
End If
%>

<!--#include file="../includes/core/incClose.asp" -->
