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
Call setPageInfo(False, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtCopyForm.asp" -->
<!--#include file="text/txtDates.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtGeneralSearch1.asp" -->
<!--#include file="text/txtGeneralSearch2.asp" -->
<!--#include file="text/txtGeoCode.asp" -->
<!--#include file="text/txtSearchBasic.asp" -->
<!--#include file="text/txtSearchBasicCIC.asp" -->
<!--#include file="text/txtSearchCCR.asp" -->
<!--#include file="includes/search/incCommSrchCIC.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/list/incAgeGroupList.asp" -->
<!--#include file="includes/list/incBusRouteList.asp" -->
<!--#include file="includes/list/incLanguagesList.asp" -->
<!--#include file="includes/list/incSchoolList.asp" -->
<!--#include file="includes/list/incTypeOfCareList.asp" -->
<!--#include file="includes/list/incTypeOfProgramList.asp" -->
<!--#include file="includes/mapping/incGoogleMaps.asp" -->
<!--#include file="includes/taxonomy/incTaxTermSearches.asp" -->
<%
Dim	bSrchCommunityDefault, _
	bCSrch, _
	bCSrchBusRoute, _
	bCSrchKeywords, _
	bCSrchLanguages, _
	bCSrchNear, _
	bCSrchSchoolEscort, _
	bCSrchSchoolsInArea, _
	bCSrchSpaceAvailable, _
	bCSrchSubsidy, _
	bCSrchTypeOfProgram

' Get Basic Search View data
Dim cmdCSrchViewData, rsCSrchViewData
Set cmdCSrchViewData = Server.CreateObject("ADODB.Command")
With cmdCSrchViewData
	.ActiveConnection = getCurrentCICBasicCnn()
	.CommandText = "dbo.sp_CIC_View_s_CSrch"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
End With
Set rsCSrchViewData = cmdCSrchViewData.Execute

' CIC View data
With rsCSrchViewData
	If Not .EOF Then
		bSrchCommunityDefault = .Fields("SrchCommunityDefault")
		bCSrch = .Fields("CSrch")
		bCSrchBusRoute = .Fields("CSrchBusRoute")
		bCSrchKeywords = .Fields("CSrchKeywords")
		bCSrchLanguages = .Fields("CSrchLanguages")
		bCSrchNear = .Fields("CSrchNear")
		bCSrchSchoolEscort = .Fields("CSrchSchoolEscort")
		bCSrchSchoolsInArea = .Fields("CSrchSchoolsInArea")
		bCSrchSpaceAvailable = .Fields("CSrchSpaceAvailable")
		bCSrchSubsidy = .Fields("CSrchSubsidy")
		bCSrchTypeOfProgram = .Fields("CSrchTypeOfProgram")
	End If
End With

If Not bCSrch Then
	Call securityFailure()
End If

If user_bLoggedIn Then
End If


Dim bInlineMode
bInlineMode = Not Nl(Trim(Request("InlineMode")))

If Not bInlineMode Then
Call makePageHeader(TXT_CHILD_CARE_SEARCH, TXT_CHILD_CARE_SEARCH, True, True, True, True)
End If

Dim intWrapAt,intWrapNum
%>
<div id="csrch_top">
<form action="cresults.asp" method="get" id="EntryForm" name="EntryForm"<%If user_bLoggedIn Then%> onSubmit="formNewWindow(this);"<%End If%>>
<div style="display:none">
<%=g_strCacheFormVals%>
</div>
<p><input type="submit" value="<%=TXT_SEARCH%>"> <input type="RESET" value="<%=TXT_CLEAR_FORM%>"></p>
<table class="BasicBorder cell-padding-3">
<%
Dim strCommTable, bEmptyCommTable
strCommTable = makeCommSrchTable(bEmptyCommTable)

If Not bEmptyCommTable Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_COMMUNITIES%></td>
	<td><span class="SmallNote"><%=TXT_NO_SELECTION_SEARCH_ALL%></span>
	<hr style="border: 1px dashed #999999">
	<%=strCommTable%></td>
</tr>
<%
End If

If bCSrchNear Then
%>
<!--#include file="includes/mapping/incMapSearchForm.asp" -->
<%
	Call printMapSearchForm(bInlineMode)
End If

intWrapAt = 1
intWrapNum = intWrapAt

Call openAgeGroupListRst(True)
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_AGES%></td>
	<td><span class="SmallNote"><%=TXT_NO_SELECTION_SEARCH_ALL%></span>
	<hr style="border: 1px dashed #999999">
	<p><%=TXT_ENTER_DATE_OF_BIRTH%></p>
	<table class="NoBorder cell-padding-2">
	<tr>
		<td class="FieldLabelClr"><label for="DOB0"><%=TXT_DATE_OF_BIRTH%> #1</label></td>
		<td><input type="text" name="DOB0" class="DatePicker" id="DOB0"> (<%=TXT_EG%> <%=DateString(Date(),True)%>)</td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><label for="DOB1"><%=TXT_DATE_OF_BIRTH%> #2</label></td>
		<td><input type="text" name="DOB1" id="DOB1" class="DatePicker"></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><label for="DOB2"><%=TXT_DATE_OF_BIRTH%> #3</label></td>
		<td><input type="text" name="DOB2" id="DOB2" class="DatePicker"></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><label for="DOB3"><%=TXT_DATE_OF_BIRTH%> #4</label></td>
		<td><input type="text" name="DOB3" id="DOB3" class="DatePicker"></td>
	</tr>
	</table>
	<p><%=TXT_SEARCH_MULTIPLE_CHILDREN%></p>
	<p><input type="radio" name="AgeType" value="" id="AgeTypeOne">&nbsp;<label for="AgeTypeOne"><%=TXT_MATCH_ONE_CHILD%></label>
	<br><input type="radio" name="AgeType" value="A" id="AgeTypeAll" checked>&nbsp;<label for="AgeTypeAll"><%=TXT_MATCH_ALL_CHILDREN%></label>
	<%If user_bLoggedIn Then%>
	<br><input type="radio" name="AgeType" value="S" id="AgeTypeSpecific">&nbsp;<label for="AgeTypeSpecific"><%=TXT_MATCH_SPECIFIC_CHILD%></label>
		<label><input type="radio" name="AgeTypeSpecific" value="0" id="AgeTypeSpecific0" checked>1</label>
		<label><input type="radio" name="AgeTypeSpecific" value="1" id="AgeTypeSpecific1">2</label>
		<label><input type="radio" name="AgeTypeSpecific" value="2" id="AgeTypeSpecific2">3</label>
		<label><input type="radio" name="AgeTypeSpecific" value="3" id="AgeTypeSpecific3">4</label>
	<%End If%>
	</p>
	<p><%=TXT_CARE_ON_FUTURE_DATE%></p>
	<table class="NoBorder cell-padding-2">
	<tr>
		<td class="FieldLabelClr"><label for="CareDate"><%=TXT_CARE_REQUIRED_ON%></label></td>
		<td><input type="text" name="CareDate" id="CareDate" class="DatePicker"><%=IIf(bInlineMode,"<br />","&nbsp;")%><input type="button" value="<%=TXT_1_MONTH%>" onClick="document.EntryForm.CareDate.value='<%=DateString(DateAdd("m",1,Date()),True)%>';">&nbsp;<input type="button" value="<%=TXT_3_MONTHS%>" onClick="document.EntryForm.CareDate.value='<%=DateString(DateAdd("m",3,Date()),True)%>';">&nbsp;<input type="button" value="<%=TXT_6_MONTHS%>" onClick="document.EntryForm.CareDate.value='<%=DateString(DateAdd("m",6,Date()),True)%>';">&nbsp;<input type="button" value="<%=TXT_1_YEAR%>" onClick="document.EntryForm.CareDate.value='<%=DateString(DateAdd("m",12,Date()),True)%>';"></td>
	</tr>
	</table>
<%
	If Not rsListAgeGroup.EOF Then
%>
	<hr style="border: 1px dashed #999999">
	<p><%=TXT_OR_ENTER_AGE_GROUPS%></p>
	<p><%=makeAgeGroupList(vbNullString,"AgeGroup",True)%></p>
<%
	End If
%>
	</td>
</tr>
<%
Call closeAgeGroupListRst()

intWrapAt = 1
intWrapNum = intWrapAt

Call openTypeOfCareListRst(False,False)
If Not rsListTypeOfCare.EOF Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_TYPE_OF_CARE%></td>
	<td><span class="SmallNote"><%=TXT_NO_SELECTION_SEARCH_ALL%></span>
	<hr style="border: 1px dashed #999999">
	<table class="NoBorder cell-padding-2">
<%
	With rsListTypeOfCare
		While Not .EOF
			If intWrapNum = intWrapAt Then
%>
			<tr>
<%
			End If
%>
				<td<%If intWrapNum <> intWrapAt Then%> style="padding-left:8px;"<%End If%>><label><input type="checkbox" name="TOCID" id="TOCID_<%=.Fields("TOC_ID")%>" value="<%=.Fields("TOC_ID")%>"> <%=.Fields("TypeOfCare")%></label></td>
<%
			If intWrapNum > 0 Then
				intWrapNum = intWrapNum - 1
			Else
%>
			</tr>
<%
				intWrapNum = intWrapAt
			End If
			.MoveNext
		Wend	
	End With
%>
	</table>
	<hr style="border: 1px dashed #999999">
	<input type="radio" name="TOCType" id="TOCType_F" value="F">&nbsp;<label for="TOCType_F"><%=TXT_MATCH_ANY_SELECTED_TOC%></label>
	<input type="radio" name="TOCType" id="TOCType_AF" value="AF" checked>&nbsp;<label for="TOCType_AF"><%=TXT_MATCH_ALL_SELECTED_TOC%></label>
	</td>
</tr>
<%
End If
Call closeTypeOfCareListRst()

If bCSrchTypeOfProgram Then

intWrapAt = 1
intWrapNum = intWrapAt

Call openTypeOfProgramListRst(False,False,Null)
If Not rsListTypeOfProgram.EOF Then
	With rsListTypeOfProgram
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_TYPE_OF_PROGRAM%></td>
	<td><span class="SmallNote"><%=TXT_NO_SELECTION_SEARCH_ALL%></span>
	<hr style="border: 1px dashed #999999">
	<table class="NoBorder cell-padding-2">

<%
		While Not .EOF
			If intWrapNum = intWrapAt Then
%>
			<tr>
<%
			End If
%>
				<td<%If intWrapNum <> intWrapAt Then%> style="padding-left:8px;"<%End If%>><label><input type="checkbox" name="TOPID" id="TOPID_<%=.Fields("TOP_ID")%>" value="<%=.Fields("TOP_ID")%>"> <%=.Fields("TypeOfProgram")%></label></td>
<%
			If intWrapNum > 0 Then
				intWrapNum = intWrapNum - 1
			Else
%>
			</tr>
<%
				intWrapNum = intWrapAt
			End If
			.MoveNext
		Wend	
%>
	</table></td>
</tr>
<%
	End With
End If
Call closeTypeOfProgramListRst()

End If

If bCSrchSubsidy Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SUBSIDY%></td>
	<td><label><input type="checkbox" name="CCSubsidy" id="CCSubsidy"> <%=TXT_LIMIT_SUBSIDY%></label></td>
</tr>
<%
End If

If bCSrchSpaceAvailable Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SPACE_AVAILABLE%></td>
	<td><label><input type="checkbox" name="CCSpace" id="CCSpace"> <%=TXT_LIMIT_SPACE_AVAILABLE%></label></td>
</tr>
<%
End If

If bCSrchBusRoute Then

Call openBusRouteListRst(False)
If Not rsListBusRoute.EOF Then
%>
<tr>
	<td class="FieldLabelLeft"><label for="BRID"><%=TXT_ON_BUS_ROUTE%></label></td>
	<td><%=makeBusRouteList(vbNullString,"BRID",True,vbNullString)%></td>
</tr>
<%
End If
Call closeBusRouteListRst()

End If

If bCSrchSchoolsInArea Or bCSrchSchoolEscort Then

	Dim strSchoolList
	
	Call openSchoolListRst(False)
	If Not rsListSchool.EOF Then
		strSchoolList = makeSchoolList(vbNullString,"SCHAID",True,vbNullString)
	End If
	Call closeSchoolListRst()

	If Not Nl(strSchoolList) Then
	
	If bCSrchSchoolsInArea Then
%>
<tr>
	<td class="FieldLabelLeft"><label for="SCHAID"><%=TXT_LOCAL_SCHOOLS%></label></td>
	<td><%=strSchoolList%></td>
</tr>
<%
	End If
	
	If bCSrchSchoolEscort Then
%>
<tr>
	<td class="FieldLabelLeft"><label for="SCHEID"><%=TXT_ESCORTS_TO%></label></td>
	<td><%=Replace(strSchoolList,"""SCHAID""","""SCHEID""")%></td>
</tr>
<%
	End If
	
	End If

End If
If bCSrchLanguages Then

Call openLanguagesListRst(False, True)
If Not rsListLanguages.EOF Then
%>
<tr>
	<td class="FieldLabelLeft"><label for="LNID"><%=TXT_LANGUAGES%></label></td>
	<td><%=makeLanguagesList(vbNullString,"LNID",True,vbNullString)%></td>
</tr>
<%
Call closeLanguagesListRst()

End If
End If
If bCSrchKeywords Then
%>
<tr>
	<td class="FieldLabelLeft"><label for="STerms"><%=TXT_SEARCH_TERMS%></label></td>
	<td><label><input type="radio" name="SCon" id="SCon_A" value="A" checked> <%=TXT_ALL_TERMS%></label>
		<label><input type="radio" name="SCon" id="SCon_O" value="O"> <%=TXT_ANY_TERMS%></label>
		<br><input type="text" name="STerms" size="<%=IIf(bInlineMode,TEXT_SIZE-20,TEXT_SIZE)%>" maxlength="255">
		<br><label><input type="radio" name="SType" id="SType_A" value="A" checked>&nbsp;<%=TXT_WORDS_ANYWHERE%></label>
		<label><input type="radio" name="SType" id="SType_O" value="O">&nbsp;<%=Nz(get_view_data_cic("OrgProgramNames"), TXT_ORG_NAMES)%></label></td>
</tr>
<%
End If
%>
<div style="display:none"><input type="hidden" name="CCRStat" value="R"></div>
</table>
<%If user_bLoggedIn Then%>
<p><label><input type="checkbox" id="NewWindow" name="NewWindow"> <%=TXT_SEARCH_RESULTS_NEW_WINDOW%></label></p>
<%End If%>
<p><input type="submit" value="<%=TXT_SEARCH%>"> <input type="RESET" value="<%=TXT_CLEAR_FORM%>"></p>
</form>

<% If Not bInlineMode Then %>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<%= makeJQueryScriptTags() %>
<% End If %>
<%= JSVerScriptTag("scripts/csrch.js") %>
<% If Not bInlineMode Then %>
<script type="text/javascript">
jQuery(function() {
		init_cached_state();
		init_pre_fill_search_parameters();
		restore_cached_state();
		});
</script>
<% End If %>
<% 
	g_bListScriptLoaded = True
%>

<%
If bCSrchNear Then
%>
<!--#include file="includes/mapping/incMapSearchFormScript.asp" -->
<%
End If
%>

</div>

<%
If Not bInlineMode Then
Call makePageFooter(True)
Else

End If

%>
<!--#include file="includes/core/incClose.asp" -->
