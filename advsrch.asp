<%@  language="VBSCRIPT" %>
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
<!--#include file="text/txtCheckList.asp" -->
<!--#include file="text/txtCommonForm.asp" -->
<!--#include file="text/txtCustFields.asp" -->
<!--#include file="text/txtDates.asp" -->
<!--#include file="text/txtFinder.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtGeneralSearch1.asp" -->
<!--#include file="text/txtGeneralSearch2.asp" -->
<!--#include file="text/txtGeoCode.asp" -->
<!--#include file="text/txtSearchAdvanced.asp" -->
<!--#include file="text/txtSearchAdvancedCIC.asp" -->
<!--#include file="text/txtSearchBasic.asp" -->
<!--#include file="text/txtSearchBasicCIC.asp" -->
<!--#include file="text/txtSearchResults.asp" -->
<!--#include file="text/txtSearchResultsTax.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/list/incAgencyList.asp" -->
<!--#include file="includes/list/incCustFieldList.asp" -->
<!--#include file="includes/list/incEmployeeRangeList.asp" -->
<!--#include file="includes/list/incLikeList.asp" -->
<!--#include file="includes/list/incStreetDirList.asp" -->
<!--#include file="includes/list/incStreetTypeList.asp" -->
<!--#include file="includes/list/incVacancyTargetPopList.asp" -->
<!--#include file="includes/list/incSharingProfileList.asp" -->
<!--#include file="includes/mapping/incGoogleMaps.asp" -->
<!--#include file="includes/publication/incGenHeadingList.asp" -->
<!--#include file="includes/publication/incPubList.asp" -->
<!--#include file="includes/search/incCommSrchCIC.asp" -->
<!--#include file="includes/search/incDateSearch.asp" -->
<!--#include file="includes/search/incAdvSearchPub.asp" -->
<!--#include file="includes/search/incSearchRecent.asp" -->
<!--#include file="includes/search/incChecklistSearchForm.asp" -->
<!--#include file="includes/search/incSharingProfileSearchForm.asp" -->
<!--#include file="includes/taxonomy/incTaxTermSearches.asp" -->
<%
Call makePageHeader(Nz(ps_strTitle,TXT_ORG_ADVANCED_SEARCH), Nz(ps_strTitle,TXT_ORG_ADVANCED_SEARCH), True, False, True, True)

Dim strStatsCanNAICSLink
Select Case g_objCurrentLang.Culture
	Case CULTURE_FRENCH_CANADIAN
		strStatsCanNAICSLink = "http://www.statcan.gc.ca/subjects-sujets/standard-norme/naics-scian/2002/naics-scian-02intro-fra.htm"
	Case Else
		strStatsCanNAICSLink = "http://www.statcan.gc.ca/subjects-sujets/standard-norme/naics-scian/2002/naics-scian-02intro-eng.htm"
End Select

Dim	bSrchCommunityDefault, _
	bASrchAddress, _
	bASrchAges, _
	bASrchBool, _
	bASrchEmail, _
	bASrchEmployee, _
	bASrchLastRequest, _
	bAsrchNear, _
	bASrchOwner, _
	bASrchVacancy, _
	bASrchVOL, _
	bCSrch

' Get Advanced Search View data
Dim cmdASrchViewData, rsASrchViewData
Set cmdASrchViewData = Server.CreateObject("ADODB.Command")
With cmdASrchViewData
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_View_s_ASrch"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
End With
Set rsASrchViewData = cmdASrchViewData.Execute

' CIC View data
With rsASrchViewData
	If Not .EOF Then
		bSrchCommunityDefault = .Fields("SrchCommunityDefault")
		bASrchAddress = .Fields("ASrchAddress")
		bASrchAges	= .Fields("ASrchAges")
		bASrchBool = .Fields("ASrchBool")
		bASrchEmail = .Fields("ASrchEmail")
		bASrchEmployee = .Fields("ASrchEmployee")
		bASrchLastRequest = .Fields("ASrchLastRequest")
		bASrchNear = .Fields("ASrchNear")
		bASrchOwner	= .Fields("ASrchOwner")
		bASrchVacancy = .Fields("ASrchVacancy")
		bASrchVOL = .Fields("ASrchVOL")
		bCSrch = .Fields("CSrch")
	End If
