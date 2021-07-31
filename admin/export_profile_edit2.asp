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
Call setPageInfo(True, DM_CIC, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtExportProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<%
'On Error Resume Next

If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Const ACTION_UPDATE = 1
Const ACTION_DELETE = 2
Const ACTION_ADD = 3

Dim intActionType, strActionType

Dim bError, _
	strErrorMessage

bError = False

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

Dim bConfirmed
bConfirmed = False

Select Case Request("Submit")
	Case TXT_UPDATE
		intActionType = ACTION_UPDATE
		strActionType = TXT_UPDATED
	Case TXT_DELETE
		bConfirmed = Request("Confirmed") = "on"
		intActionType = ACTION_DELETE
		strActionType = TXT_DELETED
	Case TXT_ADD_PROFILE
		intActionType = ACTION_ADD
		strActionType = TXT_ADDED
	Case Else
		Call handleError(TXT_NO_ACTION, "export_profile_edit.asp", "ProfileID=" & Server.HTMLEncode(intProfileID))
End Select

If intActionType <> ACTION_ADD Then
	If Nl(intProfileID) Then
		Call handleError(TXT_NO_RECORD_CHOSEN & _
			vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
			"export_profile_edit.asp", vbNullString)
	ElseIf Not IsIDType(intProfileID) Then
		Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
			vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
			"export_profile_edit.asp", vbNullString)
	Else
		intProfileID = CLng(intProfileID)
	End If
End If

If intActionType = ACTION_DELETE And Not bConfirmed Then
	Call makePageHeader(TXT_CONFIRM_DELETE_PROFILE, TXT_CONFIRM_DELETE_PROFILE, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ProfileID" value="<%=intProfileID%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%
	Call makePageFooter(False)
Else

	Dim	strProfileName

	Select Case intActionType
		Case ACTION_ADD
			strProfileName = Left(Trim(Request("ProfileName")),100)
		Case ACTION_UPDATE
			Dim aProfileCultures, _
				indCulture, _
				strSourceDbName, _
				strSourceDbURL, _
				bIncludePrivacyProfiles, _
				bConvertLine1Line2Addresses, _
				strSubmitChangesToAccessURL, _
				strInViews, _
				strDescriptions, _
				strDesc, _
				strCulture, _
				strField, _
				strValue, _
				bGotName

			bIncludePrivacyProfiles = Not Nl(Trim(Request("IncludePrivacyProfiles")))
			bConvertLine1Line2Addresses = Not Nl(Trim(Request("ConvertLine1Line2Addresses")))
			strSubmitChangesToAccessURL = Nz(Request("SubmitChangesToAccessURL"),Null)

			strDescriptions = vbNullString

			bGotName = False
			aProfileCultures = Split(Request("ProfileCulture"),",")

			For Each indCulture In aProfileCultures
				strCulture = Trim(indCulture)
				If IsCulture(strCulture) And Application("Culture_" + strCulture) Then
				strDesc = vbNullString

				For Each strField in Array("Name", "SourceDbName", "SourceDbURL")
					strValue = Trim(Request(strField & "_" & strCulture))

					If strField = "Name" Then
						strValue = Left(strValue, 100)
						If Not Nl(strValue) Then
							bGotName = True
						End If
					ElseIf strField = "SourceDbURL" Then
						strValue = Left(strValue, 200)
					ElseIf strField = "SourceDbName" Then
						strValue = Left(strValue, 255)
					End If

					If Not Nl(strValue) Then
						strDesc = strDesc & "<" & strField & ">" & XMLEncode(strValue) & "</" & strField & ">"
					End If
				Next

					strDescriptions = strDescriptions & _
						"<DESC><Culture>" & strCulture & "</Culture>" & strDesc & "</DESC>"
				End If

			Next

			If Not Nl(strDescriptions) Then
				strDescriptions = "<DESCS>" & strDescriptions & "</DESCS>"
			End If

			If Not bGotName Then
				bError = True
				strErrorMessage = TXT_NO_NAME_PROVIDED
			End If

			strInViews = Request("InViews")
			If Nl(strInViews) Then
				strInViews = Null
			End If

	End Select

	If Not bError Then
		Dim objReturn, objErrMsg, objProfileID
		Dim cmdProfile, rsProfile
		Set cmdProfile = Server.CreateObject("ADODB.Command")
		With cmdProfile
			.ActiveConnection = getCurrentAdminCnn()
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
			.Parameters.Append objReturn

			Select Case intActionType
				Case ACTION_UPDATE
					.CommandText = "dbo.sp_CIC_ExportProfile_u"
					.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
					.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
					.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
					.Parameters.Append .CreateParameter("@SubmitChangesToAccessURL", adVarChar, adParamInput, 200, strSubmitChangesToAccessURL)
					.Parameters.Append .CreateParameter("@IncludePrivacyProfiles", adBoolean, adParamInput, 1, bIncludePrivacyProfiles)
					.Parameters.Append .CreateParameter("@ConvertLine1Line2Addresses", adBoolean, adParamInput, 1, bConvertLine1Line2Addresses)
					.Parameters.Append .CreateParameter("@InViews", adLongVarChar, adParamInput, -1, strInViews)
					.Parameters.Append .CreateParameter("@Descriptions", adVarWChar, adParamInput, -1, strDescriptions)
				Case ACTION_DELETE
					.CommandText = "dbo.sp_CIC_ExportProfile_d"
					.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
					.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
				Case ACTION_ADD
					.CommandText = "dbo.sp_CIC_ExportProfile_i"
					.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
					.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
					.Parameters.Append .CreateParameter("@ProfileName", adVarChar, adParamInput, 50, strProfileName)
					Set objProfileID = .CreateParameter("@ProfileID", adInteger, adParamInputOutput, 4, Nz(intProfileID, Null))
					.Parameters.Append objProfileID
			End Select		

			Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
			.Parameters.Append objErrMsg
		End With

		Set rsProfile = cmdProfile.Execute
		Set rsProfile = rsProfile.NextRecordset

		Select Case objReturn.Value
			Case 0
				If intActionType = ACTION_DELETE Then
					Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & strActionType & ".", _
						"export_profile.asp", _
						vbNullString, _
						False)
				Else
					If intActionType = ACTION_ADD Then
						intProfileID = objProfileID.Value
					End If

					Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & strActionType & ".", _
						"export_profile_edit.asp", _
						"ProfileID=" & Server.HTMLEncode(intProfileID), _
						False)
				End If
			Case Else
				bError = True
				strErrorMessage = objErrMsg.Value
		End Select
	End If

	If bError Then
		Call makePageHeader(TXT_UPDATE_PROFILE_FAILED, TXT_UPDATE_PROFILE_FAILED, True, False, True, True)
		Call handleError(TXT_RECORDS_WERE_NOT & strActionType & TXT_COLON & Nz(Server.HTMLEncode(strErrorMessage),TXT_UNKNOWN_ERROR_OCCURED), _
			vbNullString, _
			vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
		Call makePageFooter(False)
	End If
End If

%>
<!--#include file="../includes/core/incClose.asp" -->
