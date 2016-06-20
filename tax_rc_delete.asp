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
' Purpose:		Delete existing Related Concept
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
' setPageInfo(bLogin, bAdd, bUpdate, bUserCIC, bUserVol, bUserFb, bSuperUser, bConceptAdmin, bPubAdmin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
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
If Not user_bSuperUserGlobalCIC Or Not g_bUseTaxonomy Then
	Call securityFailure()
End If

'Determine which Concept to delete
'If there is no Concept ID, or it is not a valid ID, return to
'the Taxonomy Management page and print an error message.
Dim intRCID
intRCID = Trim(Request("RCID"))
If Nl(intRCID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_CONCEPT, _
		"tax_mng.asp", vbNullString)
ElseIf Not IsIDType(intRCID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intRCID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_CONCEPT, _
		"tax_mng.asp", vbNullString)
Else
	intRCID = CLng(intRCID)

	'Has this deletion been confirmed by the user?
	Dim bConfirmed
	bConfirmed = Request("Confirmed") = "on"

	'If the deletion has not been confirmed, print a form for the user to confirm
	If Not bConfirmed Then
		Call makePageHeader(TXT_CONFIRM_DELETE_CONCEPT, TXT_CONFIRM_DELETE_CONCEPT, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE_CONCEPT%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="RCID" value="<%=intRCID%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" value="<%=TXT_DELETE%>">
</form>
<%
		Call makePageFooter(True)
	Else
		'The user has confirmed; Delete the Concept
		Dim objReturn, objErrMsg
		Dim cmdDeleteConcept, rsDeleteConcept
		Set cmdDeleteConcept = Server.CreateObject("ADODB.Command")
		With cmdDeleteConcept
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_TAX_RelatedConcept_d"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
			.Parameters.Append objReturn
			.Parameters.Append .CreateParameter("@RCID", adInteger, adParamInput, 4, intRCID)
			Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
			.Parameters.Append objErrMsg
		End With
		Set rsDeleteConcept = cmdDeleteConcept.Execute
		Set rsDeleteConcept = rsDeleteConcept.NextRecordset
		
		Select Case objReturn.Value
			Case 0
				Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
					"tax_mng.asp", _
					vbNullString, _
					False)
			Case Else
				Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
					"tax_rc_edit.asp", _
					"RCID=" & intRCID)
		End Select
	End If

End If
%>
<!--#include file="includes/core/incClose.asp" -->
