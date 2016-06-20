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
g_bAllowAPILogin = True
Call setPageInfo(False, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtExport.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<%

Const XML_EXPORT_V2 = 1
Const SHARE_EXPORT = 2
Const EXCEL_EXPORT = 3

Const EDB_LEADER = "   "
Const EDB_LINE_WRAP = 72

Dim strWhereClauseCICExport
strWhereClauseCICExport = Replace(g_strWhereClauseCIC,"AND shp.Active=1","AND shp.Active=1 AND shp.CanUseExport=1")

Dim cmdPrivacyProfile, rsPrivacyProfile
Dim dicPrivacyProfileNames, dicPrivacyProfileFields, dicFieldTemp, dicNameTemp, dicProfileName
Dim dicEmpty
Dim intLastProfileID, strFieldName, bAPIRequest

bAPIRequest = Not Nl(Request("API"))
If Not user_bLoggedIn Then
	If Not bAPIRequest Then 
		Call securityFailure()
	Else
		Call HTTPBasicUnauth("CIOC RPC")
	End If
			
End If

Function stripParagraphs(strVal)
	Dim strReturn
	
	strReturn = reReplace(strVal,"(^<p([^>]*)>)|(</p>)|(^<(u|o)l([^>]*)>)|(</(u|o)l>)|(</li>)",vbNullString,True,False,True,False)
	strReturn = reReplace(strReturn,"(<p([^>]*)>)","<br><br>",True,False,True,False)
	strReturn = reReplace(strReturn,"(<(u|o)l([^>]*)>)","<br>",True,False,True,False)
	strReturn = reReplace(strReturn,"(<li([^>]*)>)","<br>*",True,False,True,False)
	
	stripParagraphs = strReturn
End Function

Function stripLinks(strVal)
	Dim strReturn

	strReturn = reReplace(strVal,"<a href=""([^""]+)""[^>]*>(.*)<\/a>","<b>$2</b> ($1)",True,False,True,False)
	stripLinks = strReturn
End Function

Sub openPrivacyProfiles()
	Dim strPrivacyProfileSQL, strExportCritTmp, strCon
	
	strExportCritTmp = strExportCrit

	If bExportCritViewClause And Not Nl(g_intPBID) Then
		strCon = vbNullString
		If Not Nl(strExportCritTmp) Then
			strCon = AND_CON
		End If
		strExportCritTmp = strExportCritTmp & strCon & "(EXISTS(SELECT pb.BT_PB_ID FROM CIC_BT_PB pb " & vbCrLf & _
			"WHERE pb.NUM=bt.NUM AND pb.PB_ID=" & g_intPBID & "))"
	End If
	strPrivacyProfileSQL = "SELECT pp.*, ppe.ProfileName, ppf.ProfileName AS ProfileNameEq, fo.FieldName" & vbCrLf & _
		"	FROM GBL_PrivacyProfile pp" & vbCrLf & _
		"	INNER JOIN GBL_PrivacyProfile_Fld pf" & vbCrLf & _
		"		ON pp.ProfileID=pf.ProfileID" & vbCrLf & _
		"	INNER JOIN GBL_FieldOption fo" & vbCrLf & _
		"		ON fo.FieldID=pf.FieldID" & vbCrLf & _
		"	LEFT JOIN GBL_PrivacyProfile_Name ppe" & vbCrLf & _
		"		ON pp.ProfileID = ppe.ProfileID AND ppe.LangID=0" & vbCrLf & _
		"	LEFT JOIN GBL_PrivacyProfile_Name ppf" & vbCrLf & _
		"		ON pp.ProfileID = ppf.ProfileID AND ppf.LangID=2" & vbCrLf & _
		"	WHERE EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.PRIVACY_PROFILE=pp.ProfileID" & StringIf(Not Nl(strExportCritTmp), " AND (" & strExportCritTmp & ")") & ")" & vbCrLf & _
		"ORDER BY ppe.ProfileName, ppf.ProfileName, fo.FieldName"

	'Response.Write(strPrivacyProfileSQL)
	'Response.Flush()

	Set cmdPrivacyProfile = Server.CreateObject("ADODB.Command")
	Set rsPrivacyProfile = Server.CreateObject("ADODB.Recordset")
	With cmdPrivacyProfile
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = strPrivacyProfileSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
		Set rsPrivacyProfile = .Execute
	End With
	
	Set dicPrivacyProfileNames = Server.CreateObject("Scripting.Dictionary")
	Set dicPrivacyProfileFields = Server.CreateObject("Scripting.Dictionary")

	If rsPrivacyProfile.EOF Then
		If bIncludePrivacyProfiles Then
			strmOutput.WriteText "<PRIVACY_PROFILE_LIST/>", adWriteChar
		End If
	Else
		If bIncludePrivacyProfiles Then
			strmOutput.WriteText "<PRIVACY_PROFILE_LIST>", adWriteChar
		End If

		With rsPrivacyProfile
			If Not .EOF Then
				Set dicFieldTemp = Server.CreateObject("Scripting.Dictionary")
				intLastProfileID = .Fields("ProfileID").Value

				Set dicNameTemp = Server.CreateObject("Scripting.Dictionary")
				For Each strFieldName in Array("ProfileName", "ProfileNameEq") 
					dicNameTemp(strFieldName) = .Fields(strFieldName).Value
				Next
				Set dicPrivacyProfileNames(intLastProfileID) = dicNameTemp

				If bIncludePrivacyProfiles Then
					Set dicProfileName = dicPrivacyProfileNames(intLastProfileID)
					strmOutput.WriteText "<PR V=" & XMLQs(dicProfileName("ProfileName")) & StringIf(Not Nl(dicProfileName("ProfileNameEq")), " VF=" & XMLQs(dicProfileName("ProfileNameEq"))) & ">", adWriteChar
				End If
				While Not .EOF
					If intLastProfileID <> .Fields("ProfileID").Value Then
						Set dicPrivacyProfileFields(intLastProfileID) = dicFieldTemp
						Set dicFieldTemp = Server.CreateObject("Scripting.Dictionary")
						intLastProfileID = .Fields("ProfileID").Value

						Set dicNameTemp = Server.CreateObject("Scripting.Dictionary")
						For Each strFieldName in Array("ProfileName", "ProfileNameEq") 
							dicNameTemp(strFieldName) = .Fields(strFieldName).Value
						Next
						Set dicPrivacyProfileNames(intLastProfileID) = dicNameTemp

						If bIncludePrivacyProfiles Then
							Set dicProfileName = dicPrivacyProfileNames(intLastProfileID)
							strmOutput.WriteText "</PR><PR V=" & XMLQs(dicProfileName("ProfileName")) & StringIf(Not Nl(dicProfileName("ProfileNameEq")), " VF=" & XMLQs(dicProfileName("ProfileNameEq"))) & ">"
						End If
					End If

					strFieldName = .Fields("FieldName")
					dicFieldTemp(strFieldName) = True
					If bIncludePrivacyProfiles Then
						strmOutput.WriteText "<FLD V=" & XMLQs(strFieldName) & "/>", adWriteChar
					End If
					
					.MoveNext
				Wend
				Set dicPrivacyProfileFields(intLastProfileID) = dicFieldTemp
				If bIncludePrivacyProfiles Then
					strmOutput.WriteText "</PR>", adWriteChar
				End If
			End If
		End With

		If bIncludePrivacyProfiles Then
			strmOutput.WriteText "</PRIVACY_PROFILE_LIST>", adWriteChar
		End If

	End If
	rsPrivacyProfile.Close
	Set rsPrivacyProfile = Nothing
	Set cmdPrivacyProfile = Nothing

	Set dicEmpty = Server.CreateObject("Scripting.Dictionary")
End Sub

Sub getExportProfileData(bSharingFormat)
	intProfileID = Request("ExportProfileID")
	If Nl(intProfileID) Then
		bError = True
		Call handleError(TXT_NO_PROFILE, vbNullString, vbNullString)
	ElseIf Not (IsIDType(intProfileID) Or Nl(intProfileID)) Then
		bError = True
		Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID), vbNullString, vbNullString)
	End If
	
	If Not bError And Not Nl(intProfileID) Then		
		bProfilePub = False
		bProfileDist = False

		Dim cmdProfile, rsProfile
		Set cmdProfile = Server.CreateObject("ADODB.Command")
		With cmdProfile
			.ActiveConnection = getCurrentAdminCnn()
			.CommandType = adCmdStoredProc
			.CommandText = "dbo.sp_CIC_ExportProfile_sf"
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
			.Parameters.Append .CreateParameter("@SharingFormat", adBoolean, adParamInput, 1, IIf(bSharingFormat,SQL_TRUE,SQL_FALSE))
		End With
		Set rsProfile = Server.CreateObject("ADODB.Recordset")
		rsProfile.Open cmdProfile

		With rsProfile
			bIncludePrivacyProfiles = .Fields("IncludePrivacyProfiles")
			bExportEn = .Fields("ExportEn")
			bExportFr = .Fields("ExportFr")
			strSourceDbNameEn = .Fields("SourceDbNameEn")
			strSourceDbNameFr = .Fields("SourceDbNameFr")
			strSourceDbURLEn = .Fields("SourceDbURLEn")
			strSourceDbURLFr = .Fields("SourceDbURLFr")
			strSubmitChangesToAccessURL = .Fields("SubmitChangesToAccessURL")
			strSelectFields = .Fields("FieldList")

			aAccessURL = Split(Ns(strSubmitChangesToAccessURL)," ")
			'Possible values in the wild
			' "1 1 domain" -> UBound = 2
			' " 1 domain" -> UBound = 2
			If UBound(aAccessURL) = 2 Then
				If IsIDType(aAccessURL(0)) Then
					intViewType = CInt(aAccessURL(0))
				Else
					intViewType = Null
				End If
				strAccessURLTemplate = aAccessURL(2)
				strAccessURLProtocol = .Fields("SubmitChangesToAccessProtocol") & "://"
			Else
				intViewType = Null
				strAccessURLTemplate = g_strBaseURLCIC
				strAccessURLProtocol = IIf(get_db_option("FullSSLCompatibleBaseURLCIC"), "https://", "http://")
			End If
				
		End With
		
		Set rsProfile = Nothing
		Set cmdProfile = Nothing
	End If
