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
'
' Purpose: 		Display the form for editing an existing Taxonomy Term, or creating a new Term
'
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
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtTaxonomy.asp" -->
<!--#include file="text/txtTaxPreferred.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/taxonomy/incTaxConceptList.asp" -->
<%
'Ensure user has super user privileges
If Not user_bSuperUserGlobalCIC Or Not g_bUseTaxonomy Then
	Call securityFailure()
End If

Call makePageHeader(TXT_MANAGE_PREFERRED_TERM_LIST, TXT_MANAGE_PREFERRED_TERM_LIST, True, False, True, True)
%>
<p>[ <a href="<%=makeLinkB("tax_mng.asp")%>"><%=TXT_RETURN_MANAGE_TAXONOMY%></a> ]</p>

<%
Dim strTermList, _
	bRefreshAll

strTermList = Trim(Request("TermList"))
strTermList = reReplace(strTermList,"(\s|,|;|\n|\r)+", ",", False, False, True, False)
strTermList = reReplace(strTermList, "(^,+)|(,+$)", vbNullString, False, False, True, False)



bRefreshAll = Request("RefreshAll") = "on"

If Nl(strTermList) Or Not IsTaxCodeList(strTermList) Then
	Call handleError(TXT_ERROR & TXT_ENTER_LIST_OF_TERMS, vbNullString, vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
Else
	Dim objReturn, objErrMsg

	Dim cmdPreferredTerm, rsPreferredTerm
	Set cmdPreferredTerm = Server.CreateObject("ADODB.Command")

	With cmdPreferredTerm 	
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_Term_u_Preferred"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@CodeList", adVarWChar, adParamInput, -1, strTermList)
		.Parameters.Append .CreateParameter("@ResetList", adBoolean, adParamInput, 1, IIf(bRefreshAll,SQL_TRUE,SQL_FALSE))
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With

	Set rsPreferredTerm = cmdPreferredTerm.Execute
	Set rsPreferredTerm = rsPreferredTerm.NextRecordset

	'If there was no error from running the stored procedure, process Use Reference data;
	'Otherwise, grab the error message if any so it can be printed to the user.
	If objReturn.Value = 0 Then
		Call handleMessage(TXT_PREFERRED_TERM_LIST_UPDATED, _
				vbNullString, _
				vbNullString, _
				False)
	Else
		'There was an error executing the stored procedure.
		'Print any error messages from the ASP or Stored Procedure
		Call handleError(TXT_ERROR & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			vbNullString, _
			vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	End If
End If
 %>


<%
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
