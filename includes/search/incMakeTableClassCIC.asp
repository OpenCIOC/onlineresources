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
' Purpose: 		Object class which can display a list of Organization / Program records,
'				including options and formatting as specified in the current module's "Display Options".
'				The SQL to select the source and criteria of records to be displayed is a parameter of
'				the setOptions function of this class.
'				In order to preserve link structure from web-enabled fields in the display,
'				This file should never be used / included in a file that will display its results 
'				with a directory other than the usual base directory for the module being used.
'
%>

<script language="python" runat="server">
import lxml.html
from cioc.core import gtranslate

def results_page_link():
	from urlparse import parse_qsl
	from urllib import urlencode
	qs = pyrequest.query_string

	parsed_qs = parse_qsl(qs, True)
	qs = urlencode([(x,y) for x, y in parsed_qs if x.lower() != 'page'])

	if qs:
		qs = '?' + qs + '&Page='
	else:
		qs = '?Page='

	return pyrequest.path + qs


def clean_html_for_label(data):
	tree = lxml.html.document_fromstring(unicode(data))
	return tree.text_content()
</script>

<%
Const CAN_RANK_NONE = 0
Const CAN_RANK_SIMPLE = 1
Const CAN_RANK_QUOTED = 2
Const CAN_RANK_BOTH = 3

Dim cmdOrgList, _
	strParamSQL

strParamSQL = vbNullString

Dim strSearchInfoRefineNotes

Dim decNearLatitude, _
	decNearLongitude, _
	decNearDistance

Set cmdOrgList = Server.CreateObject("ADODB.Command")
With cmdOrgList
	.ActiveConnection = getCurrentCICBasicCnn()
	.CommandType = adCmdText
	.CommandTimeout = 0
End With

Class OrgRecordTable

Private rsOrgList, _
		cmdCustField, _
		rsCustField, _
		strCustOrderSelect

Private intCanRank, _
		bSortNearHome, _
		decHomeLatitude, _
		decHomeLongitude

Private aCustFields, _
		indOrgFldData, _
		aFacetFields, _
		intCurFld

Private strFromSQL, _
		strWhereSQL, _
		strSaveSQL, _
		strSaveNotes, _
		bInclDeleted, _
		bShowUnhideSubjLink, _
		strHTTPVals

Private bCustResultsFields, _
		bEnableListViewMode

Private intResultsPageSize, _
		intResultsCurrentPage

Private Sub Class_Initialize()
	Set rsOrgList = Server.CreateObject("ADODB.Recordset")
	With rsOrgList
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
	End With

	bCustResultsFields = False
	If reEquals(ps_strThisPage,"results.asp",True,False,True,False) Then
		If bCFldInc1 Or bCFldInc2 Then
			bCustResultsFields = True
		End If
	End If

	bEnableListViewMode = False

End Sub

Public Function setOptions(strFrom,strWhere,strSSNotes,bIncludeDeleted,bShowUnhideSubj,strQSVals,intRelevancyType,decInHomeLatitude,decInHomeLongitude,bInSortNearHome)
	Dim strViewWhereClause
	strViewWhereClause = IIf(bIncludeDeleted And g_bCanSeeDeletedCIC,g_strWhereClauseCIC,g_strWhereClauseCICNoDel)

	strFromSQL = strFrom
	If Nl(decNearDistance) Or Nl(decNearLatitude) Then
		strSaveSQL = strWhere
	End If
	strSaveNotes = strSSNotes
	strWhereSQL = strWhere & IIf(Not (Nl(strViewWhereClause) Or Nl(strWhere)),AND_CON,vbNullString) & strViewWhereClause
	bInclDeleted = bIncludeDeleted
	bShowUnhideSubjLink = bShowUnhideSubj
	strHTTPVals = strQSVals
	intCanRank = intRelevancyType
	decHomeLatitude = decInHomeLatitude
	decHomeLongitude = decInHomeLongitude
	bSortNearHome = bInSortNearHome
	intResultsPageSize = get_view_data_cic("ResultsPageSize")
	intResultsCurrentPage = 0
	If Not Nl(intResultsPageSize) Then
		intResultsCurrentPage = Request("Page")
		If intResultsCurrentPage = "all" Then
			intResultsPageSize = vbNullString
			intResultsCurrentPage = vbNullString
		ElseIf Nl(intResultsCurrentPage) Then
			intResultsCurrentPage = 0
		ElseIf IsNumeric(intResultsCurrentPage) Then
			intResultsCurrentPage = CInt(intResultsCurrentPage)
			If intResultsCurrentPage < 0 Then
				intResultsCurrentPage = 0
			End If
		Else
			intResultsCurrentPage = 0
		End If
	End If
End Function

Public Function enableListViewMode()
	bEnableListViewMode = True
End Function

Private Function getFields(bWeb)
	Dim strFieldList
	strFieldList = "bt.NUM,bt.RECORD_OWNER"
	
	If opt_fld_bAlertCIC Then
		strFieldList = strFieldList & "," & vbCrLf & _
			"btd.NON_PUBLIC," & vbCrLf & _
			"CAST(CASE WHEN cbtd.COMMENTS IS NULL " & _
				"THEN 0 ELSE 1 END AS bit) AS HAS_COMMENTS," & vbCrLf & _
			"CAST(CASE WHEN btd.DELETION_DATE > GETDATE() "& _
				"THEN 1 ELSE 0 END AS bit) AS TO_BE_DELETED," & vbCrLf & _
			"CAST(CASE WHEN btd.DELETION_DATE <= GETDATE() "& _
				"THEN 1 ELSE 0 END AS bit) AS IS_DELETED," & vbCrLf & _
			"CAST(CASE WHEN EXISTS(SELECT * FROM GBL_FeedbackEntry fbe WHERE fbe.NUM=bt.NUM " & _
					"AND (EXISTS(SELECT * FROM GBL_Feedback fb WHERE fbe.FB_ID=fb.FB_ID) OR EXISTS(SELECT * FROM CIC_Feedback fb WHERE fbe.FB_ID=fb.FB_ID))) " & _
			"THEN 1 ELSE 0 END AS bit) AS HAS_FEEDBACK," & vbCrLf & _
			"CAST(CASE WHEN bt.MemberID=" & g_intMemberID & " THEN 0 ELSE 1 END AS bit) AS IS_SHARED," & vbCrLf & _
			"CASE WHEN EXISTS(SELECT * FROM CIC_BT_PB pbr INNER JOIN CIC_Feedback_Publication pf ON pbr.BT_PB_ID=pf.BT_PB_ID WHERE pbr.NUM=bt.NUM) " & _
				"THEN 1 ELSE 0 END AS HAS_PUB_FEEDBACK" ' & vbCrLf & _

			If g_bUseVOL And g_bVolunteerLink Then
				strFieldList = strFieldList & "," & vbCrLf & "CASE WHEN EXISTS(SELECT * FROM VOL_Opportunity vo" & vbCrLF & _
					"INNER JOIN VOL_Opportunity_Description vod" & vbCrLf & _
					"	ON vo.VNUM=vod.VNUM" & vbCrLf & _
					"WHERE vo.NUM=bt.NUM " & vbCrLf & _
					"AND " & g_strWhereClauseVOLNoDel & ")" & vbCrLf & _
					"THEN 1 ELSE 0 END AS HAS_VOL_OPPS"
			End If
	End If
	If opt_fld_bOrgCIC Or (g_bMapSearchResults And Not g_bPrintMode) Then
		strFieldList = strFieldList & ",dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL"
	End If
	If opt_fld_bLocated Then
		strFieldList = strFieldList & _
			",btd.CMP_LocatedIn AS LOCATED_IN"
	End If
	If opt_fld_bUpdateScheduleCIC Or opt_bUpdateCIC Then
		strFieldList = strFieldList & ",cioc_shared.dbo.fn_SHR_GBL_DateString(btd.UPDATE_SCHEDULE) AS UPDATE_SCHEDULE"
		If opt_bUpdateCIC Then
			strFieldList = strFieldList & ",dbo.fn_CIC_CanUpdateRecord(bt.NUM," & user_intID & "," & g_intViewTypeCIC & ",btd.LangID,GETDATE()) AS CAN_UPDATE"
		End If
	End If
	If opt_bEmailCIC Then
		strFieldList = strFieldList & _
			",CASE WHEN ((bt.UPDATE_EMAIL IS NOT NULL OR EXISTS(SELECT * FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND E_MAIL IS NOT NULL)) AND bt.NO_UPDATE_EMAIL=0) " & _
		"THEN 1 ELSE 0 END AS CAN_EMAIL"
	End If
	If g_bMapSearchResults And Not g_bPrintMode Then
		strFieldList = strFieldList & _
			",bt.LATITUDE,bt.LONGITUDE,bt.MAP_PIN"
	End If
	Call getCustomFields(bWeb)
	If IsArray(aCustFields) Then
		For Each indOrgFldData In aCustFields
			If Not Nl(indOrgFldData.fSelect) Then
				strFieldList = strFieldList & "," & vbCrLf & indOrgFldData.fSelect
			End If
		Next
	End If
	Call getFacetFields()
	If IsArray(aFacetFields) Then
		For Each indOrgFldData In aFacetFields
			If Not Nl(indOrgFldData.fSelect) Then
				strFieldList = strFieldList & "," & vbCrLf & indOrgFldData.fSelect & " AS FacetField" & indOrgFldData.fFieldID
			End If
		Next
	End If
	getFields = strFieldList
