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
<!--#include file="text/txtChecklist.asp" -->
<!--#include file="text/txtCommonForm.asp" -->
<!--#include file="text/txtEntryForm.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtFindReplace.asp" -->
<!--#include file="text/txtFindReplaceCommon.asp" -->
<!--#include file="text/txtSetup.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/list/incBaseTableFieldList.asp" -->
<!--#include file="includes/list/incAccessibilityList.asp" -->
<!--#include file="includes/list/incAccreditationList.asp" -->
<!--#include file="includes/list/incBusRouteList.asp" -->
<!--#include file="includes/list/incCertificationList.asp" -->
<!--#include file="includes/list/incCommList.asp" -->
<!--#include file="includes/list/incContactPhoneTypeList.asp" -->
<!--#include file="includes/list/incCurrencyList.asp" -->
<!--#include file="includes/list/incDistList.asp" -->
<!--#include file="includes/list/incExtraCheckListList.asp" -->
<!--#include file="includes/list/incExtraDropDownList.asp" -->
<!--#include file="includes/list/incFeeTypeList.asp" -->
<!--#include file="includes/list/incFiscalYearEndList.asp" -->
<!--#include file="includes/list/incFundingList.asp" -->
<!--#include file="includes/list/incHonorificList.asp" -->
<!--#include file="includes/list/incLanguagesList.asp" -->
<!--#include file="includes/list/incMappingSystemList.asp" -->
<!--#include file="includes/list/incMembershipTypeList.asp" -->
<!--#include file="includes/list/incOrgLocationServiceList.asp" -->
<!--#include file="includes/list/incPaymentMethodList.asp" -->
<!--#include file="includes/list/incPaymentTermsList.asp" -->
<!--#include file="includes/list/incQualityList.asp" -->
<!--#include file="includes/list/incRecordNoteTypeList.asp" -->
<!--#include file="includes/list/incRecordTypeList.asp" -->
<!--#include file="includes/list/incSchoolList.asp" -->
<!--#include file="includes/list/incServiceLevelList.asp" -->
<!--#include file="includes/list/incSocialMediaList.asp" -->
<!--#include file="includes/list/incTypeOfCareList.asp" -->
<!--#include file="includes/list/incTypeOfProgramList.asp" -->
<!--#include file="includes/list/incWardList.asp" -->
<!--#include file="includes/publication/incHasPubDescList.asp" -->

<%
Dim strHonorificList, _
	strContactPhoneTypeList