End With

'Look for Taxonomy data, if we are adding criteria to a Taxonomy search
Dim	strTMC, _
	strATMC, _
	bTMCRestricted, _
	strTermListDisplayAll, _
	strTermListDisplayAny

'"Match All" Terms list
strTMC = Request("TMC")
If Not Nl(strTMC) Then
	If Not IsLinkedTaxCodeList(strTMC) Then
		strTMC = Null
	Else
		strTermListDisplayAll = getTermListDisplay(strTMC,vbNullString,vbNullString)
	End If
End If

'"Match Any" Terms list
strATMC = Request("ATMC")
If Not Nl(strATMC) Then
	If Not IsLinkedTaxCodeList(strATMC) Then
		strATMC = Null
	Else
		strTermListDisplayAny = getTermListDisplay(strATMC,vbNullString,vbNullString)
	End If
End If

'Is the Taxonomy search restricted (exact code only)?
bTMCRestricted = Request("TMCR") = "on"

Call InitializeRecentSearch()
%>

<form action="results.asp" method="get" onsubmit="formNewWindow(this);" id="EntryForm" class="form-horizontal">
    <div style="display: none">
        <%=g_strCacheFormVals%>
    </div>
    <p>
        <input type="submit" value="<%=TXT_SEARCH%>" class="btn btn-default">
        <input type="RESET" value="<%=TXT_CLEAR_FORM%>" class="btn btn-default">
    </p>
    <div class="max-width-lg">
        <table class="BasicBorder cell-padding-4 form-table responsive-table max-width-lg clear-line-below">
<%
'If this is an add-on to a Taxonomy search, print the details of that search.
If Not Nl(strTermListDisplayAll & strTermListDisplayAny) Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_TAX_CRITERIA%></td>
                <td class="field-data-cell">
<%
	If Not Nl(strTermListDisplayAll) Then
%>
                    <div style="display: none">
                        <input type="hidden" name="TMC" value="<%=AttrQs(strTMC)%>">
                    </div>
                    <strong><%=TXT_MUST_MATCH_TERMS%></strong>
                    <%=strTermListDisplayAll%>
<%
	End If
	If Not Nl(strTermListDisplayAny) Then
%>
                    <div style="display: none">
                        <input type="hidden" name="ATMC" value="<%=AttrQs(strATMC)%>"></div>
                    <%=StringIf(Not Nl(strTermListDisplayAll),"<br>")%><strong><%=TXT_MATCH_ANY_TERMS%></strong><%=strTermListDisplayAny%>
<%
	End If
	If bTMCRestricted Then
%>
                    <div style="display: none">
                        <input type="hidden" name="TMCR" value="on">
                    </div>
                    <%=StringIf(Not (Nl(strTermListDisplayAll) And Nl(strTermListDisplayAny)),"<br>")%><strong><%=TXT_RESTRICT%></strong>
<%
	End If
%>
                </td>
            </tr>
<%
End If

If bRecentSearchFound Then
	If IsArray(aLastSearchSessionInfo) Then
		strLastSearchSessionInfo = _
            "<li class=""search-info-list"">" & _
            Join(aLastSearchSessionInfo,"</li><li class=""search-info-list"">") & _
            "</li>"
	Else
		strLastSearchSessionInfo = TXT_YOUR_PREVIOUS_SEARCH & " [" & strLastSearchSessionTime & "]"
	End If
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_REFINE_SEARCH%></td>
                <td class="field-data-cell">
                    <div style="display: none">
                        <input type="hidden" name="RS" value="<%=strRecentSearchKey%>">
                    </div>
                    <strong>Searched On:</strong> <%=strLastSearchSessionTime%>
                    <ul><%=strLastSearchSessionInfo%></ul>
                </td>
            </tr>
