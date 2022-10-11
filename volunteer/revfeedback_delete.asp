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
<!--#include file="../text/txtCommonForm.asp" -->
<!--#include file="../text/txtDates.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtFeedbackCommon.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtRecordPages.asp" -->
<!--#include file="../text/txtReviewFeedback.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/update/incEventSchedule.asp" -->
<!--#include file="../includes/update/incFbInfo.asp" -->
<%
If Not user_bCanDeleteRecordVOL Then
	Call securityFailure()
End If

Dim bConfirmed
bConfirmed = Request("Confirmed") = "on"

Dim intRevFBID
intRevFBID = Trim(Request("FBID"))

If Nl(intRevFBID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		"revfeedback.asp", vbNullString)
ElseIf Not IsIDType(intRevFBID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intRevFBID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_FEEDBACK, _
		"revfeedback.asp", vbNullString)
Else
	intRevFBID = CLng(intRevFBID)
End If

If bConfirmed Then
	Call deleteFeedback(intRevFBID,FB_REC)
Else
%>

<%	
	Call makePageHeader(TXT_CONFIRM_DELETE_FEEDBACK, TXT_CONFIRM_DELETE_FEEDBACK, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_REVIEW_BEFORE_DELETE%></span></p>
<%
	Call printFeedbackInfo(intRevFBID,Null,FB_REC)
%>
<hr>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE_FB%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="FBID" value="<%=intRevFBID%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" value="<%=TXT_DELETE%>">
</form>
<%
	Call makePageFooter(True)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