Function makeContactFieldVal(strContactType)
	Dim strReturn
	
	If Nl(strHonorificList) Then
		Call openHonorificListRst()
		strHonorificList = makeHonorificList(vbNullString,"CONTACT_NAME_HONORIFIC",True,True)
		Call closeHonorificListRst()
	End If
	
	If Nl(strContactPhoneTypeList) Then
		Call openContactPhoneTypeListRst()
		strContactPhoneTypeList = makeContactPhoneTypeList(vbNullString,"CONTACT_PHONE_X_TYPE",True,True)
		Call closeContactPhoneTypeListRst()
	End If
	
	strReturn = "<table class=""NoBorder cell-padding-3 cell-border-bottom"">" & vbCrLf & _
		"<tr>" & vbCrLf & _
		"	<td class=""FieldLabelLeftClr"">" & TXT_NAME & "</td>" & vbCrLf & _
		"	<td>" & vbCrLf & _
		"	<table class=""NoBorder cell-padding-2"">" & vbCrLf & _
		"		<tr>" & vbCrLf & _
		"			<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_NAME_FIRST"">" & TXT_NAME_FIRST & "</label></td>" & vbCrLf & _
		"			<td>" & Replace(strHonorificList,"CONTACT_NAME_HONORIFIC",strContactType & "_NAME_HONORIFIC") & " <input type=""text"" id=""" & strContactType & "_NAME_FIRST"" name=""" & strContactType & "_NAME_FIRST"" size=""35"" maxlength=""60""></td>" & vbCrLf & _
		"		</tr>" & vbCrLf & _
		"		<tr>" & vbCrLf & _
		"			<td class=""FieldLabelLeftClr""><label for=""" & strContactType & "_NAME_LAST"">" & TXT_NAME_LAST & "</label></td>" & vbCrLf & _
		"			<td><input type=""text"" id=""" & strContactType & "_NAME_LAST"" name=""" & strContactType & "_NAME_LAST"" size=""60"" maxlength=""100""></td>" & vbCrLf & _
		"		</tr>" & vbCrLf & _
		"		<tr>" & vbCrLf & _
		"			<td class=""FieldLabelLeftClr"">" & TXT_SUFFIX & "</td>" & vbCrLf & _
		"			<td><input type=""text"" id=""" & strContactType & "_NAME_SUFFIX"" name=""" & strContactType & "_NAME_SUFFIX"" size=""30"" maxlength=""30""></td>" & vbCrLf & _
		"		</tr>" & vbCrLf & _
		"	</table></td>" & vbCrLf & _
		"</tr>" & vbCrLf & _
		"<tr>" & vbCrLf & _
		"	<td class=""FieldLabelLeftClr"">" & TXT_TITLE & "</td>" & vbCrLf & _
		"	<td><input type=""text"" id=""" & strContactType & "_TITLE"" name=""" & strContactType & "_TITLE"" size=""70"" maxlength=""100""></td>" & vbCrLf & _
		"</tr>"	& vbCrLf & _
		"<tr>" & vbCrLf & _
		"	<td class=""FieldLabelLeftClr"">" & TXT_ORGANIZATION & "</td>" & vbCrLf & _
		"	<td><input type=""text"" id=""" & strContactType & "_ORG"" name=""" & strContactType & "_ORG"" size=""70"" maxlength=""100""></td>" & vbCrLf & _
		"</tr>" & vbCrLf & _
		"<tr>" & vbCrLf & _
		"	<td class=""FieldLabelLeftClr"">" & TXT_EMAIL & "</td>" & vbCrLf & _
		"	<td><input type=""text"" id=""" & strContactType & "_EMAIL"" name=""" & strContactType & "_EMAIL"" size=""70"" maxlength=""60""></td>" & vbCrLf & _
		"</tr>" & vbCrLf & _
		"<tr valign=""top"">" & vbCrLf & _
		"	<td class=""FieldLabelLeftClr"">" & TXT_FAX & "</td>" & vbCrLf & _
		"	<td><table class=""NoBorder cell-padding-2"">" & vbCrLf & _
		"		<tr>" & vbCrLf & _
		"			<td class=""FieldLabelLeftClr"">" & TXT_NOTES & "</td>" & vbCrLf & _
		"			<td colspan=""3""><input type=""text"" id=""" & strContactType & "_FAX_NOTE"" name=""" & strContactType & "_FAX_NOTE"" size=""60"" maxlength=""100""></td>" & vbCrLf & _
		"		</tr>" & vbCrLf & _
		"		<tr>" & vbCrLf & _
		"			<td class=""FieldLabelLeftClr"">" & TXT_NUMBER & "</td>" & vbCrLf & _
		"			<td><input type=""text"" id=""" & strContactType & "_FAX_NO"" name=""" & strContactType & "_FAX_NO"" size=""20"" maxlength=""20""></td>" & vbCrLf & _
		"			<td><span class=""FieldLabelLeftClr"">" & TXT_EXT & "</span> <input type=""text"" id=""" & strContactType & "_FAX_EXT"" name=""" & strContactType & "_FAX_EXT"" size=""6"" maxlength=""10""></td>" & vbCrLf & _
		"			<td><span class=""FieldLabelLeftClr"">" & TXT_PLEASE_CALL_FIRST & "</span> <select id=""" & strContactType & "_FAX_CALLFIRST"" name=""" & strContactType & "_FAX_CALLFIRST"">" & _
		"			<option value=""> -- </option>" & _
		"			<option value=""" & SQL_TRUE & """>" & TXT_YES & "</option>" & _
		"			<option value=""" & SQL_FALSE & """>" & TXT_NO & "</option>" & _
		"			</select></td>" & vbCrLf & _
		"		</tr>" & vbCrLf & _
		"	</table></td>" & vbCrLf & _
		"</tr>"
		
	Dim i
	For i = 1 to 3
		strReturn = strReturn & _
			"<tr valign=""top"">" & vbCrLf & _
			"	<td class=""FieldLabelLeftClr"">" & TXT_PHONE & " #" & i & "</td>" & vbCrLf & _
			"	<td><table class=""NoBorder cell-padding-2"">" & vbCrLf & _
			"		<tr>" & vbCrLf & _
			"			<td class=""FieldLabelLeftClr"">Type</td>" & vbCrLf & _
			"			<td>" & Replace(strContactPhoneTypeList,"CONTACT_PHONE_X_TYPE",strContactType & "_PHONE_" & i & "_TYPE") & "</td>" & vbCrLf & _
			"			<td class=""FieldLabelLeftClr"">" & TXT_NOTES & "</td><td><input type=""text"" id=""" & strContactType & "_PHONE_" & i & "_NOTE"" name=""" & strContactType & "_PHONE_" & i & "_NOTE"" size=""30"" maxlength=""100""></td>" & vbCrLf & _
			"		</tr>" & vbCrLf & _
			"		<tr>" & vbCrLf & _
			"			<td class=""FieldLabelLeftClr"">" & TXT_NUMBER & "</td>" & vbCrLf & _
			"			<td><input type=""text"" id=""" & strContactType & "_PHONE_" & i & "_NO"" name=""" & strContactType & "_PHONE_" & i & "_NO"" size=""20"" maxlength=""20""></td>" & vbCrLf & _
			"			<td class=""FieldLabelLeftClr"">" & TXT_EXT & "</td><td><input type=""text"" id=""" & strContactType & "_PHONE_" & i & "_EXT"" name=""" & strContactType & "_PHONE_" & i & "_EXT"" size=""6"" maxlength=""10"">" & vbCrLf & _
			"			<span class=""FieldLabelLeftClr"">" & TXT_OPTION & "</span> <input type=""text"" id=""" & strContactType & "_PHONE_" & i & "_OPTION"" name=""" & strContactType & "_PHONE_" & i & "_OPTION"" size=""6"" maxlength=""10""></td>" & vbCrLf & _
			"		</tr>" & vbCrLf & _
			"	</table></td>" & vbCrLf & _
			"</tr>"
	Next

	strReturn = strReturn & "</table>"

	makeContactFieldVal = strReturn
