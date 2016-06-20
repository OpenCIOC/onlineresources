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
' Purpose: 		Process data from form to edit values for Taxonomy Related Concepts.
'				Values are stored in table: TAX_RelatedConcept.
'				Super User privileges for CIC are required.
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
' setPageInfo(bLogin, bAdd, bUpdate, bUserCIC, bUserVol, bUserFb, bSuperUser, bSubjectAdmin, bPubAdmin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtTaxonomy.asp" -->
<!--#include file="text/txtFormDataCheck.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/validation/incFormDataCheck.asp" -->
<%
If Not user_bSuperUserGlobalCIC Or Not g_bUseTaxonomy Then
	Call securityFailure()
End If

'On Error Resume Next

Sub checkConceptCode(strFldVal)
	If Not Nl(strFldVal) Then
		If Not reEquals(strFldVal,"([A-Z]{2}(\-[0-9]{3})?)",True,False,True,False) Then
			strErrorList = strErrorList & "<li>" & strFldVal & TXT_NOT_VALID_CONCEPT_CODE & "</li>"
		End If
	End If
End Sub

'Error variables
Dim strErrorList

Dim bNew
bNew = False

'Data Fields
Dim	intRCID, _
	strCode, _
	intSource, _
	bAuthorized, _
	strConceptName, _
	strDescriptions, _
	strCulture

'Which Concept are we editing?
intRCID = Trim(Request("RCID"))
If Nl(intRCID) Then
	'New Concept
	bNew = True
	intRCID = Null
ElseIf Not IsIDType(intRCID) Then
	'If this is not a new Concept and this is an invalid ID, 
	'Return to the Taxonomy Management page and print an error.
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intRCID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_SUBJECT, _
		"tax_mng.asp", vbNullString)
Else
	intRCID = CLng(intRCID)
End If

'Process the request to delete the selected Concept
If Request("Submit") = TXT_DELETE Then
	Call goToPage("tax_rc_delete.asp","RCID=" & intRCID,vbNullString)
End If

strCode = Trim(Request("Code"))
Call checkConceptCode(strCode)

strDescriptions = vbNullString
For Each strCulture In active_cultures()
	strConceptName = Left(Trim(Request("ConceptName_" & strCulture)),100)
	If Not Nl(strConceptName) Then
		strDescriptions = strDescriptions & _
			"<DESC><Culture>" & strCulture & "</Culture><ConceptName>" & _
			XMLEncode(strConceptName) & "</ConceptName></DESC>"
	End If
Next
If Not Nl(strDescriptions) Then
	strDescriptions = "<DESCS>" & strDescriptions & "</DESCS>"
End If

bAuthorized = Request("Authorized") = "on"

'Fetch Concept Source ID, confirm it is valid
intSource = Request("Source")
If Nl(intSource) Then
	intSource = Null
Else
	Call checkID(TXT_TAX_SOURCE,intSource)
End If

'If there are errors identified, print the list of errors
If Not Nl(strErrorList) Then
	Call makePageHeader(TXT_UPDATE_CONCEPT_FAILED, TXT_UPDATE_CONCEPT_FAILED, True, False, True, True)
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & "<ul>" & strErrorList & "</ul>", _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(True)
Else
	'If no basic data errors found,that will prevent the stored procedure
	'from running, send the updated information to the selected procedure
	Dim cmdUpdateConcept, rsUpdateConcept
	Set cmdUpdateConcept = Server.CreateObject("ADODB.Command")
	With cmdUpdateConcept 	
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_RelatedConcept_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append .CreateParameter("@RCID", adInteger, adParamInputOutput, 4, intRCID)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@Code", adChar, adParamInput, 6, strCode)
		.Parameters.Append .CreateParameter("@Source", adInteger, adParamInput, 4, intSource)
		.Parameters.Append .CreateParameter("@Authorized", adBoolean, adParamInput, 1, IIf(bAuthorized,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@Descriptions", adVarWChar, adParamInput, -1, strDescriptions)
		.Parameters.Append .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	End With
	Set rsUpdateConcept = cmdUpdateConcept.Execute
	Set rsUpdateConcept = rsUpdateConcept.NextRecordset

	'If there was no error from running the stored procedure, return to the Related Concept page;
	'Otherwise, grab the error message if any so it can be printed to the user.
	If cmdUpdateConcept.Parameters("@RETURN_VALUE").Value = 0 And Err.Number = 0 Then
		If bNew Then
			intRCID = cmdUpdateConcept.Parameters("@RCID").Value
		End If
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
				"tax_rc_edit.asp", _
				"RCID=" & intRCID, _
				False)
	Else
		'There was an error executing the stored procedure.
		'Print any error messages from the ASP or Stored Procedure
		Dim strErrorMessage
		If Err.Number <> 0 Then
			strErrorMessage = Err.Description
		Else
			strErrorMessage = cmdUpdateConcept.Parameters("@ErrMsg").Value
		End If
		Call makePageHeader(TXT_UPDATE_CONCEPT_FAILED, TXT_UPDATE_CONCEPT_FAILED, True, False, True, True)
		Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & strErrorMessage, _
			vbNullString, _
			vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
		Call makePageFooter(True)
	End If
End If
%>
<!--#include file="includes/core/incClose.asp" -->