<%
End If
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_SEARCH_TERMS%></td>
                <td class="field-data-cell">
                    <div class="radio-inline">
                        <label for="SCon_A">
                            <input type="radio" name="SCon" id="SCon_A" value="A" checked>
                            <%=TXT_ALL_TERMS%>
                        </label>
                    </div>
                    <div class="radio-inline">
                        <label for="SCon_O">
                            <input type="radio" name="SCon" id="SCon_O" value="O">
                            <%=TXT_ANY_TERMS%>
                        </label>
                    </div>
<%
If bASrchBool Then
%>
                    <div class="radio-inline">
                        <label for="SCon_B">
                            <input type="radio" name="SCon" id="SCon_B" value="B">
                            <%=TXT_BOOLEAN%>
                        </label>
                    </div>
<%
End If
%>
                    <input type="text" name="STerms" id="STerms" title="<%=AttrQs(TXT_SEARCH_TERMS)%>" class="form-control ui-autocomplete-input">

                    <div class="radio-inline">
                        <label for="SType_A" class="no-wrap">
                            <input type="radio" name="SType" id="SType_A" value="A" checked>
                            <%=TXT_WORDS_ANYWHERE%>
                        </label>
                    </div>
                    <div class="radio-inline">
                        <label for="SType_O" class="no-wrap">
                            <input type="radio" name="SType" id="SType_O" value="O">
                            <%=TXT_ORG_NAMES%>
                        </label>
                    </div>
<%
If g_bUseThesaurusView Then
%>
                    <div class="radio-inline">
                        <label for="SType_S" class="no-wrap">
                            <input type="radio" name="SType" id="SType_S" value="S">
                            <%=TXT_SUBJECTS%>
                        </label>
                    </div>
<%
End If
If g_bUseTaxonomyView Then
%>
                    <div class="radio-inline">
                        <label for="SType_T" class="no-wrap">
                            <input type="radio" name="SType" id="SType_T" value="T">
                            <%=TXT_SERVICE_CATEGORIES%>
                        </label>
                    </div>
<%
End If
If g_bUseCIC And g_bUseThesaurusView Then
%>
                    <div class="checkbox">
                        <label for="HideSubj">
                            <input name="HideSubj" id="HideSubj" type="checkbox" checked>
                            <%=TXT_HIDE_SUBJECT_SIDEBAR%>
                        </label>
                    </div>
<%
End If
%>
                </td>
            </tr>
            <tr>
                <td class="field-label-cell-widelabel">
                    <label for="NUM"><%=TXT_RECORD_NUM%></label></td>
                <td class="field-data-cell">
                    <textarea name="NUM" id="NUM" rows="<%=TEXTAREA_ROWS_SHORT%>" class="form-control"></textarea>
                    <div class="SmallNote"><%=TXT_INST_RECORD_NUM%></div>
                </td>
            </tr>
<%
Dim strCommTable, bEmptyCommTable
strCommTable = makeCommSrchTable(bEmptyCommTable)

If Not bEmptyCommTable Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_COMMUNITIES%></td>
                <td class="field-data-cell"><%=strCommTable%></td>
            </tr>
<%
End If
If g_bUseNAICSView Then
%>
            <tr>
                <td class="field-label-cell-widelabel">
                    <label for="NAICS"><%=TXT_NAICS_SHORT%></label></td>
                <td class="field-data-cell">
                    <div class="form-inline">
                        <input type="text" size="6" maxlength="6" name="NAICS" id="NAICS" class="form-control">
                    </div>
                    [ <a href="javascript:openWin('<%=makeLinkB("naicsfind.asp")%>','sFind')"><%=TXT_NAICS_FINDER%></a> | <a href="<%=strStatsCanNAICSLink%>" target="_blank"><%=TXT_ABOUT_NAICS%></a>]
                </td>
            </tr>
