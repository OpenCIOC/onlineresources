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
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/mapping/incGoogleMaps.asp" -->
<!--#include file="text/txtGeoCode.asp" -->
<%
If Not user_bCanDoBulkOpsCIC Then
	Call securityFailure()
End If

Dim	strIDList, _
	intGeoCodeType, _
	strGeoCodeType, _
	intMapPin, _
	bRetryWOPostal, _
	bError
	
bError = False
strIDList = Request("IDList")
intGeoCodeType = Request("GEOCODE_TYPE")
intMapPin = Request("MAP_PIN")
bRetryWOPostal = not Nl(Request("RetryWOPostal"))
If Not IsNumeric(intGeoCodeType) Then
	bError = True
	intGeoCodeType = Null
Else
	intGeoCodeType = CInt(intGeoCodeType)
	Select Case intGeoCodeType
	Case GC_DONT_CHANGE
		strGeoCodeType = TXT_GC_DONT_CHANGE
	Case GC_CURRENT
		strGeoCodeType = TXT_GC_CURRENT_SETTING
	Case GC_BLANK
		strGeoCodeType = TXT_GC_BLANK_NO_GEOCODE
	Case GC_SITE
		strGeoCodeType = TXT_GC_SITE_ADDRESS
	Case GC_INTERSECTION
		strGeoCodeType = TXT_GC_INTERSECTION
	Case Else
		bError = True
		intGeoCodeType = Null
	End Select
End If

If Not IsNumeric(intMapPin) Then
	intMapPin = Null
Else
	intMapPin = CInt(intMapPin)
	If intMapPin < MAP_PIN_MIN Or intMapPin > MAP_PIN_MAX Then
		intMapPin = Null
	End If
End If

Call makePageHeader(TXT_SELECTED_GEOCODING, TXT_SELECTED_GEOCODING, True, False, True, True)

If Not hasGoogleMapsAPI() Then
	bError = True
	Call handleError(TXT_GEOCODE_NO_MAP_KEY, _
			vbNullString, vbNullString)
ElseIf bError Then
	Call handleError(TXT_NO_ACTION, _
		vbNullString, _
		vbNullString)
