<%@  language="VBSCRIPT" %>
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
<!--#include file="../text/txtCommonForm.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../text/txtPrintProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<!--#include file="../includes/list/incFieldList.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/print/incPrintFieldTypeList.asp" -->
<%
Dim intDomain, _
	strType, _
	strDbArea

Const FTYPE_HEADING = 1
Const FTYPE_BASIC = 2
Const FTYPE_FULL = 3
Const FTYPE_CONTINUE = 4

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strDbArea = DM_S_CIC
		strType = TXT_CIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strDbArea = DM_S_VOL
		strType = TXT_VOLUNTEER
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

If Nl(intProfileID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
ElseIf Not IsIDType(intProfileID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	intProfileID = CLng(intProfileID)
End If

Dim		strProfileName

Dim cnnProfileFields, cmdProfileFields, rsProfileFields
Call makeNewAdminConnection(cnnProfileFields)
Set cmdProfileFields = Server.CreateObject("ADODB.Command")
With cmdProfileFields
	.ActiveConnection = cnnProfileFields
	.CommandText = "dbo.sp_" & strDbArea & "_PrintProfile_Fld_l"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
End With
Set rsProfileFields = cmdProfileFields.Execute

If rsProfileFields.EOF Then
	Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	strProfileName = rsProfileFields("ProfileName")
End If

Set rsProfileFields = rsProfileFields.NextRecordset

Call makePageHeader(TXT_MANAGE_FIELDS_TITLE & TXT_COLON & strProfileName, TXT_MANAGE_FIELDS_TITLE & TXT_COLON & strProfileName, True, False, True, True)
%>
<div class="btn-group" role="group">
    <a role="button" class="btn btn-default" href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a>
    <a role="button" class="btn btn-default" href="<%=makeLink("print_profile.asp","DM=" & intDomain,vbNullString)%>"><%=TXT_RETURN_TO_PROFILES%> (<%=strType%>)</a>
    <a role="button" class="btn btn-default" href="<%=makeLink("print_profile_edit.asp","ProfileID=" & intProfileID & "&DM=" & intDomain,vbNullString)%>"><%=TXT_RETURN_TO_PROFILE%> <%=strProfileName%></a>
</div>

<h2><%=TXT_MANAGE_FIELDS_TITLE%></h2>


<%
	Dim fldPFLDID, _
		fldName, _
		fldDisplay, _
		fldType, _
		fldTypeID, _
		fldHeadingLevel, _
		fldSeparator, _
		fldLabelStyle, _
		fldContentStyle, _
		fldDisplayOrder, _
		fldFindReplaceCount, _
		fldDescriptions, _
		dicDescriptions, _
		xmlDoc, _
		xmlNode, _
		xmlCultureNode,_
		strCulture, _
		strValue
	
	With rsProfileFields
		Set fldPFLDID = .Fields("PFLD_ID")
		Set fldName = .Fields("FieldName")
		Set fldDisplay = .Fields("FieldDisplay")
		Set fldType = .Fields("FieldType")
		Set fldTypeID = .Fields("FieldTypeID")
		Set fldHeadingLevel = .Fields("HeadingLevel")
		Set fldSeparator = .Fields("Separator")
		Set fldLabelStyle = .Fields("LabelStyle")
		Set fldContentStyle = .Fields("ContentStyle")
		Set fldDisplayOrder = .Fields("DisplayOrder")
		Set fldFindReplaceCount = .Fields("FindReplaceCount")
		Set fldDescriptions = .Fields("Descriptions")
	End With
	
	While Not rsProfileFields.EOF
		Set dicDescriptions = Server.CreateObject("Scripting.Dictionary")
		Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
		With xmlDoc
			.async = False
			.setProperty "SelectionLanguage", "XPath"
		End With
		xmlDoc.loadXML "<DESCS>" & Nz(fldDescriptions.Value,vbNullString) & "</DESCS>"

		For Each xmlNode in xmlDoc.selectNodes("//DESC")
			Set xmlCultureNode = xmlNode.selectSingleNode("Culture")
			If Not xmlCultureNode Is Nothing Then
				Set dicDescriptions(xmlCultureNode.text) = xmlNode
			End If
		Next


%>
<form action="print_profile_edit_fields2.asp" method="post" class="form-horizontal">
    <%=g_strCacheFormVals%>
    <input type="hidden" name="ProfileID" value="<%=intProfileID%>">
    <input type="hidden" name="DM" value="<%=intDomain%>">
    <input type="hidden" name="PFLDID" value="<%=fldPFLDID%>">
    <input type="hidden" name="FieldTypeID" value="<%=fldTypeID%>">
    <div class="panel panel-default max-width-lg">
        <div class="panel-heading">
            <h3><%=fldName.Value & StringIf(fldName.Value<>fldDisplay.Value," (" & fldDisplay.Value & ")")%></h3>
        </div>
        <div class="panel-body">
            <div class="form-group row">
                <label class="control-label col-sm-4 col-md-3 "><%=TXT_FIELD_TYPE%></label>
                <div class="col-sm-8 col-md-9"><%=fldType%></div>
            </div>
            <div class="form-group row">
                <label class="control-label col-sm-4 col-md-3 " for="DisplayOrder_<%=fldPFLDID%>"><%=TXT_ORDER%></label>
                <div class="col-sm-8 col-md-9 form-inline">
                    <input type="text" name="DisplayOrder" id="DisplayOrder_<%=fldPFLDID%>" value=<%=AttrQs(fldDisplayOrder)%> size="4" maxlength="3" class="form-control"></div>
            </div>
            <%
If fldTypeID = FTYPE_HEADING Then
            %>
            <div class="form-group row">
                <label class="control-label col-sm-4 col-md-3 " for="HeadingLevel_<%=fldPFLDID%>"><%=TXT_HEADING_LEVEL%></label>
                <div class="col-sm-8 col-md-9 form-inline">
                    <input type="text" name="HeadingLevel" id="HeadingLevel_<%=fldPFLDID%>" value=<%=AttrQs(fldHeadingLevel)%> size="2" maxlength="1" class="form-control"></div>
            </div>

            <%
End If
If fldTypeID = FTYPE_BASIC Or fldTypeID = FTYPE_FULL Then
	For Each strCulture In active_cultures()
		strValue = vbNullString
		If dicDescriptions.Exists(strCulture) Then
			Set xmlNode = dicDescriptions(strCulture)
			Set xmlNode = xmlNode.selectSingleNode("Label")
			If Not xmlNode Is Nothing Then
				strValue = xmlNode.text
			End If
		End If
            %>
            <div class="form-group row">
                <label class="control-label col-sm-4 col-md-3 " for="Label_<%= strCulture %>_<%=fldPFLDID%>"><%=TXT_FIELD_LABEL%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label>
                <div class="col-sm-8 col-md-9">
                    <input type="text" name="Label_<%=strCulture%>" id="Label_<%= strCulture %>_<%=fldPFLDID%>" value=<%=AttrQs(strValue)%> size="<%=TEXT_SIZE-15%>" maxlength="50" class="form-control"></div>
            </div>
            <% 
	Next
            %>
            <div class="form-group row">
                <label class="control-label col-sm-4 col-md-3 " for="LabelStyle_<%=fldPFLDID%>"><%=TXT_FIELD_LABEL_STYLE%></label>
                <div class="col-sm-8 col-md-9">
                    <input type="text" name="LabelStyle" id="LabelStyle_<%=fldPFLDID%>" value=<%=AttrQs(fldLabelStyle)%> size="<%=TEXT_SIZE-15%>" maxlength="50" class="form-control"></div>
            </div>
            <%
End If
If fldTypeID = FTYPE_CONTINUE Then
            %>
            <div class="form-group row">
                <label class="control-label col-sm-4 col-md-3 " for="Separator_<%=fldPFLDID%>"><%=TXT_FIELD_SEPARATOR%></label>
                <div class="col-sm-8 col-md-9">
                    <input type="text" name="Separator" id="Separator_<%=fldPFLDID%>" value=<%=AttrQs(fldSeparator)%> size="<%=TEXT_SIZE-15%>" maxlength="50" class="form-control"></div>
            </div>
            <%
Else
            %>
            <div class="form-group row">
                <label class="control-label col-sm-4 col-md-3 " for="ContentStyle_<%=fldPFLDID%>"><%=TXT_CONTENT_STYLE%></label>
                <div class="col-sm-8 col-md-9">
                    <input type="text" name="ContentStyle" id="ContentStyle_<%=fldPFLDID%>" value=<%=AttrQs(fldContentStyle)%> size="<%=TEXT_SIZE-15%>" maxlength="50" class="form-control"></div>
            </div>
            <%
End If
For Each strCulture In active_cultures()
	strValue = vbNullString
	If dicDescriptions.Exists(strCulture) Then
		Set xmlNode = dicDescriptions(strCulture)
		Set xmlNode = xmlNode.selectSingleNode("ContentIfEmpty")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.text
		End If
	End If
            %>
            <div class="form-group row">
                <label class="control-label col-sm-4 col-md-3 " for="ContentIfEmpty_<%= strCulture %>_<%=fldPFLDID%>"><%=TXT_CONTENT_IF_EMPTY%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label>
                <div class="col-sm-8 col-md-9">
                    <input type="text" name="ContentIfEmpty_<%=strCulture%>" id="ContentIfEmpty_<%= strCulture %>_<%=fldPFLDID%>" value=<%=AttrQs(strValue)%> size="<%=TEXT_SIZE-15%>" maxlength="255" class="form-control"></div>
            </div>
            <%
Next
For Each strCulture In active_cultures()
	strValue = vbNullString
	If dicDescriptions.Exists(strCulture) Then
		Set xmlNode = dicDescriptions(strCulture)
		Set xmlNode = xmlNode.selectSingleNode("Prefix")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.text
		End If
	End If
            %>
            <div class="form-group row">
                <label class="control-label col-sm-4 col-md-3 " for="Prefix_<%= strCulture %>_<%=fldPFLDID%>"><%=TXT_PREFIX%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label>
                <div class="col-sm-8 col-md-9">
                    <input type="text" name="Prefix_<%=strCulture%>" id="Prefix_<%= strCulture %>_<%=fldPFLDID%>" value=<%=AttrQs(strValue)%> size="<%=TEXT_SIZE-15%>" maxlength="100" class="form-control"></div>
            </div>
            <% 
Next
For Each strCulture In active_cultures()
	strValue = vbNullString
	If dicDescriptions.Exists(strCulture) Then
		Set xmlNode = dicDescriptions(strCulture)
		Set xmlNode = xmlNode.selectSingleNode("Suffix")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.text
		End If
	End If
            %>
            <div class="form-group row">
                <label class="control-label col-sm-4 col-md-3 " for="Suffix_<%= strCulture %>_<%=fldPFLDID%>"><%=TXT_PREFIX%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label>
                <div class="col-sm-8 col-md-9">
                    <input type="text" name="Suffix_<%=strCulture%>" id="Suffix_<%= strCulture %>_<%=fldPFLDID%>" value=<%=AttrQs(strValue)%> size="<%=TEXT_SIZE-15%>" maxlength="100" class="form-control"></div>
            </div>
            <%
Next
            %>
            <div class="form-group row">
                <label class="control-label col-sm-4 col-md-3 "><%=TXT_FIND_REPLACE%></label>
                <div class="col-sm-8 col-md-9">
                    <a href="<%=makeLink("print_profile_edit_fields_fr.asp","DM=" & intDomain & "&PFLDID=" & fldPFLDID,vbNullString)%>"><%=TXT_MANAGE_FIND_REPLACE%>&nbsp;(<%=Nz(fldFindReplaceCount.Value,0)%>)</a></div>
            </div>
            <div class="col-sm-offset-4 col-md-offset-3">
                <input class="btn btn-default" type="submit" name="Submit" value="<%=TXT_UPDATE%>"> <input class="btn btn-default" type="submit" name="Submit" value="<%=TXT_DELETE%>">
            </div>
        </div>
    </div>
</form>
<%
		rsProfileFields.MoveNext
	Wend
	rsProfileFields.Close
	Set rsProfileFields = Nothing
	Set cmdProfileFields = Nothing

%>

<hr>
<div class="max-width-md">
<form action="print_profile_edit_fields_add.asp" method="post" class="form-horizontal">
    <%=g_strCacheFormVals%>
    <input type="hidden" name="ProfileID" value="<%=intProfileID%>">
    <input type="hidden" name="DM" value="<%=intDomain%>">
    <input type="hidden" name="FieldDM" value="<%=intDomain%>">
    <h3><%=TXT_ADD_FIELD%></h3>
    <%
	Call openFieldListRst(intDomain)
    %>
    <div class="form-group row">
        <label class="control-label col-sm-3 col-md-2" for="FieldID"><%=TXT_FIELDS%></label>
        <div class="col-sm-9 col-md-10">
            <%=makeFieldList(vbNullString, "FieldID", "FieldID", True, False)%></div>
    </div>
    <%
	Call closeFieldListRst()
	Call openFieldTypeListRst()
    %>
    <div class="form-group row">
        <label class="control-label col-sm-3 col-md-2" for="FieldTypeID"><%=TXT_FIELD_TYPE%></label>
        <div class="col-sm-9 col-md-10">
            <%=makeFieldTypeList(vbNullString, "FieldTypeID", "FieldTypeID", False)%></div>
    </div>
    <%
	Call closeFieldTypeListRst()
        %>
    <div class="col-sm-offset-3 col-md-offset-2">
        <input class="btn btn-default" type="submit" name="Submit" value="<%=TXT_ADD_FIELD%>">
    </div>
</form>
</div>

<%If intDomain = DM_VOL Then%>
<hr>
<div class="max-width-md">
<form action="print_profile_edit_fields_add.asp" method="post" class="form-horizontal">
    <%=g_strCacheFormVals%>
    <input type="hidden" name="ProfileID" value="<%=intProfileID%>">
    <input type="hidden" name="DM" value="<%=intDomain%>">
    <input type="hidden" name="FieldDM" value="<%=DM_GLOBAL%>">
    <h3><%=TXT_ADD_FIELD%> (<%=TXT_ORGANIZATION%>)</h3>
    <%
	Call openFieldListRst(Null)
    %>
    <div class="form-group row">
        <label class="control-label col-sm-3 col-md-2" for="OrgFieldID"><%=TXT_FIELDS%></label>
        <div class="col-sm-9 col-md-10">
            <%=makeFieldList(vbNullString, "FieldID", "OrgFieldID", True, False)%></div>
    </div>
    <%
	Call closeFieldListRst()
	Call openFieldTypeListRst()
    %>
    <div class="form-group row">
        <label class="control-label col-sm-3 col-md-2" for="OrgFieldTypeID"><%=TXT_FIELD_TYPE%></label>
        <div class="col-sm-9 col-md-10">
            <%=makeFieldTypeList(vbNullString, "FieldTypeID", "OrgFieldTypeID", False)%></div>
    </div>
    <%
	Call closeFieldTypeListRst()
        %>
    <div class="col-sm-offset-3 col-md-offset-2">
        <input class="btn btn-default" type="submit" name="Submit" value="<%=TXT_ADD_FIELD%>">
    </div>
</form>
</div>
<%End If%>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
