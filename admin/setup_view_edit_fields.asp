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
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../text/txtView.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incDetailFieldGroupsList.asp" -->
<!--#include file="../includes/list/incRecordTypeList.asp" -->
<%
Dim intDomain, _
	strType, _
	strDomain, _
	bError, _
	strErrMessage

bError = False

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not (user_bSuperUserCIC Or (Not g_bUseCIC And user_bSuperUserVOL)) Then
			Call securityFailure()
		End If
		strType = TXT_CIC
		strDomain = "CIC"
	Case DM_VOL
		If Not user_bSuperUserVOL And g_bUseVOL Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
		strDomain = "VOL"
	Case Else
		bError = True
		strErrMessage = TXT_UNABLE_DETERMINE_TYPE
End Select

Const FORM_ACTION = "<form action=""setup_view_edit_fields2.asp"" METHOD=""POST"" class=""form"">"

Dim SUBMIT_BUTTON, _
	DELETE_BUTTON, _
	ADD_BUTTON, _
	RESET_BUTTON

SUBMIT_BUTTON = "<input type=""Submit"" name=""Submit"" value=" & AttrQs(TXT_UPDATE) & " class=""btn btn-default"">"
DELETE_BUTTON = "<input type=""Submit"" name=""Submit"" value=" & AttrQs(TXT_DELETE) & " class=""btn btn-default"">"
ADD_BUTTON = "<input type=""Submit"" name=""Submit"" value=" & AttrQs(TXT_ADD) & " class=""btn btn-default"">"
RESET_BUTTON = "<input type=""Reset"" value=" & AttrQs(TXT_RESET_FORM) & " class=""btn btn-default"">"

Dim intViewType, _
	strViewName, _
	strFType, _
	strFTypeDesc, _
	intRTID, _
	strStoredProcName

strFType = Trim(Request("FType"))
intViewType = Trim(Request("ViewType"))
intRTID = Trim(Request("RTID"))
If Not IsIDType(intRTID) Then
	intRTID = Null
End If

If Nl(intViewType) Then
	bError = True
	strErrMessage = TXT_NO_RECORD_CHOSEN
ElseIf Not IsIDType(intViewType) Then
	bError = True
	strErrMessage = TXT_INVALID_ID & Server.HTMLEncode(intViewType) & "."
Else
	intViewType = CLng(intViewType)
End If

Select Case strFType
	Case "U"
		strFTypeDesc = TXT_UPDATE_FIELDS
		strStoredProcName = "dbo.sp_" & strDomain & "_View_UpdateFields_l"
	Case "F"
		strFTypeDesc = TXT_FEEDBACK_FIELDS
		strStoredProcName = "dbo.sp_" & strDomain & "_View_FeedbackFields_l"
	Case "M"
		If intDomain = DM_VOL Then
			bError = True
			strErrMessage = TXT_ERR_FIELD_TYPE
		Else
			strFTypeDesc = TXT_MAIL_FORM_FIELDS
			strStoredProcName = "dbo.sp_" & strDomain & "_View_MailFormFields_l"
		End If
	Case "D"
		strFTypeDesc = TXT_DETAIL_FIELDS
		strStoredProcName = "dbo.sp_" & strDomain & "_View_DisplayFields_l"
	Case Else
		bError = True
		strErrMessage = TXT_ERR_FIELD_TYPE
End Select

If Not bError Then

Dim cnnViewFields, cmdViewFields, rsViewFields
Call makeNewAdminConnection(cnnViewFields)
Set cmdViewFields = Server.CreateObject("ADODB.Command")
With cmdViewFields
	.ActiveConnection = cnnViewFields
	.CommandText = strStoredProcName
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, user_strAgency)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
	If intDomain = DM_CIC And (strFType = "F" Or strFType = "U") Then
		.Parameters.Append .CreateParameter("@RT_ID", adInteger, adParamInput, 4, intRTID)
	End If
End With
Set rsViewFields = cmdViewFields.Execute

If rsViewFields.EOF Then
	bError = True
	strErrMessage = TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intViewType) & "."
Else
	strViewName = rsViewFields("ViewName")
End If

End If

If Not bError Then

Set rsViewFields = rsViewFields.NextRecordset

Dim strRecordTypeName, _
	bRecordTypeHasForm

If Not Nl(intRTID) Then
	With rsViewFields
		If Not .EOF Then
			bRecordTypeHasForm = .Fields("RT_HAS_FORM")
			strRecordTypeName = "(" & .Fields("RecordType") & ")" & _
				IIf(Nl(.Fields("RecordTypeName")),vbNullString," " & .Fields("RecordTypeName"))
		Else
			intRTID = Null
		End If
	End With
	Set rsViewFields = rsViewFields.NextRecordset
End If

