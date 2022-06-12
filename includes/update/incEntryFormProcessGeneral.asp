<%
'File:			$HeadURL$
'Last Modified:	$Date$
'Last Mod By:	$Author$
'Purpose:
'
'=================================================================
'Copyright (c) 2003-2012 Community Information Online Consortium (CIOC)
'http://www.cioc.ca
'Developed By Katherine Lambacher / KCL Custom Software
'If you did not receive a copy of the license agreement with this
'software, please contact CIOC via their website above.
'==================================================================
%>

<script language="python" runat="server">
from cioc.core.security import sanitize_html_description

def getEventScheduleXML(checkDate, checkInteger, checkID, checkLength, checkAddValidationError):
	schedules = getEventScheduleValues(checkDate, checkInteger, checkID, checkLength, checkAddValidationError)
	return convertEventScheduleValuesToXML(schedules)


def getEventScheduleSQL_l(checkDate, checkInteger, checkID, checkLength, checkAddValidationError):
	xml_value = getEventScheduleXML(checkDate, checkInteger, checkID, checkLength, checkAddValidationError)

	if pyrequest.pageinfo.DbArea == const.DM_VOL:
		id_field = '@VNUM'
		record_id = '@VNUM'
	else:
		id_field = '@NUM'
		record_id = '@NUM'

	def escape_string(value):
		return six.text_type(value).replace(u"'", "''")

	if xml_value:
		output = u'''
			EXECUTE sp_GBL_NUMVNUMSetSchedule_u N'<SCHEDULES>{}</SCHEDULES>', '{}', {}={}
		'''.format(escape_string(xml_value), escape_string(pyrequest.user.Mod), id_field, record_id)
	else:
		output = u''

	return output

</script>

<%
Function addXMLInsertField(bNew, _
		strFldName, _
		strNewValue, _
		bQuoteStr, _
		ByRef strUpdateList, _
		ByRef strInsertInto, _
		ByRef strInsertValue, _
		ByRef xmlNode)

	Dim bReturn
	bReturn = False

	Dim strOldValue

	If bNew Then
		If Not Nl(strNewValue) Then
			If bQuoteStr Then
				strNewValue = QsNl(strNewValue)
			ElseIf Not IsNumeric(strNewValue) Then
				strNewValue = Null
			ElseIf g_objCurrentLang.LangID = LANG_FRENCH _
					Or g_objCurrentLang.LangID = LANG_GERMAN _
					Or g_objCurrentLang.LangID = LANG_POLISH Then
				strNewValue = Replace(strNewValue,",",".")
			End If
			If Not Nl(strNewValue) Then
				strInsertInto = strInsertInto & "," & strFldName
				strInsertValue = strInsertValue & "," & strNewValue
				bReturn = True
			End If
		End If
	Else
		strOldValue = xmlNode.getAttribute(strFldName)
		If Not IsNull(strOldValue) Then
			strOldValue = CStr(strOldValue)
		End If
		If strNewValue <> strOldValue Or _
			(Nl(strOldValue) And Not Nl(strNewValue)) Or _
			(Nl(strNewValue) And Not Nl(strOldValue)) Then
			If Nl(strNewValue) Then
				strNewValue = "NULL"
			ElseIf bQuoteStr Then
				If Not Nl(strNewValue) Then
					strNewValue = QsNl(strNewValue)
				End If
			ElseIf strOldValue = "False" Then
				If IsNumeric(strNewValue) Then
					If CInt(strNewValue) = SQL_FALSE Then
						strNewValue = Null
					End If
				End If
			ElseIf strOldValue = "True" Then
				If IsNumeric(strNewValue) Then
					If CInt(strNewValue) = SQL_TRUE Then
						strNewValue = Null
					End If
				End If
			ElseIf Not IsNumeric(strNewValue) Then
				strNewValue = Null
			Else
				If IsNumeric(strOldValue) Then
					If CDbl(strNewValue) = CDbl(strOldValue) Then
						strNewValue = Null
					End If
				End If
				If Not Nl(strNewValue) And (g_objCurrentLang.LangID = LANG_FRENCH _
						Or g_objCurrentLang.LangID = LANG_GERMAN _
						Or g_objCurrentLang.LangID = LANG_POLISH) Then
					strNewValue = Replace(strNewValue,",",".")
				End If
			End If
			If Not Nl(strNewValue) Then
				strUpdateList = strUpdateList & "," & strFldName & "=" & strNewValue
				bReturn = True
			End If
		End If
	End If

	addXMLInsertField = bReturn
