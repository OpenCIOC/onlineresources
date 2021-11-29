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
Call setPageInfo(True, DM_GLOBAL, DM_CIC, "../", "import/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtCommonForm.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../text/txtGeoCode.asp" -->
<!--#include file="../text/txtImport.asp" -->
<!--#include file="../text/txtImportInfo.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->

<%
If Not user_bImportPermissionCIC Then
	Call securityFailure()
End If

Const DATASET_FULL = 0
Const DATASET_ADD = 1
Const DATASET_UPDATE = 2

Sub printXMLData(xmlDataNode)
	Dim xmlAttributeNode, _
		xmlChildNode, _
		strFieldName, _
		strFieldType, _
		strCon
	strFieldName = xmlDataNode.nodeName
	If xmlDataNode.nodeType = 1 Then
		If reEquals(strFieldName,"EXTRA(\_((DATE)|(EMAIL)|(RADIO)|(WWW)|(CHECKLIST)|(DROPDOWN)))?",False,False,True,False) Then
			strFieldType = xmlDataNode.getAttribute("FLD")
			If Not Nl(strFieldType) Then
				strFieldName = strFieldName & "_" & strFieldType
			End If
		End If
		If Not strFieldName = "RECORD" Then
%>
<tr><td class="FieldLabelLeftClr"><%
			Select Case strFieldName
				Case "ADDR"
					Response.Write(TXT_ADDRESS)
				Case "CD"
					Response.Write(TXT_CODE)
				Case "CHK"
					Response.Write(TXT_ITEM)
				Case "CM"
					Response.Write(TXT_COMMUNITY)
				Case "CONTACT"
					Response.Write(TXT_CONTACT)
				Case "HD"
					Response.Write(TXT_HEADING)
				Case "HEADINGS"
					Response.Write(TXT_HEADINGS)
				Case "LNK"
					Response.Write(TXT_LINK)
				Case "N"
					Response.Write(TXT_NOTE)
				Case "NM"
					Response.Write(TXT_NAME)
				Case "RT"
					Response.Write(TXT_ROUTE)
				Case "SERVICE_TYPE"
					Response.Write(TXT_SERVICE_TYPE)
				Case "TM"
					Response.Write(TXT_TERM)
				Case "TP"
					Response.Write(TXT_TARGET_POPULATION)
				Case "TYPE"
					Response.Write(TXT_TYPE)
				Case "UNIT"
					Response.Write(TXT_UNIT)
				Case Else
					If dicFieldNames.Exists(strFieldName) Then
						Response.Write(dicFieldNames(strFieldName))
					Else
						Response.Write(strFieldName)
					End If
			End Select
%></td><td>
<%
			If xmlDataNode.Attributes.length > 0 Then
				For Each xmlAttributeNode In xmlDataNode.Attributes
					If xmlAttributeNode.nodeName<>"FLD" Or Not reEquals(xmlDataNode.nodeName,"EXTRA(\_((DATE)|(EMAIL)|(RADIO)|(WWW)|(DROPDOWN)|(CHECKLIST)))?",False,False,True,False) Then
						Response.Write(strCon & "<strong>")
					End If

					Select Case xmlAttributeNode.nodeName
						Case "ADDR"
							Response.Write(TXT_ADDRESS)
						Case "ADDRF"
							Response.Write(TXT_ADDRESS & " (" & TXT_FRENCH & ")")
						Case "AP"
							Response.Write(TXT_AUTH_COMMUNITY)
						Case "APF"
							Response.Write(TXT_AUTH_COMMUNITY & " (" & TXT_FRENCH & ")")
						Case "ASSIST"
							Response.Write(TXT_ASSISTANCE_AVAILABLE)
						Case "ASSIST_FOR"
							Response.Write(TXT_ASSISTANCE_FOR)
						Case "ASSIST_FORF"
							Response.Write(TXT_ASSISTANCE_FOR & " (" & TXT_FRENCH & ")")
						Case "ASSIST_FROM"
							Response.Write(TXT_ASSISTANCE_FROM)
						Case "ASSIST_FROMF"
							Response.Write(TXT_ASSISTANCE_FROM & " (" & TXT_FRENCH & ")")
						Case "BLD"
							Response.Write(TXT_BUILDING)
						Case "BLDF"
							Response.Write(TXT_BUILDING & " (" & TXT_FRENCH & ")")
						Case "BOX"
							Response.Write(TXT_BOX_NUMBER)
						Case "BOXF"
							Response.Write(TXT_BOX_NUMBER & " (" & TXT_FRENCH & ")")
						Case "BRD"
							Response.Write(TXT_BOARD)
						Case "BXTP"
							Response.Write(TXT_BOX_TYPE)
						Case "BXTPF"
							Response.Write(TXT_BOX_TYPE & " (" & TXT_FRENCH & ")")
						Case "CAP"
							Response.Write(TXT_CAPACITY)
						Case "CREATEDBY"
							Response.Write(TXT_CREATED_BY)
						Case "CREATED"
							Response.Write(TXT_DATE_CREATED)
						Case "GID"
							Response.Write(TXT_UNIQUE_ID)
						Case "CD"
							Response.Write(TXT_CODE)
						Case "CO"
							Response.Write(TXT_MAIL_CO)
						Case "COF"
							Response.Write(TXT_MAIL_CO & " (" & TXT_FRENCH & ")")
						Case "CTY"
							Response.Write(TXT_CITY)
						Case "CTYF"
							Response.Write(TXT_CITY & " (" & TXT_FRENCH & ")")
						Case "CTRY"
							Response.Write(TXT_COUNTRY)
						Case "CTRYF"
							Response.Write(TXT_COUNTRY & " (" & TXT_FRENCH & ")")
						Case "DATE"
							Response.Write(TXT_DATE)
						Case "DAYS"
							Response.Write(TXT_DAYS)
						Case "DESC"
							Response.Write(TXT_DESCRIPTON)
						Case "EML"
							Response.Write(TXT_EMAIL)
						Case "EMLF"
							Response.Write(TXT_EMAIL & " (" & TXT_FRENCH & ")")
						Case "FAX"
							Response.Write(TXT_FAX)
						Case "FAXF"
							Response.Write(TXT_FAX & " (" & TXT_FRENCH & ")")
						Case "FAXN"
							Response.Write(TXT_FAX & " - " & TXT_NOTE)
						Case "FAXNO"
							Response.Write(TXT_FAX & " - " & TXT_NUMBER)
						Case "FUNDCAP"
							Response.Write(TXT_FUNDED_CAPACITY)
						Case "FLD"
							If Not reEquals(xmlDataNode.nodeName,"EXTRA(\_((DATE)|(EMAIL)|(RADIO)|(WWW)|(DROPDOWN)|(CHECKLIST)))?",False,False,True,False) Then
								Response.Write(TXT_FIELD)
							End If
						Case "FT"
							Response.Write(TXT_FULL_TIME)
						Case "FTE"
							Response.Write(TXT_FULL_TIME_EQUIVALENT)
						Case "HOURS"
							Response.Write(TXT_HOURS)
						Case "INF"
							Response.Write(TXT_INFANT)
						Case "KIN"
							Response.Write(TXT_KINDERGARTEN)
						Case "LANG"
							Response.Write(TXT_LANGUAGE)
						Case "LAT"
							Response.Write(TXT_LATITUDE)
						Case "LN1"
							Response.Write(TXT_LINE & " 1")
						Case "LN2"
							Response.Write(TXT_LINE & " 2")
						Case "LN3"
							Response.Write(TXT_LINE & " 3")
						Case "LN4"
							Response.Write(TXT_LINE & " 4")
						Case "LONG"
							Response.Write(TXT_LONGITUDE)
						Case "MIN_AGE"
							Response.Write(TXT_MIN_AGE)
						Case "MAX_AGE"
							Response.Write(TXT_MAX_AGE)
						Case "MOD"
							Response.Write(TXT_LAST_MODIFIED)
						Case "MODBY"
							Response.Write(TXT_MODIFIED_BY)
						Case "MUN"
							Response.Write(TXT_MUNICIPALITY)
						Case "MUNF"
							Response.Write(TXT_MUNICIPALITY & " (" & TXT_FRENCH & ")")
						Case "N"
							Response.Write(TXT_NOTES)
						Case "NF"
							Response.Write(TXT_NOTES & " (" & TXT_FRENCH & ")")
						Case "NM"
							Response.Write(TXT_NAME)
						Case "NMF"
							Response.Write(TXT_NAME & " (" & TXT_FRENCH & ")")
						Case "NMFIRST"
							Response.Write(TXT_FIRST_NAME)
						Case "NMH"
							Response.Write(TXT_HONORIFIC)
						Case "NMLAST"
							Response.Write(TXT_LAST_NAME)
						Case "NO"
							Response.Write(TXT_NUMBER)
						Case "ORG"
							Response.Write(TXT_ORGANIZATION)
						Case "ORGF"
							Response.Write(TXT_ORGANIZATION & " (" & TXT_FRENCH & ")")
						Case "PB"
							Response.Write(TXT_PUBLISH)
						Case "PBF"
							Response.Write(TXT_PUBLISH & " (" & TXT_FRENCH & ")")
						Case "PC"
							Response.Write(TXT_POSTAL_CODE)
						Case "PCF"
							Response.Write(TXT_POSTAL_CODE & " (" & TXT_FRENCH & ")")
						Case "PHN"
							Response.Write(TXT_PHONE)
						Case "PHNF"
							Response.Write(TXT_PHONE & " (" & TXT_FRENCH & ")")
						Case "PH1EXT"
							Response.Write(TXT_PHONE & " #1 " & TXT_EXT)
						Case "PH1N"
							Response.Write(TXT_PHONE & " #1 " & TXT_NOTE)
						Case "PH1NO"
							Response.Write(TXT_PHONE & " #1 " & TXT_NUMBER)
						Case "PH1OPT"
							Response.Write(TXT_PHONE & " #1 " & TXT_OPTION)
						Case "PH1TYPE"
							Response.Write(TXT_PHONE & " #1 " & TXT_TYPE)
						Case "PH2EXT"
							Response.Write(TXT_PHONE & " #2 " & TXT_EXT)
						Case "PH2N"
							Response.Write(TXT_PHONE & " #2 " & TXT_NOTE)
						Case "PH2NO"
							Response.Write(TXT_PHONE & " #2 " & TXT_NUMBER)
						Case "PH2OPT"
							Response.Write(TXT_PHONE & " #2 " & TXT_OPTION)
						Case "PH2TYPE"
							Response.Write(TXT_PHONE & " #2 " & TXT_TYPE)
						Case "PH3EXT"
							Response.Write(TXT_PHONE & " #3 " & TXT_EXT)
						Case "PH3N"
							Response.Write(TXT_PHONE & " #3 " & TXT_NOTE)
						Case "PH3NO"
							Response.Write(TXT_PHONE & " #3" & TXT_NUMBER)
						Case "PH3OPT"
							Response.Write(TXT_PHONE & " #3 " & TXT_OPTION)
						Case "PH3TYPE"
							Response.Write(TXT_PHONE & " #3" & TXT_TYPE)
						Case "PRE"
							Response.Write(TXT_PRESCHOOL)
						Case "PRI"
							Response.Write(TXT_PRIORITY)
						Case "PRV"
							Response.Write(TXT_PROVINCE)
						Case "PRVF"
							Response.Write(TXT_PROVINCE & " (" & TXT_FRENCH & ")")
						Case "PT"
							Response.Write(TXT_PART_TIME)
						Case "SCH"
							Response.Write(TXT_SCHOOL_AGE)
						Case "SFX"
							Response.Write(TXT_SUFFIX)
						Case "SFXF"
							Response.Write(TXT_SUFFIX & " (" & TXT_FRENCH & ")")
						Case "SIGNAME"
							Response.Write(TXT_SIGNATORY)
						Case "ST"
							Response.Write(TXT_STREET)
						Case "STAT"
							Response.Write(TXT_STATUS)
						Case "STF"
							Response.Write(TXT_STREET & " (" & TXT_FRENCH & ")")
						Case "STDIR"
							Response.Write(TXT_STREET_DIR)
						Case "STDIRF"
							Response.Write(TXT_STREET_DIR & " (" & TXT_FRENCH & ")")
						Case "STNUM"
							Response.Write(TXT_NUMBER)
						Case "STNUMF"
							Response.Write(TXT_NUMBER & " (" & TXT_FRENCH & ")")
						Case "STTYPE"
							Response.Write(TXT_STREET_TYPE)
						Case "STTYPEF"
							Response.Write(TXT_STREET_TYPE & " (" & TXT_FRENCH & ")")
						Case "SVC"
							Response.Write(TXT_VACANCY_INFO_SERVICE_TITLE)
						Case "SVCF"
							Response.Write(TXT_VACANCY_INFO_SERVICE_TITLE & " (" & TXT_FRENCH & ")")
						Case "TOD"
							Response.Write(TXT_TODDLER)
						Case "TOT"
							Response.Write(TXT_TOTAL)
						Case "TTL"
							Response.Write(TXT_TITLE)
						Case "TTLF"
							Response.Write(TXT_TITLE & " (" & TXT_FRENCH & ")")
						Case "TYPE"
							Response.Write(TXT_TYPE)
						Case "V"
							Response.Write(TXT_VALUE)
						Case "VAC"
							Response.Write(TXT_VACANCY)
						Case "VF"
							Response.Write(TXT_VALUE & " (" & TXT_FRENCH & ")")
						Case "WAIT"
							Response.Write(TXT_VACANCY_INFO_WAIT_LIST)
						Case "WAITD"
							Response.Write(TXT_WAIT_LIST_DATE)
						Case "WEEKS"
							Response.Write(TXT_WEEKS)
						Case Else
							Response.Write(xmlAttributeNode.nodeName)
					End Select
					If xmlAttributeNode.nodeName<>"FLD" Or Not reEquals(xmlDataNode.nodeName,"EXTRA(\_((DATE)|(EMAIL)|(RADIO)|(WWW)|(DROPDOWN)|(CHECKLIST)))?",False,False,True,False) Then
						Response.Write("</strong>: " & textToHTML(xmlAttributeNode.Value))
						strCon = "<br><br>"
					End If

				Next
			ElseIf Not xmlDataNode.hasChildNodes Then
				Response.Write("&nbsp;")
			End If
		End If
		If xmlDataNode.hasChildNodes Then
%>
<table class="BasicBorder cell-padding-3">
<%
			For Each xmlChildNode In xmlDataNode.childNodes
				printXMLData(xmlChildNode)
			Next
%>
</table>
<%
		End If
		If Not xmlDataNode.nodeName = "RECORD" Then
%>
</td></tr>
<%
		End If
	End If
End Sub

Dim intEFID
intEFID = Trim(Request("EFID"))

If Nl(intEFID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & intEFID & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_DATASET, _
		"import.asp", vbNullString)
ElseIf Not IsIDType(intEFID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intEFID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_DATASET, _
		"import.asp", vbNullString)
Else
	intEFID = CLng(intEFID)
End If

Dim intDataSet
intDataSet = Request("DataSet")
If IsNumeric(intDataSet) Then
	intDataSet = CInt(intDataSet)
End If
Select Case intDataSet
	Case DATASET_ADD
	Case DATASET_UPDATE
	Case Else
		intDataSet = DATASET_FULL
End Select

Call makePageHeader(TXT_VIEW_IMPORT_DATA, TXT_VIEW_IMPORT_DATA, True, False, True, True)

Dim intERID
intERID = Request("ERID")

If Nl(intERID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
ElseIf Not IsIDType(intERID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intERID) & ".", vbNullString, vbNullString)
Else
	intERID = CLng(intERID)

Dim cmdListImport, _
	rsListImport

Dim intError
intError = 0

Set cmdListImport = Server.CreateObject("ADODB.Command")
Set rsListImport = Server.CreateObject("ADODB.Recordset")

With cmdListImport
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_Data_s"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ER_ID", adInteger, adParamInput, 4, intERID)
End With

