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
Call setPageInfo(True, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtCommonForm.asp" -->
<!--#include file="text/txtDates.asp" -->
<!--#include file="text/txtEntryForm.asp" -->
<!--#include file="text/txtFieldHistory.asp" -->
<!--#include file="text/txtFeedbackCommon.asp" -->
<!--#include file="text/txtFinder.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtGeoCode.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtSubjects.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/list/incAccreditationList.asp" -->
<!--#include file="includes/list/incActivityStatusList.asp" -->
<!--#include file="includes/list/incAgencyList.asp" -->
<!--#include file="includes/list/incBillingAddressTypeList.asp" -->
<!--#include file="includes/list/incBoxTypeList.asp" -->
<!--#include file="includes/list/incBusRouteList.asp" -->
<!--#include file="includes/list/incCertificationList.asp" -->
<!--#include file="includes/list/incContactPhoneTypeList.asp" -->
<!--#include file="includes/list/incCurrencyList.asp" -->
<!--#include file="includes/list/incEmployeeRangeList.asp" -->
<!--#include file="includes/list/incExtraDropDownList.asp" -->
<!--#include file="includes/list/incFiscalYearEndList.asp" -->
<!--#include file="includes/list/incGeoCodeTypeList.asp" -->
<!--#include file="includes/list/incHonorificList.asp" -->
<!--#include file="includes/list/incLanguagesList.asp" -->
<!--#include file="includes/list/incMappingSystemList.asp" -->
<!--#include file="includes/list/incMappingCategoryList.asp" -->
<!--#include file="includes/list/incMembershipTypeList.asp" -->
<!--#include file="includes/list/incPaymentMethodList.asp" -->
<!--#include file="includes/list/incPaymentTermsList.asp" -->
<!--#include file="includes/list/incPrivacyProfileList.asp" -->
<!--#include file="includes/list/incQualityList.asp" -->
<!--#include file="includes/list/incRecordNoteTypeList.asp" -->
<!--#include file="includes/list/incRecordTypeList.asp" -->
<!--#include file="includes/list/incSchoolList.asp" -->
<!--#include file="includes/list/incSignatureStatusList.asp" -->
<!--#include file="includes/list/incStreetDirList.asp" -->
<!--#include file="includes/list/incStreetTypeList.asp" -->
<!--#include file="includes/list/incTypeOfProgramList.asp" -->
<!--#include file="includes/list/incVacancyServiceTitleList.asp" -->
<!--#include file="includes/list/incVacancyTargetPopList.asp" -->
<!--#include file="includes/list/incVacancyUnitTypeList.asp" -->
<!--#include file="includes/list/incWardList.asp" -->
<!--#include file="includes/mapping/incGoogleMaps.asp" -->
<!--#include file="includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="includes/update/incCICFormUpdPrint.asp" -->
<!--#include file="includes/update/incEntryFormGeneral.asp" -->
<!--#include file="includes/update/incFieldHistory.asp" -->

<script language="python" runat="server">
def get_dbopt_values():
	global intSiteCodeLength,\
			bVacancyFundedCapacity,\
			bVacancyServiceHours,\
			bVacancyServiceDays,\
			bVacancyServiceWeeks,\
			bVacancyServiceFTE,\
			strDefaultCountry,\
			intDefaultGCType

	dboptions = pyrequest.dboptions

	intSiteCodeLength = dboptions.SiteCodeLength
	bVacancyFundedCapacity = dboptions.VacancyFundedCapacity
	bVacancyServiceHours = dboptions.VacancyServiceHours
	bVacancyServiceDays = dboptions.VacancyServiceDays
	bVacancyServiceWeeks = dboptions.VacancyServiceWeeks
	bVacancyServiceFTE = dboptions.VacancyServiceFTE
	strDefaultCountry = dboptions.DefaultCountry
	intDefaultGCType = dboptions.DefaultGCType
</script>
<%
Dim strPageTitle, _
	strNUM, _
	intFBID, _
	bNUMError, _
	bFBError, _
	bRSError, _
	intFormType, _
	bNew, _
	objUpdateLang, _
	bHasDynamicAddField, _
	intRTID

bRSError = False
bNUMError = False
bFBError = False
bHasDynamicAddField = False
strPageTitle = TXT_CREATE_NEW_RECORD
intFormType = EF_NEW
intRTID = -1

strNUM = Trim(Request("NUM"))

Set objUpdateLang = create_language_object()
objUpdateLang.setSystemLanguage(Nz(Request("UpdateLn"),g_objCurrentLang.Culture))

If Nl(strNUM) Then
	intFBID = Trim(Request("FBID"))
	If Not Nl(intFBID) Then
		intFormType = EF_CREATEFB
		strPageTitle = TXT_CREATE_RECORD_FEEDBACK
	End If
Else
	intFormType = EF_UPDATE
	strPageTitle = TXT_UPDATE_RECORD_TITLE
End If

bNew = intFormType = EF_NEW Or intFormType = EF_CREATEFB

Call makePageHeader(TXT_UPDATE_RECORD_TITLE, TXT_UPDATE_RECORD_TITLE, True, False, True, True)

Dim strRestoreCulture
strRestoreCulture = g_objCurrentLang.Culture
Call setSessionLanguage(objUpdateLang.Culture)

If Not bNew Then
	If Not IsNUMType(strNUM) Then
		bNUMError = True
		Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
	End If
Else
	If intFormType = EF_CREATEFB Then
		If Not IsIDType(intFBID) Then
			bFbError = True
			Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intFBID) & ".", vbNullString, vbNullString)
		Else
			intFBID = CLng(intFBID)
		End If
	End If
	strNUM = Null
End If

' Begin writing form data
If Not bNUMError And Not bFBError Then