Call makePageHeader(strViewName & TXT_COLON & strFTypeDesc, strViewName & TXT_COLON & strFTypeDesc, False, False, True, False)
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a><%= makePageHelpLink() %> ]</p>

<h2><%=strFTypeDesc & " (" & strViewName & ")"%></h2>
<p><%=TXT_SOME_FIELDS_UNAVAILABLE%></p>
<%
if intDomain = DM_CIC Then

	If strFType = "F" Or strFType = "U" Then
		Call openRecordTypeFormListRst(intViewType, strFType)

		With rsListRecordType
			If Not .EOF Then
%>
<p><%=TXT_EDIT_FORM_FOR_TYPE%></p>
<ul>
<%
				If Not Nl(intRTID) Then
%>
	<li><a href="<%=makeLink(ps_strThisPage,"ViewType=" & intViewType & "&FType=" & strFType & "&DM=" & intDomain,vbNullString)%>"><%=TXT_ALL_TYPES%></a></li>
<%
				End If
				While Not .EOF
					If .Fields("RT_ID") <> intRTID Or Nl(intRTID) Then
%>
	<li><a href="<%=makeLink(ps_strThisPage,"ViewType=" & intViewType & "&FType=" & strFType & "&DM=" & intDomain & "&RTID=" & .Fields("RT_ID"),vbNullString)%>"><%="(" & .Fields("RecordType") & ")" & IIf(Nl(.Fields("RecordTypeName")),vbNullString," " & .Fields("RecordTypeName"))%></a></li>
<%
					End If
					.MoveNext
				Wend
%>
</ul>
<%
			End If
		End With
	
		Set rsListRecordType = rsListRecordType.NextRecordset
		If Not rsListRecordType.EOF Then
%>
<form action="<%=ps_strThisPage%>" class="form form-inline">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="ViewType" value="<%=intViewType%>">
<input type="hidden" name="FType" value="<%=strFType%>">
<input type="hidden" name="DM" value="<%=intDomain%>">
</div>
<p><label for="RTID"><%=TXT_CREATE_NEW_FORM_FOR_TYPE%></label><%=makeRecordTypeList(vbNullString, "RTID", False, vbNullString)%>&nbsp;<input type="submit" value="<%=TXT_ADD%>" class="btn btn-default"></p>
</form>

<h3><%=IIf(bRecordTypeHasForm Or Nl(strRecordTypeName),TXT_EDIT_FORM_FOR_TYPE,TXT_CREATE_NEW_FORM_FOR_TYPE) & Nz(strRecordTypeName,TXT_ALL_TYPES)%></h3>
<%
		End If
		Call closeRecordTypeListRst()
	End If
End If
%>
<%=FORM_ACTION%>
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="ViewType" value="<%=intViewType%>">
<input type="hidden" name="FType" value="<%=strFType%>">
<input type="hidden" name="DM" value="<%=intDomain%>">
<%
If Not Nl(intRTID) Then
%>
<input type="hidden" name="RTID" value="<%=intRTID%>">
<%
End If
%>
</div>

<table class="BasicBorder cell-padding-3 clear-line-below">
<tr class="RevTitleBox">
	<th><%=TXT_FIELD%></th>
	<th><%=TXT_DETAIL_FIELD_GROUP%></th>
</tr>
<%
	Call openDetailFieldGroupsListRst(intViewType, intDomain)
	With rsViewFields
		While Not .EOF
%>
<%=FORM_ACTION%>
<div style="display:none">
<input type="hidden" name="FieldID" value="<%=.Fields("FieldID")%>">
</div>
<tr valign="top">
	<td><strong><label for=<%=AttrQs("DisplayFieldGroupID_" & .Fields("FieldID"))%>><%=.Fields("FieldName")%></label></strong>
		<br>(<%=.Fields("FieldDisplay")%>)</td>
	<td><%=makeDetailFieldGroupsList(.Fields("DisplayFieldGroupID"),"DisplayFieldGroupID_" & .Fields("FieldID"),True,IIf(intDomain=DM_CIC,False,True))%></td>
</tr>
<%
			.MoveNext
		Wend
	End With
	Call closeDetailFieldGroupsListRst()
%>
</table>
<p><%=SUBMIT_BUTTON%>&nbsp;<%If bRecordTypeHasForm Then%><%=DELETE_BUTTON%><%End If%>&nbsp;<%=RESET_BUTTON%></p>
</form>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a> ]</p>

<%
Call makePageFooter(False)

Else
	Call makePageHeader(TXT_FIELD_LIST_NOT_UPDATED, TXT_FIELD_LIST_NOT_UPDATED, False, False, True, False)
	Call handleError(strErrMessage, vbNullString, vbNullString)
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a> ]</p>
<%
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