End Function

Function addBTInsertField(strFldName, _
		strNewValue, _
		bQuoteStr, _
		ByRef strUpdateList, _
		ByRef strInsertInto, _
		ByRef strInsertValue)

	Dim bReturn
	bReturn = False

	Dim strOldValue

	'Response.Write("<br>" & strFldName)
	'Response.Flush()

	' Remove contol characters that are not valid in XML
	If VarType(strNewValue) = vbString Then
		strNewValue = reReplace(strNewValue, _
				"[^\x09\x0A\x0D\x20-\uD7FF\uE000-\uFFFD\u10000-\u10FFFF]", _
				vbNullString, False, False, True, False)
	End If

	If bNew Then
		If Not Nl(strNewValue) Then
			If bQuoteStr Then
				strNewValue = QsNl(strNewValue)
			ElseIf Not IsNumeric(strNewValue) Then
				strNewValue = Null
			ElseIf g_objCurrentLang.LangID = LANG_FRENCH _
					Or g_objCurrentLang.LangID = LANG_GERMAN _
					Or g_objCurrentLang.LangID = LANG_POLISH Then
				strNewValue = Replace(strNewValue,",",".")
			End If
			If Not Nl(strNewValue) Then
				strInsertInto = strInsertInto & "," & strFldName
				strInsertValue = strInsertValue & "," & strNewValue
				bReturn = True
			End If
		End If
	Else
		strOldValue = rsOrg.Fields(strFldName)
		If Not IsNull(strOldValue) Then
			If VarType(strOldValue) = vbBoolean Then
				strOldValue = IIf(strOldValue,SQL_TRUE,SQL_FALSE)
			Else
				strOldValue = CStr(strOldValue)
			End If
		End If
		If strNewValue <> strOldValue Or _
			(Nl(strOldValue) And Not Nl(strNewValue)) Or _
			(Nl(strNewValue) And Not Nl(strOldValue)) Then
			If Nl(strNewValue) Then
				strNewValue = "NULL"
			ElseIf bQuoteStr Then
				If rsOrg.Fields(strFldName).Type = adDBTimeStamp Then
					If DateString(strNewValue,True) = DateString(strOldValue,True) Then
						strNewValue = Null
					End If
				End If
				If Not Nl(strNewValue) Then
					strNewValue = QsNl(strNewValue)
				End If
			ElseIf Not IsNumeric(strNewValue) Then
				strNewValue = Null
			Else
				If IsNumeric(strOldValue) Then
					If CDbl(strNewValue) = CDbl(strOldValue) Then
						strNewValue = Null
					End If
				End If
				If Not Nl(strNewValue) And (g_objCurrentLang.LangID = LANG_FRENCH _
						Or g_objCurrentLang.LangID = LANG_GERMAN _
						Or g_objCurrentLang.LangID = LANG_POLISH) Then
					strNewValue = Replace(strNewValue,",",".")
				End If
			End If
			If Not Nl(strNewValue) Then
				strUpdateList = strUpdateList & "," & strFldName & "=" & strNewValue
				bReturn = True
			End If
		End If
	End If

	addBTInsertField = bReturn
End Function

Function processXMLStrFldArray(bNew, strContactType, aFields, ByRef strUpdateList, ByRef strInsertInto, ByRef strInsertValue, xmlNode)
	Dim bReturn
	bReturn = False

	Dim indFldName
	If IsArray(aFields) And Nl(strErrorList) Then
		For Each indFldName In aFields
			If addXMLInsertField(bNew,indFldName,Trim(Request(strContactType & "_" & indFldName)),True,strUpdateList,strInsertInto,strInsertValue,xmlNode) Then
				bReturn = True
			End If
		Next
	End If

	processXMLStrFldArray = bReturn
End Function