End Function

Dim strCMList, _
	strSCHList

strCMList = vbNullString
strSCHList = vbNullString

Function getCMList() 
	If Nl(strCMList) Then
		Call openCommListRst()
		strCMList = makeCommList(vbNullString, "CheckListItem1", True, False, vbNullString, vbNullString)
		Call closeCommListRst()
	End If
	getCMList = strCMList
End Function

Function getSCHList() 
	If Nl(strSCHList) Then
		Call openSchoolListRst(False)
		strSCHList = makeSchoolList(vbNullString, "CheckListItem1", True, vbNullString)
		Call closeSchoolListRst()
	End If
	getSCHList = strSCHList
End Function

Function getCheckOptions(strWhich)
	Dim strChkList
	Select Case strWhich
		Case "ac"
			Call openAccessibilityListRst(False,True)
			strChkList = makeAccessibilityList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeAccessibilityListRst()
		Case "acr"
			Call openAccreditationListRst(False,True,Null)
			strChkList = makeAccreditationList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeAccreditationListRst()
		Case "br"
			Call openBusRouteListRst(False)
			strChkList = makeBusRouteList(vbNullString, "CheckListItem1", True, vbNullString)				
			Call closeBusRouteListRst()
		Case "cm"
			strChkList = getCMList()
		Case "crt"
			Call openCertificationListRst(False,True,Null)
			strChkList = makeCertificationList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeCertificationListRst()
		Case "cur"
			Call openCurrencyListRst(False)
			strChkList = makeCurrencyList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeCurrencyListRst()
		Case "dst"
			Call openDistListRst(False)
			strChkList = makeDistList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeDistListRst()			
		Case "fd"
			Call openFundingListRst(False,True)
			strChkList = makeFundingList(vbNullString, "CheckListItem1", True, vbNullString)				
			Call closeFundingListRst()
		Case "ft"
			Call openFeeTypeListRst(False,True)
			strChkList = makeFeeTypeList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeFeeTypeListRst()
		Case "fye"
			Call openFiscalYearEndListRst(False,True,Null)
			strChkList = makeFiscalYearEndList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeFiscalYearEndListRst()
		Case "lcm"
			strChkList = getCMList()
		Case "ln"
			Call openLanguagesListRst(False, False)
			strChkList = makeLanguagesList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeLanguagesListRst()
		Case "map"
			Call openMappingSystemListRst(True)
			strChkList = makeMappingSystemList(vbNullString, "CheckListItem1", True, False, vbNullString)
			Call closeMappingSystemListRst()
		Case "mt"
			Call openMembershipTypeListRst(False,True)
			strChkList = makeMembershipTypeList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeMembershipTypeListRst()
		Case "ols"
			Call openOrgLocationServiceListRst()
			strChkList = makeOrgLocationServiceList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeOrgLocationServiceListRst()
		Case "pay"
			Call openPaymentMethodListRst(False,True,Null)
			strChkList = makePaymentMethodList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closePaymentMethodListRst()
		Case "pyt"
			Call openPaymentTermsListRst(False,True,Null)
			strChkList = makePaymentTermsList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closePaymentTermsListRst()
		Case "rq"
			Call openQualityListRst(False,Null)
			strChkList = makeQualityList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeQualityListRst()
		Case "rt"
			Call openRecordTypeListRst(False,False,False,Null)
			strChkList = makeRecordTypeList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeRecordTypeListRst()
		Case "scha"
			strChkList = getSCHList()
		Case "sche"
			strChkList = getSCHList()
		Case "sl"
			Call openServiceLevelListRst(False)
			strChkList = makeServiceLevelList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeServiceLevelListRst()
		Case "sm"
			Call openSocialMediaListRst(False)
			strChkList = makeSocialMediaList(vbNullString, "CheckListItem1", True, False, vbNullString)
			Call closeSocialMediaListRst()
		Case "toc"
			Call openTypeOfCareListRst(False,True)
			strChkList = makeTypeOfCareList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeTypeOfCareListRst()
		Case "top"
			Call openTypeOfProgramListRst(False,True,Null)
			strChkList = makeTypeOfProgramList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeTypeOfProgramListRst()
		Case "wd"
			Call openWardListRst(False,Null)
			strChkList = makeWardList(vbNullString, "CheckListItem1", True, vbNullString)
			Call closeWardListRst()
		Case Else
			Dim strFieldName
			strFieldName = Mid(UCase(strWhich), 4)
			Select Case Left(strWhich, 3)
			Case "exc"
				strFieldName = "EXTRA_CHECKLIST_" & strFieldName
				Call openExtraCheckListListRst(DM_S_CIC, strFieldName, False, False)
				strChkList = makeExtraCheckListList(strFieldName, vbNullString, "CheckListItem1", True, vbNullString)
				Call closeExtraCheckListListRst(strFieldName)
			Case "exd"
				strFieldName = "EXTRA_DROPDOWN_" & strFieldName
				Call openExtraDropDownListRst(DM_S_CIC, strFieldName, False, False, vbNullString)
				strChkList = makeExtraDropDownList(strFieldName, vbNullString, "CheckListItem1", True, vbNullString)
				Call closeExtraDropDownListRst(strFieldName)
			End Select
	End Select

	getCheckOptions = Server.HTMLEncode(strChkList)
