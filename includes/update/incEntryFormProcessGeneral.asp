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
import re
import itertools
from datetime import time
from functools import partial

from cioc.core.i18n import gettext
from cioc.core import constants as const

_ = lambda x: gettext(x, pyrequest)
time_re = re.compile(r'''(?P<hour>\d?\d):(?P<minute>\d\d)(:(?P<second>\d\d))?(\s+(?P<ampm>(pm|am)))?''')
 
def check_time(label, value, checkAddValidationError=None):
	label = label + _(': ')
	if value is None:
		return
	if not value.strip():
		return

	time_match = time_re.search(value.lower())
	if time_match is None:
		checkAddValidationError(label + _('Invalid Time'))
		return None

	hour = time_match.group('hour')
	minute = time_match.group('minute')
	second = time_match.group('second')
	ampm = time_match.group('ampm')
	# log.debug('AMPM: %s', ampm)
	if ampm is None:
		ampm = ''

	hour = int(hour, 10)
	minute = int(minute, 10)
	if second is None:
		second = '0'
	second = int(second, 10)

	if hour < 0:
		checkAddValidationError(label + _('Hour is not valid'))
		return None

	# includes a time
	if hour < 12 and ampm.lower() == 'pm':
		# log.debug("PM bump up 12 hours")
		hour += 12

	elif hour == 12 and ampm.lower() == 'am':
		# log.debug("AM and 12, make 0")
		hour = 0

	if hour > 23:
		checkAddValidationError(label + _('Hour is not valid'))
		return None

	if 0 > minute or minute > 59:
		checkAddValidationError(label + _('Minute is not valid'))
		return None

	if 0 > second or second > 59:
		checkAddValidationError(label + _('Second is not valid'))
		return None

	value = time(hour, minute, second)
	return value


