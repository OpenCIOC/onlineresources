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
<script language="python" runat="server">
from xml.etree import cElementTree as ET

def makeEventScheduleValue_l(strName, strValue):
	strValue = strValue or u'<SCHEDULES />'
	xml = ET.fromstring(strValue.encode('utf-8'))
	lines = []
	for item in xml:
		attrib = item.attrib
		if not attrib.get('START_DATE'):
			continue

		lines.append(format_event_schedule_line(attrib))

	Response.Write(u"<td class=""FieldLabelLeftClr"">" + strName + u"</td>")
	Response.Write(u"<td>")
	Response.Write(Markup(u'<br>').join(lines))
	Response.Write(u"</td>")
</script>

<%

Const FB_REC = 0
Const FB_PUB = 1
Const FB_CAT = 2
Const FB_LIST = 3

Sub makeDropDownValue(strName, strValue, strFunction, bLangID, strFieldName)
	Response.Write("<td class=""FieldLabelLeftClr"">" & strName & "</td>")
	Response.Write("<td>")
	If Not Nl(strValue) And IsIDType(strValue) Then
		Dim cmdDropDown, rsDropDown
		Set cmdDropDown = Server.CreateObject("ADODB.Command")
		With cmdDropDown
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "SELECT " & strFunction & "(" & strValue & StringIf(Not Nl(strFieldName),"," & QsNl(strFieldName)) & StringIf(bLangID,",@@LANGID") & StringIf(strFunction="dbo.fn_GBL_DisplayCurrency",",1") & ") AS DropDown"
			.CommandType = adCmdText
			.CommandTimeout = 0
		End With
		Set rsDropDown = Server.CreateObject("ADODB.Recordset")
		With rsDropDown
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdDropDown
			If Not .EOF Then
				Response.Write(.Fields("DropDown"))
			End If
			.Close
		End With
		Set rsDropDown = Nothing
		Set cmdDropDown = Nothing
	Else
		Response.Write(strValue)
	End If
	Response.Write("</td>")
End Sub

Sub makeChecklistValue(strName, strValue, strPrefix, strTable)
	Response.Write("<td class=""FieldLabelLeftClr"">" & strName & "</td>")
	Response.Write("<td>")
	If InStr(1,Ns(strValue),"<" & strPrefix & "S>") Then
		Dim strSQL
		strSQL = _
		"DECLARE @conStr nvarchar(3), @returnStr nvarchar(max), @Notes nvarchar(MAX), @data xml = " & QsN(strValue) & vbCrLf & _
		"SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')" & vbCrLf & _
		"SET @Notes = @data.value('*[1]/NOTE[1]', 'nvarchar(max)')" & vbCrLf & _
		"SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') " & vbCrLf & _
		"	+ chkn.Name" & vbCrLf & _
		"	+ CASE WHEN prn.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') + prn.Notes END" & vbCrLf & _
		"FROM (" & vbCrLf & _
		"SELECT N.value('@ID', 'int') AS pk, N.value('@NOTE', 'nvarchar(255)') AS Notes FROM @data.nodes('*/*/*') AS T(N)" & vbCrLf & _
		") AS prn" & vbCrLf & _
		"" & vbCrLf & _
		"	INNER JOIN " & strTable & " chk" & vbCrLf & _
		"		ON prn.pk=chk." & strPrefix & "_ID" & vbCrLf & _
		"	INNER JOIN " & strTable & "_Name chkn" & vbCrLf & _
		"		ON chk." & strPrefix & "_ID=chkn." & strPrefix & "_ID AND chkn.LangID=@@LANGID" & vbCrLf & _
		"ORDER BY chk.DisplayOrder, chkn.Name" & vbCrLf & _
		"" & vbCrLf & _
		"IF @returnStr IS NULL SET @returnStr = ''" & vbCrLf & _
		"IF @returnStr = '' SET @conStr = ''" & vbCrLf & _
		"" & vbCrLf & _
		"IF @Notes IS NOT NULL BEGIN" & vbCrLf & _
		"	SET @returnStr = @returnStr + @conStr + @Notes" & vbCrLf & _
		"END" & vbCrLf & _
		"" & vbCrLf & _
		"IF @returnStr = '' SET @returnStr = NULL" & vbCrLf & _
		"SELECT @returnStr as CheckList"

		Dim cmdDropDown, rsDropDown
		Set cmdDropDown = Server.CreateObject("ADODB.Command")
		With cmdDropDown
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = strSQL
			.CommandType = adCmdText
			.CommandTimeout = 0
		End With
		Set rsDropDown = Server.CreateObject("ADODB.Recordset")
		With rsDropDown
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdDropDown
			If Not .EOF Then
				Response.Write(.Fields("CheckList"))
			End If
			.Close
		End With
		Set rsDropDown = Nothing
		Set cmdDropDown = Nothing

	Else
		Response.Write(Server.HTMLEncode(strValue))
	End If
	Response.Write("</td>")