End Sub

Dim rsExcelProfile
Sub getExcelProfileData()
	intProfileID = Request("ExcelProfileID")

	If Nl(intProfileID) Then
		bError = True
		Call handleError(TXT_NO_PROFILE, vbNullString, vbNullString)
	End If
	
	If Not bError And Not Nl(intProfileID) Then		
		bProfilePub = False
		bProfileDist = False

		Dim cmdProfile
		Set cmdProfile = Server.CreateObject("ADODB.Command")
		With cmdProfile
			.ActiveConnection = getCurrentAdminCnn()
			.CommandType = adCmdStoredProc
			.CommandText = "dbo.sp_CIC_ExcelProfile_sf"
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		End With
		Set rsExcelProfile = Server.CreateObject("ADODB.Recordset")
		With rsExcelProfile
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdProfile
			
			bColumnHeaders = .Fields("ColumnHeaders")
			strSelectFields = .Fields("FieldList")
			strSortFields = .Fields("SortList")
		End With
		
		Set rsExcelProfile = rsExcelProfile.NextRecordset
		Set cmdProfile = Nothing
	End If
End Sub

Sub buildXMLExportV2FieldList()
	strSelectFields = "RSN," & strSelectFields
	
	strSelectFields = reReplace(strSelectFields, "(^|,)((EXEC)|(CONTACT)|(VOLCONTACT)|(EXTRA_CONTACT))(_([A1-2]))?", _
		"$1$2_NAME$7,$2_TITLE$7,$2_ORG$7,$2_PHONE$7,$2_FAX$7,$2_EMAIL$7", _
		False,False,True,False)
		
	strSelectFields = Replace(strSelectFields, "MAIL_ADDRESS", _
		"MAIL_ADDRESS,MAIL_CARE_OF,MAIL_BOX_TYPE,MAIL_PO_BOX,MAIL_BUILDING,MAIL_STREET_NUMBER,MAIL_STREET,MAIL_STREET_TYPE,MAIL_STREET_TYPE_AFTER,MAIL_STREET_DIR,MAIL_SUFFIX,MAIL_CITY,MAIL_PROVINCE,MAIL_COUNTRY,MAIL_POSTAL_CODE")
		
	strSelectFields = Replace(strSelectFields, "SITE_ADDRESS", _
		"SITE_ADDRESS,SITE_BUILDING,SITE_STREET_NUMBER,SITE_STREET,SITE_STREET_TYPE,SITE_STREET_TYPE_AFTER,SITE_STREET_DIR,SITE_SUFFIX,SITE_CITY,SITE_PROVINCE,SITE_COUNTRY,SITE_POSTAL_CODE")

	strSelectFields = Replace(strSelectFields, "GEOCODE", _
		"LATITUDE,LONGITUDE,GEOCODE_NOTES,MAP_PIN")

	strSelectFields = reReplace(strSelectFields, "(^|,)SOURCE($|,)", _
		"$1SOURCE_NAME,SOURCE_TITLE,SOURCE_ORG,SOURCE_PHONE,SOURCE_FAX,SOURCE_EMAIL,SOURCE_POSTAL_CODE,SOURCE_PROVINCE,SOURCE_CITY,SOURCE_ADDRESS,SOURCE_BUILDING,SOURCE_DB,IMPORT_DATE$2", _
		False,False,False,False)
		
	strSelectFields = Replace(strSelectFields, "SUBJECTS", _
		"SUBJECTS,LOCAL_SUBJECTS")
		
	strSelectFields = Replace(strSelectFields,"TAXONOMY", _
		"TAXONOMY,TAX_MODIFIED_BY,TAX_MODIFIED_DATE")

	strSelectFields = reReplace(strSelectFields,"(^|,)VACANCY_INFO",vbNullString,False,False,False,False)
