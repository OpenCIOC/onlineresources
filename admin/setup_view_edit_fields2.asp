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
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtView.asp" -->
<!--#include file="../text/txtDisplayOrder.asp" -->
<!--#include file="../includes/validation/incDisplayOrder.asp" -->
<%
'On Error Resume Next

Dim	intDomain, _
	strDomain

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not (user_bSuperUserCIC Or (Not g_bUseCIC And user_bSuperUserVOL)) Then
			Call securityFailure()
		End If
		strDomain = "CIC"
	Case DM_VOL
		If Not user_bSuperUserVOL And g_bUseVOL Then
			Call securityFailure()
		End If
		strDomain = "VOL"
	Case Else
		Call handleError(TXT_FIELD_LIST_NOT_UPDATED & TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", vbNullString)
End Select

Dim strError

Const ACTION_UPDATE = 1
Const ACTION_DELETE = 2
Const ACTION_ADD = 3

Dim intActionType, _
	strActionType, _
	bConfirmed, _
	intViewType, _
	strFType, _
	intRTID, _
	strIDList, _
	strStoredProcName

intViewType = Trim(Request("ViewType"))

If Nl(intViewType) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_VIEW, _
		"setup_view.asp", vbNullString)
ElseIf Not IsIDType(intViewType) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intViewType) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_VIEW, _
		"setup_view.asp", vbNullString)
Else
	intViewType = CLng(intViewType)
End If

strFType = Trim(Request("FType"))

Select Case strFType
	Case "U"
		strStoredProcName = "dbo.sp_" & strDomain & "_View_UpdateFieldIDs_u"
	Case "F"
		strStoredProcName = "dbo.sp_" & strDomain & "_View_FeedbackFieldIDs_u"
	Case "M"
		If intDomain = DM_VOL Then
			Call handleError(TXT_ERR_FIELD_TYPE, _
				"setup_view_edit.asp", _
				"ViewType=" & intViewType & "&DM=" & intDomain)
		Else
			strStoredProcName = "dbo.sp_" & strDomain & "_View_MailFormFieldIDs_u"
		End If
	Case "D"
		strStoredProcName = "dbo.sp_" & strDomain & "_View_DisplayFieldIDs_u"
	Case Else
		Call handleError(TXT_ERR_FIELD_TYPE, _
			"setup_view_edit.asp", _
			"ViewType=" & intViewType & "&DM=" & intDomain)
End Select

strIDList = Trim(Request("FieldID"))

If Nl(strIDList) Then
	strIDList = Null
ElseIf Not IsIDList(strIDList) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strIDList), _
		"setup_view_edit_fields.asp", "DM=" & intDomain & "&ViewType=" & intViewType & "&FType=" & strFType)
End If

intRTID = Trim(Request("RTID"))
If Nl(intRTID) Then
	intRTID = Null
ElseIf Not IsIDType(intRTID) Then
	intRTID = -1
End If

Select Case Request("Submit")
	Case TXT_UPDATE
		intActionType = ACTION_UPDATE
		strActionType = TXT_UPDATED
	Case TXT_DELETE
		bConfirmed = Request("Confirmed") = "on"
		intActionType = ACTION_DELETE
		strActionType = TXT_DELETED
	Case Else
		Call handleError(TXT_NO_ACTION, _
			"setup_view_edit_fields.asp", _
			"ViewType=" & intViewtype & "&DM=" & intDomain)
End Select

Dim objReturn, objErrMsg
Dim cmdViewFields, rsViewFields
Set cmdViewFields = Server.CreateObject("ADODB.Command")
With cmdViewFields
	.ActiveConnection = getCurrentAdminCnn()
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
End With

'If the deletion has not been confirmed, print a form for the user to confirm
If intActionType = ACTION_DELETE Then
	If Not (strFType = "U" Or strFType = "F") And intDomain = DM_CIC And Not Nl(intRTID) Then
		Call handleError(TXT_NO_ACTION, _
			"setup_view_edit_fields.asp", _
			"ViewType=" & intViewtype & "&DM=" & intDomain)
	ElseIf Not bConfirmed Then
		Call makePageHeader(TXT_CONFIRM_DELETE_FORM, TXT_CONFIRM_DELETE_FORM, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="ViewType" value="<%=intViewType%>">
<input type="hidden" name="FType" value="<%=strFType%>">
<input type="hidden" name="RTID" value="<%=intRTID%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%
		Call makePageFooter(True)
	Else
		strStoredProcName = Replace(strStoredProcName,"IDs_u","IDs_d_RT")
		With cmdViewFields
			.CommandText = strStoredProcName
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
			.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
			.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
			.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, user_strAgency)
			.Parameters.Append .CreateParameter("@RT_ID", adInteger, adParamInput, 4, intRTID)
		End With
	End If
Else

Dim aFieldIDs, _
	i, _
	intFieldID, _
	intDisplayGroupID

With cmdViewFields
	.CommandText = strStoredProcName
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, user_strAgency)
	
	If intDomain = DM_CIC Then
		aFieldIDs = Split(strIDList,",")
		For i = 0 To UBound(aFieldIDs)
			intFieldID = Trim(aFieldIDs(i))
			intDisplayGroupID = Trim(Request("DisplayFieldGroupID_" & intFieldID))
			If Not IsNumeric(intDisplayGroupID) Then
				intDisplayGroupID = vbNullString
			End If
			aFieldIDs(i) = intFieldID & "-" & Nz(intDisplayGroupID,vbNullString)
		Next
		strIDList = Join(aFieldIDs,",")
		.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strIDList)
		If intDomain = DM_CIC And (strFType = "F" Or strFType = "U") Then
			.Parameters.Append .CreateParameter("@RT_ID", adInteger, adParamInput, 4, intRTID)
		End If
	Else
		.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strIDList)
	End If

End With

End If

If Not (intActionType = ACTION_DELETE And Not bConfirmed) Then

With cmdViewFields
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With

Set rsViewFields = cmdViewFields.Execute
Set rsViewFields = rsViewFields.NextRecordset

If objReturn = 0 And Err.Number = 0 Then
	If intActionType = ACTION_DELETE Then
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
			"setup_view_edit_fields.asp", _
			"DM=" & intDomain & "&FType=" & strFType & "&ViewType=" & intViewType, _
			False)
	Else
		Call handleMessage(TXT_FIELD_LIST_UPDATED, _
			"setup_view_edit_fields.asp", _
			"DM=" & intDomain & "&FType=" & strFType & "&ViewType=" & intViewType & "&RTID=" & intRTID, _
			False)
	End IF
Else
	If Err.Number <> 0 Then
		strError = Err.Description
	Else
		strError = objErrMsg.Value
	End If
	Call handleError(TXT_FIELD_LIST_NOT_UPDATED & strError, _
		"setup_view_edit_fields.asp", _
		"DM=" & intDomain & "&FType=" & strFType & "&ViewType=" & intViewType & "&RTID=" & intRTID)
End If

End If

%>
<!--#include file="../includes/core/incClose.asp" -->
