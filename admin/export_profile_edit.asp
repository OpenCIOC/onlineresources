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
<!--#include file="../text/txtExportProfile.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incViewList.asp" -->
<%
If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

If Nl(intProfileID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"export_profile.asp", vbNullString)
ElseIf Not IsIDType(intProfileID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"export_profile.asp", vbNullString)
Else
	intProfileID = CLng(intProfileID)
End If

Dim	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
	strProfileName, _
	strSubmitChangesToAccessURL, _
	bIncludePrivacyProfiles, _
	bConvertLine1Line2Addresses, _
	strValue, _
	strCulture, _
	intFieldCount, _
	intDistCount, _
	intPubCount, _
	dicDescriptions, _
	xmlDoc, _
	xmlNode, _
	xmlCultureNode, _
	intLangID, _
	bNewRow

bNewRow = False

Dim cmdProfile, rsProfile
Set cmdProfile = Server.CreateObject("ADODB.Command")
With cmdProfile
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ExportProfile_s"
	.CommandType = adCmdStoredProc
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
	.CommandTimeout = 0
End With
Set rsProfile = cmdProfile.Execute

With rsProfile
	If .EOF Then
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intProfileID) & "." & _
			vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
			"export_profile.asp", vbNullString)
	Else
		strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strProfileName = Nz(.Fields("ProfileName"),TXT_UNKNOWN)
		strSubmitChangesToAccessURL = .Fields("SubmitChangesToAccessURL")
		bIncludePrivacyProfiles = .Fields("IncludePrivacyProfiles")
		bConvertLine1Line2Addresses = .Fields("ConvertLine1Line2Addresses")
		intFieldCount = .Fields("FieldCount")
		intDistCount = .Fields("DistCount")
		intPubCount = .Fields("PubCount")
			
		Set dicDescriptions = Server.CreateObject("Scripting.Dictionary")
		Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
		With xmlDoc
			.async = False
			.setProperty "SelectionLanguage", "XPath"
		End With
		xmlDoc.loadXML "<DESCS>" & Nz(.Fields("Descriptions"),vbNullString) & "</DESCS>"

		For Each xmlNode in xmlDoc.selectNodes("//DESC")
			Set xmlCultureNode = xmlNode.selectSingleNode("Culture")
			If Not xmlCultureNode Is Nothing Then
				Set dicDescriptions(xmlCultureNode.text) = xmlNode
			End If
		Next

	End If
End With

Set rsProfile = rsProfile.NextRecordset
Dim strInViews, _
	bLastState

With rsProfile
	If .EOF Then
		strInViews = "<br>" & TXT_NO_OTHER_VIEWS
	Else
		bLastState = .Fields("InView")
		While Not .EOF
			strInViews = strInViews & IIf(bLastState<>.Fields("InView"),"<hr>","<br>") & _
				"<label for=""InViews_" & .Fields("ViewType") & """><input type=""checkbox"" name=""InViews"" id=""InViews_" & .Fields("ViewType") & """ value=" & attrQS(.Fields("ViewType")) & _
				Checked(.Fields("InView")) & ">&nbsp;" & _
				.Fields("ViewName") & "</label>"
			bLastState = .Fields("InView")
			.MoveNext
		Wend
	End If
End With

Set rsProfile = Nothing
Set cmdProfile = Nothing

Call makePageHeader(TXT_EDIT_PROFILE & TXT_COLON & strProfileName, TXT_EDIT_PROFILE & TXT_COLON & strProfileName, True, False, True, True)
%>

<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLinkB("export_profile.asp")%>"><%=TXT_RETURN_TO_PROFILES%></a> ]</p>
<form action="export_profile_edit2.asp" method="post" name="EntryForm">
<%=g_strCacheFormVals%>
<input type="hidden" name="ProfileID" value="<%=intProfileID%>">
<table class="BasicBorder cell-padding-4 max-width-lg">
<tr>
	<th colspan="2" class="RevTitleBox"><%=TXT_EDIT_PROFILE%></th>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_DATE_CREATED%></td>
	<td><%=strCreatedDate%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_CREATED_BY%></td>
	<td><%=strCreatedBy%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LAST_MODIFIED%></td>
	<td><%=strModifiedDate%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MODIFIED_BY%></td>
	<td><%=strModifiedBy%></td>
