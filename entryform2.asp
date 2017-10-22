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
Call setPageInfo(True, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtAgencyContact.asp" -->
<!--#include file="text/txtCommonForm.asp" -->
<!--#include file="text/txtEntryForm.asp" -->
<!--#include file="text/txtEntryForm2.asp" -->
<!--#include file="text/txtFeedbackCommon.asp" -->
<!--#include file="text/txtFormDataCheck.asp" -->
<!--#include file="text/txtGeoCode.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtNAICS.asp" -->
<!--#include file="text/txtRecordPages.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/core/incSendMail.asp" -->
<!--#include file="includes/naics/incCheckNAICS.asp" -->
<!--#include file="includes/update/incAgencyUpdateInfo.asp" -->
<!--#include file="includes/update/incEntryFormProcessGeneral.asp" -->
<!--#include file="includes/validation/incFormDataCheck.asp" -->
<script language="python" runat="server">
from cioc.core import vacancyscript
def make_vacancy_history_table(xml):
	return vacancyscript.make_history_table_from_xml_changes(pyrequest, xml)
</script>
<%
'On Error Resume Next

Dim strInsertIntoBT, strInsertValueBT, strUpdateListBT
Dim strInsertIntoBTD, strInsertValueBTD, strUpdateListBTD
Dim bInsertCBT, bUpdateCBT, strInsertIntoCBT, strInsertValueCBT, strUpdateListCBT
Dim bInsertCBTD, bUpdateCBTD, strInsertIntoCBTD, strInsertValueCBTD, strUpdateListCBTD
Dim bInsertCCBT, bUpdateCCBT, strInsertIntoCCBT, strInsertValueCCBT, strUpdateListCCBT
Dim bInsertCCBTD, bUpdateCCBTD, strInsertIntoCCBTD, strInsertValueCCBTD, strUpdateListCCBTD

Dim strInsSQL, strExtraSQL
Dim bProcessError

bInsertCBT = False
bUpdateCBT = False
bInsertCBTD = False
bUpdateCBTD = False
bInsertCCBT = Request("makeCCR") = "on"
bUpdateCCBT = False
bInsertCCBTD = False
bUpdateCCBTD = False

Sub getCCLicenseInfoFields()
	Dim strLCNumber, _
		dLCRenewal, _
		intLCTotal, _
		intLCInfant, _
		intLCToddler, _
		intLCPreschool, _
		intLCKindergarten, _
		intLCSchoolAge, _
		strLCNotes

	strLCNumber = Trim(Request("LICENSE_NUMBER"))
	dLCRenewal = Trim(Request("LICENSE_RENEWAL"))
	intLCTotal = Trim(Request("LC_TOTAL"))
	intLCInfant = Trim(Request("LC_INFANT"))
	intLCToddler = Trim(Request("LC_TODDLER"))
	intLCPreschool = Trim(Request("LC_PRESCHOOL"))
	intLCKindergarten = Trim(Request("LC_KINDERGARTEN"))
	intLCSchoolAge = Trim(Request("LC_SCHOOLAGE"))
	strLCNotes = Trim(Request("LC_NOTES"))
	Call checkLength(TXT_LICENSE_NUMBER,strLCNumber,50)
	Call checkDate(TXT_LICENSE_RENEWAL,dLCRenewal)
	Call checkInteger(TXT_CAPACITY & " - " & TXT_TOTAL,intLCTotal)
	Call checkInteger(TXT_CAPACITY & " - " & TXT_INFANT,intLCInfant)
	Call checkInteger(TXT_CAPACITY & " - " & TXT_TODDLER,intLCToddler)
	Call checkInteger(TXT_CAPACITY & " - " & TXT_PRESCHOOL,intLCPreschool)
	Call checkInteger(TXT_CAPACITY & " - " & TXT_KINDERGARTEN,intLCKindergarten)
	Call checkInteger(TXT_CAPACITY & " - " & TXT_SCHOOL_AGE,intLCSchoolAge)
	Call checkLength(TXT_CAPACITY & " - " & TXT_NOTES,strLCNotes,2000)
	If Nl(strErrorList) Then
		If addBTInsertField("LICENSE_NUMBER",strLCNumber,True,strUpdateListCCBT,strInsertIntoCCBT,strInsertValueCCBT) _
			Or addBTInsertField("LICENSE_RENEWAL",dLCRenewal,True,strUpdateListCCBT,strInsertIntoCCBT,strInsertValueCCBT) _
			Or addBTInsertField("LC_TOTAL",intLCTotal,False,strUpdateListCCBT,strInsertIntoCCBT,strInsertValueCCBT) _
			Or addBTInsertField("LC_INFANT",intLCInfant,False,strUpdateListCCBT,strInsertIntoCCBT,strInsertValueCCBT) _
			Or addBTInsertField("LC_TODDLER",intLCToddler,False,strUpdateListCCBT,strInsertIntoCCBT,strInsertValueCCBT) _
			Or addBTInsertField("LC_PRESCHOOL",intLCPreschool,False,strUpdateListCCBT,strInsertIntoCCBT,strInsertValueCCBT) _
			Or addBTInsertField("LC_KINDERGARTEN",intLCKindergarten,False,strUpdateListCCBT,strInsertIntoCCBT,strInsertValueCCBT) _
			Or addBTInsertField("LC_SCHOOLAGE",intLCSchoolAge,False,strUpdateListCCBT,strInsertIntoCCBT,strInsertValueCCBT) _
			Or addBTInsertField("LC_NOTES",strLCNotes,True,strUpdateListCCBTD,strInsertIntoCCBTD,strInsertValueCCBTD) Then
				Call addChangeField(fldName.Value, Null)
		End If
	End If
End Sub

Sub getEligibilityFields()
	Dim decMinAge, decMaxAge, strNotes

	decMinAge = Trim(Request("MIN_AGE"))
	decMaxAge = Trim(Request("MAX_AGE"))
	strNotes = Trim(Request("ELIGIBILITY_NOTES"))

	Call checkDouble(TXT_MIN_AGE,decMinAge)
	Call checkDouble(TXT_MAX_AGE,decMaxAge)
	Call checkLength(TXT_ELIGIBILITY_NOTES,strNotes,2000)

	If Nl(strErrorList) Then
		If addBTInsertField("MIN_AGE",decMinAge,False,strUpdateListCBT,strInsertIntoCBT,strInsertValueCBT) _
			Or addBTInsertField("MAX_AGE",decMaxAge,False,strUpdateListCBT,strInsertIntoCBT,strInsertValueCBT) _
			Or addBTInsertField("ELIGIBILITY_NOTES",strNotes,True,strUpdateListCBTD,strInsertIntoCBTD,strInsertValueCBTD) Then
				Call addChangeField(fldName.Value, Null)
		End If
	End If

End Sub

Sub getEmployeeFields()
	Dim intFT, intPT, intTotal

	intFT = Trim(Request("EMPLOYEES_FT"))
	intPT = Trim(Request("EMPLOYEES_PT"))
	intTotal = Trim(Request("EMPLOYEES_TOTAL"))

	Call checkInteger(TXT_EMPLOYEES & " - " & TXT_FULL_TIME,intFT)
	Call checkInteger(TXT_EMPLOYEES & " - " & TXT_PART_TIME,intPT)
	Call checkInteger(TXT_EMPLOYEES & " - " & TXT_TOTAL,intTotal)

	If Nl(strErrorList) Then
		If addBTInsertField("EMPLOYEES_FT",intFT,False,strUpdateListCBT,strInsertIntoCBT,strInsertValueCBT) _
			Or addBTInsertField("EMPLOYEES_PT",intPT,False,strUpdateListCBT,strInsertIntoCBT,strInsertValueCBT) _
			Or addBTInsertField("EMPLOYEES_TOTAL",intTotal,False,strUpdateListCBT,strInsertIntoCBT,strInsertValueCBT) Then
				Call addChangeField(fldName.Value, Null)
		End If
	End If

End Sub

Sub getGeoCodeFields()
	Dim intGeoCodeType, decLat, decLong, intMapPin, strNotes

	intMapPin = Trim(Request("MAP_PIN"))
	If Nl(intMapPin) Or Not IsNumeric(intMapPin) Then
		intMapPin = MAP_PIN_MIN
	Else
		intMapPin = CInt(intMapPin)
		If Not intMapPin >= MAP_PIN_MIN And intMapPin <= MAP_PIN_MAX Then
			intMapPin = MAP_PIN_MIN
		End If
	End If

	intGeoCodeType = Trim(Request("GEOCODE_TYPE"))
	If Nl(intGeoCodeType) Or Not IsNumeric(intGeoCodeType) Then
		intGeoCodeType = GC_BLANK
	Else
		intGeoCodeType = CInt(intGeoCodeType)
		If Not intGeoCodeType >= GC_BLANK And intGeoCodeType <= GC_MANUAL Then
			intGeoCodeType = GC_BLANK
		End If
	End If

	If intGeoCodeType = GC_BLANK Then
		decLat = Null
		decLong = Null
	Else
		decLat = Trim(Request("LATITUDE"))
		decLong = Trim(Request("LONGITUDE"))
		If g_objCurrentLang.LangID = LANG_FRENCH _
				Or g_objCurrentLang.LangID = LANG_GERMAN _
				Or g_objCurrentLang.LangID = LANG_POLISH Then
			decLat = Replace(decLat,".",",")
			decLong = Replace(decLong,".",",")
		End If
		If Nl(strErrorList) Then
			If Nl(decLat) Or Nl(decLong) Then
				strErrorList = strErrorList & "<li>" & TXT_INVALID_MISSING_LAT_LONG_DATA & "</li>"
			ElseIf Not (IsNumeric(decLat) And IsNumeric(decLong)) Then
				strErrorList = strErrorList & "<li>" & TXT_INVALID_MISSING_LAT_LONG_DATA & "</li>"
			Else
				decLat = CDbl(decLat)
				decLong = CDbl(decLong)
				If Not (decLat >= -180 And decLat =< 180 And decLong >= -180 And decLong =< 180) Then
					strErrorList = strErrorList & "<li>" & TXT_INVALID_MISSING_LAT_LONG_DATA & "</li>"
				End If
			End If
		End If
	End If

	strNotes = Trim(Request("GEOCODE_NOTES"))
	Call checkLength(TXT_GEOCODE & " (" & TXT_NOTES & ")",strNotes,255)

	If Nl(strErrorList) Then
		Call addBTInsertField("GEOCODE_TYPE",intGeoCodeType,False,strUpdateListBT,strInsertIntoBT,strInsertValueBT)
		Call addBTInsertField("MAP_PIN",intMapPin,False,strUpdateListBT,strInsertIntoBT,strInsertValueBT)
		Call addBTInsertField("LATITUDE",decLat,False,strUpdateListBT,strInsertIntoBT,strInsertValueBT)
		Call addBTInsertField("LONGITUDE",decLong,False,strUpdateListBT,strInsertIntoBT,strInsertValueBT)
		Call addBTInsertField("GEOCODE_NOTES",strNotes,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
	End If
End Sub

Sub getMailAddressFields()
	Dim strPostalCode, _
		aStreetType
	
	aStreetType = Split(Trim(Request("MAIL_STREET_TYPE")),"|")

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
			aStreetType(1) = Null
		End If
	Else
		ReDim Preserve aStreetType(1)
		aStreetType(1) = Null
	End If

	strPostalCode = UCase(Trim(Request("MAIL_POSTAL_CODE")))
	Call checkPostalCode(TXT_MAIL_ADDRESS & TXT_POSTAL_CODE,strPostalCode)
	If Nl(strErrorList) Then
		If addBTInsertField("MAIL_POSTAL_CODE",strPostalCode,True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) _
			Or addBTInsertField("MAIL_STREET_TYPE",aStreetType(0),True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) _
			Or addBTInsertField("MAIL_STREET_TYPE_AFTER",aStreetType(1),False,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) _
			Or processStrFldArray(Array("MAIL_CARE_OF", _
				"MAIL_PO_BOX", _
				"MAIL_BOX_TYPE", _
				"MAIL_BUILDING", _
				"MAIL_STREET_NUMBER", _
				"MAIL_STREET", _
				"MAIL_STREET_DIR", _
				"MAIL_SUFFIX", _
				"MAIL_CITY", _
				"MAIL_PROVINCE", _
				"MAIL_COUNTRY"), _
				strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) Then
			Call addChangeField(fldName.Value, Null)
		End If
	End If
End Sub

Sub getMainAddressFields()
	Dim strMainAddressType, _
		bSite, _
		bMail, _
		intAddrID
	
	strMainAddressType = Request("MAIN_ADDRESS_TYPE")
	intAddrID = Request("MAIN_ADDRESS_ADDRID")
	
	Select Case strMainAddressType
		Case "M"
			bMail = SQL_TRUE
			bSite = SQL_FALSE
			intAddrID = "NULL"
		Case "S"
			bMail = SQL_FALSE
			bSite = SQL_TRUE
			intAddrID = "NULL"
		Case Else
			bMail = SQL_FALSE
			bSite = SQL_FALSE
			If IsIDType(intAddrID) Then
				'intAddrID = "(SELECT ADDR_ID FROM CIC_BT_OTHERADDRESS WHERE NUM=@NUM AND LangID=@@LANGID AND ADDR_ID=" & intAddrID & ")"
			Else
				intAddrID = "NULL"
			End If
	End Select
	
	Call addBTInsertField("MAIN_ADDRESS_MAIL",bMail,False,strUpdateListCBT,strInsertIntoCBT,strInsertValueCBT)
	Call addBTInsertField("MAIN_ADDRESS_SITE",bSite,False,strUpdateListCBT,strInsertIntoCBT,strInsertValueCBT)
	strUpdateListCBT = strUpdateListCBT & ",MAIN_ADDRESS_ADDRID=" & intAddrID
End Sub

Sub getNUM()
	strNUM = UCase(Trim(Request("NUM")))
	If strNUM <> strOldNUM Or Nl(strNum) Or bNew Then
		If Nl(strNUM) And Not Request("AutoAssignNUM") = "on" Then
			strErrorList = strErrorList & "<li>" & TXT_RECORD_NUMBER_BLANK & "</li>"
		ElseIf Not Nl(strNUM) And Not reEquals(strNUM,"([A-Z]){3}([0-9]){4,5}",False,False,True,False) Then
			strErrorList = strErrorList & "<li>" & TXT_RECORD_NUMBER_INVALID & "</li>"
		Else
			Dim cmdCheckNUM, rsCheckNUM
			Set cmdCheckNUM = Server.CreateObject("ADODB.Command")
			With cmdCheckNUM
				.ActiveConnection = getCurrentAdminCnn()
				.CommandText = "dbo.sp_GBL_UCheck_NUM"
				.CommandType = adCmdStoredProc
				.CommandTimeout = 0
				.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
				.Parameters.Append .CreateParameter("@RSN", adInteger, adParamInput, 4, intRSN)
				.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInputOutput, 8, Nz(strNUM,Null))
				.Parameters.Append .CreateParameter("@EXTERNAL_ID", adVarChar, adParamInput, 50, Null)
				.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, Nz(Trim(Request("RECORD_OWNER")),user_strAgency))
			End With
			Set rsCheckNUM = cmdCheckNUM.Execute
			Set rsCheckNUM = rsCheckNUM.NextRecordset
			If cmdCheckNUM.Parameters("@RETURN_VALUE").Value <> 0 Then
				strErrorList = strErrorList & "<li>" & TXT_RECORD_NUMBER_USED & strNUM & ".</li>"	
			ElseIf Err.Number <> 0 Then
				strErrorList = strErrorList & "<li>" & TXT_RECORD_NUMBER_ERROR & "</li>"
			Else
				strNUM = cmdCheckNUM.Parameters("@NUM").Value
			End If
		End If
		If Nl(strErrorList) And Not bNew Then
			If addBTInsertField("NUM",strNUM,True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
				Call addChangeField("NUM", Null)
			End If
		End If
	End If
End Sub

Sub getRecordPrivacyFields()
	Dim intPrivacyProfile, _
		strUpdatePassword, _
		bUpdatePasswordRequired

	intPrivacyProfile = Trim(Request("PRIVACY_PROFILE"))
	strUpdatePassword = Trim(Request("UPDATE_PASSWORD"))
	bUpdatePasswordRequired = Trim(Request("UPDATE_PASSWORD_REQUIRED"))

	If Not IsNumeric(bUpdatePasswordRequired) Or Nl(strUpdatePassword) Then
		bUpdatePasswordRequired = Null
	Else
		bUpdatePasswordRequired = CInt(bUpdatePasswordRequired)
		If Not (bUpdatePasswordRequired = SQL_TRUE Or bUpdatePasswordRequired = SQL_FALSE) Then
			bUpdatePasswordRequired = Null
		End If
	End If

	Call checkLength(TXT_UPDATE_PASSWORD,strUpdatePassword,20)

	If Nl(strErrorList) Then
		Call addBTInsertField("PRIVACY_PROFILE", intPrivacyProfile, False, strUpdateListBT,strInsertIntoBT,strInsertValueBT)
		Call addBTInsertField("UPDATE_PASSWORD", strUpdatePassword, True, strUpdateListBT,strInsertIntoBT,strInsertValueBT)
		Call addBTInsertField("UPDATE_PASSWORD_REQUIRED", bUpdatePasswordRequired, False, strUpdateListBT,strInsertIntoBT,strInsertValueBT)
	End If
End Sub

Sub getSiteAddressFields()
	Dim strPostalCode, _
		aStreetType
	
	aStreetType = Split(Trim(Request("SITE_STREET_TYPE")),"|")

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
			aStreetType(1) = Null
		End If
	Else
		ReDim Preserve aStreetType(1)
		aStreetType(1) = Null
	End If

	strPostalCode = UCase(Trim(Request("SITE_POSTAL_CODE")))
	Call checkPostalCode(TXT_SITE_ADDRESS & " - " & TXT_POSTAL_CODE,strPostalCode)
	If Nl(strErrorList) Then
		If addBTInsertField("SITE_POSTAL_CODE",strPostalCode,True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) _
			Or addBTInsertField("SITE_STREET_TYPE",aStreetType(0),True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) _
			Or addBTInsertField("SITE_STREET_TYPE_AFTER",aStreetType(1),False,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) _
			Or processStrFldArray(Array("SITE_BUILDING", _
				"SITE_STREET_NUMBER", _
				"SITE_STREET", _
				"SITE_STREET_DIR", _
				"SITE_SUFFIX", _
				"SITE_CITY", _
				"SITE_PROVINCE", _
				"SITE_COUNTRY"), _
				strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) Then
			Call addChangeField(fldName.Value, Null)
		End If
	End If

End Sub

Sub getSourceFields()
	Dim strPostalCode, _
		strEmail

	strPostalCode = UCase(Trim(Request("SOURCE_POSTAL_CODE")))
	strEmail = Trim(Request("SOURCE_EMAIL"))

	Call checkPostalCode(TXT_SOURCE_POSTAL_CODE,strPostalCode)
	Call checkEmail(TXT_SOURCE_EMAIL,strEmail)

	If Nl(strErrorList) Then
		If addBTInsertField("SOURCE_POSTAL_CODE",strPostalCode,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) _
			Or addBTInsertField("SOURCE_EMAIL",strEmail,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) _
			Or processStrFldArray(Array("SOURCE_NAME", _
				"SOURCE_TITLE", _
				"SOURCE_ORG", _
				"SOURCE_PHONE", _
				"SOURCE_FAX", _
				"SOURCE_BUILDING", _
				"SOURCE_ADDRESS", _
				"SOURCE_CITY", _
				"SOURCE_PROVINCE"), _
				strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) Then
			Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
		End If
	End If
End Sub

Sub getSpaceAvailableFields()
	Dim bSpaceAvailable, _
		strNotes, _
		dSpaceAvailable

	bSpaceAvailable = Trim(Request("SPACE_AVAILABLE"))
	If Not IsNumeric(bSpaceAvailable) Then
		bSpaceAvailable = Null
	Else
		bSpaceAvailable = CInt(bSpaceAvailable)
		If Not (bSpaceAvailable = SQL_TRUE Or bSpaceAvailable = SQL_FALSE) Then
			bSpaceAvailable = Null
		End If
	End If
	dSpaceAvailable = Trim(Request("SPACE_AVAILABLE_DATE"))
	Call checkDate(TXT_SPACE_AVAILABLE & " (" & TXT_LAST_UPDATE & ")",dSpaceAvailable)
	dSpaceAvailable = DateString(dSpaceAvailable,True)

	strNotes = Trim(Request("SPACE_AVAILABLE_NOTES"))

	Call checkLength(TXT_SPACE_AVAILABLE & " (" & TXT_NOTES & ")",strNotes,255)

	If Nl(strErrorList) Then
		If addBTInsertField("SPACE_AVAILABLE", bSpaceAvailable, False, strUpdateListCCBT,strInsertIntoCCBT,strInsertValueCCBT) Or _
			addBTInsertField("SPACE_AVAILABLE_DATE", dSpaceAvailable, True, strUpdateListCCBT,strInsertIntoCCBT,strInsertValueCCBT) Or _
			addBTInsertField("SPACE_AVAILABLE_NOTES", strNotes, True, strUpdateListCCBTD,strInsertIntoCCBTD,strInsertValueCCBTD) Then
				Call addChangeField(fldName.Value, Null)
		End If
	End If
End Sub

Sub getActivityInfoEntrySQL(intBTACTID)
	Dim strPrefix
	strPrefix = "AI_" & intBTACTID & "_"
	
	Dim intActivityStatus, _
		strActivityName, _
		strActivityDescription, _
		strNotes

	intActivityStatus = Trim(Request(strPrefix & "ActivityStatus"))
	If Not IsIDType(intActivityStatus) Then
		intActivityStatus = Null
	End If

	strActivityName = Trim(Request(strPrefix & "ActivityName"))
	Call checkLength(TXT_ACTIVITY_INFO_NAME, strActivityName, 100)
	
	strActivityDescription = Trim(Request(strPrefix & "ActivityDescription"))
	Call checkLength(TXT_ACTIVITY_INFO_DESCRIPTION, strActivityDescription, 2000)
	
	strNotes = Trim(Request(strPrefix & "ActivityNotes"))
	Call checkLength(TXT_NOTES, strNotes, 2000)


	If Nl(strErrorList) Then
		'Delete entry, all fields empty
		If Nl(strActivityName) And Nl(strActivityDescription) And _
			Nl(strNotes) Then

			If IsIDType(intBTACTID) Then
				strExtraSQL = strExtraSQL & vbCrLf & _
					"EXEC sp_CIC_NUMActivity_d " & intBTACTID
			End If
		Else
			bInsertCBT = True
			Dim strUpdate, strBTACTIDParam
			If IsIDType(intBTACTID) Then
				strUpdate = "u"
				strBTACTIDParam = " " & intBTACTID & ", "
			Else
				strUpdate = "i"
				strBTACTIDParam = " @NUM, "
			End If
			
			strExtraSQL = strExtraSQL & vbCrLf & _
					"EXEC sp_CIC_NUMActivity_" & strUpdate & _
					strBTACTIDParam & _
					Nz(intActivityStatus, "NULL") & "," & _
					QsNl(strActivityName) & "," & _
					QsNl(strActivityDescription) & "," & _
					QsNl(strNotes)
		End If
	End If
End Sub

Sub getActivityInfoSQL()
	Dim strBTACTIDs, aBTACTIDs

	Call addChangeField(fldName.Value, Null)

	strBTACTIDs = Trim(Request("AI_IDS"))
	aBTACTIDs = Split(strBTACTIDs, ",")

	Dim indBTACTID, _
		intBTACTID

	For Each indBTACTID in aBTACTIDs
		intBTACTID = Trim(indBTACTID)
		Call getActivityInfoEntrySQL(intBTACTID)
	Next

	Dim strNotes
	strNotes = Trim(Request("ACTIVITY_NOTES"))
	Call checkLength(TXT_NOTES, strNotes, 2000)

	If Nl(strErrorList) Then
		Call addBTInsertField("ACTIVITY_NOTES",strNotes,True,strUpdateListCBTD,strInsertIntoCBTD,strInsertValueCBTD)
	End If
End Sub

Sub getAOFOSQL()
	Dim strTableName, strFieldName, strIDName
	strFieldName = fldName.Value
	strTableName = Replace(strFieldName, "_", vbNullString)
	If strFieldName = "ALT_ORG" Then
		strIDName = "BT_AO_ID"
	Else
		strIDName = "BT_FO_ID"
	End If

	Dim strIDList, aIDs, indID, strItemName, strItemDate, bPublish, i

	Call addChangeField(fldName.Value, g_objCurrentLang.LangID)

	strIDList = Trim(Request(strIDName))
		If Not (Nl(strIDList) Or IsIDList(strIDList)) Then
		strErrorList = strErrorList & "<li>" & TXT_INVALID_ID & fldDisplay.Value & " -> " & Server.HTMLEncode(strIDList) & "</li>"
	End If
	
	Dim strInserts, strUpdates, strDeletes, strXML
	strInserts = vbNullString
	strUpdates = vbNullString
	strDeletes = vbNullString

	strXML = vbNullString
	If Nl(strErrorList) Then
		If Not Nl(strIDList) Then
			aIDs = Split(strIDList,",")
			For Each indID In aIDs
				indID = Trim(indID)
				If Not Nl(indID) Then
					strItemName = Trim(Request(strFieldName & "_" & indID))
					Call checkLength(fldDisplay.Value,strItemName,255)
					If strFieldName = "FORMER_ORG" Then
						strItemDate = Trim(Request("FORMER_ORG_DATE_" & indID))
					End If
					bPublish = IIf(Request(strFieldName & "_PUBLISH_" & indID)="on",SQL_TRUE,SQL_FALSE)
					If Not Nl(strItemName) Then
						strXML = strXML & "<orgname name=" & XMLQs(strItemName) & " publish=" & XMLQs(bPublish) & StringIf(strFieldName="FORMER_ORG" And Not Nl(strItemDate), " date=" & XMLQs(strItemDate)) & " />"
					End If
				End If
			Next
		End If
	
		For i = 1 to 3
			strItemName = Trim(Request("NEW_" & strFieldName & "_" & i))
			Call checkLength(fldDisplay.Value,strItemName,255)
			If strFieldName = "FORMER_ORG" Then
				strItemDate = Trim(Request("NEW_FORMER_ORG_DATE_" & i))
			End If
			If Not Nl(strItemName) Then
				bPublish = IIf(Request("NEW_" & strFieldName & "_PUBLISH_" & i)="on",SQL_TRUE,SQL_FALSE)
				strXML = strXML & "<orgname name=" & XMLQs(strItemName) & " publish=" & XMLQs(bPublish) & StringIf(strFieldName="FORMER_ORG" And Not Nl(strItemDate), " date=" & XMLQs(strItemDate)) & " />"
			End If
		Next

		strExtraSQL = strExtraSQL & vbCrLf & "DECLARE @" & strFieldName & " xml ; SET @" & strFieldName & " = " & QsNl("<root>" & strXML & "</root>") & vbCrLf & _
		"DECLARE @" & strFieldName & "_Table TABLE (name nvarchar(255) COLLATE Latin1_General_100_CS_AS, publish bit" & StringIf(strFieldName = "FORMER_ORG", ", DATE_OF_CHANGE nvarchar(20)") & ", CNT int)" & vbCrLf & _
		"INSERT INTO @" & strFieldName & "_Table" & vbCrLf & _
		"SELECT N.value('@name', 'nvarchar(255)') AS name," & vbCrLf & _
		"		N.value('@publish', 'bit') AS publish," &  _
		StringIf(strFieldName = "FORMER_ORG", vbCrLf & "N.value('@date', 'nvarchar(20)') as DATE_OF_CHANGE,") & vbCrLf & _
		"		ROW_NUMBER() OVER (PARTITION BY N.value('@name', 'nvarchar(255)') COLLATE Latin1_General_100_CS_AS ORDER BY N.value('@publish', 'bit') DESC" & StringIf(strFieldName = "FORMER_ORG", ", N.value('@date', 'nvarchar(20)') DESC") & ") AS CNT" & vbCrLf & _
		"FROM @" & strFieldName & ".nodes('//orgname') AS T(N)" & vbCrLf & _
		"MERGE INTO GBL_BT_" & strTableName & " bt" & vbCrLf & _
		"USING (SELECT d.name, (SELECT TOP 1 publish FROM @" & strFieldName & "_Table WHERE name=d.name COLLATE Latin1_General_100_CS_AS ORDER BY CNT) AS publish" & vbCrLf & _ 
			StringIf(strFieldName = "FORMER_ORG", ", (SELECT TOP 1 DATE_OF_CHANGE FROM @" & strFieldName & "_Table WHERE name=d.name COLLATE Latin1_General_100_CS_AS ORDER BY CNT) AS DATE_OF_CHANGE") & vbCrLf & _
		"	FROM (SELECT DISTINCT name COLLATE Latin1_General_100_CS_AS AS name FROM @" & strFieldName & "_Table) AS d" & vbCrLf & _
		") AS src" & vbCrLf & _
		"	ON bt." & strFieldName & "=src.name COLLATE Latin1_General_100_CS_AS AND bt.NUM=@NUM AND bt.LangID=@@LANGID" & vbCrLf & _
		"WHEN MATCHED AND ((bt." & strFieldName & " + 'x') <> (src.name + 'x') COLLATE Latin1_General_100_CS_AS OR bt.publish <> src.publish" & _
				StringIf(strFieldName = "FORMER_ORG", " OR bt.DATE_OF_CHANGE <> src.DATE_OF_CHANGE COLLATE Latin1_General_100_CS_AS") & ") THEN " & vbCrLf & _
		"	UPDATE SET " & strFieldName & "=src.name, PUBLISH=src.publish" & StringIf(strFieldName = "FORMER_ORG", ", DATE_OF_CHANGE=src.DATE_OF_CHANGE") & vbCrLf & _
		"WHEN NOT MATCHED BY TARGET THEN" & vbCrLf & _
		"	INSERT (NUM, LangID, " & strFieldName & ", PUBLISH" & StringIf(strFieldName = "FORMER_ORG", ", DATE_OF_CHANGE") & ") VALUES" & vbCrLf & _
		"		(@NUM, @@LANGID, src.name, src.publish" & StringIf(strFieldName = "FORMER_ORG", ", src.DATE_OF_CHANGE") & ")" & vbCrLf & _
		"WHEN NOT MATCHED BY SOURCE AND bt.NUM=@NUM AND bt.LangID=@@LANGID THEN" & vbCrLf & _
		"	DELETE" & vbCrLf & _
		"	;" 
		'strExtraSQL = strExtraSQL & strDeletes & strUpdates & strInserts
	End If

End Sub

Sub getAltOrgSQL()
	Call getAOFOSQL()
End Sub

Sub getBillingAddressesSQL()
	Dim strIDList, _
		aIDs, _
		indID, _
		strFPrefix, _
		intLastOrder, _
		bEmpty
	
	Dim intAddrType, _
		strCode, _
		strLine1, _
		strLine2, _
		strLine3, _
		strLine4, _
		strCity, _
		strProvince, _
		strCountry, _
		strPostalCode, _
		intMapLink

	Call addChangeField(fldName.Value, g_objCurrentLang.LangID)

	intLastOrder = 0
	strIDList = Trim(Request("BA_IDS"))
	If Not Nl(strIDList) Then
		aIDs = Split(strIDList, ",")
		For Each indID In aIDs
			If Not Nl(indID) Then
				strFPrefix = "BA_" & indID & "_"
				bEmpty = False
			
				strCode = Left(Trim(Request(strFPrefix & "SITE_CODE")),100)
				strLine1 = Left(Trim(Request(strFPrefix & "LINE_1")),200)
				strLine2 = Left(Trim(Request(strFPrefix & "LINE_2")),200)
				strLine3 = Left(Trim(Request(strFPrefix & "LINE_3")),200)
				strLine4 = Left(Trim(Request(strFPrefix & "LINE_4")),200)
				strCity = Left(Trim(Request(strFPrefix & "CITY")),100)
				strProvince = Left(Trim(Request(strFPrefix & "PROVINCE")),2)
				strCountry = Left(Trim(Request(strFPrefix & "COUNTRY")),60)
				strPostalCode = Left(UCase(Trim(Request(strFPrefix & "POSTAL_CODE"))),20)
				intAddrType = Request(strFPrefix & "ADDR_TYPE")
				If Not IsIDType(intAddrType) Then
					intAddrType = Null
				End If
				Call checkPostalCode(StringIf(Not Nl(strCode),strCode & " - ") & TXT_POSTAL_CODE,strPostalCode)
							
				If Nl(strLine1) And Nl(strLine2) And Nl(strLine3) And Nl(strLine4) _
						And Nl(strCity) And Nl(strProvince) And Nl(strPostalCode) Then
					bEmpty = True
				End If

				If Not bEmpty Then
					intLastOrder = intLastOrder + 1
					strExtraSQL = strExtraSQL & vbCrLf & _
						"EXEC sp_GBL_NUMBillingAddress_u " & IIf(Not IsIDType(indID),"NULL",indID) & ",@NUM," & _
							Nz(intAddrType, "NULL") & "," & _
							QsNl(strCode) & "," & _
							intLastOrder & "," & _
							QsNl(strLine1) & "," & _
							QsNl(strLine2) & "," & _
							QsNl(strLine3) & "," & _
							QsNl(strLine4) & "," & _
							QsNl(strCity) & "," & _
							QsNl(strProvince) & "," & _
							QsNl(strCountry) & "," & _
							QsNl(strPostalCode)
				ElseIf IsIDType(indID) Then
					strExtraSQL = strExtraSQL & vbCrLf & _
						"DELETE GBL_BT_BILLINGADDRESS" & _
						" WHERE BADDR_ID=" & indID
				End If
			End If
		Next
	End If
End Sub

Sub getBusRoutesSQL()
	Dim strIDList

	Call addChangeField(fldName.Value, Null)

	strIDList = Trim(Request("BR_ID"))
	strIDList = reReplace(strIDList,"(\,\s*){2,}",",",False,True,True,False)
	strIDList = reReplace(strIDList,"\,+$",vbNullString,False,True,True,False)
	If strIDList = "," Then
		strIDList = vbNullString
	End If
	If Not (Nl(strIDList) Or IsIDList(strIDList)) Then
		strErrorList = strErrorList & "<li>" & TXT_INVALID_ID & fldDisplay.Value & " -> " & Server.HTMLEncode(strIDList) & "</li>"
	End If

	If Nl(strErrorList) Then
		If Not Nl(strIDList) Then
			bInsertCBT = True
		End If
		strExtraSQL = strExtraSQL & vbCrLf & "EXEC sp_CIC_NUMSetBRIDs_u @NUM," & Qs(strIDList,SQUOTE)
	End If
End Sub

Sub getFeeTypeSQL()
	Call getStdCheckListSQL("CIC", "FT", True, Null, Null, "FEE", strUpdateListCBTD, strInsertIntoCBTD, strInsertValueCBTD)

	If Nl(strErrorList) Then
		Call addBTInsertField("FEE_ASSISTANCE_FOR",Trim(Request("FEE_ASSISTANCE_FOR")),True,strUpdateListCBTD,strInsertIntoCBTD,strInsertValueCBTD)
		Call addBTInsertField("FEE_ASSISTANCE_FROM",Trim(Request("FEE_ASSISTANCE_FROM")),True,strUpdateListCBTD,strInsertIntoCBTD,strInsertValueCBTD)
		Call addBTInsertField("FEE_ASSISTANCE_AVAILABLE",IIf(Trim(Request("FEE_ASSISTANCE_AVAILABLE"))="on",SQL_TRUE,SQL_FALSE),False,strUpdateListCBT,strInsertIntoCBT,strInsertValueCBT)
	End If
End Sub

Sub getContractSignatureSQL()
	Dim strIDList, _
		aIDs, _
		indID, _
		strFPrefix, _
		bEmpty
	
	Dim strSignatory, _
		strNotes, _
		dDate, _
		intSigStatus

	Call addChangeField(fldName.Value, g_objCurrentLang.LangID)

	strIDList = Trim(Request("CS_IDS"))
	If Not Nl(strIDList) Then
		aIDs = Split(strIDList, ",")
		For Each indID In aIDs
			If Not Nl(indID) Then
				strFPrefix = "CS_" & indID & "_"
				bEmpty = False
			
				strSignatory = Left(Trim(Request(strFPrefix & "SIGNATORY")),255)
				strNotes = Left(Trim(Request(strFPrefix & "NOTES")),255)
				dDate = Left(Trim(Request(strFPrefix & "DATE")),25)
				Call checkDate(TXT_DATE_SIGNED, dDate)

				intSigStatus = Trim(Request(strFPrefix & "SIGSTATUS"))
				If Not IsIDType(intSigStatus) Then
					intSigStatus = Null
				End If
							
				If Nl(strSignatory) And Nl(strNotes) And Nl(dDate) Then
					bEmpty = True
				End If

				If Not bEmpty Then
					strExtraSQL = strExtraSQL & vbCrLf & _
						"EXEC sp_GBL_NUMContractSignature_u " & IIf(Not IsIDType(indID),"NULL",indID) & ",@NUM," & _
							Nz(intSigStatus, "NULL") & "," & _
							QsNl(strSignatory) & "," & _
							QsNl(dDate) & "," & _
							QsNl(strNotes) 
				ElseIf IsIDType(indID) Then
					strExtraSQL = strExtraSQL & vbCrLf & _
						"DELETE GBL_BT_CONTRACTSIGNATURE" & _
						" WHERE CTS_ID=" & indID
				End If
			End If
		Next
	End If
End Sub

Sub getExtraFieldSQL(strFldName,strNewValue,strExtraFieldType, strNewProtocol)
	Dim strOldValue, bNoChange, strTableName, bFieldLangID, strProtocol, bHasProtocol, strNewWebAddr

	strProtocol = vbNullString
	bHasProtocol = False
	If strExtraFieldType = "w" Then
		strNewWebAddr = strNewValue
		bHasProtocol = True
		strNewValue = strNewProtocol & strNewValue
	End If

	bNoChange = False

	If Nl(strErrorList) Then
		If Not bNew Then
			strOldValue = rsOrg.Fields(strFldName)
			If bHasProtocol And Not Nl(strOldValue) Then
				strProtocol = rsOrg.Fields(strFldName & "_PROTOCOL")
				If Nl(strProtocol) Then
					strProtocol = "http://"
				End If
				strOldValue = strProtocol & strOldValue
			End If
			If Not IsNull(strOldValue) Then
				strOldValue = CStr(strOldValue)
			End If
			If strNewValue <> strOldValue Or _
				(Nl(strOldValue) And Not Nl(strNewValue)) Or _
				(Nl(strNewValue) And Not Nl(strOldValue)) Then 
				If Not Nl(strOldValue) And Not Nl(strNewValue) Then
					If strExtraFieldType = "d" Then
						If DateString(strNewValue,True) = DateString(strOldValue,True) Then
							bNoChange = True
						End If
					ElseIf strExtraFieldType = "r" Then
						If strOldValue = "False" Then
							If IsNumeric(strNewValue) Then
								If CInt(strNewValue) = SQL_FALSE Then
									bNoChange = True
								End If
							End If
						ElseIf strOldValue = "True" Then
							If IsNumeric(strNewValue) Then
								If CInt(strNewValue) = SQL_TRUE Then
									bNoChange = True
								End If
							End If
						End If
					End If
				End If
			Else
				bNoChange = True
			End If
		End If
		
		If bNoChange Then
			strNewValue = Null
		ElseIf Nl(strNewValue) Then
			strNewValue = "NULL"
		ElseIf strExtraFieldType = "r" Then
			strNewValue = CInt(strNewValue)
		Else
			strNewValue = QsNl(strNewValue)
		End If
		
		If Not Nl(strNewValue) Then
			bFieldLangID = False
			Select Case strExtraFieldType
				Case "a"
					strTableName = "CIC_BT_EXTRA_DATE"
				Case "d"
					strTableName = "CIC_BT_EXTRA_DATE"
				Case "e"
					strTableName = "CIC_BT_EXTRA_EMAIL"
					bFieldLangID = True
				Case "r"
					strTableName = "CIC_BT_EXTRA_RADIO"
				Case "t"
					strTableName = "CIC_BT_EXTRA_TEXT"
					bFieldLangID = True
				Case "w"
					strTableName = "CIC_BT_EXTRA_WWW"
					bFieldLangID = True
					strNewValue = QsNl(strNewWebAddr)
					strNewProtocol = QsNl(strNewProtocol)
			End Select
			If strNewValue = "NULL" Then
				strExtraSQL = strExtraSQL & vbCrLf & _
					"DELETE FROM " & strTableName & " WHERE FieldName=" & QsNl(strFldName) & _
						" AND NUM=@NUM" & StringIf(bFieldLangID," AND LangID=@@LANGID")
			Else
				If strExtraFieldType = "a" Or strExtraFieldType = "d" Or strExtraFieldType = "r" Then
					bInsertCBT = True
				Else
					bInsertCBTD = True
				End If
				strExtraSQL = strExtraSQL & vbCrLf & _
					"IF EXISTS(SELECT * FROM " & strTableName & " WHERE FieldName=" & QsNl(strFldName) & _
						" AND NUM=@NUM" & StringIf(bFieldLangID," AND LangID=@@LANGID") & ") BEGIN" & vbCrLf & _
						" UPDATE " & strTableName & " SET [Value]=" & strNewValue & StringIf(bHasProtocol, ",[Protocol]=" & strNewProtocol) & " WHERE FieldName=" & QsNl(strFldName) & _
						" AND NUM=@NUM" & StringIf(bFieldLangID," AND LangID=@@LANGID") & vbCrLf & _
					"END ELSE BEGIN" & vbCrLf & _
						"INSERT INTO " & strTableName & "(FieldName,NUM," & StringIf(bFieldLangID,"LangID,") & StringIf(bHasProtocol, "[Protocol],") & "[Value])" & vbCrLf & _
						"VALUES (" & QsNl(strFldName) & ",@NUM," & StringIf(bFieldLangID,"@@LangID,") & StringIf(bHasProtocol, strNewProtocol & ",") & strNewValue & ")" & vbCrLf & _
					"END"
			End If
			Call addChangeField(strFldName, g_objCurrentLang.LangID)
		End If
	End If
End Sub

Sub getFormerOrgSQL()
	Call getAOFOSQL()
End Sub

Sub getGeneralHeadingSQL(intPBID, intPBRelID, strFldName, strVal)
	strExtraSQL = strExtraSQL & vbCrLf & vbCrLf & _
		"SET @PB_ID=" & intPBID & vbCrLf & _
		"SET @BT_PB_ID=NULL"

	If Not Nl(intPBRelID) Then
		strExtraSQL = strExtraSQL & vbCrLf & vbCrLf & _
			"SELECT @BT_PB_ID=BT_PB_ID FROM CIC_BT_PB WHERE BT_PB_ID=" & intPBRelID
	Else
		strExtraSQL = strExtraSQL & vbCrLf & vbCrLf & _
			"SELECT @BT_PB_ID=BT_PB_ID FROM CIC_BT_PB WHERE NUM=@NUM AND PB_ID=" & intPBID
	End If

	If IsIDList(strVal) Then
		If Nl(intPBRelID) Then
			strExtraSQL = strExtraSQL & vbCrLf & _
				"IF @BT_PB_ID IS NULL BEGIN" & vbCrLf & _
				"	INSERT INTO CIC_BT_PB (NUM, PB_ID, MODIFIED_DATE, MODIFIED_BY) VALUES (@NUM, @PB_ID, GETDATE()," & QsNl(user_strMod) & ")" & vbCrLf & _
				"	SET @BT_PB_ID = SCOPE_IDENTITY()" & vbCrLf & _
				"END"
		End If
		strExtraSQL = strExtraSQL & vbCrLf & _
			"IF @BT_PB_ID IS NOT NULL BEGIN" & vbCrLf & _
			"	MERGE INTO CIC_BT_PB_GH pr" & vbCrLf & _
			"	USING (SELECT GH_ID FROM CIC_GeneralHeading gh WHERE Used=1 AND GH_ID IN (" & strVal & ")) nt" & vbCrLf & _
			"		ON nt.GH_ID=pr.GH_ID AND pr.BT_PB_ID=@BT_PB_ID" & vbCrLf & _
			"	WHEN NOT MATCHED BY TARGET THEN" & vbCrLf & _
			"		INSERT (GH_ID, BT_PB_ID, NUM_Cache) VALUES (nt.GH_ID, @BT_PB_ID, @NUM)" & vbCrLf & _
			"	WHEN NOT MATCHED BY SOURCE AND pr.BT_PB_ID=@BT_PB_ID AND EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.GH_ID=pr.GH_ID AND gh.Used IS NOT NULL) THEN" & vbCrLf & _
			"		DELETE" & vbCrLf & _
			"	;" & vbCrLf & _
			"END"
	ElseIf Nl(strVal) And Not Nl(intPBRelID) Then
		strExtraSQL = strExtraSQL & vbCrLf & _
			"DELETE pr FROM CIC_BT_PB_GH pr WHERE pr.BT_PB_ID=@BT_PB_ID AND EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.GH_ID=pr.GH_ID AND gh.Used IS NOT NULL)"
	End If
 End Sub

Sub getLocatedIn()
	Dim strLocated, strOldLocated, intLocated, intOldLocated

	intOldLocated = vbNullString
	intLocated = Trim(Request("LOCATED_IN_CM_ID"))
	If IsNumeric(intLocated) Then
		intLocated = CInt(intLocated)
	Else
		intLocated = vbNullString
	End If
	strLocated = Trim(Request("LOCATED_IN_CM"))
	If Not bNew Then
		strOldLocated = Nz(rsOrg("LOCATED_IN_CM"), vbNullString)
		intOldLocated = Nz(rsOrg("LOCATED_IN_CM_ID"), vbNullString)
	End If
	If strLocated <> strOldLocated Or _
			intLocated <> intOldLocated Then
		Dim cmdCheckLocated, rsCheckLocated
		Set cmdCheckLocated = Server.CreateObject("ADODB.Command")
		With cmdCheckLocated
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_GBL_UCheck_LocatedIn"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
			.Parameters.Append .CreateParameter("@LocatedIn", adVarChar, adParamInput, 100, Nz(strLocated, Null))
			.Parameters.Append .CreateParameter("@CM_ID", adInteger, adParamInputOutput, 4, Nz(intLocated, Null))
		End With
		Set rsCheckLocated = cmdCheckLocated.Execute
		Set rsCheckLocated = rsCheckLocated.NextRecordset
		If cmdCheckLocated.Parameters("@RETURN_VALUE").Value <> 0 Then
			strErrorList = strErrorList & "<li>" & TXT_LOCATED_IN_VALUE & " &quot;" & strLocated & "&quot; " & TXT_NOT_VALID_COMMUNITY & "</li>"	
		ElseIf Err.Number <> 0 Then
			strErrorList = strErrorList & "<li>" & TXT_LOCATED_IN_ERROR & "</li>"
		Else
			intLocated = cmdCheckLocated.Parameters("@CM_ID").Value
		End If
		If Nl(strErrorList) Then
			If addBTInsertField("LOCATED_IN_CM",intLocated,False,strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
				Call addChangeField(fldName.Value, Null)
			End If
		End If
	End If
End Sub

Sub getLocationServices()
	Dim strIDList

	Call addChangeField(fldName.Value, Null)

	strIDList = Trim(Request(fldName.Value))
	If Not (Nl(strIDList) Or IsNUMList(strIDList)) Then
		strErrorList = strErrorList & "<li>" & TXT_INVALID_ID & fldDisplay.Value & " -> " & Server.HTMLEncode(strIDList) & "</li>"
	End If

	If Nl(strErrorList) Then
		strExtraSQL = strExtraSQL & vbCrLf & "EXEC sp_GBL_NUMSet" & fldName.Value & "_NUMs_u @NUM," & Qs(strIDList,SQUOTE)
	End If

End Sub

Sub getLogoAddress()
	Dim strLogoAddress, strLogoAddressLink, strLogoAddressProtocol, strLogoAddressLinkProtocol
	strLogoAddress = Trim(Request("LOGO_ADDRESS"))
	Call checkWebWithProtocol(TXT_LOGO_ADDRESS, strLogoAddress, strLogoAddressProtocol)
	Call checkLength(TXT_LOGO_ADDRESS, strLogoAddress, 200)

	strLogoAddressLink = Trim(Request("LOGO_ADDRESS_LINK"))
	Call checkWebWithProtocol(TXT_LOGO_ADDRESS, strLogoAddressLink, strLogoAddressLinkProtocol)
	Call checkLength(TXT_LOGO_ADDRESS, strLogoAddressLink, 200)

	If Nl(strErrorList) Then
		If addBTInsertField("LOGO_ADDRESS", strLogoAddress, True, strUpdateListCBTD,strInsertIntoCBTD,strInsertValueCBTD) _
			Or addBTInsertField("LOGO_ADDRESS_LINK", strLogoAddressLink, True, strUpdateListCBTD,strInsertIntoCBTD,strInsertValueCBTD) _
			Or addBTInsertField("LOGO_ADDRESS_PROTOCOL", strLogoAddressProtocol, True, strUpdateListCBTD,strInsertIntoCBTD,strInsertValueCBTD) _
			Or addBTInsertField("LOGO_ADDRESS_LINK_PROTOCOL", strLogoAddressLinkProtocol, True, strUpdateListCBTD,strInsertIntoCBTD,strInsertValueCBTD) Then
				Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
		End If
	End If
End Sub

Sub getNAICSSQL()
	Call addChangeField(fldName.Value, Null)

	If Not Nl(strNewNAICS) Then
		bInsertCBT = True
	End If
	strExtraSQL = strExtraSQL & vbCrLf & "EXEC sp_CIC_NUMSetNAICSCodes_u @NUM," & Qs(strNewNAICS,SQUOTE)
End Sub

Sub getOrgNameSQL(strName,strPublish)
	Dim strOrg, bPublish
	strOrg = Trim(Request(strName))
	bPublish = IIf(Request(strPublish)="on" And Not Nl(strOrg),SQL_TRUE,SQL_FALSE)

	If addBTInsertField(strName,strOrg,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) _
		Or addBTInsertField(strPublish,bPublish,False,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) Then
			Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
	End If
End Sub

Sub getLocationNameSQL(bUpdateLocationName)
	Dim strOrg, bDisplayName, bChanged
	strOrg = Trim(Request("LOCATION_NAME"))
	bDisplayName = IIf(Nl(Request("HIDE_LOCATION_NAME")),SQL_TRUE,SQL_FALSE)

	bChanged = False

	If bUpdateLocationName Then
		bChanged = addBTInsertField("LOCATION_NAME",strOrg,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
	End If
	bChanged = bChanged Or addBTInsertField("DISPLAY_LOCATION_NAME",bDisplayName,False,strUpdateListBT,strInsertIntoBT,strInsertValueBT)

	If bChanged Then
		Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
	End If
End Sub

Sub getLanguagesSQL()
	Call getStdCheckListSQL("CIC", "LN", True, Null, Null, "LANGUAGE", strUpdateListCBTD, strInsertIntoCBTD, strInsertValueCBTD)

	Dim strIDList, aIDs, indID, strLNDIDList, aLNDIDList, aFullIDList, i, strFullIDList
	If Not (Nl(strIDList) Or IsIDList(strIDList)) Then
		Exit Sub
	End If
	strIDList = Trim(Request("LN_ID"))
	aIDS = Split(strIDList, ",")
	ReDim aFullIDList(-1)
	int i = 0
	For Each indID in aIDs
		indID = Trim(indID)
		strLNDIDList = Trim(Request("LND_" & indID))
		If Not Nl(strLNDIDList) And IsIDList(strLNDIDList) Then
			ReDim Preserve aFullIDList(i)
			aLNDIDList = Split(Replace(strLNDIDList, " ", vbNullString), ",")
			aFullIDList(i) = indID & ";" & Join(aLNDIDList, "," & indID & ";")
			i = i + 1
		End If
	Next
	strFullIDList = Join(aFullIDList, ",")
	strExtraSQL = strExtraSQL & vbCrLf & "EXEC sp_CIC_NUMSetLNDIDs_u @NUM," & Qs(strFullIDList, SQUOTE)
End Sub

Sub getOrgNumSQL()
	Dim strOrgNum
	strOrgNum = Trim(Request("ORG_NUM"))
	If Not Nl(strOrgNum) And Not reEquals(strOrgNum,"([A-Z]){3}([0-9]){4,5}",False,False,True,False) Then
		strErrorList = strErrorList & "<li>" & TXT_PARENT_RECORD_NUMBER_INVALID & "</li>"
		Exit Sub
	ElseIf Not Nl(strOrgNUM) And strOrgNum = Nz(strNUM, strOldNUM) Then
		strOrgNUM = vbNullString
	End If
	If addBTInsertField("ORG_NUM",strOrgNum,True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) _
		Or addBTInsertField("DISPLAY_ORG_NAME",IIf(bDisplayOrg,SQL_TRUE,SQL_FALSE),False,strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
		Call addChangeField(strOrgNUMFieldName, vbNullString)
	End If
End Sub

Sub getOtherAddressesSQL()
	Dim strIDList, _
		aIDs, _
		indID, _
		strFPrefix, _
		bEmpty
	
	Dim strTitle, _
		strCode, _
		strCO, _
		strBoxType, _
		strPO, _
		strBuilding, _
		strNum, _
		strStreet, _
		aStreetType, _
		bTypeAfter, _
		strStreetDir, _
		strSuffix, _
		strCity, _
		strProvince, _
		strCountry, _
		strPostalCode, _
		intMapLink

	Call addChangeField(fldName.Value, g_objCurrentLang.LangID)

	strIDList = Trim(Request("OA_IDS"))
	If Not Nl(strIDList) Then
		aIDs = Split(strIDList, ",")
		For Each indID In aIDs
			If Not Nl(indID) Then
				strFPrefix = "OA_" & indID & "_"
				bEmpty = False
			
				strTitle = Left(Trim(Request(strFPrefix & "TITLE")),100)
				strCode = Left(Trim(Request(strFPrefix & "SITE_CODE")),100)
				strCO = Left(Trim(Request(strFPrefix & "CARE_OF")),100)
				strBoxType = Left(Trim(Request(strFPrefix & "BOX_TYPE")),20)
				strPO = Left(Trim(Request(strFPrefix & "PO_BOX")),20)
				strBuilding = Left(Trim(Request(strFPrefix & "BUILDING")),100)
				strNum = Left(Trim(Request(strFPrefix & "STREET_NUMBER")),30)
				strStreet = Left(Trim(Request(strFPrefix & "STREET")),200)
				strStreetDir = Trim(Request(strFPrefix & "STREET_DIR"))
				strSuffix = Left(Trim(Request(strFPrefix & "SUFFIX")),150)
				strCity = Left(Trim(Request(strFPrefix & "CITY")),100)
				strProvince = Left(Trim(Request(strFPrefix & "PROVINCE")),2)
				strCountry = Left(Trim(Request(strFPrefix & "COUNTRY")),60)
				strPostalCode = Left(UCase(Trim(Request(strFPrefix & "POSTAL_CODE"))),20)
				intMapLink = Request(strFPrefix & "MAP_LINK")
				If Not IsIDType(intMapLink) Then
					intMapLink = Null
				End If
				
				Call checkPostalCode(IIf(Not Nl(strTitle),strTitle & " - ",StringIf(Not Nl(strCode),strCode & " - ")) & TXT_POSTAL_CODE,strPostalCode)
							
				aStreetType = Split(Trim(Request(strFPrefix & "STREET_TYPE")),"|")
			
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
						aStreetType(1) = Null
					End If
				Else
					ReDim Preserve aStreetType(1)
					aStreetType(1) = Null
				End If
				
				If Nl(strCO) And Nl(strBoxType) And Nl(strPO) And Nl(strBuilding) _
						And Nl(strNum) And Nl(strStreet) And Nl(strSuffix) _
						And Nl(strCity) And Nl(strProvince) And Nl(strPostalCode) Then
					bEmpty = True
				End If

				If Not bEmpty Then
					strExtraSQL = strExtraSQL & vbCrLf & _
						"EXEC sp_CIC_NUMOtherAddress_u " & IIf(Not IsIDType(indID),"NULL",indID) & ",@NUM," & _
							QsNl(strTitle) & "," & _
							QsNl(strCode) & "," & _
							QsNl(strCO) & "," & _
							QsNl(strBoxType) & "," & _
							QsNl(strPO) & "," & _
							QsNl(strBuilding) & "," & _
							QsNl(strNum) & "," & _
							QsNl(strStreet) & "," & _
							QsNl(aStreetType(0)) & "," & _
							Nz(aStreetType(1),"NULL") & "," & _
							QsNl(strStreetDir) & "," & _
							QsNl(strSuffix) & "," & _
							QsNl(strCity) & "," & _
							QsNl(strProvince) & "," & _
							QsNl(strCountry) & "," & _
							QsNl(strPostalCode) & "," & _
							Nz(intMapLink,"NULL")
				ElseIf IsIDType(indID) Then
					strExtraSQL = strExtraSQL & vbCrLf & _
						"DELETE CIC_BT_OTHERADDRESS" & _
						" WHERE ADDR_ID=" & indID
				End If
			End If
		Next
	End If
End Sub

Sub getSortAsSQL()
	Dim strSortAs, bUseLetter
	strSortAs = Trim(Request("SORT_AS"))
	bUseLetter = Trim(Request("SORT_AS_USELETTER"))
	
	If Not IsNumeric(bUseLetter) Then
		bUseLetter = Null
	Else
		bUseLetter = CInt(bUseLetter)
		If Not (bUseLetter = SQL_TRUE Or bUseLetter = SQL_FALSE) Then
			bUseLetter = Null
		End If
	End If

	If addBTInsertField("SORT_AS",strSortAs,True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) _
		Or addBTInsertField("SORT_AS_USELETTER",bUseLetter,False,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) Then
			Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
	End If
End Sub

Sub getStdCheckListSQL(strDomain, strIDType, bCheckNotes, strFieldName, strIDListName, strNotesPrefix, ByRef strUpdateList, ByRef strInsertInto, ByRef strInsertValue)
	Dim strNotes, aIDS, indID, strItemNote
	Dim strIDList

	Call addChangeField(fldName.Value, Null)
	
	If Not Nl(strNotesPrefix) Then
		strNotes = Trim(Request(strNotesPrefix & "_NOTES"))
		Call checkLength(fldDisplay.Value & " - " & TXT_NOTES,strNotes,2000)	
		Call addBTInsertField(strNotesPrefix & "_NOTES",strNotes,True,strUpdateList,strInsertInto,strInsertValue)
	End If

	strIDList = Trim(Request(Nz(strIDListName,strIDType & "_ID")))
	If Not (Nl(strIDList) Or IsIDList(strIDList)) Then
		strErrorList = strErrorList & "<li>" & TXT_INVALID_ID & fldDisplay.Value & " -> " & Server.HTMLEncode(strIDList) & "</li>"
	End If
	
	If Nl(strErrorList) Then
		strExtraSQL = strExtraSQL & vbCrLf & _
			"EXEC sp_" & strDomain & "_NUMSet" & strIDType & "IDs_u " & StringIf(Not Nl(strFieldName),QsNNl(strFieldName) & ",") & "@NUM," & Qs(strIDList,SQUOTE)

		If Not Nl(strIDList) Then
			Select Case strDomain
				Case "CIC"
					bInsertCBT = True
				Case "CCR"
					bInsertCCBT = True
			End Select
			
			If bCheckNotes Then
				aIDs = Split(strIDList,",")
				For Each indID In aIDs
					indID = Trim(indID)
					If Not Nl(indID) Then
						strItemNote = Trim(Request(strIDType & "_NOTES_" & indID))
						Call checkLength(fldDisplay.Value & " - " & TXT_NOTES,strItemNote,255)
						strExtraSQL = strExtraSQL & vbCrLf & _
							"SET @BT_REL_ID=NULL" & vbCrLf & _
							"SELECT @BT_REL_ID=BT_" & strIDType & "_ID FROM " & strDomain & "_BT_" & strIDType & " WHERE NUM=@NUM AND " & strIDType & "_ID=" & indID
						If Nl(strItemNote) Then
							strExtraSQL = strExtraSQL & vbCrLf & _
								"DELETE FROM " & strDomain & "_BT_" & strIDType & "_Notes WHERE BT_" & strIDType & "_ID=@BT_REL_ID AND LangID=@@LANGID"
						Else
							strExtraSQL = strExtraSQL & vbCrLf & _
								"SET @CheckListNotes=" & QsNl(strItemNote) & vbCrLf & _
								"IF EXISTS(SELECT * FROM " & strDomain & "_BT_" & strIDType & "_Notes WHERE BT_" & strIDType & "_ID=@BT_REL_ID AND LangID=@@LANGID) BEGIN" & vbCrLf & _
								"	UPDATE " & strDomain & "_BT_" & strIDType & "_Notes SET Notes=@CheckListNotes" & vbCrLf & _
								"		WHERE BT_" & strIDType & "_ID=@BT_REL_ID AND LangID=@@LANGID AND Notes<>@CheckListNotes COLLATE Latin1_General_100_CS_AS" & vbCrLf & _
								"END ELSE IF @BT_REL_ID IS NOT NULL BEGIN" & vbCrLf & _
								"	INSERT INTO " & strDomain & "_BT_" & strIDType & "_Notes (BT_" & strIDType & "_ID,LangID,Notes)" & vbCrLF & _
								"	VALUES(@BT_REL_ID,@@LANGID,@CheckListNotes)" & vbCrLf & _
								"END"
						End If
					End If
				Next
			End If
		End If
	End If
End Sub


Sub getSchoolEscortSQL()
	Call addChangeField(fldName.Value, Null)

	Dim intID, strIDList, strFullIDList, aIDs, indID, strItemNote, strNotes
	strIDList = Trim(Request("ESCORT_SCH_ID"))
	strFullIDList = strIDList

	strNotes = Trim(Request("SCHOOL_ESCORT_NOTES"))
	Call checkLength(TXT_SCHOOL_ESCORT_NOTES,strNotes,2000)
	If Nl(strErrorList) Then
		Call addBTInsertField("SCHOOL_ESCORT_NOTES",strNotes,True,strUpdateListCCBTD,strInsertIntoCCBTD,strInsertValueCCBTD)
		strExtraSQL = strExtraSQL & vbCrLf & "EXEC sp_CCR_NUMSetSCHIDs_u @NUM," & Qs(strFullIDList,SQUOTE) & "," & SQL_TRUE & "," & SQL_FALSE
		If Not Nl(strFullIDList) Then
			bInsertCCBT = True
			aIDs = Split(strFullIDList,",")
			For Each indID In aIDs
				indID = Trim(indID)
				If Not Nl(indID) Then
					strItemNote = Trim(Request("ESCORT_SCH_NOTES_" & indID))
					strExtraSQL = strExtraSQL & vbCrLf & _
						"SET @BT_REL_ID=NULL" & vbCrLf & _
						"SELECT @BT_REL_ID=BT_SCH_ID FROM CCR_BT_SCH WHERE NUM=@NUM AND SCH_ID=" & indID
					If Nl(strItemNote) Then
						strExtraSQL = strExtraSQL & vbCrLf & _
							"IF EXISTS(SELECT * FROM CCR_BT_SCH_Notes WHERE BT_SCH_ID=@BT_REL_ID AND LangID=@@LANGID AND InAreaNotes IS NOT NULL) BEGIN" & vbCrLf & _
							"	UPDATE CCR_BT_SCH_Notes SET EscortNotes=NULL" & vbCrLf & _
							"		WHERE BT_SCH_ID=@BT_REL_ID AND LangID=@@LANGID AND EscortNotes IS NOT NULL" & vbCrLf & _
							"END ELSE BEGIN" & vbCrLf & _
							"	DELETE FROM CCR_BT_SCH_Notes WHERE BT_SCH_ID=@BT_REL_ID AND LangID=@@LANGID AND InAreaNotes IS NULL" & vbCrLf & _
							"END"
					Else
						strExtraSQL = strExtraSQL & vbCrLf & _
							"SET @CheckListNotes=" & QsNl(strItemNote) & vbCrLf & _
							"IF EXISTS(SELECT * FROM CCR_BT_SCH_Notes WHERE BT_SCH_ID=@BT_REL_ID AND LangID=@@LANGID) BEGIN" & vbCrLf & _
							"	UPDATE CCR_BT_SCH_Notes SET EscortNotes=@CheckListNotes" & vbCrLf & _
							"		WHERE BT_SCH_ID=@BT_REL_ID AND LangID=@@LANGID AND (EscortNotes<>@CheckListNotes COLLATE Latin1_General_100_CS_AS OR EscortNotes IS NULL)" & vbCrLf & _
							"END ELSE IF @BT_REL_ID IS NOT NULL BEGIN" & vbCrLf & _
							"	INSERT INTO CCR_BT_SCH_Notes (BT_SCH_ID,LangID,EscortNotes)" & vbCrLF & _
							"	VALUES (@BT_REL_ID,@@LANGID,@CheckListNotes)" & vbCrLf & _
							"END"
					End If
				End If
			Next
		End If
	End If
End Sub

Sub getSchoolsInAreaSQL()
	Call addChangeField(fldName.Value, Null)

	Dim intID, strIDList, strFullIDList, aIDs, indID, strItemNote, strNotes
	strIDList = Trim(Request("INAREA_SCH_ID"))
	strFullIDList = strIDList

	strNotes = Trim(Request("SCHOOLS_IN_AREA_NOTES"))
	Call checkLength(TXT_SCHOOLS_IN_AREA_NOTES,strNotes,2000)
	If Nl(strErrorList) Then
		Call addBTInsertField("SCHOOLS_IN_AREA_NOTES",strNotes,True,strUpdateListCCBTD,strInsertIntoCCBTD,strInsertValueCCBTD)
		strExtraSQL = strExtraSQL & vbCrLf & "EXEC sp_CCR_NUMSetSCHIDs_u @NUM," & Qs(strFullIDList,SQUOTE) & "," & SQL_FALSE & "," & SQL_TRUE
		If Not Nl(strFullIDList) Then
			bInsertCCBT = True
			aIDs = Split(strFullIDList,",")
			For Each indID In aIDs
				indID = Trim(indID)
				If Not Nl(indID) Then
					strItemNote = Trim(Request("INAREA_SCH_NOTES_" & indID))
					strExtraSQL = strExtraSQL & vbCrLf & _
						"SET @BT_REL_ID=NULL" & vbCrLf & _
						"SELECT @BT_REL_ID=BT_SCH_ID FROM CCR_BT_SCH WHERE NUM=@NUM AND SCH_ID=" & indID
					If Nl(strItemNote) Then
						strExtraSQL = strExtraSQL & vbCrLf & _
							"IF EXISTS(SELECT * FROM CCR_BT_SCH_Notes WHERE BT_SCH_ID=@BT_REL_ID AND LangID=@@LANGID AND EscortNotes IS NOT NULL) BEGIN" & vbCrLf & _
							"	UPDATE CCR_BT_SCH_Notes SET InAreaNotes=NULL" & vbCrLf & _
							"		WHERE BT_SCH_ID=@BT_REL_ID AND LangID=@@LANGID AND InAreaNotes IS NOT NULL" & vbCrLf & _
							"END ELSE BEGIN" & vbCrLf & _
							"	DELETE FROM CCR_BT_SCH_Notes WHERE BT_SCH_ID=@BT_REL_ID AND LangID=@@LANGID AND EscortNotes IS NULL" & vbCrLf & _
							"END"
					Else
						strExtraSQL = strExtraSQL & vbCrLf & _
							"SET @CheckListNotes=" & QsNl(strItemNote) & vbCrLf & _
							"IF EXISTS(SELECT * FROM CCR_BT_SCH_Notes WHERE BT_SCH_ID=@BT_REL_ID AND LangID=@@LANGID) BEGIN" & vbCrLf & _
							"	UPDATE CCR_BT_SCH_Notes SET InAreaNotes=@CheckListNotes" & vbCrLf & _
							"		WHERE BT_SCH_ID=@BT_REL_ID AND LangID=@@LANGID AND (InAreaNotes<>@CheckListNotes COLLATE Latin1_General_100_CS_AS OR InAreaNotes IS NULL)" & vbCrLf & _
							"END ELSE IF @BT_REL_ID IS NOT NULL BEGIN" & vbCrLf & _
							"	INSERT INTO CCR_BT_SCH_Notes (BT_SCH_ID,LangID,InAreaNotes)" & vbCrLF & _
							"	VALUES(@BT_REL_ID,@@LANGID,@CheckListNotes)" & vbCrLf & _
							"END"
					End If
				End If
			Next
		End If
	End If
End Sub

Sub getVacancyInfoEntrySQL(intBTVUTID)
	Dim strPrefix, bUpdate
	strPrefix = "VI_" & intBTVUTID & "_"

	bUpdate = IsIDType(intBTVUTID)

	Dim strServiceTitle, _
		intCapacity, _
		intFundedCapacity, _
		intVacancy, _
		intLastVacancyChange, _
		decHoursPerDay, _
		decDaysPerWeek, _
		decWeeksPerYear, _
		decFTE, _
		strVTPIDs, _
		intVUTID, _
		bWaitList, _
		strWaitListDate, _
		strNotes, _
		strVacancyModifiedDate

	intCapacity = Trim(Request(strPrefix & "VUT_Capacity"))
	Call checkInteger(TXT_VACANCY_INFO_CAPACITY, intCapacity)

	Dim bDelete
	bDelete = True
	If Not Nl(intCapacity) And Nl(strErrorList) Then
		If intCapacity <> 0 Then
			bDelete = False
		End If
	End If
	If Not bDelete Then
		strServiceTitle = Trim(Request(strPrefix & "ServiceTitle"))
		Call checkLength(TXT_VACANCY_INFO_SERVICE_TITLE, strServiceTitle, 100)
		
		strNotes = Trim(Request(strPrefix & "VacancyServiceNotes"))
		Call checkLength(TXT_VACANCY_INFO_NOTES, strNotes, 2000)

		intFundedCapacity = Trim(Request(strPrefix & "VUT_FundedCapacity"))
		Call checkInteger(TXT_VACANCY_INFO_FUNDED_CAPACITY_OF, intFundedCapacity)

		intVacancy = Trim(Request(strPrefix & "VUT_Vacancy"))
		Call checkInteger(TXT_VACANCY_INFO_VACANCY, intVacancy)

		intLastVacancyChange = Trim(Request(strPrefix & "VUT_LastVacancyChange"))
		Call checkInteger(TXT_VACANCY_INFO_VACANCY, intLastVacancyChange)
		
		decHoursPerDay = Trim(Request(strPrefix & "VUT_HoursPerDay"))
		Call checkDouble(TXT_VACANCY_INFO_HOURS_PER_DAY, decHoursPerDay)
		
		decDaysPerWeek = Trim(Request(strPrefix & "VUT_DaysPerWeek"))
		Call checkDouble(TXT_VACANCY_INFO_DAYS_PER_WEEK, decDaysPerWeek)
		
		decWeeksPerYear = Trim(Request(strPrefix & "VUT_WeeksPerYear"))
		Call checkDouble(TXT_VACANCY_INFO_WEEKS_PER_YEAR, decWeeksPerYear)
		
		decFTE = Trim(Request(strPrefix & "VUT_FTE"))
		Call checkDouble(TXT_VACANCY_INFO_FULL_TIME_EQUIVALENT, decFTE)

		bWaitList = Trim(Request(strPrefix & "WaitList"))
		If Not Nl(bWaitList) Then
			bWaitList = IIf(CInt(bWaitList)=SQL_TRUE, SQL_TRUE, SQL_FALSE)
		Else
			bWaitList = Null
		End If

		strWaitListDate = Trim(Request(strPrefix & "WaitListDate"))
		Call checkDate(TXT_VACANCY_INFO_WAIT_LIST_DATE, strWaitListDate)

		strVacancyModifiedDate = Trim(Request(strPrefix & "VacancyModifiedDate"))
		Call checkDate(TXT_VACANCY_INFO_MODIFIED_DATE, strVacancyModifiedDate)

		strVTPIDs = Trim(Request(strPrefix & "VTP_ID"))
	
		If Not bUpdate Then
			intVUTID = Trim(Request(strPrefix & "VUT_ID"))
			Call checkInteger(TXT_VACANCY_INFO_UNIT_TYPE, intVUTID)
			If Nl(intVUTID) Then
				Call checkAddValidationError(TXT_VACANCY_INFO_UNIT_TYPE_REQUIRED)
			End If
		End If
	End If

	If Nl(strErrorList) Then
		'Delete entry, capacity is 0 or Null
		If Not Nl(intCapacity) And Nl(strErrorList) Then
			If intCapacity = 0 Then
				intCapacity = Null
			End If
		End If
		If Nl(intCapacity) Then
			If bUpdate Then
				strExtraSQL = strExtraSQL & vbCrLf & _
					"EXEC sp_CIC_NUMVacancy_d " & intBTVUTID
			End If
		Else
			bInsertCBT = True
			Dim strUpdate, strBTVUTIDParam
			If bUpdate Then
				strUpdate = "u"
				strBTVUTIDParam = " " & intBTVUTID & ", "
			Else
				strUpdate = "i"
				strBTVUTIDParam = " @NUM, " & intVUTID & ", "
			End If
			
			strExtraSQL = strExtraSQL & vbCrLf & _
					"EXEC sp_CIC_NUMVacancy_" & strUpdate & _
					strBTVUTIDParam & _
					intCapacity & "," & _
					Nz(intFundedCapacity, "NULL") & "," & _
					Nz(intLastVacancyChange, "NULL") & "," & _
					Nz(intVacancy, "NULL") & "," & _
					Nz(decHoursPerDay, "NULL") & "," & _
					Nz(decDaysPerWeek, "NULL") & "," & _
					Nz(decWeeksPerYear, "NULL") & "," & _
					Nz(decFTE, "NULL") & "," & _
					Nz(bWaitList, "NULL") & "," & _
					QsNl(strWaitListDate) & "," & _
					QsNl(strServiceTitle) & "," & _
					QsNl(strNotes) & "," & _
					QsNl(strVacancyModifiedDate) & "," & _
					QsNl(user_strMod) & "," & _
					QsNl(strVTPIDs) & "," & _
					"@VacancyWarningTmp OUTPUT" & vbCrLf & _
					"IF @VacancyWarningTmp IS NOT NULL BEGIN" & vbCrLf & _
					"	SET @VacancyWarning = @VacancyWarning + @VacancyWarningTmp" & vbCrLf & _
					"END"
		End If
	End If
End Sub

Sub getVacancyInfoSQL()
	Call addChangeField(fldName.Value, g_objCurrentLang.LangID)

	Dim strBTVUTIDs, aBTVUTIDs
	strBTVUTIDs = Trim(Request("VI_IDS"))

	aBTVUTIDs = Split(strBTVUTIDs, ",")

	Dim indBTVUTID, _
		intBTVUTID

	For Each indBTVUTID in aBTVUTIDs
		intBTVUTID = Trim(indBTVUTID)
		Call getVacancyInfoEntrySQL(intBTVUTID)
	Next

	Dim strNotes
	strNotes = Trim(Request("VACANCY_NOTES"))
	Call checkLength(TXT_VACANCY_INFO_NOTES, strNotes, 2000)

	If Nl(strErrorList) Then
		Call addBTInsertField("VACANCY_NOTES",strNotes,True,strUpdateListCBTD,strInsertIntoCBTD,strInsertValueCBTD)
	End If
End Sub

Dim intRSN, _
	bRSError, _
	bRSNError, _
	strUpdateLang, _
	objUpdateLang, _
	strRestoreCulture, _
	bNew, _
	strReferer, _
	strErrorList, _
	strNUM, _
	strOldNUM, _
	bOrgNUMCheck, _
	bDisplayOrg, _
	bUpdateLocationName, _
	bNeedOrgNUM, _
	strOrgNUMFieldName

bRSError = False
bRSNError = False
bNew = False
bNeedOrgNUM = False
intRSN = Trim(Request("RSN"))
strUpdateLang = Nz(Request("UpdateLn"),g_objCurrentLang.Culture)
strOldNUM = Null
bOrgNUMCheck = False
bDisplayOrg = SQL_FALSE
bUpdateLocationName = True

strReferer = Request.ServerVariables("HTTP_REFERER")
If Not reEquals(strReferer,"entryform.asp",True,False,False,False) Then
	Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, True, True, True)
	Call handleError(TXT_UPDATE_REJECTED, vbNullString, vbNullString)
	Call makePageFooter(True)
	bRSNError = True
End If

If Nl(intRSN) Then
	intRSN = Null
	bNew = True
End If

If bNew Then
	If Not user_bAddDOM Then
		Call securityFailure()
	End If
Else
	If user_intUpdateDOM = UPDATE_NONE Then
		Call securityFailure()
	End If
End If

If Not bNew Then
	If Not IsIDType(intRSN) Then
		Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, True, True, True)
		Call handleError(TXT_INVALID_RSN & intRSN & ".", vbNullString, vbNullString)
		Call makePageFooter(True)
		bRSNError = True
	Else
		intRSN = CLng(intRSN)
	End If
End If

If Not IsCulture(strUpdateLang) Then
	bRSNError = True
	Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
	Call handleError(TXT_INVALID_LANGUAGE & strUpdateLang & ".", vbNullString, vbNullString)
	Call makePageFooter(True)
Else
	Set objUpdateLang = create_language_object()
	objUpdateLang.setSystemLanguage(strUpdateLang)
	strRestoreCulture = g_objCurrentLang.Culture
	Call setSessionLanguage(objUpdateLang.Culture)
End If

If Not bRSNError Then
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
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandText = "sp_CIC_View_UpdateFields"
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@RSN", adInteger, adParamInput, 4, intRSN)
	.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, Null)
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	.Parameters.Append .CreateParameter("@RT_ID", adInteger, adParamInput, 4, intRTID)
End With
Set rsFields = Server.CreateObject("ADODB.Recordset")
With rsFields
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFields
End With

If Err.Number <> 0 Then
	bRSError = True
	Call handleError(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
End If

Dim bMakeCCR, _
	bDeleteCCR, _
	bEnforceReqFields

With rsFields
	If .EOF Then
		bRSError = True
		Call handleError(TXT_ERROR & Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), vbNullString, vbNullString)
	Else
		bMakeCCR = .Fields("makeCCR")
		bDeleteCCR = .Fields("deleteCCR")
		bEnforceReqFields = .Fields("EnforceReqFields")
	End If
End With

Set rsFields = rsFields.NextRecordSet

strExtraSQL = "DECLARE @BT_REL_ID int," & vbCrLf & _
			"	@CheckListNotes varchar(255)," & vbCrLf & _
			"	@PB_ID int, @BT_PB_ID int," & vbCrLf & _
			"	@VacancyWarning nvarchar(max), @VacancyWarningTmp nvarchar(max); SET @VacancyWarning=N''"

If Not bNew Then
	Dim strSQL, _
		strCon, _
		indCulture, _
		objSysLang

	strSQL = "DECLARE @SiteID int" & vbCrLf & _
		"SELECT @SiteID = OLS_ID FROM GBL_OrgLocationService ols WHERE ols.Code='SITE'" & vbCrLf & _
		"SELECT @SiteID AS SITE_CODE_ID, CAST(CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS WHERE NUM=bt.NUM AND OLS_ID=@SiteID) THEN 1 ELSE 0 END AS bit) AS IS_SITE, " & _
		"bt.RSN, bt.NUM, bt.RECORD_OWNER, " & vbCrLf & _
		"dbo.fn_CIC_CanUpdateRecord(bt.NUM," & user_intID & "," & g_intViewTypeCIC & ",btd.LangID,GETDATE()) AS CAN_UPDATE," & vbCrLf & _
		"cioc_shared.dbo.fn_SHR_GBL_DateString(btd.UPDATE_DATE) AS UPDATE_DATE, btd.UPDATED_BY, " & vbCrLf & _
		"cioc_shared.dbo.fn_SHR_GBL_DateString(btd.UPDATE_SCHEDULE) AS UPDATE_SCHEDULE, btd.UPDATE_HISTORY," & vbCrLf & _
		"btd.ORG_LEVEL_1,bt.DISPLAY_ORG_NAME, bt.ORG_NUM"

	If g_bMultiLingual Then
		For Each indCulture In Application("Cultures")
			If indCulture <> g_objCurrentLang.Culture Then
				Set objSysLang = create_language_object()
				objSysLang.setSystemLanguage(indCulture)
				strSQL = strSQL & _
					",CAST(CASE WHEN EXISTS(SELECT * FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND LangID=" & objSysLang.LangID & ") " & "THEN 1 ELSE 0 END AS bit) AS HAS_" & Replace(indCulture,"-","_") & _
					",dbo.fn_CIC_CanUpdateRecord(bt.NUM," & user_intID & "," & g_intViewTypeCIC & "," & objSysLang.LangID & ",GETDATE()) AS CAN_UPDATE_" & Replace(indCulture,"-","_") & _
					",dbo.fn_CIC_RecordInView(bt.NUM," & g_intViewTypeCIC & "," & objSysLang.LangID & ",0,GETDATE()) AS CAN_SEE_" & Replace(indCulture,"-","_") & _
					",(SELECT cioc_shared.dbo.fn_SHR_GBL_DateString(btd.UPDATE_DATE) FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND LangID=" & objSysLang.LangID & ") AS UPDATE_DATE_" & Replace(indCulture,"-","_")
			End If
		Next
	End If

	With rsFields
		While Not .EOF
			If Not Nl(.Fields("FieldSelect")) And _
				Not reEquals(.Fields("FieldName"), _
						"((RSN)|(NUM)|(RECORD_OWNER)|(ORG_LEVEL_1)|(UPDATE(_DATE)|(_SCHEDULE)|(D_BY)|(HISTORY)))", _
						True,False,True,False) Then
				strSQL = strSQL & ", " & .Fields("FieldSelect")
				If .Fields("FieldName") = "ORG_NUM" Then
					bOrgNumCheck = True
				End If
			End If
			.MoveNext
		Wend
		If Not .RecordCount = 0 Then
			.MoveFirst
		End If
	End With

	strSQL = strSQL & " FROM GBL_BaseTable bt" & vbCrLf & _
		"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf & _
		"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
		"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=@@LANGID" & vbCrLf & _
		"WHERE bt.RSN=" & intRSN

	'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
	'Response.Flush()

	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandText = strSQL
		.CommandTimeout = 0
		Set rsOrg = .Execute
	End With
	If rsOrg.EOF Then
		Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
		Call handleError(TXT_NO_RECORD_EXISTS_RSN & intRSN & ".", vbNullString, vbNullString)
		Call makePageFooter(True)
		bRSNError = True
	ElseIf Not rsOrg("CAN_UPDATE") = 1 Then
		Call securityFailure()
	Else
		strOldNUM = rsOrg.Fields("NUM")
		bDisplayOrg = rsOrg.Fields("DISPLAY_ORG_NAME")
	End If
End If

End If

If Not bRSNError Then

	Dim dUpdateDate, dUpdateSchedule
	Dim strUserInsert
	Dim strBasicInsertInto, strBasicInsertValues, strBasicUpdateList

	strUserInsert = QsNl(user_strMod)

	strBasicInsertInto = "NUM,MODIFIED_DATE,MODIFIED_BY,CREATED_DATE,CREATED_BY"
	strBasicInsertValues = "@NUM" & ",GETDATE()," & strUserInsert & ",GETDATE()," & strUserInsert
	strBasicUpdateList = "MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & strUserInsert

	If bNew Then
		strInsertIntoBT = "MemberID," & strBasicInsertInto
		strInsertValueBT = g_intMemberID & "," & strBasicInsertValues
		strInsertIntoBTD = strBasicInsertInto
		strInsertValueBTD = strBasicInsertValues
		strInsertIntoCBT = strBasicInsertInto
		strInsertValueCBT = strBasicInsertValues
		strInsertIntoCBTD = strBasicInsertInto
		strInsertValueCBTD = strBasicInsertValues
		strInsertIntoCCBT = strBasicInsertInto
		strInsertValueCCBT = strBasicInsertValues
		strInsertIntoCCBTD = strBasicInsertInto
		strInsertValueCCBTD = strBasicInsertValues
	Else
		strUpdateListBT = strBasicUpdateList
		strUpdateListBTD = strBasicUpdateList
		strUpdateListCBT = strBasicUpdateList
		strUpdateListCBTD = strBasicUpdateList
		strUpdateListCCBT = strBasicUpdateList
		strUpdateListCCBTD = strBasicUpdateList
	End If

	If user_bFullUpdateDOM Then
		dUpdateDate = Trim(Request("UPDATE_DATE"))
		dUpdateSchedule = Trim(Request("UPDATE_SCHEDULE"))
	
		Call checkDate(TXT_UPDATE_DATE,dUpdateDate)
		Call checkDate(TXT_UPDATE_SCHEDULE,dUpdateSchedule)
		If Not bNew Then
			Call processUpdateHistory(rsOrg("UPDATE_HISTORY"),dUpdateDate,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
		End If
		Call addBTInsertField("UPDATE_DATE",DateString(dUpdateDate,False),True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
		Call addBTInsertField("UPDATED_BY",Trim(Request("UPDATED_BY")),True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
		Call addBTInsertField("UPDATE_SCHEDULE",DateString(dUpdateSchedule,False),True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
	End If

	If bNew Then
		Call getNUM()
		If addBTInsertField("RECORD_OWNER",Trim(Request("RECORD_OWNER")),True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
			Call addChangeField("RECORD_OWNER", Null)
		End If
	End If

	If bOrgNUMCheck Then
		bDisplayOrg = Request("DISPLAY_ORG_NAME") = "on" And Not Nl(Request("ORG_NUM"))
	End If

	If Not bNew Then
		If Nl(Request("OLS_ID")) And Not rsOrg.Fields("IS_SITE") Then
			bUpdateLocationName = False
		ElseIf Nz(InStr(Request("OLS_ID"),rsOrg.Fields("SITE_CODE_ID")),0) < 1 Then
			bUpdateLocationName = False
		End If
	End If

	Dim fldName, fldDisplay, strFieldVal
	Set fldName = rsFields.Fields("FieldName")
	Set fldDisplay = rsFields.Fields("FieldDisplay")
	
	While Not rsFields.EOF
		Select Case fldName.Value
			Case "ACCESSIBILITY"
				Call getStdCheckListSQL("GBL", "AC", True, Null, Null, fldName.Value, strUpdateListBTD, strInsertIntoBTD, strInsertValueBTD)
			Case "ACTIVITY_INFO"
				Call getActivityInfoSQL()
			Case "ALT_ORG"
				Call getAltOrgSQL()
			Case "AREAS_SERVED"
				Call getStdCheckListSQL("CIC", "CM", True, Null, Null, fldName.Value, strUpdateListCBTD, strInsertIntoCBTD, strInsertValueCBTD)
			Case "BILLING_ADDRESSES"
				Call getBillingAddressesSQL()
			Case "BUS_ROUTES"
				Call getBusRoutesSQL()
			Case "CC_LICENSE_INFO"
				Call getCCLicenseInfoFields()
			Case "CONTACT_1"
				Call getContactFields(fldName.Value)
			Case "CONTACT_2"
				Call getContactFields(fldName.Value)
			Case "CONTRACT_SIGNATURE"
				Call getContractSignatureSQL()
			Case "DISTRIBUTION"
				Call getStdCheckListSQL("CIC", "DST", False, Null, Null, Null, Null, Null, Null)
			Case "ELIGIBILITY"
				Call getEligibilityFields()
			Case "EMPLOYEES"
				Call getEmployeeFields()
			Case "EXEC_1"
				Call getContactFields(fldName.Value)
			Case "EXEC_2"
				Call getContactFields(fldName.Value)
			Case "EXTRA_CONTACT_A"
				Call getContactFields(fldName.Value)
			Case "FEES"
				Call getFeeTypeSQL()
			Case "FORMER_ORG"
				Call getFormerOrgSQL()
			Case "FUNDING"
				Call getStdCheckListSQL("CIC", "FD", True, Null, Null, fldName.Value, strUpdateListCBTD, strInsertIntoCBTD, strInsertValueCBTD)
			Case "GEOCODE"
				Call getGeoCodeFields()
			Case "INTERNAL_MEMO"
				Call getRecordNoteFields(fldName.Value)
			Case "LANGUAGES"
				Call getLanguagesSQL()
			Case "LEGAL_ORG"
				Call getOrgNameSQL(fldName.Value,"LO_PUBLISH")
			Case "LOCATED_IN_CM"
				Call getLocatedIn()
			Case "LOCATION_NAME"
				Call getLocationNameSQL(bUpdateLocationName)
			Case "LOCATION_SERVICES"
				Call getLocationServices()
			Case "LOGO_ADDRESS"
				Call getLogoAddress()
			Case "MAIL_ADDRESS"
				Call getMailAddressFields()
			Case "MAIN_ADDRESS"
				Call getMainAddressFields()
			Case "MAP_LINK"
				Call getStdCheckListSQL("GBL", "MAP", False, Null, Null, Null, Null, Null, Null)
			Case "MEMBERSHIP"
				Call getStdCheckListSQL("CIC", "MT", False, Null, Null, fldName.Value, strUpdateListCBTD, strInsertIntoCBTD, strInsertValueCBTD)
			Case "NAICS"
				Call checkNAICS()
				If Nl(strErrorList) Then
					Call getNAICSSQL()
				End If
			Case "NON_PUBLIC"
				Call addBTInsertField(fldName.Value,Nz(Request("NON_PUBLIC"),SQL_FALSE),False,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
			Case "NUM"
				If Not bNew Then
					Call getNUM()
				End If
			Case "ORG_LEVEL_1"
				If Not bDisplayOrg Then
					Call addBTInsertField(fldName.Value,Trim(Request("ORG_LEVEL_1")),True,strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
				End If
			Case "ORG_LEVEL_2"
				If Not bDisplayOrg Then
					Call getOrgNameSQL(fldName.Value,"O2_PUBLISH")
				End If
			Case "ORG_LEVEL_3"
				If Not bDisplayOrg Then
					Call getOrgNameSQL(fldName.Value,"O3_PUBLISH")
				End If
			Case "ORG_LEVEL_4"
				If Not bDisplayOrg Then
					Call getOrgNameSQL(fldName.Value,"O4_PUBLISH")
				End If
			Case "ORG_LEVEL_5"
				If Not bDisplayOrg Then
					Call getOrgNameSQL(fldName.Value,"O5_PUBLISH")
				End If
			Case "ORG_LOCATION_SERVICE"
				Call getStdCheckListSQL("GBL", "OLS", False, Null, Null, Null, Null, Null, Null)
			Case "ORG_NUM"
				'Delay to last because we need to be sure NUM is processed first
				bNeedOrgNUM = True
				strOrgNUMFieldName = fldName.Value
			Case "OTHER_ADDRESSES"
				Call getOtherAddressesSQL()
			Case "RECORD_OWNER"
				If Not bNew Then
					If addBTInsertField("RECORD_OWNER",Trim(Request("RECORD_OWNER")),True,strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
						Call addChangeField(fldName.Value, Null)
					End If
				End If
			Case "RECORD_PRIVACY"
				Call getRecordPrivacyFields()
			Case "SCHEDULE"
				Call getScheduleSQL()
			Case "SCHOOL_ESCORT"
				Call getSchoolEscortSQL()
			Case "SCHOOLS_IN_AREA"
				Call getSchoolsInAreaSQL()
			Case "SITE_ADDRESS"
				Call getSiteAddressFields()
			Case "SERVICE_LEVEL"
				Call getStdCheckListSQL("CIC", "SL", False, Null, Null, Null, Null, Null, Null)
			Case "SERVICE_LOCATIONS"
				Call getLocationServices()
			Case "SERVICE_NAME_LEVEL_1"
				Call getOrgNameSQL(fldName.Value,"S1_PUBLISH")
			Case "SERVICE_NAME_LEVEL_2"
				Call getOrgNameSQL(fldName.Value,"S2_PUBLISH")
			Case "SOCIAL_MEDIA"
				Call getSocialMediaField()
			Case "SORT_AS"
				Call getSortAsSQL()
			Case "SOURCE"
				Call getSourceFields()
			Case "SPACE_AVAILABLE"
				Call getSpaceAvailableFields()
			Case "SUBJECTS"
				Call getStdCheckListSQL("CIC", "Subj", False, Null, Null, Null, Null, Null, Null)
			Case "TYPE_OF_CARE"
				Call getStdCheckListSQL("CCR", "TOC", True, Null, Null, fldName.Value, strUpdateListCCBTD, strInsertIntoCCBTD, strInsertValueCCBTD)
			Case "VACANCY_INFO"
				Call getVacancyInfoSQL()
			Case "VOLCONTACT"
				Call getContactFields(fldName.Value)
			Case Else
				strFieldVal = Trim(Request(fldName.Value))

				If Not Nl(rsFields.Fields("PB_ID")) Then
					Call getGeneralHeadingSQL(rsFields.Fields("PB_ID").Value,rsFields.Fields("BT_PB_ID").Value,fldName.Value,strFieldVal)
				ElseIf rsFields.Fields("ValidateType") = "w" And Ns(rsFields.Fields("ExtraFieldType")) <> "w" Then
					' NOTE No web field that isn't going into a description Field
					' NOTE Extra WWW Handled below
					Select Case rsFields.Fields("FieldType")
						Case "GBL"
							Call addBTInsertWebField(fldName.Value, rsFields.Fields("FieldDisplay"), strFieldVal, rsFields.Fields("MaxLength"), _
									strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD)
						Case "CIC"
							Call addBTInsertWebField(fldName.Value, rsFields.Fields("FieldDisplay"), strFieldVal, rsFields.Fields("MaxLength"), _
									strUpdateListCBTD,strInsertIntoCBTD,strInsertValueCBTD)
						Case "CCR"
							Call addBTInsertWebField(fldName.Value, rsFields.Fields("FieldDisplay"), strFieldVal, rsFields.Fields("MaxLength"), _
									strUpdateListCCBTD,strInsertIntoCCBTD,strInsertValueCCBTD)
					End Select
				Else
					Dim strProtocol
					strProtocol = vbNullString

					If rsFields.Fields("ValidateType") = "d" or rsFields.Fields("ValidateType") = "a" Then
						Call checkDate(rsFields.Fields("FieldDisplay"),strFieldVal)
						strFieldVal = DateString(strFieldVal,False)
					ElseIf rsFields.Fields("ValidateType") = "e" Then
						Call checkEmail(rsFields.Fields("FieldDisplay"),strFieldVal)
					ElseIf rsFields.Fields("ValidateType") = "w" Then
						' Extra WWW
						Call checkWebWithProtocol(rsFields.Fields("FieldDisplay"),strFieldVal,strProtocol)
					End if
					Call checkLength(rsFields.Fields("FieldDisplay"), strFieldVal, rsFields.Fields("MaxLength"))
					If Nl(strErrorList) Then
						If reEquals(rsFields.Fields("ExtraFieldType"),"a|d|e|r|t|w",False,False,True,False) Then
							Call getExtraFieldSQL(fldName.Value, strFieldVal, rsFields.Fields("ExtraFieldType"), strProtocol)
						ElseIf rsFields.Fields("ExtraFieldType") = "l" Then
							Call getStdCheckListSQL("CIC", "EXC", False, fldName.Value, fldName.Value & "_ID", Null, Null, Null, Null)
						ElseIf rsFields.Fields("ExtraFieldType") = "p" Then
							Call getStdCheckListSQL("CIC", "EXD", False, fldName.Value, fldName.Value, Null, Null, Null, Null)
						Else
							Select Case rsFields.Fields("FieldType")
								Case "GBL"
									If rsFields.Fields("EquivalentSource") Then
										If addBTInsertField(fldName.Value, _
											strFieldVal, _
											(rsFields.Fields("FormFieldType") <> "c" And Ns(rsFields.Fields("ValidateType"))<>"n"), _
											strUpdateListBTD,strInsertIntoBTD,strInsertValueBTD) Then
												Call addChangeField(fldName.Value, Null)
										End If
									Else
										If addBTInsertField(fldName.Value, _
											strFieldVal, _
											(rsFields.Fields("FormFieldType") <> "c" And Ns(rsFields.Fields("ValidateType"))<>"n"), _
											strUpdateListBT,strInsertIntoBT,strInsertValueBT) Then
												Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
										End If
									End If
								Case "CIC"
									If rsFields.Fields("EquivalentSource") Then
										If addBTInsertField(fldName.Value, _
											strFieldVal, _
											(rsFields.Fields("FormFieldType") <> "c" And Ns(rsFields.Fields("ValidateType"))<>"n"), _
											strUpdateListCBTD,strInsertIntoCBTD,strInsertValueCBTD) Then
												Call addChangeField(fldName.Value, Null)
										End If
									Else
										If addBTInsertField(fldName.Value, _
											strFieldVal, _
											(rsFields.Fields("FormFieldType") <> "c" And Ns(rsFields.Fields("ValidateType"))<>"n"), _
											strUpdateListCBT,strInsertIntoCBT,strInsertValueCBT) Then
												Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
										End If
									End If
								Case "CCR"
									If rsFields.Fields("EquivalentSource") Then
										If addBTInsertField(fldName.Value, _
											strFieldVal, _
											(rsFields.Fields("FormFieldType") <> "c" And Ns(rsFields.Fields("ValidateType"))<>"n"), _
											strUpdateListCCBTD,strInsertIntoCCBTD,strInsertValueCCBTD) Then
												Call addChangeField(fldName.Value, Null)
										End If
									Else
										If addBTInsertField(fldName.Value, _
											strFieldVal, _
											(rsFields.Fields("FormFieldType") <> "c" And Ns(rsFields.Fields("ValidateType"))<>"n"), _
											strUpdateListCCBT,strInsertIntoCCBT,strInsertValueCCBT) Then
												Call addChangeField(fldName.Value, g_objCurrentLang.LangID)
										End If
									End If
							End Select
						End If
					End If
				End If
		End Select
		rsFields.MoveNext
	Wend
	If bNeedOrgNUM Then
		'Need to be sure that NUM has been processed
		Call getOrgNumSQL()
	End If

	If Not Nl(g_intPBID) Then
		strExtraSQL = "IF EXISTS(SELECT * FROM CIC_Publication WHERE PB_ID=" & g_intPBID & ") " & _
					"	AND NOT EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=@NUM AND PB_ID=" & g_intPBID &") BEGIN " & _
					"	IF NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE NUM=@NUM) BEGIN " & _
					"		INSERT INTO CIC_BaseTable (" & strBasicInsertInto & ") VALUES " & _
					"		(" & strBasicInsertValues & ") " & _
					"	END " & _
					"	INSERT INTO CIC_BT_PB (NUM,PB_ID) VALUES (@NUM," & g_intPBID & ") " & _
					"END" & vbCrLf & strExtraSQL
	End If

	If bNew Then ' Auto Add Pubs
		strExtraSQL = "IF EXISTS(SELECT * FROM CIC_View_AutoAddPub aap WHERE ViewType=" & g_intViewTypeCIC & " AND " & _
					"	NOT EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=@NUM AND PB_ID=aap.PB_ID)) BEGIN " & _
					"	IF NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE NUM=@NUM) BEGIN " & _
					"		INSERT INTO CIC_BaseTable (" & strBasicInsertInto & ") VALUES " & _
					"		(" & strBasicInsertValues & ") " & _
					"	END " & _
					"	INSERT INTO CIC_BT_PB (NUM,PB_ID) SELECT @NUM,PB_ID FROM CIC_View_AutoAddPub WHERE ViewType=" & g_intViewTypeCIC & _
					" END" & vbCrLf & strExtraSQL
	End If

	If Nl(strErrorList) Then
		strInsSQL = "SET NOCOUNT ON; DECLARE @NUM varchar(8)" & vbCrLf
		If bNew Then
			bUpdateCBT = bInsertCBT Or (strInsertIntoCBT <> strBasicInsertInto And strInsertIntoCBT <> strBasicInsertInto & ",FEE_ASSISTANCE_AVAILABLE")
			bUpdateCBTD = bInsertCBTD Or (strInsertIntoCBTD <> strBasicInsertInto)
			bUpdateCCBT = bInsertCCBT Or (strInsertIntoCCBT <> strBasicInsertInto)
			bUpdateCCBTD = bInsertCCBTD Or (strInsertIntoCCBTD <> strBasicInsertInto)
		
			strInsSQL = strInsSQL & vbCrLf & _
						"SET @NUM=" & QsNl(strNUM) & vbCrLf & _
						"IF NOT EXISTS(SELECT * FROM GBL_BaseTable WHERE NUM=@NUM) BEGIN" & vbCrLf & _
						"	INSERT INTO GBL_BaseTable (" & strInsertIntoBT & ") VALUES (" & strInsertValueBT & ")" & vbCrLf & _
						"	IF @@ERROR<>0 OR NOT EXISTS(SELECT * FROM GBL_BaseTable WHERE NUM=@NUM AND RSN=SCOPE_IDENTITY()) BEGIN" & vbCrLf & _
						"		RAISERROR (N'The record could not be added: %s', 0, 1, @NUM)" & vbCrLf & _
						"		SET @NUM = NULL" & vbCrLf & _
						"	END ELSE BEGIN" & vbCrLf & _
						"		INSERT INTO GBL_BaseTable_Description (" & strInsertIntoBTD & ",LangID) VALUES (" & strInsertValueBTD & ",@@LANGID)" & vbCrLf & _
						"		IF @@ERROR<>0 OR NOT EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LANGID=@@LANGID) BEGIN" & vbCrLf & _
						"			RAISERROR (N'The record could not be added: %s', 0, 1, @NUM)" & vbCrLf & _
						"			SET @NUM = NULL" & vbCrLf & _
						"		END" & vbCrLf & _
						"	END" & vbCrLf & _
						"END ELSE BEGIN" & vbCrLf & _
						"	RAISERROR (N'The record number is already in use: %s', 0, 1, @NUM)" & vbCrLf & _
						"	SET @NUM=NULL" & vbCrLf & _
						"END" & vbCrLf
					
					
			If bUpdateCBT Or bUpdateCBTD Or bUpdateCCBT Or bUpdateCCBTD Then
				strInsSQL = strInsSQL & _
						"IF @NUM IS NOT NULL BEGIN" & vbCrLf
			End If
			If bUpdateCBT Or bUpdateCBTD Then
				strInsSQL = strInsSQL & vbCrLf & _
						"	IF NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE NUM=@NUM) BEGIN" & vbCrLf & _
						"		INSERT INTO CIC_BaseTable (" & strInsertIntoCBT & ") VALUES (" & strInsertValueCBT & ")" & vbCrLf & _
						"	END"
			End If
			If bUpdateCBTD Then
				strInsSQL = strInsSQL & vbCrLf & _
						"	IF NOT EXISTS(SELECT * FROM CIC_BaseTable_Description WHERE NUM=@NUM AND LangID=@@LANGID) BEGIN" & vbCrLf & _
						"		INSERT INTO CIC_BaseTable_Description (" & strInsertIntoCBTD & ",LangID) VALUES (" & strInsertValueCBTD & ",@@LANGID)" & vbCrLf & _
						"	END"
			End If
			If bUpdateCCBT Or bUpdateCCBTD Then
				strInsSQL = strInsSQL & vbCrLf & _
						"	IF NOT EXISTS(SELECT * FROM CCR_BaseTable WHERE NUM=@NUM) BEGIN" & vbCrLf & _
						"		INSERT INTO CCR_BaseTable (" & strInsertIntoCCBT & ") VALUES (" & strInsertValueCCBT & ")" & vbCrLf & _
						"	END"
			End If
			If bUpdateCCBTD Then
				strInsSQL = strInsSQL & vbCrLf & _
						"	IF NOT EXISTS(SELECT * FROM CCR_BaseTable_Description WHERE NUM=@NUM AND LangID=@@LANGID) BEGIN" & vbCrLf & _
						"		INSERT INTO CCR_BaseTable_Description (" & strInsertIntoCCBTD & ",LangID) VALUES (" & strInsertValueCCBTD & ",@@LANGID)" & vbCrLf & _
						"	END"
			End If
			If bUpdateCBT Or bUpdateCBTD Or bUpdateCCBT Or bUpdateCCBTD Then
				strInsSQL = strInsSQL & vbCrLf & _
						"END"
			End If
		Else
			bUpdateCBT = strUpdateListCBT <> strBasicUpdateList And strUpdateListCBT <> strBasicUpdateList
			bUpdateCBTD = strUpdateListCBTD <> strBasicUpdateList
			bUpdateCCBT = strUpdateListCCBT <> strBasicUpdateList
			bUpdateCCBTD = strUpdateListCCBTD <> strBasicUpdateList
		
			strInsSQL = strInsSQL & vbCrLf & _
						"UPDATE GBL_BaseTable SET " & strUpdateListBT & " WHERE RSN=" & intRSN & vbCrLf & _
						"SELECT @NUM=NUM FROM GBL_BaseTable WHERE RSN=" & intRSN & vbCrLf & _
						"IF @NUM IS NOT NULL BEGIN" & vbCrLf & _
						"	IF NOT EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=@@LANGID) BEGIN" & vbCrLf & _
						"		INSERT INTO GBL_BaseTable_Description (" & strBasicInsertInto & ",LangID) VALUES (" & strBasicInsertValues & ",@@LANGID)" & vbCrLf & _
						"	END" & vbCrLf & _
						"	UPDATE GBL_BaseTable_Description SET " & strUpdateListBTD & " WHERE NUM=@NUM AND LangID=@@LANGID"

			If bUpdateCBT Or bInsertCBT Or bUpdateCBTD Then
				strInsSQL = strInsSQL & vbCrLf & _
						"	IF NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE NUM=@NUM) BEGIN" & vbCrLf & _
						"		INSERT INTO CIC_BaseTable (" & strBasicInsertInto & ") VALUES (" & strBasicInsertValues & ")" & vbCrLf & _
						"	END"
				If bUpdateCBT Then
					strInsSQL = strInsSQL & vbCrLf & _
						"	UPDATE CIC_BaseTable SET " & strUpdateListCBT & " WHERE NUM=@NUM"
				End If
			End If
		
			If bUpdateCBTD Or bInsertCBTD Then
				strInsSQL = strInsSQL & vbCrLf & _
						"	IF NOT EXISTS(SELECT * FROM CIC_BaseTable_Description WHERE NUM=@NUM AND LangID=@@LANGID) BEGIN" & vbCrLf & _
						"		INSERT INTO CIC_BaseTable_Description (" & strBasicInsertInto & ",LangID) VALUES (" & strBasicInsertValues & ",@@LANGID)" & vbCrLf & _
						"	END"
			End If
			If bUpdateCBTD Then
				strInsSQL = strInsSQL & vbCrLf & _
						"	UPDATE CIC_BaseTable_Description SET " & strUpdateListCBTD & " WHERE NUM=@NUM AND LangID=@@LANGID"
			End If
		
			If bUpdateCCBT Or bInsertCCBT Or bUpdateCCBTD Then
				strInsSQL = strInsSQL & vbCrLf & _
						"	IF NOT EXISTS(SELECT * FROM CCR_BaseTable WHERE NUM=@NUM) BEGIN" & vbCrLf & _
						"		INSERT INTO CCR_BaseTable (" & strBasicInsertInto & ") VALUES (" & strBasicInsertValues & ")" & vbCrLf & _
						"	END"
				If bUpdateCCBT Then
					strInsSQL = strInsSQL & vbCrLf & _
						"	UPDATE CCR_BaseTable SET " & strUpdateListCCBT & " WHERE NUM=@NUM"
				End If
			End If
		
			If bUpdateCCBTD Or bInsertCCBTD Then
				strInsSQL = strInsSQL & vbCrLf & _
						"	IF NOT EXISTS(SELECT * FROM CCR_BaseTable_Description WHERE NUM=@NUM AND LangID=@@LANGID) BEGIN" & vbCrLf & _
						"		INSERT INTO CCR_BaseTable_Description (" & strBasicInsertInto & ",LangID) VALUES (" & strBasicInsertValues & ",@@LANGID)" & vbCrLf & _
						"	END"
			End If
			If bUpdateCCBTD Then
				strInsSQL = strInsSQL & vbCrLf & _
						"	UPDATE CCR_BaseTable_Description SET " & strUpdateListCCBTD & " WHERE NUM=@NUM AND LangID=@@LANGID"
			End If
		
			strInsSQL = strInsSQL & vbCrLf & _
						"END"
		End If
	
		If Not bNew And Request("deleteCCR") = "on" Then
			If bDeleteCCR Then
				strInsSQL = strInsSQL & vbCrLf & _
					"DELETE FROM CCR_BaseTable WHERE NUM=@NUM"
			End If
		End If
	
		strInsSQL = strInsSQL & vbCrLf & "IF @@ERROR = 0 AND @NUM IS NOT NULL BEGIN" & vbCrLf & strExtraSQL & vbCrLf & "SELECT @VacancyWarning AS VacancyWarning WHERE NULLIF(@VacancyWarning, '') IS NOT NULL" & vbCrLf & "END"
	
		strInsSQL = strInsSQL & vbCrLf & "EXEC sp_CIC_SRCH_u @NUM"

		'Response.Write("<pre>" & Server.HTMLEncode(Ns(strInsSQL)) & "</pre>")
		'Response.Flush()

		Dim cmdInsUpd, bInsSQLError, strInsSQLError, strErrorDetails, objErr, rsInsUpdErrors, strVacancyWarning
		Set cmdInsUpd = Server.CreateObject("ADODB.Command")
		bInsSQLError = False
		strInsSQLError = vbNullString
		strErrorDetails = vbNullString
		With cmdInsUpd
			.ActiveConnection = getCurrentAdminCnn()
			.CommandType = adCmdText
			.CommandText = strInsSQL
			On Error Resume Next
			Set rsInsUpdErrors = .Execute
			If Err.Number <> 0 Or .ActiveConnection.Errors.Count > 0 Then
				bInsSQLError = True
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

				Call sendEmail(True, "qw4afPcItA5KJ18NH4nV@cioc.ca", "qw4afPcItA5KJ18NH4nV@cioc.ca", vbNullString, "Entryform SQL Error", strErrorDetails & strInsSQL)
			End If
			On Error GoTo 0
		End With

		If Err.Number = 0 And Not bInsSQLError Then
			If Not rsInsUpdErrors.EOF Then
				strVacancyWarning = rsInsUpdErrors("VacancyWarning")
				rsInsUpdErrors.Close
			End If
			Dim cmdGetNUM, rsGetNUM, strGetNUMSQL
			strGetNUMSQL = "SELECT bt.NUM, bt.RECORD_OWNER," & _
					"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL" & vbCrLf & _
					"FROM GBL_BaseTable bt" & vbCrLf & _
					"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
					"WHERE " & IIf(Nl(intRSN), "bt.NUM=" & QsNl(strNUM), "bt.RSN=" & intRSN)
				
			'Response.Write(strGetNUMSQL)
			'Response.Flush()

			Set cmdGetNUM = Server.CreateObject("ADODB.Command")
			With cmdGetNUM
				.ActiveConnection = getCurrentAdminCnn()
				.CommandType = adCmdText
				.CommandText = strGetNUMSQL
				Set rsGetNUM = .Execute
			End With
			If Not rsGetNUM.EOF Then
				strNUM = rsGetNUM("NUM")
			End If
			Dim tmpOrgName
			tmpOrgName = rsGetNUM.Fields("ORG_NAME_FULL")
		
			If (Not Nl(strChangeHistoryList) Or Not Nl(strChangeHistoryListL)) And Not Nl(strNUM) Then
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
					.Parameters.Append .CreateParameter("@FieldList", adLongVarChar, adParamInput, -1)
					.Parameters.Append .CreateParameter("@Names", adBoolean, adParamInput, 1, SQL_TRUE)
					.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2, Null)
					.Prepared = True
					If Not Nl(strChangeHistoryList) Then
						.Parameters("@FieldList").Value = strChangeHistoryList
						.Execute
					End If
					If Not Nl(strChangeHistoryListL) Then
						.Parameters("@FieldList").Value = strChangeHistoryListL
						.Parameters("@LangID").Value = g_objCurrentLang.LangID
						.Execute
					End If
				End With
			End If

			Dim intFBID
			intFBID = Trim(Request("FBID"))
			If Nl(intFBID) Then
				intFBID = Null
			ElseIf Not IsIDType(intFBID) Then
				intFBID = Null
			End If

			Dim objReturn, objErrMsg
			Dim cmdDeleteFb
			Set cmdDeleteFb = Server.CreateObject("ADODB.Command")
			With cmdDeleteFb
				.ActiveConnection = getCurrentAdminCnn()
				.CommandType = adCmdStoredProc
				If bNew And Not Nl(intFBID) Then
					If IsIDType(intFBID) Then
						.CommandText = "dbo.sp_CIC_Feedback_d"
						Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
						.Parameters.Append objReturn
						.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
						.Parameters.Append .CreateParameter("@FB_ID", adInteger, adParamInput, 4, intFBID)
						Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
						.Parameters.Append objErrMsg
					End If
				Else
					.CommandText = "dbo.sp_CIC_Feedback_d_NUM"
					.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
					.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2)
					.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
				End If
			End With

			If Not Nl(Request("DeleteFeedback")) Then
				Dim aDeleteFb, _
					indDeleteFb
				aDeleteFb = Split(Request("DeleteFeedback"),",")
			
				For Each indDeleteFb in aDeleteFb
					indDeleteFb = Trim(indDeleteFb)
					If IsCulture(indDeleteFb) Then
						Set objSysLang = create_language_object()
						objSysLang.setSystemLanguage(indDeleteFb)
				
						Call setSessionLanguage(objSysLang.Culture)
						Call getROInfo(rsGetNUM("RECORD_OWNER"),DM_CIC)
						If Not g_bNoEmail Then
							Call sendNotifyEmails(strNUM, intFBID, tmpOrgName)
						End If
						With cmdDeleteFb
							If Not bNew Or Nl(intFBID) Then
								.Parameters("@LangID").Value = objSysLang.LangID
							Else
								intFBID = Null
							End If
							.Execute
						End With
						Call setSessionLanguage(objUpdateLang.Culture)
					End If
				Next
			End If
		
			If bNew And Not Nl(intFBID) Then
				If IsIDType(intFBID) Then
					Dim cmdSetFbRSN
					Set cmdSetFbRSN = Server.CreateObject("ADODB.Command")
					With cmdSetFBRSN
						.ActiveConnection = getCurrentAdminCnn()
						.CommandType = adCmdStoredProc
						.CommandText = "dbo.sp_CIC_Feedback_u_NUM"
						.Parameters.Append .CreateParameter("@FB_ID", adInteger, adParamInput, 4, intFBID)
						.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
						.Execute
					End With
				End If
			End If
		
			If Not bProcessError Then
				Dim strOtherLangList
				strOtherLangList = vbNullString
			
				If Not bNew and g_bMultiLingual Then
					For Each indCulture In Application("Cultures")
						If indCulture <> g_objCurrentLang.Culture Then
							Set objSysLang = create_language_object()
							objSysLang.setSystemLanguage(indCulture)
							If rsOrg("HAS_" & Replace(indCulture,"-","_")) Then
								strOtherLangList = strOtherLangList & "<li>" & _
								IIf(rsOrg("CAN_SEE_" & Replace(indCulture,"-","_")) And rsOrg("CAN_UPDATE_" & Replace(indCulture,"-","_"))=1, _
									"<a href=""" & makeLink("entryform.asp","NUM=" & strNUM & "&UpdateLn=" & indCulture,vbNullString) & """>" & TXT_UPDATE_RECORD & " - <strong>" & objSysLang.LanguageName & "</strong></a>", _
									"<a href=""" & makeLink("feedback.asp","NUM=" & strNUM & "&UpdateLn=" & indCulture,vbNullString) & """>" & TXT_SUGGEST_UPDATE & " - <strong>" & objSysLang.LanguageName) & "</strong></a>" & _
								" (" & TXT_UPDATE_DATE & TXT_COLON & Nz(rsOrg("UPDATE_DATE_" & Replace(indCulture,"-","_")),TXT_UNKNOWN) & ")" & _
								"</li>"
							End If
						End If
					Next
				End If
		
				If Nl(strOtherLangList) And Nl(strVacancyWarning) Then
					Call handleDetailsMessage(TXT_UPDATE_SUCCESSFUL, _
						strNUM, _
						StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber), _
						False)
				Else
					Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
					If Not Nl(strVacancyWarning) Then
						strVacancyWarning = "<root>" & strVacancyWarning & "</root>"
						%><p class="AlertBubble"><%= TXT_VACANCY_INFO_VACANCY_CHANGED %></p><%= make_vacancy_history_table(strVacancyWarning) %><%

					End If
					If Not Nl(strOtherLangList) Then
%>
<h2><%=TXT_RECORD_DETAILS & TXT_COLON%><a href="<%=makeDetailsLink(strNUM,StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber),vbNullString)%>"><%=tmpOrgName%></a></h2>
<p><%=TXT_EDIT_EQUIVALENT%>
<ul>
	<%=strOtherLangList%>
</ul>
</p>
<%
					End If
					Call makePageFooter(True)
				End If
			End If
		Else
			Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
			Call handleError(TXT_UNKNOWN_ERRORS_OCCURED & strInsSQLError & ".",vbNullString,vbNullString)
			Call makePageFooter(True)
		End If
	Else
		Call makePageHeader(TXT_UPDATE_ADD_RECORD, TXT_UPDATE_ADD_RECORD, True, False, True, True)
		Call handleError(TXT_ERRORS_FOUND & TXT_COLON & "<ul>" & strErrorList & "</ul>",vbNullString,vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
		Call makePageFooter(True)
	End If

	Call setSessionLanguage(strRestoreCulture)

End If
%>

<!--#include file="includes/core/incClose.asp" -->
