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
<!--#include file="text/txtCopyForm.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<%
If Not user_bCopyCIC And user_intUpdateDOM = UPDATE_NONE Then
	Call securityFailure()
End If

Dim strNUM, _
	strNewNUM, _
	bAutoAssignNUM, _
	strOwner, _
	i, _
	dicOrgName, _
	intRTID, _
	strFieldList, _
	bCopyOnlyCurrentLang, _
	bCopyPubs, _
	bCopyTaxonomy, _
	strCopyCulture, _
	bNonPublic, _
	bNUMError, _
	intCopyLangID, _
	fieldNames

strNUM = Request("NUM")
fieldNames = Array("ORG_LEVEL_1", "ORG_LEVEL_2", "ORG_LEVEL_3", "ORG_LEVEL_4", "ORG_LEVEL_5", "LOCATION_NAME", "SERVICE_NAME_LEVEL_1", "SERVICE_NAME_LEVEL_2")
Set dicOrgName = Server.CreateObject("Scripting.Dictionary")

If Not IsNUMType(strNUM) Then
	bNUMError = True
	Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
	Call makePageFooter(False)
Else
	strCopyCulture = Left(Trim(Request("CopyLn")),5)

	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_GBL_BaseTable_s_CanCopy"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, user_strAgency)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@Culture", adVarChar, adParamInput, 5, strCopyCulture)
	End With
	Set rsOrg = cmdOrg.Execute
	If rsOrg.EOF Then
		bNUMError = True
		Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
		Call makePageFooter(False)
	ElseIf rsOrg.Fields("CAN_UPDATE") = 0 Then
		Call securityFailure()
	Else
		intCopyLangID = rsOrg.Fields("LangID")
		strNewNUM = rsOrg.Fields("NewNUM")
		
		If Not Nl(strCopyCulture) And Nl(intCopyLangID) Then
			bNUMError = True
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
	strNewNUM = Nz(Left(Trim(Request("NewNUM")), 8), strNewNUM)
	bAutoAssignNUM = Request("AutoAssignNUM") = "on"
	If bAutoAssignNUM Then
		strNewNUM = Null
	ElseIf Not IsNUMType(strNewNUM) Then
		bNUMError = True
		Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
		Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNewNUM) & ".", vbNullString, vbNullString)
		Call makePageFooter(False)
	End If
	bCopyOnlyCurrentLang = IIf(Request("CopyOnlyCurrentLang") = "on",SQL_TRUE,SQL_FALSE)
	bCopyPubs = IIf(Request("CopyPubs") = "on",SQL_TRUE,SQL_FALSE)
	bCopyTaxonomy = IIf(Request("CopyTaxonomy") = "on",SQL_TRUE,SQL_FALSE)
	bNonPublic = IIf(Request("NonPublic") = "on",SQL_TRUE,SQL_FALSE)

	intRTID = Request("RECORD_TYPE")
	

	For Each i in fieldNames
		dicOrgName(i) = Request(i)
		If dicOrgName(i) = Request("Old" + i) Then
			dicOrgName(i) = "[COPY]"
		End If
	Next
End If

If Not bNUMError Then
	Dim objReturn, objNUM, objErrMsg
	Dim cmdCopy, rsCopy
	Set cmdCopy = Server.CreateObject("ADODB.Command")
	With cmdCopy
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		If Nl(intCopyLangID) Then
			.CommandText = "sp_GBL_BaseTable_i_Copy"
		Else
			.CommandText = "sp_GBL_BaseTable_i_CopyLang"
		End If
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		If Nl(intCopyLangID) Then
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		End If
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		If Nl(intCopyLangID) Then
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
			.Parameters.Append .CreateParameter("@AutoNUM", adBoolean, adParamInput, 1, IIf(bAutoAssignNUM,SQL_TRUE,SQL_FALSE))
			Set objNUM = .CreateParameter("@NewNUM", adVarChar, adParamInputOutput, 8, Nz(strNewNUM,Null))
			.Parameters.Append objNUM
			.Parameters.Append .CreateParameter("@Owner", adVarChar, adParamInput, 3, strOwner)
			For Each i in fieldNames
				.Parameters.Append .CreateParameter("@" + i, adVarChar, adParamInput, 200, Nz(dicOrgName(i),Null))
			Next
			.Parameters.Append .CreateParameter("@RecordType", adInteger, adParamInput, 4, Nz(intRTID,Null))
			.Parameters.Append .CreateParameter("@FieldList", adLongVarChar, adParamInput, -1, Nz(strFieldList,Null))
			.Parameters.Append .CreateParameter("@CopyPubs", adBoolean, adParamInput, 1, bCopyPubs)
			.Parameters.Append .CreateParameter("@CopyTaxonomy", adBoolean, adParamInput, 1, bCopyTaxonomy)
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
				strNewNUM = objNUM.Value
				Call goToPage("entryform.asp", _
					"NUM=" & strNewNUM, _
					vbNullString)			
			Else
				Call goToPage("entryform.asp", _
					"NUM=" & strNUM & "&UpdateLn=" & strCopyCulture & StringIf(intCurSearchNumber >= 0,"&Number=" & intCurSearchNumber), _
					vbNullString)			
			End If
		Case Else
			Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, True, True, True, True)
			Call handleError(TXT_ERROR & TXT_RECORD_WAS_NOT_CREATED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
			Call makePageFooter(False)
	End Select

End If
%>
<!--#include file="includes/core/incClose.asp" -->
