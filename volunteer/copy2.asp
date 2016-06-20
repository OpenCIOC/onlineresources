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
' Purpose:		Select format and records for export
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
Call setPageInfo(True, DM_VOL, DM_VOL, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtCopyForm.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
If Not user_bCopyVOL And user_intUpdateDOM = UPDATE_NONE Then
	Call securityFailure()
End If

Dim strVNUM, _
	strNewVNUM, _
	bAutoAssignVNUM, _
	strOwner, _
	strFieldList, _
	bCopyOnlyCurrentLang, _
	strCopyCulture, _
	bNonPublic, _
	bVNUMError, _
	intCopyLangID, _
	strPosTitle

strVNUM = Request("VNUM")
If Not IsVNUMType(strVNUM) Then
	bVNUMError = True
	Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
	Call makePageFooter(False)
Else
	strCopyCulture = Left(Trim(Request("CopyLn")),5)

	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_VOL_Opportunity_s_CanCopy"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
		.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, user_strAgency)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
		.Parameters.Append .CreateParameter("@Culture", adVarChar, adParamInput, 5, strCopyCulture)
	End With
	Set rsOrg = cmdOrg.Execute

	If rsOrg.EOF Then
		bVNUMError = True
		Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
		Call makePageFooter(False)
	ElseIf rsOrg.Fields("CAN_UPDATE") = 0 Then
		Call securityFailure()
	Else
		intCopyLangID = rsOrg.Fields("LangID")
		strNewVNUM = rsOrg.Fields("NewVNUM")
		
		If Not Nl(strCopyCulture) And Nl(intCopyLangID) Then
			bVNUMError = True
			Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
			Call handleError(TXT_ERROR & TXT_NOT_A_VALID_LANGUAGE & strCopyCulture & ".", vbNullString, vbNullString)
			Call makePageFooter(False)
		End If
	End If
	rsOrg.Close
	Set rsOrg = Nothing
	Set cmdOrg = Nothing
End If

If Nl(intCopyLangID) Then
	strOwner = Nz(Left(Trim(Request("Owner")),3), user_strAgency)
	strFieldList = Request("IDList")
	strPosTitle = Left(Trim(Request("POSITION_TITLE")), 150)
	strNewVNUM = Nz(Left(Trim(Request("NewVNUM")), 10), strNewVNUM)
	bAutoAssignVNUM = Request("AutoAssignVNUM") = "on"
	If bAutoAssignVNUM Then
		strNewVNUM = Null
	ElseIf Not IsVNUMType(strNewVNUM) Then
		bVNUMError = True
		Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
		Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNewVNUM) & ".", vbNullString, vbNullString)
		Call makePageFooter(False)
	End If
	bCopyOnlyCurrentLang = IIf(Request("CopyOnlyCurrentLang") = "on",SQL_TRUE,SQL_FALSE)
	bNonPublic = IIf(Request("NonPublic") = "on",SQL_TRUE,SQL_FALSE)
End If

If Not bVNUMError Then
	Dim objReturn, objVNUM, objErrMsg
	Dim cmdCopy, rsCopy
	Set cmdCopy = Server.CreateObject("ADODB.Command")
	With cmdCopy
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		If Nl(intCopyLangID) Then
			.CommandText = "sp_VOL_Opportunity_i_Copy"
		Else
			.CommandText = "sp_VOL_Opportunity_i_CopyLang"
		End If
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		If Nl(intCopyLangID) Then
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		End If
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
		If Nl(intCopyLangID) Then
			.Parameters.Append .CreateParameter("@AutoVNUM", adBoolean, adParamInput, 1, IIf(bAutoAssignVNUM,SQL_TRUE,SQL_FALSE))
			Set objVNUM = .CreateParameter("@NewVNUM", adVarChar, adParamInputOutput, 10, Nz(strNewVNUM,Null))
			.Parameters.Append objVNUM
			.Parameters.Append .CreateParameter("@Owner", adVarChar, adParamInput, 3, strOwner)
			.Parameters.Append .CreateParameter("@POSITION_TITLE", adVarChar, adParamInput, 150, strPosTitle)
			.Parameters.Append .CreateParameter("@FieldList", adLongVarChar, adParamInput, -1, Nz(strFieldList,Null))
			.Parameters.Append .CreateParameter("@AddToSet", adInteger, adParamInput, 4, g_intCommunitySetID)
			.Parameters.Append .CreateParameter("@CopyOnlyCurrentLang", adBoolean, adParamInput, 1, bCopyOnlyCurrentLang)
			.Parameters.Append .CreateParameter("@MakeNonPublic", adBoolean, adParamInput, 1, bNonPublic)
		Else
			.Parameters.Append .CreateParameter("@NewLangID", adInteger, adParamInput, 2, intCopyLangID)
		End If
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsCopy = cmdCopy.Execute
	Set rsCopy = rsCopy.NextRecordset

	Select Case objReturn.Value
		Case 0
			If Nl(strCopyCulture) Then
				strNewVNUM = objVNUM.Value
				Call goToPage("entryform.asp", _
					"VNUM=" & objVNUM.Value, _
					vbNullString)			
			Else
				Call goToPage("entryform.asp", _
					"VNUM=" & strVNUM & "&UpdateLn=" & strCopyCulture & StringIf(intCurSearchNumber >=  0,"&Number=" & intCurSearchNumber), _
					vbNullString)			
			End If
		Case Else
			Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
			Call handleError(TXT_ERROR & TXT_RECORD_WAS_NOT_CREATED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
			Call makePageFooter(False)
	End Select

End If
%>
<!--#include file="../includes/core/incClose.asp" -->
