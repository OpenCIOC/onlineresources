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
' Purpose:		Processes the data previously loaded into the system from an Export XML file.
'				This file contains various functions to process data based on field name or type.
'				Only fields explicitly listed in this file are processed, and this file should always
'				reflect the current version of the sharing schema (import/cioc_schema.xsd).
'				Data processed in this file has been previously validated by the schema at the time it
'				was loaded, to conform to length and basic formatting requirements;
'				however, in cases where items must match a system list etc, data may still be moved or dropped.
'				Any moved or dropped data will result in a report to the user.
'
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
Call setPageInfo(True, DM_CIC, DM_CIC, "../", "import/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtImport.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
If Not user_bImportPermissionCIC Then
	Call securityFailure()
End If

'Allow up to 8 hours to process the import routine.
'Note that the scripts allow for partial completion, if the timeout occurs before completion.
Server.ScriptTimeOut = 43200

Const DATASET_FULL = 0
Const DATASET_ADD = 1
Const DATASET_UPDATE = 2

Const CNF_KEEP_EXISTING = 0
Const CNF_TAKE_NEW = 1
Const CNF_DO_NOT_IMPORT = 2

Const FTYPE_TEXT = 0
Const FTYPE_NUMBER = 1
Const FTYPE_DATE = 2

Dim strNowInsert
strNowInsert = QsN(DateString(Date(),False) & " " & Time())

Dim dicTableList, _
	indTable

Set dicTableList = Server.CreateObject("Scripting.Dictionary")

dicTableList.Add "GBL", New TableEntry
Call dicTableList("GBL").setTable("GBL_BaseTable",Null)
dicTableList.Add "GBLE", New TableEntry
Call dicTableList("GBLE").setTable("GBL_BaseTable_Description",LANG_ENGLISH)
dicTableList.Add "GBLF", New TableEntry
Call dicTableList("GBLF").setTable("GBL_BaseTable_Description",LANG_FRENCH)
dicTableList.Add "CIC", New TableEntry
Call dicTableList("CIC").setTable("CIC_BaseTable",Null)
dicTableList.Add "CICE", New TableEntry
Call dicTableList("CICE").setTable("CIC_BaseTable_Description",LANG_ENGLISH)
dicTableList.Add "CICF", New TableEntry
Call dicTableList("CICF").setTable("CIC_BaseTable_Description",LANG_FRENCH)
dicTableList.Add "CCR", New TableEntry
Call dicTableList("CCR").setTable("CCR_BaseTable",Null)
dicTableList.Add "CCRE", New TableEntry
Call dicTableList("CCRE").setTable("CCR_BaseTable_Description",LANG_ENGLISH)
dicTableList.Add "CCRF", New TableEntry
Call dicTableList("CCRF").setTable("CCR_BaseTable_Description",LANG_FRENCH)

Class TableEntry

	Public TableName
	Public Created
	Public Used
	Public LangID
	Public UpdateList

	Private Sub Class_Initialize()
		Created = False
		Used = False
		LangID = Null
		UpdateList = "MODIFIED_DATE=" & strNowInsert & ",MODIFIED_BY='(Import)'"
	End Sub

	Sub setTable(strTableName, intLangID)
		TableName = strTableName
		LangID = intLangID
	End Sub

	Sub resetUsage()
		Created = False
		Used = False
		Select Case TableName
			Case "GBL_BaseTable_Description"
				UpdateList = "MODIFIED_DATE=" & strNowInsert & ",MODIFIED_BY='(Import)',IMPORT_DATE=" & strNowInsert
			Case Else
				UpdateList = "MODIFIED_DATE=" & strNowInsert & ",MODIFIED_BY='(Import)'"
		End Select
	End Sub

	Sub processField(strFieldName,strAttributeName,ByRef strVal,bUseVal,intType)
		Dim bHasVal, strMyVal
		strMyVal = strVal

		bHasVal = False
		If Nl(strFieldName) Then
			strFieldName = xmlChildNode.nodeName
		End If
		strAttributeName = Nz(strAttributeName,"V")

		Select Case LangID
			Case LANG_ENGLISH
				If bInsertEnglish Then
					bHasVal = True
					If Not bUseVal Then
						strMyVal = xmlChildNode.getAttribute(strAttributeName)
					End If
				End If
			Case LANG_FRENCH
				If bInsertFrench Then
					bHasVal = True
					If Not bUseVal Then
						strMyVal = xmlChildNode.getAttribute(strAttributeName & "F")
					End If
				End If
			Case Else
				bHasVal = True
				If Not bUseVal Then
					strMyVal = xmlChildNode.getAttribute(strAttributeName)
				End If
		End Select

		If bHasVal Then
			Used = True
			Select Case intType
				Case FTYPE_DATE
					strMyVal = QsNl(DateTimeString(strMyVal,False))
				Case FTYPE_NUMBER
					strMyVal = Nz(strMyVal,"NULL")
				Case Else
					strMyVal = QsNl(strMyVal)
			End Select
			UpdateList = UpdateList & "," & strFieldName & "=" & strMyVal
		End If
	End Sub

End Class

Sub addImportNote(strNote)
	strReport = strReport & strReportCon & strNote
	strReportCon = " ; " & vbCrLf
End Sub

'*-------------------------------------*
' Begin Generic Import Functions (GBL, CIC)
'*-------------------------------------*

Sub processGBLField(strFieldName,strAttributeName,intType)
	Call dicTableList("GBL").processField(strFieldName,strAttributeName,Null,False,intType)
End Sub

Sub processGBLDField(strFieldName,strAttributeName,intType)
	Call dicTableList("GBLE").processField(strFieldName,strAttributeName,Null,False,intType)
	Call dicTableList("GBLF").processField(strFieldName,strAttributeName,Null,False,intType)
End Sub

Sub processCICField(strFieldName,strAttributeName,intType)
	Call dicTableList("CIC").processField(strFieldName,strAttributeName,Null,False,intType)
End Sub

Sub processCICDField(strFieldName,strAttributeName,intType)
	Call dicTableList("CICE").processField(strFieldName,strAttributeName,Null,False,intType)
	Call dicTableList("CICF").processField(strFieldName,strAttributeName,Null,False,intType)
End Sub

Sub processCCRField(strFieldName,strAttributeName,intType)
	Call dicTableList("CCR").processField(strFieldName,strAttributeName,Null,False,intType)
End Sub

Sub processCCRDField(strFieldName,strAttributeName,intType)
	Call dicTableList("CCRE").processField(strFieldName,strAttributeName,Null,False,intType)
	Call dicTableList("CCRF").processField(strFieldName,strAttributeName,Null,False,intType)
End Sub

'*-------------------------------------*
' End Generic Import Functions (GBL, CIC)
'*-------------------------------------*

'*-------------------------------------*
' Begin Accessibility Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportAccessibility, rsImportAccessibility, _
	cmdImportAccessibilityD, _
	strACIDList, strACIDCon

Sub processAccessibilityA()
	Set cmdImportAccessibility = Server.CreateObject("ADODB.Command")
	Set rsImportAccessibility = Server.CreateObject("ADODB.Recordset")

	With cmdImportAccessibility
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Accessibility_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@AccessibilityTypeEn", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@AccessibilityTypeFr", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@NotesEn", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@NotesFr", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@AC_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportAccessibility
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportAccessibilityD = Server.CreateObject("ADODB.Command")

	With cmdImportAccessibilityD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processAccessibilityB()
	cmdImportAccessibility.Parameters("@NUM").Value = fldNUM
	strACIDList = vbNullString
	strACIDCon = vbNullString
End Sub

Sub processAccessibilityC()
	Dim xmlAccessibilityNode, _
		strAccessibilityTypeE, strAccessibilityTypeF, _
		strAccessibilityNoteE, strAccessibilityNoteF, _
		strAccessibilityNotesE, strAccessibilityNotesF, _
		strNoteConE, strNoteConF

	strAccessibilityNotesE = vbNullString
	strAccessibilityNotesF = vbNullString
	strNoteConE = vbNullString
	strNoteConF = vbNullString

	If bInsertEnglish Then
		strAccessibilityNotesE = Nz(xmlChildNode.getAttribute("N"),vbNullString)
		If Not Nl(strAccessibilityNotesE) Then
			strNoteConE = " ; "
		End If
	End If
	If bInsertFrench Then
		strAccessibilityNotesF = Nz(xmlChildNode.getAttribute("NF"),vbNullString)
		If Not Nl(strAccessibilityNotesF) Then
			strNoteConF = " ; "
		End If
	End If

	For Each xmlAccessibilityNode in xmlChildNode.childNodes
		If bInsertEnglish Then
			strAccessibilityTypeE = xmlAccessibilityNode.getAttribute("V")
			strAccessibilityNoteE = xmlAccessibilityNode.getAttribute("N")
		End If
		If bInsertFrench Then
			strAccessibilityTypeF = Nz(xmlAccessibilityNode.getAttribute("VF"),xmlAccessibilityNode.getAttribute("V"))
			strAccessibilityNoteF = xmlAccessibilityNode.getAttribute("NF")
		End If

		With cmdImportAccessibility
			.Parameters("@AccessibilityTypeEn").Value = Nz(strAccessibilityTypeE,Null)
			.Parameters("@AccessibilityTypeFr").Value = Nz(strAccessibilityTypeF,Null)
			.Parameters("@NotesEn").Value = Nz(strAccessibilityNoteE,Null)
			.Parameters("@NotesFr").Value = Nz(strAccessibilityNoteF,Null)
		End With

		Set rsImportAccessibility = cmdImportAccessibility.Execute

		With rsImportAccessibility
			Set rsImportAccessibility = .NextRecordset
			If Not Nl(cmdImportAccessibility.Parameters("@AC_ID")) Then
				strACIDList = strACIDList & strACIDCon & cmdImportAccessibility.Parameters("@AC_ID")
				strACIDCon = ","
			Else
				If bInsertEnglish Then
					strAccessibilityNotesE = strAccessibilityTypeE & _
						IIf(Nl(strAccessibilityNoteE),vbNullString," - " & strAccessibilityNoteE) & _
						strNoteConE & strAccessibilityNotesE
					strNoteConE = " ; "
				End If
				If bInsertFrench Then
					strAccessibilityNotesF = strAccessibilityTypeF & _
						IIf(Nl(strAccessibilityNoteF),vbNullString," - " & strAccessibilityNoteF) & _
						strNoteConF & strAccessibilityNotesF
					strNoteConF = " ; "
				End If
				Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_VALUE_MOVED_TO_NOTES & TXT_COLON & Nz(strAccessibilityTypeE,strAccessibilityTypeF))
			End If
		End With
	Next

	With cmdImportAccessibilityD
		.CommandText = "DELETE FROM GBL_BT_AC WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strACIDList)," AND AC_ID NOT IN (" & strACIDList & ")")
		.Execute
	End With

	Call dicTableList("GBLE").processField("ACCESSIBILITY_NOTES",Null,strAccessibilityNotesE,True,FTYPE_TEXT)
	Call dicTableList("GBLF").processField("ACCESSIBILITY_NOTES",Null,strAccessibilityNotesF,True,FTYPE_TEXT)
End Sub

'*-------------------------------------*
' End Accessibility Import Functions (A,B,C)
'*-------------------------------------*

'*-------------------------------------*
' Begin Accreditation Import Functions
'*-------------------------------------*
Dim cmdImportAccreditation, rsImportAccreditation

Sub processAccreditationA()
	Set cmdImportAccreditation = Server.CreateObject("ADODB.Command")
	Set rsImportAccreditation = Server.CreateObject("ADODB.Recordset")

	With cmdImportAccreditation
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Accreditation_Check"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@AccreditationE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@AccreditationF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@ACR_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportAccreditation
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processAccreditationB()
	Dim strAccreditationE, strAccreditationF

	If bInsertEnglish Then
		strAccreditationE = xmlChildNode.getAttribute("V")
	End If
	If bInsertFrench Then
		strAccreditationF = Nz(xmlChildNode.getAttribute("VF"),xmlChildNode.getAttribute("V"))
	End If

	If Nl(strAccreditationE) And Nl(strAccreditationF) Then
		Call dicTableList("CIC").processField("ACCREDITED",Null,"NULL",True,FTYPE_NUMBER)
	Else
		With cmdImportAccreditation
			.Parameters("@AccreditationE") = Nz(strAccreditationE,Null)
			.Parameters("@AccreditationF") = Nz(strAccreditationF,Null)
		End With

		Set rsImportAccreditation = cmdImportAccreditation.Execute

		With rsImportAccreditation
			Set rsImportAccreditation = .NextRecordset
			If Nl(cmdImportAccreditation.Parameters("@ACR_ID")) Then
				Call dicTableList("CIC").processField("ACCREDITED",Null,"NULL",True,FTYPE_NUMBER)
				Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & Nz(strAccreditationE,strAccreditationF))
			Else
				Call dicTableList("CIC").processField("ACCREDITED",Null,cmdImportAccreditation.Parameters("@ACR_ID"),True,FTYPE_NUMBER)
			End If
		End With
	End If
End Sub

'*-------------------------------------*
' End Accreditation Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Activity Import Functions
'*-------------------------------------*
Dim cmdImportActivityInfo, rsImportActivityInfo, _
	cmdImportActivityInfoD

Sub processActivityInfoA()
	Set cmdImportActivityInfo = Server.CreateObject("ADODB.Command")
	Set cmdImportActivityInfoD = Server.CreateObject("ADODB.Command")

	With cmdImportActivityInfo
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_ActivityInfo_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@HAS_ENGLISH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@HAS_FRENCH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@GUID", adGUID, adParamInput, 16)
		.Parameters.Append .CreateParameter("@ActivityNameEn", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@ActivityNameFr", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@ActivityDescriptionEn", adVarChar, adParamInput, 2000)
		.Parameters.Append .CreateParameter("@ActivityDescriptionFr", adVarChar, adParamInput, 2000)
		.Parameters.Append .CreateParameter("@ActivityStatusEn", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@ActivityStatusFr", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@NotesEn", adVarChar, adParamInput, 2000)
		.Parameters.Append .CreateParameter("@NotesFr", adVarChar, adParamInput, 2000)
		.Parameters.Append .CreateParameter("@BT_ACT_ID", adInteger, adParamOutput, 4)
	End With

	With cmdImportActivityInfoD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processActivityInfoB()
	cmdImportActivityInfo.Parameters("@NUM").Value = fldNUM
	cmdImportActivityInfo.Parameters("@HAS_ENGLISH").Value = IIf(bInsertEnglish,SQL_TRUE,SQL_FALSE)
	cmdImportActivityInfo.Parameters("@HAS_FRENCH").Value = IIf(bInsertFrench,SQL_TRUE,SQL_FALSE)
End Sub

Sub processActivityInfoC()
	Dim xmlActivityInfoNode, _
		strActivityInfoGUID, _
		strActivityInfoActivityNameE,_
		strActivityInfoActivityNameF,_
		strActivityInfoActivityDescriptionE,_
		strActivityInfoActivityDescriptionF,_
		strActivityInfoStatusE,_
		strActivityInfoStatusF,_
		dActivityInfoStartDate,_
		dActivityInfoEndDate,_
		strActivityInfoNoteE, _
		strActivityInfoNoteF, _
		strActivityInfoNotesE, _
		strActivityInfoNotesF, _
		strNoteConE, strNoteConF, _
		strACTIDList, _
		strACTIDCon

	makeCICRecordCheck()

	If bInsertEnglish Then
		strActivityInfoNotesE = xmlChildNode.getAttribute("N")
	End If
	If bInsertFrench Then
		strActivityInfoNotesF = xmlChildNode.getAttribute("NF")
	End If

	If Not Nl(strActivityInfoNotesE) Then
		strNoteConE = vbCrLf & vbCrLf
	End If
	If Not Nl(strActivityInfoNotesF) Then
		strNoteConF = vbCrLf & vbCrLf
	End If

	For Each xmlActivityInfoNode in xmlChildNode.childNodes
		strActivityInfoGUID = xmlActivityInfoNode.getAttribute("GID")
		If bInsertEnglish Then
			strActivityInfoActivityNameE = xmlActivityInfoNode.getAttribute("ACTN")
			strActivityInfoActivityDescriptionE = xmlActivityInfoNode.getAttribute("ACTD")
			strActivityInfoStatusE = xmlActivityInfoNode.getAttribute("ACTS")
			strActivityInfoNoteE = xmlActivityInfoNode.getAttribute("N")
		End If
		If bInsertFrench Then
			strActivityInfoActivityNameF = xmlActivityInfoNode.getAttribute("ACTNF")
			strActivityInfoActivityDescriptionF = xmlActivityInfoNode.getAttribute("ACTDF")
			strActivityInfoStatusF = xmlActivityInfoNode.getAttribute("ACTSF")
			strActivityInfoNoteF = xmlActivityInfoNode.getAttribute("NF")
		End If

		cmdImportActivityInfo.Parameters("@GUID").Value = "{" & strActivityInfoGUID & "}"
		cmdImportActivityInfo.Parameters("@ActivityNameEn").Value = Nz(strActivityInfoActivityNameE,Null)
		cmdImportActivityInfo.Parameters("@ActivityNameFr").Value = Nz(strActivityInfoActivityNameF,Null)
		cmdImportActivityInfo.Parameters("@ActivityDescriptionEn").Value = Nz(strActivityInfoActivityDescriptionE,Null)
		cmdImportActivityInfo.Parameters("@ActivityDescriptionFr").Value = Nz(strActivityInfoActivityDescriptionF,Null)
		cmdImportActivityInfo.Parameters("@ActivityStatusEn").Value = Nz(strActivityInfoStatusE,Null)
		cmdImportActivityInfo.Parameters("@ActivityStatusFr").Value = Nz(strActivityInfoStatusF,Null)
		cmdImportActivityInfo.Parameters("@NotesEn").Value = Nz(strActivityInfoNoteE,Null)
		cmdImportActivityInfo.Parameters("@NotesFr").Value = Nz(strActivityInfoNoteF,Null)

		Set rsImportActivityInfo = cmdImportActivityInfo.Execute

		With rsImportActivityInfo
			Set rsImportActivityInfo = .NextRecordset
			If Not Nl(cmdImportActivityInfo.Parameters("@BT_ACT_ID")) Then
				strACTIDList = strACTIDList & strACTIDCon & cmdImportActivityInfo.Parameters("@BT_ACT_ID")
				strACTIDCon = ","
			Else
				Call addImportNote("[" & strImportFld & "] " & TXT_COULD_NOT_CREATE_ACTIVITY & TXT_COLON & strActivityGUID)
			End If
		End With
	Next

	With cmdImportActivityInfoD
		.CommandText = "DELETE FROM CIC_BT_ACT WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strACTIDList)," AND BT_ACT_ID NOT IN (" & strACTIDList & ")")
		.Execute
	End With

	If bInsertEnglish Then
		Call dicTableList("CICE").processField("ACTIVITY_NOTES",Null,strActivityInfoNotesE,True,FTYPE_TEXT)
	End If
	If bInsertFrench Then
		Call dicTableList("CICF").processField("ACTIVITY_NOTES",Null,strActivityInfoNotesF,True,FTYPE_TEXT)
	End If

End Sub

'*-------------------------------------*
' End Activity Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Address Import Functions
'*-------------------------------------*

Sub processAddress(strType)
	Call processGBLDField(strType & "_LINE_1","LN1",FTYPE_TEXT)
	Call processGBLDField(strType & "_LINE_2","LN2",FTYPE_TEXT)
	Call processGBLField(strType & "_POSTAL_CODE","PC",FTYPE_TEXT)
	Call processGBLDField(strType & "_BUILDING","BLD",FTYPE_TEXT)
	Call processGBLDField(strType & "_STREET_NUMBER","STNUM",FTYPE_TEXT)
	Call processGBLDField(strType & "_STREET","ST",FTYPE_TEXT)
	Call processGBLDField(strType & "_STREET_TYPE","STTYPE",FTYPE_TEXT)
	Call processGBLDField(strType & "_STREET_DIR","STDIR",FTYPE_TEXT)
	Call processGBLDField(strType & "_SUFFIX","SFX",FTYPE_TEXT)
	Call processGBLDField(strType & "_CITY","CTY",FTYPE_TEXT)
	Call processGBLDField(strType & "_PROVINCE","PRV",FTYPE_TEXT)
	Call processGBLDField(strType & "_COUNTRY","CTRY",FTYPE_TEXT)

	If strType = "MAIL" Then
		Call processGBLDField(strType & "_CARE_OF","CO",FTYPE_TEXT)
		Call processGBLDField(strType & "_BOX_TYPE","BXTP",FTYPE_TEXT)
		Call processGBLDField(strType & "_PO_BOX","BOX",FTYPE_TEXT)
	End If
End Sub

'*-------------------------------------*
' End Address Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Alt Org Import Functions (A,B)
'*-------------------------------------*

Dim cmdImportAltOrg

Sub processAltOrgA()
	Set cmdImportAltOrg = Server.CreateObject("ADODB.Command")

	With cmdImportAltOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processAltOrgB()
	Dim xmlAltOrgNode, _
		strAltOrgName, _
		bAltOrgPublish, _
		intAltOrgLangID, _
		strAOEList, _
		strAOFList, _
		strAOECon, _
		strAOFCon

	strAOECon = vbNullString
	strAOFCon = vbNullString

	For Each xmlAltOrgNode in xmlChildNode.childNodes
		strAltOrgName = xmlAltOrgNode.getAttribute("V")
		bAltOrgPublish = Nz(xmlAltOrgNode.getAttribute("PB"),SQL_FALSE)
		Select Case xmlAltOrgNode.getAttribute("LANG")
			Case "E"
				intAltOrgLangID = LANG_ENGLISH
			Case "F"
				intAltOrgLangID = LANG_FRENCH
			Case Else
				strAltOrgName = vbNullString
		End Select

		If Not Nl(strAltOrgName) Then
			strAltOrgName = QsN(strAltOrgName)
			If (intAltOrgLangID = LANG_ENGLISH And bInsertEnglish) Or (intAltOrgLangID = LANG_FRENCH And bInsertFrench) Then
				If intAltOrgLangID = LANG_ENGLISH And bInsertEnglish Then
					strAOEList = strAOEList & strAOECon & strAltOrgName
					strAOECon = ","
				End If
				If intAltOrgLangID = LANG_FRENCH And bInsertFrench Then
					strAOFList = strAOFList & strAOFCon & strAltOrgName
					strAOFCon = ","
				End If
				With cmdImportAltOrg
					.CommandText = "IF NOT EXISTS(SELECT * FROM GBL_BT_ALTORG WHERE LangID=" & intAltOrgLangID & " AND NUM=" & strQNUM & _
						" AND ALT_ORG=" & strAltOrgName & ") BEGIN" & _
						" INSERT INTO GBL_BT_ALTORG (NUM,LangID,ALT_ORG,PUBLISH) VALUES (" & strQNUM & "," & intAltOrgLangID & "," & strAltOrgName & "," & bAltOrgPublish & ") END" & _
						" ELSE BEGIN UPDATE GBL_BT_ALTORG SET PUBLISH=" & bAltOrgPublish & _
						" WHERE NUM=" & strQNUM & " AND LangID=" & intAltOrgLangID & " AND ALT_ORG=" & strAltOrgName & _
						" AND PUBLISH<>" & bAltOrgPublish & " END"
					.Execute
				End With
			End If
		End If
	Next

	With cmdImportAltOrg
		If bInsertEnglish Then
			.CommandText = "DELETE FROM GBL_BT_ALTORG WHERE LangID=" & LANG_ENGLISH & " AND NUM=" & strQNUM & _
				StringIf(Not Nl(strAOEList)," AND ALT_ORG NOT IN (" & strAOEList & ")")
			.Execute
		End If
		If bInsertFrench Then
			.CommandText = "DELETE FROM GBL_BT_ALTORG WHERE LangID=" & LANG_FRENCH & " AND NUM=" & strQNUM & _
				StringIf(Not Nl(strAOFList)," AND ALT_ORG NOT IN (" & strAOFList & ")")
			.Execute
		End If
	End With
End Sub

'*-------------------------------------*
' End Alt Org Import Functions (A,B)
'*-------------------------------------*

'*-------------------------------------*
' Begin Areas Served Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportAreasServed, rsImportAreasServed, _
	cmdImportAreasServedD, _
	strCMIDList, strCMIDCon

Sub processAreasServedA()
	Set cmdImportAreasServed = Server.CreateObject("ADODB.Command")
	Set rsImportAreasServed = Server.CreateObject("ADODB.Recordset")

	With cmdImportAreasServed
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_AreasServed_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@CommunityE", adVarWChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@CommunityF", adVarWChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@AuthCommunity", adVarWChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@ProvState", adVarWChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@DefaultProvState", adVarWChar, adParamInput, 2, Nz(g_strDefaultProvState,Null))
		.Parameters.Append .CreateParameter("@Country", adVarWChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@NotesEn", adVarWChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@NotesFr", adVarWChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@CM_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportAreasServed
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportAreasServedD = Server.CreateObject("ADODB.Command")

	With cmdImportAreasServedD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processAreasServedB()
	cmdImportAreasServed.Parameters("@NUM").Value = fldNUM
	strCMIDList = vbNullString
	strCMIDCon = vbNullString
End Sub

Sub processAreasServedC()
	Dim xmlCommunityNode, _
		strCommunityE, strCommunityF, strAuthCommunity, _
		strProv, strCountry, _
		strCommunityNoteE, strCommunityNoteF, _
		strCommunityNotesE, strCommunityNotesF, _
		bCommunityOnlyNotesE, bCommunityOnlyNotesF, _
		strNoteConE, strNoteConF

	strCommunityNotesE = vbNullString
	strCommunityNotesF = vbNullString
	strNoteConE = vbNullString
	strNoteConF = vbNullString

	makeCICRecordCheck()

	If bInsertEnglish Then
		strCommunityNotesE = Nz(xmlChildNode.getAttribute("N"),vbNullString)
		If Not Nl(strCommunityNotesE) Then
			strNoteConE = " ; "
		End If
		bCommunityOnlyNotesE = Nz(xmlChildNode.getAttribute("ODN"),Null)
	End If
	If bInsertFrench Then
		strCommunityNotesF = Nz(xmlChildNode.getAttribute("NF"),vbNullString)
		If Not Nl(strCommunityNotesF) Then
			strNoteConF = " ; "
		End If
		bCommunityOnlyNotesF = Nz(xmlChildNode.getAttribute("ODNF"),Null)
	End If

	For Each xmlCommunityNode in xmlChildNode.childNodes
		strAuthCommunity = xmlCommunityNode.getAttribute("AP")
		strProv = xmlCommunityNode.getAttribute("PRV")
		strCountry = xmlCommunityNode.getAttribute("CTRY")
		If bInsertEnglish Then
			strCommunityE = xmlCommunityNode.getAttribute("V")
			strCommunityNoteE = xmlCommunityNode.getAttribute("N")
		End If
		If bInsertFrench Then
			strCommunityF = Nz(xmlCommunityNode.getAttribute("VF"),xmlCommunityNode.getAttribute("V"))
			strCommunityNoteF = xmlCommunityNode.getAttribute("NF")
		End If

		With cmdImportAreasServed
			.Parameters("@CommunityE").Value = Nz(strCommunityE,Null)
			.Parameters("@CommunityF").Value = Nz(strCommunityF,Null)
			.Parameters("@AuthCommunity").Value = Nz(strAuthCommunity,Null)
			.Parameters("@ProvState").Value = Nz(strProv,Null)
			.Parameters("@Country").Value = Nz(strCountry,Null)
			.Parameters("@NotesEn").Value = Nz(strCommunityNoteE,Null)
			.Parameters("@NotesFr").Value = Nz(strCommunityNoteF,Null)
		End With

		Set rsImportAreasServed = cmdImportAreasServed.Execute

		With rsImportAreasServed
			Set rsImportAreasServed = .NextRecordset
			If Not Nl(cmdImportAreasServed.Parameters("@CM_ID")) Then
				strCMIDList = strCMIDList & strCMIDCon & cmdImportAreasServed.Parameters("@CM_ID")
				strCMIDCon = ","
			Else
				If bInsertEnglish Then
					strCommunityNotesE = strCommunityE & _
						IIf(Nl(strCommunityNoteE),vbNullString," - " & strCommunityNoteE) & _
						strNoteConE & strCommunityNotesE
					strNoteConE = " ; "
				End If
				If bInsertFrench Then
					strCommunityNotesF = strCommunityF & _
						IIf(Nl(strCommunityNoteF),vbNullString," - " & strCommunityNoteF) & _
						strNoteConF & strCommunityNotesF
					strNoteConF = " ; "
				End If
				Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_VALUE_MOVED_TO_NOTES & TXT_COLON & Nz(strCommunityE,strCommunityF))
			End If
		End With
	Next

	With cmdImportAreasServedD
		.CommandText = "DELETE FROM CIC_BT_CM WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strCMIDList)," AND CM_ID NOT IN (" & strCMIDList & ")")
		.Execute
	End With

	Call dicTableList("CICE").processField("AREAS_SERVED_NOTES",Null,strCommunityNotesE,True,FTYPE_TEXT)
	Call dicTableList("CICF").processField("AREAS_SERVED_NOTES",Null,strCommunityNotesF,True,FTYPE_TEXT)
	If Not Nl(bCommunityOnlyNotesE) Then
		Call dicTableList("CICE").processField("AREAS_SERVED_ONLY_DISPLAY_NOTES",Null,bCommunityOnlyNotesE,True,FTYPE_NUMBER)
	End If
	If Not Nl(bCommunityOnlyNotesF) Then
		Call dicTableList("CICF").processField("AREAS_SERVED_ONLY_DISPLAY_NOTES",Null,bCommunityOnlyNotesF,True,FTYPE_NUMBER)
	End If
