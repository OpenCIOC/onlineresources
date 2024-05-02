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
Call setPageInfo(False, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtAgencyContact.asp" -->
<!--#include file="../text/txtCommonForm.asp" -->
<!--#include file="../text/txtDetails.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtFormSecurity.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMonth.asp" -->
<!--#include file="../text/txtVolunteer.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incMonthList.asp" -->
<!--#include file="../includes/referral/incYesVolOpInfo.asp" -->
<!--#include file="../includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="../includes/vprofile/incProfileSecurity.asp" -->
<%
Dim strVNUM, _
        bVNUMError

bVNUMError = False
strVNUM = Request("VNUM")

Call makePageHeader(TXT_YES_VOLUNTEER, TXT_YES_VOLUNTEER, True, False, True, True)

If Nl(strVNUM) Then
        bVNUMError = True
        Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
ElseIf Not IsVNUMType(strVNUM) Then
        bVNUMError = True
        Call handleError(TXT_INVALID_OPID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
End If

If Not bVNUMError Then
        Call setOpInfo()
        If Nl(strPosition) Then
                Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strVNUM) & ".", vbNullString, vbNullString)
        ElseIf Not (bInView Or bInDefaultView) Then
                Call handleError(TXT_ERROR & TXT_RECORD_YOU_REQUESTED & TXT_RECORD_EXISTS_BUT, vbNullString, vbNullString)
%>
<p><%=TXT_CONCERNS & TXT_COLON%><strong><%=strROName%></strong></p>
<%
                Call getROInfo(strRecordOwner,DM_VOL)
                Call printROContactInfo(False)
        ElseIf bExpired Then
                Call handleError(TXT_ERROR & TXT_RECORD_YOU_REQUESTED & " " & TXT_HAS_EXPIRED, vbNullString, vbNullString)
%>
<p><%=TXT_CONCERNS & TXT_COLON%><strong><%=strROName%></strong></p>
<%
                Call getROInfo(strRecordOwner,DM_VOL)
                Call printROContactInfo(False)
        Else
                Call getROInfo(strRecordOwner,DM_VOL)
                Dim dicContactInfo
                Set dicContactInfo = Server.CreateObject("Scripting.Dictionary")
                If vprofile_bLoggedIn Then

                        Dim objReturn, objErrMsg
                        Dim cmdProfileInfo, rsProfileInfo
                        Set cmdProfileInfo = Server.CreateObject("ADODB.Command")
                        With cmdProfileInfo
                                .ActiveConnection = getCurrentVOLBasicCnn()
                                .CommandText = "sp_VOL_Profile_s_ReferralForm"
                                .CommandType = adCmdStoredProc
                                .CommandTimeout = 0
                                Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
                                .Parameters.Append objReturn
                                .Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, vprofile_strID)
                                Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
                                .Parameters.Append objErrMsg
                        End With
                        Set rsProfileInfo = cmdProfileInfo.Execute()

                        Dim objField
                        For Each objField in rsProfileInfo.Fields
                                dicContactInfo(objField.Name) = objField.Value
                        Next

                        rsProfileInfo.Close()
                        Set rsProfileInfo = Nothing
                        Set cmdProfileInfo = Nothing
                End If
%>
<div class="panel panel-info">
    <div class="panel-body">
        <h4><%= TXT_SUBMITTING_INFORMATION_FOR %></h4>
        <h3><a href="<%=makeVOLDetailsLink(strVNUM, IIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber,vbNullString),vbNullString)%>"><%=strPosition%> (<%=strOrgName%>)</a></h3>
        <%If Not Nl(strDuties) Then%>
        <button class="btn btn-info" type="button" data-toggle="collapse" data-target="#collapseDuties" aria-expanded="false" aria-controls="collapseDuties">
            <%=TXT_DISPLAY_POSITION_DUTIES%>
        </button>
        <div class="collapse" id="collapseDuties">
            <p><%=strDuties%></p>
        </div>
        <%End If%>
    </div>
</div>
<p class="Info"><%=TXT_INST_DIFFICULTIES_CONTACT%></p>
<%
Call printROContactInfo(False)
Dim strProfileLoginReturnArgs
strProfileLoginReturnArgs = "VNUM=" & strVNUM
%>
<form name="EntryForm" id="EntryForm" action="volunteer2.asp" role="form" method="POST" class="form">
    <%=g_strCacheFormVals%>
    <input type="hidden" name="VNUM" value="<%=strVNUM%>">
    <%If intCurSearchNumber >= 0 Then%>
    <input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
    <%
        strProfileLoginReturnArgs = strProfileLoginReturnArgs & "&Number=" & intCurSearchNumber
    %>
    <%End If%>
    <div class="panel panel-default max-width-lg clear-line-below">
        <div class="panel-heading">
            <h3><span class="glyphicon glyphicon-user" aria-hidden="true"></span> <%=TXT_VOLUNTEER_FORM %></h3>
        </div>
        <div class="panel-body no-padding">
            <table class="BasicBorder cell-padding-4 form-table responsive-table inset-table">
                <tr>
                    <td colspan="2" class="field-data-cell" style="text-align:center;">
                        <p class="AlertBubble"><span class="glyphicon glyphicon-star" aria-hidden="true"></span><%=TXT_INST_FILL_FORM%></p>