End Sub

Sub printFeedbackInfo(intFBID,intDbAreaID,intFBType)
	Dim intError
	intError = 0

	Dim cmdFb, rsFb, fld
	Set cmdFb = Server.CreateObject("ADODB.Command")
	With cmdFb
		.ActiveConnection = getCurrentAdminCnn()
		Select Case intFBType
			Case FB_PUB
				.CommandText = "dbo.sp_CIC_Feedback_Pub_s"
			Case FB_REC
				.CommandText = "dbo.sp_" & ps_strDbArea & "_Feedback_s"
			Case Else
				.CommandText = "dbo.sp_" & ps_strDbArea & "_Feedback_ls"
		End Select
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		If Not intFBType=FB_LIST Then
			.Parameters.Append .CreateParameter("@FB_ID", adInteger, adParamInput, 4, intFBID)
		ElseIf ps_intDbArea = DM_VOL Then
			.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, intDbAreaID)		
		Else
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, intDbAreaID)
		End If
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeDOM)
	End With
	Set rsFb = cmdFb.Execute
	
	With rsFb
		If Not .EOF Then
			intError = .Fields("Error")
			If intError <> 0 Then
				Call handleError(Nz(.Fields("ErrMsg"),TXT_UNKNOWN_ERROR_OCCURED),vbNullString,vbNullString)
			End If
		End If
	End With

	If intError = 0 Then

	Set rsFb = rsFb.NextRecordset

	Dim dicFieldNames, strFieldDisplay, strFieldName
	Set dicFieldNames = Server.CreateObject("Scripting.Dictionary")

	dicFieldNames("FEEDBACK_KEY_MATCH") = TXT_FEEDBACK_KEY
	
	If intFBType <> FB_PUB Then
		With rsFb
			While Not .EOF
				strFieldName = .Fields("FieldName").Value
				strFieldDisplay = .Fields("FieldDisplay").Value
				If ps_intDbArea = DM_CIC And (strFieldName = "ORG_LEVEL_1" Or strFieldName = "ORG_LEVEL_2" Or strFieldName = "ORG_LEVEL_3") Then
					strFieldDisplay = Nz(get_view_data_cic("OrgLevel" & Right(strFieldName, 1) & "Name"), strFieldDisplay)
				End If
				dicFieldNames(strFieldName) = strFieldDisplay
				.MoveNext
			Wend
		End With
		
		' Note - this does not yet cover all field names for special or multi-part fields
		
		If ps_intDbArea = DM_CIC Then
			dicFieldNames("BUILDING") = TXT_BUILDING
			dicFieldNames("CARE_OF") = TXT_MAIL_CO
			dicFieldNames("BOX_TYPE") = TXT_BOX_TYPE
			dicFieldNames("CITY") = TXT_CITY
			dicFieldNames("COUNTRY") = TXT_COUNTRY
			dicFieldNames("ELIGIBILITY_NOTES") = Nz(dicFieldNames("ELIGIBILITY"),"ELIGIBILITY") & " - " & TXT_NOTES
			dicFieldNames("EMPLOYEES_FT") = Nz(dicFieldNames("EMPLOYEES"),"EMPLOYEES") & " - " & TXT_FULL_TIME
			dicFieldNames("EMPLOYEES_PT") = Nz(dicFieldNames("EMPLOYEES"),"EMPLOYEES") & " - " & TXT_PART_TIME
			dicFieldNames("EMPLOYEES_TOTAL") = Nz(dicFieldNames("EMPLOYEES"),"EMPLOYEES") & " - " & TXT_TOTAL
			dicFieldNames("LOGO_ADDRESS_LINK") = TXT_LOGO_LINK_ADDRESS
			dicFieldNames("LOGO_ADDRESS_ALT_TEXT") = TXT_LOGO_ALT_TEXT
			dicFieldNames("LOGO_ADDRESS_HOVER_TEXT") = TXT_LOGO_HOVER_TEXT
			dicFieldNames("PO_BOX") = TXT_BOX_NUMBER
			dicFieldNames("POSTAL_CODE") = TXT_POSTAL_CODE
			dicFieldNames("PROVINCE") = TXT_PROVINCE
			dicFieldNames("STREET") = TXT_STREET
			dicFieldNames("STREET_DIR") = TXT_STREET_DIR
			dicFieldNames("STREET_NUMBER") = TXT_STREET_NUMBER
			dicFieldNames("STREET_TYPE") = TXT_STREET_TYPE
			dicFieldNames("SUFFIX") = TXT_SUFFIX
		End If
		
		If ps_intDbArea = DM_VOL Then
			dicFieldNames("ORG_NAME") = TXT_ORG_NAMES
			dicFieldNames("MINIMUM_HOURS_PER") = Nz(dicFieldNames("MINIMUM_HOURS"),"MINIMUM_HOURS") & " / ?"
			dicFieldNames("NUM_NEEDED_NOTES") = Nz(dicFieldNames("NUM_NEEDED"),"NUM_NEEDED") & " - " & TXT_NOTES
			dicFieldNames("NUM_NEEDED_TOTAL") = Nz(dicFieldNames("NUM_NEEDED"),"NUM_NEEDED") & " - " & TXT_INDIVIDUALS_WANTED & " (" & TXT_TOTAL & ")"
			dicFieldNames("SCHEDULE_GRID") = Nz(dicFieldNames("SCHEDULE"),"SCHEDULE")
			dicFieldNames("START_DATE_FIRST") = Nz(dicFieldNames("START_DATE"),"START_DATE") & " - " & TXT_ON_AFTER_DATE
			dicFieldNames("START_DATE_LAST") = Nz(dicFieldNames("START_DATE"),"START_DATE") & " - " & TXT_ON_BEFORE_DATE
		End If
	
		dicFieldNames("EMAIL") = TXT_EMAIL
		dicFieldNames("FAX") = TXT_FAX
		dicFieldNames("MAX_AGE") = TXT_MAX_AGE
		dicFieldNames("MIN_AGE") = TXT_MIN_AGE
		dicFieldNames("NAME") = TXT_NAME
		dicFieldNames("ORG") = TXT_ORGANIZATION
		dicFieldNames("PHONE") = TXT_PHONE
		dicFieldNames("PHONE1") = TXT_PHONE & " #1"
		dicFieldNames("PHONE2") = TXT_PHONE & " #2"
		dicFieldNames("PHONE3") = TXT_PHONE & " #3"
		dicFieldNames("SOURCE") = TXT_SOURCE
		dicFieldNames("TITLE") = TXT_TITLE		
		Set rsFb = rsFb.NextRecordset
	Else
		dicFieldNames("GeneralHeadings") = TXT_GENERAL_HEADINGS
	End If
	
	With rsFb
		If Not .EOF Then
			If ps_intDbArea = DM_VOL Then
				If Not Nl(.Fields("VNUM_FB")) Then