Function processStrFldArray(ByRef aFields, ByRef strUpdateList, ByRef strInsertInto, ByRef strInsertValue)
	Dim bReturn
	bReturn = False

	Dim indFldName
	If IsArray(aFields) And Nl(strErrorList) Then
		For Each indFldName In aFields
			If addBTInsertField(indFldName,Trim(Request(indFldName)),True,strUpdateList,strInsertInto,strInsertValue) Then
				bReturn = True
			End If
		Next
	End If

	processStrFldArray = bReturn
End Function

Sub processUpdateHistory(strOldValue, strNewValue, ByRef strUpdateList, ByRef strInsertInto, ByRef strInsertValue)
	Dim strOldDate
	strOldDate = Trim(Request("OLD_UPDATE_DATE"))
	If Not Nl(strOldDate) Then
		If IsSmallDate(strOldDate) Then
			strOldDate = DateString(strOldDate,True)
		End If
		If IsSmallDate(strNewValue) Then
			strNewValue = DateString(strNewValue,True)
		End If
		If strOldDate <> strNewValue Then
			Call addBTInsertField("UPDATE_HISTORY",strOldValue & IIf(Nl(strOldValue),vbNullString," ; ") & strOldDate,True,strUpdateList,strInsertInto,strInsertValue)
		End If
	End If
End Sub

Sub sendNotifyEmails(strID, intFBID, strRecName)

	If Nl(strROUpdateEmail) Then
		Exit Sub
	End If

	Dim strDetailLink

	Dim strMsgText, _
		strSender, _
		strSubject

	Dim cmdFb, rsFb
	Set cmdFb = Server.CreateObject("ADODB.Command")
	With cmdFb
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.CommandText = "dbo.sp_" & ps_strDbArea & "_ProcessFb"
		If ps_intDbArea = DM_VOL Then
			.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strID)
		Else
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strID)
		End If
		.Parameters.Append .CreateParameter("@FB_ID", adInteger, adParamInput, 4, intFBID)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2, g_objCurrentLang.LangID)
		Set rsFb = .Execute
	End With

	With rsFb
		If Not .EOF And Not g_bNoEmail Then
			strSender = strROUpdateEmail & " <" & strROUpdateEmail & ">"
			strSubject = TXT_SUGGESTIONS_REVIEWED
			If .Fields("IN_VIEW") Then
				strDetailLink = TXT_VIEW_RECORD_AT & _
					vbCrLf & _
					"https://" & IIf(Not Nl(.Fields("AccessURL")), .Fields("AccessURL"), IIf(ps_intDbArea = DM_CIC,g_strBaseURLCIC,g_strBaseURLVOL)) & _
					"/" & ps_strDbAreaDefaultPath & IIf(Nl(strRecordRoot), _
						"details.asp?" & IIf(ps_intDbArea=DM_VOL,"VNUM=" & strID,"NUM=" & strID) & "&", _
						strRecordRoot & strID & "?") & _
					StringIf(Not Nl(.Fields("ViewType")),IIf(ps_intDbArea=DM_VOL,"UseVOLVw=","UseCICVw=") & .Fields("ViewType") & "&") & _
					"Ln=" & g_objCurrentLang.Culture
			Else
				strDetailLink = TXT_VIEW_RECORD_AT & _
					"https://" & IIf(Not Nl(.Fields("AccessURL")), .Fields("AccessURL"), IIf(ps_intDbArea = DM_CIC,g_strBaseURLCIC,g_strBaseURLVOL)) & _
					"/" & ps_strDbAreaDefaultPath & "feedback.asp?" & _
					IIf(ps_intDbArea=DM_VOL,"VNUM=","NUM=") & strID & _
					StringIf(Not Nl(.Fields("ViewType")),IIf(ps_intDbArea=DM_VOL,"&UseVOLVw=","&UseCICVw=") & .Fields("ViewType")) & _
					"&Ln=" & g_objCurrentLang.Culture & _
					StringIf(Not Nl(.Fields("FBKEY")),"&Key=" & .Fields("FBKEY"))
			End If
			strMsgText = TXT_YOU_SUBMITTED_FEEDBACK_1 & _
					vbCrLf & _
					strRecName & _
					vbCrLf & _
					TXT_YOU_SUBMITTED_FEEDBACK_2 & get_db_option_current_lang("DatabaseName" & ps_strDbArea) & _
					vbCrLf & vbCrLf & _
					TXT_RECORD_WAS_REVIEWED & _
					vbCrLf & strDetailLink
			While Not .EOF
				Call sendEmail(False, strSender, .Fields("SOURCE_EMAIL"), strSubject, strMsgText)
				.MoveNext
			Wend
		End If
		.Close
	End With
	Set rsFb = Nothing
	Set cmdFb = Nothing
