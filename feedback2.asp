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
Call setPageInfo(False, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtCommonForm.asp" -->
<!--#include file="text/txtEntryForm.asp" -->
<!--#include file="text/txtFeedback.asp" -->
<!--#include file="text/txtFeedbackCommon.asp" -->
<!--#include file="text/txtFormDataCheck.asp" -->
<!--#include file="text/txtFormSecurity.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtGeoCode.asp" -->
<!--#include file="text/txtMonth.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/list/incMonthList.asp" -->
<!--#include file="includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="includes/update/incEventSchedule.asp" -->
<!--#include file="includes/update/incEntryFormGeneral.asp" -->
<!--#include file="includes/update/incFeedbackFormProcessGeneral.asp" -->
<!--#include file="includes/validation/incFormDataCheck.asp" -->
<!--#include file="includes/validation/incVulgarCheck.asp" -->
<!--#include file="includes/core/incSendMail.asp" -->

<script language="python" runat="server">
def get_feedback_msg(culture):
	try:
		return pyrequest.dboptions[culture].FeedbackMsgCIC
	except KeyError:
		return ''

</script>
<%
'On Error Resume Next

Dim objUpdateLang, _
	strUpdateLang

strUpdateLang = Request("UpdateLn")
If Not IsCulture(strUpdateLang) Then
	strUpdateLang = vbNullString
End If

If Nl(strUpdateLang) Then
	strUpdateLang = Request("Ln")
	If Not IsCulture(strUpdateLang) Then
		strUpdateLang = vbNullString
	End If
End If

Set objUpdateLang = create_language_object()
objUpdateLang.setSystemLanguage(Nz(strUpdateLang,g_objCurrentLang.Culture))

Dim strRestoreCulture
strRestoreCulture = g_objCurrentLang.Culture
Call setSessionLanguage(objUpdateLang.Culture)

Class PubFbEntry
	Public intID
	Public strDescription
	Public strHeadings
End Class

Dim strInsertIntoFBE, strInsertValueFBE
Dim strInsertIntoFB, strInsertValueFB
Dim strInsertIntoCFB, strInsertValueCFB
Dim strInsertIntoCCFB, strInsertValueCCFB
Dim strInsSQL, strExtraSQL

Sub getCCLicenseInfoFields(ByRef strInsertInto,ByRef strInsertValue)
	Dim strLCNumber, _
		dLCRenewal, _
		intLCTotal, _
		intLCInfant, _
		intLCToddler, _
		intLCPreschool, _
		intLCKindergarten, _
		intLCSchoolAge, _
		strLCNotes

		strLCNumber = QsNNl(getStrSetValue("LICENSE_NUMBER"))
		dLCRenewal = QsNNl(getDateSetValue("LICENSE_RENEWAL"))
		intLCTotal = QsNNl(getStrSetValue("LC_TOTAL"))
		intLCInfant = QsNNl(getStrSetValue("LC_INFANT"))
		intLCToddler = QsNNl(getStrSetValue("LC_TODDLER"))
		intLCPreschool = QsNNl(getStrSetValue("LC_PRESCHOOL"))
		intLCKindergarten = QsNNl(getStrSetValue("LC_KINDERGARTEN"))
		intLCSchoolAge = QsNNl(getStrSetValue("LC_SCHOOLAGE"))
		strLCNotes = QsNNl(getStrSetValue("LC_NOTES"))

		If addInsertField("LICENSE_NUMBER",strLCNumber,strInsertInto,strInsertValue) Then
			Call addEmailField(TXT_LICENSE_NUMBER,strLCNumber)
		End If
		If addInsertField("LICENSE_RENEWAL",dLCRenewal,strInsertInto,strInsertValue) Then
			Call addEmailField(TXT_LICENSE_RENEWAL,dLCRenewal)
		End If
		If addInsertField("LC_TOTAL",intLCTotal,strInsertInto,strInsertValue) Then
			Call addEmailField(TXT_CAPACITY & " - " & TXT_TOTAL,intLCTotal)
		End If
		If addInsertField("LC_INFANT",intLCInfant,strInsertInto,strInsertValue) Then
			Call addEmailField(TXT_CAPACITY & " - " & TXT_INFANT,intLCInfant)
		End If
		If addInsertField("LC_TODDLER",intLCToddler,strInsertInto,strInsertValue) Then
			Call addEmailField(TXT_CAPACITY & " - " & TXT_TODDLER,intLCToddler)
		End If
		If addInsertField("LC_PRESCHOOL",intLCPreschool,strInsertInto,strInsertValue) Then
			Call addEmailField(TXT_CAPACITY & " - " & TXT_PRESCHOOL,intLCPreschool)
		End If
		If addInsertField("LC_KINDERGARTEN",intLCKindergarten,strInsertInto,strInsertValue) Then
			Call addEmailField(TXT_CAPACITY & " - " & TXT_KINDERGARTEN,intLCKindergarten)
		End If
		If addInsertField("LC_SCHOOLAGE",intLCSchoolAge,strInsertInto,strInsertValue) Then
			Call addEmailField(TXT_CAPACITY & " - " & TXT_SCHOOL_AGE,intLCSchoolAge)
		End If
		If addInsertField("LC_NOTES",strLCNotes,strInsertInto,strInsertValue) Then
			Call addEmailField(TXT_CAPACITY & " - " & TXT_NOTES,strLCNotes)
		End If

End Sub

Sub getEligibilityFields(strFieldDisplay)
	Dim strFieldVal
	strFieldVal = getStrSetValue("MIN_AGE")
	If addInsertField("MIN_AGE",QsNNl(strFieldVal),strInsertIntoCFB,strInsertValueCFB) Then
		Call addEmailField(TXT_MIN_AGE,strFieldVal)
	End If
	strFieldVal = getStrSetValue("MAX_AGE")
	If addInsertField("MAX_AGE",QsNNl(strFieldVal),strInsertIntoCFB,strInsertValueCFB) Then
		Call addEmailField(TXT_MAX_AGE,strFieldVal)
	End If
	strFieldVal = getStrSetValue("ELIGIBILITY_NOTES")
	If addInsertField("ELIGIBILITY_NOTES",QsNNl(strFieldVal),strInsertIntoCFB,strInsertValueCFB) Then
		Call addEmailField(strFieldDisplay & " " & TXT_NOTES,strFieldVal)
	End If
End Sub

Sub getEmployeesFields(strFieldDisplay)
	Dim strFieldVal
	strFieldVal = getStrSetValue("EMPLOYEES_FT")
	If addInsertField("EMPLOYEES_FT",QsNNl(strFieldVal),strInsertIntoCFB,strInsertValueCFB) Then
		Call addEmailField("Full Time",strFieldVal)
	End If
	strFieldVal = getStrSetValue("EMPLOYEES_PT")
	If addInsertField("EMPLOYEES_PT",QsNNl(strFieldVal),strInsertIntoCFB,strInsertValueCFB) Then
		Call addEmailField("Part Time / Seasonal",strFieldVal)
	End If
	strFieldVal = getStrSetValue("EMPLOYEES_TOTAL")
	If addInsertField("EMPLOYEES_TOTAL",QsNNl(strFieldVal),strInsertIntoCFB,strInsertValueCFB) Then
		Call addEmailField("Total Employees",strFieldVal)
	End If
End Sub

Sub getLanguagesFields(strFieldDisplay)
	Dim strNUM, strNotes
	If Not bSuggest Then
		strNUM = rsOrg("NUM")
		strNotes = rsOrg("LANGUAGE_NOTES")
	Else
		strNum = vbNullString
		strNotes = vbNullString
	End If

	Dim strIDList
	strIDList = Replace(Trim(Request("LN_ID")), " ", vbNullString)

	Dim cmdLanguage, rsLanguage, aLanguageDetails
	Set cmdLanguage = Server.CreateObject("ADODB.Command")
	With cmdLanguage
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMLanguage_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@LNIDs", adVarChar, adParamInput, 5000, strIDList)
	End With
	Set rsLanguage = cmdLanguage.Execute
	
	makeLanguageDetailsMap(rsLanguage)
	Dim strXML, strEmailText, strEmailCon, bChanged, strSubIDList, aSubIDList, indID, bChecked, strLNNote, aDetailNames, strXMLInner, strExistingDetail, i
	bChanged = False
	strEmailCon = vbNullString
	strEmailText = vbNullString
	strXML = vbNullString

	If Nl(strIDList) Or Not IsIDList(strIDList) Then
		strIDList = vbNullString
	Else
		strIDList = "<" & Replace(strIDList, ",", "><") & ">"
	End If

	Set rsLanguage = rsLanguage.NextRecordset
	With rsLanguage
		While Not .EOF
			strSubIDList = vbNullString
			bChecked = InStr(strIDList, "<" & .Fields("LN_ID") & ">") > 0 
			If bChecked Then
				strLNNote = Trim(Request("LN_NOTES_" & .Fields("LN_ID")))
				strSubIDList = Trim(Request("LND_" & .Fields("LN_ID")))
				If Nl(strSubIDList) Or Not IsIDList(strSubIDList) Then
					strSubIDList = vbNullString
					aSubIDList = Array()
					aDetailNames = Array()
					strXMLInner = vbNullString
				Else
					aSubIDList = Split(Replace(strSubIDList, " ", vbNullString), ",")
					ReDim aDetailNames(UBound(aSubIDList))
					strXMLInner = "<LNDS><LND>" & Join(aSubIDList, "</LND><LND>") & "</LND></LNDS>"
				End If
				strExistingDetail = "<" & Replace(Ns(.Fields("LNDIDs")), ",", "><") & ">"
				For i = 0 to UBound(aSubIDList)
					indID = aSubIDList(i)
					aDetailNames(i) = getLanguageDetailValue(indID, "Name")
					If InStr(strExistingDetail, "<" & indID & ">") = 0 Then
						bChanged = True
					End If
				Next
				If Not Nl(strExistingDetail) And Not bChanged Then
					Dim subIDs
					subIds = "<" & Join(aSubIDList, "><") & ">"
					For Each indID in Split(Ns(.Fields("LNDIDs")), ",")
						If InStr(subIds, "<" & indID & ">") = 0 Then
							bChanged = True
						End If
					Next
				End If
				strEmailText = strEmailText & strEmailCon & .Fields("LanguageName")
				If Not Nl(strSubIDList) Or Not Nl(strLNNote) Then
					strEmailText = strEmailText & TXT_COLON
				End If 
				If Not Nl(strSubIDList) Then
					strEmailText = strEmailText & Join(aDetailNames, ", ")
				End If
				If Not Nl(strSubIDList) And Not Nl(strLNNote) Then
					strEmailText = strEmailText & ", "
				End If
				strEmailText = strEmailText & Ns(strLNNote)
				strEmailCon = " ; "
				strXML = strXML & "<LN ID=" & XMLQs(.Fields("LN_ID")) & StringIf(Not Nl(strLNNote), " NOTE=" & XMLQs(strLNNote)) & _
						IIf(Not Nl(strXMLInner), ">" & strXMLInner & "</LN>", "/>")
					
			End If
			If .Fields("IS_SELECTED") <> IIf(bChecked, 1, 0) Then
				bChanged = True
				If Not bChecked Then
					strEmailText = strEmailText & strEmailCon & .Fields("LanguageName") & TXT_COLON & TXT_CONTENT_DELETED
					strEmailCon = " ; "
				End If
			End If
			.MoveNext
		Wend
	End With

	If Not Nl(strXML) Then
		strXML = "<LNS>" & strXML & "</LNS>"
	End If
	strLNNote = Trim(Request("LANGUAGE_NOTES"))
	If Not Nl(strLNNote) Then
		strXML = strXML & "<NOTE>" & XMLEncode(strLNNote) & "</NOTE>"
		strEmailText = strEmailText & strEmailCon & strLNNote
	End If
	If Ns(strLNNote) <> Ns(strNotes) Then
		bChanged = True
		If Nl(strLNNote) Then
			strEmailText = strEmailText & strEmailCon & TXT_NOTES & TXT_COLON & TXT_CONTENT_DELETED
		End If
	End If
	strXML = "<LANGUAGES>" & strXML & "</LANGUAGES>"

	If bChanged Then
		Call addInsertField("LANGUAGES", QsNl(strXML), strInsertIntoCFB,strInsertValueCFB)
	End If
	If Not Nl(strEmailText) Then
		Call addEmailField(strFieldDisplay, strEmailText)
	End If

End Sub

Sub getGeocodeFields(strFieldDisplay)
	Dim intGeoCodeType, strGeoCodeType, _
		decLat, decLong, _
		strNotes

	intGeoCodeType = getStrSetValue("GEOCODE_TYPE")
	decLat = getStrSetValue("LATITUDE")
	decLong = getStrSetValue("LONGITUDE")
	strNotes = getStrSetValue("GEOCODE_NOTES")

	If IsNumeric(intGeoCodeType) Then
		intGeoCodeType = CInt(intGeoCodeType)
	Else
		intGeoCodeType = Null
		decLat = Null
		decLong = Null
	End If

	If intGeoCodeType = GC_BLANK Then
		decLat = Null
		decLong = Null
	ElseIf intGeoCodeType > GC_BLANK And intGeoCodeType <= GC_MANUAL And Not (Nl(decLat) Or Nl(decLong)) Then
		If Not (IsNumeric(decLat) And IsNumeric(decLong)) Then
			intGeoCodeType = Null
			decLat = Null
			decLong = Null
		Else
			decLat = CDbl(decLat)
			decLong = CDbl(decLong)
			If Not (decLat >= -180 And decLat =< 180 And decLong >= -180 And decLong =< 180) Then
				intGeoCodeType = Null
				decLat = Null
				decLong = Null
			End If
		End If
	End If

	If addInsertField("GEOCODE_TYPE",intGeoCodeType,strInsertIntoFB,strInsertValueFB) Then
		Select Case intGeoCodeType
			Case GC_BLANK
				strGeoCodeType = TXT_GC_BLANK_NO_GEOCODE
			Case GC_SITE
				strGeoCodeType = TXT_GC_SITE_ADDRESS
			Case GC_INTERSECTION
				strGeoCodeType = TXT_GC_INTERSECTION
			Case GC_MANUAL
				strGeoCodeType = TXT_GC_MANUAL
		End Select
		Call addEmailField(TXT_GEOCODE,strGeoCodeType)
	End If
	If addInsertField("LATITUDE",QsNl(decLat),strInsertIntoFB,strInsertValueFB) Then
		Call addEmailField(TXT_GEOCODE & " - " & TXT_LATITUDE,decLat)
	End If
	If addInsertField("LONGITUDE",QsNl(decLong),strInsertIntoFB,strInsertValueFB) Then
		Call addEmailField(TXT_GEOCODE & " - " & TXT_LONGITUDE,decLong)
	End If
	If addInsertField("GEOCODE_NOTES",QsNNl(strNotes),strInsertIntoFB,strInsertValueFB) Then
		Call addEmailField(strFieldDisplay & " " & TXT_NOTES,strNotes)
	End If
End Sub

Sub getLogoAddressFields(strFieldDisplay)
	Dim strFieldVal
	strFieldVal = getStrSetValue("LOGO_ADDRESS")
	If addInsertField("LOGO_ADDRESS",QsNNl(strFieldVal),strInsertIntoCFB,strInsertValueCFB) Then
		Call addEmailField(TXT_LOGO_ADDRESS,strFieldVal)
	End If
	strFieldVal = getStrSetValue("LOGO_ADDRESS_LINK")
	If addInsertField("LOGO_ADDRESS_LINK",QsNNl(strFieldVal),strInsertIntoCFB,strInsertValueCFB) Then
		Call addEmailField(TXT_LOGO_LINK_ADDRESS,strFieldVal)
	End If
	strFieldVal = getStrSetValue("LOGO_ADDRESS_HOVER_TEXT")
	If addInsertField("LOGO_ADDRESS_HOVER_TEXT",QsNNl(strFieldVal),strInsertIntoCFB,strInsertValueCFB) Then
		Call addEmailField(TXT_LOGO_HOVER_TEXT,strFieldVal)
	End If
	strFieldVal = getStrSetValue("LOGO_ADDRESS_ALT_TEXT")
	If addInsertField("LOGO_ADDRESS_ALT_TEXT",QsNNl(strFieldVal),strInsertIntoCFB,strInsertValueCFB) Then
		Call addEmailField(TXT_LOGO_ALT_TEXT,strFieldVal)
	End If
End Sub

Sub getMailAddressFields(strFieldDisplay)
	Dim aStreetType, _
		strOldStreetType, _
		bOldAfterName
	
	aStreetType = Split(Trim(Request("MAIL_STREET_TYPE")),"|")

	If Not bSuggest Then
		strOldStreetType = Trim(rsOrg("MAIL_STREET_TYPE"))
		bOldAfterName = rsOrg("MAIL_STREET_TYPE_AFTER")
	End If

	If Not IsArray(aStreetType) Then
		ReDim Preserve aStreetType(1)
		aStreetType(0) = Null
		aStreetType(1) = Null
	End If

	If UBound(aStreetType) > 0 Then
		If aStreetType(1) = CStr(SQL_TRUE) And Not Nl(aStreetType(0)) Then
			aStreetType(1) = SQL_TRUE
		ElseIf aStreetType(1) = CStr(SQL_FALSE) And Not Nl(aStreetType(0)) Then
			aStreetType(1) = SQL_FALSE
		Else
			aStreetType(1) = "NULL"
		End If
	Else
		ReDim Preserve aStreetType(1)
		aStreetType(1) = Null
	End If

	If Not bSuggest Then
		If Nl(aStreetType(1)) And Nl(bOldAfterName) Then
			aStreetType(1) = Null
		ElseIf Not Nl(aStreetType(1)) Then
			If CBool(aStreetType(1)) = bOldAfterName Then
				aStreetType(1) = Null
			End If
		End If
		If aStreetType(0) = strOldStreetType Then
			If Nl(aStreetType(1)) Then
				aStreetType(0) = Null
			End If
		ElseIf Nl(aStreetType(0)) And Not Nl(strOldStreetType) Then
			aStreetType(0) = Qs(TXT_CONTENT_DELETED,SQUOTE)
		End If
	End If

	If addInsertField("MAIL_CARE_OF",QsNNl(getStrSetValue("MAIL_CARE_OF")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_LINE_1",QsNNl(getStrSetValue("MAIL_LINE_1")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_LINE_2",QsNNl(getStrSetValue("MAIL_LINE_2")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_BOX_TYPE",QsNNl(getStrSetValue("MAIL_BOX_TYPE")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_PO_BOX",QsNNl(getStrSetValue("MAIL_PO_BOX")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_BUILDING",QsNNl(getStrSetValue("MAIL_BUILDING")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_STREET_NUMBER",QsNNl(getStrSetValue("MAIL_STREET_NUMBER")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_STREET",QsNNl(getStrSetValue("MAIL_STREET")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_STREET_TYPE",QsNNl(aStreetType(0)),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_STREET_TYPE_AFTER",aStreetType(1),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_STREET_DIR",QsNNl(getStrSetValue("MAIL_STREET_DIR")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_SUFFIX",QsNNl(getStrSetValue("MAIL_SUFFIX")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_CITY",QsNNl(getStrSetValue("MAIL_CITY")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_PROVINCE",QsNNl(getStrSetValue("MAIL_PROVINCE")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_COUNTRY",QsNNl(getStrSetValue("MAIL_COUNTRY")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("MAIL_POSTAL_CODE",QsNNl(getStrSetValue("MAIL_POSTAL_CODE")),strInsertIntoFB,strInsertValueFB) Then
		Dim cmdAddress, rsAddress
		Set cmdAddress = Server.CreateObject("ADODB.Command")
		With cmdAddress
			.ActiveConnection = getCurrentCICBasicCnn()
			.CommandType = adCmdStoredProc
			.CommandText = "dbo.fn_GBL_FullAddress"
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@RETURN_VALUE", adVarChar, adParamReturnValue, 8000)
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, Null)
			.Parameters.Append .CreateParameter("@RSN", adInteger, adParamInput, 4, Null)
			.Parameters.Append .CreateParameter("@Line1", adVarChar, adParamInput, 100, Left(Trim(Request("MAIL_LINE_1")),255))
			.Parameters.Append .CreateParameter("@Line2", adVarChar, adParamInput, 100, Left(Trim(Request("MAIL_LINE_2")),255))
			.Parameters.Append .CreateParameter("@Building", adVarChar, adParamInput, 100, Left(Trim(Request("MAIL_BUILDING")),100))
			.Parameters.Append .CreateParameter("@StreetNumber", adVarWChar, adParamInput, 30, Left(Trim(Request("MAIL_STREET_NUMBER")),30))
			.Parameters.Append .CreateParameter("@Street", adVarWChar, adParamInput, 150, Left(Trim(Request("MAIL_STREET")),150))
			.Parameters.Append .CreateParameter("@StreetType", adVarWChar, adParamInput, 30, Nz(aStreetType(0),Null))
			.Parameters.Append .CreateParameter("@AfterName", adBoolean, adParamInput, 1, Nz(aStreetType(1),Null))
			.Parameters.Append .CreateParameter("@StreetDir", adVarChar, adParamInput, 2, Left(Trim(Request("MAIL_STREET_DIR")),2))
			.Parameters.Append .CreateParameter("@Suffix", adVarWChar, adParamInput, 150, Left(Trim(Request("MAIL_SUFFIX")),150))
			.Parameters.Append .CreateParameter("@City", adVarWChar, adParamInput, 100, Left(Trim(Request("MAIL_CITY")),100))
			.Parameters.Append .CreateParameter("@Province", adVarChar, adParamInput, 2, Left(Trim(Request("MAIL_PROVINCE")),2))
			.Parameters.Append .CreateParameter("@Country", adVarWChar, adParamInput, 100, Left(Trim(Request("MAIL_COUNTRY")),100))
			.Parameters.Append .CreateParameter("@PostalCode", adVarChar, adParamInput, 20, Left(Trim(Request("MAIL_POSTAL_CODE")),20))
			.Parameters.Append .CreateParameter("@CareOf", adVarWChar, adParamInput, 150, Left(Trim(Request("MAIL_CARE_OF")),150))
			.Parameters.Append .CreateParameter("@BoxType", adVarWChar, adParamInput, 20, Left(Trim(Request("MAIL_BOX_TYPE")),20))
			.Parameters.Append .CreateParameter("@POBox", adVarWChar, adParamInput, 100, Left(Trim(Request("MAIL_PO_BOX")),100))
			.Parameters.Append .CreateParameter("@LATITUDE", adDecimal, adParamInput)
			.Parameters("@LATITUDE").Precision = 11
			.Parameters("@LATITUDE").NumericScale = 7
			.Parameters("@LATITUDE") = Null
			.Parameters.Append .CreateParameter("@LONGITUDE", adDecimal, adParamInput)
			.Parameters("@LONGITUDE").Precision = 11
			.Parameters("@LONGITUDE").NumericScale = 7
			.Parameters("@LONGITUDE") = Null
			.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2, g_objCurrentLang.LangID)
			.Parameters.Append .CreateParameter("@WebEnable", adBoolean, adParamInput, 1, SQL_FALSE)
			Set rsAddress = .Execute
		End With
		Set rsAddress = rsAddress.NextRecordset
		Call addEmailField("Mailing Address",cmdAddress.Parameters("@RETURN_VALUE").Value)
		Set rsAddress = Nothing
		Set cmdAddress = Nothing
	End If
End Sub

Sub getSiteAddressFields(strFieldDisplay)
	Dim aStreetType, _
		strOldStreetType, _
		bOldAfterName
	
	aStreetType = Split(Trim(Request("SITE_STREET_TYPE")),"|")

	If Not bSuggest Then
		strOldStreetType = Trim(rsOrg("SITE_STREET_TYPE"))
		bOldAfterName = rsOrg("SITE_STREET_TYPE_AFTER")
	End If

	If Not IsArray(aStreetType) Then
		ReDim Preserve aStreetType(1)
		aStreetType(0) = Null
		aStreetType(1) = Null
	End If

	If UBound(aStreetType) > 0 Then
		If aStreetType(1) = CStr(SQL_TRUE) And Not Nl(aStreetType(0)) Then
			aStreetType(1) = SQL_TRUE
		ElseIf aStreetType(1) = CStr(SQL_FALSE) And Not Nl(aStreetType(0)) Then
			aStreetType(1) = SQL_FALSE
		Else
			aStreetType(1) = "NULL"
		End If
	Else
		ReDim Preserve aStreetType(1)
		aStreetType(1) = Null
	End If

	If Not bSuggest Then
		If Nl(aStreetType(1)) And Nl(bOldAfterName) Then
			aStreetType(1) = Null
		ElseIf Not Nl(aStreetType(1)) Then
			If CBool(aStreetType(1)) = bOldAfterName Then
				aStreetType(1) = Null
			End If
		End If
		If aStreetType(0) = strOldStreetType Then
			If Nl(aStreetType(1)) Then
				aStreetType(0) = Null
			End If
		ElseIf Nl(aStreetType(0)) And Not Nl(strOldStreetType) Then
			aStreetType(0) = Qs(TXT_CONTENT_DELETED,SQUOTE)
		End If
	End If

	If addInsertField("SITE_LINE_1",QsNNl(getStrSetValue("SITE_LINE_1")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_LINE_2",QsNNl(getStrSetValue("SITE_LINE_2")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_BUILDING",QsNNl(getStrSetValue("SITE_BUILDING")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_STREET_NUMBER",QsNNl(getStrSetValue("SITE_STREET_NUMBER")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_STREET",QsNNl(getStrSetValue("SITE_STREET")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_STREET_TYPE",QsNNl(aStreetType(0)),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_STREET_TYPE_AFTER",aStreetType(1),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_STREET_DIR",QsNNl(getStrSetValue("SITE_STREET_DIR")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_SUFFIX",QsNNl(getStrSetValue("SITE_SUFFIX")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_CITY",QsNNl(getStrSetValue("SITE_CITY")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_PROVINCE",QsNNl(getStrSetValue("SITE_PROVINCE")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_COUNTRY",QsNNl(getStrSetValue("SITE_COUNTRY")),strInsertIntoFB,strInsertValueFB) Or _
			addInsertField("SITE_POSTAL_CODE",QsNNl(getStrSetValue("SITE_POSTAL_CODE")),strInsertIntoFB,strInsertValueFB) Then
		Dim cmdAddress, rsAddress
		Set cmdAddress = Server.CreateObject("ADODB.Command")
		With cmdAddress
			.ActiveConnection = getCurrentCICBasicCnn()
			.CommandType = adCmdStoredProc
			.CommandText = "dbo.fn_GBL_FullAddress"
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@RETURN_VALUE", adVarChar, adParamReturnValue, 8000)
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, Null)
			.Parameters.Append .CreateParameter("@RSN", adInteger, adParamInput, 4, Null)
			.Parameters.Append .CreateParameter("@Line1", adVarChar, adParamInput, 100, Left(Trim(Request("SITE_LINE_1")),255))
			.Parameters.Append .CreateParameter("@Line2", adVarChar, adParamInput, 100, Left(Trim(Request("SITE_LINE_2")),255))
			.Parameters.Append .CreateParameter("@Building", adVarWChar, adParamInput, 100, Left(Trim(Request("SITE_BUILDING")),100))
			.Parameters.Append .CreateParameter("@StreetNumber", adVarWChar, adParamInput, 30, Left(Trim(Request("SITE_STREET_NUMBER")),30))
			.Parameters.Append .CreateParameter("@Street", adVarWChar, adParamInput, 150, Left(Trim(Request("SITE_STREET")),150))
			.Parameters.Append .CreateParameter("@StreetType", adVarWChar, adParamInput, 30, Nz(aStreetType(0),Null))
			.Parameters.Append .CreateParameter("@AfterName", adBoolean, adParamInput, 1, Nz(aStreetType(1),Null))
			.Parameters.Append .CreateParameter("@StreetDir", adVarChar, adParamInput, 2, Left(Trim(Request("SITE_STREET_DIR")),2))
			.Parameters.Append .CreateParameter("@Suffix", adVarWChar, adParamInput, 150, Left(Trim(Request("SITE_SUFFIX")),150))
			.Parameters.Append .CreateParameter("@City", adVarWChar, adParamInput, 100, Left(Trim(Request("SITE_CITY")),100))
			.Parameters.Append .CreateParameter("@Province", adVarChar, adParamInput, 2, Left(Trim(Request("SITE_PROVINCE")),2))
			.Parameters.Append .CreateParameter("@Country", adVarWChar, adParamInput, 100, Left(Trim(Request("SITE_COUNTRY")),100))
			.Parameters.Append .CreateParameter("@PostalCode", adVarChar, adParamInput, 20, Left(Trim(Request("SITE_POSTAL_CODE")),20))
			.Parameters.Append .CreateParameter("@CareOf", adVarWChar, adParamInput, 100, Null)
			.Parameters.Append .CreateParameter("@BoxType", adVarWChar, adParamInput, 20, Null)
			.Parameters.Append .CreateParameter("@POBox", adVarWChar, adParamInput, 100, Null)
			.Parameters.Append .CreateParameter("@LATITUDE", adDecimal, adParamInput)
			.Parameters("@LATITUDE").Precision = 11
			.Parameters("@LATITUDE").NumericScale = 7
			.Parameters("@LATITUDE") = Null
			.Parameters.Append .CreateParameter("@LONGITUDE", adDecimal, adParamInput)
			.Parameters("@LONGITUDE").Precision = 11
			.Parameters("@LONGITUDE").NumericScale = 7
			.Parameters("@LONGITUDE") = Null
			.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2, g_objCurrentLang.LangID)
			.Parameters.Append .CreateParameter("@WebEnable", adBoolean, adParamInput, 1, SQL_FALSE)
			Set rsAddress = .Execute
		End With
		Set rsAddress = rsAddress.NextRecordset
		Call addEmailField("Site Address",cmdAddress.Parameters("@RETURN_VALUE").Value)
		Set rsAddress = Nothing
		Set cmdAddress = Nothing
	End If
End Sub

Sub getSpaceAvailableFields(strFieldDisplay)
	Dim strFieldVal
	strFieldVal = getCbSetValue("SPACE_AVAILABLE", rsFields.Fields("CheckboxOnText"), rsFields.Fields("CheckboxOffText"))	
	If addInsertField("SPACE_AVAILABLE",QsNNl(strFieldVal),strInsertIntoCCFB,strInsertValueCCFB) Then
		Call addEmailField(strFieldDisplay,strFieldVal)
	End If
	strFieldVal = getDateSetValue("SPACE_AVAILABLE_DATE")
	If addInsertField("SPACE_AVAILABLE_DATE",QsNNl(strFieldVal),strInsertIntoCCFB,strInsertValueCCFB) Then
		Call addEmailField(strFieldDisplay & " " & TXT_DATE_OF_CHANGE,strFieldVal)
	End If
	strFieldVal = getStrSetValue("SPACE_AVAILABLE_NOTES")
	If addInsertField("SPACE_AVAILABLE_NOTES",QsNNl(strFieldVal),strInsertIntoCCFB,strInsertValueCCFB) Then
		Call addEmailField(strFieldDisplay & " " & TXT_NOTES,strFieldVal)
	End If
End Sub

Sub getSubjectFields(strFieldDisplay)
	Dim strFieldVal
	strFieldVal = getBasicListSetValue("SUBJECTS","#","#")
	If addInsertField("SUBJECTS",QsNNl(strFieldVal),strInsertIntoCFB,strInsertValueCFB) Then
		Call addEmailField(strFieldDisplay & " " & TXT_NOTES,strFieldVal)
	End If
End Sub

Dim strNUM, _
	bNUMError, _
	bSuggest, _
	bUpdatePasswordRequired, _
	strUpdatePassword

bNUMError = False
bSuggest = False

strNUM = Trim(Request("NUM"))
strUpdatePassword = Trim(Request("FeedbackPassword"))
If Nl(strUpdatePassword) Then
	strUpdatePassword = Null
End If

If Not Nl(strNUM) Then
	If Not IsNUMType(strNUM) Then
		bNUMError = True
		Call setSessionLanguage(strRestoreCulture)
		Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
		Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
		Call makePageFooter(True)
	End If
Else
	strNUM = Null
	bSuggest = True
End If

If Not user_bLoggedIn And (isVulgar(Request.QueryString) Or isVulgar(Request.Form)) Then
	bNUMError = True
	Call setSessionLanguage(strRestoreCulture)
	Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
	Call handleError(TXT_WARNING & TXT_WARNING_VULGAR, vbNullString, vbNullString)
	Call makePageFooter(True)
End If

If Not bNUMError Then

Dim indItem, _
	strErrorList

Dim strSourceName, _
	strSourceTitle, _
	strSourceOrg, _
	strSourcePhone, _
	strSourceEmail

strSourceName = Trim(CStr(Request("SOURCE_NAME")))
strSourceTitle = Trim(CStr(Request("SOURCE_TITLE")))
strSourceOrg = Trim(CStr(Request("SOURCE_ORG")))
strSourcePhone = Trim(CStr(Request("SOURCE_PHONE")))
strSourceEmail = Trim(CStr(Request("SOURCE_EMAIL")))

If Not user_bLoggedIn Then

Call checkEmail(TXT_YOUR & TXT_EMAIL, strSourceEmail)

If Nl(strSourceName) Or (Nl(strSourcePhone) And Nl(strSourceEmail)) Or Not Nl(strErrorList) Then
	bNUMError = True
%>
<%
Call setSessionLanguage(strRestoreCulture)
Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
Call setSessionLanguage(objUpdateLang.Culture)
%>
<h3 class="Alert"><%=TXT_ABOUT_YOU%></h3>
<p><%=TXT_INST_ABOUT_YOU%></p>
<%
If Not Nl(strErrorList) Then
%>
<ul><%=strErrorList%></ul>
<%
End If
%>
<form action="feedback2.asp" method="post">
<%
	For Each indItem In Request.QueryString()
		If (indItem <> "SOURCE_NAME") And (indItem <> "SOURCE_EMAIL") And (indItem <> "SOURCE_PHONE") Then
%>
<div style="display:none"><input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.QueryString(indItem))%>></div>
<%
		End If
	Next%>
<%
	For Each indItem In Request.Form()
		If (indItem <> "SOURCE_NAME") And (indItem <> "SOURCE_EMAIL") And (indItem <> "SOURCE_PHONE") Then
%>
<div style="display:none"><input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.Form(indItem))%>></div>
<%
		End If
	Next
%>
<table class="BasicBorder cell-padding-3 form-table responsive-table">
<%
	Call printRow("SOURCE_NAME",TXT_YOUR & TXT_NAME, makeTextFieldVal("SOURCE_NAME", strSourceName, 60, False), False,False,False,True,False,False, False)
	Call printRow("SOURCE_EMAIL",TXT_YOUR & TXT_EMAIL, makeTextFieldVal("SOURCE_EMAIL", strSourceEmail, 100, False), False,False,False,True,False,False, False)
	Call printRow("SOURCE_PHONE",TXT_YOUR & TXT_PHONE, makeTextFieldVal("SOURCE_PHONE", strSourcePhone, 60, False), False,False,False,True,False,False, False)
%>
</table>
<p><input type="submit" value="<%=TXT_SUBMIT%>" class="btn btn-default"></p>
</form>
<%
Call setSessionLanguage(strRestoreCulture)
Call makePageFooter(True)
%>
<%
End If

End If

End If

Dim bSecurityCheckOkay
bSecurityCheckOkay = False

If Not bNUMError Then

	Dim intSCheckDay, _
		intSCheckMonth, _
		intSCheckYear

	intSCheckDay = Trim(Request("sCheckDay"))
	intSCheckMonth = Trim(Request("sCheckMonth"))
	intSCheckYear = Trim(Request("sCheckYear"))

	On Error Resume Next
	If Not (Nl(intSCheckDay) Or Nl(intSCheckMonth) Or Nl(intSCheckYear)) Then
		If IsPosSmallInt(intSCheckDay) And IsPosSmallInt(intSCheckMonth) And IsPosSmallInt(intSCheckYear) Then
			If DateSerial(intSCheckYear,intSCheckMonth,intSCheckDay) = DateAdd("d",1,Date()) Then
				If Err.number = 0 Then
					bSecurityCheckOkay = True
				End If
			End If
		End If
	End If
	On Error GoTo 0

	If Not (user_bLoggedIn Or bSecurityCheckOkay) Then
		bNUMError = True
		Call setSessionLanguage(strRestoreCulture)
		Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
		Call setSessionLanguage(objUpdateLang.Culture)
%>
<h3 class="Alert"><%=TXT_SECURITY_CHECK%></h3>
<p><span class="AlertBubble"><%=TXT_INST_SECURITY_CHECK_FAIL%></span></p>
<p><%=TXT_INST_SECURITY_CHECK_2%></p>
<form action="feedback2.asp" method="post" class="form-horizontal">
<div style="display:none">
<%
		For Each indItem In Request.QueryString()
			If Not reEquals(indItem,"sCheck.+",False,False,True,False) Then
				%><input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.QueryString(indItem))%>><%
			End If
		Next
		For Each indItem In Request.Form()
			If Not reEquals(indItem,"sCheck.+",False,False,True,False) Then
				%><input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.Form(indItem))%>><%
			End If
		Next
%>
</div>
<p><%=TXT_ENTER_TOMORROWS_DATE%></p>
<div class="form-group">
	<label for="sCheckDay" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_DAY%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10">
		<input id="sCheckDay" name="sCheckDay" type="text" size="5" maxlength="8" class="form-control">
	</div>
</div>
<div class="form-group">
	<label for="sCheckMonth" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_MONTH%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10 col-md-11">
		<%Call printMonthList("sCheckMonth")%></label>
	</div>
</div>
<div class="form-group">
	<label for="sCheckYear" class="control-label col-xs-4 col-sm-2 col-md-1"><%=TXT_YEAR%></label>
	<div class="form-inline form-inline-always col-xs-8 col-sm-10 col-md-11">
		<input id="sCheckYear" name="sCheckYear" type="text" size="5" maxlength="8" class="form-control">
	</div>
</div>
<div class="form-group">
	<div class="col-sm-offset-2 col-xs-offset-4 col-sm-10 col-xs-8 col-md-offset-1 col-md-11">
		<input type="submit" value="<%=TXT_SUBMIT%>" class="btn btn-default">
	</div>
</div>
</form>
<%
		Call setSessionLanguage(strRestoreCulture)
		Call makePageFooter(True)
	End If
End If

If Not bNUMError Then
Dim intRTID
intRTID = Trim(Request("CUR_RT_ID"))
If Not Nl(intRTID) Then
	If Not IsIDType(intRTID) Then
		intRTID = -1
	End If
Else
	intRTID = Null
End If

Dim cmdFields, rsFields
Set cmdFields = Server.CreateObject("ADODB.Command")
With cmdFields
	.ActiveConnection = getCurrentCICBasicCnn()
	.CommandType = adCmdStoredProc
	.CommandText = "dbo.sp_CIC_View_FeedbackFields"
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	.Parameters.Append .CreateParameter("@RT_ID", adInteger, adParamInput, 4, intRTID)
	.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
	.Parameters.Append .CreateParameter("@LoggedIn", adBoolean, adParamInput, 1, IIf(user_bLoggedIn,SQL_TRUE,SQL_FALSE))
	.Parameters.Append .CreateParameter("@UPDATE_PASSWORD", adVarChar, adParamInput, 21, strUpdatePassword)
End With
Set rsFields = Server.CreateObject("ADODB.Recordset")
With rsFields
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFields
End With

If Not bSuggest Then
	Dim strSQL, strCon

	strSQL = "SELECT bt.RSN,bt.NUM,bt.FBKEY," & _
		"bt.RECORD_OWNER," & _
		"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & _
		"btd.SOURCE_NAME, btd.SOURCE_TITLE, btd.SOURCE_ORG, btd.SOURCE_PHONE, btd.SOURCE_EMAIL, bt.UPDATE_EMAIL, btd.E_MAIL," & _
		"dbo.fn_CIC_RecordInView(bt.NUM," & g_intViewTypeCIC & ",btd.LangID,0,GETDATE()) AS IN_VIEW," & _
		"bt.PRIVACY_PROFILE, bt.UPDATE_PASSWORD, bt.UPDATE_PASSWORD_REQUIRED"

	'Does this record have an Equivalent Record
	Dim indCulture, _
		objSysLang

	If g_bMultiLingual Then
		For Each indCulture In Application("Cultures")
			If indCulture <> g_objCurrentLang.Culture Then
				Set objSysLang = create_language_object()
				objSysLang.setSystemLanguage(indCulture)
				strSQL = strSQL & ",CAST(CASE WHEN EXISTS(SELECT * FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND LangID=" & objSysLang.LangID & ") " & _
					"THEN 1 ELSE 0 END AS bit) AS HAS_" & Replace(indCulture,"-","_")
			End If
		Next
	End If

	With rsFields
		While Not .EOF
			If Not Nl(.Fields("FieldSelect")) And _
				Not reEquals(.Fields("FieldName"), "(NUM)|(SOURCE_*)|(UPDATE_EMAIL)|(E_MAIL)",True,False,True,False) Then
				strSQL = strSQL & ", " & .Fields("FieldSelect")
			End If
			.MoveNext
		Wend
		If Not .RecordCount = 0 Then
			.MoveFirst
		End If
	End With

	strSQL = strSQL & vbCrLf & _
		"FROM GBL_BaseTable bt " & _
		"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbcrLf & _
		"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbcrLf & _
		"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
		"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=@@LANGID" & vbCrLf & _
		"WHERE bt.NUM=" & QsNl(strNUM)

	'Response.Write("<pre>" & strSQL & "</pre>")
	'Response.Flush()

	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandType = adCmdText
		.CommandText = strSQL
		.CommandTimeout = 0
		Set rsOrg = .Execute
	End With
	If rsOrg.EOF Then
		bNUMError = True
		Call setSessionLanguage(strRestoreCulture)
		Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
		Call makePageFooter(True)
	Else
		If Not bSuggest Then
			strNUM = rsOrg("NUM")

			bUpdatePasswordRequired = rsOrg("UPDATE_PASSWORD_REQUIRED")
			If (bUpdatePasswordRequired = False And Nl(rsOrg("PRIVACY_PROFILE"))) Or _
					(user_bLoggedIn And Not g_bRespectPrivacyProfile) Then
				bUpdatePasswordRequired = Null
			End If
			If Nl(bUpdatePasswordRequired) Then
				strUpdatePassword = Null
			Else
				If strUpdatePassword <> rsOrg("UPDATE_PASSWORD") Then
					Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
					Call handleError(TXT_FEEDBACK_PASSWORD_ERROR, vbNullString, vbNullString)
					Call makePageFooter(True)
					strUpdatePassword = Null
					bNUMError = True
				End If
			End If
		End If
	End If
End If

End If

If Not bNUMError Then

Dim dicPubFb, tmpPubItem, strTmpPubRelID
Set dicPubFb = Server.CreateObject("Scripting.Dictionary")

Dim dicExtraFb, tmpExtraItem
Set dicExtraFb = Server.CreateObject("Scripting.Dictionary")

Dim strFBKey

strInsertIntoFBE = "MemberID,LangID,SUBMIT_DATE,IPAddress,FEEDBACK_OWNER"
strInsertValueFBE = g_intMemberID & "," & g_objCurrentLang.LangID & _
		"," & QsN(DateString(Date(),False) & " " & Time()) & _
		"," & QsN(getRemoteIP()) & _
		"," & QsNl(StringIf(Not Nl(g_strAssignSuggestionsToCIC) And Nl(strNUM),g_strAssignSuggestionsToCIC))
If Not bSuggest Then
	strFBKey = Left(Trim(Request("Key")),6)
	If Not Nl(strFBKey) Then
		strInsertIntoFBE = strInsertIntoFBE & ",FBKEY"
		strInsertValueFBE = strInsertValueFBE & "," & QsNl(strFbKey)
	End If
	Call addInsertField("NUM",QsNl(strNUM),strInsertIntoFBE,strInsertValueFBE)
	Select Case Request("FType")
		Case "F"
			Call addInsertField("FULL_UPDATE",SQL_TRUE,strInsertIntoFBE,strInsertValueFBE)
		Case "N"
			Call addInsertField("FULL_UPDATE",SQL_TRUE,strInsertIntoFBE,strInsertValueFBE)
			Call addInsertField("NO_CHANGES",SQL_TRUE,strInsertIntoFBE,strInsertValueFBE)
		Case "D"
			Call addInsertField("REMOVE_RECORD",SQL_TRUE,strInsertIntoFBE,strInsertValueFBE)
	End Select
	Call getROInfo(rsOrg("RECORD_OWNER"),DM_CIC)
End If
If addInsertField("AUTH_TYPE",QsNl(Request("Auth")),strInsertIntoFBE,strInsertValueFBE) Then
	Select Case Request("Auth")
		Case "A"
			If user_bLoggedIn Then
				Dim bAuthInquiry, _
					bAuthOnline, _
					bAuthPrint
				
				bAuthInquiry = Request("AuthInquiry")="on"
				bAuthOnline = Request("AuthOnline")="on"
				bAuthPrint = Request("AuthPrint")="on"
			
				Call addInsertField("AUTH_INQUIRY",IIf(bAuthInquiry,SQL_TRUE,SQL_FALSE),strInsertIntoFBE,strInsertValueFBE)
				Call addInsertField("AUTH_ONLINE",IIf(bAuthOnline,SQL_TRUE,SQL_FALSE),strInsertIntoFBE,strInsertValueFBE)
				Call addInsertField("AUTH_PRINT",IIf(bAuthPrint,SQL_TRUE,SQL_FALSE),strInsertIntoFBE,strInsertValueFBE)
			
				strFieldVal = TXT_AUTH_GIVEN_FOR & _
					IIf(bAuthInquiry,TXT_USE_INQUIRY & "; ",vbNullString) & _
					IIf(bAuthOnline,TXT_USE_ONLINE & "; ",vbNullString) & _
					IIf(bAuthPrint,TXT_USE_PRINT & "; ",vbNullString) & _
					IIf(bAuthInquiry Or bAuthOnline Or bAuthPrint, vbNullString, TXT_NONE_SELECTED)
			Else
				strFieldVal = TXT_AUTH_GIVEN
			End If
		Case "C"
			strFieldVal = TXT_CONTACT_SUBMITTER
		Case "I"
			strFieldVal = TXT_INTERNAL_REVIEW
		Case "N"
	End Select
	Call addEmailField(TXT_AUTHORIZATION,strFieldVal)
End If

If user_bLoggedIn Then
	Call addInsertField("User_ID",user_intID,strInsertIntoFBE,strInsertValueFBE)
End If

Dim intCICVw
intCICVw = Request("UseCICVw")
If Not IsIDType(intCICVw) Then
	intCICVw = Null
End If
If Not Nl(intCICVw) Then
	Call addInsertField("ViewType",intCICVw,strInsertIntoFBE,strInsertValueFBE)
End If

Dim strAccessURL
strAccessURL = Request.ServerVariables("HTTP_HOST")

If strAccessURL <> g_strBaseURLCIC Then
	Call addInsertField("AccessURL",QsNNl(strAccessURL),strInsertIntoFBE,strInsertValueFBE)
End If

Dim strFbNotes
strFbNotes = Trim(CStr(Request("FB_NOTES")))
If Not Nl(strFBNotes) Then
	Call addInsertField("FB_NOTES",QsNNl(strFbNotes),strInsertIntoFBE,strInsertValueFBE)
End If
If user_bLoggedIn Then
	Call addInsertField("SOURCE_NAME",QsNNl(getStrSetValue("SOURCE_NAME")),strInsertIntoFBE,strInsertValueFBE)
	Call addInsertField("SOURCE_TITLE",QsNNl(getStrSetValue("SOURCE_TITLE")),strInsertIntoFBE,strInsertValueFBE)
	Call addInsertField("SOURCE_ORG",QsNNl(getStrSetValue("SOURCE_ORG")),strInsertIntoFBE,strInsertValueFBE)
	Call addInsertField("SOURCE_PHONE",QsNNl(getStrSetValue("SOURCE_PHONE")),strInsertIntoFBE,strInsertValueFBE)
	Call addInsertField("SOURCE_EMAIL",QsNNl(getStrSetValue("SOURCE_EMAIL")),strInsertIntoFBE,strInsertValueFBE)
Else
	Call addInsertField("SOURCE_NAME",QsNNl(strSourceName),strInsertIntoFBE,strInsertValueFBE)
	Call addInsertField("SOURCE_TITLE",QsNNl(strSourceTitle),strInsertIntoFBE,strInsertValueFBE)
	Call addInsertField("SOURCE_ORG",QsNNl(strSourceOrg),strInsertIntoFBE,strInsertValueFBE)
	Call addInsertField("SOURCE_PHONE",QsNNl(strSourcePhone),strInsertIntoFBE,strInsertValueFBE)
	Call addInsertField("SOURCE_EMAIL",QsNNl(strSourceEmail),strInsertIntoFBE,strInsertValueFBE)
End If

Dim strOldEmail, _
	strNewEmail

strNewEmail = vbNullString
If Not bSuggest Then
	strOldEmail = Nz(rsOrg("UPDATE_EMAIL"),rsOrg("E_MAIL"))
Else
	strOldEmail = vbNullString
End If

Dim strFieldName, _
	strFieldVal, _
	strFieldValDisplay, _
	strFieldDisplay

While Not rsFields.EOF
	strFieldVal = vbNullString
	strFieldValDisplay = vbNullString
	strFieldName = rsFields.Fields("FieldName")
	Select Case strFieldName
		Case "CC_LICENSE_INFO"
			Call getCCLicenseInfoFields(strInsertIntoCCFB,strInsertValueCCFB)
		Case "CONTACT_1"
			Call getContactFields(strFieldName, rsFields.Fields("FieldDisplay"),strInsertIntoFB,strInsertValueFB)
		Case "CONTACT_2"
			Call getContactFields(strFieldName, rsFields.Fields("FieldDisplay"),strInsertIntoFB,strInsertValueFB)
		Case "ELIGIBILITY"
			Call getEligibilityFields(rsFields.Fields("FieldDisplay"))
		Case "EMPLOYEES"
			Call getEmployeesFields(rsFields.Fields("FieldDisplay"))
		Case "EVENT_SCHEDULE"
			Call getEventScheduleFields(rsFields.Fields("FieldDisplay"))
		Case "EXEC_1"
			Call getContactFields(strFieldName, rsFields.Fields("FieldDisplay"),strInsertIntoFB,strInsertValueFB)
		Case "EXEC_2"
			Call getContactFields(strFieldName, rsFields.Fields("FieldDisplay"),strInsertIntoFB,strInsertValueFB)
		Case "EXTRA_CONTACT_A"
			Call getContactFields(strFieldName, rsFields.Fields("FieldDisplay"),strInsertIntoCFB,strInsertValueCFB)
		Case "GEOCODE"
			Call getGeoCodeFields(rsFields.Fields("FieldDisplay"))
		Case "LANGUAGES"
			Call getLanguagesFields(rsFields.Fields("FieldDisplay"))
		Case "LOGO_ADDRESS"
			Call getLogoAddressFields(rsFields.Fields("FieldDisplay"))
		Case "MAIL_ADDRESS"
			Call getMailAddressFields(rsFields.Fields("FieldDisplay"))
		Case "SITE_ADDRESS"
			Call getSiteAddressFields(rsFields.Fields("FieldDisplay"))
		Case "SOCIAL_MEDIA"
			Call getSocialMediaField(rsFields.Fields("FieldDisplay"),strInsertIntoFB,strInsertValueFB)
		Case "SPACE_AVAILABLE"
			Call getSpaceAvailableFields(rsFields.Fields("FieldDisplay"))
		Case "SUBJECTS"
			Call getSubjectFields(rsFields.Fields("FieldDisplay"))
		Case "VOLCONTACT"
			Call getContactFields(strFieldName, rsFields.Fields("FieldDisplay"),strInsertIntoFB,strInsertValueFB)
		Case Else
			strTmpPubRelID = rsFields.Fields("BT_PB_ID")
			If Not Nl(strTmpPubRelID) Then
				strFieldVal = getStrSetValue(strFieldName)
				If Not Nl(strFieldVal) Then
					If reEquals(strFieldName,".*_DESC",False,False,True,False) Then
						If dicPubFb.Exists(strTmpPubRelID) Then
							dicPubFb(strTmpPubRelID).strDescription = strFieldVal
							Call addEmailField(rsFields.Fields("FieldDisplay"),strFieldVal)
						Else
							Set tmpPubItem = New PubFbEntry
							tmpPubItem.intID = strTmpPubRelID
							tmpPubItem.strDescription = strFieldVal
							dicPubFb.Add strTmpPubRelID, tmpPubItem
							Call addEmailField(rsFields.Fields("FieldDisplay"),strFieldVal)
						End If
					ElseIf reEquals(strFieldName,".*_HEADINGS(_NP)?",False,False,True,False) Then
						If dicPubFb.Exists(strTmpPubRelID) Then
							dicPubFb(strTmpPubRelID).strHeadings = strFieldVal
							Call addEmailField(rsFields.Fields("FieldDisplay"),strFieldVal)
						Else
							Set tmpPubItem = New PubFbEntry
							tmpPubItem.intID = strTmpPubRelID
							tmpPubItem.strHeadings = strFieldVal
							dicPubFb.Add strTmpPubRelID, tmpPubItem
							Call addEmailField(rsFields.Fields("FieldDisplay"),strFieldVal)
						End If
					End If
				End If
			Else
				If rsFields.Fields("ExtraFieldType") = "l" Then
					strFieldVal = getBasicListSetValue(strFieldName,"#","#")
				ElseIf rsFields.Fields("ExtraFieldType") = "p" Then
					strFieldVal = getStrSetValue(strFieldName)
					strFieldValDisplay = getDropDownValue(strFieldVal,"dbo.fn_CIC_DisplayExtraDropDown",True,strFieldName)
				ElseIf rsFields.Fields("FormFieldType") = "c" Then
					strFieldVal = getCbSetValue(strFieldName, rsFields.Fields("CheckboxOnText"), rsFields.Fields("CheckboxOffText"))			
				ElseIf rsFields.Fields("FormFieldType") = "d" Then
					strFieldVal = getDateSetValue(strFieldName)
				Else
					strFieldVal = getStrSetValue(strFieldName)
				End If
				If reEquals(rsFields.Fields("ExtraFieldType"),"a|d|e|l|p|r|t|w",False,False,True,False) Then
					If Not Nl(strFieldVal) Then
						dicExtraFb.Add strFieldName, strFieldVal
						Call addEmailField(rsFields.Fields("FieldDisplay"),Nz(strFieldValDisplay,strFieldVal))
					End If									
				Else
					Select Case rsFields.Fields("FieldType")
						Case "GBL"
							If addInsertField(strFieldName, _
									QsNNl(strFieldVal), _
									strInsertIntoFB,strInsertValueFB) Then
								strFieldDisplay = rsFields.Fields("FieldDisplay")
								If strFieldName = "ORG_LEVEL_1" Or strFieldName = "ORG_LEVEL_2" Or strFieldName = "ORG_LEVEL_3" Then
									strFieldDisplay = Nz(get_view_data_cic("OrgLevel" & Right(strFieldName, 1) & "Name"), strFieldDisplay)
								End If
								Call addEmailField(strFieldDisplay,strFieldVal)
							End If
						Case "CIC"
							If addInsertField(strFieldName, _
									QsNNl(strFieldVal), _
									strInsertIntoCFB,strInsertValueCFB) Then
								Select Case strFieldName
									Case "ACCREDITED"
										strFieldValDisplay = getDropDownValue(strFieldVal,"dbo.fn_CIC_DisplayAccreditation",True,Null)
									Case "CERTIFIED"
										strFieldValDisplay = getDropDownValue(strFieldVal,"dbo.fn_CIC_DisplayCertification",True,Null)
									Case "EMPLOYEES_RANGE"
										Dim intERID
										intERID = strFieldVal
										If Not Nl(intERID) And IsIDType(intERID) Then
											Dim cmdEmployeeRange, rsEmployeeRange
											Set cmdEmployeeRange = Server.CreateObject("ADODB.Command")
											With cmdEmployeeRange
												.ActiveConnection = getCurrentCICBasicCnn()
												.CommandText = "dbo.sp_CIC_EmployeeRange_s"
												.CommandType = adCmdStoredProc
												.CommandTimeout = 0
												.Parameters.Append .CreateParameter("@ER_ID", adInteger, adParamInput, 4, intERID)
											End With
											Set rsEmployeeRange = Server.CreateObject("ADODB.Recordset")
											With rsEmployeeRange
												.CursorLocation = adUseClient
												.CursorType = adOpenStatic
												.Open cmdEmployeeRange
												If Not .EOF Then
													strFieldValDisplay = .Fields("Range")
												End If
												.Close
											End With
											Set rsEmployeeRange = Nothing
											Set cmdEmployeeRange = Nothing
										End If
									Case "FISCAL_YEAR_END"
										strFieldValDisplay = getDropDownValue(strFieldVal,"dbo.fn_CIC_DisplayFiscalYearEnd",True,Null)
									Case "QUALITY"
										strFieldValDisplay = getDropDownValue(strFieldVal,"dbo.fn_CIC_FullQuality",False,Null)
									Case "RECORD_TYPE"
										strFieldValDisplay = getDropDownValue(strFieldVal,"dbo.fn_CIC_FullRecordType",False,Null)			
									Case "WARD"
										strFieldValDisplay = getDropDownValue(strFieldVal,"dbo.fn_CIC_FullWard",False,Null)
									Case Else
										strFieldValDisplay = strFieldVal
								End Select
								Call addEmailField(rsFields.Fields("FieldDisplay"),strFieldValDisplay)
							End If
						Case "CCR"
							If addInsertField(strFieldName, _
									QsNNl(strFieldVal), _
									strInsertIntoCCFB,strInsertValueCCFB) Then
								Select Case strFieldName
									Case "TYPE_OF_PROGRAM"
										strFieldValDisplay = getDropDownValue(strFieldVal,"dbo.fn_CCR_DisplayTypeOfProgram",True,Null)
									Case Else
										strFieldValDisplay = strFieldVal
								End Select
								Call addEmailField(rsFields.Fields("FieldDisplay"),strFieldValDisplay)
							End If
					End Select
				End If
				If Not bSuggest Then
					If strFieldName = "UPDATE_EMAIL" Then
						If Not Nl(Trim(Request("UPDATE_EMAIL"))) Then
							strNewEmail = Trim(Request("UPDATE_EMAIL"))
							If strNewEmail = strOldEmail Then
								strNewEmail = vbNullString
							End If
						ElseIf Not Nl(rsOrg("UPDATE_EMAIL")) Then
							If Not Nl(Trim(Request("E_MAIL"))) Then
								strNewEmail = Trim(Request("E_MAIL"))
							Else
								strNewEmail = TXT_DELETED
							End If
						End If
					End If
					If strFieldName = "E_MAIL" And Nl(strNewEmail) And Nl(rsOrg("UPDATE_EMAIL")) Then
						If Not Nl(Trim(Request("E_MAIL"))) Then
							strNewEmail = Trim(Request("E_MAIL"))
							If strNewEmail = strOldEmail Then
								strNewEmail = vbNullString
							End If
						ElseIf Not Nl(rsOrg("E_MAIL")) Then
							strNewEmail = TXT_DELETED
						End If
					End If
				End If
			End If
	End Select
	rsFields.MoveNext
Wend

Dim aTmp, iTmp
aTmp = dicPubFb.Items
For Each iTmp In aTmp
	If Not Nl(iTmp.intID) Then
		strExtraSQL = strExtraSQL & vbCrLf & _
			"IF EXISTS(SELECT * FROM CIC_BT_PB pr WHERE pr.BT_PB_ID=" & iTmp.intID & ") BEGIN " & _
			"INSERT INTO CIC_Feedback_Publication" & " " & _
				"(FB_ID,BT_PB_ID,Description,GeneralHeadings) " & _
			"VALUES (@FB_ID," & _
				iTmp.intID & "," & _
				QsNl(iTmp.strDescription) & "," & _
				QsNl(iTmp.strHeadings) & _
			") END"
	End If
Next

aTmp = dicExtraFb.Keys
For Each iTmp In aTmp
	If Not Nl(iTmp) Then
		strExtraSQL = strExtraSQL & vbCrLf & _
			"IF EXISTS(SELECT * FROM GBL_FieldOption fo WHERE fo.ExtraFieldType IN ('a','d','e','l','p','r','t','w') AND fo.FieldName=" & QsNl(iTmp) & ") BEGIN " & _
			"INSERT INTO CIC_Feedback_Extra" & " " & _
				"(FB_ID,FieldName,[Value]) " & _
			"VALUES (@FB_ID," & _
				QsNl(iTmp) & "," & _
				QsNl(dicExtraFb(iTmp)) & _
			") END"
	End If
Next

strInsSQL = "INSERT INTO GBL_FeedbackEntry (" & strInsertIntoFBE & ") VALUES (" & strInsertValueFBE & ") DECLARE @FB_ID int SET @FB_ID=SCOPE_IDENTITY()"

strInsertIntoFB = "FB_ID" & strInsertIntoFB
strInsertValueFB = "@FB_ID" & strInsertValueFB
strInsSQL = strInsSQL & vbCrLf & "IF @@ERROR = 0 BEGIN INSERT INTO GBL_Feedback (" & strInsertIntoFB & ") VALUES (" & strInsertValueFB & ") END"

strInsertIntoCFB = "FB_ID" & strInsertIntoCFB
strInsertValueCFB = "@FB_ID" & strInsertValueCFB
strInsSQL = strInsSQL & vbCrLf & "IF @@ERROR = 0 BEGIN INSERT INTO CIC_Feedback (" & strInsertIntoCFB & ") VALUES (" & strInsertValueCFB & ") END"

strInsertIntoCCFB = "FB_ID" & strInsertIntoCCFB
strInsertValueCCFB = "@FB_ID" & strInsertValueCCFB
strInsSQL = strInsSQL & vbCrLf & "IF @@ERROR = 0 BEGIN INSERT INTO CCR_Feedback (" & strInsertIntoCCFB & ") VALUES (" & strInsertValueCCFB & ") END"

If Not Nl(strExtraSQL) Then
	strInsSQL = strInsSQL & vbCrLf & "IF @@ERROR = 0 BEGIN" & vbCrLf & strExtraSQL & vbCrLf & "END"
End If

'Response.Write("<pre>" & strInsSQL & "</pre>")
'Response.Flush()

Dim cmdInsertFb, bFbSQLError, strFbSQLError, strErrorDetails, objErr
Set cmdInsertFb = Server.CreateObject("ADODB.Command")
bFbSQLError = False
With cmdInsertFb
	.ActiveConnection = getCurrentCICBasicCnn()
	.CommandType = adCmdText
	.CommandText = strInsSQL
	On Error Resume Next
	.Execute
	If Err.Number <> 0 Or .ActiveConnection.Errors.Count > 0 Then
		bFbSQLError = True
		strFbSQLError = TXT_UNKNOWN_ERROR_OCCURED
		strInsSQLError = Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED)
		strErrorDetails =  Ns(user_strMod) & vbCrLf & Ns(user_strAgency) & vbCrLf & Ns(g_strMemberName) & _
							vbCrLf & g_intMemberID & vbCrLf & g_strApplicationInstance & vbCrLf & _
							Ns(Err.Number) & vbCrLf & Hex(IIf(Nl(Err.Number), 0, Err.Number)) & vbCrLf & _
							Ns(Err.Source) & vbCrLf &  Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED) & vbCrLf
		For Each objErr in .ActiveConnection.Errors
			strErrorDetails = strErrorDetails & "Description: " & Ns(objErr.Description) & vbCrLf & _
							"Help context: " & Ns(objErr.HelpContext) & vbCrLf & _
							"Help file: "  & Ns(objErr.HelpFile) & vbCrLf & _
							"Native error: " & Ns(objErr.NativeError) & vbCrLf & _
							"Error number: " & Ns(objErr.Number) & vbCrLf & _
							"Error source: " & Ns(objErr.Source) & vbCrLf & _
							"SQL state: " & Ns(objErr.SQLState) & vbCrLf
		Next

		Call sendEmail(True, CIOC_TASK_NOTIFY_EMAIL, CIOC_TASK_NOTIFY_EMAIL, "Entryform SQL Error", strErrorDetails & strInsSQL)
	End if
	On Error Goto 0
End With


If Err.Number = 0 And Not bFbSQLError Then
	If bSuggest Then
		Call setSessionLanguage(strRestoreCulture)
		Call makePageHeader(TXT_SUGGEST_NEW_RECORD, TXT_SUGGEST_NEW_RECORD, True, False, True, True)
	Else
		If Not g_bNoEmail Then
			Call sendNotifyEmails(rsOrg.Fields("NUM"), rsOrg.Fields("ORG_NAME_FULL"),strOldEmail,strNewEmail,rsOrg.Fields("IN_VIEW"), "https://" & strAccessURL,intCICVw,strFbKey,rsOrg.Fields("FBKEY"))
		End If
		If Not rsOrg.Fields("IN_VIEW") Then
			Call setSessionLanguage(strRestoreCulture)
			Call makePageHeader(TXT_THANKS_FOR_FEEDBACK, TXT_THANKS_FOR_FEEDBACK, True, False, True, True)
			bSuggest = True
		End If
	End If

	Dim strFeedbackMsg
	strFeedbackMsg = get_feedback_msg(g_objCurrentLang.Culture)
	If Nl(strFeedbackMsg) And strRestoreCulture <> g_objCurrentLang.Culture Then
		strFeedbackMsg = get_feedback_msg(strRestoreCulture)
	End If

	Dim strOtherLangList
	strOtherLangList = vbNullString

	If Not bSuggest And g_bMultiLingual Then
		For Each indCulture In Application("Cultures")
			If indCulture <> g_objCurrentLang.Culture Then
				Set objSysLang = create_language_object()
				objSysLang.setSystemLanguage(indCulture)
				If rsOrg("HAS_" & Replace(indCulture,"-","_")) Then
					strOtherLangList = strOtherLangList & "<li>" & _
					"<a href=""" & makeLink(StringIf(Not Nl(strRecordRoot), "../") & "feedback.asp","NUM=" & strNUM & "&UpdateLn=" & indCulture,vbNullString) & """>" & TXT_SUGGEST_UPDATE & " - <strong>" & objSysLang.LanguageName & "</strong></a>" & _
					"</li>"
				End If
			End If
		Next
	End If

	If Not bSuggest Then
		Call handleDetailsMessage(strFeedbackMsg & _
			StringIf(Not Nl(strOtherLangList),"<p class=""Alert"">" & TXT_EDIT_EQUIVALENT & "<ul>" & strOtherLangList & "</ul></p>"), _
			strNUM, _
			vbNullString, _
			False)
	Else
%>
<p class="Info"><%= strFeedbackMsg %></p>
<%
	End If


	If bSuggest Then
		Call makePageFooter(True)
	End If
Else
	Call makePageHeader(TXT_RECORD_FEEDBACK, TXT_RECORD_FEEDBACK, True, False, True, True)
	Call handleError(TXT_UNABLE_SAVE_FEEDBACK & strFbSQLError, vbNullString, vbNullString)
	Call makePageFooter(True)
End If

End If
%>

<!--#include file="includes/core/incClose.asp" -->