<%
If Not user_bLoggedIn And g_bUseProfilesView And Not vprofile_bLoggedIn Then
        Dim strProfileLoginReturnParams
        strProfileLoginReturnParams = "page="& Server.URLEncode(ps_strThisPageFull) & "&args=" & Server.URLEncode(strProfileLoginReturnArgs)
%>
                        <p><strong><em><%= TXT_DO_YOU_HAVE_PROFILE %></em></strong> <a class="btn btn-info" href="<%=makeLink("profile/login.asp", strProfileLoginReturnParams, vbNullString)%>"><%=TXT_LOGIN_TO_YOUR_VOLUNTEER_PROFILE %></a> <%=TXT_OR%> <a class="btn btn-info" href="<%=makeLink("profile/create.asp", strProfileLoginReturnParams, vbNullString)%>"><%= TXT_CREATE_A_PROFILE_NEW %></a></p>
<%
End If
%>
                    </td>
                </tr>
                <tr>
                    <td class="field-label-cell">
                        <label for="VolunteerName"><%=TXT_NAME%> <span class="Alert" title="<%=TXT_REQUIRED%>"><span class="glyphicon glyphicon-star" aria-hidden="true"></span></span></label>
                    </td>
                    <td class="field-data-cell">
                        <input type="Text" name="VolunteerName" id="VolunteerName" maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(dicContactInfo("FirstName")) & StringIf(Not Nl(dicContactInfo("FirstName")) And Not Nl(dicContactInfo("LastName"))," ") & Ns(dicContactInfo("LastName"))))%> class="form-control<%=StringIf(not user_bLoggedIn, " required")%>" aria-required="true">
                    </td>
                </tr>
                <tr>
                    <td class="field-label-cell">
                        <label for="VolunteerEmail"><%=TXT_EMAIL%> <span class="Alert" title="<%=TXT_REQUIRED%>"><span class="glyphicon glyphicon-star" aria-hidden="true"></span></span></label>
                    </td>
                    <td class="field-data-cell">
                        <input type="Text" name="VolunteerEmail" id="VolunteerEmail" maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(vprofile_strEmail)))%> class="form-control single-email<%=StringIf(not user_bLoggedIn, " required-contact")%>" aria-required="true">
                    </td>
                </tr>
                <tr>
                    <td class="field-label-cell">
                        <label for="VolunteerPhone"><%=TXT_PHONE%></label>
                    </td>
                    <td class="field-data-cell">
                        <input type="Text" name="VolunteerPhone" id="VolunteerPhone" maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(dicContactInfo("Phone"))))%> class="form-control<%=StringIf(not user_bLoggedIn, " required-contact")%>"></td>
                </tr>
                <tr>
                    <td class="field-label-cell"><%=TXT_ADDRESS%></td>
                    <td class="field-data-cell form-horizontal">
                        <div class="row form-group">
                            <label class="control-label col-sm-3" for="VolunteerAddress"><%=TXT_ADDRESS%></label>
                            <div class="col-sm-9">
                                <input type="Text" name="VolunteerAddress" id="VolunteerAddress" maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(dicContactInfo("Address"))))%> class="form-control">
                            </div>
                        </div>
                        <div class="row form-group">
                            <label class="control-label col-sm-3" for="VolunteerCity"><%=TXT_CITY%> <span class="Alert" title="<%=TXT_REQUIRED%>"><span class="glyphicon glyphicon-star" aria-hidden="true"></span></span></label>
                            <div class="col-sm-9">
                                <input type="Text" name="VolunteerCity" id="VolunteerCity" maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(dicContactInfo("City"))))%> class="form-control required" aria-required="true">
                            </div>
                        </div>
                        <div class="row form-group">
                            <label class="control-label col-sm-3" for="VolunteerPostalCode"><%=TXT_POSTAL_CODE%></label>
                            <div class="col-sm-9 form-inline">
                                <input type="Text" name="VolunteerPostalCode" id="VolunteerPostalCode" maxlength="10" value=<%=AttrQs(Server.HTMLEncode(Ns(dicContactInfo("PostalCode"))))%> class="form-control">
                            </div>
                        </div>
                    </td>
                </tr>
                <%If Not (Nl(strAppQ1) And Nl(strAppQ2) And Nl(strAppQ3)) Then%>
                <tr>
                    <td class="field-label-cell">
                        <label for="VolunteerPhone"><%=TXT_OTHER_INFO%></label>
                    </td>
                    <td class="field-data-cell">
                        <p><em><%=strOrgName & TXT_SUPPLIED_QUESTONS%></em></p>

                        <%If Not Nl(strAppQ1) Then%>
                        <input type="hidden" name="Question1" value=<%=AttrQs(strAppQ1)%>>
                        <div class="form-group">
                            <label for="Question1Answer" class="control-label"><%=strAppQ1%></label> <span class="SmallNote"><%=TXT_INST_MAX_4000%></span>
                            <textarea name="Question1Answer" id="Question1Answer" class="form-control" rows="<%=TEXTAREA_ROWS_XLONG%>" maxlength="4000"></textarea>
                        </div>
                        <%End If%>

                        <%If Not Nl(strAppQ2) Then%>
                        <input type="hidden" name="Question2" value=<%=AttrQs(strAppQ2)%>>
                        <div class="form-group">
                            <label for="Question2Answer" class="control-label"><%=strAppQ2%></label> <span class="SmallNote"><%=TXT_INST_MAX_4000%></span>
                            <textarea name="Question2Answer" id="Question2Answer" class="form-control" rows="<%=TEXTAREA_ROWS_XLONG%>" maxlength="4000"></textarea>
                        </div>
                        <%End If%>

                        <%If Not Nl(strAppQ3) Then%>
                        <input type="hidden" name="Question3" value=<%=AttrQs(strAppQ3)%>>
                        <div class="form-group">
                            <label for="Question3Answer" class="control-label"><%=strAppQ3%></label> <span class="SmallNote"><%=TXT_INST_MAX_4000%></span>
                            <textarea name="Question3Answer" id="Question3Answer" class="form-control" rows="<%=TEXTAREA_ROWS_XLONG%>" maxlength="4000"></textarea>
                        </div>
                        <%End If%>
                    </td>
                </tr>
                <%End If%>
                <tr>
                    <td class="field-label-cell">
                        <label for="VolunteerNotes"><%=TXT_NOTES_COMMENTS%></label></td>
                    <td class="field-data-cell">
                        <p><%= TXT_INST_NOTES_1 %> <%If Not Nl(strROName) Then%> <strong><%=strROName%></strong> <%=TXT_OR_LC%> <%End If%><strong><%=strOrgName%></strong> <%=TXT_INST_NOTES_2%> <span class="SmallNote"><%=TXT_INST_MAX_4000%></p>
                        <textarea name="VolunteerNotes" id="VolunteerNotes" class="form-control" rows="<%=TEXTAREA_ROWS_XLONG%>" maxlength="4000"></textarea>
                    </td>
                </tr>
            </table>
        </div>
    </div>

    <%Call printSurveyInfo()%>

    <%If Not user_bLoggedIn And Not vprofile_bLoggedIn Then%>
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3><span class="fa fa-lock" aria-hidden="true"></span> <%=TXT_SECURITY_CHECK%></h3>
        </div>
        <div class="panel-body">
            <p><%=TXT_INST_SECURITY_CHECK%></p>
            <p><span class="Alert"><span class="glyphicon glyphicon-star" aria-hidden="true"></span> <%=TXT_REQUIRED%></span><%=TXT_COLON & TXT_ENTER_TOMORROWS_DATE%></p>
            <div class="form-inline">
                <div class="form-group">
                    <label for="sCheckDay" class="control-label"><%=TXT_DAY%></label>
                     <input id="sCheckDay" name="sCheckDay" type="text" size="5" maxlength="8" class="form-control">
                </div>
                <div class="form-group">
                    <label for="sCheckMonth" class="control-label"><%=TXT_MONTH%></label>
                     <%Call printMonthList("sCheckMonth")%>
                </div>
                <div class="form-group">
                    <label for="sCheckYear" class="control-label"><%=TXT_YEAR%></label>
                    <input id="sCheckYear" name="sCheckYear" type="text" size="5" maxlength="8" class="form-control">
                </div>
            </div>
        </div>
    </div>
    <%End If%>

    <p>
        <input type="submit" value="<%=TXT_SUBMIT%>" class="btn btn-default">
        <input type="reset" value="<%=TXT_RESET_FORM%>" class="btn btn-default">
    </p>
</form>
    <%
        End If
End If
    %>
    <%= makeJQueryScriptTags() %>
    <%= JSVerScriptTag("scripts/volunteer.js") %>
<script type="text/javascript">
jQuery(function($) {
    var form = init_client_validators('#EntryForm');
    var rules = Object.fromEntries(
        $('.required-contact').get().map(
           function(current) { return [current.id, {require_from_group: [1, '.required-contact'] }]; }
        )
    );
    var validator = form.validate({
        ignore: 'input[type=hidden]',
        ignoreTitle: true,
        rules: rules,
        focusInvalid: false, onfocusout: false,
        onkeyup: false, onclick: false
    });
	init_community_autocomplete($, "VolunteerCity", "<%= makeLinkB(ps_strPathToStart & "jsonfeeds/community_generator.asp") %>", 3);
});
</script>
    <%
Call makePageFooter(True)
    %>
    <!--#include file="../includes/core/incClose.asp" -->