End Function

Private Sub getCustomFields(bWeb)
	Dim cmdCustField, rsCustField
	
	If IsArray(opt_fld_aCustCIC) Or bCustResultsFields Then
		Dim strFldList, strFldListCon
		If IsArray(opt_fld_aCustCIC) Then
			strFldList = Join(opt_fld_aCustCIC,",")
		End If
		If bCustResultsFields Then
			If Not Nl(strFldList) Then
				strFldListCon = ","
			End If
			If bCFldInc1 Then
				strFldList = strFldList & strFldListCon & strCFldIDList1
				strFldListCon = ","
			End If
			If bCFldInc2 Then
				strFldList = strFldList & strFldListCon & strCFldIDList2
				strFldListCon = ","
			End If
		End If

		If Not Nl(strFldList) Then
			Set cmdCustField = Server.CreateObject("ADODB.Command")
			With cmdCustField
				.ActiveConnection = getCurrentCICBasicCnn()
				.CommandType = adCmdStoredProc
				.CommandText = "sp_CIC_View_CustomField_sr"
				.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strFldList)
				.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
				.Parameters.Append .CreateParameter("@WebEnable", adBoolean, adParamInput, 1, IIf(bWeb,SQL_TRUE,SQL_FALSE))
				.Parameters.Append .CreateParameter("@LoggedIn", adBoolean, adParamInput, 1, IIf(user_bLoggedIn,SQL_TRUE,SQL_FALSE))
				.Parameters.Append .CreateParameter("@HTTPVals", adVarChar, adParamInput, 500, g_strCacheHTTPVals)
				.Parameters.Append .CreateParameter("@PathToStart", adVarChar, adParamInput, 50, ps_strPathToStart)
				.CommandTimeout = 0
			End With
			Set rsCustField = Server.CreateObject("ADODB.Recordset")
			With rsCustField
				.CursorLocation = adUseClient
				.CursorType = adOpenStatic
				.Open cmdCustField
				ReDim aCustFields(.RecordCount-1)
				intCurFld = 0
				While Not .EOF
					Set aCustFields(intCurFld) = New FieldData
					Call aCustFields(intCurFld).setData(.Fields("FieldName"),.Fields("FieldSelect"),.Fields("FieldDisplay"))
					intCurFld = intCurFld + 1
					.MoveNext
				Wend
				.Close
			End With
			Set rsCustField = Nothing
			Set cmdCustField = Nothing
		End If
	End If

	If Not Nl(opt_fld_intCustOrderCIC) Then
		Set cmdCustField = Server.CreateObject("ADODB.Command")
		With cmdCustField
			.ActiveConnection = getCurrentCICBasicCnn()
			.CommandType = adCmdStoredProc
			.CommandText = "sp_CIC_View_CustomField_s"
			.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, opt_fld_intCustOrderCIC)
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
			.Parameters.Append .CreateParameter("@LoggedIn", adBoolean, adParamInput, 1, IIf(user_bLoggedIn,SQL_TRUE,SQL_FALSE))
			.CommandTimeout = 0
		End With
		Set rsCustField = Server.CreateObject("ADODB.Recordset")
		With rsCustField
			.CursorType = adOpenForwardOnly
			.Open cmdCustField
			If Not .EOF Then
				If .Fields("FormFieldType") = "d" Then
					strCustOrderSelect = "CAST(" & .Fields("FieldSelect") & " AS smalldatetime)"
				Else
					strCustOrderSelect = .Fields("FieldSelect")
				End If
			End If
			.Close
		End With
		Set rsCustField = Nothing
		Set cmdCustField = Nothing
	End If
End Sub

Private Sub getFacetFields()
	Dim cmdCustField, rsCustField
	
	If Not g_bPrintMode Then
			Set cmdCustField = Server.CreateObject("ADODB.Command")
			With cmdCustField
				.ActiveConnection = getCurrentCICBasicCnn()
				.CommandType = adCmdStoredProc
				.CommandText = "sp_CIC_View_FacetFields_l"
				.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
				.CommandTimeout = 0
			End With
			Set rsCustField = Server.CreateObject("ADODB.Recordset")
			With rsCustField
				.CursorLocation = adUseClient
				.CursorType = adOpenStatic
				.Open cmdCustField
				ReDim aFacetFields(.RecordCount-1)
				intCurFld = 0
				While Not .EOF
					Set aFacetFields(intCurFld) = New FacetFieldData
					Call aFacetFields(intCurFld).setData(.Fields("FieldName"),.Fields("FacetFieldList"),.Fields("FieldDisplay"),.Fields("FieldID"))
					intCurFld = intCurFld + 1
					.MoveNext
				Wend
				.Close
			End With
			Set rsCustField = Nothing
			Set cmdCustField = Nothing
	End If

End Sub

Private Function getOrderBy()
	Dim strOrderByDefault, strOrgLevel1Sort, strDesc, strResult
	
	If reEquals(ps_strThisPage,"browsebyorg.asp",True,False,True,False) Then
		Dim strChosenLetter
		strChosenLetter = Trim(Request("Let"))

		If Not reEquals(strChosenLetter,"([A-Z])|(0\-9)",True,False,True,False) Then
			strChosenLetter = vbNullString
			strOrgLevel1Sort = "ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1)"
		Else
			strOrgLevel1Sort = "CASE WHEN btd.SORT_AS_USELETTER IS NULL AND NOT LEFT(btd.SORT_AS,1)=LEFT(btd.ORG_LEVEL_1,1) AND btd.ORG_LEVEL_1 LIKE '" & strChosenLetter + "%' THEN btd.ORG_LEVEL_1 ELSE ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1) END"
		End If	
	Else
		strOrgLevel1Sort = "ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1)"
	End If

	strOrderByDefault = strOrgLevel1Sort & " [DESC]" & _
		",btd.ORG_LEVEL_2 [DESC]" & _
		",btd.ORG_LEVEL_3 [DESC]" & _
		",btd.ORG_LEVEL_4 [DESC]" & _
		",btd.ORG_LEVEL_5 [DESC]," & vbCrLf & _
		"	STUFF(" & vbCrLf & _
		"		CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)" & vbCrLf & _
		"			THEN NULL" & vbCrLf & _
		"			ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +" & vbCrLf & _
		"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +" & vbCrLf & _
		"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')" & vbCrLf & _
		"			 END," & vbCrLf & _
		"		1, 2, ''" & vbCrLf & _
		"	) [DESC], bt.NUM [DESC]"

	strDesc = StringIf(opt_bOrderByDescCIC, " DESC")

	strResult = vbNullString

	
	Select Case opt_intOrderByCIC
		Case OB_NUM
			strResult = "bt.NUM" & strDesc
		Case OB_UPDATE
			strResult = "CAST(btd.UPDATE_SCHEDULE AS smalldatetime)" & strDesc & "," & Replace(strOrderByDefault, "[DESC]", vbNullString)
		Case OB_CUSTOM 
			If Not Nl(strCustOrderSelect) Then
				strResult = strCustOrderSelect & strDesc & "," & Replace(strOrderByDefault, "[DESC]", vbNullString)
			Else
				strResult = Replace(strOrderByDefault, "[DESC]", strDesc)
			End If
		Case OB_RELEVANCY 
			Select Case intCanRank
				Case CAN_RANK_SIMPLE
					strResult = "kt.RANK" & StringIf(Not opt_bOrderByDescCIC," DESC") & "," & Replace(strOrderByDefault, "[DESC]", vbNullString)
				Case CAN_RANK_QUOTED
					strResult = "ktq.RANK" & StringIf(Not opt_bOrderByDescCIC," DESC") & "," & Replace(strOrderByDefault, "[DESC]", vbNullString)
				Case CAN_RANK_BOTH
					strResult = "ISNULL(kt.RANK,0) + ISNULL(ktq.RANK,0)" & StringIf(Not opt_bOrderByDescCIC," DESC") & "," & Replace(strOrderByDefault, "[DESC]", vbNullString)
				Case Else
					strResult = Replace(strOrderByDefault, "[DESC]", strDesc)
			End Select
		Case OB_LOCATION
			strResult = "btd.CMP_LocatedIn" & strDesc & "," & Replace(strOrderByDefault, "[DESC]", vbNullString)
		Case Else
			strResult = Replace(strOrderByDefault, "[DESC]", strDesc)
	End Select

	If bSortNearHome And Not Nl(decHomeLongitude) And Not Nl(decHomeLatitude) Then
		strResult = "CASE WHEN bt.GEOCODE_TYPE = 0 THEN 40076 ELSE cioc_shared.dbo.fn_SHR_GEO_CalculateDistance(bt.LONGITUDE, bt.LATITUDE, @NearLongitude, @NearLatitude) END" & strDesc & ", " & Replace(strOrderByDefault, "[DESC]", vbNullString)
	End If

	getOrderBy = strResult 
End Function

Public Sub makeTable()

Dim	strSQL, _
	strOrgName, _
	dUpdateSchedule, _
	strDetailLink, _
	strUpdateText, _
	strUpdateLink, _
	strPubLink, _
	strCatLink, _
	strMailLink, _
	strEmailLink, _
	strAlertColumn, _
	strSelectFields, _
	i, _
	strOrderBy

If Nl(strFromSQL) Then
	Exit Sub
