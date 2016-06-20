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
<!--#include file="text/txtPrintMap.asp" -->
<!--#include file="text/txtSearchResults.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/list/incMappingCategoryList.asp" -->
<!--#include file="includes/mapping/incGoogleMaps.asp" -->


<%
Call makePageHeader(TXT_PRINT_MAP, TXT_PRINT_MAP, False, False, False, False)

Const OT_LETTER_PORTRAIT = 0
Const OT_LETTER_LANDSCAPE = 1
Const OT_LEGAL_PORTRAIT = 2
Const OT_LEGAL_LANDSCAPE = 3
Const OT_CUSTOM = 4

Dim	strIDList, _
	intOrientation, _
	strDimensionStyle, _
	strSQL, _
	bError

bError = False

strIDList = Replace(Request("IDList")," ",vbNullString)

intOrientation = Request("Orientation")
If Not IsNumeric(intOrientation) Then
	intOrientation = OT_LETTER_PORTRAIT
Else
	intOrientation = CInt(intOrientation)
End If

Select Case intOrientation
	Case OT_LETTER_PORTRAIT
		strDimensionStyle = "height: 10.5in; width: 7.8in;"
	Case OT_LETTER_LANDSCAPE
		strDimensionStyle = "height: 7.5in; width: 10.5in;"
	Case OT_LEGAL_PORTRAIT
		strDimensionStyle = "height: 13.5in; width: 7.8in;"
	Case OT_LEGAL_LANDSCAPE
		strDimensionStyle = "height: 7.5in; width: 13.5in;"
	Case Else
		intOrientation = OT_CUSTOM
End Select