</tr>
<%If g_bMultiLingualActive Then %>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LANGUAGE%></td>
	<td><%=TXT_INST_EXPORT_IN_LANGUAGES%>
	<br />&nbsp;
<%
	For Each strCulture In active_cultures()
		intLangID = Application("Culture_" & strCulture & "_LangID")
		If IsLangID(intLangID) Then
			Set xmlNode = xmlDoc.selectSingleNode("//DESC[@LangID=" & Qs(intLangID,SQUOTE) & "]")
			If Not xmlNode Is Nothing Then
				dicDescriptions.Add strCulture, xmlNode
			End If
%>
		<br /><label for="ProfileCulture_<%=strCulture%>"><input type="checkbox" name="ProfileCulture" id="ProfileCulture_<%=strCulture%>" value=<%=AttrQs(strCulture)%><%=Checked(dicDescriptions.Exists(strCulture))%> />&nbsp;<%=Application("Culture_" & strCulture & "_LanguageName")%></label>
<%
		End If
	Next
%>
	</td>
</tr>
<%Else%>
<div style="display:none">
	<input type="hidden" name="ProfileCulture" value=<%=AttrQs(g_objCurrentLang.Culture)%> />
</div>
<%End If%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_NAME%></td>
	<td><%=TXT_INST_PROFILE_NAME & TXT_COLON%>
	<br />&nbsp;
	<table class="NoBorder cell-padding-2">
<%
	For Each strCulture In active_cultures()
		strValue = vbNullString
		If dicDescriptions.Exists(strCulture) Then
			Set xmlNode = dicDescriptions(strCulture)
			Set xmlNode = xmlNode.selectSingleNode("Name")
			If Not xmlNode Is Nothing Then
				strValue = xmlNode.text
			End If
		End If
%>
		<tr>
			<%If g_bMultiLingualActive Then %>
			<td class="FieldLabelLeftClr"><label for="ProfileName_<%=strCulture%>"><%=Application("Culture_" & strCulture & "_LanguageName")%></label></td>
			<%End If%>
			<td><input type="text" name="Name_<%=strCulture%>" id="ProfileName_<%=strCulture%>" value=<%=AttrQs(strValue)%> size="<%=IIf(g_bMultiLingualActive,TEXT_SIZE-10,TEXT_SIZE)%>" maxlength="100"></td>
		</tr>
<%
	Next
%>
	</table></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SOURCE_DATABASE_INFO%></td>
	<td>
	<table class="NoBorder cell-padding-2">
	<tr>
		<td class="FieldLabelLeftClr"<%=StringIf(g_bMultiLingualActive," rowspan=""" & UBound(active_cultures())+1 & """")%>><%=TXT_DB_NAME%></td>
<%
	bNewRow = False
	For Each strCulture In active_cultures()
		strValue = vbNullString
		If dicDescriptions.Exists(strCulture) Then
			Set xmlNode = dicDescriptions(strCulture)
			Set xmlNode = xmlNode.selectSingleNode("SourceDbName")
			If Not xmlNode Is Nothing Then
				strValue = xmlNode.text
			End If
		End If
		If g_bMultiLingualActive Then
			If bNewRow Then
%>
	</tr><tr>
<%		End If
%>
		<td class="FieldLabelLeftClr"><label for="SourceDbName_<%=strCulture%>"><%=Application("Culture_" & strCulture & "_LanguageName")%></label></td>
<%
		End If
%>
		<td><input type="text" name="SourceDbName_<%=strCulture%>" id="SourceDbName_<%=strCulture%>" value=<%=AttrQs(strValue)%> size="<%=IIf(g_bMultiLingualActive,TEXT_SIZE-30,TEXT_SIZE-20)%>" maxlength="255"></td>
<%
		bNewRow = True
	Next
%>
	</tr>
	<tr>
		<td class="FieldLabelLeftClr"<%=StringIf(g_bMultiLingualActive," rowspan=""" & UBound(active_cultures())+1 & """")%>><%=TXT_DB_URL%></td>
<%
	bNewRow = False
	For Each strCulture In active_cultures()
		strValue = vbNullString
		If dicDescriptions.Exists(strCulture) Then
			Set xmlNode = dicDescriptions(strCulture)
			Set xmlNode = xmlNode.selectSingleNode("SourceDbURL")
			If Not xmlNode Is Nothing Then
				strValue = xmlNode.text
			End If
		End If
		If g_bMultiLingualActive Then
			If bNewRow Then
%>
	</tr><tr>
<%		End If
%>
		<td class="FieldLabelLeftClr"><label for="SourceDbURL_<%=strCulture%>"><%=Application("Culture_" & strCulture & "_LanguageName")%></label></td>
<%
		End If
%>
		<td><input type="text" name="SourceDbURL_<%=strCulture%>" id="SourceDbURL_<%=strCulture%>" value=<%=AttrQs(strValue)%> size="<%=IIf(g_bMultiLingualActive,TEXT_SIZE-30,TEXT_SIZE-20)%>" maxlength="255">
		<input type="button" id="SourceDbURL_<%=strCulture%>_Button" value="<%=TXT_RESET%>" onClick="document.getElementById('SourceDbURL_<%=strCulture%>').value='<%="https://" & g_strBaseURLCIC%>/?Ln=<%=strCulture%>'"/></td>
<%
		bNewRow = True
	Next
%>
	</tr>
<%
Call openViewURLListRst(DM_CIC)
	If Not rsListView.EOF Then
%>
	<tr>
		<td class="FieldLabelLeftClr"<%=StringIf(g_bMultiLingualActive," colspan=""2""")%>><label for="SubmitChangesToAccessURL"><%=TXT_SUBMIT_RECORD_CHANGES_TO%></label></td>
		<td><%=makeViewDomainList(strSubmitChangesToAccessURL,"SubmitChangesToAccessURL",True)%></td>
	</tr>