End If

If Not Nl(intResultsPageSize) Then
	strSQL = "DECLARE @PageStart int; SET @PageStart=" & (intResultsPageSize * intResultsCurrentPage) & vbCrLf
Else
	strSQL = vbNullString
End If

strSQL = strSQL & "DECLARE @MemberID int; SET @MemberID=" & g_intMemberID & vbCrLf

strSelectFields = getFields(opt_bWebCIC)
strSQL = strSQL & strParamSQL & "SELECT bt.NUM FROM " & strFromSQL 
If Not Nl(strWhereSQL) Then
	strSQL = strSQL & vbCrLf & "WHERE (" & strWhereSQL & ")"
End If
strOrderBy = " ORDER BY " & getOrderBy()
strSQL = strSQL & strOrderBy


If Not Nl(intResultsPageSize) Then
	strSQL = strSQL & vbCrLf & "IF @@ROWCOUNT >= @PageStart BEGIN"
End If

strSQL = strSQL & vbCrLf & "SELECT " & strSelectFields & vbCrLf & "FROM " & strFromSQL & vbCrLf 
If Not Nl(strWhereSQL) Then
	strSQL = strSQL & vbCrLf & "WHERE (" & strWhereSQL & ")"
End If
strSQL = strSQL & strOrderBy

If Not Nl(intResultsPageSize) Then
	strSQL = strSQL & vbCrLf & "OFFSET " & (intResultsPageSize * intResultsCurrentPage) & " ROWS FETCH NEXT " & intResultsPageSize & " ROWS ONLY"
	strSQL = strSQL & vbCrLf & "END"
End If

'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
'Response.Flush()

Dim strSQLError, strErrorDetails
On Error Resume Next

cmdOrgList.CommandText = strSQL
rsOrgList.Open cmdOrgList

If Err.Number <> 0 Or cmdOrgList.ActiveConnection.Errors.Count > 0 Then
	With cmdOrgList
			strSQLError = Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED)
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

			If Nl(Request("Limit")) Then
				Call sendEmail(True, "qw4afPcItA5KJ18NH4nV@cioc.ca", "qw4afPcItA5KJ18NH4nV@cioc.ca", "CIC Search SQL Error", strErrorDetails & strSQL)
			End If
	End With
	Err.Clear
	 'Nz(Err.Description, TXT_UNKNOWN_ERROR_OCCURED), _
	Call handleError(TXT_SRCH_ERROR & strSQLError, _
		vbNullString, _
		vbNullString)
	Call makePageFooter(True)
	%>
	<!--#include file="../../includes/core/incClose.asp" -->
	<%
	Response.End
End If

Dim intTotalResultCount, intMaxPage, intLastPage, intNextPage, intPrevPage

On Error Goto 0

intTotalResultCount = rsOrgList.RecordCount
If Not Nl(intResultsPageSize) Then
	intLastPage = Int(intTotalResultCount / intResultsPageSize)
	If intResultsCurrentPage = intLastPage Then
		intNextPage = -1
	Else
		intNextPage = intResultsCurrentPage + 1
	End If
	If intResultsCurrentPage = 0 Then
		intPrevPage = -1
	Else
		intPrevPage = intResultsCurrentPage - 1
	End If
Else
	intLastPage = -1
	intNextPage = -1
	intPrevPage = -1
End If

If Not Nl(intResultsPageSize) Then
	If intLastPage < intResultsCurrentPage Then
		rsOrgList.Close

		Call handleError(TXT_SRCH_ERROR & strSQLError, _
			vbNullString, _
			vbNullString)
		Call makePageFooter(True)
		%>
		<!--#include file="../../includes/core/incClose.asp" -->
		<%
		Response.End
	End If
End If

Dim aIDList
Dim fldNUM

With rsOrgList

ReDim aIDList(.RecordCount-1)
i = 0
	
Set fldNUM = .Fields("NUM")

While Not .EOF
	aIDList(i) = fldNUM.Value
	i = i+1
	.MoveNext
Wend

End With


Set rsOrgList = rsOrgList.NextRecordset
'Response.Write(render_gtranslate_ui())

Dim strResultsMenuStart
strResultsMenuStart = "<p>[ "

%>
<script type="text/javascript">window.cioc_results_count=<%= intTotalResultCount %>;</script>
<%

If intTotalResultCount = 0 Then
	Dim strSearchNoResultMessage
	strSearchNoResultMessage = get_view_data_cic("NoResultsMsg")
	If Nl(strSearchNoResultMessage) Then
		strSearchNoResultMessage = TXT_NO_MATCH
	End If
	Call handleMessage(strSearchNoResultMessage,vbNullString,vbNullString,False)
	If user_bCIC And g_bUseCIC _
		And user_intSavedSearchQuota > 0 _
		And Not g_bPrintMode _
		And reEquals(ps_strThisPage,".?results.asp",True,False,True,False) _
		And (Len(strSaveSQL) < 10000) _
		And Not Nl(strSaveSQL) _
		And Nl(Request("SRCHID")) Then
%>
<p>[ <% If bEnableListViewMode And Not g_bEnableListModeCT Then %><a class="NoLineLink SimulateLink" id="remove_all_from_list"><img src="<%= ps_strPathToStart %>images/listremove.gif" width="17" height="17" border="0"> <%= TXT_LIST_REMOVE_ALL %></a> |<% End If %>
<a class="NoLineLink" href="<%=makeLink(ps_strPathToStart & "savedsearch_edit.asp","WhereClause=" & Server.URLEncode(strSaveSQL) & "&InclDel=" & IIf(bInclDeleted,"on",vbNullString) & "&Notes=" & strSaveNotes,vbNullString)%>"><img border="0" src="images/folder.gif">&nbsp;<%=TXT_SAVE_THIS_SEARCH%></a> ]</p>
<%
	End If
Else

	If bCanRefineSearch And Not Nl(strSaveSQL) Then
		strRecentSearchKey = recentSearchStore(ps_intDbArea, strSaveSQL, strSearchInfoRefineNotes, DateTimeString(Now(),True), g_strViewNameCIC, g_intViewTypeCIC, g_objCurrentLang.LanguageAlias, intTotalResultCount)
	End If

	If bEnableListViewMode Then
	%><div id="records_ui"><%
	End If
	If Not g_bPrintMode Then
		If Not bEnableListViewMode Then
%>
<div class="clearfix"><div class="browse-by-list">
<% If Not Nl(intResultsPageSize) And (intPrevPage <> -1 Or intNextPage <> -1) Then
	Dim strPageLinkTemplate
	strPageLinkTemplate = results_page_link()
	%>
	<%= TXT_SHOWING_RECORDS %>  <%= (intResultsCurrentPage * intResultsPageSize) + 1 %> <%= TXT_TO %> <%= Min((intResultsCurrentPage + 1) * intResultsPageSize, intTotalResultCount) %> <%= TXT_OF %> <strong><a href="<%= strPageLinkTemplate %>all"><%= intTotalResultCount %></a></strong> <%=TXT_RECORDS_MATCH%>
	<br><br><b><%= TXT_MORE_RESULTS %></b>
	<% If intPrevPage <> -1 Then %>
		<span style="white-space: nowrap"><a class="NoLineLink" href="<%= strPageLinkTemplate %>0"><img src="<%= ps_strPathToStart %>images/first.gif" border="0">&nbsp;<%= TXT_FIRST %></a></span>
		<span style="white-space: nowrap"><a class="NoLineLink" href="<%= strPageLinkTemplate & intPrevPage %>"><img src="<%= ps_strPathToStart %>images/previous.gif" border="0">&nbsp;<%= TXT_PREVIOUS %></a></span>
		<% If intNextPage <> -1 Then %> | <% End If %>
	<% End If %>
	<% If intNextPage <> -1 Then %>
		<span class="NoWrap"><a class="NoLineLink" href="<%= strPageLinkTemplate & intNextPage %>"><%= TXT_NEXT %>&nbsp;<img src="<%= ps_strPathToStart %>images/next.gif" aria-hidden="true" border="0"></a></span>
		<span class="NoWrap"><a class="NoLineLink" href="<%= strPageLinkTemplate & intLastPage %>"><%= TXT_LAST %>&nbsp;<img src="<%= ps_strPathToStart %>images/last.gif" aria-hidden="true" border="0"></a></span>	
	<% End If %>
	<br><br>
<% ElseIf Not Request("NoCount")="on" Then %>
<%=TXT_THERE_ARE%> <strong><%= intTotalResultCount %></strong> <%=TXT_RECORDS_MATCH%>
<br><br>
<% End If %>
<%If opt_fld_bOrgCIC And Not opt_fld_bNUM Then%><%=Nz(get_view_data_cic("ClickToViewDetails"), TXT_CLICK_ON & TXT_ORG_NAME & TXT_VIEW_FULL)%><%Else%><%=TXT_CLICK_ON%><%=TXT_RECORD_NUM%><%=TXT_VIEW_FULL%><%End If%>
</div></div>
<%	
		ElseIf Not g_bEnableListModeCT Then
		%>
		<%=strResultsMenuStart%><a class="NoLineLink SimulateLink" id="remove_all_from_list"><img src="<%= ps_strPathToStart %>images/listremove.gif" width="17" height="17" border="0"> <%= TXT_LIST_REMOVE_ALL %></a>
		<%
		strResultsMenuStart = " | "
		End If
		If user_bCIC Then