End Sub

'*-------------------------------------*
' End Areas Served Import Functions (A,B,C)
'*-------------------------------------*

'*-------------------------------------*
' Begin Billing Address Import Functions (A,B,C)
'*-------------------------------------*

'***************************************
' Begin Sub processBillingAddressA
'	Creates a command object for updating the taxonomy data
'***************************************
Dim cmdImportBillingAddressInfo, rsImportBillingAddressInfo, _
	cmdImportBillingAddressInfoD

Sub processBillingAddressA()
	Set cmdImportBillingAddressInfo = Server.CreateObject("ADODB.Command")
	Set cmdImportBillingAddressInfoD = Server.CreateObject("ADODB.Command")

	With cmdImportBillingAddressInfo
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_BillingAddress_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2)
		.Parameters.Append .CreateParameter("@GUID", adGUID, adParamInput, 16)
		.Parameters.Append .CreateParameter("@AddrType", adVarChar, adParamInput, 20)
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@CASConfirmationDate", adDate, adParamInput, 16)
		.Parameters.Append .CreateParameter("@Priority", adInteger, adParamInput, 1)
		.Parameters.Append .CreateParameter("@Line1", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@Line2", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@Line3", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@Line4", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@City", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@Province", adVarChar, adParamInput, 2)
		.Parameters.Append .CreateParameter("@Country", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@PostalCode", adVarChar, adParamInput, 10)
		.Parameters.Append .CreateParameter("@BADDR_ID", adInteger, adParamOutput, 4)
	End With

	With cmdImportBillingAddressInfoD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub
'***************************************
' End Sub processBillingAddressA
'***************************************

'***************************************
' Begin Sub processBillingAddressB
'	Reset values for the current record
'***************************************
Sub processBillingAddressB()
	cmdImportBillingAddressInfo.Parameters("@NUM").Value = fldNUM
End Sub
'***************************************
' End Sub processBillingAddressB
'***************************************

'***************************************
' Begin Sub processBillingAddressC
'	Update the BillingAddress data for the given record.
'***************************************
Sub processBillingAddressC()
	Dim xmlBillingAddressNode, _
		strBillingAddressGUID, _
		intBillingAddressLangID, _
		strBillingAddressType, _
		strBillingAddressCode, _
		dBillingAddressCASConfirmation, _
		intBillingAddressPriority, _
		strBillingAddressLine1, _
		strBillingAddressLine2, _
		strBillingAddressLine3, _
		strBillingAddressLine4, _
		strBillingAddressCity, _
		strBillingAddressProvince, _
		strBillingAddressCountry, _
		strBillingAddressPostalCode, _
		strADDRIDList, _
		strADDRIDCon

	makeCICRecordCheck()


	For Each xmlBillingAddressNode in xmlChildNode.childNodes
		Select Case xmlBillingAddressNode.getAttribute("LANG")
			Case "E"
				intBillingAddressLangID = LANG_ENGLISH
			Case "F"
				intBillingAddressLangID = LANG_FRENCH
			Case Else
				intBillingAddressLangID = Null
		End Select

		If (intBillingAddressLangID = LANG_ENGLISH And bInsertEnglish) Or (intBillingAddressLangID = LANG_FRENCH And bInsertFrench) Then
			strBillingAddressGUID = xmlBillingAddressNode.getAttribute("GID")
			strBillingAddressType = xmlBillingAddressNode.getAttribute("TYPE")
			strBillingAddressCode = xmlBillingAddressNode.getAttribute("CD")
			dBillingAddressCASConfirmation = DateTimeStringFromXML(xmlBillingAddressNode.getAttribute("CCD"), False)
			intBillingAddressPriority = xmlBillingAddressNode.getAttribute("PRI")
			strBillingAddressLine1 = xmlBillingAddressNode.getAttribute("LN1")
			strBillingAddressLine2 = xmlBillingAddressNode.getAttribute("LN2")
			strBillingAddressLine3 = xmlBillingAddressNode.getAttribute("LN3")
			strBillingAddressLine4 = xmlBillingAddressNode.getAttribute("LN4")
			strBillingAddressCity = xmlBillingAddressNode.getAttribute("CTY")
			strBillingAddressProvince = xmlBillingAddressNode.getAttribute("PRV")
			strBillingAddressCountry = xmlBillingAddressNode.getAttribute("CTRY")
			strBillingAddressPostalCode = xmlBillingAddressNode.getAttribute("PC")


			cmdImportBillingAddressInfo.Parameters("@GUID").Value = "{" & strBillingAddressGUID & "}"
			cmdImportBillingAddressInfo.Parameters("@LangID").Value = intBillingAddressLangID
			cmdImportBillingAddressInfo.Parameters("@AddrType").Value = Nz(strBillingAddressType,Null)
			cmdImportBillingAddressInfo.Parameters("@Code").Value = Nz(strBillingAddressCode,Null)
			cmdImportBillingAddressInfo.Parameters("@CASConfirmationDate").Value = dBillingAddressCASConfirmation
			cmdImportBillingAddressInfo.Parameters("@Priority").Value = Nz(intBillingAddressPriority,Null)
			cmdImportBillingAddressInfo.Parameters("@Line1").Value = Nz(strBillingAddressLine1,Null)
			cmdImportBillingAddressInfo.Parameters("@Line2").Value = Nz(strBillingAddressLine2,Null)
			cmdImportBillingAddressInfo.Parameters("@Line3").Value = Nz(strBillingAddressLine3,Null)
			cmdImportBillingAddressInfo.Parameters("@Line4").Value = Nz(strBillingAddressLine4,Null)
			cmdImportBillingAddressInfo.Parameters("@City").Value = Nz(strBillingAddressCity,Null)
			cmdImportBillingAddressInfo.Parameters("@Province").Value = Nz(strBillingAddressProvince,Null)
			cmdImportBillingAddressInfo.Parameters("@Country").Value = Nz(strBillingAddressCountry,Null)
			cmdImportBillingAddressInfo.Parameters("@PostalCode").Value = Nz(strBillingAddressPostalCode,Null)

			Set rsImportBillingAddressInfo = cmdImportBillingAddressInfo.Execute

			With rsImportBillingAddressInfo
				Set rsImportBillingAddressInfo = .NextRecordset
				If Not Nl(cmdImportBillingAddressInfo.Parameters("@BADDR_ID")) Then
					strADDRIDList = strADDRIDList & strADDRIDCon & cmdImportBillingAddressInfo.Parameters("@BADDR_ID")
					strADDRIDCon = ","
				End If
			End With
		End If
	Next

	With cmdImportBillingAddressInfoD
		.CommandText = "DELETE FROM GBL_BT_BILLINGADDRESS WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strADDRIDList)," AND BADDR_ID NOT IN (" & strADDRIDList & ")") & _
			" AND LangID IN (-1," & StringIf(bInsertEnglish,LANG_ENGLISH) & StringIf(bInsertEnglish And bInsertFrench,",") & StringIf(bInsertEnglish,LANG_ENGLISH) & ")"
		.Execute
	End With

End Sub
'***************************************
' End Sub processBillingAddressC
'***************************************

'*-------------------------------------*
' End Billing Address Import Functions (A,B,C)
'*-------------------------------------*

'*-------------------------------------*
' Begin Bus Routes Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportBusRoute, rsImportBusRoute, _
	cmdImportBusRouteD, _
	strBRIDList, strBRIDCon

Sub processBusRoutesA()
	Set cmdImportBusRoute = Server.CreateObject("ADODB.Command")
	Set rsImportBusRoute = Server.CreateObject("ADODB.Recordset")

	With cmdImportBusRoute
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_BusRoutes_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@RouteNumber", adVarChar, adParamInput, 20)
		.Parameters.Append .CreateParameter("@RouteNameEn", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@RouteNameFr", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@MunicipalityE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@MunicipalityF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@BR_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportBusRoute
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportBusRouteD = Server.CreateObject("ADODB.Command")

	With cmdImportBusRouteD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processBusRoutesB()
	cmdImportBusRoute.Parameters("@NUM").Value = fldNUM
	strBRIDList = vbNullString
	strBRIDCon = vbNullString
End Sub

Sub processBusRoutesC()
	Dim xmlBusRouteNode, _
		strRouteNumber, _
		strRouteNameE, strRouteNameF, _
		strMunicipalityE, strMunicipalityF

	makeCICRecordCheck()

	For Each xmlBusRouteNode in xmlChildNode.childNodes
		strRouteNumber = xmlBusRouteNode.getAttribute("NO")
		If bInsertEnglish Then
			strRouteNameE = xmlBusRouteNode.getAttribute("V")
			strMunicipalityE = xmlBusRouteNode.getAttribute("MUN")
		End If
		If bInsertFrench Then
			strRouteNameE = Nz(xmlBusRouteNode.getAttribute("V"),xmlBusRouteNode.getAttribute("VF"))
			strMunicipalityE = Nz(xmlBusRouteNode.getAttribute("MUN"),xmlBusRouteNode.getAttribute("MUNF"))
		End If

		With cmdImportBusRoute
			.Parameters("@RouteNumber").Value = Nz(strRouteNumber,Null)
			.Parameters("@RouteNameEn").Value = Nz(strRouteNameE,Null)
			.Parameters("@RouteNameFr").Value = Nz(strRouteNameF,Null)
			.Parameters("@MunicipalityE").Value = Nz(strMunicipalityE,Null)
			.Parameters("@MunicipalityF").Value = Nz(strMunicipalityF,Null)
		End With

		Set rsImportBusRoute = cmdImportBusRoute.Execute

		With rsImportBusRoute
			Set rsImportBusRoute = .NextRecordset
			If Not Nl(cmdImportBusRoute.Parameters("@BR_ID")) Then
				strBRIDList = strBRIDList & strBRIDCon & cmdImportBusRoute.Parameters("@BR_ID")
				strBRIDCon = ","
			Else
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & StringIf(Not Nl(strRouteNumber),"(" & strRouteNumber & ") ") & _
					Nz(strRouteNameE,Nz(strRouteNameF,vbNullString)) & " " & Nz(strMunicipalityE,Nz(strMunicipalityF,vbNullString)))
			End If
		End With
	Next

	With cmdImportBusRouteD
		.CommandText = "DELETE FROM CIC_BT_BR WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strBRIDList)," AND BR_ID NOT IN (" & strBRIDList & ")")
		.Execute
	End With
End Sub

'*-------------------------------------*
' End Bus Routes Import Functions (A,B,C)
'*-------------------------------------*

'*-------------------------------------*
' Begin CC License Info Import Function
'*-------------------------------------*
Sub processCCLicenseInfo()
	Call processCCRField("LICENSE_NUMBER","NO",FTYPE_TEXT)
	Call processCCRField("LICENSE_RENEWAL","DATE",FTYPE_DATE)
	Call processCCRField("LC_TOTAL","TOT",FTYPE_NUMBER)
	Call processCCRField("LC_INFANT","INF",FTYPE_NUMBER)
	Call processCCRField("LC_TODDLER","TOD",FTYPE_NUMBER)
	Call processCCRField("LC_PRESCHOOL","PRE",FTYPE_NUMBER)
	Call processCCRField("LC_KINDERGARTEN","KIN",FTYPE_NUMBER)
	Call processCCRField("LC_SCHOOLAGE","SCH",FTYPE_NUMBER)

	Call processCCRDField("LC_NOTES","N",FTYPE_TEXT)
End Sub
'*-------------------------------------*
' End CC License Info Import Function
'*-------------------------------------*

'*-------------------------------------*
' Begin Certification Import Functions
'*-------------------------------------*
Dim cmdImportCertification, rsImportCertification

Sub processCertificationA()
	Set cmdImportCertification = Server.CreateObject("ADODB.Command")
	Set rsImportCertification = Server.CreateObject("ADODB.Recordset")

	With cmdImportCertification
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Certification_Check"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@CertificationE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@CertificationF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@CRT_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportCertification
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processCertificationB()
	Dim strCertificationE, strCertificationF

	If bInsertEnglish Then
		strCertificationE = xmlChildNode.getAttribute("V")
	End If
	If bInsertFrench Then
		strCertificationF = Nz(xmlChildNode.getAttribute("VF"),xmlChildNode.getAttribute("V"))
	End If

	If Nl(strCertificationE) And Nl(strCertificationF) Then
		Call dicTableList("CIC").processField("CERTIFIED",Null,"NULL",True,FTYPE_NUMBER)
	Else
		With cmdImportCertification
			.Parameters("@CertificationE") = Nz(strCertificationE,Null)
			.Parameters("@CertificationF") = Nz(strCertificationF,Null)
		End With

		Set rsImportCertification = cmdImportCertification.Execute

		With rsImportCertification
			Set rsImportCertification = .NextRecordset
			If Nl(cmdImportCertification.Parameters("@CRT_ID")) Then
				Call dicTableList("CIC").processField("CERTIFIED",Null,"NULL",True,FTYPE_NUMBER)
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & Nz(strCertificationE,strCertificationF))
			Else
				Call dicTableList("CIC").processField("CERTIFIED",Null,cmdImportCertification.Parameters("@CRT_ID"),True,FTYPE_NUMBER)
			End If
		End With
	End If
End Sub

'*-------------------------------------*
' End Certification Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Contact Import Functions (GBL, CIC)
'*-------------------------------------*

'***************************************
' Begin Sub processContactA
'	Creates a command object for updating the contact data
'***************************************
Dim cmdImportContact

Sub processContactA()
	Set cmdImportContact = Server.CreateObject("ADODB.Command")

	With cmdImportContact
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Contact_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@HAS_ENGLISH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@HAS_FRENCH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@ContactType", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@Contacts", adVarWChar, adParamInput, -1)
	End With
End Sub
'***************************************
' End Sub processContactA
'***************************************

'***************************************
' Begin Sub processContactB
'	Reset values for the current record
'***************************************
Sub processContactB()
	cmdImportContact.Parameters("@NUM").Value = fldNUM
	cmdImportContact.Parameters("@HAS_ENGLISH").Value = IIf(bInsertEnglish,SQL_TRUE,SQL_FALSE)
	cmdImportContact.Parameters("@HAS_FRENCH").Value = IIf(bInsertFrench,SQL_TRUE,SQL_FALSE)
End Sub
'***************************************
' End Sub processContactB
'***************************************

'***************************************
' Begin Sub processContactC
'	Update the contact data for the given record.
'***************************************
Sub processContactC()
	cmdImportContact.Parameters("@ContactType").Value = strImportFld
	cmdImportContact.Parameters("@Contacts").Value = Nz(xmlChildNode.xml,Null)
	cmdImportContact.Execute
End Sub
'***************************************
' End Sub processContactC
'***************************************

Sub processSourceField()
	Call processGBLDField("SOURCE_NAME","NM",FTYPE_TEXT)
	Call processGBLDField("SOURCE_TITLE","TTL",FTYPE_TEXT)
	Call processGBLDField("SOURCE_ORG","ORG",FTYPE_TEXT)
	Call processGBLDField("SOURCE_PHONE","PHN",FTYPE_TEXT)
	Call processGBLDField("SOURCE_FAX","FAX",FTYPE_TEXT)
	Call processGBLDField("SOURCE_EMAIL","EML",FTYPE_TEXT)
	Call processGBLDField("SOURCE_BUILDING","BLD",FTYPE_TEXT)
	Call processGBLDField("SOURCE_ADDRESS","ADDR",FTYPE_TEXT)
	Call processGBLDField("SOURCE_CITY","CTY",FTYPE_TEXT)
	Call processGBLDField("SOURCE_PROVINCE","PRV",FTYPE_TEXT)
	Call processGBLDField("SOURCE_POSTAL_CODE","PC",FTYPE_TEXT)
End Sub

'*-------------------------------------*
' End Contact Import Functions (GBL, CIC)
'*-------------------------------------*

'*-------------------------------------*
' Begin Contract Signature Import Functions
'*-------------------------------------*

'***************************************
' Begin Sub processContractSignatureA
'	Creates a command object for updating the contact data
'***************************************
Dim cmdImportContractSignature

Sub processContractSignatureA()
	Set cmdImportContractSignature = Server.CreateObject("ADODB.Command")

	With cmdImportContractSignature
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_ContractSignature_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@ContractSignatures", adLongVarChar, adParamInput, -1)
	End With
End Sub
'***************************************
' End Sub processContractSignatureA
'***************************************

'***************************************
' Begin Sub processContractSignatureB
'	Reset values for the current record
'***************************************
Sub processContractSignatureB()
	cmdImportContractSignature.Parameters("@NUM").Value = fldNUM
End Sub
'***************************************
' End Sub processContractSignatureB
'***************************************

'***************************************
' Begin Sub processContractSignatureC
'	Update the contact data for the given record.
'***************************************
Sub processContractSignatureC()
	cmdImportContractSignature.Parameters("@ContractSignatures").Value = Nz(xmlChildNode.xml,Null)
	cmdImportContractSignature.Execute
End Sub
'***************************************
' End Sub processContractSignatureC
'***************************************

'*-------------------------------------*
' End Contract Signature Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Deletion Date Import Function
'*-------------------------------------*

Dim strDeletedByE, strDeletedByF, _
	dDeletionE, dDeletionF

Sub processDeletionDate()
	dDeletionE = xmlChildNode.getAttribute("V")
	dDeletionF = xmlChildNode.getAttribute("VF")

	If fldDeletedConflict.Value = CNF_TAKE_NEW Or Nl(fldNUME.Value) Then
		Call dicTableList("GBLE").processField("DELETION_DATE", Null, dDeletionE, True, FTYPE_DATE)
		If Nl(dDeletionE) Then
			Call dicTableList("GBLE").processField("DELETED_BY", Null, vbNullString, True, FTYPE_TEXT)
		Else
			Call dicTableList("GBLE").processField("DELETED_BY", Null, Nz(strDeletedByE, "(Import)"), True, FTYPE_TEXT)
		End If
	End If

	If fldDeletedConflict.Value = CNF_TAKE_NEW Or Nl(fldNUMF.Value) Then
		Call dicTableList("GBLF").processField("DELETION_DATE", Null, dDeletionF, True, FTYPE_DATE)
		If Nl(dDeletionF) Then
			Call dicTableList("GBLF").processField("DELETED_BY", Null, vbNullString, True, FTYPE_TEXT)
		Else
			Call dicTableList("GBLF").processField("DELETED_BY", Null, Nz(strDeletedByF, "(Import)"), True, FTYPE_TEXT)
		End If
	End If
End Sub

Sub processDeletedByA()
	strDeletedByE = vbNullString
	StrDeletedByF = vbNullString
End Sub

Sub processDeletedByB()
	strDeletedByE = xmlChildNode.getAttribute("V")
	strDeletedByF = xmlChildNode.getAttribute("VF")
End Sub

'*-------------------------------------*
' End Deletion Date Import Function
'*-------------------------------------*

'*-------------------------------------*
' Begin Distribution Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportDistribution, rsImportDistribution, _
	strImportDistributionList, _
	cmdImportDistributionD, _
	strDSTIDList, strDSTIDCon

Sub processDistributionA()
	Dim cmdImportDistributionList, rsImportDistributionList
	Set cmdImportDistributionList = Server.CreateObject("ADODB.Command")
	Set rsImportDistributionList = Server.CreateObject("ADODB.Recordset")

	With cmdImportDistributionList
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "SELECT dbo.fn_CIC_ImportEntry_Distributions(" & fldEFID.Value & ") AS DistributionList"
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With

	With rsImportDistributionList
		.Open cmdImportDistributionList
		If Not .EOF Then
			strImportDistributionList = .Fields("DistributionList")
		End If
		.Close
	End With

	Set rsImportDistributionList = Nothing
	Set cmdImportDistributionList = Nothing

	Set cmdImportDistribution = Server.CreateObject("ADODB.Command")
	Set rsImportDistribution = Server.CreateObject("ADODB.Recordset")

	With cmdImportDistribution
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Distribution_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 20)
		.Parameters.Append .CreateParameter("@DST_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportDistribution
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportDistributionD = Server.CreateObject("ADODB.Command")

	With cmdImportDistributionD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processDistributionB()
	cmdImportDistribution.Parameters("@NUM") = fldNUM
	strDSTIDList = vbNullString
	strDSTIDCon = vbNullString
End Sub

Sub processDistributionC()
	Dim xmlDistributionNode, strDistributionCode

	makeCICRecordCheck()

	For Each xmlDistributionNode in xmlChildNode.childNodes
		strDistributionCode = xmlDistributionNode.getAttribute("V")

		cmdImportDistribution.Parameters("@Code") = strDistributionCode

		Set rsImportDistribution = cmdImportDistribution.Execute

		With rsImportDistribution
			Set rsImportDistribution = .NextRecordset
			If Not Nl(cmdImportDistribution.Parameters("@DST_ID")) Then
				strDSTIDList = strDSTIDList & strDSTIDCon & cmdImportDistribution.Parameters("@DST_ID")
				strDSTIDCon = ","
			Else
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & strDistributionCode)
			End If
		End With

	Next

	If Not Nl(strImportDistributionList) Then
		With cmdImportDistributionD
			.CommandText = "DELETE FROM CIC_BT_DST WHERE NUM=" & strQNUM & _
				" AND DST_ID IN (" & strImportDistributionList & ")" & _
				StringIf(Not Nl(strDSTIDList)," AND DST_ID NOT IN (" & strDSTIDList & ")")
			.Execute
		End With
	End If
End Sub

'*-------------------------------------*
' End Distribution Import Functions (A,B,C)
'*-------------------------------------*

'*-------------------------------------*
' Begin Eligibility Import Functions
'*-------------------------------------*

Sub processEligibility()
	Call processCICField("MIN_AGE","MIN_AGE",FTYPE_NUMBER)
	Call processCICField("MAX_AGE","MAX_AGE",FTYPE_NUMBER)
	Call processCICDField("ELIGIBILITY_NOTES","N",FTYPE_TEXT)
End Sub

'*-------------------------------------*
' End Eligibility Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Employees Import Functions
'*-------------------------------------*
Sub processEmployeesField()
	Call processCICField("EMPLOYEES_FT","FT",FTYPE_NUMBER)
	Call processCICField("EMPLOYEES_PT","PT",FTYPE_NUMBER)
	Call processCICField("EMPLOYEES_TOTAL","TTL",FTYPE_NUMBER)
End Sub
'*-------------------------------------*
' End Employees Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Extra Text Import Functions
'*-------------------------------------*
'***************************************
' Begin Sub processExtraTextA
'	Creates a command object for updating the ExtraText data
'***************************************
Dim cmdImportExtraText, rsImportExtraText

Sub processExtraTextA()
	Set cmdImportExtraText = Server.CreateObject("ADODB.Command")
	Set rsImportExtraText = Server.CreateObject("ADODB.Recordset")

	With cmdImportExtraText
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_ExtraText_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@HAS_ENGLISH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@HAS_FRENCH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@ExtraTextType", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@ExtraTextE", adVarWChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@ExtraTextF", adVarWChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@FieldID", adInteger, adParamOutput, 4)
	End With

	With rsImportCertification
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub
'***************************************
' End Sub processExtraTextA
'***************************************

'***************************************
' Begin Sub processExtraTextB
'	Reset values for the current record
'***************************************
Sub processExtraTextB()
	cmdImportExtraText.Parameters("@NUM").Value = fldNUM
	cmdImportExtraText.Parameters("@HAS_ENGLISH").Value = IIf(bInsertEnglish,SQL_TRUE,SQL_FALSE)
	cmdImportExtraText.Parameters("@HAS_FRENCH").Value = IIf(bInsertFrench,SQL_TRUE,SQL_FALSE)
End Sub
'***************************************
' End Sub processExtraTextB
'***************************************

'***************************************
' Begin Sub processExtraTextC
'	Update the ExtraText data for the given record.
'***************************************
Sub processExtraTextC()
	Dim strExtraFieldType, strExtraTextE, strExtraTextF

	Call makeCICRecordCheck()

	strExtraFieldType = "EXTRA_" & xmlChildNode.getAttribute("FLD")

	If bInsertEnglish Then
		strExtraTextE = xmlChildNode.getAttribute("V")
	End If
	If bInsertFrench Then
		strExtraTextF = Nz(xmlChildNode.getAttribute("VF"),xmlChildNode.getAttribute("V"))
	End If

	With cmdImportExtraText
		.Parameters("@ExtraTextType").Value = strExtraFieldType
		.Parameters("@ExtraTextE") = Nz(strExtraTextE,Null)
		.Parameters("@ExtraTextF") = Nz(strExtraTextF,Null)
	End With

		Set rsImportExtraText = cmdImportExtraText.Execute

		With rsImportExtraText
			Set rsImportExtraText = .NextRecordset
			If Nl(cmdImportExtraText.Parameters("@FieldID")) Then
				Call addImportNote("[" & strExtraFieldType & "] " & TXT_UNKNOWN_FIELD)
			End If
		End With
End Sub
'***************************************
' End Sub processExtraTextC
'***************************************
'*-------------------------------------*
' End Extra Text Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Extra Date Import Functions
'*-------------------------------------*
'***************************************
' Begin Sub processExtraDateA
'	Creates a command object for updating the ExtraDate data
'***************************************
Dim cmdImportExtraDate, rsImportExtraDate

Sub processExtraDateA()
	Set cmdImportExtraDate = Server.CreateObject("ADODB.Command")
	Set rsImportExtraDate = Server.CreateObject("ADODB.Recordset")

	With cmdImportExtraDate
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_ExtraDate_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@ExtraDateType", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@ExtraDate", adDate, adParamInput)
		.Parameters.Append .CreateParameter("@FieldID", adInteger, adParamOutput, 4)
	End With

	With rsImportCertification
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub
'***************************************
' End Sub processExtraDateA
'***************************************