def getEventScheduleEntrySQL(sched_no, sched_id, vals, checkDate, checkInteger, checkID, checkLength, checkAddValidationError):
	is_new = sched_id.startswith('NEW')
	validation_label_prefix = _('Schedule # ') + sched_no + _(' - ')
	start_date = vals.get('START_DATE')
	if start_date:
		start_date = start_date.strip()

	if is_new and not start_date:
		return None
	
	if not is_new:
		try:
			sched_id = int(sched_id, 10)
		except TypeError:
			return None

	if not start_date:
		# No Start date means it's a delete because start date is required
		return "DELETE FROM GBL_Schedule WHERE GblNUM = @NUM AND SchedID = {}".format(sched_id)

	def checkTime(label, value, name=None):
		if not value:
			vals[name] = None
			return

		value = check_time(label, value, checkAddValidationError)
		if value:
			value = value.isoformat()

		vals[name] = value

	def check_date(label, value, name=None):
		vals[name] = checkDate(label, value) or None

	recur_type = vals.get('RECURS_TYPE')
	if recur_type not in ['0', '1', '2', '3']:
		checkAddValidationError(validattion_label_prefix + _("Repeats") + _(': ') + _('Invalid Repeat Type'))
		return None

	to_check = [
		(_('Start Date'), 'START_DATE', partial(check_date, name='START_DATE')),
		(_('End Date'), 'END_DATE', partial(check_date, name='END_DATE')),
		(_('Start Time'), 'START_TIME', partial(checkTime, name='START_TIME')),
		(_('End Time'), 'END_TIME', partial(checkTime, name='END_TIME')),
	]

	def get_none(label, value, name=None):
		vals[name] = None
		
	def get_false(label, value, name=None):
		vals[name] = False
	
	def get_true(label, value, name=None):
		vals[name] = True

	def get_bool(label, value, name=None):
		vals[name] = bool(value)

	def get_zero(label, value, name=None):
		vals[name] = 0
	
	def get_and_check_int(label, value, name=None):
		checkInteger(label, value)
		if value == '' or value is None:
			vals[name] = None
			return
		try:
			vals[name] = int(value, 10)
		except TypeError:
			vals[name] = None

	def get_and_check_int_min_1(label, value, name=None):
		get_and_check_int(label, value, name=name)
		if not vals[name]:
			vals[name] = 1

	if recur_type != '0':
		to_check.append((_('Repeat Every'), 'RECURS_EVERY', partial(get_and_check_int_min_1, name='RECURS_EVERY')))
	else:
		to_check.append((None, 'RECURS_EVERY', partial(get_zero, name='RECURS_EVERY')))

	if recur_type == '1':
		to_check.append((None, 'RECURS_DAY_OF_WEEK', partial(get_true, name="RECURS_DAY_OF_WEEK")))
	else:
		to_check.append((None, 'RECURS_DAY_OF_WEEK', partial(get_false, name="RECURS_DAY_OF_WEEK")))

	if recur_type == '2':
		to_check.append((_('Day of Month'), 'RECURS_DAY_OF_MONTH', partial(get_and_check_int, name='RECURS_DAY_OF_MONTH')))
	else:
		to_check.append((None, 'RECURS_DAY_OF_MONTH', partial(get_none, name='RECURS_DAY_OF_MONTH')))

	if recur_type == '3':
		to_check.append((_('Week of Month'), 'RECURS_XTH_WEEKDAY_OF_MONTH', partial(get_and_check_int_min_1, name='RECURS_XTH_WEEKDAY_OF_MONTH')))
	else:
		to_check.append((None, 'RECURS_XTH_WEEKDAY_OF_MONTH', partial(get_none, name='RECURS_XTH_WEEKDAY_OF_MONTH')))
	
	if recur_type in ['1', '3']:
		to_check.extend((None, 'RECURS_WEEKDAY_%d' % i, partial(get_bool, name='RECURS_WEEKDAY_%d' % i)) for i in range(1, 8))
	else:
		to_check.extend((None, 'RECURS_WEEKDAY_%d' % i, partial(get_false, name='RECURS_WEEKDAY_%d' % i)) for i in range (1, 8)) 
		
	def escape_for_sql(value):
		if value is None:
			return 'NULL'
		elif isinstance(value, bool):
			return unicode(int(value))
		elif isinstance(value, int):
			return unicode(value)
		elif value:
			return u"'{}'".format(unicode(value).replace(u"'", "''"))

		return 'NULL'

	changes = []
	for label, field, check in to_check:
		value = vals.get(field)
		if label:
			label = validation_label_prefix + label
		check(label, value)
		value = vals.get(field)
		changes.append((field, escape_for_sql(value)))

	label_val = vals.get('Label') or None
	if label_val:
		checkLength(validation_label_prefix + _('Label'), label_val, const.TEXT_SIZE)
		
	label_val = escape_for_sql(label_val)

	if pyrequest.pageinfo.DbArea == const.DM_VOL:
		id_field = 'VolVNUM'
		record_id = '@VNUM'
	else:
		id_field = 'GblNUM'
		record_id = '@NUM'

	
	
	changes.append(('MODIFIED_BY', escape_for_sql(pyrequest.user.Mod)))
	if is_new:
		changes.append((id_field, record_id))
		changes.append(('CREATED_BY', escape_for_sql(pyrequest.user.Mod)))
		return u'''
			SET @SchedLabel = {label}
			INSERT INTO GBL_Schedule (CREATED_DATE, MODIFIED_DATE, {fields}) VALUES (GETDATE(), GETDATE(), {values}) 
			SET @SchedID = SCOPE_IDENTITY()
			IF @SchedLabel IS NOT NULL BEGIN
				INSERT INTO GBL_Schedule_Name (SchedID, LangID, Label) VALUES (@SchedID, @@LANGID, @SchedLabel)
			END
			'''.format(
				fields=u','.join(x[0] for x in changes),
				values=u','.join(x[1] for x in changes),
				label=label_val)
	else:
		return u'''
			SET @SchedID = {sched_id}
			SET @SchedLabel = {label}
			UPDATE GBL_Schedule SET {values} WHERE {id_field}={record_id} AND SchedID=@SchedID
			IF @SchedLabel IS NULL BEGIN
				DELETE FROM GBL_Schedule_Name WHERE SchedID=@SchedID AND LangID=@@LANGID
					AND EXISTS(SELECT * FROM GBL_Schedule WHERE SchedID=@SchedID AND {id_field}={record_id})
			END ELSE IF EXISTS(SELECT * FROM GBL_Schedule_Name WHERE SchedID=@SchedID AND LangID=@@LANGID) BEGIN
				UPDATE GBL_Schedule_Name SET Label=@SchedLabel WHERE SchedID=@SchedID AND LangID=@@LANGID
			END ELSE BEGIN
				INSERT INTO GBL_Schedule_Name (SchedID, LangID, Label) VALUES (@SchedID, @@LANGID, @SchedLabel)
			END
			'''.format(
				id_field=id_field, record_id=record_id,
				sched_id=sched_id, label=label_val,
				values=u','.join('%s=%s' % x for x in changes),
		)