End Function

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

Dim intReplaceType, _
	strIDList

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

Call makePageHeader(TXT_FIND_REPLACE_ON_SELECTED, TXT_FIND_REPLACE_ON_SELECTED, True, True, True, True)
%>
<h2><%=TXT_FIND_REPLACE_ON_SELECTED%></h2>
<p><span class="AlertBubble" style="font-size:larger;"><%=TXT_USE_WITH_CAUTION%></span></p>
<%If g_bMultiLingual Then%>
<p class="Alert"><%=TXT_ONLY_IN_LANGUAGE%></p>
<%End If%>
<p class="Alert"><%=TXT_INST_NO_VALIDATION%></p>
<%
Select Case intReplaceType
	Case RT_FINDREPLACE
%>
<form action="<%=ps_strPathToStart%>findreplace2.asp" method="post">
<input type="hidden" name="ReplaceType" value="<%=RT_FINDREPLACE%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<%=g_strCacheFormVals%>
<p class="Info"><%=TXT_NOT_ALL_FIELDS_AVAILABLE%></p>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="2" class="RevTitleBox"><%=TXT_FIND_AND_REPLACE_TOOL%></th>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LOOK_IN_FIELDS%></td>
	<td><span class="SmallNote"><%=TXT_HOLD_CTRL%></span>
	<br><%Call printBaseTableTextFieldList("FieldName",False,False,True,True,False)%></td>