'***************************************
' Begin Sub processExtraDateB
'	Reset values for the current record
'***************************************
Sub processExtraDateB()
	cmdImportExtraDate.Parameters("@NUM").Value = fldNUM
End Sub
'***************************************
' End Sub processExtraDateB
'***************************************

'***************************************
' Begin Sub processExtraDateC
'	Update the ExtraDate data for the given record.
'***************************************
Sub processExtraDateC()
	'On Error Resume Next

	Dim strExtraFieldType, strExtraDate

	Call makeCICRecordCheck()

	strExtraFieldType = "EXTRA_DATE_" & xmlChildNode.getAttribute("FLD")

	strExtraDate = DateTimeStringFromXML(xmlChildNode.getAttribute("V"), False)

	With cmdImportExtraDate
		.Parameters("@ExtraDateType").Value = strExtraFieldType
		.Parameters("@ExtraDate").Value = strExtraDate
	End With

		Set rsImportExtraDate = cmdImportExtraDate.Execute

		With rsImportExtraDate
			Set rsImportExtraDate = .NextRecordset
			If Nl(cmdImportExtraDate.Parameters("@FieldID")) Then
				Call addImportNote("[" & strExtraFieldType & "] " & TXT_UNKNOWN_FIELD)
			End If
		End With
End Sub
'***************************************
' End Sub processExtraDateC
'***************************************
'*-------------------------------------*
' End Extra Date Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Extra Email Import Functions
'*-------------------------------------*
'***************************************
' Begin Sub processExtraEmailA
'	Creates a command object for updating the ExtraEmail data
'***************************************
Dim cmdImportExtraEmail, rsImportExtraEmail

Sub processExtraEmailA()
	Set cmdImportExtraEmail = Server.CreateObject("ADODB.Command")
	Set rsImportExtraEmail = Server.CreateObject("ADODB.Recordset")

	With cmdImportExtraEmail
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_ExtraEmail_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@HAS_ENGLISH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@HAS_FRENCH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@ExtraEmailType", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@ExtraEmailE", adVarWChar, adParamInput, 60)
		.Parameters.Append .CreateParameter("@ExtraEmailF", adVarWChar, adParamInput, 60)
		.Parameters.Append .CreateParameter("@FieldID", adInteger, adParamOutput, 4)
	End With

	With rsImportCertification
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub
'***************************************
' End Sub processExtraEmailA
'***************************************

'***************************************
' Begin Sub processExtraEmailB
'	Reset values for the current record
'***************************************
Sub processExtraEmailB()
	cmdImportExtraEmail.Parameters("@NUM").Value = fldNUM
	cmdImportExtraEmail.Parameters("@HAS_ENGLISH").Value = IIf(bInsertEnglish,SQL_TRUE,SQL_FALSE)
	cmdImportExtraEmail.Parameters("@HAS_FRENCH").Value = IIf(bInsertFrench,SQL_TRUE,SQL_FALSE)
End Sub
'***************************************
' End Sub processExtraEmailB
'***************************************

'***************************************
' Begin Sub processExtraEmailC
'	Update the ExtraEmail data for the given record.
'***************************************
Sub processExtraEmailC()
	Dim strExtraFieldType, strExtraEmailE, strExtraEmailF

	Call makeCICRecordCheck()

	strExtraFieldType = "EXTRA_EMAIL_" & xmlChildNode.getAttribute("FLD")

	If bInsertEnglish Then
		strExtraEmailE = xmlChildNode.getAttribute("V")
	End If
	If bInsertFrench Then
		strExtraEmailF = Nz(xmlChildNode.getAttribute("VF"),xmlChildNode.getAttribute("V"))
	End If

	With cmdImportExtraEmail
		.Parameters("@ExtraEmailType").Value = strExtraFieldType
		.Parameters("@ExtraEmailE") = Nz(strExtraEmailE,Null)
		.Parameters("@ExtraEmailF") = Nz(strExtraEmailF,Null)
	End With

		Set rsImportExtraEmail = cmdImportExtraEmail.Execute

		With rsImportExtraEmail
			Set rsImportExtraEmail = .NextRecordset
			If Nl(cmdImportExtraEmail.Parameters("@FieldID")) Then
				Call addImportNote("[" & strExtraFieldType & "] " & TXT_UNKNOWN_FIELD)
			End If
		End With
End Sub
'***************************************
' End Sub processExtraEmailC
'***************************************
'*-------------------------------------*
' End Extra Email Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Extra Radio Import Functions
'*-------------------------------------*
'***************************************
' Begin Sub processExtraRadioA
'	Creates a command object for updating the ExtraRadio data
'***************************************
Dim cmdImportExtraRadio, rsImportExtraRadio

Sub processExtraRadioA()
	Set cmdImportExtraRadio = Server.CreateObject("ADODB.Command")
	Set rsImportExtraRadio = Server.CreateObject("ADODB.Recordset")

	With cmdImportExtraRadio
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_ExtraRadio_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@ExtraRadioType", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@ExtraRadio", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@FieldID", adInteger, adParamOutput, 4)
	End With

	With rsImportCertification
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub
'***************************************
' End Sub processExtraRadioA
'***************************************

'***************************************
' Begin Sub processExtraRadioB
'	Reset values for the current record
'***************************************
Sub processExtraRadioB()
	cmdImportExtraRadio.Parameters("@NUM").Value = fldNUM
End Sub
'***************************************
' End Sub processExtraRadioB
'***************************************

'***************************************
' Begin Sub processExtraRadioC
'	Update the ExtraRadio data for the given record.
'***************************************
Sub processExtraRadioC()
	Dim strExtraFieldType, strExtraRadio

	Call makeCICRecordCheck()

	strExtraFieldType = "EXTRA_RADIO_" & xmlChildNode.getAttribute("FLD")

	strExtraRadio = xmlChildNode.getAttribute("V")

	With cmdImportExtraRadio
		.Parameters("@ExtraRadioType").Value = strExtraFieldType
		.Parameters("@ExtraRadio") = Nz(strExtraRadio,Null)
	End With

		Set rsImportExtraRadio = cmdImportExtraRadio.Execute

		With rsImportExtraRadio
			Set rsImportExtraRadio = .NextRecordset
			If Nl(cmdImportExtraRadio.Parameters("@FieldID")) Then
				Call addImportNote("[" & strExtraFieldType & "] " & TXT_UNKNOWN_FIELD)
			End If
		End With
End Sub
'***************************************
' End Sub processExtraRadioC
'***************************************
'*-------------------------------------*
' End Extra Radio Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Extra WWW Import Functions
'*-------------------------------------*
'***************************************
' Begin Sub processExtraWWWA
'	Creates a command object for updating the ExtraWWW data
'***************************************
Dim cmdImportExtraWWW, rsImportExtraWWW

Sub processExtraWWWA()
	Set cmdImportExtraWWW = Server.CreateObject("ADODB.Command")
	Set rsImportExtraWWW = Server.CreateObject("ADODB.Recordset")

	With cmdImportExtraWWW
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_ExtraWWW_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@HAS_ENGLISH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@HAS_FRENCH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@ExtraWWWType", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@ExtraWWWE", adVarWChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@ExtraWWWF", adVarWChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@FieldID", adInteger, adParamOutput, 4)
	End With

	With rsImportCertification
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub
'***************************************
' End Sub processExtraWWWA
'***************************************

'***************************************
' Begin Sub processExtraWWWB
'	Reset values for the current record
'***************************************
Sub processExtraWWWB()
	cmdImportExtraWWW.Parameters("@NUM").Value = fldNUM
	cmdImportExtraWWW.Parameters("@HAS_ENGLISH").Value = IIf(bInsertEnglish,SQL_TRUE,SQL_FALSE)
	cmdImportExtraWWW.Parameters("@HAS_FRENCH").Value = IIf(bInsertFrench,SQL_TRUE,SQL_FALSE)
End Sub
'***************************************
' End Sub processExtraWWWB
'***************************************

'***************************************
' Begin Sub processExtraWWWC
'	Update the ExtraWWW data for the given record.
'***************************************
Sub processExtraWWWC()
	Dim strExtraFieldType, strExtraWWWE, strExtraWWWF

	Call makeCICRecordCheck()

	strExtraFieldType = "EXTRA_WWW_" & xmlChildNode.getAttribute("FLD")

	If bInsertEnglish Then
		strExtraWWWE = xmlChildNode.getAttribute("V")
		Call makeCICRecordCheckE()
	End If
	If bInsertFrench Then
		strExtraWWWF = Nz(xmlChildNode.getAttribute("VF"),xmlChildNode.getAttribute("V"))
		Call makeCICRecordCheckF()
	End If

	With cmdImportExtraWWW
		.Parameters("@ExtraWWWType").Value = strExtraFieldType
		.Parameters("@ExtraWWWE") = Nz(strExtraWWWE,Null)
		.Parameters("@ExtraWWWF") = Nz(strExtraWWWF,Null)
	End With

		Set rsImportExtraWWW = cmdImportExtraWWW.Execute

		With rsImportExtraWWW
			Set rsImportExtraWWW = .NextRecordset
			If Nl(cmdImportExtraWWW.Parameters("@FieldID")) Then
				Call addImportNote("[" & strExtraFieldType & "] " & TXT_UNKNOWN_FIELD)
			End If
		End With
End Sub
'***************************************
' End Sub processExtraWWWC
'***************************************
'*-------------------------------------*
' End Extra WWW Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin ExtraCheckListA Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportExtraCheckList, rsImportExtraCheckList

Sub processExtraCheckListA()
	Set cmdImportExtraCheckList = Server.CreateObject("ADODB.Command")
	Set rsImportExtraCheckList = Server.CreateObject("ADODB.Recordset")

	With cmdImportExtraCheckList
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_ExtraCheckList_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@FieldName", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@ListXML", adVarWChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@BadValues", adVarChar, adParamOutput, 5000)
	End With

	With rsImportExtraCheckList
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processExtraCheckListB()
	cmdImportExtraCheckList.Parameters("@NUM").Value = fldNUM
End Sub

Sub processExtraCheckListC()
	Dim strExtraFieldType

	strExtraFieldType = "EXTRA_CHECKLIST_" & xmlChildNode.getAttribute("FLD")

	With cmdImportExtraCheckList
		.Parameters("@FieldName") = strExtraFieldType
		.Parameters("@ListXML") = Nz(xmlChildNode.xml,Null)
	End With

	Set rsImportExtraCheckList = cmdImportExtraCheckList.Execute

	With rsImportExtraCheckList
		Set rsImportExtraCheckList = .NextRecordset
		If Not Nl(cmdImportExtraCheckList.Parameters("@BadValues")) Then
			Call addImportNote("[" & strExtraFieldType & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & cmdImportExtraCheckList.Parameters("@BadValues"))
		End If
	End With
	
End Sub

'*-------------------------------------*
' End Extra CheckList Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Extra DropDown Import Functions
'*-------------------------------------*
Dim cmdImportExtraDropDown, rsImportExtraDropDown

Sub processExtraDropDownA()
	Set cmdImportExtraDropDown = Server.CreateObject("ADODB.Command")
	Set rsImportExtraDropDown = Server.CreateObject("ADODB.Recordset")

	With cmdImportExtraDropDown
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_ExtraDropDown_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@FieldName", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 20)	
		.Parameters.Append .CreateParameter("@ExtraDropDownEn", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@ExtraDropDownFr", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@BadValue", adVarChar, adParamOutput, 200)
	End With

	With rsImportExtraDropDown
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processExtraDropDownB()
	cmdImportExtraDropDown.Parameters("@NUM").Value = fldNUM
End Sub

Sub processExtraDropDownC()
	Dim strExtraFieldType, strExtraDropDownCode, strExtraDropDownEn, strExtraDropDownFr

	strExtraFieldType = "EXTRA_DROPDOWN_" & xmlChildNode.getAttribute("FLD")

	strExtraDropDownCode = xmlChildNode.getAttribute("CD")

	If bInsertEnglish Then
		strExtraDropDownEn = xmlChildNode.getAttribute("V")
	End If
	If bInsertFrench Then
		strExtraDropDownFr = Nz(xmlChildNode.getAttribute("VF"),xmlChildNode.getAttribute("V"))
	End If

	With cmdImportExtraDropDown
		.Parameters("@FieldName") = strExtraFieldType
		.Parameters("@Code") = Nz(strExtraDropDownCode,Null)		
		.Parameters("@ExtraDropDownEn") = Nz(strExtraDropDownEn,Null)
		.Parameters("@ExtraDropDownFr") = Nz(strExtraDropDownFr,Null)
	End With

	Set rsImportExtraDropDown = cmdImportExtraDropDown.Execute

	With rsImportExtraDropDown
		Set rsImportExtraDropDown = .NextRecordset
		If Not Nl(cmdImportExtraDropDown.Parameters("@BadValue")) Then
			Call addImportNote("[" & strExtraFieldType & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & cmdImportExtraDropDown.Parameters("@BadValue"))
		End If
	End With

End Sub

'*-------------------------------------*
' End Extra DropDown Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Fee Import Functions
'*-------------------------------------*

Dim cmdImportFees, rsImportFees, _
	cmdImportFeesD, _
	strFTIDList, strFTIDCon

Sub processFeesA()
	Set cmdImportFees = Server.CreateObject("ADODB.Command")
	Set rsImportFees = Server.CreateObject("ADODB.Recordset")

	With cmdImportFees
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Fees_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@FeeTypeEn", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@FeeTypeFr", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@NotesEn", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@NotesFr", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@FT_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportFees
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportFeesD = Server.CreateObject("ADODB.Command")

	With cmdImportFeesD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processFeesB()
	cmdImportFees.Parameters("@NUM").Value = fldNUM
	strFTIDList = vbNullString
	strFTIDCon = vbNullString
End Sub

Sub processFeesC()
	Dim xmlFeesNode, _
		strFeeTypeE, strFeeTypeF, _
		strFeeNoteE, strFeeNoteF, _
		strFeeNotesE, strFeeNotesF, _
		strNoteConE, strNoteConF

	strFeeNotesE = vbNullString
	strFeeNotesF = vbNullString
	strNoteConE = vbNullString
	strNoteConF = vbNullString

	makeCICRecordCheck()

	If bInsertEnglish Then
		strFeeNotesE = Nz(xmlChildNode.getAttribute("N"),vbNullString)
		If Not Nl(strFeeNotesE) Then
			strNoteConE = " ; "
		End If
	End If
	If bInsertFrench Then
		strFeeNotesF = Nz(xmlChildNode.getAttribute("NF"),vbNullString)
		If Not Nl(strFeeNotesF) Then
			strNoteConF = " ; "
		End If
	End If

	For Each xmlFeesNode in xmlChildNode.childNodes
		If bInsertEnglish Then
			strFeeTypeE = xmlFeesNode.getAttribute("V")
			strFeeNoteE = xmlFeesNode.getAttribute("N")
		End If
		If bInsertFrench Then
			strFeeTypeF = Nz(xmlFeesNode.getAttribute("VF"),xmlFeesNode.getAttribute("V"))
			strFeeNoteF = xmlFeesNode.getAttribute("NF")
		End If

		With cmdImportFees
			.Parameters("@FeeTypeEn").Value = Nz(strFeeTypeE,Null)
			.Parameters("@FeeTypeFr").Value = Nz(strFeeTypeF,Null)
			.Parameters("@NotesEn").Value = Nz(strFeeNoteE,Null)
			.Parameters("@NotesFr").Value = Nz(strFeeNoteF,Null)
		End With

		Set rsImportFees = cmdImportFees.Execute

		With rsImportFees
			Set rsImportFees = .NextRecordset
			If Not Nl(cmdImportFees.Parameters("@FT_ID")) Then
				strFTIDList = strFTIDList & strFTIDCon & cmdImportFees.Parameters("@FT_ID")
				strFTIDCon = ","
			Else
				If bInsertEnglish Then
					strFeeNotesE = strFeeTypeE & _
						IIf(Nl(strFeeNoteE),vbNullString," - " & strFeeNoteE) & _
						strNoteConE & strFeeNotesE
					strNoteConE = " ; "
				End If
				If bInsertFrench Then
					strFeeNotesF = strFeeTypeF & _
						IIf(Nl(strFeeNoteF),vbNullString," - " & strFeeNoteF) & _
						strNoteConF & strFeeNotesF
					strNoteConF = " ; "
				End If
				Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_VALUE_MOVED_TO_NOTES & TXT_COLON & Nz(strFeeTypeE,strFeeTypeF))
			End If
		End With
	Next

	With cmdImportFeesD
		.CommandText = "DELETE FROM CIC_BT_FT WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strFTIDList)," AND FT_ID NOT IN (" & strFTIDList & ")")
		.Execute
	End With

	Call dicTableList("CIC").processField("FEE_ASSISTANCE_AVAILABLE","ASSIST",Null,False,FTYPE_NUMBER)
	Call dicTableList("CICE").processField("FEE_ASSISTANCE_FOR","ASSIST_FOR",Null,False,FTYPE_TEXT)
	Call dicTableList("CICF").processField("FEE_ASSISTANCE_FOR","ASSIST_FOR",Null,False,FTYPE_TEXT)
	Call dicTableList("CICE").processField("FEE_ASSISTANCE_FROM","ASSIST_FROM",Null,False,FTYPE_TEXT)
	Call dicTableList("CICF").processField("FEE_ASSISTANCE_FROM","ASSIST_FROM",Null,False,FTYPE_TEXT)
	Call dicTableList("CICE").processField("FEE_NOTES",Null,strFeeNotesE,True,FTYPE_TEXT)
	Call dicTableList("CICF").processField("FEE_NOTES",Null,strFeeNotesF,True,FTYPE_TEXT)
End Sub

'*-------------------------------------*
' End Fee Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Fiscal Year End Import Functions
'*-------------------------------------*
Dim cmdImportFiscalYearEnd, rsImportFiscalYearEnd

Sub processFiscalYearEndA()
	Set cmdImportFiscalYearEnd = Server.CreateObject("ADODB.Command")
	Set rsImportFiscalYearEnd = Server.CreateObject("ADODB.Recordset")

	With cmdImportFiscalYearEnd
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_FiscalYearEnd_Check"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@FiscalYearEndE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@FiscalYearEndF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@FYE_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportFiscalYearEnd
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processFiscalYearEndB()
	Dim strFiscalYearEndE, strFiscalYearEndF

	If bInsertEnglish Then
		strFiscalYearEndE = xmlChildNode.getAttribute("V")
	End If
	If bInsertFrench Then
		strFiscalYearEndF = Nz(xmlChildNode.getAttribute("VF"),xmlChildNode.getAttribute("V"))
	End If

	If Nl(strFiscalYearEndE) And Nl(strFiscalYearEndF) Then
		Call dicTableList("CIC").processField("FISCAL_YEAR_END",Null,"NULL",True,FTYPE_NUMBER)
	Else
		With cmdImportFiscalYearEnd
			.Parameters("@FiscalYearEndE") = Nz(strFiscalYearEndE,Null)
			.Parameters("@FiscalYearEndF") = Nz(strFiscalYearEndF,Null)
		End With

		Set rsImportFiscalYearEnd = cmdImportFiscalYearEnd.Execute

		With rsImportFiscalYearEnd
			Set rsImportFiscalYearEnd = .NextRecordset
			If Nl(cmdImportFiscalYearEnd.Parameters("@FYE_ID")) Then
				Call dicTableList("CIC").processField("FISCAL_YEAR_END",Null,"NULL",True,FTYPE_NUMBER)
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & Nz(strFiscalYearEndE,strFiscalYearEndF))
			Else
				Call dicTableList("CIC").processField("FISCAL_YEAR_END",Null,cmdImportFiscalYearEnd.Parameters("@FYE_ID"),True,FTYPE_NUMBER)
			End If
		End With
	End If
End Sub

'*-------------------------------------*
' End Fiscal Year End Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Former Org Import Functions
'*-------------------------------------*

Dim cmdImportFormerOrg

Sub processFormerOrgA()
	Set cmdImportFormerOrg = Server.CreateObject("ADODB.Command")

	With cmdImportFormerOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processFormerOrgB()

	Dim xmlFormerOrgNode, _
		strFormerOrgName, _
		strFormerOrgDate, _
		bFormerOrgPublish, _
		intFormerOrgLangID, _
		strFOEList, _
		strFOFList, _
		strFOECon, _
		strFOFCon

	strFOECon = vbNullString
	strFOFCon = vbNullString

	For Each xmlFormerOrgNode in xmlChildNode.childNodes
		strFormerOrgName = xmlFormerOrgNode.getAttribute("V")
		bFormerOrgPublish = Nz(xmlFormerOrgNode.getAttribute("PB"),SQL_FALSE)
		strFormerOrgDate = QsNl(xmlFormerOrgNode.getAttribute("DATE"))
		Select Case xmlFormerOrgNode.getAttribute("LANG")
			Case "E"
				intFormerOrgLangID = LANG_ENGLISH
			Case "F"
				intFormerOrgLangID = LANG_FRENCH
			Case Else
				strFormerOrgName = vbNullString
		End Select

		If Not Nl(strFormerOrgName) Then
			strFormerOrgName = QsN(strFormerOrgName)
			If (intFormerOrgLangID = LANG_ENGLISH And bInsertEnglish) Or (intFormerOrgLangID = LANG_FRENCH And bInsertFrench) Then
				If intFormerOrgLangID = LANG_ENGLISH And bInsertEnglish Then
					strFOEList = strFOEList & strFOECon & strFormerOrgName
					strFOECon = ","
				End If
				If intFormerOrgLangID = LANG_FRENCH And bInsertFrench Then
					strFOFList = strFOFList & strFOFCon & strFormerOrgName
					strFOFCon = ","
				End If
				With cmdImportFormerOrg
					.CommandText = "IF NOT EXISTS(SELECT * FROM GBL_BT_FORMERORG WHERE LangID=" & intFormerOrgLangID & " AND NUM=" & strQNUM & _
						" AND FORMER_ORG=" & strFormerOrgName & ") BEGIN" & _
						" INSERT INTO GBL_BT_FORMERORG (NUM,LangID,FORMER_ORG,DATE_OF_CHANGE,PUBLISH) VALUES (" & strQNUM & "," & intFormerOrgLangID & "," & strFormerOrgName & "," & strFormerOrgDate & "," & bFormerOrgPublish & ") END" & _
						" ELSE BEGIN UPDATE GBL_BT_FORMERORG SET PUBLISH=" & bFormerOrgPublish & _
						" WHERE NUM=" & strQNUM & " AND LangID=" & intFormerOrgLangID & " AND FORMER_ORG=" & strFormerOrgName & _
						" AND (PUBLISH<>" & bFormerOrgPublish & " OR (" & IIf(strFormerOrgDate="NULL","DATE_OF_CHANGE IS NOT NULL","(DATE_OF_CHANGE<>" & strFormerOrgDate & " OR DATE_OF_CHANGE IS NULL)") & ")) END"
					.Execute
				End With
			End If
		End If
	Next

	With cmdImportFormerOrg
		If bInsertEnglish Then
			.CommandText = "DELETE FROM GBL_BT_FORMERORG WHERE LangID=" & LANG_ENGLISH & " AND NUM=" & strQNUM & _
				StringIf(Not Nl(strFOEList)," AND FORMER_ORG NOT IN (" & strFOEList & ")")
			.Execute
		End If
		If bInsertFrench Then
			.CommandText = "DELETE FROM GBL_BT_FORMERORG WHERE LangID=" & LANG_FRENCH & " AND NUM=" & strQNUM & _
				StringIf(Not Nl(strFOFList)," AND FORMER_ORG NOT IN (" & strFOFList & ")")
			.Execute
		End If
	End With

End Sub

'*-------------------------------------*
' End Former Org Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Funding Import Functions
'*-------------------------------------*

Dim cmdImportFunding, rsImportFunding, _
	cmdImportFundingD, _
	strFDIDList, strFDIDCon

Sub processFundingA()
	Set cmdImportFunding = Server.CreateObject("ADODB.Command")
	Set rsImportFunding = Server.CreateObject("ADODB.Recordset")

	With cmdImportFunding
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Funding_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@FundingTypeEn", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@FundingTypeFr", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@NotesEn", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@NotesFr", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@FD_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportFunding
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportFundingD = Server.CreateObject("ADODB.Command")

	With cmdImportFundingD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processFundingB()
	cmdImportFunding.Parameters("@NUM").Value = fldNUM
	strFDIDList = vbNullString
	strFDIDCon = vbNullString
End Sub

Sub processFundingC()
	Dim xmlFundingNode, _
		strFundingTypeE, strFundingTypeF, _
		strFundingNoteE, strFundingNoteF, _
		strFundingNotesE, strFundingNotesF, _
		strNoteConE, strNoteConF

	strFundingNotesE = vbNullString
	strFundingNotesF = vbNullString
	strNoteConE = vbNullString
	strNoteConF = vbNullString

	makeCICRecordCheck()

	If bInsertEnglish Then
		strFundingNotesE = Nz(xmlChildNode.getAttribute("N"),vbNullString)
		If Not Nl(strFundingNotesE) Then
			strNoteConE = " ; "
		End If
	End If
	If bInsertFrench Then
		strFundingNotesF = Nz(xmlChildNode.getAttribute("NF"),vbNullString)
		If Not Nl(strFundingNotesF) Then
			strNoteConF = " ; "
		End If
	End If

	For Each xmlFundingNode in xmlChildNode.childNodes
		If bInsertEnglish Then
			strFundingTypeE = xmlFundingNode.getAttribute("V")
			strFundingNoteE = xmlFundingNode.getAttribute("N")
		End If
		If bInsertFrench Then
			strFundingTypeF = Nz(xmlFundingNode.getAttribute("VF"),xmlFundingNode.getAttribute("V"))
			strFundingNoteF = xmlFundingNode.getAttribute("NF")
		End If

		With cmdImportFunding
			.Parameters("@FundingTypeEn").Value = Nz(strFundingTypeE,Null)
			.Parameters("@FundingTypeFr").Value = Nz(strFundingTypeF,Null)
			.Parameters("@NotesEn").Value = Nz(strFundingNoteE,Null)
			.Parameters("@NotesFr").Value = Nz(strFundingNoteF,Null)
		End With

		Set rsImportFunding = cmdImportFunding.Execute

		With rsImportFunding
			Set rsImportFunding = .NextRecordset
			If Not Nl(cmdImportFunding.Parameters("@FD_ID")) Then
				strFDIDList = strFDIDList & strFDIDCon & cmdImportFunding.Parameters("@FD_ID")
				strFDIDCon = ","
			Else
				If bInsertEnglish Then
					strFundingNotesE = strFundingTypeE & _
						IIf(Nl(strFundingNoteE),vbNullString," - " & strFundingNoteE) & _
						strNoteConE & strFundingNotesE
					strNoteConE = " ; "
				End If
				If bInsertFrench Then
					strFundingNotesF = strFundingTypeF & _
						IIf(Nl(strFundingNoteF),vbNullString," - " & strFundingNoteF) & _
						strNoteConF & strFundingNotesF
					strNoteConF = " ; "
				End If
				Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_VALUE_MOVED_TO_NOTES & TXT_COLON & Nz(strFundingTypeE,strFundingTypeF))
			End If
		End With
	Next

	With cmdImportFundingD
		.CommandText = "DELETE FROM CIC_BT_FD WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strFDIDList)," AND FD_ID NOT IN (" & strFDIDList & ")")
		.Execute
	End With

	Call dicTableList("CICE").processField("FUNDING_NOTES",Null,strFundingNotesE,True,FTYPE_TEXT)
	Call dicTableList("CICF").processField("FUNDING_NOTES",Null,strFundingNotesF,True,FTYPE_TEXT)
