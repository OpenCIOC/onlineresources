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
<%
Call volReferralSearchHeader()
Call volReferralSearchPageTitle(TXT_REFERRALS_REQUIRING_FOLLOWUP, vbNullString)
Call volReferralSearchUpdateFollowUpFlags()

Dim cmdListReferrals

Set cmdListReferrals = Server.CreateObject("ADODB.Command")
With cmdListReferrals
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_VOL_OP_Referral_ls_FollowUp"
	.CommandType = adCmdStoredProc
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@RECORD_OWNER", adVarChar, adParamInput, 3, IIf(user_bSuperUserVOL,Null,user_strAgency))
	.CommandTimeout = 0
End With

With rsListReferrals
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdListReferrals
End With

Call volReferralSearchResults(True, True, False)

Set cmdListReferrals = Nothing

Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