ElseIf Nl(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf Not IsNUMList(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
End If
If Not bError Then
	Dim strSQL, _
		strGeocodeQuery, _
		strGeocodeQueryNoPC

	strSQL = "SELECT bt.NUM, dbo.fn_CIC_CanUpdateRecord(bt.NUM," & user_intID & _
				"," & g_intViewTypeCIC & ",btd.LangID,GETDATE()) AS CAN_UPDATE, GEOCODE_TYPE, LATITUDE, LONGITUDE" & _
				",dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL"
	If intGeoCodeType = GC_CURRENT Or intGeoCodeType = GC_SITE Then
		strSQL = strSQL & ", CMP_SiteAddress SITE_ADDRESS" 
		If bRetryWOPostal Then
			strSQL = strSQL & ", dbo.fn_GBL_FullAddress(NULL, NULL, btd.SITE_LINE_1, btd.SITE_LINE_2, NULL, btd.SITE_STREET_NUMBER, btd.SITE_STREET, btd.SITE_STREET_TYPE, btd.SITE_STREET_TYPE_AFTER, " & _
				"btd.SITE_STREET_DIR, NULL, btd.SITE_CITY, btd.SITE_PROVINCE, ISNULL(btd.SITE_COUNTRY, 'Canada'), NULL, NULL, NULL, NULL, NULL, NULL, btd.LangID, 0) " & _
				"AS SITE_ADDRESS_NO_PC" 
		End If
	End If
	
	If intGeoCodeType = GC_CURRENT Or intGeoCodeType = GC_INTERSECTION Then
		strSQL = strSQL & ",INTERSECTION,SITE_CITY,SITE_PROVINCE, SITE_COUNTRY"
	End If
	
	If Not Nl(intMapPin) Then
		strSQL = strSQL & ", bt.MAP_PIN"
	End If
	
	strSQL = strSQL & vbCrLf & "FROM GBL_BaseTable bt" & vbCrLf & _
		"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=0 THEN 0 ELSE CASE WHEN LangID=@@LANGID THEN 1 ELSE 2 END END, LangID)" & vbCrLf
	
	If intGeoCodeType = GC_CURRENT Or intGeoCodeType = GC_INTERSECTION Then
		strSQL = strSQL & _
			"LEFT JOIN CIC_BaseTable_Description cbtd ON bt.NUM=cbtd.NUM AND cbtd.LangID=(SELECT TOP 1 LangID FROM CIC_BaseTable_Description WHERE NUM=cbtd.NUM ORDER BY CASE WHEN LangID=0 THEN 0 ELSE CASE WHEN LangID=@@LANGID THEN 1 ELSE 2 END END, LangID)" & vbCrLf
	End If
	strSQL = strSQL & _
		"WHERE bt.NUM in (" & QsStrList(strIDList) & ")"
	
	'Response.Write(strSQL)
	'Response.Flush()

	Dim cmdUpdateGeocode, rsUpdateGeocode, bIDError
	Set cmdUpdateGeocode = Server.CreateObject("ADODB.Command")
	Set rsUpdateGeocode = Server.CreateObject("ADODB.Recordset")

	bIDError = False

	With cmdUpdateGeocode
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = strSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
	With rsUpdateGeocode
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdUpdateGeocode
	End With

	If rsUpdateGeocode.EOF Then
		bIDError = True
	End If

	If Not bIDError Then
	%>
	<h2><%=TXT_GEOCODE_USING & strGeoCodeType%> <input type='button' class="NotVisible" id="restart_geocode" value="<%= TXT_RESTART_PROCESSING %>"> <input type='button' class="NotVisible" id="continue_geocode" value="<%= TXT_CONTINUE_PROCESSING %>"></h2>
	<table id="geocode_table" class="BasicBorder cell-padding-3">
	<tr class="RevTitleBox" id="table_header"><th><%=TXT_RECORD_NUM%></th><th><%=TXT_ORG_NAMES%></th><th><%=TXT_STATUS%></th></tr>
	<%
	With rsUpdateGeocode
		While Not .EOF
			If intGeoCodeType=GC_SITE Or (intGeoCodeType=GC_CURRENT And .Fields("GEOCODE_TYPE")=GC_SITE) Then
				strGeocodeQuery = .Fields("SITE_ADDRESS")
				If bRetryWOPostal Then
					strGeocodeQueryNoPC = .Fields("SITE_ADDRESS_NO_PC")
				Else
					strGeocodeQueryNoPC = vbNullString
				End If
			ElseIf intGeoCodeType=GC_INTERSECTION Or (intGeoCodeType=GC_CURRENT And .Fields("GEOCODE_TYPE")=GC_INTERSECTION) Then
				strGeocodeQuery = Join(Array(Ns(.Fields("INTERSECTION")), Ns(.Fields("SITE_CITY")), Ns(.Fields("SITE_PROVINCE")), Nz(.Fields("SITE_COUNTRY"), "Canada")), ", ")
				strGeocodeQueryNoPC = vbNullString
			Else
				strGeocodeQuery = vbNullString
				strGeocodeQueryNoPC = vbNullString
			End If
			%><tr valign="top" class="RowToCode" id="row_to_code_<%=.Fields("NUM")%>" latitude="<%=.Fields("LATITUDE")%>" longitude="<%=.Fields("LONGITUDE")%>" <%If Not Nl(intMapPin) Then%> map_pin="<%=.Fields("MAP_PIN")%>"<%end if%>geocode_type="<%=.Fields("GEOCODE_TYPE")%>" geocode_query=<%=AttrQs(Server.HTMLEncode(Ns(strGeocodeQuery)))%> <%If Not Nl(strGeocodeQueryNoPC) Then%>geocode_query_no_pc=<%=AttrQs(Server.HTMLEncode(Ns(strGeocodeQueryNoPC)))%> <%End If%>can_update="<%=.Fields("CAN_UPDATE")%>">
				<td><a href="<%=makeDetailsLink(.Fields("NUM"), vbNullString, vbNullString)%>"><%=.Fields("NUM")%></a></td>
				<td><%=.Fields("ORG_NAME_FULL")%></td>
				<td><span id="status_no_pc_<%=.Fields("NUM")%>" class="NotVisible"><%=TXT_GEOCODED_WITHOUT_POSTAL%><br></span><span id="status_<%=.Fields("NUM")%>" class="NotVisible"></td>
			</tr><%
			.MoveNext
		Wend
	End With
	%>

	</table>
	<form id="stateForm" name="stateForm" class="NotVisible"><input type="text" id="stateField" name="stateField" value="0"></form>
	<%= makeJQueryScriptTags() %>
	<%= JSVerScriptTag("scripts/geocode.js") %>
	<%= JSVerScriptTag("scripts/cultures/globalize.culture." & g_objCurrentLang.Culture & ".js") %>
	<% g_bListScriptLoaded = True %>
	<script type="text/javascript">
		jQuery(function() {
			var status_messages = { 
						coding: <%=JsQs(TXT_GEOCODE_CODING)%>,
						nochange: <%=JsQs(TXT_UNCHANGED)%>,
						updating: <%=JsQs(TXT_GEOCODE_UPDATING)%>,
						unknown: <%=JsQs(TXT_GEOCODE_UNKNOWN_ADDRESS) %>,
						error_unknown_address: <%=JsQs(TXT_GEOCODE_UNKNOWN_ADDRESS) %>,
						error_map_key_fail: <%= JsQs(TXT_GEOCODE_TOO_MANY_QUERIES) %>,
						error_too_many_queries: <%= JsQs(TXT_GEOCODE_TOO_MANY_QUERIES) %>,
						error_unknown_error: <%= JsQs(TXT_GEOCODE_UNKNOWN_ERROR & TXT_COLON) %>,
						error_server: <%= JsQs(TXT_SERVER_ERROR) %>
			};
			var types = {
				dont_change: <%= GC_DONT_CHANGE %>,
				current: <%= GC_CURRENT %>,
				blank: <%= GC_BLANK %>,
				manual: <%= GC_MANUAL %>
			};

			initialize({status_messages: status_messages, culture: "<%= g_objCurrentLang.Culture %>", 
				map_pin_target: <%=Nz(intMapPin, "null")%>, types: types,
				url: <%= JsQs(makeLinkB("jsonfeeds/geocode_update.asp")) %>,
				geocode_type_target: <%= intGeoCodeType %>,
				key_arg: <%= JSONQs(getGoogleMapsKeyArg(), True) %>
				});
		});
	</script>
	<%
	End If
End If

Call makePageFooter(True)
%>

<!--#include file="includes/core/incClose.asp" -->