End Sub

'*-------------------------------------*
' End Funding Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Geocode Import Functions
'*-------------------------------------*

Sub processGeocode()
	Dim intGeoCodeType, _
		decLat, decLong

	intGeoCodeType = CInt(xmlChildNode.getAttribute("TYPE"))
	decLat = xmlChildNode.getAttribute("LAT")
	If Not Nl(decLat) Then
		decLat = Replace(decLat,",",".")
	End If
	decLong = xmlChildNode.getAttribute("LONG")
	If Not Nl(decLong) Then
		decLong = Replace(decLong,",",".")
	End If

	If intGeoCodeType = GC_BLANK Then
		decLat = Null
		decLong = Null
	End If

	If intGeoCodeType <> GC_BLANK And (Nl(decLat) Or Nl(decLong)) Then
		Call addImportNote("[" & strImportFld & "] " & TXT_INVALID_GEOCODE_INFO & TXT_COLON & intGeoCodeType & ", " & decLat & ", " & decLong)
	Else
		Call dicTableList("GBL").processField("GEOCODE_TYPE",Null,intGeoCodeType,True,FTYPE_NUMBER)
		Call dicTableList("GBL").processField("LATITUDE",Null,decLat,True,FTYPE_NUMBER)
		Call dicTableList("GBL").processField("LONGITUDE",Null,decLong,True,FTYPE_NUMBER)
		Call processGBLDField("GEOCODE_NOTES","N",FTYPE_TEXT)
	End If
End Sub

'*-------------------------------------*
' End Geocode Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Languages Import Functions
'*-------------------------------------*

Dim cmdImportLanguage, rsImportLanguage, _
	strLNIDList, strLNIDCon

Sub processLanguagesA()
	Set cmdImportLanguage = Server.CreateObject("ADODB.Command")

	With cmdImportLanguage
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Language_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@HAS_ENGLISH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@HAS_FRENCH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@Languages", adVarWChar, adParamInput, -1)
	End With

	Exit Sub

	Set rsImportLanguage = Server.CreateObject("ADODB.Recordset")
	With rsImportLanguage
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processLanguagesB()
	cmdImportLanguage.Parameters("@NUM").Value = fldNUM
	cmdImportLanguage.Parameters("@HAS_ENGLISH").Value = IIf(bInsertEnglish,SQL_TRUE,SQL_FALSE)
	cmdImportLanguage.Parameters("@HAS_FRENCH").Value = IIf(bInsertFrench,SQL_TRUE,SQL_FALSE)
End Sub

Sub processLanguagesC()
	Dim xmlLanguageNode, _
		strLanguageNameE, strLanguageNameF, _
		strLanguageNoteE, strLanguageNoteF, _
		strLanguageNotesE, strLanguageNotesF, _
		strNoteConE, strNoteConF

	strLanguageNotesE = vbNullString
	strLanguageNotesF = vbNullString
	strNoteConE = vbNullString
	strNoteConF = vbNullString

	makeCICRecordCheck()

	If bInsertEnglish Then
		strLanguageNotesE = Nz(xmlChildNode.getAttribute("N"),vbNullString)
		If Not Nl(strLanguageNotesE) Then
			strNoteConE = " ; "
		End If
	End If
	If bInsertFrench Then
		strLanguageNotesF = Nz(xmlChildNode.getAttribute("NF"),vbNullString)
		If Not Nl(strLanguageNotesF) Then
			strNoteConF = " ; "
		End If
	End If

	cmdImportLanguage.Parameters("@Languages").Value = Nz(xmlChildNode.xml, Null)
	Set rsImportLanguage = cmdImportLanguage.Execute

	With rsImportLanguage
		While Not .EOF
			Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_VALUE_MOVED_TO_NOTES & TXT_COLON & .Fields("Name"))
			.MoveNext
		Wend
	End With

	Set rsImportLanguage = rsImportLanguage.NextRecordset

	With rsImportLanguage
		While Not .EOF
			strLanguageNameE = .Fields("LanguageEn")
			strLanguageNameF = .Fields("LanguageFr")
			strLanguageNoteE = .Fields("NoteEn")
			strLanguageNoteF = .Fields("NoteFr")

			If bInsertEnglish Then
				strLanguageNotesE = strLanguageNameE & _
					IIf(Nl(strLanguageNoteE),vbNullString," - " & strLanguageNoteE) & _
					strNoteConE & strLanguageNotesE
				strNoteConE = " ; "
			End If
			If bInsertFrench Then
				strLanguageNotesF = strLanguageNameF & _
					IIf(Nl(strLanguageNoteF),vbNullString," - " & strLanguageNoteF) & _
					strNoteConF & strLanguageNotesF
				strNoteConF = " ; "
			End If
			Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_VALUE_MOVED_TO_NOTES & TXT_COLON & Nz(strLanguageNameE,strLanguageNameF))
			.MoveNext
		Wend
	End With

	Call dicTableList("CICE").processField("LANGUAGE_NOTES",Null,strLanguageNotesE,True,FTYPE_TEXT)
	Call dicTableList("CICF").processField("LANGUAGE_NOTES",Null,strLanguageNotesF,True,FTYPE_TEXT)
End Sub

'*-------------------------------------*
' End Languages Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Located In Community Import Functions
'*-------------------------------------*

Dim cmdImportLocatedIn, rsImportLocatedIn

Sub processLocatedInA()
	Set cmdImportLocatedIn = Server.CreateObject("ADODB.Command")
	Set rsImportLocatedIn = Server.CreateObject("ADODB.Recordset")

	With cmdImportLocatedIn
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_LocatedIn_Check"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@CommunityE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@CommunityF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@AuthCommunity", adVarChar, adParamInputOutput, 200)
		.Parameters.Append .CreateParameter("@ProvState", adVarWChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@DefaultProvState", adVarWChar, adParamInput, 2, Nz(g_strDefaultProvState,Null))
		.Parameters.Append .CreateParameter("@Country", adVarWChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@CM_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportLocatedIn
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processLocatedInB()
	Dim strCommunityE, _
		strCommunityF, _
		strAuthCommunity, _
		strProv, strCountry, _
		intCMID

	strAuthCommunity = xmlChildNode.getAttribute("AP")
	strProv = xmlChildNode.getAttribute("PRV")
	strCountry = xmlChildNode.getAttribute("CTRY")
	If bInsertEnglish Then
		strCommunityE = xmlChildNode.getAttribute("V")
	End If
	If bInsertFrench Then
		strCommunityF = Nz(xmlChildNode.getAttribute("VF"),xmlChildNode.getAttribute("V"))
	End If

	If Nl(strCommunityE) And Nl(strCommunityF) Then
		Call dicTableList("GBL").processField("LOCATED_IN_CM",Null,"NULL",True,FTYPE_NUMBER)
	Else
		With cmdImportLocatedIn
			.Parameters("@CommunityE").Value = Nz(strCommunityE,Null)
			.Parameters("@CommunityF").Value = Nz(strCommunityF,Null)
			.Parameters("@AuthCommunity").Value = Nz(strAuthCommunity,Null)
			.Parameters("@ProvState").Value = Nz(strProv,Null)
			.Parameters("@Country").Value = Nz(strCountry,Null)
		End With

		Set rsImportLocatedIn = cmdImportLocatedIn.Execute

		With rsImportLocatedIn
			Set rsImportLocatedIn = .NextRecordset
			intCMID = cmdImportLocatedIn.Parameters("@CM_ID")
		
			If Nl(intCMID) Then
				Call dicTableList("GBL").processField("LOCATED_IN_CM",Null,"NULL",True,FTYPE_NUMBER)
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & IIf(Nl(strAuthCommunity),Nz(strCommunityE,strCommunityF),Nz(strCommunityE,strCommunityF) & StringIf(Not Nl(strAuthCommunity),"/" & strAuthCommunity)))
			Else
				If Not Nl(cmdImportLocatedIn.Parameters("@AuthCommunity")) Then
					Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & Nz(strCommunityE,strCommunityF) & TXT_USED_VALUE & strAuthCommunity)
				End If
				Call dicTableList("GBL").processField("LOCATED_IN_CM",Null,intCMID,True,FTYPE_NUMBER)
			End If
		End With
	End If
End Sub

'*-------------------------------------*
' End Located In Community Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Location Services Import Functions
'*-------------------------------------*

'***************************************
' Begin Sub processOrgLocationServiceA
'	Creates a command object for updating the Org-Location-Service data
'***************************************
Dim cmdImportLocationServices, rsImportLocationServices

Sub processLocationServicesA()
	Set cmdImportLocationServices = Server.CreateObject("ADODB.Command")
	Set rsImportLocationServices = Server.CreateObject("ADODB.Recordset")

	With cmdImportLocationServices
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_LocationServices_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@SourceDbCode", adVarChar, adParamInput, 20)
		.Parameters.Append .CreateParameter("@ServiceNUMs", adVarWChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@BadNUMs", adVarChar, adParamOutput, 8000)
	End With

	With rsImportLocationServices
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub
'***************************************
' End Sub processLocationServicesA
'***************************************

'***************************************
' Begin Sub processLocationServicesB
'	Update the LocationServices data for the given record.
'***************************************
Sub processLocationServicesB()
	Dim strBadVals

	cmdImportLocationServices.Parameters("@NUM").Value = fldNUM
	cmdImportLocationServices.Parameters("@SourceDbCode").Value = Nz(fldSourceDbCode.Value,Null)
	cmdImportLocationServices.Parameters("@ServiceNUMs").Value = Nz(xmlChildNode.xml,Null)

	Set rsImportLocationServices = cmdImportLocationServices.Execute
	Set rsImportLocationServices = rsImportLocationServices.NextRecordset

	strBadVals = cmdImportLocationServices.Parameters("@BadNUMs").Value

	If Not Nl(strBadVals) Then
		Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_INACTIVE_OR_DUPLICATE_VALUE & TXT_COLON & strBadVals)
	End If

End Sub
'***************************************
' End Sub processOrgLocationServiceB
'***************************************

'*-------------------------------------*
' End Location Services Import Functions

'*-------------------------------------*
' Begin MembershipType Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportMembershipType, rsImportMembershipType, _
	cmdImportMembershipTypeD, _
	strMTIDList, strMTIDCon

Sub processMembershipTypeA()
	Set cmdImportMembershipType = Server.CreateObject("ADODB.Command")
	Set rsImportMembershipType = Server.CreateObject("ADODB.Recordset")

	With cmdImportMembershipType

		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_MembershipType_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@MembershipTypeEn", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@MembershipTypeFr", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@MT_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportMembershipType

		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportMembershipTypeD = Server.CreateObject("ADODB.Command")

	With cmdImportMembershipTypeD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processMembershipTypeB()
	cmdImportMembershipType.Parameters("@NUM").Value = fldNUM
	strMTIDList = vbNullString
	strMTIDCon = vbNullString
End Sub

Sub processMembershipTypeC()
	Dim xmlMembershipTypeNode, _
		strMembershipTypeE, strMembershipTypeF

	makeCICRecordCheck()

	For Each xmlMembershipTypeNode in xmlChildNode.childNodes
		If bInsertEnglish Then
			strMembershipTypeE = xmlMembershipTypeNode.getAttribute("V")
		End If
		If bInsertFrench Then
			strMembershipTypeF = Nz(xmlMembershipTypeNode.getAttribute("VF"),xmlMembershipTypeNode.getAttribute("V"))
		End If

		With cmdImportMembershipType

			.Parameters("@MembershipTypeEn").Value = Nz(strMembershipTypeE,Null)
			.Parameters("@MembershipTypeFr").Value = Nz(strMembershipTypeF,Null)
		End With

		Set rsImportMembershipType = cmdImportMembershipType.Execute

		With rsImportMembershipType

			Set rsImportMembershipType = .NextRecordset
			If Not Nl(cmdImportMembershipType.Parameters("@MT_ID")) Then
				strMTIDList = strMTIDList & strMTIDCon & cmdImportMembershipType.Parameters("@MT_ID")
				strMTIDCon = ","
			Else
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & Nz(strMembershipTypeE,strMembershipTypeF))
			End If
		End With
	Next

	With cmdImportMembershipTypeD
		.CommandText = "DELETE FROM CIC_BT_MT WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strMTIDList)," AND MT_ID NOT IN (" & strMTIDList & ")")
		.Execute
	End With

	Call dicTableList("CICE").processField("MEMBERSHIP_NOTES",Null,Nz(xmlChildNode.getAttribute("N"),vbNullString),True,FTYPE_TEXT)
	Call dicTableList("CICF").processField("MEMBERSHIP_NOTES",Null,Nz(xmlChildNode.getAttribute("NF"),vbNullString),True,FTYPE_TEXT)
End Sub

'*-------------------------------------*
' End MembershipType Import Functions (A,B,C)
'*-------------------------------------*

'*-------------------------------------*
' Begin Naics Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportNaics, rsImportNaics, _
	cmdImportNaicsD, _
	strNAICSIDList, strNAICSIDCon

Sub processNaicsA()
	Set cmdImportNaics = Server.CreateObject("ADODB.Command")
	Set rsImportNaics = Server.CreateObject("ADODB.Recordset")

	makeCICRecordCheck()

	With cmdImportNaics
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_NAICS_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 6)
		.Parameters.Append .CreateParameter("@BT_NAICS_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportNaics
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportNaicsD = Server.CreateObject("ADODB.Command")

	With cmdImportNaicsD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processNaicsB()
	cmdImportNaics.Parameters("@NUM").Value = fldNUM
	strNAICSIDList = vbNullString
	strNAICSIDCon = vbNullString
End Sub

Sub processNaicsC()
	Dim xmlNaicsNode, strNaicsCode


	For Each xmlNaicsNode in xmlChildNode.childNodes
		strNaicsCode = xmlNaicsNode.getAttribute("V")

		cmdImportNaics.Parameters("@Code").Value = strNaicsCode
		Set rsImportNaics = cmdImportNaics.Execute

		With rsImportNaics
			Set rsImportNaics = .NextRecordset
			If Not Nl(cmdImportNaics.Parameters("@BT_NAICS_ID")) Then
				strNAICSIDList = strNAICSIDList & strNAICSIDCon & cmdImportNaics.Parameters("@BT_NAICS_ID")
				strNAICSIDCon = ","
			Else
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & strNaicsCode)
			End If
		End With
	Next

	With cmdImportNaicsD
		.CommandText = "DELETE FROM CIC_BT_NC WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strNAICSIDList)," AND BT_NAICS_ID NOT IN (" & strNAICSIDList & ")")
		.Execute
	End With

End Sub

'*-------------------------------------*
' End Naics Import Functions (A,B,C)
'*-------------------------------------*

'*-------------------------------------*
' Begin Non-Public Import Functions
'*-------------------------------------*

Sub processNonPublicField()
	If fldPublicConflict.Value = CNF_TAKE_NEW Or Nl(fldNUME.Value)	Then
		Call dicTableList("GBLE").processField("NON_PUBLIC",Null, Nz(xmlChildNode.getAttribute("V"),SQL_TRUE),True,FTYPE_NUMBER)
	End If
	If fldPublicConflict.Value = CNF_TAKE_NEW Or NL(fldNUMF.Value)	Then
		Call dicTableList("GBLF").processField("NON_PUBLIC",Null, Nz(xmlChildNode.getAttribute("VF"),SQL_TRUE),True,FTYPE_NUMBER)
	End If
End Sub

'*-------------------------------------*
' End Non-Public Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin NUM Check Functions
'*-------------------------------------*

Dim cmdCheckNUM, rsCheckNUM

Const NUM_NULL = 0
Const NUM_EXISTS = 1
Const NUM_DOES_NOT_EXIST = 2
Const NUM_INVALID = 3

Sub NUMExistsConfig()
	Set cmdCheckNUM = Server.CreateObject("ADODB.Command")
	With cmdCheckNUM
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_UCheck_NUM"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append .CreateParameter("@RSN", adInteger, adParamInput, 4, Null)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInputOutput, 8, Null)
		.Parameters.Append .CreateParameter("@EXTERNAL_ID", adVarChar, adParamInput, 50, Null)
		.Parameters.Append .CreateParameter("@SOURCE_DB_CODE", adVarChar, adParamInput, 20, Null)
		.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, Null)
	End With
End Sub

Function NUMExists(ByRef strNUM)
	Dim strExtID

	If Nl(strNUM) Then
		NUMExists = NUM_NULL
	ElseIf Len(strNUM) > 50 Then
		NUMExists = NUM_INVALID
	Else
		If IsNUMType(strNUM) Then
			cmdCheckNUM.Parameters("@NUM") = strNUM
		Else
			strExtID = strNUM
			cmdCheckNUM.Parameters("@EXTERNAL_ID") = strExtID
			cmdCheckNUM.Parameters("@SOURCE_DB_CODE") = fldSourceDbCode.Value
		End If

		Set rsCheckNUM = cmdCheckNUM.Execute
		Set rsCheckNUM = rsCheckNUM.NextRecordset

		If cmdCheckNUM.Parameters("@RETURN_VALUE") = 1 Then
			NUMExists = NUM_EXISTS
			strNUM = cmdCheckNUM.Parameters("@NUM")
			'Response.Write("<br>ID: " & strExtID & ", " & strNUM)
		ElseIf Not IsNUMType(strNUM) Then
			NUMExists = NUM_INVALID
		Else
			NUMExists = NUM_DOES_NOT_EXIST
		End If
	End If
End Function

Sub processOrgNUM()
	Dim strNUM, bNUMExists, bDisplayOrgName

	strNUM = xmlChildNode.getAttribute("V")
	bDisplayOrgName = xmlChildNode.getAttribute("DISPLAY_ORG_NAME")

	bNUMExists = NUMExists(strNUM)
	If bNUMExists = NUM_INVALID Then
		Call addImportNote("[" & strImportFld & "] " & TXT_INVALID_ID & strNUM)
	Else
		If bNUMExists = NUM_DOES_NOT_EXIST Then
			Call addImportNote("[" & strImportFld & "] " & TXT_WARNING & TXT_UNKNOWN_VALUE & " " & strNUM)
			bDisplayOrgName = 0
		End If
		Call dicTableList("GBL").processField("ORG_NUM",Null,strNUM,True,FTYPE_TEXT)
		Call dicTableList("GBL").processField("DISPLAY_ORG_NAME",Null,Nz(bDisplayOrgName,SQL_FALSE),True,FTYPE_NUMBER)
	End If
End Sub

'*-------------------------------------*
' End NUM Check Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Organization Name Import Functions (Lvl 1-5)
'*-------------------------------------*

Sub processOrgNameField(strPublish)
	Call processGBLDField(Null,Null,FTYPE_TEXT)
	If Not Nl(xmlChildNode.getAttribute("PB")) Or Not Nl(xmlChildNode.getAttribute("PBF")) Then
		If Nl(xmlChildNode.getAttribute("PB")) Then
			xmlChildNode.setAttribute("PB") = 0
		End If
		If Nl(xmlChildNode.getAttribute("PBF")) Then
			xmlChildNode.setAttribute("PBF") = 0
		End If
		Call processGBLDField(strPublish,"PB",FTYPE_NUMBER)
	End If
End Sub

'*-------------------------------------*
' End Organization Name Import Functions (Lvl 1-5)
'*-------------------------------------*

'*-------------------------------------*
' Begin Org-Location-Service Import Functions
'*-------------------------------------*

'***************************************
' Begin Sub processOrgLocationServiceA
'	Creates a command object for updating the Org-Location-Service data
'***************************************
Dim cmdImportOrgLocationService

Sub processOrgLocationServiceA()
	Set cmdImportOrgLocationService = Server.CreateObject("ADODB.Command")

	With cmdImportOrgLocationService
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_OrgLocationService_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@Codes", adVarWChar, adParamInput, -1)
	End With
End Sub
'***************************************
' End Sub processOrgLocationServiceA
'***************************************

'***************************************
' Begin Sub processOrgLocationServiceB
'	Update the OrgLocationService data for the given record.
'***************************************
Sub processOrgLocationServiceB()
	cmdImportOrgLocationService.Parameters("@NUM").Value = fldNUM
	cmdImportOrgLocationService.Parameters("@Codes").Value = Nz(xmlChildNode.xml,Null)
	cmdImportOrgLocationService.Execute
End Sub
'***************************************
' End Sub processOrgLocationServiceB
'***************************************

'*-------------------------------------*
' End Org-Location-Service Import Functions
'*-------------------------------------*

'***************************************
' Begin Sub processOtherAddressA
'	Creates a command object for updating the taxonomy data
'***************************************
Dim cmdImportOtherAddressInfo, rsImportOtherAddressInfo, _
	cmdImportOtherAddressInfoD

Sub processOtherAddressA()
	Set cmdImportOtherAddressInfo = Server.CreateObject("ADODB.Command")
	Set cmdImportOtherAddressInfoD = Server.CreateObject("ADODB.Command")

	With cmdImportOtherAddressInfo
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_OtherAddress_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2)
		.Parameters.Append .CreateParameter("@GUID", adGUID, adParamInput, 16)
		.Parameters.Append .CreateParameter("@Title", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@CareOf", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@BoxType", adVarChar, adParamInput, 20)
		.Parameters.Append .CreateParameter("@POBox", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@Building", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@StreetNumber", adVarChar, adParamInput, 30)
		.Parameters.Append .CreateParameter("@Street", adVarChar, adParamInput, 150)
		.Parameters.Append .CreateParameter("@StreetType", adVarChar, adParamInput, 30)
		.Parameters.Append .CreateParameter("@AfterName", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@StreetDir", adVarChar, adParamInput, 2)
		.Parameters.Append .CreateParameter("@Suffix", adVarChar, adParamInput, 150)
		.Parameters.Append .CreateParameter("@City", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@Province", adVarChar, adParamInput, 2)
		.Parameters.Append .CreateParameter("@Country", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@PostalCode", adVarChar, adParamInput, 10)
		.Parameters.Append .CreateParameter("@ADDR_ID", adInteger, adParamOutput, 4)
	End With

	With cmdImportOtherAddressInfoD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub
'***************************************
' End Sub processOtherAddressA
'***************************************

'***************************************
' Begin Sub processOtherAddressB
'	Reset values for the current record
'***************************************
Sub processOtherAddressB()
	cmdImportOtherAddressInfo.Parameters("@NUM").Value = fldNUM
End Sub
'***************************************
' End Sub processOtherAddressB
'***************************************

'***************************************
' Begin Sub processOtherAddressC
'	Update the OtherAddress data for the given record.
'***************************************
Sub processOtherAddressC()
	Dim xmlOtherAddressNode, _
		strOtherAddressGUID, _
		intOtherAddressLangID, _
		strOtherAddressTitle, _
		strOtherAddressCode, _
		strOtherAddressCareOf, _
		strOtherAddressBoxType, _
		strOtherAddressPOBox, _
		strOtherAddressBuilding, _
		strOtherAddressStreetNumber, _
		strOtherAddressStreet, _
		strOtherAddressStreetType, _
		strOtherAddressAfterName, _
		strOtherAddressStreetDir, _
		strOtherAddressSuffix, _
		strOtherAddressCity, _
		strOtherAddressProvince, _
		strOtherAddressCountry, _
		strOtherAddressPostalCode, _
		strADDRIDList, _
		strADDRIDCon

	makeCICRecordCheck()


	For Each xmlOtherAddressNode in xmlChildNode.childNodes
		Select Case xmlOtherAddressNode.getAttribute("LANG")
			Case "E"
				intOtherAddressLangID = LANG_ENGLISH
			Case "F"
				intOtherAddressLangID = LANG_FRENCH
			Case Else
				intOtherAddressLangID = Null
		End Select

		If (intOtherAddressLangID = LANG_ENGLISH And bInsertEnglish) Or (intOtherAddressLangID = LANG_FRENCH And bInsertFrench) Then
			strOtherAddressGUID = xmlOtherAddressNode.getAttribute("GID")
			strOtherAddressTitle = xmlOtherAddressNode.getAttribute("TITLE")
			strOtherAddressCode = xmlOtherAddressNode.getAttribute("CD")
			strOtherAddressCareOf = xmlOtherAddressNode.getAttribute("CO")
			strOtherAddressBoxType = xmlOtherAddressNode.getAttribute("BXTP")
			strOtherAddressPOBox = xmlOtherAddressNode.getAttribute("BOX")
			strOtherAddressBuilding = xmlOtherAddressNode.getAttribute("BLD")
			strOtherAddressStreetNumber = xmlOtherAddressNode.getAttribute("STNUM")
			strOtherAddressStreet = xmlOtherAddressNode.getAttribute("ST")
			strOtherAddressStreetType = xmlOtherAddressNode.getAttribute("STTYPE")
			strOtherAddressAfterName = xmlOtherAddressNode.getAttribute("STTYPEAFTER")
			strOtherAddressStreetDir = xmlOtherAddressNode.getAttribute("STDIR")
			strOtherAddressSuffix = xmlOtherAddressNode.getAttribute("SFX")
			strOtherAddressCity = xmlOtherAddressNode.getAttribute("CTY")
			strOtherAddressProvince = xmlOtherAddressNode.getAttribute("PRV")
			strOtherAddressCountry = xmlOtherAddressNode.getAttribute("CTRY")
			strOtherAddressPostalCode = xmlOtherAddressNode.getAttribute("PC")


			cmdImportOtherAddressInfo.Parameters("@GUID").Value = "{" & strOtherAddressGUID & "}"
			cmdImportOtherAddressInfo.Parameters("@LangID").Value = intOtherAddressLangID
			cmdImportOtherAddressInfo.Parameters("@Title").Value = Nz(strOtherAddressTitle,Null)
			cmdImportOtherAddressInfo.Parameters("@Code").Value = Nz(strOtherAddressCode,Null)
			cmdImportOtherAddressInfo.Parameters("@CareOf").Value = Nz(strOtherAddressCareOf,Null)
			cmdImportOtherAddressInfo.Parameters("@BoxType").Value = Nz(strOtherAddressBoxType,Null)
			cmdImportOtherAddressInfo.Parameters("@POBox").Value = Nz(strOtherAddressPOBox,Null)
			cmdImportOtherAddressInfo.Parameters("@Building").Value = Nz(strOtherAddressBuilding,Null)
			cmdImportOtherAddressInfo.Parameters("@StreetNumber").Value = Nz(strOtherAddressStreetNumber,Null)
			cmdImportOtherAddressInfo.Parameters("@Street").Value = Nz(strOtherAddressStreet,Null)
			cmdImportOtherAddressInfo.Parameters("@StreetType").Value = Nz(strOtherAddressStreetType,Null)
			cmdImportOtherAddressInfo.Parameters("@AfterName").Value = Nz(strOtherAddressAfterName,Null)
			cmdImportOtherAddressInfo.Parameters("@StreetDir").Value = Nz(strOtherAddressStreetDir,Null)
			cmdImportOtherAddressInfo.Parameters("@Suffix").Value = Nz(strOtherAddressSuffix,Null)
			cmdImportOtherAddressInfo.Parameters("@City").Value = Nz(strOtherAddressCity,Null)
			cmdImportOtherAddressInfo.Parameters("@Province").Value = Nz(strOtherAddressProvince,Null)
			cmdImportOtherAddressInfo.Parameters("@Country").Value = Nz(strOtherAddressCountry,Null)
			cmdImportOtherAddressInfo.Parameters("@PostalCode").Value = Nz(strOtherAddressPostalCode,Null)

			Set rsImportOtherAddressInfo = cmdImportOtherAddressInfo.Execute

			With rsImportOtherAddressInfo
				Set rsImportOtherAddressInfo = .NextRecordset
				If Not Nl(cmdImportOtherAddressInfo.Parameters("@ADDR_ID")) Then
					strADDRIDList = strADDRIDList & strADDRIDCon & cmdImportOtherAddressInfo.Parameters("@ADDR_ID")
					strADDRIDCon = ","
				End If
			End With
		End If
	Next

	With cmdImportOtherAddressInfoD
		.CommandText = "DELETE FROM CIC_BT_OTHERADDRESS WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strADDRIDList)," AND ADDR_ID NOT IN (" & strADDRIDList & ")")
		.Execute
	End With

End Sub
'***************************************
' End Sub processOtherAddressC
'***************************************

'*-------------------------------------*
' Begin Payment Terms Import Functions
'*-------------------------------------*
Dim cmdImportPaymentTerms, rsImportPaymentTerms

Sub processPaymentTermsA()
	Set cmdImportPaymentTerms = Server.CreateObject("ADODB.Command")
	Set rsImportPaymentTerms = Server.CreateObject("ADODB.Recordset")

	With cmdImportPaymentTerms
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_PaymentTerms_Check"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@PaymentTermsE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@PaymentTermsF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@PYT_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportPaymentTerms
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processPaymentTermsB()
	Dim strPaymentTermsE, strPaymentTermsF

	If bInsertEnglish Then
		strPaymentTermsE = xmlChildNode.getAttribute("V")
	End If
	If bInsertFrench Then
		strPaymentTermsF = Nz(xmlChildNode.getAttribute("VF"),xmlChildNode.getAttribute("V"))
	End If

	If Nl(strPaymentTermsE) And Nl(strPaymentTermsF) Then
		Call dicTableList("CIC").processField("PAYMENT_TERMS",Null,"NULL",True,FTYPE_NUMBER)
	Else
		With cmdImportPaymentTerms
			.Parameters("@PaymentTermsE") = Nz(strPaymentTermsE,Null)
			.Parameters("@PaymentTermsF") = Nz(strPaymentTermsF,Null)
		End With

		Set rsImportPaymentTerms = cmdImportPaymentTerms.Execute

		With rsImportPaymentTerms
			Set rsImportPaymentTerms = .NextRecordset
			If Nl(cmdImportPaymentTerms.Parameters("@PYT_ID")) Then
				Call dicTableList("CIC").processField("PAYMENT_TERMS",Null,"NULL",True,FTYPE_NUMBER)
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & Nz(strPaymentTermsE,strPaymentTermsF))
			Else
				Call dicTableList("CIC").processField("PAYMENT_TERMS",Null,cmdImportPaymentTerms.Parameters("@PYT_ID"),True,FTYPE_NUMBER)
			End If
		End With
	End If
End Sub

'*-------------------------------------*
' End Payment Terms Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Preferred Currency Import Functions
'*-------------------------------------*

Dim cmdImportPrefCurrency, rsImportPrefCurrency

Sub processPrefCurrencyA()
	Set cmdImportPrefCurrency = Server.CreateObject("ADODB.Command")
	Set rsImportPrefCurrency = Server.CreateObject("ADODB.Recordset")

	With cmdImportPrefCurrency
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Currency_Check"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@Currency", adChar, adParamInput, 3)
		.Parameters.Append .CreateParameter("@CUR_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportPrefCurrency
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processPrefCurrencyB()
	Dim strPrefCurrency

	strPrefCurrency = xmlChildNode.getAttribute("V")

	If Nl(strPrefCurrency) Then
		Call dicTableList("CIC").processField("PREF_CURRENCY",Null,"NULL",True,FTYPE_NUMBER)
	Else
		With cmdImportPrefCurrency
			.Parameters("@Currency") = strPrefCurrency
		End With

		Set rsImportPrefCurrency = cmdImportPrefCurrency.Execute

		With rsImportPrefCurrency
			Set rsImportPrefCurrency = .NextRecordset
			If Nl(cmdImportPrefCurrency.Parameters("@CUR_ID")) Then
				Call dicTableList("CIC").processField("PREF_CURRENCY",Null,"NULL",True,FTYPE_NUMBER)
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & strPrefCurrency)
			Else
				Call dicTableList("CIC").processField("PREF_CURRENCY",Null,cmdImportPrefCurrency.Parameters("@CUR_ID"),True,FTYPE_NUMBER)
			End If
		End With
	End If
End Sub

'*-------------------------------------*
' End Preferred Currency Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Preferred Payment Method Import Functions
'*-------------------------------------*
Dim cmdImportPrefPaymentMethod, rsImportPrefPaymentMethod

Sub processPrefPaymentMethodA()
	Set cmdImportPrefPaymentMethod = Server.CreateObject("ADODB.Command")
	Set rsImportPrefPaymentMethod = Server.CreateObject("ADODB.Recordset")

	With cmdImportPrefPaymentMethod
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_PaymentMethod_Check"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@PaymentMethodE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@PaymentMethodF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@PAY_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportPrefPaymentMethod
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processPrefPaymentMethodB()
	Dim strPaymentMethodE, strPaymentMethodF

	If bInsertEnglish Then
		strPaymentMethodE = xmlChildNode.getAttribute("V")
	End If
	If bInsertFrench Then
		strPaymentMethodF = Nz(xmlChildNode.getAttribute("VF"),xmlChildNode.getAttribute("V"))
	End If

	If Nl(strPaymentMethodE) And Nl(strPaymentMethodF) Then
		Call dicTableList("CIC").processField("PREF_PAYMENT_METHOD",Null,"NULL",True,FTYPE_NUMBER)
	Else
		With cmdImportPrefPaymentMethod
			.Parameters("@PaymentMethodE") = Nz(strPaymentMethodE,Null)
			.Parameters("@PaymentMethodF") = Nz(strPaymentMethodF,Null)
		End With

		Set rsImportPrefPaymentMethod = cmdImportPrefPaymentMethod.Execute

		With rsImportPrefPaymentMethod
			Set rsImportPrefPaymentMethod = .NextRecordset
			If Nl(cmdImportPrefPaymentMethod.Parameters("@PAY_ID")) Then
				Call dicTableList("CIC").processField("PREF_PAYMENT_METHOD",Null,"NULL",True,FTYPE_NUMBER)
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & Nz(strPaymentMethodE,strPaymentMethodF))
			Else
				Call dicTableList("CIC").processField("PREF_PAYMENT_METHOD",Null,cmdImportPrefPaymentMethod.Parameters("@PAY_ID"),True,FTYPE_NUMBER)
			End If
		End With
	End If