End Sub

Function getFileName()
	Dim dNow
	Dim strFileExtension
	Dim strFileName
	Select Case intExportType
		Case XML_EXPORT_V2
			strFileExtension = "mrv2.xml"
		Case SHARE_EXPORT
			strFileExtension = "sh.xml"
		Case EXCEL_EXPORT
			If bHTML Then
				strFileExtension = "exc.htm"
			Else
				strFileExtension = "exc.csv"
			End If
	End Select
	dNow = Now()
	strFileName	= Right(Year(dNow),2) & _
	IIf(Len(Month(dNow))<2, "0",vbNullString) & Month(dNow) & _
	IIf(Len(Day(dNow))<2, "0",vbNullString) & Day(dNow) & _
	IIf(Len(Hour(dNow))<2, "0",vbNullString) & Hour(dNow) & _
	IIf(Len(Minute(dNow))<2, "0",vbNullString) & Minute(dNow) & _
	IIf(Len(Second(dNow))<2, "0",vbNullString) & Second(dNow) & _
	strFileExtension
	getFileName = Replace(user_strLogin, " ", "_") & "_" & strFileName
End Function

Dim intProfileID, _
	bError
	
bError = False

'SHARE_FORMAT vars
Dim	bProfilePub, _
	bProfileDist, _
	bIncludePrivacyProfiles, _
	bIncludeSourceDb, _
	bExportEn, _
	bExportFr, _
	strSourceDbNameEn, _
	strSourceDbNameFr, _
	strSourceDbURLEn, _
	strSourceDbURLFr, _
	strSubmitChangesToAccessURL, _
	strAccessURLTemplate, _
	strAccessURLProtocol, _
	aAccessURL, _
	strAccessURL, _
	intViewType
	
