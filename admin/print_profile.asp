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
<!--#include file="../text/txtPrintProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/print/incPrintProfileList.asp" -->
<%
Dim intDomain, _
	strType

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strType = TXT_CIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Call makePageHeader(TXT_MANAGE_PROFILES & " (" & strType & ")", TXT_MANAGE_PROFILES & " (" & strType & ")", True, True, True, True)
%>
<div class="btn-group" role="group">
    <a role="button" class="btn btn-default" href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a>
</div>
<hr />
<div class="max-width-md">
    <form action="print_profile_edit.asp" method="get" class="form-horizontal form-inline">
        <%=g_strCacheFormVals%>
        <input type="hidden" name="DM" value="<%=intDomain%>">
        <h4>
            <label for="ProfileID"><%=TXT_EDIT_PROFILE%> (<%=strType%>)</label></h4>
        </tr>
        <%
Call openPrintProfileListRst(intDomain, Null)
        %>
        <%=makePrintProfileList(vbNullString,"ProfileID","ProfileID",False)%>
        <input class="btn btn-default" type="submit" value="<%=TXT_VIEW_EDIT_PROFILE%>">
    </form>
    <hr>
    <form action="print_profile_add.asp" method="post" class="form-horizontal">
        <%=g_strCacheFormVals%>
        <input type="hidden" name="DM" value="<%=intDomain%>">
        <h4><%=TXT_CREATE_PROFILE%> (<%=strType%>)</h4>
        <p><%=TXT_INST_ADD_PROFILE%></p>
        <div class="form-group row">
            <label class="control-label col-sm-3 col-md-2" for="ProfileName"><%=TXT_NAME%></label>
            <div class="col-sm-9 col-md-10"><input type="text" name="ProfileName" id="ProfileName" size="50" maxlength="50" class="form-control"></div>
        </div>
        <div class="form-group row">
            <label class="control-label col-sm-3 col-md-2" for="NewProfileID"><%=TXT_COPY_PROFILE%></label>
            <div class="col-sm-9 col-md-10"><%=makePrintProfileList(vbNullString,"ProfileID","NewProfileID",True)%></div>
        </div>
        <div class="col-sm-offset-3 col-md-offset-2">
            <input class="btn btn-default" type="submit" value="<%=TXT_ADD_PROFILE%>">
        </div>
    </form>
</div>
<%
Call closePrintProfileListRst()
%>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