%>
<p><strong><em><%=.Fields("POSITION_TITLE_FB")%> (<%=.Fields("ORG_NAME_FULL_FB")%>)</em></strong> [ <a href="<%=makeVOLDetailsLink(.Fields("VNUM_FB"), IIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber,vbNullString),vbNullString)%>"><%=TXT_RECORD_DETAILS%></a> ]</p>				
<hr>
<%
				End If
			Else
				If Not Nl(.Fields("NUM_FB")) Then
%>
<p><strong><em><%=.Fields("ORG_NAME_FULL_FB")%> (<%=.Fields("NUM_FB")%>)</em></strong> [ <a href="<%=makeDetailsLink(.Fields("NUM_FB"), StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber),vbNullString)%>"><%=TXT_RECORD_DETAILS%></a> ]</p>
<hr>
<%
				End If
			End If
%>

<%
			While Not .EOF
%>
<table class="NoBorder cell-padding-3">
<tr>
	<td class="FieldLabelLeftClr"><%=TXT_FEEDBACK_ID%></td>
	<td><%=rsFb.Fields("FB_ID")%></td>
</tr>
<%				If intFBType = FB_PUB Then%>
<tr>
	<td class="FieldLabelLeftClr"><%=TXT_FOR_PUBLICATION%></td>
	<td><%=rsFb.Fields("PubCode")%></td>