%>
<%=strResultsMenuStart%><a class="NoLineLink" href="javascript:openWin('<%=makeLink(ps_strPathToStart & "display_options.asp",vbNullString,vbNullString)%>');"><img border="0" src="images/edit.gif">&nbsp;<%=TXT_CHANGE_DISPLAY%></a>
<%
			strResultsMenuStart = " | "
			If g_bUseCIC _
				And reEquals(ps_strThisPage,".?results.asp",True,False,True,False) _
				And ps_strThisPage <> "presults.asp" _
				And user_intSavedSearchQuota > 0 _
				And (Len(strSaveSQL) < 10000) _
				And Not Nl(strSaveSQL) _
				And Nl(Request("SRCHID")) Then
%>
<%=strResultsMenuStart%><a class="NoLineLink" href="<%=makeLink(ps_strPathToStart & "savedsearch_edit.asp","WhereClause=" & Server.URLEncode(strSaveSQL) & "&InclDel=" & IIf(bInclDeleted,"on",vbNullString) & "&Notes=" & strSaveNotes,vbNullString)%>"><img border="0" src="images/folder.gif">&nbsp;<%=TXT_SAVE_THIS_SEARCH%></a>
<%
			End If
			If g_bUseCIC And Not Nl(strRecentSearchKey) And Not Request("NoRefine")="on" Then
%>
<%=strResultsMenuStart%><a class="NoLineLink" href="<%=makeLink(ps_strPathToStart & "advsrch.asp","RS=" & Server.URLEncode(strRecentSearchKey),vbNullString)%>"><img border="0" src="images/zoom.gif">&nbsp;<%=TXT_REFINE_SEARCH%></a>
<%
			End If
%>
<span id="show_eubjects_display" class="NotVisible"><%=strResultsMenuStart%><a id="show_subjects" class="NoLineLink"><%=TXT_SHOW_SUBJECTS%></a></span>
<%
		End If 'User is CIC
	
		If g_bPrintVersionResultsCIC And (user_bLoggedIn Or g_bPrintModePublic) And Not Nl(g_intPrintDesignCIC) Then
			If reEquals(ps_strThisPage,".?results.asp",True,False,True,False) Then
%>
<%=strResultsMenuStart%><a class="NoLineLink" href="<%=ps_strThisPage & "?" & IIf(Nl(strQueryString),vbNullString,strQueryString & "&")%>PrintMd=on" target="_BLANK"><img border="0" src="images/printer.gif">&nbsp;<%=TXT_PRINT_VERSION%></a>
<%
				strResultsMenuStart = " | "
			ElseIf reEquals(ps_strThisPage,"browsebyorg.asp",True,False,True,False) Then
%>
<%=strResultsMenuStart%><a class="NoLineLink" href="<%=makeLink(ps_strThisPage,"PrintMd=on&Let=" & strChosenLetter,vbNullString)%>" target="_BLANK"><img border="0" src="images/printer.gif">&nbsp;<%=TXT_PRINT_VERSION%></a>
<%
				strResultsMenuStart = " | "
			ElseIf reEquals(ps_strThisPage,"processRecordList.asp",True,False,True,False) Then
%>
<%=strResultsMenuStart%><a class="NoLineLink" href="<%=makeLink(ps_strThisPage,"PrintMd=on&ActionType=N&IDList=" & strIDList,vbNullString)%>" target="_BLANK"><img border="0" src="images/printer.gif">&nbsp;<%=TXT_PRINT_VERSION%></a>	
<%
				strResultsMenuStart = " | "
			End If 'Print Version link type test
		End If 'Print Version Link test
			
		If bEnableListViewMode Then
			Dim strRecordListIDs, intDefaultPrintProfile
			strRecordListIDs = getSessionValue(ps_strDbArea & "RecordList")
			intDefaultPrintProfile = get_default_print_profile()
			If Not Nl(strRecordListIDs) And Not Nl(intDefaultPrintProfile) Then

		%>
<%=strResultsMenuStart%><a class="NoLineLink" href="<%= makeLink("printlist2.asp", "IDList=" & strRecordListIDs & "&ProfileID=" & intDefaultPrintProfile, vbNullString) %>" target="_BLANK"><img border="0" src="images/printer.gif">&nbsp;<%=TXT_PRINT_RECORD_DETAILS %></a>
		<%
			strResultsMenuStart = " | "
			End If
		End If
		If g_bUseCIC And g_bMapSearchResults Then
%>
<span id="map_my_results_ui" style="display: none;"><%=strResultsMenuStart%><a class="NoLineLink" href="#/SHOWMAP" id="map_my_results"><img border="0" area-hidden="true" src="images/globe.gif"> <%=TXT_MAP_RESULTS%></a><%If strResultsMenuStart <> " | " Then%> ]</p><%End If%></span>
<%
		End If 'Map Search results test
		If strResultsMenuStart = " | " Then
%>
]</p>
<%
		End If
	End If 'Not in Print Mode

	If user_bCIC And opt_bSelectCIC And Not g_bPrintMode Then
%>
<form name="RecordList" action="<%=ps_strPathToStart%>processRecordList.asp" method="post">
<%=g_strCacheFormVals%>
<hr>
<div class="form-horizontal form-group row">
	<label for="SearchResultActionList" class="control-label col-xs-12 col-sm-4 col-md-3 col-lg-2"><%=TXT_ACTION_ON_SELECTED%></label>
	<div class="col-xs-10 col-sm-6 col-md-8 col-lg-9">
	<select name="ActionType" class="form-control" id="SearchResultActionList">
	<option value="N"><%=TXT_SLCT_NEW_RESULTS%></option>
	<option value="AR"><%=TXT_SLCT_NEW_REMINDER%></option>
	<option value="EL"><%=TXT_SLCT_EMAIL_RECORD_LIST%></option>
	<optgroup label="<%=TXT_SLCT_STATS_AND_REPORTING%>">
		<option value="P"><%=TXT_SLCT_PRINT%></option>
<%	
	If hasGoogleMapsAPI() Then %>
		<option value="PM"><%=TXT_SLCT_PRINT_MAP%></option>
<%
	End If
	If user_intCanViewStatsCIC > STATS_NONE Then
%>
	<option value="G"><%=TXT_SLCT_STATS%></option>
<%
	End If
%>
	</optgroup>
<%
	If user_bCanDoBulkOpsCIC Or (user_intCanUpdatePubs <> UPDATE_NONE And (user_bCanDoBulkOpsCIC Or user_bLimitedViewCIC)) Then
%>
	<optgroup label="<%=TXT_SLCT_DATA_MANAGEMENT%>">
<%
		If user_bCanRequestUpdateCIC And Not g_bNoEmail Then
%>
	<option value="U"><%=TXT_SLCT_EMAIL_UPDATE%></option>
<%	
		End If
		If user_bCanDoBulkOpsCIC Then
%>
		<option value="NP"><%=TXT_SLCT_PUBLIC_NONPUBLIC%></option>
<%
			If user_bCanDeleteRecordCIC Then
%>
		<option value="R"><%=TXT_SLCT_DELETE_RESTORE%></option>
<%
			End If
			If user_bSuperUserCIC Then
%>
		<option value="AO"><%=TXT_SLCT_AGENCY%></option>
<%
			End If 
%>
		<option value="RO"><%=TXT_SLCT_CHANGE_OWNER%></option>
		<option value="DST"><%=TXT_SLCT_DISTRIBUTION%></option>
<%
		End If
		If user_intCanUpdatePubs <> UPDATE_NONE And (user_bCanDoBulkOpsCIC Or user_bLimitedViewCIC) Then
%>
		<option value="GH"><%=TXT_SLCT_HEADING%></option>
<%
		End If
		If user_bCanDoBulkOpsCIC Then
%>
		<option value="NC"><%=TXT_SLCT_NAICS%></option>
		<option value="PB"><%=TXT_SLCT_PUBLICATION%></option>
<%
			If g_bUseThesaurusView Then
%>
		<option value="SBJ"><%=TXT_SLCT_SUBJECT%></option>
<%
			End If
			If g_bUseTaxonomyView Then
%>
		<option value="TX"><%=TXT_SLCT_TAXONOMY%></option>
<%
			End If
			If user_bSuperUserCIC Then
%>
		<option value="F"><%=TXT_SLCT_FIND_REPLACE%></option>
<%	
			End If
			If hasGoogleMapsAPI() Then
%>
		<option value="GE"><%=TXT_SLCT_GEOCODE%></option>
<%
			End If
		End If
%>
	</optgroup>
<%
	End If
	If (user_bSuperUserCIC And g_bOtherMembers) Or user_intExportPermissionCIC <> EXPORT_NONE Then
%>
	<optgroup label="<%=TXT_SLCT_DATA_SHARING%>">
<%
		If user_intExportPermissionCIC <> EXPORT_NONE Then
%>
		<option value="E"><%=TXT_SLCT_EXPORT%></option>
<%
		End If
		If user_bSuperUserCIC And g_bOtherMembers Then
%>
		<option value="SP"><%= TXT_SLCT_SHARING_PROFILE %></option>
<%
		End If
%>
	</optgroup>
<%
	End If
%>
</select>
</div>
	<div class="col-xs-2 col-sm-2 col-md-1 col-lg-1">
		<input type="submit" value="<%=TXT_SUBMIT%>" class="btn btn-default">
	</div>
