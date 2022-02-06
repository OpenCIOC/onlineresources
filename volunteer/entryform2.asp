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
Call setPageInfo(True, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtAgencyContact.asp" -->
<!--#include file="../text/txtCommonForm.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtEntryForm2.asp" -->
<!--#include file="../text/txtFeedbackCommon.asp" -->
<!--#include file="../text/txtFormDataCheck.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtRecordPages.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="../includes/update/incEventSchedule.asp" -->
<!--#include file="../includes/update/incEntryFormProcessGeneral.asp" -->
<!--#include file="../includes/validation/incFormDataCheck.asp" -->
<!--#include file="../includes/core/incSendMail.asp" -->
<%
'On Error Resume Next

Dim strInsertIntoBT, strInsertValueBT, strUpdateListBT
Dim strInsertIntoBTD, strInsertValueBTD, strUpdateListBTD

Dim strInsSQL, strExtraSQL

Sub getAgeFields()
	Dim decMinAge, decMaxAge

	Call addChangeField(fldName.Value, Null)

	decMinAge = Trim(Request("MIN_AGE"))
	decMaxAge = Trim(Request("MAX_AGE"))

	Call checkDouble(TXT_MIN_AGE,decMinAge)
	Call checkDouble(TXT_MAX_AGE,decMaxAge)

	If Nl(strErrorList) Then
		Call addBTInsertField("MIN_AGE",decMinAge,False,strUpdateListBT,strInsertIntoBT,strInsertValueBT)
		Call addBTInsertField("MAX_AGE",decMaxAge,False,strUpdateListBT,strInsertIntoBT,strInsertValueBT)
	End If
End Sub

Sub getMinimumHoursFields()
	Dim intMinHours, intMinHoursPer

	Call addChangeField(fldName.Value, Null)

	intMinHours = Trim(Request("MINIMUM_HOURS"))
	intMinHoursPer = Trim(Request("MINIMUM_HOURS_PER"))

	Call checkDouble(TXT_MIN_HOURS,intMinHours)
	Call checkID(TXT_MIN_HOURS_PER,intMinHoursPer)

	If Nl(strErrorList) Then
		Call addBTInsertField("MINIMUM_HOURS",intMinHours,False,strUpdateListBT,strInsertIntoBT,strInsertValueBT)
		Call addBTInsertField("MINIMUM_HOURS_PER",intMinHoursPer,True,strUpdateListBT,strInsertIntoBT,strInsertValueBT)
	End If
End Sub

Sub getNUM()
	strNUM = UCase(TrimAll(Request("NUM")))
	If Nl(strNUM) Then
		strNUM = Null
		Call checkAddValidationError(TXT_ORG_RECORD_NUMBER_BLANK)
	Else
		If Not IsNUMType(strNUM) Then
			Call checkAddValidationError(Server.HTMLEncode(strNUM) & " " & TXT_ORG_RECORD_NUMBER_INVALID)
		End If
		If Nl(strErrorList) Then
			Dim cmdCheckNUM, rsCheckNUM
			Set cmdCheckNUM = Server.CreateObject("ADODB.Command")
			With cmdCheckNUM
				.ActiveConnection = getCurrentAdminCnn()
				.CommandText = "dbo.sp_GBL_UCheck_NUM"
				.CommandType = adCmdStoredProc
				.CommandTimeout = 0
				.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append .CreateParameter("@RSN", adInteger, adParamInput, 4, Null)
				.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
				.Parameters.Append .CreateParameter("@EXTERNAL_ID", adVarChar, adParamInput, 50, Null)
				.Parameters.Append .CreateParameter("@SOURCE_DB_CODE", adVarChar, adParamInput, 20, Null)
				.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, Null)
			End With
			Set rsCheckNUM = cmdCheckNUM.Execute
			Set rsCheckNUM = rsCheckNUM.NextRecordset
			If cmdCheckNUM.Parameters("@RETURN_VALUE").Value = 0 Then
				Call checkAddValidationError(Replace(TXT_ORG_RECORD_NUMBER_NOT_EXIST, "[NUM]", Server.HTMLEncode(strNUM)))
			ElseIf Err.Number <> 0 Then
				Call checkAddValidationError(TXT_ORG_RECORD_NUMBER_ERROR)
			End If
		End If		
		If Nl(strErrorList) Then
			If addBTInsertField("NUM",strNUM,True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
				Call addChangeField("NUM", Null)
			End If
		End If
	End If
End Sub

Sub getVNUM()
	strVNUM = UCase(Trim(Request("VNUM")))
	If strVNUM <> strOldVNUM Or Nl(strNum) Or bNew Then
		If Nl(strVNUM) And Not Request("AutoAssignVNUM") = "on" Then
			strErrorList = strErrorList & "<li>" & TXT_RECORD_NUMBER_BLANK & "</li>"
		ElseIf Not Nl(strVNUM) And Not reEquals(strVNUM,"V-([A-Z]){3}([0-9]){4,5}",False,False,True,False) Then
			strErrorList = strErrorList & "<li>" & TXT_RECORD_NUMBER_INVALID & "</li>"
		Else
			Dim cmdCheckVNUM, rsCheckVNUM
			Set cmdCheckVNUM = Server.CreateObject("ADODB.Command")
			With cmdCheckVNUM
				.ActiveConnection = getCurrentAdminCnn()
				.CommandText = "dbo.sp_VOL_UCheck_VNUM"
				.CommandType = adCmdStoredProc
				.CommandTimeout = 0
				.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append .CreateParameter("@OPID", adInteger, adParamInput, 4, intOPID)
				.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInputOutput, 10, Nz(strVNUM,Null))
				.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, Nz(Trim(Request("RECORD_OWNER")),user_strAgency))
			End With
			Set rsCheckVNUM = cmdCheckVNUM.Execute
			Set rsCheckVNUM = rsCheckVNUM.NextRecordset
			If cmdCheckVNUM.Parameters("@RETURN_VALUE").Value <> 0 Then
				strErrorList = strErrorList & "<li>" & TXT_RECORD_NUMBER_USED & strVNUM & ".</li>"	
			ElseIf Err.Number <> 0 Then
				strErrorList = strErrorList & "<li>" & TXT_RECORD_NUMBER_ERROR & "</li>"
			Else
				strVNUM = cmdCheckVNUM.Parameters("@VNUM").Value
			End If
		End If
		If Nl(strErrorList) And Not bNew Then
			If addBTInsertField("VNUM",strVNUM,True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
				Call addChangeField("VNUM", Null)
			End If
		End If
	End If
End Sub

Sub getScheduleFields()
	Dim strNotes, strMorning, strAfternoon, strEvening, strTime, bUpdateHistory
	strNotes = Trim(Request("SCHEDULE_NOTES"))
	bUpdateHistory = False
	Dim aShorts, indShort
	aShorts = Array("M","TU","W","TH","F","ST","SN")
	Call checkLength(TXT_SCHEDULE_NOTES,strNotes,2000)
	If Nl(strErrorList) Then
		For each indShort In aShorts
			strMorning = "SCH_" & indShort & "_Morning"
			strAfternoon = "SCH_" & indShort & "_Afternoon"
			strEvening = "SCH_" & indShort & "_Evening"
			strTime = "SCH_" & indShort & "_Time"
			If addBTInsertField(strMorning, _
					IIf(Request(strMorning)="on",SQL_TRUE,SQL_FALSE),False, _
					strUpdateListBT,strInsertIntoBT,strInsertValueBT) Or _
					addBTInsertField(strAfternoon, _
					IIf(Request(strAfternoon)="on",SQL_TRUE,SQL_FALSE),False, _
					strUpdateListBT,strInsertIntoBT,strInsertValueBT) Or _
					addBTInsertField(strEvening, _
					IIf(Request(strEvening)="on",SQL_TRUE,SQL_FALSE),False, _
					strUpdateListBT,strInsertIntoBT,strInsertValueBT) Or _
					addBTInsertField(strTime, _
					Trim(Request(strTime)),True, _
					strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) Then
				bUpdateHistory = True
			End If
		Next
		If bUpdateHistory Or addBTInsertField("SCHEDULE_NOTES",strNotes,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) Then
			Call addChangeField(fldName.Value, Null)
		End If
	End If
End Sub

Sub getSourceFields()
	Dim dPub
	dPub = Trim(Request("SOURCE_PUBLICATION_DATE"))
	Call checkDate(TXT_SOURCE_PUBLICATION_DATE,dPub)
	Call checkEmail(TXT_SOURCE_EMAIL,Trim(Request("SOURCE_EMAIL")))

	If Nl(strErrorList) Then
		Call addBTInsertField("SOURCE_PUBLICATION_DATE",dPub,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
	End If

	If processStrFldArray(Array("SOURCE_PUBLICATION", _
			"SOURCE_NAME", _
			"SOURCE_TITLE", _
			"SOURCE_ORG", _
			"SOURCE_PHONE", _
			"SOURCE_FAX", _
			"SOURCE_EMAIL"), _
			strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) Then
		Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
	End If
End Sub

Sub getStartDateFields()
	Dim sDFirst,sDLast
	sDFirst = Trim(Request("START_DATE_FIRST"))
	sDLast = Trim(Request("START_DATE_LAST"))
	Call checkDate(TXT_START_DATE_FIRST,sDFirst)
	Call checkDate(TXT_START_DATE_LAST,sDLast)
	
	If Nl(strErrorList) Then
		If addBTInsertField("START_DATE_FIRST",sDFirst,True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) Or _
				addBTInsertField("START_DATE_LAST",sDLast,True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
			Call addChangeField(fldName.Value, Null)
		End If
	End If
End Sub

Sub getPositionTitle()
	Dim strPositionTitle
	strPositionTitle = Trim(Request("POSITION_TITLE"))
	If Nl(strPositionTitle) Then
		Call checkAddValidationError(TXT_POSITION_TITLE_REQUIRED)
	Else
		If addBTInsertField("POSITION_TITLE",strPositionTitle,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) Then
			Call addChangeField("POSITION_TITLE", g_objCurrentLang.LangID)
		End If
	End If
End Sub

Sub getCommunitySetSQL()
	Dim strIDList, aIDs, indID
	strIDList = Trim(Request("CommunitySetID"))
	If Nl(strIDList) Then
		Call checkAddValidationError(TXT_COMMUNITY_SET_REQUIRED)
	End If
	If Nl(strErrorList) Then
		strExtraSQL = strExtraSQL & vbCrLf & "EXEC sp_VOL_VNUMSetCommunitySetIDs_u " & g_intMemberID & ",@VNUM," & Qs(Nz(strIDList,g_intViewTypeVOL),SQUOTE)
		Call addChangeField("COMMUNITY_SETS", Null)
	End If
End Sub

Sub getNumNeededSQL()
	Dim strNotes, strIDList, aIDs, indID, intNumPos, intNumPosTotal

	Call addChangeField(fldName.Value, Null)

	strNotes = Trim(Request("NUM_NEEDED_NOTES"))
	Call checkLength(TXT_NUMBER_NEEDED_NOTES,strNotes,2000)
	strIDList = Trim(Request("CM_ID"))
	intNumPosTotal = Trim(Request("NUM_NEEDED_TOTAL"))
	Call checkInteger(TXT_NUMBER_OF_OPPORTUNITIES & " - " & TXT_TOTAL,intNumPosTotal)

	If Nl(strIDList) Or Not IsIDList(strIDList) Then
		Call checkAddValidationError(TXT_COMMUNITY_REQUIRED)
		strIDList = Null
	End If
	
	If Nl(strErrorList) Then
		Call addBTInsertField("NUM_NEEDED_NOTES",strNotes,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
		Call addBTInsertField("NUM_NEEDED_TOTAL",intNumPosTotal,False,strUpdateListBT,strInsertIntoBT,strInsertValueBT)
	
		If Not Nl(strIDList) Then
			aIDs = Split(strIDList,",")
			For Each indID In aIDs
				indID = Trim(indID)
				If Not Nl(indID) Then
					intNumPos = Trim(Request("CM_NUM_NEEDED_" & indID))
					If Nl(intNumPos) Then
						intNumPos = "NULL"
					Else
						Call checkInteger(TXT_NUMBER_OF_OPPORTUNITIES,intNumPos)
						If Nl(strErrorList) Then
							intNumPos = CInt(intNumPos)
							If intNumPos <= 0 Then
								intNumPos = "NULL"
							End If
						End If
					End If
	
					If Nl(strErrorList) Then
						strExtraSQL = strExtraSQL & vbCrLf & _
						"IF EXISTS(SELECT * FROM VOL_OP_CM WHERE VNUM=@VNUM AND CM_ID=" & indID & ") BEGIN " & vbCrLf & _
						"	UPDATE VOL_OP_CM SET NUM_NEEDED=" & intNumPos & vbCrLf & _
						"		WHERE VNUM=@VNUM AND CM_ID=" & indID & vbCrLf & _
						"END ELSE BEGIN " & vbCrLf & _
						"	INSERT INTO VOL_OP_CM (VNUM,CM_ID,NUM_NEEDED) " & vbCrLf & _
						"	SELECT @VNUM,cm.CM_ID," & intNumPos & vbCrLf & _
						"	FROM GBL_Community cm WHERE cm.CM_ID=" & indID & vbCrLf & _
						"END" & vbCrLf & _
						"DELETE VOL_OP_CM" & vbCrLf & _
						"	WHERE VNUM=@VNUM AND CM_ID NOT IN (" & strIDList & ")"
					End If
				End If
				If Not Nl(strErrorList) Then
					Exit For
				End If
			Next
		End If
	End If
End Sub

Sub getStdCheckListSQL(strIDType, bCheckNotes, strFieldName, strIDListName, strNotesPrefix)
	Dim strNotes, strIDList, aIDS, indID, strItemNote

	Call addChangeField(fldName.Value, Null)
	
	If Not Nl(strNotesPrefix) Then
		strNotes = Trim(Request(strNotesPrefix & "_NOTES"))
		Call checkLength(fldDisplay.Value & " - " & TXT_NOTES,strNotes,2000)	
		Call addBTInsertField(strNotesPrefix & "_NOTES",strNotes,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
	End If

	strIDList = Trim(Request(Nz(strIDListName,strIDType & "_ID")))
	If Not (Nl(strIDList) Or IsIDList(strIDList)) Then
		strErrorList = strErrorList & "<li>" & TXT_INVALID_ID & fldDisplay.Value & " -> " & Server.HTMLEncode(strIDList) & "</li>"
	End If
	
	If Nl(strErrorList) Then
		strExtraSQL = strExtraSQL & vbCrLf & "EXEC sp_VOL_VNUMSet" & strIDType & "IDs_u " & StringIf(Not Nl(strFieldName),QsNNl(strFieldName) & ",") & "@VNUM," & Qs(strIDList,SQUOTE)

		If Not Nl(strIDList) Then		
			If bCheckNotes Then
				aIDs = Split(strIDList,",")
				For Each indID In aIDs
					indID = Trim(indID)
					If Not Nl(indID) Then
						strItemNote = Trim(Request(strIDType & "_NOTES_" & indID))
						Call checkLength(fldDisplay.Value & " - " & TXT_NOTES,strItemNote,255)
						strExtraSQL = strExtraSQL & vbCrLf & _
							"SET @OP_REL_ID=NULL" & vbCrLf & _
							"SELECT @OP_REL_ID=OP_" & strIDType & "_ID FROM VOL_OP_" & strIDType & " WHERE VNUM=@VNUM AND " & strIDType & "_ID=" & indID
						If Nl(strItemNote) Then
							strExtraSQL = strExtraSQL & vbCrLf & _
								"DELETE FROM VOL_OP_" & strIDType & "_Notes WHERE OP_" & strIDType & "_ID=@OP_REL_ID AND LangID=@@LANGID"
						Else
							strExtraSQL = strExtraSQL & vbCrLf & _
								"SET @CheckListNotes=" & QsNl(strItemNote) & vbCrLf & _
								"IF EXISTS(SELECT * FROM VOL_OP_" & strIDType & "_Notes WHERE OP_" & strIDType & "_ID=@OP_REL_ID AND LangID=@@LANGID) BEGIN" & vbCrLf & _
								"	UPDATE VOL_OP_" & strIDType & "_Notes SET Notes=@CheckListNotes" & vbCrLf & _
								"		WHERE OP_" & strIDType & "_ID=@OP_REL_ID AND LangID=@@LANGID AND Notes<>@CheckListNotes COLLATE Latin1_General_100_CS_AS" & vbCrLf & _
								"END ELSE IF @OP_REL_ID IS NOT NULL BEGIN" & vbCrLf & _
								"	INSERT INTO VOL_OP_" & strIDType & "_Notes (OP_" & strIDType & "_ID,LangID,Notes)" & vbCrLF & _
								"	VALUES(@OP_REL_ID,@@LANGID,@CheckListNotes)" & vbCrLf & _
								"END"
						End If
					End If
				Next
			End If
		End If
	End If
End Sub

Sub getExtraFieldSQL(strFldName,strNewValue,strExtraFieldType, strNewProtocol)
	Dim strOldValue, bNoChange, strTableName, bFieldLangID, strProtocol, bHasProtocol, strNewWebAddr

	strProtocol = vbNullString
	bHasProtocol = False
	If strExtraFieldType = "w" Then
		strNewWebAddr = strNewValue
		bHasProtocol = True
		strNewValue = strNewProtocol & strNewValue
	End If

	bNoChange = False

	If Nl(strErrorList) Then
		If Not bNew Then
			strOldValue = rsOrg.Fields(strFldName)
			If bHasProtocol And Not Nl(strOldValue) Then
				strProtocol = rsOrg.Fields(strFldName & "_PROTOCOL")
				If Nl(strProtocol) Then
					strProtocol = "http://"
				End If
				strOldValue = strProtocol & strOldValue
			End If
			If Not IsNull(strOldValue) Then
				strOldValue = CStr(strOldValue)
			End If
			If strNewValue <> strOldValue Or _
				(Nl(strOldValue) And Not Nl(strNewValue)) Or _
				(Nl(strNewValue) And Not Nl(strOldValue)) Then 
				If Not Nl(strOldValue) And Not Nl(strNewValue) Then
					If strExtraFieldType = "d" Then
						If DateString(strNewValue,True) = DateString(strOldValue,True) Then
							bNoChange = True
						End If
					ElseIf strExtraFieldType = "r" Then
						If strOldValue = "False" Then
							If IsNumeric(strNewValue) Then
								If CInt(strNewValue) = SQL_FALSE Then
									bNoChange = True
								End If
							End If
						ElseIf strOldValue = "True" Then
							If IsNumeric(strNewValue) Then
								If CInt(strNewValue) = SQL_TRUE Then
									bNoChange = True
								End If
							End If
						End If
					End If
				End If
			Else
				bNoChange = True
			End If
		End If
		
		If bNoChange Then
			strNewValue = Null
		ElseIf Nl(strNewValue) Then
			strNewValue = "NULL"
		ElseIf strExtraFieldType = "r" Then
			strNewValue = CInt(strNewValue)
		Else
			strNewValue = QsNl(strNewValue)
		End If
		
		If Not Nl(strNewValue) Then
			bFieldLangID = False
			Select Case strExtraFieldType
				Case "a"
					strTableName = "VOL_OP_EXTRA_DATE"
				Case "d"
					strTableName = "VOL_OP_EXTRA_DATE"
				Case "e"
					strTableName = "VOL_OP_EXTRA_EMAIL"
					bFieldLangID = True
				Case "r"
					strTableName = "VOL_OP_EXTRA_RADIO"
				Case "t"
					strTableName = "VOL_OP_EXTRA_TEXT"
					bFieldLangID = True
				Case "w"
					strTableName = "VOL_OP_EXTRA_WWW"
					bFieldLangID = True
					strNewValue = QsNl(strNewWebAddr)
					strNewProtocol = QsNl(strNewProtocol)
			End Select
			If strNewValue = "NULL" Then
				strExtraSQL = strExtraSQL & vbCrLf & _
					"DELETE FROM " & strTableName & " WHERE FieldName=" & QsNl(strFldName) & _
						" AND VNUM=@VNUM" & StringIf(bFieldLangID," AND LangID=@@LANGID")
			Else
				strExtraSQL = strExtraSQL & vbCrLf & _
					"IF EXISTS(SELECT * FROM " & strTableName & " WHERE FieldName=" & QsNl(strFldName) & _
						" AND VNUM=@VNUM" & StringIf(bFieldLangID," AND LangID=@@LANGID") & ") BEGIN" & vbCrLf & _
						" UPDATE " & strTableName & " SET [Value]=" & strNewValue & StringIf(bHasProtocol, ",[Protocol]=" & strNewProtocol) & " WHERE FieldName=" & QsNl(strFldName) & _
						" AND VNUM=@VNUM" & StringIf(bFieldLangID," AND LangID=@@LANGID") & vbCrLf & _
					"END ELSE BEGIN" & vbCrLf & _
						"INSERT INTO " & strTableName & "(FieldName,VNUM," & StringIf(bFieldLangID,"LangID,") & StringIf(bHasProtocol, "[Protocol],") & "[Value])" & vbCrLf & _
						"VALUES (" & QsNl(strFldName) & ",@VNUM," & StringIf(bFieldLangID,"@@LangID,") & StringIf(bHasProtocol, strNewProtocol & ",") & strNewValue & ")" & vbCrLf & _
					"END"
			End If
			Call addChangeField(strFldName, g_objCurrentLang.LangID)
		End If
	End If
End Sub

Dim intOPID, _
	bRSError , _
	bOPIDError, _
	strUpdateLang, _
	objUpdateLang, _
	strRestoreCulture, _
	bNew, _
	strReferer, _
	strErrorList, _
	strNUM, _
	strVNUM, _
	strOldVNUM

bRSError = False
bOPIDError = False
bNew = False
intOPID = Trim(Request("OPID"))
strUpdateLang = Nz(Request("UpdateLn"),g_objCurrentLang.Culture)
strOldVNUM = Null

strReferer = Request.ServerVariables("HTTP_REFERER")
If Not reEquals(strReferer,"entryform.asp",True,False,False,False) Then
	Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
	Call handleError(TXT_UPDATE_REJECTED, vbNullString, vbNullString)
	Call makePageFooter(True)
	bOPIDError = True
End If

If Nl(intOPID) Then
	intOPID = Null
	bNew = True
End If

If bNew And Not user_bAddVOL Then
	Call securityFailure()
ElseIf user_intUpdateVOL = UPDATE_NONE Then
	Call securityFailure()
End If

If Not bNew Then
	If Not IsIDType(intOPID) Then
		Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
		Call handleError(TXT_INVALID_OPID & Server.HTMLEncode(intOPID) & ".", vbNullString, vbNullString)
		Call makePageFooter(True)
		bOPIDError = True
	Else
		intOPID = CLng(intOPID)
	End If
End If

If Not IsCulture(strUpdateLang) Then
	bRSNError = True
	Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
	Call handleError(TXT_INVALID_LANGUAGE & strUpdateLang & ".", vbNullString, vbNullString)
	Call makePageFooter(True)
Else
	Set objUpdateLang = create_language_object()
	objUpdateLang.setSystemLanguage(strUpdateLang)
	strRestoreCulture = g_objCurrentLang.Culture
	Call setSessionLanguage(objUpdateLang.Culture)
End If

If Not bOPIDError Then

Dim cmdFields, rsFields
Set cmdFields = Server.CreateObject("ADODB.Command")
With cmdFields
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandText = "sp_VOL_View_UpdateFields"
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, Null)
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
End With
Set rsFields = Server.CreateObject("ADODB.Recordset")
With rsFields
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFields
End With

If Err.Number <> 0 Then
	bRSError = True
	Call handleError(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
End If

Dim bEnforceReqFields

With rsFields
	If .EOF Then
		bRSError = True
		Call handleError(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
	Else
		bEnforceReqFields = .Fields("EnforceReqFields")
	End If
End With

Set rsFields = rsFields.NextRecordSet

If Not bNew And Not bRSError Then
	Dim strSQL, _
		strCon, _
		indCulture, _
		objSysLang

	strSQL = "SELECT vo.OP_ID, vo.VNUM,vo.RECORD_OWNER," & vbCrLf & _
		"dbo.fn_VOL_CanUpdateRecord(vo.VNUM," & user_intID & "," & g_intViewTypeVOL & ",vod.LangID,GETDATE()) AS CAN_UPDATE," & vbCrLf & _
		"cioc_shared.dbo.fn_SHR_GBL_DateString(vod.UPDATE_DATE) AS UPDATE_DATE, vod.UPDATED_BY, " & vbCrLf & _
		"cioc_shared.dbo.fn_SHR_GBL_DateString(vod.UPDATE_SCHEDULE) AS UPDATE_SCHEDULE, vod.UPDATE_HISTORY," & vbCrLf & _
		"vod.POSITION_TITLE"

	If g_bMultiLingual Then
		For Each indCulture In Application("Cultures")
			If indCulture <> g_objCurrentLang.Culture Then
				Set objSysLang = create_language_object()
				objSysLang.setSystemLanguage(indCulture)
				strSQL = strSQL & _
					",CAST(CASE WHEN EXISTS(SELECT * FROM VOL_Opportunity_Description vod2 WHERE vod2.VNUM=vo.VNUM AND LangID=" & objSysLang.LangID & ") " & "THEN 1 ELSE 0 END AS bit) AS HAS_" & Replace(indCulture,"-","_") & _
					",dbo.fn_VOL_CanUpdateRecord(vo.VNUM," & user_intID & "," & g_intViewTypeVOL & "," & objSysLang.LangID & ",GETDATE()) AS CAN_UPDATE_" & Replace(indCulture,"-","_") & _
					",dbo.fn_VOL_RecordInView(vo.VNUM," & g_intViewTypeVOL & "," & objSysLang.LangID & ",0,GETDATE()) AS CAN_SEE_" & Replace(indCulture,"-","_") & _
					",(SELECT cioc_shared.dbo.fn_SHR_GBL_DateString(vod.UPDATE_DATE) FROM VOL_Opportunity_Description vod2 WHERE vod2.VNUM=vo.VNUM AND LangID=" & objSysLang.LangID & ") AS UPDATE_DATE_"  & Replace(indCulture,"-","_")
			End If
		Next
	End If

	With rsFields
		While Not .EOF
			If Not Nl(.Fields("FieldSelect")) And _
				Not reEquals(.Fields("FieldName"), _
						"(RECORD_OWNER)|(POSITION_TITLE)|(UPDATE(_DATE)|(_SCHEDULE)|(D_BY)|(HISTORY))", _
						True,False,True,False) Then
				strSQL = strSQL & ", " & .Fields("FieldSelect")
			End If
			.MoveNext
		Wend
		If Not .RecordCount = 0 Then
			.MoveFirst
		End If
	End With

	strSQL = strSQL & vbCrLf & _
			"FROM VOL_Opportunity vo" & vbCrLf & _
			"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
			"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
			"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
			"WHERE vo.OP_ID=" & intOPID
	
	'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
	'Response.Flush

	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandText = strSQL
		.CommandTimeout = 0
		Set rsOrg = .Execute
	End With
	If rsOrg.EOF Then
		Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
		Call handleError(TXT_NO_RECORD_EXISTS_ID & intOPID & ".", vbNullString, vbNullString)
		Call makePageFooter(True)
		bOPIDError = True
	ElseIf Not rsOrg("CAN_UPDATE")=1 Then
		Call securityFailure()
	End If
	'strExtraSQL = "DECLARE @VNUM int SET @VNUM = " & strVNUM
Else
	'strExtraSQL = "DECLARE @VNUM int SET @VNUM = SCOPE_IDENTITY()"
End If

End If

strExtraSQL = strExtraSQL & vbCrLf & _
			"DECLARE @OP_REL_ID int," & vbCrLf & _
			"	@CheckListNotes varchar(255)"

If Not bOPIDError Then
	Dim dUpdateDate, dUpdateSchedule
	Dim strUserInsert
	Dim strBasicInsertInto, strBasicInsertValues, strBasicUpdateList

	strUserInsert = QsN(user_strMod)

	strBasicInsertInto = "VNUM,MODIFIED_DATE,MODIFIED_BY,CREATED_DATE,CREATED_BY"
	strBasicInsertValues = "@VNUM, GETDATE()," & strUserInsert & ",GETDATE()," & strUserInsert
	strBasicUpdateList = "MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & strUserInsert

	If bNew Then
		strInsertIntoBT = "MemberID," & strBasicInsertInto
		strInsertValueBT = g_intMemberID & "," & strBasicInsertValues
		strInsertIntoBTD = strBasicInsertInto
		strInsertValueBTD = strBasicInsertValues
	Else
		strUpdateListBT = strBasicUpdateList
		strUpdateListBTD = strBasicUpdateList
	End If

	dUpdateDate = Trim(Request("UPDATE_DATE"))
	dUpdateSchedule = Trim(Request("UPDATE_SCHEDULE"))

	Call checkDate("Update Date",dUpdateDate)
	Call checkDate(TXT_UPDATE_SCHEDULE,dUpdateSchedule)
	If Not bNew Then
		Call processUpdateHistory(rsOrg("UPDATE_HISTORY"),dUpdateDate,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
	End If

	Call addBTInsertField("UPDATE_DATE",dUpdateDate,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
	Call addBTInsertField("UPDATED_BY",Trim(Request("UPDATED_BY")),True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
	Call addBTInsertField("UPDATE_SCHEDULE",dUpdateSchedule,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)

	Call getCommunitySetSQL()

	If bNew Then
		Call getVNUM()
		Call getNUM()
		Call getPositionTitle()
		If Nl(strErrorList) Then
			If addBTInsertField("RECORD_OWNER",Trim(Request("RECORD_OWNER")),True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
				Call addChangeField("RECORD_OWNER", Null)
			End If
		End If
	End If

	Dim fldName, fldDisplay, strFieldVal
	Set fldName = rsFields.Fields("FieldName")
	Set fldDisplay = rsFields.Fields("FieldDisplay")
	
	While Not rsFields.EOF
		Select Case fldName.Value
			Case "ACCESSIBILITY"
				Call getStdCheckListSQL("AC", True, Null, Null, fldName.Value)
			Case "AGES"
				Call getAgeFields()
			Case "COMMITMENT_LENGTH"
				Call getStdCheckListSQL("CL", True, Null, Null, fldName.Value)
			Case "CONTACT"
				Call getContactFields(fldName.Value)
			Case "EVENT_SCHEDULE"
				Call getEventScheduleSQL()
			Case "INTERACTION_LEVEL"
				Call getStdCheckListSQL("IL", True, Null, Null, fldName.Value)
			Case "INTERESTS"
				Call getStdCheckListSQL("AI", False, Null, Null, vbNullString)
			Case "INTERNAL_MEMO"
				Call getRecordNoteFields(fldName.Value)
			Case "MINIMUM_HOURS"
				Call getMinimumHoursFields()
			Case "NON_PUBLIC"
				Call addBTInsertField(fldName.Value,Nz(Request("NON_PUBLIC"),SQL_FALSE),False,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
			Case "NUM_NEEDED"
				Call getNumNeededSQL()
			Case "POSITION_TITLE"
				If Not bNew Then
					Call getPositionTitle()
				End If
			Case "RECORD_OWNER"
				If Not bNew Then
					If addBTInsertField("RECORD_OWNER",Trim(Request("RECORD_OWNER")),True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
						Call addChangeField(fldName.Value, Null)
					End If
				End If
			Case "NUM"
				If Not bNew Then
					Call getNUM()
				End If
			Case "SCHEDULE"
				Call getScheduleFields()
			Case "SEASONS"
				Call getStdCheckListSQL("SSN", True, Null, Null, fldName.Value)
			Case "SKILLS"
				Call getStdCheckListSQL("SK", True, Null, Null, fldName.Value)
			Case "SOURCE"
				Call getSourceFields()
			Case "SOCIAL_MEDIA"
				Call getSocialMediaField()
			Case "START_DATE"
				Call getStartDateFields()
			Case "SUITABILITY"
				Call getStdCheckListSQL("SB", False, Null, Null, vbNullString)
			Case "TRAINING"
				Call getStdCheckListSQL("TRN", True, Null, Null, fldName.Value)
			Case "TRANSPORTATION"
				Call getStdCheckListSQL("TRP", True, Null, Null, fldName.Value)
			Case "VNUM"
				If Not bNew Then
					Call getVNUM()
				End If
			Case Else
				strFieldVal = Trim(Request(fldName.Value))
				If rsFields.Fields("ValidateType") = "w"  And Ns(rsFields.Fields("ExtraFieldType")) <> "w" Then
					' NOTE No web field that isn't going into a description Field
					' NOTE Extra WWW handled below
					Call addBTInsertWebField(fldName.Value, rsFields.Fields("FieldDisplay"), strFieldVal, rsFields.Fields("MaxLength"), _
							strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
				Else
					Dim strProtocol
					strProtocol = vbNullString

					If rsFields.Fields("ValidateType") = "d"  or rsFields.Fields("ValidateType") = "a" Then
						Call checkDate(rsFields.Fields("FieldDisplay"),strFieldVal)
						strFieldVal = DateString(strFieldVal,False)
					ElseIf rsFields.Fields("ValidateType") = "e" Then
						Call checkEmail(rsFields.Fields("FieldDisplay"),strFieldVal)
					ElseIf rsFields.Fields("ValidateType") = "w" Then
						' Extra WWW
						Call checkWebWithProtocol(rsFields.Fields("FieldDisplay"),strFieldVal,strProtocol)
					End If
					Call checkLength(rsFields.Fields("FieldDisplay"),strFieldVal, rsFields.Fields("MaxLength"))
					If Nl(strErrorList) Then
						If reEquals(rsFields.Fields("ExtraFieldType"),"a|d|e|r|t|w",False,False,True,False) Then
							Call getExtraFieldSQL(fldName.Value, strFieldVal, rsFields.Fields("ExtraFieldType"), strProtocol)
						ElseIf rsFields.Fields("ExtraFieldType") = "l" Then
							Call getStdCheckListSQL("EXC", False, fldName.Value, fldName.Value & "_ID", Null)
						ElseIf rsFields.Fields("ExtraFieldType") = "p" Then
							Call getStdCheckListSQL("EXD", False, fldName.Value, fldName.Value, Null)
						Else
							If rsFields.Fields("EquivalentSource") Then
								If addBTInsertField(fldName.Value,strFieldVal,_
										rsFields.Fields("FormFieldType") <> "c",_
										strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) Then
									Call addChangeField(fldName.Value, Null)
								End If
							Else
								If addBTInsertField(fldName.Value,strFieldVal,_
										rsFields.Fields("FormFieldType") <> "c",_
										strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
									Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
								End If
							End If
						End If
					End If
				End If
		End Select
		rsFields.MoveNext
	Wend

	If Nl(strErrorList) Then
		strInsSQL = "SET NOCOUNT ON DECLARE @VNUM varchar(10)" & vbCrLf
		If bNew Then
			strInsSQL = strInsSQL & vbCrLf & _
						"SET @VNUM=" & QsNl(strVNUM) & vbCrLf & _
						"IF NOT EXISTS(SELECT * FROM VOL_Opportunity WHERE VNUM=@VNUM) BEGIN" & vbCrLf & _
						"	INSERT INTO VOL_Opportunity (" & strInsertIntoBT & ") VALUES (" & strInsertValueBT & ")" & vbCrLf & _
						"	IF @@ERROR<>0 OR NOT EXISTS(SELECT * FROM VOL_Opportunity WHERE VNUM=@VNUM AND OP_ID=SCOPE_IDENTITY()) BEGIN" & vbCrLf & _
						"		RAISERROR (N'The record could not be added: %s', 0, 1, @VNUM)" & vbCrLf & _
						"		SET @VNUM = NULL" & vbCrLf & _
						"	END ELSE BEGIN" & vbCrLf & _
						"		INSERT INTO VOL_Opportunity_Description (" & strInsertIntoBTD & ",LangID) VALUES (" & strInsertValueBTD & ",@@LANGID)" & vbCrLf & _
						"		IF @@ERROR<>0 OR NOT EXISTS(SELECT * FROM VOL_Opportunity_Description WHERE VNUM=@VNUM AND LANGID=@@LANGID) BEGIN" & vbCrLf & _
						"			RAISERROR (N'The record could not be added: %s', 0, 1, @VNUM)" & vbCrLf & _
						"			SET @VNUM = NULL" & vbCrLf & _
						"		END" & vbCrLf & _
						"	END" & vbCrLf & _
						"END ELSE BEGIN" & vbCrLf & _
						"	RAISERROR (N'The record number is already in use: %s', 0, 1, @VNUM)" & vbCrLf & _
						"	SET @VNUM=NULL" & vbCrLf & _
						"END" & vbCrLf
		Else
			strInsSQL = strInsSQL & vbCrLf & _
						"UPDATE VOL_Opportunity SET " & strUpdateListBT & " WHERE OP_ID=" & intOPID & vbCrLf & _
						"SELECT @VNUM=VNUM FROM VOL_Opportunity WHERE OP_ID=" & intOPID & vbCrLf & _
						"IF @VNUM IS NOT NULL BEGIN" & vbCrLf & _
						"	IF NOT EXISTS(SELECT * FROM VOL_Opportunity_Description WHERE VNUM=@VNUM AND LangID=@@LANGID) BEGIN" & vbCrLf & _
						"		INSERT INTO VOL_Opportunity_Description (" & strBasicInsertInto & ",LangID) VALUES (" & strBasicInsertValues & ",@@LANGID)" & vbCrLf & _
						"	END" & vbCrLf & _
						"	UPDATE VOL_Opportunity_Description SET " & strUpdateListBTD & " WHERE VNUM=@VNUM AND LangID=@@LANGID" & vbCrLf & _
						"END"

		End If
		
		strInsSQL = strInsSQL & vbCrLf & "IF @@ERROR = 0 AND @VNUM IS NOT NULL BEGIN " & vbCrLf & strExtraSQL & vbCrLf & "END"

		strInsSQL = strInsSQL & vbCrLf & "EXEC sp_VOL_SRCH_u @VNUM"

		strInsSQL = strInsSQL & vbCrLf & _
					"SELECT vo.VNUM,vo.RECORD_OWNER," & _
					" dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL" & _
					" FROM (SELECT MAX(VNUM) AS VNUM,RECORD_OWNER,NUM" & _
					" FROM VOL_Opportunity vo " & _
					" WHERE VNUM=@VNUM " & _
					" GROUP BY RECORD_OWNER, NUM) vo" & vbCrLf & _
					"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
					"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=bt.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)"

		'Response.Write("<pre>" & strInsSQL & "</pre>")
		'Response.Flush()

		Dim cmdInsUpd, rsInsUpd, bInsSQLError, strInsSQLError, strRecordOwner, tmpPosOrg, tmpPosTitle, strErrorDetails, objErr
		Set cmdInsUpd = Server.CreateObject("ADODB.Command")
		bInsSQLError = False
		strInsSQLError = vbNullString
		With cmdInsUpd
			.ActiveConnection = getCurrentAdminCnn()
			.CommandType = adCmdText
			.CommandText = strInsSQL
			On Error Resume Next
			Set rsInsUpd = .Execute
			If Err.Number <> 0 Then
				bInsSQLError = True
				strInsSQLError = Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED)
				strErrorDetails =  Ns(user_strMod) & vbCrLf & Ns(user_strAgency) & vbCrLf & Ns(g_strMemberName) & _
									vbCrLf & g_intMemberID & vbCrLf & g_strApplicationInstance & vbCrLf & _
									Ns(Err.Number) & vbCrLf & Hex(IIf(Nl(Err.Number), 0, Err.Number)) & vbCrLf & _
									Ns(Err.Source) & vbCrLf &  Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED) & vbCrLf
				For Each objErr in .ActiveConnection.Errors
					strErrorDetails = strErrorDetails & "Description: " & Ns(objErr.Description) & vbCrLf & _
									"Help context: " & Ns(objErr.HelpContext) & vbCrLf & _
									"Help file: "  & Ns(objErr.HelpFile) & vbCrLf & _
									"Native error: " & Ns(objErr.NativeError) & vbCrLf & _
									"Error number: " & Ns(objErr.Number) & vbCrLf & _
									"Error source: " & Ns(objErr.Source) & vbCrLf & _
									"SQL state: " & Ns(objErr.SQLState) & vbCrLf
				Next

				Call sendEmail(True, CIOC_TASK_NOTIFY_EMAIL, CIOC_TASK_NOTIFY_EMAIL, "VOL Entryform SQL Error", strErrorDetails & strInsSQL)
			ElseIf Not rsInsUpd.EOF Then
				strVNUM = rsInsUpd("VNUM")
				tmpPosOrg = rsInsUpd.Fields("ORG_NAME_FULL")
				strRecordOwner = rsInsUpd.Fields("RECORD_OWNER")
			Else
				tmpPosOrg = vbNullString
			End If
			On Error Goto 0
		End With
		If Err.Number = 0 And Not bInsSQLError Then
			tmpPosTitle = Request("POSITION_TITLE")

			If Not Nl(strChangeHistoryList) And Not Nl(strVNUM) Then
				Dim cmdHistory
				Set cmdHistory = Server.CreateObject("ADODB.Command")
			
				With cmdHistory
					.ActiveConnection = getCurrentAdminCnn()
					.CommandText = "dbo.sp_VOL_Opportunity_History_i"
					.CommandType = adCmdStoredProc
					.CommandTimeout = 0
					.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
					.Parameters.Append .CreateParameter("@MODIFIED_DATE", adDBTimeStamp, adParamInput, , Now())
					.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
					.Parameters.Append .CreateParameter("@FieldList", adLongVarChar, adParamInput, -1)
					.Parameters.Append .CreateParameter("@Names", adBoolean, adParamInput, 1, SQL_TRUE)
					.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2, Null)
					.Prepared = True
					If Not Nl(strChangeHistoryList) Then
						.Parameters("@FieldList").Value = strChangeHistoryList
						.Execute
					End If
					If Not Nl(strChangeHistoryListL) Then
						.Parameters("@FieldList").Value = strChangeHistoryListL
						.Parameters("@LangID").Value = g_objCurrentLang.LangID
						.Execute
					End If
				End With
			End If

			Dim intFBID
			intFBID = Trim(Request("FBID"))
			If Nl(intFBID) Then
				intFBID = Null
			ElseIf Not IsIDType(intFBID) Then
				intFBID = Null
			End If

			Dim objReturn, objErrMsg
			Dim cmdDeleteFb
			Set cmdDeleteFb = Server.CreateObject("ADODB.Command")
			With cmdDeleteFb
				.ActiveConnection = getCurrentAdminCnn()
				.CommandType = adCmdStoredProc
				If bNew And Not Nl(intFBID) Then
					If IsIDType(intFBID) Then
						.CommandText = "dbo.sp_VOL_Feedback_d"
						Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
						.Parameters.Append objReturn
						.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
						.Parameters.Append .CreateParameter("@FB_ID", adInteger, adParamInput, 4, intFBID)
						Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
						.Parameters.Append objErrMsg
					End If
				Else
					.CommandText = "dbo.sp_VOL_Feedback_d_VNUM"
					.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
					.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2)
				End If
			End With

			If Not Nl(Request("DeleteFeedback")) Then
				Dim aDeleteFb, _
					indDeleteFb
				aDeleteFb = Split(Request("DeleteFeedback"),",")
				
				For Each indDeleteFb in aDeleteFb
					If IsCulture(indDeleteFb) Then
						Set objSysLang = create_language_object()
						objSysLang.setSystemLanguage(indDeleteFb)
					
						Call setSessionLanguage(objSysLang.Culture)
						Call getROInfo(strRecordOwner,DM_VOL)
						If Not g_bNoEmail Then
							Call sendNotifyEmails(strVNUM, intFBID, tmpPosTitle & " (" & tmpPosOrg & ")")
						End If
						With cmdDeleteFb
							If Not bNew Or Nl(intFBID) Then
								.Parameters("@LangID").Value = objSysLang.LangID
							Else
								intFBID = Null
							End If
							.Execute
						End With
						Call setSessionLanguage(objUpdateLang.Culture)
					End If
				Next
			End If

			If bNew And Not Nl(intFBID) Then
				If IsIDType(intFBID) Then
					Dim cmdSetFbVNUM
					Set cmdSetFbVNUM = Server.CreateObject("ADODB.Command")
					With cmdSetFBVNUM
						.ActiveConnection = getCurrentAdminCnn()
						.CommandType = adCmdStoredProc
						.CommandText = "dbo.sp_VOL_Feedback_u_VNUM"
						.Parameters.Append .CreateParameter("@FB_ID", adInteger, adParamInput, 4, intFBID)
						.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
						.Execute
					End With
				End If
			End If

			Dim strOtherLangList
			strOtherLangList = vbNullString
		
			If Not bNew And g_bMultiLingual Then
				For Each indCulture In Application("Cultures")
					If indCulture <> g_objCurrentLang.Culture Then
						Set objSysLang = create_language_object()
						objSysLang.setSystemLanguage(indCulture)
						If rsOrg("HAS_" & Replace(indCulture,"-","_")) Then
							strOtherLangList = strOtherLangList & "<li>" & _
							IIf(rsOrg("CAN_SEE_" & Replace(indCulture,"-","_")) And rsOrg("CAN_UPDATE_" & Replace(indCulture,"-","_"))=1, _
								"<a href=""" & makeLink("entryform.asp","VNUM=" & strVNUM & "&UpdateLn=" & indCulture,vbNullString) & """>" & TXT_UPDATE_RECORD & " - <strong>" & objSysLang.LanguageName & "</strong></a>", _
								"<a href=""" & makeLink("feedback.asp","VNUM=" & strVNUM & "&UpdateLn=" & indCulture,vbNullString) & """>" & TXT_SUGGEST_UPDATE & " - <strong>" & objSysLang.LanguageName) & "</strong></a>" & _
							" (" & TXT_UPDATE_DATE & TXT_COLON & Nz(rsOrg("UPDATE_DATE_" & Replace(indCulture,"-","_")),TXT_UNKNOWN) & ")" & _
							"</li>"
						End If
					End If
				Next
			End If
			
			If Nl(strOtherLangList) Then
				Call handleVOLDetailsMessage(TXT_UPDATE_SUCCESSFUL, _
					strVNUM, StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber), _
					False)

			Else
				Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
%>
<h2><%=TXT_RECORD_DETAILS & TXT_COLON%><a href="<%=makeVOLDetailsLink(strVNUM, StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber),vbNullString)%>"><%=tmpPosTitle & " (" & tmpPosOrg & ")"%></a></h2>
<p><%=TXT_EDIT_EQUIVALENT%>
<ul>
	<%=strOtherLangList%>
</ul>
</p>
<%
				Call makePageFooter(True)
			End If
		Else
			Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
			Call handleError(TXT_UNKNOWN_ERRORS_OCCURED & strInsSQLError & ".",vbNullString,vbNullString)
			Call makePageFooter(True)
		End If
	Else
		Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
		Call handleError(TXT_ERRORS_FOUND & TXT_COLON & "<ul>" & strErrorList & "</ul>",vbNullString,vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
		Call makePageFooter(True)
	End If
End If
%>

<!--#include file="../includes/core/incClose.asp" -->