With rsListImport
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdListImport

	If Not .EOF Then
		intError = .Fields("Error")
		If intError <> 0 Then
			Call handleError(Nz(.Fields("ErrMsg"),TXT_UNKNOWN_ERROR_OCCURED),vbNullString,vbNullString)
		End If
	End If
End With

If intError = 0 Then

Set rsListImport = rsListImport.NextRecordset

Dim dicFieldNames
Set dicFieldNames = Server.CreateObject("Scripting.Dictionary")

With rsListImport
	While Not .EOF
		dicFieldNames(.Fields("FieldName").Value) = .Fields("FieldDisplay").Value
		.MoveNext
	Wend
End With

Set rsListImport = rsListImport.NextRecordset

If rsListImport.EOF Then
	Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intERID), vbNullString, vbNullString)
Else
%>
<p>[ <a href="<%=makeLink("import_update_list.asp","EFID=" & intEFID & "&DataSet=" & intDataSet,vbNullString)%>"><%=TXT_RETURN_TO_LIST%></a> | <a href="<%=makeLinkB("import.asp")%>"><%=TXT_RETURN_TO_IMPORT%></a> ]</p>
<h2><%=TXT_RECORD_NUM & " "%>
	<%=rsListImport.Fields("NUM") & StringIf(Not Nl(rsListImport.Fields("EXTERNAL_ID"))," (" & rsListImport.Fields("EXTERNAL_ID") & ")")%></h2>
<p><strong><%=TXT_RECORD_OWNER & TXT_COLON%></strong> <%=rsListImport.Fields("OWNER")%></p>
<p><strong><%=TXT_LANGUAGE & TXT_COLON%></strong> <%=rsListImport.Fields("LANGUAGES")%></p>
<%
	Dim xmlDoc, xmlNode
	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
		.LoadXML rsListImport.Fields("DATA")
	End With
	
	Set xmlNode = xmlDoc.selectSingleNode("/RECORD")
	If Not xmlNode Is Nothing Then
		printXMLData(xmlNode)
	End If
End If

End If

rsListImport.Close

Set rsListImport = Nothing
Set cmdListImport = Nothing

End If

Call makePageFooter(False)
%>

<!--#include file="../includes/core/incClose.asp" -->