</tr>
<%
Call openHasPubDescRst(strIDList)
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LOOK_IN_PUB_DESCRIPTIONS%></td>
	<td><span class="SmallNote"><%=TXT_CODES_WITH_DESCRIPTIONS%>
	<br><%=TXT_HOLD_CTRL%></span>
	<br><%=makeHasPubDescList(vbNullString,"CodeIDList",False,True)%></td>
</tr>
<%
Call closeHasPubDescRst()
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LOOK_IN_CHECK_NOTES%></td>
	<td><span class="SmallNote"><%=TXT_HOLD_CTRL%></span>
	<br><select name="CheckListType" multiple size="7">
		<option value="ac"><%=TXT_CHK_ACCESSIBILITY%></option>
		<option value="cm"><%=TXT_CHK_AREAS_SERVED%></option>
		<option value="ft"><%=TXT_CHK_FEES%></option>
		<option value="fd"><%=TXT_CHK_FUNDING%></option>
		<option value="ln"><%=TXT_CHK_LANGUAGE%></option>
		<option value="sche"><%=TXT_SCHOOL_ESCORT%></option>
		<option value="scha"><%=TXT_SCHOOLS_IN_AREA%></option>
		<option value="toc"><%=TXT_CHK_TYPE_OF_CARE%></option>
	</select></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_FOR_THE_TEXT%></td>
	<td><textarea name="FindText" cols="<%=TEXTAREA_COLS%>" rows="2"></textarea></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_REPLACE_WITH%></td>
	<td><textarea name="ReplaceText" cols="<%=TEXTAREA_COLS%>" rows="2"></textarea></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_OPTIONS%></td>
	<td><input type="checkbox" name="MatchCase">&nbsp;<%=TXT_MATCH_CASE%>
	<br><input type="checkbox" name="WholeField">&nbsp;<%=TXT_WHOLE_FIELD%>
	<br><input type="checkbox" name="IgnoreSpace">&nbsp;<%=TXT_IGNORE_WHITESPACE%></td>
</tr>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_REPLACE%>"></td>
</tr>
</table>
</form>
<%
	Case RT_INSERT
