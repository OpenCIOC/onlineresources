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
Call setPageInfo(True, DM_CIC, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtCustFields.asp" -->
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtFinder.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtGeneralSearch2.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../text/txtSubjects.asp" -->
<!--#include file="../text/txtThesaurus.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/search/incDateSearch.asp" -->
<!--#include file="../includes/thesaurus/incSubjCategoryList.asp" -->
<!--#include file="../includes/thesaurus/incSubjSourceList.asp" -->
<%
If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Call makePageHeader(TXT_MANAGE_THESAURUS, TXT_MANAGE_THESAURUS, True, False, True, True)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> ]</p>
<form action="thesaurus_results.asp" method="get" id="EntryForm">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-2">
<tr><th class="RevTitleBox" colspan="2"><%=TXT_MANAGE_THESAURUS%></th></tr>
<tr><td colspan="2"><%=TXT_TO_EDIT_EXISTING_TERM%>
<br><a href="<%=makeLinkB(ps_strPathToStart & "admin/thesaurus/edit")%>"><%=TXT_CREATE_NEW_SUBJECT%></a>
<%If user_bSuperUserGlobalCIC Then%>
<br><a href="<%=makeLinkB(ps_strPathToStart & "admin/thesaurus/source")%>"><%=TXT_MANAGE_SOURCES%></a>
<%End If%>
</td></tr>
<tr><th class="RevTitleBox" colspan="2"><%=TXT_SEARCH_FOR_SUBJECTS%></th></tr>
<tr><td colspan="2" align="center"><input type="submit" value="<%=TXT_SEARCH%>"> <input type="RESET" value="<%=TXT_CLEAR_FORM%>"></td></tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_KEYWORDS%></td>
	<td><label for="SCon1_All"><input type="radio" name="SCon1" id="SCon1_All" value="A" checked> <%=TXT_ALL_TERMS%></label>
		<label for="SCon1_Any"><input type="radio" name="SCon1" id="SCon1_Any" value="O"> <%=TXT_ANY_TERMS%></label>
		<label for="SCon1_Boolean"><input type="radio" name="SCon1" id="SCon1_Boolean" value="B"> <%=TXT_BOOLEAN%></label>
		<br><input type="text" name="STerms1" title=<%=AttrQs(TXT_SEARCH_TERMS & TXT_COLON & "1")%> id="STerms1" size="<%=TEXT_SIZE%>">
		<br><label for="SType1_TE"><input type="radio" name="SType1" id="SType1_TE" value="TE" checked> (<%=TXT_ENGLISH%>)</label>
		<label for="SType1_TF"><input type="radio" name="SType1" id="SType1_TF" value="TF"> (<%=TXT_FRENCH%>)</label>
		<label for="SType1_NE"><input type="radio" name="SType1" id="SType1_NE" value="NE"> <%=TXT_SUBJECT_NOTES%> (<%=TXT_ENGLISH%>)</label>
		<label for="SType1_NF"><input type="radio" name="SType1" id="SType1_NF" value="NF"> <%=TXT_SUBJECT_NOTES%> (<%=TXT_FRENCH%>)</label>
	<br><br><select name="SCon">
		<option value="A"><%=TXT_AND%></option>
		<option value="O"><%=TXT_OR%></option>
		<option value="AN"><%=TXT_AND_NOT%></option>
		<option value="ON"><%=TXT_OR_NOT%></option>
	</select>
	<br><br><label for="SCon2_All"><input type="radio" name="SCon2" id="SCon2_All" value="A" checked> <%=TXT_ALL_TERMS%></label>
		<label for="SCon2_Any"><input type="radio" name="SCon2" id="SCon2_Any" value="O"> <%=TXT_ANY_TERMS%></label>
		<label for="SCon2_Boolean"><input type="radio" name="SCon2" id="SCon2_Boolean" value="B"> <%=TXT_BOOLEAN%></label>
		<br><input type="text" name="STerms2" title=<%=AttrQs(TXT_SEARCH_TERMS & TXT_COLON & "2")%>  size="<%=TEXT_SIZE%>">
		<br><label for="SType2_TE"><input type="radio" name="SType2" id="SType2_TE" value="TE" checked> (<%=TXT_ENGLISH%>)</label>
		<label for="SType2_TF"><input type="radio" name="SType2" id="SType2_TF" value="TF"> (<%=TXT_FRENCH%>)</label>
		<label for="SType2_NE"><input type="radio" name="SType2" id="SType2_NE" value="NE"> <%=TXT_SUBJECT_NOTES%> (<%=TXT_ENGLISH%>)</label>
		<label for="SType2_NF"><input type="radio" name="SType2" id="SType2_NF" value="NF"> <%=TXT_SUBJECT_NOTES%> (<%=TXT_FRENCH%>)</label></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><select name="SDateType">
		<option value=""> -- </option>
		<option value="C"><%=TXT_DATE_CREATED%></option>
		<option value="M"><%=TXT_LAST_MODIFIED%></option>
	</select></td>
		<td><%Call printDateSearchTable("S")%></td>