End Sub

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

Sub getContactFields(strContactType)
	Dim intContactID, _
		strUpdateList, _
		strInsertInto, _
		strInsertValue

	Dim xmlDoc, xmlNode

	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With

	If Not bNew Then
		xmlDoc.loadXML Nz(rsOrg(strContactType).Value,"<CONTACT/>")
	Else
		xmlDoc.loadXML "<CONTACT/>"
	End If
	Set xmlNode = xmlDoc.selectSingleNode("/CONTACT")

	intContactID = xmlNode.getAttribute("ContactID")

	Call checkEmail(fldDisplay.Value & " " & TXT_EMAIL,Trim(Request(strContactType & "_EMAIL")))

	If addXMLInsertField(IIf(Nl(intContactID),True,False),"FAX_CALLFIRST",IIf(Trim(Request(strContactType & "_FAX_CALLFIRST"))="on",SQL_TRUE,SQL_FALSE),False,strUpdateList,strInsertInto,strInsertValue,xmlNode) _
		Or processXMLStrFldArray(IIf(Nl(intContactID),True,False), _
			strContactType, _
			aContactFields, _
			strUpdateList,strInsertInto,strInsertValue,xmlNode) Then

			Call addChangeField(fldName.Value, g_objCurrentLang.LangID)

			Dim indValidateField, bHasContent
			bHasContent = False
			For Each indValidateField in aContactFieldsValidate
				If Not Nl(Trim(Request(strContactType & "_" & indValidateField))) Then
					bHasContent = True
					Exit For
				End If
			Next
			If Not Nl(intContactID) Then
				If Not Nl(strUpdateList) And bHasContent Then
					strExtraSQL = strExtraSQL & vbCrLf & _
						"UPDATE GBL_Contact" & vbCrLf & _
						"SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & QsNl(user_strMod) & strUpdateList & vbCrLf
					If ps_intDbArea = DM_VOL Then
						strExtraSQL = strExtraSQL & _
							"WHERE VolContactType=" & QsNl(strContactType) & " AND VolVNUM=@VNUM"
					Else
						strExtraSQL = strExtraSQL & _
							"WHERE GblContactType=" & QsNl(strContactType) & " AND GblNUM=@NUM AND LangID=@@LANGID"
					End If
				ElseIf Not bHasContent Then
					If ps_intDbArea = DM_VOL Then
						strExtraSQL = strExtraSQL & vbCrLf & _
							"DELETE GBL_Contact WHERE VolContactType=" & QsNl(strContactType) & " AND VolVNUM=@VNUM AND LangID=@@LANGID"
					Else
						strExtraSQL = strExtraSQL & vbCrLf & _
							"DELETE GBL_Contact WHERE GblContactType=" & QsNl(strContactType) & " AND GblNUM=@NUM AND LangID=@@LANGID"
					End If
				End If
			ElseIf bHasContent Then
					If ps_intDbArea = DM_VOL Then
						strExtraSQL = strExtraSQL & vbCrLf & _
							"IF NOT EXISTS(SELECT * FROM GBL_Contact WHERE VolContactType=" & QsNl(strContactType) & " AND VolVNUM=@VNUM AND LangID=@@LANGID) BEGIN" & vbCrLf & _
							"	INSERT INTO GBL_Contact (VolContactType,VolOPDID,VolVNUM,LangID,CREATED_BY, MODIFIED_BY" & strInsertInto & ")" & vbCrLf & _
							"	VALUES (" & QsNl(strContactType) & ",(SELECT OPD_ID FROM VOL_Opportunity_Description WHERE VNUM=@VNUM AND LangID=@@LANGID),@VNUM,@@LANGID," & QsNl(user_strMod) & "," & QsNl(user_strMod) & strInsertValue & ")" & vbCrLf & _
							"END"
					Else
						strExtraSQL = strExtraSQL & vbCrLf & _
							"IF NOT EXISTS(SELECT * FROM GBL_Contact WHERE GblContactType=" & QsNl(strContactType) & " AND GblNUM=@NUM AND LangID=@@LANGID) BEGIN" & vbCrLf & _
							"	INSERT INTO GBL_Contact (GblContactType,GblNUM,LangID,CREATED_BY, MODIFIED_BY" & strInsertInto & ")" & vbCrLf & _
							"	VALUES (" & QsNl(strContactType) & ",@NUM,@@LANGID," & QsNl(user_strMod) & "," & QsNl(user_strMod) & strInsertValue & ")" & vbCrLf & _
							"END"

					End If
			End If
	End If
