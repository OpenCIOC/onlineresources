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
<!--#include file="text/txtFormDataCheck.asp" -->
<!--#include file="text/txtFindReplaceCommon.asp" -->
<!--#include file="text/txtFindReplaceReport.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/core/incRExpFuncs.asp" -->

<%
Sub addHistoryField(strFieldName)
	Select Case strFieldName
		Case "ACCESSIBILITY_NOTES"
			dicHistoryFields("ACCESSIBILITY") = g_objCurrentLang.LangID
		Case "AREAS_SERVED_NOTES"
			dicHistoryFields("AREAS_SERVED") = g_objCurrentLang.LangID
		Case "CONTACT_EMAIL_1"
			dicHistoryFields("CONTACT_1") = g_objCurrentLang.LangID
		Case "CONTACT_EMAIL_2"
			dicHistoryFields("CONTACT_2") = g_objCurrentLang.LangID
		Case "CONTACT_FAX_1"
			dicHistoryFields("CONTACT_1") = g_objCurrentLang.LangID
		Case "CONTACT_FAX_2"
			dicHistoryFields("CONTACT_2") = g_objCurrentLang.LangID
		Case "CONTACT_NAME_1"
			dicHistoryFields("CONTACT_1") = g_objCurrentLang.LangID
		Case "CONTACT_NAME_2"
			dicHistoryFields("CONTACT_2") = g_objCurrentLang.LangID
		Case "CONTACT_ORG_1"
			dicHistoryFields("CONTACT_1") = g_objCurrentLang.LangID
		Case "CONTACT_ORG_2"
			dicHistoryFields("CONTACT_2") = g_objCurrentLang.LangID
		Case "CONTACT_PHONE_1"
			dicHistoryFields("CONTACT_1") = g_objCurrentLang.LangID
		Case "CONTACT_PHONE_2"
			dicHistoryFields("CONTACT_2") = g_objCurrentLang.LangID
		Case "CONTACT_TITLE_1"
			dicHistoryFields("CONTACT_1") = g_objCurrentLang.LangID
		Case "CONTACT_TITLE_2"
			dicHistoryFields("CONTACT_2") = g_objCurrentLang.LangID
		Case "ELIGIBILITY_NOTES"
			dicHistoryFields("ELIGIBILITY") = g_objCurrentLang.LangID
		Case "EXEC_EMAIL_1"
			dicHistoryFields("EXEC_1") = g_objCurrentLang.LangID
		Case "EXEC_EMAIL_2"
			dicHistoryFields("EXEC_2") = g_objCurrentLang.LangID
		Case "EXEC_FAX_1"
			dicHistoryFields("EXEC_1") = g_objCurrentLang.LangID
		Case "EXEC_FAX_2"
			dicHistoryFields("EXEC_2") = g_objCurrentLang.LangID
		Case "EXEC_NAME_1"
			dicHistoryFields("EXEC_1") = g_objCurrentLang.LangID
		Case "EXEC_NAME_2"
			dicHistoryFields("EXEC_2") = g_objCurrentLang.LangID
		Case "EXEC_ORG_1"
			dicHistoryFields("EXEC_1") = g_objCurrentLang.LangID
		Case "EXEC_ORG_2"
			dicHistoryFields("EXEC_2") = g_objCurrentLang.LangID
		Case "EXEC_PHONE_1"
			dicHistoryFields("EXEC_1") = g_objCurrentLang.LangID
		Case "EXEC_PHONE_2"
			dicHistoryFields("EXEC_2") = g_objCurrentLang.LangID
		Case "EXEC_TITLE_1"
			dicHistoryFields("EXEC_1") = g_objCurrentLang.LangID
		Case "EXEC_TITLE_2"
			dicHistoryFields("EXEC_2") = g_objCurrentLang.LangID
		Case "FEE_ASSISTANCE_FOR"
			dicHistoryFields("FEES") = g_objCurrentLang.LangID
		Case "FEE_ASSISTANCE_FROM"
			dicHistoryFields("FEES") = g_objCurrentLang.LangID
		Case "FEE_NOTES"
			dicHistoryFields("FEES") = g_objCurrentLang.LangID
		Case "FUNDING_NOTES"
			dicHistoryFields("FUNDING") = g_objCurrentLang.LangID
		Case "LANGUAGE_NOTES"
			dicHistoryFields("LANGUAGES") = g_objCurrentLang.LangID
		Case "LOCATED_IN_CM"
			dicHistoryFields("LOCATED_IN_CM") = Null
		Case "LICENSE_NUMBER"
			dicHistoryFields("CC_LICENSE_INFO") = Null
		Case "LOGO_ADDRESS_LINK"
			dicHistoryFields("EXEC_2") = g_objCurrentLang.LangID
		Case "MAIL_BOX_TYPE"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_BUILDING"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_CARE_OF"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_CITY"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_COUNTRY"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_LINE_1"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_LINE_2"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_PO_BOX"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_POSTAL_CODE"
			dicHistoryFields("MAIL_ADDRESS") = Null
		Case "MAIL_PROVINCE"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_STREET"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_STREET_DIR"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_STREET_NUMBER"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_STREET_TYPE"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "MAIL_SUFFIX"
			dicHistoryFields("MAIL_ADDRESS") = IIf(Nl(dicHistoryFields("MAIL_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SCHOOL_ESCORT_NOTES"
			dicHistoryFields("SCHOOL_ESCORT") = g_objCurrentLang.LangID
		Case "SCHOOLS_IN_AREA_NOTES"
			dicHistoryFields("SCHOOLS_IN_AREA") = g_objCurrentLang.LangID
		Case "SITE_BUILDING"
			dicHistoryFields("SITE_ADDRESS") = IIf(Nl(dicHistoryFields("SITE_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SITE_CITY"
			dicHistoryFields("SITE_ADDRESS") = IIf(Nl(dicHistoryFields("SITE_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SITE_COUNTRY"
			dicHistoryFields("SITE_ADDRESS") = IIf(Nl(dicHistoryFields("SITE_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SITE_LINE_1"
			dicHistoryFields("SITE_ADDRESS") = IIf(Nl(dicHistoryFields("SITE_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SITE_LINE_2"
			dicHistoryFields("SITE_ADDRESS") = IIf(Nl(dicHistoryFields("SITE_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SITE_POSTAL_CODE"
			dicHistoryFields("SITE_ADDRESS") = Null
		Case "SITE_PROVINCE"
			dicHistoryFields("SITE_ADDRESS") = IIf(Nl(dicHistoryFields("SITE_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SITE_STREET"
			dicHistoryFields("SITE_ADDRESS") = IIf(Nl(dicHistoryFields("SITE_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SITE_STREET_DIR"
			dicHistoryFields("SITE_ADDRESS") = IIf(Nl(dicHistoryFields("SITE_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SITE_STREET_NUMBER"
			dicHistoryFields("SITE_ADDRESS") = IIf(Nl(dicHistoryFields("SITE_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SITE_STREET_TYPE"
			dicHistoryFields("SITE_ADDRESS") = IIf(Nl(dicHistoryFields("SITE_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SITE_SUFFIX"
			dicHistoryFields("SITE_ADDRESS") = IIf(Nl(dicHistoryFields("SITE_ADDRESS")),Null,g_objCurrentLang.LangID)
		Case "SOURCE_ADDRESS"
			dicHistoryFields("SOURCE") = g_objCurrentLang.LangID
		Case "SOURCE_BUILDING"
			dicHistoryFields("SOURCE") = g_objCurrentLang.LangID
		Case "SOURCE_CITY"
			dicHistoryFields("SOURCE") = g_objCurrentLang.LangID
		Case "SOURCE_EMAIL"
			dicHistoryFields("SOURCE") = g_objCurrentLang.LangID
		Case "SOURCE_FAX"
			dicHistoryFields("SOURCE") = g_objCurrentLang.LangID
		Case "SOURCE_NAME"
			dicHistoryFields("SOURCE") = g_objCurrentLang.LangID
		Case "SOURCE_ORG"
			dicHistoryFields("SOURCE") = g_objCurrentLang.LangID
		Case "SOURCE_PHONE"
			dicHistoryFields("SOURCE") = g_objCurrentLang.LangID
		Case "SOURCE_POSTAL_CODE"
			dicHistoryFields("SOURCE") = g_objCurrentLang.LangID
		Case "SOURCE_PROVINCE"
			dicHistoryFields("SOURCE") = g_objCurrentLang.LangID
		Case "SOURCE_TITLE"
			dicHistoryFields("SOURCE") = g_objCurrentLang.LangID
		Case "SPACE_AVAILABLE_NOTES"
			dicHistoryFields("SPACE_AVAILABLE") = g_objCurrentLang.LangID
		Case "TYPE_OF_CARE_NOTES"
			dicHistoryFields("TYPE_OF_CARE") = g_objCurrentLang.LangID
		Case "VACANCY_NOTES"
			dicHistoryFields("VACANCY") = g_objCurrentLang.LangID
		Case "VOLCONTACT_EMAIL"
			dicHistoryFields("VOLCONTACT") = g_objCurrentLang.LangID
		Case "VOLCONTACT_FAX"
			dicHistoryFields("VOLCONTACT") = g_objCurrentLang.LangID
		Case "VOLCONTACT_NAME"
			dicHistoryFields("VOLCONTACT") = g_objCurrentLang.LangID
		Case "VOLCONTACT_ORG"
			dicHistoryFields("VOLCONTACT") = g_objCurrentLang.LangID
		Case "VOLCONTACT_PHONE"
			dicHistoryFields("VOLCONTACT") = g_objCurrentLang.LangID
		Case "VOLCONTACT_TITLE"
			dicHistoryFields("VOLCONTACT") = g_objCurrentLang.LangID
		Case Else
			If InStr(strFieldList,"btd." & strFieldName) Then
				dicHistoryFields(strFieldName) = g_objCurrentLang.LangID
			Else
				dicHistoryFields(strFieldName) = Null
			End If
	End Select
End Sub

Sub writeHistory(strNUM)
	For Each indHistoryField In dicHistoryFields
		If Nl(dicHistoryFields(indHistoryField)) Then
			strHistoryFields = strHistoryFields & strHistoryFieldCon & indHistoryField
			strHistoryFieldCon = ","								
		Else				
			strHistoryFieldsL = strHistoryFieldsL & strHistoryFieldConL & indHistoryField
			strHistoryFieldConL = ","
		End If
	Next
	
	If Not Nl(strHistoryFields) Then
		cmdHistory.Parameters("@NUM").Value = strNUM
		cmdHistory.Parameters("@FieldList").Value = strHistoryFields
		cmdHistory.Parameters("@LangID").Value = Null
		cmdHistory.Execute
	End If
	If Not Nl(strHistoryFieldsL) Then
		cmdHistory.Parameters("@NUM").Value = strNUM
		cmdHistory.Parameters("@FieldList").Value = strHistoryFieldsL
		cmdHistory.Parameters("@LangID").Value = g_objCurrentLang.LangID
		cmdHistory.Execute
	End If
End Sub

Sub getContactFldData(strContactType, aFields, ByRef dicContactData, bEraseData)
	Dim indFldName, _
		strFldData
	If IsArray(aFields) Then
		For Each indFldName In aFields
			If bEraseData Then
				If indFldName = "FAX_CALLFIRST" Then
					dicContactData(indFldName) = SQL_FALSE
				Else
					dicContactData(indFldName) = "*"
				End If
			Else
				strFldData = Trim(Request(strContactType & "_" & indFldName))
				If Not Nl(strFldData) Then
					dicContactData(indFldName) = strFldData
				End If
			End If
		Next
	End If
End Sub

Function updateName(strNameType, strNUM, ByRef strErrorList)
	Dim cmdUpdateNameField, _
		rsUpdateNameField, _
		strNameTable, _
		strNameField, _
		strDateField, _
		strErrCon, _
		intNamesAffected, _
		bNameMod
		
	strErrCon = vbNullString

	Select Case strNameType
		Case "ALT_ORG"
			strNameTable = "GBL_BT_ALTORG"
			strNameField = "ALT_ORG"
			strDateField = vbNullString
		Case "FORMER_ORG"
			strNameTable = "GBL_BT_FORMERORG"
			strNameField = "FORMER_ORG"
			strDateField = "DATE_OF_CHANGE"
	End Select

	Set cmdUpdateNameField = Server.CreateObject("ADODB.Command")
	With cmdUpdateNameField
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
		If Nl(strFindText) Then
			.CommandText = "IF NOT EXISTS(SELECT * FROM " & strNameTable & " WHERE NUM=" & QsNl(strNUM) & " AND LangID=@@LANGID AND " & strNameField & "=" & QsNl(strReplaceText) & ") BEGIN" & _
				" INSERT INTO " & strNameTable & "(NUM,LangID," & strNameField & IIf(strNameType="FORMER_ORG",",DATE_OF_CHANGE",vbNullString) & _
				" ) VALUES (" & QsNl(strNUM) & ",@@LANGID," & QsNl(strReplaceText) & IIf(strNameType="FORMER_ORG","," & QsNl(strDateOfChange),vbNullString) & ")" & _
				" END"
			.Execute intNamesAffected
			If intNamesAffected > 0 Then
				bNameMod = True
			End If
		Else
			.CommandText = "SELECT NUM," & strNameField & StringIf(Not Nl(strDateField),"," & strDateField) & _
				" FROM " & strNameTable & _
				" WHERE NUM=" & QsNl(strNUM) & _
				" AND LangID=@@LANGID"
		End If
	End With
	If Not Nl(strFindText) Then
		Set rsUpdateNameField = Server.CreateObject("ADODB.Recordset")
		With rsUpdateNameField
			.CursorLocation = adUseClient
			.CursorType = adOpenKeyset
			.LockType = adLockOptimistic
			.Open cmdUpdateNameField
			While Not .EOF
				strFieldText = .Fields(strNameField)
				If reEquals(strFieldText,strFindText,Not bMatchCase,bIgnoreSpace,bMatchWholeField,False) Then
					strFieldText = Trim(reReplace(strFieldText,strFindText,strReplaceText,Not bMatchCase,bIgnoreSpace,True,False))
					If Nl(strFieldText) Then
						.Delete
					Else
						.Fields(strNameField) = strFieldText
						If Not Nl(strDateField) Then
							.Fields(strDateField) = strDateOfChange
						End If
						.Update
					End If
					If Err.Number <> 0 Then
						strErrorList = strErrorList & strErrCon & _
							"<span class=""Alert"">[" & TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED) & "]</span>"
						strAltFldCon = "; "
						Err.Clear
					Else
						bNameMod = True
					End If
					strErrCon = "; "
					bNameMod = True
				End If
				.MoveNext
			Wend
			.Close
		End With
		Set rsUpdateNameField = Nothing
	End If

	Set cmdUpdateNameField = Nothing

	updateName = bNameMod
End Function

Function updateCLNotes(strListType, strNUM, ByRef strErrorList)
	Dim cmdUpdateCheckListNotes, _
		rsUpdateCheckListNotes, _
		strListTable, _
		strListRelID, _
		strNotesName, _
		strFieldName, _
		strErrCon, _
		bCheckMod
		
	strErrCon = vbNullString

	strNotesName = "Notes"

	Select Case strListType
		Case "ac"
			strListTable = "GBL_BT_AC"
			strListRelID = "BT_AC_ID"
			strFieldName = "ACCESSIBILITY"
		Case "cm"
			strListTable = "CIC_BT_CM"
			strListRelID = "BT_CM_ID"
			strFieldName = "AREAS_SERVED"
		Case "fd"
			strListTable = "CIC_BT_FD"
			strListRelID = "BT_FD_ID"
			strFieldName = "FUNDING"
		Case "ft"
			strListTable = "CIC_BT_FT"
			strListRelID = "BT_FT_ID"
			strFieldName = "FEES"
		Case "ln"
			strListTable = "CIC_BT_LN"
			strListRelID = "BT_LN_ID"
			strFieldName = "LANGUAGES"
		Case "scha"
			strListTable = "CCR_BT_SCH"
			strListRelID = "BT_SCH_ID"
			strNotesName = "InAreaNotes AS Notes"
			strFieldName = "SCHOOLS_IN_AREA"
		Case "sche"
			strListTable = "CCR_BT_SCH"
			strListRelID = "BT_SCH_ID"
			strNotesName = "EscortNotes AS Notes"
			strFieldName = "SCHOOL_ESCORT"
		Case "toc"
			strListTable = "CCR_BT_TOC"
			strListRelID = "BT_TOC_ID"
			strFieldName = "TYPE_OF_CARE"
	End Select

	Set cmdUpdateCheckListNotes = Server.CreateObject("ADODB.Command")
	With cmdUpdateCheckListNotes
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandText = "SELECT " & strNotesName & " FROM " & strListTable & "_Notes cln" & _
			" WHERE cln.LangID=" & g_objCurrentLang.LangID & _
			" AND EXISTS(SELECT * FROM " & strListTable & " cl WHERE cl." & strListRelID & "=cln." & strListRelID & " AND cl.NUM=" & QsNl(strNUM) & ")"
		.CommandTimeout = 0
	End With
	
	'Response.Write("<pre>" & cmdUpdateCheckListNotes.CommandText & "</pre>")
	'Response.Flush()
	
	Set rsUpdateCheckListNotes = Server.CreateObject("ADODB.Recordset")
	With rsUpdateCheckListNotes
		.CursorLocation = adUseClient
		.CursorType = adOpenKeyset
		.LockType = adLockOptimistic
		.Open cmdUpdateCheckListNotes
		While Not .EOF
			strFieldText = .Fields("Notes")
			If reEquals(strFieldText,strFindText,Not bMatchCase,bIgnoreSpace,bMatchWholeField,False) Then
				strFieldText = Trim(reReplace(strFieldText,strFindText,strReplaceText,Not bMatchCase,bIgnoreSpace,True,False))
				If Nl(strFieldText) And Not (strListType = "sche" Or strListType = "scha") Then
					.Delete
				Else
					.Fields("Notes") = Nz(strFieldText,Null)
					.Update
				End If
				If Err.Number <> 0 Then
					strErrorList = strErrorList & strErrCon & _
						"<span class=""Alert"">[" & TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED) & "]</span>"
					strAltFldCon = "; "
					Err.Clear
				Else
					bCheckMod = True
				End If
				strErrCon = "; "
				bCheckMod = True
			End If
			.MoveNext
		Wend
		.Close
	End With
	Set rsUpdateCheckListNotes = Nothing
	Set cmdUpdateCheckListNotes = Nothing

	If bCheckMod Then
		dicHistoryFields(strFieldName) = g_objCurrentLang.LangID
	End If
	
	updateCLNotes = bCheckMod
End Function

Sub setTableList()
	Dim intPos
	
	intPos = InStr(2,strFieldList,".")
	If IsNumeric(intPos) Then
		If intPos < 1 Then
			intPos = Null
		End If
	End If
	
	If Not Nl(intPos) Then
		strFldType = Left(strFieldList,intPos-1)
		strTblFld = Right(strFieldList,Len(strFieldList)-intPos)
	Else
		strFldType = "bt"
		strTblFld = strFieldList
	End If
	
	Select Case strFldType
		Case "bt"
			strTblList = "GBL_BaseTable bt" & vbCrLf & _
				"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID"
		Case "btd"
			strTblList = "GBL_BaseTable bt" & vbCrLf & _
				"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID"
		Case "cbt"
			strBasicCheckSQL = strBasicCICCheckSQL
			strTblList = "GBL_BaseTable bt" & vbCrLf & _
				"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"INNER JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM"
		Case "cbtd"
			strBasicCheckSQL = strBasicCICCheckSQL & vbCrLf & strBasicCICDCheckSQL
			strTblList = "GBL_BaseTable bt" & vbCrLf & _
				"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"INNER JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
				"INNER JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID"
		Case "ccbt"
			strBasicCheckSQL = strBasicCCRCheckSQL
			strTblList = "GBL_BaseTable bt" & vbCrLf & _
				"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"INNER JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM"
		Case "ccbtd"
			strBasicCheckSQL = strBasicCCRCheckSQL & vbCrLf & strBasicCCRDCheckSQL
			strTblList = "GBL_BaseTable bt" & vbCrLf & _
				"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"INNER JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
				"INNER JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=@@LANGID"
		Case "xe"
			strBasicCheckSQL = strBasicCICCheckSQL & vbCrLf & strBasicCICDCheckSQL
			strTblList = "CIC_BT_EXTRA_EMAIL"
			bExtraField = True
		Case "xd"
			strBasicCheckSQL = strBasicCICCheckSQL
			strTblList = "CIC_BT_EXTRA_DATE"
			bExtraField = True
		Case "xt"
			strBasicCheckSQL = strBasicCICCheckSQL & vbCrLf & strBasicCICDCheckSQL
			strTblList = "CIC_BT_EXTRA_TEXT"
			bExtraField = True
		Case "xr"
			strBasicCheckSQL = strBasicCICCheckSQL
			strTblList = "CIC_BT_EXTRA_RADIO"
			bExtraField = True
		Case "xw"
			strBasicCheckSQL = strBasicCICCheckSQL & vbCrLf & strBasicCICDCheckSQL
			strTblList = "CIC_BT_EXTRA_WWW"
			bExtraField = True
	End Select
End Sub

'On Error Resume Next
Server.ScriptTimeOut = 900

If Not user_bSuperUserDOM Then
	Call securityFailure()
End If

Const RT_FINDREPLACE = 0
Const RT_INSERT = 1
Const RT_CLEARFIELD = 2
Const RT_CHECKLIST = 3
Const RT_NAME = 4
Const RT_CONTACT = 5
Const RT_RECORDNOTE = 6

Dim strHistoryFields, _
	strHistoryFieldsL, _
	strHistoryFieldCon, _
	strHistoryFieldConL, _
	indHistoryField

Dim dicHistoryFields
Set dicHistoryFields = Server.CreateObject("Scripting.Dictionary")

Dim intReplaceType, _
	strIDList, _
	strQIDList

intReplaceType = Request("ReplaceType")
If IsNumeric(intReplaceType) Then
	intReplaceType = CInt(intReplaceType)
Else
	intReplaceType = vbNullString
End If

strIDList = Replace(Request("IDList")," ",vbNullString)
If Nl(strIDList) Or Nl(intReplaceType) Then
	Call goToPage("processRecordList.asp","ActionType=F&IDList=" & strIDList, vbNullString)
End If

strQIDList = QsStrList(strIDList)

If (intReplaceType = RT_FINDREPLACE _
	Or intReplaceType = RT_INSERT _
	Or intReplaceType = RT_CLEARFIELD _
	Or intReplaceType = RT_CONTACT _
	Or intReplaceType = RT_RECORDNOTE) Then

	Dim strFieldList
	strFieldList = Trim(Request("FieldName"))
End If

If (intReplaceType = RT_FINDREPLACE _
	Or intReplaceType = RT_NAME) Then

	Dim	strOriginalFindText, _
		strFindText, _
		strReplaceText, _
		bIgnoreSpace

		strOriginalFindText = Request("FindText")
		strFindText = reFormatStr(strOriginalFindText)
		strReplaceText = Request("ReplaceText")
		bIgnoreSpace = Request("IgnoreSpace") = "on"
End If

If (intReplaceType = RT_CONTACT _
	Or intReplaceType = RT_FINDREPLACE _
	Or intReplaceType = RT_NAME) Then

	Dim	bMatchCase, _
		bMatchWholeField

		bMatchCase = Request("MatchCase") = "on"
		bMatchWholeField = Request("WholeField") = "on"
End If

If (intReplaceType = RT_INSERT _
	Or intReplaceType = RT_RECORDNOTE) Then
	
	Dim strInsertText
	strInsertText = Request("InsertText")
End If

If (intReplaceType = RT_INSERT _
	Or intReplaceType = RT_CLEARFIELD _
	Or intReplaceType = RT_CHECKLIST) Then
	
	Dim strBasicTmpNUMs, _
		strBasicCICCheckSQL, _
		strBasicCICDCheckSQL, _
		strBasicCCRCheckSQL, _
		strBasicCCRDCheckSQL, _
		strBasicCheckSQL

	strBasicTmpNUMs = "DECLARE @tmpNUMs TABLE(NUM varchar(8) COLLATE Latin1_General_100_CI_AI)" & vbCrLf & _
					"INSERT INTO @tmpNUMs SELECT DISTINCT tm.*" & vbCrLf & _
					"	FROM dbo.fn_GBL_ParseVarCharIDList(" & QsNl(strIDList) & ",',') tm" & vbCrLf & _
					"	INNER JOIN GBL_BaseTable bt ON tm.ItemID = bt.NUM COLLATE Latin1_General_100_CI_AI AND bt.MemberID=" & g_intMemberID
	strBasicCICCheckSQL = "INSERT INTO CIC_BaseTable (NUM,CREATED_BY,MODIFIED_BY)" & vbCrLf & _
						"	SELECT tm.NUM," & QsNl(user_strMod) & "," & QsNl(user_strMod) & vbCrLf & _
						"	FROM @tmpNUMs tm" & vbCrLf & _
						"	WHERE NOT EXISTS(SELECT * FROM CIC_BaseTable cbt WHERE cbt.NUM=tm.NUM)"
	strBasicCICDCheckSQL = "INSERT INTO CIC_BaseTable_Description (NUM,LangID,CREATED_BY,MODIFIED_BY)" & vbCrLf & _
						"	SELECT tm.NUM,@@LANGID," & QsNl(user_strMod) & "," & QsNl(user_strMod) & vbCrLf & _
						"	FROM @tmpNUMs tm" & vbCrLf & _
						"	WHERE NOT EXISTS(SELECT * FROM CIC_BaseTable_Description cbtd WHERE cbtd.NUM=tm.NUM AND cbtd.LangID=@@LANGID)" & vbCrLf & _
						"	AND EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=tm.NUM AND btd.LangID=@@LANGID)"
	strBasicCCRCheckSQL = "INSERT INTO CCR_BaseTable (NUM,CREATED_BY,MODIFIED_BY)" & vbCrLf & _
						"	SELECT tm.NUM," & QsNl(user_strMod) & "," & QsNl(user_strMod) & vbCrLf & _
						"	FROM @tmpNUMs tm" & vbCrLf & _
						"	WHERE NOT EXISTS(SELECT * FROM CCR_BaseTable ccbt WHERE ccbt.NUM=tm.NUM)"
	strBasicCCRDCheckSQL = "INSERT INTO CCR_BaseTable_Description (NUM,LangID,CREATED_BY,MODIFIED_BY)" & vbCrLf & _
						"	SELECT tm.NUM,@@LANGID," & QsNl(user_strMod) & "," & QsNl(user_strMod) & vbCrLf & _
						"	FROM @tmpNUMs tm" & vbCrLf & _
						"	WHERE NOT EXISTS(SELECT * FROM CCR_BaseTable_Description ccbtd WHERE ccbtd.NUM=tm.NUM AND ccbtd.LangID=@@LANGID)" & vbCrLf & _
						"	AND EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=tm.NUM AND btd.LangID=@@LANGID)"
	strBasicCheckSQL = vbNullString
End If

Dim strCodeIDList, _
	strCheckListType, _
	aCheckList

	strCodeIDList = Request("CodeIDList")
	aCheckList = Split(Request("CheckListType"),",")

	If UBound(aCheckList) > -1 Then
		strCheckListType = aCheckList(0)
	Else
		strCheckListType = vbNullString
	End If

Dim strFldType, _
	strTblFld, _
	strTblList, _
	bExtraField
	
bExtraField = False
	
Dim dicContactFind, _
	dicContactReplace
Set dicContactFind = Server.CreateObject("Scripting.Dictionary")
Set dicContactReplace = Server.CreateObject("Scripting.Dictionary")

Select Case intReplaceType
	Case RT_FINDREPLACE
	Case RT_INSERT
		Dim bBeforeText
		bBeforeText = Request("BeforeAfter") = "B"
		Call setTableList()
	Case RT_CLEARFIELD
		Dim bConfirmed
		bConfirmed = Request("Confirmed") = "on" And Request("Confirmed2") = "on"
		Call setTableList()
	Case RT_CHECKLIST
		Dim intCheckListItem1, _
			intCheckListItem2, _
			strCheckListNote
		intCheckListItem1 = Request("CheckListItem1")
		intCheckListItem2 = Request("CheckListItem2")
		strCheckListNote = Trim(Request("CheckListNote"))
		If Not IsIDType(intCheckListItem1) Then
			intCheckListItem1 = vbNullString
		End If
		If Not IsIDType(intCheckListItem2) Then
			intCheckListItem2 = vbNullString
		End If
	Case RT_NAME
		Dim strNameField, _
			strDateOfChange
		strNameField = Request("NameField")
		strDateOfChange = Request("DATE_OF_CHANGE")
	Case RT_CONTACT
		Dim aContactFields, _
			aContactFieldsValidate
		
		aContactFields = Array("NAME_HONORIFIC", "NAME_FIRST", "NAME_LAST", "NAME_SUFFIX", _
							"TITLE", "ORG", "EMAIL", _
							"FAX_NOTE", "FAX_NO", "FAX_EXT", _
							"PHONE_1_TYPE", "PHONE_1_NOTE", "PHONE_1_NO", "PHONE_1_EXT", "PHONE_1_OPTION", _
							"PHONE_2_TYPE", "PHONE_2_NOTE", "PHONE_2_NO", "PHONE_2_EXT", "PHONE_2_OPTION", _
							"PHONE_3_TYPE", "PHONE_3_NOTE", "PHONE_3_NO", "PHONE_3_EXT", "PHONE_3_OPTION")
		
		aContactFieldsValidate = Array("NAME_FIRST","NAME_LAST", _
			"TITLE","ORG", "EMAIL", _
			"FAX_NOTE","FAX_NO","FAX_EXT", _
			"PHONE_1_NOTE","PHONE_1_NO","PHONE_1_EXT","PHONE_1_OPTION", _
			"PHONE_2_NOTE","PHONE_2_NO","PHONE_2_EXT","PHONE_2_OPTION", _
			"PHONE_3_NOTE","PHONE_3_NO","PHONE_3_EXT","PHONE_3_OPTION")
			
		Dim bEraseContact
		bEraseContact = Request("EraseContact") = "on" And Request("EraseContactConfirmed") = "on"
		
		Call getContactFldData("FIND",aContactFields,dicContactFind,False)
		Call getContactFldData("REPLACE",aContactFields,dicContactReplace,bEraseContact)
	Case RT_RECORDNOTE
		Dim intNoteTypeID
		intNoteTypeID = Nz(Request("NoteTypeID"),Null)
		If Not IsIDType(intNoteTypeID) Then
			intNoteTypeID = Null
		End If
	Case Else
		Call goToPage("processRecordList.asp","ActionType=F&IDList=" & strIDList, vbNullString)
End Select

	Dim cmdHistory
Set cmdHistory = Server.CreateObject("ADODB.Command")

With cmdHistory
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	If intReplaceType = RT_CHECKLIST Or intReplaceType = RT_CONTACT Or (intReplaceType = RT_CLEARFIELD And bExtraField) Or (intReplaceType = RT_INSERT And strFldType="xd") Then
		.CommandText = "dbo.sp_GBL_BaseTable_History_i_Field"
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MODIFIED_DATE", adDBTimeStamp, adParamInput, , Now())
		.Parameters.Append .CreateParameter("@NUMList", adLongVarChar, adParamInput, -1, strIDList)
		.Parameters.Append .CreateParameter("@FieldName", adLongVarChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2, Null)
	Else
		.CommandText = "dbo.sp_GBL_BaseTable_History_i"
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MODIFIED_DATE", adDBTimeStamp, adParamInput, , Now())
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@FieldList", adLongVarChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@Names", adBoolean, adParamInput, 1, SQL_TRUE)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2)
	End If
End With

Call makePageHeader(TXT_FIND_REPLACE_REPORT, TXT_FIND_REPLACE_REPORT, True, True, True, True)

If Nl(strIDList) Then
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf (Nl(strFieldList)) _
		And Not (intReplaceType = RT_FINDREPLACE And Not (Nl(strCodeIDList) And UBound(aCheckList)<0)) _
		And Not (intReplaceType = RT_CHECKLIST And Not UBound(aCheckList)<0) _
		And Not (intReplaceType = RT_NAME And Not Nl(strNameField)) Then
	Call handleError(TXT_INST_SPECIFY_FIELD, _
		vbNullString, _
		vbNullString)
ElseIf (intReplaceType = RT_CONTACT And dicContactReplace.Count <= 0) Then
	Call handleError(TXT_INST_NO_TEXT_REPLACE, _
		vbNullString, _
		vbNullString)
ElseIf (Nl(strFindText) And intReplaceType = RT_FINDREPLACE) Then
	Call handleError(TXT_INST_NO_TEXT_FIND, _
		vbNullString, _
		vbNullString)
ElseIf Nl(strInsertText) And (intReplaceType = RT_INSERT Or intReplaceType = RT_RECORDNOTE) Then
	Call handleError(TXT_INST_NO_TEXT_APPEND, _
		vbNullString, _
		vbNullString)
ElseIf Not bConfirmed And intReplaceType = RT_CLEARFIELD Then
	Call handleError(TXT_INST_CONFIRM_CLEAR, _
		vbNullString, _
		vbNullString)
Else
	Dim cmdFindReplace, _
		strSQL, _
		rsFindReplace, _
		fld, _
		bFirstFld, _
		bRecordMod, _
		strFieldText, _
		intNumAffected, _
		strAffectedList, _
		strAffCon

	strAffCon = vbNullString
	intNumAffected = 0
	Set cmdFindReplace = Server.CreateObject("ADODB.Command")
	With cmdFindReplace
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With

	Select Case intReplaceType
		Case RT_FINDREPLACE
			Dim cmdFindReplaceCodeDesc, _
				rsFindReplaceCodeDesc, _
				intLastPubNUM, _
				intCheckItem, _
				strCheckError, _
				strAlteredFields, _
				strAltFldCon, _
				bPubMod, _
				bCheckMod
				
			Dim aFields, _
				indField, _
				intPos, _
				strNewFieldList, _
				strNewFieldListCon , _
				aExtraEmail(), _
				aExtraText(), _
				aExtraWWW()
		
			strNewFieldList = vbNullString
			strNewFieldListCon = vbNullString
			
			ReDim aExtraEmail(-1)
			ReDim aExtraText(-1)
			ReDim aExtraWWW(-1)
			
			aFields = Split(strFieldList,",")
			For Each indField In aFields
				indField = Trim(indField)
				intPos = InStr(2,indField,".")
				If IsNumeric(intPos) Then
					If intPos < 1 Then
						intPos = Null
					End If
				End If
				
				If Not Nl(intPos) Then
					strFldType = Trim(Left(indField,intPos-1))
					strTblFld = Trim(Right(indField,Len(indField)-intPos))
				Else
					strFldType = "bt"
					strTblFld = Trim(indField)
				End If
				
				Select Case strFldType
					Case "xe"
						ReDim Preserve aExtraEmail(UBound(aExtraEmail)+1)
						aExtraEmail(UBound(aExtraEmail)) = strTblFld
					Case "xt"
						ReDim Preserve aExtraText(UBound(aExtraText)+1)
						aExtraText(UBound(aExtraText)) = strTblFld
					Case "xw"
						ReDim Preserve aExtraWWW(UBound(aExtraWWW)+1)
						aExtraWWW(UBound(aExtraWWW)) = strTblFld
					Case Else
						If Left(strFldType,1) <> "x" Then
							strNewFieldList = strNewFieldList & strNewFieldListCon & indField
							strNewFieldListCon = ","
						End If
				End Select
			Next
			
			strFieldList = strNewFieldList
			
%>
<h1><%=TXT_FIND_REPLACE_REPORT%></h1>
<p class="Info"><%=TXT_INST_PRINT_REPORT%></p>
<hr>
<p><strong><%=TXT_YOUR_SEARCH_TO_FIND%></strong> <%=strOriginalFindText%>
<br><strong><%=TXT_AND_REPLACE_IT_WITH%></strong> <%=strReplaceText%>
<br><%=TXT_RETURNED_RESULTS%></p>
<table class="BasicBorder cell-padding-2">
<tr><th><%=TXT_RECORD%></th><th><%=TXT_FIELDS_MATCHED%></th></tr>
<%
			If Not Nl(strCodeIDList) Then
				Set cmdFindReplaceCodeDesc = Server.CreateObject("ADODB.Command")
				With cmdFindReplaceCodeDesc
					.ActiveConnection = getCurrentAdminCnn()
					.CommandType = adCmdText
					.CommandText = "SELECT pb.PubCode AS CodeName,pr.NUM,pr.MODIFIED_BY,pr.MODIFIED_DATE,prn.Description" & _
						" FROM CIC_BT_PB pr" & _
						" INNER JOIN CIC_BT_PB_Description prn ON pr.BT_PB_ID=prn.BT_PB_ID AND prn.LangID=" & g_objCurrentLang.LangID & _
						" INNER JOIN CIC_Publication pb ON pr.PB_ID=pb.PB_ID" & _
						" WHERE pr.NUM IN (" & strQIDList & ")" & _
						" AND pr.PB_ID IN (" & strCodeIDList & ")" & _
						" AND dbo.fn_CIC_CanUpdatePub(pr.NUM, pr.PB_ID, " & user_intID & ", " & g_intViewTypeCIC & ", @@LANGID,GETDATE())=1" & _
						" ORDER BY pr.NUM"
					.CommandTimeout = 0
				End With
				Set rsFindReplaceCodeDesc = Server.CreateObject("ADODB.Recordset")
				With rsFindReplaceCodeDesc
					.CursorLocation = adUseClient
					.CursorType = adOpenKeyset
					.LockType = adLockOptimistic
					.Open cmdFindReplaceCodeDesc
					If Not .EOF Then
						intLastPubNUM = .Fields("NUM")
					End If
				End With
			End If

			strSQL = "SELECT bt.NUM,btd.BTD_ID,btd.MODIFIED_DATE,btd.MODIFIED_BY" & StringIf(Not Nl(strFieldList),"," & strFieldList)
			
			For Each indField In aExtraEmail
				strSQL = strSQL & vbCrLf & _
					",xe_" & indField & ".Value AS [" & indField & "]"
			Next
			
			For Each indField In aExtraText
				strSQL = strSQL & vbCrLf & _
					",xt_" & indField & ".Value AS [" & indField & "]"
			Next
			
			For Each indField In aExtraWWW
				strSQL = strSQL & vbCrLf & _
					",xw_" & indField & ".Value AS [" & indField & "]"
			Next
			
			strSQL = strSQL & vbCrLf & _
				"FROM GBL_BaseTable bt" & vbCrLf & _
				"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
				"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf & _
				"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
				"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=@@LANGID"
			
			For Each indField In aExtraEmail
				strSQL = strSQL & vbCrLf & _
					"LEFT JOIN CIC_BT_EXTRA_EMAIL xe_" & indField & " ON xe_" & indField & ".NUM=cbtd.NUM AND xe_" & indField & ".LangID=cbtd.LangID AND xe_" & indField & ".FieldName=" & QsNl(indField)
			Next
			
			For Each indField In aExtraText
				strSQL = strSQL & vbCrLf & _
					"LEFT JOIN CIC_BT_EXTRA_TEXT xt_" & indField & " ON xt_" & indField & ".NUM=cbtd.NUM AND xt_" & indField & ".LangID=cbtd.LangID AND xt_" & indField & ".FieldName=" & QsNl(indField)
			Next
			
			For Each indField In aExtraWWW
				strSQL = strSQL & vbCrLf & _
					"LEFT JOIN CIC_BT_EXTRA_WWW xw_" & indField & " ON xw_" & indField & ".NUM=cbtd.NUM AND xw_" & indField & ".LangID=cbtd.LangID AND xw_" & indField & ".FieldName=" & QsNl(indField)
			Next
			
			strSQL = strSQL & vbCrLf & _
				"WHERE bt.NUM IN (" & strQIDList & ")" & vbCrLf & _
				"ORDER BY bt.NUM"
				
			'Response.Write("<pre>" & strSQL & "<pre>")
			'Response.Flush()
			
			Dim cmdFindReplaceExtra
			Set cmdFindReplaceExtra = Server.CreateObject("ADODB.Command")
			With cmdFindReplaceExtra
					.ActiveConnection = getCurrentAdminCnn()
					.CommandType = adCmdText
					.CommandTimeout = 0
			End With
			
			cmdFindReplace.CommandText = strSQL
			Set rsFindReplace = Server.CreateObject("ADODB.Recordset")
			With rsFindReplace
				.CursorLocation = adUseClient
				.CursorType = adOpenKeyset
				.LockType = adLockOptimistic
				.Open cmdFindReplace
				While Not .EOF
					dicHistoryFields.RemoveAll()
					strHistoryFields = vbNullString
					strHistoryFieldCon = vbNullString
					bRecordMod = False
					bPubMod = False
					bCheckMod = False
					strAlteredFields = vbNullString
					strAltFldCon = vbNullString
					If Not Nl(strCodeIDList) Then
						While Not rsFindReplaceCodeDesc.EOF And intLastPubNUM = .Fields("NUM")
							strFieldText = rsFindReplaceCodeDesc("DESCRIPTION")
							If reEquals(strFieldText,strFindText,Not bMatchCase,bIgnoreSpace,bMatchWholeField,False) Then
								strFieldText = Trim(reReplace(strFieldText,strFindText,strReplaceText,Not bMatchCase,bIgnoreSpace,True,False))
								rsFindReplaceCodeDesc("DESCRIPTION") = strFieldText
								rsFindReplaceCodeDesc("MODIFIED_DATE") = Now()
								rsFindReplaceCodeDesc("MODIFIED_BY") = user_strMod
								.Update
								If Err.Number <> 0 Then
									strAlteredFields = strAlteredFields & strAltFldCon & _
										"<span class=""Alert"">[" & TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED) & "]</span>"
									strAltFldCon = "; "
									Err.Clear
								Else
									bPubMod = True
								End If
								strAlteredFields = strAlteredFields & strAltFldCon & _
									rsFindReplaceCodeDesc("CodeName") & "_DESC"
								strAltFldCon = "; "
								bPubMod = True
							End If
							rsFindReplaceCodeDesc.MoveNext
							If Not rsFindReplaceCodeDesc.EOF Then
								intLastPubNUM = rsFindReplaceCodeDesc("NUM")
							End If
						Wend
					End If
					If UBound(aCheckList) > -1 Then
						For intCheckItem = 0 to UBound(aCheckList)
							aCheckList(intCheckItem) = Trim(aCheckList(intCheckItem))
							If Not Nl(aCheckList(intCheckItem)) Then
								If updateCLNotes(aCheckList(intCheckItem),.Fields("NUM"),strCheckError) Then
									bCheckMod = True
									.Fields("MODIFIED_DATE") = Now()
									.Fields("MODIFIED_BY") = user_strMod
									Select Case aCheckList(intCheckItem)
										Case "ac"
											strAlteredFields = strAlteredFields & strAltFldCon & "Accessibility_CheckListNotes"
										Case "cm"
											strAlteredFields = strAlteredFields & strAltFldCon & "AreasServed_CheckListNotes"
										Case "fd"
											strAlteredFields = strAlteredFields & strAltFldCon & "Funding_CheckListNotes"
										Case "ft"
											strAlteredFields = strAlteredFields & strAltFldCon & "Fees_CheckListNotes"
										Case "ln"
											strAlteredFields = strAlteredFields & strAltFldCon & "Languages_CheckListNotes"
										Case "scha"
											strAlteredFields = strAlteredFields & strAltFldCon & "SchoolsInArea_CheckListNotes"
										Case "sche"
											strAlteredFields = strAlteredFields & strAltFldCon & "SchoolEscort_CheckListNotes"
										Case "toc"
											strAlteredFields = strAlteredFields & strAltFldCon & "TypeOfCare_CheckListNotes"
									End Select
									strAltFldCon = "; "
								ElseIf Not Nl(strCheckError) Then
									Select Case aCheckList(intCheckItem)
										Case "ac"
											strAlteredFields = strAlteredFields & strAltFldCon & "Accessibility_CheckListNotes -> " & strCheckError
										Case "cm"
											strAlteredFields = strAlteredFields & strAltFldCon & "AreasServed_CheckListNotes -> " & strCheckError
										Case "fd"
											strAlteredFields = strAlteredFields & strAltFldCon & "Funding_CheckListNotes -> " & strCheckError
										Case "ft"
											strAlteredFields = strAlteredFields & strAltFldCon & "Fees_CheckListNotes -> " & strCheckError
										Case "ln"
											strAlteredFields = strAlteredFields & strAltFldCon & "Languages_CheckListNotes -> " & strCheckError
										Case "sche"
											strAlteredFields = strAlteredFields & strAltFldCon & "SchoolEscort_CheckListNotes -> " & strCheckError
										Case "toc"
											strAlteredFields = strAlteredFields & strAltFldCon & "TypeOfCare_CheckListNotes -> " & strCheckError
									End Select
									strAltFldCon = "; "
								End If
							End If
						Next
					End If
					For Each fld in .Fields
						strFieldText = fld.Value
						If Not reEquals(fld.Name,"(NUM)|(MODIFIED_DATE)|(MODIFIED_BY)|(([C]){0,2}BT(D)?_ID)",True,False,True,False) And Not Nl(strFieldText) Then
							If reEquals(strFieldText,strFindText,Not bMatchCase,bIgnoreSpace,bMatchWholeField,False) Then
								strFieldText = Trim(reReplace(strFieldText,strFindText,strReplaceText,Not bMatchCase,bIgnoreSpace,True,False))
								If Nl(strFieldText) Then
									strFieldText = Null
								End If
								If fld.DefinedSize <> -1 And Len(strFieldText) > fld.DefinedSize Then
									strAlteredFields = strAlteredFields & strAltFldCon & _
										"<span class=""Alert"">[" & TXT_COULD_NOT_REPLACE_IN & " " & fld.Name & TXT_COLON & TXT_TEXT_TOO_LONG & "]</span>"
									strAltFldCon = "; "
								ElseIf (fld.Type = adNumeric Or fld.Type = adInteger) And Not (Nl(strFieldText) Or IsNumeric(strFieldText)) Then
									strAlteredFields = strAlteredFields & strAltFldCon & _
										"<span class=""Alert"">[" & TXT_COULD_NOT_REPLACE_IN & " " & fld.Name & "]</span>"
									strAltFldCon = "; "
								ElseIf fld.Type = adNumeric And Len(strFieldText) > fld.Precision Then
									strAlteredFields = strAlteredFields & strAltFldCon & _
										"<span class=""Alert"">[" & TXT_COULD_NOT_REPLACE_IN & " " & fld.Name & "]</span>"
									strAltFldCon = "; "
								Else
									If Not reEquals(fld.Name,"EXTRA_.*",True,False,True,False) Then
										fld.Value = strFieldText
									Else
										If reEquals(fld.Name,"EXTRA_EMAIL_[A-Z0-9]+",True,False,True,False) Then
											If Nl(strFieldText) Then
												cmdFindReplaceExtra.CommandText = "DELETE CIC_BT_EXTRA_EMAIL" & _
													"WHERE NUM=" & QsNl(.Fields("NUM")) & " AND LangID=@@LANGID AND FieldName=" & QsNl(fld.Name)											
											Else
												cmdFindReplaceExtra.CommandText = "UPDATE CIC_BT_EXTRA_EMAIL SET Value=" & QsNl(strFieldText) & _
													"WHERE NUM=" & QsNl(.Fields("NUM")) & " AND LangID=@@LANGID AND FieldName=" & QsNl(fld.Name)
											End If
											cmdFindReplaceExtra.Execute		
										ElseIf reEquals(fld.Name,"EXTRA_DATE_[A-Z0-9]+",True,False,True,False) Then
											If Nl(strFieldText) Then
												cmdFindReplaceExtra.CommandText = "DELETE CIC_BT_EXTRA_DATE" & _
													"WHERE NUM=" & QsNl(.Fields("NUM")) & " AND LangID=@@LANGID AND FieldName=" & QsNl(fld.Name)											
											Else
												cmdFindReplaceExtra.CommandText = "UPDATE CIC_BT_EXTRA_DATE SET Value=" & QsNl(strFieldText) & _
													"WHERE NUM=" & QsNl(.Fields("NUM")) & " AND LangID=@@LANGID AND FieldName=" & QsNl(fld.Name)
											End If
											cmdFindReplaceExtra.Execute		
										ElseIf reEquals(fld.Name,"EXTRA_[A-Z0-9]+",True,False,True,False) Then
											If Nl(strFieldText) Then
												cmdFindReplaceExtra.CommandText = "DELETE CIC_BT_EXTRA_TEXT" & _
													"WHERE NUM=" & QsNl(.Fields("NUM")) & " AND LangID=@@LANGID AND FieldName=" & QsNl(fld.Name)											
											Else
												cmdFindReplaceExtra.CommandText = "UPDATE CIC_BT_EXTRA_TEXT SET Value=" & QsNl(strFieldText) & _
													"WHERE NUM=" & QsNl(.Fields("NUM")) & " AND LangID=@@LANGID AND FieldName=" & QsNl(fld.Name)
											End If
											cmdFindReplaceExtra.Execute										
										End If
									End If
									.Fields("MODIFIED_DATE") = Now()
									.Fields("MODIFIED_BY") = user_strMod
									bRecordMod = True
									strAlteredFields = strAlteredFields & strAltFldCon & fld.Name
									strAltFldCon = "; "
									Call addHistoryField(fld.Name)									
								End If
							End If
						End If
					Next
					If bRecordMod Then
						.Update
						If Err.Number <> 0 Then
							bRecordMod = False
							strAlteredFields = "<span class=""Alert"">[" & TXT_ERROR & TXT_UNKNOWN_ERROR_OCCURED & "]</span>"
							.CancelUpdate
							Err.Clear
						End If
					End If
					If bRecordMod Or bPubMod Or bCheckMod Then
						intNumAffected = intNumAffected + 1
						strAffectedList = strAffectedList & strAffCon & .Fields("NUM")
						strAffCon = ","
						
						Call writeHistory(.Fields("NUM"))
					End If
					If bRecordMod Or bPubMod Or bCheckMod Or Not Nl(strAlteredFields) Then
%>
<tr>
	<td><a href="<%=makeDetailsLink(.Fields("NUM"),vbNullString,vbNullString)%>"><%=.Fields("NUM")%></a></td>
	<td><%=Nz(strAlteredFields,"&nbsp;")%></td>
</tr>
<%
						Response.Flush()
					End If
					.MoveNext
				Wend
				.Close
			End With

			If Not Nl(strCodeIDList) Then
				rsFindReplaceCodeDesc.Close
				Set rsFindReplaceCodeDesc = Nothing
				Set cmdFindReplaceCodeDesc = Nothing
			End If
			Set rsFindReplace = Nothing
%>
</table>
<p class="Alert"><%=intNumAffected%> <%=TXT_RECORDS_WERE_ALTERED%> <a href="<%=makeLinkB("presults.asp")%>"><%=TXT_RETURN_PREVIOUS_SEARCH%></a>.</p>
<form action="processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ActionType" value="N">
<input type="hidden" name="IDList" value="<%=strAffectedList%>">
<input type="submit" value="<%=TXT_LIST_ALTERED_RECORDS%>">
</form>
<form action="processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ActionType" value="N">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_ORIGINAL_LIST%>">
</form>
<%
			If Err.Number <> 0 Then
				Response.Write(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED))
				Response.Flush()
				Err.Clear
			End If
		Case RT_INSERT
			If bExtraField Then
				If strFldType = "xd" Then
					strInsertText = Trim(strInsertText)
					If Nl(strInsertText) Then
						Response.Write(TXT_INST_NO_TEXT_APPEND)
						Response.Flush()
					ElseIf Not IsDate(strInsertText) Then
						Response.Write(TXT_ERROR & strInsertText & TXT_INVALID_DATE_FORMAT & DateString(MIN_SMALL_DATE,True) & TXT_AND_LC & DateString(MAX_SMALL_DATE,True))
						Response.Flush()
					Else
						strInsertText = DateString(strInsertText,True)
						strSQL = "SET NOCOUNT ON" & vbCrLf & _
						strBasicTmpNUMs & vbCrLf & _
						strBasicCheckSQL & vbCrLf & _
						"UPDATE xtra SET Value=" & QsNl(strInsertText) & vbCrLf & _
						"FROM " & strTblList & " xtra" & vbCrLf & _
						"INNER JOIN @tmpNUMs tm ON xtra.NUM=tm.NUM" & vbCrLf & _
						"WHERE xtra.FieldName='" & strTblFld & "'" & vbCrLf & _
						"INSERT INTO " & strTblList & " (NUM,FieldName,Value)" & vbCrLf & _
						"SELECT NUM,'" & strTblFld & "'," & QsNl(strInsertText) & vbCrLf & _
						"	FROM @tmpNUMs tm WHERE NOT EXISTS(SELECT * FROM " & strTblList & " xtra WHERE xtra.NUM=tm.NUM AND xtra.FieldName='" & strTblFld & "')" & vbCrLf & _
						"UPDATE cbt SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & QsNl(user_strMod) & " FROM CIC_BaseTable cbt INNER JOIN @tmpNUMs tm ON cbt.NUM=tm.NUM" & vbCrLf & _
						"SET NOCOUNT OFF" & vbCrLf & _
						"DELETE FROM @tmpNUMs"
						
						'Response.Write("<pre>" & strSQL & "</pre>")
						'Response.Flush()
		
						cmdFindReplace.CommandText = strSQL
						cmdFindReplace.Execute intNumAffected
						If intNumAffected > 0 Then
							cmdHistory.Parameters("@FieldName").Value = strTblFld
							cmdHistory.Parameters("@LangID").Value = Null
							cmdHistory.Execute
						End If
					End If
				ElseIf strFldType = "xe" Or strFldType = "xt" Or strFldType = "xw" Then
					strSQL = "SET NOCOUNT ON" & vbCrLf & _
						strBasicTmpNUMs & vbCrLf & strBasicCheckSQL & vbCrLf & _
						"INSERT INTO " & strTblList & " (NUM,LangID,FieldName,Value)" & vbCrLf & _
						"SELECT NUM,@@LANGID,'" & strTblFld & "',''" & vbCrLf & _
						"	FROM @tmpNUMs tm WHERE NOT EXISTS(SELECT * FROM " & strTblList & " xtra WHERE xtra.NUM=tm.NUM AND xtra.LangID=@@LANGID AND xtra.FieldName='" & strTblFld & "')" & vbCrLf & _
						"SET NOCOUNT OFF"
						
					'Response.Write("<pre>" & strSQL & "</pre>")
					'Response.Flush()
						
					cmdFindReplace.CommandText = strSQL
					cmdFindReplace.Execute
									
					strSQL = "SET NOCOUNT ON" & vbCrLf & _
						strBasicTmpNUMs & vbCrLf & _
						"SET NOCOUNT OFF" & vbCrLf & _
						"SELECT btd.NUM,btd.MODIFIED_BY,btd.MODIFIED_DATE,xtra.Value" & vbCrLf & _
						"FROM GBL_BaseTable bt" & vbCrLf & _
						"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
						"INNER JOIN " & strTblList & " xtra ON btd.NUM=xtra.NUM AND xtra.LangID=btd.LangID AND xtra.FieldName='" & strTblFld & "'" & vbCrLf & _
						"INNER JOIN @tmpNUMs tm ON btd.NUM=tm.NUM"
						
					'Response.Write("<pre>" & strSQL & "</pre>")
					'Response.Flush()
					
					cmdFindReplace.CommandText = strSQL
					Set rsFindReplace = Server.CreateObject("ADODB.Recordset")
					With rsFindReplace
						.CursorLocation = adUseClient
						.CursorType = adOpenKeyset
						.LockType = adLockOptimistic
						.Open cmdFindReplace
						While Not .EOF
							Set fld = .Fields("Value")
							strFieldText = Nz(fld.Value, vbNullString)
							If bBeforeText Then
								strFieldText = Trim(strInsertText & strFieldText)
							Else
								strFieldText = Trim(strFieldText & strInsertText)
							End If
							If Nl(strFieldText) Then
								strFieldText = Null
							End If
							If fld.DefinedSize <> -1 And Len(strFieldText) > fld.DefinedSize Then
								Response.Write("<br><span class=""Alert"">[" & _
									"<a href=""" & makeDetailsLink(.Fields("NUM"),vbNullString,vbNullString) & """>" & .Fields("NUM") & "</a>" & _
									" - " & TXT_COULD_NOT_REPLACE_IN & " " & strTblFld & TXT_COLON & TXT_TEXT_TOO_LONG & "]</span>")
								Response.Flush()
							Else
								fld.Value = strFieldText
								.Fields("MODIFIED_DATE") = Now()
								.Fields("MODIFIED_BY") = user_strMod
								.Update
								If Err.Number <> 0 Then
									Response.Write("<span class=""Alert"">[" & _
										"<a href=""" & makeDetailsLink(.Fields("NUM"),vbNullString,vbNullString) & """>" & .Fields("NUM") & "</a>" & _
										" - " & TXT_ERROR & fld.Name & ", " & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED) & "]</span>")
									Err.Clear
								Else
									intNumAffected = intNumAffected + 1
									strAffectedList = strAffectedList & strAffCon & .Fields("NUM")
									strAffCon = ","
		
									Call addHistoryField(strTblFld)
									Call writeHistory(.Fields("NUM"))
								End If
								Response.Flush()
							End If
							.MoveNext
						Wend
						.Close
					End With
					Set rsFindReplace = Nothing
					
					strSQL = "SET NOCOUNT ON" & vbCrLf & _
						strBasicTmpNUMs & vbCrLf & _
						"DELETE xtra FROM " & strTblList & " xtra" & vbCrLf & _
						"INNER JOIN @tmpNUMs tm ON xtra.NUM=tm.NUM" & vbCrLf & _
						"WHERE xtra.FieldName='" & strTblFld & "' AND xtra.Value=''" & vbCrLf & _
						"SET NOCOUNT OFF"
						
					'Response.Write("<pre>" & strSQL & "</pre>")
					'Response.Flush()
						
					cmdFindReplace.CommandText = strSQL
					cmdFindReplace.Execute
				Else
					Response.Write(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED))
					Response.Flush()
				End If
			Else
				strSQL = "SET NOCOUNT ON" & vbCrLf & _
					strBasicTmpNUMs
				If Not Nl(strBasicCheckSQL) Then
					strSQL = strSQL & vbCrLf & _
						strBasicCheckSQL 
				End If
				strSQL = strSQL & vbCrLf & _
					"SET NOCOUNT OFF" & vbCrLf & _
					"SELECT bt.NUM,btd.MODIFIED_BY,btd.MODIFIED_DATE," & strFieldList & vbCrLf & _
					"FROM " & strTblList & vbCrLf & _
					"INNER JOIN @tmpNUMs tm ON bt.NUM=tm.NUM"
					
				'Response.Write("<pre>" & strSQL & "</pre>")
				'Response.Flush()
				
				cmdFindReplace.CommandText = strSQL
				Set rsFindReplace = Server.CreateObject("ADODB.Recordset")
				With rsFindReplace
					.CursorLocation = adUseClient
					.CursorType = adOpenKeyset
					.LockType = adLockOptimistic
					.Open cmdFindReplace
					While Not .EOF
						Set fld = .Fields(strTblFld)
						strFieldText = Nz(fld.Value, vbNullString)
						If bBeforeText Then
							strFieldText = Trim(strInsertText & strFieldText)
						Else
							strFieldText = Trim(strFieldText & strInsertText)
						End If
						If Nl(strFieldText) Then
							strFieldText = Null
						End If
						If fld.DefinedSize <> -1 And Len(strFieldText) > fld.DefinedSize Then
							Response.Write("<br><span class=""Alert"">[" & _
								"<a href=""" & makeDetailsLink(.Fields("NUM"),vbNullString,vbNullString) & """>" & .Fields("NUM") & "</a>" & _
								" - " & TXT_COULD_NOT_REPLACE_IN & " " & fld.Name & TXT_COLON & TXT_TEXT_TOO_LONG & "]</span>")
							Response.Flush()
						Else
							fld.Value = strFieldText
							.Fields("MODIFIED_DATE") = Now()
							.Fields("MODIFIED_BY") = user_strMod
							.Update
							If Err.Number <> 0 Then
								Response.Write("<span class=""Alert"">[" & _
									"<a href=""" & makeDetailsLink(.Fields("NUM"),vbNullString,vbNullString) & """>" & .Fields("NUM") & "</a>" & _
									" - " & TXT_ERROR & fld.Name & ", " & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED) & "]</span>")
								Err.Clear
							Else
								intNumAffected = intNumAffected + 1
								strAffectedList = strAffectedList & strAffCon & .Fields("NUM")
								strAffCon = ","
	
								Call addHistoryField(fld.Name)
								Call writeHistory(.Fields("NUM"))
							End If
							Response.Flush()
						End If
						.MoveNext
					Wend
					.Close
				End With
				Set rsFindReplace = Nothing
			End If
						
			If Err.Number <> 0 Then
				Response.Write(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED))
				Response.Flush()
				Err.Clear
			End If
%>
<p class="Alert"><%=intNumAffected%> <%=TXT_RECORDS_WERE_ALTERED%> <a href="<%=makeLinkB("presults.asp")%>"><%=TXT_RETURN_PREVIOUS_SEARCH%></a>.</p>
<%If Not Nl(strAffectedList) Then%>
<form action="processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ActionType" value="N">
<input type="hidden" name="IDList" value="<%=strAffectedList%>">
<input type="submit" value="<%=TXT_LIST_ALTERED_RECORDS%>">
</form>
<%End If%>
<form action="processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ActionType" value="N">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_ORIGINAL_LIST%>">
</form>
<%
		Case RT_CLEARFIELD
			If bExtraField Then
				strSQL = "SET NOCOUNT ON" & vbCrLf & _
					strBasicTmpNUMs & vbCrLf & _
					"DELETE tm FROM @tmpNUMs tm WHERE NOT EXISTS(SELECT * FROM " & strTblList & " xtra WHERE xtra.NUM=tm.NUM AND xtra.FieldName='" & strTblFld & "'" & StringIf(strFldType <> "xd" AND strFldType <> "xr"," AND xtra.LangID=@@LANGID") & ")" & vbCrLf & _
					"DELETE xtra FROM " & strTblList & " xtra" & vbCrLf & _
					"INNER JOIN @tmpNUMs tm ON xtra.NUM=tm.NUM" & vbCrLf & _
					"WHERE xtra.FieldName='" & strTblFld & "'" & StringIf(strFldType <> "xd" and strFldType <> "xr"," AND xtra.LangID=@@LANGID") & vbCrLf & _
					"UPDATE cbt SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & QsNl(user_strMod) & " FROM CIC_BaseTable cbt INNER JOIN @tmpNUMs tm ON cbt.NUM=tm.NUM" & vbCrLf & _
					"SET NOCOUNT OFF" & vbCrLf & _
					"DELETE FROM @tmpNUMs"

				'Response.Write("<pre>" & strSQL & "</pre>")
				'Response.Flush()

				cmdFindReplace.CommandText = strSQL
				cmdFindReplace.Execute intNumAffected
				If intNumAffected > 0 Then
					cmdHistory.Parameters("@FieldName").Value = strTblFld
					cmdHistory.Parameters("@LangID").Value = IIf(strFldType <> "xd" and strFldType <> "xr",g_objCurrentLang.LangID,Null)
					cmdHistory.Execute
				End If
			Else
				strSQL = "SET NOCOUNT ON" & vbCrLf & _
					strBasicTmpNUMs
				strSQL = strSQL & vbCrLf & _
					"SET NOCOUNT OFF" & vbCrLf & _
					"SELECT bt.NUM,btd.MODIFIED_BY,btd.MODIFIED_DATE," & strFieldList & vbCrLf & _
					"FROM " & strTblList & vbCrLf & _
					"INNER JOIN @tmpNUMs tm ON bt.NUM=tm.NUM"
					
				'Response.Write("<pre>" & strSQL & "</pre>")
				'Response.Flush()
				
				cmdFindReplace.CommandText = strSQL
				Set rsFindReplace = Server.CreateObject("ADODB.Recordset")
				With rsFindReplace
					.CursorLocation = adUseClient
					.CursorType = adOpenKeyset
					.LockType = adLockOptimistic
					.Open cmdFindReplace
					While Not .EOF
						Set fld = .Fields(strTblFld)
						strFieldText = fld.Value
						If Not Nl(strFieldText) Then
							fld.Value = Null
							.Fields("MODIFIED_DATE") = Now()
							.Fields("MODIFIED_BY") = user_strMod
							.Update
							If Err.Number <> 0 Then
								Response.Write("<span class=""Alert"">[" & _
									"<a href=""" & makeDetailsLink(.Fields("NUM"),vbNullString,vbNullString) & """>" & .Fields("NUM") & "</a>" & _
									" - " & TXT_ERROR & fld.Name & ", " & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED) & "]</span>")
								Err.Clear
							Else
								intNumAffected = intNumAffected + 1
								strAffectedList = strAffectedList & strAffCon & .Fields("NUM")
								strAffCon = ","
	
								Call addHistoryField(fld.Name)
								Call writeHistory(.Fields("NUM"))
							End If
						End If
						Response.Flush()
						.MoveNext
					Wend
					.Close
				End With
				Set rsFindReplace = Nothing
			End If
						
			If Err.Number <> 0 Then
				Response.Write(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED))
				Response.Flush()
				Err.Clear
			End If
%>
<p class="Alert"><%=intNumAffected%> <%=TXT_RECORDS_WERE_ALTERED%> <a href="<%=makeLinkB("presults.asp")%>"><%=TXT_RETURN_PREVIOUS_SEARCH%></a>.</p>
<%If Not Nl(strAffectedList) Then%>
<form action="processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ActionType" value="N">
<input type="hidden" name="IDList" value="<%=strAffectedList%>">
<input type="submit" value="<%=TXT_LIST_ALTERED_RECORDS%>">
</form>
<%End If%>
<form action="processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ActionType" value="N">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_ORIGINAL_LIST%>">
</form>
<%
	Case RT_CHECKLIST
		Dim strListTable, _
			strListNotesTable, _
			strListID, _
			intCheckMod, _
			strCheckUpdateSQL, _
			strNoteInsertList, _
			strNoteInsertValue, _
			strExtraCondition, _
			bDropDown
		
		strListNotesTable = vbNullString
		strNoteInsertList = vbNullString
		strNoteInsertValue = vbNullString
		strExtraCondition = vbNullString
		bDropDown = False

		If Not Nl(strCheckListType) Then
			Select Case strCheckListType
				Case "ac"
					strListTable = "GBL_BT_AC"
					strListID = "AC_ID"
					strListNotesTable = strListTable & "_Notes"
					strNoteInsertList = ",Notes"
					strNoteInsertValue = "," & QsNl(strCheckListNote)
					strHistoryFields = "ACCESSIBILITY"
				Case "acr"
					strListID = "ACCREDITED"
					strListTable = "CIC_BaseTable"
					strBasicCheckSQL = strBasicCICCheckSQL
					bDropDown = True
					strHistoryFields = "ACCREDITED"
				Case "br"
					strListTable = "CIC_BT_BR"
					strListID = "BR_ID"
					strBasicCheckSQL = strBasicCICCheckSQL
					strHistoryFields = "BUS_ROUTES"
				Case "cm"
					strListTable = "CIC_BT_CM"
					strListID = "CM_ID"
					strListNotesTable = strListTable & "_Notes"
					strNoteInsertList = ",Notes"
					strNoteInsertValue = "," & QsNl(strCheckListNote)
					strBasicCheckSQL = strBasicCICCheckSQL
					strHistoryFields = "AREAS_SERVED"
				Case "crt"
					strListID = "CERTIFIED"
					strListTable = "CIC_BaseTable"
					strBasicCheckSQL = strBasicCICCheckSQL
					bDropDown = True
					strHistoryFields = "CERTIFIED"
				Case "cur"
					strListID = "PREF_CURRENCY"
					strListTable = "CIC_BaseTable"
					strBasicCheckSQL = strBasicCICCheckSQL
					bDropDown = True
					strHistoryFields = "PREF_CURRENCY"
				Case "dst"
					strListTable = "CIC_BT_DST"
					strListID = "DST_ID"
					strBasicCheckSQL = strBasicCICCheckSQL
					strHistoryFields = "DISTRIBUTION"
				Case "fd"
					strListTable = "CIC_BT_FD"
					strListID = "FD_ID"
					strListNotesTable = strListTable & "_Notes"
					strNoteInsertList = ",Notes"
					strNoteInsertValue = "," & QsNl(strCheckListNote)
					strBasicCheckSQL = strBasicCICCheckSQL
					strHistoryFields = "FUNDING"
				Case "ft"
					strListTable = "CIC_BT_FT"
					strListID = "FT_ID"
					strListNotesTable = strListTable & "_Notes"
					strNoteInsertList = ",Notes"
					strNoteInsertValue = "," & QsNl(strCheckListNote)
					strBasicCheckSQL = strBasicCICCheckSQL
					strHistoryFields = "FEES"
				Case "fye"
					strListID = "FISCAL_YEAR_END"
					strListTable = "CIC_BaseTable"
					strBasicCheckSQL = strBasicCICCheckSQL
					bDropDown = True
					strHistoryFields = "FISCAL_YEAR_END"
				Case "lcm"
					strListID = "LOCATED_IN_CM"
					strListTable = "GBL_BaseTable"
					If Not Nl(intCheckListItem1) Then
						intCheckListItem1 = QsNl(intCheckListItem1)
					End If
					If Not Nl(intCheckListItem2) Then
						intCheckListItem2 = QsNl(intCheckListItem2)
					End If
					bDropDown = True
					strHistoryFields = "LOCATED_IN_CM"
				Case "ln"
					strListTable = "CIC_BT_LN"
					strListID = "LN_ID"
					strListNotesTable = strListTable & "_Notes"
					strNoteInsertList = ",Notes"
					strNoteInsertValue = "," & QsNl(strCheckListNote)
					strBasicCheckSQL = strBasicCICCheckSQL
					strHistoryFields = "LANGUAGES"
				Case "map"
					strListTable = "GBL_BT_MAP"
					strListID = "MAP_ID"
					strHistoryFields = "MAP_LINK"
				Case "mt"
					strListTable = "CIC_BT_MT"
					strListID = "MT_ID"
					strBasicCheckSQL = strBasicCICCheckSQL
					strHistoryFields = "MEMBERSHIP"
				Case "ols"
					strListTable = "GBL_BT_OLS"
					strListID = "OLS_ID"
					strHistoryFields = "ORG_LOCATION_SERVICE"
				Case "pay"
					strListID = "PREF_PAYMENT_METHOD"
					strListTable = "CIC_BaseTable"
					strBasicCheckSQL = strBasicCICCheckSQL
					bDropDown = True
					strHistoryFields = "PREF_PAYMENT_METHOD"
				Case "pyt"
					strListID = "PAYMENT_TERMS"
					strListTable = "CIC_BaseTable"
					strBasicCheckSQL = strBasicCICCheckSQL
					bDropDown = True
					strHistoryFields = "PAYMENT_TERMS"
				Case "rq"
					strListID = "QUALITY"
					strListTable = "CIC_BaseTable"
					strBasicCheckSQL = strBasicCICCheckSQL
					If Not Nl(intCheckListItem1) Then
						intCheckListItem1 = QsNl(intCheckListItem1)
					End If
					If Not Nl(intCheckListItem2) Then
						intCheckListItem2 = QsNl(intCheckListItem2)
					End If
					bDropDown = True
					strHistoryFields = "QUALITY"
				Case "rt"
					strListID = "RECORD_TYPE"
					strListTable = "CIC_BaseTable"
					strBasicCheckSQL = strBasicCICCheckSQL
					If Not Nl(intCheckListItem1) Then
						intCheckListItem1 = QsNl(intCheckListItem1)
					End If
					If Not Nl(intCheckListItem2) Then
						intCheckListItem2 = QsNl(intCheckListItem2)
					End If
					bDropDown = True
					strHistoryFields = "RECORD_TYPE"
				Case "scha"
					strListTable = "CCR_BT_SCH"
					strListID = "SCH_ID"
					strListNotesTable = strListTable & "_Notes"
					strNoteInsertList = ",InAreaNotes"
					strNoteInsertValue = "," & QsNl(strCheckListNote)
					strBasicCheckSQL = strBasicCCRCheckSQL
					strHistoryFields = "SCHOOLS_IN_AREA"
				Case "sche"
					strListTable = "CCR_BT_SCH"
					strListNotesTable = strListTable & "_Notes"
					strListID = "SCH_ID"
					strNoteInsertList = ",EscortNotes"
					strNoteInsertValue = "," & QsNl(strCheckListNote)
					strBasicCheckSQL = strBasicCCRCheckSQL
					strHistoryFields = "SCHOOL_ESCORT"
				Case "sl"
					strListTable = "CIC_BT_SL"
					strListID = "SL_ID"
					strBasicCheckSQL = strBasicCICCheckSQL
					strHistoryFields = "SERVICE_LEVEL"
				Case "sm"
					strListTable = "GBL_BT_SM"
					strListID = "SM_ID"
					strHistoryFields = "SOCIAL_MEDIA"
				Case "toc"
					strListTable = "CCR_BT_TOC"
					strListID = "TOC_ID"
					strListNotesTable = strListTable & "_Notes"
					strNoteInsertList = ",Notes"
					strNoteInsertValue = "," & QsNl(strCheckListNote)
					strBasicCheckSQL = strBasicCCRCheckSQL
					strHistoryFields = "TYPE_OF_CARE"
				Case "top"
					strListID = "TYPE_OF_PROGRAM"
					strListTable = "CCR_BaseTable"
					strBasicCheckSQL = strBasicCCRCheckSQL
					bDropDown = True
					strHistoryFields = "TYPE_OF_PROGRAM"
				Case "wd"
					strListID = "WARD"
					strListTable = "CIC_BaseTable"
					strBasicCheckSQL = strBasicCICCheckSQL
					bDropDown = True
					strHistoryFields = "WARD"
				Case Else
					Dim strExtraPrefix, strFieldName
					strExtraPrefix = UCase(strChecklistType)
					strFieldName = Mid(strExtraPrefix, 4)
					Select Case Left(strChecklistType, 3)
					Case "exc"
						strListTable = "CIC_BT_EXC"
						strListID = "EXC_ID"
						strBasicCheckSQL = strBasicCICCheckSQL
						strHistoryFields = "EXTRA_CHECKLIST_" & strFieldName
					Case "exd"
						strListTable = "CIC_BT_EXD"
						strListID = "EXD_ID"
						strBasicCheckSQL = strBasicCICCheckSQL
						strHistoryFields = "EXTRA_DROPDOWN_" & strFieldName
						strExtraCondition = " OR FieldName_Cache='" & strHistoryFields & "'"
					End Select
			End Select
		End If
				
		If Not Nl(strListTable) And Not (Nl(intCheckListItem1) And Nl(intCheckListItem2)) Then
			Dim cmdFindReplaceCheckList
		
			Set cmdFindReplaceCheckList = Server.CreateObject("ADODB.Command")
			With cmdFindReplaceCheckList
				.ActiveConnection = getCurrentAdminCnn()
				.CommandType = adCmdText
				.CommandTimeout = 0
				'Adding a Checklist Item
				If Nl(intChecklistItem1) Then
					'We do not need to add if the checklist item already exists for the record; remove from the list
					'Update the modified date on list of records that will have a checklist item added
					strCheckUpdateSQL = "SET NOCOUNT ON" & vbCrLf & _
							strBasicTmpNUMs & vbCrLf & _
						"DELETE tm FROM @tmpNUMs tm" & vbCrLf & _
						"	WHERE EXISTS(SELECT * FROM " & strListTable & " lt" & vbCrLf & _
						"		WHERE lt.NUM=tm.NUM AND " & strListID & "=" & intCheckListItem2 & _
						IIf(strCheckListType = "SCHE"," AND Escort=1",StringIf(strCheckListType = "SCHA"," AND InArea=1")) & ")" & vbCrLf & _
						strBasicCheckSQL & vbCrLf & _
						"UPDATE bt SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & QsNl(user_strMod) & " FROM GBL_BaseTable bt INNER JOIN @tmpNUMs tm ON bt.NUM=tm.NUM"
					'Schools in Area and School Escort are special cases; may need to update rather than insert
					Select Case strCheckListType
						Case "scha"
							strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
								"UPDATE lt SET InArea=" & SQL_TRUE & vbCrLf & _
								"FROM " & strListTable & " lt" & vbCrLf & _
								"INNER JOIN @tmpNUMs tm ON lt.NUM=tm.NUM" & vbCrLf & _
								"WHERE " & strListID & "=" & intCheckListItem2 & " AND InArea=" & SQL_FALSE
						Case "sche"
							strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
								"UPDATE lt SET Escort=" & SQL_TRUE & vbCrLf & _
								"FROM " & strListTable & " lt" & vbCrLf & _
								"INNER JOIN @tmpNUMs tm ON lt.NUM=tm.NUM" & vbCrLf & _
								"WHERE " & strListID & "=" & intCheckListItem2 & " AND Escort=" & SQL_FALSE
					End Select
					'If not a drop-down, we need to add checklist values
					If Not bDropDown Then
						strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
							"INSERT INTO " & strListTable & vbCrLf & _
							"	(NUM,"

						Select Case strCheckListType
							Case "sche"
								strCheckUpdateSQL = strCheckUpdateSQL & "Escort,"
							Case "scha"
								strCheckUpdateSQL = strCheckUpdateSQL & "InArea,"
							Case "sm"
								strCheckUpdateSQL = strCheckUpdateSQL & "LangID,URL,"
						End Select
						If Left(strChecklistType, 3) = "exc" or Left(strChecklistType, 3) = "exd" Then
							strCheckUpdateSQL = strCheckUpdateSQL & "FieldName_Cache,"
						End If

						strCheckUpdateSQL = strCheckUpdateSQL & strListID & ")" & vbCrLf & _
							"SELECT tm.NUM,"
						
						Select Case strCheckListType
							Case "sche"
								strCheckUpdateSQL = strCheckUpdateSQL & SQL_TRUE & ","
							Case "scha"
								strCheckUpdateSQL = strCheckUpdateSQL & SQL_TRUE & ","
							Case "sm"
								strCheckUpdateSQL = strCheckUpdateSQL & g_objCurrentLang.LangID & "," & QsNl(strCheckListNote) & ","
						End Select
						If Left(strChecklistType, 3) = "exc" or Left(strChecklistType, 3) = "exd" Then
							strCheckUpdateSQL = strCheckUpdateSQL & "'" & strHistoryFields & "',"
						End If
												
						strCheckUpdateSQL = strCheckUpdateSQL & _
							intCheckListItem2 & vbCrLf & _
							"	FROM @tmpNUMs tm" & vbCrLf & _
							"	WHERE NOT EXISTS(SELECT * FROM " & strListTable & " lt" & vbCrLf & _
							"		WHERE lt.NUM=tm.NUM AND (" & strListID & "=" & intCheckListItem2 & strExtraCondition & "))" & vbCrLf
						'Are there notes to be added?
						If Not Nl(strListNotesTable) And Not Nl(strCheckListNote) Then
							strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
								"INSERT INTO " & strListNotesTable & vbCrLf & _
								"	(BT_" & strListID & ",LangID" & strNoteInsertList & ")" & vbCrLf & _
								"SELECT lt.BT_" & strListID & "," & g_objCurrentLang.LangID & strNoteInsertValue & vbCrLf & _
								"FROM " & strListTable & " lt" & vbCrLf & _
								"INNER JOIN @tmpNUMs tm ON lt.NUM=tm.NUM" & vbCrLf & _
								"WHERE " & strListID & "=" & intCheckListItem2 & vbCrLf & _
								"	AND NOT EXISTS(SELECT * FROM " & strListNotesTable & " ltn" & vbCrLf & _
								"		WHERE lt.BT_" & strListID & "=ltn.BT_" & strListID & " AND ltn.LangID=" & g_objCurrentLang.LangID & ")"
							'School Escort / Schools in Area are special cases
							Select Case strCheckListType
								Case "scha"
									strCheckUpdateSQL = strCheckUpdateSQL & _
										"UPDATE ltn" & vbCrLf & _
										"	SET InAreaNotes=" & QsNl(strCheckListNote) & vbCrLf & _
										"FROM " & strListNotesTable & " ltn" & vbCrLf & _
										"INNER JOIN " & strListTable & " lt ON ltn.BT_" & strListID & "=lt.BT_" & strListID & vbCrLf & _
										"INNER JOIN @tmpNUMs tm ON lt.NUM=tm.NUM" & vbCrLf & _
										"WHERE lt." & strListID & "=" & intCheckListItem2 & _
										"	AND lt.InArea=" & SQL_TRUE & _
										"	AND ltn.InAreaNotes IS NULL" & _
										"	AND ltn.LangID=" & g_objCurrentLang.LangID
								Case "sche"
									strCheckUpdateSQL = strCheckUpdateSQL & _
										"UPDATE ltn" & vbCrLf & _
										"	SET EscortNotes=" & QsNl(strCheckListNote) & vbCrLf & _
										"FROM " & strListNotesTable & " ltn" & vbCrLf & _
										"INNER JOIN " & strListTable & " lt ON ltn.BT_" & strListID & "=lt.BT_" & strListID & vbCrLf & _
										"INNER JOIN @tmpNUMs tm ON lt.NUM=tm.NUM" & vbCrLf & _
										"WHERE lt." & strListID & "=" & intCheckListItem2 & _
										"	AND lt.Escort=" & SQL_TRUE & _
										"	AND ltn.EscortNotes IS NULL" & _
										"	AND ltn.LangID=" & g_objCurrentLang.LangID
								Case Else
							End Select					
						End If
						If Left(strChecklistType, 3) = "exd" Then
							strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
								"UPDATE lt " & vbCrLf & _
								"	SET " & strListID & "=" & intCheckListItem2 & vbCrLf & _
								"FROM " & strListTable & " lt INNER JOIN @tmpNUMs tm ON lt.NUM=tm.NUM" & vbCrLf & _
								"WHERE " & strListID & " IS NULL OR " & strListID & "<>" & intCheckListItem2 & " AND FieldName_Cache='" & strHistoryFields & "'" & vbCrLf
						End If
					'If this is a drop-down, a value will be changed in the basetable
					Else
						strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
							"UPDATE lt " & vbCrLf & _
							"	SET " & strListID & "=" & intCheckListItem2 & vbCrLf & _
							"FROM " & strListTable & " lt INNER JOIN @tmpNUMs tm ON lt.NUM=tm.NUM" & vbCrLf & _
							"WHERE " & strListID & " IS NULL OR " & strListID & "<>" & intCheckListItem2 & vbCrLf
					End If
					strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
						"SET NOCOUNT OFF" & vbCrLf & _
						"DELETE FROM @tmpNUMs"
					
					'Response.Write("<pre>" & strCheckUpdateSQL & "</pre>")
					'Response.Flush()
					
					.CommandText = strCheckUpdateSQL
					.Execute intCheckMod
					If intCheckMod > 0 Then
						intNumAffected = intNumAffected + intCheckMod
					End If
				'Removing a Checklist Item
				ElseIf Nl(intCheckListItem2) Then
					strCheckUpdateSQL = "SET NOCOUNT ON" & vbCrLf & _
							strBasicTmpNUMs & vbCrLf & _
						"DELETE tm FROM @tmpNUMs tm" & vbCrLf & _
						"	WHERE NOT EXISTS(SELECT * FROM " & strListTable & " lt" & vbCrLf & _
						"		WHERE lt.NUM=tm.NUM AND " & strListID & "=" & intCheckListItem1 & _
							IIf(strCheckListType = "SCHE"," AND Escort=1",IIf(strCheckListType = "SCHA"," AND InArea=1",vbNullString)) & ")" & vbCrLf & _
						"UPDATE bt SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & QsNl(user_strMod) & " FROM GBL_BaseTable bt INNER JOIN @tmpNUMs tm ON bt.NUM=tm.NUM"
					Select Case strCheckListType
						Case "scha"
							strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
								"UPDATE lt SET InArea=" & SQL_FALSE & vbCrLf & _
								"FROM " & strListTable & " lt" & vbCrLf & _
								"INNER JOIN @tmpNUMs tm ON lt.NUM=tm.NUM" & vbCrLf & _
								"WHERE " & strListID & "=" & intCheckListItem1 & " AND InArea=" & SQL_TRUE
						Case "sche"
							strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
								"UPDATE lt SET Escort=" & SQL_FALSE & vbCrLf & _
								"FROM " & strListTable & " lt" & vbCrLf & _
								"INNER JOIN @tmpNUMs tm ON lt.NUM=tm.NUM" & vbCrLf & _
								"WHERE " & strListID & "=" & intCheckListItem1 & " AND Escort=" & SQL_TRUE
						Case Else
							If Not bDropDown Then
								strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
									"DELETE lt FROM " & strListTable & " lt" & vbCrLf & _
									"	INNER JOIN @tmpNUMs tm ON lt.NUM=tm.NUM" & vbCrLf & _
									"	WHERE " & strListID & "=" & intCheckListItem1 & _
										StringIf(strCheckListType = "sm"," AND LangID=" & g_objCurrentLang.LangID) & vbCrLf
							Else
								strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
									"UPDATE lt SET " & strListID & "=NULL FROM " & strListTable & " lt" & vbCrLf & _
									"	INNER JOIN @tmpNUMs tm ON lt.NUM=tm.NUM" & vbCrLf & _
									"	WHERE " & strListID & "=" & intCheckListItem1 & vbCrLf
							End If
					End Select
					strCheckUpdateSQL = strCheckUpdateSQL & vbCrLf & _
						"SET NOCOUNT OFF" & vbCrLf & _
						"DELETE FROM @tmpNUMs"

					'Response.Write("<pre>" & strCheckUpdateSQL & "<pre>")
					'Response.Flush()
					
					.CommandText = strCheckUpdateSQL
					.Execute intCheckMod
					If intCheckMod > 0 Then
						intNumAffected = intNumAffected + intCheckMod
					End If
				'Replacing a Checklist Item
				Else
					strCheckUpdateSQL = "SET NOCOUNT ON" & vbCrLf & _
						"UPDATE GBL_BaseTable SET MODIFIED_DATE=GETDATE(), MODIFIED_BY=" & QsNl(user_strMod) & vbCrLf & _
						"	WHERE NUM IN (" & strQIDList & ")" & vbCrLf & _
						"	AND EXISTS(SELECT * FROM " & strListTable & " lt" & vbCrLf & _
						"		WHERE lt.NUM=GBL_BaseTable.NUM AND " & strListID & "=" & intCheckListItem1 & ")" & vbCrLf & _
						"		AND NOT EXISTS(SELECT * FROM " & strListTable & " lt" & vbCrLf & _
						"			WHERE lt.NUM=GBL_BaseTable.NUM AND " & strListID & "=" & intCheckListItem2 & ")" & vbCrLf & _
						"SET NOCOUNT OFF" & vbCrLf & _
						"UPDATE " & strListTable & " SET " & strListID & "=" & intCheckListItem2 & vbCrLf & _
						"	WHERE NUM IN (" & strQIDList & ")" & vbCrLf & _
						"	AND " & strListID & "=" & intCheckListItem1 & vbCrLf & _
						"	AND NOT EXISTS(SELECT * FROM " & strListTable & " lt" & vbCrLf & _
						"		WHERE lt.NUM=" & strListTable & ".NUM AND " & strListID & "=" & intCheckListItem2 & ")"
			
					'Response.Write("<pre>" & strCheckUpdateSQL & "<pre>")
					'Response.Flush()
			
					.CommandText = strCheckUpdateSQL
					.Execute intCheckMod
					If intCheckMod > 0 Then
						intNumAffected = intNumAffected + intCheckMod
					End If
				End If
			End With
			
			If intCheckMod > 0 Then
				If Not Nl(strHistoryFields) Then
					cmdHistory.Parameters("@FieldName").Value = strHistoryFields
					cmdHistory.Execute
				End If
			End If
			
			Set cmdFindReplaceCheckList = Nothing
			If Err.Number <> 0 Then
				intNumAffected = 0
				Call handleError(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
				Response.Flush()
				Err.Clear
			End If

%>
<p class="Alert"><%=intNumAffected%> <%=TXT_RECORDS_WERE_ALTERED%> <a href="<%=makeLinkB("presults.asp")%>"><%=TXT_RETURN_PREVIOUS_SEARCH%></a>.</p>
<form action="processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ActionType" value="N">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_ORIGINAL_LIST%>">
</form>
<%
		End If
	Case RT_NAME
		Dim strNameError

		strSQL = "SELECT bt.NUM,bt.MODIFIED_BY,bt.MODIFIED_DATE FROM GBL_BaseTable bt" & vbCrLf & _
			"WHERE bt.NUM IN (" & strQIDList & ") AND MemberID=" & g_intMemberID & vbCrLf & _
			"ORDER BY bt.NUM"
			
		cmdFindReplace.CommandText = strSQL
		
		'Response.Write(strSQL)
		'Response.Flush()
		
		Set rsFindReplace = Server.CreateObject("ADODB.Recordset")
		With rsFindReplace
			.CursorLocation = adUseClient
			.CursorType = adOpenKeyset
			.LockType = adLockOptimistic
			.Open cmdFindReplace
			While Not .EOF
				dicHistoryFields.RemoveAll()
			
				bRecordMod = False
				strNameError = vbNullString

				If updateName(strNameField,.Fields("NUM"),strNameError) Then
					bRecordMod = True
					strAffectedList = strAffectedList & strAffCon & .Fields("NUM")
					strAffCon = ","
					.Fields("MODIFIED_DATE") = Now()
					.Fields("MODIFIED_BY") = user_strMod
					.Update
					If Err.Number <> 0 Then
						bRecordMod = False
						Call handleError(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
						.CancelUpdate
						Err.Clear
					End If
					intNumAffected = intNumAffected + 1
					
					dicHistoryFields(strNameField) = g_objCurrentLang.LangID
					Call writeHistory(.Fields("NUM"))
				ElseIf Not Nl(strNameError) Then
					Call handleError(TXT_ERROR & strNameError, vbNullString, vbNullString)
				End If
				.MoveNext
			Wend
			.Close
		End With

		Set rsFindReplace = Nothing

		If Err.Number <> 0 Then
			Response.Write(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED))
			Response.Flush()
			Err.Clear
		End If

%>
<p class="Alert"><%=intNumAffected%> <%=TXT_RECORDS_WERE_ALTERED%> <a href="<%=makeLinkB("presults.asp")%>"><%=TXT_RETURN_PREVIOUS_SEARCH%></a>.</p>
<form action="processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ActionType" value="N">
<input type="hidden" name="IDList" value="<%=strAffectedList%>">
<input type="submit" value="<%=TXT_LIST_ALTERED_RECORDS%>">
</form>
<form action="processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ActionType" value="N">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_ORIGINAL_LIST%>">
</form>
<%
		Case RT_CONTACT
			Dim strContactSQL, _
				strContactCon, _
				indContactCrit, _
				strReplaceCon, _
				indReplaceData, _
				strRequiredCon, _
				indRequiredData
			
			strContactCon = vbCrLf & "WHERE "
			strContactSQL = "DECLARE @tmpNUMs TABLE(NUM varchar(8) COLLATE Latin1_General_100_CI_AI)" & vbCrLf & _
							"INSERT INTO @tmpNUMs SELECT DISTINCT tm.*" & vbCrLf & _
							"	FROM dbo.fn_GBL_ParseVarCharIDList(" & QsNl(strIDList) & ",',') tm" & vbCrLf & _
							"	INNER JOIN GBL_BaseTable bt ON tm.ItemID = bt.NUM COLLATE Latin1_General_100_CI_AI AND bt.MemberID=" & g_intMemberID & vbCrLf & _
							"	INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" 
			If dicContactFind.Count > 0 Then
				strContactSQL = strContactSQL & vbCrLf & _
					"	INNER JOIN GBL_Contact c ON btd.NUM=c.GblNUM AND c.LangID=@@LANGID"
				For Each indContactCrit In dicContactFind
					strContactSQL = strContactSQL & strContactCon & _
						"c." & indContactCrit & _
						IIf(bMatchWholeField,"=" & QsN(dicContactFind(indContactCrit))," LIKE " & QsN("%" & dicContactFind(indContactCrit) & "%")) & _
						StringIf(bMatchCase," COLLATE Latin1_General_100_CS_AS")
					strContactCon = AND_CON
				Next
			End If
			
			strContactSQL = strContactSQL & vbCrLf & _
				"INSERT INTO GBL_Contact (GblContactType, GblNUM, LangID)" & vbCrLf & _
				"SELECT " & Qs(strFieldList,SQUOTE) & ",NUM,@@LANGID FROM @tmpNUMs" & vbCrLf & _
				"WHERE NOT EXISTS(SELECT * FROM GBL_Contact WHERE GblContactType=" & Qs(strFieldList,SQUOTE) & " AND GblNUM=NUM AND LangID=@@LANGID)"
			
			strReplaceCon = vbNullString
			strContactSQL = strContactSQL & vbCrLf & "UPDATE GBL_Contact SET "
			For Each indReplaceData In dicContactReplace
				strContactSQL = strContactSQL & strReplaceCon & _
					indReplaceData & "=" & IIf(dicContactReplace(indReplaceData)="*","NULL",IIf(indReplaceData = "FAX_CALLFIRST",dicContactReplace(indReplaceData),QsN(dicContactReplace(indReplaceData))))
				strReplaceCon = ","
			Next
			strContactSQL = strContactSQL & vbCrLf & _
				"WHERE GblContactType=" & Qs(strFieldList,SQUOTE) & " AND LangID=@@LANGID AND EXISTS(SELECT * FROM @tmpNUMs WHERE NUM=GblNUM)"
			
			strContactSQL = strContactSQL & vbCrLf & _
				"UPDATE GBL_Contact SET NAME_HONORIFIC=NULL WHERE NAME_FIRST IS NULL AND NAME_LAST IS NULL AND NAME_HONORIFIC IS NOT NULL" & vbCrLf & _
				"AND GblContactType=" & Qs(strFieldList,SQUOTE) & " AND LangID=@@LANGID AND EXISTS(SELECT * FROM @tmpNUMs WHERE NUM=GblNUM)"
			
			strRequiredCon = vbNullString
			strContactSQL = strContactSQL & vbCrLf & _
				"DELETE c" & vbCrLf & _
				"FROM GBL_Contact c INNER JOIN @tmpNUMs tm ON c.GblNUM=tm.NUM AND c.LangID=@@LANGID AND c.GblContactType=" & Qs(strFieldList,SQUOTE) & vbCrLf & _
				"WHERE "
			For Each indRequiredData In aContactFieldsValidate
				strContactSQL = strContactSQL & strRequiredCon & indRequiredData & " IS NULL"
				strRequiredCon = AND_CON
			Next
			
			strContactSQL = strContactSQL & vbCrLf & _
				"UPDATE GBL_BaseTable_Description SET MODIFIED_DATE=GETDATE(), MODIFIED_BY=" & QsNl(user_strMod) & " WHERE LangID=@@LANGID AND NUM IN (SELECT NUM FROM @tmpNUMs)" & vbCrLf & _
				"DECLARE @AffectedList varchar(max), @NowDateTime datetime" & vbCrLf & _
				"SET @NowDateTime = GETDATE()" & vbCrLf & _
				"SELECT @AffectedList = COALESCE(@AffectedList + ',','') + NUM FROM @tmpNUMs" & vbCrLf & _
				"EXEC dbo.sp_GBL_BaseTable_History_i_Field " & QsNl(user_strMod) & ",@NowDateTime,@AffectedList," & QsNl(strFieldList) & "," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID" & vbCrLf & _
				"SELECT * FROM @tmpNUMs"
			
			Dim cmdFindReplaceContact, _
				rsFindReplaceContact
		
			Set cmdFindReplaceContact = Server.CreateObject("ADODB.Command")
			With cmdFindReplaceContact
				.ActiveConnection = getCurrentAdminCnn()
				.CommandType = adCmdText
				.CommandText = strContactSQL
				.CommandTimeout = 120
				.Parameters.Append .CreateParameter("@AffectedList", adVarChar, adParamOutput, 8000)
				.Execute intNUMAffected
			End With
%>
<h1><%=TXT_FIND_REPLACE_REPORT%></h1>
<p class="Alert"><%=intNumAffected%> <%=TXT_RECORDS_WERE_ALTERED%> <a href="<%=makeLinkB("presults.asp")%>"><%=TXT_RETURN_PREVIOUS_SEARCH%></a>.</p>
<form action="processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ActionType" value="N">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_ORIGINAL_LIST%>">
</form>
<%
	Case RT_RECORDNOTE
		Dim strRecordNoteSQL
		
		strRecordNoteSQL = "DECLARE @tmpNUMs TABLE(NUM varchar(8) COLLATE Latin1_General_100_CI_AI)" & vbCrLf & _
				"INSERT INTO @tmpNUMs SELECT DISTINCT tm.*" & vbCrLf & _
				"	FROM dbo.fn_GBL_ParseVarCharIDList(" & QsNl(strIDList) & ",',') tm" & vbCrLf & _
				"	INNER JOIN GBL_BaseTable bt ON tm.ItemID = bt.NUM COLLATE Latin1_General_100_CI_AI AND bt.MemberID=" & g_intMemberID & vbCrLf & _
				"	INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"INSERT INTO GBL_RecordNote (MODIFIED_BY, CREATED_BY, NoteTypeID, GblNoteType, GblNUM, LangID, Value)" & vbCrLf & _
				"SELECT " & QsNl(user_strMod) & "," & QsNl(user_strMod) & ",(SELECT NoteTypeID FROM GBL_RecordNote_Type WHERE NoteTypeID=" & QsNl(intNoteTypeID) & ")," & Qs(strFieldList,SQUOTE) & ",NUM,@@LANGID," & QsNl(strInsertText) & " FROM @tmpNUMs"

		strRecordNoteSQL = strRecordNoteSQL & vbCrLf & _
			"UPDATE GBL_BaseTable_Description SET MODIFIED_DATE=GETDATE(), MODIFIED_BY=" & QsNl(user_strMod) & " WHERE LangID=@@LANGID AND NUM IN (SELECT NUM FROM @tmpNUMs)" & vbCrLf & _
			"DECLARE @AffectedList varchar(max), @NowDateTime datetime" & vbCrLf & _
			"SET @NowDateTime = GETDATE()" & vbCrLf & _
			"SELECT @AffectedList = COALESCE(@AffectedList + ',','') + NUM FROM @tmpNUMs" & vbCrLf & _
			"EXEC dbo.sp_GBL_BaseTable_History_i_Field " & QsNl(user_strMod) & ",@NowDateTime,@AffectedList," & QsNl(strFieldList) & "," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID" & vbCrLf & _
			"SELECT * FROM @tmpNUMs"
		
		Dim cmdFindReplaceRecordNote, _
			rsFindReplaceRecordNote

		Set cmdFindReplaceRecordNote = Server.CreateObject("ADODB.Command")
		With cmdFindReplaceRecordNote
			.ActiveConnection = getCurrentAdminCnn()
			.CommandType = adCmdText
			.CommandText = strRecordNoteSQL
			.CommandTimeout = 120
			.Parameters.Append .CreateParameter("@AffectedList", adVarChar, adParamOutput, 8000)
			.Execute intNUMAffected
		End With
%>
<h1><%=TXT_FIND_REPLACE_REPORT%></h1>
<p class="Alert"><%=intNumAffected%> <%=TXT_RECORDS_WERE_ALTERED%> <a href="<%=makeLinkB("presults.asp")%>"><%=TXT_RETURN_PREVIOUS_SEARCH%></a>.</p>
<form action="processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ActionType" value="N">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="submit" value="<%=TXT_ORIGINAL_LIST%>">
</form>
<%
	End Select
	
	Set cmdFindReplace = Nothing
	
	Dim cmdUpdate
	Set cmdUpdate = Server.CreateObject("ADODB.Command")
	With cmdUpdate
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "sp_CIC_SRCH_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Execute
	End With
	Set cmdUpdate = Nothing
End If
Call makePageFooter(True)
%>

<!--#include file="includes/core/incClose.asp" -->

