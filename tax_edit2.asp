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
' Purpose: 		Process data from form to edit values for Taxonomy Terms.
'				Values are stored in tables: TAX_Term, TAX_Unused, TAX_TM_RC.
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
<!--#include file="includes/taxonomy/incCheckTaxonomy.asp" -->
<!--#include file="includes/taxonomy/incTaxUpdateUseRef.asp" -->
<!--#include file="includes/validation/incFormDataCheck.asp" -->
<%
If Not user_bSuperUserGlobalCIC Or Not g_bUseTaxonomy Then
	Call securityFailure()
End If

'On Error Resume Next
Server.ScriptTimeOut = 900

Dim strErrorList, _
	strTmpError
	
Dim strBadUseRefs, _
	strBadUseRefCon

Dim bNew
bNew = False

'Data fields
Dim	intTMID, _
	strCode, _
	strCdLvl1, _
	strCdLvl2, _
	strCdLvl3, _
	strCdLvl4, _
	strCdLvl5, _
	strCdLvl6, _
	intSource, _
	bAuthorized, _
	intFacet, _
	strIconURL, _
	strIconURLProto, _
	bActive, _
	strSeeAlsoTCList, _
	strSeeAlsoAuthList, _
	strRelatedConceptList, _
	strRelatedConceptAuthList, _
	strDescriptions, _
	strDesc, _
	strCulture, _
	strField, _
	strValue

'Which term are we editing?
intTMID = Trim(Request("TMID"))
If Nl(intTMID) Then
	'New Term
	bNew = True
	intTMID = Null
ElseIf Not IsIDType(intTMID) Then
	'If this is not a new Term and this is an invalid ID, 
	'Return to the Taxonomy Management page and print an error.
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intTMID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_TERM, _
		"tax_mng.asp", vbNullString)
Else
	intTMID = CLng(intTMID)
End If

'Which Term are we editing? (for delete)
strCode = Trim(Request("TC"))
If Nl(strCode) Then
	strCode = Null
ElseIf Not IsTaxonomyCodeType(strCode) Then
	'The Code is not a valid Taxonomy Code
	Call handleError(TXT_INVALID_CODE & strCode & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_TERM, _
		"tax_mng.asp", vbNullString)
		strCode = Null
End If

'Process the request to delete the selected Term
If Request("Submit") = TXT_DELETE Then
	Call goToPage("tax_delete.asp","TC=" & strCode,vbNullString)
End If

'Fetch Code data
strCdLvl1 = UCase(Trim(Request("CdLvl1")))
strCdLvl2 = UCase(Trim(Request("CdLvl2")))
strCdLvl3 = Trim(Request("CdLvl3"))
strCdLvl4 = Trim(Request("CdLvl4"))
strCdLvl5 = Trim(Request("CdLvl5"))
strCdLvl6 = Trim(Request("CdLvl6"))
'Confirm the Code parts make a valid Code
Call checkTaxonomyCode(strCdLvl1,strCdLvl2,strCdLvl3,strCdLvl4,strCdLvl5,strCdLvl6)

'Fetch Term Source ID, confirm it is valid
intSource = Request("Source")
If Nl(intSource) Then
	intSource = Null
Else
	Call checkID(TXT_TAX_SOURCE,intSource)
End If

bAuthorized = Request("Authorized") = "on"

intFacet = Request("Facet")
If Nl(intFacet) Then
	intFacet = Null
Else
	Call checkID(TXT_FACET,intFacet)
End If

strIconURL = Trim(Request("IconURL"))
Call checkWebWithProtocol(TXT_ICON_URL, strIconURL, strIconURLProto)
strIconURL = Ns(strIconURLProto) & strIconURL 

bActive = Request("Active")
If Nl(bActive) Then
	bActive = Null
End If

strDescriptions = vbNullString
Dim bTermNull, dicNames
Set dicNames = Server.CreateObject("Scripting.Dictionary")

dicNames("Definition") = TXT_DEFINITION
dicNames("Comments") = TXT_COMMENTS
dicNames("AltDefinition") = TXT_ALTERNATE_DEFINITION

