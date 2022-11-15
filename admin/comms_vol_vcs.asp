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
Call setPageInfo(True, DM_VOL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../text/txtCommunitySets.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incVOLCommunitySetList.asp" -->

<%
If Not user_bSuperUserVOL Then
	Call securityFailure()
End If

Call makePageHeader(TXT_VOLUNTEER_COMMUNITY_SETS, TXT_VOLUNTEER_COMMUNITY_SETS, True, False, True, True)
%>
<%
Const FORM_ACTION = "<form action=""comms_vol_vcs2.asp"" method=""post"" class=""form-horizontal"">"
Dim SUBMIT_BUTTON, _
	DELETE_BUTTON, _
	ADD_BUTTON, _
	strCulture, _
	xmlDoc, _
	xmlNode, _
	strValue

SUBMIT_BUTTON = "<input class=""btn btn-default"" type=""submit"" name=""Submit"" value=""" & TXT_UPDATE & """>"
DELETE_BUTTON = "<input class=""btn btn-default"" type=""submit"" name=""Submit"" value=""" & TXT_DELETE & """>"
ADD_BUTTON = "<input class=""btn btn-default"" type=""submit"" name=""Submit"" value=""" & TXT_ADD & """>"

Call openVOLCommunitySetListRst(CSET_FULL, vbNullString)
%>
<div class="btn-group" role="group">
    <a role="button" class="btn btn-default" href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a>
    <a role="button" class="btn btn-default" href="<%=makeLinkB("comms_vol.asp")%>"><%=TXT_RETURN_TO_VC %></a>
</div>

<h2><%= TXT_EDIT_VOLUNTEER_COMMUNITY_SETS %></h2>
<p><span class="AlertBubble"><%= TXT_NOTE %>: <%= TXT_INST_DELETE %></span></p>
<%
With rsListVolCommunitySet
	If Not .EOF Then
		While Not .EOF
			Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
			With xmlDoc
				.async = False
				.setProperty "SelectionLanguage", "XPath"
			End With
			xmlDoc.loadXML "<DESCS>" & Nz(.Fields("Descriptions"),vbNullString) & "</DESCS>"
%>
<%=FORM_ACTION%>
<div style="display: none">
    <%=g_strCacheFormVals%>
    <input type="hidden" name="CommunitySetID" value="<%=.Fields("CommunitySetID")%>">
</div>
<div class="panel panel-default max-width-lg">
    <div class="panel-heading">
        <h3><%=xmlDoc.selectSingleNode("//DESC[1]").getAttribute("SetName")%></h3>
    </div>
    <div class="panel-body no-padding">
        <table class="BasicBorder cell-padding-4 full-width form-table responsive-table inset-table">
            <tr>
                <td class="field-label-cell">
                    <%=TXT_USAGE%>
                </td>
                <td class="field-data-cell">Records: <%=.Fields("UsageCountRecords")%>; Views: <%=.Fields("UsageCountViews")%>
                </td>
            </tr>
            <tr>
                <td class="field-label-cell">
                    <%=TXT_SET_NAME%>
                </td>
                <td class="field-data-cell">
                    <%
	For Each strCulture In active_cultures()
		Set xmlNode = xmlDoc.selectSingleNode("//DESC[@Culture=" & Qs(strCulture,SQUOTE) & "]")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.getAttribute("SetName")
		Else
			strValue = vbNullString
		End If
                    %>
                    <div class="form-group row">
                        <label for="SetName_<%=strCulture%>_<%=.Fields("CommunitySetID")%>" class="control-label col-sm-4 col-md-3 col-lg-2">
                            <%= Application("Culture_" & strCulture & "_LanguageName") %>
                        </label>
                        <div class="col-sm-8 col-md-9 col-lg-10">
                            <input class="form-control" type="text" id="SetName_<%=strCulture%>_<%=.Fields("CommunitySetID")%>" name="SetName_<%=strCulture%>" title=<%=AttrQs(Application("Culture_" & strCulture & "_LanguageName") & TXT_COLON & TXT_SET_NAME)%> value=<%=AttrQs(strValue)%> maxlength="100">
                        </div>
                    </div>
                    <%
	Next
                    %>
                </td>
            </tr>
            <tr>
                <td class="field-label-cell">
                    <%=TXT_AREAS_SERVED%>
                </td>
                <td class="field-data-cell">
                    <%
	For Each strCulture In active_cultures()
		Set xmlNode = xmlDoc.selectSingleNode("//DESC[@Culture=" & Qs(strCulture,SQUOTE) & "]")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.getAttribute("AreaServed")
		Else
			strValue = vbNullString
		End If
                    %>
                    <div class="form-group row">
                        <label for="AreaServed_<%=strCulture%>_<%=.Fields("CommunitySetID")%>" class="control-label col-sm-4 col-md-3 col-lg-2">
                            <%= Application("Culture_" & strCulture & "_LanguageName") %>
                        </label>
                        <div class="col-sm-8 col-md-9 col-lg-10">
                            <input class="form-control" type="text" id="AreaServed_<%=strCulture%>_<%=.Fields("CommunitySetID")%>" name="AreaServed_<%=strCulture%>" title=<%=AttrQs(Application("Culture_" & strCulture & "_LanguageName") & TXT_COLON & TXT_AREAS_SERVED)%> value=<%=AttrQs(strValue)%> maxlength="100">
                        </div>
                    </div>
                    <%
	Next
                    %>
                </td>
            </tr>
            <tr>
                <td class="field-data-cell" colspan="2">
                    <%=submit_button%><%If .Fields("UsageCountRecords") + .Fields("UsageCountViews") = 0 Then%> <%=DELETE_BUTTON%><%End If%>
                </td>
            </tr>
        </table>
    </div>
</div>
</form>
<%
			.MoveNext
		Wend
	End If
End With
Call closeVOLCommunitySetListRst()

%>
<%=FORM_ACTION%>
<div style="display: none">
    <%=g_strCacheFormVals%>
</div>

<div class="panel panel-default max-width-lg">
    <div class="panel-heading">
        <h3><%=TXT_INST_ADD%></h3>
    </div>
    <div class="panel-body no-padding">
        <table class="BasicBorder cell-padding-4 full-width form-table responsive-table inset-table">
            <tr>
                <td class="field-label-cell">
                    <%=TXT_SET_NAME%>
                </td>
                <td class="field-data-cell">
                    <%
	For Each strCulture In active_cultures()
                    %>
                    <div class="form-group row">
                        <label for="SetName_<%=strCulture%>" class="control-label col-sm-4 col-md-3 col-lg-2">
                            <%= Application("Culture_" & strCulture & "_LanguageName") %>
                        </label>
                        <div class="col-sm-8 col-md-9 col-lg-10">
                            <input class="form-control" type="text" id="SetName_<%=strCulture%>" name="SetName_<%=strCulture%>" title=<%=AttrQs(Application("Culture_" & strCulture & "_LanguageName") & TXT_COLON & TXT_SET_NAME)%> maxlength="100">
                        </div>
                    </div>
                    <%
	Next
                    %>
                </td>
            </tr>
            <tr>
                <td class="field-label-cell">
                    <%=TXT_AREAS_SERVED%>
                </td>
                <td class="field-data-cell">
                    <%
	For Each strCulture In active_cultures()
                    %>
                    <div class="form-group row">
                        <label for="AreaServed_<%=strCulture%>" class="control-label col-sm-4 col-md-3 col-lg-2">
                            <%= Application("Culture_" & strCulture & "_LanguageName") %>
                        </label>
                        <div class="col-sm-8 col-md-9 col-lg-10">
                            <input class="form-control" type="text" id="AreaServed_<%=strCulture%>" name="AreaServed_<%=strCulture%>" title=<%=AttrQs(Application("Culture_" & strCulture & "_LanguageName") & TXT_COLON & TXT_AREAS_SERVED)%> maxlength="100">
                        </div>
                    </div>
                    <%
	Next
                    %>
                </td>
            </tr>
            <tr>
                <td class="field-data-cell" colspan="2">
                    <%=add_button%>
                </td>
            </tr>
        </table>
    </div>
</div>
</form>

<%
Call makePageFooter(True)
%>



<!--#include file="../includes/core/incClose.asp" -->