<%
End If

If bASrchAddress Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_STREET_ADDRESS%></td>
                <td class="field-data-cell">
                    <div class="row form-group">
                        <label for="StreetName" class="control-label col-sm-3"><%=TXT_STREET_NAME%></label>
                        <div class="col-sm-9">
                            <input type="text" size="25" maxlength="100" name="StreetName" id="StreetName" class="form-control">
                        </div>
                    </div>
<%
	Call openStreetTypeListRst(True)
%>
                    <div class="row form-group">
                        <label for="StreetType" class="control-label col-sm-3"><%=TXT_STREET_TYPE%></label>
                        <div class="col-sm-6">
                            <%=makeStreetTypeListD("StreetType")%>
                        </div>
                        <div class="col-sm-3">
                            <%=TXT_OPTIONAL%>
                        </div>
                    </div>
<%
	Call closeStreetTypeListRst()
	Call openStreetDirListRst()
%>
                    <div class="row form-group">
                        <label for="StreetType" class="control-label col-sm-3"><%=TXT_STREET_DIR%></label>
                        <div class="col-sm-6">
                            <%=makeStreetDirList(vbNullString,"StreetDir",True)%>
                        </div>
                        <div class="col-sm-3">
                            <%=TXT_OPTIONAL%>
                        </div>
                    </div>
<%
	Call closeStreetDirListRst()
%>
                </td>
            </tr>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_POSTAL_CODE%></td>
                <td class="field-data-cell">
                    <div class="row form-group">
                        <label for="PostalCode" class="control-label col-sm-3"><%=TXT_BEGINS_WITH%></label>
                        <div class="col-sm-6">
                            <input type="text" size="7" maxlength="7" name="PostalCode" id="PostalCode" class="form-control">
                        </div>
                        <div class="col-sm-3">
                            (<%=TXT_POSTAL_CODE_EXAMPLE%>)
                        </div>
                    </div>
                </td>
            </tr>
<%
End If

If bASrchNear Then
%>
            <!--#include file="includes/mapping/incMapSearchForm.asp" -->
<%
	Call printMapSearchForm(False)
End If

If bASrchAges Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_AGES%></td>
                <td class="field-data-cell">
                    <div class="form-inline form-inline-always">
                        <%=TXT_SERVING_AGE%>
                        <input type="text" name="Age1" title="<%=AttrQs(TXT_MIN_AGE)%>" size="3" maxlength="3" class="form-control">
                        -
                        <input type="text" name="Age2" title="<%=AttrQs(TXT_MAX_AGE)%>" size="3" maxlength="3" class="form-control">
                        (<%=TXT_IN_YEARS%>)
                    </div>
                    <div class="radio-inline">
                        <label for="AgeType_O">
                            <input type="radio" name="AgeType" id="AgeType_O" value="" checked><%=TXT_ANY_IN_RANGE%></label>
                    </div>
                    <div class="radio-inline">
                        <label for="AgeType_A">
                            <input type="radio" name="AgeType" id="AgeType_A" value="A"><%=TXT_ALL_IN_RANGE%></label>
                    </div>
                    <br>
                    <span class="SmallNote"><%=TXT_AGE_INSTRUCTIONS%></span></td>
            </tr>
<%
End If

If bASrchVacancy Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_VACANCY%></td>
                <td class="field-data-cell"><span class="SmallNote"><%=TXT_NO_SELECTION_SEARCH_ALL%></span>
<%
	Call openVacancyTargetPopListRst(False,Null)
%>
                    <p>
                        <label for="VacancyTP" class="control-label"><%=TXT_HAS_CAPACITY_FOR%></label>
                        <%=makeVacancyTargetPopList(vbNullString, "VacancyTP", True, vbNullString)%>
                    </p>