End Sub

Sub getRecordNoteFields(strNoteType)

	Const RN_CHANGE_NOONE = 0
	Const RN_CHANGE_ANYONE = 1
	Const RN_CHANGE_SUPER_USER = 2

	Dim intCanDeleteRecordNote, intCanUpdateRecordNote, _
		bCanDeleteRecordNote, bCanUpdateRecordNote
	intCanDeleteRecordNote = get_db_option("CanDeleteRecordNote" & ps_strDbArea)
	intCanUpdateRecordNote = get_db_option("CanUpdateRecordNote" & ps_strDbArea)

	bCanDeleteRecordNote = False
	If intCanDeleteRecordNote = RN_CHANGE_ANYONE Or (user_bSuperUserDOM And intCanDeleteRecordNote = RN_CHANGE_SUPER_USER) Then
		bCanDeleteRecordNote = True
	End If

	bCanUpdateRecordNote = False
	If intCanUpdateRecordNote = RN_CHANGE_ANYONE Or (user_bSuperUserDOM And intCanUpdateRecordNote = RN_CHANGE_SUPER_USER) Then
		bCanUpdateRecordNote = True
	End If

	Dim strUpdateRecordNoteIDs, _
		strDeleteRecordNoteIDs, _
		strCancelRecordNoteIDs, _
		strRestoreRecordNoteIDs, _
		aAllUpdateRecordNoteIDs, _
		aNewRecordNoteIDs, _
		aUpdateRecordNoteIDs, _
		indRecordNoteID, _
		intNoteTypeID, _
		strNoteValue

	strUpdateRecordNoteIDs = Nz(Request(strNoteType & "_UPDATE_IDS"),vbNullString)
	aAllUpdateRecordNoteIDs = Split(Replace(strUpdateRecordNoteIDs," ",vbNullString),",")
	aNewRecordNoteIDs = Filter(aAllUpdateRecordNoteIDs,"NEW",True)

	If bCanUpdateRecordNote Then
		aUpdateRecordNoteIDs = Filter(aAllUpdateRecordNoteIDs,"NEW",False)
	Else
		aUpdateRecordNoteIDs = Array()
	End If

	If bCanDeleteRecordNote Then
		strDeleteRecordNoteIDs = Nz(Request(strNoteType & "_DELETE_IDS"),vbNullString)
		If Not IsIDList(strDeleteRecordNoteIDs) Then
			strDeleteRecordNoteIDs = vbNullString
		End If
	Else
		strDeleteRecordNoteIDs = vbNullString
	End If

	strCancelRecordNoteIDs = Nz(Request(strNoteType & "_CANCEL_IDS"),vbNullString)
	If Not IsIDList(strCancelRecordNoteIDs) Then
		strCancelRecordNoteIDs = vbNullString
	End If

	strRestoreRecordNoteIDs = Nz(Request(strNoteType & "_RESTORE_IDS"),vbNullString)
	If Not IsIDList(strRestoreRecordNoteIDs) Then
		strRestoreRecordNoteIDs = vbNullString
	End If

	strExtraSQL = strExtraSQL & vbCrLf & "DECLARE @NoteTypeID int"

	'Add New Notes
	For Each indRecordNoteID In aNewRecordNoteIDs
		intNoteTypeID = Request(strNoteType & "_" & indRecordNoteID & "_NoteTypeID")
		If Not IsIDType(intNoteTypeID) Then
			intNoteTypeID = Null
		End If
		strNoteValue = Trim(Request(strNoteType & "_" & indRecordNoteID & "_RecordNoteValue"))
		If Not Nl(strNoteValue) Then
			If Not Nl(intNoteTypeID) Then
				strExtraSQL = strExtraSQL & vbCrLf & _
					"SELECT @NoteTypeID=NoteTypeID FROM GBL_RecordNote_Type WHERE NoteTypeID=" & QsNl(intNoteTypeID)
			Else
				strExtraSQL = strExtraSQL & vbCrLf & _
					"SET @NoteTypeID = NULL"
			End If
			If ps_intDbArea = DM_VOL Then
				strExtraSQL = strExtraSQL & vbCrLf & _
					"INSERT INTO GBL_RecordNote (VolNoteType,VolOPDID,VolVNUM,LangID,CREATED_BY,MODIFIED_BY,NoteTypeID,Value)" & vbCrLf & _
					"VALUES (" & QsNl(strNoteType) & ",(SELECT OPD_ID FROM VOL_Opportunity_Description WHERE VNUM=@VNUM AND LangID=@@LANGID),@VNUM,@@LANGID," & QsNl(user_strMod) & "," & QsNl(user_strMod) & ",@NoteTypeID," & QsNl(strNoteValue) & ")"
			Else
				strExtraSQL = strExtraSQL & vbCrLf & _
					"INSERT INTO GBL_RecordNote (GblNoteType,GblNUM,LangID,CREATED_BY,MODIFIED_BY,NoteTypeID,Value)" & vbCrLf & _
					"VALUES (" & QsNl(strNoteType) & ",@NUM,@@LANGID," & QsNl(user_strMod) & "," & QsNl(user_strMod) & ",@NoteTypeID," & QsNl(strNoteValue) & ")"

			End If
		End If
	Next

	'Update Notes
	For Each indRecordNoteID In aUpdateRecordNoteIDs
		intNoteTypeID = Request(strNoteType & "_" & indRecordNoteID & "_NoteTypeID")
		If Not IsIDType(intNoteTypeID) Then
			intNoteTypeID = Null
		End If
		strNoteValue = Trim(Request(strNoteType & "_" & indRecordNoteID & "_RecordNoteValue"))
		If Not Nl(strNoteValue) And IsIDType(indRecordNoteID) Then
			If Not Nl(intNoteTypeID) Then
				strExtraSQL = strExtraSQL & vbCrLf & _
					"SELECT @NoteTypeID=NoteTypeID FROM GBL_RecordNote_Type WHERE NoteTypeID=" & QsNl(intNoteTypeID)
			Else
				strExtraSQL = strExtraSQL & vbCrLf & _
					"SET @NoteTypeID = NULL"
			End If
			strExtraSQL = strExtraSQL & vbCrLf & _
				"UPDATE GBL_RecordNote SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & QsNl(user_strMod) & ",NoteTypeID=@NoteTypeID,Value=" & QsNl(strNoteValue) & vbCrLf & _
				"WHERE RecordNoteID=" & indRecordNoteID
			If ps_intDbArea = DM_VOL Then
				strExtraSQL = strExtraSQL & vbCrLf & _
					"AND VolNoteType=" & QsNl(strNoteType) & " AND VolVNUM=@VNUM AND LangID=@@LANGID"
			Else
				strExtraSQL = strExtraSQL & vbCrLf & _
					"AND GblNoteType=" & QsNl(strNoteType) & " AND GblNUM=@NUM AND LangID=@@LANGID"

			End If
		End If
	Next

	'Delete Notes
	If Not Nl(strDeleteRecordNoteIDs) Then
		strExtraSQL = strExtraSQL & vbCrLf & _
			"DELETE FROM GBL_RecordNote" & vbCrLf & _
			"WHERE RecordNoteID IN (" & strDeleteRecordNoteIDs & ")"
		If ps_intDbArea = DM_VOL Then
			strExtraSQL = strExtraSQL & vbCrLf & _
				"AND VolNoteType=" & QsNl(strNoteType) & " AND VolVNUM=@VNUM AND LangID=@@LANGID"
		Else
			strExtraSQL = strExtraSQL & vbCrLf & _
				"DELETE FROM GBL_RecordNote" & vbCrLf & _
				"WHERE GblNoteType=" & QsNl(strNoteType) & " AND GblNUM=@NUM AND LangID=@@LANGID" & vbCrLf & _
				"	AND RecordNoteID IN (" & strDeleteRecordNoteIDs & ")"
		End If
	End If

	'Cancel Notes
	If Not Nl(strCancelRecordNoteIDs) Then
		strExtraSQL = strExtraSQL & vbCrLf & _
			"UPDATE GBL_RecordNote SET CANCELLED_DATE=GETDATE(),CANCELLED_BY=" & QsNl(user_strMod) & vbCrLf & _
			"WHERE RecordNoteID IN (" & strCancelRecordNoteIDs & ")"
		If ps_intDbArea = DM_VOL Then
			strExtraSQL = strExtraSQL & vbCrLf & _
				"AND VolNoteType=" & QsNl(strNoteType) & " AND VolVNUM=@VNUM AND LangID=@@LANGID"
		Else
			strExtraSQL = strExtraSQL & vbCrLf & _
				"AND GblNoteType=" & QsNl(strNoteType) & " AND GblNUM=@NUM AND LangID=@@LANGID"
		End If
	End If

	'Restore Notes
	If Not Nl(strRestoreRecordNoteIDs) Then
		strExtraSQL = strExtraSQL & vbCrLf & _
			"UPDATE GBL_RecordNote SET CANCELLED_DATE=NULL,CANCELLED_BY=NULL,MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & QsNl(user_strMod) & vbCrLf & _
			"WHERE RecordNoteID IN (" & strRestoreRecordNoteIDs & ")"
		If ps_intDbArea = DM_VOL Then
			strExtraSQL = strExtraSQL & vbCrLf & _
				"AND VolNoteType=" & QsNl(strNoteType) & " AND VolVNUM=@VNUM AND LangID=@@LANGID"
		Else
			strExtraSQL = strExtraSQL & vbCrLf & _
				"AND GblNoteType=" & QsNl(strNoteType) & " AND GblNUM=@NUM AND LangID=@@LANGID"
		End If
	End If

	Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