<%
	End If
Call closeViewListRst()
%>
	</table>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_PRIVACY_PROFILES%></td>
	<td><label for="export_privacy"><input id="export_privacy" type="radio" name="IncludePrivacyProfiles" value="on"<%=Checked(bIncludePrivacyProfiles)%>> <%=TXT_PRIVACY_PROFILE_EXPORT%></label>
	<br><label for="skip_private_fields"><input id="skip_private_fields" type="radio" name="IncludePrivacyProfiles" value=""<%=Checked(Not bIncludePrivacyProfiles)%>> <%=TXT_PRIVACY_PROFILE_SKIP%></label></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LINE1_LINE2_HANDLING%></td>
	<td><label for="convert_line1_line2"><input id="convert_line1_line2" type="checkbox" name="ConvertLine1Line2Addresses" value="on"<%=Checked(bConvertLine1Line2Addresses)%>> <%=TXT_CONVERT_LINE1_LINE2_ADDRESSES_FOR_COMPATIBILITY%></label>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_IN_VIEWS%></td>
	<td><strong><%=TXT_INST_IN_VIEWS%></strong>
	<%=strInViews%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_INCLUDE_DATA%></td>
	<td><a href="javascript:openWinL('<%=makeLink("export_profile_edit_fields.asp","ProfileID=" & intProfileID,vbNullString)%>','fieldEdit')"><%=TXT_MANAGE_FIELDS%>&nbsp;[<%=Nz(intFieldCount,0)%>] <%=TXT_NEW_WINDOW%></a>
	<br><a href="javascript:openWinL('<%=makeLink("export_profile_edit_dists.asp","ProfileID=" & intProfileID,vbNullString)%>','fieldEdit')"><%=TXT_MANAGE_DISTRIBUTIONS%>&nbsp;[<%=Nz(intDistCount,0)%>] <%=TXT_NEW_WINDOW%></a>
	<br><a href="javascript:openWinL('<%=makeLink("export_profile_edit_pubs.asp","ProfileID=" & intProfileID,vbNullString)%>','fieldEdit')"><%=TXT_MANAGE_PUBLICATIONS%>&nbsp;[<%=Nz(intPubCount,0)%>] <%=TXT_NEW_WINDOW%></a>
	</td>
</tr>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_UPDATE%>"> <input type="submit" name="Submit" value="<%=TXT_DELETE%>"> <input type="reset" value="<%=TXT_RESET_FORM%>"></td>
</tr>
</table>
</form>

<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