%>
<form action="<%=ps_strPathToStart%>findreplace2.asp" method="post">
<input type="hidden" name="ReplaceType" value="<%=RT_INSERT%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<%=g_strCacheFormVals%>
<p class="Info"><%=TXT_NOT_ALL_FIELDS_AVAILABLE%></p>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="2" class="RevTitleBox"><%=TXT_PREPEND_APPEND%></th>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_IN_BASETABLE%></td>
	<td><%Call printBaseTableTextFieldList("FieldName",True,False,False,False,True)%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_INSERT_TEXT%></td>
	<td><span class="SmallNote"><%=TXT_INST_INSERT%></span>
	<br><textarea name="InsertText" cols="<%=TEXTAREA_COLS%>" rows="2"></textarea></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_PUT_TEXT%></td>
	<td><select name="BeforeAfter">
		<option value="B"><%=TXT_BEFORE_TEXT%></option>
		<option value="A"><%=TXT_AFTER_TEXT%></option>
	</select>
	<p class="Alert"><%=TXT_NOTE_APPEND_DATE%></p></td>
</tr>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_INSERT_TEXT%>"></td>
</tr>
</table>
</form>
<%
	Case RT_CLEARFIELD
%>
<form action="<%=ps_strPathToStart%>findreplace2.asp" method="post">
<input type="hidden" name="ReplaceType" value="<%=RT_CLEARFIELD%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<%=g_strCacheFormVals%>
<p class="Info"><%=TXT_NOT_ALL_FIELDS_AVAILABLE%></p>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="2" class="RevTitleBox"><%=TXT_CLEAR_FIELD_TOOL%></th>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_ERASE_FIELD%></td>
	<td><%Call printBaseTableTextFieldList("FieldName",True,True,True,False,True)%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_IM_SURE%></td>
	<td><input type="checkbox" name="Confirmed" autocomplete="OFF"> <%=TXT_ERASE_IN_ALL_RECORDS%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_IM_REALLY_SURE%></td>
	<td><input type="checkbox" name="Confirmed2" autocomplete="OFF"> <%=TXT_I_KNOW_WHAT_IM_DOING%></td>
</tr>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_CLEAR_FIELD%>"></td>
</tr>
</table>
</form>
<%
	Case RT_CHECKLIST
	
	Dim cmdViewUpdChkData, rsViewUpdChkData
	Set cmdViewUpdChkData = Server.CreateObject("ADODB.Command")
	With cmdViewUpdChkData
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_View_UpdateFields_l_Chk"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	End With
	Set rsViewUpdChkData = Server.CreateObject("ADODB.Recordset")
	With rsViewUpdChkData
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdViewUpdChkData
	End With
	
%>
<form action="<%=ps_strPathToStart%>findreplace2.asp" method="post" name="CheckListForm">
<input type="hidden" name="ReplaceType" value="<%=RT_CHECKLIST%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="2" class="RevTitleBox"><%=TXT_CHECKLIST_TOOL%></th>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_CHECKLISTS%></td>
	<td><select name="CheckListType" id="CheckListType">
		<option value=""> -- </option>
<%
With rsViewUpdChkData
	While Not .EOF

%>
	<option value="<%=.Fields("ChecklistSearch")%>" data-optui="<%= getCheckOptions(.Fields("ChecklistSearch")) %>"><%=.Fields("FieldDisplay")%></option>
<%
		.MoveNext
	Wend
End With	
%>
	</select></td>
</tr>
<tr id="CheckListItem1Row">
	<td class="FieldLabelLeft"><span id="LookForTextBlock"><%=TXT_LOOK_FOR%> / </span><%=TXT_DELETE%></td>
	<td><div id="CheckListItem1Block">&nbsp;</div></td>
</tr>
<tr id="CheckListItem2Row">
	<td class="FieldLabelLeft"><span id="ReplaceWithTextBlock"><%=TXT_REPLACE_WITH%> / </span><%=TXT_ADD%></td>
	<td><div id="CheckListItem2Block">&nbsp;</div></td>
</tr>
<tr id="CheckListNoteRow">
	<td class="FieldLabelLeft"><span id="NoteTextBlock"><%=TXT_NOTES%></span><span id="URLTextBlock" style="display:none"><%=TXT_URL%></span></td>
	<td><div id="CheckListNoteBlock">&nbsp;</div></td>
</tr>
<tr>
	<td colspan="2"><input type="submit" name="Submit" id="ReplaceButton" value="<%=TXT_REPLACE%>"></td>
