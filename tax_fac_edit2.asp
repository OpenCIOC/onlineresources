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
' Purpose: 		Process data from form to edit values for Taxonomy Facets.
'				Values are stored in table: TAX_Facet.
'				Super User privileges for CIC are required.
'
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
<!--#include file="text/txtTaxonomy.asp" -->
<%
'Ensure user has Super User privileges
If Not user_bSuperUserCIC Or Not g_bUseTaxonomy Then
	Call securityFailure()
End If

Const ACTION_UPDATE = 1
Const ACTION_DELETE = 2
Const ACTION_ADD = 3

Dim intActionType, strActionType, strError

Dim bConfirmed
bConfirmed = False

'Is this an addition, update, or deletion?
Select Case Request("Submit")
	Case TXT_UPDATE
		intActionType = ACTION_UPDATE
		strActionType = TXT_UPDATED
	Case TXT_DELETE
		bConfirmed = Request("Confirmed") = "on"
		intActionType = ACTION_DELETE
		strActionType = TXT_DELETED
	Case TXT_ADD
		intActionType = ACTION_ADD
		strActionType = TXT_ADDED
	Case Else
		Call handleError(TXT_NO_ACTION, "tax_fac_edit.asp", vbNullString)
End Select	

'Field data
Dim intFCID, _
	strFacet, _
	strDescriptions, _
	strCulture

intFCID = Trim(Request("FCID"))

strDescriptions = vbNullString
For Each strCulture In active_cultures()
	strFacet = Left(Trim(Request("Facet_" & strCulture)),255)
	If Not Nl(strFacet) Then
		strDescriptions = strDescriptions & _
			"<DESC><Culture>" & strCulture & "</Culture><Facet>" & _
			XMLEncode(strFacet) & "</Facet></DESC>"
	End If
Next
If Not Nl(strDescriptions) Then
	strDescriptions = "<DESCS>" & strDescriptions & "</DESCS>"
End If



'If the action is not an addition, confirm that a valid ID was given.
If intActionType <> ACTION_ADD Then
	If Nl(intFCID) Then
		Call handleError(TXT_NO_RECORD_CHOSEN & _
			vbCrLf & "<br>" & TXT_CHOOSE_FACET, _
			"tax_fac_edit.asp", vbNullString)
	ElseIf Not IsIDType(intFCID) Then
		Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intFCID) & "." & _
			vbCrLf & "<br>" & TXT_CHOOSE_FACET, _
			"tax_fac_edit.asp", vbNullString)
	Else
		intFCID = CLng(intFCID)
	End If
End If

'If the deletion has not been confirmed, print a form for the user to confirm
If intActionType = ACTION_DELETE And Not bConfirmed Then
	Call makePageHeader(TXT_CONFIRM_DELETE_FACET, TXT_CONFIRM_DELETE_FACET, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="FCID" value="<%=intFCID%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%
	Call makePageFooter(True)
Else

'If no basic data errors found,that will prevent the stored procedure
'from running, send the updated information to the selected procedure
If Nl(strError) Then
	Dim objReturn, objErrMsg
	Dim cmdUpdateFacet, rsUpdateFacet
	Set cmdUpdateFacet = Server.CreateObject("ADODB.Command")
	With cmdUpdateFacet
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Select Case intActionType
			Case ACTION_UPDATE
				.CommandText = "dbo.sp_TAX_Facet_u"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@FC_ID", adInteger, adParamInput, 4, intFCID)
				.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
				.Parameters.Append .CreateParameter("@Descriptions", adVarWChar, adParamInput, -1, strDescriptions)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
			Case ACTION_DELETE
				.CommandText = "dbo.sp_TAX_Facet_d"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@FC_ID", adInteger, adParamInput, 4, intFCID)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
			Case ACTION_ADD
				.CommandText = "dbo.sp_TAX_Facet_i"
				Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append objReturn
				.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
				.Parameters.Append .CreateParameter("@Descriptions", adVarWChar, adParamInput, -1, strDescriptions)
				Set objErrMsg = .CreateParameter("@ErrMsg", adVarChar, adParamOutput, 500)
				.Parameters.Append objErrMsg
		End Select
		
		Set rsUpdateFacet = .Execute
		Set rsUpdateFacet = rsUpdateFacet.NextRecordset
 
		'If the stored procedure returns an error, save the error message;
		'Otherwise, return to the Taxonomy Source Edit page.
		If objReturn.Value = 0 Then
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & strActionType, _
				"tax_fac_edit.asp", vbNullString, False)
		Else
			If Err.Number <> 0 Then
				strError = Err.Description
			Else
				strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
			End If
		End If
	End With
	
	Set rsUpdateFacet = Nothing
	Set cmdUpdateFacet = Nothing
End If

'Print any error messages
If Not Nl(strError) Then
	Call makePageHeader(TXT_UPDATE_FACET_FAILED, TXT_UPDATE_FACET_FAILED, True, False, True, True)
	Call handleError(TXT_RECORDS_WERE_NOT & strActionType & TXT_COLON & strError, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(True)
End If

End If 'Confirm Delete
%>
<!--#include file="includes/core/incClose.asp" -->