'EXCEL_FORMAT vars
Dim bColumnHeaders, _
	bHTML

If user_intExportPermissionCIC = EXPORT_NONE And Not g_bHasExcelProfile Then
	Call securityFailure()
End If

If Not bAPIRequest Then
Call makePageHeader(TXT_EXPORTING_RECORDS, TXT_EXPORTING_RECORDS, True, False, True, True)
Else
'Set response type headers
Response.ContentType = "application/json"
Response.CacheControl = "Private"

Call run_response_callbacks()
'Response.Expires=-1
End If

'On Error Resume Next
Server.ScriptTimeOut = 1800

Dim strExportView, _
	strLocalPath, _
	strDownloadFileName, _
	strSelectFields, _
	aSelectFields, _
	strSortFields

Dim objFileSys, objTextStream, fld, strFldVal, strTmpVal, intPrivacyProfile, dicProfileFields

Dim intExportType
intExportType = Request("ExportType")
If Not Nl(intExportType) Then
	intExportType = CInt(intExportType)
End If

If user_intExportPermissionCIC = EXPORT_NONE Then
	intExportType = EXCEL_EXPORT
End If

Dim strBTNUM, strBTOWNER
strBTNUM = "NUM"
strBTOWNER = "RECORD_OWNER"
Select Case intExportType
	Case XML_EXPORT_V2
		strExportView = "XML_EXPORT_V2 bt"
		Call getExportProfileData(False)
		Call buildXMLExportV2FieldList()
	Case SHARE_EXPORT
		Call getExportProfileData(True)
		strExportView = "CIC_SHARE_VIEW" & IIf(Not bExportFr,"_EN",StringIf(Not bExportEn,"_FR")) & " bt"
		strSelectFields = strSelectFields & ",HAS_ENGLISH,HAS_FRENCH,XPRIVACY"
	Case EXCEL_EXPORT
		bHTML = Request("ExcelFormat") = "H"
		strExportView = "GBL_BaseTable bt" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd" & vbCrLf & _
			"	ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
			"LEFT JOIN CIC_BaseTable cbt" & vbCrLf & _
			"	ON bt.NUM=cbt.NUM" & vbCrLf & _
			"LEFT JOIN CIC_BaseTable_Description cbtd" & vbCrLf & _
			"	ON cbt.NUM=cbtd.NUM AND cbtd.LangID=btd.LangID" & vbCrLf & _
			"LEFT JOIN CCR_BaseTable ccbt" & vbCrLf & _
			"	ON bt.NUM=ccbt.NUM" & vbCrLf & _
			"LEFT JOIN CCR_BaseTable_Description ccbtd" & vbCrLf & _
			"	ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=btd.LangID"
		Call getExcelProfileData()
		strSelectFields = strSelectFields & StringIf(Not Nl(strSelectFields),",") & "PRIVACY_PROFILE AS XPRIVACY"
	Case Else
		bError = True
		Call handleError(TXT_NO_EXPORT_FORMAT, vbNullString, vbNullString)
End Select

Dim strIDList
strIDList = Request("IDList")

Dim strDSTIDList
strDSTIDList = Request("DSTID")

Dim strPBIDList
strPBIDList = Request("PBID")

If Not bError Then
	If Not bAPIRequest Then