</tr>
<%				End If%>
<%				If g_bMultiLingual Then%>
<tr>
	<td class="FieldLabelLeftClr"><%=TXT_FEEDBACK_LANGUAGE%></td>
	<td><%=rsFb.Fields("LanguageName")%></td>
</tr>
<%				End If
				If ps_intDomain <> DM_VOL Then
					If Not Nl(rsFb.Fields("AUTH_TYPE")) Then%>
<tr>
	<td class="FieldLabelLeftClr"><%=TXT_AUTHORIZATION%></td>
	<td><%
						Select Case rsFb.Fields("AUTH_TYPE")
							Case "A"
								If Not Nl(rsFb.Fields("User_ID")) Then
%>
<%=TXT_AUTH_GIVEN_FOR & IIf(rsFb.Fields("AUTH_INQUIRY"),TXT_USE_INQUIRY & "; ",vbNullString) & IIf(rsFb.Fields("AUTH_ONLINE"),TXT_USE_ONLINE & "; ",vbNullString) & IIf(rsFb.Fields("AUTH_PRINT"),TXT_USE_PRINT & "; ",vbNullString) & IIf(Not (rsFb.Fields("AUTH_INQUIRY") Or rsFb.Fields("AUTH_ONLINE") Or rsFb.Fields("AUTH_ONLINE")), TXT_NONE_SELECTED, vbNullString)%>
<%
								Else
%>
<%=TXT_AUTH_GIVEN%>
<%
								End If
							Case "C"
%>
<%=TXT_CONTACT_SUBMITTER%>
<%
							Case "I"
%>
<%=TXT_INTERNAL_REVIEW%>
<%
							Case "E"
%>
<%=TXT_AUTH_INQUIRIES_ONLY%>
<%			
							Case "N"
%>
<%=TXT_AUTH_NOT_RECEIVED%>
<%
						End Select
	%></td>
