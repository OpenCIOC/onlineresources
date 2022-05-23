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
<!--#include file="../text/txtSearchBasicVOL.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/search/incVolReferralSearch.asp" -->
<%
If Not user_bCanAccessProfiles Then
	Call securityFailure()
End If

Dim strEmail, _
	strProfileID

strEmail = Left(Trim(Request("Email")),100)
strProfileID = Left(Trim(Request("ProfileID")),38)

If Not IsGUIDType(strProfileID) Or Nl(strProfileID) Then
	strProfileID = Null
End If

Call volReferralSearchHeader()

If Nl(strEmail) And Nl(strProfileID) Then
%>
<p><%=TXT_NO_PROFILE_GIVEN%></p>
<%
Else
	Dim strPFirstName, _
		strPLastName, _
		strPEmail, _
		bOrgCanContact, _
		bNoMatch

	bNoMatch = True

	Dim cmdListReferrals
	
	Set cmdListReferrals = Server.CreateObject("ADODB.Command")
	With cmdListReferrals
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_VOL_OP_Referral_ls_Profile"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 100, strEmail)
		.Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, strProfileID)
	End With

	With rsListReferrals
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListReferrals

		If Not .EOF Then
			bNoMatch = False
			strProfileID = .Fields("ProfileID")
			strPFirstName = .Fields("FirstName")
			strPLastName = .Fields("LastName")
			strPEmail = .Fields("Email")
			bOrgCanContact = .Fields("OrgCanContact")
		End If
	End With

	Set rsListReferrals = rsListReferrals.NextRecordset
	
	If Not bNoMatch Then
		Call volReferralSearchPageTitle(TXT_REFERRALS_FOR_PROFILE & " <em>" & strPEmail & " (" & strPFirstName & " " & strPLastName & ")</em>", _
			"<a href=""" & makeLinkB(ps_strPathToStart & "volunteer/profiles.asp") & """>" & TXT_VOLUNTEER_PROFILES & "</a>" & _
			" | <a href=""" & makeLink(ps_strPathToStart & "volunteer/profiles_details.asp",IIf(bOrgCanContact,"Email=" & Server.URLEncode(strPEmail),"ProfileID=" & strProfileID), vbNullString) & """>" & TXT_PROFILE_DETAILS & " (" & strPEmail & ")</a>")

		Call volReferralSearchUpdateFollowUpFlags()

		Call volReferralSearchResults(True, True, False)
	Else
%>
	<p><%=TXT_FOUND%><strong>0</strong><%=TXT_MATCHES%>.</p>
<%
	End If
	
	Set cmdListReferrals = Nothing

End If

Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