Dim cnnFields, cmdFields, rsFields
Call makeNewAdminConnection(cnnFields)
Set cmdFields = Server.CreateObject("ADODB.Command")
With cmdFields
	.ActiveConnection = cnnFields
	.CommandType = adCmdStoredProc
	.CommandText = "sp_CIC_View_UpdateFields"
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@RSN", adInteger, adParamInput, 4, Null)
	.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	.Parameters.Append .CreateParameter("@RT_ID", adInteger, adParamInput, 4, intRTID)
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

Dim bMakeCCR, _
	bDeleteCCR, _
	bEnforceReqFields

With rsFields
	If .EOF Then
		bRSError = True
		Call handleError(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
	Else
		bMakeCCR = .Fields("makeCCR")
		bDeleteCCR = .Fields("deleteCCR")
		bEnforceReqFields = .Fields("EnforceReqFields")
		Call get_dbopt_values()
	End If
End With

Set rsFields = rsFields.NextRecordSet

If Not bNew And Not bRSError Then

	Dim strSQL, strCon

	strSQL = _
		"SELECT sln.LangID, sln.LanguageName " & vbCrLf & _
			"FROM STP_LANGUAGE sln" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd " & _
			"	ON sln.LangID=btd.LangID WHERE NUM='" & strNUM & "' " & vbCrLf & _
		"SELECT " & _
			"bt.RSN, bt.NUM, bt.DISPLAY_ORG_NAME, bt.ORG_NUM, " & _
			"STUFF((SELECT ',' + ols.Code FROM GBL_OrgLocationService ols INNER JOIN GBL_BT_OLS pr ON ols.OLS_ID=pr.OLS_ID AND pr.NUM=bt.NUM FOR XML PATH('')), 1, 1, '') AS OLS," & _
			"bt.RECORD_OWNER," & _
			"cbt.RECORD_TYPE AS CUR_RT_ID," & _
			"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & _
			"btd.ORG_LEVEL_1 AS OL1,btd.ORG_LEVEL_2 AS OL2,btd.ORG_LEVEL_3 AS OL3,btd.ORG_LEVEL_4 AS OL4,btd.ORG_LEVEL_5 AS OL5,btd.LOCATION_NAME AS LN,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2," & _
			"btd.NON_PUBLIC," & _
			"btd.CREATED_DATE, " & _
			"btd.CREATED_BY, " & _
			"btd.UPDATE_DATE, " & _
			"btd.UPDATED_BY, " & _
			"btd.UPDATE_SCHEDULE," & _
			"btd.MODIFIED_DATE," & _
			"btd.MODIFIED_BY," & _
			"dbo.fn_CIC_CanUpdateRecord(bt.NUM," & user_intID & "," & g_intViewTypeCIC & ",btd.LangID,GETDATE()) AS CAN_UPDATE," & _
			"CAST(CASE WHEN EXISTS(SELECT * FROM CIC_SecurityLevel_RecordType WHERE SL_ID=" & user_intUserTypeCIC & ") THEN 1 ELSE 0 END AS bit) AS LIMIT_RECORDTYPE"

	With rsFields
		While Not .EOF
			If Not Nl(.Fields("FieldSelect")) And _
				Not reEquals(.Fields("FieldName"), _
						"((RSN)|(NUM)|(RECORD_OWNER)|(NON_PUBLIC)|(CREATED_DATE)|(UPDATE(_DATE)|(_SCHEDULE)|(D_BY)))", _
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
		"FROM GBL_BaseTable bt" & vbCrLf & _
		"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbcrLf & _
		"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbcrLf & _
		"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
		"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=@@LANGID" & vbCrLf & _
		"WHERE bt.NUM=" & QsNl(strNUM)
	
	'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
	'Response.Flush()

	Dim cmdOrg, rsOrg, strVersions
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandText = strSQL
		.CommandTimeout = 0
		Set rsOrg = .Execute
	End With
	If Err.Number <> 0 Then
		bRSError = True
		Call handleError(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
	Else	
		Dim strVersionCon
		strVersionCon = vbNullString
		strVersions = "[ "
		With rsOrg
			While Not .EOF
				strVersions = strVersions & strVersionCon & _
					"<span class=""SimulateLink HistorySummary NoLineLink"" data-cioclang=""" & .Fields("LangID") & """ data-ciocid=""" & strNUM & """>" & _
						"<img src=""" & ps_strPathToStart & "images/versions.gif"" width=""17"" height=""17"" alt=" & AttrQs(TXT_FIELD_HISTORY & TXT_COLON) & ">" & _
						"&nbsp;" & .Fields("LanguageName") & _
						"</span>"
				strVersionCon = " | "
				.MoveNext
			Wend
		End With
		strVersions = strVersions & " ]"
		Set rsOrg = rsOrg.NextRecordSet
	End If
	
	

	If Not bRSError And rsOrg.EOF Then
		bNUMError = True
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
	End If
End If

If intFormType <> EF_UPDATE Then
	Dim strNewNUM
	strNewNUM = getNewNUM()
End If

Dim cmdFb, rsFb
If intFormType = EF_CREATEFB Then
	Set cmdFb = Server.CreateObject("ADODB.Command")
	With cmdFb
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_CIC_Feedback_s"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@FB_ID", adInteger, adParamInput, 4, intFBID)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	End With
	Set rsFb = Server.CreateObject("ADODB.Recordset")
	With rsFb
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdFb

		If Not .EOF Then
			If .Fields("Error") <> 0 Then
				bFbError = True
				Call handleError(Nz(.Fields("ErrMsg"),TXT_UNKNOWN_ERROR_OCCURED),vbNullString,vbNullString)
			End If
		End If

		If Not bFbError Then
			Set rsFb = rsFb.NextRecordSet
			Set rsFb = rsFb.NextRecordSet
			If .EOF Then
				bFBError = True
				Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intFBID) & ".", vbNullString, vbNullString)
			Else
				bFeedback = True
			End If
		End If
	End With