End Sub

'*-------------------------------------*
' End Preferred Payment Method Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Publication Import Functions
'*-------------------------------------*

Dim cmdImportPublication, rsImportPublication, _
	strImportPublicationList, _
	cmdImportPublicationD, _
	strPBIDList, strPBIDCon, _
	intPBID, intBTPBID, strPublicationCode

Sub processPublicationA()
	Dim cmdImportPublicationList, rsImportPublicationList
	Set cmdImportPublicationList = Server.CreateObject("ADODB.Command")
	Set rsImportPublicationList = Server.CreateObject("ADODB.Recordset")

	With cmdImportPublicationList
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "SELECT dbo.fn_CIC_ImportEntry_Publications(" & fldEFID.Value & ") AS PublicationList"
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With

	With rsImportPublicationList
		.Open cmdImportPublicationList
		If Not .EOF Then
			strImportPublicationList = .Fields("PublicationList")
		End If
		.Close
	End With

	Set rsImportPublicationList = Nothing
	Set cmdImportPublicationList = Nothing

	Set cmdImportPublication = Server.CreateObject("ADODB.Command")
	Set rsImportPublication = Server.CreateObject("ADODB.Recordset")

	With cmdImportPublication
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Publication_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 20)
		.Parameters.Append .CreateParameter("@DescriptionE", adVarWChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@DescriptionF", adVarWChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@PB_ID", adInteger, adParamOutput, 4)
		.Parameters.Append .CreateParameter("@BT_PB_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportPublication
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportPublicationD = Server.CreateObject("ADODB.Command")

	With cmdImportPublicationD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processPublicationB()
	cmdImportPublication.Parameters("@NUM") = fldNUM
	strPBIDList = vbNullString
	strPBIDCon = vbNullString
End Sub

Sub processPublicationC()
	Dim xmlPublicationNode, _
		strPublicationDescE, strPublicationDescF

	For Each xmlPublicationNode in xmlChildNode.childNodes
		strPublicationCode = xmlPublicationNode.getAttribute("V")
		If bInsertEnglish Then
			strPublicationDescE = xmlPublicationNode.getAttribute("N")
		End If
		If bInsertFrench Then
			strPublicationDescF = xmlPublicationNode.getAttribute("NF")
		End If

		cmdImportPublication.Parameters("@Code") = strPublicationCode
		cmdImportPublication.Parameters("@DescriptionE") = Nz(strPublicationDescE,Null)
		cmdImportPublication.Parameters("@DescriptionF") = Nz(strPublicationDescF,Null)

		Set rsImportPublication = cmdImportPublication.Execute

		With rsImportPublication
			Set rsImportPublication = .NextRecordset
			intPBID = cmdImportPublication.Parameters("@PB_ID")
			intBTPBID = cmdImportPublication.Parameters("@BT_PB_ID")
			If Not Nl(intBTPBID) And Not Nl(intPBID) Then
				strPBIDList = strPBIDList & strPBIDCon & intPBID
				strPBIDCon = ","
				If xmlPublicationNode.childNodes.length > 0 Then
					Call processHeadingB(xmlPublicationNode.firstChild)
				End If
			Else
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & strPublicationCode)
			End If
		End With

	Next

	If Not Nl(strImportPublicationList) Then
		With cmdImportPublicationD
			.CommandText = "DELETE FROM CIC_BT_PB WHERE NUM=" & strQNUM & _
				" AND PB_ID IN (" & strImportPublicationList & ")" & _
				StringIf(Not Nl(strPBIDList)," AND PB_ID NOT IN (" & strPBIDList & ")")
			.Execute
		End With
	End If
End Sub

'*-------------------------------------*
' End Publication Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin General Heading Import Functions
'*-------------------------------------*

Dim cmdImportHeading, rsImportHeading, _
	cmdImportHeadingD, _
	strGHIDList, strGHIDCon

Sub processHeadingA()
	Set cmdImportHeading = Server.CreateObject("ADODB.Command")
	Set rsImportHeading = Server.CreateObject("ADODB.Recordset")

	With cmdImportHeading
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_GeneralHeading_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@PB_ID", adInteger, adParamInput, 4)
		.Parameters.Append .CreateParameter("@BT_PB_ID", adInteger, adParamInput, 4)
		.Parameters.Append .CreateParameter("@GeneralHeadings", adVarWChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@NoMatchHeadings", adVarWChar, adParamOutput, 4000)
		.Parameters.Append .CreateParameter("@NoMatchTaxonomyHeadings", adVarWChar, adParamOutput, 4000)
	End With

	With rsImportHeading
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processHeadingB(xmlHeadingListNode)
	cmdImportHeading.Parameters("@NUM").Value = fldNUM
	cmdImportHeading.Parameters("@PB_ID") = intPBID
	cmdImportHeading.Parameters("@BT_PB_ID") = intBTPBID
	cmdImportHeading.Parameters("@GeneralHeadings") = Nz(xmlHeadingListNode.xml,"<HEADINGS/>")
	Set rsImportHeading = cmdImportHeading.Execute

	With rsImportHeading
		Set rsImportHeading = .NextRecordset
		If Not Nl(cmdImportHeading.Parameters("@NoMatchHeadings")) Then
			Call addImportNote( "[" & strImportFld & Nz(TXT_COLON & strPublicationCode,vbNullString) & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & cmdImportHeading.Parameters("@NoMatchHeadings"))
		End If
		If Not Nl(cmdImportHeading.Parameters("@NoMatchTaxonomyHeadings")) Then
			Call addImportNote( "[" & strImportFld & Nz(TXT_COLON & strPublicationCode,vbNullString) & "] " & TXT_TAXONOMY_INDEXING_DOES_NOT_MATCH & cmdImportHeading.Parameters("@NoMatchTaxonomyHeadings"))
		End If
	End With
End Sub

'*-------------------------------------*
' End Heading Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Record Note Import Functions (A,B,C)
'*-------------------------------------*

'***************************************
' Begin Sub processRecordNoteA
'	Creates a command object for updating the contact data
'***************************************
Dim cmdImportRecordNote

Sub processRecordNoteA()
	Set cmdImportRecordNote = Server.CreateObject("ADODB.Command")

	With cmdImportRecordNote
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_RecordNote_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@HAS_ENGLISH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@HAS_FRENCH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@RecordNoteType", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@RecordNotes", adLongVarWChar, adParamInput, -1)
	End With
End Sub
'***************************************
' End Sub processRecordNoteA
'***************************************

'***************************************
' Begin Sub processRecordNoteB
'	Reset values for the current record
'***************************************
Sub processRecordNoteB()
	cmdImportRecordNote.Parameters("@NUM").Value = fldNUM
	cmdImportRecordNote.Parameters("@HAS_ENGLISH").Value = IIf(bInsertEnglish,SQL_TRUE,SQL_FALSE)
	cmdImportRecordNote.Parameters("@HAS_FRENCH").Value = IIf(bInsertFrench,SQL_TRUE,SQL_FALSE)
End Sub
'***************************************
' End Sub processRecordNoteB
'***************************************

'***************************************
' Begin Sub processRecordNoteC
'	Update the contact data for the given record.
'***************************************
Sub processRecordNoteC(strType)
	cmdImportRecordNote.Parameters("@RecordNoteType").Value = strType
	cmdImportRecordNote.Parameters("@RecordNotes").Value = Nz(xmlChildNode.xml,Null)
	cmdImportRecordNote.Execute
End Sub
'***************************************
' End Sub processRecordNoteC
'***************************************

'*-------------------------------------*
' End Record Note Import Functions (A,B,C)
'*-------------------------------------*

'*-------------------------------------*
' Begin Space Available Import Function
'*-------------------------------------*
Sub processSpaceAvailable()
	Call processCCRField("SPACE_AVAILABLE",Null,FTYPE_NUMBER)
	Call processCCRField("SPACE_AVAILABLE_DATE","DATE",FTYPE_DATE)
	Call processCCRDField("SPACE_AVAILABLE_NOTES","N",FTYPE_TEXT)
End Sub
'*-------------------------------------*
' End Space Available Import Function
'*-------------------------------------*

'*-------------------------------------*
' Begin Quality Import Functions
'*-------------------------------------*

Dim cmdImportQuality, rsImportQuality

Sub processQualityA()
	Set cmdImportQuality = Server.CreateObject("ADODB.Command")
	Set rsImportQuality = Server.CreateObject("ADODB.Recordset")

	With cmdImportQuality
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Quality_Check"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@Quality", adChar, adParamInput, 1)
		.Parameters.Append .CreateParameter("@RQ_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportQuality
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processQualityB()
	Dim strQuality

	strQuality = xmlChildNode.getAttribute("V")

	If Nl(strQuality) Then
		Call dicTableList("CIC").processField("QUALITY",Null,"NULL",True,FTYPE_NUMBER)
	Else
		With cmdImportQuality
			.Parameters("@Quality") = strQuality
		End With

		Set rsImportQuality = cmdImportQuality.Execute

		With rsImportQuality
			Set rsImportQuality = .NextRecordset
			If Nl(cmdImportQuality.Parameters("@RQ_ID")) Then
				Call dicTableList("CIC").processField("QUALITY",Null,"NULL",True,FTYPE_NUMBER)
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & strQuality)
			Else
				Call dicTableList("CIC").processField("QUALITY",Null,cmdImportQuality.Parameters("@RQ_ID"),True,FTYPE_NUMBER)
			End If
		End With
	End If
End Sub

'*-------------------------------------*
' End Quality Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Record Type Import Functions
'*-------------------------------------*

Dim cmdImportRecordType, rsImportRecordType

Sub processRecordTypeA()
	Set cmdImportRecordType = Server.CreateObject("ADODB.Command")
	Set rsImportRecordType = Server.CreateObject("ADODB.Recordset")

	With cmdImportRecordType
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_RecordType_Check"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@RecordType", adChar, adParamInput, 1)
		.Parameters.Append .CreateParameter("@RQ_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportRecordType
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processRecordTypeB()
	Dim strRecordType

	strRecordType = xmlChildNode.getAttribute("V")

	If Nl(strRecordType) Then
		Call dicTableList("CIC").processField("RECORD_TYPE",Null,"NULL",True,FTYPE_NUMBER)
	Else
		With cmdImportRecordType
			.Parameters("@RecordType") = strRecordType
		End With

		Set rsImportRecordType = cmdImportRecordType.Execute

		With rsImportRecordType
			Set rsImportRecordType = .NextRecordset
			If Nl(cmdImportRecordType.Parameters("@RQ_ID")) Then
				Call dicTableList("CIC").processField("RECORD_TYPE",Null,"NULL",True,FTYPE_NUMBER)
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & strRecordType)
			Else
				Call dicTableList("CIC").processField("RECORD_TYPE",Null,cmdImportRecordType.Parameters("@RQ_ID"),True,FTYPE_NUMBER)
			End If
		End With
	End If
End Sub

'*-------------------------------------*
' End Record Type Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin School Escort Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportSchoolEscort, rsImportSchoolEscort, _
	cmdImportSchoolEscortD, _
	strSCHEIDList, strSCHEIDCon

Sub processSchoolEscortA()
	Set cmdImportSchoolEscort = Server.CreateObject("ADODB.Command")
	Set rsImportSchoolEscort = Server.CreateObject("ADODB.Recordset")

	With cmdImportSchoolEscort
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_SchoolEscort_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@SchoolE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@SchoolF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@SchoolBoard", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@NotesEn", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@NotesFr", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@SCH_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportSchoolEscort
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportSchoolEscortD = Server.CreateObject("ADODB.Command")

	With cmdImportSchoolEscortD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processSchoolEscortB()
	cmdImportSchoolEscort.Parameters("@NUM").Value = fldNUM
	strSCHEIDList = vbNullString
	strSCHEIDCon = vbNullString
End Sub

Sub processSchoolEscortC()
	Dim xmlSchoolEscortNode, _
		strSchoolE, strSchoolF, _
		strSchoolBoard, _
		strSchoolEscortNoteE, strSchoolEscortNoteF, _
		strSchoolEscortNotesE, strSchoolEscortNotesF, _
		strNoteConE, strNoteConF

	strSchoolEscortNotesE = vbNullString
	strSchoolEscortNotesF = vbNullString
	strNoteConE = vbNullString
	strNoteConF = vbNullString

	makeCCRRecordCheck()

	If bInsertEnglish Then
		strSchoolEscortNotesE = Nz(xmlChildNode.getAttribute("N"),vbNullString)
		If Not Nl(strSchoolEscortNotesE) Then
			strNoteConE = " ; "
		End If
	End If
	If bInsertFrench Then
		strSchoolEscortNotesF = Nz(xmlChildNode.getAttribute("NF"),vbNullString)
		If Not Nl(strSchoolEscortNotesF) Then
			strNoteConF = " ; "
		End If
	End If

	For Each xmlSchoolEscortNode in xmlChildNode.childNodes
		strSchoolBoard = xmlSchoolEscortNode.getAttribute("BRD")
		If Nl(strSchoolBoard) Then
			strSchoolBoard = Null
		End If

		If bInsertEnglish Then
			strSchoolE = xmlSchoolEscortNode.getAttribute("V")
			strSchoolEscortNoteE = xmlSchoolEscortNode.getAttribute("N")
		End If
		If bInsertFrench Then
			strSchoolF = Nz(xmlSchoolEscortNode.getAttribute("VF"),xmlSchoolEscortNode.getAttribute("V"))
			strSchoolEscortNoteF = xmlSchoolEscortNode.getAttribute("NF")
		End If

		With cmdImportSchoolEscort
			.Parameters("@SchoolE").Value = Nz(strSchoolE,Null)
			.Parameters("@SchoolF").Value = Nz(strSchoolF,Null)
			.Parameters("@SchoolBoard").Value = strSchoolBoard
			.Parameters("@NotesEn").Value = Nz(strSchoolEscortNoteE,Null)
			.Parameters("@NotesFr").Value = Nz(strSchoolEscortNoteF,Null)
		End With

		Set rsImportSchoolEscort = cmdImportSchoolEscort.Execute

		With rsImportSchoolEscort
			Set rsImportSchoolEscort = .NextRecordset
			If Not Nl(cmdImportSchoolEscort.Parameters("@SCH_ID")) Then
				strSCHEIDList = strSCHEIDList & strSCHEIDCon & cmdImportSchoolEscort.Parameters("@SCH_ID")
				strSCHEIDCon = ","
			Else
				If bInsertEnglish Then
					strSchoolEscortNotesE = strSchoolE & _
						IIf(Nl(strSchoolEscortNoteE),vbNullString," - " & strSchoolEscortNoteE) & _
						strNoteConE & strSchoolEscortNotesE
					strNoteConE = " ; "
				End If
				If bInsertFrench Then
					strSchoolEscortNotesF = strSchoolF & _
						IIf(Nl(strSchoolEscortNoteF),vbNullString," - " & strSchoolEscortNoteF) & _
						strNoteConF & strSchoolEscortNotesF
					strNoteConF = " ; "
				End If
				Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_VALUE_MOVED_TO_NOTES & TXT_COLON & Nz(strSchoolE,strSchoolF))
			End If
		End With
	Next

	With cmdImportSchoolEscortD
		.CommandText = "UPDATE CCR_BT_SCH SET Escort=0 WHERE NUM=" & strQNUM & StringIf(Not Nl(strSCHEIDList),"AND SCH_ID NOT IN (" & strSCHEIDList & ")")
		.Execute
	End With

	Call dicTableList("CCRE").processField("SCHOOL_ESCORT_NOTES",Null,strSchoolEscortNotesE,True,FTYPE_TEXT)
	Call dicTableList("CCRF").processField("SCHOOL_ESCORT_NOTES",Null,strSchoolEscortNotesF,True,FTYPE_TEXT)
End Sub

'*-------------------------------------*
' End School Escort Import Functions (A,B,C)
'*-------------------------------------*

'*-------------------------------------*
' Begin Schools In Area Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportSchoolsInArea, rsImportSchoolsInArea, _
	cmdImportSchoolsInAreaD, _
	strSCHAIDList, strSCHAIDCon

Sub processSchoolsInAreaA()
	Set cmdImportSchoolsInArea = Server.CreateObject("ADODB.Command")
	Set rsImportSchoolsInArea = Server.CreateObject("ADODB.Recordset")

	With cmdImportSchoolsInArea
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_SchoolsInArea_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@SchoolE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@SchoolF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@SchoolBoard", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@NotesEn", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@NotesFr", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@SCH_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportSchoolsInArea
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportSchoolsInAreaD = Server.CreateObject("ADODB.Command")

	With cmdImportSchoolsInAreaD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processSchoolsInAreaB()
	cmdImportSchoolsInArea.Parameters("@NUM").Value = fldNUM
	strSCHAIDList = vbNullString
	strSCHAIDCon = vbNullString
End Sub

Sub processSchoolsInAreaC()
	Dim xmlSchoolsInAreaNode, _
		strSchoolE, strSchoolF, _
		strSchoolBoard, _
		strSchoolsInAreaNoteE, strSchoolsInAreaNoteF, _
		strSchoolsInAreaNotesE, strSchoolsInAreaNotesF, _
		strNoteConE, strNoteConF

	strSchoolsInAreaNotesE = vbNullString
	strSchoolsInAreaNotesF = vbNullString
	strNoteConE = vbNullString
	strNoteConF = vbNullString

	makeCCRRecordCheck()

	If bInsertEnglish Then
		strSchoolsInAreaNotesE = Nz(xmlChildNode.getAttribute("N"),vbNullString)
		If Not Nl(strSchoolsInAreaNotesE) Then
			strNoteConE = " ; "
		End If
	End If
	If bInsertFrench Then
		strSchoolsInAreaNotesF = Nz(xmlChildNode.getAttribute("NF"),vbNullString)
		If Not Nl(strSchoolsInAreaNotesF) Then
			strNoteConF = " ; "
		End If
	End If

	For Each xmlSchoolsInAreaNode in xmlChildNode.childNodes
		strSchoolBoard = xmlSchoolsInAreaNode.getAttribute("BRD")
		If Nl(strSchoolBoard) Then
			strSchoolBoard = Null
		End If

		If bInsertEnglish Then
			strSchoolE = xmlSchoolsInAreaNode.getAttribute("V")
			strSchoolsInAreaNoteE = xmlSchoolsInAreaNode.getAttribute("N")
		End If
		If bInsertFrench Then
			strSchoolF = Nz(xmlSchoolsInAreaNode.getAttribute("VF"),xmlSchoolsInAreaNode.getAttribute("V"))
			strSchoolsInAreaNoteF = xmlSchoolsInAreaNode.getAttribute("NF")
		End If

		With cmdImportSchoolsInArea
			.Parameters("@SchoolE").Value = Nz(strSchoolE,Null)
			.Parameters("@SchoolF").Value = Nz(strSchoolF,Null)
			.Parameters("@SchoolBoard").Value = strSchoolBoard
			.Parameters("@NotesEn").Value = Nz(strSchoolsInAreaNoteE,Null)
			.Parameters("@NotesFr").Value = Nz(strSchoolsInAreaNoteF,Null)
		End With

		Set rsImportSchoolsInArea = cmdImportSchoolsInArea.Execute

		With rsImportSchoolsInArea
			Set rsImportSchoolsInArea = .NextRecordset
			If Not Nl(cmdImportSchoolsInArea.Parameters("@SCH_ID")) Then
				strSCHAIDList = strSCHAIDList & strSCHAIDCon & cmdImportSchoolsInArea.Parameters("@SCH_ID")
				strSCHAIDCon = ","
			Else
				If bInsertEnglish Then
					strSchoolsInAreaNotesE = strSchoolE & _
						IIf(Nl(strSchoolsInAreaNoteE),vbNullString," - " & strSchoolsInAreaNoteE) & _
						strNoteConE & strSchoolsInAreaNotesE
					strNoteConE = " ; "
				End If
				If bInsertFrench Then
					strSchoolsInAreaNotesF = strSchoolF & _
						IIf(Nl(strSchoolsInAreaNoteF),vbNullString," - " & strSchoolsInAreaNoteF) & _
						strNoteConF & strSchoolsInAreaNotesF
					strNoteConF = " ; "
				End If
				Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_VALUE_MOVED_TO_NOTES & TXT_COLON & Nz(strSchoolE,strSchoolF))
			End If
		End With
	Next

	With cmdImportSchoolsInAreaD
		.CommandText = "UPDATE CCR_BT_SCH SET InArea=0 WHERE NUM=" & strQNUM & StringIf(Not Nl(strSCHAIDList),"AND SCH_ID NOT IN (" & strSCHAIDList & ")")
		.Execute
	End With

	Call dicTableList("CCRE").processField("SCHOOLS_IN_AREA_NOTES",Null,strSchoolsInAreaNotesE,True,FTYPE_TEXT)
	Call dicTableList("CCRF").processField("SCHOOLS_IN_AREA_NOTES",Null,strSchoolsInAreaNotesF,True,FTYPE_TEXT)
End Sub

'*-------------------------------------*
' End Schools In Area Import Functions (A,B,C)
'*-------------------------------------*

'*-------------------------------------*
' Begin Service Level Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportServiceLevel, rsImportServiceLevel, _
	cmdImportServiceLevelD, _
	strSLIDList, strSLIDCon