</div>
<div class="form-group row">
	<div class="hidden-xs col-sm-4 col-md-3 col-lg-2"></div>
	<div class="col-xs-12 col-sm-8 col-md-9 col-lg-10">
	<input type="button" class="btn btn-default" onClick="CheckAll();" value="<%=TXT_CHECK_ALL%>">
	<input type="button" class="btn btn-default" onClick="ClearAll();" value="<%=TXT_UNCHECK_ALL%>"> 
<%
		If g_bMapSearchResults Then
%>
	<input type="button" class="btn btn-default" onClick="do_check_all_in_viewport();" class="NotVisible" id="check_all_in_viewport" value="<%=TXT_CHECK_IN_VIEWPORT%>">
<%
		End If
%>
	</div>
</div>
<%
	End If 'Select Checkbox

	If Not Nl(decHomeLatitude) And Not g_bPrintMode Then
%>
<div class="NotVisible">
<input type="hidden" name="GeoLocatedNearLatitude" id="geo_latitude" value="<%=decHomeLatitude%>">
<input type="hidden" name="GeoLocatedNearLongitude" id="geo_longitude" value="<%=decHomeLongitude%>">
<input type="hidden" name="GeoLocatedNearSort" value="<%=StringIf(bSortNearHome,"on")%>">
</div>
<%
	End If 'Hidden mapping fields
	If Not g_bPrintMode Then

'begin building the org table
'start with the table header
	i = 2
%>
<style type="text/css">
<% If opt_bDispTableCIC Then %>
	@media screen and (max-width: 1023px)  {
<% End If %>

<%
	If g_bMapSearchResults And Not g_bPrintMode Then
%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: ""; }
<% i= i + 1
	End If
	If opt_bSelectCIC Then
%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_SELECT%>"; }
<% i= i + 1
	End If
	If opt_fld_bAlertCIC Then
%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: ""; }
<% i= i + 1
	End If
	If opt_fld_bNUM Or Not opt_fld_bOrgCIC Then
%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_RECORD_NUM%>"; }
<% i= i + 1
	End If
	If opt_fld_bOrgCIC Then
%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=IIf(Not Nl(get_view_data_cic("OrgProgramNames")), clean_html_for_label(get_view_data_cic("OrgProgramNames")), TXT_ORG_NAMES)%>"; }
<% i= i + 1
	End If
	If opt_fld_bRecordOwnerCIC Then
%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_OWNER%>"; }
<% i= i + 1
	End If
	If opt_fld_bLocated Then
%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_LOCATED_IN%>"; }
<% i= i + 1
	End If
	If IsArray(aCustFields) Then
		For Each indOrgFldData In aCustFields%>
	.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=clean_html_for_label(indOrgFldData.fLabel)%>"; }
<% i= i + 1
		Next
	End If
	If opt_fld_bUpdateScheduleCIC Then
%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_UPDATE_SCHEDULE%>"; }
<% i= i + 1
	End If
	If opt_bUpdateCIC Then
%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_UPDATE_FEEDBACK%>"; }
<% i= i + 1
	End If
	If ps_intDbArea=DM_CIC And opt_bPub Then
%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_UPDATE_PUBS%>"; }
<% i= i + 1
	End If
	If (opt_bMail Or opt_bEmailCIC) And user_bCanRequestUpdateCIC Then
	i= i + 1
	If opt_bMail And opt_bEmailCIC Then
		i = i + 1
	End If
%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=TXT_REQUEST_UPDATE%>"; }
<% i= i + 1
	End If
	If Not g_bPrintMode And (opt_bListAddRecordCIC Or bEnableListViewMode) Then
		%>.ResponsiveResults td:nth-of-type(<%=i%>):before { content: "<%=IIf(g_bEnableListModeCT, TXT_CT_CLIENT_TRACKER,TXT_MY_LIST)%>"; }
		<% i= i + 1
	End If
%>
<% If opt_bDispTableCIC Then %>
}
<% End If %>
</style>
<% End If %>
<% If Not g_bPrintMode Then %><%If Not opt_bDispTableCIC Then %><div class="CompactResults"><%End If %>
<% If IsArray(aFacetFields) Then %>
<div id="search-facet-selectors" style="display:none">
<% 
	Dim cmdFacetLists, rsFacetLists, aFacetLists
	Set cmdFacetLists = Server.CreateObject("ADODB.Command")
	With cmdFacetLists
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_CIC_View_FacetFields_l_SearchValues"
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.CommandTimeout = 0
	End With
	Set rsFacetLists = Server.CreateObject("ADODB.Recordset")
	With rsFacetLists
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdFacetLists

	End With
%>
<div class="panel panel-default">
<div class="panel-heading">
<h3 class="panel-title"><a href="#facet-filtersearch" data-toggle="collapse"><span class="glyphicon glyphicon-filter" aria-hidden="true"></span> Filter Search Results<span class="caret"></span></a></h3>
</div>
<div id="facet-filtersearch" class="panel-body panel-collapse collapse">
	<div class="form-horizontal">
<%
	For Each indOrgFldData In aFacetFields
%>
		<div class="form-group row">
		<label for="facet-<%=indOrgFldData.fFieldID%>" class="control-label col-xs-12 col-sm-3 col-lg-2"><%= indOrgFldData.fLabel %></label>
		<div class="col-xs-9 col-sm-7 col-lg-9">
			<select class="facet-selector form-control" id="facet-<%=indOrgFldData.fFieldID%>" data-facet="<%= indOrgFldData.fFieldID %>">
				<option selected value=""></option>
<%
		Set rsFacetLists = rsFacetLists.NextRecordset
		With rsFacetLists
			While Not .EOF
%>
				<option value="<%=.Fields("Facet_ID")%>"><%=Server.HTMLEncode(.Fields("Facet_Value"))%></option>
<%
				.MoveNext
			Wend
		End With
%>
			</select>
		</div>
		<div class="col-xs-3 col-sm-2 col-lg-1">
			<input type="button" class="btn btn-default" value="<%=TXT_RESET%>"
				onClick="$('#facet-<%=indOrgFldData.fFieldID%>').val('').trigger('change');"/>
		</div>
		</div>
<%
	Next
	rsFacetLists.Close
	Set cmdFacetLists = Nothing
	Set rsFacetLists = Nothing
%>
	</div>
</div>
</div>
</div><%End If %>
<% End If %>
<table class="BasicBorder cell-padding-3 HideListUI HideMapColumn <% If Not g_bPrintMode Then %>ResponsiveResults <%If Not opt_bDispTableCIC Then %>CompactResults<%End If %><% End If %>" id="results_table">
<thead>
<tr class="RevTitleBox">
<% If not g_bPrintMode Then %><th class="MobileShowField"></th><% End If %>
<%If g_bMapSearchResults And Not g_bPrintMode Then%><th class="MapColumn MobileHideField">&nbsp;</th><%End If%>
<%If opt_bSelectCIC Then%><th class="">&nbsp;</th><%End If%>
<%If opt_fld_bAlertCIC Then%><th width="5" class="MobileHideField">&nbsp;</th><%End If%>
<%If opt_fld_bNUM Or Not opt_fld_bOrgCIC Then%><th><%=TXT_RECORD_NUM%></th><%End If%>
<%If opt_fld_bOrgCIC Then%><th><%=Nz(get_view_data_cic("OrgProgramNames"), TXT_ORG_NAMES)%></th><%End If%>
<%If opt_fld_bRecordOwnerCIC Then%><th><%=TXT_OWNER%></th><%End If%>
<%If opt_fld_bLocated Then%><th><%=TXT_LOCATED_IN%></th><%End If%>
<%If IsArray(aCustFields) Then
	For Each indOrgFldData In aCustFields%>
<th><%=indOrgFldData.fLabel%></th>
<%	Next
End If%>
<%If opt_fld_bUpdateScheduleCIC Then%><th><%=TXT_UPDATE_SCHEDULE%></th><%End If%>
<%If opt_bUpdateCIC Then%><th><%=TXT_UPDATE_FEEDBACK%></th><%End If%>
<%If ps_intDbArea=DM_CIC And opt_bPub Then%><th><%=TXT_UPDATE_PUBS%></th><%End If%>
<%If (opt_bMail Or opt_bEmailCIC) And user_bCanRequestUpdateCIC Then%><th class="MobileHideField"<%If opt_bMail And opt_bEmailCIC Then%> colspan="2"<%End If%>><%=TXT_REQUEST_UPDATE%></th>
<th class="MobileShowFieldNormal"></th>
<%End If%>

<%If Not g_bPrintMode And (opt_bListAddRecordCIC Or bEnableListViewMode) Then Call myListResultsAddRecordHeader() End If%>
</tr>
</thead>
<%

Dim strNUMLink, _
	strNUMNumberLink, _
	bBot

If reEquals(Request.ServerVariables("HTTP_USER_AGENT"),"(googlebot)|(crawler)|(spider)|(robot)",True,False,False,False) Then
	bBot = True
End If

i = 0

Dim fldOrgName, _
	fldLocatedIn, _
	fldLatitude, _
	fldLongitude, _
	fldMapPinID
	

With rsOrgList

If .RecordCount > 10000 Then
	' If we have a lot of records, let the script timout be 10 minutes
	' This is actually driven by end browser render time, not how long
	' it takes to generate the page.
	Server.ScriptTimeout = 600
