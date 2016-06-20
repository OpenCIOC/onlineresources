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
Call setPageInfo(True, DM_VOL, DM_GLOBAL, "../","admin/", vbNullString)
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

Dim strError

Const ACTION_UPDATE = 1
Const ACTION_DELETE = 2
Const ACTION_ADD = 3

Dim intActionType, _
	strActionType, _
	intVOLCMID, _
	intCommunityGroupID, _
	intCommunitySetID, _
	intCGCMID

intCommunitySetID=Trim(Request("CommunitySetID"))
If IsIDType(intCommunitySetID) Then
	intCommunitySetID=CInt(intCommunitySetID)
Else
	Call handleError(TXT_INVALID_CS, _
		"comms_vol.asp", vbNullString)
End If

Select Case Request("Submit")
	Case TXT_UPDATE
		intActionType = ACTION_UPDATE
		strActionType = TXT_UPDATED
	Case TXT_DELETE
		intActionType = ACTION_DELETE
		strActionType = TXT_DELETED
	Case TXT_ADD
		intActionType = ACTION_ADD
		strActionType = TXT_ADDED
	Case Else
		Call handleError(TXT_NO_ACTION, "comms_vol_vcgc.asp", _
				"CommunitySetID=" & intCommunitySetID)
End Select

If intActionType <> ACTION_ADD Then
	intCGCMID = Trim(Request("CGCMID"))
	If Not IsIDType(intCGCMID) Then
		Call handleError(TXT_NO_RECORD_CHOSEN, "comms_vol_vcgc.asp", _
				"CommunitySetID=" & intCommunitySetID)
	End If
Else
	intVOLCMID = Trim(Request("VOLCMID"))
	If Not IsIDType(intVOLCMID) Then
		Call handleError(TXT_NO_RECORD_CHOSEN, "comms_vol_vcgc.asp", _
				"CommunitySetID=" & intCommunitySetID)
	End If
End IF

intCommunityGroupID = Trim(Request("CommunityGroupID"))
If Nl(intCommunityGroupID) Then
	Call handleError(TXT_ERROR_NO_GROUP_SELECTED, "comms_vol_vcgc.asp", "CommunitySetID=" & intCommunitySetID)
End If

Dim objReturn, objErrMsg
Dim cmdViewComms, rsViewComms
Set cmdViewComms = Server.CreateObject("ADODB.Command")
With cmdViewComms
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	If Nl(strError) Then
		Select Case intActionType
			Case ACTION_UPDATE
				.CommandText = "dbo.sp_VOL_CommunityGroup_CM_u"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@CG_CM_ID", adInteger, adParamInput, 4, intCGCMID)
				.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				.Parameters.Append .CreateParameter("@CommunityGroupID", adInteger, adParamInput, 4, intCommunityGroupID)	
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
			Case ACTION_ADD
				.CommandText = "dbo.sp_VOL_CommunityGroup_CM_i"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				.Parameters.Append .CreateParameter("@CM_ID", adInteger, adParamInput, 4, intVOLCMID)
				.Parameters.Append .CreateParameter("@CommunityGroupID", adInteger, adParamInput, 4, intCommunityGroupID)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
			Case ACTION_DELETE
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.CommandText = "dbo.sp_VOL_CommunityGroup_CM_d"
				.Parameters.Append .CreateParameter("@CG_CM_ID", adInteger, adParamInput, 4, intCGCMID)
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
		End Select
	End If
End With

Set rsViewComms = cmdViewComms.Execute
Set rsViewComms = rsViewComms.NextRecordset

If objReturn.Value = 0 And Err.Number = 0 Then
	Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & strActionType, _
		"comms_vol_vcgc.asp", _
		"CommunitySetID=" & intCommunitySetID, _
		False)
Else
	Call handleError(TXT_RECORDS_WERE_NOT & strActionType & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
		"comms_vol_vcgc.asp", _
		"CommunitySetID=" & intCommunitySetID)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
