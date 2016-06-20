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
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtReferral.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/search/incVolReferralSearch.asp" -->
<!--#include file="../includes/referral/incYesVolOpInfo.asp" -->
<%
Call volReferralSearchHeader()

Dim bError
bError = False

Dim strVNUM
strVNUM = Request("VNUM")

If Nl(strVNUM) Then
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
ElseIf Not IsVNUMType(strVNUM) Then
	Call handleError(TXT_INVALID_OPID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
Else
	Call setOpInfo()
	If Nl(strPosition) Then
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
	Else
	
	Dim cmdListReferrals

	Set cmdListReferrals = Server.CreateObject("ADODB.Command")
	With cmdListReferrals
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_VOL_OP_Referral_ls"
		.CommandType = adCmdStoredProc
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
		.CommandTimeout = 0
	End With

	With rsListReferrals
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListReferrals
	End With

	Dim strPageTitle
	strPageTitle = TXT_PAST_REFERRALS_FOR_POSITION & " <br><a href=""" & makeVOLDetailsLink(strVNUM, IIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber,vbNullString),vbNullString) & """>" & strPosition & " <em>(" & strOrgName & ")</em></a>"

	Call volReferralSearchPageTitle(strPageTitle, vbNullString)

	Call volReferralSearchUpdateFollowUpFlags()

	Call volReferralSearchResults(False, False, True)

	Set cmdListReferrals = Nothing

	End If
End If
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