For Each strCulture In active_cultures()
	strDesc = vbNullString

	bTermNull = False
	For Each strField in Array("Term", "Definition", "Comments", "AltTerm", "AltDefinition")
		strValue = Trim(Request(strField & "_" & strCulture))

		If strField = "Term" or strField = "AltTerm" Then
			strValue = Left(strValue, 255)
		Else
			Call checkLength(dicNames(strField) & "(" & Application("Culture_" & strCulture & "_LanguageName") & ")",strValue,4000)
		End If

		If strField="Term" And Nl(strValue) Then
			bTermNull = True
		End If

		If Not bTermNull And Not Nl(strValue) Then
			strDesc = strDesc & "<" & strField & ">" & XMLEncode(strValue) & "</" & strField & ">"
		End If
	Next

	If Not bTermNull And Not Nl(strDesc) Then
		strDescriptions = strDescriptions & _
			"<DESC><Culture>" & strCulture & "</Culture>" & strDesc & "</DESC>"
	End If

Next

If Not Nl(strDescriptions) Then
	strDescriptions = "<DESCS>" & strDescriptions & "</DESCS>"
End If

'Fetch Related Term ("See Also") data
strNewTCs = vbNullString
strTmpError = checkTaxTerms(Trim(Request("SeeAlsoTerms")),True)
If Not Nl(strTmpError) Then
	strErrorList = strErrorList & "<li>" & strTmpError & "</li>"
	strTmpError = Null
End If
strSeeAlsoTCList = Trim(Request("SA_Code"))
strSeeAlsoAuthList = Trim(Request("SA_AUTH"))
If Not Nl(strSeeAlsoTCList) And Not Nl(strNewTCs) Then
	strSeeAlsoTCList = strNewTCs & "," & strSeeAlsoTCList
ElseIf Not Nl(strNewTCs) Then
	strSeeAlsoTCList = strNewTCs
End If

'Fetch Related Concept data
strNewRCIDs = vbNullString
strTmpError = checkRelatedConcepts(Trim(Request("RelatedConcepts")))
If Not Nl(strTmpError) Then
	strErrorList = strErrorList & "<li>" & strTmpError & "</li>"
	strTmpError = Null
End If
strRelatedConceptList = Trim(Request("TM_RC_ID"))
strRelatedConceptAuthList = Trim(Request("RC_AUTH"))
If Not Nl(strRelatedConceptList) And Not Nl(strNewRCIDs) Then
	strRelatedConceptList = strNewRCIDs & "," & strRelatedConceptList
ElseIf Not Nl(strNewRCIDs) Then
	strRelatedConceptList = strNewRCIDs
End If

