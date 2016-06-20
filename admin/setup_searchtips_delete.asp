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
'
' Purpose:		Deletes page information
'
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
' setSearchTips(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtSearchTips.asp" -->
<%
Dim intDomain

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Dim bConfirmed
bConfirmed = Request("Confirmed") = "on"

Dim intSearchTipsID
intSearchTipsID = Trim(Request("SearchTipsID"))

If Nl(intSearchTipsID) Then
	bNew = True
	intSearchTipsID = Null
ElseIf Not IsIDType(intSearchTipsID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intSearchTipsID) & ".", _
		"setup_searchtips.asp", vbNullString)
Else
	intSearchTipsID = CLng(intSearchTipsID)
End If

If Not bConfirmed Then
	Call makePageHeader(TXT_DELETE_SEARCH_TIPS, TXT_DELETE_SEARCH_TIPS, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="SearchTipsID" value="<%=intSearchTipsID%>">
<input type="hidden" name="Confirmed" value="on">
</div>
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%
	Call makePageFooter(False)
Else

Dim objReturn, objErrMsg
Dim cmdDeleteSearchTips, rsInsertSearchTips
Set cmdDeleteSearchTips = Server.CreateObject("ADODB.Command")
With cmdDeleteSearchTips
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_SearchTips_d"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@SearchTipsID", adInteger, adParamInput, 4, intSearchTipsID)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsInsertSearchTips = cmdDeleteSearchTips.Execute
Set rsInsertSearchTips = rsInsertSearchTips.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
			"setup_searchtips.asp", _
			"DM=" & intDomain, _
			False)
	Case Else
		Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			"setup_searchtips_edit.asp", _
			"DM=" & intDomain & "&SearchTipsID=" & intSearchTipsID)
End Select

End If
%>
<!--#include file="../includes/core/incClose.asp" -->