End If


Set fldNUM = .Fields("NUM")

If opt_fld_bOrgCIC Or (g_bMapSearchResults And Not g_bPrintMode) Then
	Set fldOrgName = .Fields("ORG_NAME_FULL")
End If

If opt_fld_bLocated Then
	Set fldLocatedIn = .Fields("LOCATED_IN")
End If

If g_bMapSearchResults And Not g_bPrintMode Then
	Set fldLatitude = .Fields("LATITUDE")
	Set fldLongitude = .Fields("LONGITUDE")
	Set fldMapPinID = .Fields("MAP_PIN")
End If

Dim strRecordListUI
strRecordListUI = vbNullString

If Not g_bPrintMode And (opt_bListAddRecordCIC Or bEnableListViewMode) Then 
	strRecordListUI = myListResultsAddRecord("[IDID]", bEnableListViewMode, "<td class=""ListUI"">", "</td>") 
End If

Dim bCheckVolOps, bCheckFeedback
bCheckVolOps = CBool(ps_intDbArea = DM_CIC And g_bUseVOL And g_bVolunteerLink)
bCheckFeedback = CBool(Nz(user_bFeedbackAlertCIC, False))

Dim strDetailLinkTemplate
strDetailLinkTemplate = "<a" & StringIf(g_bMapSearchResults And Not g_bPrintMode," class=""DetailsLink"" data-num=""[NUMNUM]"" id=""details_link_[NUMNUM]""") & " href=""" & _
		makeDetailsLink("[NUMNUM]", StringIf(Not bBot, "Number=[NUMBERNUMBER]"), vbNullString) & _
		""">"

%><tbody><%

While Not .EOF
	If opt_fld_bOrgCIC Then
		strOrgName = fldOrgName.Value
	End If
	strNUMLink = "NUM=" & fldNUM.Value

	If Not bBot Then
		strNUMNumberLink = strNUMLink & "&Number=" & i
	Else
		strNUMNumberLink = strNUMLink
	End If

	strEmailLink = "&nbsp;"
	
	strDetailLink = Replace(Replace(strDetailLinkTemplate, "[NUMNUM]", fldNUM), _
						"[NUMBERNUMBER]", Cstr(i))

	If ps_intDbArea=DM_CIC And opt_bPub And (user_intCanUpdatePubs <> UPDATE_NONE) Then
		strPubLink = "<a href=""" & _
			makeLink(ps_strPathToStart & "update_pubs.asp",strNUMNumberLink,vbNullString) & _
			""">" & TXT_UPDATE_PUBS & "</a>"
	End If
	If opt_bMail Then
		strMailLink = "<a href=""" & _
			makeLink(ps_strPathToStart & "mailform.asp",strNUMNumberLink & "&PrintMd=on",vbNullString) & _
			""" target=""_BLANK"">" & TXT_MAIL_FORM & "</a>"
	End If
	If opt_bEmailCIC And (user_bCanRequestUpdateCIC) And Not g_bNoEmail Then
		If .Fields("CAN_EMAIL") Then
			strEmailLink = "<a href=""" & _
				makeLinkAdmin("email_prep.asp","IDList=" & fldNUM.Value & "&Number=" & i & "&DM=" & ps_intDbArea) & _
				""">" & TXT_EMAIL & "</a>"
		Else
			strEmailLink = "&nbsp;"
		End If
	End If
	
	dUpdateSchedule = Null
	If opt_fld_bUpdateScheduleCIC Or opt_bUpdateCIC Then
		If Not Nl(.Fields("UPDATE_SCHEDULE")) Then
			dUpdateSchedule = DateValue(.Fields("UPDATE_SCHEDULE"))
		End If
	End If

	If opt_bUpdateCIC Then
		strUpdateText = IIf(.Fields("CAN_UPDATE") = 1,TXT_UPDATE,TXT_FEEDBACK)
		strUpdateLink = "<a href=""" & _
			makeLink(ps_strPathToStart & IIf(.Fields("CAN_UPDATE") = 1,"entryform.asp","feedback.asp"),strNUMNumberLink,vbNullString) & """"
		If Not opt_fld_bUpdateScheduleCIC And (Now() > dUpdateSchedule Or Nl(dUpdateSchedule)) Then
			strUpdateLink = strUpdateLink & " class=""Alert"""
		End If
		strUpdateLink = strUpdateLink & ">"
	End If
	i = i + 1
	strAlertColumn = vbNullString
	If opt_fld_bAlertCIC Then
		If .Fields("IS_SHARED") Then
			strAlertColumn = "S"
		End If
		If .Fields("IS_DELETED") Then
			strAlertColumn = strAlertColumn & "X"
		ElseIf .Fields("TO_BE_DELETED") Then
			strAlertColumn = strAlertColumn & "P"
		End If
		If .Fields("HAS_COMMENTS") And user_bCommentAlertCIC Then
			strAlertColumn = strAlertColumn & "C"
		End If
		If bCheckFeedback Then
			If .Fields("HAS_FEEDBACK") Or .Fields("HAS_PUB_FEEDBACK") Then
				strAlertColumn = strAlertColumn & "F"
			End If
		End If
		If bCheckVolOps Then
			If .Fields("HAS_VOL_OPPS") Then
				strAlertColumn = strAlertColumn & "V"
			End If
		End If
		If Nl(strAlertColumn) Then
			strAlertColumn = "&nbsp;"
		Else
			strAlertColumn = "<span style=""font-weight:bold"">" & strAlertColumn & "</span>"
		End If
	End If
%>
<tr valign="top" <% 
If IsArray(aFacetFields) Then %>data-facets="{<%
	Dim strFacetCon
	strFacetCon = vbNullString
	For Each indOrgFldData In aFacetFields
		If Not Nl(indOrgFldData.fSelect) Then %><%= strFacetCon %>&quot;<%= indOrgFldData.fFieldID %>&quot;:[<%= Server.HTMLEncode(Ns(.Fields("FacetField" & indOrgFldData.fFieldID))) %>]<%
		strFacetCon = ","
		End If
	Next
%>}"<% End If %> >
<% If Not g_bPrintMode Then %>
<td class="MobileShowField">
<h3>
<%If g_bMapSearchResults And Not g_bPrintMode And Not Nl(fldLatitude) And Not Nl(fldLongitude) Then%><span id="map_column_mobile_<%=fldNUM.Value%>" class="MapColumnMobile MobileMiniColumnSpan"><%If Nl(fldLatitude) Or Nl(fldLongitude) Then%>&nbsp;<%Else%><a class="MapLinkMobile" id="map_link_mobile_<%=fldNUM.Value%>" href="javascript:void(0);" data-num="<%= fldNUM.Value %>" data-info="{<%=Server.HTMLEncode(JSONQs("num", True))%>: <%= Server.HTMLEncode(JSONQs(fldNUM.Value, True)) %>}"><img id="map_marker_icon_mobile_<%=fldNUM.Value%>" src="images/mapping/mm_0_white_20.png" border="0" align="absbottom" alt="<%=TXT_MAP_RECORD%>"></a><%End If%></span><%End If%>
<% 'If opt_bSelectCIC Then% ><span class="MobileMiniColumnSpan"><input type="checkbox" name="IDList" value="<%=fldNUM.Value% >" id="IDList_<%=fldNUM.Value% >"></span><%End If %>
<%If opt_fld_bAlertCIC Then%><%If (.Fields("NON_PUBLIC") Or strAlertColumn <> "&nbsp;") Then%><span class="MobileMiniColumnSpan MobileAlertColumnBubble"><%If .Fields("NON_PUBLIC") Then %><span class="Alert">N</span><%End If %><%=Replace(strAlertColumn, "&nbsp;", "")%></span><%End If%><%End If%>

<%If not opt_fld_bOrgCIC Then %>
<%If Not g_bPrintMode Then%><%=strDetailLink%><%End If%><%=fldNUM.Value%><%If Not g_bPrintMode Then%></a><%End If%>
<%Else%>
<%If Not g_bPrintMode Then%><%=strDetailLink%><%End If%><%=strOrgName%><%If Not g_bPrintMode Then%></a><%End If%>
<%End If %>

