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
' Purpose:		Process changes to field names and display order
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
<!--#include file="../text/txtDisplayOrder.asp" -->
<!--#include file="../text/txtField.asp" -->
<!--#include file="../includes/validation/incDisplayOrder.asp" -->
<%
Dim intDomain, _
	strType, _
	strFType, _
	bSuperUserGlobal, _
	bDelete

Dim strStoredProcName

bDelete = (Request("Submit") = TXT_DELETE)

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		bSuperUserGlobal = user_bSuperUserGlobalCIC
		strType = TXT_CIC
		strStoredProcName = "dbo.sp_GBL_FieldOption_" & IIf(bDelete,"d","u") & "_Extra"
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		bSuperUserGlobal = user_bSuperUserGlobalVOL
		strType = TXT_VOLUNTEER
		strStoredProcName = "dbo.sp_VOL_FieldOption_" & IIf(bDelete,"d","u") & "_Extra"
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

strFType = Request("FType")
If Not reEquals(strFType,"d|e|l|p|r|t|w",False,False,True,False) Then
	Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
		"setup.asp", _
		vbNullString)
End If

Dim strErrorList

Dim	intFieldID, _
	strFieldName, _
	strExtraFieldType, _
	strOldName, _
	intMaxLength, _
	intOldMaxLength, _
	bFullTextIndex, _
	bOldFullTextIndex, _
	intMemberID, _
	intOldMemberID

If bSuperUserGlobal Then
	intMemberID = Request("MemberID")
	If Nl(intMemberID) Then
		intMemberID = Null
	ElseIf IsIDType(intMemberID) Then
		intMemberID = CInt(intMemberID)
	Else
		strErrorList = strErrorList & "<li>" & TXT_INVALID_ID & Server.HTMLEncode(intMemberID) & "</li>"
	End If 
Else 
	intMemberID = g_intMemberID
End If

If bSuperUserGlobal Then
	intOldMemberID = Request("OldMemberID")
	If Nl(intOldMemberID) Then
		intOldMemberID = Null
	ElseIf IsIDType(intOldMemberID) Then
		intOldMemberID = CInt(intOldMemberID)
	Else
		strErrorList = strErrorList & "<li>" & TXT_INVALID_ID & Server.HTMLEncode(intOldMemberID) & "</li>"
	End If 
Else 
	intOldMemberID = g_intMemberID
End If
If Not Nl(Request("FieldID")) Then
	If IsIDType(Request("FieldID")) Then
		intFieldID = CInt(Request("FieldID"))
		If Not bDelete Then
			strOldName = Trim(Request("OldName"))
			If strFType = "t" Then
				intOldMaxLength = Trim(Request("OldMaxLength"))
				bOldFullTextIndex = CbToSQLBool("OldFullTextIndex")
			End If
		End If
	Else
		strErrorList = strErrorList & "<li>" & TXT_INVALID_ID & Server.HTMLEncode(intFieldID) & "</li>"
	End If
Else
	If bDelete Then
		strErrorList = strErrorList & "<li>" & TXT_NO_RECORD_CHOSEN & "</li>"
	Else
		intFieldID = Null
		strOldName = Null
		If strFType = "t" Then
			intOldMaxLength = Null
			bOldFullTextIndex = Null
		End If
	End If
End If

strExtraFieldType = strFType
If strFType = "d" Then
	If Not Nl(Request("NoYear")) Then
		strExtraFieldType = "a"
	End If
End If
If Not bDelete Then
	If strFType = "t" Then
		intMaxLength = Trim(Request("MaxLength"))
		If Nl(intMaxLength) Then
			strErrorList = strErrorList & "<li>" & TXT_INST_FIELD_LENGTH & "</li>"
		ElseIf Not IsPosSmallInt(intMaxLength) Then
			strErrorList = strErrorList & "<li>" & TXT_INST_FIELD_LENGTH & "</li>"
		Else
			intMaxLength = CInt(intMaxLength)
			If intMaxLength > 8000 Then
				intMaxLength = 8000
			End If
		End If
		bFullTextIndex = CbToSQLBool("FullTextIndex")
	Else
		intMaxLength = Null
		bFullTextIndex = Null
	End If

	strFieldName = UCase(Trim(Request("ExtraFieldName")))
	If Not reEquals(strFieldName,"[A-Z0-9]{1,25}",False,False,True,False) Then
		strErrorList = strErrorList & "<li>" & TXT_INST_FIELD_NAME & "</li>"
	ElseIf strFieldName = strOldName And intMemberID = intOldMemberID Then
		If (strFType<>"t" And strFType<>"d") Or _
			(strFType="t" And intMaxLength = intOldMaxLength And bFullTextIndex=bOldFullTextIndex) Or _
			(strFType="d" And CBooL(strExtraFieldType="a") = CBool(Not Nl(Request("OldNoYear")))) Then
				strErrorList = strErrorList & "<li>" & TXT_NO_CHANGES_MADE & "</li>"
		End If
	End If
End If

If Nl(strErrorList) Then
	Dim objReturn, objErrMsg
	Dim cmdFields, rsFields
	Set cmdFields = Server.CreateObject("ADODB.Command")
	With cmdFields
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = strStoredProcName
		.CommandTimeout = 0
		.Prepared = False
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@SuperUserGlobal", adBoolean, adParamInput, 1, bSuperUserGlobal)
		.Parameters.Append .CreateParameter("@OwnerMemberID", adInteger, adParamInput, 4, intMemberID)
		If Not bDelete Then
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		End If
		.Parameters.Append .CreateParameter("@FieldID", adInteger, adParamInput, 4, intFieldID)
		If Not bDelete Then
			.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		End If
		.Parameters.Append .CreateParameter("@ExtraFieldType", adChar, adParamInput, 1, strExtraFieldType)
		If Not bDelete Then
			.Parameters.Append .CreateParameter("@ExtraFieldName", adVarChar, adParamInput, 25, strFieldName)
			.Parameters.Append .CreateParameter("@MaxLength", adInteger, adParamInput, 4, intMaxLength)
			.Parameters.Append .CreateParameter("@FullTextIndex", adBoolean, adParamInput, 1, bFullTextIndex)
		End If
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
		Set rsFields = .Execute
	End With
	
	Set rsFields = rsFields.NextRecordset
		
	Select Case objReturn.Value
		Case 0
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
				"setup_extrafield.asp", _
				"DM=" & intDomain & "&FType=" & strFType, _
				False)
		Case Else
			strErrorList = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End Select
	
	Set rsFields = Nothing
	Set cmdFields = Nothing
End If


If Not Nl(strErrorList) Then
	Call makePageHeader(TXT_CHANGE_EXTRA_FIELD_FAILED, TXT_CHANGE_EXTRA_FIELD_FAILED, True, False, True, True)
	Call handleError(TXT_RECORDS_WERE_NOT & IIf(bDelete,TXT_DELETED,TXT_UPDATED) & TXT_COLON & "<ul>" & strErrorList & "</ul>", _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
End If

%>
<!--#include file="../includes/core/incClose.asp" -->

