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
Call setPageInfo(False, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtBrowse.asp" -->
<!--#include file="text/txtClientTracker.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtRecordPages.asp" -->
<!--#include file="text/txtSearchBasic.asp" -->
<!--#include file="text/txtSearchResults.asp" -->
<!--#include file="includes/core/incFieldDataClass.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/core/incOrderByConst.asp" -->
<!--#include file="includes/display/incCICDisplayOptionsFields.asp" -->
<!--#include file="includes/list/incAlphaList.asp" -->
<!--#include file="includes/list/incMappingCategoryList.asp" -->
<!--#include file="includes/mapping/incGoogleMaps.asp" -->
<!--#include file="includes/mapping/incMapSearchResults.asp" -->
<!--#include file="includes/search/incMakeTableClassCIC.asp" -->
<!--#include file="includes/search/incMyList.asp" -->
<!--#include file="includes/search/incSearchRecent.asp" -->

<%
Public Sub printSearchInfo()

End Sub

Call getDisplayOptionsCIC(g_intViewTypeCIC, Not user_bCIC)

Dim strTitle
strTitle = Nz(get_view_data_cic("BrowseByOrg"), Nz(ps_strTitle,TXT_BROWSE_BY_ORG_TITLE))
Call makePageHeader(strTitle, strTitle, True, True, True, True)


Dim strChosenLetter, strLettersList
strChosenLetter = Trim(Request("Let"))

If Not reEquals(strChosenLetter,"([A-Z])|(0\-9)",True,False,True,False) Then
	strChosenLetter = vbNullString
End If

If Not g_bPrintMode Then
	Response.Write(render_gtranslate_ui())
	strLettersList = makeAlphaList(strChosenLetter, True, ps_strThisPage, False)
	Response.Write(strLettersList)
End If
%>
<%'If a Letter has been selected
If Not Nl(strChosenLetter) Then
	Dim strFrom, _
		strWhere
	
	Dim objOrgTable
	Set objOrgTable = New OrgRecordTable

	strFrom = "GBL_BaseTable bt" & vbCrLf & _
		"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbcrLf & _
		"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbcrLf & _
		"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
		"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=" & g_objCurrentLang.LangID

	strSearchInfoRefineNotes = Nz(get_view_data_cic("BrowseByOrg"), TXT_BROWSE_BY_ORG) & TXT_COLON & strChosenLetter

	If strChosenLetter < "A" Then
		strWhere = "(((btd.SORT_AS_USELETTER IS NULL OR NOT btd.SORT_AS_USELETTER=1) AND btd.ORG_LEVEL_1 < 'A') OR ((btd.SORT_AS_USELETTER IS NULL OR NOT btd.SORT_AS_USELETTER=0) AND btd.SORT_AS < 'A'))"
	Else
		strWhere = "(((btd.SORT_AS_USELETTER IS NULL OR NOT btd.SORT_AS_USELETTER=1) AND btd.ORG_LEVEL_1 LIKE '" & strChosenLetter & "%') OR ((btd.SORT_AS_USELETTER IS NULL OR NOT btd.SORT_AS_USELETTER=0) AND btd.SORT_AS LIKE '" & strChosenLetter & "%'))"
	End If

	Call objOrgTable.setOptions(strFrom, strWhere, vbNullString, False, False, vbNullString, CAN_RANK_NONE, vbNullString, vbNullString, False)

	Call objOrgTable.makeTable()

	Set objOrgTable = Nothing

End If
%>

<%
Call makeMappingSearchFooter()
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
