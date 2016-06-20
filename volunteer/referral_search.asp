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
Call setPageInfo(True, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtFormDataCheck.asp" -->
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtReferral.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="../includes/search/incVolReferralSearch.asp" -->
<%
Function keywordSearchString(strKeywords)
	Dim strK
	strK = Left(Trim(strKeywords),750)
	If Not Nl(strK) Then
		Dim singleSTerms(), _
			quotedSTerms(), _
			exactSTerms(), _
			displaySTerms()

		Call makeSearchString( _
			strK, _
			singleSTerms, _
			quotedSTerms, _
			exactSTerms, _
			displaySTerms, _
			False _
		)
		strK = vbNullString
		
		If UBound(singleSTerms) > -1 Then
			strK = strK & Join(singleSTerms,AND_CON)
		End If
		If UBound(quotedSTerms) > -1 Then
			If UBound(singleSTerms) > -1 Then
				strK = strK & AND_CON
			End If
			strK = strK & Join(quotedSTerms,AND_CON)
		End If
	End If
	keywordSearchString = strK
End Function

Function dateSearchVal(strInDate, bErr)
	Dim strDate 
	strDate = Null
	If Not Nl(strInDate) Then
		If IsSmallDate(strInDate) Then
			strDate = DateValue(strInDate)
		Else
			bErr = True
			Call handleError(strInDate & TXT_INVALID_DATE_FORMAT & DateString(MIN_SMALL_DATE,True) & TXT_AND_LC & DateString(MAX_SMALL_DATE,True), _
				vbNullString, vbNullString)
		End If
	End If
	dateSearchVal = strDate
End Function

Call volReferralSearchHeader()
Call volReferralSearchPageTitle(TXT_REFERRAL_SEARCH_RESULTS, vbNullString)

Dim bError
bError = False

Dim strAgency, _
	strRefStartDate, _
	strRefEndDate, _
	strModStartDate, _
	strModEndDate, _
	strOrgKeywords, _
	strPosKeywords, _
	strVolunteerName, _
	bFollowup
	
strAgency = Null
If Not Nl(Request("RecordOwner")) Then strAgency = Request("RecordOwner") End If

strOrgKeywords = keywordSearchString(Request("STerms"))
strPosKeywords = keywordSearchString(Request("PTitle"))

strVolunteerName = Left(Trim(Request("VolunteerName")), 100)

strRefStartDate = dateSearchVal(Request("RefStartDate"), bError)
strRefEndDate = dateSearchVal(Request("RefEndDate"), bError)

strModStartDate = dateSearchVal(Request("ModStartDate"), bError)
strModEndDate = dateSearchVal(Request("ModEndDate"), bError)

bFollowup = UCase(Trim(Request("HasFollowUp")))
If Nl(bFollowup) Then
	bFollowup = Null
ElseIf bFollowup = "N" Then
	bFollowup = 0
ElseIf bFollowup = "R" Then
	bFollowup = 1
Else
	bFollowup = Null
End If


If Not bError Then

Dim cmdListReferrals

Set cmdListReferrals = Server.CreateObject("ADODB.Command")
With cmdListReferrals
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_VOL_OP_Referral_Search"
	.CommandType = adCmdStoredProc
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@RecordOwner", adChar, adParamInput, 3, strAgency)
	.Parameters.Append .CreateParameter("@RefStartDate", adDBDate, adParamInput, 4, strRefStartDate)
	.Parameters.Append .CreateParameter("@RefEndDate", adDBDate, adParamInput, 4, strRefEndDate)
	.Parameters.Append .CreateParameter("@ModStartDate", adDBDate, adParamInput, 4, strModStartDate)
	.Parameters.Append .CreateParameter("@ModEndDate", adDBDate, adParamInput, 4, strModEndDate)
	.Parameters.Append .CreateParameter("@OrgKeywords", adVarWChar, adParamInput, 1000, Nz(strOrgKeywords,Null))
	.Parameters.Append .CreateParameter("@PosKeywords", adVarWChar, adParamInput, 1000, Nz(strPosKeywords,Null))
	.Parameters.Append .CreateParameter("@VolunteerName", adVarWChar, adParamInput, 100, strVolunteerName)
	.Parameters.Append .CreateParameter("@FollowUp", adBoolean, adParamInput, 1, bFollowup)
	.CommandTimeout = 0
End With

With rsListReferrals
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdListReferrals
End With

Call volReferralSearchUpdateFollowUpFlags()

Call volReferralSearchResults(True, True, False)

Set cmdListReferrals = Nothing

Else
%>
<p><%=TXT_NO_MATCHES%></p>
<%

End If
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
