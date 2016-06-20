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
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtReferral.asp" -->
<!--#include file="../text/txtStats.asp" -->
<!--#include file="../includes/list/incAgencyList.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
If Not user_bSuperUserVOL Then
	Call securityFailure()
End If

Call makePageHeader(TXT_DELETE_OLD_REFERRALS, TXT_DELETE_OLD_REFERRALS, True, False, True, True)
%>
<p>[ <a href="<%=makeLinkB("referral.asp")%>"><%= TXT_REFERRALS_MAIN_MENU %></a> ]</p>

<h3><%= TXT_DELETE_OLD_REFERRALS %></h3>
<p><%= Join(Array(TXT_INST_DELETE_REFERRALS_1, TXT_INST_DELETE_REFERRALS_2, TXT_INST_DELETE_REFERRALS_3, TXT_INST_DELETE_REFERRALS_4,  TXT_INST_DELETE_REFERRALS_5, TXT_INST_DELETE_REFERRALS_6, TXT_INST_DELETE_REFERRALS_7), " ") %></p>
<%
Dim cmdStatD, rsStatD
Set cmdStatD = Server.CreateObject("ADODB.Command")
With cmdStatD
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandText = "dbo.sp_VOL_OP_Referral_Month_l"
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.CommandTimeout = 0
	Set rsStatD = .Execute
End With
%>
<form action="referral_delete2.asp" method="post">
<%=g_strCacheFormVals%>
<%
Dim intStatTotal, intStatStaffTotal
intStatTotal = 0
intStatStaffTotal = 0

With rsStatD
%>
<table class="BasicBorder cell-padding-2">
<tr class="RevTitleBox"><th><%= TXT_DELETE_UP_TO %></th><th><%= TXT_NUMBER_REFERRALS_TO_DELETE %></th></tr>
<%
	While Not .EOF
		intStatTotal = intStatTotal + .Fields("ReferralCount")
%>
<tr><td><label for=<%=AttrQs(Replace("DeleteToDate_" & .Fields("REFERRAL_MONTH"), " ", "_"))%>><input type="radio" name="DeleteToDate" id=<%=AttrQs(Replace("DeleteToDate_" & .Fields("REFERRAL_MONTH"), " ", "_"))%> value="<%=DateString(DateAdd("m",1,.Fields("REFERRAL_MONTH")),True)%>"> <%=.Fields("REFERRAL_MONTH")%></label></td><td><%=intStatTotal%></td></tr>
<%
		.MoveNext
	Wend
%>
</table>
<input type="submit" value="<%=TXT_DELETE%>">
<%
End With
%>
</form>
<%

Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
