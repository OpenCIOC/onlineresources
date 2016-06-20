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

<%
If Not user_bCanManageMembers Then
	Call securityFailure()
End If

Dim bError, strError, intActionType, strActionType, _
		strNUM, strJoined, strNextRenewal, intVMemID, bActive

bError=False
strError = vbNullString

Const ACTION_UPDATE = 1
Const ACTION_ADD = 2

Select Case Request("Submit")
	Case TXT_UPDATE
		intActionType = ACTION_UPDATE
		strActionType = TXT_UPDATED
	Case TXT_ADD
		intActionType = ACTION_ADD
		strActionType = TXT_ADDED
	Case Else
		bError = True
		strError = TXT_NO_ACTION
End Select

If Not bError and intActionType <> ACTION_ADD Then
	intVMemID = Trim(Request("VMemID"))
	If Nl(intVMemID) Then
		bError = True
		strError = "No Volunteer Member selected."
	ElseIf Not IsIDType(intVMemID) Then
		bError = True
		strError = "Volunteer Member ID is not valid."
	End If
End If

If Not bError Then
strNUM = Request("NUM")
strJoined = Trim(Request("MemberSince"))
strNextRenewal = Trim(Request("NextRenewalDate"))
bActive = Not Nl(Trim(Request("Active")))

If Not IsNUMType(strNUM) Then
	bError = True
	strError = "The Organization Record # is not valid."
ElseIf Not (Nl(strJoined) Or IsSmallDate(strJoined)) Then
	bError = True
	strError = "Date Joined is not a valid date."
ElseIf Not (Nl(strNextRenewal) Or IsSmallDate(strJoined)) Then
	bError = True
	strError = "Next Renewal Date is not a valid date."
Else
	If Nl(strJoined) Then
		strJoined = Null
	End If

	If Nl(strNextRenewal) Then
		strNextRenewal = Null
	End If

	Dim cmdAddMember, rsAddMember
	Set cmdAddMember = Server.CreateObject("ADODB.Command")

	With cmdAddMember
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		If intActionType = ACTION_ADD Then
			.CommandText = "dbo.sp_VOL_Member_i"
			.Parameters.Append .CreateParameter("@VMEM_ID", adInteger, adParamOutput, 4)
		Else
			.CommandText = "dbo.sp_VOL_Member_u"
			.Parameters.Append .CreateParameter("@VMEM_ID", adInteger, adParamInput, 4, intVMemID)
		End If
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@MemberSince", adDBDate, adParamInput, 4, strJoined)
		If intActionType = ACTION_ADD Then
			.Parameters.Append .CreateParameter("@NextRenewEndDate", adDBDate, adParamInput, 4, strNextRenewal)
		Else
			.Parameters.Append .CreateParameter("@Active", adBoolean, adParamInput, 1, bActive)
		End If

		.Parameters.Append .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	End With

	Set rsAddMember = cmdAddMember.Execute
	Set rsAddMember = rsAddMember.NextRecordset
	strError = cmdAddMember.Parameters("@ErrMsg")
	If Err.Number = 0 And Nl(strError) Then
		intVMemID = cmdAddMember.Parameters("@VMEM_ID")
		Call handleMessage("The Member was added successfully.", _
				"member_details.asp", "VMemID=" & intVMemID, False)
	Else
		bError = True
		strError = Server.HTMLEncode(Err.Description & " " & strError)
	End If

End If
End If

If bError Then
	Call makePageHeader("Add Volunteer Member Organization", "Add Volunteer Member Organization", True, False, True, True)
	Call handleError("The Member was not " & strActionType & TXT_COLON & strError, _
		vbNullString, _
		vbNullString)
	Call makePageFooter(True)
End If

%>

<!--#include file="../includes/core/incClose.asp" -->


