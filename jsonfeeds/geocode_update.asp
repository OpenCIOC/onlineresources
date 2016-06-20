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
Call setPageInfo(False, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtGeoCode.asp" -->
<!--#include file="../text/txtSecurityFailure.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%

'Set response type headers
Response.ContentType = "application/json"
Response.CacheControl = "Private"
Response.Expires=-1

Call run_response_callbacks()

If Not user_bCanDoBulkOpsCIC Then
%>{"fail": true, "msg": <%=JSONQs(TXT_SECURITY_FAILURE, True)%>}<%
	%><!--#include file="../includes/core/incClose.asp" --><%
	Response.End()
End If

Dim	bError, _
	strNUM, _
	intGeoCodeType, _
	intMapPin, _
	decLat, _
	decLong, _
	strMessage

bError = False

strNUM = Request("NUM")
intGeoCodeType = Request("GEOCODE_TYPE")
intMapPin = Request("MAP_PIN")

If Nl(strNUM) Then
	bError = True
	strMessage = (TXT_NO_RECORD_CHOSEN)
ElseIf Not IsNUMType(strNUM) Then
	bError = True
	strMessage = (TXT_INVALID_ID & Server.HTMLEncode(strNUM))
ElseIf Nl(intGeoCodeType) Then
	bError = True
	strMessage = (TXT_NO_ACTION)
ElseIf Not IsNumeric(intGeoCodeType) Then
	bError = True
	strMessage = (TXT_ERROR & "invalid geocode type")
Else
	intGeoCodeType = CInt(intGeoCodeType)
End If

If Not IsNumeric(intMapPin) Then
	intMapPin = Null
Else
	intMapPin = CInt(intMapPin)
	If intMapPin < MAP_PIN_MIN Or intMapPin > MAP_PIN_MAX Then
		intMapPin = Null
	End If
End If

If Not bError Then
	If intGeoCodeType = GC_SITE Or intGeoCodeType = GC_INTERSECTION Then
		decLat = Request("LATITUDE")
		decLong = Request("LONGITUDE")
		If Nl(decLat) Or Nl(decLong) Then
			bError = True
			strMessage = (TXT_ERROR & TXT_INVALID_MISSING_LAT_LONG_DATA)
		ElseIf Not (IsNumeric(decLat) And IsNumeric(decLong)) Then
			bError = True
			strMessage = (TXT_ERROR & TXT_INVALID_MISSING_LAT_LONG_DATA)
		Else
			decLat = CDbl(decLat)
			decLong = CDbl(decLong)
			If Not (decLat >= -180 And decLat <= 180 And decLong >= -180 And decLong <= 180) Then
				bError = True
				strMessage = (TXT_ERROR & TXT_INVALID_MISSING_LAT_LONG_DATA)
			End If
		End If
	ElseIf intGeoCodeType = GC_BLANK Or intGeoCodeType = GC_DONT_CHANGE Then
		decLat = Null
		decLong = Null
	Else
		bError = True
		strMessage = (TXT_ERROR & "invalid geocode type")
	End If
End If

If Not bError Then
	Dim objReturn, objErrMsg
	Dim cmdUpdateGeoCode, rsUpdateGeoCode
	Set cmdUpdateGeoCode = Server.CreateObject("ADODB.Command")
	With cmdUpdateGeoCode
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_GeoCode_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNum)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@GEOCODE_TYPE", adInteger, adParamInput, 2, intGeoCodeType)
		.Parameters.Append .CreateParameter("@MAP_PIN", adInteger, adParamInput, 1, intMapPin)
		.Parameters.Append .CreateParameter("@LATITUDE", adDecimal, adParamInput)	
		.Parameters("@LATITUDE").Precision = 11
		.Parameters("@LATITUDE").NumericScale = 7
		.Parameters("@LATITUDE") = decLat
		.Parameters.Append .CreateParameter("@LONGITUDE", adDecimal, adParamInput)	
		.Parameters("@LONGITUDE").Precision = 11
		.Parameters("@LONGITUDE").NumericScale = 7
		.Parameters("@LONGITUDE") = decLong
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsUpdateGeoCode = cmdUpdateGeoCode.Execute
	Set rsUpdateGeoCode = rsUpdateGeoCode.NextRecordset
	
	Select Case objReturn.Value
		Case 0
			strMessage = TXT_SUCCESS
		Case Else
			bError = True
			strMessage = TXT_ERROR & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End Select

End If

If bError Then
%>{ "fail": true, "msg": <%=JSONQs(strMessage, True)%> }<%
Else
%>{ "fail": false, "msg": <%=JSONQs(TXT_GEOCODE_UPDATED, True)%> }<%
End If

%>

<!--#include file="../includes/core/incClose.asp" -->