%>
<h1><%=TXT_STARTING_EXPORT%></h1>
<p><%=TXT_EXPORT_PROCESSING%></p>
<%
	Response.Flush()
	End If
	Dim strExportSQL, strExportCrit, strCon, intPermission, bExportCritViewClause, strExportCritData

	intPermission = user_intExportPermissionCIC
	If intExportType = EXCEL_EXPORT Then
		intPermission = EXPORT_VIEW
	End If

	bExportCritViewClause = False
	strExportCritData = vbNullString
	strExportCrit = vbNullString
	strCon = vbNullString
	If Not Nl(strDSTIDList) Then
		strExportCrit = strExportCrit & strCon & "EXISTS(SELECT * FROM CIC_BT_DST dst WHERE dst.NUM=bt." & strBTNUM & " AND DST_ID IN (" & strDSTIDList & "))"
		strCon = AND_CON
	End If
	If Not Nl(strPBIDList) Then
		strExportCrit = strExportCrit & strCon & "EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt." & strBTNUM & " AND PB_ID IN (" & strPBIDList & "))"
		strCon = AND_CON
	End If
	If Not Nl(strIDList) Then
		strExportCrit = strExportCrit & strCon & "bt." & strBTNUM & " IN (" & QsStrList(strIDList) & ")"
		strCon = AND_CON
	End If
	If intExportType = XML_EXPORT_V2 Then
		strExportCrit = strExportCrit & strCon & "bt.USE_MEMBER_ID=" & g_intMemberID
		strCon = AND_CON
	End If

	Select Case intPermission
		Case EXPORT_OWNED
			strExportCrit = strExportCrit & strCon & "bt." & strBTOWNER & "=" & Qs(user_strAgency,SQUOTE)
			strCon = AND_CON
		Case EXPORT_VIEW
			bExportCritViewClause = True
			If intExportType = SHARE_EXPORT Then
				strExportCritData = strExportCrit & strCon & Replace(Replace(Replace(Replace(strWhereClauseCICExport,"DELETION_DATE","XDEL"),"UPDATE_DATE","XUPD"),"NON_PUBLIC","XNP"), "btd.", "bt.")
			ElseIf intExportType = EXCEL_EXPORT Then
				strExportCritData = strExportCrit & StringIf(Not Nl(g_strWhereClauseCIC), strCon) & strWhereClauseCICExport
			Else
				' XML_EXPORT_V2
				strExportCritData = strExportCrit & strCon & Replace(strWhereClauseCICExport, "btd.", "bt.")
			End IF
			strCon = AND_CON
	End Select

	If Nl(strExportCritData) Then
		strExportCritData = strExportCrit
	End If

	strExportSQL = "SELECT " & strSelectFields & " FROM " & strExportView
	If Not Nl(strExportCritData) Then
		strExportSQL = strExportSQL & " WHERE (" & strExportCritData & ")"
	End If
	If Not Nl(strSortFields) Then
		strExportSQL = strExportSQL & " ORDER BY " & strSortFields
	End If
	
	'Response.Write("<pre>" & strExportSQL & "</pre>")
	'Response.Flush()

	Dim cmdExport, rsExport
	Set cmdExport = Server.CreateObject("ADODB.Command")
	With cmdExport
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = strExportSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
	Set rsExport = Server.CreateObject("ADODB.Recordset")
	With rsExport
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdExport
		If .EOF Then
			bError = True
		Else
			If Not bAPIRequest Then
				Response.Write("<p>" & .RecordCount & TXT_RECORDS_TO_EXPORT & "</p>")
			End If
		End If
	End With

	If bError Then
		Call handleError(TXT_NO_RECORDS_TO_EXPORT, vbNullString, vbNullString)
	Else
		Dim strmOutput, strOutputVal
		
		strDownloadFileName = getFileName()
		strLocalPath = reReplace(Request.ServerVariables("PATH_TRANSLATED"),"export2.asp",vbNullString,True,False,False,True) & "download\"
		Select Case intExportType
			Case SHARE_EXPORT
				Set strmOutput = Server.CreateObject("ADODB.Stream")
				strmOutput.Charset = "UTF-8"
				'Line separator needs to be C only because that is what comes
				'out of the database
				strmOutput.LineSeparator = adCrLf
				strmOutput.Open

				If Not bAPIRequest Then
					Response.Write("<br>" & TXT_EXPORT_STARTED_AT & Time() & "<br>")
				End If
				strmOutput.WriteText "<?xml version=""1.0"" encoding=""UTF-8""?>", adWriteLine

				strmOutput.WriteText "<ROOT xmlns=""urn:ciocshare-schema"">", adWriteChar

				strmOutput.WriteText "<SOURCE_DB ", adWriteChar
				If Not Nl(strSourceDbNameEn) Then
					strmOutput.WriteText "NM=" & XMLQs(strSourceDbNameEn) & " ", adWriteChar
				End If
				If Not Nl(strSourceDbNameFr) Then
					strmOutput.WriteText "NMF=" & XMLQs(strSourceDbNameFr) & " ", adWriteChar
				End If
				If Not Nl(strSourceDbURLEn) Then
					strmOutput.WriteText "URL=" & XMLQs(strSourceDbURLEn) & " ", adWriteChar
				End If
				If Not Nl(strSourceDbURLFr) Then
					strmOutput.WriteText "URLF=" & XMLQs(strSourceDbURLFr) & " ", adWriteChar
				End If
				strmOutput.WriteText "/>"

				Call openPrivacyProfiles()

				Dim cmdDistributionList, rsDistributionList
				Set cmdDistributionList = Server.CreateObject("ADODB.Command")
				Set rsDistributionList = Server.CreateObject("ADODB.Recordset")
				With cmdDistributionList
					.ActiveConnection = getCurrentAdminCnn()
					.CommandText = "sp_CIC_XML_Distribution_List"
					.CommandType = adCmdStoredProc
					.CommandTimeout = 0
					.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
					Set rsDistributionList = .Execute
				End With
				With rsDistributionList
					If .EOF Then
						strmOutput.WriteText "<DIST_CODE_LIST/>", adWriteChar
					Else
						If .Fields("DIST_CODE_LIST") <> "<DIST_CODE_LIST/>" Then
							bProfileDist = True
						End If
						strmOutput.WriteText .Fields("DIST_CODE_LIST"), adWriteChar
					End If
					.Close
				End With
				Set rsDistributionList = Nothing
				Set cmdDistributionList = Nothing

				If bProfileDist Then
					Dim cmdDistribution
					Set cmdDistribution = Server.CreateObject("ADODB.Command")
					With cmdDistribution
						.ActiveConnection = getCurrentAdminCnn()
						.CommandText = "sp_CIC_XML_Distribution"
						.CommandType = adCmdStoredProc
						.CommandTimeout = 0
						.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
						.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
						.Parameters.Append .CreateParameter("@DistList", adVarChar, adParamOutput, 8000)
					End With
				End If

				Dim cmdPublicationList, rsPublicationList
				Set cmdPublicationList = Server.CreateObject("ADODB.Command")
				Set rsPublicationList = Server.CreateObject("ADODB.Recordset")
				With cmdPublicationList
					.ActiveConnection = getCurrentAdminCnn()
					.CommandText = "sp_CIC_XML_Publication_List"
					.CommandType = adCmdStoredProc
					.CommandTimeout = 0
					.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
					Set rsPublicationList = .Execute
				End With
				With rsPublicationList
					If .EOF Then
						strmOutput.WriteText "<PUB_CODE_LIST/>", adWriteChar
					Else
						If Not reEquals(.Fields("PUB_CODE_LIST"),"<PUB_CODE_LIST\s?\/>",False,False,True,False) Then
							bProfilePub = True
						End If
						strmOutput.WriteText .Fields("PUB_CODE_LIST"), adWriteChar
					End If
					.Close
				End With
				Set rsPublicationList = Nothing
				Set cmdPublicationList = Nothing

				If bProfilePub Then
					Dim cmdPublication, rsPublication
					Set cmdPublication = Server.CreateObject("ADODB.Command")
					Set rsPublication = Server.CreateObject("ADODB.Recordset")
					With cmdPublication
						.ActiveConnection = getCurrentAdminCnn()
						.CommandText = "sp_CIC_XML_Publication"
						.CommandType = adCmdStoredProc
						.CommandTimeout = 0
						.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8)
						.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
						.Parameters.Append .CreateParameter("@HasEnglish", adBoolean, adParamInput, 4, IIf(bExportEn,SQL_TRUE,SQL_FALSE))
						.Parameters.Append .CreateParameter("@HasFrench", adBoolean, adParamInput, 4, IIf(bExportFr,SQL_TRUE,SQL_FALSE))
					End With
				End If

				With rsExport
					While Not .EOF
						intPrivacyProfile = .Fields("XPRIVACY").Value
						If Nl(intPrivacyProfile) Then
							Set dicProfileFields = dicEmpty
						Else
							Set dicProfileFields = dicPrivacyProfileFields(intPrivacyProfile)
						End If
						strmOutput.WriteText "<RECORD NUM=" & XMLQs(.Fields("NUM")) & _
							" RECORD_OWNER=" & XMLQs(.Fields("RECORD_OWNER")) & _
							" HAS_ENGLISH=" & Qs(.Fields("HAS_ENGLISH"),DQUOTE) & _
							" HAS_FRENCH=" & Qs(.Fields("HAS_FRENCH"),DQUOTE), adWriteChar
						If bIncludePrivacyProfiles And Not Nl(intPrivacyProfile) Then
							Set dicProfileName = dicPrivacyProfileNames(intPrivacyProfile)
							strmOutput.WriteText " PRIVACY_PROFILE=" & XMLQs(dicProfileName("ProfileName")), adWriteChar
						End If
						strmOutput.WriteText ">", adWriteChar

						If Not Nl(strSubmitChangesToAccessURL) Then
							If Not Nl(strAccessURLTemplate) Then
								strAccessURL = strAccessURLTemplate & "/feedback.asp?NUM=" & .Fields("NUM") & IIf(Nl(intViewType),vbNullString,"&UseCICVw=" & intViewType)
								strmOutput.WriteText "<SUBMIT_CHANGES_TO ", adWriteChar
								If .Fields("HAS_ENGLISH") <> 0 Then
									strmOutput.WriteText "V=" & XMLQs(strAccessURL & "&Ln=" & CULTURE_ENGLISH_CANADIAN) & " ", adWriteChar
									strmOutput.WriteText "P=" & XMLQs(strAccessURLProtocol) & " ", adWriteChar
								End If
								If .Fields("HAS_FRENCH") <> 0 Then
									strmOutput.WriteText "VF=" & XMLQs(strAccessURL & "&Ln=" & CULTURE_FRENCH_CANADIAN) & " ", adWriteChar
									strmOutput.WriteText "PF=" & XMLQs(strAccessURLProtocol) & " ", adWriteChar
								End If
								strmOutput.WriteText "/>"
							End If
						End If
							
						For Each fld in .Fields
							If Not reEquals(fld.Name,"(NUM)|(RECORD_OWNER)|(HAS_ENGLISH)|(HAS_FRENCH)|(XPRIVACY)",True,False,True,False) Then
								If bIncludePrivacyProfiles Or Nl(intPrivacyProfile) Or Not dicProfileFields.Exists(fld.Name) Then
									strOutputVal = Nz(fld.Value,vbNullString)
									strOutputVal = Replace(Replace(strOutputVal, vbCr, vbNullString), vbLf, vbCrLf)
									strmOutput.WriteText strOutputVal, adWriteChar
								End If
							End If
						Next

						If bProfilePub Then
							cmdPublication.Parameters("@NUM") = rsExport.Fields("NUM")
							Set rsPublication = cmdPublication.Execute
							With rsPublication
								If .EOF Then
									strmOutput.WriteText "<PUBLICATION/>", adWriteChar
								Else
									strmOutput.WriteText .Fields("PUBLICATION"), adWriteChar
								End If
							End With
						End If
						
						If bProfileDist Then
							With cmdDistribution
								.Parameters("@NUM") = rsExport.Fields("NUM")
								.Execute
								strmOutput.WriteText .Parameters("@DistList"), adWriteChar
							End With
						End If

						strmOutput.WriteText "</RECORD>", adWriteLine
						If Not bAPIRequest Then
							Response.Write(". ")
							Response.Flush()
						End If
						.MoveNext
					Wend
				End With
							
				strmOutput.WriteText "</ROOT>", adWriteChar
				strmOutput.SaveToFile strLocalPath & strDownloadFileName

				If Not bAPIRequest Then
					Response.Write("<br>" & TXT_EXPORT_FINISHED_AT & Time())
				End If
				
				strmOutput.Close
				Set strmOutput = Nothing
			Case EXCEL_EXPORT
				Set strmOutput = Server.CreateObject("ADODB.Stream")
				If bHTML Then
					'Line separator needs to be C only because that is what comes
					'out of the database
					strmOutput.LineSeparator = adCrLf
					strmOutput.Charset = "UTF-8"
				Else
					strmOutput.Charset = "Windows-1252"
					strmOutput.LineSeparator = adLf
				End If
				strmOutput.Open

				If Not bAPIRequest Then
					Response.Write("<br>" & TXT_EXPORT_STARTED_AT & Time() & "<br>")
				End If

				If bHTML Then
					strmOutput.WriteText "<html>" & vbCrLf & _
						"<head>" & vbCrLf & _
						"<meta http-equiv=Content-Type content=""text/html; charset=utf-8"">" & vbCrLf & _
						"<meta name=ProgId content=Excel.Sheet>" & vbCrLf & _
						"<style type=""text/css"">" & vbCrLf & _
						"	br {mso-data-placement:same-cell;}" & vbCrLf & _
						"</style>" & vbCrLf & _
						"</head>" & vbCrLf & _
						"<body>" & vbCrLf & _
						"<table border=""1"">", adWriteLine
				End If
				
				Call openPrivacyProfiles()

				Dim strFieldVal, _
					bFirstField

				With rsExport
					If Not Nl(bColumnHeaders) Then
						bFirstField = True
						If bHTML Then
							strmOutput.WriteText "<tr>"
						End If
						While Not rsExcelProfile.EOF
							If bHTML Then
								strmOutput.WriteText "<th>" & Nz(rsExcelProfile.Fields("FieldDisplay"),vbNullString) & "</th>", adWriteLine
							Else
								strmOutput.WriteText StringIf(Not bFirstField,",") & Qs(Nz(rsExcelProfile.Fields("FieldDisplay"),vbNullString),DQUOTE), adWriteChar
							End If
							bFirstField = False
							rsExcelProfile.MoveNext
						Wend
						If bHTML Then
							strmOutput.WriteText "</tr>"
						Else
							strmOutput.WriteText vbLf, adWriteChar
						End If
					End If
					
					While Not .EOF
						bFirstField = True
						intPrivacyProfile = .Fields("XPRIVACY").Value
						If Nl(intPrivacyProfile) Then
							Set dicProfileFields = dicEmpty
						Else
							Set dicProfileFields = dicPrivacyProfileFields(intPrivacyProfile)
						End If
						
						If bHTML Then
							strmOutput.WriteText "<tr valign=""top"">", adWriteLine
						End If
						
						If rsExcelProfile.RecordCount > 0 Then
							rsExcelProfile.MoveFirst
						End If
						While Not rsExcelProfile.EOF
							If Not Nl(intPrivacyProfile) And dicProfileFields.Exists(rsExcelProfile.Fields("FieldName")) Then
								strFieldVal = vbNullString
							ElseIf bHTML Then
								strFieldVal = textToHTML(Nz(.Fields(rsExcelProfile.Fields("FieldName").Value),vbNullString))
								If rsExcelProfile.Fields("CheckHTML") Then
									strFieldVal = stripLinks(stripParagraphs(strFieldVal))
								End If
							Else
								strFieldVal = Replace(Nz(.Fields(rsExcelProfile.Fields("FieldName").Value),vbNullString), vbCrLf, vbLf)
							End If
							If bHTML Then
								strmOutput.WriteText "<td>" & strFieldVal & "</td>", adWriteLine
							Else
								strmOutput.WriteText StringIf(Not bFirstField,",") & Qs(strFieldVal,DQUOTE), adWriteChar
							End If
							bFirstField = False
							rsExcelProfile.MoveNext
						Wend
						If bHTML Then
							strmOutput.WriteText "</tr>", adWriteLine
						Else
							strmOutput.WriteText vbLf, adWriteChar
						End If
						If Not bAPIRequest Then
							Response.Write(". ")
							Response.Flush()
						End If
						.MoveNext
					Wend
				End With
				
				If bHTML Then
					strmOutput.WriteText "</table>" & vbCrLf & _
						"</body>" & vbCrLf & _
						"</html>", adWriteChar
				End If
				
				strmOutput.SaveToFile strLocalPath & strDownloadFileName

				If Not bAPIRequest Then
					Response.Write("<br>" & TXT_EXPORT_FINISHED_AT & Time())
				End If
				
				strmOutput.Close
				Set strmOutput = Nothing
				
				Set rsExcelProfile = Nothing
			Case XML_EXPORT_V2
				rsExport.Save strLocalPath & strDownloadFileName, adPersistXML
		End Select
		If Not bAPIRequest Then
