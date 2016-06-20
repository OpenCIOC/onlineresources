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
<!--#include file="text/txtAgencyContact.asp" -->
<!--#include file="text/txtCommonForm.asp" -->
<!--#include file="text/txtEntryForm.asp" -->
<!--#include file="text/txtFeedback.asp" -->
<!--#include file="text/txtFeedbackCommon.asp" -->
<!--#include file="text/txtMailForm.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/update/incAgencyUpdateInfo.asp" -->
<%
Function makeEmployeeContents(rst, bPrivateField)
	Dim intEmpFT, intEmpPT, intEmpTotal
	
	If bPrivateField Then
		intEmpFT = rst("EMPLOYEES_FT")
		intEmpPT = rst("EMPLOYEES_PT")
		intEmpTotal = rst("EMPLOYEES_TOTAL")
	End If
	
	makeEmployeeContents = "<table class=""NoBorder cell-padding-2"">" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_FULL_TIME & TXT_COLON & "</td><td>" & Nz(intEmpFT,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_PART_TIME & TXT_COLON & "</td><td>" & Nz(intEmpPT,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_TOTAL_EMPLOYEES & TXT_COLON & "</td><td>" & Nz(intEmpTotal,"&nbsp;") & "</td></tr>" & _
			"</table>"
End Function

Function makeCCLicenseInfoContents(rst, bPrivateField)
	Dim strLCNumber, _
		dLCRenewal, _
		intLCTotal, _
		intLCInfant, _
		intLCToddler, _
		intLCPreschool, _
		intLCKindergarten, _
		intLCSchoolAge, _
		strLCNotes
	
	If Not bPrivateField Then
		strLCNumber = rst("LICENSE_NUMBER")
		dLCRenewal = rst("LICENSE_RENEWAL")
		intLCTotal = rst("LC_TOTAL")
		intLCInfant = rst("LC_INFANT")
		intLCToddler = rst("LC_TODDLER")
		intLCPreschool = rst("LC_PRESCHOOL")
		intLCKindergarten = rst("LC_KINDERGARTEN")
		intLCSchoolAge = rst("LC_SCHOOLAGE")
		strLCNotes = textToHTML(rst("LC_NOTES"))
	End If
	
	makeCCLicenseInfoContents = "<table class=""NoBorder cell-padding-2"">" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_LICENSE_NUMBER & TXT_COLON & "</td><td>" & Nz(strLCNumber,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_LICENSE_RENEWAL & TXT_COLON & "</td><td>" & Nz(dLCRenewal,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_CAPACITY & TXT_COLON & "</td><td>" & _
			"<table class=""BasicBorder cell-padding-2"">" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_TOTAL & "</td><td width=""50"">" & Nz(intLCTotal,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_INFANT & "</td><td width=""50"">" & Nz(intLCInfant,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_TODDLER & "</td><td width=""50"">" & Nz(intLCToddler,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_PRESCHOOL & "</td><td width=""50"">" & Nz(intLCPreschool,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_KINDERGARTEN & "</td><td width=""50"">" & Nz(intLCKindergarten,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_SCHOOL_AGE & "</td><td width=""50"">" & Nz(intLCSchoolAge,"&nbsp;") & "</td></tr>" & _
			"</table>" & _
			"</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_NOTES & TXT_COLON & "</td><td>" & Nz(strLCNotes,"&nbsp;") & "</td></tr>" & _
			"</table>"
End Function

Function makeContactContents(rst,strContactType,bPrivateField)
	Dim strName,strTitle,strOrg,aPhone(2),strFax,strEmail,i
	Dim xmlDoc, xmlNode
	
	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With

	xmlDoc.loadXML Nz(rst(strContactType).Value,"<CONTACT/>")
	Set xmlNode = xmlDoc.selectSingleNode("/CONTACT")
	
	If Not bPrivateField Then
		strName = xmlNode.getAttribute("NAME")
		strTitle = xmlNode.getAttribute("TITLE")
		strOrg = xmlNode.getAttribute("ORG")
		For i = 0 to 2
			aPhone(i) = xmlNode.getAttribute("PHONE" & i+1)
		Next
		strFax = xmlNode.getAttribute("FAX")
		strEmail = xmlNode.getAttribute("EMAIL")
	End If

	makeContactContents = "<table class=""NoBorder cell-padding-2"">" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_NAME & TXT_COLON & "</td><td>" & Nz(strName,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_TITLE & TXT_COLON & "</td><td>" & Nz(strTitle,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_ORGANIZATION & TXT_COLON & "</td><td>" & Nz(strOrg,"&nbsp;") & "</td></tr>"

	For i = 0 to 2
		makeContactContents = makeContactContents & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_PHONE & " #" & CStr(i+1) & TXT_COLON & "</td><td>" & Nz(aPhone(i),"&nbsp;") & "</td></tr>"
	Next
			
	makeContactContents = makeContactContents & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_FAX & TXT_COLON & "</td><td>" & Nz(strFax,"&nbsp;") & "</td></tr>" & _
			"<tr><td class=""FieldLabelLeftClr"">" & TXT_EMAIL & TXT_COLON & "</td><td>" & Nz(strEmail,"&nbsp;") & "</td></tr>" & _
			"</table>"
End Function

Function makeSpaceAvailableContents(rst,bPrivateField)
	Dim strReturn
	
	Dim bSpaceAvailable, _
		strNotes, _
		dSpaceAvailable
	
	If Not bPrivateField Then
		bSpaceAvailable = rst("SPACE_AVAILABLE")
		strNotes = rst("SPACE_AVAILABLE_NOTES")
		dSpaceAvailable = rst("SPACE_AVAILABLE_DATE")
	End If

	strReturn = strReturn & "<table class=""NoBorder cell-padding-2"">" & _
		"<tr><td class=""FieldLabelLeftClr"">" & TXT_SPACE_AVAILABLE & "</td><td>"
		
	If bPrivateField Then
		strReturn = strReturn & "&nbsp;"
	ElseIf Nl(bSpaceAvailable) Then
		strReturn = strReturn & TXT_UNKNOWN
	ElseIf bSpaceAvailable Then
		strReturn = strReturn & TXT_YES
	Else
		strReturn = strReturn & TXT_NO
	End If

	strReturn = strReturn & _
		"</td></tr>" & _
		"<tr valign=""top""><td class=""FieldLabelLeftClr"">" & TXT_NOTES & TXT_COLON & "</td><td>" & Nz(strNotes,"&nbsp;") & "</td></tr>" & _
		"<tr><td class=""FieldLabelLeftClr"">" & TXT_DATE_OF_CHANGE & TXT_COLON & "</td><td>" & Nz(dSpaceAvailable,"&nbsp;") & "</td></tr>" & _
		"</table>"

	makeSpaceAvailableContents = strReturn
End Function

Function makeRow(strFieldName,strFieldContents)
	makeRow = vbCrLf & _
		"<tr valign=""top""><td class=""FieldLabelClr"">" & _
			strFieldName & "</td><td width=""90%"">" & Nz(strFieldContents, "&nbsp;") & "</td></tr>"
End Function

Call makePageHeader(TXT_MAIL_FAX_FORM, TXT_MAIL_FAX_FORM, True, False, True, True)

Dim strNUM, _
	bNUMError

bNUMError = False
strNUM = Request("NUM")

If Nl(strNUM) Then
	bNUMError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
ElseIf Not IsNUMType(strNUM) Then
	bNUMError = True
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
Else

	Dim cmdFields, rsFields
	Set cmdFields = Server.CreateObject("ADODB.Command")
	With cmdFields
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_CIC_View_MailFormFields"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	End With
	Set rsFields = Server.CreateObject("ADODB.Recordset")
	With rsFields
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdFields
	End With

	Dim strSQL, _
		strCon

	strSQL = "SELECT bt.NUM, bt.RECORD_OWNER," & _
		"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & _
		"cioc_shared.dbo.fn_SHR_GBL_DateString(bt.CREATED_DATE) AS CREATED_DATE, " & _
		"cioc_shared.dbo.fn_SHR_GBL_DateString(btd.UPDATE_DATE) AS UPDATE_DATE, " & _
		"cioc_shared.dbo.fn_SHR_GBL_DateString(btd.UPDATE_SCHEDULE) AS UPDATE_SCHEDULE," & _
		"cioc_shared.dbo.fn_SHR_GBL_DateString(bt.MODIFIED_DATE) AS MODIFIED_DATE"

	With rsFields
		While Not .EOF
			If Not Nl(.Fields("FieldSelect")) And _
				Not reEquals(.Fields("FieldName"), _
					"(NUM)|(RECORD_OWNER)|(CREATED_DATE)|(UPDATE(_DATE)|(_SCHEDULE))", _
					True,False,True,False) Then
				strSQL = strSQL & "," & vbCrLf & .Fields("FieldSelect")
			End If
			.MoveNext
		Wend
		If Not .RecordCount = 0 Then
			.MoveFirst
		End If
	End With

	strSQL = strSQL & vbCrLf & _
		"FROM GBL_BaseTable bt " & vbCrLf & _
		"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf & _
		"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
		"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=@@LANGID" & vbCrLf & _
		"WHERE bt.NUM=" & QsNl(strNUM)
	
	'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
	'Response.Flush()

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
		bNUMError = True
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
	End If
End If

Dim strFeedbackBlurb, _
	strTermsOfUseURL, _
	bDataUseAuth, _
	bDataUseAuthPhone

bDataUseAuth = False

Dim cmdViewFb, rsViewFb
Set cmdViewFb = Server.CreateObject("ADODB.Command")
With cmdViewFb
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_View_Fb_s"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
End With
Set rsViewFb = cmdViewFb.Execute
With rsViewFb
	If Not .EOF Then
		strFeedbackBlurb = .Fields("FeedbackBlurb")
		strTermsOfUseURL = .Fields("TermsOfUseURL")
		bDataUseAuth = .Fields("DataUseAuth")
		bDataUseAuthPhone = .Fields("DataUseAuthPhone")
	End If
End With

If Not bNUMError Then
	Call getROInfo(rsOrg.Fields("RECORD_OWNER"),DM_CIC)
	Dim strOrgName
	strOrgName = rsOrg.Fields("ORG_NAME_FULL")
%>
<h2><%=TXT_REVIEW_RECORD%>
<br><%=strOrgName%></h2>
<p><%=TXT_WE_APPRECIATE%> <strong><%=strROName%></strong></p>
<p><%=TXT_YOU_CAN_CONTACT_US%></p>
<%
	Call printROContactInfo(True)
%>
<p><%=TXT_IF_YOU_DONT_HAVE_ROOM%></p>

<table class="BasicBorder cell-padding-3" width="100%">
<tr><th colspan="2" class="RevTitleBox"><%=TXT_REVIEW_RECORD & rsOrg("NUM")%></th></tr>
<%
	Dim strModifiedDate, _
		strUpdateDate, _
		strUpdateSchedule

	strModifiedDate = Nz(DateString(rsOrg.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN)
	strUpdateDate = Nz(DateString(rsOrg.Fields("UPDATE_DATE"),True),TXT_UNKNOWN)
	strUpdateSchedule = Nz(DateString(rsOrg.Fields("UPDATE_SCHEDULE"),True),TXT_UNKNOWN)
	
	Response.Write(makeRow(TXT_LAST_MODIFIED, strModifiedDate))
	Response.Write(makeRow(TXT_LAST_UPDATE, strUpdateDate))
	Response.Write(makeRow(TXT_NEXT_REVIEW, strUpdateSchedule))
	Response.Write(makeRow(TXT_RECORD_NUM, rsOrg("NUM")))

	Dim intPrevGroupID, _
		strGroupContents, _
		strGroupHeader, _
		strFieldName, _
		strFieldDisplay, _
		strFieldContents, _
		strFieldContentsPrefix

	While Not rsFields.EOF
		If intPrevGroupID <> rsFields.Fields("DisplayFieldGroupID") Then
			If Not Nl(strGroupContents) Then
				Response.Write(strGroupHeader)
				Response.Write(strGroupContents)
			End If
			strGroupHeader = "<tr><th colspan=""2"" class=""RevTitleBox"">" & rsFields.Fields("DisplayFieldGroupName") & "</th></tr>"
			strGroupContents = vbNullString
		End If
		strFieldDisplay = rsFields.Fields("FieldDisplay")
		strFieldName = rsFields.Fields("FieldName")
		If strFieldName = "ORG_LEVEL_1" Or strFieldName = "ORG_LEVEL_2" Or strFieldName = "ORG_LEVEL_3" Then
			strFieldDisplay = Nz(get_view_data_cic("OrgLevel" & Right(strFieldName, 1) & "Name"), strFieldDisplay)
		End If
		strFieldContents = vbNullString
		strFieldContentsPrefix = vbNullString
		If rsFields("PRIVATE_FIELD") Then
			strFieldContentsPrefix = "<em>[ " & TXT_BLOCKED_BY_PRIVACY_PROFILE & " ]</em><br>"
		End If
		If Nl(rsFields.Fields("FieldSelect")) Then
			strFieldContents = "&nbsp;"
		ElseIf rsFields.Fields("FormFieldType") = "d" Then
			If Not rsFields("PRIVATE_FIELD") Then
				strFieldContents = DateString(rsOrg(strFieldName),True)
				If Nl(strFieldContents) Then
					strFieldContents = "&nbsp;"
				End If
			End If
			strFieldContents = strFieldContentsPrefix & strFieldContents
		ElseIf Not rsFields.Fields("UseDisplayForMailForm") Then
			Select Case strFieldName
				Case "CC_LICENSE_INFO"
					strFieldContents = makeCCLicenseInfoContents(rsOrg, rsFields("PRIVATE_FIELD"))
				Case "CONTACT_1"
					strFieldContents = makeContactContents(rsOrg, strFieldName, rsFields("PRIVATE_FIELD"))
				Case "CONTACT_2"
					strFieldContents = makeContactContents(rsOrg, strFieldName, rsFields("PRIVATE_FIELD"))
				Case "EMPLOYEES"
					strFieldContents = makeEmployeeContents(rsOrg, rsFields("PRIVATE_FIELD"))
				Case "EXEC_1"
					strFieldContents = makeContactContents(rsOrg, strFieldName, rsFields("PRIVATE_FIELD"))
				Case "EXEC_2"
					strFieldContents = makeContactContents(rsOrg, strFieldName, rsFields("PRIVATE_FIELD"))
				Case "EXTRA_CONTACT_A"
					strFieldContents = makeContactContents(rsOrg, strFieldName, rsFields("PRIVATE_FIELD"))
				Case "VOLCONTACT"
					strFieldContents = makeContactContents(rsOrg, strFieldName, rsFields("PRIVATE_FIELD"))
				Case "SPACE_AVAILABLE"
					strFieldContents = makeSpaceAvailableContents(rsOrg, rsFields("PRIVATE_FIELD"))
				Case Else
					If rsFields("PRIVATE_FIELD") Then
						strFieldContents = vbNullString
					ElseIf rsFields.Fields("CheckMultiline") Then
						strFieldContents = textToHTML(rsOrg(strFieldName))
					Else
						strFieldContents = rsOrg(strFieldName)
					End If
					If Nl(strFieldContents) Then
						strFieldContents = "&nbsp;"
					End If
			End Select
			strFieldContents = strFieldContentsPrefix & strFieldContents & "<br>&nbsp;<br>&nbsp;"
		Else
			If strFieldName <> "NUM" Then
				If rsFields("PRIVATE_FIELD") Then
					strFieldContents = vbNullString
				ElseIf rsFields.Fields("CheckMultiline") Then
					strFieldContents = textToHTML(rsOrg(strFieldName))
				Else
					strFieldContents = rsOrg(strFieldName)
				End If
				If Nl(strFieldContents) Then
					strFieldContents = "&nbsp;"
				End If
				strFieldContents = strFieldContentsPrefix & strFieldContents & "<br>&nbsp;<br>&nbsp;"
			End If
		End If
		strGroupContents = strGroupContents & vbCrLf & makeRow(strFieldDisplay,strFieldContents)
		intPrevGroupID = rsFields.Fields("DisplayFieldGroupID")
		rsFields.MoveNext
	Wend
	rsFields.Close
	Set rsFields = Nothing
	Set cmdFields = Nothing
	
	If Not Nl(strGroupContents) Then
		Response.Write(strGroupHeader)
		Response.Write(strGroupContents)
	End If
%>
</table>

<h3 class="Alert"><%=TXT_ABOUT_YOU%></h3>
<table class="BasicBorder cell-padding-3">
<%
Response.Write(makeRow(TXT_YOUR & TXT_NAME, "&nbsp;"))
Response.Write(makeRow(TXT_YOUR & TXT_EMAIL, "&nbsp;"))
Response.Write(makeRow(TXT_YOUR & TXT_PHONE, "&nbsp;"))
Response.Write(makeRow(TXT_YOUR & TXT_ORGANIZATION, "&nbsp;"))
Response.Write(makeRow(TXT_YOUR & TXT_JOB_TITLE, "&nbsp;"))
%>
</table>

<%If bDataUseAuth Then%>
<h3 class="Alert"><%=TXT_USE_OF_INFO%></h3>
<p><%=TXT_PLEASE_SELECT_OPTIONS%></p>
<table class="NoBorder cell-padding-2">
	<tr>
		<td><input type="radio" name="Auth" id="Auth_A" value="A"></td>
		<td><label for="Auth_A"><%=TXT_AUTH_APPROVE%></label>
		<%If Not Nl(strTermsOfUseURL) Then%><br><strong><%=strTermsOfUseURL%></strong><%End If%></td>
	</tr>
	<%If bDataUseAuthPhone Then%>
	<tr>
		<td><input type="radio" name="Auth" id="Auth_E" value="E"></td>
		<td><label for="Auth_E"><%=TXT_AUTH_INQUIRIES%></label></td>
	</tr>
	<%End If%>
	<tr>
		<td><input type="radio" name="Auth" id="Auth_C" value="C"></td>
		<td><label for="Auth_C"><%=TXT_AUTH_CONTACT%></label></td>
	</tr>
</table>
<p><span class="FieldLabelLeftClr"><%=TXT_SIGNATURE%></span> _____________________________________________________</p>
<%End If%>
<%
End If

Call makePageFooter(True)
%>

<!--#include file="includes/core/incClose.asp" -->

