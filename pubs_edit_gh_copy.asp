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
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtGeneralHeading.asp" -->
<!--#include file="text/txtSearchResults.asp" -->
<!--#include file="text/txtUpdatePubs.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<%
If Not user_intCanUpdatePubs = UPDATE_ALL Then
	Call securityFailure()
End If

Dim bError
bError = False

Dim	intPBID, _
	intCopyPBID, _
	strCopyToName, _
	strCopyToCode, _
	strCopyFromName, _
	strCopyFromCode

intPBID = Request("PBID")
If Nl(intPBID) Then
	intPBID = Null
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUB, _
		"publication", vbNullString)
ElseIf Not IsIDType(intPBID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intPBID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUB, _
		"publication", vbNullString)
Else
	intPBID = CLng(intPBID)
End If

intCopyPBID = Request("CopyPBID")
If Nl(intCopyPBID) Then
	intCopyPBID = Null
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUB, _
		"publication", vbNullString)
ElseIf Not IsIDType(intCopyPBID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intCopyPBID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUB, _
		"publication", vbNullString)
Else
	intCopyPBID = CLng(intCopyPBID)
End If

If user_bLimitedViewCIC And Not user_intPBID=intPBID Then
	Call securityFailure()
End If

Dim	fldGHID, _
	fldGeneralHeading, _
	fldGeneralHeadingEq

If Not bError Then
	Dim cmdGeneralHeading, rsGeneralHeading
	Set cmdGeneralHeading = Server.CreateObject("ADODB.Command")
	With cmdGeneralHeading
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_GeneralHeading_l_Copy"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@SuperUserGlobal", adBoolean, adParamInput, 1, IIf(user_bSuperUserGlobalCIC,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@PB_ID", adInteger, adParamInput, 4, intPBID)
		.Parameters.Append .CreateParameter("@CopyPBID", adInteger, adParamInput, 4, intCopyPBID)
		Set rsGeneralHeading = .Execute
	End With


	If Not rsGeneralHeading.EOF Then
		strCopyToCode = rsGeneralHeading.Fields("PubCode")
		strCopyToName = strCopyToCode & StringIf(Not Nl(rsGeneralHeading.Fields("PubName"))," (" & rsGeneralHeading.Fields("PubName") & ")")
		Set rsGeneralHeading = rsGeneralHeading.NextRecordset
	Else
		bError = True
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intPBID), _
			vbNullString, _
			vbNullString)	
	End If

	If Not rsGeneralHeading.EOF Then
		strCopyFromCode = rsGeneralHeading.Fields("PubCode")
		strCopyFromName = strCopyFromCode & StringIf(Not Nl(rsGeneralHeading.Fields("PubName"))," (" & rsGeneralHeading.Fields("PubName") & ")")
		Set rsGeneralHeading = rsGeneralHeading.NextRecordset
	Else
		bError = True
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intPBID), _
			vbNullString, _
			vbNullString)	
	End If


End If

If Not bError Then

Call makePageHeader(TXT_COPY_HEADINGS_FROM & strCopyFromCode, TXT_COPY_HEADINGS_FROM & strCopyFromCode, True, False, True, True)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("publication")%>"><%=TXT_RETURN_PUBS%></a> | <a href="<%=makeLink("publication/edit","PB_ID=" & intPBID,vbNullString)%>"><%=TXT_RETURN_PUBLICATION & strCopyToCode%></a> ]</p>
<p class="Info"><%=TXT_COPY_HEADINGS_FROM%> <em><%=strCopyFromName%></em> <%=TXT_TO%> <em><%=strCopyToName%></em></p>
<p><%=TXT_INST_COPY_HEADINGS%></p>
<%
With rsGeneralHeading
	If .EOF Then
%>
<p><%=TXT_NO_VALUES_AVAILABLE%></p>
<%
	Else
%>
<form name="RecordList" action="pubs_edit_gh_copy2.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="PBID" value="<%=intPBID%>">
<input type="hidden" name="CopyPBID" value="<%=intCopyPBID%>">
<p><input type="BUTTON" onClick="CheckAll();" value="<%=TXT_CHECK_ALL%>"> <input type="BUTTON" onClick="ClearAll();" value="<%=TXT_UNCHECK_ALL%>"></p>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox">&nbsp;</th>
	<th class="RevTitleBox"><%=TXT_NAME%></th>
</tr>
<%
		While Not .EOF
%>
<tr>
	<td>
<%
			If Not Nl(.Fields("CopyGHID")) Then
%>
	<img src="images/greencheck.gif" width="15" height="15">
<%
			Else
%>
	<input type="checkbox" name="IDList" value="<%=.Fields("GH_ID")%>">
<%
			End If
%>
	</td>
	<td><%=Nz(.Fields("GeneralHeading"),"&nbsp;")%></td>
</tr>
<%		
			.MoveNext
		Wend
%>
</table>
<p><input type="submit" value="<%=TXT_UPDATE%>"></p>
<%
	End If
End With

End If

Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