def getEventScheduleSQL_l(checkDate, checkInteger, checkID, checkLength, checkAddValidationError):
	fields = ('Label START_DATE END_DATE START_TIME END_TIME RECURS_TYPE RECURS_EVERY RECURS_DAY_OF_WEEK '
			'RECURS_XTH_WEEKDAY_OF_MONTH RECURS_DAY_OF_MONTH').split()
	fields.extend('RECURS_WEEKDAY_%d' % i for i in range(1,8))

	output = []
	sched_ids = (pyrequest.POST.get("Sched_IDS") or u'').split(',')
	
	for sched_no, sched in enumerate(sched_ids, 1) :
		prefix = 'Sched_%s_' % sched
		vals = {x: pyrequest.POST.get(prefix + x) for x in fields}

		if 'NEW' in sched:
			sched_no = unicode(sched_no) + ' ' + _('(new)')
		else:
			sched_no = unicode(sched_no)

		entry = getEventScheduleEntrySQL(sched_no, sched, vals, checkDate, checkInteger, checkID, checkLength, checkAddValidationError)
		if not entry:
			continue

		output.append(entry)

	if output:
		output = itertools.chain(['DECLARE @SchedID int, @SchedLabel nvarchar(200)'], output)

	return u'\n'.join(output)

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
					IIf(Not Nl(.Fields("AccessURL")), IIf(.Fields("DomainFullSSLCompatible" & IIf(ps_intDbArea = DM_CIC, "CIC", "VOL")) And .Fields("ViewFullSSLCompatible" & IIf(ps_intDbArea = DM_CIC, "CIC", "VOL")), "https://", "http://") & .Fields("AccessURL"),IIf(get_db_option("DomainDefaultViewSSLCompatible" & IIf(ps_intDbArea = DM_CIC, "CIC", "VOL")), "https://", "http://") & IIf(ps_intDbArea = DM_CIC,g_strBaseURLCIC,g_strBaseURLVOL)) & _
					"/" & ps_strDbAreaDefaultPath & IIf(Nl(strRecordRoot), _
						"details.asp?" & IIf(ps_intDbArea=DM_VOL,"VNUM=" & strID,"NUM=" & strID) & "&", _
						strRecordRoot & strID & "?") & _
					StringIf(Not Nl(.Fields("ViewType")),IIf(ps_intDbArea=DM_VOL,"UseVOLVw=","UseCICVw=") & .Fields("ViewType") & "&") & _
					"Ln=" & g_objCurrentLang.Culture
			Else
				strDetailLink = TXT_VIEW_RECORD_AT & _
					IIf(Not Nl(.Fields("AccessURL")), IIf(.Fields("DomainFullSSLCompatible" & IIf(ps_intDbArea = DM_CIC, "CIC", "VOL")) And .Fields("ViewFullSSLCompatible" & IIf(ps_intDbArea = DM_CIC, "CIC", "VOL")), "https://", "http://") & .Fields("AccessURL"),IIf(get_db_option("DomainDefaultViewSSLCompatible" & IIf(ps_intDbArea = DM_CIC, "CIC", "VOL")), "https://", "http://") & IIf(ps_intDbArea = DM_CIC,g_strBaseURLCIC,g_strBaseURLVOL)) & _
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
				Call sendEmail(False, strSender, .Fields("SOURCE_EMAIL"), vbNullString, strSubject, strMsgText)
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
		strSQL = "DECLARE @SocialXml xml; DECLARE @SocialTable TABLE (SM_ID int not null, URL nvarchar(200), Protocol varchar(10))" & vbCrLf & _
				"SET @SocialXml = " & QsNl(strXML) & vbCrLf & _
				"INSERT INTO @SocialTable (SM_ID, URL, Protocol) " & vbCrLf & _
				"SELECT N.value('@SM_ID', 'int') AS SM_ID, N.value('@URL', 'nvarchar(200)') AS URL, N.value('@Proto', 'varchar(10)') AS Protocol" & vbCrLf & _
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

Function WrapCheckDate(strFldName, ByVal strValue)
	Dim strRetval
	If Nl(strValue) Then
		strRetval = vbNullString
	Else
		strRetval = CStr(strValue)
	End If
	Call checkDate(strFldName, strRetval)

	WrapCheckDate = strRetVal
End Function
Sub getEventScheduleSQL()
	Dim strSQLToAdd
	strSQLToAdd = getEventScheduleSQL_l(GetRef("WrapCheckDate"), GetRef("checkInteger"), GetRef("checkID"), _
			GetRef("checkLength"), GetRef("checkAddValidationError"))

	If Not Nl(strSQLToAdd) Then
		strExtraSQL = strExtraSQL & vbCrLf & strSQLToAdd
	End If
End Sub

%>