</h3>
</td>
<% End If %>
<%If g_bMapSearchResults And Not g_bPrintMode Then%><td id="map_column_<%=fldNUM.Value%>" class="MapColumn MobileHideField"><%If Nl(fldLatitude) Or Nl(fldLongitude) Then%>&nbsp;<%Else%><a class="MapLink" id="map_link_<%=fldNUM.Value%>" href="javascript:void(0);" data-num="<%= fldNUM.Value %>" data-info="{<%=Server.HTMLEncode(JSONQs("num", True))%>: <%= Server.HTMLEncode(JSONQs(fldNUM.Value, True)) %>, <%= Server.HTMLEncode(JSONQs("latitude", True))%>: <%= Server.HTMLEncode(JSONQs(fldLatitude.Value, True)) %>, <%= Server.HTMLEncode(JSONQs("longitude", True)) %>: <%= Server.HTMLEncode(JSONQs(fldLongitude, True)) %>, <%=Server.HTMLEncode(JSONQs("mappin", True))%>: <%=fldMapPinID%>, <%= Server.HTMLEncode(JSONQs("orgname", True))%>: <%=Server.HTMLEncode(JSONQs(Nz(strOrgName, fldNUM.Value), True))%>}"><img id="map_marker_icon_<%=fldNUM.Value%>" src="images/mapping/mm_0_white_20.png" border="0" align="absbottom" alt="<%=TXT_MAP_RECORD%>"></a><%End If%></td><%End If%>
<%If opt_bSelectCIC Then%><td><input type="checkbox" name="IDList" title=<%=AttrQs(TXT_SELECT & TXT_COLON & fldNUM.Value)%> value="<%=fldNUM.Value%>" id="IDList_<%=fldNUM.Value%>"></td><%End If%>
<%If opt_fld_bAlertCIC Then%><td class="MobileHideField<%If .Fields("NON_PUBLIC") Then%> AlertBox<%End If%>"><%=strAlertColumn%></td><%End If%>
<%If opt_fld_bNUM Or Not opt_fld_bOrgCIC Then%><td <% If Not opt_fld_bOrgCIC Then%>class="MobileHideField"<%End If%>><%If Not g_bPrintMode Then%><%=strDetailLink%><%End If%><%=fldNUM.Value%><%If Not g_bPrintMode Then%></a><%End If%></td><%End If%>
<%If opt_fld_bOrgCIC Then%><td class="MobileHideField"><%If Not opt_fld_bNUM And Not g_bPrintMode Then%><%=strDetailLink%><%End If%><%=strOrgName%><%If Not opt_fld_bNUM And Not g_bPrintMode Then%></a><%End If%></td><%End If%>
<%If opt_fld_bRecordOwnerCIC Then%><td><%=.Fields("RECORD_OWNER")%></td><%End If%>
<%If opt_fld_bLocated Then%><td <%=StringIf(Nl(fldLocatedIn.Value), "class=""MobileHideField""")%>><%If Not Nl(fldLocatedIn.Value) Then%><%=fldLocatedIn.Value%><%Else%>&nbsp;<%End If%></td><%End If%>
<%If IsArray(aCustFields) Then
	For Each indOrgFldData In aCustFields%>
<td <%If Nl(.Fields(indOrgFldData.fName)) Then %>class="MobileHideField"<%End If%>><%If Not Nl(.Fields(indOrgFldData.fName)) Then%><%=textToHTML(.Fields(indOrgFldData.fName))%><%Else%>&nbsp;<%End If%></td>
<%	Next
End If%>
<%If opt_fld_bUpdateScheduleCIC Then%><td><%If Now() > dUpdateSchedule Or Nl(dUpdateSchedule) Then%><span class="Alert"><%End If%><%=IIf(Nl(dUpdateSchedule),TXT_UNKNOWN,.Fields("UPDATE_SCHEDULE"))%><%If Now() > dUpdateSchedule Or Nl(dUpdateSchedule) Then%></span><%End If%></td><%End If%>
<%If opt_bUpdateCIC Then%><td><%=strUpdateLink%><%=strUpdateText%></a></td><%End If%>
<%If ps_intDbArea=DM_CIC And opt_bPub Then%><td><%=strPubLink%></td><%End If%>
<%If opt_bMail Then%><td class="MobileHideField"><%=strMailLink%></td><%End If%>
<%If opt_bEmailCIC And user_bCanRequestUpdateCIC Then%><td class="MobileHideField"><%=strEMailLink%></td><%End If%>
<%If opt_bMail Or (opt_bEmailCIC And user_bCanRequestUpdateCIC) Then%><td class="<%If Not opt_bMail And strEmailLink = "&nbsp;" Then%>MobileHideField <%End If%>MobileShowFieldNormal">
<%If opt_bMail Then%><%=strMailLink%><%End If%><%If opt_bEmailCIC And user_bCanRequestUpdateCIC Then%><%If opt_bMail And strEmailLink <> "&nbsp;" Then%> | <%End If%><%=strEMailLink%><%End If%>
</td><%End If%>
<% Response.Write(Replace(strRecordListUI, "[IDID]", fldNUM.Value)) %>
</tr>
<%
	.MoveNext
	If i Mod 500 = 0 Then
		Response.Flush
	End If
Wend

If Not bBot Then
	Call setSessionValue("aNUMSearchList", Join(aIDList,","))
End If
%>
</tbody>
</table>
<% If Not g_bPrintMode Then %><%If Not opt_bDispTableCIC Then %></div><%End If %><% End If %>
<%
If opt_bSelectCIC Then
%>
</form>
<%
End If

	If bEnableListViewMode Then
	%></div><%
	End If

End With

End If 'Not .EOF
	
rsOrgList.Close


End Sub

Public Sub makeJSON(bUseLimitedConnection)

'On Error Resume Next

Dim	strSQL, _
	strOrgName, _
	dUpdateSchedule, _
	strDetailLink, _
	strRPCDetailLink, _
	strAlertColumn, _
	i

If Nl(strFromSQL) Then
	Exit Sub
End If

strSQL = strParamSQL & "SELECT " & getFields(False) & vbCrLf & "FROM " & strFromSQL
If Not Nl(strWhereSQL) Then
	strSQL = strSQL & vbCrLf & "WHERE (" & strWhereSQL & ")"
End If
strSQL = strSQL & " ORDER BY " & getOrderBy()

'Response.Write("<pre>" & strSQL & "</pre>")
'Response.Flush()

cmdOrgList.CommandText = strSQL
rsOrgList.Open cmdOrgList

If Err.Number <> 0 Then
	'TODO: Add JSON Error Response
%>
{ "error": <%= JSONQs(Err.Message,True) %>, "recordset": null}
<%
	Exit Sub
End If

With rsOrgList

If .EOF Then
%>
{ "error": null, "recordset": [] }
<%
Else	
Dim bGotField
bGotField = False
%>
{ "error" : null, 
  "fields": {
<%If opt_fld_bNUM Or Not opt_fld_bOrgCIC Then%>"NUM": <%=JSONQs(TXT_RECORD_NUM, True)%><%
	bGotField=True
End If%>
<%If opt_fld_bOrgCIC Then%><%If bGotField Then%>,<%Else
bGotField=True
End If%>"ORG_NAME_FULL": <%=JSONQs(Nz(get_view_data_cic("OrgProgramNames"), TXT_ORG_NAMES), True)%><%End If%>
<%If opt_fld_bRecordOwnerCIC Then%><%If bGotField Then%>,<%Else
bGotField=True
End If%>"RECORD_OWNER": <%=JSONQs(TXT_OWNER, True)%><%End If%>
<%If opt_fld_bLocated Then%><%If bGotField Then%>,<%Else
bGotField=True
End If%>"LOCATED_IN": <%=JSONQs(TXT_LOCATED_IN, True)%><%End If%>
<%If IsArray(aCustFields) Then
	For Each indOrgFldData In aCustFields%>
<%If bGotField Then%>,<%Else
bGotField=True
End If%><%=JSONQs(indOrgFldData.fName, True)%>: <%=JSONQs(indOrgFldData.fLabel, True)%>
<%	Next
End If%>
},
"recordset" : [
<%
If .RecordCount > 10000 Then
	' If we have a lot of records, let the script timout be 10 minutes
	' This is actually driven by end browser render time, not how long
	' it takes to generate the page.
	Server.ScriptTimeout = 600
End If

i = 0

Dim fldNUM, _
	fldOrgName, _
	fldLocatedIn, _
	fldLatitude, _
	fldLongitude
	
Set fldNUM = .Fields("NUM")

If opt_fld_bOrgCIC Or (g_bMapSearchResults And Not g_bPrintMode) Then
	Set fldOrgName = .Fields("ORG_NAME_FULL")
End If

If opt_fld_bLocated Then
	Set fldLocatedIn = .Fields("LOCATED_IN")
End If

If g_bMapSearchResults And Not g_bPrintMode Then
	Set fldLatitude = .Fields("LATITUDE")
	Set fldLongitude = .Fields("LONGITUDE")
End If

Dim strAccessURL
strAccessURL = Request.ServerVariables("HTTP_HOST")

Dim strDetailLinkTemplate, strRPCDetailLinkTemplate
strDetailLinkTemplate = IIf(get_db_option("DomainDefaultViewSSLCompatibleCIC"), "https://", "http://") & strAccessURL & makeDetailsLink("[NUMNUM]",vbNullString,"UseCICVw")
strRPCDetailLinkTemplate = IIf(g_bSSL, "https://", "http://") & strAccessURL & "/" & _ 
								makeLink("rpc/record/[NUMNUM]",vbNullString,vbNullString)

Dim bCheckVolOps
bCheckVolOps = CBool(ps_intDbArea = DM_CIC And g_bUseVOL And g_bVolunteerLink)

While Not .EOF
	If opt_fld_bOrgCIC Then
		strOrgName = fldOrgName.Value
	End If
	
	strDetailLink = Replace(strDetailLinkTemplate, "[NUMNUM]", fldNUM.Value)
	strRPCDetailLink = Replace(strRPCDetailLinkTemplate, "[NUMNUM]", fldNUM.Value)

	dUpdateSchedule = Null
	If opt_fld_bUpdateScheduleCIC Then
		If Not Nl(.Fields("UPDATE_SCHEDULE")) Then
			dUpdateSchedule = DateValue(.Fields("UPDATE_SCHEDULE"))
		End If
	End If
	i = i + 1
	strAlertColumn = vbNullString
	If opt_fld_bAlertCIC Then
		If .Fields("NON_PUBLIC") Then
			strAlertColumn = strAlertColumn & "N"
		End If
		If .Fields("IS_DELETED") Then
			strAlertColumn = strAlertColumn & "X"
		ElseIf .Fields("TO_BE_DELETED") Then
			strAlertColumn = strAlertColumn & "P"
		End If
		If .Fields("HAS_COMMENTS") And user_bCommentAlertCIC Then
			strAlertColumn = strAlertColumn & "C"
		End If
		If user_bFeedbackAlertCIC Then
			If .Fields("HAS_FEEDBACK") Or .Fields("HAS_PUB_FEEDBACK") Then
				strAlertColumn = strAlertColumn & "F"
			End If
		End If
		If bCheckVolOps Then
			If .Fields("HAS_VOL_OPPS") Then
				strAlertColumn = strAlertColumn & "V"
			End If
		End If
	End If
%>
{
"NUM" : <%=JSONQs(fldNUM,True)%>
,"RECORD_DETAILS" : <%=JSONQs(strDetailLink,True)%>
,"API_RECORD_DETAILS" : <%=JSONQs(strRPCDetailLink,True)%>
<%If opt_fld_bAlertCIC Then%>
,"ALERT" : <%=JSONQs(strAlertColumn,True)%>
<%End If%>
<%If opt_fld_bRecordOwnerCIC Then%>
,"RECORD_OWNER" : <%=JSONQs(.Fields("RECORD_OWNER"),True)%>
<%End If%>
<%If opt_fld_bOrgCIC Then%>
,"ORG_NAME" : <%=JSONQs(strOrgName,True)%>
<%End If%>
<%If g_bMapSearchResults Then%>
,"LATITUDE" : <%=JSONQs(Replace(Nz(fldLatitude,"null"),",","."),False)%>
,"LONGITUDE" : <%=JSONQs(Replace(Nz(fldLongitude,"null"),",","."),False)%>
<%End If%>
<%If opt_fld_bLocated Then%>
,"LOCATED_IN_CM" : <%=JSONQs(fldLocatedIn.Value,True)%>
<%End If%>
<%If IsArray(aCustFields) Then
	For Each indOrgFldData In aCustFields%>
,"<%=indOrgFldData.fName%>" : <%=JSONQs(textToHTML(.Fields(indOrgFldData.fName)),True)%>
<%	Next
End If%>
<%If opt_fld_bUpdateScheduleCIC Then%>
,"UPDATE_SCHEDULE" : <%=JSONQs(Nz(dUpdateSchedule,TXT_UNKNOWN),True)%>
<%End If%>
}<%
	.MoveNext
	If Not .EOF Then
%>,<%
	End If
	If i Mod 500 = 0 Then
		Response.Flush
	End If
Wend
%>
] }
<%
End If 'Not .EOF
	