</tr>
<%
Call openSubjectSourceListRst()
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SUBJECT_SOURCE%></td>
	<td><span class="SmallNote"><%=TXT_HOLD_CTRL%></span>
	<br><%=makeSubjectSourceList(vbNullString,"SRCID",True,False,True)%></td>
</tr>
<%
Call closeSubjectSourceListRst()
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_AUTHORIZED%></td>
	<td><select name="Auth" id="Auth">
		<option value=""> -- </option>
		<option value="Y"><%=TXT_YES%></option>
		<option value="N"><%=TXT_NO%></option>
	</select></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_ACTIVE_STATUS%></td>
	<td><select name="Active">
		<option value=""> -- </option>
		<option value="A" selected><%=TXT_ACTIVE%></option>
		<option value="I"><%=TXT_INACTIVE%></option>
		</select></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_TERM_USAGE%></td>
	<td><select name="TUsage" id="TUsage">
		<option value=""> -- </option>
		<option value="U"><%=TXT_USED_TERM%></option>
		<option value="S"><%=TXT_UNUSED_TERM%></option>
		<option value="O"><%=TXT_USED_FOR_ANOTHER%></option>
		</select></td>
</tr>
<%
Call openSubjectCategoryListRst()
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SUBJECT_CATEGORY%></td>
	<td><span class="SmallNote"><%=TXT_HOLD_CTRL%></span>
	<br><%=makeSubjectCategoryList(vbNullString,"SubjCatID",True,False,True)%></td>
</tr>
<%
Call closeSubjectCategoryListRst()
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_RECORD_USE%></td>
	<td><%=TXT_IN_USE_BY_1_AT_LEAST%>&nbsp;<input name="RUseMore" title=<%=AttrQs(TXT_MIN_RECORDS)%> type="text" size="4" maxlength="4">&nbsp;<%=TXT_IN_USE_BY_2%>
	<br><%=TXT_IN_USE_BY_1_NO_MORE%>&nbsp;<input name="RUseLess" title=<%=AttrQs(TXT_MAX_RECORDS)%> type="text" size="4" maxlength="4">&nbsp;<%=TXT_IN_USE_BY_2%></td>
</tr>
<%If g_bOtherMembers Then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_OTHER_MEMBERS%></td>
	<td><label for="OtherLocal"><input type="checkbox" name="OtherLocal" id="OtherLocal">&nbsp;<%=TXT_INCLUDE_OTHER_MEMBERS_LOCAL_TERMS%></label></td>
</tr>
<%End If%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_RESULTS_OPTIONS%></td>
	<td><label for="ShowFull"><input type="checkbox" name="ShowFull" id="ShowFull">&nbsp;<%=TXT_SHOW_FULL_SUBJECT_INFO%></label>
	<br><%=TXT_SORT_BY & TXT_COLON%><label for="SortBy_N"><input type="radio" name="SortBy" id="SortBy_N" value="N" checked>&nbsp;<%=TXT_NAME%></label> <label for="SortBy_M"><input type="radio" name="SortBy" id="SortBy_M" value="M">&nbsp;<%=TXT_LAST_MODIFIED%></label></td>
</tr>
<tr>
	<td colspan="2" align="center"><input type="submit" value="<%=TXT_SEARCH%>"> <input type="RESET" value="<%=TXT_CLEAR_FORM%>"></td>
</tr>
</table>
</form>

<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/datepicker.js") %>
<script type="text/javascript">
jQuery(function() {
		init_cached_state();
		restore_cached_state();
		});
</script>

<%
g_bListScriptLoaded = True
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