<%
	Call closeVacancyTargetPopListRst()
%>
                    <hr>
                    <p>
                        <label for="Vacancy_N">
                            <input type="radio" name="Vacancy" id="Vacancy_N" value="" checked>&nbsp;<%=TXT_NO_SEARCH_VACANCY%></label>
                        <br>
                        <label for="Vacancy_Y">
                            <input type="radio" name="Vacancy" id="Vacancy_Y" value="Y">&nbsp;<%=TXT_HAS_VACANCIES%></label>
                        <br>
                        <label for="Vacancy_W">
                            <input type="radio" name="Vacancy" id="Vacancy_W" value="W">&nbsp;<%=TXT_HAS_VACANCIES_OR_WAITLIST%></label>
                    </p>
                </td>
            </tr>
<%
End If

If bASrchEmployee Then
	Call openEmployeeRangeListRst()
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_NUMBER_EMPLOYEES%></td>
                <td class="field-data-cell"><span class="SmallNote"><%=TXT_WARNING_EMPLOYEES%></span>
                    <div class="form-group row">
                        <label for="ERID" class="control-label col-sm-4"><%=TXT_NUMBER_EMPLOYEES_RANGE%></label>
                        <div class="col-sm-8">
                            <%=makeEmployeeRangeList(vbNullString,"ERID",True)%>
                        </div>
                    </div>
                    <p><strong><%=TXT_OR%></strong></p>
                    <div class="form-inline">
                        <div class="input-group">
                            <div class="input-group-addon">
                                <label for="NumEmpMin"><%=TXT_AT_LEAST%></label>
                            </div>
                            <input type="text" name="NumEmpMin" id="NumEmpMin" size="4" maxlength="4" class="form-control">
                            <div class="input-group-addon">
                                <label for="NumEmpMax"><%=TXT_NO_MORE_THAN%></label>
                            </div>
                            <input type="text" name="NumEmpMax" id="NumEmpMax" size="4" maxlength="4" class="form-control">
                        </div>
                    </div>
                    <br>
                    <label for="NumEmpType_T">
                        <input type="radio" name="NumEmpType" id="NumEmpType_T" value="" checked>&nbsp;<%=TXT_TOTAL_EMPLOYEES%></label>
                    <label for="NumEmpType_F">
                        <input type="radio" name="NumEmpType" id="NumEmpType_F" value="F">&nbsp;<%=TXT_FULL_TIME%></label>
                    <label for="NumEmpType_P">
                        <input type="radio" name="NumEmpType" id="NumEmpType_P" value="P">&nbsp;<%=TXT_PART_TIME_SEASONAL%></label>
                </td>
            </tr>
<%
	Call closeEmployeeRangeListRst()
End If

If bASrchLastRequest Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_LAST_EMAIL_UPDATE%></td>
                <td class="field-data-cell">
                    <div class="form-inline">
                        <div class="input-group">
                            <div class="input-group-addon">
                                 <%=TXT_MORE_THAN%>
                            </div>
                            <input type="text" name="LastEmail" title="<%=AttrQs(TXT_DAYS_SINCE_EMAIL_REQUESTING_UPDATE)%>" id="LastEmail" size="4" maxlength="3" class="form-control">
                            <div class="input-group-addon">
                                <%=TXT_DAYS%>
                            </div>
                        </div>
                    </div>
                </td>
            </tr>
<%
End If

Call openCustFieldRst(DM_CIC, g_intViewTypeCIC, True,True)
Call makeDateSearchRow(1)
Call makeDateSearchRow(2)
Call closeCustFieldRst()
Call openCustFieldRst(DM_CIC, g_intViewTypeCIC, True,False)
Call makeCustomFieldSearchRow(1)
Call makeCustomFieldSearchRow(2)
Call closeCustFieldRst()

Dim strOrgName