Sub processServiceLevelA()
	Set cmdImportServiceLevel = Server.CreateObject("ADODB.Command")
	Set rsImportServiceLevel = Server.CreateObject("ADODB.Recordset")

	With cmdImportServiceLevel
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_ServiceLevel_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@ServiceLevelCode", adInteger, adParamInput, 2)
		.Parameters.Append .CreateParameter("@SL_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportServiceLevel
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportServiceLevelD = Server.CreateObject("ADODB.Command")

	With cmdImportServiceLevelD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processServiceLevelB()
	cmdImportServiceLevel.Parameters("@NUM") = fldNUM
	strSLIDList = vbNullString
	strSLIDCon = vbNullString
End Sub

Sub processServiceLevelC()
	Dim xmlServiceLevelNode, intServiceLevelCode

	makeCICRecordCheck()

	For Each xmlServiceLevelNode in xmlChildNode.childNodes
		intServiceLevelCode = xmlServiceLevelNode.getAttribute("V")

		cmdImportServiceLevel.Parameters("@ServiceLevelCode") = intServiceLevelCode

		Set rsImportServiceLevel = cmdImportServiceLevel.Execute

		With rsImportServiceLevel
			Set rsImportServiceLevel = .NextRecordset
			If Not Nl(cmdImportServiceLevel.Parameters("@SL_ID")) Then
				strSLIDList = strSLIDList & strSLIDCon & cmdImportServiceLevel.Parameters("@SL_ID")
				strSLIDCon = ","
			Else
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & intServiceLevelCode)
			End If
		End With

	Next

	With cmdImportServiceLevelD
		.CommandText = "DELETE FROM CIC_BT_SL WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strSLIDList), " AND SL_ID NOT IN (" & strSLIDList & ")")
		.Execute
	End With
End Sub

'*-------------------------------------*
' End Service Level Import Functions (A,B,C)
'*-------------------------------------*

'*-------------------------------------*
' Begin Social Media Import Functions
'*-------------------------------------*

'***************************************
' Begin Sub processSocialMediaA
'	Creates a command object for updating the Social Media data
'***************************************
Dim cmdImportSocialMedia, rsImportSocialMedia

Sub processSocialMediaA()
	Set cmdImportSocialMedia = Server.CreateObject("ADODB.Command")
	Set rsImportAccessibility = Server.CreateObject("ADODB.Recordset")

	With cmdImportSocialMedia
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_SocialMedia_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@HAS_ENGLISH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@HAS_FRENCH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@SocialMediaXML", adVarWChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@BadTypes", adVarWChar, adParamOutput, 4000)
	End With
End Sub
'***************************************
' End Sub processSocialMediaA
'***************************************

'***************************************
' Begin Sub processSocialMediaB
'	Reset values for the current record
'***************************************
Sub processSocialMediaB()
	cmdImportSocialMedia.Parameters("@NUM").Value = fldNUM
	cmdImportSocialMedia.Parameters("@HAS_ENGLISH").Value = IIf(bInsertEnglish,SQL_TRUE,SQL_FALSE)
	cmdImportSocialMedia.Parameters("@HAS_FRENCH").Value = IIf(bInsertFrench,SQL_TRUE,SQL_FALSE)
End Sub
'***************************************
' End Sub processSocialMediaB
'***************************************

'***************************************
' Begin Sub processSocialMediaC
'	Update the Social Media data for the given record.
'***************************************
Sub processSocialMediaC()
	Dim strBadVals

	cmdImportSocialMedia.Parameters("@SocialMediaXML").Value = Nz(xmlChildNode.xml,Null)
	Set rsImportSocialMedia = cmdImportSocialMedia.Execute

	Set rsImportSocialMedia = rsImportSocialMedia.NextRecordset

	strBadVals = cmdImportSocialMedia.Parameters("@BadTypes").Value

	If Not Nl(strBadVals) Then
		Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_INACTIVE_OR_DUPLICATE_VALUE & TXT_COLON & strBadVals)
	End If
End Sub
'***************************************
' End Sub processSocialMediaC
'***************************************

'*-------------------------------------*
' End Social Media Import Functions
'*-------------------------------------*

'*-------------------------------------*
' Begin Subjects Import Functions (A,B,C)
'*-------------------------------------*
Dim cmdImportSubjects, rsImportSubjects, _
	cmdImportSubjectsD, _
	strSubjIDList, strSubjIDCon

Sub processSubjectsA()
	Set cmdImportSubjects = Server.CreateObject("ADODB.Command")
	Set rsImportSubjects = Server.CreateObject("ADODB.Recordset")

	With cmdImportSubjects
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Subject_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@SubjectTermEn", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@SubjectTermFr", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@Subj_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportSubjects
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportSubjectsD = Server.CreateObject("ADODB.Command")

	With cmdImportSubjectsD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processSubjectsB()
	cmdImportSubjects.Parameters("@NUM").Value = fldNUM
	strSubjIDList = vbNullString
	strSubjIDCon = vbNullString
End Sub

Sub processSubjectsC()
	Dim xmlSubjectNode, _
		strSubjectTermE, strSubjectTermF

	makeCICRecordCheck()

	For Each xmlSubjectNode in xmlChildNode.childNodes
		If bInsertEnglish Then
			strSubjectTermE = xmlSubjectNode.getAttribute("V")
		End If
		If bInsertFrench Then
			strSubjectTermF = Nz(xmlSubjectNode.getAttribute("VF"),xmlSubjectNode.getAttribute("V"))
		End If

		With cmdImportSubjects
			.Parameters("@SubjectTermEn").Value = Nz(strSubjectTermE,Null)
			.Parameters("@SubjectTermFr").Value = Nz(strSubjectTermF,Null)
		End With

		Set rsImportSubjects = cmdImportSubjects.Execute

		With rsImportSubjects
			Set rsImportSubjects = .NextRecordset
			If Not Nl(cmdImportSubjects.Parameters("@Subj_ID")) Then
				strSubjIDList = strSubjIDList & strSubjIDCon & cmdImportSubjects.Parameters("@Subj_ID")
				strSubjIDCon = ","
			Else
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & Nz(strSubjectTermE,strSubjectTermF))
			End If
		End With

	Next

	With cmdImportSubjectsD
		.CommandText = "DELETE FROM CIC_BT_SBJ WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strSubjIDList)," AND Subj_ID NOT IN (" & strSubjIDList & ")") & vbCrLf & _
			"EXEC dbo.sp_CIC_SRCH_THS_u"
		.Execute
	End With
End Sub
'*-------------------------------------*
' End Subjects Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportTaxonomy, rsImportTaxonomy, _
	cmdImportTaxonomyD, _
	strLinkList, strLinkCon

'***************************************
' Begin Sub processTaxonomyA
'	Creates a command object for updating the taxonomy data
'***************************************
Sub processTaxonomyA()
	Set cmdImportTaxonomy = Server.CreateObject("ADODB.Command")
	Set cmdImportTaxonomyD = Server.CreateObject("ADODB.Command")

	With cmdImportTaxonomy
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMTaxonomy_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, "(Import)")
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@CodeList", adLongVarChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@BT_TAX_ID", adInteger, adParamOutput, 4)
	End With

	With cmdImportTaxonomyD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub
'***************************************
' End Sub processTaxonomyA
'***************************************

'***************************************
' Begin Sub processTaxonomyB
'	Reset values for the current record
'***************************************
Sub processTaxonomyB()
	cmdImportTaxonomy.Parameters("@NUM").Value = fldNUM
	strLinkList = vbNullString
	strLinkCon = vbNullString
End Sub
'***************************************
' End Sub processTaxonomyB
'***************************************

'***************************************
' Begin Sub processTaxonomyC
'	Update the Taxonomy data for the given record.
'***************************************
Sub processTaxonomyC()
	Dim xmlTaxLinkNode, _
		xmlTaxCodeNode, _
		strTaxonomyCode, _
		dMod, _
		strModBy, _
		strCodeList, _
		strCodeCon

	strModBy = Nz(xmlChildNode.getAttribute("MODIFIED_BY"),"(Import)")
	dMod = Nz(xmlChildNode.getAttribute("MODIFIED_DATE"),DateString(Date(),False) & " " & Time())

	makeCICRecordCheck()

	'For each Taxonomy Link (set of linked Terms) check if a link set exists in the record
	'that contains all valid Taxonomy terms in the link. If it does exist, fetch the link ID.
	'If it does not exist, create a new Taxonomy link with all valid terms, and fetch the new link ID.
	'Assemble all the link IDs into a list, strLinkList.
	For Each xmlTaxLinkNode in xmlChildNode.childNodes
		'Reset values for this link
		strCodeList = vbNullString
		strCodeCon = vbNullString

		'Assemble the list of Taxonomy Term codes in this link
		For Each xmlTaxCodeNode in xmlTaxLinkNode.childNodes
			'Fetch the current Taxonomy Code. It was already validated by the Schema when the file was loaded.
			strTaxonomyCode = xmlTaxCodeNode.getAttribute("V")
			If Not Nl(strTaxonomyCode) Then
				strCodeList = strCodeList & strCodeCon & strTaxonomyCode
				strCodeCon = ","
			End If
		Next

		'We have the list of all the Terms for this link.
		'If there is at least one Term, find the link (or create a new one) and add the link's ID to the list
		If Not Nl(strCodeList) Then
			Call makeCICRecordCheck()
			'Locate / Add the link for this group of Terms
			With cmdImportTaxonomy
				.Parameters("@CodeList").Value = strCodeList
				Set rsImportTaxonomy = .Execute
				Set rsImportTaxonomy = rsImportTaxonomy.NextRecordset

				'Add the ID to the list of link IDs allowed for this record
				If Not Nl(cmdImportTaxonomy.Parameters("@BT_TAX_ID")) Then
					strLinkList = strLinkList & strLinkCon & cmdImportTaxonomy.Parameters("@BT_TAX_ID")
					strLinkCon = ","
				Else
					Call addImportNote("[" & strImportFld & "] " & TXT_COULD_NOT_ADD_TAXONOMY_CODES & strCodeList)
				End If
			End With
		End If

	Next

	'Update the Taxonomy modified date info
	'Remove from the record all Taxonomy Links that do not either:
	'	a) contain at least one local (non-Authorized) Term
	'	b) appear in the list strLinkList
	With cmdImportTaxonomyD
		.CommandText =	"UPDATE CIC_BaseTable SET TAX_MODIFIED_DATE=" & QsNl(dMod) & ",TAX_MODIFIED_BY=" & QsNl(strModBy) & " WHERE NUM=" & strQNUM & vbCrLf & _
			"IF EXISTS(SELECT * FROM CIC_BT_TAX tl WHERE NUM=" & strQNUM & _
			" AND NOT (EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt INNER JOIN TAX_Term tm ON tlt.Code=tm.Code WHERE BT_TAX_ID=tl.BT_TAX_ID AND tm.Authorized=0)" & _
			IIf(Nl(strLinkList),vbNullString," OR (BT_TAX_ID IN (" & strLinkList & "))") & _
			")) BEGIN" & vbCrLf & _
			"DELETE tl FROM CIC_BT_TAX tl WHERE NUM=" & strQNUM & _
			" AND NOT (EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt INNER JOIN TAX_Term tm ON tlt.Code=tm.Code WHERE BT_TAX_ID=tl.BT_TAX_ID AND tm.Authorized=0)" & _
			IIf(Nl(strLinkList),vbNullString," OR (BT_TAX_ID IN (" & strLinkList & "))") & _
			")" & vbCrLf & _
			"END" & vbCrLf & _
			"EXEC dbo.sp_CIC_SRCH_TAX_u" 
		.Execute
	End With
End Sub
'***************************************
' End Sub processTaxonomyC
'***************************************

'*-------------------------------------*
' Begin Type Of Care Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportTypeOfCare, rsImportTypeOfCare, _
	cmdImportTypeOfCareD, _
	strTOCIDList, strTOCIDCon

Sub processTypeOfCareA()
	Set cmdImportTypeOfCare = Server.CreateObject("ADODB.Command")
	Set rsImportTypeOfCare = Server.CreateObject("ADODB.Recordset")

	With cmdImportTypeOfCare
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_TypeOfCare_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@TypeOfCareE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@TypeOfCareF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@NotesEn", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@NotesFr", adVarChar, adParamInput, 255)
		.Parameters.Append .CreateParameter("@TOC_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportTypeOfCare
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	Set cmdImportTypeOfCareD = Server.CreateObject("ADODB.Command")

	With cmdImportTypeOfCareD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub

Sub processTypeOfCareB()
	cmdImportTypeOfCare.Parameters("@NUM").Value = fldNUM
	strTOCIDList = vbNullString
	strTOCIDCon = vbNullString
End Sub

Sub processTypeOfCareC()
	Dim xmlTypeOfCareNode, _
		strTypeOfCareE, strTypeOfCareF, _
		strTypeOfCareNoteE, strTypeOfCareNoteF, _
		strTypeOfCareNotesE, strTypeOfCareNotesF, _
		strNoteConE, strNoteConF

	strTypeOfCareNotesE = vbNullString
	strTypeOfCareNotesF = vbNullString
	strNoteConE = vbNullString
	strNoteConF = vbNullString

	makeCCRRecordCheck()

	If bInsertEnglish Then
		strTypeOfCareNotesE = Nz(xmlChildNode.getAttribute("N"),vbNullString)
		If Not Nl(strTypeOfCareNotesE) Then
			strNoteConE = " ; "
		End If
	End If
	If bInsertFrench Then
		strTypeOfCareNotesF = Nz(xmlChildNode.getAttribute("NF"),vbNullString)
		If Not Nl(strTypeOfCareNotesF) Then
			strNoteConF = " ; "
		End If
	End If

	For Each xmlTypeOfCareNode in xmlChildNode.childNodes
		If bInsertEnglish Then
			strTypeOfCareE = xmlTypeOfCareNode.getAttribute("V")
			strTypeOfCareNoteE = xmlTypeOfCareNode.getAttribute("N")
		End If
		If bInsertFrench Then
			strTypeOfCareF = Nz(xmlTypeOfCareNode.getAttribute("VF"),xmlTypeOfCareNode.getAttribute("V"))
			strTypeOfCareNoteF = xmlTypeOfCareNode.getAttribute("NF")
		End If

		With cmdImportTypeOfCare
			.Parameters("@TypeOfCareE").Value = Nz(strTypeOfCareE,Null)
			.Parameters("@TypeOfCareF").Value = Nz(strTypeOfCareF,Null)
			.Parameters("@NotesEn").Value = Nz(strTypeOfCareNoteE,Null)
			.Parameters("@NotesFr").Value = Nz(strTypeOfCareNoteF,Null)
		End With

		Set rsImportTypeOfCare = cmdImportTypeOfCare.Execute

		With rsImportTypeOfCare
			Set rsImportTypeOfCare = .NextRecordset
			If Not Nl(cmdImportTypeOfCare.Parameters("@TOC_ID")) Then
				strTOCIDList = strTOCIDList & strTOCIDCon & cmdImportTypeOfCare.Parameters("@TOC_ID")
				strTOCIDCon = ","
			Else
				If bInsertEnglish Then
					strTypeOfCareNotesE = strTypeOfCareE & _
						IIf(Nl(strTypeOfCareNoteE),vbNullString," - " & strTypeOfCareNoteE) & _
						strNoteConE & strTypeOfCareNotesE
					strNoteConE = " ; "
				End If
				If bInsertFrench Then
					strTypeOfCareNotesF = strTypeOfCareF & _
						IIf(Nl(strTypeOfCareNoteF),vbNullString," - " & strTypeOfCareNoteF) & _
						strNoteConF & strTypeOfCareNotesF
					strNoteConF = " ; "
				End If
				Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_VALUE_MOVED_TO_NOTES & TXT_COLON & Nz(strTypeOfCareE,strTypeOfCareF))
			End If
		End With
	Next

	With cmdImportTypeOfCareD
		.CommandText = "DELETE FROM CCR_BT_TOC WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strTOCIDList)," AND TOC_ID NOT IN (" & strTOCIDList & ")")
		.Execute
	End With

	Call dicTableList("CCRE").processField("TYPE_OF_CARE_NOTES",Null,strTypeOfCareNotesE,True,FTYPE_TEXT)
	Call dicTableList("CCRF").processField("TYPE_OF_CARE_NOTES",Null,strTypeOfCareNotesF,True,FTYPE_TEXT)
End Sub

'*-------------------------------------*
' End Type Of Care Import Functions (A,B,C)
'*-------------------------------------*

Dim cmdImportTypeOfProgram, rsImportTypeOfProgram

Sub processTypeOfProgramA()
	Set cmdImportTypeOfProgram = Server.CreateObject("ADODB.Command")
	Set rsImportTypeOfProgram = Server.CreateObject("ADODB.Recordset")

	With cmdImportTypeOfProgram
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_TypeOfProgram_Check"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@TypeOfProgramE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@TypeOfProgramF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@TOP_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportTypeOfProgram
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processTypeOfProgramB()
	Dim strTypeOfProgramE, strTypeOfProgramF

	If bInsertEnglish Then
		strTypeOfProgramE = xmlChildNode.getAttribute("V")
	End If
	If bInsertFrench Then
		strTypeOfProgramF = Nz(xmlChildNode.getAttribute("VF"),xmlChildNode.getAttribute("V"))
	End If

	If Nl(strTypeOfProgramE) And Nl(strTypeOfProgramF) Then
		Call dicTableList("CCR").processField("TYPE_OF_PROGRAM",Null,"NULL",True,FTYPE_NUMBER)
	Else
		With cmdImportTypeOfProgram
			.Parameters("@TypeOfProgramE") = Nz(strTypeOfProgramE,Null)
			.Parameters("@TypeOfProgramF") = Nz(strTypeOfProgramF,Null)
		End With

		Set rsImportTypeOfProgram = cmdImportTypeOfProgram.Execute

		With rsImportTypeOfProgram
			Set rsImportTypeOfProgram = .NextRecordset
			If Nl(cmdImportTypeOfProgram.Parameters("@TOP_ID")) Then
				Call dicTableList("CCR").processField("TYPE_OF_PROGRAM",Null,"NULL",True,FTYPE_NUMBER)
				Call addImportNote("Unknown Type of Program: " & Nz(strTypeOfProgramE,strTypeOfProgramF))
			Else
				Call dicTableList("CCR").processField("TYPE_OF_PROGRAM",Null,cmdImportTypeOfProgram.Parameters("@TOP_ID"),True,FTYPE_NUMBER)
			End If
		End With
	End If
End Sub

'***************************************
' Begin Sub processVacancyInfoA
'	Creates a command object for updating the vacancy data
'***************************************
Dim cmdImportVacancyInfo, rsImportVacancyInfo, _
	cmdImportVacancyInfoD

Sub processVacancyInfoA()
	Set cmdImportVacancyInfo = Server.CreateObject("ADODB.Command")
	Set cmdImportVacancyInfoD = Server.CreateObject("ADODB.Command")

	With cmdImportVacancyInfo
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_VacancyInfo_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
		.Parameters.Append .CreateParameter("@HAS_ENGLISH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@HAS_FRENCH", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@GUID", adGUID, adParamInput, 16)
		.Parameters.Append .CreateParameter("@ServiceTitleEn", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@ServiceTitleFr", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@UnitTypeNameEn", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@UnitTypeNameFr", adVarChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@Capacity", adInteger, adParamInput, 4)
		.Parameters.Append .CreateParameter("@FundedCapacity", adInteger, adParamInput, 4)
		.Parameters.Append .CreateParameter("@Vacancy", adInteger, adParamInput, 4)
		.Parameters.Append .CreateParameter("@HoursPerDay", adDecimal, adParamInput)
		.Parameters("@HoursPerDay").Precision = 6
		.Parameters("@HoursPerDay").NumericScale = 1
		.Parameters.Append .CreateParameter("@DaysPerWeek", adDecimal, adParamInput)
		.Parameters("@DaysPerWeek").Precision = 6
		.Parameters("@DaysPerWeek").NumericScale = 1
		.Parameters.Append .CreateParameter("@WeeksPerYear", adDecimal, adParamInput)
		.Parameters("@WeeksPerYear").Precision = 6
		.Parameters("@WeeksPerYear").NumericScale = 1
		.Parameters.Append .CreateParameter("@FullTimeEquivalent", adDecimal, adParamInput)
		.Parameters("@FullTimeEquivalent").Precision = 6
		.Parameters("@FullTimeEquivalent").NumericScale = 1
		.Parameters.Append .CreateParameter("@WaitList", adBoolean, adParamInput, 1)
		.Parameters.Append .CreateParameter("@WaitListDate", adDate, adParamInput, 16)
		.Parameters.Append .CreateParameter("@NotesEn", adVarChar, adParamInput, 2000)
		.Parameters.Append .CreateParameter("@NotesFr", adVarChar, adParamInput, 2000)
		.Parameters.Append .CreateParameter("@MODIFIED_DATE", adDate, adParamInput, 16)
		.Parameters.Append .CreateParameter("@TargetPopulations", adLongVarChar, adParamInput, -1)
		.Parameters.Append .CreateParameter("@BT_VUT_ID", adInteger, adParamOutput, 4)
	End With

	With cmdImportVacancyInfoD
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
End Sub
'***************************************
' End Sub processVacancyInfoA
'***************************************

'***************************************
' Begin Sub processVacancyInfoB
'	Reset values for the current record
'***************************************
Sub processVacancyInfoB()
	cmdImportVacancyInfo.Parameters("@NUM").Value = fldNUM
	cmdImportVacancyInfo.Parameters("@HAS_ENGLISH").Value = IIf(bInsertEnglish,SQL_TRUE,SQL_FALSE)
	cmdImportVacancyInfo.Parameters("@HAS_FRENCH").Value = IIf(bInsertFrench,SQL_TRUE,SQL_FALSE)
End Sub
'***************************************
' End Sub processVacancyInfoB
'***************************************

'***************************************
' Begin Sub processVacancyInfoC
'	Update the VacancyInfo data for the given record.
'***************************************
Sub processVacancyInfoC()
	Dim xmlVacancyInfoNode, _
		xmlVacancyInfoTPNode, _
		strVacancyInfoGUID, _
		strVacancyInfoServiceTitleE, _
		strVacancyInfoServiceTitleF, _
		strVacancyInfoUnitTypeE,_
		strVacancyInfoUnitTypeF,_
		intVacancyInfoCapacity, _
		intVacancyInfoFundedCapacity, _
		intVacancyInfoVacancy, _
		intVacancyInfoHours, _
		intVacancyInfoDays, _
		intVacancyInfoWeeks, _
		intVacancyInfoFTE, _
		bVacancyInfoWaitList, _
		dVacancyInfoWaitListDate, _
		dVacancyInfoModified, _
		strVacancyInfoNoteE, _
		strVacancyInfoNoteF, _
		strVacancyInfoNotesE, _
		strVacancyInfoNotesF, _
		strNoteConE, strNoteConF, _
		strTargetPopulations, _
		strVacancyInfoUnknownTargetPops, _
		strVacancyInfoUnknownTargetPopsCon, _
		strVacancyInfoUnknownTargetPopsF, _
		strTPE, _
		strTPF, _
		strTPConE, _
		strTPConF, _
		strVUTIDList, _
		strVUTIDCon

	makeCICRecordCheck()

	If bInsertEnglish Then
		strVacancyInfoNotesE = xmlChildNode.getAttribute("N")
	End If
	If bInsertFrench Then
		strVacancyInfoNotesF = xmlChildNode.getAttribute("NF")
	End If

	If Not Nl(strVacancyInfoNotesE) Then
		strNoteConE = vbCrLf & vbCrLf
	End If
	If Not Nl(strVacancyInfoNotesF) Then
		strNoteConF = vbCrLf & vbCrLf
	End If

	For Each xmlVacancyInfoNode in xmlChildNode.childNodes
		strVacancyInfoGUID = xmlVacancyInfoNode.getAttribute("GID")
		intVacancyInfoCapacity = xmlVacancyInfoNode.getAttribute("CAP")
		intVacancyInfoFundedCapacity = xmlVacancyInfoNode.getAttribute("FUNDCAP")
		intVacancyInfoVacancy = xmlVacancyInfoNode.getAttribute("VAC")
		intVacancyInfoHours = xmlVacancyInfoNode.getAttribute("HOURS")
		intVacancyInfoDays = xmlVacancyInfoNode.getAttribute("DAYS")
		intVacancyInfoWeeks = xmlVacancyInfoNode.getAttribute("WEEKS")
		intVacancyInfoFTE = xmlVacancyInfoNode.getAttribute("FTE")
		bVacancyInfoWaitList = xmlVacancyInfoNode.getAttribute("WAIT")
		dVacancyInfoWaitListDate = DateTimeStringFromXML(xmlVacancyInfoNode.getAttribute("WAITD"),False)
		dVacancyInfoModified = DateTimeStringFromXML(xmlVacancyInfoNode.getAttribute("MODIFIED_DATE"),False)
		If bInsertEnglish Then
			strVacancyInfoServiceTitleE = xmlVacancyInfoNode.getAttribute("SVC")
			strVacancyInfoUnitTypeE = xmlVacancyInfoNode.getAttribute("NM")
			strVacancyInfoNoteE = xmlVacancyInfoNode.getAttribute("N")
		End If
		If bInsertFrench Then
			strVacancyInfoServiceTitleF = xmlVacancyInfoNode.getAttribute("SVCF")
			strVacancyInfoUnitTypeF = Nz(xmlVacancyInfoNode.getAttribute("NMF"),xmlVacancyInfoNode.getAttribute("NM"))
			strVacancyInfoNoteF = xmlVacancyInfoNode.getAttribute("NF")
		End If
		strTargetPopulations = xmlVacancyInfoNode.xml

		cmdImportVacancyInfo.Parameters("@GUID").Value = "{" & strVacancyInfoGUID & "}"
		cmdImportVacancyInfo.Parameters("@ServiceTitleEn").Value = Nz(strVacancyInfoServiceTitleE,Null)
		cmdImportVacancyInfo.Parameters("@ServiceTitleFr").Value = Nz(strVacancyInfoServiceTitleF,Null)
		cmdImportVacancyInfo.Parameters("@UnitTypeNameEn").Value = Nz(strVacancyInfoUnitTypeE,Null)
		cmdImportVacancyInfo.Parameters("@UnitTypeNameFr").Value = Nz(strVacancyInfoUnitTypeF,Null)
		cmdImportVacancyInfo.Parameters("@Capacity").Value = intVacancyInfoCapacity
		cmdImportVacancyInfo.Parameters("@FundedCapacity").Value = intVacancyInfoFundedCapacity
		cmdImportVacancyInfo.Parameters("@Vacancy").Value = intVacancyInfoVacancy
		cmdImportVacancyInfo.Parameters("@HoursPerDay").Value = intVacancyInfoHours
		cmdImportVacancyInfo.Parameters("@DaysPerWeek").Value = intVacancyInfoDays
		cmdImportVacancyInfo.Parameters("@WeeksPerYear").Value = intVacancyInfoWeeks
		cmdImportVacancyInfo.Parameters("@FullTimeEquivalent").Value = intVacancyInfoFTE
		cmdImportVacancyInfo.Parameters("@WaitList").Value = bVacancyInfoWaitList
		cmdImportVacancyInfo.Parameters("@WaitListDate").Value = dVacancyInfoWaitListDate
		cmdImportVacancyInfo.Parameters("@NotesEn").Value = Nz(strVacancyInfoNoteE,Null)
		cmdImportVacancyInfo.Parameters("@NotesFr").Value = Nz(strVacancyInfoNoteF,Null)
		cmdImportVacancyInfo.Parameters("@MODIFIED_DATE").Value = dVacancyInfoModified
		cmdImportVacancyInfo.Parameters("@TargetPopulations").Value = Nz(strTargetPopulations,Null)

		Set rsImportVacancyInfo = cmdImportVacancyInfo.Execute

		With rsImportVacancyInfo
			Set rsImportVacancyInfo = .NextRecordset
			If Not Nl(cmdImportVacancyInfo.Parameters("@BT_VUT_ID")) Then
				strVUTIDList = strVUTIDList & strVUTIDCon & cmdImportVacancyInfo.Parameters("@BT_VUT_ID")
				strVUTIDCon = ","
			Else
				strTPCon = " for "
				strTP = vbNullString
				strTPConF = " pour les "
				strTP = vbNullString
				Dim strNotesTmp

				For Each xmlVacancyInfoTPNode in xmlVacancyInfoNode.childNodes
					strTP = strTP & strTPCon & xmlVacancyInfoTPNode.getAttribute("V")
					strTPCon = ", "
					strTPF = strTPF & strTPConF & Nz(xmlVacancyInfoTPNode.getAttribute("VF"), xmlVacancyInfoTPNode.getAttribute("V"))
					strTPConF = ", "
				Next
				strNotesTmp = StringIf(Not Nl(strVacancyInfoServiceTitle), strVacancyInfoServiceTitle & ": ") & "Capacity of " & _
					intVacancyInfoCapacity & " " & strVacancyInfoUnitType & strTP & StringIf(Not Nl(intVacancyInfoFundedCapacity),"; Funded Capacity of " & intVacancyInfoFundedCapacity) & "."
				If Nl(intVacancyInfoVacancy) Then
					strNotesTmp = strNotesTmp & " Vacancy is unknown"
				ElseIf intVacancyInfoVacancy = 0 Then
					strNotesTmp = strNotesTmp & " No vacancy"
				Else
					strNotesTmp = strNotesTmp & " Vacancy of " & intVacancyInfoVacancy & " " & strVacancyInfoUnitType
				End If
				If Not Nl(dVacancyInfoModified) Then
					strNotesTmp = strNotesTmp & " (as of " & DateStringFromXML(xmlVacancyInfoNode.getAttribute("MODIFIED_DATE"), True) & ")"
				End If
				strNotesTmp = strNotesTmp & "."
				If bVacancyInfoWaitList = 0 Then
					strNotesTmp = strNotesTmp & " A wait list is not available."
				ElseIf bVacancyInfoWaitList = 1 Then
					strNotesTmp = strNotesTmp & " A wait list is available"
					If Not Nl(dVacancyInfoWaitListDate) Then
						strNotesTmp = strNotesTmp & " (" & DateStringFromXML(xmlVacancyInfoNode.getAttribute("WD"), True) & ")"
					End If
					strNotesTmp = strNotesTmp & "."
				End If
				strNotesTmp = strNotesTmp & IIf(Nl(strVacancyInfoNote),vbNullString," Notes: " & strVacancyInfoNote)
				strVacancyInfoNotes = strNotesTmp & strNoteCon & strVacancyInfoNotes
				strNoteCon = vbCrLf & vbCrLf

				If bInsertFrench Then
					strNotesTmp = StringIf(Not Nl(strVacancyInfoServiceTitleF), strVacancyInfoServiceTitleF & " : ") & "Capacité de " & _
						intVacancyInfoCapacity & " " & Nz(strVacancyInfoUnitType, strVacancyInfoUnitTypeF) & strTPF & StringIf(Not Nl(intVacancyInfoFundedCapacity),"; Capacité de " & intVacancyInfoFundedCapacity & " avec un financement") & "."
					If Nl(intVacancyInfoVacancy) Then
						strNotesTmp = strNotesTmp & " La disponibilité n''est pas connue"
					ElseIf intVacancyInfoVacancy = 0 Then
						strNotesTmp = strNotesTmp & " Pas de disponibilité"
					Else
						strNotesTmp = strNotesTmp & " " & intVacancyInfoVacancy & " " & Nz(strVacancyInfoUnitType, strVacancyInfoUnitTypeF) & " sont disponibles"
					End If
					If Not Nl(dVacancyInfoModified) Then
						Response.LCID = LCID_FRENCH_CANADIAN
						strNotesTmp = strNotesTmp & " (à partir du " & DateStringFromXML(xmlVacancyInfoNode.getAttribute("MODIFIED_DATE"), True) & ")"
						Response.LCID = LCID_ENGLISH_CANADIAN
					End If
					strNotesTmp = strNotesTmp & "."
					If bVacancyInfoWaitList = 0 Then
						strNotesTmp = strNotesTmp & " Une liste d'attente ne sont pas disponibles."
					ElseIf bVacancyInfoWaitList = 1 Then
						strNotesTmp = strNotesTmp & " Une liste d''attente est disponible"
						If Not Nl(dVacancyInfoWaitListDate) Then
							Response.LCID = LCID_FRENCH_CANADIAN
							strNotesTmp = strNotesTmp & " (" & DateStringFromXML(xmlVacancyInfoNode.getAttribute("WD"), True) & ")"
							Response.LCID = LCID_ENGLISH_CANADIAN
						End If
						strNotesTmp = strNotesTmp & "."
					End If
					strNotesTmp = strNotesTmp & IIf(Nl(strVacancyInfoNoteF),vbNullString," Notes : " & strVacancyInfoNoteF)
					strVacancyInfoNotesF = strNotesTmp & strNoteConF & strVacancyInfoNotesF
					strNoteConF = vbCrLf & vbCrLf
				End If
				Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_VALUE_MOVED_TO_NOTES & TXT_COLON & strVacancyInfoUnitType)
			End If
		End With
	Next

	With cmdImportVacancyInfoD
		.CommandText = "DELETE FROM CIC_BT_VUT WHERE NUM=" & strQNUM & _
			StringIf(Not Nl(strVUTIDList)," AND BT_VUT_ID NOT IN (" & strVUTIDList & ")")
		.Execute
	End With

	If bInsertEnglish Then
		Call dicTableList("CICE").processField("VACANCY_NOTES",Null,strVacancyInfoNotesE,True,FTYPE_TEXT)
	End If
	If bInsertFrench Then
		Call dicTableList("CICF").processField("VACANCY_NOTES",Null,strVacancyInfoNotesF,True,FTYPE_TEXT)
	End If