End Sub

Sub getSocialMediaField()
	Dim intSMID, strXML, strURL, strProto, strSQL, strTblPrefix, strIDName, bUpdateHistory
	Dim xmlDoc, xmlNode, xmlChildNode

	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With

	If Not bNew Then
		xmlDoc.loadXML Nz(rsOrg("SOCIAL_MEDIA").Value,"<SOCIAL_MEDIA/>")
	Else
		Dim rsSocialMedia, cmdSocialMedia
		Set cmdSocialMedia = Server.CreateObject("ADODB.Command")
		With cmdSocialMedia
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_GBL_SocialMedia_s_Entryform"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
		End With
		Set rsSocialMedia = Server.CreateObject("ADODB.Recordset")
		With rsSocialMedia
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdSocialMedia
		End With


		If Not rsSocialMedia.EOF Then
			xmlDoc.loadXML Nz(rsSocialMedia("SOCIAL_MEDIA").Value, "<SOCIAL_MEDIA/>")
		Else
			xmlDoc.loadXML "<SOCIAL_MEDIA/>"
		End If

		Call rsSocialMedia.Close()

		Set rsSocialMedia = Nothing
		Set cmdSocialMedia = Nothing
	End If

	bUpdateHistory = False
	strXML = "<SMS>"
	Set xmlNode = xmlDoc.selectSingleNode("/SOCIAL_MEDIA")
	If Not xmlNode Is Nothing Then
		For Each xmlChildNode in xmlNode.childNodes
			intSMID = xmlChildNode.getAttribute("ID")
			strURL = Request("SOCIAL_MEDIA_" & intSMID)
			Call checkWebWithProtocol(rsFields.Fields("FieldDisplay"), strURL, strProto)
			If Not Nl(strURL) Then
				strXML = strXML & "<SM SM_ID=" & AttrQs(intSMID) & " URL=" & XMLQs(strURL) & " Proto=" & XMLQs(strProto) & "/>"
			End If
			If Ns(strURL) <> Ns(xmlChildNode.getAttribute("URL")) Then
				bUpdateHistory = True
			End If
		Next
	End If
	strXML = strXML & "</SMS>"

	If ps_intDbArea = DM_VOL Then
		strTblPrefix = "VOL_OP"
		strIDName = "VNUM"
	Else
		strTblPrefix = "GBL_BT"
		strIDName = "NUM"
	End If

	If bUpdateHistory Then
		strSQL = "DECLARE @SocialXml xml; DECLARE @SocialTable TABLE (SM_ID int not null, URL nvarchar(255), Protocol varchar(10))" & vbCrLf & _
				"SET @SocialXml = " & QsNl(strXML) & vbCrLf & _
				"INSERT INTO @SocialTable (SM_ID, URL, Protocol) " & vbCrLf & _
				"SELECT N.value('@SM_ID', 'int') AS SM_ID, N.value('@URL', 'nvarchar(255)') AS URL, N.value('@Proto', 'varchar(10)') AS Protocol" & vbCrLf & _
				"FROM @SocialXml.nodes('//SM') AS T(N)" & vbCrLf & _
				"MERGE INTO " & strTblPrefix & "_SM sm" & vbCrLf & _
				"USING (SELECT nt.* FROM @SocialTable nt WHERE EXISTS(SELECT * FROM GBL_SocialMedia WHERE SM_ID=nt.SM_ID)) nt" & vbCrLf & _
				"	ON sm." & strIDName & "=@" & strIDName & " AND sm.LangID=@@LANGID AND sm.SM_ID=nt.SM_ID" & vbCrLf & _
				"WHEN MATCHED AND (sm.URL <> nt.URL COLLATE Latin1_General_100_CS_AS OR ISNULL(sm.Protocol, '') <> ISNULL(nt.Protocol, '') COLLATE Latin1_General_100_CI_AI) THEN" & vbCrLf & _
				"	UPDATE SET URL=nt.URL, Protocol=nt.Protocol" & vbCrLf & _
				"WHEN NOT MATCHED BY TARGET THEN" & vbCrLf & _
				"	INSERT (" & strIDName & ", LangID, SM_ID, URL, Protocol)" & vbCrLf & _
				"		VALUES (@" & strIDName & ", @@LANGID, nt.SM_ID, nt.URL, nt.Protocol)" & vbCrLf & _
				"WHEN NOT MATCHED BY SOURCE AND sm." & strIDName & "=@" & strIDName & " AND sm.LangID=@@LANGID THEN" & vbCrLf & _
				"	DELETE" & vbCrLf & _
				" ; "

		strExtraSQL = strExtraSQL & vbCrLf & strSQL

		Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
	End If
