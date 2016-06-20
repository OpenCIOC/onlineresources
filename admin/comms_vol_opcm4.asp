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
Call setPageInfo(True, DM_VOL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtCommunitySets.asp" -->
<%
If Not user_bSuperUserVOL Then
	Call securityFailure()
End If

Const ACTION_ADD = 1
Const ACTION_REMOVE = 2

Dim intActionType, _
	intCommunitySetID, _
	strActionResult, _
	strActionType, _
	strError,_
	strVNUMList, _
	strSetName

Select Case Request("AddRemove")
	Case "A"
		intActionType = ACTION_ADD
		strActionResult = TXT_ADDED
		strActionType = TXT_ADD
	Case "R"
		intActionType = ACTION_REMOVE
		strActionResult = "removed"
		strActionType = "Remove"
	Case Else
		Call handleError(TXT_NO_ACTION, "comms_vol_opcm.asp", vbNullString)
End Select

intCommunitySetID=Trim(Request("CommunitySetID"))
If IsIDType(intCommunitySetID) Then
	intCommunitySetID=CInt(intCommunitySetID)
Else
	Call handleError(TXT_INVALID_CS, _
		"comms_vol_opcm.asp", vbNullString)
End If
strSetName=Request("SetName")

strVNUMList = Request("VNUM")
If Nl(strVNUMList) Or Not IsVNUMList(strVNUMList) Then
	Call handleError(TXT_NO_OPPS_SELECTED, "comms_vol_opcm.asp", vbNullString)
End If

Dim objReturn, objErrMsg
Dim cmdUpdate, rsUpdate
Set cmdUpdate = Server.CreateObject("ADODB.Command")
With cmdUpdate
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Select Case intActionType
		Case ACTION_ADD
			.CommandText = "dbo.sp_VOL_OP_CommunitySet_i"
		Case ACTION_REMOVE
			.CommandText = "dbo.sp_VOL_OP_CommunitySet_d"
	End Select
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@CommunitySetID", adInteger, adParamInput, 4, intCommunitySetID)
		.Parameters.Append .CreateParameter("@VNUMList", adLongVarChar, adParamInput, -1, strVNUMList)	
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg	
End With

Set rsUpdate = cmdUpdate.Execute
Set rsUpdate = rsUpdate.NextRecordset

If objReturn.Value = 0 And Err.Number = 0 Then
	Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & strActionResult, _
		"comms_vol_opcm.asp", _
		vbNullString, _
		False)
Else
	Call handleError(TXT_RECORDS_WERE_NOT & strActionResult & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
		"comms_vol_opcm.asp", _
		vbNullString)
End If

%>



<!--#include file="../includes/core/incClose.asp" -->