ElseIf intFormType = EF_UPDATE Then
	Set cmdFb = Server.CreateObject("ADODB.Command")
	With cmdFb
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_CIC_Feedback_l_NUM"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	End With
	Set rsFb = Server.CreateObject("ADODB.Recordset")
	With rsFb
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdFb
		If Not .EOF Then
			bFeedback = True
		End If
	End With
End If

End If

If Not bNUMError And Not bFBError Then

Select Case intFormType
	Case EF_UPDATE
		If Not rsOrg("CAN_UPDATE") = 1 Then
			Call securityFailure()
		End If
		Dim bUpdateLangActive, _
			strLangLink
		bUpdateLangActive = Nz(Application("Culture_" & g_objCurrentLang.Culture),False)
		strLangLink = StringIf(strRestoreCulture<>g_objCurrentLang.Culture,StringIf(Not bUpdateLangActive,"Tmp") & "Ln=" & g_objCurrentLang.Culture)
%>
<h2><%=TXT_UPDATE_RECORD_TITLE & TXT_COLON%>
<br><a href="<%=makeDetailsLink(rsOrg.Fields("NUM"), StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber) & strLangLink,StringIf(bUpdateLangActive,"Ln"))%>"><%=rsOrg.Fields("ORG_NAME_FULL")%></a></h2>
<%
	Case EF_NEW
		If (Not user_bAddDOM) Then
			Call securityFailure()
		End If
%>
<h2><%=TXT_CREATE_NEW_RECORD%></h2>
<%
	Case EF_CREATEFB
		If (Not user_bAddDOM) Then
			Call securityFailure()
		End If
%>
<h2><%=TXT_CREATE_RECORD_FEEDBACK%></h2>
<%
End Select
%>
<p class="HideJs Alert">
<%= TXT_JAVASCRIPT_REQUIRED %>
</p>
<div class="HideNoJs">
<table aria-hidden="true" class="BasicBorder cell-padding-3 max-width-lg clear-line-below">
	<tr>
		<th class="RevTitleBox" colspan="2"><%=TXT_LEGEND%></th>
	</tr>
	<tr>
		<td><span class="glyphicon glyphicon-question-sign medium-icon"></span></td>
		<td><%=TXT_LEGEND_HELP%></td>
	</tr>
	<% If Not bNew Then %>
	<tr>
		<td><span class="glyphicon glyphicon-duplicate medium-icon"></span></td>
		<td><%=TXT_LEGEND_VERSIONS%></td>
	</tr>
	<% End If %>
</table>

<form name="EntryForm" id="EntryForm" action="entryform2.asp" role="form" class="form-horizontal" method="post" lang="<%=objUpdateLang.Culture%>">
<div style="display:none">
<input name="transaction-amount" autocomplete="transaction-amount">
<%=g_strCacheFormVals%>
<input type="hidden" name="UpdateLn" value="<%=objUpdateLang.Culture%>">
<%
If intFormType = EF_UPDATE Then%>
<input type="hidden" name="CUR_RT_ID" value="<%=rsOrg("CUR_RT_ID")%>">
<input type="hidden" name="RSN" value="<%=rsOrg("RSN")%>">
<%	If intCurSearchNumber >= 0 Then%>
<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%	End If
	If Not Nl(rsOrg("UPDATE_DATE")) Then%>
<input type="hidden" name="OLD_UPDATE_DATE" value="<%=rsOrg("UPDATE_DATE")%>">
<%	End If
End If
If intFormType = EF_CREATEFB Then
%>
<input type="hidden" name="FBID" value="<%=intFBID%>">
<%
End If
%>
</div>
<%

Dim i, dicFb
If bFeedback Then
	Set dicFb = Server.CreateObject("Scripting.Dictionary")
	i=1
%>
<p><span class="AlertBubble"><%=TXT_CHECK_FEEDBACK%></span></p>
<table class="NoBorder cell-padding-3 max-width-lg clear-line-below">
<%
	With rsFb
		.MoveFirst
		While Not .EOF
%>
<tr>
	<td class="FieldLabelLeftClr"><%=TXT_FEEDBACK_NUM%><%=i%><%If g_bMultiLingual Then%> (<%=.Fields("LanguageName")%>)<%End If%><%=TXT_COLON%></td>
	<td class="Alert"><%=TXT_SUBMITTED_BY & TXT_COLON%><%=.Fields("SUBMITTED_BY")%>
	<%If Not Nl(.Fields("SUBMITTED_BY_EMAIL")) Then%><br><%=TXT_SUBMITTER_EMAIL & TXT_COLON%><a href="mailto:<%=.Fields("SUBMITTED_BY_EMAIL")%>"><%=.Fields("SUBMITTED_BY_EMAIL")%></a><%End If%>
	<br><%=TXT_SUBMIT_DATE & .Fields("SUBMIT_DATE")%>
<%If .Fields("REMOVE_RECORD") Then%>
	<br><%=TXT_REMOVE_RECORD_REQUEST%>
<%Else%>
	<br><%=TXT_FULL_UPDATE & TXT_COLON%><%If .Fields("FULL_UPDATE") Then%><%=TXT_YES%><%If .Fields("NO_CHANGES") Then%> (<%=TXT_NO_CHANGES_REQUIRED%>)<%End If%><%Else%><%=TXT_NO%><%End If%>
<%End If%>
<%
Select Case .Fields("AUTH_TYPE")
	Case "A"
		If Not Nl(.Fields("User_ID")) Then
