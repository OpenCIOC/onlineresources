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
<!--#include file="../text/txtReferral.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
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

If Not user_bCanManageReferrals Then
	Call securityFailure()
End If

Call makePageHeader(TXT_VOLUNTEER_REFERRAL_STATISTICS, TXT_VOLUNTEER_REFERRAL_STATISTICS, True, False, True, True)

If Not g_bPrintMode Then
%>
<p>[ <a href="<%=makeLinkB("referral_stats.asp")%>"><%= TXT_RETURN_TO_STATISTICS_SEARCH %></a> ]</p>
<h3><%= TXT_REFERRAL_STATS_REPORT %></h3>
<%
End If

Dim bError
bError = False

Dim strAgency, _
	strStartDate, _
	strEndDate, _
	strOrgKeywords, _
	intThreshold, _
	bPlacement
	
bPlacement = Request("Placement") = "on"

intThreshold = Trim(Request("AtLeast"))
If Nl(intThreshold) Then
	intThreshold = Null
ElseIf Not IsNumeric(intThreshold) Then
	bError = True
	Call handleError(TXT_THRESHOLD & TXT_MUST_BE_A_NUMBER, _
		vbNullString, vbNullString)
End If

strAgency = Null
If Not Nl(Request("RecordOwner")) Then strAgency = Request("RecordOwner")

strOrgKeywords = keywordSearchString(Request("STerms"))

strStartDate = Null
If Not Nl(Request("StartDate")) Then
	If IsSmallDate(Request("StartDate")) Then
		strStartDate = DateValue(Request("StartDate"))
	Else
		bError = True
		Call handleError(Request("StartDate") & TXT_INVALID_DATE_FORMAT & DateString(MIN_SMALL_DATE,True) & TXT_AND_LC & DateString(MAX_SMALL_DATE,True), _
			vbNullString, vbNullString)
	End If
End If

strEndDate = Null
If Not Nl(Request("EndDate")) Then
	If IsSmallDate(Request("EndDate")) Then
		strEndDate = DateValue(Request("EndDate"))
	Else
		bError = True
		Call handleError(Request("EndDate") & TXT_INVALID_DATE_FORMAT & DateString(MIN_SMALL_DATE,True) & TXT_AND_LC & DateString(MAX_SMALL_DATE,True), _
			vbNullString, vbNullString)
	End If
End If

If Not bError Then

Dim cmdStat1, rsStat1
Set cmdStat1 = Server.CreateObject("ADODB.Command")
With cmdStat1
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandText = "dbo.sp_VOL_OP_Referral_Stats"
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@RecordOwner", adChar, adParamInput, 3, strAgency)
	.Parameters.Append .CreateParameter("@StartDate", adDBDate, adParamInput, 4, strStartDate)
	.Parameters.Append .CreateParameter("@EndDate", adDBDate, adParamInput, 4, strEndDate)
	.Parameters.Append .CreateParameter("@OrgKeywords", adVarWChar, adParamInput, 1000, strOrgKeywords)
	.Parameters.Append .CreateParameter("@CountThreshold", adInteger, adParamInput, 4, intThreshold)
	.CommandTimeout = 0
	Set rsStat1 = .Execute
End With

Dim intStatTotal, _
	intOrgTotal, _
	intStatPTotal, _
	intOrgPTotal, _
	intPrevNUM
	
	intStatTotal = 0
	intOrgTotal = 0
	intStatPTotal = 0
	intOrgPTotal = 0
	intPrevNUM = vbNullString
	
Dim fldVNUM, _
	fldNUM, _
	fldOrgName, _
	fldPositionTitle, _
	fldReferralCount, _
	fldPlacementCount

With rsStat1
	If Not .EOF Then
		Set fldVNUM = .Fields("VNUM")
		Set fldNUM = .Fields("NUM")
		Set fldOrgName = .Fields("ORG_NAME_FULL")
		Set fldPositionTitle = .Fields("POSITION_TITLE")
		Set fldReferralCount = .Fields("ReferralCount")
		Set fldPlacementCount = .FieldS("PlacementCount")
%>
<table class="BasicBorder cell-padding-2">
<%
		While Not .EOF
			If fldNUM.Value <> intPrevNUM Then
				If Not Nl(intPrevNUM) Then
%>
<tr>
	<td colspan="2" class="FieldLabel"><%=TXT_TOTAL%></td>
	<td><%=intOrgTotal%></td>
<%If bPlacement Then%>
	<td><%=intOrgPTotal%></td>
<%End If%>
</tr>
<%
					intOrgTotal = 0
					intOrgPTotal = 0
				End If
%>
<tr class="RevTitleBox"><th colspan="<%=IIf(bPlacement,4,3)%>"><%=fldOrgName.Value%></th></tr>
<tr>
	<th class="FieldLabelLeft"><%=TXT_RECORD_NUM%></th>
	<th class="FieldLabelLeft"><%=TXT_POSITION_TITLE%></th>
	<th class="FieldLabelLeft"><%= TXT_REFERRAL_COUNT %></th>
<%If bPlacement Then%>
	<th class="FieldLabelLeft"><%= TXT_PLACEMENTS %></th>
<%End If%>
</tr>
<%
				intPrevNUM = fldNUM.Value
			End If
%>
<tr>
	<td><%=fldVNUM.Value%></td>
	<td><%=fldPositionTitle.Value%></td>
	<td><%=fldReferralCount.Value%></td>
<%If bPlacement Then%>
	<td><%=fldPlacementCount.Value%></td>
<%End If%>
</tr>
<%
			intStatTotal = intStatTotal + Nz(fldReferralCount.Value,0)
			intOrgTotal = intOrgTotal + Nz(fldReferralCount.Value,0)
			intStatPTotal = intStatPTotal + Nz(fldPlacementCount.Value,0)
			intOrgPTotal = intOrgPTotal + Nz(fldPlacementCount.Value,0)
			.MoveNext
		Wend
%>
<tr>
	<td colspan="2" class="FieldLabel"><%=TXT_TOTAL%></td>
	<td><%=intOrgTotal%></td>
<%If bPlacement Then%>
	<td><%=intOrgPTotal%></td>
<%End If%>
</tr>
<tr class="RevTitleBox"><td colspan="<%=IIf(bPlacement,4,3)%>"><hr></td></tr>
<tr>
	<td colspan="2" class="FieldLabel"><%= TXT_GRAND_TOTAL %></td>
	<td><%=intStatTotal%></td>
<%If bPlacement Then%>
	<td><%=intStatPTotal%></td>
<%End If%>
</tr>
</table>
<%
	Else
%>
<p><%=TXT_NO_MATCHES%></p>
<%
	End If
End With

End If
%>
<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
