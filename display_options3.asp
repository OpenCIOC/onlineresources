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
<!--#include file="includes/core/adovbs.inc" -->
<!--#include file="includes/core/incVBUtils.asp" -->
<!--#include file="includes/validation/incBasicTypes.asp" -->
<!--#include file="includes/core/incRExpFuncs.asp" -->
<!--#include file="includes/core/incHandleError.asp" -->
<!--#include file="includes/core/incSetLanguage.asp" -->
<!--#include file="includes/core/incPassVars.asp" -->
<!--#include file="text/txtGeneral.asp" -->
<!--#include file="text/txtError.asp" -->
<!--#include file="includes/core/incConnection.asp" -->
<!--#include file="includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtDisplay.asp" -->
<!--#include file="includes/core/incOrderByConst.asp" -->
<!--#include file="includes/display/incCICDisplayOptionsFields.asp" -->
<%
Call makePageHeader(TXT_CHANGE_RESULTS_DISPLAY, TXT_CHANGE_RESULTS_DISPLAY, False, True, True, False)

Dim strCustFld
If Not Nl(getSessionValue("opt_fld_aCustCIC")) Then
	strCustFld = getSessionValue("opt_fld_aCustCIC")
Else
	strCustFld = Null
End If

Call saveDisplayOptionsCIC( _
	user_intID, _
	vbNullString, _
	Nz(getSessionValue("opt_fld_bNUM"),False), _
	Nz(getSessionValue("opt_fld_bRecordOwnerCIC"),False), _
	Nz(getSessionValue("opt_fld_bAlertCIC"),g_bAlertColumnCIC), _
	Nz(getSessionValue("opt_fld_bOrgCIC"),True), _
	Nz(getSessionValue("opt_fld_bLocated"),True), _
	Nz(getSessionValue("opt_fld_bUpdateScheduleCIC"),False), _
	Nz(getSessionValue("opt_bUpdateCIC"),False), _
	Nz(getSessionValue("opt_bEmailCIC"),False), _
	Nz(getSessionValue("opt_bSelectCIC"),False), _
	Nz(getSessionValue("opt_bWebCIC"),False), _
	Nz(getSessionValue("opt_bListAddRecordCIC"),False), _
	NlNl(getSessionValue("opt_intOrderByCIC")), _
	NlNl(getSessionValue("opt_fld_intCustOrderCIC")), _
	Nz(getSessionValue("opt_bOrderByDescCIC"),False), _
	Nz(getSessionValue("opt_bMail"),False), _
	Nz(getSessionValue("opt_bPub"),False), _
	NlNl(strCustFld) _
	)
	
Call handleMessage(TXT_SETTINGS_SAVED, _
		vbNullString, vbNullString, False)
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a><%= makePageHelpLink() %> ]</p>
<%
Call makePageFooter(False)
%>
<!--#include file="includes/core/incClose.asp" -->