%>
<br><%=TXT_AUTH_GIVEN_FOR & IIf(rsFb.Fields("AUTH_INQUIRY"),TXT_USE_INQUIRY & "; ",vbNullString) & IIf(.Fields("AUTH_ONLINE"),TXT_USE_ONLINE & "; ",vbNullString) & IIf(rsFb.Fields("AUTH_PRINT"),TXT_USE_PRINT & "; ",vbNullString) & IIf(Not (rsFb.Fields("AUTH_INQUIRY") Or rsFb.Fields("AUTH_ONLINE") Or rsFb.Fields("AUTH_ONLINE")), TXT_NONE_SELECTED, vbNullString)%>
<%
		Else
%>
<br><%=TXT_AUTH_GIVEN%>
<%
		End If
	Case "C"
%>
<br><%=TXT_CONTACT_SUBMITTER%>
<%
	Case "I"
%>
<br><%=TXT_INTERNAL_REVIEW%>
<%
	Case "E"
%>
<br><%=TXT_AUTH_INQUIRIES_ONLY%>
<%			
	Case "N"
%>
<br><%=TXT_AUTH_NOT_RECEIVED%>
<%
End Select
%>
	<%If Not Nl(.Fields("FB_NOTES")) Then%><br><%=TXT_NOTES & TXT_COLON%><%=.Fields("FB_NOTES")%><%End If%></td>
</tr>
<%
			i = i+1
			dicFb(.Fields("Culture").Value) = .Fields("LanguageName")
			.MoveNext
		Wend
	End With
%>
</table>
<br>
<%
End If

If Not bNew Then
%>
<p class="Info"><%=TXT_PAST_CHANGES_TO_THIS_RECORD & strVersions%>
</p>
<%
End If
%>
<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
<%If Not bNew Then%>
		<h2><%=TXT_REVIEW_RECORD & rsOrg("NUM")%></h2>
<%Else%>
		<h2><%=TXT_CREATE_NEW_RECORD%></h2>
<%End If%>
	</div>
	<div class="panel-body no-padding">
		<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
<%
Call printAutoFields(rsOrg, intFormType = EF_UPDATE)

Call printUpdatedFields(rsOrg, intFormType = EF_UPDATE, bEnforceReqFields)

Call printRecordOwner(rsOrg, Not bNew)