</tr>
</table>
</form>
<%
	Case RT_NAME
%>
<form action="<%=ps_strPathToStart%>findreplace2.asp" method="post" name="NameForm" id="NameForm">
<input type="hidden" name="ReplaceType" value="<%=RT_NAME%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="2" class="RevTitleBox"><%=TXT_NAME_TOOL%></th>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_NAME%></td>
	<td><select name="NameField" id="NameField">
	<option value=""> -- </option>
	<option value="ALT_ORG" data-replacewithui="<%= Server.HTMLEncode("<input name=""ReplaceText"" id=""ReplaceText"" size=""" & TEXT_SIZE & """ maxlength=""255"">") %>">ALT_ORG</option>
	<option value="FORMER_ORG" data-replacewithui="<%= Server.HTMLEncode("<span class=""SmallNote"">" & TXT_ADD_ONLY_UNUSED & "</span><table class=""NoBorder cell-padding-2""><tr><td class=""FieldLabelLeftClr"">" & TXT_NAME & "</td><td><input name=""ReplaceText"" id=""ReplaceText"" size=""" & CStr(TEXT_SIZE-15) & """ maxlength=""255""></td></tr><tr><td class=""FieldLabelLeftClr"">" & TXT_DATE_OF_CHANGE & "</td><td><input name=""DATE_OF_CHANGE"" type=""TEXT"" size=""20"" maxlength=""20""> " & TXT_OPTIONAL & "</td></tr></table>") %>">FORMER_ORG</option>
	</select></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LOOK_FOR%> / <%=TXT_DELETE%></td>
	<td><span id="LookFor"><input name="FindText" id="FindText" size="<%=TEXT_SIZE%>" maxlength="255"></span></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_REPLACE_WITH%> / <%=TXT_ADD%></td>
	<td><span id="ReplaceWith">&nbsp;</span></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_OPTIONS%></td>
	<td><input type="checkbox" name="MatchCase">&nbsp;<%=TXT_MATCH_CASE%>
	<br><input type="checkbox" name="WholeField">&nbsp;<%=TXT_WHOLE_FIELD%>
	<br><input type="checkbox" name="IgnoreSpace">&nbsp;<%=TXT_IGNORE_WHITESPACE%></td>
</tr>
<tr>
	<td colspan="2"><input type="submit" name="Submit" id="ReplaceButton" value="<%=TXT_REPLACE%>"></td>
</tr>
</table>
</form>
<%
	Case RT_CONTACT
	
	Dim cmdViewUpdContactData, rsViewUpdContactData
	Set cmdViewUpdContactData = Server.CreateObject("ADODB.Command")
	With cmdViewUpdContactData
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_View_UpdateFields_l_Contact"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	End With
	Set rsViewUpdContactData = Server.CreateObject("ADODB.Recordset")
	With rsViewUpdContactData
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdViewUpdContactData
	End With
%>
<form action="<%=ps_strPathToStart%>findreplace2.asp" method="post">
<input type="hidden" name="ReplaceType" value="<%=RT_CONTACT%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="2" class="RevTitleBox"><%=TXT_FIND_AND_REPLACE_TOOL%></th>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LOOK_IN_CONTACT%></td>
	<td><select name="FieldName">
<%
With rsViewUpdContactData
	While Not .EOF
%>
	<option value="<%=.Fields("FieldName")%>"><%=.Fields("FieldDisplay")%></option>
<%
		.MoveNext
	Wend
