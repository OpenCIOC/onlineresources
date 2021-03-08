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
' Purpose: 		Process Taxonomy indexing changes for the given record (NUM)
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
<!--#include file="text/txtSearchTax.asp" -->
<!--#include file="text/txtTaxUpdate.asp" -->
<%
Dim bError, _
	strErrorMsg
bError = False


'Retreive the Record # of the record we are trying to update.
'If no Record # is given or the Record # is invalid, set an error message.
Dim strNUM
strNUM = Request("NUM")

If Nl(strNUM) Then
	bError = True
	strErrorMsg = TXT_NO_RECORD_CHOSEN
ElseIf Not IsNUMType(strNUM) Then
	bError = True
	strErrorMsg = TXT_INVALID_ID & Server.HTMLEncode(strNUM) & "."
End If

'To help ensure valid updates, the software checks that the changes were sent from the expected page.
Dim strReferer
strReferer = Request.ServerVariables("HTTP_REFERER")
If Not reEquals(strReferer,"update_tax.asp",True,False,False,False) Then
	bError = True
	strErrorMsg = TXT_UPDATE_REJECTED
End If

'If we have not encountered any other errors, 
'retrieve the list of Terms provided to index the given record.
If Not bError Then
	Dim strTMC
	strTMC = Request("TMC")
	If Not Nl(strTMC) Then
		If Not IsLinkedTaxCodeList(strTMC) Then
			strTMC = Null
			bError = True
			strErrorMsg = TXT_INVALID_CODE_LIST
		End If
	End If
End If

'If there is an error, print the details
If bError Then
	Call makePageHeader(TXT_UPDATE_TAXONOMY_TITLE, TXT_UPDATE_TAXONOMY_TITLE, True, False, True, True)
	Call handleError(strErrorMsg, vbNullString, vbNullString)
	Call makePageFooter(True)
Else

Dim cmdUpdateTaxonomy, rsUpdateTaxonomy, _
	cmdUpdateTaxonomyD, _
	strLinkList, strLinkCon
	
strLinkList = vbNullString
strLinkCon = vbNullString

'First the new Taxonomy Terms / sets of linked Terms are added to the record.
'The procedure is the same one used for Import functionality; it involves
'multiple iterations checking an individual Term or linked Term set,
'and adding it to the record if it does not exist, and returning the existing
'ID of the link if the Term / link set already exists.
Set cmdUpdateTaxonomy = Server.CreateObject("ADODB.Command")
Set cmdUpdateTaxonomyD = Server.CreateObject("ADODB.Command")

With cmdUpdateTaxonomy
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_NUMTaxonomy_i"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	.Parameters.Append .CreateParameter("@CodeList", adLongVarChar, adParamInput, -1)
	.Parameters.Append .CreateParameter("@BT_TAX_ID", adInteger, adParamOutput, 4)
End With

Dim aLinks, _
	indLink, _
	strCodeList
	
	strErrorMsg = vbNullString
	aLinks = Split(strTMC,",")

'For each Taxonomy Link (set of linked Terms) check if a link set exists in the record
'that contains all valid Taxonomy terms in the link. If it does exist, fetch the link ID.
'If it does not exist, create a new Taxonomy link with all valid terms, and fetch the new link ID.
'Assemble all the link IDs into a list, strLinkList.
For Each indLink in aLinks
	strCodeList = Replace(indLink,"~",",")

	'We have the list of all the Terms for this link.
	'If there is at least one Term, find the link (or create a new one) and add the link's ID to the list
	If IsTaxCodeList(strCodeList) Then
		'Locate / Add the link for this group of Terms
		With cmdUpdateTaxonomy
			.Parameters("@CodeList").Value = strCodeList
			Set rsUpdateTaxonomy = .Execute
			Set rsUpdateTaxonomy = rsUpdateTaxonomy.NextRecordset
			
			'Add the ID to the list of link IDs allowed for this record
			If Not Nl(cmdUpdateTaxonomy.Parameters("@BT_TAX_ID")) Then
				strLinkList = strLinkList & strLinkCon & cmdUpdateTaxonomy.Parameters("@BT_TAX_ID")
				strLinkCon = ","
			Else
				strErrorMsg = strErrorMsg & "<li>" & TXT_COULD_NOT_ADD_CODES & strCodeList & "</li>"
			End If
		End With
	End If

Next

'Remove from the record all Taxonomy Links that do not either:
'	a) contain at least one local (non-Authorized) Term
'	b) appear in the list strLinkList
'Complete the update by triggering the SRCH fields to populate.
With cmdUpdateTaxonomyD
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdText
	.CommandTimeout = 0
End With

With cmdUpdateTaxonomyD
	.CommandText = "IF EXISTS(SELECT * FROM CIC_BT_TAX tl WHERE NUM=" & QsNl(strNUM) & _
			IIf(Nl(strLinkList),vbNullString," AND (BT_TAX_ID NOT IN (" & strLinkList & "))") & _
			") BEGIN" & vbCrLf & _
			"UPDATE CIC_BaseTable SET TAX_MODIFIED_DATE=GETDATE(),TAX_MODIFIED_BY=" & QsN(user_strMod) & " WHERE NUM=" & QsNl(strNUM) & vbCrLf & _
			"DELETE tl FROM CIC_BT_TAX tl WHERE NUM=" & QsNl(strNUM) & _
			IIf(Nl(strLinkList),vbNullString," AND (BT_TAX_ID NOT IN (" & strLinkList & "))") & _
			"END" & vbCrLf & _
			"EXEC sp_CIC_SRCH_TAX_u NULL" & vbCrLf & _
			"EXEC sp_CIC_SRCH_PubTax_u " & QsNl(strNUM) & ", NULL"
	.Execute
End With

If Nl(strErrorMsg) Then
	Dim cmdHistory
	Set cmdHistory = Server.CreateObject("ADODB.Command")
	
	With cmdHistory
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_BaseTable_History_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MODIFIED_DATE", adDBTimeStamp, adParamInput, , Now())
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@FieldList", adLongVarChar, adParamInput, -1, "TAXONOMY")
		.Parameters.Append .CreateParameter("@Names", adBoolean, adParamInput, 1, SQL_TRUE)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2, Null)
		.Execute
	End With
	
	Call handleDetailsMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED, _
		strNUM, _
		StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber), _
		False)
Else
	Call handleDetailsError(TXT_UNKNOWN_ERRORS_OCCURED & strErrorMsg, _
		strNUM,  _
		StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber), _
		False)
End If

End If
%>

<!--#include file="includes/core/incClose.asp" -->