If Nl(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf Not IsNUMList(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
Else
	strIDList = QsStrList(strIDList)
	strSQL = "SELECT mc.MapImageSmCircle, mcn.Name AS CategoryName" & vbCrLf & _
		"FROM GBL_MappingCategory mc" & vbCrLf & _
		"LEFT JOIN GBL_MappingCategory_Name mcn ON mc.MapCatID=mcn.MapCatID AND mcn.LangId=" & g_objCurrentLang.LangID & vbCrLf & _
		"WHERE mcn.Name IS NOT NULL" & vbCrLf & _
		"AND EXISTS(SELECT * FROM GBL_BaseTable WHERE MAP_PIN=mc.MapCatID AND NUM IN (" & strIDList & "))" & vbCrLf & _
		"SELECT bt.NUM, dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & vbCrLf & _
		"bt.LATITUDE, bt.LONGITUDE, bt.MAP_PIN, mc.MapImageSmCircle, mcn.Name AS CategoryName" & vbCrLf & _
		"FROM GBL_BaseTable bt " & vbCrLf & _
		"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbcrLf & _
		"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
		"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbcrLf & _
		"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
		"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=" & g_objCurrentLang.LangID & vbCrLf & _
		"LEFT JOIN GBL_MappingCategory mc on bt.MAP_PIN=mc.MapCatID" & vbCrLf & _
		"LEFT JOIN GBL_MappingCategory_Name mcn ON mc.MapCatID=mcn.MapCatID AND mcn.LangID=" & g_objCurrentLang.LangID

	Dim strViewWhereClause
	strViewWhereClause = IIf(g_bCanSeeDeletedCIC,g_strWhereClauseCIC,g_strWhereClauseCICNoDel)
	strSQL = strSQL & " WHERE bt.NUM IN (" & strIDList & ")" & StringIf(Not Nl(strViewWhereClause), " AND " & strViewWhereClause) & vbCrLf & _
		"ORDER BY ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5," & vbCrLf & _
		"	STUFF(" & vbCrLf & _
		"		CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)" & vbCrLf & _
		"			THEN NULL" & vbCrLf & _
		"			ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +" & vbCrLf & _
		"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +" & vbCrLf & _
		"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')" & vbCrLf & _
		"			 END," & vbCrLf & _
		"		1, 2, ''" & vbCrLf & _
		"	)"

	Dim strLegend, _
		strCategoryName

	Dim cmdOrgList, rsOrgList
	Set cmdOrgList = Server.CreateObject("ADODB.Command")
	With cmdOrgList
		.CommandText = strSQL
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
	Set rsOrgList = Server.CreateObject("ADODB.Recordset")
	With rsOrgList
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdOrgList

		While Not .EOF
			strCategoryName = .Fields("CategoryName")
			If Not Nl(strCategoryName) Then
				strLegend = strLegend & "<tr><td><img src=""" & ps_strPathToStart & "images/mapping/" & .Fields("MapImageSmCircle") & """></td><td>" & strCategoryName & "</td></tr>"
			End If
			.MoveNext
		Wend
	End With
	
	Set rsOrgList = rsOrgList.NextRecordset

	If rsOrgList.EOF Then
		bError = True
		Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
	End If

End If

If Not bError Then
%>
<style type="text/css">
.cluster {
	-webkit-print-color-adjust: exact;
	print-color-adjust: exact;
}
</style>
<div id="map_canvas" style="<%=strDimensionStyle%> page-break-after: always; page-breakinside: avoid;"></div>
<h1 class="NotVisible" id="PrintMapPageTitle"></h1>
<%
	If Not Nl(strLegend) Then
%>
<table class="NoBorder cell-padding-2">
<tr><td><img src="<%= ps_strPathToStart %>images/mapping/mm_0_white_20_circle.png"></td><td><%= TXT_MULTIPLE_ORGANIZATIONS %></td></tr>
<%=strLegend%>
</table>
<%
	End If
%>
<table class="BasicBorder cell-padding-3" style="margin-top: 10px;">
<tr class="RevTitleBox"><th></th><th><img src="<%=ps_strPathToStart%>images/mapping/mm_0_white_20.png"></th><th><%=TXT_RECORD_NUM%></th><th><%=TXT_ORG_NAMES%></th></tr>
<% 
	Dim fldOrgName, _
		fldLatitude, _
		fldLongitude, _
		fldMapPinID, _
		fldMapImage
	
	Dim i
	i = 0

	With rsOrgList	
		If Not .EOF Then
			Set fldOrgName = .Fields("ORG_NAME_FULL")
			Set fldLatitude = .Fields("LATITUDE")
			Set fldLongitude = .Fields("LONGITUDE")
			Set fldMapPinID = .Fields("MAP_PIN")
			Set fldMapImage = .Fields("MapImageSmCircle")
			While Not .EOF
				If Not Nl(fldLatitude) Then
					i = i+1
				End If
%>
	<tr valign="top" <%If Not Nl(fldLatitude) And Not Nl(fldLongitude) Then%>class="MapRow" data-mapinfo='{"latitude":<%=Server.HTMLEncode(JSONQs(fldLatitude.Value, True))%>, "longitude": <%=Server.HTMLEncode(JSONQs(fldLongitude.Value,True))%>, "mappin":<%=fldMapPinID.Value%>, "mapid":<%=i%>, "num":<%=Server.HTMLEncode(JSONQs(.Fields("NUM"), True))%>}'<%End If%>><td><%If Not Nl(fldMapImage) Then%><img src="<%=ps_strPathToStart%>images/mapping/<%=fldMapImage%>" title="<%=.Fields("CategoryName")%>"><%End If%></td><td id="map_pin_number_<%=.Fields("NUM")%>"><%=IIf(Nl(fldLatitude),"&nbsp;",i)%></td><td><%=.Fields("NUM")%></td><td><%=fldOrgName.Value%></td></tr>
<%
				.MoveNext
			Wend
%>
</table>
<%
		End If
	End With
%>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/printmap.js") %>
<%= JSVerScriptTag("scripts/cultures/globalize.culture." & g_objCurrentLang.Culture & ".js") %>
<% g_bListScriptLoaded = True %>
<script type="text/javascript">
(function(){
var map_pins = {
0: {
	category: 'Cluster',
	image: 'mm_0_white_circle.png',
	textColour: '000000'
<%
		Call openMappingCategoryListRst()
		With rsListMappingCategory
			.MoveFirst
			While Not .EOF
%>
},
<%=.Fields("MapCatID")%>: {
	category: <%=JsQs(.Fields("CategoryName"))%>, 
	image: <%=JsQs(.Fields("MapImageCircle"))%>,
	textColour: <%=JsQs(.Fields("TextColour"))%>

<%
				.MoveNext
			Wend
		End With
		Call closeMappingCategoryListRst()
%>
	}
};
	jQuery(function() {
		init({map_pins: map_pins,
			culture: "<%= g_objCurrentLang.Culture %>",
			key_arg: <%= JSONQs(getGoogleMapsKeyArg(), True) %>,
			});
	});
})();
</script>
<%

End If

	Call makePageFooter(False)
%>

<!--#include file="includes/core/incClose.asp" -->