End With	
%>
		</select></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MATCH_CONTACTS%></td>
	<td><span class="SmallNote"><%=TXT_INST_MATCH_CONTACTS%></span>
	<br>&nbsp;
	<%=makeContactFieldVal("FIND")%>
	<br><span class="FieldLabelClr"><%=TXT_OPTIONS & TXT_COLON%></span>
	<br><input type="checkbox" name="MatchCase">&nbsp;<%=TXT_MATCH_CASE%>
	<br><input type="checkbox" name="WholeField">&nbsp;<%=TXT_WHOLE_FIELD%>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_NEW_CONTACT_INFO%></td>
	<td><span class="SmallNote"><%=TXT_INST_NEW_CONTACT_INFO%></span>
	<br>&nbsp;
	<%=makeContactFieldVal("REPLACE")%>
	<br><span class="FieldLabelClr"><%=TXT_OR%>...</span>
	<br><input type="checkbox" name="EraseContact"> <%=TXT_ERASE_IN_ALL_RECORDS%>
	<br><input type="checkbox" name="EraseContactConfirmed"> <%=TXT_I_KNOW_WHAT_IM_DOING%>
	</td>
</tr>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_REPLACE%>"> <input type="reset" value="<%=TXT_CLEAR_FORM%>"></td>
</tr>
</table>
</form>
<%
	Case RT_RECORDNOTE
	
	Dim cmdViewUpdRecordNoteData, rsViewUpdRecordNoteData
	Set cmdViewUpdRecordNoteData = Server.CreateObject("ADODB.Command")
	With cmdViewUpdRecordNoteData
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_View_UpdateFields_l_RecordNote"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	End With
	Set rsViewUpdRecordNoteData = Server.CreateObject("ADODB.Recordset")
	With rsViewUpdRecordNoteData
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdViewUpdRecordNoteData
	End With
%>
<form action="<%=ps_strPathToStart%>findreplace2.asp" method="post">
<input type="hidden" name="ReplaceType" value="<%=RT_RECORDNOTE%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="2" class="RevTitleBox"><%=TXT_FIND_AND_REPLACE_TOOL%></th>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_ADD_NOTE_IN%></td>
	<td><select name="FieldName">
<%
With rsViewUpdRecordNoteData
	While Not .EOF
%>
	<option value="<%=.Fields("FieldName")%>"><%=.Fields("FieldDisplay")%></option>
<%
		.MoveNext
	Wend
End With	
%>
		</select></td>
</tr>
<%
		Call openRecordNoteTypeListRst()
		If Not rsListRecordNoteType.EOF Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_NOTE_TYPE%></td>
	<td><%=makeRecordNoteTypeList(vbNullString,"NoteTypeID",IIf(ps_intDbArea=DM_CIC,g_bRecordNoteTypeOptionalCIC,g_bRecordNoteTypeOptionalVOL),vbNullString)%></td>
</tr>
<%
		End If
		Call closeRecordNoteTypeListRst()
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_NOTES%></td>
	<td><textarea name="InsertText" cols="<%=TEXTAREA_COLS-5%>" rows="<%=TEXTAREA_ROWS_LONG%>"></textarea></td>
</tr>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_ADD%>"> <input type="reset" value="<%=TXT_CLEAR_FORM%>"></td>
</tr>
</table>
</form>
<%
	Case Else
		Call goToPage("processRecordList.asp","ActionType=F&IDList=" & strIDList, vbNullString)
End Select

If intReplaceType = RT_CHECKLIST or intReplaceType = RT_NAME Then
g_bListScriptLoaded = True
%>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/findreplace.js") %>
<script type="text/javascript">
<%If intReplaceType = RT_CHECKLIST Then %>
	CIOC.initFindAndReplaceCheckList(
			<%= JsQs("<span class=""SmallNote"">" & TXT_ADD_ONLY_UNUSED & "</span><br>") %>,
			<%= JsQs("<span class=""SmallNote"">" & TXT_NOTES_ADD_ONLY & "</span><br>") %>,
			'<input type="text" size="<%= TEXT_SIZE %>" maxlength="255" name="CheckListNote" id="CheckListNote">');
<%Else%>
	CIOC.initFindAndReplaceName('" & TXT_INST_SPECIFY_FIELD & "', '" & TXT_INST_REPLACE_DIFFERENT & "');
<%End If%>
</script>
<%
End If
Call makePageFooter(True)
%>

<!--#include file="includes/core/incClose.asp" -->