'If there are errors identified, print the list of errors
If Not Nl(strErrorList) Then
	Call makePageHeader(TXT_UPDATE_TERM_FAILED, TXT_UPDATE_TERM_FAILED, True, False, True, True)
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & "<ul>" & strErrorList & "</ul>", _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(True)
Else
	'If no basic data errors found,that will prevent the stored procedure
	'from running, send the updated information to the selected procedure
	Dim objReturn, objErrMsg

	Dim cmdUpdateTerm, rsUpdateTerm
	Set cmdUpdateTerm = Server.CreateObject("ADODB.Command")

	With cmdUpdateTerm 	
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_Term_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@TM_ID", adInteger, adParamInput, 4, intTMID)
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamOutput, 21)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@CdLvl1", adChar, adParamInput, 1, strCdLvl1)
		.Parameters.Append .CreateParameter("@CdLvl2", adVarChar, adParamInput, 1, strCdLvl2)
		.Parameters.Append .CreateParameter("@CdLvl3", adVarChar, adParamInput, 4, strCdLvl3)
		.Parameters.Append .CreateParameter("@CdLvl4", adVarChar, adParamInput, 4, strCdLvl4)
		.Parameters.Append .CreateParameter("@CdLvl5", adVarChar, adParamInput, 3, strCdLvl5)
		.Parameters.Append .CreateParameter("@CdLvl6", adVarChar, adParamInput, 2, strCdLvl6)
		.Parameters.Append .CreateParameter("@Source", adInteger, adParamInput, 4, intSource)
		.Parameters.Append .CreateParameter("@Authorized", adBoolean, adParamInput, 1, IIf(bAuthorized,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@Facet", adInteger, adParamInput, 4, intFacet)
		.Parameters.Append .CreateParameter("@IconURL", adVarChar, adParamInput, 150, strIconURL)
		.Parameters.Append .CreateParameter("@Active", adBoolean, adParamInput, 1, bActive)
		.Parameters.Append .CreateParameter("@SeeAlsoTCList", adLongVarChar, adParamInput, -1, strSeeAlsoTCList)
		.Parameters.Append .CreateParameter("@SeeAlsoAuthList", adLongVarChar, adParamInput, -1, strSeeAlsoAuthList)
		.Parameters.Append .CreateParameter("@RelatedConceptList", adLongVarChar, adParamInput, -1, strRelatedConceptList)
		.Parameters.Append .CreateParameter("@RelatedConceptAuthList", adLongVarChar, adParamInput, -1, strRelatedConceptAuthList)
		.Parameters.Append .CreateParameter("@Descriptions", adVarWChar, adParamInput, -1, strDescriptions)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With

	Set rsUpdateTerm = cmdUpdateTerm.Execute
	Set rsUpdateTerm = rsUpdateTerm.NextRecordset

	'If there was no error from running the stored procedure, process Use Reference data;
	'Otherwise, grab the error message if any so it can be printed to the user.
	If objReturn.Value = 0 Then
		strCode = cmdUpdateTerm.Parameters("@Code").Value

		'Process Use References
		Dim strUseRefIDs, _
			aUseRefIDs, _
			indUseRef, _
			strUseRefID
		
		strBadUseRefCon = vbNullString
		strUseRefIDs = Request("UT_ID")
		If Not Nl(strUseRefIDs) Then
			aUseRefIDs = Split(strUseRefIDs,",")
			For Each indUseRef In aUseRefIDs
				strUseRefID = Trim(indUseRef)
				strTmpError = updateUnusedTerm(strUseRefID, _
						Trim(Request("UT_TERM_" & strUseRefID)), _
						Not Nl(Request("UT_AUTH_" & strUseRefID)), _
						Not Nl(Request("UT_ACTIVE_" & strUseRefID)), _
						Nz(Trim(Request("UT_LANGID_" & strUseRefID)), Null))
				If Not Nl(strTmpError) Then
					strBadUseRefs = strBadUseRefs & strBadUseRefCon & strTmpError
					strTmpError = Null
				End If
			Next
		End If
		
		Dim i
		For i = 1 to 3
			strUseRefID = Trim("NEW_" & i)
			If Not Nl(Trim(Request("UT_TERM_" & strUseRefID))) Then
				strTmpError = updateUnusedTerm(Null, _
						Trim(Request("UT_TERM_" & strUseRefID)), _
						Not Nl(Request("UT_AUTH_" & strUseRefID)), _
						Not Nl(Request("UT_ACTIVE_" & strUseRefID)), _
						Nz(Trim(Request("UT_LANGID_" & strUseRefID)), Null))
				If Not Nl(strTmpError) Then
					strBadUseRefs = strBadUseRefs & strBadUseRefCon & strTmpError
					strTmpError = Null
				End If
			End If
		Next

		'Check if there were any invalid Codes given in the lists
		'of Unused Terms, Related Concepts, and Related Terms
		If Nl(strBadTaxTerms) And Nl(strBadConcepts) And Nl(strBadUseRefs) And Nl(strErrorList) Then
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
					"tax_edit.asp", _
					"TC=" & strCode, _
					False)
		Else
			'One or more Related Terms ("See Also") were invalid
			If Not Nl(strBadTaxTerms) Then
				strErrorList = strErrorList & "<li>" & TXT_INVALID_TERMS & strBadTaxTerms & "</li>"
			End If
			'One or more Related Concpets were invalid
			If Not Nl(strBadConcepts) Then
				strErrorList = strErrorList & "<li>" & TXT_INVALID_TERMS & strBadTaxTerms & "</li>"
			End If
			'One or more Unused Terms ("Use References") were invalid
			If Not Nl(strBadUseRefs) Then
				strErrorList = strErrorList & "<li>" & TXT_INVALID_USE_REFERENCES & "<ul>" & strBadUseRefs & "</ul></li>"
			End If
			Call handleError(TXT_TERM_PARTIALLY_UPDATED & TXT_COLON & "<ul>" & strErrorList & "</ul>", _
					"tax_edit.asp", _
					"TC=" & strCode)
		End If
	Else
		'There was an error executing the stored procedure.
		'Print any error messages from the ASP or Stored Procedure
		Call makePageHeader(TXT_UPDATE_TERM_FAILED, TXT_UPDATE_TERM_FAILED, True, False, True, True)
		Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			vbNullString, _
			vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
		Call makePageFooter(True)
	End If
End If
%>
<!--#include file="includes/core/incClose.asp" -->