If bASrchOwner Then
	Call openAgencyListRst(DM_CIC, True, True)
	With rsListAgency
		If Not .EOF Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_RECORD_OWNER%></td>
                <td class="field-data-cell"><span class="SmallNote"><%=TXT_HOLD_CTRL%></span>
                    <br>
                    <select name="RO" id="RO" class="form-control" multiple>
<%
			While Not .EOF
				strOrgName = IIf(Nl(.Fields("ORG_NAME_FULL")),vbNullString," - " & Server.HTMLEncode(.Fields("ORG_NAME_FULL")))
				If Len(strOrgName) > 80 Then
					strOrgName = Left(strOrgName,80) & " ..."
				End If
                        %><option value="<%=.Fields("AgencyCode")%>"><%=.Fields("AgencyCode") & strOrgName%></option>
<%
				.MoveNext
			Wend
%>
                    </select></td>
            </tr>
<%
		End If
	End With
	Call closeAgencyListRst()
End If

If g_bUseVOL And g_bVolunteerLink And bASrchVOL Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_VOLUNTEER_OPPS%></td>
                <td class="field-data-cell">
                    <label for="VolType">
                        <input type="radio" name="VolType" id="VolType" value="" checked><%=TXT_NO_SEARCH_OPPS%></label>
                    <br>
                    <label for="VolType_A">
                        <input type="radio" name="VolType" id="VolType_A" value="A"><%=TXT_HAS_ANY_OPPS%></label>
                    <br>
                    <label for="VolType_V">
                        <input type="radio" name="VolType" id="VolType_V" value="V"><%=TXT_HAS_ANY_OPPS%> <strong><%=TXT_IN_THIS_VIEW%></strong></label>
                    <br>
                    <label for="VolType_C">
                        <input type="radio" name="VolType" id="VolType_C" value="C"><%=TXT_HAS_CURRENT_OPPS%> <strong><%=TXT_IN_THIS_VIEW%></strong></label>
                    <br>
                    <label for="VolType_P">
                        <input type="radio" name="VolType" id="VolType_P" value="P"><%=TXT_HAS_PUBLIC_OPPS%> <strong><%=TXT_IN_THIS_VIEW%></strong></label>
                    <br>
                    <label for="VolType_N">
                        <input type="radio" name="VolType" id="VolType_N" value="N"><%=TXT_HAS_NO_OPPS%></label>
                    <br>
                    <label for="VolType_E">
                        <input type="radio" name="VolType" id="VolType_E" value="E"><%=TXT_HAS_ONLY_EXPIRED_OPPS%></label></td>
            </tr>
<%
End If

If Not g_bLimitedView Then
	Call getPublicationOptionList()
	If bHavePublications Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_PUBLICATIONS%></td>
                <td class="field-data-cell">
                    <%Call makePublicationUI()%>
                </td>
            </tr>
<%
	End If
Else
	Call getGeneralHeadingOptionList(g_intPBID)
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_HEADINGS%></td>
                <td class="field-data-cell">
                    <%Call makeGeneralHeadingUI()%>
                </td>
            </tr>
<%
End If

Call makeSharingProfileAdvSearchForm()

If bASrchEmail Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_EMAIL%></td>
                <td class="field-data-cell">
                    <label for="HasEmail_A">
                        <input type="radio" name="HasEmail" id="HasEmail_A" value="" checked>&nbsp;<%=TXT_ALL_RECORDS%></label>
                    <br>
                    <label for="HasEmail_E">
                        <input type="radio" name="HasEmail" id="HasEmail_E" value="E">&nbsp;<%=TXT_ONLY_EMAIL%></label>
                    <label for="HasEmail_NE">
                        <input type="radio" name="HasEmail" id="HasEmail_NE" value="NE">&nbsp;<%=TXT_ONLY_NO_EMAIL%></label>
                    <br>
                    <label for="HasEmail_U">
                        <input type="radio" name="HasEmail" id="HasEmail_U" value="U">&nbsp;<%=TXT_CAN_UPDATE_EMAIL%></label>
                    <label for="HasEmail_NU">
                        <input type="radio" name="HasEmail" id="HasEmail_NU" value="NU">&nbsp;<%=TXT_CANNOT_UPDATE_EMAIL%></label></td>
            </tr>
