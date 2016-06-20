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
	intCommunitySetID, _
	strField, _
	strDescriptions, _
	strValue, _
	strCulture

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
		Call handleError(TXT_NO_ACTION, "comms_vol_vcs.asp", vbNullString)
End Select

If intActionType <> ACTION_ADD Then
	intCommunitySetID = Trim(Request("CommunitySetID"))
	If Nl(intCommunitySetID) Then
		Call handleError(TXT_ERROR_NO_SET_SELECTED, "comms_vol_vcs.asp", vbNullString)
	End If
End IF


strDescriptions = vbNullString
Dim strDesc

For Each strCulture In active_cultures()
	strDesc = vbNullString

	For Each strField in Array("SetName", "AreaServed")
		strValue = Left(Trim(Request(strField & "_" & strCulture)), 100)

		If Not Nl(strValue) Then
			strDesc = strDesc & "<" & strField & ">" & XMLEncode(strValue) & "</" & strField & ">"
		End If
	Next

	If Not Nl(strDesc) Then
		strDescriptions = strDescriptions & _
			"<DESC><Culture>" & strCulture & "</Culture>" & strDesc & "</DESC>"
	End If

Next

If Not Nl(strDescriptions) Then
	strDescriptions = "<DESCS>" & strDescriptions & "</DESCS>"
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
				.CommandText = "dbo.sp_VOL_CommunitySet_u"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@CommunitySetID", adInteger, adParamInput, 4, intCommunitySetID)
				.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				.Parameters.Append .CreateParameter("@Descriptions", adVarWChar, adParamInput, -1, strDescriptions)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
			Case ACTION_ADD
				.CommandText = "dbo.sp_VOL_CommunitySet_i"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				.Parameters.Append .CreateParameter("@Descriptions", adVarWChar, adParamInput, -1, strDescriptions)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
			Case ACTION_DELETE
				.CommandText = "dbo.sp_VOL_CommunitySet_d"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@CommunitySetID", adInteger, adParamInput, 4, intCommunitySetID)
				.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
		End Select
	End If
End With

Set rsViewComms = cmdViewComms.Execute
Set rsViewComms = rsViewComms.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & strActionType, _
			"comms_vol_vcs.asp", _
			vbNullString, _
			False)
	Case Else
		Call handleError(TXT_RECORDS_WERE_NOT & strActionType & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			"comms_vol_vcs.asp", _
			vbNullString)
End Select
%>
<!--#include file="../includes/core/incClose.asp" -->