End Sub

Dim strChangeHistoryList, _
	strChangeHistoryListL

strChangeHistoryList = vbNullString
strChangeHistoryListL = vbNullString

Sub addChangeField(strFieldName, intLangID)
	If Not Nl(intLangID) Then
		If Nl(strChangeHistoryListL) Then
			strChangeHistoryListL = strFieldName
		Else
			strChangeHistoryListL = strChangeHistoryListL & "," & strFieldName
		End If
	Else
		If Nl(strChangeHistoryList) Then
			strChangeHistoryList = strFieldName
		Else
			strChangeHistoryList = strChangeHistoryList & "," & strFieldName
		End If
	End If
End Sub

Sub addBTInsertWebField(strFieldName, strFieldDisplay, ByVal strFieldVal, intMaxLength, ByRef strUpdateList, ByRef strInsertInto, ByRef strInsertValue)
	Dim strProtocol, bChanged
	bChanged = False
	Call checkWebWithProtocol(strFieldDisplay,strFieldVal,strProtocol)
	Call checkLength(strFieldDisplay,strFieldVal,intMaxLength)
	If Nl(strErrorList) Then
		bChanged = addBTInsertField(strFieldName, strFieldVal, True, strUpdateList, strInsertInto, strInsertValue)
		bChanged = bChanged Or addBTInsertField(strFieldName + "_PROTOCOL", strProtocol, True, strUpdateList, strInsertInto, strInsertValue)
		If bChanged Then
			Call addChangeField(strFieldName, g_objCurrentLang.LangID)
		End If
	End If
End Sub

Sub getEventScheduleSQL()
	Dim strSQLToAdd
	strSQLToAdd = getEventScheduleSQL_l(GetRef("WrapCheckDate"), GetRef("checkInteger"), GetRef("checkID"), _
			GetRef("checkLength"), GetRef("checkAddValidationError"))

	If Not Nl(strSQLToAdd) Then
		strExtraSQL = strExtraSQL & vbCrLf & strSQLToAdd
	End If
End Sub

%>