</tr>
<%
					End If
				End If
				
				Dim bHidePrivateData
				If ps_intDbArea = DM_CIC And intFBType <> FB_PUB Then
					bHidePrivateData = g_bRespectPrivacyProfile And .Fields("IS_PRIVATE") = SQL_TRUE
				Else
					bHidePrivateData = False
				End If
				
				For Each fld in .Fields
					If Not Nl(fld.Value) _
						And Not reEquals(fld.Name,"(BT_PB_ID)|(CatCode)|(LangID)|(LanguageName)|(FB_ID)|(PB_FB_ID)|(IS_PRIVATE)|(PubCode)|(User_ID)|(AUTH_.*)|(.*_FB)",True,False,True,False) Then
						Response.Write("<tr>")
						Select Case fld.Name
							Case "FB_NOTES"
								Response.Write("<td class=""FieldLabelLeftClr"">" & TXT_FEEDBACK_NOTES & "</td>")
								Response.Write("<td>" & fld.Value & "</td>")
							Case "FEEDBACK_OWNER"
								Response.Write("<td class=""FieldLabelLeftClr"">" & TXT_FEEDBACK_OWNER & "</td>")
								Response.Write("<td>" & fld.Value & "</td>")
							Case "FULL_UPDATE"
								Response.Write("<td class=""FieldLabelLeftClr"">" & TXT_FULL_REVIEW & "</td>")
								Response.Write("<td>" & IIf(fld.Value,TXT_YES,TXT_NO) & "</td>")
							Case "IPAddress"
								Response.Write("<td class=""FieldLabelLeftClr"">" & TXT_SUBMITTER_IP & "</td>")
								Response.Write("<td>" & fld.Value & "</td>")
							Case "NO_CHANGES"
								Response.Write("<td class=""FieldLabelLeftClr"">" & TXT_NO_CHANGES & "</td>")
								Response.Write("<td>" & IIf(fld.Value,TXT_YES,TXT_NO) & "</td>")
							Case "REMOVE_RECORD"
								Response.Write("<td class=""FieldLabelLeftClr"">" & TXT_REMOVE_RECORD & "</td>")
								Response.Write("<td>" & IIf(fld.Value,TXT_YES,TXT_NO) & "</td>")
							Case "SUBMITTED_BY"
								Response.Write("<td class=""FieldLabelLeftClr"">" & TXT_SUBMITTED_BY & "</td>")
								Response.Write("<td>" & fld.Value & "</td>")
							Case "SUBMITTED_BY_EMAIL"
								Response.Write("<td class=""FieldLabelLeftClr"">" & TXT_SUBMITTER_EMAIL & "</td>")
								Response.Write("<td><a href=""mailto:" & fld.Value & """>" & fld.Value & "</a></td>")
							Case "SUBMIT_DATE"
								Response.Write("<td class=""FieldLabelLeftClr"">" & TXT_DATE_SUBMITTED & "</td>")
								Response.Write("<td>" & DateString(fld.Value,True) & "</td>")
							Case "ACCESSIBILITY"
								If ps_intDbArea = DM_VOL Then
									Call makeChecklistValue(Nz(dicFieldNames(fld.Name), fld.Name), fld.Value, "AC", "GBL_Accessibility")
								ElseIf Not bHidePrivateData Then
									Response.Write("<td class=""FieldLabelLeftClr"">" & Nz(dicFieldNames(fld.Name),fld.Name) & "</td>")
									Response.Write("<td>" & Server.HTMLEncode(fld.Value) & "</td>")
								End If
							Case "ACCREDITED"
								If Not bHidePrivateData Then
									Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_CIC_DisplayAccreditation",True,Null)
								End If
							Case "CERTIFIED"
								If Not bHidePrivateData Then
									Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_CIC_DisplayCertification",True,Null)
								End If
							Case "COMMITMENT_LENGTH"
								Call makeChecklistValue(Nz(dicFieldNames(fld.Name), fld.Name), fld.Value, "CL", "VOL_CommitmentLength")
							Case "INTERACTION_LEVEL"
								Call makeChecklistValue(Nz(dicFieldNames(fld.Name), fld.Name), fld.Value, "IL", "VOL_InteractionLevel")
							Case "INTERESTS"
								Call makeChecklistValue(Nz(dicFieldNames(fld.Name), fld.Name), fld.Value, "AI", "VOL_Interest")
							Case "EMPLOYEES_RANGE"
								If Not bHidePrivateData Then
									Response.Write("<td class=""FieldLabelLeftClr"">" & Nz(dicFieldNames(fld.Name),fld.Name) & "</td>")
									Response.Write("<td>")
									Dim intERID
									intERID = fld.Value
									If Not Nl(intERID) And IsIDType(intERID) Then
										Dim cmdEmployeeRange, rsEmployeeRange
										Set cmdEmployeeRange = Server.CreateObject("ADODB.Command")
										With cmdEmployeeRange
											.ActiveConnection = getCurrentAdminCnn()
											.CommandText = "dbo.sp_CIC_EmployeeRange_s"
											.CommandType = adCmdStoredProc
											.CommandTimeout = 0
											.Parameters.Append .CreateParameter("@ER_ID", adInteger, adParamInput, 4, intERID)
										End With
										Set rsEmployeeRange = Server.CreateObject("ADODB.Recordset")
										With rsEmployeeRange
											.CursorLocation = adUseClient
											.CursorType = adOpenStatic
											.Open cmdEmployeeRange
											If Not .EOF Then
												Response.Write(.Fields("Range"))
											End If
											.Close
										End With
										Set rsEmployeeRange = Nothing
										Set cmdEmployeeRange = Nothing
									Else
										Response.Write(fld.Value)
									End If
									Response.Write("</td>")		
								End If
							Case "EVENT_SCHEDULE"
								If Not bHidePrivateData Then
									Call makeEventScheduleValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value)
								End If
							Case "FBKEY"
							Case "FISCAL_YEAR_END"
								If Not bHidePrivateData Then
									Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_CIC_DisplayFiscalYearEnd",True,Null)
								End If
							Case "GEOCODE_TYPE"
								Dim strGeoCodeType
								Select Case fld.Value
									Case GC_BLANK
										strGeoCodeType = TXT_GC_BLANK_NO_GEOCODE
									Case GC_SITE
										strGeoCodeType = TXT_GC_SITE_ADDRESS
									Case GC_INTERSECTION
										strGeoCodeType = TXT_GC_INTERSECTION
									Case GC_MANUAL
										strGeoCodeType = TXT_GC_MANUAL
								End Select
								Response.Write("<td class=""FieldLabelLeftClr"">" & Nz(dicFieldNames(fld.Name),fld.Name) & "</td>")
								Response.Write("<td>" & strGeoCodeType & "</td>")
							CASE "LANGUAGES"
								If Not bHidePrivateData Then
									Call makeLanguagesValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value)
								End If
							Case "MemberID"
							Case "MINIMUM_HOURS_PER"
								Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_VOL_DisplayMinHoursPer",True,Null)
							Case "PAYMENT_TERMS"
								If Not bHidePrivateData Then
									Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_GBL_DisplayPaymentTerms",True,Null)
								End If
							Case "PREF_CURRENCY"
								If Not bHidePrivateData Then
									Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_GBL_DisplayCurrency",False,Null)
								End If
							Case "PREF_PAYMENT_METHOD"
								If Not bHidePrivateData Then
									Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_GBL_DisplayPaymentMethod",True,Null)
								End If
							Case "QUALITY"
								If Not bHidePrivateData Then
									Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_CIC_FullQuality",False,Null)
								End If
							Case "RECORD_TYPE"
								If Not bHidePrivateData Then
									Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_CIC_FullRecordType",False,Null)
								End If
							Case "SEASONS"
								Call makeChecklistValue(Nz(dicFieldNames(fld.Name), fld.Name), fld.Value, "SSN", "VOL_Seasons")
							Case "SKILLS"
								Call makeChecklistValue(Nz(dicFieldNames(fld.Name), fld.Name), fld.Value, "SK", "VOL_Skill")
							Case "SOCIAL_MEDIA"
								If Not bHidePrivateData Then
									Call makeSocialMediaValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value)
								End If
							Case "SUITABILITY"
								Call makeChecklistValue(Nz(dicFieldNames(fld.Name), fld.Name), fld.Value, "SB", "VOL_Suitability")
							Case "TRAINING"
								Call makeChecklistValue(Nz(dicFieldNames(fld.Name), fld.Name), fld.Value, "TRN", "VOL_Training")
							Case "TRANSPORTATION"
								Call makeChecklistValue(Nz(dicFieldNames(fld.Name), fld.Name), fld.Value, "TRP", "VOL_Transportation")
							Case "TYPE_OF_PROGRAM"
								If Not bHidePrivateData Then
									Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_CCR_DisplayTypeOfProgram",True,Null)
								End If
							Case "WARD"
								If Not bHidePrivateData Then
									Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_CIC_FullWard",False,Null)
								End If
							Case Else
								Dim strFieldGeneralType, strFieldSpecificType
								If reEquals(fld.Name,".*((EXEC)|(CONTACT)|(SOURCE))(_[0-9A-Z])?_([^_]+)",False,False,True,False) Then
									strFieldGeneralType = reReplace(fld.Name,"(.*((EXEC)|(CONTACT)|(SOURCE))(_[0-9A-Z])?)_([^_]+)","$1",False,False,False,False)
									strFieldSpecificType = reReplace(fld.Name,"(.*((EXEC)|(CONTACT)|(SOURCE))(_[0-9A-Z])?)_([^_]+)","$7",False,False,False,False)
									Response.Write("<td class=""FieldLabelLeftClr"">")
									Response.Write(Nz(dicFieldNames(strFieldGeneralType),strFieldGeneralType) & " - " & Nz(dicFieldNames(strFieldSpecificType),strFieldSpecificType))
									Response.Write("</td>")
									Response.Write("<td>" & Server.HTMLEncode(fld.Value) & "</td>")
								ElseIf reEquals(fld.Name,"((MAIL)|(SITE))_.*",False,False,True,False) And fld.Name <> "SITE_LOCATION" Then
									strFieldGeneralType = reReplace(fld.Name,"((MAIL)|(SITE))_(.*)","$1",False,False,False,False) & "_ADDRESS"
									strFieldSpecificType = reReplace(fld.Name,"((MAIL)|(SITE))_(.*)","$4",False,False,False,False)
									Response.Write("<td class=""FieldLabelLeftClr"">")
									Response.Write(Nz(dicFieldNames(strFieldGeneralType),strFieldGeneralType) & " - " & Nz(dicFieldNames(strFieldSpecificType),strFieldSpecificType))
									Response.Write("</td>")
									Response.Write("<td>" & Server.HTMLEncode(fld.Value) & "</td>")
								ElseIf reEquals(fld.Name,"EXTRA_DROPDOWN_.*",False,False,True,False) Then
									If Not bHidePrivateData Then
										Call makeDropDownValue(Nz(dicFieldNames(fld.Name),fld.Name),fld.Value,"dbo.fn_CIC_DisplayExtraDropDown",True,fld.Name)
									End If
								Else
									If Not bHidePrivateData Then
										Response.Write("<td class=""FieldLabelLeftClr"">" & Nz(dicFieldNames(fld.Name),fld.Name) & "</td>")
										Response.Write("<td>" & Replace(Server.HTMLEncode(fld.Value),vbCrLf,"<br>") & "</td>")
									End If
								End If
						End Select
						Response.Write("</tr>")
					End If
				Next
%>
</table>
<%				If bHidePrivateData Then%>
<p><span class="AlertBubble"><%=TXT_REMAINDER_HIDDEN%></span></p>
<%
				End If
				.MoveNext
				If Not .EOF Then
%>
<hr>
<%
				End If
			Wend
		Else
			If intFBType = FB_LIST Then
%>
<p><span class="AlertBubble"><%=TXT_NO_FEEDBACK_OR_NOT_AVAILABLE%></span></p>
<%
			Else
%>
<p><span class="AlertBubble"><%=TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intFBID)%></span></p>
<%
			End If
		End If
	End With

	End If
End Sub

Sub deleteFeedback(intFBID,intFBType)
	Dim objReturn, objErrMsg
	Dim cmdDeleteFb, rsDeleteFb
	Set cmdDeleteFb = Server.CreateObject("ADODB.Command")
	With cmdDeleteFb
		.ActiveConnection = getCurrentAdminCnn()
		Select Case intFBType
			Case FB_PUB
				.CommandText = "dbo.sp_CIC_Feedback_Pub_d"
			Case Else
				.CommandText = "dbo.sp_" & ps_strDbArea & "_Feedback_d"
		End Select
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		If intFBType = FB_PUB Then
			.Parameters.Append .CreateParameter("@PB_FB_ID", adInteger, adParamInput, 4, intRevFBID)
			.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		Else
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@FB_ID", adInteger, adParamInput, 4, intRevFBID)
		End If
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsDeleteFb = cmdDeleteFb.Execute
	Set rsDeleteFb = rsDeleteFb.NextRecordset
	
	Select Case objReturn.Value
		Case 0
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
				"revfeedback.asp", _
				vbNullString, _
				False)
		Case Else
			Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
				"revfeedback.asp", _
				vbNullString)
	End Select
End Sub
Sub makeLanguagesValue(strName, strValue)
	Dim xmlDoc, xmlNode, strNotes
	Response.Write("<td class=""FieldLabelLeftClr"">" & strName & "</td>")
	Response.Write("<td>")

	
	If Not Nl(strValue) Then
		Dim cmdLanguages, rsLanguages, strReturn
		Set cmdLanguages = Server.CreateObject("ADODB.Command")
		With cmdLanguages
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_CIC_Languages_l_Feedback"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@Value", adLongVarWChar, adParamInput, -1, strValue)
		End With
		Set rsLanguages = Server.CreateObject("ADODB.Recordset")


		Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
		xmlDoc.async = False
		xmlDoc.setProperty "SelectionLanguage", "XPath"
		xmlDoc.loadXML Ns(strValue)
		Set xmlNode = xmlDoc.selectSingleNode("LANGUAGES/NOTE")
		If Not xmlNode Is Nothing Then
			strNotes = xmlNode.text
		Else
			strNotes = vbNullString
		End If

		strReturn = vbNullString

		With rsLanguages
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdLanguages
			If Not .EOF Or Not Nl(strNotes) Then
				strReturn = "<table class=""NoBorder cell-padding-2"">"
				While Not .EOF
					strReturn = strReturn & "<tr><td>" & .Fields("Name")
					If Not Nl(.Fields("DETAILS")) Or Not Nl(.Fields("NOTE")) Then
						strReturn = strReturn & " - " & Ns(.Fields("DETAILS")) & StringIf(Not Nl(.Fields("DETAILS")) And Not Nl(.Fields("NOTE")), ", ") & Server.HTMLEncode(Ns(.Fields("NOTE")))
					End If
					strReturn = strReturn & "</td></tr>"
					.MoveNext
				Wend
				If Not Nl(strNotes) Then
					strReturn = strReturn & "<tr><td>" & Server.HTMLEncode(strNotes) & "</td></tr>"
				End If
				strReturn = strReturn & "</table>"
			End If
			.Close
		End With
		Set rsLanguages = Nothing
		Set cmdLanguages = Nothing

		Response.Write(strReturn)
	
	End If

	Response.Write("</td>")
End Sub
Sub makeSocialMediaValue(strName, strValue)
	Dim xmlDoc, xmlNode, xmlChildNode
	Response.Write("<td class=""FieldLabelLeftClr"">" & strName & "</td>")
	Response.Write("<td>")
	'Response.Write("<pre>" & Server.HTMLEncode(strValue) & "</pre>")

	If Not Nl(strValue) Then
		Dim cmdSocialMedia, rsSocialMedia
		Set cmdSocialMedia = Server.CreateObject("ADODB.Command")
		With cmdSocialMedia
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "SELECT CAST(dbo.fn_GBL_FullSocialMedia(" & QsNl(strValue) & ") AS nvarchar(max)) AS SocialMedia"
			.CommandType = adCmdText
			.CommandTimeout = 0
		End With
		Set rsSocialMedia = Server.CreateObject("ADODB.Recordset")
		With rsSocialMedia
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdSocialMedia
			If Not .EOF Then
				Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
				xmlDoc.async = False
				xmlDoc.setProperty "SelectionLanguage", "XPath"
				xmlDoc.loadXML Nz(.Fields("SocialMedia"), "<SOCIAL_MEDIA/>")
	
			Else
				xmlDoc.loadXML "<SOCIAL_MEDIA/>"
			End If
			.Close
		End With
		Set rsSocialMedia = Nothing
		Set cmdSocialMedia = Nothing

		Dim strReturn, strGeneralURL, strSmName, strUrl, strProto
		strReturn = vbNullString

		Set xmlNode = xmlDoc.selectSingleNode("/SOCIAL_MEDIA")
		If Not xmlNode Is Nothing Then
			strReturn = "<table class=""NoBorder cell-padding-2"">"
			For Each xmlChildNode in xmlNode.childNodes
				strGeneralURL = xmlChildNode.getAttribute("GeneralURL")
				strName = xmlChildNode.getAttribute("Name")
				strUrl = xmlChildNode.getAttribute("URL")
				strProto = xmlChildNode.getAttribute("Proto")
				If Nl(strProto) Then
					strProto = "https://"
				End If
				If Nl(strUrl) Then
					strUrl = TXT_CONTENT_DELETED
				Else
					strUrl = CStr(strProto) & CStr(strUrl)
				End If
				strReturn = strReturn & "<tr>" & vbCrLf & _
					"<td><img src=" & AttrQs(xmlChildNode.getAttribute("Icon16")) & " width=""16"" height=""16"" alt=" & AttrQs(strSmName) & ">&nbsp;" & _
					StringIf(Not Nl(strGeneralURL),"<a href=""https://" & strGeneralURL & """>") & _
					strSmName & _
					StringIf(Not Nl(strGeneralURL),"</a>") & _
					"</td>" & _
					"<td>" & Server.HTMLEncode(strUrl) & "</td>" & _
					"</tr>"
			Next
			strReturn = strReturn & "</table>"
		End If

		Response.Write(strReturn)

	End If

	Response.Write("</td>")
End Sub
Sub makeEventScheduleValue(strName, strValue):
	Dim junk
	junk = makeEventScheduleValue_l(strName, strValue)
End Sub
%>