If intFormType <> EF_UPDATE Then
	Call printRow("NUM", TXT_RECORD_NUM, _
		"<label for=" & AttrQs("AutoAssignNUM") & ">" & _
		"<input type=""checkbox"" id=" & AttrQs("AutoAssignNUM") & " name=""AutoAssignNUM"" checked onClick=""changeAutoAssign(this, document.EntryForm.NUM, document.EntryForm.NUMButton);"">" & TXT_AUTO_ASSIGN_LOWEST_NUM & _
		"</label>" & _
		"<div class=""form-inline""><input type=""text"" name=""NUM"" title=" & AttrQs(TXT_RECORD_NUM) & " size=""9"" maxlength=""8"" disabled class=""record-num form-control"">" & _
		" <input type=""button"" id=""NUMButton"" value=""" & TXT_LOWEST_UNUSED_FOR & "" & user_strAgency & """ onClick=""document.EntryForm.NUM.value='" & strNewNUM & "';"" class=""btn btn-default"" disabled></div>" & _
		" [ <a href=""javascript:openWin('" & makeLinkB("numfind.asp") & "','aFind')"">" & TXT_LOWEST_UNUSED_FOR & TXT_ALL_AGENCIES & "</a> ]", _
		True,True,False,True,bEnforceReqFields,False,False)
End If
%>
	
		</table>
	</div>
</div>
<%

Dim intPrevGroupID, _
	strFieldDisplay, _
	strFieldName, _
	strFieldContents, _
	strFieldVal, _
	strValidate, _
	intPubID, _
	bHasLabel

	intPrevGroupID = vbNullString

While Not rsFields.EOF
	If intPrevGroupID <> rsFields.Fields("DisplayFieldGroupID") Then
		If Not Nl(intPrevGroupID) Then
%>
		</table>
	</div>
</div>
<%
		End If
		intPrevGroupID = rsFields.Fields("DisplayFieldGroupID")
%>
<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
		<h2><%=rsFields.Fields("DisplayFieldGroupName")%></h2>
	</div>
	<div class="panel-body no-padding">
		<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
<%
	End If
	strFieldName = rsFields.Fields("FieldName")
	strFieldVal = Null
	bFieldHasFeedback = False
	If Not (bNew Or rsFields.Fields("FormFieldType") = "f") Then
		strFieldContents = rsOrg(strFieldName)
	Else
		strFieldContents = Null
	End If
	If Not (intFormType <> EF_UPDATE And reEquals(rsFields.Fields("FieldName"), "(NUM)|(RECORD_OWNER)",True,False,True,False)) Then
		Select Case rsFields.Fields("FormFieldType")
			Case "c"
				strFieldVal = makeCBFieldVal(strFieldName, _
					strFieldContents, _
					rsFields.Fields("CheckboxOnText"), _
					rsFields.Fields("CheckboxOffText"), _
					TXT_UNKNOWN, _
					rsFields.Fields("AllowNulls"), _
					rsFields.Fields("CanUseFeedback") _
					)
			Case "d"
				strFieldVal = makeDateFieldValFull(strFieldName, _
					strFieldContents, _
					IIf(strFieldName="COLLECTED_DATE",True,False),False,False,False,False, _
					rsFields.Fields("CanUseFeedback"), _
					Ns(rsFields.Fields("ExtraFieldType"))="a" _
					)
			Case "t"
				If rsFields.Fields("ValidateType") = "w" Then
					Dim strProtocol
					If Not (bNew) Then
						strProtocol = rsOrg(strFieldName + "_PROTOCOL")
					Else
						strProtocol = vbNullString
					End If
					strFieldVal = makeWebFieldVal(strFieldName, _
						strFieldContents, _
						rsFields.Fields("MaxLength"), _
						rsFields.Fields("CanUseFeedback"), _
						strProtocol _
						)
				Else
					strValidate = vbNullString
					If rsFields.Fields("ValidateType") = "e" Then
						strValidate = "email"
					ElseIf rsFields.Fields("FieldName") = "NUM" Then
						strValidate = "record-num"
					End If
					strFieldVal = makeValidatedTextFieldVal(strFieldName, _
						strFieldContents, _
						rsFields.Fields("MaxLength"), _
						rsFields.Fields("CanUseFeedback"), _
						strValidate _
						)
				End If
			Case "u"
				strFieldVal = makeUserFieldVal(strFieldName, _
					strFieldContents, _
					rsFields.Fields("CanUseFeedback") _
					)
			Case "f"
				Select Case strFieldName
					Case "ACCESSIBILITY"
						strFieldVal = makeAccessibilityContents(rsOrg, Not bNew)
					Case "ACCREDITED"
						strFieldVal = makeAccreditationContents(rsOrg, Not bNew)
					Case "ACTIVITY_INFO"
						strFieldVal = makeActivityInfoContents(rsOrg, Not bNew)
					Case "ALT_ORG"
						strFieldVal = makeAltOrgContents(rsOrg, Not bNew, rsFields.Fields("FieldDisplay"))
					Case "AREAS_SERVED"
						strFieldVal = makeAreasServedContents(rsOrg, Not bNew)
					case "BILLING_ADDRESSES"
						strFieldVal = makeBillingAddressContents(rsOrg, Not bNew)
					Case "BUS_ROUTES"
						strFieldVal = makeBusRouteContents(rsOrg, Not bNew)
					Case "CC_LICENSE_INFO"
						strFieldVal = makeCCLicenseInfoContents(rsOrg, Not bNew)
					Case "CERTIFIED"
						strFieldVal = makeCertificationContents(rsOrg, Not bNew)
					Case "CONTACT_1"
						strFieldVal = makeContactFieldVal(rsOrg, strFieldName, Not bNew)
					Case "CONTACT_2"
						strFieldVal = makeContactFieldVal(rsOrg, strFieldName, Not bNew)
					Case "CONTRACT_SIGNATURE"
						strFieldVal = makeContractSignatureContents(rsOrg, Not bNew)
					Case "DESCRIPTION"
						strFieldVal = makeMemoFieldVal(strFieldName, _
							strFieldContents, _
							TEXTAREA_ROWS_SHORT, _
							rsFields.Fields("CanUseFeedback") _
							)
					Case "DISTRIBUTION"
						strFieldVal = makeDistributionContents(rsOrg, Not bNew)
					Case "ELIGIBILITY"
						strFieldVal = makeEligibilityContents(rsOrg, Not bNew)
					Case "EMPLOYEES"
						strFieldVal = makeEmployeesContents(rsOrg, Not bNew)
					Case "EMPLOYEES_RANGE"
						strFieldVal = makeEmployeesRangeContents(rsOrg, Not bNew)
					Case "EXEC_1"
						strFieldVal = makeContactFieldVal(rsOrg, strFieldName, Not bNew)
					Case "EXEC_2"
						strFieldVal = makeContactFieldVal(rsOrg, strFieldName, Not bNew)
					Case "EXTRA_CONTACT_A"
						strFieldVal = makeContactFieldVal(rsOrg, strFieldName, Not bNew)
					Case "FISCAL_YEAR_END"
						strFieldVal = makeFiscalYearEndContents(rsOrg, Not bNew)
					Case "FORMER_ORG"
						strFieldVal = makeFormerOrgContents(rsOrg, Not bNew, rsFields.Fields("FieldDisplay"))
					Case "FEES"
						strFieldVal = makeFeeContents(rsOrg, Not bNew)
					Case "FUNDING"
						strFieldVal = makeFundingContents(rsOrg, Not bNew)
					Case "GEOCODE"
						strFieldVal = makeGeoCodeContents(rsOrg, Not bNew)
					Case "INTERNAL_MEMO"
						strFieldVal = makeRecordNoteFieldVal(rsOrg, strFieldName, Not bNew)
					Case "LANGUAGES"
						strFieldVal = makeLanguageContents(rsOrg, Not bNew)
					Case "LEGAL_ORG"
						strFieldVal = makeOrgNameContents(rsOrg, strFieldName, "LO_PUBLISH", Not bNew)
					Case "LOCATED_IN_CM"
						strFieldVal = makeLocatedInContents(rsOrg, Not bNew)
					Case "LOCATION_NAME"
						strFieldVal = makeLocationNameContents(rsOrg, Not bNew)
					Case "LOGO_ADDRESS"
						strFieldVal = makeLogoAddressContents(rsOrg, Not bNew)
					Case "LOCATION_SERVICES"
						strFieldVal = makeLocationsServicesContents(rsOrg, strFieldName, TXT_ADD_SERVICE_RECORD, TXT_SERVICE_WARNING, Not bNew)
					Case "MAIL_ADDRESS"
						strFieldVal = makeAddress(rsOrg, True, Not bNew)
					Case "MAIN_ADDRESS"
						strFieldVal = makeMainAddressContents(rsOrg, Not bNew)
					Case "MAP_LINK"
						strFieldVal = makeMappingSystemContents(rsOrg, Not bNew)
					Case "MEMBERSHIP"
						strFieldVal = makeMembershipTypeContents(rsOrg, Not bNew)
					Case "NAICS"
						strFieldVal = makeNAICSContents(rsOrg, Not bNew)
					Case "ORG_LEVEL_2"
						strFieldVal = makeOrgNameContents(rsOrg, strFieldName, "O2_PUBLISH", Not bNew)
					Case "ORG_LEVEL_3"
						strFieldVal = makeOrgNameContents(rsOrg, strFieldName, "O3_PUBLISH", Not bNew)
					Case "ORG_LEVEL_4"
						strFieldVal = makeOrgNameContents(rsOrg, strFieldName, "O4_PUBLISH", Not bNew)
					Case "ORG_LEVEL_5"
						strFieldVal = makeOrgNameContents(rsOrg, strFieldName, "O5_PUBLISH", Not bNew)
					Case "ORG_LOCATION_SERVICE"
						strFieldVal = makeOrgLocationServiceContents(rsOrg, Not bNew)
					Case "ORG_NUM"
						strFieldVal = makeOrgNumContents(rsOrg, Not bNew)
					case "OTHER_ADDRESSES"
						strFieldVal = makeOtherAddressContents(rsOrg, Not bNew)
					Case "PAYMENT_TERMS"
						strFieldVal = makePaymentTermsContents(rsOrg, Not bNew)
					Case "PREF_CURRENCY"
						strFieldVal = makePrefCurrencyContents(rsOrg, Not bNew)
					Case "PREF_PAYMENT_METHOD"
						strFieldVal = makePrefPaymentMethodContents(rsOrg, Not bNew)
					Case "QUALITY"
						strFieldVal = makeQualityContents(rsOrg, Not bNew)
					Case "RECORD_OWNER"
						strFieldVal = makeRecordOwnerFieldVal(rsOrg, Not bNew)
					Case "RECORD_PRIVACY"
						strFieldVal = makeRecordPrivacyContents(rsOrg, Not bNew)
					Case "RECORD_TYPE"
						strFieldVal = makeRecordTypeContents(rsOrg, Not bNew)
					Case "SCHEDULE"
						strFieldVal = makeScheduleContents(rsOrg, Not bNew)
					Case "SCHOOL_ESCORT"
						strFieldVal = makeSchoolEscortContents(rsOrg, Not bNew)
					Case "SCHOOLS_IN_AREA"
						strFieldVal = makeSchoolsInAreaContents(rsOrg, Not bNew)
					Case "SERVICE_LEVEL"
						strFieldVal = makeServiceLevelContents(rsOrg, Not bNew)
					Case "SERVICE_LOCATIONS"
						strFieldVal = makeLocationsServicesContents(rsOrg, strFieldName, TXT_ADD_LOCATION_RECORD, TXT_LOCATION_WARNING, Not bNew)
					Case "SERVICE_NAME_LEVEL_1"
						strFieldVal = makeOrgNameContents(rsOrg, strFieldName, "S1_PUBLISH", Not bNew)
					Case "SERVICE_NAME_LEVEL_2"
						strFieldVal = makeOrgNameContents(rsOrg, strFieldName, "S2_PUBLISH", Not bNew)
					Case "SOURCE"
						strFieldVal = makeSourceContents(rsOrg, Not bNew)
					Case "SPACE_AVAILABLE"
						strFieldVal = makeSpaceAvailableContents(rsOrg, Not bNew)
					Case "SITE_ADDRESS"
						strFieldVal = makeAddress(rsOrg, False, Not bNew)
					Case "SOCIAL_MEDIA"
						strFieldVal = makeSocialMediaFieldVal(rsOrg, Not bNew)
					Case "SORT_AS"
						strFieldVal = makeSortAsContents(rsOrg, Not bNew)
					Case "SUBJECTS"
						strFieldVal = makeSubjectContents(rsOrg, Not bNew)
					Case "TYPE_OF_CARE"
						strFieldVal = makeTypeOfCareContents(rsOrg, Not bNew)
					Case "TYPE_OF_PROGRAM"
						strFieldVal = makeTypeOfProgramContents(rsOrg, Not bNew)
					Case "VACANCY_INFO"
						strFieldVal = makeVacancyInfoContents(rsOrg, Not bNew)
					Case "VOLCONTACT"
						strFieldVal = makeContactFieldVal(rsOrg, strFieldName, Not bNew)
					Case "WARD"
						strFieldVal = makeWardContents(rsOrg, Not bNew)
					Case Else
						Select Case Ns(rsFields.Fields("ExtraFieldType"))
							Case "l"
								strFieldVal = makeExtraCheckListContents(rsOrg, Not bNew, False)
							Case "p"
								strFieldVal = makeExtraDropDownContents(rsOrg, Not bNew, False)
							Case Else
								intPubID = rsFields.Fields("PB_ID")
								If Not Nl(intPubID) Then
									strFieldVal = makeGeneralHeadingFieldVal(rsOrg, Not bNew, intPubID)
								Else
									If Not bNew Then
										strFieldContents = rsOrg(strFieldName)
									Else
										strFieldContents = vbNullString
									End If
									strFieldVal = makeMemoFieldVal(strFieldName, _
										strFieldContents, _
										TEXTAREA_ROWS_SHORT, _
										rsFields.Fields("CanUseFeedback") _
										)
								End If
						End Select
				End Select
			Case Else
				strFieldVal = makeMemoFieldVal(strFieldName, _
					strFieldContents, _
					TEXTAREA_ROWS_SHORT, _
					rsFields.Fields("CanUseFeedback") _
					)
		End Select
		strFieldDisplay = rsFields.Fields("FieldDisplay")
		If strFieldName = "ORG_LEVEL_1" Or strFieldName = "ORG_LEVEL_2" Or strFieldName = "ORG_LEVEL_3" Then
			strFieldDisplay = Nz(get_view_data_cic("OrgLevel" & Right(strFieldName, 1) & "Name"), strFieldDisplay)
		End If
		bHasLabel = False
		If reEquals(strFieldName,"(NAICS)|(ORG_NUM)|(ORG_LEVEL_[1-5])|(SERVICE_NAME_LEVEL_[1-5])|(LOCATION_NAME)|(LOCATED_IN_CM)|(SORT_AS)|(LEGAL_ORG)",True,True,True,False) _
					Or reEquals(rsFields.Fields("FormFieldType"),"d|m|t|u",True,True,True,False) _
					Or rsFields.Fields("ExtraFieldType") = "p" _
					Or rsFields.Fields("ValidateType") = "n" _
				Then
			bHasLabel = True
		End If
		Call printRow(strFieldName,strFieldDisplay,strFieldVal,True,rsFields.Fields("HasHelp"),Nz(rsFields.Fields("ChangeHistory"), 0) > 0 And Not bNew,Not rsFields.Fields("AllowNulls"),bEnforceReqFields,bFieldHasFeedback,bHasLabel)
	End If
	rsFields.MoveNext
Wend

rsFields.Close
Set rsFields = Nothing
Set cmdFields = Nothing
%>
		</table>
	</div>
</div>

<%

Call closeAddressRecordsets()
Call closeContactRecordsets()
Call closeRecordNoteTypeRecordsets()

If bMakeCCR Then
%>
<p><label><input type="checkbox" name="makeCCR" id="makeCCR"><%=TXT_DESIGNATE_CHILD_CARE_RESOURCE%></label></p>
<%
ElseIf bDeleteCCR Then
%>
<p><label><input type="checkbox" name="deleteCCR" id="deleteCCR"><%=TXT_REMOVE_CHILD_CARE_RESOURCE_DESIGNATION%></label></p>
<%
End If

Dim indFbLang
If bFullUpdate Then
	If bFeedback Then
		For Each indFbLang In dicFb
%>
<p class="Alert"><label><input type="checkbox" name="DeleteFeedback" id="DeleteFeedback_<%=indFBLang%>" value="<%=indFbLang%>" <%=Checked(indFbLang=g_objCurrentLang.Culture)%>><%=TXT_DELETE_FEEDBACK%><%If g_bMultiLingual Then%> (<%=dicFb(indFbLang)%>)<%End If%></label></p>
<%
		Next
	End If
End If
%>
<div id="unadded_checklist_error_box" class="NotVisible">
<span class="Alert"><%= TXT_UNADDED_CHECKLISTS %></span>
<div id="unadded_checklist_error_list">
</div>
</div>
<% If g_intPreventDuplicateOrgNames <> 0 Then %>
<div id="duplicate_name_error_box" class="NotVisible">
<p><span class="AlertBubble"><%= TXT_DUPLICATE_ORG_NAME_ERROR %></span></p>
</div>
<% End If %>
<div id="validation_error_box" class="NotVisible">
<p><span class="AlertBubble"><%= TXT_VALIDATION_ERRORS_MESSAGE %></span></p>
</div>
<p>
	<input type="button" id="SUBMIT_BUTTON" class="btn btn-default" value="<%=TXT_SUBMIT_UPDATES%>">
	<input type="reset" class="btn btn-default" value="<%=TXT_RESET_FORM%>">
</p>

</form>
</div>

<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/entryform.js") %>
<%= JSVerScriptTag("scripts/cultures/globalize.culture." & objUpdateLang.Culture & ".js") %>
<% 
g_bListScriptLoaded = True
If Not bNew And g_bUseCIC Then
	Call printHistoryDialogHTML(strNUM, False)
End If

%>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>

<script type="text/javascript">
jQuery(function($) {
	if ($('html.no-js').length) {
		return;
	}
	
	var scrollTop = $('html').scrollTop();
	var ef_node = $('#EntryForm').hide();

	configure_entry_form_button();

	<% If g_intPreventDuplicateOrgNames <> 0 Then %>
	var org_levels = {
	<%
		If Not bNew Then
			Dim key,values
			key = Array("ORG_LEVEL_1", "ORG_LEVEL_2", "ORG_LEVEL_3", "ORG_LEVEL_4", "ORG_LEVEL_5", "LOCATION_NAME", "SERVICE_NAME_LEVEL_1", "SERVICE_NAME_LEVEL_2")
			values = Array("OL1", "OL2", "OL3", "OL4", "OL5", "LN", "SERVICE_NAME_LEVEL_1", "SERVICE_NAME_LEVEL_2")
			For i = 0 to 7 
				Response.Write(StringIf(i <> 0, ",") & JSONQs(key(i),True) & ": " & JSONQs(rsOrg(values(i)), True))
			Next
		End If
	%>
	};

	init_validate_duplicate_org_names({
		num: <%= IIf(bNew, "null", JSONQs(strNUM, True)) %>,
		org_levels: org_levels,
		confirm_string: <%= JSONQs(TXT_DUPLICATE_ORG_NAME_PROMPT, True) %>,
		<% If g_intPreventDuplicateOrgNames = 2 Then %>
		only_warn: false,
		<% End If %>
		url: <%= JSONQs(makeLinkB("jsonfeeds/orgname_checker.asp"),True) %>
	});
	<% End If %>
	entryform.org_level_complete_url = "<%= makeLinkB(ps_strPathToStart & "jsonfeeds/orgname_generator.asp") %>";
	init_orglevels($);
	entryform.chk_notes_maxlen = "<%= MAX_LENGTH_CHECKLIST_NOTES %>";
	entryform.chk_notes_size = "<%= TEXT_SIZE - 25 %>";
	init_cached_state();

	init_entryform_notes($('.EntryFormNotesContainer'), '<%= TXT_VIEW_CANCELLED %>', '<%= TXT_HIDE_CANCELLED %>');
	init_fees($);
	init_org_num($);
	init_locations_services($, <%=JSONQs(TXT_INVALID_RECORD_NUM, True) %>);
<%
If bOtherAddressesAdded or bActivityInfoAdded or bBillingAddressesAdded or bContractSignatureAdded or bVacancyAdded or bHasSchedule Then
%> 
	init_entryform_items($('.EntryFormItemContainer'),'<%= TXT_DELETE %>', '<%= TXT_RESTORE %>'); 
<%
End If
If bAreasServed Or bLocatedIn Or bSiteAddress Then
%>
	entryform.community_complete_url = "<%= makeLinkB(ps_strPathToStart & "jsonfeeds/community_generator.asp") %>";
<%
End If
If bAreasServed Then
%>
	init_areas_served($, "<%= TXT_NOT_FOUND %>"); 
<%
End If
If bLocatedIn Then
%>
	init_community_autocomplete($, 'LOCATED_IN_CM', entryform.community_complete_url, 3, '#LOCATED_IN_CM_ID');
<%
End If
If bLanguages Then
%>
	entryform.languages_source = <%= makeLanguagesListJavaScript() %>;
	init_languages($, "<%= TXT_NOT_FOUND %>");
<%
End If
%>
<%
If bSchoolsInArea Or bSchoolEscort Then
%>
	entryform.sch_source = <%= makeSchoolListJavaScript() %>;
<%
End If
If bSchoolsInArea Then
%>
	init_inarea_schools($, "<%= TXT_NOT_FOUND %>");
<%
End If
If bSchoolEscort Then
%>
	init_escort_schools($, "<%= TXT_NOT_FOUND %>");
<%
End If
If bDistribution Then
%>
	entryform.dst_complete_url = "<%= makeLinkB(ps_strPathToStart & "jsonfeeds/distribution_generator.asp") %>";
	init_distribution($, "<%= TXT_NOT_FOUND %>");
<%
End If
If bSubjects Then
%>
	entryform.subj_complete_url = "<%= makeLinkB(ps_strPathToStart & "jsonfeeds/subject_generator.asp") %>";
	init_subjects($, "<%= TXT_NOT_FOUND %>");
<%
End If
If bSiteAddress Then
%>
	init_community_autocomplete($, 'SITE_CITY', entryform.community_complete_url, 3)
<%
End If
If bBusRoutes Then
%>
	init_busroutes($);
<%
End If

If bHasVacancyServiceTitles Then
%>
	<%= strVacancyServiceTitleUI %>
	entryform.service_titles = service_titles;
	$('.ServiceTitleField').combobox({ source: service_titles });
<%
End If
%>
	restore_cached_state();
<%
If bHasSchedule Then
%>
	init_schedule($)
<%
End If
%>

	update_form_make_required_org_level();

	var validator = init_client_validation('#EntryForm', '<%= TXT_VALIDATION_ERRORS_TITLE %>');

	init_check_for_autochecklist(<%= JSONQs(TXT_UNADDED_CHECKLIST_ALERT, True) %>);

	<% If Not bNew Then %>
	var ols = <%= JSONQs(rsOrg.Fields("OLS"), True) %>.split(',');
	<% Else %>
	var ols = [];
	<% End If %>
	var defaults = {
		<% If Not bNew Then %>
		org_num: <%= JSONQs(rsOrg.Fields("ORG_NUM"), True) %>,
		display_org_name: <%= IIf(rsOrg.Fields("DISPLAY_ORG_NAME"), "true", "false") %>
		<% Else %>
		org_num: null,
		display_org_name: false
		<% End If %>
	};
	$.each(ols, function(index, value) {
		defaults[value] = true;
	});
	init_name_editable_toggle(defaults);
<%
If Not bNew Then
%>
	if (!validator.form()) {
		ef_node.show();
		$('html').scrollTop(scrollTop);
		alert("<%= TXT_VALIDATION_ERRORS_MESSAGE %>");
		ef_node.hide();
	}

<%
End If
%>
<%
If Not bNew And g_bUseCIC Then
	Call printHistoryDialogJavaScript(False)
End If

If bHaveGeoCodeUI Then
%>
setTimeout(function() {
	pageconstants = {};
	pageconstants.txt_geocode_address_changed = "<%=TXT_GEOCODE_ADDRESS_CHANGED%>";
	pageconstants.txt_geocode_intersection_change = "<%=TXT_GEOCODE_ADDRESS_CHANGED%>";
	pageconstants.culture= "<%= objUpdateLang.Culture %>";
	Globalize.culture(pageconstants.culture);

	pageconstants.txt_geocode_unknown_address= "<%=TXT_GEOCODE_UNKNOWN_ADDRESS%>";
	pageconstants.txt_geocode_map_key_fail= "<%=TXT_GEOCODE_MAP_KEY_FAIL%>";
	pageconstants.txt_geocode_too_many_queries= "<%=TXT_GEOCODE_TOO_MANY_QUERIES%>";
	pageconstants.txt_geocode_unknown_error= "<%= TXT_GEOCODE_UNKNOWN_ERROR & TXT_COLON%>";
	initialize_maps(pageconstants.culture, <%= JSONQs(getGoogleMapsKeyArg(), True)%>, entryform_maps_loaded);
	}, 25);
<%
End If
%>
ef_node.show();
$('html').scrollTop(scrollTop);
});

</script>
<%
'End writing form data
End If

Call setSessionLanguage(strRestoreCulture)

Call makePageFooter(True)
%>

<!--#include file="includes/core/incClose.asp" -->