<%
End If

If g_bCanSeeNonPublicCIC Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_PUBLIC_STATUS%></td>
                <td class="field-data-cell">
                    <label for="PublicStatus_A">
                        <input type="radio" name="PublicStatus" id="PublicStatus_A" value="" checked>&nbsp;<%=TXT_ALL_RECORDS%></label>
                    <label for="PublicStatus_P">
                        <input type="radio" name="PublicStatus" id="PublicStatus_P" value="P">&nbsp;<%=TXT_ONLY_PUBLIC%></label>
                    <label for="PublicStatus_N">
                        <input type="radio" name="PublicStatus" id="PublicStatus_N" value="N">&nbsp;<%=TXT_ONLY_NONPUBLIC%></label></td>
            </tr>
<%
End If

If g_bMultiLingual Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_LANGUAGE%></td>
                <td class="field-data-cell">
                    <label for="EqStat_A">
                        <input type="radio" name="EqStat" id="EqStat_A" value="" checked>&nbsp;<%=TXT_ALL_RECORDS%></label>
                    <label for="EqStat_E">
                        <input type="radio" name="EqStat" id="EqStat_E" value="E">&nbsp;<%=TXT_HAS_EQUIVALENT%></label>
                    <label for="EqStat_N">
                        <input type="radio" name="EqStat" id="EqStat_N" value="N">&nbsp;<%=TXT_HAS_NO_EQUIVALENT%></label></td>
            </tr>
<%
End If

If bCSrch Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_CHILD_CARE_RESOURCE%></td>
                <td class="field-data-cell">
                    <label for="CCRStat_A">
                        <input type="radio" name="CCRStat" id="CCRStat_A" value="" checked>&nbsp;<%=TXT_ALL_RECORDS%></label>
                    <label for="CCRStat_R">
                        <input type="radio" name="CCRStat" id="CCRStat_R" value="R">&nbsp;<%=TXT_ONLY_CHILD_CARE_RESOURCES%></label>
                    <label for="CCRStat_N">
                        <input type="radio" name="CCRStat" id="CCRStat_N" value="N">&nbsp;<%=TXT_EXCLUDE_CHILD_CARE_RESOURCES%></label></td>
            </tr>
<%
End If

If g_bCanSeeDeletedCIC Then
%>
            <tr>
                <td class="field-label-cell-widelabel"><%=TXT_DELETED_STATUS%></td>
                <td class="field-data-cell">
                    <label for="incDel">
                        <input name="incDel" id="incDel" type="checkbox">
                        <%=TXT_INCLUDE_DELETED%></label></td>
            </tr>
<%
End If

If user_bCanAddSQLCIC Then
%>
            <tr>
                <td class="field-label-cell-widelabel">
                    <label for="Limit"><%=TXT_SQL%></label></td>
                <td class="field-data-cell"><a href="javascript:openWinXL('<%=makeLinkB("sql_help.asp")%>','sqlHelp')"><%=TXT_SQL_HELP%></a>
                    <br>
                    <textarea name="Limit" id="Limit" rows="<%=TEXTAREA_ROWS_LONG%>" class="form-control"></textarea></td>
            </tr>
<%
End If

Dim bHaveAChecklist

Set rsASrchViewData = rsASrchViewData.NextRecordset

With rsASrchViewData
	If Not .EOF Then
		bHaveAChecklist = True
%>
            <tr>
                <td class="field-label-cell-widelabel">
                    <label for="CheckListSource"><%=TXT_CHECKLISTS%></label></td>
                <td class="field-data-cell">
                    <div id="CheckListSourceContainer">
                        <div class="input-group">
                           <select id="CheckListSource" class="form-control">