End Sub
'***************************************
' End Sub processVacancyInfoC
'***************************************

Dim cmdImportWard, rsImportWard

Sub processWardA()
	Set cmdImportWard = Server.CreateObject("ADODB.Command")
	Set rsImportWard = Server.CreateObject("ADODB.Recordset")

	With cmdImportWard
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Ward_Check"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@WardNumber", adInteger, adParamInput, 2)
		.Parameters.Append .CreateParameter("@MunicipalityE", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@MunicipalityF", adVarChar, adParamInput, 200)
		.Parameters.Append .CreateParameter("@ProvState", adVarWChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@Country", adVarWChar, adParamInput, 100)
		.Parameters.Append .CreateParameter("@WD_ID", adInteger, adParamOutput, 4)
	End With

	With rsImportWard
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With
End Sub

Sub processWardB()
	Dim strWard, _
		strMunicipalityE, strMunicipalityF, _
		strProv, strCountry

	strWard = xmlChildNode.getAttribute("V")
	strProv = xmlChildNode.getAttribute("PRV")
	strCountry = xmlChildNode.getAttribute("CTRY")
	If bInsertEnglish Then
		strMunicipalityE = xmlChildNode.getAttribute("MUN")
	End If
	If bInsertFrench Then
		strMunicipalityF = Nz(xmlChildNode.getAttribute("MUN"),xmlChildNode.getAttribute("MUNF"))
	End If

	If Nl(strWard) Then
		Call dicTableList("CIC").processField("WARD",Null,"NULL",True,FTYPE_NUMBER)
	Else
		With cmdImportWard
			.Parameters("@WardNumber") = strWard
			.Parameters("@MunicipalityE") = Nz(strMunicipalityE,Null)
			.Parameters("@MunicipalityF") = Nz(strMunicipalityF,Null)
			.Parameters("@ProvState").Value = Nz(strProv,Null)
			.Parameters("@Country").Value = Nz(strCountry,Null)
		End With

		Set rsImportWard = cmdImportWard.Execute

		With rsImportWard
			Set rsImportWard = .NextRecordset
			If Nl(cmdImportWard.Parameters("@WD_ID")) Then
				Call dicTableList("CIC").processField("WARD",Null,"NULL",True,FTYPE_NUMBER)
				Call addImportNote( "[" & strImportFld & "] " & TXT_UNKNOWN_VALUE & TXT_COLON & Nz(strMunicipalityE,strMunicipalityF) & " " & strWard)
			Else
				Call dicTableList("CIC").processField("WARD",Null,cmdImportWard.Parameters("@WD_ID"),True,FTYPE_NUMBER)
			End If
		End With
	End If
End Sub

Sub makeGBLRecordCheck()
	'Reset Flags
	For Each indTable In dicTableList
		Call dicTableList(indTable).resetUsage()
	Next

	Dim cmdListImportData, rsListImportData
	Set cmdListImportData = Server.CreateObject("ADODB.Command")
	Set rsListImportData = Server.CreateObject("ADODB.Recordset")

	With cmdListImportData
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_GBL_Check_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInputOutput, 8, fldNUM.Value)
		.Parameters.Append .CreateParameter("@EXTERNAL_ID", adVarChar, adParamInput, 50, fldEXTERNALID.Value)
		.Parameters.Append .CreateParameter("@SourceDbCode", adVarChar, adParamInput, 20, fldSourceDbCode.Value)
		.Parameters.Append .CreateParameter("@OWNER", adChar, adParamInput, 3, fldOWNER.Value)
		.Parameters.Append .CreateParameter("@HAS_ENGLISH", adBoolean, adParamInputOutput, 1, Nz(fldHASE.Value,SQL_FALSE))
		.Parameters.Append .CreateParameter("@HAS_FRENCH", adBoolean, adParamInputOutput, 1, Nz(fldHASF.Value,SQL_FALSE))
	End With

	With rsListImportData
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListImportData
		Set rsListImportData = .NextRecordset
	End With

	With cmdListImportData
		If Not Nl(.Parameters("@NUM").Value) Then
			If Nl(fldNUM.Value) Then
				fldNUM.Value = .Parameters("@NUM").Value
			End If
			strQNUM = QsNl(fldNUM)
			dicTableList("GBL").Created = True
		Else
			strQNUM = Null
		End If

		If bInsertEnglish Then
			bInsertEnglish = .Parameters("@HAS_ENGLISH").Value
			dicTableList("GBLE").Created = True
		End If
		If bInsertFrench Then
			bInsertFrench = .Parameters("@HAS_FRENCH").Value
			dicTableList("GBLF").Created = True
		End If
	End With

	Set rsListImportData = Nothing
	Set cmdListImportData = Nothing
End Sub

Dim cmdCICRecordCheck, rsCICRecordCheck
Set cmdCICRecordCheck = Server.CreateObject("ADODB.Command")

With cmdCICRecordCheck
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_CIC_Check_i"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInputOutput, 8)
	.Prepared = True
End With

Sub makeCICRecordCheck()
	If dicTableList("CIC").Created = True Then
		Exit Sub
	End If

	With cmdCICRecordCheck
		.Parameters("@NUM").Value = fldNUM
	End With

	Set rsCICRecordCheck = cmdCICRecordCheck.Execute
	Set rsCICRecordCheck = rsCICRecordCheck.NextRecordset

	With cmdCICRecordCheck
		If Not Nl(.Parameters("@NUM").Value) Then
			dicTableList("CIC").Created = True
		End If
	End With
End Sub

Dim cmdCICRecordCheckE, rsCICRecordCheckE
Set cmdCICRecordCheckE = Server.CreateObject("ADODB.Command")

With cmdCICRecordCheckE
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_CICE_Check_i"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
	.Prepared = True
End With

Sub makeCICRecordCheckE()
	If dicTableList("CICE").Created = True Then
		Exit Sub
	End If

	With cmdCICRecordCheckE
		.Parameters("@NUM").Value = fldNUM
	End With

	Set rsCICRecordCheckE = cmdCICRecordCheckE.Execute
	Set rsCICRecordCheckE = rsCICRecordCheckE.NextRecordset

	With cmdCICRecordCheckE
		If Not Nl(.Parameters("@NUM").Value) Then
			dicTableList("CICE").Created = True
		End If
	End With
End Sub

Dim cmdCICRecordCheckF, rsCICRecordCheckF
Set cmdCICRecordCheckF = Server.CreateObject("ADODB.Command")

With cmdCICRecordCheckF
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_CICE_Check_i"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
	.Prepared = True
End With

Sub makeCICRecordCheckF()
	If dicTableList("CICF").Created = True Then
		Exit Sub
	End If

	With cmdCICRecordCheckF
		.Parameters("@NUM").Value = fldNUM
	End With

	Set rsCICRecordCheckF = cmdCICRecordCheckF.Execute
	Set rsCICRecordCheckF = rsCICRecordCheckF.NextRecordset

	With cmdCICRecordCheckF
		If Not Nl(.Parameters("@NUM").Value) Then
			dicTableList("CICF").Created = True
		End If
	End With
End Sub

Dim cmdCCRRecordCheck, rsCCRRecordCheck
Set cmdCCRRecordCheck = Server.CreateObject("ADODB.Command")

With cmdCCRRecordCheck
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_CCR_Check_i"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInputOutput, 8)
	.Prepared = True
End With

Sub makeCCRRecordCheck()
	If dicTableList("CCR").Created = True Then
		Exit Sub
	End If

	With cmdCCRRecordCheck
		.Parameters("@NUM").Value = fldNUM
	End With

	Set rsCCRRecordCheck = cmdCCRRecordCheck.Execute
	Set rsCCRRecordCheck = rsCCRRecordCheck.NextRecordset

	With cmdCCRRecordCheck
		If Not Nl(.Parameters("@NUM").Value) Then
			dicTableList("CCR").Created = True
		End If
	End With
End Sub

Dim intEFID
intEFID = Trim(Request("EFID"))

Dim cmdQueuedDataSet, _
	rsQueuedDataSet, _
	aEFID, _
	i

If Nl(intEFID) Then
	intEFID = Null
ElseIf Not IsIDType(intEFID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intEFID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_DATASET, _
		"import.asp", vbNullString)
Else
	intEFID = CLng(intEFID)
End If

Dim intDataSet
intDataSet = Request("DataSet")

If IsNumeric(intDataSet) Then
	intDataSet = CInt(intDataSet)
End If

Select Case intDataSet
	Case DATASET_ADD
	Case DATASET_UPDATE
	Case Else
		intDataSet = DATASET_FULL
End Select

Dim strImportOwners, _
	intOwnerConflict, _
	intPrivacyProfileConflict, _
	intPublicConflict, _
	intDeletedConflict, _
	intImportTop, _
	bRetryFailed, _
	bImportSourceDb, _
	bUnmappedPrivacySkipFields, _
	strAutoAddPubs

strImportOwners = Request("ImportOwners")
If Not Nl(strImportOwners) Then
	strImportOwners = SQUOTE & reReplace(strImportOwners,",","','",True,True,True,False) & SQUOTE
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

strAutoAddPubs = Request("AutoAddPubs")
If Not IsIDList(strAutoAddPubs) Then
	strAutoAddPubs = Null
End If

intImportTop = Request("ImportTop")
If IsNumeric(intImportTop) Then
	intImportTop = CInt(intImportTop)
Else
	intImportTop = Null
End If

bRetryFailed = Request("RetryFailed") = "on"
bImportSourceDb = Request("ImportSourceDb") = "on"
bUnmappedPrivacySkipFields = Trim(Request("UnmappedPrivacySkipFields")) = "F"

Dim bQ, _
	strSQL

strSQL = "SELECT ie.EF_ID, dbo.fn_CIC_ImportEntry_FieldList(ie.EF_ID) AS FieldList, ISNULL(DisplayName,FileName) AS DisplayName," & vbCrLf & _
		"iede.SourceDbName AS SourceDbNameEn, iede.SourceDbURL AS SourceDbURLEn," & vbCrLf & _
		"iedf.SourceDbName AS SourceDbNameFr, iedf.SourceDbURL AS SourceDbURLFr," & vbCrLf & _
		"ie.SourceDbCode," & vbCrLf & _
		"CAST(CASE WHEN EXISTS(SELECT * FROM CIC_ImportEntry_PrivacyProfile ipp WHERE ipp.EF_ID=ie.EF_ID) THEN 1 ELSE 0 END AS bit) AS HasPrivacyProfiles,"

If Not Nl(intEFID) Then
	bQ = False
	strSQL = strSQL & vbCrLf & _
		intOwnerConflict & " AS QOwnerConflict, CAST(" & IIf(bImportSourceDb,SQL_TRUE,SQL_FALSE) & " AS bit) AS QImportSourceDbInfo, " & vbCrLf & _
		"CAST(" & IIf(bUnmappedPrivacySkipFields,SQL_TRUE,SQL_FALSE) & " AS bit) AS QUnmappedPrivacySkipFields," & vbCrLf & _
		"CAST(" & IIf(bRetryFailed,SQL_TRUE,SQL_FALSE) & " AS bit) AS QRetryFailed," & vbCrLf & _
		" " & intPrivacyProfileConflict & " AS QPrivacyProfileConflict," & vbCrLf & _
		" " & QsNl(strAutoAddPubs) & " AS QAutoAddPubs," & intPublicConflict & " AS QPublicConflict," & intDeletedConflict & " AS QDeletedConflict" & vbCrLf & _
		"FROM CIC_ImportEntry ie" & vbCrLf & _
		"LEFT JOIN CIC_ImportEntry_Description iede ON ie.EF_ID=iede.EF_ID AND iede.LangID=" & LANG_ENGLISH & vbCrLf & _
		"LEFT JOIN CIC_ImportEntry_Description iedf ON ie.EF_ID=iedf.EF_ID AND iedf.LangID=" & LANG_FRENCH & vbCrLf & _
		"WHERE ie.MemberID=" & g_intMemberID & vbCrLf & _
		"AND ie.EF_ID=" & intEFID
Else
	bQ = True
	strSQL = strSQL & vbCrLf & _
		"QOwnerConflict, QImportSourceDbInfo," & vbCrLf & _
		"QUnmappedPrivacySkipFields," & vbCrLf & _
		"QPrivacyProfileConflict," & vbCrLf & _
		"QAutoAddPubs," & vbCrLf & _
		"QPublicConflict," & vbCrLf & _
		"QDeletedConflict," & vbCrLf & _
		"QDate, QBy," & vbCrLf & _
		"QRetryFailed"  & vbCrLf & _
		"FROM CIC_ImportEntry ie" & vbCrLf & _
		"LEFT JOIN CIC_ImportEntry_Description iede ON ie.EF_ID=iede.EF_ID AND iede.LangID=" & LANG_ENGLISH & vbCrLf & _
		"LEFT JOIN CIC_ImportEntry_Description iedf ON ie.EF_ID=iedf.EF_ID AND iedf.LangID=" & LANG_FRENCH & vbCrLf & _
		"WHERE ie.MemberID=" & g_intMemberID & vbCrLf & _
		"AND QDate IS NOT NULL"
End If

'Response.Write("<pre>" & strSQL & "<pre>")
'Response.Flush()

Dim cmdImportEntry, _
	rsImportEntry

Set cmdImportEntry = Server.CreateObject("ADODB.Command")
Set rsImportEntry = Server.CreateObject("ADODB.Recordset")

With cmdImportEntry
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strSQL
	.CommandType = adCmdText
	.CommandTimeout = 0
End With

With rsImportEntry
	.CursorLocation = adUseClient
	.CursorType = adOpenKeyset
	.LockType = adLockOptimistic
	.Open cmdImportEntry

	If .EOF Then
		Call handleError(TXT_NO_RECORD_CHOSEN & _
			vbCrLf & "<br>" & TXT_CHOOSE_DATASET, _
			"import.asp", vbNullString)
	End If
End With

Call makePageHeader(TXT_IMPORT_RECORD_DATA, TXT_IMPORT_RECORD_DATA, True, False, True, True)

Dim strSourceDbEn, strSourceDbFr

Dim strQNUM, _
	bInsertEnglish, _
	bInsertFrench

Dim bCreatedCIC
Dim strReport, strReportCon

Dim fldEFID, fldDisplayName, fldFieldList, fldOwnerConflict, fldPublicConflict, fldDeletedConflict, fldPrivacyProfileConflict, fldQAutoAddPubs, fldImportSourceDb, fldQDate, fldQBy, _
	fldSourceDbCode, fldSourceDbNameEn, fldSourceDbNameFr, fldSourceDbURLEn, fldSourceDbURLFr, fldRetryFailed
Dim fldERID, fldNUM, fldEXTERNALID, fldOWNER, fldHASE, fldHASF, fldPrivacyProfile, fldDATA, fldREPORT, fldIMPORTED, fldNUME, fldNUMF

Dim bHavePrivacyProfiles, dicPrivacyProfileFields, dicPrivacyProfileMap, dicPrivacyProfiles

Dim cmdListImport, rsListImport, intRecordCount
Set cmdListImport = Server.CreateObject("ADODB.Command")
Set rsListImport = Server.CreateObject("ADODB.Recordset")

Dim xmlDoc, xmlNode, xmlChildNode
Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
With xmlDoc
	.async = False
	.setProperty "SelectionLanguage", "XPath"
End With

Set fldEFID = rsImportEntry.Fields("EF_ID")
Set fldDisplayName = rsImportEntry.Fields("DisplayName")
Set fldFieldList = rsImportEntry.Fields("FieldList")
Set fldOwnerConflict = rsImportEntry.Fields("QOwnerConflict")
Set fldRetryFailed = rsImportEntry.Fields("QRetryFailed")
Set fldPublicConflict = rsImportEntry.Fields("QPublicConflict")
Set fldDeletedConflict = rsImportEntry.Fields("QDeletedConflict")
Set fldPrivacyProfileConflict = rsImportEntry.Fields("QPrivacyProfileConflict")
Set fldQAutoAddPubs = rsImportEntry.Fields("QAutoAddPubs")
Set fldImportSourceDb = rsImportEntry.Fields("QImportSourceDbInfo")
Set fldSourceDbCode = rsImportEntry.Fields("SourceDbCode")
Set fldSourceDbNameEn = rsImportEntry.Fields("SourceDbNameEn")
Set fldSourceDbNameFr = rsImportEntry.Fields("SourceDbNameFr")
Set fldSourceDbURLEn = rsImportEntry.Fields("SourceDbURLEn")
Set fldSourceDbURLFr = rsImportEntry.Fields("SourceDbURLFr")

If bQ Then
	Set fldQDate = rsImportEntry.Fields("QDate")
	Set fldQBy = rsImportEntry.Fields("QBy")
End IF

Dim bPrintedADot
While Not rsImportEntry.EOF
bPrintedADot=False

'Privacy Profile Map
bUnmappedPrivacySkipFields = rsImportEntry("QUnmappedPrivacySkipFields").Value
bHavePrivacyProfiles = rsImportEntry("HasPrivacyProfiles").Value

Set dicPrivacyProfileMap = Server.CreateObject("Scripting.Dictionary")
Set dicPrivacyProfiles = Server.CreateObject("Scripting.Dictionary")

If bHavePrivacyProfiles Then
	Dim cmdPrivacyProfileMap, rsPrivacyProfileMap, strPrivacyProfileMapSQL, strProfileName, strFieldName
	Dim strPrivacyMap, strPrivacyMapCon, strERID, strProfileID
	strPrivacyMap = vbNullString
	strPrivacyMapCon = vbNullString
	If Not bQ Then
		For Each strERID in Split(Request("PrivacyProfiles"), ",")
			If IsIDType(strERID) Then
				strProfileID = Trim(Request("QProfileMap_" & strERID))
				If Not Nl(strProfileID) And IsIDType(strProfileID) Then
					strPrivacyMap = strPrivacyMap & strPrivacyMapCon & strERID & "," & strProfileID
					strPrivacyMapCon = ";"
				End If
			End If
		Next
	End If

	strPrivacyProfileMapSQL = "SELECT ipp.ER_ID, ippn.ProfileName, FieldNames, " & _
									IIf(bQ, "QPrivacyMap", "pp.ProfileID AS QPrivacyMap") & _
								" FROM CIC_ImportEntry_PrivacyProfile ipp" & _
								" INNER JOIN CIC_ImportEntry_PrivacyProfile_Name ippn " & _
								"	ON ipp.ER_ID=ippn.ER_ID AND ippn.LangID = (SELECT TOP 1 LangID FROM CIC_ImportEntry_PrivacyProfile_Name WHERE ER_ID=ippn.ER_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)"
	If Not bQ Then
		strPrivacyProfileMapSQL = strPrivacyProfileMapSQL & _
								" LEFT JOIN dbo.fn_GBL_ParseIntIDPairList(" & Qs(strPrivacyMap, "'") & ", ';',',') ipl" & _
								"		ON ipp.ER_ID=ipl.LeftID" & _
								"	LEFT JOIN GBL_PrivacyProfile pp" & _
								"		ON ipl.RightID = pp.ProfileID "
	End If

	strPrivacyProfileMapSQL = strPrivacyProfileMapSQL & "	WHERE ipp.EF_ID=" & fldEFID.Value
	'Response.Write(strPrivacyProfileMapSQL & "<br>")
	'Response.Flush

	Set cmdPrivacyProfileMap = Server.CreateObject("ADODB.Command")
	Set rsPrivacyProfileMap = Server.CreateObject("ADODB.Recordset")
	With cmdPrivacyProfileMap
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = strPrivacyProfileMapSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With

	With rsPrivacyProfileMap
		.CursorLocation = adUseClient
		.CursorType = adOpenKeyset
		.LockType = adLockOptimistic
		.Open cmdPrivacyProfileMap

		While Not .EOF
			strProfileName = .Fields("ProfileName").Value
			If Not Nl(.Fields("QPrivacyMap").Value) Then
				dicPrivacyProfileMap(strProfileName) = .Fields("QPrivacyMap").Value
			End If
			Set dicPrivacyProfileFields = Server.CreateObject("Scripting.Dictionary")
			Set dicPrivacyProfiles(strProfileName) = dicPrivacyProfileFields
			For Each strFieldName in Split(.Fields("FieldNames"), ",")
				dicPrivacyProfileFields(strFieldName) = True
			Next
			.MoveNext
		Wend
		.Close

	End With
	Set cmdPrivacyProfileMap = Nothing
	Set rsPrivacyProfileMap = Nothing
End If


If fldImportSourceDb.Value Then
	strSourceDbEn = Nz(fldSourceDbNameEn.Value,fldSourceDbURLEn.Value)
	If Not Nl(fldSourceDbURLEn.Value) Then
		strSourceDbEn = "&copy; <a href=""" & fldSourceDbURLEn.Value & """>" & strSourceDbEn & "</a>"
	End If
	strSourceDbFr = Nz(fldSourceDbNameFr.Value,fldSourceDbURLFr.Value)
	If Not Nl(fldSourceDbURLFr.Value) Then
		strSourceDbFr = "&copy; <a href=""" & fldSourceDbURLFr.Value & """>" & strSourceDbFr & "</a>"
	End If
Else
	strSourceDbEn = vbNullString
	strSourceDbFr = vbNullString
End If
'Response.Write(Server.HTMLEncode(strSourceDbE))
'Response.Flush()

strSQL = "SELECT " & IIf(intImportTop > 0,"TOP " & intImportTop,vbNullString) & vbCrLf & _
		"ied.ER_ID, ied.NUM, ied.EXTERNAL_ID, ied.OWNER, ied.DATA, ied.REPORT, ied.IMPORTED, btde.NUM AS NUME, btdf.NUM AS NUMF, " & vbCrLf & _
		"CASE WHEN iedle.ER_ID IS NOT NULL THEN 1 ELSE 0 END AS HAS_ENGLISH," & vbCrLf & _
		"CASE WHEN iedlf.ER_ID IS NOT NULL THEN 1 ELSE 0 END AS HAS_FRENCH," & vbCrLf & _
		"ied.PRIVACY_PROFILE" & vbCrLf & _
		"FROM CIC_ImportEntry_Data ied" & vbCrLf & _
		"LEFT JOIN CIC_ImportEntry_Data_Language iedle ON ied.ER_ID=iedle.ER_ID AND iedle.LangID=" & LANG_ENGLISH & vbCrLf & _
		"LEFT JOIN CIC_ImportEntry_Data_Language iedlf ON ied.ER_ID=iedlf.ER_ID AND iedlf.LangID=" & LANG_FRENCH & vbCrLf & _
		"LEFT JOIN GBL_BaseTable bt ON ied.NUM=bt.NUM" & vbCrLf & _
		"LEFT JOIN GBL_BaseTable_Description btde ON bt.NUM=btde.NUM AND btde.LangID=0" & vbCrLf & _
		"LEFT JOIN GBL_BaseTable_Description btdf ON bt.NUM=btdf.NUM AND btdf.LangID=2" & vbCrLf

If bHavePrivacyProfiles Then
	If bQ Then
		strSQL = strSQL & vbCrLf & _
			"LEFT JOIN (SELECT ipp.*, ippn.ProfileName " & vbCrLf & _
			"	FROM CIC_ImportEntry_PrivacyProfile ipp " & vbCrLf & _
			"	INNER JOIN CIC_ImportEntry_PrivacyProfile_Name ippn " & _
			"		ON ipp.ER_ID=ippn.ER_ID AND LangID=(SELECT TOP 1 LangID FROM CIC_ImportEntry_PrivacyProfile_Name WHERE ippn.ER_ID=ER_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) " & vbCrLf & _
			"	) pm " & _
			"	ON ied.PRIVACY_PROFILE=pm.ProfileName AND ied.EF_ID=pm.EF_ID"
	Else
		strSQL = strSQL & vbCrLf & vbCrLf & _
			"LEFT JOIN (SELECT ippn.ProfileName, pp.ProfileID as QPrivacyMap " & vbCrLf & _
			"	FROM dbo.fn_GBL_ParseIntIDPairList(" & Qs(strPrivacyMap, "'") & ", ';',',') ipl" & vbCrLf & _
			"	INNER JOIN GBL_PrivacyProfile pp" & vbCrLf & _
			"		ON ipl.RightID = pp.ProfileID " & vbCrLf & _
			"	INNER JOIN CIC_ImportEntry_PrivacyProfile ipp" & vbCrLf & _
			"		ON ipp.ER_ID=ipl.LeftID" & vbCrLf & _
			"	INNER JOIN CIC_ImportEntry_PrivacyProfile_Name ippn" & vbCrLf & _
			"		ON ippn.ER_ID=ipp.ER_ID AND ippn.LangID=(SELECT TOP 1 LangID FROM CIC_ImportEntry_PrivacyProfile_Name WHERE ER_ID=ippn.ER_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
			"	WHERE ipp.EF_ID=" & fldEFID.Value & _
			"	) pm" & vbCrLf & _
			"	ON ied.PRIVACY_PROFILE=pm.ProfileName"
	End If
End If
strSQL = strSQL & vbCrLf & _
		"WHERE ied.EF_ID=" & fldEFID.Value & vbcrLf & _
		"AND ied.DATA IS NOT NULL"

Select Case intDataSet
	Case DATASET_ADD
		strSQL = strSQL & " AND bt.NUM IS NULL"
	Case DATASET_UPDATE
		strSQL = strSQL & " AND EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.NUM=ied.NUM AND bt.MemberID=" & g_intMemberID & ")"
	Case Else
		strSQL = strSQL & " AND (bt.NUM IS NULL OR EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.NUM=ied.NUM AND bt.MemberID=" & g_intMemberID & "))"
End Select

If fldOwnerConflict.Value = CNF_DO_NOT_IMPORT Then
	strSQL = strSQL & " AND (bt.NUM IS NULL OR bt.RECORD_OWNER=ied.OWNER)"
End If
If fldPublicConflict.Value = CNF_DO_NOT_IMPORT Then
	strSQL = strSQL & " AND (bt.NUM IS NULL OR ((btde.NUM IS NULL OR iedle.NON_PUBLIC IS NULL OR btde.NON_PUBLIC=iedle.NON_PUBLIC) AND (btdf.NUM IS NULL OR iedlf.NON_PUBLIC IS NULL OR btdf.NON_PUBLIC=iedlf.NON_PUBLIC)))"
End If
If fldDeletedConflict.Value = CNF_DO_NOT_IMPORT Then
	strSQL = strSQL & " AND (bt.NUM IS NULL OR ((btde.NUM IS NULL OR iedle.ER_ID IS NULL OR ISNULL(btde.DELETION_DATE, '1900-01-01')=ISNULL(iedle.DELETION_DATE, '1900-01-01')) AND (btdf.NUM IS NULL OR iedlf.ER_ID IS NULL OR ISNULL(btdf.DELETION_DATE, '1900-01-01')=ISNULL(iedlf.DELETION_DATE, '1900-01-01'))))"
End If

If Not fldRetryFailed.Value Then
	strSQL = strSQL & " AND IMPORTED=0"
End If

If bHavePrivacyProfiles Then
	If fldPrivacyProfileConflict.Value = CNF_DO_NOT_IMPORT Then
		strSQL = strSQL & " AND (bt.PRIVACY_PROFILE IS NULL OR bt.PRIVACY_PROFILE=pm.QPrivacyMap OR (pm.ProfileName IS NOT NULL AND pm.QPrivacyMap IS NULL))"
	End If
	If Not bUnmappedPrivacySkipFields Then
		strSQL = strSQL & " AND (ied.PRIVACY_PROFILE IS NULL OR pm.QPrivacyMap IS NOT NULL)"
	End If
End If

If Not Nl(strImportOwners) Then
	strSQL = strSQL & " AND OWNER IN (" & strImportOwners & ")"
End If

strSQL = strSQL & " ORDER BY ied.ER_ID"

'Response.Write("<pre>" & strSQL & "</pre>")
'Response.Flush()

With cmdListImport
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strSQL
	.CommandType = adCmdText
	.CommandTimeout = 0
End With

Dim strImportFld

With rsListImport
	.CursorLocation = adUseClient
	.CursorType = adOpenKeyset
	.LockType = adLockOptimistic
	.Open cmdListImport

	intRecordCount = .RecordCount
%>
<p><strong><%=fldDisplayName.Value%></strong><%=TXT_COLON & intRecordCount & TXT_RECORDS_TO_IMPORT%></p>
<%
	Response.Flush()
	If intRecordCount > 0 Then
%>
<p><%=TXT_IMPORT_STARTED_AT & Time()%>
<br>
<%
		Response.Flush()

		Set fldERID = .Fields("ER_ID")
		Set fldNUM = .Fields("NUM")
		Set fldEXTERNALID = .Fields("EXTERNAL_ID")
		Set fldOWNER = .Fields("OWNER")
		Set fldHASE = .Fields("HAS_ENGLISH")
		Set fldHASF = .Fields("HAS_FRENCH")
		Set fldPrivacyProfile = .Fields("PRIVACY_PROFILE")
		Set fldDATA = .Fields("DATA")
		Set fldREPORT = .Fields("REPORT")
		Set fldIMPORTED = .Fields("IMPORTED")
		Set fldNUME = .Fields("NUME")
		Set fldNUMF = .Fields("NUMF")

		Call processAccessibilityA()
		Call processActivityInfoA()
		Call processAccreditationA()
		Call processAreasServedA()
		Call processAltOrgA()
		Call processBillingAddressA()
		Call processBusRoutesA()
		Call processContactA()
		Call processContractSignatureA()
		Call processCertificationA()
		Call processDistributionA()
		Call processExtraTextA()
		Call processExtraCheckListA()
		Call processExtraDateA()
		Call processExtraDropDownA()
		Call processExtraEmailA()
		Call processExtraRadioA()
		Call processExtraWWWA()
		Call processFeesA()
		Call processFiscalYearEndA()
		Call processFormerOrgA()
		Call processFundingA()
		Call processLanguagesA()
		Call processLocatedInA()
		Call processPublicationA()
		Call processHeadingA()
		Call processLocationServicesA()
		Call processMembershipTypeA()
		Call processNaicsA()
		Call processOrgLocationServiceA()
		Call processOtherAddressA()
		Call processPaymentTermsA()
		Call processPrefCurrencyA()
		Call processPrefPaymentMethodA()
		Call processQualityA()
		Call processRecordNoteA()
		Call processRecordTypeA()
		Call processSocialMediaA()
		Call processSchoolEscortA()
		Call processSchoolsInAreaA()
		Call processServiceLevelA()
		Call processSubjectsA()
		Call processTaxonomyA()
		Call processTypeOfCareA()
		Call processTypeOfProgramA()
		Call processVacancyInfoA()
		Call processWardA()
		Call NUMExistsConfig()

While Not .EOF
	bInsertEnglish = fldHASE And Application("Culture_" & CULTURE_ENGLISH_CANADIAN)
	bInsertFrench = fldHASF And Application("Culture_" & CULTURE_FRENCH_CANADIAN)

	xmlDoc.loadXML fldDATA.Value
	Set xmlNode = xmlDoc.selectSingleNode("/RECORD")
	If Not xmlNode Is Nothing Then

		Call makeGBLRecordCheck()

		If Not Nl(strQNUM) Then

			If fldOwnerConflict.Value = CNF_TAKE_NEW Then
				Call dicTableList("GBL").processField("RECORD_OWNER",Null,fldOwner.Value,True,FTYPE_TEXT)
			End If

			If fldImportSourceDb.Value Then
				Call dicTableList("GBLE").processField("SOURCE_DB",Null,strSourceDbEn,True,FTYPE_TEXT)
				Call dicTableList("GBLF").processField("SOURCE_DB",Null,strSourceDbFr,True,FTYPE_TEXT)
			End If

			If bHavePrivacyProfiles And Not bUnmappedPrivacySkipFields Then
				If Nl(fldPrivacyProfile.Value) Then
					If fldPrivacyProfileConflict.Value = CNF_TAKE_NEW Then
						Call dicTableList("GBL").processField("PRIVACY_PROFILE",Null,"NULL",True,FTYPE_NUMBER)
					End If
				ElseIf dicPrivacyProfileMap.Exists(fldPrivacyProfile.Value) Then
					If fldPrivacyProfileConflict.Value = CNF_TAKE_NEW Then
						Call dicTableList("GBL").processField("PRIVACY_PROFILE",Null,dicPrivacyProfileMap(fldPrivacyProfile.Value),True,FTYPE_NUMBER)
					Else
						Call dicTableList("GBL").processField("PRIVACY_PROFILE",Null,"ISNULL(PRIVACY_PROFILE," & dicPrivacyProfileMap(fldPrivacyProfile.Value) & ")",True,FTYPE_NUMBER)
					End If
				End If
			End If

			strReport = vbNullString
			strReportCon = vbNullString

			Call processAccessibilityB()
			Call processActivityInfoB()
			Call processAreasServedB()
			Call processBillingAddressB()
			Call processBusRoutesB()
			Call processContactB()
			Call processContractSignatureB()
			Call processDeletedByA()
			Call processDistributionB()
			Call processExtraTextB()
			Call processExtraCheckListB()
			Call processExtraDateB()
			Call processExtraDropDownB()
			Call processExtraEmailB()
			Call processExtraRadioB()
			Call processExtraWWWB()
			Call processFeesB()
			Call processFundingB()
			Call processLanguagesB()
			Call processMembershipTypeB()
			Call processNaicsB()
			Call processOtherAddressB()
			Call processPublicationB()
			Call processRecordNoteB()
			Call processSocialMediaB()
			Call processSchoolEscortB()
			Call processSchoolsInAreaB()
			Call processServiceLevelB()
			Call processSubjectsB()
			Call processTaxonomyB()
			Call processTypeOfCareB()
			Call processVacancyInfoB()

			Dim bSkipField

			For Each xmlChildNode In xmlNode.childNodes
				strImportFld = xmlChildNode.nodeName
				bSkipField = False
				If bHavePrivacyProfiles And bUnmappedPrivacySkipFields Then
					If Not Nl(fldPrivacyProfile.Value) And _
							Not dicPrivacyProfileMap.Exists(fldPrivacyProfile.Value) Then
						' A broken import with undeclared privacy profiles can cause the next line to fail
						Set dicPrivacyProfileFields = dicPrivacyProfiles(fldPrivacyProfile.Value)
						If dicPrivacyProfileFields.Exists(strImportFld) Then
							bSkipField = True
						End If
					End If
				End If

				If Not bSkipField Then
					Select Case strImportFld
						Case "ACCESSIBILITY"
							Call processAccessibilityC()
						Case "ACCREDITED"
							Call processAccreditationB()
						Case "ACTIVITY_INFO"
							Call processActivityInfoC()
						Case "AFTER_HRS_PHONE"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "ALT_ORG"
							Call processAltOrgB()
						Case "APPLICATION"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "AREAS_SERVED"
							Call processAreasServedC()
						Case "BEST_TIME_TO_CALL"
							Call processCCRDField(Null,Null,FTYPE_TEXT)
						Case "BILLING_ADDRESSES"
							Call processBillingAddressC()
						Case "BOUNDARIES"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "BUS_ROUTES"
							Call processBusRoutesC()
						Case "CC_LICENSE_INFO"
							Call processCCLicenseInfo()
						Case "CERTIFIED"
							Call processCertificationB()
						Case "COLLECTED_BY"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "COLLECTED_DATE"
							Call processGBLDField(Null,Null,FTYPE_DATE)
						Case "COMMENTS"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "CONTACT_1"
							Call processContactC()
						Case "CONTACT_2"
							Call processContactC()
						Case "CONTRACT_SIGNATURE"
							Call processContractSignatureC()
						Case "CORP_REG_NO"
							Call processCICField(Null,Null,FTYPE_TEXT)
						Case "CREATED_BY"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "CREATED_DATE"
							Call processGBLDField(Null,Null,FTYPE_DATE)
						Case "CRISIS_PHONE"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "DATES"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "DD_CODE"
							Call processCICField(Null,Null,FTYPE_TEXT)
						Case "DELETED_BY"
							Call processDeletedByB()
						Case "DELETION_DATE"
							Call processDeletionDate()
						Case "DESCRIPTION"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "DISTRIBUTION"
							Call processDistributionC()
						Case "DOCUMENTS_REQUIRED"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "EXTERNAL_ID"
							If Nl(fldEXTERNALID) Then
								Call processGBLField(Null,Null,FTYPE_TEXT)
							End If
						Case "E_MAIL"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "ELECTIONS"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "ELIGIBILITY"
							Call processEligibility()
						CASE "EMAIL_UPDATE_DATE"
							Call processGBLField(Null,Null,FTYPE_DATE)
						Case "EMPLOYEES"
							Call processEmployeesField()
						Case "ESTABLISHED"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "EXEC_1"
							Call processContactC()
						Case "EXEC_2"
							Call processContactC()
						Case "EXTRA"
							Call processExtraTextC()
						Case "EXTRA_CHECKLIST"
							Call processExtraCheckListC()
						Case "EXTRA_CONTACT_A"
							Call processContactC()
						Case "EXTRA_DATE"
							Call processExtraDateC()
						Case "EXTRA_DROPDOWN"
							Call processExtraDropDownC()
						Case "EXTRA_EMAIL"
							Call processExtraEmailC()
						Case "EXTRA_RADIO"
							Call processExtraRadioC()
						Case "EXTRA_WWW"
							Call processExtraWWWC()
						Case "FAX"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "FEES"
							Call processFeesC()
						Case "FISCAL_YEAR_END"
							Call processFiscalYearEndB()
						Case "FORMER_ORG"
							Call processFormerOrgB()
						Case "FUNDING"
							Call processFundingC()
						Case "GEOCODE"
							Call processGeocode()
						Case "HOURS"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "INTERNAL_MEMO"
							Call processRecordNoteC(xmlChildNode.nodeName)
						Case "INTERSECTION"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "LANGUAGES"
							Call processLanguagesC()
						Case "LEGAL_ORG"
							Call processOrgNameField("LO_PUBLISH")
						Case "LOCATED_IN_CM"
							Call processLocatedInB()
						Case "LOCATION_DESCRIPTION"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "LOCATION_NAME"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "LOCATION_SERVICES"
							Call processLocationServicesB()
						Case "LOGO_ADDRESS"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "MAIL_ADDRESS"
							Call processAddress("MAIL")
						Case "MEETINGS"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "MEMBERSHIP"
							Call processMembershipTypeC()
						Case "MODIFIED_BY"
							'Call processGBLField(Null,Null,FTYPE_TEXT)
						Case "MODIFIED_DATE"
							'Call processGBLField(Null,Null,FTYPE_DATE)
						Case "NAICS"
							Call processNaicsC()
						Case "NO_UPDATE_EMAIL"
							Call processGBLField(Null,Null,FTYPE_NUMBER)
						Case "NON_PUBLIC"
							Call processNonPublicField()
						Case "OCG_NO"
							Call processCICField(Null,Null,FTYPE_TEXT)
						Case "OFFICE_PHONE"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "ORG_DESCRIPTION"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "ORG_LEVEL_1"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "ORG_LEVEL_2"
							Call processOrgNameField("O2_PUBLISH")
						Case "ORG_LEVEL_3"
							Call processOrgNameField("O3_PUBLISH")
						Case "ORG_LEVEL_4"
							Call processOrgNameField("O4_PUBLISH")
						Case "ORG_LEVEL_5"
							Call processOrgNameField("O5_PUBLISH")
						Case "ORG_LOCATION_SERVICE"
							Call processOrgLocationServiceB()
						Case "ORG_NUM"
							Call processOrgNUM()
						Case "OTHER_ADDRESSES"
							Call processOtherAddressC()
						Case "PAYMENT_TERMS"
							Call processPaymentTermsB()
						Case "PREF_CURRENCY"
							Call processPrefCurrencyB()
						Case "PREF_PAYMENT_METHOD"
							Call processPrefPaymentMethodB()
						Case "PRINT_MATERIAL"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "PUBLIC_COMMENTS"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "PUBLICATION"
							Call processPublicationC()
						Case "QUALITY"
							Call processQualityB()
						Case "RECORD_TYPE"
							Call processRecordTypeB()
						Case "RESOURCES"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "SCHOOL_ESCORT"
							Call processSchoolEscortC()
						Case "SCHOOLS_IN_AREA"
							Call processSchoolsInAreaC()
						Case "SERVICE_NAME_LEVEL_1"
							Call processOrgNameField("S1_PUBLISH")
						Case "SERVICE_NAME_LEVEL_2"
							Call processOrgNameField("S2_PUBLISH")
						Case "SERVICE_LEVEL"
							Call processServiceLevelC()
						Case "SITE_ADDRESS"
							Call processAddress("SITE")
						Case "SITE_LOCATION"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "SOCIAL_MEDIA"
							Call processSocialMediaC()
						Case "SORT_AS"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "SOURCE"
							Call processSourceField()
						Case "SOURCE_FROM_ICAROL"
							Call processGBLField(Null,Null,FTYPE_NUMBER)
						Case "SPACE_AVAILABLE"
							Call processSpaceAvailable()
						Case "SUBJECTS"
							Call processSubjectsC()
						Case "SUBSIDY"
							Call processCCRField(Null,Null,FTYPE_NUMBER)
						Case "SUBMIT_CHANGES_TO"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
							Call processGBLDField("SUBMIT_CHANGES_TO_PROTOCOL", "P", FTYPE_TEXT)
						Case "SUP_DESCRIPTION"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "TAX_REG_NO"
							Call processCICField(Null,Null,FTYPE_TEXT)
						Case "TAXONOMY"
							Call processTaxonomyC()
						Case "TDD_PHONE"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "TOLL_FREE_PHONE"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "TRANSPORTATION"
							Call processCICDField(Null,Null,FTYPE_TEXT)
						Case "TYPE_OF_CARE"
							Call processTypeOfCareC()
						Case "TYPE_OF_PROGRAM"
							Call processTypeOfProgramB()
						Case "UPDATE_DATE"
							Call processGBLDField(Null,Null,FTYPE_DATE)
						Case "UPDATE_EMAIL"
							Call processGBLField(Null,Null,FTYPE_TEXT)
						Case "UPDATE_HISTORY"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "UPDATE_SCHEDULE"
							Call processGBLDField(Null,Null,FTYPE_DATE)
						Case "UPDATED_BY"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case "VACANCY_INFO"
							Call processVacancyInfoC()
						Case "VOLCONTACT"
							Call processContactC()
						Case "WARD"
							Call processWardB()
						Case "WCB_NO"
							Call processCICField(Null,Null,FTYPE_TEXT)
						Case "WWW_ADDRESS"
							Call processGBLDField(Null,Null,FTYPE_TEXT)
						Case Else
							Call addImportNote("[" & strImportFld & "] " & TXT_UNKNOWN_FIELD)
					End Select
				End If
			Next

			strSQL = vbNullString

			For Each indTable In dicTableList
				If dicTableList(indTable).Used Then
					If Not dicTableList(indTable).Created Then
						strSQL = strSQL & vbCrLf & _
							"EXEC sp_CIC_ImportEntry_" & indTable & "_Check_i " & strQNUM
					End If
					strSQL = strSQL & vbCrLf & _
							"UPDATE " & dicTableList(indTable).TableName & " SET " & dicTableList(indTable).UpdateList & vbCrLf & _
								"WHERE NUM=" & strQNUM & StringIf(Not Nl(dicTableList(indTable).LangID)," AND LangID=" & dicTableList(indTable).LangID)
				End If
			Next

			If Not Nl(fldQAutoAddPubs) Then
				If IsIDList(fldQAutoAddPubs) Then
					strSQL = strSQL & vbCrLf & _
						"INSERT INTO CIC_BT_PB (NUM,PB_ID)" & vbCrLf & _
						"SELECT bt.NUM, pb.PB_ID" & vbCrLf & _
						"FROM GBL_BaseTable bt, CIC_Publication pb" & vbCrLf & _
						"WHERE bt.NUM=" & strQNUM & " AND pb.PB_ID IN (" & fldQAutoAddPubs & ")" & vbCrLf & _
						"	AND NOT EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=pb.PB_ID)"
				End If
			End If

			strSQL = "SET NOCOUNT ON" & vbCrLf & "BEGIN TRY "  & vbCrLf & "BEGIN TRANSACTION" & vbCrLf & strSQL & vbCrLf & _
				"EXEC sp_GBL_BaseTable_History_i " & QsNl("Import - " & user_strMod) & "," & strNowInsert & "," & strQNUM & "," & QsNl(fldFieldList.Value) & ",0,NULL" & vbCrLf & "COMMIT TRANSACTION" & vbCrLf & _
				"END TRY" & vbCrLf & _
				"BEGIN CATCH" & vbCrLf & _
				"	IF @@TRANCOUNT > 0 BEGIN" & vbCrLf & _
				"		ROLLBACK TRAN" & vbCrLf & _
				"	END" & vbCrLf & _
				"	DECLARE @ErrorMessage NVARCHAR(4000);" & vbCrLf & _
				"	DECLARE @ErrorSeverity INT;" & vbCrLf & _
				"	DECLARE @ErrorState INT;" & vbCrLf & _
				"	SET @ErrorMessage = ERROR_MESSAGE()" & vbCrLf & _
				"	SET @ErrorSeverity = ERROR_SEVERITY()" & vbCrLf & _
				"	SET @ErrorState = ERROR_STATE();" & vbCrLf & _
				"	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState) WITH SETERROR" & vbCrLf & _
				"END CATCH"


			'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
			'Response.Flush()


			'On Error Resume Next

			Dim cmdUpdate, bIsError
			bIsError = False
			Set cmdUpdate = Server.CreateObject("ADODB.Command")
			With cmdUpdate
				.ActiveConnection = getCurrentAdminCnn()
				.CommandType = adCmdText
				.CommandText = strSQL
				.CommandTimeout = 0
				On Error Resume Next
				.Execute
				If Err.Number <> 0 Or .ActiveConnection.Errors.Count > 0 Then
					On Error Goto 0
					bIsError = True
					Dim strInsSQLError, strErrorDetails, objErr
					strErrorDetails =  Ns(Err.Number) & "<br>" & _
										Ns(Err.Source) & "<br>" &  Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED) & "<br>"
					For Each objErr in .ActiveConnection.Errors
						strErrorDetails = strErrorDetails & "Description: " & Ns(objErr.Description) & "<br>" & _
										"Help context: " & Ns(objErr.HelpContext) & "<br>" & _
										"Help file: "  & Ns(objErr.HelpFile) & "<br>" & _
										"Native error: " & Ns(objErr.NativeError) & "<br>" & _
										"Error number: " & Ns(objErr.Number) & "<br>" & _
										"Error source: " & Ns(objErr.Source) & "<br>" & _
										"SQL state: " & Ns(objErr.SQLState) & "<br>"
					Next
					Err.Clear
					Call handleError("<br>Error Processing " & fldNUM.Value & ":<br>" & strErrorDetails & "<br>", vbNullString, vbNullString)
					Response.Flush()
				End If
				On Error GoTo 0
			End With

			If Not Nl(strReport) Then
				fldREPORT.Value = strReport
			ElseIf Not Nl(fldREPORT.Value) Then
				' strReport is Null and fldREPORT.Value Is not Null. This is a retry
				fldREPORT.Value = Null
			End If

			If Not bIsError Then
			    fldIMPORTED.Value = SQL_TRUE
				If Nl(strReport) Then
					fldDATA.Value = Null
				End If

				If Not bQ Or .AbsolutePosition Mod 50 = 0 Then
					Response.Write(". ")
					Response.Flush()
					bPrintedADot = True
				End If
			End If
		End If
	End If
	.Update
	.MoveNext
Wend

Set cmdUpdate = Nothing

Set cmdUpdate = Server.CreateObject("ADODB.Command")
With cmdUpdate
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "sp_CIC_SRCH_u"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Execute
End With
Set cmdUpdate = Nothing

%>
<%If bPrintedADot Then%><br><%End If%>
<%=TXT_IMPORT_FINISHED_AT & Time()%></p>
<%
	End If

	If bQ Then
		fldQDate.Value = NULL
		fldQBy.Value = NULL
		fldOwnerConflict.Value = NULL
		fldImportSourceDb.Value = SQL_FALSE
		rsImportEntry.Update
	End If

	.Close
End With

rsImportEntry.MoveNext
Wend

rsImportEntry.Close

Set rsImportEntry = Nothing
Set cmdImportEntry = Nothing

Set rsListImport = Nothing
Set cmdListImport = Nothing

Set rsCICRecordCheck = Nothing
Set cmdCICRecordCheck = Nothing

Set rsCCRRecordCheck = Nothing
Set cmdCCRRecordCheck = Nothing

%>
<p>[ <a href="<%=makeLinkB("import.asp")%>"><%=TXT_RETURN_TO_IMPORT%></a> ]</p>
<%
Call makePageFooter(False)
%>

<!--#include file="../includes/core/incClose.asp" -->