.Close

End With

End Sub

Public Sub makeXML(bUseLimitedConnection)

'On Error Resume Next

Dim	strSQL, _
	strOrgName, _
	dUpdateSchedule, _
	strDetailLink, _ 
	strRPCDetailLink, _
	strAlertColumn, _
	i

If Nl(strFromSQL) Then
	Exit Sub
End If

strSQL = strParamSQL & "SELECT " & getFields(False) & vbCrLf & "FROM " & strFromSQL
If Not Nl(strWhereSQL) Then
	strSQL = strSQL & vbCrLf & "WHERE (" & strWhereSQL & ")"
End If
strSQL = strSQL & " ORDER BY " & getOrderBy()

'Response.Write("<pre>" & strSQL & "</pre>")
'Response.Flush()

cmdOrgList.CommandText = strSQL
rsOrgList.Open cmdOrgList

If Err.Number <> 0 Then
%>
<root><error><%= XMLEncode(Err.Message) %></error><records/></root>
<%
End If

With rsOrgList

If .EOF Then
%>
<root><error/><recordset/></root>
<%
Else	
%>
<root>
<error/>
<recordset>
<%
If .RecordCount > 10000 Then
	' If we have a lot of records, let the script timout be 10 minutes
	' This is actually driven by end browser render time, not how long
	' it takes to generate the page.
	Server.ScriptTimeout = 600
End If

i = 0

Dim fldNUM, _
	fldOrgName, _
	fldLocatedIn, _
	fldLatitude, _
	fldLongitude
	
Set fldNUM = .Fields("NUM")

If opt_fld_bOrgCIC Or (g_bMapSearchResults And Not g_bPrintMode) Then
	Set fldOrgName = .Fields("ORG_NAME_FULL")
End If

If opt_fld_bLocated Then
	Set fldLocatedIn = .Fields("LOCATED_IN")
End If

If g_bMapSearchResults And Not g_bPrintMode Then
	Set fldLatitude = .Fields("LATITUDE")
	Set fldLongitude = .Fields("LONGITUDE")
End If

Dim strAccessURL
strAccessURL = Request.ServerVariables("HTTP_HOST") & strAccessURL

Dim strDetailLinkTemplate, strRPCDetailLinkTemplate
strDetailLinkTemplate = IIf(get_db_option("DomainDefaultViewSSLCompatibleCIC"), "https://", "http://") & strAccessURL & makeDetailsLink("[NUMNUM]",vbNullString,"UseCICVw")
strRPCDetailLinkTemplate = IIf(g_bSSL, "https://", "http://") & strAccessURL & "/" & _
								makeLink("rpc/record/[NUMNUM]","format=xml",vbNullString)

Dim bCheckVolOps
bCheckVolOps = CBool(ps_intDbArea = DM_CIC And g_bUseVOL And g_bVolunteerLink)

While Not .EOF
	If opt_fld_bOrgCIC Then
		strOrgName = fldOrgName.Value
	End If
	
	strDetailLink = Replace(strDetailLinkTemplate, "[NUMNUM]", fldNUM.Value)
	strRPCDetailLink = Replace(strRPCDetailLinkTemplate, "[NUMNUM]", fldNUM.Value)

	dUpdateSchedule = Null
	If opt_fld_bUpdateScheduleCIC Then
		If Not Nl(.Fields("UPDATE_SCHEDULE")) Then
			dUpdateSchedule = DateValue(.Fields("UPDATE_SCHEDULE"))
		End If
	End If
	i = i + 1
	strAlertColumn = vbNullString
	If opt_fld_bAlertCIC Then
		If .Fields("NON_PUBLIC") Then
			strAlertColumn = strAlertColumn & "N"
		End If
		If .Fields("IS_DELETED") Then
			strAlertColumn = strAlertColumn & "X"
		ElseIf .Fields("TO_BE_DELETED") Then
			strAlertColumn = strAlertColumn & "P"
		End If
		If .Fields("HAS_COMMENTS") And user_bCommentAlertCIC Then
			strAlertColumn = strAlertColumn & "C"
		End If
		If user_bFeedbackAlertCIC Then
			If .Fields("HAS_FEEDBACK") Or .Fields("HAS_PUB_FEEDBACK") Then
				strAlertColumn = strAlertColumn & "F"
			End If
		End If
		If bCheckVolOps Then
			If .Fields("HAS_VOL_OPPS") Then
				strAlertColumn = strAlertColumn & "V"
			End If
		End If
	End If
%>
<record NUM=<%=AttrQs(fldNUM)%>>
<%If opt_fld_bAlertCIC Then%>
<field name="ALERT"><%=XMLEncode(strAlertColumn)%></field>
<%End If%>
<%If opt_fld_bRecordOwnerCIC Then%>
<field name="RECORD_OWNER"><%=XMLEncode(.Fields("RECORD_OWNER"))%></field>
<%End If%>
<field name="RECORD_DETAILS"><%=XMLEncode(strDetailLink)%></field>
<field name="API_RECORD_DETAILS"><%=XMLEncode(strRPCDetailLink)%></field>
<%If opt_fld_bOrgCIC Then%>
<field name="ORG_NAME"><%=XMLEncode(strOrgName)%></field>
<%End If%>
<%If g_bMapSearchResults Then%>
<field name="LATITUDE"<%If Nl(fldLatitude) Then%>/><%Else%>><%=XMLEncode(Replace(fldLatitude,",","."))%></field><%End If%>
<field name="LONGITUDE"<%If Nl(fldLongitude) Then%>/><%Else%>><%=XMLEncode(Replace(fldLongitude,",","."))%></field><%End If%>
<%End If%>
<%If opt_fld_bLocated Then%>
<field name="LOCATED_IN_CM"><%=XMLEncode(fldLocatedIn.Value)%></field>
<%End If%>
<%If IsArray(aCustFields) Then
	For Each indOrgFldData In aCustFields%>
<field name=<%=AttrQs(indOrgFldData.fName)%>><%=XMLEncode(textToHTML(.Fields(indOrgFldData.fName)))%></field>
<%	Next
End If%>
<%If opt_fld_bUpdateScheduleCIC Then%>
<field name="UPDATE_SCHEDULE"><%=XMLEncode(Nz(dUpdateSchedule,TXT_UNKNOWN))%></field>
<%End If%>
</record><%
	.MoveNext
	If i Mod 500 = 0 Then
		Response.Flush
	End If
Wend
%>
</recordset></root>
<%
End If 'Not .EOF
	
.Close

End With

End Sub

Private Sub Class_Terminate()
	Set cmdOrgList = Nothing
	Set rsOrgList = Nothing
End Sub

End Class
%>