%>
<h1><%=TXT_EXPORT_COMPLETE%></h1>
<p><%=TXT_INST_SAVE_FILE%></p>
<%
		End If
Dim strExt1, strExt2, strLabel2, bHasSecondLink
If intExportType = SHARE_EXPORT Then
	strExt1 = ".zip"
	bHasSecondLink = False
ElseIf intExportType = EXCEL_EXPORT Then
	bHasSecondLink = True
	If g_bDownloadUncompressed Then
		strExt1 = vbNullString
		strExt2 = ".zip"
		strLabel2 = TXT_COMPRESSED
	Else
		strExt1 = ".zip"
		strExt2 = vbNullString
		strLabel2 = TXT_UNCOMPRESSED
	End If
Else
	bHasSecondLink = g_bDownloadUncompressed
	strExt1 = ".zip"
	If g_bDownloadUncompressed Then
		strExt1 = vbNullString
		strExt2 = ".zip"
		strLabel2 = TXT_COMPRESSED
	End If

End If
If Not bAPIRequest Then
%>
<p><a href="<%= makeLinkB("downloads/" & Server.URLEncode(strDownloadFileName) & strExt1) %>"><%=TXT_EXPORT_FILE%></a><%If bHasSecondLink Then%> (<a href="<%= makeLinkB("downloads/" & Server.URLEncode(strDownloadFileName) & strExt2) %>"><%= strLabel2 %></a>)<%End If%></p>
<%
	Else
		' XXX take off port
		strAccessURL = Request.ServerVariables("HTTP_HOST")
%>
{
	"zipped": <%= JSONQs(IIf(g_bSSL, "https://", "http://") & strAccessURL & makeLink("~/downloads/" & Server.URLEncode(strDownloadFileName) & ".zip", "api=on", vbNullString), True) %>,
	"unzipped": <%= JSONQs(IIf(g_bSSL, "https://", "http://") & strAccessURL & makeLink("~/downloads/" & Server.URLEncode(strDownloadFileName), "api=on", vbNullString), True) %> 
}
<%
	End If
	End If

	Set rsExport = Nothing	
	Set cmdExport = Nothing
	
End If
%>
<%
If Not bAPIRequest Then
Call makePageFooter(False)
End If
%>
<!--#include file="includes/core/incClose.asp" -->