<%
		While Not .EOF
%>
                               <option value="<%=.Fields("ChecklistSearch")%>" id="Chk<%=.Fields("ChecklistSearch")%>"><%=.Fields("FieldDisplay")%></option>
<%
			.MoveNext
		Wend
%>
                            </select>
                            <div class="input-group-btn">
                                <input class="btn btn-default" type="button" id="AddChecklistCriteria" value="<%=TXT_ADD%>">
                            </div>
                        </div>
                    </div>
                </td>
            </tr>
<%
	End If
End With

rsASrchViewData.Close
Set rsASrchViewData = Nothing
%>
        </table>
    </div>
<%
Dim bSearchDisplay, _
	bNewWindow
bSearchDisplay = getSessionValue("SearchDisplayCIC") = "on"
bNewWindow = getSessionValue("NewWindowCIC") = "on"
%>
    <p>
        <label for="NewWindow">
            <input type="checkbox" name="NewWindow" id="NewWindow" <%=Checked(bNewWindow)%>>
            <%=TXT_SEARCH_RESULTS_NEW_WINDOW%>
        </label>
        <br>
        <label for="SearchDisplay">
            <input type="checkbox" name="SearchDisplay" id="SearchDisplay" <%=Checked(bSearchDisplay)%>>
            <%=TXT_DISPLAY_SEARCH_DETAILS%>
        </label>
    </p>

    <input type="submit" value="<%=TXT_SEARCH%>" class="btn btn-default">
    <input type="RESET" id="ResetForm" value="<%=TXT_CLEAR_FORM%>" class="btn btn-default">
</form>

<form class="NotVisible" name="stateForm" id="stateForm">
    <textarea id="cache_form_values"></textarea>
</form>

<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/advsrch.js") %>

<%
g_bListScriptLoaded = True
If (Not g_bLimitedView And bHavePublications) Or bHaveAChecklist Or Not bEmptyCommTable Then
%>
<script type="text/javascript">
    jQuery(function ($) {
        init_cached_state()
<%
    If(Not g_bLimitedView And bHavePublications) Then
%>
        init_pubs_dropdown('<%=makeLinkB(ps_strPathToStart & "jsonfeeds/heading_searchform.asp")%>');
<%
    End If
    If bHaveAChecklist Then
%>
        init_checklist_search('<%=makeLinkB(ps_strPathToStart & "jsonfeeds/checklist_searchform.asp")%>');
<%
    End If
%>
        init_pre_fill_search_parameters('<%=makeLinkB(ps_strPathToStart & "jsonfeeds/checklist_searchform.asp")%>', '#OComm', '#OCommID');
<%
    If Not bEmptyCommTable Then
%>
        init_community_autocomplete($, 'OComm', "<%= makeLinkB("~/jsonfeeds/community_generator.asp")%>", 3, '#OCommID');
<%
    End If
%>
        init_find_box({
            A: "<%= makeLink(ps_strPathToStart & "jsonfeeds/cic_keyword_generator.asp", "SearchType=A", vbNullString) %>",
            O: "<%= makeLink(ps_strPathToStart & "jsonfeeds/cic_keyword_generator.asp", "SearchType=O", vbNullString) %>",
            S: "<%= makeLink(ps_strPathToStart & "jsonfeeds/cic_keyword_generator.asp", "SearchType=S", vbNullString) %>",
            T: "<%= makeLink(ps_strPathToStart & "jsonfeeds/cic_keyword_generator.asp", "SearchType=T", vbNullString) %>"
		}, $('#EntryForm'));
        restore_cached_state();
    })
</script>
<%
End If

If bASrchNear Then
%>
<!--#include file="includes/mapping/incMapSearchFormScript.asp" -->
<%
End If
Call setSessionValue("session_test", "ok")

Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
